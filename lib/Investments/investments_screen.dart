import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'Gold/gold_investment_screen.dart';

class investment extends StatefulWidget {
  final VoidCallback? onGoldTap;

  const investment({super.key, this.onGoldTap});

  @override
  State<investment> createState() => _investmentState();
}

class _investmentState extends State<investment> {
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
                Text(
                  'Investments',
                  style: GoogleFonts.urbanist(
                    textStyle: const TextStyle(
                      color: Color(0xffE2E2E2),
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        widget.onGoldTap?.call(); // same, keeps nav bar and highlights Investments tab
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            size.width * 0.03,
                          ),
                          gradient: const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Color(0xff666666), Color(0xff000000)],
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(size.width * 0.003),
                          child: Container(
                            width: size.width * 0.3,
                            height: size.height * 0.08,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                size.width * 0.03,
                              ),
                              color: const Color(0xff1A1A1A),
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(left: size.width * 0.02),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: size.height * 0.008),
                                  Text(
                                    'Gold',
                                    style: GoogleFonts.urbanist(
                                      textStyle: TextStyle(
                                        color: const Color(0xff626262),
                                        fontSize: size.width * 0.03,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                      left: size.width * 0.14,
                                    ),
                                    child: Image.asset(
                                      'assets/images/Investments/gold.png',
                                      width: size.width * 0.15,
                                      height: size.height * 0.04,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(size.width * 0.03),
                        gradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Color(0xff666666), Color(0xff000000)],
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(size.width * 0.003),
                        child: Container(
                          width: size.width * 0.3,
                          height: size.height * 0.08,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              size.width * 0.03,
                            ),
                            color: const Color(0xff1A1A1A),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(left: size.width * 0.02),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: size.height * 0.008),
                                Text(
                                  'Real Estate',
                                  style: GoogleFonts.urbanist(
                                    textStyle: TextStyle(
                                      color: const Color(0xff626262),
                                      fontSize: size.width * 0.03,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: size.width * 0.14,
                                  ),
                                  child: Image.asset(
                                    'assets/images/Investments/real_estate.png',
                                    width: size.width * 0.15,
                                    height: size.height * 0.04,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(size.width * 0.03),
                        gradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Color(0xff666666), Color(0xff000000)],
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(size.width * 0.003),
                        child: Container(
                          width: size.width * 0.3,
                          height: size.height * 0.08,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              size.width * 0.03,
                            ),
                            color: const Color(0xff1A1A1A),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(left: size.width * 0.02),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: size.height * 0.008),
                                Text(
                                  'Receipts',
                                  style: GoogleFonts.urbanist(
                                    textStyle: TextStyle(
                                      color: const Color(0xff626262),
                                      fontSize: size.width * 0.03,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                SizedBox(height: size.height * 0.004),
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: size.width * 0.14,
                                  ),
                                  child: Image.asset(
                                    'assets/images/Investments/receipts_1.png',
                                    width: size.width * 0.15,
                                    height: size.height * 0.035,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
