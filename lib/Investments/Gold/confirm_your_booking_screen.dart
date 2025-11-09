import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user_app/Investments/Gold/confirmation_receipts_screen.dart';
import 'package:user_app/Investments/Gold/store_selection_screen.dart';

class confirm_your_booking extends StatefulWidget {
  const confirm_your_booking({super.key});

  @override
  State<confirm_your_booking> createState() => _confirm_your_bookingState();
}

class _confirm_your_bookingState extends State<confirm_your_booking> {
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
                            builder: (context) => store_selection(),
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
                      'Confirm your Booking',
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
                  height: 423,
                  decoration: BoxDecoration(
                    color: Color(0xff1F1F1F),
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(color: Color(0xff61512B), width: .5),
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
                          'Please review your booking details\nbefore confirming',
                          style: GoogleFonts.urbanist(
                            textStyle: const TextStyle(
                              color: Color(0xffDDDDDD),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(height: size.height * 0.02),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.04,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Gold Amount',
                                    style: GoogleFonts.urbanist(
                                      textStyle: const TextStyle(
                                        color: Color(0xff989898),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '8.5g',
                                    style: GoogleFonts.urbanist(
                                      textStyle: const TextStyle(
                                        color: Color(0xff989898),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: size.height * 0.005),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Estimate',
                                    style: GoogleFonts.urbanist(
                                      textStyle: const TextStyle(
                                        color: Color(0xff989898),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '₹92,320',
                                    style: GoogleFonts.urbanist(
                                      textStyle: const TextStyle(
                                        color: Color(0xff989898),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: size.height * 0.005),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Format',
                                    style: GoogleFonts.urbanist(
                                      textStyle: const TextStyle(
                                        color: Color(0xff989898),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'Physical Gold',
                                    style: GoogleFonts.urbanist(
                                      textStyle: const TextStyle(
                                        color: Color(0xff989898),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: size.height * 0.005),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Store',
                                    style: GoogleFonts.urbanist(
                                      textStyle: const TextStyle(
                                        color: Color(0xff989898),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'Malabar- Bangalore',
                                    style: GoogleFonts.urbanist(
                                      textStyle: const TextStyle(
                                        color: Color(0xff989898),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: size.height * 0.005),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Platform Fee',
                                    style: GoogleFonts.urbanist(
                                      textStyle: const TextStyle(
                                        color: Color(0xff989898),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '₹210',
                                    style: GoogleFonts.urbanist(
                                      textStyle: const TextStyle(
                                        color: Color(0xff989898),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: size.height * 0.025),
                              Divider(color: Color(0xff61512B), height: 1),
                              SizedBox(height: size.height * 0.025),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total Gold Value',
                                    style: GoogleFonts.urbanist(
                                      textStyle: const TextStyle(
                                        color: Color(0xffD1AF74),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '8.5 g',
                                    style: GoogleFonts.urbanist(
                                      textStyle: const TextStyle(
                                        color: Color(0xffD1AF74),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: size.height * 0.035),
                              Container(
                                width: double.infinity,
                                height: 51,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Color(0xff515151),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(width: size.width * 0.02),
                                    Center(
                                      child: Image.asset(
                                        'assets/images/Investments/alert_2.png',
                                        width: 16,
                                        height: 16,
                                      ),
                                    ),
                                    SizedBox(width: size.width * 0.02),
                                    Center(
                                      child: Text(
                                        'By confirming, you agree to convert 8.5g of digital gold to\nphysical gold. The amount will be deducted from your holdings\nand charges from your wallet.',
                                        style: GoogleFonts.urbanist(
                                          textStyle: const TextStyle(
                                            color: Color(0xff989898),
                                            fontSize: 9,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: size.height * 0.04),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => confirmation_receipts(),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(11),
                                    color: Color(0xffD4B373),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Confirm Booking',
                                      style: GoogleFonts.urbanist(
                                        textStyle: const TextStyle(
                                          color: Color(0xff544B35),
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
                      ],
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
