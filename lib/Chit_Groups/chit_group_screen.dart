import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:user_app/Chit_Groups/requested_chit_notifier.dart';
import 'package:user_app/Chit_Groups/selected_chit_notifier.dart';
import 'package:user_app/Profile/setup_profile_screen.dart';

import '../Helper/Local_storage_manager.dart';
import '../Models/Chit_Groups/chit_groups.dart';
import '../Services/secure_storage.dart';
import 'package:shimmer/shimmer.dart';

class chit_groups extends StatefulWidget {
  Function(int)? onTabChange;

  chit_groups({super.key, this.onTabChange});

  @override
  State<chit_groups> createState() => _chit_groupsState();
}

class _chit_groupsState extends State<chit_groups> {
  Map<String, bool> _joinLoading = {};
  bool isKycLoading = true;
  bool isKycCompleted = false;
  int? _highlightChitIndex;
  String? profileId;
  final FlutterSecureStorage storage = FlutterSecureStorage();
  List<Chit_Group_Model>? _chits;
  bool _isLoadingChits = true;
  List<Chit_Group_Model>? _filteredChits;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;

      if (_chits != null && _chits!.isNotEmpty) {
        if (index == 0) {
          _filteredChits = List.from(_chits!); // All chits
        } else {
          final filterType = chitTypeTags[index];
          _filteredChits = _chits!
              .where(
                (c) => c.chitsType.toLowerCase() == filterType.toLowerCase(),
              )
              .toList();
        }
      }
    });

    // Delay slightly to ensure _filteredChits is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 50), () {
        _handleHighlight();
      });
    });

    if (widget.onTabChange != null) widget.onTabChange!(index);
  }

  @override
  void initState() {
    super.initState();
    RequestedChitNotifier.init(); // loads hive
    loadServerRequestedChits();  // sync server → local
    _loadKycStatus();
    _loadChitsWithCache();
  }


  Future<void> _loadChitsWithCache() async {
    final cached = LocalStorageManager.getActiveUpcomingChits();
    if (cached.isNotEmpty) {
      print('📦 Loaded ${cached.length} active-upcoming chits from Hive');
      setState(() {
        _chits = cached;
        _filteredChits = List.from(cached);
        _isLoadingChits = false;
      });
      _refreshChitsInBackground();
    } else {
      await _fetchChitsFromApi();
    }
  }

  Future<void> _fetchChitsFromApi() async {
    final Token = await SecureStorageService.getToken();
    try {
      final url = Uri.parse(
        'https://foxlchits.com/api/MainBoard/ChitsCreate/active-upcoming',

      );
      print("chit :$url");
      final response = await http.get(url, headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $Token",
      },);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final chits = data.map((e) => Chit_Group_Model.fromJson(e)).toList();

        await LocalStorageManager.saveActiveUpcomingChits(chits);

        setState(() {
          _chits = chits;
          _filteredChits = List.from(chits);
          _isLoadingChits = false;
        });

        print('✅ Active-Upcoming Chits fetched & cached (${chits.length})');
      } else {
        print('❌ API Error: ${response.statusCode}');
        setState(() => _isLoadingChits = false);
      }
    } catch (e) {
      print('⚠️ Error fetching chits: $e');
      setState(() => _isLoadingChits = false);
    }
  }

  Future<void> _refreshChitsInBackground() async {
    final Token = await SecureStorageService.getToken();
    try {
      final url = Uri.parse(
        'https://foxlchits.com/api/MainBoard/ChitsCreate/active-upcoming',
      );
      final response = await http.get(url, headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $Token",
      },);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final chits = data.map((e) => Chit_Group_Model.fromJson(e)).toList();
        await LocalStorageManager.saveActiveUpcomingChits(chits);
        print('🔄 Background cache refreshed (${chits.length} chits)');
      }
    } catch (e) {
      print('⚠️ Background refresh failed: $e');
    }
  }

  void _handleHighlight() {
    if (SelectedChitNotifier.selectedChitId == null || _filteredChits == null)
      return;

    // Get the current selectedChitId
    final selectedId = SelectedChitNotifier.selectedChitId!;

    // Find the index in the filtered list
    final indexInFiltered = _filteredChits!.indexWhere(
      (c) => c.id == selectedId,
    );

    if (indexInFiltered == -1) return; // Not in current filter

    // Highlight it
    setState(() => _highlightChitIndex = indexInFiltered);

    // Reset after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _highlightChitIndex = null;
        SelectedChitNotifier.selectedChitId = null; // now reset safely
      });
    });
  }

  int _selectedIndex = 0;

  Future<void> _loadKycStatus() async {
    final id = await storage.read(key: 'profileId');
    final Token = await SecureStorageService.getToken();

    if (id != null && id.isNotEmpty) {
      try {
        final response = await http.get(
          Uri.parse("https://foxlchits.com/api/Profile/profile/$id"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $Token",
          },
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final kyc = data['kycVerification'] ?? false;

          setState(() {
            isKycCompleted = kyc;
            isKycLoading = false;
          });

          print("✅ KYC Status: $kyc");
        } else {
          print("❌ Failed to load profile: ${response.statusCode}");
          setState(() => isKycLoading = false);
        }
      } catch (e) {
        print("⚠️ Error fetching profile: $e");
        setState(() => isKycLoading = false);
      }
    } else {
      print("⚠️ No stored profileId found");
      setState(() => isKycLoading = false);
    }
  }

  final List<String> chitTypeTags = ["All Chits", "Daily", "Weekly", "Monthly"];

  Future<void> _requestToJoinChit(String chitId) async {
    try {
      // Start loading
      setState(() {
        _joinLoading[chitId] = true;
      });

      final userId = await SecureStorageService.getUserId();
      final referId = await SecureStorageService.getReferId();
      final Token = await SecureStorageService.getToken();

      if (userId == null || userId.isEmpty) {
        showBlueSnack(context, "User info missing. Please login again.");
        setState(() {
          _joinLoading[chitId] = false;
        });
        return;
      }

      final Map<String, String> queryParams = {
        'chitId': chitId,
        'userID': userId,
      };

      if (referId != null && referId.isNotEmpty && referId != 'null') {
        queryParams['referId'] = referId;
      }

      final url = Uri.https(
        'foxlchits.com',
        '/api/JoinToChit/request-join',
        queryParams,
      );

      final response = await http.post(url, headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $Token",
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["status"] == "UserConfirmed") {
          showBlueSnack(context, data["message"]);
        } else {
          showBlueSnack(context, "Successfully requested to join!");
          RequestedChitNotifier.addRequestedChit({
            "chitsName": _filteredChits!
                .firstWhere((c) => c.id == chitId)
                .chitsName,
          });
        }
      }

    } catch (e) {
      showBlueSnack(context, "Something went wrong: $e");
    } finally {
      setState(() {
        _joinLoading[chitId] = false;
      });
    }
  }



  Future<void> loadServerRequestedChits() async {
    final userId = await SecureStorageService.getUserId();
    final Token = await SecureStorageService.getToken();

    final url = Uri.https(
      'foxlchits.com',
      '/api/JoinToChit/get-requests-by-user',
      {'userID': userId},
    );

    final response = await http.get(url, headers: {
      "Authorization": "Bearer $Token",
    });

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      for (var item in data) {
        RequestedChitNotifier.addRequestedChit({
          "chitsName": item["chitsName"],
        });
      }

      print("🔄 Synced requested chits from server: ${data.length}");
    }
  }


  void showBlueSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xff3A7AFF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              msg,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xff000000),
      body: SafeArea(
        child: RefreshIndicator(
          color: Colors.white,
          backgroundColor: const Color(0xff3A7AFF),
          onRefresh: () async {
            await _fetchChitsFromApi(); // 👈 Pull-to-refresh triggers live API
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(), // 👈 makes pull work even if content < screen height
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

                  // 🔹 Filter Chips
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

                  // 🔹 Shimmer / Empty / Chit List
                  if (_isLoadingChits)
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
                    )
                  else if (_filteredChits == null || _filteredChits!.isEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: size.width * 0.7),
                      child: Center(
                        child: Text(
                          'No chits available right now.',
                          style: GoogleFonts.urbanist(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    )
                  else
                    Column(
                      children: _filteredChits!.asMap().entries.map((entry) {
                        final index = entry.key;
                        final chit = entry.value;

                        return Padding(
                          padding: EdgeInsets.only(bottom: size.height * 0.02),
                          child: ChitCardDynamic(
                          chit: chit,
                          isHighlighted: _highlightChitIndex == index,
                          isKycCompleted: isKycCompleted,
                          isKycLoading: isKycLoading,
                          isJoinLoading: _joinLoading[chit.id] ?? false,
                        ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}

String getNextAuctionDate(List<dynamic> auctionDates) {
  if (auctionDates.isEmpty) return "N/A";

  DateTime now = DateTime.now();
  List<DateTime> parsedDates = [];

  // Handle both plain dates and objects like upcomingAuctions
  for (var d in auctionDates) {
    try {
      if (d is Map && d.containsKey('auctionDate')) {
        // ✅ Only include if not completed
        if (d['completed'] == false || d['completed'] == null) {
          parsedDates.add(DateTime.parse(d['auctionDate'].toString()));
        }
      } else {
        parsedDates.add(DateTime.parse(d.toString()));
      }
    } catch (_) {}
  }

  if (parsedDates.isEmpty) return "N/A";

  // Sort the dates in ascending order
  parsedDates.sort();

  // ✅ Find the first upcoming auction date (≥ today)
  for (var date in parsedDates) {
    if (!date.isBefore(DateTime(now.year, now.month, now.day))) {
      return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} "
          "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    }
  }

  // If all completed, return last available date
  final lastDate = parsedDates.last;
  return "${lastDate.year}-${lastDate.month.toString().padLeft(2, '0')}-${lastDate.day.toString().padLeft(2, '0')}";
}

List<String> getAuctionStartEndDates(
  List<dynamic>? auctionDates,
  String? dueDate,
) {
  // 🟦 1. Default empty return
  if (auctionDates == null || auctionDates.isEmpty) {
    // Start date = dueDate (if exists), End date empty
    return [dueDate ?? "", ""];
  }

  // 🟦 2. Parse all auction dates safely
  List<DateTime> parsedDates = [];
  for (var d in auctionDates) {
    try {
      parsedDates.add(DateTime.parse(d.toString()));
    } catch (_) {}
  }

  if (parsedDates.isEmpty) return [dueDate ?? "", ""];

  // 🟦 3. Sort dates
  parsedDates.sort();

  // 🟦 4. Take last auction date and add +1 month
  DateTime lastDate = parsedDates.last;
  DateTime endPlusOneMonth;

  // ✅ Safely handle month overflow (e.g., Jan 31 + 1 month → Feb 28)
  if (lastDate.month == 12) {
    endPlusOneMonth = DateTime(lastDate.year + 1, 1, lastDate.day);
  } else {
    int nextMonth = lastDate.month + 1;
    int nextYear = lastDate.year;

    // Handle shorter months
    int day = lastDate.day;
    int daysInNextMonth = DateTime(nextYear, nextMonth + 1, 0).day;
    if (day > daysInNextMonth) day = daysInNextMonth;

    endPlusOneMonth = DateTime(nextYear, nextMonth, day);
  }

  // 🟦 5. Format end date
  String end =
      "${endPlusOneMonth.year}-${endPlusOneMonth.month.toString().padLeft(2, '0')}-${endPlusOneMonth.day.toString().padLeft(2, '0')}";

  // 🟦 6. Start = chit.duedate
  return [dueDate ?? "", end];
}

class ChitCardDynamic extends StatelessWidget {
  final Chit_Group_Model chit;
  final bool isHighlighted;
  final bool isKycCompleted;
  final bool isKycLoading;

  final bool isJoinLoading;

  const ChitCardDynamic({
    super.key,
    required this.chit,
    required this.isHighlighted,
    required this.isKycCompleted,
    required this.isKycLoading,
    required this.isJoinLoading,
  });


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final dates = getAuctionStartEndDates(
      chit.auctionDates,
      chit.duedate is DateTime
          ? (chit.duedate as DateTime).toIso8601String().split('T').first
          : chit.duedate?.toString(),
    );
    // ✅ Compute status dynamically
    bool isRequested = RequestedChitNotifier.isRequested(chit.chitsName);
    String status = isRequested ? "Requested" : "Request to Join";

    return AnimatedContainer(
      width: double.infinity,
      height: size.height * 0.22,
      duration: const Duration(milliseconds: 100),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    chit.chitsName,
                    style: GoogleFonts.urbanist(
                      color: const Color(0xff3A7AFF),
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  chit.chitsType,
                  style: GoogleFonts.urbanist(
                    color: const Color(0xffB5B4B4),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: size.height * 0.01),
            _buildInfoRow(
              "Chit Value : ₹${chit.value.toStringAsFixed(0)}",
              "Mon.Contribution : ₹${chit.contribution.toStringAsFixed(0)}",
            ),
            _buildInfoRow("Start Date : ${dates[0]}", "End Date : ${dates[1]}"),
            _buildInfoRow(
              "Duration : ${chit.timePeriod.toStringAsFixed(0)}",
              'Total Members : ${chit.totalMember.toStringAsFixed(0)}',
            ),
            SizedBox(height: size.height * 0.025),
            Align(
              alignment: Alignment.bottomRight,
              child: GestureDetector(
                onTap: () async {
                  if (isKycLoading) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Checking profile, please wait..."),
                      ),
                    );
                    return;
                  }

                  if (!isKycCompleted) {
                    showKycDrawer(context);
                    return;
                  }

                  if (!isRequested) {
                    // ✅ Request the chit
                    final parentState = context
                        .findAncestorStateOfType<_chit_groupsState>();
                    if (parentState != null) {
                      await parentState._requestToJoinChit(chit.id);
                    }
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
                    child: isJoinLoading
                        ? SizedBox(
                      height: 14,
                      width: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: isRequested
                            ? Colors.white70
                            : Colors.black,
                      ),
                    )
                        : Text(
                      status,
                      style: GoogleFonts.urbanist(
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
              color: const Color(0xffF8F8F8),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            right,
            style: GoogleFonts.urbanist(
              color: const Color(0xffF8F8F8),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void showKycDrawer(BuildContext context) {
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
                      color: const Color(0xff6F6F6F),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(height: size.height * 0.03),
                  Image.asset(
                    'assets/images/Chit_Groups/kyc.png',
                    width: 101,
                    height: 131,
                  ),
                  SizedBox(height: size.height * 0.02),
                  const Text(
                    "Complete your profile and KYC to participate in\nchits or start investing.",
                    style: TextStyle(
                      color: Color(0xffFFFFFF),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: size.height * 0.03),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => setup_profile(),
                        ),
                      );
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
