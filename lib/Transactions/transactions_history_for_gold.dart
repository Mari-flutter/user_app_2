import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';

import '../Models/Investments/Gold/gold_transaction_model.dart';
import '../Services/secure_storage.dart';

class transactions_history_for_gold extends StatefulWidget {
  const transactions_history_for_gold({super.key});

  @override
  State<transactions_history_for_gold> createState() =>
      _transactions_history_for_goldState();
}

class _transactions_history_for_goldState
    extends State<transactions_history_for_gold> {
  String? profileId;
  List<GoldTransaction> allTransactions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProfileAndTransactions();
  }

  Future<void> loadProfileAndTransactions() async {
    profileId = await SecureStorageService.getProfileId();

    if (profileId == null) {
      print("❌ Profile ID is NULL");
      setState(() => isLoading = false);
      return;
    }

    await loadTransactions();
  }

  Future<void> loadTransactions() async {
    final Token = await SecureStorageService.getToken();
    final buyUrl =
        "https://foxlchits.com/api/PaymentHistory/buy-profile/$profileId";
    final sellUrl =
        "https://foxlchits.com/api/AddYourGold/selling/$profileId";

    List<GoldTransaction> temp = [];

    try {
      final buyRes = await http.get(Uri.parse(buyUrl),headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $Token",
      },);
      final sellRes = await http.get(Uri.parse(sellUrl),headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $Token",
      },);

      if (buyRes.statusCode == 200) {
        List buy = jsonDecode(buyRes.body);
        temp.addAll(buy.map((e) => GoldTransaction.fromBuy(e)));
      }

      if (sellRes.statusCode == 200) {
        List sell = jsonDecode(sellRes.body);
        temp.addAll(sell.map((e) => GoldTransaction.fromSell(e)));
      }

      // Sort by latest
      temp.sort((a, b) => b.dateTime.compareTo(a.dateTime));

      setState(() {
        allTransactions = temp;
        isLoading = false;
      });
    } catch (e) {
      print("❌ Error loading gold history: $e");
      setState(() => isLoading = false);
    }
  }

  List<Map<String, dynamic>> get uiList {
    return allTransactions.map((t) {
      return {
        "title": t.type == "buy" ? "Gold Purchased" : "Gold Sold",
        "date": t.dateTime.toLocal().toString().split(" ")[0],
        "amount":
        t.type == "buy" ? "- ₹${t.amount}" : "+ ₹${t.amount}",
        "type": t.type == "buy" ? "debited" : "credited",
        "gram": "${t.goldGrams} g",
      };
    }).toList();
  }

  // ⭐ SHIMMER WIDGET
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

    final txList = uiList;

    return txList.isEmpty
        ? const Center(
      child: Text(
        "No gold transactions found",
        style: TextStyle(color: Colors.white),
      ),
    )
        : ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: txList.length,
      itemBuilder: (context, index) {
        final tx = txList[index];
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
                    tx["type"] == "debited"
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
                        tx["title"],
                        style: GoogleFonts.urbanist(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        tx["date"],
                        style: GoogleFonts.urbanist(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        tx["amount"],
                        style: GoogleFonts.urbanist(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        tx["gram"],
                        style: GoogleFonts.urbanist(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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
