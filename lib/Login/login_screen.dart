import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:user_app/Bottom_Navbar/bottom_navigation_bar.dart';

import '../Models/Login/request_otp.dart';
import '../Models/Login/verify_otp.dart';

class login extends StatefulWidget {
  const login({super.key});

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {
  String? backendOtp;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool isOtpSent = false;
  bool isSending = false;
  int resendTimer = 0;
  Timer? timer;

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
    });

    try {
      //  Create model object
      final requestBody = RequestOtpModel(phoneNumber: phone);

      //  Make API call
      final response = await http.post(
        Uri.parse("https://foxlchits.com/api/AuthPhoneUser/request-otp"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody.toJson()), //  using model
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final demoOtp = data['otp'] ?? data['otpForDemo'];
        if (demoOtp != null) {
          print("🔹 TEST OTP: $demoOtp");
          backendOtp = demoOtp.toString(); // store it for verification
        } else {
          print("⚠️ OTP not found in response: $data");
        }

        // success
        setState(() {
          isOtpSent = true;
          resendTimer = 30;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("OTP sent successfully to +91 $phone"),
            backgroundColor: const Color(0xff07C66A),
          ),
        );

        // start countdown
        timer = Timer.periodic(const Duration(seconds: 1), (t) {
          if (resendTimer == 0) {
            t.cancel();
          } else {
            setState(() {
              resendTimer--;
            });
          }
        });
      } else {
        // failure
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to send OTP. Please try again."),
            backgroundColor: Colors.redAccent,
          ),
        );
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

  final storage = FlutterSecureStorage();

  void verifyOtp() async {
    FocusScope.of(context).unfocus();
    final enteredOtp = _otpController.text.trim();
    final phone = _phoneController.text.trim();

    if (enteredOtp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter OTP"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    try {
      final verifyBody = VerifyOtpModel(phoneNumber: phone, otp: enteredOtp);

      final response = await http.post(
        Uri.parse(
          "https://foxlchits.com/api/AuthPhoneUser/verify-otp-register",
        ),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(verifyBody.toJson()),
      );

      if (response.statusCode == 200) {
        final verifyResponse = VerifyOtpResponse.fromJson(
          jsonDecode(response.body),
        );

        if (verifyResponse.phoneVerified) {
          // ✅ Save details securely for later use
          await storage.write(
            key: 'profileId',
            value: verifyResponse.profileId,
          );
          await storage.write(key: 'token', value: verifyResponse.token);
          await storage.write(
            key: 'phoneNumber',
            value: verifyResponse.phoneNumber,
          );

          // After phone OTP verification:
          await storage.write(key: 'loginType', value: 'phone');

          // After email login:
          await storage.write(key: 'loginType', value: 'email');

          print('✅ Profile ID Saved: ${verifyResponse.profileId}');
          print('✅ Token Saved: ${verifyResponse.token}');

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("OTP Verified Successfully"),
              backgroundColor: Color(0xff07C66A),
            ),
          );

          // ✅ Navigate to Home
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomeLayout()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("OTP verification failed"),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Invalid OTP. Please try again."),
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

  @override
  Widget build(BuildContext context) {
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
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Color(0xffCFCFCF),
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
                    onTap: () {
                      // final otp = _otpController.text.trim();
                      // final phone = _phoneController.text.trim();
                      //
                      // if (otp.isEmpty) {
                      //   ScaffoldMessenger.of(context).showSnackBar(
                      //     const SnackBar(
                      //       content: Text("Please enter OTP"),
                      //       backgroundColor: Colors.redAccent,
                      //     ),
                      //   );
                      //   return;
                      // }
                      //
                      // try {
                      //   final verifyBody = VerifyOtpModel(
                      //     phoneNumber: phone,
                      //     otp: otp,
                      //   );
                      //
                      //   final response = await http.post(
                      //     Uri.parse(
                      //       "https://foxlchits.com/api/AuthPhoneUser/verify-otp",
                      //     ),
                      //     headers: {"Content-Type": "application/json"},
                      //     body: jsonEncode(verifyBody.toJson()),
                      //   );
                      //
                      //   if (response.statusCode == 200) {
                      //     // ✅ OTP Verified successfully
                      //     ScaffoldMessenger.of(context).showSnackBar(
                      //       const SnackBar(
                      //         content: Text("OTP Verified Successfully"),
                      //         backgroundColor: Color(0xff07C66A),
                      //       ),
                      //     );
                      //
                      //     Navigator.pushReplacement(
                      //       context,
                      //       MaterialPageRoute(
                      //         builder: (context) => HomeLayout(),
                      //       ),
                      //     );
                      //   } else {
                      //     // ❌ Wrong OTP or expired
                      //     ScaffoldMessenger.of(context).showSnackBar(
                      //       const SnackBar(
                      //         content: Text("Invalid OTP. Please try again."),
                      //         backgroundColor: Colors.redAccent,
                      //       ),
                      //     );
                      //   }
                      // } catch (e) {
                      //   ScaffoldMessenger.of(context).showSnackBar(
                      //     SnackBar(
                      //       content: Text("Error verifying OTP: $e"),
                      //       backgroundColor: Colors.redAccent,
                      //     ),
                      //   );
                      // }
                      verifyOtp();
                    },

                    child: Container(
                      width: 52,
                      height: 52,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF686763),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: const Icon(
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
