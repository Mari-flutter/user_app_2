import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'explore_chit_screen.dart';

class terms_condition extends StatefulWidget {
  const terms_condition({super.key});

  @override
  State<terms_condition> createState() => _terms_conditionState();
}

class _terms_conditionState extends State<terms_condition> {
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
              children: [SizedBox(height: size.height * 0.02), Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => explore_chit(
                            auctionDateTime: "2025-10-06T10:00:00",
                            totalMonths: 10,
                            completedMonths: 3,
                            chitValue: 200000,
                            totalContribution: 30000,
                          ),
                        ),
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
                    'Past Auction Results',
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
                SizedBox(height: size.height * 0.04),],
            ),
          ),
        ),
      ),
    );
  }
}
