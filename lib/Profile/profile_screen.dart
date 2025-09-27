import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user_app/Profile/kyc_verified.dart';
import 'package:http/http.dart' as http;

import '../Models/Profile/profile_model.dart';
import '../Models/Profile/profile_update_model.dart' hide Profile;

class profile extends StatefulWidget {
  const profile({super.key});

  @override
  State<profile> createState() => _profileState();
}

class _profileState extends State<profile> {
  bool isEdited = false;
  bool isExpanded = false;
  Image? selected_Image;
  String? selectedValue;
  DateTime? _selectedDate;
  TextEditingController Phonenumbercontroller = TextEditingController();
  final mobileController = TextEditingController();

  final storage = FlutterSecureStorage();
  String? profileId; // store the loaded ID

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

  //get data
  Future<Profile> getProfileData() async {
    final response = await http.get(
      Uri.parse("https://foxlchits.com/api/Profile/profile/$profileId"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);
      return Profile.fromJson(data);
    } else {
      throw Exception('Failed to load profile');
    }
  }

  //put data
  Future<void> updateProfile(ProfileUpdate profile) async {
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

  late Future<Profile> profileFuture;

  @override
  void initState() {
    super.initState();
    _loadProfileId();
    profileFuture = getProfileData();
  }

  Future<void> _loadProfileId() async {
    profileId = await storage.read(key: 'profileId');
    print("📦 Loaded Profile ID: $profileId");
  }

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  bool _isPrefilled = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Color(0xff000000),
      body: FutureBuilder(
        future: profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No profile data found'));
          }

          if (snapshot.hasData) {
            final profile = snapshot.data!;
            if (!_isPrefilled) {
              nameController.text = profile.name;
              emailController.text = profile.email;
              phoneController.text = profile.phoneNumber;
              addressController.text = profile.address;
              selectedValue = profile.gender;
              _isPrefilled = true; // avoid reassigning
            }

            if (_selectedDate == null && profile.dateOfBirth.isNotEmpty) {
              try {
                final parts = profile.dateOfBirth.split('-'); // MM-DD-YYYY
                _selectedDate = DateTime(
                  int.parse(parts[2]), // year
                  int.parse(parts[0]), // month
                  int.parse(parts[1]), // day
                );
              } catch (e) {
                _selectedDate = null;
                print("Failed to parse DOB: $e");
              }
            }

            selectedValue ??= profile.gender;

            return SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: size.height * 0.02),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SupportText(
                            text: 'Profile',
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                            color: appclr.profile_clr1,
                            fontType: FontType.urbanist,
                          ),
                          GestureDetector(
                            onTap: () async {
                              if (isEdited) {
                                // Currently in edit mode, now user clicked Save → trigger update
                                final updatedProfile = ProfileUpdate(
                                  name: nameController.text.isEmpty
                                      ? profile.name
                                      : nameController.text,
                                  email: emailController.text.isEmpty
                                      ? profile.email
                                      : emailController.text,
                                  address: addressController.text.isEmpty
                                      ? profile.address
                                      : addressController.text,
                                  gender: selectedValue ?? profile.gender,
                                  dateOfBirth: _selectedDate != null
                                      ? "${_selectedDate!.month}-${_selectedDate!.day}-${_selectedDate!.year}"
                                      : profile.dateOfBirth,
                                );

                                await updateProfile(updatedProfile);
                              }

                              setState(() {
                                isEdited = !isEdited;
                              });
                            },

                            child: SupportText(
                              text: isEdited ? 'Save' : 'Edit',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: isEdited
                                  ? Color(0xff3A7AFF)
                                  : appclr.profile_clr1,
                              fontType: FontType.urbanist,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.04),
                      const SupportText(
                        text: 'Name',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: appclr.profile_clr2,
                        fontType: FontType.urbanist,
                      ),
                      SizedBox(height: size.height * 0.015),
                      inputTextField('${profile.name}', nameController, (
                        value,
                      ) {
                        if (value == null || value.isEmpty) {
                          return "This field cannot be empty";
                        }
                        return null;
                      }),
                      SizedBox(height: size.height * 0.02),
                      const SupportText(
                        text: 'User Id / Referal Id',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: appclr.profile_clr2,
                        fontType: FontType.urbanist,
                      ),
                      SizedBox(height: size.height * 0.015),
                      inputTextField(
                        '${profile.userID}',
                        TextEditingController(),
                        (value) {
                          if (value == null || value.isEmpty) {
                            return "This field cannot be empty";
                          }
                          return null;
                        },
                      ),
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
                      calendarandgender(profile.dateOfBirth, profile.gender),
                      SizedBox(height: size.height * 0.02),
                      const SupportText(
                        text: 'Mobile Number',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: appclr.profile_clr2,
                        fontType: FontType.urbanist,
                      ),
                      SizedBox(height: size.height * 0.015),
                      Row(
                        children: [
                          Expanded(child: mobileTextField(profile.phoneNumber)),
                        ],
                      ),
                      SizedBox(height: size.height * 0.02),
                      SupportText(
                        text: 'Mail ID',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: appclr.profile_clr2,
                        fontType: FontType.urbanist,
                      ),
                      SizedBox(height: size.height * 0.015),
                      inputTextField('${profile.email}', emailController, (
                        value,
                      ) {
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
                      inputTextField('${profile.address}', addressController, (
                        value,
                      ) {
                        if (value == null || value.isEmpty) {
                          return "This field cannot be empty";
                        }
                        return null;
                      }),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
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
    Size size = MediaQuery.of(context).size;
    return TextFormField(
      readOnly: !isEdited,
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
        contentPadding: EdgeInsets.symmetric(
          horizontal: size.width * 0.05,
          vertical: size.height * 0.017,
        ),
        filled: true,
        fillColor: Colors.black,
        hintText: hintText,
        hintStyle: GoogleFonts.urbanist(
          color: Color(0xffADADAD),
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
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

  calendarandgender(String dob, String gender) {
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
                      child: SupportText(
                        text: _selectedDate == null
                            ? dob.isEmpty
                                  ? 'Select Date'
                                  : dob
                            : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: appclr.profile_clr1,
                        fontType: FontType.urbanist,
                      ),
                    ),
                    if (isEdited)
                      GestureDetector(
                        onTap: isEdited ? () => _pickDate(context) : null,
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
                  Container(
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
                            text: selectedValue ?? gender,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: appclr.profile_clr1,
                            fontType: FontType.urbanist,
                          ),
                        ),
                        if (isEdited)
                          GestureDetector(
                            onTap: isEdited
                                ? () {
                                    setState(() => isExpanded = !isExpanded);
                                  }
                                : null,
                            child: Image.asset(
                              isExpanded
                                  ? 'assets/images/Profile/gender_up.png'
                                  : 'assets/images/Profile/gender_down.png',
                              height: size.height * 0.03,
                              width: size.width * 0.06,
                              color: appclr.profile_clr2,
                            ),
                          ),
                      ],
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

  Widget mobileTextField(String phoneNumber) {
    Size size = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xff323232)),
        borderRadius: BorderRadius.circular(11),
      ),
      child: TextFormField(
        readOnly: !isEdited,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: size.width * 0.05,
            vertical: size.height * 0.017,
          ),
          hintText: phoneNumber.isEmpty ? "Enter phone number" : phoneNumber,
          hintStyle: GoogleFonts.urbanist(
            color: Color(0xffADADAD),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        keyboardType: TextInputType.phone,
      ),
    );
  }

  loginbutton() {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => kyc_verified()),
        );
      },
      child: Container(
        height: 38,
        width: 162,
        decoration: BoxDecoration(
          color: Color(0xff2563EB).withOpacity(.9),
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
