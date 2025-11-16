// login.dart
import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:user_app/Bottom_Navbar/bottom_navigation_bar.dart';

import '../Profile/setup_profile_after_login_without_kyc_screen.dart';
import '../Services/secure_storage.dart';

class RequestOtpModel {
  final String phoneNumber;

  RequestOtpModel({required this.phoneNumber});

  Map<String, dynamic> toJson() => {'phoneNumber': phoneNumber};
}

class VerifyOtpModel {
  final String phoneNumber;
  final String otp;

  VerifyOtpModel({required this.phoneNumber, required this.otp});

  Map<String, dynamic> toJson() => {'phoneNumber': phoneNumber, 'otp': otp};
}

class VerifyOtpResponse {
  final String profileId;
  final String token;
  final String phoneNumber;
  final bool phoneVerified;

  VerifyOtpResponse({
    required this.profileId,
    required this.token,
    required this.phoneNumber,
    required this.phoneVerified,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    // 🔑 LOGIC: If a token is present in the 200 OK response, verification is successful.
    final bool verified =
        json['token'] != null && json['token'].toString().isNotEmpty;

    return VerifyOtpResponse(
      profileId: json['profileId'] ?? '',
      token: json['token'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      phoneVerified: verified,
    );
  }
}

// --- LOGIN WIDGET ---

class login extends StatefulWidget {
  const login({super.key});

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {
  // State variables and controllers
  String _sentPhoneNumber = '';
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool isGoogleSigningIn = false;
  bool isOtpSent = false;
  bool isSending = false;
  int resendTimer = 0;
  Timer? timer;
  String selectedCountryCode = "+91";

  // 🔑 NEW STATE: Tracks if the current sequence is for Registration or Login
  bool _isRegistering = false;

  // 🔑 NEW ENDPOINTS
  static const String _loginRequestUrl =
      "https://foxlchits.com/api/AuthPhoneUser/login-request-otp";
  static const String _loginVerifyUrl =
      "https://foxlchits.com/api/AuthPhoneUser/verify-otp-login";

  static const String _registerRequestUrl =
      "https://foxlchits.com/api/AuthPhoneUser/request-otp";
  static const String _registerVerifyUrl =
      "https://foxlchits.com/api/AuthPhoneUser/verify-otp-register";

  final storage = const FlutterSecureStorage();

  @override
  void sendOtp() async {
    final phone = "$selectedCountryCode${_phoneController.text.trim()}";

    if (_phoneController.text.trim().length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid 10-digit number"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      isSending = true;
      _isRegistering = false; // Start by assuming Login
    });

    try {
      final requestBody = RequestOtpModel(phoneNumber: phone);
      print(requestBody);
      // 1. 🔍 ATTEMPT LOGIN REQUEST FIRST
      var response = await http.post(
        Uri.parse(_loginRequestUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody.toJson()),
      );
      print(response.body);

      if (response.statusCode == 200) {
        // ✅ SUCCESS: User is Registered, proceed to Login Verification
        _handleOtpSuccess(response, phone, "Login");
      } else {
        // ❌ FAILURE (Non-200): User is likely NOT Registered. Attempt to Register.
        print(
          "⚠ Login OTP failed (Status ${response.statusCode}). Attempting Registration...",
        );

        // 2. 📝 ATTEMPT REGISTRATION REQUEST
        response = await http.post(
          Uri.parse(_registerRequestUrl),
          // Request OTP for new user registration
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(requestBody.toJson()),
        );

        if (response.statusCode == 200) {
          // ✅ SUCCESS: Registration OTP sent, proceed to Register Verification
          setState(() {
            _isRegistering = true; // Set flag for the verifyOtp function
          });
          _handleOtpSuccess(response, phone, "Registration");
        } else {
          // ❌ FAILURE: Registration failed (e.g., phone invalid or other server issue)
          String errorMessage = "Failed to send OTP. Please try again.";
          try {
            final errorData = jsonDecode(response.body);
            errorMessage = errorData['message'] ?? errorMessage;
          } catch (e) {
            // Response body was not JSON
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.redAccent),
      );
    } finally {
      setState(() {
        isSending = false;
      });
    }
  }

  // Helper method to handle common success logic after OTP request
  void _handleOtpSuccess(http.Response response, String phone, String mode) {
    final data = jsonDecode(response.body);
    final demoOtp = data['otp'] ?? data['otpForDemo'];
    if (demoOtp != null) {
      print("🔹 TEST OTP ($mode): $demoOtp");
    }

    setState(() {
      isOtpSent = true;
      _sentPhoneNumber = phone; // Store the phone number
      resendTimer = 30;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "OTP sent successfully for $mode to $selectedCountryCode $phone",
        ),
        backgroundColor: const Color(0xff07C66A),
      ),
    );

    // Start countdown
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (resendTimer == 0) {
        t.cancel();
      } else {
        setState(() {
          resendTimer--;
        });
      }
    });
  }

  void verifyOtp() async {
    FocusScope.of(context).unfocus();
    final enteredOtp = _otpController.text.trim();
    // Use the stored phone number from the send request
    final phone = _sentPhoneNumber.isNotEmpty
        ? _sentPhoneNumber
        : _phoneController.text.trim();

    if (enteredOtp.isEmpty || _phoneController.text.trim().length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please send and enter a valid OTP"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    try {
      final verifyBody = VerifyOtpModel(phoneNumber: phone, otp: enteredOtp);

      // Determine which API to call based on the flag set in sendOtp()
      final String verificationUrl = _isRegistering
          ? _registerVerifyUrl
          : _loginVerifyUrl;
      final String successType = _isRegistering ? "Registration" : "Login";

      final response = await http.post(
        Uri.parse(verificationUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(verifyBody.toJson()),
      );

      if (response.statusCode == 200) {
        final verifyResponse = VerifyOtpResponse.fromJson(
          jsonDecode(response.body),
        );

        // Since the model verifies success by token presence in a 200 OK response,
        // we can safely proceed.
        if (verifyResponse.phoneVerified) {
          await storage.write(
            key: 'profileId',
            value: verifyResponse.profileId,
          );
          await storage.write(key: 'token', value: verifyResponse.token);
          await storage.write(
            key: 'phoneNumber',
            value: verifyResponse.phoneNumber,
          );
          await storage.write(key: 'loginType', value: 'phone');
          await SecureStorageService.updateUserAndReferIdsFromApi();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("$successType Successful!"),
              backgroundColor: const Color(0xff07C66A),
            ),
          );

          if (_isRegistering) {
            // New user → go setup screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => setup_profile_after_login_without_kyc_screen(),
              ),
            );
          } else {
            // Existing user → go home
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomeLayout()),
            );
          }
        } else {
          // This case should ideally not be hit with the current API response logic,
          // but included as a safeguard.
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Verification failed despite 200 OK."),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } else {
        // ❌ Non-200 Status Code Error Handling (Invalid OTP, Expired, etc.)
        print("🚨 Verification Failed Status Code: ${response.statusCode}");
        print("🚨 Verification Failed Response Body: ${response.body}");

        String errorMessage = "Invalid OTP for $successType. Please try again.";
        try {
          final errorData = jsonDecode(response.body);
          errorMessage =
              errorData['message'] ?? errorData['error'] ?? errorMessage;
        } catch (e) {
          // If response body is not JSON, use the default message
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error verifying OTP: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<bool> isNewUser(String profileId, String token) async {
    final url = Uri.parse(
      "https://foxlchits.com/api/Profile/profile/$profileId",
    );

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final String name = data["name"] ?? "";
      final String gender = data["gender"] ?? "";
      final String dob = data["dateofBirth"] ?? "";
      final String address = data["address"] ?? "";
      final String email = data["email"] ?? ""; // ✔ added

      // If any essential field is missing → user is NEW
      if (name.isEmpty ||
          gender.isEmpty ||
          dob.isEmpty ||
          address.isEmpty ||
          email.isEmpty) {
        // ✔ added
        return true; // NEW USER
      } else {
        return false; // EXISTING USER
      }
    }

    return true; // default assume new user if unable to fetch profile
  }

  @override
  void dispose() {
    timer?.cancel();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> signInWithGoogle() async {
    try {
      setState(() {
        isGoogleSigningIn = true;
      });

      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email'],
        clientId:
            "634781175675-9sr37dl784o2r8dckmd2ie9hnrsvm5e4.apps.googleusercontent.com",
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        setState(() => isGoogleSigningIn = false);
        print("User cancelled login");
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final String? idToken = googleAuth.idToken;

      developer.log("GOOGLE TOKEN: $idToken");

      // 🔥 Step 2 — Send token to your backend
      final url = Uri.parse("https://foxlchits.com/api/Account/google-login");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"idToken": idToken}),
      );
      print("🌐 GOOGLE LOGIN API RESPONSE => ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Extract token correctly
        final String jwtToken = data["token"]["result"] ?? "";
        final String profileId = data["profile"]["id"];

        await storage.write(key: "profileId", value: profileId);
        await storage.write(key: "token", value: jwtToken);
        await storage.write(key: "loginType", value: "google");

        await SecureStorageService.updateUserAndReferIdsFromApi();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Google Login Successful!"),
            backgroundColor: const Color(0xff07C66A),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const setup_profile_after_login_without_kyc_screen(),
          ),
        );
      }
      else {
        String msg = "Google login failed";

        try {
          msg = jsonDecode(response.body)["message"] ?? msg;
        } catch (_) {}
        print(msg);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
        );
      }
    } catch (e) {
      print("error:$e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Google sign-in error: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() => isGoogleSigningIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... (Your existing UI code remains the same)
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: size.height * 0.02),
                Center(
                  child: Image.asset(
                    "assets/images/Login/login.png",
                    width: 338,
                    height: 338,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: size.height * 0.04),
                Text(
                  "Enter Mobile Number",
                  style: GoogleFonts.urbanist(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: const Color(0xFF7E7E7E),
                  ),
                ),
                SizedBox(height: size.height * 0.01),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        showCountryPicker(
                          context: context,
                          showPhoneCode: true,

                          countryListTheme: CountryListThemeData(
                            // 🔻 Background of the drawer
                            backgroundColor: Colors.black,

                            // 🔻 Text color inside picker
                            textStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),

                            // 🔻 Height (reduced drawer size)
                            bottomSheetHeight: MediaQuery.of(context).size.height * 0.50,

                            // 🔻 Rounded top corners
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                            // 🔻 Reduce padding and row height
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            margin: const EdgeInsets.only(top: 10),
                            flagSize: 22, // Smaller flags
                          ),

                          onSelect: (Country country) {
                            setState(() {
                              selectedCountryCode = "+${country.phoneCode}";
                            });
                          },
                        );

                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        margin: EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Color(0xffCFCFCF),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black26, width: 0.8),
                        ),
                        child: Text(
                          selectedCountryCode,
                          style: GoogleFonts.urbanist(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),

                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.number,
                        maxLength: 10,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          suffixIcon: GestureDetector(
                            onTap: (isSending || resendTimer > 0)
                                ? null
                                : sendOtp,
                            child: Container(
                              padding: EdgeInsets.only(top: 15, right: 10),
                              child: Text(
                                isSending
                                    ? "Sending..."
                                    : resendTimer > 0
                                    ? "Resend (${resendTimer}s)"
                                    : isOtpSent
                                    ? "Resend"
                                    : "Send OTP",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: (isSending || resendTimer > 0)
                                      ? Colors.grey
                                      : Colors.black,
                                ),
                              ),
                            ),
                          ),
                          filled: true,
                          fillColor: Color(0xffCFCFCF),
                          counterText: "",
                          hintText: "Enter number",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.02),
                // 🔹 Enter OTP
                Text(
                  "Enter OTP",
                  style: GoogleFonts.urbanist(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: const Color(0xFF7E7E7E),
                  ),
                ),
                SizedBox(height: size.height * 0.01),
                // 🔹 OTP Field
                SizedBox(
                  width: double.infinity,
                  child: TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: const Color(0xffCFCFCF),
                      counterText: "",
                      border: InputBorder.none,
                      hintText: "Enter OTP",
                      hintStyle: GoogleFonts.urbanist(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: const Color(0xFF7E7E7E),
                      ),
                    ),
                    cursorColor: Colors.black,
                    style: GoogleFonts.urbanist(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: const Color(0xff7E7E7E),
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.04),
                // 🔹 Continue Button
                Align(
                  alignment: Alignment.bottomRight,
                  child: GestureDetector(
                    onTap: verifyOtp, // Calls the verification function

                    child: Container(
                      width: 52,
                      height: 52,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF686763),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Color(0xffFFFFFF),
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.08),

                // 🔹 Continue with Google Button
                GestureDetector(
                  onTap: isGoogleSigningIn ? null : () => signInWithGoogle(),
                  child: Container(
                    width: double.infinity,
                    height: 51,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9D9D9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: isGoogleSigningIn
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "Signing in...",
                                  style: GoogleFonts.urbanist(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  "assets/images/Login/google.png",
                                  width: 18,
                                  height: 18,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "Continue with Google",
                                  style: GoogleFonts.urbanist(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
