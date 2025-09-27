import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user_app/Chit_Groups/chit_group_screen.dart';
import 'package:user_app/Profile/profile_screen.dart';

class kyc_verified extends StatefulWidget {
  const kyc_verified({super.key});

  @override
  State<kyc_verified> createState() => _kyc_verifiedState();
}

class _kyc_verifiedState extends State<kyc_verified> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xff000000),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
          child: Column(
            children: [
              SizedBox(height: size.height * 0.3),
              Center(
                child: Image.asset(
                  'assets/images/Profile/kyc_verified.png',
                  width: 162,
                  height: 150,
                ),
              ),
              SizedBox(height: size.height * 0.02),
              Text(
                'Your profile has been submitted successfully.',
                style: GoogleFonts.urbanist(
                  textStyle: const TextStyle(
                    color: Color(0xffFFFFFF),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.23),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => chit_groups()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4770CB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 90,
                    vertical: 10,
                  ),
                ),
                child: const Text(
                  "Explore Chits",
                  style: TextStyle(
                    color: Color(0xffFFFFFF),
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.02),
              ElevatedButton(
                onPressed: () {

                  Navigator.push(context, MaterialPageRoute(builder: (_) => profile()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1A1A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 90,
                    vertical: 10,
                  ),
                ),
                child: const Text(
                  "Go to Profile",
                  style: TextStyle(
                    color: Color(0xffFFFFFF),
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
