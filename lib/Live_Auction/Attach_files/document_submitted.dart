import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user_app/Bottom_Navbar/bottom_navigation_bar.dart';

class document_submited extends StatefulWidget {
  const document_submited({super.key});

  @override
  State<document_submited> createState() => _document_submitedState();
}

class _document_submitedState extends State<document_submited> {
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
                SizedBox(height: size.height * 0.2),
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.only(left: size.width*0.02),
                    child: Image.asset(
                      'assets/images/Live_Auction/document_submitted.png',
                      width: 270,
                      height: 269,
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.01),

                Text(
                  'Process completed and file submitted successfully. After verification,\nthe amount will be credited in 1–2 working days, and you will be notified.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.urbanist(
                    textStyle: const TextStyle(
                      color: Color(0xff6B6B6B),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.25),
                Center(
                  child: SizedBox(
                    width: 276,
                    height: 37,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff585858),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11),
                        ),
                      ),
                      onPressed: () {
                       Navigator.push(context,MaterialPageRoute(builder:(context)=>HomeLayout()));
                      },
                      child: Text(
                        'Go to Home',
                        style: GoogleFonts.urbanist(
                          textStyle: const TextStyle(
                            color: Color(0xffFFFFFF),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
