import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PendingPaymentsPage extends StatelessWidget {
  const PendingPaymentsPage({super.key});

  final List<Map<String, dynamic>> chitList = const [
    {
      "title": "₹2 Lakh Chit",
      "type": "Due Pending",
      "value": "2,00,000/-",
      "contribution": "10,000/-",
    },
    {
      "title": "₹4 Lakh Chit",
      "type": "Due Paid",
      "value": "4,00,000/-",
      "contribution": "20,000/-",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Wants to pay a month ₹ 20,000",
            style: GoogleFonts.urbanist(
              color: Color(0xffFFFFFF),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: size.height * 0.02),
          Column(
            children: chitList.map((chit) {
              return Padding(
                padding: EdgeInsets.only(bottom: size.height * 0.02),
                child: ChitCard_for_pay_pending(chit: chit),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class ChitCard_for_pay_pending extends StatelessWidget {
  final Map<String, dynamic> chit;

  const ChitCard_for_pay_pending({super.key, required this.chit});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.04,
        vertical: size.height * 0.02,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xff232323), Color(0xff383836)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                chit["title"] ?? "",
                style: GoogleFonts.urbanist(
                  color: const Color(0xff3A7AFF),
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                chit["type"] ?? "",
                style: GoogleFonts.urbanist(
                  color: chit["type"] == "Due Pending"
                      ? const Color(0xffC60F12)
                      : chit["type"] == "Due Paid"
                      ? const Color(0xff03DF96)
                      : const Color(0xffB5B4B4),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.01),

          _buildInfoRow(
            "Chit Value : ${chit["value"] ?? "-"}",
            "Mon.Contribution : ${chit["contribution"] ?? "-"}",
          ),
          SizedBox(height: size.height * 0.01),
          chit["type"] == "Due Pending"
              ? Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    width: 63,
                    height: 22,
                    decoration: BoxDecoration(
                      color: Color(0xffFFFFFF),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        "Pay Due",
                        style: GoogleFonts.urbanist(
                          color: const Color(0xff000000),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                )
              : SizedBox(height: 1),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String left, String right) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            left,
            style: GoogleFonts.urbanist(
              color: const Color(0xffF8F8F8),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            right,
            style: GoogleFonts.urbanist(
              color: const Color(0xffF8F8F8),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
