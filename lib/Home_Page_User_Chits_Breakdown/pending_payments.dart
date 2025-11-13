import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Models/User_chit_breakdown/pending_payment_model.dart';
import '../Services/pending_payment_service.dart';
import 'package:shimmer/shimmer.dart';

class PendingPaymentsPage extends StatefulWidget {
  const PendingPaymentsPage({super.key});

  @override
  State<PendingPaymentsPage> createState() => _PendingPaymentsPageState();
}
class _PendingPaymentsPageState extends State<PendingPaymentsPage> {
  List<PendingPayment> pendingPayments = [];
  bool isLoading = true;
  double totalPendingAmount = 0;


  @override
  void initState() {
    super.initState();
    fetchPendingPayments();
  }

  Future<void> fetchPendingPayments() async {
    try {
      final payments = await PendingPaymentService.fetchPendingPayments();

      // ✅ Show only pending payments
      final filtered = payments.where((p) => p.pendingAmount > 0).toList();

      // ✅ Calculate total
      final total = filtered.fold<double>(
        0,
            (sum, p) => sum + p.pendingAmount,
      );

      setState(() {
        pendingPayments = filtered;
        totalPendingAmount = total;
        isLoading = false;
      });
      print("✅ UI received ${filtered.length} pending payments:");
      for (var p in filtered) {
        print("→ ${p.chitName} | Pending: ${p.pendingAmount} | Month: ${p.month}");
      }
    } catch (e) {
      print("⚠️ Error fetching pending payments: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: fetchPendingPayments,
        color: Colors.white,
        backgroundColor: const Color(0xff3A7AFF),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: isLoading
                    ? _buildShimmerLoader(size)
                    : pendingPayments.isEmpty
                    ? Center(
                  child: Text(
                    "No pending payments ",
                    style: GoogleFonts.urbanist(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
                    : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Wants to pay a month ₹ ${totalPendingAmount.toStringAsFixed(2)}",
                      style: GoogleFonts.urbanist(
                        color: const Color(0xffFFFFFF),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: size.height * 0.02),
                    Column(
                      children: pendingPayments.map((chit) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: size.height * 0.02),
                          child: ChitCard_for_pay_pending(chit: chit),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              )
            );
          },
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
          // "Wants to pay a month" shimmer
          Container(
            width: 220,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          SizedBox(height: size.height * 0.02),

          // 3 shimmer cards
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

class ChitCard_for_pay_pending extends StatelessWidget {
  String formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
  }
  final PendingPayment chit;
  const ChitCard_for_pay_pending({super.key,required this.chit});

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  chit.chitName ?? "",
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: GoogleFonts.urbanist(
                    color: const Color(0xff3A7AFF),
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                "Due Pending",
                style: GoogleFonts.urbanist(
                  color: const Color(0xffC60F12),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          SizedBox(height: size.height * 0.01),

          _buildInfoRow(
            "Due Date : ${formatDate(chit.dueDate)}",
            "Mon.Contribution : ₹${chit.pendingAmount.toStringAsFixed(2)}",
          ),
          SizedBox(height: size.height * 0.01),
          Align(
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
