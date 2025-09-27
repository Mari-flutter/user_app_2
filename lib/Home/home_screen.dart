import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user_app/Home_Page_User_Chits_Breakdown/history_screen.dart';
import 'package:user_app/Investments/Gold/gold_investment_screen.dart';
import 'package:user_app/My_Chits/my_chits.dart';
import 'package:user_app/Notification/notification_screen.dart';
import 'package:user_app/Live_Auction/pre_auction_timer_lobby.dart';
import 'package:user_app/Chit_Groups/selected_chit_notifier.dart';

class home extends StatefulWidget {
  final Function(int) onTabChange; // Callback to switch tabs
  final VoidCallback? onGoldTap;

  const home({super.key, required this.onTabChange, this.onGoldTap});

  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {
  final List<String> labels = [
    "Home",
    "Chit Groups",
    "Investments",
    "Transactions",
    "Profile",
  ];

  final List<String> icons = [
    'assets/images/Bottom_Navbar/home.png',
    'assets/images/Bottom_Navbar/chit group.png',
    'assets/images/Bottom_Navbar/investment.png',
    'assets/images/Bottom_Navbar/transactions.png',
    'assets/images/Bottom_Navbar/profile.png',
  ];

  @override
  Widget build(BuildContext context) {
    final List<String> items = [
      "₹ 2 Lakh Chit",
      "₹ 4 Lakh Chit",
      "₹ 2 Lakh Chit",
      "View More",
    ];
    final auction_status = true;
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
                      'Monday, 5',
                      style: GoogleFonts.urbanist(
                        textStyle: const TextStyle(
                          color: Color(0xffFFFFFF),
                          fontSize: 36,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => notification(),
                          ),
                        );
                      },
                      child: Image.asset(
                        'assets/images/Home/notification (2).png',
                        width: 31,
                        height: 31,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.02),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => History(initialTab: 0),
                      ),
                    );
                  },
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 189,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Color(0xff3B69CF), Color(0xff000000)],
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
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                  Container(
                                    width: 91,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      color: Color(
                                        0xff8484844D,
                                      ).withOpacity(0.3),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Pending Dues',
                                        style: GoogleFonts.urbanist(
                                          textStyle: const TextStyle(
                                            color: Color(0xffFFFFFF),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
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
                        bottom: 0,
                        right: 0,
                        child: Image.asset(
                          'assets/images/Home/container.png',
                          width: 143,
                          height: 53,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                Row(
                  children: [
                    Text(
                      'Overview of your',
                      style: GoogleFonts.urbanist(
                        textStyle: const TextStyle(
                          color: Color(0xffEDEDED),
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      ' activities..',
                      style: GoogleFonts.urbanist(
                        textStyle: const TextStyle(
                          color: Color(0xff4770CB),
                          fontSize: 20,
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
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => my_chits(initialTab: 0),
                          ),
                        );
                      },
                      child: Container(
                        width: size.width * 0.28,
                        height: size.height * 0.15,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(11),
                          color: Color(0xff1A1A1A),
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(left: size.width * 0.02),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: size.height * 0.017),
                              Text(
                                'My Chits',
                                style: GoogleFonts.urbanist(
                                  textStyle: const TextStyle(
                                    color: Color(0xffBFBFBF),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              SizedBox(height: size.height * 0.01),
                              Text(
                                'Keep track of all your\nactive and past chits\neffortlessly.',
                                style: GoogleFonts.urbanist(
                                  textStyle: const TextStyle(
                                    color: Color(0xffBFBFBF),
                                    fontSize: 8,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  left: size.width * 0.2,
                                  top: size.height * 0.033,
                                ),
                                child: Image.asset(
                                  'assets/images/Home/arrow forward.png',
                                  width: 18,
                                  height: 17,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: size.width * 0.28,
                      height: size.height * 0.15,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(11),
                        color: Color(0xff1A1A1A),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(left: size.width * 0.02),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: size.height * 0.017),
                            Text(
                              'Investments',
                              style: GoogleFonts.urbanist(
                                textStyle: const TextStyle(
                                  color: Color(0xffBFBFBF),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(height: size.height * 0.01),
                            Text(
                              'Monitor earnings from\nall your investments.',
                              style: GoogleFonts.urbanist(
                                textStyle: const TextStyle(
                                  color: Color(0xffBFBFBF),
                                  fontSize: 8,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                left: size.width * 0.2,
                                top: size.height * 0.045,
                              ),
                              child: Image.asset(
                                'assets/images/Home/arrow forward.png',
                                width: 18,
                                height: 17,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => auction_timer_lobby(),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(11),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: auction_status == true
                                ? [Color(0xff6495F9), Color(0xff000000)]
                                : [Color(0xff1A1A1A), Color(0xff1A1A1A)],
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(1),
                          child: Container(
                            width: size.width * 0.28,
                            height: size.height * 0.15,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(11),
                              color: Color(0xff1A1A1A),
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(left: size.width * 0.02),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: size.height * 0.017),
                                  Text(
                                    'Auction',
                                    style: GoogleFonts.urbanist(
                                      textStyle: TextStyle(
                                        color: const Color(0xff4770CB),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: size.height * 0.01),
                                  Text(
                                    'Step into the world of\ncompetitive bidding.',
                                    style: GoogleFonts.urbanist(
                                      textStyle: const TextStyle(
                                        color: Color(0xffBFBFBF),
                                        fontSize: 8,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  if (auction_status == true) ...[
                                    SizedBox(height: size.height * 0.01),
                                    Text(
                                      'Action Starts in 05:00',
                                      style: GoogleFonts.urbanist(
                                        textStyle: const TextStyle(
                                          color: Color(0xff1762FC),
                                          fontSize: 8,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                  Padding(
                                    padding: EdgeInsets.only(
                                      left: size.width * 0.2,
                                      top: (auction_status == true)
                                          ? size.height * 0.023
                                          : size.height * 0.04,
                                    ),
                                    child: Image.asset(
                                      'assets/images/Home/auction.png',
                                      width: 18,
                                      height: 17,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.02),
                Text(
                  'Available Chits',
                  style: GoogleFonts.urbanist(
                    textStyle: const TextStyle(
                      color: Color(0xff4770CB),
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(items.length, (index) {
                      final bool isLast = index == items.length - 1;
                      return isLast == false
                          ? GestureDetector(
                              onTap: () {
                                // Store the selected chit index in the notifier
                                SelectedChitNotifier.selectedChitIndex = index;
                                widget.onTabChange.call(
                                  1,
                                ); // navigate to chit groups
                              },
                              child: Container(
                                width: 169,
                                height: size.height * 0.106,
                                margin: EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: Color(0xff3966CA),
                                  borderRadius: BorderRadius.circular(11),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: size.width * 0.025,
                                    vertical: size.height * 0.009,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        items[index],
                                        style: GoogleFonts.urbanist(
                                          color: Color(0xffFFFFFF),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 18,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: size.height * 0.001),
                                      Text(
                                        'Total Members : 10',
                                        style: GoogleFonts.urbanist(
                                          color: Color(0xffFFFFFF),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 10,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: size.height * 0.001),
                                      Text(
                                        'Duration : 10 Months',
                                        style: GoogleFonts.urbanist(
                                          color: Color(0xffFFFFFF),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 10,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: size.height * 0.001),
                                      Text(
                                        'Monthly Contribution : 10,000/-',
                                        style: GoogleFonts.urbanist(
                                          color: Color(0xffFFFFFF),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 10,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : GestureDetector(
                              onTap: () {
                                widget.onTabChange(
                                  1,
                                ); // Switch to chit_groups tab
                              },
                              child: Container(
                                width: 44,
                                height: 88,
                                margin: EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: Color(0xff3966CA),
                                  borderRadius: BorderRadius.circular(11),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: size.width * 0.02,
                                    vertical: size.height * 0.023,
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        'View\nMore',
                                        style: GoogleFonts.urbanist(
                                          color: Color(0xffFFFFFF),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 10,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      Image.asset(
                                        'assets/images/Home/view more.png',
                                        width: 15.56,
                                        height: 15.56,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                    }),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                Text(
                  'Investments',
                  style: GoogleFonts.urbanist(
                    textStyle: const TextStyle(
                      color: Color(0xff4770CB),
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        widget.onGoldTap
                            ?.call(); // <-- this calls navigateToGold() in HomeLayout
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            size.width * 0.03,
                          ),
                          gradient: const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Color(0xff666666), Color(0xff000000)],
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(size.width * 0.003),
                          child: Container(
                            width: size.width * 0.3,
                            height: size.height * 0.08,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                size.width * 0.03,
                              ),
                              color: const Color(0xff1A1A1A),
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(left: size.width * 0.02),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: size.height * 0.008),
                                  Text(
                                    'Gold',
                                    style: GoogleFonts.urbanist(
                                      textStyle: TextStyle(
                                        color: const Color(0xff626262),
                                        fontSize: size.width * 0.03,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                      left: size.width * 0.14,
                                    ),
                                    child: Image.asset(
                                      'assets/images/Investments/gold.png',
                                      width: size.width * 0.15,
                                      height: size.height * 0.04,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: size.width * 0.06),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(size.width * 0.03),
                        gradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Color(0xff666666), Color(0xff000000)],
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(size.width * 0.003),
                        child: Container(
                          width: size.width * 0.3,
                          height: size.height * 0.08,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              size.width * 0.03,
                            ),
                            color: const Color(0xff1A1A1A),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(left: size.width * 0.02),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: size.height * 0.008),
                                Text(
                                  'Real Estate',
                                  style: GoogleFonts.urbanist(
                                    textStyle: TextStyle(
                                      color: const Color(0xff626262),
                                      fontSize: size.width * 0.03,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: size.width * 0.14,
                                  ),
                                  child: Image.asset(
                                    'assets/images/Investments/real_estate.png',
                                    width: size.width * 0.15,
                                    height: size.height * 0.04,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
