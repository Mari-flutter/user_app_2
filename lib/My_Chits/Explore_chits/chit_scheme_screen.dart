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
  final int CurrentMember;
  final int TotalMember;
  final String ChitType;
  final String ChitName;
  final double OtherCharges;
  final double Penalty;
  final double Taxes;
  final double Value;
  final double Contribution;
  final String nextAuctionDate;

  const chit_scheme({
    super.key,
    required this.totalMonths,
    required this.completedMonths,
    required this.auctionDate,
    required this.auctionEndDate,
    required this.CurrentMember,
    required this.TotalMember,
    required this.ChitType,
    required this.OtherCharges,
    required this.Penalty,
    required this.Taxes,
    required this.ChitName,
    required this.Value,
    required this.Contribution,
    required this.nextAuctionDate,
  });

  @override
  State<chit_scheme> createState() => _chit_schemeState();
}

class _chit_schemeState extends State<chit_scheme> {
  late DateTime auctionTime;
  late DateTime auctionEndTime;
  late DateTime nextAuctionDate;
  bool isAuctionStarted = false;
  bool isAuctionEnded = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final parts = widget.auctionDate.split('-'); // e.g., ['15', '10', '2025']
    final isoDateString = '${parts[2]}-${parts[1]}-${parts[0]}T00:00:00';

    nextAuctionDate = DateTime.parse(isoDateString);
    _checkAuctionStatus();
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      _checkAuctionStatus();
    });
  }

  void _checkAuctionStatus() {
    final now = DateTime.now();

    // NOTE: If you are not using these for real-time auction status,
    // this entire function and the timer should be removed for efficiency.
    // For this example, I'll simplify the status check based only on the "Next Auction Date"
    // which we'll assume is the widget.auctionDate.

    final started = now.isAfter(nextAuctionDate.subtract(Duration(hours: 1))); // Auction starts 1 hour before due date? (Conceptual)
    final ended = now.isAfter(nextAuctionDate);

    if (started != isAuctionStarted || ended != isAuctionEnded) {
      setState(() {
        isAuctionStarted = started;
        isAuctionEnded = ended;
      });
    }
  }
  String _formatDisplayDate(String ddMmYyyy) {
    try {
      final parts = ddMmYyyy.split('-');
      if (parts.length != 3) return ddMmYyyy;

      final day = parts[0];
      final monthIndex = int.parse(parts[1]) - 1;
      final year = parts[2];

      const monthNames = [
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
      ];

      if (monthIndex >= 0 && monthIndex < 12) {
        return '$day ${monthNames[monthIndex]} $year';
      }
      return ddMmYyyy;
    } catch (e) {
      return ddMmYyyy; // Return original string on error
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
                        Navigator.pop(context);
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
                          '${widget.ChitName}',
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
                                  '${widget.ChitType}',
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
                                  '${widget.Value}',
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
                                  '${widget.Contribution}',
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
                                  '${widget.totalMonths}',
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
                                  '${widget.TotalMember}',
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
                                  '${widget.CurrentMember}',
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
                                  '${_formatDisplayDate(widget.nextAuctionDate)} at 10:00 AM',
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
                              'Other Charges',
                              style: GoogleFonts.urbanist(
                                textStyle: const TextStyle(
                                  color: Color(0xffDDDDDD),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              '${widget.OtherCharges}',
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
                              'Penalty',
                              style: GoogleFonts.urbanist(
                                textStyle: const TextStyle(
                                  color: Color(0xffDDDDDD),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              '${widget.Penalty}',
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
                              '${widget.Taxes}',
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
