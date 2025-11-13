import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user_app/Bottom_Navbar/bottom_navigation_bar.dart';
// Note: We are using a simplified/placeholder model for this file since core chit details are missing in the current constructor
import '../../Models/My_Chits/explore_chit_model.dart';

class chit_monthly_pay_due extends StatefulWidget {
  final List<ExploreChit> paymentHistory;

  const chit_monthly_pay_due({
    super.key,
    required this.paymentHistory,
  });

  @override
  State<chit_monthly_pay_due> createState() => _chit_monthly_pay_dueState();
}

class _chit_monthly_pay_dueState extends State<chit_monthly_pay_due> {

  // Helper to format DateTime to DD-MM-YYYY
  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    // Format to YYYY-MM-DD
    final dateString = date.toLocal().toString().split(' ')[0];

    // Convert YYYY-MM-DD to DD-MM-YYYY for display
    try {
      final parts = dateString.split('-');
      return '${parts[2]}-${parts[1]}-${parts[0]}';
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Determine the installment number of the next payment due
    // The first item where paid is false is the next one due.
    final nextDueIndex = widget.paymentHistory.indexWhere((chit) => chit.paid == false);
    final List<ExploreChit> duePayments =
    widget.paymentHistory.where((chit) => chit.paid == false).toList();

    return Scaffold(
      backgroundColor: const Color(0xff000000),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height * 0.02),
              // --- Header ---
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context); // Navigate back to explore_chit
                    },
                    child: Image.asset(
                      'assets/images/My_Chits/back_arrow.png',
                      width: 24,
                      height: 24,
                    ),
                  ),
                  SizedBox(width: size.width * 0.03),
                  Text(
                    'Installment Details',
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

              // --- List of Installment Cards ---
              Expanded(
                child:duePayments.isEmpty
                    ? Center(
                  child: Text(
                    'No pending installments.',
                    style: GoogleFonts.urbanist(
                      color: const Color(0xffDDDDDD),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
                    : ListView.builder(
                  itemCount: duePayments.length,
                  itemBuilder: (context, index) {
                    final installment = widget.paymentHistory[index];
                    final isNextDue = index == nextDueIndex;
                    return _buildInstallmentCard(
                        size,
                        installment,
                        isNextDue
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔑 Installment Card Widget (Replaced the previous hardcoded card structure)
  Widget _buildInstallmentCard(
      Size size,
      ExploreChit installment,
      bool isNextDue,
      ) {
    final statusColor = installment.paid ? const Color(0xff07C66A) : const Color(0xffC60F12);
    final dueDateDisplay = installment.dueDate is DateTime
        ? _formatDate(installment.dueDate as DateTime?)
        : installment.dueDate.toString();

    return Padding(
      padding: EdgeInsets.only(bottom: size.height * 0.02),
      child: Container(
        width: double.infinity,
        height: size.height * 0.1,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            // Use a slight highlight for the next due card
            colors:  [const Color(0xff232323), const Color(0xff383836)],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.04,
            vertical: size.height * 0.01,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Due ${installment.action}',
                style: GoogleFonts.urbanist(
                  textStyle: TextStyle(
                    color: const Color(0xffFFFFFF) ,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Due Amount: ${installment.howMuchToPay.toStringAsFixed(0)}',
                        style: GoogleFonts.urbanist(
                          textStyle: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      _buildInfoRow(
                        "Due Date",
                        dueDateDisplay,
                        isWhite: true,
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                        },
                        child: Container(
                          width: 100,
                          height: 24,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7),
                            color: const Color(0xff3A7AFF),
                          ),
                          child: Center(
                            child: Text(
                              'Pay Due',
                              style: GoogleFonts.urbanist(
                                textStyle: const TextStyle(
                                  color: Color(0xffFFFFFF),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height:10,)
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper for displaying info rows
  Widget _buildInfoRow(String left, String right, {bool isWhite = false}) {
    final color = isWhite ? const Color(0xffF8F8F8) : const Color(0xffF8F8F8);
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            left + ': ',
            style: GoogleFonts.urbanist(
              textStyle: TextStyle(
                color: Color(0xffF8F8F8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            right,
            style: GoogleFonts.urbanist(
              textStyle: TextStyle(
                color: Color(0xffF8F8F8),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}