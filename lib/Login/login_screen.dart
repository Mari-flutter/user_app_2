// login.dart
import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:user_app/Bottom_Navbar/bottom_navigation_bar.dart';

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

  bool isOtpSent = false;
  bool isSending = false;
  int resendTimer = 0;
  Timer? timer;

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
    final phone = _phoneController.text.trim();

    if (phone.length != 10) {
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

      // 1. 🔍 ATTEMPT LOGIN REQUEST FIRST
      var response = await http.post(
        Uri.parse(_loginRequestUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody.toJson()),
      );

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
        content: Text("OTP sent successfully for $mode to +91 $phone"),
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

    if (enteredOtp.isEmpty || phone.length != 10) {
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
          // ✅ Save details securely
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

          print('✅ Profile ID Saved: ${verifyResponse.profileId}');
          print('✅ Token Saved: ${verifyResponse.token}');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("$successType Successful!"),
              backgroundColor: const Color(0xff07C66A),
            ),
          );

          // ✅ Navigate to Home
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeLayout()),
          );
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

  @override
  void dispose() {
    timer?.cancel();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<String?> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: ['email'],
      clientId: "634781175675-9sr37dl784o2r8dckmd2ie9hnrsvm5e4.apps.googleusercontent.com",
    );

    // Step 1: user chooses Google account
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      print("User cancelled login");
      return null;
    }

    // Step 2: get tokens
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // Step 3: login into Firebase
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
      accessToken: googleAuth.accessToken,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);

    // Step 4: send this to backend
    print("TOKEN: ${googleAuth.idToken}");
    developer.log("TOKEN: ${googleAuth.idToken}");

    return googleAuth.idToken;
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
                SizedBox(
                  width: double.infinity,
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.number,
                    maxLength: 10,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      suffixIcon: GestureDetector(
                        onTap: (isSending || resendTimer > 0)
                            ? null
                            : sendOtp, // Disable tap while sending or waiting
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: size.height * 0.015,
                            right: size.width * 0.03,
                          ),
                          child: Text(
                            isSending
                                ? "Sending..."
                                : resendTimer > 0
                                ? "Resend (${resendTimer}s)"
                                : isOtpSent
                                ? "Resend"
                                : "Send OTP",
                            style: GoogleFonts.urbanist(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: (isSending || resendTimer > 0)
                                  ? Colors.grey
                                  : const Color(0xff201F1F),
                            ),
                          ),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: const Color(0xffCFCFCF),
                      counterText: "",
                      hintText: "Enter number",
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
                  onTap: () {
                    signInWithGoogle();
                  },
                  child: Container(
                    width: double.infinity,
                    height: 51,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9D9D9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Google Icon
                          Image.asset(
                            "assets/images/Login/google.png",
                            width: 18,
                            height: 18,
                            fit: BoxFit.contain,
                          ),
                          SizedBox(width: size.width * 0.02),
                          Text(
                            "Continue with Google",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.urbanist(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: Colors.black,
                              height: 1.0,
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
