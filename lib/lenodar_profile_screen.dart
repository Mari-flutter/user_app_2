import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class lenodar_profile extends StatefulWidget {
  const lenodar_profile({super.key});

  @override
  State<lenodar_profile> createState() => _lenodar_profileState();
}

class _lenodar_profileState extends State<lenodar_profile> {
  bool isEdited = false;
  final ShopNameController = TextEditingController();
  final LocationController = TextEditingController();
  final TimingController = TextEditingController();
  final ContactController = TextEditingController();
  final ConvertionChargeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xff000000),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height * 0.02),
              Row(
                children: [
                  Text(
                    "Shop Details",
                    style: GoogleFonts.urbanist(
                      fontWeight: FontWeight.w500,
                      fontSize: 26,
                      color: const Color(0xFFFFFFFF),
                    ),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () async {
                      if (isEdited) {
                        // Currently in edit mode, now user clicked Save → trigger update
                        // final updatedProfile = ProfileUpdate(
                        //   ShopName: ShopNameController.text.isEmpty
                        //       ? ''
                        //       : ShopNameController.text,
                        //   Location: LocationController.text.isEmpty
                        //       ? ''
                        //       : LocationController.text,
                        //   Timing: TimingController.text.isEmpty
                        //       ? ''
                        //       : TimingController.text,
                        //   Contact: ContactController.text.isEmpty
                        //       ? ''
                        //       : ContactController.text,
                        //   ConvertionCharge: ConvertionChargeController.text.isEmpty
                        //       ? ''
                        //       : ConvertionChargeController.text,
                        // );
                        // await updateProfile(updatedProfile);
                      }

                      setState(() {
                        isEdited = !isEdited;
                      });
                    },
                    child: Text(
                      isEdited?"Save":"Edit",
                      style: GoogleFonts.urbanist(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color:isEdited?Color(0xff7B5326): Color(0xFFE2E2E2),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.05),
              Center(
                child: Container(
                  width: 67,
                  height: 67,
                  decoration: BoxDecoration(
                    color: Color(0xff161616),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Image.asset(
                      'assets/images/Investments/malabar.png',
                      width: 60,
                      height: 60,
                    ),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.02),
              Text(
                "Shop Name*",
                style: GoogleFonts.urbanist(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: const Color(0xFFADADAD),
                ),
              ),
              SizedBox(height: size.height * 0.02),
              SizedBox(
                child: inputTextField('', ShopNameController, (value) {
                  if (value == null || value.isEmpty) {
                    return "This field cannot be empty";
                  }
                  return null;
                }),
              ),
              SizedBox(height: size.height * 0.02),
              Text(
                "Location*",
                style: GoogleFonts.urbanist(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: const Color(0xFFADADAD),
                ),
              ),
              SizedBox(height: size.height * 0.02),
              SizedBox(
                child: inputTextField('', LocationController, (value) {
                  if (value == null || value.isEmpty) {
                    return "This field cannot be empty";
                  }
                  return null;
                }),
              ),
              SizedBox(height: size.height * 0.02),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Timing*",
                        style: GoogleFonts.urbanist(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: const Color(0xFFADADAD),
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                      SizedBox(
                        width: size.width * 0.45,
                        child: inputTextField('', TimingController, (value) {
                          if (value == null || value.isEmpty) {
                            return "This field cannot be empty";
                          }
                          return null;
                        }),
                      ),
                    ],
                  ),
                  Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Contact*",
                        style: GoogleFonts.urbanist(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: const Color(0xFFADADAD),
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                      SizedBox(
                        width: size.width * 0.45,
                        child: inputTextField('', ContactController, (value) {
                          if (value == null || value.isEmpty) {
                            return "This field cannot be empty";
                          }
                          return null;
                        }),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.02),
              Text(
                "Convertion Charge",
                style: GoogleFonts.urbanist(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: const Color(0xFFADADAD),
                ),
              ),
              SizedBox(height: size.height * 0.02),
              SizedBox(
                child: inputTextField('', ConvertionChargeController, (value) {
                  if (value == null || value.isEmpty) {
                    return "This field cannot be empty";
                  }
                  return null;
                }),
              ),
            ],
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
    Size size = MediaQuery.of(context).size;
    return TextFormField(
      // readOnly: !isEdited,
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
}
