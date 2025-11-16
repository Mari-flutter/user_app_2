import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import '../Models/withdraw_model.dart';
import '../Services/secure_storage.dart';

class transactions_history_for_all_withdraw extends StatefulWidget {
  const transactions_history_for_all_withdraw({super.key});

  @override
  State<transactions_history_for_all_withdraw> createState() =>
      _transactions_history_for_all_withdrawState();
}

class _transactions_history_for_all_withdrawState
    extends State<transactions_history_for_all_withdraw> {

  List<WithdrawHistoryItem> history = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadAllWithdrawHistory();
  }

  Future<void> loadAllWithdrawHistory() async {
    final profileId = await SecureStorageService.getProfileId();
    final Token = await SecureStorageService.getToken();
    final razorUrl =
    Uri.parse("https://foxlchits.com/api/RazorPayWithdraw/$profileId");

    final historyUrl = Uri.parse(
        "https://foxlchits.com/api/WithdrawAmount/withdraw-history/$profileId");

    final responses = await Future.wait([
      http.get(razorUrl,headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $Token",
      },),
      http.get(historyUrl,headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $Token",
      },),
    ]);

    List<WithdrawHistoryItem> tempList = [];

    // RazorPay withdrawals
    if (responses[0].statusCode == 200) {
      final List data = jsonDecode(responses[0].body);
      for (var item in data) {
        tempList.add(
          WithdrawHistoryItem(
            title: item["narration"] ?? "Instant Withdrawal",
            amount: item["amount"]?.toDouble() ?? 0,
            date: DateTime.parse(item["createdAt"]),
          ),
        );
      }
    }

    // Withdraw History
    if (responses[1].statusCode == 200) {
      final decoded = jsonDecode(responses[1].body);
      final List list = decoded["withdrawHistory"];

      for (var item in list) {
        tempList.add(
          WithdrawHistoryItem(
            title: "Bank Withdrawal",
            amount: item["amount"]?.toDouble() ?? 0,
            date: DateTime.parse(item["createdAt"]),
          ),
        );
      }
    }

    // Sort by recent
    tempList.sort((a, b) => b.date.compareTo(a.date));

    setState(() {
      history = tempList;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    if (isLoading) return shimmerList(size);

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final item = history[index];

        return Column(
          children: [
            Container(
              width: double.infinity,
              height: 65,
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.04,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(11),
                color: Color(0xff2C2C2C),
              ),
              child: Row(
                children: [
                  Image.asset(
                    "assets/images/Transactions/credited.png",
                    width: 22,
                    height: 22,
                  ),
                  SizedBox(width: 14),

                  // Title + Date
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.title,
                        style: GoogleFonts.urbanist(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        "${item.date.day}-${item.date.month}-${item.date.year}",
                        style: GoogleFonts.urbanist(
                          color: Color(0xffAAAAAA),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  Spacer(),

                  Text(
                    "+ ₹${item.amount.toStringAsFixed(1)}",
                    style: GoogleFonts.urbanist(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
          ],
        );
      },
    );
  }

  Widget shimmerList(Size size) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (_, __) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade800,
            highlightColor: Colors.grey.shade600,
            child: Container(
              height: 65,
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(11),
              ),
            ),
          ),
        );
      },
    );
  }
}
