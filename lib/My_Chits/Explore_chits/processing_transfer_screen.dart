import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user_app/My_Chits/Explore_chits/withdraw_for_chits_screen.dart';

class processing_transfer extends StatefulWidget {
  const processing_transfer({super.key});

  @override
  State<processing_transfer> createState() => _processing_transferState();
}

class _processing_transferState extends State<processing_transfer> {
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
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => withdraw_for_chits()),
                        );
                      },
                      child: Image.asset(
                        'assets/images/My_Chits/back_arrow.png',
                        width: 24,
                        height: 24,
                      ),
                    ),
                    SizedBox(width: size.width * 0.03),
                    Text(
                      'Back',
                      style: GoogleFonts.urbanist(
                        textStyle: const TextStyle(
                          color: Color(0xffFFFFFF),
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.18),
                Center(
                  child: Image.asset(
                    'assets/images/My_Chits/withdraw_successful.png',
                    width: 221,
                    height: 221,
                  ),
                ),
                SizedBox(height: size.height * 0.03),
                Center(
                  child: Text(
                    'Successful!',
                    style: GoogleFonts.urbanist(
                      textStyle: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        foreground: Paint()
                          ..shader = LinearGradient(
                            colors: [
                              Color(0xFFFFFFFF),
                              Color(0xFFFFFFFF),
                              Color(0xFFFFFFFF),
                              Color(0xFFFFFFFF),
                              Color(0xFF3422B4),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                Center(
                  child: Text(
                    'Amount will be credited to your account\nwithin 7 working days.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.urbanist(
                      textStyle: const TextStyle(
                        color: Color(0xffFFFFFF),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
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
