import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user_app/Investments/Gold/sell_gold_screen.dart';

import 'buy_gold_screen.dart';
import 'gold_scheme_screen.dart';

class gold_investment extends StatefulWidget {
  final Function(int)? onTabChange;
  final int initialTab;
  final VoidCallback? onBack; // <-- Added callback

  const gold_investment({
    super.key,
    this.onTabChange,
    required this.initialTab,
    this.onBack, // <-- Accept callback
  });

  @override
  State<gold_investment> createState() => gold_investmentState();
}

class gold_investmentState extends State<gold_investment> {
  late int _selectedIndex;
  void switchToTab(int index) {
    _onItemTapped(index); // call the private one internally
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTab;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    widget.onTabChange?.call(index);
  }

  final List<String> buy_sell_scheme_tag = ['Buy Gold', 'Sell Gold', 'Schemes'];
  late final List<Widget> pages = [buy_gold(), sell_gold(), gold_scheme()];

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
                    Text(
                      'Investments',
                      style: GoogleFonts.urbanist(
                        textStyle: const TextStyle(
                          color: Color(0xffE2E2E2),
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: size.width * 0.02),
                    Container(
                      width: 42,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Color(0xffF8C545),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Center(
                        child: Text(
                          'Gold',
                          style: GoogleFonts.urbanist(
                            textStyle: const TextStyle(
                              color: Color(0xff383838),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.02),
                Container(
                  width: double.infinity,
                  height: 168,
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
                        Text(
                          'Invest in Digital Gold Today,',
                          style: GoogleFonts.urbanist(
                            textStyle: const TextStyle(
                              color: Color(0xffFFFFFF),
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          'Safe & Convenient.',
                          style: GoogleFonts.urbanist(
                            textStyle: const TextStyle(
                              color: Color(0xffFFFFFF),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(height: size.height * 0.03),
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
                                  '₹6,250/g',
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
                Text(
                  'Quick Actions',
                  style: GoogleFonts.urbanist(
                    textStyle: const TextStyle(
                      color: Color(0xff696969),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.03),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(buy_sell_scheme_tag.length, (
                      index,
                    ) {
                      final bool isSelected = _selectedIndex == index;
                      return GestureDetector(
                        onTap: () => _onItemTapped(index),
                        child: Padding(
                          padding: EdgeInsets.only(right: size.width * 0.02),
                          child: Padding(
                            padding: EdgeInsets.all(.2),
                            child: Container(
                              width: size.width * 0.3,
                              height: 72,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(11),
                                color: isSelected?Color(0xffB5925B):Color(0xff3E3E3E),
                              ),
                              child: Center(
                                child: Text(
                                  buy_sell_scheme_tag[index],
                                  style: GoogleFonts.urbanist(
                                    textStyle: const TextStyle(
                                      color: Color(0xffFFFFFF),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
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
                SizedBox(height: size.height * 0.03),

                // 🔹 Show tab content dynamically
                pages[_selectedIndex],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
