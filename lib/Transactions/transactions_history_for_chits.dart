import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class transactions_history_for_chits extends StatelessWidget {
  const transactions_history_for_chits({super.key});

  final List<Map<String, dynamic>> transactions = const [
    {
      "title": "₹2 Lakh Chit",
      "date": "01-10-2025",
      "amount": "- ₹5,000",
      "type": "debited",
    },
    {
      "title": "Chit Winning Amount",
      "date": "01-10-2025",
      "amount": "+ ₹1,25,000",
      "type": "credited",
    },
    {
      "title": "Referral Bonus",
      "date": "01-10-2025",
      "amount": "+ ₹200",
      "type": "credited",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return ListView.builder(
      shrinkWrap: true,
      // ← Let ListView take minimal height
      physics: const NeverScrollableScrollPhysics(),
      // ← Disable scrolling inside parent
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final tx = transactions[index];
        return Column(
          children: [
            Container(
              width: double.infinity,
              height: 58,
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.04,
                vertical: size.height * 0.01,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(11),
                color: Color(0xff2C2C2C),
              ),
              child: Row(
                children: [
                  Image.asset(
                    transactions[index]["type"] == "debited"
                        ? "assets/images/Transactions/debited.png"
                        : "assets/images/Transactions/credited.png",
                    width: 20,
                    height: 20,
                  ),
                  SizedBox(width: size.width * 0.04),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx["title"],
                        style: GoogleFonts.urbanist(
                          color: const Color(0xffFFFFFF),
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        tx["date"],
                        style: GoogleFonts.urbanist(
                          color: const Color(0xffFFFFFF),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  Text(
                    tx["amount"],
                    style: GoogleFonts.urbanist(
                      color: const Color(0xffFFFFFF),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: size.height * 0.015),
          ],
        );
      },
    );
  }
}
