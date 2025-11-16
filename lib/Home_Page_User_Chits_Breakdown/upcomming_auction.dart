import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../Models/User_chit_breakdown/user_chit_breakdown_model.dart';
import '../Services/secure_storage.dart';

class UpcomingAuctionPage extends StatefulWidget {
  final List<Chit> chitList;
  final Function(int)? onCountUpdated;
  const UpcomingAuctionPage({super.key, required this.chitList, this.onCountUpdated,});

  @override
  State<UpcomingAuctionPage> createState() => _UpcomingAuctionPageState();
}

class _UpcomingAuctionPageState extends State<UpcomingAuctionPage> {
  List<Map<String, dynamic>> upcomingChits = [];
  bool isLoading = true;
  bool isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadAuctions();
  }

  Future<void> _loadAuctions() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    await Future.delayed(const Duration(milliseconds: 300));
    _filterUpcomingAuctions();
    if (!mounted) return;
    setState(() => isLoading = false);
  }

  Future<void> _refreshAuctions() async {
    if (!mounted) return;
    setState(() => isRefreshing = true);
    await Future.delayed(const Duration(milliseconds: 400));
    _filterUpcomingAuctions();
    if (!mounted) return;
    setState(() => isRefreshing = false);
  }

  void _filterUpcomingAuctions() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final List<Map<String, dynamic>> filtered = [];

    for (final chit in widget.chitList) {
      if (chit.auctionSchedules.isEmpty) continue;

      // Sort auction schedules by date (earliest first)
      chit.auctionSchedules.sort((a, b) =>
          DateTime.parse(a.auctionDate).compareTo(DateTime.parse(b.auctionDate)));

      // Loop through each auction schedule
      for (final schedule in chit.auctionSchedules) {
        final auctionDate = DateTime.parse(schedule.auctionDate);
        final auctionDay = DateTime(auctionDate.year, auctionDate.month, auctionDate.day);
        final difference = auctionDay.difference(today).inDays;

        // ✅ Show from 5 days before auction date until 1 day before auction
        if (!schedule.completed && difference <= 5 && difference >= 1) {
          filtered.add({
            "title": chit.chitsName,
            "type": "Upcoming",
            "value": "₹${chit.value.toStringAsFixed(0)}/-",
            "contribution": "₹${chit.contribution.toStringAsFixed(0)}/-",
            "totalMembers": chit.totalMember.toString(),
            "addedMembers": chit.currentMemberCount.toString(),
            "startDate": _formatDate(DateTime.parse(chit.duedate)),
            "endDate": _formatDate(
                _addMonths(DateTime.parse(chit.duedate), chit.timePeriod - 1)),
            "duration": "${chit.timePeriod} Months",
            "auctionDate": _formatDate(auctionDate),
            "auctionTime": _formatTime(auctionDate),
          });
          break; // ✅ Stop after first valid upcoming auction per chit
        }
      }
    }

    // Sort all by auction date ascending
    filtered.sort((a, b) => a["auctionDate"].compareTo(b["auctionDate"]));

    if (!mounted) return;
    setState(() {
      upcomingChits = filtered;
    });

    // ✅ Save count to secure storage
    await SecureStorageService.saveUpcomingAuctionCount(filtered.length);

    // ✅ Notify parent widget if needed
    widget.onCountUpdated?.call(filtered.length);
  }



  String _formatTime(DateTime dt) {
    int hour = dt.hour;
    String minute = dt.minute.toString().padLeft(2, '0');
    String period = hour >= 12 ? "PM" : "AM";

    if (hour == 0) hour = 12;
    else if (hour > 12) hour -= 12;

    return "$hour:$minute $period";
  }

  String _formatDate(DateTime d) =>
      "${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}";
  String _formatDateTime(DateTime dt) {
    // DATE
    const monthNames = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];

    final dateStr =
        "${dt.day.toString().padLeft(2, '0')} ${monthNames[dt.month - 1]} ${dt.year}";

    // TIME
    int hour = dt.hour;
    String minute = dt.minute.toString().padLeft(2, '0');
    String period = hour >= 12 ? "PM" : "AM";

    if (hour == 0) hour = 12;
    else if (hour > 12) hour -= 12;

    final timeStr = "$hour:$minute $period";

    return "$dateStr at $timeStr";
  }

  DateTime _addMonths(DateTime date, int monthsToAdd) {
    final int totalMonths = date.month + monthsToAdd;
    final int newYear = date.year + ((totalMonths - 1) ~/ 12);
    final int newMonth = ((totalMonths - 1) % 12) + 1;
    final int lastDay = DateTime(newYear, newMonth + 1, 0).day;
    final int newDay = date.day > lastDay ? lastDay : date.day;
    return DateTime(newYear, newMonth, newDay);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _refreshAuctions,
        color: Colors.white,
        backgroundColor: const Color(0xff3A7AFF),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
            child: Column(
              children: [
                SizedBox(height: size.height * 0.02),

                if (isLoading)
                  _buildShimmerLoader(size)
                else if (upcomingChits.isEmpty)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: size.height * 0.3),
                      child: Text(
                        "No upcoming auctions found 🎯",
                        style: GoogleFonts.urbanist(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                else
                  Column(
                    children: upcomingChits.map((chit) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: size.height * 0.02),
                        child: ChitCard(chit: chit),
                      );
                    }).toList(),
                  ),

                if (isRefreshing)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: const CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor:
                      AlwaysStoppedAnimation<Color>(Color(0xff3A7AFF)),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoader(Size size) {
    return Shimmer.fromColors(
      baseColor: const Color(0xff2E2E2E),
      highlightColor: const Color(0xff4A4A4A),
      child: Column(
        children: List.generate(3, (index) {
          return Padding(
            padding: EdgeInsets.only(bottom: size.height * 0.02),
            child: Container(
              width: double.infinity,
              height: size.height * 0.18,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          );
        }),
      ),
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
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                chit["type"],
                style: GoogleFonts.urbanist(
                  color: const Color(0xffB5B4B4),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.01),
          _buildInfoRow("Chit Value : ${chit["value"]}",
              "Mon.Contribution : ${chit["contribution"]}"),
          _buildInfoRow("Total Members : ${chit["totalMembers"]}",
              "Added Members : ${chit["addedMembers"]}"),
          _buildInfoRow("Duration : ${chit["duration"]}",
              "End Date : ${chit["endDate"]}"),
          _buildInfoRow(
              "Auction Date : ${chit["auctionDate"]}", "Auction Time : ${chit["auctionTime"]}"),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String left, String right) {
    bool isAuctionRow =
        left.contains("Auction Date") || left.contains("Auction Time") ||
            right.contains("Auction Date") || right.contains("Auction Time");

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            left,
            style: GoogleFonts.urbanist(
              color: isAuctionRow ? const Color(0xff1762FC) : const Color(0xffF8F8F8),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            right,
            style: GoogleFonts.urbanist(
              color: isAuctionRow ? const Color(0xff1762FC) : const Color(0xffF8F8F8),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
