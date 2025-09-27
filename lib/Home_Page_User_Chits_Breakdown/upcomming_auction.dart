import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UpcomingAuctionPage extends StatelessWidget {
  const UpcomingAuctionPage({super.key});

  final List<Map<String, dynamic>> chitList = const [
    {
      "title": "₹2 Lakh Chit",
      "type": "Due Pending",
      "value": "2,00,000/-",
      "contribution": "10,000/-",
      "totalMembers": "20",
      "addedMembers": "08",
      "startDate": "05-11-2025",
      "endDate": "05-03-2027",
      "duration": "20 Months",
      "auctionDate": "05-12-2025",
    },
    {
      "title": "₹4 Lakh Chit",
      "type": "Due Pending",
      "value": "4,00,000/-",
      "contribution": "20,000/-",
      "totalMembers": "10",
      "addedMembers": "09",
      "startDate": "06-12-2025",
      "endDate": "06-12-2026",
      "duration": "10 Months",
      "auctionDate": "06-01-2026",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: chitList.map((chit) {
        return Padding(
          padding: EdgeInsets.only(bottom: size.height * 0.02),
          child: ChitCard(chit: chit),
        );
      }).toList(),
    );
  }
}

class ChitCard extends StatelessWidget {
  final Map<String, dynamic> chit;

  const ChitCard({super.key, required this.chit});

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
                chit["title"],
                style: GoogleFonts.urbanist(
                  color: const Color(0xff3A7AFF),
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                chit["type"],
                style: GoogleFonts.urbanist(
                  color: chit["type"] == "Due Pending"
                      ? Color(0xffC60F12)
                      : chit["type"] == "Due Paid"
                      ? Color(0xff03DF96)
                      : Color(0xffB5B4B4),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.01),

          _buildInfoRow(
            "Chit Value : ${chit["value"]}",
            "Mon.Contribution : ${chit["contribution"]}",
          ),
          _buildInfoRow(
            "Total Members : ${chit["totalMembers"]}",
            "Added Members : ${chit["addedMembers"]}",
          ),
          _buildInfoRow(
            "Start Date : ${chit["startDate"]}",
            "End Date : ${chit["endDate"]}",
          ),
          _buildInfoRow(
            "Duration : ${chit["duration"]}",
            "Auction Date : ${chit["auctionDate"]}",
          ),
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
              color: right.contains("Auction Date")
                  ? const Color(0xff1762FC)
                  : const Color(0xffF8F8F8),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
