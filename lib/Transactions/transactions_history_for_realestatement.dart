import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';

import '../Models/Investments/Realestate/real_estate_transaction_model.dart';

class transactions_history_for_real_estatement extends StatefulWidget {
  const transactions_history_for_real_estatement({super.key});

  @override
  State<transactions_history_for_real_estatement> createState() =>
      _transactions_history_for_real_estatementState();
}

class _transactions_history_for_real_estatementState
    extends State<transactions_history_for_real_estatement> {
  List<RealEstateTxModel> transactions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    final url = Uri.parse(
      "https://foxlchits.com/api/PaymentHistory/by-profile-REInvestment/f864ab0d-dfd0-4c28-901e-df65cbfe9a1b",
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        setState(() {
          transactions =
              data.map((json) => RealEstateTxModel.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error fetching transactions: $e");
      setState(() => isLoading = false);
    }
  }

  // ⭐ SHIMMER LOADER
  Widget shimmerLoader(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Column(
          children: [
            Shimmer.fromColors(
              baseColor: Colors.grey.shade800,
              highlightColor: Colors.grey.shade600,
              child: Container(
                width: double.infinity,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
            ),
            SizedBox(height: size.height * 0.015),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    if (isLoading) return shimmerLoader(context);

    if (transactions.isEmpty) {
      return Center(
        child: Text(
          "No Transactions Found",
          style: GoogleFonts.urbanist(color: Colors.white, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final tx = transactions[index];

        String title = "Real Estate Investment";
        String date = tx.dateTime.split("T")[0];
        String amount = "₹${tx.amount.toStringAsFixed(2)}";

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
                color: const Color(0xff2C2C2C),
              ),
              child: Row(
                children: [
                  Image.asset(
                    tx.status
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
                        title,
                        style: GoogleFonts.urbanist(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        date,
                        style: GoogleFonts.urbanist(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    tx.status ? "- $amount" : "+ $amount",
                    style: GoogleFonts.urbanist(
                      color: Colors.white,
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
