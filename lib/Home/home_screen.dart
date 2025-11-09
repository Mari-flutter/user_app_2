import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user_app/Home_Page_User_Chits_Breakdown/history_screen.dart';
import 'package:user_app/Investments/Gold/gold_investment_screen.dart';
import 'package:user_app/Investments/Real_Estate/real_estate_investment_screen.dart';
import 'package:user_app/Live_Auction/join_auction_screen.dart';
import 'package:user_app/My_Chits/my_chits.dart';
import 'package:user_app/My_Investments/my_investments_screen.dart';
import 'package:user_app/Notification/notification_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../Helper/Local_storage_manager.dart';
import '../Models/Chit_Groups/chit_groups.dart';

class home extends StatefulWidget {
  final Function(int) onTabChange;

  const home({super.key, required this.onTabChange});

  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> with AutomaticKeepAliveClientMixin {
  late Future<void> _initFuture;
  late Future<List<Chit_Group_Model>> chitFuture;
  final storage = FlutterSecureStorage();
  String? profileId;

  List<Chit_Group_Model>? _cachedChits;
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => true; // keeps state alive

  @override
  void initState() {
    super.initState();
    _initFuture = _initialize();
  }

  Future<void> _initialize() async {
    await _loadProfileId();
    await _loadChits();
  }

  Future<void> _loadProfileId() async {
    profileId = await storage.read(key: 'profileId');
    print('ProfileId: $profileId');
  }

  Future<void> _loadChits() async {
    // Load cached data first
    final cached = LocalStorageManager.getChits();
    if (cached != null && cached.isNotEmpty) {
      _cachedChits = cached;
      setState(() => _isLoading = false);
      // silently fetch new data from API in the background
      _refreshChits();
    } else {
      // No cache, fetch from API
      try {
        final chits = await _fetchFromApi();
        _cachedChits = chits;
      } catch (e) {
        print('Failed to fetch chits: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _refreshChits() async {
    try {
      final chits = await _fetchFromApi();
      if (!listEquals(_cachedChits, chits)) {
        // only update if new data is different
        _cachedChits = chits;
        await LocalStorageManager.saveChits(chits);
        setState(() {}); // update UI
      }
    } catch (e) {
      print('Silent refresh failed: $e');
    }
  }

  Future<List<Chit_Group_Model>> _fetchFromApi() async {
    final url = Uri.parse(
      'https://foxlchits.com/api/MainBoard/ChitsCreate/all',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      final chits = jsonData.map((e) => Chit_Group_Model.fromJson(e)).toList();
      await LocalStorageManager.saveChits(chits);
      return chits;
    } else {
      throw Exception('Failed to load chits from API');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auction_status = true;
    Size size = MediaQuery.of(context).size;
    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(color: Color(0xff4770CB)),
          )
        : Scaffold(
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                            Positioned(
                              top: size.height * 0.03,
                              right: size.width * 0.03,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          History(initialTab: 3),
                                    ),
                                  );
                                },
                                child: Image.asset(
                                  'assets/images/Home/pending dues.png',
                                  width: 74,
                                  height: 23,
                                ),
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
                                padding: EdgeInsets.only(
                                  left: size.width * 0.02,
                                ),
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
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      my_investments(initialTab: 0),
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
                                padding: EdgeInsets.only(
                                  left: size.width * 0.02,
                                ),
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
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => join_auction(),
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
                                    padding: EdgeInsets.only(
                                      left: size.width * 0.02,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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

                      if (_cachedChits != null && _cachedChits!.isNotEmpty)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              // Map each chit
                              ..._cachedChits!.map((chit) {
                                return GestureDetector(
                                  onTap: () {
                                    widget.onTabChange(
                                      1,
                                    );// navigate to Chit Groups tab
                                  },
                                  child: Container(
                                    width: 185,
                                    height: size.height * 0.106,
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      image: const DecorationImage(
                                        image: AssetImage(
                                          'assets/images/Home/Home_screen_main card_1.jpg',
                                        ),
                                        fit: BoxFit.fill,
                                      ),
                                      borderRadius: BorderRadius.circular(11),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: size.width * 0.030,
                                        vertical: size.height * 0.009,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '₹ ${chit.chitsName}',
                                            style: GoogleFonts.urbanist(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 18,
                                            ),
                                          ),
                                          SizedBox(height: size.height * 0.001),
                                          Text(
                                            'Total Members: ${chit.totalMember}',
                                            style: GoogleFonts.urbanist(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 10,
                                            ),
                                          ),
                                          Text(
                                            'Duration: ${chit.timePeriod} Months',
                                            style: GoogleFonts.urbanist(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 10,
                                            ),
                                          ),
                                          Text(
                                            'Monthly Contribution: ₹ ${chit.contribution.toStringAsFixed(0)}/-',
                                            style: GoogleFonts.urbanist(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),

                              // View More button
                              GestureDetector(
                                onTap: () => widget.onTabChange(1),
                                child: Container(
                                  width: 44,
                                  height: 88,
                                  margin: const EdgeInsets.only(right: 12),
                                  decoration: BoxDecoration(
                                    image: const DecorationImage(
                                      image: AssetImage(
                                        'assets/images/Home/Home_screen_main card_1.jpg',
                                      ),
                                      fit: BoxFit.fill,
                                    ),
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
                                            color: Colors.white,
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
                              ),
                            ],
                          ),
                        )
                      else
                        Text(
                          'No chits available right now.',
                          style: GoogleFonts.urbanist(
                            color: Colors.white70,
                            fontSize: 14,
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      gold_investment(initialTab: 0),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  size.width * 0.03,
                                ),
                                gradient: const LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Color(0xff666666),
                                    Color(0xff000000),
                                  ],
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
                                    padding: EdgeInsets.only(
                                      left: size.width * 0.02,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      real_estate_investment(),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  size.width * 0.03,
                                ),
                                gradient: const LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Color(0xff666666),
                                    Color(0xff000000),
                                  ],
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
                                    padding: EdgeInsets.only(
                                      left: size.width * 0.02,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
