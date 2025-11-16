import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';

import '../Models/Investments/Gold/gold_scheme_transaction_model.dart';

class transactions_history_for_gold_scheme extends StatelessWidget {
  const transactions_history_for_gold_scheme({super.key});

  Future<List<GoldSchemeTransaction>> fetchGoldSchemePayments() async {
    final url = Uri.parse(
        "https://foxlchits.com/api/PaymentHistory/by-profile-Goldscheme/f864ab0d-dfd0-4c28-901e-df65cbfe9a1b");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => GoldSchemeTransaction.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load scheme payments");
    }
  }

  // 🔥 SHIMMER WIDGET
  Widget buildShimmer(BuildContext context) {
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

    return FutureBuilder(
      future: fetchGoldSchemePayments(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return buildShimmer(context);   // ← show shimmer here
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              "No transactions found",
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        final transactions = snapshot.data!;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
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
                    color: const Color(0xff2C2C2C),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        !tx.status
                            ? "assets/images/Transactions/credited.png"
                            : "assets/images/Transactions/debited.png",
                        width: 20,
                        height: 20,
                      ),
                      SizedBox(width: size.width * 0.04),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tx.schemeName,
                            style: GoogleFonts.urbanist(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "${tx.dateTime.day}-${tx.dateTime.month}-${tx.dateTime.year}",
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
                          !tx.status?
                        "- ₹${tx.amount.toStringAsFixed(2)}": "- ₹${tx.amount.toStringAsFixed(2)}",
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
      },
    );
  }
}


/// MODEL CLASS

