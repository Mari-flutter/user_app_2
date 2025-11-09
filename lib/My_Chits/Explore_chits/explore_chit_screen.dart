import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:user_app/My_Chits/Explore_chits/auction_result_screen.dart';
import 'package:user_app/My_Chits/Explore_chits/chit_scheme_screen.dart';
import 'package:user_app/My_Chits/Explore_chits/terms_and_condition_screen.dart';
import 'package:user_app/My_Chits/Explore_chits/withdraw_for_chits_screen.dart';
import 'package:user_app/My_Chits/my_chits.dart';
import 'package:user_app/My_Chits/Explore_chits/receipts_screen.dart';
import 'package:user_app/Services/secure_storage.dart';
import 'dart:async';

import '../../Models/My_Chits/explore_chit_model.dart';

class explore_chit extends StatefulWidget {
  final String auctionDateTime;
  final int completedMonths;
  final double chitValue;
  final double totalContribution;
  final String chitId;
  final int timePeriod;
  final double otherCharges;
  final double penalty;
  final double taxes;
  final String chitName;
  final String chitType;
  final int TotalMembers;
  final int CurrentMember;

  const explore_chit({
    super.key,
    required this.chitId,
    required this.completedMonths,
    required this.chitValue,
    required this.totalContribution,
    required this.auctionDateTime,
    required this.timePeriod,
    required this.otherCharges,
    required this.penalty,
    required this.taxes,
    required this.chitName,
    required this.chitType,
    required this.TotalMembers,
    required this.CurrentMember,
  });


  @override
  State<explore_chit> createState() => _explore_chitState();
}

class _explore_chitState extends State<explore_chit> {
  final List<String> chit_scheme_to_TC_tags = [
    'Chit Scheme',
    'Auction Results',
    'Receipts',
    'T&C’s',
    'Withdraw'
  ];
  final List<String> chit_scheme_to_TC_images = [
    'assets/images/My_Chits/chit_scheme.png',
    'assets/images/My_Chits/auction_result.png',
    'assets/images/My_Chits/receipts.png',
    'assets/images/My_Chits/T&c.png',
    'assets/images/My_Chits/with_draw.png',
  ];
  late final List<Widget> chit_scheme_to_TC_pages = [
    chit_scheme(
      totalMonths: widget.timePeriod,
      completedMonths: exploreChitList.length,
      auctionDate: "2025-10-04",
      auctionEndDate: "2025-10-04",
      CurrentMember:widget.CurrentMember,
      TotalMember:widget.TotalMembers,
      ChitType:widget.chitType,
      ChitName:widget.chitName,
      OtherCharges:widget.otherCharges,
      Penalty:widget.penalty,
      Taxes:widget.taxes,
      Value:widget.chitValue,
      Contribution:widget.totalContribution,
    ),
    auction_result(),
    receipts(),
    terms_condition(),
    withdraw_for_chits(),
  ];
  final bool isPay_due = true;

  late DateTime auctionTime;
  bool isAuctionStarted = false;
  Timer? _timer;
  List<ExploreChit> exploreChitList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExploreChitData();
  }

  Future<void> _loadExploreChitData() async {
    final userId = await SecureStorageService.getUserId();
    final cacheKey = 'explore_chit_${widget.chitId}_$userId';
    final box = Hive.box('chitBox');

    // 🔹 1. Load cache immediately (no wait)
    final cachedData = box.get(cacheKey);
    if (cachedData != null) {
      final decoded = jsonDecode(cachedData) as List;
      final cachedList = decoded
          .map((e) => ExploreChit.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      setState(() {
        exploreChitList = cachedList;
        isLoading = false;
      });
      print('📦 Loaded ${cachedList.length} explore chit records from cache');
    }

    // 🔹 2. Fetch latest data from API in background
    try {
      final url = Uri.parse(
          'https://foxlchits.com/api/ChitPayment/payment-history/${widget.chitId}/$userId');
      print('🌍 Fetching explore chit data: $url');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final freshList =
        data.map((e) => ExploreChit.fromJson(e)).toList();

        if (freshList.isNotEmpty) {
          await box.put(
            cacheKey,
            jsonEncode(freshList.map((e) => e.toJson()).toList()),
          );
          print('✅ Cached ${freshList.length} explore chit records');
        }

        if (mounted) {
          setState(() => exploreChitList = freshList);
        }
      } else {
        print('⚠️ API Error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching explore chit data: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  final chit_month = 20;
  final completed_chits = 6;
  double get totalPaid {
    return exploreChitList.fold(0.0, (sum, e) => sum + e.amountPaid);
  }
  String _formatDate(DateTime date) {
    // Example: 03rd Nov 25
    const suffixes = ["th", "st", "nd", "rd"];
    int day = date.day;
    String suffix = "th";

    if (day % 10 == 1 && day != 11) suffix = "st";
    else if (day % 10 == 2 && day != 12) suffix = "nd";
    else if (day % 10 == 3 && day != 13) suffix = "rd";

    String monthName = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ][date.month - 1];

    String shortYear = date.year.toString().substring(2);

    return "${day.toString().padLeft(2, '0')}$suffix $monthName $shortYear";
  }


  @override
  Widget build(BuildContext context) {
    // Find the first unpaid chit (i.e., next payment due)
    final ExploreChit? nextDue = exploreChitList.firstWhere(
          (chit) => chit.paid == false,
      orElse: () => exploreChitList.last, // fallback if all are paid
    );

    Size size = MediaQuery.of(context).size;
    double progress = exploreChitList.isNotEmpty
        ? exploreChitList.length / widget.timePeriod
        : 0;
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }
    if (exploreChitList.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'No explore chit data available.',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      );
    }

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
                //head
                Row(
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

                //chit details card
                Container(
                  height: 163,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF060D1D), Color(0xFF4982FF)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.04,
                      vertical: size.height * 0.015,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Chit Value : ₹${widget.chitValue.toString()}/-',
                              style: GoogleFonts.urbanist(
                                color: Color(0xffFFFFFF),
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${widget.timePeriod} Months',
                              style: GoogleFonts.urbanist(
                                color: Color(0xffFFFFFF),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: size.height * 0.015),
                        Text(
                          'Total Contribution till now : ₹${totalPaid.toStringAsFixed(2)}/-',
                          style: GoogleFonts.urbanist(
                            color: Color(0xffDDDDDD),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: size.height * 0.04),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progress',
                              style: GoogleFonts.urbanist(
                                color: Color(0xffDBDBDB),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${exploreChitList.length} of ${widget.timePeriod} months completed',
                              style: GoogleFonts.urbanist(
                                color: Color(0xffDBDBDB),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: size.height * 0.01),
                        // --- Gradient Progress Bar ---
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final width = constraints.maxWidth * progress;
                            return Container(
                              width: double.infinity,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Color(0xffE5E5E5),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Stack(
                                children: [
                                  // Blue Gradient Progress Fill
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 600),
                                    width: width,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF2196F3),
                                          Color(0xFF64B5F6),
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: size.height * 0.04),
                //chit scheme,auction result,receipt,t&C
                SizedBox(
                  height: size.height * 0.13,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: chit_scheme_to_TC_tags.length,
                    itemBuilder: (BuildContext, index) {
                      return Padding(
                        padding: EdgeInsets.only(
                          right: index == chit_scheme_to_TC_tags.length - 1
                              ? 0
                              : size.width * 0.045,
                        ),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        chit_scheme_to_TC_pages[index],
                                  ),
                                );
                              },
                              child: Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: Color(0xff3A7AFF),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Center(
                                  child: Image.asset(
                                    chit_scheme_to_TC_images[index],
                                    width: 24,
                                    height: 24,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: size.height * 0.01),
                            Text(
                              chit_scheme_to_TC_tags[index],
                              style: GoogleFonts.urbanist(
                                color: Color(0xffFFFFFF),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: size.height * 0.03),
                Container(
                  width: double.infinity,
                  height: 109,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [Color(0xff4770CB), Color(0xff000000)],
                    ),
                  ),
                  child: Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: size.width * 0.002,
                      vertical: size.height * 0.001,
                    ),
                    width: double.infinity,
                    height: 109,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Color(0xff000000),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.04,
                        vertical: size.height * 0.025,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'This month Contribution',
                            style: GoogleFonts.urbanist(
                              color: Color(0xffFFFFFF),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: size.height * 0.013),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                nextDue != null
                                    ? '₹${nextDue.howMuchToPay.toStringAsFixed(0)}/-'
                                    : '₹0/-',
                                style: GoogleFonts.urbanist(
                                  color: Color(0xffFFFFFF),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  // simulate payment process
                                  if (nextDue != null && nextDue.howMuchToPay > 0) {
                                    // ✅ After successful payment, set to 0
                                    await _loadExploreChitData(); // 🔁 Refresh API to get updated status
                                    // You can later call your POST API here for payment confirmation.
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Payment Successful!'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  width: 87,
                                  height: 25,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(11),
                                    color: Color(0xff3F60A9),
                                  ),

                                  child: Center(
                                    child: Text(
                                      nextDue == null
                                          ? 'Loading...'
                                          : (nextDue.howMuchToPay == 0 ? 'No Due' : 'Pay Due'),
                                      style: GoogleFonts.urbanist(
                                        color: Color(0xffFFFFFF),
                                        fontSize: 14,
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
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.03),
                Text(
                  'Breakdown of your Monthly Contribution',
                  style: GoogleFonts.urbanist(
                    color: Color(0xffFFFFFF),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: size.height * 0.01),
                Text(
                  'Starts from 03-11-2025 and Ends in 03-09-2025',
                  style: GoogleFonts.urbanist(
                    color: Color(0xff545454),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: size.height * 0.03),
                GridView.builder(
                  shrinkWrap: true,
                  // 👈 makes GridView take only needed height
                  physics: NeverScrollableScrollPhysics(),
                  // 👈 disables its scroll
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // Number of columns
                    crossAxisSpacing: 10, // Horizontal spacing between items
                    mainAxisSpacing: 10, // Vertical spacing between items
                    childAspectRatio: 1, // Width / Height ratio
                  ),
                  itemCount: widget.timePeriod,
                  itemBuilder: (BuildContext, index) {
                    String _ordinalSuffix(int number) {
                      if (number % 10 == 1 && number != 11) return "${number}st";
                      if (number % 10 == 2 && number != 12) return "${number}nd";
                      if (number % 10 == 3 && number != 13) return "${number}rd";
                      return "${number}th";
                    }

                    final isCompleted =
                        index < widget.timePeriod; // completed chits
                    ExploreChit? item =
                    index < exploreChitList.length ? exploreChitList[index] : null;
                    String paymentDate = item != null
                        ? _formatDate(item.paymentDate)
                        : 'Upcoming'; // fallback for future months
                    return Column(
                      children: [
                        Container(
                          width: 99,
                          height: 28,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: isCompleted
                                  ? [Color(0xff3A7AFF), Color(0xff4770CB)]
                                  : [
                                      Color(0xff3A7AFF).withOpacity(0.3),
                                      Color(0xff4770CB).withOpacity(0.3),
                                    ],
                            ),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(17),
                              topRight: Radius.circular(17),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              paymentDate,
                              style: GoogleFonts.urbanist(
                                color: isCompleted
                                    ? Color(0xffFFFFFF)
                                    : Color(0xffFFFFFF).withOpacity(0.3),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 99,
                          height: 74,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: isCompleted
                                  ? [Color(0xff313131), Color(0xff21242A)]
                                  : [
                                      Color(0xff313131).withOpacity(0.3),
                                      Color(0xff21242A).withOpacity(0.3),
                                    ],
                            ),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(17),
                              bottomRight: Radius.circular(17),
                            ),
                          ),
                          child: Column(
                            children: [
                              SizedBox(height: size.height * 0.025),
                              if (isCompleted)
                                Text(
                                  '₹${(item?.amountPaid ?? 0).toStringAsFixed(2)}',
                                  style: GoogleFonts.urbanist(
                                    color: (item?.amountPaid ?? 0) > 0
                                        ? const Color(0xffFFFFFF)
                                        : const Color(0xffFFFFFF).withOpacity(0.3),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              SizedBox(
                                height: size.height * 0.01

                              ),
                              Text(
                                'On ${_ordinalSuffix(index + 1)} Auction',
                                style: GoogleFonts.urbanist(
                                  color: isCompleted
                                      ? Color(0xff515151).withOpacity(1)
                                      : Color(0xff515151).withOpacity(0.3),
                                  fontSize: 8,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
