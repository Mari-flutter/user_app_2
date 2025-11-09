import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user_app/Bottom_Navbar/bottom_navigation_bar.dart';
import 'package:user_app/Home_Page_User_Chits_Breakdown/total_chits.dart';
import 'package:user_app/Home_Page_User_Chits_Breakdown/upcomming_auction.dart';

import 'pay_a_month.dart';
import 'pending_payments.dart';

class History extends StatefulWidget {
  final Function(int)? onTabChange;
  final int initialTab;

  const History({super.key, this.onTabChange, required this.initialTab});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
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

  final List<String> chitTypeTags = [
    "Total Chits 2",
    "Upcoming Auction 1",
    "Pay a month",
    "Pending Payments",
  ];

  // 🔹 Widget list for each tab
  late final List<Widget> pages = [
    const TotalChitsPage(),
    const UpcomingAuctionPage(),
    const PayMonthPage(),
    const PendingPaymentsPage(),
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
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Color(0xff282828),
                  ),
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HomeLayout()),
                        );
                      },
                      child: Image.asset(
                        'assets/images/Home_Page_User_Chits_Breakdown/back.png',
                        width: 15,
                        height: 15,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: size.width * 0.03),
                Text(
                  'Breakdown',
                  style: GoogleFonts.urbanist(
                    textStyle: const TextStyle(
                      color: Color(0xffFFFFFF),
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: size.height * 0.02),

            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 189,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        'assets/images/Home/Home_screen_main card_1.jpg',
                      ),
                      fit: BoxFit.fill, // full screen
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.05,
                      vertical: size.height * 0.02,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi Tom,',
                          style: GoogleFonts.urbanist(
                            textStyle: const TextStyle(
                              color: Color(0xffF8F8F8),
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(height: size.height * 0.005),
                        Row(
                          children: [
                            Text(
                              '₹ 2,40,000',
                              style: GoogleFonts.urbanist(
                                textStyle: const TextStyle(
                                  color: Color(0xffFFFFFF),
                                  fontSize: 32,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(width: size.width * 0.03),
                            Text(
                              'total subscription value',
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
                        SizedBox(height: size.height * 0.005),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                            SizedBox(height: size.height * 0.002),
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
                            SizedBox(height: size.height * 0.002),
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
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 15,
                  child: Image.asset(
                    'assets/images/Home/container.png',
                    width: 107,
                    height: 90,
                  ),
                ),
              ],
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
