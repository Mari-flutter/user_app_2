import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user_app/Bottom_Navbar/bottom_navigation_bar.dart';

class draw_for_loosers extends StatefulWidget {
  const draw_for_loosers({super.key});

  @override
  State<draw_for_loosers> createState() => _draw_for_loosersState();
}

class _draw_for_loosersState extends State<draw_for_loosers> {
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '₹2 Lakh Chit',
                            style: GoogleFonts.urbanist(
                              textStyle: const TextStyle(
                                color: Color(0xffE2E2E2),
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(height: size.height * 0.002),
                          Text(
                            '#F025271',
                            style: GoogleFonts.urbanist(
                              textStyle: const TextStyle(
                                color: Color(0xffADADAD),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      width: 100,
                      height: 28,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(11),
                        color: Color(0xff353535),
                      ),

                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/images/Live_Auction/bid_on_live.png',
                              width: 31,
                              height: 31,
                            ),
                            Text(
                              'Bid on Live',
                              style: GoogleFonts.urbanist(
                                textStyle: const TextStyle(
                                  color: Color(0xffFFFFFF),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            SizedBox(width: size.width * 0.01),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.15),
                Center(
                  child: Image.asset(
                    'assets/images/Live_Auction/draw_for_loosers.png',
                    width: 208,
                    height: 208,
                  ),
                ),
                SizedBox(height: size.height * 0.04),
                Center(
                  child: Text(
                    'Draw win by Rajesh Kumar',
                    style: GoogleFonts.urbanist(
                      textStyle: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        foreground: Paint()
                          ..shader = LinearGradient(
                            colors: [
                              Color(0xFFFFFFFF),
                              Color(0xFFFFFFFF),
                              Color(0xFFD47A18),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.01),
                Center(
                  child: Text(
                    'Stay tuned for the next draw!',
                    style: GoogleFonts.urbanist(
                      textStyle: const TextStyle(
                        color: Color(0xffB6B6B6),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.28),
                Center(
                  child: SizedBox(
                    width: 276,
                    height: 37,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff585858),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HomeLayout()),
                        );
                      },
                      child: Text(
                        'Go to Home',
                        style: GoogleFonts.urbanist(
                          textStyle: const TextStyle(
                            color: Color(0xffFFFFFF),
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
    );
  }
}
