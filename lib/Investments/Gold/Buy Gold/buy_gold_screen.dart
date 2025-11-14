import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user_app/Investments/Gold/Buy%20Gold/confirm_your_gold_buy.dart';
import 'package:user_app/widgets/noise_background_container.dart';

class buy_gold extends StatefulWidget {
  final double goldrate;
  const buy_gold({super.key, required this.goldrate});

  @override
  State<buy_gold> createState() => _buy_goldState();
}

class _buy_goldState extends State<buy_gold> {
  final TextEditingController _controller = TextEditingController();
  double _calculatedGrams = 0.0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _calculateGrams(String value) {
    if (value.isEmpty) {
      setState(() => _calculatedGrams = 0);
      return;
    }
    double enteredAmount = double.tryParse(value) ?? 0;
    setState(() {
      _calculatedGrams = enteredAmount / widget.goldrate;
    });
  }

  /// 🟨 Simple custom-styled default snackbar
  void _showSmoothSnackBar(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(
          child: Text(
            message,
            style: GoogleFonts.urbanist(
              color: const Color(0xff141414),
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ),
        backgroundColor: const Color(0xffD4B373),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
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
              border: Border.all(color: const Color(0xff61512B), width: 2),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.05,
                vertical: size.height * 0.025,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Header
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
                          color: const Color(0xffFFFFFF),
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.03),

                  // --- Amount + grams
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Amount
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Enter Amount (₹)',
                            style: GoogleFonts.urbanist(
                              color: const Color(0xffDBDBDB),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: size.height * 0.01),
                          SizedBox(
                            width: size.width * 0.55,
                            height: 38,
                            child: TextField(
                              controller: _controller,
                              style: const TextStyle(
                                color: Color(0xffFFFFFF),
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                              cursorColor: const Color(0xffFFFFFF),
                              keyboardType: TextInputType.number,
                              onChanged: _calculateGrams,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(0xff575757),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Color(0xff575757),
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Color(0xff575757),
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Approx Grams
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Approx(g)',
                            style: GoogleFonts.urbanist(
                              color: const Color(0xffDBDBDB),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: size.height * 0.01),
                          Container(
                            width: size.width * 0.27,
                            height: 38,
                            decoration: BoxDecoration(
                              color: const Color(0xff575757),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Center(
                              child: Text(
                                '≈ ${_calculatedGrams.toStringAsFixed(3)} g',
                                style: GoogleFonts.urbanist(
                                  color: const Color(0xffDBDBDB),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: size.height * 0.04),

                  // Quick tags
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(buy_gold_amount_tag.length, (index) {
                        return Padding(
                          padding: EdgeInsets.only(
                            right: index == buy_gold_amount_tag.length - 1
                                ? 0
                                : size.width * 0.035,
                          ),
                          child: GestureDetector(
                            onTap: () {
                              _controller.text = buy_gold_amount_tag[index];
                              _calculateGrams(buy_gold_amount_tag[index]);
                            },
                            child: Container(
                              width: 71,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xff575757),
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: Center(
                                child: Text(
                                  buy_gold_amount_tag[index],
                                  style: GoogleFonts.urbanist(
                                    color: const Color(0xffFFFFFF),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
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

                  // Buy Button
                  GestureDetector(
                    onTap: () {
                      double enteredAmount = double.tryParse(_controller.text) ?? 0;

                      if (enteredAmount < 1000) {
                        _showSmoothSnackBar("You can buy gold only for ₹1000 and abouve");
                        return;
                      }

                      if (_calculatedGrams <= 0) {
                        _showSmoothSnackBar("Enter a valid amount to calculate grams");
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => confirm_your_buying(
                            selectedGrams: _calculatedGrams,
                            EstimatedValue: enteredAmount,
                            CurrentPrice : widget.goldrate,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      height: 42,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(11),
                        color: const Color(0xffD4B373),
                      ),
                      child: Center(
                        child: Row(
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
                                color: const Color(0xff141414),
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
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
