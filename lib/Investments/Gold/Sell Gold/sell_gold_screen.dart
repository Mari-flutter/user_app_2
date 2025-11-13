import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user_app/Investments/Gold/Sell%20Gold/sell_gold_now_screen.dart';
import 'package:user_app/widgets/noise_background_container.dart';

import '../../../Models/Investments/Gold/CurrentGoldValue_Model.dart';
import '../../../Services/Gold_price.dart';
import '../gold_investment_screen.dart';
import '../Get Physical Gold/get_physical_gold_screen.dart';


class sell_gold extends StatefulWidget {
  const sell_gold({super.key});

  @override
  State<sell_gold> createState() => _sell_goldState();
}

class _sell_goldState extends State<sell_gold> {
  final TextEditingController _controller = TextEditingController();
  double approxAmount = 0.0;
  CurrentGoldValue? _goldValue;

  @override
  void initState() {
    super.initState();
    _loadGoldValue();
    _controller.addListener(_calculateApproxAmount);
  }

  Future<void> _loadGoldValue() async {
    final gold = await GoldService.fetchAndCacheGoldValue();
    setState(() {
      _goldValue = gold;
    });
  }

  void _calculateApproxAmount() {
    double grams = double.tryParse(_controller.text) ?? 0;
    if (_goldValue != null) {
      final double goldRate = _goldValue!.goldValue;
      setState(() {
        approxAmount = grams * goldRate;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NoiseBackgroundContainer(
          height: 270,
          // same height as before
          dotSize: 0.5,
          // set 1.0 for visible dots; reduce if too strong
          density: 1,
          // tweak: smaller = more dots; larger = fewer dots
          opacity: 0.15,
          // 15% opacity
          color: Colors.white,
          child: Container(
            width: double.infinity,
            height: 270,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(11)),
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
                        'assets/images/Investments/sell_digital_gold.png',
                        width: 24,
                        height: 24,
                      ),
                      SizedBox(width: size.width * 0.02),
                      Text(
                        'Sell Digital Gold',
                        style: GoogleFonts.urbanist(
                          textStyle: const TextStyle(
                            color: Color(0xffFFFFFF),
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.02),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Enter Gram (g)',
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
                            width: size.width * 0.41,
                            height: 39,
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
                                // 👈 must enable to show background color
                                fillColor: Color(0xff2A2A2A),

                                // 👈 background color
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xff2A2A2A),
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                // 👇 Focused border (when you tap on it)
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xff2A2A2A),
                                  ),
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xff2A2A2A),
                                  ),
                                  borderRadius: BorderRadius.circular(7),
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
                            'Approx(₹)',
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
                            height: 38.5,
                            decoration: BoxDecoration(
                              color: Color(0xff907643),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Row(
                              children: [
                                SizedBox(width: size.width * 0.02),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    '₹ ${approxAmount.toStringAsFixed(0)}',
                                    style: GoogleFonts.urbanist(
                                      textStyle: const TextStyle(
                                        color: Color(0xffFFFFFF),
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
                  SizedBox(height: size.height * 0.02),
                  Text(
                    'You got ₹${approxAmount.toStringAsFixed(0)}',
                    style: GoogleFonts.urbanist(
                      textStyle: const TextStyle(
                        color: Color(0xffDBDBDB),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.03),
                  GestureDetector(
                    onTap: () {
                      double? enteredGrams = double.tryParse(_controller.text);

                      if (enteredGrams == null || enteredGrams <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Please enter a valid gold amount to sell.',
                              style: GoogleFonts.urbanist(
                                textStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            backgroundColor: Colors.redAccent,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                        return;
                      }

                      if (_goldValue == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              "Gold price not loaded yet. Try again.",
                            ),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        return;
                      }
                      // ✅ Navigate to confirm_sell_gold screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => sell_gold_now(
                            enteredGrams: enteredGrams,
                            estimateAmount: approxAmount,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      height: 42,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(11),
                        color: Color(0xffD4B373),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.28,
                          vertical: size.height * 0.01,
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/images/Investments/buy_gold_now.png',
                              width: 22,
                              height: 22,
                            ),
                            SizedBox(width: size.width * 0.01),
                            Text(
                              'Sell Now',
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
        SizedBox(height: size.height * 0.04),
        NoiseBackgroundContainer(
          height: 208,
          // same height as before
          dotSize: 0.5,
          // set 1.0 for visible dots; reduce if too strong
          density: 1,
          // tweak: smaller = more dots; larger = fewer dots
          opacity: 0.15,
          // 15% opacity
          color: Colors.white,
          child: Container(
            width: double.infinity,
            height: 208,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(11)),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.05,
                vertical: size.height * 0.025,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Get Physical gold',
                    style: GoogleFonts.urbanist(
                      textStyle: const TextStyle(
                        color: Color(0xffFFFFFF),
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.03),
                  Text(
                    'Note:Physical gold can be collected from our partner jewellery\nstores. A voucher will be generated for redemption.',
                    style: GoogleFonts.urbanist(
                      textStyle: const TextStyle(
                        color: Color(0xffA5A5A5),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.03),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => get_physical_gold(
                            onBackToGold: () {
                              final goldState = context
                                  .findAncestorStateOfType<
                                    gold_investmentState
                                  >();
                              if (goldState != null) {
                                goldState.switchToTab(
                                  1,
                                ); // Switch to Sell Gold tab
                              }
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      height: 42,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(11),
                        color: Color(0xffD4B373),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.2,
                          vertical: size.height * 0.01,
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/images/Investments/buy_gold_now.png',
                              width: 22,
                              height: 22,
                            ),
                            SizedBox(width: size.width * 0.01),
                            Text(
                              'Get Physical Gold',
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
        SizedBox(height: size.height * 0.04),
      ],
    );
  }
}
