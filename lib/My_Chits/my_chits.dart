import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user_app/Bottom_Navbar/bottom_navigation_bar.dart';
import 'package:user_app/My_Chits/Explore_chits/explore_chit_screen.dart';
import 'package:user_app/Chit_Groups/requested_chit_notifier.dart';

class my_chits extends StatefulWidget {
  final Function(int)? onTabChange;
  final int initialTab;

  const my_chits({super.key, this.onTabChange, required this.initialTab});

  @override
  State<my_chits> createState() => _my_chitsState();
}

class _my_chitsState extends State<my_chits> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTab; // 🔹 start with Requested tab
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (widget.onTabChange != null) {
      widget.onTabChange!(index);
    }
  }

  final List<String> chitTypeTags = ["Active Chits", "Requsted"];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xff000000),
      body: SafeArea(
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
                    'My Chits',
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
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(chitTypeTags.length, (index) {
                    final bool isSelected = _selectedIndex == index;
                    return GestureDetector(
                      onTap: () => _onItemTapped(index),
                      child: Container(
                        height: 25,
                        margin: const EdgeInsets.only(right: 13),
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
                              textStyle: const TextStyle(
                                color: Color(0xffFFFFFF),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
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
              Expanded(
                child: _selectedIndex == 0
                    ? ActiveChitsPage() // Active Chits
                    : RequestedChitsPage(), // Requested Chits
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ActiveChitsPage extends StatefulWidget {
  const ActiveChitsPage({super.key});

  @override
  State<ActiveChitsPage> createState() => _ActiveChitsPageState();
}

class _ActiveChitsPageState extends State<ActiveChitsPage> {
  final List<Map<String, dynamic>> activeChits = [
    {
      "title": "₹4 Lakh Chit",
      "type": "Monthly",
      "value": "₹1,00,000",
      "contribution": "₹10,000",
      "totalMembers": "10",
      "addedMembers": "8",
      "startDate": "01/10/2025",
      "endDate": "01/08/2026",
      "duration": "10 Months",
      "auctionDate": "05/10/2025",
    },
    {
      "title": "₹2 Lakh Chit",
      "type": "Weekly",
      "value": "₹50,000",
      "contribution": "₹5,000",
      "totalMembers": "10",
      "addedMembers": "10",
      "startDate": "10/09/2025",
      "endDate": "10/07/2026",
      "duration": "10 Months",
      "auctionDate": "15/09/2025",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (activeChits.isEmpty) {
      return Center(
        child: Column(
          children: [
            SizedBox(height: size.height * 0.15),
            Image.asset(
              'assets/images/My_Chits/no_active chits.png',
              width: 232,
              height: 232,
            ),
            SizedBox(height: size.height * 0.04),
            Text(
              "No active chits available at the moment!",
              style: GoogleFonts.urbanist(
                textStyle: const TextStyle(
                  color: Color(0xffBBBBBB),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 🔹 Show Active Chits
    return SingleChildScrollView(
      child: Column(
        children: activeChits.map((chit) {
          return Padding(
            padding: EdgeInsets.only(bottom: size.height * 0.02),
            child: Column(
              children: [
                // 🔹 Chit Card (Top section)
                Container(
                  width: double.infinity,
                  height: size.height * 0.23,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    gradient: const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Color(0xff232323), Color(0xff383836)],
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.04,
                      vertical: size.height * 0.02,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              chit["title"],
                              style: GoogleFonts.urbanist(
                                textStyle: const TextStyle(
                                  color: Color(0xff3A7AFF),
                                  fontSize: 28,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              chit["type"],
                              style: GoogleFonts.urbanist(
                                textStyle: const TextStyle(
                                  color: Color(0xffB5B4B4),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: size.height * 0.01),

                        // Info rows
                        _buildInfoRow(
                          "Chit Value : ${chit["value"]}",
                          "Mon.Contribution : ${chit["contribution"]}",
                        ),
                        _buildInfoRow(
                          "Total Members : ${chit["totalMembers"]}",
                          "Added Members : ${chit["addedMembers"]}",
                        ),
                        _buildInfoRow(
                          "Start Date : ${chit["startDate"]}",
                          "End Date : ${chit["endDate"]}",
                        ),
                        _buildInfoRow(
                          "Duration : ${chit["duration"]}",
                          "Auction Date : ${chit["auctionDate"]}",
                        ),
                        SizedBox(height: size.height * 0.01),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => explore_chit(
                                    totalMonths: 10,
                                    completedMonths: 3,
                                    chitValue: 200000,
                                    totalContribution: 30000,
                                    auctionDateTime: "2025-10-06T10:00:00",
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: 78,
                              height: 24,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(7),
                                color: const Color(0xffFFFFFF),
                              ),
                              child: Center(
                                child: Text(
                                  'Explore',
                                  style: GoogleFonts.urbanist(
                                    textStyle: const TextStyle(
                                      color: Color(0xff000000),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
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
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInfoRow(String left, String right) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            left,
            style: GoogleFonts.urbanist(
              textStyle: const TextStyle(
                color: Color(0xffF8F8F8),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            right,
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
    );
  }
}

class RequestedChitsPage extends StatefulWidget {
  @override
  State<RequestedChitsPage> createState() => _RequestedChitsPageState();
}

class _RequestedChitsPageState extends State<RequestedChitsPage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final requestedChits = RequestedChitNotifier.requestedChits;

    if (requestedChits.isEmpty) {
      return Center(
        child: Column(
          children: [
            SizedBox(height: size.height * 0.15),
            Image.asset(
              'assets/images/My_Chits/no_active chits.png',
              width: 232,
              height: 232,
            ),
            SizedBox(height: size.height * 0.04),
            Text(
              "No requested chits yet!",
              style: GoogleFonts.urbanist(
                textStyle: const TextStyle(
                  color: Color(0xffBBBBBB),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: requestedChits.map((chit) {
          // 🔹 Compute status dynamically
          bool isRequested = RequestedChitNotifier.requestedChits.any(
            (c) => c['title'] == chit['title'],
          );
          String status = isRequested ? "Requested" : "Request to Join";

          return Padding(
            padding: EdgeInsets.only(bottom: size.height * 0.02),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: size.height * 0.23,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                    gradient: const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Color(0xff232323), Color(0xff383836)],
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.04,
                      vertical: size.height * 0.02,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              chit["title"],
                              style: GoogleFonts.urbanist(
                                textStyle: const TextStyle(
                                  color: Color(0xff3A7AFF),
                                  fontSize: 28,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              chit["type"],
                              style: GoogleFonts.urbanist(
                                textStyle: const TextStyle(
                                  color: Color(0xffB5B4B4),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: size.height * 0.01),

                        // Info rows
                        _buildInfoRow(
                          "Chit Value : ${chit["value"]}",
                          "Mon.Contribution : ${chit["contribution"]}",
                        ),
                        _buildInfoRow(
                          "Total Members : ${chit["totalMembers"]}",
                          "Added Members : ${chit["addedMembers"]}",
                        ),
                        _buildInfoRow(
                          "Start Date : ${chit["startDate"]}",
                          "End Date : ${chit["endDate"]}",
                        ),
                        _buildInfoRow(
                          "Duration : ${chit["duration"]}",
                          "Auction Date : ${chit["auctionDate"]}",
                        ),

                        SizedBox(height: size.height * 0.01),

                        Align(
                          alignment: Alignment.bottomRight,
                          child: Container(
                            width: 100,
                            height: 24,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(7),
                              color: isRequested
                                  ? const Color(0xff626262)
                                  : Color(0xffFFFFFF),
                            ),
                            child: Center(
                              child: Text(
                                status,
                                style: GoogleFonts.urbanist(
                                  textStyle: TextStyle(
                                    color: isRequested
                                        ? const Color(0xffC4C4C4)
                                        : const Color(0xff000000),
                                    fontSize: 12,
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
                // 🔹 Grey container below each chit card
                Container(
                  width: double.infinity,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25),
                    ),
                    color: Color(0xffD6D6D6),
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: size.width * 0.04),
                      Image.asset(
                        'assets/images/My_Chits/time.png',
                        width: 24,
                        height: 24,
                      ),
                      SizedBox(width: size.width * 0.02),
                      Text(
                        'Your chit request has been sent successfully. Once verified,\nyou’ll be added to the chit group.',
                        style: GoogleFonts.urbanist(
                          textStyle: const TextStyle(
                            color: Color(0xff6B6B6B),
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInfoRow(String left, String right) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            left,
            style: GoogleFonts.urbanist(
              textStyle: const TextStyle(
                color: Color(0xffF8F8F8),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            right,
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
    );
  }
}
