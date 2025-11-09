import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:user_app/Investments/Gold/confirmation_receipt_for_sell_gold_now.dart';
import 'package:user_app/Investments/Gold/gold_investment_screen.dart';

import '../../Models/Investments/Gold/CurrentGoldValue_Model.dart';
import '../../Models/Investments/Gold/sell_gold_model.dart';
import '../../Models/Investments/Gold/user_hold_gold_model.dart';
import '../../Services/Gold_holdings.dart';
import '../../Services/Gold_price.dart';
import '../../Services/secure_storage.dart';

class sell_gold_now extends StatefulWidget {
  final double enteredGrams;
  final double estimateAmount;
  final VoidCallback? onBackToGold;

  const sell_gold_now({
    super.key,
    required this.enteredGrams,
    required this.estimateAmount,
    this.onBackToGold,
  });

  @override
  State<sell_gold_now> createState() => _sell_gold_nowState();
}

class _sell_gold_nowState extends State<sell_gold_now> {
  CurrentGoldValue? _goldValue;
  GoldHoldings? goldHoldings;
  bool _loading = true;
  @override
  void initState() {
    super.initState();
    _loadGoldValue();
    _loadGoldHoldings();
  }
  Future<void> _loadGoldHoldings() async {
    // Step 1️⃣ — Load cached data immediately
    final cached = await GoldHoldingsService.getCachedGoldHoldings();
    if (cached != null) {
      setState(() {
        goldHoldings = cached;
      });
    }

    // Step 2️⃣ — Background fetch new data silently
    final latest = await GoldHoldingsService.fetchAndCacheGoldHoldings();
    if (latest != null) {
      // If new data differs, update UI automatically
      if (latest.userGold != goldHoldings?.userGold ||
          latest.userInvestment != goldHoldings?.userInvestment) {
        setState(() {
          goldHoldings = latest;
        });
      }
    }
  }

  Future<void> sellGold() async {
    final String apiUrl = "https://foxlchits.com/api/AddYourGold/sell";

    // 🧠 Retrieve userId securely
    final userId = await SecureStorageService.getProfileId();

    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    final double amount = double.parse(widget.estimateAmount.toStringAsFixed(0));

    final sellGoldData = SellGoldModel(
      userId: userId,
      amount: amount,
      type: "Sell",
    );

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(sellGoldData.toJson()),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print("✅ Sell Success: $jsonResponse");

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gold sold successfully!")),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => confirmation_receipt_for_sell_gold_now(),
          ),
        );
      } else {
        print("❌ Sell Failed: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to sell gold. Try again.")),
        );
      }
    } catch (e) {
      print("⚠️ Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> _loadGoldValue() async {
    // 1️⃣ Load cached value first
    final cachedValue = await GoldService.getCachedGoldValue();
    if (cachedValue != null) {
      print('💾 Showing cached gold value: ₹${cachedValue.goldValue}');
      setState(() {
        _goldValue = cachedValue;
        _loading = false;
      });
    } else {
      print('⚠️ No cached value, showing loader...');
      setState(() {
        _loading = true;
      });
    }

    // 2️⃣ Fetch updated gold value in background
    try {
      print('🔹 Fetching latest gold price...');
      final latestValue = await GoldService.fetchAndCacheGoldValue();
      if (!mounted) return;
      if (latestValue != null) {
        setState(() {
          _goldValue = latestValue;
          _loading = false;
        });
        print('🌐 Updated to latest gold value: ₹${latestValue.goldValue}');
      }
    } catch (e) {
      print('❌ Error fetching gold value: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    TextEditingController _controller = TextEditingController();
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Color(0xff000000),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: size.height * 0.02),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                gold_investment(initialTab: 1),
                          ),
                        );
                      },
                      child: Image.asset(
                        'assets/images/My_Chits/back_arrow.png',
                        width: 24,
                        height: 24,
                      ),
                    ),
                    SizedBox(width: size.width * 0.03),
                    Text(
                      'Sell Gold',
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
                SizedBox(height: size.height * 0.02),
                Container(
                  width: double.infinity,
                  height: 95,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(11),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Color(0xff70481C), Color(0xffF5D695)],
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.05,
                      vertical: size.height * 0.01,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Current Gold Price ',
                                  style: GoogleFonts.urbanist(
                                    textStyle: const TextStyle(
                                      color: Color(0xffCCAF78),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                _loading
                                    ? const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                )
                                    :
                                Text(
                                  '₹${_goldValue?.goldValue.toStringAsFixed(2) ?? '--'}/g',
                                  style: GoogleFonts.urbanist(
                                    textStyle: const TextStyle(
                                      color: Color(0xffFFFFFF),
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  _goldValue != null
                                      ? 'Updated on ${_goldValue!.date.toLocal().toString().split(" ").first}'
                                      : '',
                                  style: GoogleFonts.urbanist(
                                    textStyle: const TextStyle(
                                      color: Color(0xffFFFFFF),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Your Holdings',
                                  style: GoogleFonts.urbanist(
                                    textStyle: const TextStyle(
                                      color: Color(0xffF9F5EC),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${goldHoldings?.userGold.toStringAsFixed(2) ?? '--'} g',
                                  style: GoogleFonts.urbanist(
                                    textStyle: const TextStyle(
                                      color: Color(0xffFFFFFF),
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  '₹${goldHoldings?.userInvestment.toStringAsFixed(0) ?? '--'}',
                                  style: GoogleFonts.urbanist(
                                    textStyle: const TextStyle(
                                      color: Color(0xffFFFFFF),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.03),
                Container(
                  width: double.infinity,
                  height: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(11),
                    color: Color(0xff3E3E3E),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.05,
                      vertical: size.height * 0.025,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: size.width * 0.02),
                        Text(
                          'Select Gold Amount',
                          style: GoogleFonts.urbanist(
                            textStyle: const TextStyle(
                              color: Color(0xffFFFFFF),
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(height: size.height * 0.045),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Entered grams (₹)',
                                  style: GoogleFonts.urbanist(
                                    textStyle: const TextStyle(
                                      color: Color(0xffDBDBDB),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                SizedBox(height: size.height * 0.01),
                                Container(
                                  width: size.width * 0.41,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: Color(0xff525252),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(width: size.width * 0.02),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          widget.enteredGrams.toStringAsFixed(2),
                                          style: GoogleFonts.urbanist(
                                            textStyle: const TextStyle(
                                              color: Color(0xffDBDBDB),
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Estimate',
                                  style: GoogleFonts.urbanist(
                                    textStyle: const TextStyle(
                                      color: Color(0xffDBDBDB),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                SizedBox(height: size.height * 0.01),
                                Container(
                                  width: size.width * 0.41,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: Color(0xff525252),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(width: size.width * 0.02),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          '₹${widget.estimateAmount.toStringAsFixed(0)}',
                                          style: GoogleFonts.urbanist(
                                            textStyle: const TextStyle(
                                              color: Color(0xffDBDBDB),
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: size.height * 0.05),
                        GestureDetector(
                          onTap: () {
                            sellGold();
                          },
                          child: Container(
                            width: double.infinity,
                            height: 42,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(11),
                              color: Color(0xffD4B373),
                            ),
                            child: Center(
                              child: Text(
                                'Confirm to Sell',
                                style: GoogleFonts.urbanist(
                                  textStyle: const TextStyle(
                                    color: Color(0xff141414),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.04),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
