import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user_app/My_Investments/my_investment_gold_screen.dart';

import '../Bottom_Navbar/bottom_navigation_bar.dart';
import 'my_investment_realestate_screen.dart';

class my_investments extends StatefulWidget {
  final Function(int)? onTabChange;
  final int initialTab;
  final VoidCallback? onBack; // <-- Added callback
  final VoidCallback? onGoldSellTap;

  const my_investments({
    super.key,
    this.onTabChange,
    required this.initialTab,
    this.onBack,
    this.onGoldSellTap,
  });

  @override
  State<my_investments> createState() => _my_investmentsState();
}

class _my_investmentsState extends State<my_investments> {
  late int _selectedIndex;

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

  final List<String> InvestmentTypeTags = ["Gold", "Real Estate"];
  late final List<Widget> pages = [
    my_investment_gold(
      totalMonths: 10,
      completedMonths: 6,
      chitValue: 100000,
      totalContribution: 450,
      onGoldSellTap: widget.onGoldSellTap, // pass up to parent
    ),
    my_investment_realestate(
      totalMonths: 10,
      completedMonths: 6,
    ),
  ];

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
                          MaterialPageRoute(builder: (context) => HomeLayout()),
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
                      'My Investments',
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

                // 🔹 Tabs
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(InvestmentTypeTags.length, (index) {
                      final bool isSelected = _selectedIndex == index;
                      return GestureDetector(
                        onTap: () => _onItemTapped(index),
                        child: Container(
                          height: 25,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xff3A7AFF).withOpacity(0.76)
                                : const Color(0xff262626).withOpacity(0.76),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.02,
                              vertical: size.height * 0.003,
                            ),
                            child: Text(
                              InvestmentTypeTags[index],
                              style: GoogleFonts.urbanist(
                                color: const Color(0xffFFFFFF),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                SizedBox(height: size.height * 0.03),
                pages[_selectedIndex],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
