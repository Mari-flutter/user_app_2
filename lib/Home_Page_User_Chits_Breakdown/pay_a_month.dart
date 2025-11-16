import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../Models/User_chit_breakdown/pending_payment_model.dart';
import '../Services/pending_payment_service.dart';

class PayMonthPage extends StatefulWidget {
  const PayMonthPage({super.key});

  @override
  State<PayMonthPage> createState() => _PayMonthPageState();
}

class _PayMonthPageState extends State<PayMonthPage> {
  List<PendingPayment> allPayments = [];
  bool isLoading = true;
  double totalMonthPay = 0;

  @override
  void initState() {
    super.initState();
    fetchAllChits();
  }

  Future<void> fetchAllChits() async {
    try {
      final payments = await PendingPaymentService.fetchAllChitPayments(context);

      // ✅ Calculate total pending across all chits
      final total = payments.fold<double>(
        0,
            (sum, p) => sum + p.pendingAmount,
      );

      setState(() {
        allPayments = payments;
        totalMonthPay = total;
        isLoading = false;
      });

      print("✅ Loaded ${payments.length} chit records (all types)");
    } catch (e) {
      print("⚠️ Error loading chit records: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: fetchAllChits,
        color: Colors.white,
        backgroundColor: const Color(0xff3A7AFF),
        child: LayoutBuilder(
            builder: (context, constraints){
          return  SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: isLoading
                ? _buildShimmerLoader(size)
                : allPayments.isEmpty
                ? Center(
              child: Padding(
                padding: EdgeInsets.only(top: size.height * 0.3),
                child: Text(
                  "No chits available ",
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
                Text(
                  "Wants to pay a month ₹ ${totalMonthPay.toStringAsFixed(2)}",
                  style: GoogleFonts.urbanist(
                    color: const Color(0xffFFFFFF),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                Column(
                  children: allPayments.map((chit) {
                    final status = chit.pendingAmount > 0
                        ? "Due Pending"
                        : "Due Paid";
                    return Padding(
                      padding:
                      EdgeInsets.only(bottom: size.height * 0.02),
                      child: ChitCardForPayMonth(
                        chit: chit,
                        status: status,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          );},
        ),
      ),
    );
  }

  Widget _buildShimmerLoader(Size size) {
    return Shimmer.fromColors(
      baseColor: const Color(0xff2E2E2E),
      highlightColor: const Color(0xff4A4A4A),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 220,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          SizedBox(height: size.height * 0.02),
          for (int i = 0; i < 3; i++) ...[
            Container(
              width: double.infinity,
              height: size.height * 0.18,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            SizedBox(height: size.height * 0.02),
          ],
        ],
      ),
    );
  }
}

class ChitCardForPayMonth extends StatelessWidget {
  final PendingPayment chit;
  final String status;

  const ChitCardForPayMonth({
    super.key,
    required this.chit,
    required this.status,
  });

  String formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Opacity(
      opacity: status == "Due Paid" ? 0.6 : 1.0, // 🔹 fade paid ones
      child: Container(
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
                Expanded(
                  child: Text(
                    chit.chitName ?? "",
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.urbanist(
                      color: const Color(0xff3A7AFF),
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  status,
                  style: GoogleFonts.urbanist(
                    color: status == "Due Pending"
                        ? const Color(0xffC60F12)
                        : const Color(0xff03DF96),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: size.height * 0.01),
            _buildInfoRow(
              "Due Date : ${formatDate(chit.dueDate)}",
              "Contribution : ₹${chit.pendingAmount.toStringAsFixed(2)}",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String left, String right) {
    return Row(
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
    );
  }
}
