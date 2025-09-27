import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user_app/My_Chits/Explore_chits/auction_result_screen.dart';
import 'package:user_app/My_Chits/Explore_chits/chit_scheme_screen.dart';
import 'package:user_app/My_Chits/Explore_chits/terms_and_condition_screen.dart';
import 'package:user_app/My_Chits/Explore_chits/withdraw_screen.dart';
import 'package:user_app/My_Chits/my_chits.dart';
import 'package:user_app/My_Chits/Explore_chits/receipts_screen.dart';
import 'dart:async';

class explore_chit extends StatefulWidget {
  final String auctionDateTime;
  final int totalMonths;
  final int completedMonths;
  final int chitValue;
  final int totalContribution;

  const explore_chit({
    super.key,
    required this.totalMonths,
    required this.completedMonths,
    required this.chitValue,
    required this.totalContribution,
    required this.auctionDateTime,
  });

  @override
  State<explore_chit> createState() => _explore_chitState();
}

class _explore_chitState extends State<explore_chit> {
  final List<String> chit_scheme_to_TC_tags = [
    'Chit Scheme',
    'Auction Results',
    'Receipts',
    'T&C’s',
    'Withdraw'
  ];
  final List<String> chit_scheme_to_TC_images = [
    'assets/images/My_Chits/chit_scheme.png',
    'assets/images/My_Chits/auction_result.png',
    'assets/images/My_Chits/receipts.png',
    'assets/images/My_Chits/T&c.png',
    'assets/images/My_Chits/with_draw.png',
  ];
  late final List<Widget> chit_scheme_to_TC_pages = [
    chit_scheme(
      totalMonths: 20,
      completedMonths: 10,
      auctionDate: "2025-10-04",
      auctionEndDate: "2025-10-04",
    ),
    auction_result(),
    receipts(),
    terms_condition(),
    withdraw(),
  ];
  final bool isPay_due = true;

  late DateTime auctionTime;
  bool isAuctionStarted = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    auctionTime = DateTime.parse(widget.auctionDateTime);
    _checkAuctionStatus();
    // Periodically check auction status every second
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      _checkAuctionStatus();
    });
  }

  void _checkAuctionStatus() {
    final now = DateTime.now();
    final started = now.isAfter(auctionTime);
    if (started != isAuctionStarted) {
      setState(() {
        isAuctionStarted = started;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel timer to prevent memory leaks
    super.dispose();
  }

  final chit_month = 20;
  final completed_chits = 6;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double progress = widget.completedMonths / widget.totalMonths;

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
                            builder: (context) => my_chits(initialTab: 0),
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
                      'My Chits',
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

                //chit details card
                Container(
                  height: 163,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF060D1D), Color(0xFF4982FF)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.04,
                      vertical: size.height * 0.015,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Chit Value : ₹${widget.chitValue.toString()}/-',
                              style: GoogleFonts.urbanist(
                                color: Color(0xffFFFFFF),
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${widget.totalMonths} Months',
                              style: GoogleFonts.urbanist(
                                color: Color(0xffFFFFFF),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: size.height * 0.015),
                        Text(
                          'Total Contribution till now : ₹${widget.totalContribution.toString()}/-',
                          style: GoogleFonts.urbanist(
                            color: Color(0xffDDDDDD),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: size.height * 0.04),
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
                        // --- Gradient Progress Bar ---
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

                SizedBox(height: size.height * 0.04),
                //chit scheme,auction result,receipt,t&C
                SizedBox(
                  height: size.height * 0.13,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: chit_scheme_to_TC_tags.length,
                    itemBuilder: (BuildContext, index) {
                      return Padding(
                        padding: EdgeInsets.only(
                          right: index == chit_scheme_to_TC_tags.length - 1
                              ? 0
                              : size.width * 0.045,
                        ),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        chit_scheme_to_TC_pages[index],
                                  ),
                                );
                              },
                              child: Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: Color(0xff3A7AFF),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Center(
                                  child: Image.asset(
                                    chit_scheme_to_TC_images[index],
                                    width: 24,
                                    height: 24,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: size.height * 0.01),
                            Text(
                              chit_scheme_to_TC_tags[index],
                              style: GoogleFonts.urbanist(
                                color: Color(0xffFFFFFF),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 109,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    gradient: LinearGradient(
                      colors: [Color(0xff4770CB), Color(0xff000000)],
                    ),
                  ),
                  child: Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: size.width * 0.002,
                      vertical: size.height * 0.001,
                    ),
                    width: double.infinity,
                    height: 109,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Color(0xff000000),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.04,
                        vertical: size.height * 0.025,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '07 days for Upcoming Auction',
                            style: GoogleFonts.urbanist(
                              color: Color(0xffFFFFFF),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: size.height * 0.015),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: GestureDetector(
                              onTap: isAuctionStarted
                                  ? () {
                                      // Perform enroll action
                                    }
                                  : null,
                              child: Container(
                                width: 70,
                                height: 25,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(11),
                                  color: isAuctionStarted
                                      ? const Color(0xff3F60A9) // active blue
                                      : const Color(
                                          0xff232D42,
                                        ), // inactive grey
                                ),

                                child: Center(
                                  child: Text(
                                    'Enroll',
                                    style: GoogleFonts.urbanist(
                                      color: isAuctionStarted
                                          ? Color(0xffFFFFFF)
                                          : Color(0xff4A4A4A),
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
                SizedBox(height: size.height * 0.03),
                Container(
                  width: double.infinity,
                  height: 109,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [Color(0xff4770CB), Color(0xff000000)],
                    ),
                  ),
                  child: Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: size.width * 0.002,
                      vertical: size.height * 0.001,
                    ),
                    width: double.infinity,
                    height: 109,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Color(0xff000000),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.04,
                        vertical: size.height * 0.025,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'This month Contribution',
                            style: GoogleFonts.urbanist(
                              color: Color(0xffFFFFFF),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: size.height * 0.013),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '₹10,000/-',
                                style: GoogleFonts.urbanist(
                                  color: Color(0xffFFFFFF),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {},
                                child: Container(
                                  width: 87,
                                  height: 25,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(11),
                                    color: Color(0xff3F60A9),
                                  ),

                                  child: Center(
                                    child: Text(
                                      isPay_due ? 'No Due' : 'Pay Due',
                                      style: GoogleFonts.urbanist(
                                        color: Color(0xffFFFFFF),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
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
                SizedBox(height: size.height * 0.03),
                Text(
                  'Breakdown of your Monthly Contribution',
                  style: GoogleFonts.urbanist(
                    color: Color(0xffFFFFFF),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: size.height * 0.01),
                Text(
                  'Starts from 03-11-2025 and Ends in 03-09-2025',
                  style: GoogleFonts.urbanist(
                    color: Color(0xff545454),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: size.height * 0.03),
                GridView.builder(
                  shrinkWrap: true,
                  // 👈 makes GridView take only needed height
                  physics: NeverScrollableScrollPhysics(),
                  // 👈 disables its scroll
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // Number of columns
                    crossAxisSpacing: 10, // Horizontal spacing between items
                    mainAxisSpacing: 10, // Vertical spacing between items
                    childAspectRatio: 1, // Width / Height ratio
                  ),
                  itemCount: chit_month,
                  itemBuilder: (BuildContext, index) {
                    final isCompleted =
                        index < completed_chits; // completed chits
                    return Column(
                      children: [
                        Container(
                          width: 99,
                          height: 28,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: isCompleted
                                  ? [Color(0xff3A7AFF), Color(0xff4770CB)]
                                  : [
                                      Color(0xff3A7AFF).withOpacity(0.3),
                                      Color(0xff4770CB).withOpacity(0.3),
                                    ],
                            ),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(17),
                              topRight: Radius.circular(17),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '03rd Nov 25',
                              style: GoogleFonts.urbanist(
                                color: isCompleted
                                    ? Color(0xffFFFFFF)
                                    : Color(0xffFFFFFF).withOpacity(0.3),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 99,
                          height: 74,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: isCompleted
                                  ? [Color(0xff313131), Color(0xff21242A)]
                                  : [
                                      Color(0xff313131).withOpacity(0.3),
                                      Color(0xff21242A).withOpacity(0.3),
                                    ],
                            ),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(17),
                              bottomRight: Radius.circular(17),
                            ),
                          ),
                          child: Column(
                            children: [
                              SizedBox(height: size.height * 0.025),
                              if (isCompleted)
                                Text(
                                  '₹10,000/-',
                                  style: GoogleFonts.urbanist(
                                    color: Color(0xffFFFFFF),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              SizedBox(
                                height: isCompleted
                                    ? size.height * 0.01
                                    : size.height * 0.035,
                              ),
                              Text(
                                'On first auction',
                                style: GoogleFonts.urbanist(
                                  color: isCompleted
                                      ? Color(0xff515151).withOpacity(1)
                                      : Color(0xff515151).withOpacity(0.3),
                                  fontSize: 8,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
