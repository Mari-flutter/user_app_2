import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:user_app/Investments/Gold/Sell%20Gold/confirmation_receipt_for_sell_gold_now.dart';
import 'package:user_app/Investments/Gold/gold_investment_screen.dart';
import '../../../Models/Investments/Gold/sell_gold_model.dart';
import '../../../Services/secure_storage.dart';

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
  bool isLoading = false;
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
    final double estimateamount = double.parse(widget.estimateAmount.toStringAsFixed(0));
    final double servicecharge = 300;
    final double amount = estimateamount - servicecharge;

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
          SnackBar(content: Text("Gold sold successfully! ${amount}")),
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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final double Servicefee = 100;
    final estimateamount = double.parse(widget.estimateAmount.toStringAsFixed(0));
    final double totalsellprice = estimateamount-Servicefee;
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
                      'Confirm your selling',
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
                  height: size.height * 0.45,
                  decoration: BoxDecoration(
                    color: const Color(0xff1F1F1F),
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(
                      color: const Color(0xff61512B),
                      width: 0.5,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.04,
                      vertical: size.height * 0.02,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Please review your selling details before confirming',
                          style: GoogleFonts.urbanist(
                            textStyle: const TextStyle(
                              color: Color(0xffDDDDDD),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(height: size.height * 0.02),

                        // --- Details ---
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.04,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDetailRow("Gold",
                                  "${widget.enteredGrams} g"),
                              _buildDetailRow(
                                  "Estimate Amount", "₹ ${double.parse(widget.estimateAmount.toStringAsFixed(0))}"),
                              _buildDetailRow("Format", "Digital Gold"),
                              _buildDetailRow("Service Fee", "${Servicefee}"),

                              SizedBox(height: size.height * 0.025),
                              const Divider(color: Color(0xff61512B), height: 1),
                              SizedBox(height: size.height * 0.025),

                              _buildDetailRow(
                                "Total Sell Value",
                                "₹ ${totalsellprice}",
                                highlight: true,
                              ),

                              SizedBox(height: size.height * 0.035),

                              // --- Alert ---
                              Container(
                                width: double.infinity,
                                height: 30,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: const Color(0xff515151),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(width: size.width * 0.03),
                                    Image.asset(
                                      'assets/images/Investments/alert_2.png',
                                      width: 16,
                                      height: 16,
                                    ),
                                    SizedBox(width: size.width * 0.03),
                                    Expanded(
                                      child: Text(
                                        'By confirming, you agree to selling ${widget.enteredGrams} g of digital gold.',
                                        style: GoogleFonts.urbanist(
                                          textStyle: const TextStyle(
                                            color: Color(0xff989898),
                                            fontSize: 9,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: size.height * 0.025),

                              // --- Confirm Button ---
                              GestureDetector(
                                onTap: isLoading ? null : sellGold,
                                child: Container(
                                  width: double.infinity,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(11),
                                    color: isLoading
                                        ? const Color(0xffA09068)
                                        : const Color(0xffD4B373),
                                  ),
                                  child: Center(
                                    child: isLoading
                                        ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        color: Color(0xff544B35),
                                        strokeWidth: 3,
                                      ),
                                    )
                                        : Text(
                                      'Confirm to Sell',
                                      style: GoogleFonts.urbanist(
                                        textStyle: const TextStyle(
                                          color: Color(0xff544B35),
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
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildDetailRow(String label, String value,
      {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.urbanist(
              textStyle: TextStyle(
                color: highlight ? const Color(0xffD1AF74) : const Color(0xff989898),
                fontSize: highlight ? 14 : 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.urbanist(
              textStyle: TextStyle(
                color: highlight ? const Color(0xffD1AF74) : const Color(0xff989898),
                fontSize: highlight ? 14 : 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
