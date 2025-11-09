import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';

class my_investment_realestate extends StatefulWidget {
  final int totalMonths;
  final int completedMonths;

  const my_investment_realestate({
    super.key,
    required this.totalMonths,
    required this.completedMonths,
  });

  @override
  State<my_investment_realestate> createState() =>
      _my_investment_realestateState();
}

final List<Map<String, dynamic>> activeInvestments = [
  {
    'image': 'assets/images/My_Investments/land_sample_pic.jpg',
    'planName': 'Premium Fixed Term Plan',
    'startDate': 'Dec 2024',
    'maturity': 'Dec 2026',
    'invested': '₹60,000',
    'roiEarned': '₹1,00,000',
    'monthlyRoi': '₹1,000',
  },
  {
    'image': 'assets/images/My_Investments/land_sample_pic.jpg',
    'planName': 'Elite Realty Growth Plan',
    'startDate': 'Jan 2025',
    'maturity': 'Jan 2027',
    'invested': '₹80,000',
    'roiEarned': '₹1,20,000',
    'monthlyRoi': '₹1,200',
  },
];

final chit_month = 20;
final completed_chits = 6;

class _my_investment_realestateState extends State<my_investment_realestate> {
  List<Map<String, dynamic>> active = List.from(activeInvestments);
  List<Map<String, dynamic>> history = [];

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
                      'Active Investments',
                      style: GoogleFonts.urbanist(
                        textStyle: const TextStyle(
                          color: Color(0xffDBDBDB),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '1',
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
                      'This Month ROI',
                      style: GoogleFonts.urbanist(
                        textStyle: const TextStyle(
                          color: Color(0xffDBDBDB),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '₹2,229',
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
        Text(
          'Active Investments',
          style: GoogleFonts.urbanist(
            color: Color(0xffAFC9FF),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: size.height * 0.02),
        Column(
          children: List.generate(activeInvestments.length, (index) {
            final item = activeInvestments[index];
            return _investmentCard(
              context,
              size,
              progress,
              item,
              isCompleted: false,
              onCancelPlan: () {
                setState(() {
                  active.removeAt(index);
                  history.add(item);
                });
              },
            );
          }),
        ),
        SizedBox(height: size.height * 0.02),
        Text(
          'Completed Investments',
          style: GoogleFonts.urbanist(
            color: Color(0xffAFC9FF),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: size.height * 0.03),
        history.isEmpty
            ? Column(
                children: [
                  Center(
                    child: Image.asset(
                      'assets/images/My_Investments/no_completed_investment.png',
                      width: 24,
                      height: 24,
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  Center(
                    child: Text(
                      'No completed investments yet',
                      style: GoogleFonts.urbanist(
                        color: Color(0xff8D8D8D),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                children: List.generate(history.length, (index) {
                  final item = history[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _investmentCard(
                        context,
                        size,
                        1.0, // full progress for completed
                        item,
                        isCompleted: true,
                      ),
                    ],
                  );
                }),
              ),
      ],
    );
  }

  Widget _investmentCard(
    BuildContext context,
    Size size,
    double progress,
    Map<String, dynamic> item, {
    required bool isCompleted,
    VoidCallback? onCancelPlan,
  }) {
    return Column(
      children: [
        isCompleted
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(11),
                      topRight: Radius.circular(11),
                    ),
                    child: Image.asset(
                      item['image'],
                      width: double.infinity,
                      height: 174,
                      fit: BoxFit.cover,
                      color: Colors.black.withOpacity(0.5),
                      // dim the image
                      colorBlendMode: BlendMode.darken,
                    ),
                  ),
                  Positioned(
                    top: size.height*0.1,
                    left: size.width*0.3,
                    child: Text(
                      'Plan Canceled by User',
                      style: GoogleFonts.urbanist(
                        color: const Color(0xffFFFFFF),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              )
            : ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(11),
                  topRight: Radius.circular(11),
                ),
                child: Image.asset(
                  item['image'],
                  width: double.infinity,
                  height: 174,
                  fit: BoxFit.cover,
                ),
              ),
        Container(
          width: double.infinity,
          height:isCompleted?240:292,
          margin: EdgeInsets.only(bottom: size.height * 0.02),
          decoration: BoxDecoration(
            color: const Color(0xff1D1D1D),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(11),
              bottomRight: Radius.circular(11),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.05,
              vertical: size.height * 0.02,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: size.height * 0.005),
                Text(
                  '${widget.totalMonths} months @ 10% ROI',
                  style: GoogleFonts.urbanist(
                    color: const Color(0xffFFFFFF),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Duration',
                      style: GoogleFonts.urbanist(
                        color: const Color(0xffDBDBDB),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      isCompleted
                          ? 'Completed'
                          : '${widget.completedMonths} of ${widget.totalMonths} months completed',
                      style: GoogleFonts.urbanist(
                        color: const Color(0xffDBDBDB),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.01),
                // --- Progress Bar ---
                LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth * progress;
                    return Container(
                      width: double.infinity,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xffE5E5E5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Stack(
                        children: [
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
                SizedBox(height: size.height * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Start Date: ${item['startDate']}',
                      style: GoogleFonts.urbanist(
                        color: const Color(0xffFFFFFF),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Maturity: ${item['maturity']}',
                      style: GoogleFonts.urbanist(
                        color: const Color(0xffFFFFFF),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.035),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _infoColumn('Invested', item['invested']),
                    _infoColumn('ROI Earned', item['roiEarned']),
                    _infoColumn('Monthly ROI', item['monthlyRoi']),
                  ],
                ),
                SizedBox(height: size.height * .02),
                if(!isCompleted)
                Align(
                  alignment: Alignment.bottomRight,
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            backgroundColor: const Color(0xffD9D9D9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(11),
                            ),
                            content: Container(
                              height: 150,
                              child: Column(
                                children: [
                                  Text(
                                    'Confirmation',
                                    style: GoogleFonts.urbanist(
                                      fontSize: 16,
                                      color: Color(0xff000000),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: size.height * 0.02),
                                  Divider(height: 1, color: Color(0xffC0C0C0)),
                                  SizedBox(height: size.height * 0.02),
                                  Text(
                                    'Are you sure you want to cancel the\nreal estate plan?',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.urbanist(
                                      color: Color(0xff434343),
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(height: size.height * 0.02),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(width: size.width * 0.05),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                          width: 57,
                                          height: 26,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              7,
                                            ),
                                            color: Color(0xff8B8B8B),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Cancel',
                                              style: GoogleFonts.urbanist(
                                                color: const Color(0xffFFFFFF),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.pop(context);
                                          if (onCancelPlan != null)
                                            onCancelPlan();
                                        },
                                        child: Container(
                                          width: 57,
                                          height: 26,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              7,
                                            ),
                                            gradient: LinearGradient(
                                              colors: [
                                                Color(0xff2C5DC2),
                                                Color(0xff4C71BC),
                                              ],
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Confirm',
                                              style: GoogleFonts.urbanist(
                                                color: const Color(0xffFFFFFF),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: size.width * 0.05),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: Container(
                      width: 66,
                      height: 26,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(7),
                        gradient: LinearGradient(
                          colors: [Color(0xff2C5DC2), Color(0xff4C71BC)],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'End Plan',
                          style: GoogleFonts.urbanist(
                            color: const Color(0xffFFFFFF),
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
          ),
        ),
      ],
    );
  }

  Widget _infoColumn(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.urbanist(
            color: const Color(0xffDBDBDB),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.urbanist(
            color: const Color(0xff5B8EF8),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
