import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Models/User_chit_breakdown/user_chit_breakdown_model.dart';
import 'package:shimmer/shimmer.dart';

class TotalChitsPage extends StatefulWidget {
  final List<Chit> chitList;
  const TotalChitsPage({super.key, required this.chitList});

  @override
  State<TotalChitsPage> createState() => _TotalChitsPageState();
}
class _TotalChitsPageState extends State<TotalChitsPage> {
  late List<Chit> chits;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChits();
  }

  Future<void> _loadChits() async {
    setState(() => isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800)); // simulate short delay
    setState(() {
      chits = widget.chitList;
      isLoading = false;
    });
  }

  Future<void> _refreshChits() async {
    await _loadChits(); // reload data (or from API later)
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _refreshChits,
        color: Colors.white,
        backgroundColor: const Color(0xff3A7AFF),
        child: LayoutBuilder(
            builder: (context, constraints){
             return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: isLoading
                ? _buildShimmerLoader(size)
                : chits.isEmpty
                ? Padding(
              padding: EdgeInsets.only(top: size.height * 0.35),
              child: Center(
                child: Text(
                  "No chits found 😄",
                  style: GoogleFonts.urbanist(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: size.height * 0.01),
                Column(
                  children: chits.map((chit) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: size.height * 0.02),
                      child: ChitCard(chit: chit),
                    );
                  }).toList(),
                ),
              ],
            ),
          );}
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
  final Chit chit;

  const ChitCard({super.key, required this.chit});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // ✅ Start date = chit.duedate
    final DateTime startDate = _parseDate(chit.duedate);

    // ✅ End date = duedate + (timePeriod - 1) months
    final DateTime endDate = _addMonths(startDate, chit.timePeriod - 1);

    // ✅ Auction date logic:
    // Take first auction where completed == false
    String auctionDate = "Completed";
    if (chit.auctionSchedules.isNotEmpty) {
      for (var auction in chit.auctionSchedules) {
        if (auction.completed == false) {
          auctionDate = _formatDateString(auction.auctionDate);
          break;
        }
      }
    }

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
          // 🔹 Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                chit.chitsName,
                style: GoogleFonts.urbanist(
                  color: const Color(0xff3A7AFF),
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                chit.chitsType,
                style: GoogleFonts.urbanist(
                  color: const Color(0xffB5B4B4),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.01),

          // 🔹 Info Rows
          _buildInfoRow(
            "Chit Value : ₹${chit.value.toStringAsFixed(0)}",
            "Mon.Contribution : ₹${chit.contribution.toStringAsFixed(0)}",
          ),
          _buildInfoRow(
            "Total Members : ${chit.totalMember}",
            "Added Members : ${chit.currentMemberCount}",
          ),
          _buildInfoRow(
            "Start Date : ${_formatDate(startDate)}",
            "End Date : ${_formatDate(endDate)}",
          ),
          _buildInfoRow(
            "Duration : ${chit.timePeriod} Months",
            "Auction Date : $auctionDate",
          ),
        ],
      ),
    );
  }

  // 🔹 Info Row Widget
  Widget _buildInfoRow(String left, String right) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
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

  // 🔹 Helper: Parse date safely
  DateTime _parseDate(String? iso) {
    if (iso == null || iso.isEmpty) return DateTime.now();
    try {
      return DateTime.parse(iso);
    } catch (_) {
      return DateTime.now();
    }
  }

  // 🔹 Helper: Format DateTime → dd-MM-yyyy
  String _formatDate(DateTime d) {
    return "${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}";
  }

  // 🔹 Helper: Format ISO string → dd-MM-yyyy
  String _formatDateString(String? iso) {
    if (iso == null || iso.isEmpty) return '-';
    try {
      final dt = DateTime.parse(iso);
      return _formatDate(dt);
    } catch (_) {
      return '-';
    }
  }

  // 🔹 Helper: Add months to DateTime safely
  DateTime _addMonths(DateTime date, int monthsToAdd) {
    if (monthsToAdd <= 0) return date;
    final int totalMonths = date.month + monthsToAdd;
    final int newYear = date.year + ((totalMonths - 1) ~/ 12);
    final int newMonth = ((totalMonths - 1) % 12) + 1;
    final int lastDay = DateTime(newYear, newMonth + 1, 0).day;
    final int newDay = date.day > lastDay ? lastDay : date.day;
    return DateTime(newYear, newMonth, newDay);
  }
}
