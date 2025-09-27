import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class contribution extends StatelessWidget {
  const contribution({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final List<Map<String, dynamic>> contributions = const [
      {
        "title": "₹2 Lakh Chit",
        "type": "Monthly",
        "amount": "₹5000",
        "progress": "12/15",
        "nextDue": "Oct 5, 2025",
      },
      {
        "title": "₹2 Lakh Chit",
        "type": "Monthly",
        "amount": "₹5000",
        "progress": "12/15",
        "nextDue": "Oct 5, 2025",
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      // ← Let ListView take minimal height
      physics: const NeverScrollableScrollPhysics(),
      // ← Disable scrolling inside parent
      itemCount: contributions.length,
      itemBuilder: (context, index) {
        final tx = contributions[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 110,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xff2C2C2C),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(11),
                  topLeft: Radius.circular(11),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.035,
                  vertical: size.height * 0.01,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          tx['title'],
                          style: GoogleFonts.urbanist(
                            color: const Color(0xff3A7AFF),
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          tx['type'],
                          style: GoogleFonts.urbanist(
                            color: const Color(0xffB5B4B4),
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
                          'Contibution',
                          style: GoogleFonts.urbanist(
                            color: const Color(0xffB5B4B4),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Progress',
                          style: GoogleFonts.urbanist(
                            color: const Color(0xffB5B4B4),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: size.height * 0.001),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          tx['amount'],
                          style: GoogleFonts.urbanist(
                            color: const Color(0xff3A7AFF),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          tx['progress'],
                          style: GoogleFonts.urbanist(
                            color: const Color(0xff3A7AFF),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: 42,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xff515151),
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(11),
                  bottomLeft: Radius.circular(11),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.035,
                  vertical: size.height * 0.01,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Next Due : ${tx['nextDue']}',
                      style: GoogleFonts.urbanist(
                        color: const Color(0xffB5B4B4),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: 71,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Color(0xff747474),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Center(
                          child: Text(
                            'Pay Now',
                            style: GoogleFonts.urbanist(
                              color: const Color(0xffFFFFFF),
                              fontSize: 13,
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
            SizedBox(height: size.height * 0.015),
          ],
        );
      },
    );
  }
}
