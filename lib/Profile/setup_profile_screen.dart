import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:user_app/Profile/kyc_verified.dart';

import '../Models/Profile/set_up_profile.dart';
import 'animation_screen.dart';

class setup_profile extends StatefulWidget {
  final VoidCallback? onKycCompleted; // 👈 add this line

  const setup_profile({super.key, this.onKycCompleted});

  @override
  State<setup_profile> createState() => _setup_profileState();
}

class _setup_profileState extends State<setup_profile> {
  String? _fcmToken;
  bool isExpanded = false;
  Image? selected_Image;
  String? selectedValue;
  DateTime? _selectedDate;
  final mobileController = TextEditingController();
  final otpController = TextEditingController();
  bool otpSent = false;
  bool otpVerified = false;
  bool emailVerified = false;
  final storage = FlutterSecureStorage();
  String? profileId; // to hold the stored id
  String? loginType;

  @override
  void initState() {
    super.initState();
    _getToken();
    _loadProfileId(); // call this first
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

  void sendOtp() {
    setState(() {
      otpSent = true;
    });

    print("OTP sent to ${mobileController.text}");
  }

  void verifyOtp() {
    setState(() {
      otpVerified = true;
    });
    // Here, you would call your API to send OTP
    print("OTP sent to ${mobileController.text}");
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
    final response = await http.get(
      Uri.parse("https://foxlchits.com/api/Profile/profile/$profileId"),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);
      setState(() {
        nameController.text = data['name'] ?? '';
        emailController.text = data['email'] ?? '';
        mobileController.text = data['phoneNumber'] ?? '';
        addressController.text = data['address'] ?? '';
        _selectedDate =
            data['dateofBirth'] != null && data['dateofBirth'].isNotEmpty
            ? DateTime.parse(data['dateofBirth'])
            : null;
        selectedValue = data['gender'] ?? '';
        otpVerified = data['phoneVerified'] ?? false;
        otpSent = otpVerified;
        emailVerified = data['emailVerified'] ?? false;
      });
    } else {
      print("Failed to load profile data");
    }
  }

  //put data
  Future<void> updateProfile(SetupProfile profile) async {
    final url = Uri.parse("https://foxlchits.com/api/Profile/$profileId");

    final response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
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
      print("⚠️ Cannot save FCM token — missing profileId or token");
      return;
    }

    final url = Uri.parse("https://foxlchits.com/api/Notification/profile/save-token");

    final body = {
      "userId": profileId,
      "fcmToken": _fcmToken,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
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

  late Future<SetupProfile> profileFuture;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

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
                      Row(children: [Expanded(child: mobileTextField())]),
                      if (loginType != 'phone' && otpSent && !otpVerified) ...[
                        SizedBox(height: size.height * 0.02),
                        const SupportText(
                          text:
                              'Enter the OTP sended to the Registered Mobile Number',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: appclr.profile_clr2,
                          fontType: FontType.urbanist,
                        ),
                        SizedBox(height: size.height * 0.015),
                        Row(children: [Expanded(child: otptextfield())]),
                      ],
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
                          inputTextField('', emailController, (value) {
                            if (value == null || value.isEmpty) {
                              return "This field cannot be empty";
                            }
                            return null;
                          }),
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
              enabled: !otpVerified,
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

          // Send OTP Button
          if (loginType == 'phone') ...[
            TextButton(
              onPressed: (!otpSent && !otpVerified) ? sendOtp : null,
              child: const SupportText(
                text: 'Send OTP',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: appclr.blue,
                fontType: FontType.urbanist,
              ),
            ),
          ],
        ],
      ),
    );
  }

  otptextfield() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xff323232)),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: otpController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
              keyboardType: TextInputType.phone,
            ),
          ),
          TextButton(
            onPressed: () {
              verifyOtp();
              // Handle OTP send
            },
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
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () async {
        final setupProfileData = SetupProfile(
          id: profileId ?? '',
          userID: "", // if needed
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          phoneNumber: mobileController.text.trim(),
          address: addressController.text.trim(),
          gender: selectedValue ?? "",
          dateOfBirth: _selectedDate != null
              ? "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}"
              : "",
          signupType: "",
          phoneVerified: otpVerified,
          emailVerified: emailVerified,
          joinDate: "",
          kycVerification: false,
          referBy: "",
        );

        // 1️⃣ PUT API
        await updateProfile(setupProfileData);

        // 2️⃣ POST FCM token
        await saveFcmToken();

        // 3️⃣ Navigate to KYC verified screen
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const kyc_verified()),
        );

        // 4️⃣ Notify parent
        if (widget.onKycCompleted != null) {
          widget.onKycCompleted!();
        }

        // Optional: pop back
        Navigator.pop(context);
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
            text: 'Proceed with KYC',
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: appclr.profile_clr1,
            fontType: FontType.urbanist,
          ),
        ),
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
