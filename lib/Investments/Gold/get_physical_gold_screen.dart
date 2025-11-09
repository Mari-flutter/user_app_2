import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user_app/Investments/Gold/gold_investment_screen.dart';
import 'package:user_app/Investments/Gold/store_selection_screen.dart';

class get_physical_gold extends StatefulWidget {
  final VoidCallback? onBackToGold;

  const get_physical_gold({super.key, this.onBackToGold});

  @override
  State<get_physical_gold> createState() => _get_physical_goldState();
}

class _get_physical_goldState extends State<get_physical_gold> {
  TextEditingController _controller = TextEditingController();
  double approxAmount = 0.0;
  final double goldRate = 10000; // 1 gram = ₹10,000
  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      double grams = double.tryParse(_controller.text) ?? 0;
      setState(() {
        approxAmount = grams * goldRate;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                                gold_investment(initialTab: 0),
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
                      'Get Physical Gold',
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
                                Text(
                                  '${goldRate}/gram',
                                  style: GoogleFonts.urbanist(
                                    textStyle: const TextStyle(
                                      color: Color(0xffFFFFFF),
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  '+2.3% today',
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
                                  '28.5 grams',
                                  style: GoogleFonts.urbanist(
                                    textStyle: const TextStyle(
                                      color: Color(0xffFFFFFF),
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  '₹1,78,125',
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
                                  'Enter grams (₹)',
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
                                      // 👈 must enable to show background color
                                      fillColor: Color(0xff2A2A2A),

                                      // 👈 background color
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 10,
                                          ),

                                      // 👇 Focused border (when you tap on it)
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0xff2A2A2A),
                                        ),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0xff2A2A2A),
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
                                          '₹ ${approxAmount.toStringAsFixed(0)}',
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => store_selection(),
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
                            child: Center(
                              child: Text(
                                'Continue to Store Selection >',
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
