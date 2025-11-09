import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user_app/widgets/noise_background_container.dart';

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
                child: NoiseBackgroundContainer(
                  height: 145,
                  // same height as before
                  dotSize: 0.5,
                  // set 1.0 for visible dots; reduce if too strong
                  density: 1,
                  // tweak: smaller = more dots; larger = fewer dots
                  opacity: 0.15,
                  // 15% opacity
                  color: Colors.white,
                  child: Container(
                    width: double.infinity,
                    height: 145,
                    decoration: BoxDecoration(
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
                                    fontSize: 17,
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
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '₹100,000',
                                    style: GoogleFonts.urbanist(
                                      textStyle: const TextStyle(
                                        color: Color(0xffF8C545),
                                        fontSize: 15,
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
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '16.0 g',
                                    style: GoogleFonts.urbanist(
                                      textStyle: const TextStyle(
                                        color: Color(0xffF8C545),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

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
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
