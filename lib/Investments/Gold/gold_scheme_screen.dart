import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class gold_scheme extends StatefulWidget {
  const gold_scheme({super.key});

  @override
  State<gold_scheme> createState() => _gold_schemeState();
}

class _gold_schemeState extends State<gold_scheme> {
  @override
  Widget build(BuildContext context) {
    final List<String> buy_gold_amount_tag = ['10', '08', '12'];
    final size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: size.height * 0.02),
        Row(
          children: [
            Image.asset(
              'assets/images/Investments/gold_scheme.png',
              width: 24,
              height: 24,
            ),
            SizedBox(width: size.width * 0.02),
            Text(
              'Schemes',
              style: GoogleFonts.urbanist(
                textStyle: const TextStyle(
                  color: Color(0xffFFFFFF),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: size.height * 0.02),
        SingleChildScrollView(
          child: Column(
            children: List.generate(buy_gold_amount_tag.length, (index) {
              return Padding(
                padding: EdgeInsets.only(bottom: size.width * 0.05),
                child: Container(
                  width: double.infinity,
                  height: 160,
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
                              '${buy_gold_amount_tag[index]} Month Plan',
                              style: GoogleFonts.urbanist(
                                textStyle: const TextStyle(
                                  color: Color(0xffFFFFFF),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              '₹10,000/month',
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
                        SizedBox(height: size.height * 0.02),
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Value',
                                  style: GoogleFonts.urbanist(
                                    textStyle: const TextStyle(
                                      color: Color(0xffDBDBDB),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  '₹100,000',
                                  style: GoogleFonts.urbanist(
                                    textStyle: const TextStyle(
                                      color: Color(0xffF8C545),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: size.width * 0.05),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Est. Gold',
                                  style: GoogleFonts.urbanist(
                                    textStyle: const TextStyle(
                                      color: Color(0xffDBDBDB),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  '16.0 g',
                                  style: GoogleFonts.urbanist(
                                    textStyle: const TextStyle(
                                      color: Color(0xffF8C545),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
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
                            width: 89,
                            height: 26,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(7),
                              gradient: LinearGradient(
                                colors: [Color(0xffF8C545), Color(0xff8F7021)],
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Subscribe',
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
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
