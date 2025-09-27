import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class home extends StatefulWidget {
  const home({super.key});

  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {
  final kyc_verified = false;
  int _selectedIndex = 0;

  final List<String> labels = [
    "Home",
    "Chit Groups",
    "Investments",
    "Transactions",
    "Profile",
  ];

  final List<String> icons = [
    'assets/images/home.png',
    'assets/images/chit group.png',
    'assets/images/investment.png',
    'assets/images/transactions.png',
    'assets/images/profile.png',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // You can navigate to your screens here if needed
    // Example:
    // if (index == 0) Navigator.push(...);
  }

  @override
  Widget build(BuildContext context) {
    final List<String> items = [
      "₹ 10 Lakh Chit",
      "₹ 10 Lakh Chit",
      "₹ 10 Lakh Chit",
      "₹ 10 Lakh Chit",
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
                    Image.asset(
                      'assets/images/notification (2).png',
                      width: 31,
                      height: 31,
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                    color: Color(0xff8484844D).withOpacity(0.3),
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
                        'assets/images/container.png',
                        width: 143,
                        height: 53,
                      ),
                    ),
                  ],
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
                                'assets/images/arrow forward.png',
                                width: 18,
                                height: 17,
                              ),
                            ),
                          ],
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
                                'assets/images/arrow forward.png',
                                width: 18,
                                height: 17,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(11),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: auction_status == true
                              ? [Color(0xff6495F9), Color(0xff000000)]
                              : [Color(0xff1A1A1A)],
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
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: size.width * 0.2,
                                    top: size.height * 0.045,
                                  ),
                                  child: Image.asset(
                                    'assets/images/auction.png',
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
                                if (!kyc_verified) {
                                  showHalfScreenDrawer(context);
                                }
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
                          : Container(
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
                                      'assets/images/view more.png',
                                      width: 15.56,
                                      height: 15.56,
                                    ),
                                  ],
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                          width: size.width * 0.28,
                          height: size.height * 0.09,
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
                                  'Money',
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
                                    'assets/images/cash.png',
                                    width: size.width * 0.1,
                                    height: size.height * 0.05,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
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
                          width: size.width * 0.28,
                          height: size.height * 0.09,
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
                                    'assets/images/gold.png',
                                    width: size.width * 0.1,
                                    height: size.height * 0.05,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
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
                          width: size.width * 0.28,
                          height: size.height * 0.09,
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
                                    'assets/images/real estate.png',
                                    width: size.width * 0.1,
                                    height: size.height * 0.05,
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
      bottomNavigationBar: Container(
        width: double.infinity,
        decoration: BoxDecoration(color: Color(0xff000000)),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(5, (index) {
            final bool isSelected = _selectedIndex == index;

            return GestureDetector(
              onTap: () => _onItemTapped(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: size.width * 0.02,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF3966CA).withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      icons[index],
                      width: 25,
                      height: 25,
                      color: isSelected ? Color(0xFF4770CB) : Color(0xffFFFFFF),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      labels[index],
                      style: GoogleFonts.urbanist(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? const Color(0xFF1762FC)
                            : Color(0xffFFFFFF),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  void showHalfScreenDrawer(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.4, // 🧭 Half the screen height
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xff242424), Color(0xff373735)],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Small top indicator line
                  Container(
                    width: 30,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Color(0xff6F6F6F),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(height: size.height * 0.03),
                  Image.asset('assets/images/kyc.png', width: 101, height: 131),
                  SizedBox(height: size.height * 0.02),
                  const Text(
                    "Complete your profile and KYC to participate in\n                     chits or start investing.",
                    style: TextStyle(
                      color: Color(0xffFFFFFF),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(height: size.height * 0.03),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // 👉 Navigate to your KYC screen if needed
                      // Navigator.push(context, MaterialPageRoute(builder: (_) => KycScreen()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4770CB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 80,
                        vertical: 10,
                      ),
                    ),
                    child: const Text(
                      "Set up Profile",
                      style: TextStyle(
                        color: Color(0xffFFFFFF),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
