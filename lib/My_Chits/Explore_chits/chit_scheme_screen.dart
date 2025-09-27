import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';

import 'explore_chit_screen.dart';

class chit_scheme extends StatefulWidget {
  final int totalMonths;
  final int completedMonths;
  final String auctionDate;
  final String auctionEndDate;

  const chit_scheme({
    super.key,
    required this.totalMonths,
    required this.completedMonths,
    required this.auctionDate,
    required this.auctionEndDate,
  });

  @override
  State<chit_scheme> createState() => _chit_schemeState();
}

class _chit_schemeState extends State<chit_scheme> {
  late DateTime auctionTime;
  late DateTime auctionEndTime;
  bool isAuctionStarted = false;
  bool isAuctionEnded = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    auctionTime = DateTime.parse(widget.auctionDate);
    auctionEndTime = DateTime.parse(widget.auctionEndDate);
    _checkAuctionStatus();
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      _checkAuctionStatus();
    });
  }

  void _checkAuctionStatus() {
    final now = DateTime.now();
    final started = now.isAfter(auctionTime);
    final ended = now.isAfter(auctionEndTime);

    if (started != isAuctionStarted || ended != isAuctionEnded) {
      setState(() {
        isAuctionStarted = started;
        isAuctionEnded = ended;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel timer to prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double progress = widget.completedMonths / widget.totalMonths;
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
                //head
                Row(
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
                      'Chit Scheme',
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
                SizedBox(height: size.height * 0.04),
                Container(
                  width: double.infinity,
                  height: 424,
                  decoration: BoxDecoration(
                    color: Color(0xff151515),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.045,
                      vertical: size.height * 0.025,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chit Name',
                          style: GoogleFonts.urbanist(
                            textStyle: const TextStyle(
                              color: Color(0xffDDDDDD),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(height: size.height * 0.005),
                        Text(
                          '₹2 Lakh Chit',
                          style: GoogleFonts.urbanist(
                            textStyle: const TextStyle(
                              color: Color(0xff3A7AFF),
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        SizedBox(height: size.height * 0.03),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,

                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Chit Type',
                                  style: GoogleFonts.urbanist(
                                    textStyle: const TextStyle(
                                      color: Color(0xffDDDDDD),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                SizedBox(height: size.height * 0.005),
                                Text(
                                  'Monthly',
                                  style: GoogleFonts.urbanist(
                                    textStyle: const TextStyle(
                                      color: Color(0xff3A7AFF),
                                      fontSize: 16,
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
                                  'Total Chit Value',
                                  style: GoogleFonts.urbanist(
                                    textStyle: const TextStyle(
                                      color: Color(0xffDDDDDD),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                SizedBox(height: size.height * 0.005),
                                Text(
                                  '2,00,000',
                                  style: GoogleFonts.urbanist(
                                    textStyle: const TextStyle(
                                      color: Color(0xff3A7AFF),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        SizedBox(height: size.height * 0.03),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,

                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Monthly Contribution',
                                  style: GoogleFonts.urbanist(
                                    textStyle: const TextStyle(
                                      color: Color(0xffDDDDDD),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                SizedBox(height: size.height * 0.005),
                                Text(
                                  '₹10,000',
                                  style: GoogleFonts.urbanist(
                                    textStyle: const TextStyle(
                                      color: Color(0xff3A7AFF),
                                      fontSize: 16,
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
                                  'Duration',
                                  style: GoogleFonts.urbanist(
                                    textStyle: const TextStyle(
                                      color: Color(0xffDDDDDD),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                SizedBox(height: size.height * 0.005),
                                Text(
                                  '20 Months',
                                  style: GoogleFonts.urbanist(
                                    textStyle: const TextStyle(
                                      color: Color(0xff3A7AFF),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        SizedBox(height: size.height * 0.03),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Members',
                                  style: GoogleFonts.urbanist(
                                    textStyle: const TextStyle(
                                      color: Color(0xffDDDDDD),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                SizedBox(height: size.height * 0.005),
                                Text(
                                  '20 Members',
                                  style: GoogleFonts.urbanist(
                                    textStyle: const TextStyle(
                                      color: Color(0xff3A7AFF),
                                      fontSize: 16,
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
                                  'Current Members',
                                  style: GoogleFonts.urbanist(
                                    textStyle: const TextStyle(
                                      color: Color(0xffDDDDDD),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                SizedBox(height: size.height * 0.005),
                                Text(
                                  '8 Members Joined',
                                  style: GoogleFonts.urbanist(
                                    textStyle: const TextStyle(
                                      color: Color(0xff3A7AFF),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        SizedBox(height: size.height * 0.05),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progress',
                              style: GoogleFonts.urbanist(
                                color: Color(0xffDBDBDB),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${widget.completedMonths} of ${widget.totalMonths} months completed',
                              style: GoogleFonts.urbanist(
                                color: Color(0xffDBDBDB),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: size.height * 0.01),

                        LayoutBuilder(
                          builder: (context, constraints) {
                            final width = constraints.maxWidth * progress;
                            return Container(
                              width: double.infinity,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Color(0xffE5E5E5),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Stack(
                                children: [
                                  // Blue Gradient Progress Fill
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 600),
                                    width: width,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF2196F3),
                                          Color(0xFF64B5F6),
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: size.height * 0.02),

                Container(
                  width: double.infinity,
                  height: 240,
                  decoration: BoxDecoration(
                    color: Color(0xff151515),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.045,
                      vertical: size.height * 0.025,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Important Dates',
                          style: GoogleFonts.urbanist(
                            textStyle: const TextStyle(
                              color: Color(0xffFFFFFF),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(height: size.height * 0.02),
                        Row(
                          children: [
                            Column(
                              children: [
                                Container(
                                  width: 33,
                                  height: 33,
                                  decoration: BoxDecoration(
                                    color: isAuctionStarted
                                        ? Color(0xff1C3C38)
                                        : Color(0xff292939),
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: isAuctionStarted
                                          ? Color(0xff07C66A)
                                          : Color(0xff4D5263),
                                      width: 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Image.asset(
                                      'assets/images/My_Chits/chit_starting_date.png',
                                      width: 15,
                                      height: 15,
                                      color: isAuctionStarted
                                          ? Color(0xff07C66A)
                                          : Color(0xff99A1AF),
                                    ),
                                  ),
                                ),
                                Image.asset(
                                  'assets/images/My_Chits/Line 1.png',
                                  width: 1,
                                  height: 26,
                                ),
                                Container(
                                  width: 33,
                                  height: 33,
                                  decoration: BoxDecoration(
                                    color: isAuctionStarted
                                        ? Color(0xff212D58)
                                        : Color(0xff292939),
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: isAuctionStarted
                                          ? Color(0xff366FE7)
                                          : Color(0xff4D5263),
                                      width: 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Image.asset(
                                      'assets/images/My_Chits/next_auction_date.png',
                                      width: 15,
                                      height: 15,
                                      color: isAuctionStarted
                                          ? Color(0xff366FE7)
                                          : Color(0xff99A1AF),
                                    ),
                                  ),
                                ),
                                Image.asset(
                                  'assets/images/My_Chits/Line 2.png',
                                  width: 1,
                                  height: 26,
                                ),
                                Container(
                                  width: 33,
                                  height: 33,
                                  decoration: BoxDecoration(
                                    color: isAuctionEnded
                                        ? Color(0xff483233)
                                        : Color(0xff292939),
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: isAuctionEnded
                                          ? Color(0xffC60F12)
                                          : Color(0xff4D5263),
                                      width: 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Image.asset(
                                      'assets/images/My_Chits/chit_ending_date.png',
                                      width: 15,
                                      height: 15,
                                      color: isAuctionEnded
                                          ? Color(0xffC60F12)
                                          : Color(0xff99A1AF),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: size.width * 0.04),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Chit Starting Date',
                                  style: GoogleFonts.urbanist(
                                    textStyle: const TextStyle(
                                      color: Color(0xffDDDDDD),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  '05 November 2025',
                                  style: GoogleFonts.urbanist(
                                    textStyle: const TextStyle(
                                      color: Color(0xffDDDDDD),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                SizedBox(height: size.height * 0.03),
                                Text(
                                  'Next Auction Date',
                                  style: GoogleFonts.urbanist(
                                    textStyle: const TextStyle(
                                      color: Color(0xffDDDDDD),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  '05 December 2025 at 10:00 AM',
                                  style: GoogleFonts.urbanist(
                                    textStyle: const TextStyle(
                                      color: Color(0xffDDDDDD),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                SizedBox(height: size.height * 0.03),
                                Text(
                                  'Chit Ending Date',
                                  style: GoogleFonts.urbanist(
                                    textStyle: const TextStyle(
                                      color: Color(0xffDDDDDD),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  '05 March 2027',
                                  style: GoogleFonts.urbanist(
                                    textStyle: const TextStyle(
                                      color: Color(0xffDDDDDD),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.02),

                Container(
                  width: double.infinity,
                  height: 183,
                  decoration: BoxDecoration(
                    color: Color(0xff151515),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.045,
                      vertical: size.height * 0.025,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Charges Overview',
                          style: GoogleFonts.urbanist(
                            textStyle: const TextStyle(
                              color: Color(0xffFFFFFF),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(height: size.height * 0.04),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Foreman Commission',
                              style: GoogleFonts.urbanist(
                                textStyle: const TextStyle(
                                  color: Color(0xffDDDDDD),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              '₹500/month',
                              style: GoogleFonts.urbanist(
                                textStyle: const TextStyle(
                                  color: Color(0xffDDDDDD),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: size.height * 0.01),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Discount Benefit',
                              style: GoogleFonts.urbanist(
                                textStyle: const TextStyle(
                                  color: Color(0xffDDDDDD),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              '₹500',
                              style: GoogleFonts.urbanist(
                                textStyle: const TextStyle(
                                  color: Color(0xffDDDDDD),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: size.height * 0.01),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Taxes & Fees',
                              style: GoogleFonts.urbanist(
                                textStyle: const TextStyle(
                                  color: Color(0xffDDDDDD),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              '₹500',
                              style: GoogleFonts.urbanist(
                                textStyle: const TextStyle(
                                  color: Color(0xffDDDDDD),
                                  fontSize: 13,
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
                SizedBox(height: size.height * 0.01),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
