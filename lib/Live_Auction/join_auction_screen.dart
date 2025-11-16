import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../Bottom_Navbar/bottom_navigation_bar.dart';
import '../Models/My_Chits/active_chits_model.dart';
import '../Services/secure_storage.dart';
import '../Services/websocket_service.dart';
import 'auction_screen.dart';
import 'package:shimmer/shimmer.dart';


class join_auction extends StatefulWidget {
  const join_auction({super.key});

  @override
  State<join_auction> createState() => _join_auctionState();
}

class _join_auctionState extends State<join_auction> {
  ActiveChit? selectedChit; // ✅ Store which chit user joined
  final ws = WebSocketService(); // ✅ shared instance
  bool _isLoading = true;
  String auctionStatusMessage = '';
  int countdownSeconds = 0;
  bool canJoinNow = false;
  String formattedCountdown = '';
  String? currentChitId;
  String? joiningChitId;


  String? userName;
  String? userId;
  String? profileId;
  List<ActiveChit> allChits = [];

  @override
  void initState() {
    super.initState();
    _loadUserDataAndChits();

    // ✅ Connect only once — shared across screens
    ws.connect();

    ws.onMessage = (data) {
      print("📩 WS Message (${data['type']}): $data");

      switch (data['type']) {
        case 'AUCTION_ACTIVE':
          print("🚨 Auction Active!");
          if (mounted && selectedChit != null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => auction_screen(
                  myUserId: userId ?? '',
                  myUsername: userName ?? '',
                  chitId: currentChitId ?? '',
                  chitName: selectedChit!.chitsName,
                  chitValue: selectedChit!.value,
                  minBid: selectedChit!.miniumBid,
                  maxBid: selectedChit!.maximumBid,
                  TotalUsers:selectedChit!.totalMember,
                ),
              ),
            );
          } else {
            print("⚠️ selectedChit is null — auction triggered too early.");
          }
          break;


        case 'TIMER_TICK':
          final timeLeft = data['timeLeft'] ?? 0;
          print("⏱ Remaining Time: $timeLeft seconds");
          setState(() {
            countdownSeconds = timeLeft;
            formattedCountdown = _formatDuration(Duration(seconds: timeLeft));
          });
          if (timeLeft == 0) {
            setState(() => canJoinNow = true);
          }
          break;

        case 'AUCTION_STATUS':
          final msg = data['message'] ?? '';
          print("📢 Auction Status: $msg");
          setState(() => auctionStatusMessage = msg);
          break;

        case 'ERROR':
          print("⚠️ WS Error: ${data['message']}");
          _showSnackBar(data['message'] ?? 'Something went wrong');
          break;
        case 'AUCTION_COUNTDOWN':
          final msg = data['message'] ?? 'Auction starting soon...';
          final timeLeft = data['timeLeftToStart'] ?? '--:--';
          print("⏳ Auction Countdown: $msg (Time left: $timeLeft)");
          setState(() {
            auctionStatusMessage = msg;
          });
          break;


        default:
          print("ℹ️ Ignored WS type: ${data['type']}");
      }
    };
  }

  Future<void> _loadUserDataAndChits() async {
    final name = await SecureStorageService.getUserName();
    final id = await SecureStorageService.getUserId();
    final profile = await SecureStorageService.getProfileId();

    setState(() {
      userName = name;
      userId = id;
      profileId = profile;
    });

    await _fetchActiveChits();
  }

  Future<void> _fetchActiveChits() async {
    final Token = await SecureStorageService.getToken();
    try {
      final url = Uri.parse(
        "https://foxlchits.com/api/JoinToChit/profile/$profileId/chits?userID=$userId",
      );
      final response = await http.get(url,headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $Token",
      },);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final chits = data.map((e) => ActiveChit.fromJson(e)).toList();
        setState(() => allChits = chits);
      }
    } catch (e) {
      print('❌ Exception fetching chit: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _joinAuction(ActiveChit chit) async {
    if (currentChitId != null && currentChitId == chit.id) {
      String msg = "Already joined this chit Auction please wait untill the countdown will start";
      _showSnackBar(msg);
      print("⚠️ Already joined this chit — skipping duplicate join");
      return;
    }

    if (userId == null || userName == null) {
      _showSnackBar('Missing user data');
      return;
    }
    setState(() {
      joiningChitId = chit.id; // Set the ID of the chit we are joining/waiting for
    });

    final chitId = chit.id;
    final normalizedChitId = chitId.trim().toLowerCase();

    final joinData = {
      "type": "JOIN",
      "userId": userId,
      "userName": userName,
      "chitId": normalizedChitId,
    };
    print("🚀 Sending JOIN: $joinData");
    print("🪄 Joining chit: $normalizedChitId");

    ws.send(joinData);
    currentChitId = chit.id;
    selectedChit = chit; // ✅ Remember this chit for auction

    await Future.delayed(const Duration(seconds: 1));
  }




  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatDuration(Duration d) {
    int days = d.inDays;
    int hours = d.inHours.remainder(24);
    int minutes = d.inMinutes.remainder(60);
    int seconds = d.inSeconds.remainder(60);

    if (days > 0) return "${days}d ${hours}h ${minutes}m ${seconds}s";
    if (hours > 0) return "${hours}h ${minutes}m ${seconds}s";
    if (minutes > 0) return "${minutes}m ${seconds}s";
    return "${seconds}s";
  }

  @override
  void dispose() {
    // ❌ Do NOT close socket here (it’s shared)
    super.dispose();
  }
  Widget _buildShimmerCard(Size size) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade900.withOpacity(0.25),
      highlightColor: Colors.grey.shade700.withOpacity(0.4),
      period: const Duration(seconds: 2),
      child: Container(
        width: double.infinity,
        height: 220,
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: const Color(0xff1B3977).withOpacity(0.5),
            width: 0.5,
          ),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xff1C2A48), // darker top
              Color(0xff0D111A), // almost black bottom
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(size.height * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 14, width: 120, color: Colors.grey.shade800), // title
              SizedBox(height: size.height * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(height: 20, width: 100, color: Colors.grey.shade800), // amount
                  Container(height: 15, width: 60, color: Colors.grey.shade800), // chit type
                ],
              ),
              SizedBox(height: size.height * 0.03),
              Container(height: 10, width: 180, color: Colors.grey.shade800),
              SizedBox(height: size.height * 0.03),
              Container(height: 10, width: 220, color: Colors.grey.shade800),
              const Spacer(),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 28,
                  width: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xff000000),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(size.height * 0.02),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: _isLoading
                ? Column(
              children: [
                SizedBox(height: size.height * 0.02),
                _buildShimmerCard(size),
                _buildShimmerCard(size),
                _buildShimmerCard(size),
              ],
            )
                : Column(
              children: [
                Row(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomeLayout(),
                          ),
                        ),
                        child: Image.asset(
                          'assets/images/My_Chits/back_arrow.png',
                          width: 24,
                          height: 24,
                        ),
                      ),
                    ),
                    SizedBox(width: size.width * 0.02),
                    Text(
                      'Join Live Auction',
                      style: GoogleFonts.urbanist(
                        textStyle: const TextStyle(
                          color: Color(0xffFFFFFF),
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.02),
                if (auctionStatusMessage.isNotEmpty)
                  AnimatedGradientBorder(text: auctionStatusMessage),
                SizedBox(height: size.height * 0.02),
                Expanded(
                  child: allChits.isEmpty
                      ? const Center(
                    child: Text(
                      "No active chits available.",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                      : ListView.builder(
                    itemCount: allChits.length,
                    itemBuilder: (context, index) {
                      final chit = allChits[index];
                      return _buildChitCard(chit, size);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChitCard(ActiveChit chit, Size size) {
    final isWaitingToJoin = joiningChitId == chit.id;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        width: 316,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xff1B3977), width: 0.5),
          borderRadius: BorderRadius.circular(11),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xff3A7AFF), Color(0xff000000)],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(size.height * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                chit.chitsName,
                style: GoogleFonts.urbanist(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: const Color(0xFFB5B4B4),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "₹${chit.value.toStringAsFixed(0)}",
                    style: GoogleFonts.urbanist(
                      fontWeight: FontWeight.w600,
                      fontSize: 22,
                      color: const Color(0xFFD7D7D7),
                    ),
                  ),
                  Text(
                    chit.chitsType,
                    style: GoogleFonts.urbanist(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: const Color(0xFFB5B4B4),
                    ),
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.025),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'User Id',
                        style: GoogleFonts.urbanist(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: const Color(0xFFB5B4B4),
                        ),
                      ),
                      Text(
                        '$userId',
                        style: GoogleFonts.urbanist(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: const Color(0xFFB5B4B4),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: size.width * 0.15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'User Name',
                        style: GoogleFonts.urbanist(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: const Color(0xFFB5B4B4),
                        ),
                      ),
                      Text(
                        '$userName',
                        style: GoogleFonts.urbanist(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: const Color(0xFFB5B4B4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.025),
              Text(
                'Note: Once you join the auction, you cannot go back. After the auction is completed, you will be redirected to the home page.',
                style: GoogleFonts.urbanist(
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                  color: const Color(0xFFB5B4B4),
                ),
              ),
              SizedBox(height: size.height * 0.1),
              Center(
                child: GestureDetector(
                  onTap: isWaitingToJoin ? null : () => _joinAuction(chit),
                  child: Text(
                      isWaitingToJoin ? "Please Wait..." : "Join Auction >",
                    style: GoogleFonts.urbanist(
                      textStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        foreground: Paint()
                          ..shader = LinearGradient(
                            colors: [
                              Color(0xFFF7F7F7),
                              Color(0xFF919191),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                      )
                    )
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class AnimatedGradientBorder extends StatefulWidget {
  final String text;

  const AnimatedGradientBorder({super.key, required this.text});

  @override
  State<AnimatedGradientBorder> createState() => _AnimatedGradientBorderState();
}

class _AnimatedGradientBorderState extends State<AnimatedGradientBorder>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: 43,
          padding: EdgeInsets.all(2), // Border thickness
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            gradient: SweepGradient(
              colors: [
                Color(0xff000000),
                Color(0xff001648),
                Color(0xff3A7AFF),
              ],
              stops: [0.0, 0.5, 1.0],
              transform: GradientRotation(_controller.value * 6.28),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                Color(0xff0E0E0E),
                Color(0xff101010),
              ]),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Center(
              child: Text(
                widget.text,
                style: GoogleFonts.urbanist(
                  color: Color(0xffFFFFFF),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}