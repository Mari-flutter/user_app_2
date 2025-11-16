import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../Models/chit_transaction_model.dart';
import '../Services/secure_storage.dart';
import 'package:shimmer/shimmer.dart';

class transactions_history_for_chits extends StatefulWidget {
  const transactions_history_for_chits({super.key});

  @override
  State<transactions_history_for_chits> createState() =>
      _transactions_history_for_chitsState();
}

class _transactions_history_for_chitsState
    extends State<transactions_history_for_chits> {
  List<ChitTransactionModel> transactions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    final profileId = await SecureStorageService.getProfileId();
    final Token = await SecureStorageService.getToken();
    final url = Uri.parse(
        "https://foxlchits.com/api/PaymentHistory/by-profile-chits/$profileId");

    final response = await http.get(url,headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $Token",
    },);

    if (response.statusCode == 200) {
      final List list = jsonDecode(response.body);

      setState(() {
        transactions =
            list.map((e) => ChitTransactionModel.fromJson(e)).toList();
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    if (isLoading) {
      return shimmerList(size);   // 🔥 NEW shimmer effect
    }


    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final tx = transactions[index];

        // logic
        final isDebited = tx.status == true;
        final iconPath = isDebited
            ? "assets/images/Transactions/debited.png"
            : "assets/images/Transactions/credited.png";

        final amountText =
            "${isDebited ? "-" : "+"} ₹${tx.amount}";

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
                  Image.asset(iconPath, width: 20, height: 20),
                  SizedBox(width: size.width * 0.04),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx.chitName,
                        style: GoogleFonts.urbanist(
                          color: const Color(0xffFFFFFF),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        tx.date,
                        style: GoogleFonts.urbanist(
                          color: const Color(0xffAAAAAA),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  Text(
                    amountText,
                    style: GoogleFonts.urbanist(
                      color: const Color(0xffFFFFFF),
                      fontSize: 14,
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
  Widget shimmerList(Size size) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (_, __) {
        return Column(
          children: [
            Shimmer.fromColors(
              baseColor: Colors.grey.shade800,
              highlightColor: Colors.grey.shade600,
              child: Container(
                width: double.infinity,
                height: 58,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Color(0xff2C2C2C),
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

}

