import 'dart:convert';

import 'package:country_picker/country_picker.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:user_app/Bottom_Navbar/bottom_navigation_bar.dart';


import '../Models/Profile/set_up_profile.dart';
import '../Services/secure_storage.dart';

import 'animation_screen.dart';


class setup_profile_after_login_without_kyc_screen extends StatefulWidget {
  final VoidCallback? onKycCompleted; // 👈 add this line

  const setup_profile_after_login_without_kyc_screen({super.key, this.onKycCompleted});

  @override
  State<setup_profile_after_login_without_kyc_screen> createState() => _setup_profile_after_login_without_kyc_screenState();
}

class _setup_profile_after_login_without_kyc_screenState extends State<setup_profile_after_login_without_kyc_screen> {
  String selectedCountryCode = "+91";
  bool isExpanded = false;
  Image? selected_Image;
  String? selectedValue;
  DateTime? _selectedDate;

  final storage = FlutterSecureStorage();
  String? _fcmToken;
  String? profileId; // to hold the stored id
  String signupType = "";

  late Future<SetupProfile> profileFuture;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final addressController = TextEditingController();

  final phoneOtpController = TextEditingController();
  final emailOtpController = TextEditingController();

  bool phoneOtpSent = false;
  bool phoneOtpVerified = false;
  bool isSendingPhoneOtp = false;

  bool emailOtpSent = false;
  bool emailOtpVerified = false;
  bool isSendingEmailOtp = false;

  bool isVerifyingPhoneOtp = false;
  bool isVerifyingEmailOtp = false;


  @override
  void initState() {
    super.initState();
    _getToken();
    _loadProfileId(); // call this first
  }

// ---------------- PHONE OTP ------------------

  Future<void> requestPhoneOtp() async {
    if (mobileController.text.isEmpty) return;

    setState(() => isSendingPhoneOtp = true);
    final Token = await SecureStorageService.getToken();
    final url = Uri.parse(
      "https://foxlchits.com/api/Profile/$profileId/request-phone-otp",
    );

    final body = {"phoneNumber": "$selectedCountryCode${mobileController.text.trim()}",
    };

    final response = await http.post(url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $Token",
        },
        body: jsonEncode(body));

    setState(() => isSendingPhoneOtp = false);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data["phoneVerified"] == true) {
        phoneOtpVerified = true;

        // JUST CALL THIS — NO showDialog()
        showBottomInfo("User already registered");

        setState(() {});
        return;
      }

      // Normal OTP
      phoneOtpSent = true;
      setState(() {});
    } else {
      showBottomInfo("User already registered");
      return;
    }
  }


  Future<void> verifyPhoneOtp() async {
    setState(() => isVerifyingPhoneOtp = true);
    final Token = await SecureStorageService.getToken();
    final url = Uri.parse(
      "https://foxlchits.com/api/Profile/$profileId/verify-phone-otp",
    );

    final body = {
      "phoneNumber": "$selectedCountryCode${mobileController.text.trim()}",
      "otp": phoneOtpController.text.trim()
    };
    final raw = mobileController.text.trim();
    if (raw.length != 10) {
      _showMessage("Enter valid 10 digit mobile number");
      setState(() => isSendingPhoneOtp = false);
      return;
    }

    final response = await http.post(url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $Token",
        },
        body: jsonEncode(body));

    setState(() => isVerifyingPhoneOtp = false);

    if (response.statusCode == 200) {
      phoneOtpVerified = true;
      setState(() {});
      _showMessage("Phone Verified");
    } else {
      _showMessage("Invalid Phone OTP");
    }
  }

  // ---------------- EMAIL OTP ------------------
  Future<void> requestEmailOtp() async {
    if (emailController.text.isEmpty) return;

    setState(() => isSendingEmailOtp = true);
    final Token = await SecureStorageService.getToken();
    final url = Uri.parse(
      "https://foxlchits.com/api/Profile/$profileId/request-email-otp",
    );

    final body = {"email": emailController.text.trim()};

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $Token",
      },
      body: jsonEncode(body),
    );

    setState(() => isSendingEmailOtp = false);

    if (response.statusCode != 200) {
      showBottomInfo("User already registered");
      return;
    }

    final data = jsonDecode(response.body);

    if (data["emailVerified"] == true) {
      emailOtpVerified = true;
      showBottomInfo("User already registered");
      setState(() {});
      return;
    }

    emailOtpSent = true;
    setState(() {});
  }



  Future<void> verifyEmailOtp() async {
    setState(() => isVerifyingEmailOtp = true);
    final Token = await SecureStorageService.getToken();
    final url = Uri.parse(
      "https://foxlchits.com/api/Profile/$profileId/verify-email-otp",
    );

    final body = {
      "email": emailController.text.trim(),
      "otp": emailOtpController.text.trim()
    };

    final response = await http.post(url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $Token",
        },
        body: jsonEncode(body));

    setState(() => isVerifyingEmailOtp = false);

    if (response.statusCode == 200) {
      emailOtpVerified = true;
      setState(() {});
      _showMessage("Email Verified");
    } else {
      _showMessage("Invalid Email OTP");
    }
  }


  void _showMessage(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _getToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request permission (for iOS)
    await messaging.requestPermission();

    // Get the token
    String? token = await messaging.getToken();
    setState(() {
      _fcmToken = token;
    });

    print("FCM Token: $_fcmToken");
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> loadProfile() async {
    final Token = await SecureStorageService.getToken();
    final response = await http.get(
      Uri.parse("https://foxlchits.com/api/Profile/profile/$profileId"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $Token",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final phone = data['phoneNumber'] ?? '';

      setState(() {
        // NAME
        nameController.text = data['name'] ?? '';

        // EMAIL
        emailController.text = data['email'] ?? '';

        // ----------------------------
        //   PHONE + COUNTRY CODE FIX
        // ----------------------------
        if (phone.startsWith('+')) {
          final digitsOnly = phone.replaceAll(RegExp('[^0-9]'), '');

          if (digitsOnly.length >= 11) {
            // Country code = everything except last 10 digits
            selectedCountryCode =
            "+${digitsOnly.substring(0, digitsOnly.length - 10)}";

            // Mobile number = last 10 digits
            mobileController.text =
                digitsOnly.substring(digitsOnly.length - 10);
          } else {
            // Invalid backend format → fallback
            selectedCountryCode = "+91";
            mobileController.text = "";
          }
        } else {
          // No +code from backend → fallback
          selectedCountryCode = "+91";
          mobileController.text = phone;
        }

        // ADDRESS
        addressController.text = data['address'] ?? '';

        // SIGNUP TYPE (Google / Phone)
        signupType = data['signupType'] ?? "";

        // GENDER
        selectedValue = data['gender'] ?? '';

        // VERIFIED STATUS
        phoneOtpVerified = data['phoneVerified'] ?? false;
        emailOtpVerified = data['emailVerified'] ?? false;

        // DATE OF BIRTH
        if (data['dateofBirth'] != null && data['dateofBirth'].toString().isNotEmpty) {
          _selectedDate = DateTime.parse(data['dateofBirth']);
        }
      });
    }
  }


  Future<void> updateProfile(SetupProfile profile) async {
    final Token = await SecureStorageService.getToken();
    final url = Uri.parse("https://foxlchits.com/api/Profile/$profileId");

    final response = await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $Token",
      },
      body: jsonEncode(profile.toJson()),
    );

    if (response.statusCode == 200) {
      print("✅ Profile updated successfully");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully")),
      );
    } else {
      print("❌ Failed to update profile: ${response.statusCode}");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to update profile")));
    }
  }

  Future<void> saveFcmToken() async {
    if (profileId == null || _fcmToken == null) {
      print("⚠ Cannot save FCM token — missing profileId or token");
      return;
    }
    final Token = await SecureStorageService.getToken();
    final url = Uri.parse("https://foxlchits.com/api/Notification/profile/save-token");

    final body = {
      "userId": profileId,
      "fcmToken": _fcmToken,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $Token",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print("✅ FCM token saved successfully for user $profileId");
      } else {
        print("❌ Failed to save FCM token: ${response.statusCode}");
        print("Response: ${response.body}");
      }
    } catch (e) {
      print("🚨 Error saving FCM token: $e");
    }
  }

  Future<void> _loadProfileId() async {
    profileId = await storage.read(key: 'profileId');
    print('📦 Loaded profileId: $profileId');

    if (profileId != null) {
      await loadProfile(); // ✅ only now load the profile
    }
  }

  Future<String> getDiditSessionUrl(String userId) async {
    if (userId.isEmpty) {
      throw Exception("User ID is empty. Cannot initiate KYC session.");
    }
    final Token = await SecureStorageService.getToken();
    const url = "https://foxlchits.com/api/KYCDidit/Profile-kyc-create-session"; // Assuming the same endpoint accepts the User ID

    try {
      // Encode the ID as a raw JSON string ("GUID")
      String jsonString = jsonEncode(userId.trim());
      List<int> bodyBytes = utf8.encode(jsonString);

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          'Accept': 'application/json',
          "Authorization": "Bearer $Token",
        },
        body: bodyBytes,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final sessionUrl = data['url'] as String?;

        if (sessionUrl != null && sessionUrl.isNotEmpty) {
          return sessionUrl;
        }
        throw Exception("API response missing or invalid 'url' field. Body: ${response.body}");
      } else {
        print("DIDIT API Error Response Body: ${response.body}");
        throw Exception(
            "Failed to get DIDIT session URL. Status: ${response.statusCode}");
      }
    } catch (e) {
      print("Error getting DIDIT session URL: $e");
      rethrow;
    }
  }




  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    addressController.dispose();
    phoneOtpController.dispose();
    emailOtpController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Color(0xff000000),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: size.height * 0.02),
                const SupportText(
                  text: 'Set up your Profile',
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: appclr.profile_clr1,
                  fontType: FontType.urbanist,
                ),
                SizedBox(height: size.height * 0.04),
                const SupportText(
                  text: 'Enter your Name (as per ID)',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: appclr.profile_clr2,
                  fontType: FontType.urbanist,
                ),
                SizedBox(height: size.height * 0.015),
                inputTextField('', nameController, (value) {
                  if (value == null || value.isEmpty) {
                    return "This field cannot be empty";
                  }
                  return null;
                }),
                SizedBox(height: size.height * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SupportText(
                      text: 'Date of Birth',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: appclr.profile_clr2,
                      fontType: FontType.urbanist,
                    ),
                    SizedBox(width: size.width * 0.26),
                    const SupportText(
                      text: 'Gender',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: appclr.profile_clr2,
                      fontType: FontType.urbanist,
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.015),
                calendarandgender(),
                SizedBox(height: size.height * 0.02),
                const SupportText(
                  text: 'Mobile Number',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: appclr.profile_clr2,
                  fontType: FontType.urbanist,
                ),
                SizedBox(height: size.height * 0.015),
                Container(
                  child: Column(
                    children: [
                      Container(
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xff323232)),
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(width: size.width * 0.06),
                                  Opacity(
                                    opacity: signupType == "Google" && !phoneOtpVerified ? 1.0 : 0.5,
                                    child: GestureDetector(
                                      onTap: signupType == "Google" && !phoneOtpVerified
                                          ? () {
                                        showCountryPicker(
                                          context: context,
                                          showPhoneCode: true,
                                          onSelect: (Country country) {
                                            setState(() {
                                              selectedCountryCode = "+${country.phoneCode}";
                                            });
                                          },
                                        );
                                      }
                                          : null,
                                      child: Text(
                                        selectedCountryCode,
                                        style: GoogleFonts.urbanist(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: size.width * 0.06),
                                  Container(
                                    height: size.height * 0.05,
                                    width: 1,
                                    color: const Color(0xffADADAD),
                                  ),
                                  SizedBox(width: size.width * 0.06),
                                  Expanded(
                                    child: TextFormField(
                                      controller: mobileController,
                                      enabled: !(signupType == "Phone") && !phoneOtpVerified,
                                      style: const TextStyle(color: Colors.white),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: size.width * 0.02,
                                          vertical: size.height * 0.02,
                                        ),
                                        hintText: "Enter mobile number",
                                        hintStyle: GoogleFonts.urbanist(
                                          color: const Color(0xffFFFFFF),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      keyboardType: TextInputType.phone,
                                    ),
                                  ),

                                  // PHONE OTP button (only for users who signed up with Email)
                                  if (signupType == "Google" && !phoneOtpVerified)
                                    TextButton(
                                      onPressed: isSendingPhoneOtp ? null : requestPhoneOtp,
                                      child: Text(
                                        isSendingPhoneOtp
                                            ? "Sending..."
                                            : phoneOtpSent
                                            ? "Resend"
                                            : "Send OTP",
                                        style: const TextStyle(color: appclr.blue),
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            // PHONE OTP input below (compact)
                            if (signupType == "Google" && phoneOtpSent && !phoneOtpVerified) ...[
                              SizedBox(height: 10),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: const Color(0xff323232)),
                                  borderRadius: BorderRadius.circular(11),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: phoneOtpController,
                                        style: const TextStyle(color: Colors.white),
                                        decoration: const InputDecoration(
                                          hintText: "Enter OTP",
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                                        ),
                                        keyboardType: TextInputType.number,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: isVerifyingPhoneOtp ? null : verifyPhoneOtp,
                                      child: Text(
                                        isVerifyingPhoneOtp ? "Verifying..." : "Verify",
                                        style: const TextStyle(color: appclr.blue),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SupportText(
                            text: 'Enter your Mail ID',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: appclr.profile_clr2,
                            fontType: FontType.urbanist,
                          ),
                          SizedBox(height: size.height * 0.015),

                          // Email input (keeps your inputTextField)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              inputTextField(
                                "",
                                emailController,
                                    (value) {
                                  if (value == null || value.isEmpty) return "Enter email";
                                  return null;
                                },
                                // suffixIcon only when signupType == "Phone"
                                suffixIcon: (signupType == "Phone")
                                    ? (!emailOtpVerified
                                    ? TextButton(
                                  onPressed: isSendingEmailOtp ? null : requestEmailOtp,
                                  child: Text(
                                    isSendingEmailOtp ? "Sending..." : (emailOtpSent ? "Resend" : "Send OTP"),
                                    style: const TextStyle(color: appclr.blue),
                                  ),
                                )
                                    : const Icon(Icons.check, color: Colors.green))
                                    : null,
                              ),

                              // Email OTP input below
                              if (signupType == "Phone" && emailOtpSent && !emailOtpVerified) ...[
                                SizedBox(height: 10),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: const Color(0xff323232)),
                                    borderRadius: BorderRadius.circular(11),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: emailOtpController,
                                          style: const TextStyle(color: Colors.white),
                                          decoration: const InputDecoration(
                                            hintText: "Enter Email OTP",
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.symmetric(horizontal: 12),
                                          ),
                                          keyboardType: TextInputType.number,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: isVerifyingEmailOtp ? null : verifyEmailOtp,
                                        child: Text(
                                          isVerifyingEmailOtp ? "Verifying..." : "Verify",
                                          style: const TextStyle(color: appclr.blue),
                                        ),
                                      ),

                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                          SizedBox(height: size.height * 0.02),
                          const SupportText(
                            text: 'Address',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: appclr.profile_clr2,
                            fontType: FontType.urbanist,
                          ),
                          SizedBox(height: size.height * 0.015),
                          inputTextField('', addressController, (value) {
                            if (value == null || value.isEmpty) {
                              return "This field cannot be empty";
                            }
                            return null;
                          }),
                        ],
                      ),
                      SizedBox(height: size.height * 0.04),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: loginbutton(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  inputTextField(
      String hintText,
      TextEditingController controller,
      String? Function(String?) validator, {
        Widget? suffixIcon,
        bool obscureText = false,
      }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      keyboardType: TextInputType.text,
      style: GoogleFonts.urbanist(
        color: Color(0xffADADAD), // your desired color
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.black,
        hintText: hintText,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(
            color: Color(0xFF323232), // Added border color
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(
            color: Color(0xFF323232), // Border color when not focused
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: Color(0xFF323232), width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(
            color: Color.fromARGB(220, 166, 42, 42),
            width: 1.0,
          ),
        ),
      ),
    );
  }

  calendarandgender() {
    Size size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Picker
            Expanded(
              child: Container(
                height: size.height * 0.06,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xff323232), width: 1),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _pickDate(context),
                        child: SupportText(
                          text: _selectedDate == null
                              ? 'Select Date'
                              : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: appclr.profile_clr1,
                          fontType: FontType.urbanist,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _pickDate(context),
                      child: Image.asset(
                        'assets/images/Profile/calender.png',
                        height: size.height * 0.03,
                        width: size.width * 0.06,
                        color: appclr.profile_clr2,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(width: size.width * 0.04),

            // Gender selector
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isExpanded = !isExpanded;
                      });
                    },
                    child: Container(
                      height: size.height * 0.06,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xff323232), width: 1),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: SupportText(
                              text: selectedValue ?? "Select Gender",
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: appclr.profile_clr1,
                              fontType: FontType.urbanist,
                            ),
                          ),
                          Image.asset(
                            isExpanded
                                ? 'assets/images/Profile/gender_up.png'
                                : 'assets/images/Profile/gender_down.png',
                            height: size.height * 0.03,
                            width: size.width * 0.06,
                            color: appclr.profile_clr2,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Dropdown expands below gender selector
                  if (isExpanded)
                    Container(
                      width: size.width * 0.45,
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Color(0xff141414),
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(color: Color(0xff323232), width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selected_Image = Image.asset(
                                  'assets/images/Profile/male.png',
                                  width: 16,
                                  height: 16,
                                );
                                selectedValue = "Male";
                                isExpanded = false;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                                horizontal: 12,
                              ),
                              child: Row(
                                children: [
                                  Image.asset(
                                    'assets/images/Profile/male.png',
                                    width: 16,
                                    height: 16,
                                  ),
                                  SizedBox(width: size.width * 0.03),
                                  const Text(
                                    "Male",
                                    style: TextStyle(
                                      color: Color(0xffADADAD),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selected_Image = Image.asset(
                                  'assets/images/Profile/female.png',
                                  width: 16,
                                  height: 16,
                                );
                                selectedValue = "Female";
                                isExpanded = false;
                              });
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 8.0,
                                horizontal: 12,
                              ),
                              child: Row(
                                children: [
                                  Image.asset(
                                    'assets/images/Profile/female.png',
                                    width: 16,
                                    height: 16,
                                  ),
                                  SizedBox(width: size.width * 0.03),
                                  const Text(
                                    "Female",
                                    style: TextStyle(
                                      color: Color(0xffADADAD),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget mobileTextField() {
    Size size = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xff323232)),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        children: [
          SizedBox(width: size.width * 0.06),

          // Country Code
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.02,
              vertical: size.height * 0.02,
            ),
            child: const SupportText(
              text: '+91',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: appclr.profile_clr1,
              fontType: FontType.urbanist,
            ),
          ),

          SizedBox(width: size.width * 0.06),

          // Vertical Divider Line
          Container(
            height: size.height * 0.05,
            width: 1,
            color: const Color(0xffADADAD),
          ),

          SizedBox(width: size.width * 0.06),

          // Mobile Number Input
          Expanded(
            child: TextFormField(
              controller: mobileController,
              enabled: !(signupType == "Phone"), // Phone signup → skip OTP
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.02,
                  vertical: size.height * 0.02,
                ),
                hintText: "Enter mobile number",
                hintStyle: GoogleFonts.urbanist(
                  color: Color(0xffFFFFFF),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              keyboardType: TextInputType.phone,
            ),
          ),

          // ================================================
          // NEW OTP BUTTON (ONLY for signupType = Email)
          // ================================================
          if (signupType == "Email" && !phoneOtpVerified)
            TextButton(
              onPressed: isSendingPhoneOtp ? null : requestPhoneOtp,
              child: Text(
                isSendingPhoneOtp
                    ? "Sending..."
                    : phoneOtpSent
                    ? "Resend"
                    : "Send OTP",
                style: const TextStyle(color: appclr.blue),
              ),
            ),

          // If signupType = Phone → show nothing
        ],
      ),
    );
  }


  Widget otptextfield() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xff323232)),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: phoneOtpController,     // <-- UPDATED
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                hintText: "Enter OTP",          // <-- ADDED
                hintStyle: TextStyle(color: Colors.white54),
              ),
              keyboardType: TextInputType.number,
            ),
          ),

          TextButton(
            onPressed: verifyPhoneOtp,            // <-- UPDATED
            child: AnimatedGradientText(
              text: "Verify",
              style: GoogleFonts.urbanist(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              colors: const [Colors.blue, Colors.black],
            ),
          ),
        ],
      ),
    );
  }


  loginbutton() {

    return GestureDetector(
      onTap: () async {
        // -----------------------------
        // VALIDATION BEFORE SUBMIT
        // -----------------------------

        // If user registered using phone → email must be verified
        if (signupType == "Phone" && !emailOtpVerified) {
          _showMessage("Please verify your email before proceeding");
          return;
        }

        // If user registered using email → phone must be verified
        if (signupType == "Email" && !phoneOtpVerified) {
          _showMessage("Please verify your phone number before proceeding");
          return;
        }

        // -----------------------------
        // BUILD DATA
        // -----------------------------
        final setupProfileData = SetupProfile(
          id: profileId ?? '',
          userID: "",
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          phoneNumber: "$selectedCountryCode${mobileController.text.trim()}",  // ✅ FIXED
          address: addressController.text.trim(),
          gender: selectedValue ?? "",
          dateOfBirth: _selectedDate != null
              ? "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}"
              : "",
          signupType: signupType ?? "",
          phoneVerified: phoneOtpVerified,
          emailVerified: emailOtpVerified,
          joinDate: "",
          kycVerification: false,
          referBy: "",
        );


        // -----------------------------
        // API CALL
        // -----------------------------
        try {
          // 1️⃣ PUT API: Save all updated profile details first
          await updateProfile(setupProfileData);

          // 2️⃣ POST FCM token (if not done in init)
          await saveFcmToken();

          // 3️⃣ Call KYC API to get the session URL
          final kycUrl = await getDiditSessionUrl(profileId!);

          // 4️⃣ Navigate to the In-App Webview screen
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>HomeLayout()
            ),
          );

          // 5️⃣ Notify parent/pop back (This happens AFTER the KYC webview is closed)
          if (widget.onKycCompleted != null) {
            widget.onKycCompleted!();
          }

          // Since the KYC Webview screen handles popping itself upon completion/failure,
          // we should not pop here unless we want to close this setup screen immediately.
          // Let's assume you want to remain here until the user is manually verified
          // and the parent handles the final navigation based on status.

        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("KYC setup failed: ${e.toString().split(':').last.trim()}")),
          );
        }
      },

      child: Container(
        height: 38,
        width: 162,
        decoration: BoxDecoration(
          color: const Color(0xff2563EB).withOpacity(.9),
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Center(
          child: SupportText(
            text: 'Continue',
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: appclr.profile_clr1,
            fontType: FontType.urbanist,
          ),
        ),
      ),
    );
  }


  void showBottomInfo(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        backgroundColor: const Color(0xff2563EB),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

}

enum FontType { urbanist }

class SupportText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;
  final FontType fontType;
  final VoidCallback? onTap;

  const SupportText({
    super.key,
    required this.text,
    required this.fontSize,
    required this.fontWeight,
    required this.color,
    this.textAlign,
    this.overflow,
    this.maxLines,
    required this.fontType,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle style;

    switch (fontType) {
      case FontType.urbanist:
        style = GoogleFonts.poppins(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
        );
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: style,
        textAlign: textAlign,
        overflow: overflow,
        maxLines: maxLines,
      ),
    );
  }
}

class appclr {
  static const Color profile_clr1 = Color(0xffFFFFFF);
  static const Color profile_clr2 = Color(0xffADADAD);
  static const Color bg = Colors.black;
  static const Color blue = Color(0xff2563EB);
  static const Color dblue = Color(0xff1088FF);
  static const Color lightpink = Color(0xffCAB4B4);
  static const Color lightgrey = Color(0xff737373);
}