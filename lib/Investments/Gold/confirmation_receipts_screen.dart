import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user_app/Investments/Gold/confirm_your_booking_screen.dart';

class confirmation_receipts extends StatefulWidget {
  const confirmation_receipts({super.key});

  @override
  State<confirmation_receipts> createState() => _confirmation_receiptsState();
}

class _confirmation_receiptsState extends State<confirmation_receipts> {
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
                        Navigator.pop(context); // This will go back to the existing get_physical_gold
                      },
                      child: Image.asset(
                        'assets/images/My_Chits/back_arrow.png',
                        width: 24,
                        height: 24,
                      ),
                    ),
                    SizedBox(width: size.width * 0.03),
                    Text(
                      'Confirmation Receipts',
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
                SizedBox(height: size.height * 0.02),
                Container(
                  width: double.infinity,
                  height: 111,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xff795124), Color(0xffD4B277)],
                    ),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(11),
                      topLeft: Radius.circular(11),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.04,
                      vertical: size.height * 0.03,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Foxl Chit Funds',
                              style: GoogleFonts.urbanist(
                                textStyle: const TextStyle(
                                  color: Color(0xffFFFFFF),
                                  fontSize: 25,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              'Official Confirmation Receipt',
                              style: GoogleFonts.urbanist(
                                textStyle: const TextStyle(
                                  color: Color(0xffFFFFFF),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            SizedBox(height: size.height * .02),
                            Text(
                              'Rajesh Kumar (#F02343)',
                              style: GoogleFonts.urbanist(
                                textStyle: const TextStyle(
                                  color: Color(0xffFFFFFF),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(height: size.height * .005),
                            Text(
                              'Booking ID: #GOLD4257',
                              style: GoogleFonts.urbanist(
                                textStyle: const TextStyle(
                                  color: Color(0xffFFFFFF),
                                  fontSize: 10,
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
                Container(
                  width: double.infinity,
                  height: 310,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xff7D5628), Color(0xffD2B075)],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(11),
                      bottomLeft: Radius.circular(11),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(1),
                    child: Container(
                      width: double.infinity,
                      height: 310,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(11),
                          bottomLeft: Radius.circular(11),
                        ),
                        color: Color(0xff000000),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.04,
                          vertical: size.height * 0.03,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 57,
                                  decoration: BoxDecoration(
                                    color: Color(0xffCCA96F),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 57,
                                    decoration: BoxDecoration(
                                      color: Color(0xff2E2E2E),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: size.width * 0.03,
                                        vertical: size.height * 0.01,
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            width: 33,
                                            height: 33,
                                            decoration: BoxDecoration(
                                              color: Color(0xffD3B176),
                                              border: Border.all(
                                                color: Color(0xff7A5225),
                                                width: 1,
                                              ),
                                              borderRadius: BorderRadius.circular(
                                                30,
                                              ),
                                            ),
                                            child: Center(
                                              child: Image.asset(
                                                'assets/images/Investments/booking_confirmed.png',
                                                width: 15,
                                                height: 15,
                                              ),
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(height: size.height*0.005,),
                                              Text(
                                                'Booking Confirmed',
                                                style: GoogleFonts.urbanist(
                                                  textStyle: const TextStyle(
                                                    color: Color(0xffFFFFFF),
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                'Your physical gold conversion has been scheduled successfully.',
                                                style: GoogleFonts.urbanist(
                                                  textStyle: const TextStyle(
                                                    color: Color(0xffCBA86F),
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: size.height*0.02,),
                            Container(
                              width: double.infinity,
                              height: 180,
                              decoration: BoxDecoration(
                                color: Color(0xff2E2E2E),
                                borderRadius: BorderRadius.circular(11)
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
                                      'Booking Details',
                                      style: GoogleFonts.urbanist(
                                        textStyle: const TextStyle(
                                          color: Color(0xffFFFFFF),
                                          fontSize:13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: size.height*0.015),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Collection Store',
                                              style: GoogleFonts.urbanist(
                                                textStyle: const TextStyle(
                                                  color: Color(0xff6E6E6E),
                                                  fontSize:9,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              'Malabar- Bangalore',
                                              style: GoogleFonts.urbanist(
                                                textStyle: const TextStyle(
                                                  color: Color(0xff989898),
                                                  fontSize:12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: size.height*0.01),
                                            Text(
                                              'Convertion Date',
                                              style: GoogleFonts.urbanist(
                                                textStyle: const TextStyle(
                                                  color: Color(0xff6E6E6E),
                                                  fontSize:9,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              '11 November 2025',
                                              style: GoogleFonts.urbanist(
                                                textStyle: const TextStyle(
                                                  color: Color(0xff989898),
                                                  fontSize:12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: size.height*0.01),
                                            Text(
                                              'Collection Date',
                                              style: GoogleFonts.urbanist(
                                                textStyle: const TextStyle(
                                                  color: Color(0xff6E6E6E),
                                                  fontSize:9,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              '3 days from the date of convertion.',
                                              style: GoogleFonts.urbanist(
                                                textStyle: const TextStyle(
                                                  color: Color(0xff989898),
                                                  fontSize:12,
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
                                              'Gold Details',
                                              style: GoogleFonts.urbanist(
                                                textStyle: const TextStyle(
                                                  color: Color(0xff6E6E6E),
                                                  fontSize:9,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              '10g',
                                              style: GoogleFonts.urbanist(
                                                textStyle: const TextStyle(
                                                  color: Color(0xff989898),
                                                  fontSize:12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: size.height*0.01),
                                            Text(
                                              'Store Contact',
                                              style: GoogleFonts.urbanist(
                                                textStyle: const TextStyle(
                                                  color: Color(0xff6E6E6E),
                                                  fontSize:9,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              '+91 80 6789 5432',
                                              style: GoogleFonts.urbanist(
                                                textStyle: const TextStyle(
                                                  color: Color(0xff989898),
                                                  fontSize:12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: size.height*0.045),
                                          ],
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: size.height*0.04),
                Container(
                  width: double.infinity,
                  height: 174,
                  decoration: BoxDecoration(
                    color: Color(0xff1F1F1F),
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(color: Color(0xff81592B),width: 0.5)
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.045,
                      vertical: size.height * 0.02,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Important Instructions',
                          style: GoogleFonts.urbanist(
                            textStyle: const TextStyle(
                              color: Color(0xffC5AE6D),
                              fontSize:13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(height: size.height*0.02),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: Color(0xff61512B),
                                borderRadius: BorderRadius.circular(5)
                              ),
                            ),
                            Text(
                              'Bring a valid government-issued photo ID for verification',
                              style: GoogleFonts.urbanist(
                                textStyle: const TextStyle(
                                  color: Color(0xffA09984),
                                  fontSize:12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: size.height*0.005),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                  color: Color(0xff61512B),
                                  borderRadius: BorderRadius.circular(5)
                              ),
                            ),
                            Text(
                              'Show this booking confirmation at the store                       ',
                              style: GoogleFonts.urbanist(
                                textStyle: const TextStyle(
                                  color: Color(0xffA09984),
                                  fontSize:12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: size.height*0.005),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                  color: Color(0xff61512B),
                                  borderRadius: BorderRadius.circular(5)
                              ),
                            ),
                            Text(
                              'The gold will be inspected and verified in your presence ',
                              style: GoogleFonts.urbanist(
                                textStyle: const TextStyle(
                                  color: Color(0xffA09984),
                                  fontSize:12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: size.height*0.005),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                  color: Color(0xff61512B),
                                  borderRadius: BorderRadius.circular(5)
                              ),
                            ),
                            Text(
                              "You'll receive a purity certificate with your gold                 ",
                              style: GoogleFonts.urbanist(
                                textStyle: const TextStyle(
                                  color: Color(0xffA09984),
                                  fontSize:12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(height: size.height*0.04),
                Row(
                  children: [
                    SizedBox(width: size.width*0.02,),
                    Image.asset('assets/images/Investments/alert_2.png',width: 16,height: 16,),
                    SizedBox(width: size.width*0.04,),
                    Text(
                      'You can view the Confirmation Receipt in the Receipts Section in\nInvestment Menu',
                      style: GoogleFonts.urbanist(
                        textStyle: const TextStyle(
                          color: Color(0xff989898),
                          fontSize:9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.03),
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
                    height: 37,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(11),
                      color: Color(0xffD4B373),
                    ),
                    child: Center(
                      child: Text(
                        'Download Receipt',
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
        ),
      ),
    );
  }
}
