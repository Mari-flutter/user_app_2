import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:user_app/Investments/Gold/Buy%20Gold/confirmation_receipt_for_buy_gold.dart';
import '../../../Models/Investments/Gold/buy_gold_model.dart';
import '../../../Services/secure_storage.dart';

class confirm_your_buying extends StatefulWidget {
  final double selectedGrams;
  final double EstimatedValue;
  final double CurrentPrice;

  const confirm_your_buying({
    super.key,
    required this.selectedGrams,
    required this.EstimatedValue,
    required this.CurrentPrice,
  });

  @override
  State<confirm_your_buying> createState() => _confirm_your_buyingState();
}

class _confirm_your_buyingState extends State<confirm_your_buying> {
  bool isLoading = false;

  // --- API Call Method ---
  Future<void> _buyGold() async {
    final userId = await SecureStorageService.getProfileId();
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("User not found. Please login again."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // --- Input Values ---
    final double enteredAmount = widget.EstimatedValue;
    final double goldRate = widget.CurrentPrice;
    const double gstPercent = 3;
    const double serviceCharge = 200;

    // --- Calculations ---
    final double gstAmount = enteredAmount * (gstPercent / 100);
    final double netAmount = enteredAmount - gstAmount - serviceCharge;
    final double gramsToBuy = netAmount / goldRate;

    // Final gold value (₹)
    final double totalGoldValue = gramsToBuy * goldRate;

    print("💰 Entered Amount: ₹$enteredAmount");
    print("🧾 GST (3%): ₹$gstAmount");
    print("⚙️ Service Charge: ₹$serviceCharge");
    print("➡️ Net Amount: ₹$netAmount");
    print("🥇 Gold Rate: ₹$goldRate per gram");
    print("🏷️ Calculated Grams: ${gramsToBuy.toStringAsFixed(3)} g");
    print("💎 Final Gold Value: ₹${totalGoldValue.toStringAsFixed(2)}");

    // --- Create Request ---
    final request = BuyGoldRequest(
      userId: userId,
      amount: totalGoldValue,
      type: "Buy",
    );

    setState(() => isLoading = true);

    try {
      final url = Uri.parse("https://foxlchits.com/api/AddYourGold/buy");
      final token = await SecureStorageService.getToken();

      final headers = {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      };

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(request.toJson()),
      );

      print("📩 Buy Gold Response: ${response.statusCode} | ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "🎉 Successfully bought ${gramsToBuy.toStringAsFixed(3)}g of gold!",
              textAlign: TextAlign.center,
              style: GoogleFonts.urbanist(
                fontWeight: FontWeight.w700,
                color: const Color(0xff141414),
              ),
            ),
            backgroundColor: const Color(0xffD4B373),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => confirmation_receipt_for_buy_gold_now(
              goldAmount: widget.EstimatedValue,
              estimate: widget.selectedGrams,
              format: "Digital Gold",
              gstPercent: gstPercent,
              serviceCharge: serviceCharge,
              totalGoldValue: gramsToBuy,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Failed to buy gold (Code: ${response.statusCode})",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      print("❌ Error buying gold: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final double enteredAmount = widget.EstimatedValue;
    final double goldRate = widget.CurrentPrice;
    const double gstPercent = 3;
    const double serviceCharge = 200;

// --- Calculate final gold value after GST & service fee ---
    final double gstAmount = enteredAmount * (gstPercent / 100);
    final double netAmount = enteredAmount - gstAmount - serviceCharge;
    final double finalGrams = netAmount / goldRate;


    return Scaffold(
      backgroundColor: const Color(0xff000000),
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
                        Navigator.pop(context);
                      },
                      child: Image.asset(
                        'assets/images/My_Chits/back_arrow.png',
                        width: 24,
                        height: 24,
                      ),
                    ),
                    SizedBox(width: size.width * 0.03),
                    Text(
                      'Confirm your buying',
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

                // --- Booking Details ---
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
                          'Please review your buying details before confirming',
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
                              _buildDetailRow("Gold Amount",
                                  "₹${widget.EstimatedValue.toStringAsFixed(0)}"),
                              _buildDetailRow(
                                  "Estimate", "${widget.selectedGrams.toStringAsFixed(2)}g"),
                              _buildDetailRow("Format", "Digital Gold"),
                              _buildDetailRow("GST", "$gstPercent%"),
                              _buildDetailRow("Service Fee", "₹$serviceCharge"),

                              SizedBox(height: size.height * 0.025),
                              const Divider(color: Color(0xff61512B), height: 1),
                              SizedBox(height: size.height * 0.025),

                              _buildDetailRow(
                                "Total Gold Value",
                                "${finalGrams.toStringAsFixed(3)} g",
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
                                        'By confirming, you agree to buying ${finalGrams.toStringAsFixed(3)}g of digital gold.',
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
                                onTap: isLoading ? null : _buyGold,
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
                                      'Confirm to Buy',
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

  /// Helper for displaying key-value rows
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
