import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user_app/Investments/Gold/get_physical_gold_screen.dart';
import 'package:user_app/Investments/Gold/gold_investment_screen.dart';
import 'package:user_app/Investments/toggle_screen_gold_realestate.dart';

import '../Investments/Gold/sell_gold_screen.dart';

class my_investment_gold extends StatefulWidget {
  final VoidCallback? onGoldSellTap;
  final int totalMonths;
  final int completedMonths;
  final int chitValue;
  final int totalContribution;

  const my_investment_gold({
    super.key,
    this.onGoldSellTap,
    required this.totalMonths,
    required this.completedMonths,
    required this.chitValue,
    required this.totalContribution,
  });

  @override
  State<my_investment_gold> createState() => _my_investment_goldState();
}

final chit_month = 20;
final completed_chits = 6;

class _my_investment_goldState extends State<my_investment_gold> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double progress = widget.completedMonths / widget.totalMonths;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: size.width * 0.45,
              height: 68,
              decoration: BoxDecoration(
                color: Color(0xff323B48),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: size.height * 0.01,
                  horizontal: size.width * 0.04,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Gold',
                      style: GoogleFonts.urbanist(
                        textStyle: const TextStyle(
                          color: Color(0xffDBDBDB),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '28.5 grams',
                      style: GoogleFonts.urbanist(
                        textStyle: const TextStyle(
                          color: Color(0xff5B8EF8),
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: size.width * 0.45,
              height: 68,
              decoration: BoxDecoration(
                color: Color(0xff323B48),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: size.height * 0.01,
                  horizontal: size.width * 0.04,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Value',
                      style: GoogleFonts.urbanist(
                        textStyle: const TextStyle(
                          color: Color(0xffDBDBDB),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '₹1,78,125',
                      style: GoogleFonts.urbanist(
                        textStyle: const TextStyle(
                          color: Color(0xff5B8EF8),
                          fontSize: 20,
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
        SizedBox(height: size.height * 0.02),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: size.width * 0.45,
              height: 68,
              decoration: BoxDecoration(
                color: Color(0xff323B48),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: size.height * 0.01,
                  horizontal: size.width * 0.04,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Investment',
                      style: GoogleFonts.urbanist(
                        textStyle: const TextStyle(
                          color: Color(0xffDBDBDB),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '₹1,65,000',
                      style: GoogleFonts.urbanist(
                        textStyle: const TextStyle(
                          color: Color(0xff5B8EF8),
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: size.width * 0.45,
              height: 68,
              decoration: BoxDecoration(
                color: Color(0xff323B48),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: size.height * 0.01,
                  horizontal: size.width * 0.04,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Returns',
                      style: GoogleFonts.urbanist(
                        textStyle: const TextStyle(
                          color: Color(0xffDBDBDB),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '+₹13,125 (7.9%)',
                      style: GoogleFonts.urbanist(
                        textStyle: const TextStyle(
                          color: Color(0xff5B8EF8),
                          fontSize: 20,
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
        SizedBox(height: size.height * 0.03),
        Container(
          width: double.infinity,
          height: 273,
          decoration: BoxDecoration(
            color: Color(0xff1D1D1D),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.05,
              vertical: size.height * 0.015,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${widget.totalMonths} Months',
                      style: GoogleFonts.urbanist(
                        color: Color(0xffFFFFFF),
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '₹${widget.chitValue.toString()}/month',
                      style: GoogleFonts.urbanist(
                        color: Color(0xffFFFFFF),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.02),
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
                                colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
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
                SizedBox(height: size.height * 0.025),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Invested',
                          style: GoogleFonts.urbanist(
                            color: Color(0xffDBDBDB),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '₹60,000',
                          style: GoogleFonts.urbanist(
                            color: Color(0xff5B8EF8),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: size.height * 0.015),
                        Text(
                          'Gold Accumulated',
                          style: GoogleFonts.urbanist(
                            color: Color(0xffDBDBDB),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '9.6 grams',
                          style: GoogleFonts.urbanist(
                            color: Color(0xff5B8EF8),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Target Amount',
                          style: GoogleFonts.urbanist(
                            color: Color(0xffDBDBDB),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '₹1,00,000',
                          style: GoogleFonts.urbanist(
                            color: Color(0xff5B8EF8),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: size.height * 0.015),
                        Text(
                          'Maturity Date',
                          style: GoogleFonts.urbanist(
                            color: Color(0xffDBDBDB),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Apr 2026',
                          style: GoogleFonts.urbanist(
                            color: Color(0xff5B8EF8),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.02),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    width: 66,
                    height: 26,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(11),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xff2C5DC2), Color(0xff4C71BC)],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Pay Now',
                        style: GoogleFonts.urbanist(
                          color: Color(0xffFFFFFF),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: size.height * 0.03),
        Container(
          width: double.infinity,
          height: 208,
          decoration: BoxDecoration(
            color: Color(0xff1D1D1D),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: size.height * 0.02,
              horizontal: size.width * 0.05,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Redemption Options',
                  style: GoogleFonts.urbanist(
                    textStyle: const TextStyle(
                      color: Color(0xffFFFFFF),
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.03),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => toggle_gold_realestate(initialIsGold: true,initialTab: 1,)),
                        );
                      },
                      child: Container(
                        width: size.width * 0.4,
                        height: 47,
                        decoration: BoxDecoration(
                          color: Color(0xffD9D9D9),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: size.height * 0.01,
                            horizontal: size.width * 0.05,
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Sell as Digital Gold',
                                style: GoogleFonts.urbanist(
                                  textStyle: const TextStyle(
                                    color: Color(0xff000000),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              SizedBox(width: size.width * 0.015),
                              Image.asset(
                                'assets/images/My_Investments/sell_as_digital_gold.png',
                                width: 13,
                                height: 13,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => get_physical_gold(),
                          ),
                        );
                      },
                      child: Container(
                        width: size.width * 0.4,
                        height: 47,
                        decoration: BoxDecoration(
                          color: Color(0xffD9D9D9),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: size.height * 0.01,
                            horizontal: size.width * 0.03,
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Convert Physical Gold',
                                style: GoogleFonts.urbanist(
                                  textStyle: const TextStyle(
                                    color: Color(0xff000000),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              SizedBox(width: size.width * 0.015),
                              Image.asset(
                                'assets/images/My_Investments/convert_physical_gold.png',
                                width: 13,
                                height: 13,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.035),
                Text(
                  'Note: Physical gold can be collected from our partner jewellery\nstores. A voucher will be generated for redemption',
                  style: GoogleFonts.urbanist(
                    textStyle: const TextStyle(
                      color: Color(0xffA5A5A5),
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
    );
  }
}
