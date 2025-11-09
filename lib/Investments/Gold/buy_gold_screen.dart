import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:user_app/widgets/noise_background_container.dart';

import '../../Models/Investments/Gold/buy_gold_model.dart';
import '../../Services/secure_storage.dart';

class buy_gold extends StatefulWidget {
  const buy_gold({super.key});

  @override
  State<buy_gold> createState() => _buy_goldState();
}

class _buy_goldState extends State<buy_gold> {
  final TextEditingController _controller = TextEditingController();
  double approxGrams = 0.0;
  final double goldRate = 10000; // ₹10,000 per gram
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      double value = double.tryParse(_controller.text) ?? 0;
      setState(() {
        approxGrams = value / goldRate;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 🪙 Service function to buy gold
  Future<void> _buyGold() async {
    final amount = double.tryParse(_controller.text) ?? 0;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid amount")),
      );
      return;
    }

    final userId = await SecureStorageService.getProfileId();
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not found. Please login again.")),
      );
      return;
    }

    // 🧩 Create request model
    final request = BuyGoldRequest(
      userId: userId,
      amount: amount,
      type: "Buy", // change if your backend expects different type
    );

    setState(() => isLoading = true);

    try {
      final url = Uri.parse("https://foxlchits.com/api/AddYourGold/buy");
      final token = await SecureStorageService.getToken();

      final headers = {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      };

      print("📤 Sending request: ${request.toJson()}");

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(request.toJson()),
      );

      print("📩 Buy Gold Response: ${response.statusCode} | ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gold purchased successfully!")),
        );
        _controller.clear();
        setState(() => approxGrams = 0.0);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed: ${response.statusCode}")),
        );
      }
    } catch (e) {
      print("❌ Error buying gold: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> buy_gold_amount_tag = ['1000', '3000', '5000', '10000'];
    final size = MediaQuery.of(context).size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NoiseBackgroundContainer(
          height: 350,
          dotSize: 0.5,
          density: 1,
          opacity: 0.15,
          color: Colors.white,
          child: Container(
            width: double.infinity,
            height: 350,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: Color(0xff61512B), width: 2),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.05,
                vertical: size.height * 0.025,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/Investments/buy_digital_gold.png',
                        width: 24,
                        height: 24,
                      ),
                      SizedBox(width: size.width * 0.02),
                      Text(
                        'Buy Gold',
                        style: GoogleFonts.urbanist(
                          textStyle: const TextStyle(
                            color: Color(0xffFFFFFF),
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.03),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Enter Amount (₹)',
                            style: GoogleFonts.urbanist(
                              textStyle: const TextStyle(
                                color: Color(0xffDBDBDB),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(height: size.height * 0.01),
                          SizedBox(
                            width: size.width * 0.55,
                            height: 38,
                            child: TextField(
                              style: TextStyle(
                                color: Color(0xffFFFFFF),
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                              cursorColor: Color(0xffFFFFFF),
                              controller: _controller,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Color(0xff575757),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xff575757),
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xff575757),
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Approx(g)',
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
                            width: size.width * 0.27,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Color(0xff575757),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Center(
                              child: Text(
                                '≈ ${approxGrams.toStringAsFixed(3)} grams',
                                style: GoogleFonts.urbanist(
                                  textStyle: const TextStyle(
                                    color: Color(0xffDBDBDB),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.04),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(buy_gold_amount_tag.length, (
                        index,
                      ) {
                        return Padding(
                          padding: EdgeInsets.only(
                            right: index == buy_gold_amount_tag.length - 1
                                ? 0
                                : size.width * 0.035,
                          ),
                          child: GestureDetector(
                            onTap: () {
                              _controller.text = buy_gold_amount_tag[index];
                            },
                            child: Container(
                              width: 71,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Color(0xff575757),
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: Center(
                                child: Text(
                                  buy_gold_amount_tag[index],
                                  style: GoogleFonts.urbanist(
                                    textStyle: const TextStyle(
                                      color: Color(0xffFFFFFF),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  SizedBox(height: size.height * 0.05),
                  GestureDetector(
                    onTap: isLoading ? null : _buyGold,
                    child: Container(
                      width: double.infinity,
                      height: 42,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(11),
                        color: const Color(0xffD4B373),
                      ),
                      child: Center(
                        child: isLoading
                            ? const CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2,
                        )
                            : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/Investments/buy_gold_now.png',
                              width: 22,
                              height: 22,
                            ),
                            SizedBox(width: size.width * 0.02),
                            Text(
                              'Buy Now',
                              style: GoogleFonts.urbanist(
                                textStyle: const TextStyle(
                                  color: Color(0xff141414),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

