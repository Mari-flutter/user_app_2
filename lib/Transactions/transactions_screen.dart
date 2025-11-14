import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user_app/Transactions/transactions_history_for_chits.dart';
import 'package:user_app/Transactions/transactions_history_for_gold.dart';
import 'package:user_app/Transactions/transactions_history_for_gold_scheme.dart';
import 'package:user_app/Transactions/transactions_history_for_realestatement.dart';

import 'contribution_screen.dart';

class transactions extends StatefulWidget {
  final Function(int)? onTabChange;
  final int initialTab;

  const transactions({super.key, this.onTabChange, required this.initialTab});

  @override
  State<transactions> createState() => _transactionsState();
}

class _transactionsState extends State<transactions> {
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

  final List<String> chitTypeTags = ["Chits", "Gold","Gold Scheme","Real Estate"];

  // 🔹 Widget list for each tab
  late final List<Widget> pages = [
     transactions_history_for_chits(),
    transactions_history_for_gold(),
    transactions_history_for_gold_scheme(),
    transactions_history_for_real_estatement()
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xff000000),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
          children: [
            SizedBox(height: size.height * 0.02),
            Text(
              'Transactions',
              style: GoogleFonts.urbanist(
                textStyle: const TextStyle(
                  color: Color(0xffFFFFFF),
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(height: size.height * 0.04),

            // 🔹 Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(chitTypeTags.length, (index) {
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
                          chitTypeTags[index],
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

            // 🔹 Show tab content dynamically
            pages[_selectedIndex],
          ],
        ),
      ),
    );
  }
}
