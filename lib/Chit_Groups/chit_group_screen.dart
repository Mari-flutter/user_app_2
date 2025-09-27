import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user_app/My_Chits/my_chits.dart';
import 'package:user_app/Chit_Groups/requested_chit_notifier.dart';
import 'package:user_app/Chit_Groups/selected_chit_notifier.dart';
import 'package:user_app/Profile/setup_profile_screen.dart';

class chit_groups extends StatefulWidget {
  Function(int)? onTabChange;

  chit_groups({super.key, this.onTabChange});

  @override
  State<chit_groups> createState() => _chit_groupsState();
}

class _chit_groupsState extends State<chit_groups> {
  int? _highlightChitIndex;

  @override
  void initState() {
    super.initState();

    if (SelectedChitNotifier.selectedChitIndex != null) {
      _highlightChitIndex = SelectedChitNotifier.selectedChitIndex;
      SelectedChitNotifier.selectedChitIndex = null;

      // 🔹 Glow lasts very short: 100ms
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          setState(() {
            _highlightChitIndex = null;
          });
        }
      });
    }
  }

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (widget.onTabChange != null) {
      widget.onTabChange!(index);
    }
  }

  final List<String> chitTypeTags = [
    "All Chits",
    "Daily",
    "Weekly",
    "Monthly",
    "Yearly",
  ];

  final List<Map<String, dynamic>> chitList = [
    {
      "title": "₹2 Lakh Chit",
      "type": "Monthly",
      "value": "2,00,000/-",
      "contribution": "10,000/-",
      "totalMembers": "20",
      "addedMembers": "08",
      "startDate": "05-11-2025",
      "endDate": "05-03-2027",
      "duration": "20 Months",
      "auctionDate": "05-12-2025",
      "status": "Request to Join",
    },
    {
      "title": "₹4 Lakh Chit",
      "type": "Weekly",
      "value": "4,00,000/-",
      "contribution": "20,000/-",
      "totalMembers": "10",
      "addedMembers": "09",
      "startDate": "06-12-2025",
      "endDate": "06-12-2026",
      "duration": "10 Months",
      "auctionDate": "06-01-2026",
      "status": "Request to Join",
    },
    {
      "title": "₹6 Lakh Chit",
      "type": "Yearly",
      "value": "2,00,000/-",
      "contribution": "10,000/-",
      "totalMembers": "20",
      "addedMembers": "08",
      "startDate": "05-11-2025",
      "endDate": "05-03-2027",
      "duration": "20 Months",
      "auctionDate": "05-12-2025",
      "status": "Request to Join",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xff000000),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: size.height * 0.02),
                Text(
                  'Chit Groups',
                  style: GoogleFonts.urbanist(
                    textStyle: const TextStyle(
                      color: Color(0xffFFFFFF),
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.04),

                // 🔹 Chips
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

                SizedBox(height: size.height * 0.025),

                Column(
                  children: chitList.asMap().entries.map((entry) {
                    final index = entry.key;
                    final chit = entry.value;

                    return Padding(
                      padding: EdgeInsets.only(bottom: size.height * 0.02),
                      child: ChitCard(
                        chit: chit,
                        isHighlighted: _highlightChitIndex == index,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ChitCard extends StatefulWidget {
  final Map<String, dynamic> chit;
  final Function(Map<String, dynamic>)? onStatusChanged;
  final bool isHighlighted;

  const ChitCard({
    super.key,
    required this.chit,
    this.onStatusChanged,
    this.isHighlighted = false,
  });

  @override
  State<ChitCard> createState() => _ChitCardState();
}

class _ChitCardState extends State<ChitCard> {
  final bool kyc_verified = true;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // ✅ Compute status dynamically from notifier
    bool isRequested = RequestedChitNotifier.requestedChits.any(
      (c) => c['title'] == widget.chit['title'],
    );
    String status = isRequested ? "Requested" : "Request to Join";

    return AnimatedContainer(
      width: double.infinity,
      height: size.height * 0.23,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: widget.isHighlighted
            ? const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xFF485267), Color(0xFF485267)],
              )
            : const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xff232323), Color(0xff383836)],
              ),
      ),
      duration: const Duration(milliseconds: 100),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.04,
          vertical: size.height * 0.02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.chit["title"],
                  style: GoogleFonts.urbanist(
                    textStyle: const TextStyle(
                      color: Color(0xff3A7AFF),
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  widget.chit["type"],
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

            _buildInfoRow(
              "Chit Value : ${widget.chit["value"]}",
              "Mon.Contribution : ${widget.chit["contribution"]}",
            ),
            _buildInfoRow(
              "Total Members : ${widget.chit["totalMembers"]}",
              "Added Members : ${widget.chit["addedMembers"]}",
            ),
            _buildInfoRow(
              "Start Date : ${widget.chit["startDate"]}",
              "End Date : ${widget.chit["endDate"]}",
            ),
            _buildInfoRow(
              "Duration : ${widget.chit["duration"]}",
              "Auction Date : ${widget.chit["auctionDate"]}",
            ),

            SizedBox(height: size.height * 0.01),

            Align(
              alignment: Alignment.bottomRight,
              child: GestureDetector(
                onTap: () {
                  if (kyc_verified) {
                    showHalfScreenDrawer(context);
                  } else {
                    // ✅ Add chit to Requested if not already added
                    bool alreadyExists = RequestedChitNotifier.requestedChits
                        .any((c) => c["title"] == widget.chit["title"]);

                    if (!alreadyExists) {
                      RequestedChitNotifier.requestedChits.add(
                        Map<String, dynamic>.from(widget.chit),
                      );
                      setState(() {});
                    }

                    // ✅ Navigate directly to My Chits, Requested tab (index 1)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => my_chits(initialTab: 1),
                      ),
                    ).then((_) {
                      // Optional: you can trigger a setState to refresh if needed
                      setState(() {});
                    });
                  }
                },
                child: Container(
                  width: 100,
                  height: 24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    color: isRequested
                        ? const Color(0xff626262)
                        : const Color(0xffFFFFFF),
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
            ),
          ],
        ),
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

  void showHalfScreenDrawer(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.4,
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
                  Container(
                    width: 30,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Color(0xff6F6F6F),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(height: size.height * 0.03),
                  Image.asset('assets/images/Chit_Groups/kyc.png', width: 101, height: 131),
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
                      Navigator.push(context,MaterialPageRoute(builder: (context)=>setup_profile()));
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
