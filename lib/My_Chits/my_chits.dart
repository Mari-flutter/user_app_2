import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:user_app/Bottom_Navbar/bottom_navigation_bar.dart';
import 'package:user_app/My_Chits/Explore_chits/explore_chit_screen.dart';
import '../Helper/Local_storage_manager.dart';
import '../Models/My_Chits/active_chits_model.dart';
import '../Models/My_Chits/requested_chits_model.dart';
import '../Services/secure_storage.dart';
import 'package:shimmer/shimmer.dart';

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

  Future<Map<String, String?>> _getUserIds() async {
    final profileId = await SecureStorageService.getProfileId();
    final userId = await SecureStorageService.getUserId();

    // If userId is not yet stored, fetch it using your API updater
    if (userId == null || userId.isEmpty) {
      await SecureStorageService.updateUserAndReferIdsFromApi();
    }

    final refreshedUserId = await SecureStorageService.getUserId();

    return {'profileId': profileId ?? '', 'userId': refreshedUserId ?? ''};
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
                    ? FutureBuilder(
                        future: _getUserIds(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final ids = snapshot.data!;
                          return ActiveChitsPage(
                            profileId: ids['profileId'] ?? '',
                            userId: ids['userId'] ?? '',
                          );
                        },
                      )
                    : FutureBuilder(
                        future: _getUserIds(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final ids = snapshot.data!;
                          return RequestedChitsPage(
                            profileId: ids['profileId'] ?? '',
                            userId: ids['userId'] ?? '',
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ActiveChitsPage extends StatefulWidget {
  final String profileId;
  final String userId;

  const ActiveChitsPage({
    super.key,
    required this.profileId,
    required this.userId,
  });

  @override
  State<ActiveChitsPage> createState() => _ActiveChitsPageState();
}

class _ActiveChitsPageState extends State<ActiveChitsPage> {
  bool _isLoadedOnce = false;
  bool isLoading = true;
  List<ActiveChit> activeChits = [];

  @override
  void initState() {
    super.initState();
    if (!_isLoadedOnce) {
      _loadActiveChits();
      _isLoadedOnce = true;
    }
  }

  Future<void> _loadActiveChits() async {
    setState(() => isLoading = true);

    // 🔹 1. Load cached data instantly
    final cachedList = LocalStorageManager.getActiveChitsApi(widget.userId);
    if (cachedList.isNotEmpty) {
      setState(() {
        activeChits = cachedList;
        isLoading = false;
      });
      print('📦 Loaded ${cachedList.length} active chits from Hive cache');
    }

    // 🔹 2. Fetch latest from API in background
    try {
      final url = Uri.parse(
        "https://foxlchits.com/api/JoinToChit/profile/${widget.profileId}/chits?userID=${widget.userId}",
      );
      print('🌍 Active Chits API URL: $url');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final freshList = data.map((e) => ActiveChit.fromJson(e)).toList();

        if (freshList.isNotEmpty) {
          await LocalStorageManager.saveActiveChitsApi(
            freshList,
            widget.userId,
          );
          print('✅ Cached ${freshList.length} active chits to Hive');

          if (mounted) {
            setState(() => activeChits = freshList);
            print(activeChits);
          }
        }
      } else {
        print('⚠️ API error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Exception while fetching active chits: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (isLoading) {
      Column(
        children: List.generate(5, (index) {
          return Shimmer.fromColors(
            baseColor: const Color(0xff2A2A2A),
            highlightColor: const Color(0xff3A3A3A),
            child: Container(
              width: double.infinity,
              height: size.height * 0.22,
              margin: EdgeInsets.only(bottom: size.height * 0.02),
              decoration: BoxDecoration(
                color: const Color(0xff2A2A2A),
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          );
        }),
      );
    }
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
                  height: size.height * 0.21,
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
                              chit.chitsName,
                              style: GoogleFonts.urbanist(
                                textStyle: const TextStyle(
                                  color: Color(0xff3A7AFF),
                                  fontSize: 28,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              chit.chitsType,
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

                        // Info Rows
                        _buildInfoRow(
                          "Chit Value : ₹${chit.value.toStringAsFixed(0)}",
                          "Mon.Contribution : ₹${chit.contribution.toStringAsFixed(0)}",
                        ),
                        _buildInfoRow(
                          "Total Members : ${chit.members.length}",
                          "Joined : ${chit.currentMemberCount}/${chit.members.length}",
                        ),
                        _buildInfoRow(
                          "Duration : ${chit.timePeriod} months",
                          "Due Date : ${chit.duedate.toLocal().toString().split(' ')[0]}",
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
  final String profileId;
  final String userId;

  const RequestedChitsPage({
    super.key,
    required this.profileId,
    required this.userId,
  });

  @override
  State<RequestedChitsPage> createState() => _RequestedChitsPageState();
}

class _RequestedChitsPageState extends State<RequestedChitsPage> {
  bool _isLoadedOnce = false;

  List<RequestedChitModel> requestedChits = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    if (!_isLoadedOnce) {
      _loadRequestedChits();
      _isLoadedOnce = true;
    }
  }

  Future<void> _loadRequestedChits() async {
    setState(() => isLoading = true);

    // 🔹 1. Load cached data immediately (no spinner delay)
    final cachedList = LocalStorageManager.getRequestedChitsApi();
    if (cachedList.isNotEmpty) {
      setState(() {
        requestedChits = cachedList
            .map((e) => RequestedChitModel.fromJson(e))
        // 🚫 Skip "UserConfirmed" chits from cache
            .where((chit) => chit.status.toLowerCase() != 'userconfirmed')
            .toList();
        isLoading = false;
      });
      print(
        '📦 Loaded ${requestedChits.length} requested chits from Hive cache',
      );
    }

    // 🔹 2. Fetch from API in background
    try {
      final url = Uri.parse(
        "https://foxlchits.com/api/JoinToChit/${widget.profileId}/requests?userID=${widget.userId}",
      );
      print(url);
      final response = await http.get(url);
      print(response);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final freshList = data
            .map((json) => RequestedChitModel.fromJson(json))
        // 🚫 Hide chits with status == "UserConfirmed"
            .where((chit) => chit.status.toLowerCase() != 'userconfirmed')
            .toList();

        // If data differs, update Hive and UI
        if (freshList.isNotEmpty) {
          await LocalStorageManager.saveRequestedChitsApi(
            freshList.map((e) => e.toJson()).toList(),
          );
          print('✅ Cached requested chits (${freshList.length}) to Hive');

          // Update state only if list changed
          if (mounted) {
            setState(() => requestedChits = freshList);
          }
        }
      } else {
        print('⚠️ API error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Exception while fetching chits: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    if (isLoading) {
      Column(
        children: List.generate(5, (index) {
          return Shimmer.fromColors(
            baseColor: const Color(0xff2A2A2A),
            highlightColor: const Color(0xff3A3A3A),
            child: Container(
              width: double.infinity,
              height: size.height * 0.22,
              margin: EdgeInsets.only(bottom: size.height * 0.02),
              decoration: BoxDecoration(
                color: const Color(0xff2A2A2A),
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          );
        }),
      );
    }
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
          final bool isPending = chit.status.toLowerCase() !=( "mainboardapproved" )&& chit.status.toLowerCase() !=( 'userconfirmed');
          final String statusLabel = isPending ? "Requested" : "Aproved";

          return Padding(
            padding: EdgeInsets.only(bottom: size.height * 0.02),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: size.height * 0.21,
                  decoration: BoxDecoration(
                    borderRadius: isPending
                        ? BorderRadius.only(
                            topLeft: Radius.circular(25),
                            topRight: Radius.circular(25),
                          )
                        : BorderRadius.circular(25),
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
                        // Title + Type
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              chit.chitsName,
                              style: GoogleFonts.urbanist(
                                textStyle: const TextStyle(
                                  color: Color(0xff3A7AFF),
                                  fontSize: 28,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              chit.chitsType,
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
                          "Chit Value : ₹${chit.value.toStringAsFixed(0)}",
                          "Mon.Contribution : ₹${chit.contribution.toStringAsFixed(0)}/-",
                        ),
                        _buildInfoRow(
                          "Duration : ${chit.timePeriod} months",
                          "Requested Date : ₹${chit.requestDate.toLocal().toString().split(' ')[0]}",
                        ),
                        // _buildInfoRow(
                        //   "Total Members : ${chit.members.length}",
                        //   "Added Members: ${chit.currentMemberCount.toStringAsFixed(0)}/${chit.members.length}",
                        // ),
                        _buildInfoRow(
                          "Status : ${chit.status}",
                          "Due Date : ${chit.duedate.toLocal().toString().split(' ')[0]}",
                        ),

                        SizedBox(height: size.height * 0.01),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (!isPending)
                              Container(
                                width: 100,
                                height: 24,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(7),
                                  color: const Color(0xffFFFFFF),
                                ),
                                child: Center(
                                  child: Text(
                                    'Pay Due',
                                    style: GoogleFonts.urbanist(
                                      textStyle: TextStyle(
                                        color: const Color(0xff000000),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            SizedBox(width: size.width * 0.02),
                            Container(
                              width: 100,
                              height: 24,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(7),
                                color: isPending
                                    ? const Color(0xff626262)
                                    : const Color(0xff3fea96),
                              ),
                              child: Center(
                                child: Text(
                                  statusLabel,
                                  style: GoogleFonts.urbanist(
                                    textStyle: TextStyle(
                                      color: isPending
                                          ? const Color(0xffC4C4C4)
                                          : const Color(0xff000000),
                                      fontSize: 12,
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

                // Grey note section
                if (isPending)
                  Container(
                    width: double.infinity,
                    height: 40,
                    decoration: const BoxDecoration(
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
