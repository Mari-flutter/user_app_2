
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user_app/Bottom_Navbar/bottom_navigation_bar.dart';

class investments_receipts_overall extends StatefulWidget {
  const investments_receipts_overall({super.key});

  @override
  State<investments_receipts_overall> createState() =>
      _investments_receipts_overallState();
}

class _investments_receipts_overallState
    extends State<investments_receipts_overall> {
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
                          MaterialPageRoute(
                            builder: (context) => HomeLayout(initialTab: 2),
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
                      'Receipts',
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
                SizedBox(height: size.height * 0.02),
                Column(
                  children: List.generate(
                    4,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: const FoxlReceiptCard(),
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

class FoxlReceiptCard extends StatelessWidget {
  const FoxlReceiptCard({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 111,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff795124), Color(0xffD4B277)],
            ),
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(11),
              topLeft: Radius.circular(11),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.04,
              vertical: size.height * 0.03,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Foxl Chit Funds',
                      style: GoogleFonts.urbanist(
                        textStyle: const TextStyle(
                          color: Color(0xffFFFFFF),
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      'Rajesh Kumar (#F02343)',
                      style: GoogleFonts.urbanist(
                        textStyle: const TextStyle(
                          color: Color(0xffFFFFFF),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Official Confirmation Receipt',
                      style: GoogleFonts.urbanist(
                        textStyle: const TextStyle(
                          color: Color(0xffFFFFFF),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      'Booking ID: #GOLD4257',
                      style: GoogleFonts.urbanist(
                        textStyle: const TextStyle(
                          color: Color(0xffFFFFFF),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Container(
          width: double.infinity,
          height: 315,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff7D5628), Color(0xffD2B075)],
            ),
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(11),
              bottomLeft: Radius.circular(11),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(1),
            child: Container(
              width: double.infinity,
              height: 310,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(11),
                  bottomLeft: Radius.circular(11),
                ),
                color: Color(0xff000000),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.04,
                  vertical: size.height * 0.03,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 57,
                          decoration: BoxDecoration(color: Color(0xffCCA96F)),
                        ),
                        Expanded(
                          child: Container(
                            height: 57,
                            decoration: BoxDecoration(color: Color(0xff2E2E2E)),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: size.width * 0.03,
                                vertical: size.height * 0.005,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 33,
                                    height: 33,
                                    decoration: BoxDecoration(
                                      color: Color(0xffD3B176),
                                      border: Border.all(
                                        color: Color(0xff7A5225),
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Center(
                                      child: Image.asset(
                                        'assets/images/Investments/booking_confirmed.png',
                                        width: 15,
                                        height: 15,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: size.width * 0.04),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: size.height * 0.005),
                                      Text(
                                        'Gold Sale Completed',
                                        style: GoogleFonts.urbanist(
                                          textStyle: const TextStyle(
                                            color: Color(0xffFFFFFF),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        'Your online gold has been sold successfully. The proceeds\nwill be transferred to your account soon.',
                                        style: GoogleFonts.urbanist(
                                          textStyle: const TextStyle(
                                            color: Color(0xffCBA86F),
                                            fontSize: 9,
                                            fontWeight: FontWeight.w600,
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
                      ],
                    ),
                    SizedBox(height: size.height * 0.02),
                    Container(
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(
                        color: Color(0xff2E2E2E),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.04,
                          vertical: size.height * 0.02,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Booking Details',
                              style: GoogleFonts.urbanist(
                                textStyle: const TextStyle(
                                  color: Color(0xffFFFFFF),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(height: size.height * 0.015),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Transfer Mode',
                                      style: GoogleFonts.urbanist(
                                        textStyle: const TextStyle(
                                          color: Color(0xff6E6E6E),
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'Online Credit',
                                      style: GoogleFonts.urbanist(
                                        textStyle: const TextStyle(
                                          color: Color(0xff989898),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Gold Details',
                                      style: GoogleFonts.urbanist(
                                        textStyle: const TextStyle(
                                          color: Color(0xff6E6E6E),
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '10g',
                                      style: GoogleFonts.urbanist(
                                        textStyle: const TextStyle(
                                          color: Color(0xff989898),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            SizedBox(height: size.height * 0.01),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Transaction Date:',
                                      style: GoogleFonts.urbanist(
                                        textStyle: const TextStyle(
                                          color: Color(0xff6E6E6E),
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '11 November 2025',
                                      style: GoogleFonts.urbanist(
                                        textStyle: const TextStyle(
                                          color: Color(0xff989898),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Store Contact',
                                      style: GoogleFonts.urbanist(
                                        textStyle: const TextStyle(
                                          color: Color(0xff6E6E6E),
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '+91 80 6789 5432',
                                      style: GoogleFonts.urbanist(
                                        textStyle: const TextStyle(
                                          color: Color(0xff989898),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            SizedBox(height: size.height * 0.01),
                            Text(
                              'Credit Timeline:',
                              style: GoogleFonts.urbanist(
                                textStyle: const TextStyle(
                                  color: Color(0xff6E6E6E),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              'Within 3 working days from the date of sale',
                              style: GoogleFonts.urbanist(
                                textStyle: const TextStyle(
                                  color: Color(0xff989898),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
