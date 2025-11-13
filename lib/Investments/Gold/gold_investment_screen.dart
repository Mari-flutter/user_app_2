import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user_app/Investments/Gold/withdraw_for_gold_screen.dart';

import '../../Bottom_Navbar/bottom_navigation_bar.dart';
import '../../Models/Investments/Gold/CurrentGoldValue_Model.dart';
import '../../Models/Investments/Gold/user_hold_gold_model.dart';
import '../../Services/Gold_holdings.dart';
import '../../Services/Gold_price.dart';
import 'Buy Gold/buy_gold_screen.dart';
import 'Sell Gold/sell_gold_screen.dart';
import 'gold_scheme_screen.dart';

class gold_investment extends StatefulWidget {
  final Function(int)? onTabChange;
  final int initialTab;

  const gold_investment({
    super.key,
    this.onTabChange,
    required this.initialTab,
  });

  @override
  State<gold_investment> createState() => gold_investmentState();
}

class gold_investmentState extends State<gold_investment> {
  GoldHoldings? goldHoldings;
  CurrentGoldValue? _goldValue;
  bool _loading = true;
  late int _selectedIndex;

  void switchToTab(int index) {
    _onItemTapped(index); // call the private one internally
  }
  Timer? _autoRefreshTimer;
  @override
  void initState() {
    super.initState();
    _loadGoldValue();
    _loadGoldHoldings();
    _selectedIndex = widget.initialTab;
  }
  Future<void> _loadGoldHoldings() async {
    // Step 1️⃣ — Load cached data immediately
    final cached = await GoldHoldingsService.getCachedGoldHoldings();
    if (cached != null) {
      setState(() {
        goldHoldings = cached;
      });
    }

    // Step 2️⃣ — Background fetch new data silently
    final latest = await GoldHoldingsService.fetchAndCacheGoldHoldings();
    if (latest != null) {
      // If new data differs, update UI automatically
      if (latest.userGold != goldHoldings?.userGold ||
          latest.userInvestment != goldHoldings?.userInvestment) {
        setState(() {
          goldHoldings = latest;
        });
      }
    }
  }

  Future<void> _loadGoldValue() async {
    // 1️⃣ Load cached value first
    final cachedValue = await GoldService.getCachedGoldValue();
    if (cachedValue != null) {
      print('💾 Showing cached gold value: ₹${cachedValue.goldValue}');
      setState(() {
        _goldValue = cachedValue;
        _loading = false;
      });
    } else {
      print('⚠️ No cached value, showing loader...');
      setState(() {
        _loading = true;
      });
    }

    // 2️⃣ Fetch updated gold value in background
    try {
      print('🔹 Fetching latest gold price...');
      final latestValue = await GoldService.fetchAndCacheGoldValue();
      if (!mounted) return;
      if (latestValue != null) {
        setState(() {
          _goldValue = latestValue;
          _loading = false;
        });
        print('🌐 Updated to latest gold value: ₹${latestValue.goldValue}');
      }
    } catch (e) {
      print('❌ Error fetching gold value: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    widget.onTabChange?.call(index);
  }

  final List<String> buy_sell_scheme_tag = ['Buy Gold', 'Sell Gold', 'Schemes'];
  late final List<Widget> pages = [buy_gold(goldrate: _goldValue!.goldValue), sell_gold(), gold_scheme()];

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    if (_loading || _goldValue == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    // ✅ Create pages safely here (after gold value is ready)
    final pages = [
      buy_gold(goldrate: _goldValue!.goldValue),
      sell_gold(),
      gold_scheme(),
    ];
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
                          MaterialPageRoute(builder: (context) => HomeLayout(initialTab: 2,)),
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
                      'Investments',
                      style: GoogleFonts.urbanist(
                        textStyle: const TextStyle(
                          color: Color(0xffE2E2E2),
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: size.width * 0.05),
                    GestureDetector(
                      onTap: () {},
                      child: AnimatedContainer(
                        height: 20,
                        width: 42,
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          color: const Color(0xffF8C545),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Gold',
                            style: GoogleFonts.urbanist(
                              textStyle: const TextStyle(
                                color: Color(0xffFFFFFF),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
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
                    gradient: LinearGradient(colors: [Color(0xff734B1F),Color(0xffE1C083)]),
                    borderRadius: BorderRadius.circular(11)
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.05,
                      vertical: size.height * 0.02,
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
                                      color: Color(0xffFFFFFF),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                _loading
                                    ? const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                )
                                    :
                                Text(
                                  '₹${_goldValue?.goldValue.toStringAsFixed(2) ?? '--'}/g',
                                  style: GoogleFonts.urbanist(
                                    textStyle: const TextStyle(
                                      color: Color(0xffFFFFFF),
                                      fontSize: 30,
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
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${goldHoldings?.userGold.toStringAsFixed(2) ?? '--'} g',
                                  style: GoogleFonts.urbanist(
                                    textStyle: const TextStyle(
                                      color: Color(0xffFFFFFF),
                                      fontSize: 30,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: size.height*0.01),
                        Text(
                          'Total Chit Taken : 2',
                          style: GoogleFonts.urbanist(
                            textStyle: const TextStyle(
                              color: Color(0xffF8F8F8),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          'Upcoming Auction on 7 days',
                          style: GoogleFonts.urbanist(
                            textStyle: const TextStyle(
                              color: Color(0xffF8F8F8),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Wants to pay a month : 12,000/-',
                              style: GoogleFonts.urbanist(
                                textStyle: const TextStyle(
                                  color: Color(0xffF8F8F8),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                final goldPrice = _goldValue?.goldValue ?? 0;
                                final holdings = goldHoldings?.userGold ?? 0;
                                final totalValue = goldPrice * holdings;

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => withdraw_for_gold(totalGoldValue: totalValue),
                                  ),
                                );
                              },

                              child: Image.asset(
                                'assets/images/Investments/gold_withdraw.png',
                                width: 60,
                                height: 23,
                              ),
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
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
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
                                gradient: LinearGradient(
                                  colors: isSelected
                                      ? [Color(0xff754E21), Color(0xffCBCBCB)]
                                      : [Color(0xff3E3E3E), Color(0xff3E3E3E)],
                                ),
                              ),
                              child: Container(
                                margin: EdgeInsets.all(2),
                                width: size.width * 0.3,
                                height: 72,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(11),
                                  color: isSelected
                                      ? Color(0xffB5925B)
                                      : Color(0xff3E3E3E),
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
