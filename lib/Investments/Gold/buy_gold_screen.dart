import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class buy_gold extends StatefulWidget {
  const buy_gold({super.key});

  @override
  State<buy_gold> createState() => _buy_goldState();
}

class _buy_goldState extends State<buy_gold> {
  @override
  Widget build(BuildContext context) {
    final List<String> buy_gold_amount_tag = ['1000', '3000', '5000', '10000'];
    final size = MediaQuery.of(context).size;
    TextEditingController _controller = TextEditingController();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: size.height * 0.02),
        Container(
          width: double.infinity,
          height: 354,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            color: Color(0xff3E3E3E),
            border: Border.all(color: Color(0xff61512B), width:0.5),
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
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.04),
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
                              // 👈 must enable to show background color
                              fillColor: Color(0xff575757),
                              // 👈 background color
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              // 👇 Focused border (when you tap on it)
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xff575757),
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              border: OutlineInputBorder(
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
                              '≈ 0.160 grams',
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
                      );
                    }),
                  ),
                ),
                SizedBox(height: size.height * 0.06),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: double.infinity,
                    height: 42,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(11),
                      color: Color(0xffD4B373),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.31,
                        vertical: size.height * 0.01,
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/images/Investments/buy_gold_now.png',
                            width: 20,
                            height: 20,
                          ),
                          SizedBox(width: size.width * 0.01),
                          Text(
                            'Buy Now',
                            style: GoogleFonts.urbanist(
                              textStyle: const TextStyle(
                                color: Color(0xff141414),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
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
      ],
    );
  }
}
