import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user_app/Investments/Real_Estate/withdraw_for_realestate_screen.dart';
import 'package:user_app/My_Chits/Explore_chits/withdraw_for_chits_screen.dart';

import '../../Bottom_Navbar/bottom_navigation_bar.dart';

class real_estate_investment extends StatefulWidget {
  const real_estate_investment({super.key});

  @override
  State<real_estate_investment> createState() => real_estate_investmentState();
}

class real_estate_investmentState extends State<real_estate_investment> {
  final List<Map<String, dynamic>> activeInvestments = [
    {
      'imagePath': 'assets/images/Investments/land_sample_2.png',
      'planName': 'Premium Fixed Term Plan',
      'duration': '24 months',
      'roi': '10%',
      'invested': '₹2,00,000',
      'roiEarned': '₹16,667',
      'monthlyRoi': '₹1,667',
      'points': [
        'Withdraw anytime after 6 months',
        'Monthly ROI credited to wallet',
        'No penalty on withdrawal',
      ],
    },
    {
      'imagePath': 'assets/images/Investments/land_sample_2.png',
      'planName': 'Elite Growth Plan',
      'duration': '36 months',
      'roi': '12%',
      'invested': '₹3,00,000',
      'roiEarned': '₹24,000',
      'monthlyRoi': '₹2,000',
      'points': [
        'Withdraw anytime after 12 months',
        'ROI credited quarterly',
        'Tax benefits applicable',
      ],
    },
    {
      'imagePath': 'assets/images/Investments/land_sample_2.png',
      'planName': 'Elite Growth Plan',
      'duration': '36 months',
      'roi': '12%',
      'invested': '₹3,00,000',
      'roiEarned': '₹24,000',
      'monthlyRoi': '₹2,000',
      'points': [
        'Withdraw anytime after 12 months',
        'ROI credited quarterly',
        'Tax benefits applicable',
      ],
    },
    {
      'imagePath': 'assets/images/Investments/land_sample_2.png',
      'planName': 'Elite Growth Plan',
      'duration': '36 months',
      'roi': '12%',
      'invested': '₹3,00,000',
      'roiEarned': '₹24,000',
      'monthlyRoi': '₹2,000',
      'points': [
        'Withdraw anytime after 12 months',
        'ROI credited quarterly',
        'Tax benefits applicable',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Color(0xff000000),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: size.width,
            height: activeInvestments.length*600,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  'assets/images/Investments/realestate_background.png',
                ),
                fit: BoxFit.cover, // full screen
              ),
            ),
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
                            MaterialPageRoute(builder: (context) => HomeLayout(initialTab: 2,)),
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
                        'Investments',
                        style: GoogleFonts.urbanist(
                          textStyle: const TextStyle(
                            color: Color(0xffE2E2E2),
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(width: size.width * 0.05),
                      GestureDetector(
                        onTap: () {},
                        child: AnimatedContainer(
                          height: 20,
                          width: 70,
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [Color(0xff1D3D74),Color(0xff071020)]),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              'Real Estate',
                              style: GoogleFonts.urbanist(
                                textStyle: const TextStyle(
                                  color: Color(0xffFFFFFF),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: size.height * 0.02),
                  Container(
                    width: double.infinity,
                    height: 194,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                          'assets/images/Investments/realestate_card.png',
                        ),
                        fit: BoxFit.fill, // full screen
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.05,
                        vertical: size.height * 0.03,
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total Invested',
                                    style: GoogleFonts.urbanist(
                                      textStyle: const TextStyle(
                                        color: Color(0xffFFFFFF),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '₹2,67,500',
                                    style: GoogleFonts.urbanist(
                                      textStyle: const TextStyle(
                                        color: Color(0xffFFFFFF),
                                        fontSize: 30,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '+10% Annual ROI',
                                    style: GoogleFonts.urbanist(
                                      textStyle: const TextStyle(
                                        color: Color(0xff07C66A),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total ROI Earned',
                                    style: GoogleFonts.urbanist(
                                      textStyle: const TextStyle(
                                        color: Color(0xffFFFFFF),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '₹2,67,500',
                                    style: GoogleFonts.urbanist(
                                      textStyle: const TextStyle(
                                        color: Color(0xff07C66A),
                                        fontSize: 30,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: size.height * 0.04),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Number of Investments : 0',
                                style: GoogleFonts.urbanist(
                                  textStyle: const TextStyle(
                                    color: Color(0xffFFFFFF),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => withdraw_for_realestate(),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 73,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: Color(0xff07C66A),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Withdraw',
                                      style: GoogleFonts.urbanist(
                                        textStyle: const TextStyle(
                                          color: Color(0xffFFFFFF),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
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
                  SizedBox(height: size.height * 0.02),
                  // ---------------- Active Investments Section ----------------
                  Text(
                    'Active Investments',
                    style: GoogleFonts.urbanist(
                      textStyle: const TextStyle(
                        color: Color(0xffFFFFFF),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),

                  // Use List.generate (since we are already in SingleChildScrollView)
                  Column(
                    children: List.generate(activeInvestments.length, (index) {
                      final item = activeInvestments[index];
                      return Column(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(11),
                              topRight: Radius.circular(11),
                            ),
                            child: Image.asset(
                              item['imagePath'],
                              width: double.infinity,
                              height: 174,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            height: 269,
                            margin: EdgeInsets.only(bottom: size.height * 0.02),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(
                                  'assets/images/Investments/realestatecard_2.png',
                                ),
                                fit: BoxFit.fill,
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: size.width * 0.05,
                                vertical: size.height * 0.015,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['planName'],
                                    style: GoogleFonts.urbanist(
                                      textStyle: const TextStyle(
                                        color: Color(0xff6FA7FF),
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${item['duration']} @ ${item['roi']} ROI',
                                    style: GoogleFonts.urbanist(
                                      textStyle: const TextStyle(
                                        color: Color(0xffDBDBDB),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: size.height * 0.02),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildInfoColumn(
                                        'Invested',
                                        item['invested'],
                                      ),
                                      _buildInfoColumn(
                                        'ROI Earned',
                                        item['roiEarned'],
                                      ),
                                      _buildInfoColumn(
                                        'Monthly ROI',
                                        item['monthlyRoi'],
                                      ),
                                      SizedBox(width: size.width * 0.08),
                                    ],
                                  ),
                                  SizedBox(height: size.height * 0.02),
                                  ...item['points'].map<Widget>(
                                    (text) => Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.play_arrow_rounded,
                                            color: Color(0xff6FA7FF),
                                            size: 16,
                                          ),
                                          SizedBox(width: size.width * 0.02),
                                          Text(
                                            text,
                                            style: GoogleFonts.urbanist(
                                              textStyle: const TextStyle(
                                                color: Color(0xffDBDBDB),
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: size.height* 0.02),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Container(
                                      width: 89,
                                      height: 26,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(7),
                                        gradient: LinearGradient(
                                          colors: [Color(0xff5A8FAB), Color(0xff09283A)],
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Subscribe',
                                          style: GoogleFonts.urbanist(
                                            textStyle: const TextStyle(
                                              color: Color(0xffFFFFFF),
                                              fontSize: 13,
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
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.urbanist(
            textStyle: const TextStyle(
              color: Color(0xffDBDBDB),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.urbanist(
            textStyle: const TextStyle(
              color: Color(0xff6FA7FF),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
