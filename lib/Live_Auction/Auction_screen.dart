import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user_app/Live_Auction/winner_screen_demo.dart';

import '../Services/secure_storage.dart';
import '../Services/websocket_service.dart';
import 'draw_auction_loading.dart';
import 'draw_for_loosers.dart';

class AuctionMessage {
  final String userName;
  final double amount;

  AuctionMessage({required this.userName, required this.amount});

  factory AuctionMessage.fromJson(Map<String, dynamic> json) {
    return AuctionMessage(
      userName: json['userName'] ?? json['bidder'] ?? 'Unknown',
      amount: (json['amount'] ?? 0).toDouble(),
    );
  }
}

class auction_screen extends StatefulWidget {
  final String myUserId;
  final String myUsername;
  final String chitId;
  final String chitName;
  final double chitValue;
  final double minBid;
  final double maxBid;
  final int  TotalUsers;

  const auction_screen({
    super.key,
    required this.myUserId,
    required this.myUsername,
    required this.chitId,
    required this.chitName,
    required this.chitValue,
    required this.minBid,
    required this.maxBid,
    required this. TotalUsers,
  });

  @override
  State<auction_screen> createState() => _auction_screenState();
}

class _auction_screenState extends State<auction_screen> {
  bool _showBackWarning = false;
  final ws = WebSocketService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<AuctionMessage> _messages = [];
  Timer? _auctionTimer;
  int _remainingSeconds = 60;
  Color _timerColor = const Color(0xff3A7AFF);
  String? _errorMessage;
  String? userId;
  int participantsCount = 0;
  List<String> maxBidders = [];
  bool isDrawInProgress = false;


  @override
  void initState() {
    super.initState();
    _loadUserData();
    ws.connect();

    // ✅ Re-register on join
    Future.delayed(const Duration(milliseconds: 500), () {
      final joinMsg = {
        "type": "JOIN",
        "userId": widget.myUserId,
        "userName": widget.myUsername,
        "chitId": widget.chitId.trim(),
      };
      ws.send(joinMsg);
      print("📡 Sent JOIN again from auction_screen: $joinMsg");
    });

    // ✅ Start listening
    ws.onMessage = (jsonData) => handleMessage(jsonData);
  }

  Future<void> _loadUserData() async {
    final id = await SecureStorageService.getUserId();
    setState(() => userId = id);
  }

  void handleMessage(Map<String, dynamic> jsonData) {
    switch (jsonData['type']) {
      case 'TIMER_START':
        setState(() => _remainingSeconds = jsonData['timeLeft'] ?? 120);
        startBidTimer();
        break;

      case 'TIMER_TICK':
        setState(() => _remainingSeconds = jsonData['timeLeft']);
        break;

      case 'NEW_BID':
        print("🔥 NEW_BID RECEIVED: $jsonData");
        final bidderName = jsonData['bidder'] ?? jsonData['userName'] ??
            'Unknown';
        final amount = (jsonData['amount'] as num?)?.toDouble() ?? 0.0;

        final isMaxBid = amount >= widget.maxBid;

        final bidMessage = AuctionMessage(userName: bidderName, amount: amount);
        setState(() {
          _messages.insert(0, bidMessage);
          if (isMaxBid && !maxBidders.contains(bidderName)) {
            maxBidders.add(bidderName);
          }
        });
        break;

      case 'USERS_JOINED':
        setState(() =>
        participantsCount = jsonData['count'] ?? participantsCount);
        break;

    // 🎯 Tie detected — move to draw loading screen
      case 'WINNER_TIE':
        print("🎲 Tie detected → ${jsonData['message']}");
        _showDrawScreen();
        break;

    // 🎯 Backend picked random winner
      case 'WINNER_RANDOM':
        print("🏁 Random winner selected: ${jsonData['winner']}");
        Future.delayed(const Duration(seconds: 3), () {
          navigateToWinnerFromBackend(jsonData);
        });
        break;

    // 🥇 Final winner decided — direct result
      case 'WINNER_FINAL':
        print("🥇 Final winner declared: ${jsonData['winner']}");
        if (!isDrawInProgress) {
          isDrawInProgress = true;
          Future.delayed(const Duration(seconds: 2), () {
            navigateToWinnerFromBackend(jsonData);
          });
        }
        break;

      default:
        print('[WS] Unknown: ${jsonData['type']}');
    }
  }


  void _showDrawScreen() {
    if (isDrawInProgress) return;
    isDrawInProgress = true;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            draw_auction_loading(
              chitName: widget.chitName,
              chitValue: widget.chitValue,
              userId: widget.myUserId,
              maxBidders: maxBidders,
              maxBid: widget.maxBid,
            ),
      ),
    );

    // Reset after 6 seconds so new navigation can occur
    Future.delayed(const Duration(seconds:10), () {
      isDrawInProgress = false;
    });
  }


  void startBidTimer() {
    _auctionTimer?.cancel();
    _auctionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      setState(() {
        _remainingSeconds--;
        if (_remainingSeconds <= 30) _timerColor = const Color(0xffC60F12);
        if (_remainingSeconds <= 0) {
          timer.cancel();
          _remainingSeconds = 0;
        }
      });
    });
  }

  void sendBid() {
    final text = _controller.text.trim();
    final bid = int.tryParse(text);

    if (bid == null || bid <= 0) {
      _showInlineError("Enter a valid bid");
      return;
    }
    if(bid < widget.minBid){
      _showInlineError("Please enter a Bid abouve or equal ${widget.minBid}");
      return;
    }
    if(bid > widget.maxBid){
      _showInlineError("Please enter a Bid Below or equal ${widget.maxBid}");
      return;
    }
    final msg = {
      "type": "BID",
      "chitId": widget.chitId.trim().toLowerCase(),
      "userId": widget.myUserId,
      "userName": widget.myUsername,
      "amount": bid,
    };
    ws.send(msg);
    _controller.clear();
  }

  void navigateToWinnerFromBackend(Map<String, dynamic> data) {
    final winnerUserId = data['winner'] ?? '';
    final winnerName = data['winnerName'] ?? data['winner'] ?? 'Unknown Winner';
    final amount = (data['amount'] as num?)?.toInt() ?? 0;

    print("🏆 Winner: $winnerName — ₹$amount");

    if (winnerUserId == widget.myUserId) {
      // 🥇 Current user is the winner
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              WinnerScreen(
                winnerName: winnerName,
                winnerBid: amount,
                chitName: widget.chitName,
                chitValue: widget.chitValue,
              ),
        ),
      );
    } else {
      // 😢 Not winner, show who won
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              draw_for_loosers(
                winnerName: winnerName,
                winnerBid: amount,
                chitName: widget.chitName,
                chitValue: widget.chitValue,
              ),
        ),
      );
    }
  }

  void _showInlineError(String message) {
    setState(() => _errorMessage = message);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _errorMessage = null);
    });
  }

  @override
  void dispose() {
    _auctionTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  bool get isLastMinute => _remainingSeconds <= 30;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;
    return WillPopScope(
      onWillPop: () async {
        // Show inline warning
        _showInlineError("You cannot go back until the auction is over.");
        return false; // prevent navigation
      },
      child: Scaffold(
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "₹${widget.chitName}",
                              style: GoogleFonts.urbanist(
                                textStyle: const TextStyle(
                                  color: Color(0xffE2E2E2),
                                  fontSize: 28,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(height: size.height * 0.002),
                            Text(
                              '$userId',
                              style: GoogleFonts.urbanist(
                                textStyle: const TextStyle(
                                  color: Color(0xffADADAD),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        width: 100,
                        height: 28,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(11),
                          color: Color(0xff353535),
                        ),

                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/images/Live_Auction/bid_on_live.png',
                                width: 31,
                                height: 31,
                              ),
                              Text(
                                'Bid on Live',
                                style: GoogleFonts.urbanist(
                                  textStyle: const TextStyle(
                                    color: Color(0xffFFFFFF),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              SizedBox(width: size.width * 0.01),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.02),
                  Row(
                    children: [
                      Container(
                        width: size.width * 0.46,
                        height: 53,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(11),
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: isLastMinute
                                ? [Color(0xffC60F12), Color(0xff440304)]
                                : [Color(0xff4285F4), Color(0xff223D76)],
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.002,
                            vertical: size.height * 0.001,
                          ),
                          child: Container(
                            width: 180,
                            height: 53,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(11),
                              color: isLastMinute
                                  ? Color(0xff483233)
                                  : Color(0xff323B48),
                            ),

                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    'assets/images/Live_Auction/bid_timer.png',
                                    color: isLastMinute
                                        ? Color(0xffC60F12)
                                        : Color(0xff3A7AFF),
                                    width: 17,
                                    height: 17,
                                  ),
                                  SizedBox(width: size.width * 0.01),
                                  Text(
                                    'Time Remaining : ${_remainingSeconds ~/
                                        60}:${(_remainingSeconds % 60)
                                        .toString()
                                        .padLeft(2, '0')}',
                                    style: GoogleFonts.urbanist(
                                      textStyle: TextStyle(
                                        color: isLastMinute
                                            ? Color(0xffC60F12)
                                            : Color(0xff3A7AFF),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Spacer(),
                      Container(
                        width: size.width * 0.46,
                        height: 53,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(11),
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Color(0xff4285F4), Color(0xff223D76)],
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.002,
                            vertical: size.height * 0.001,
                          ),
                          child: Container(
                            width: 180,
                            height: 53,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(11),
                              color: Color(0xff323B48),
                            ),

                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    'assets/images/Live_Auction/participants_blue.png',
                                    width: 17,
                                    height: 17,
                                  ),
                                  SizedBox(width: size.width * 0.01),
                                  Text(
                                    'Participants: $participantsCount/${widget
                                        .TotalUsers}',
                                    style: GoogleFonts.urbanist(
                                      textStyle: const TextStyle(
                                        color: Color(0xffFFFFFF),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
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
                  SizedBox(height: size.height * 0.04),
                  Container(
                    width: double.infinity,
                    height: 68,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(17),
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Color(0xff5081EC).withOpacity(.26),
                          Color(0xff8F20DE).withOpacity(.26),
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.04,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: size.height * 0.015),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/images/Live_Auction/current_leading.png',
                                width: 15,
                                height: 15,
                              ),
                              SizedBox(width: size.width * 0.01),
                              Text(
                                'Current Leading Bidder',
                                style: GoogleFonts.urbanist(
                                  textStyle: const TextStyle(
                                    color: Color(0xffB5B5B5),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: size.height * 0.003),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _messages.isNotEmpty
                                    ? '${_messages.first.userName}'
                                    : 'No bids yet',
                                style: GoogleFonts.urbanist(
                                  textStyle: const TextStyle(
                                    color: Color(0xffFFFFFF),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Spacer(),
                              Text(
                                _messages.isNotEmpty
                                    ? '₹ ${_messages.first.amount}'
                                    : '₹ 0',
                                style: GoogleFonts.urbanist(
                                  textStyle: const TextStyle(
                                    color: Color(0xffE2E2E2),
                                    fontSize: 17,
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
                  // 🔹 Show SnackBar Inline Between Containers
                  if (_errorMessage != null) ...[
                    SizedBox(height: size.height * 0.02),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: 1,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xffDFDFDF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/Live_Auction/alert.png',
                              width: 17,
                              height: 17,
                            ),
                            SizedBox(width: size.width * 0.02),
                            Flexible(
                              child: Text(
                                _errorMessage ?? '',
                                style: GoogleFonts.urbanist(
                                  textStyle: const TextStyle(
                                    color: Color(0xff717171),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  SizedBox(height: size.height * 0.02),

                  //chat space
                  Container(
                    width: double.infinity,
                    height: (_showBackWarning) ? 407 : 437,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(11),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xff3A7AFF), Color(0xff000000)],
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.002,
                        vertical: size.height * 0.001,
                      ),
                      child: Container(
                        width: double.infinity,
                        height: (_showBackWarning) ? 407 : 437,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(11),
                          color: Color(0xff121212),
                        ),

                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.03,
                            vertical: size.height * 0.03,
                          ),
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Recent Activities',
                                  style: GoogleFonts.urbanist(
                                    textStyle: const TextStyle(
                                      color: Color(0xffFFFFFF),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: size.height * 0.02),
                              Expanded(
                                child: ListView.builder(
                                  controller: _scrollController,
                                  reverse: true,
                                  itemCount: _messages.length,
                                  itemBuilder: (context, i) {
                                    final m = _messages[i];
                                    final isMe =
                                        m.userName.trim().toLowerCase() ==
                                            widget.myUsername
                                                .trim()
                                                .toLowerCase();
                                    final isMaxBid = m.amount == widget.maxBid;
                                    return Align(
                                      alignment: isMe
                                          ? Alignment.centerRight
                                          : Alignment.centerLeft,
                                      child: Container(
                                        margin: EdgeInsets.symmetric(
                                          vertical: 6,
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          border: isMaxBid
                                              ? Border.all(
                                            color: Color(0xff3A7AFF),
                                            width: 1.5,
                                          )
                                              : null,
                                          color: isMe
                                              ? Color(0xff3A7AFF)
                                              : Color(0xff505050),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          isMaxBid
                                              ? '${m.userName} - ₹${m
                                              .amount} Max limit Reached'
                                              : '${m.userName} - ₹${m.amount}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: size.height * 0.02),
                  Text(
                    "*Minimum Bed Starts from ₹${widget.minBid.toStringAsFixed(
                        0)}/- and Maximum ₹${widget.maxBid.toStringAsFixed(
                        0)}/-",
                    style: TextStyle(
                      color: Color(0xff989898),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          width: size.width * 0.5,
                          height: 43,
                          child: TextField(
                            style: TextStyle(
                              color: Color(0xffFFFFFF),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                            cursorColor: Color(0xffFFFFFF),
                            controller: _controller,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              filled: true,
                              // 👈 must enable to show background color
                              fillColor: const Color(0xff353535),

                              // 👈 background color
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              // 👇 Normal (unfocused) border
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0xff353535),
                                ),
                                borderRadius: BorderRadius.circular(11),
                              ),

                              // 👇 Focused border (when you tap on it)
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0xff353535),
                                ),
                                borderRadius: BorderRadius.circular(11),
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xff353535),
                                ),
                                borderRadius: BorderRadius.circular(11),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: size.width * 0.05),
                      GestureDetector(
                        onTap: sendBid,
                        child: Container(
                          width: 141,
                          height: 43,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(11),
                            color: Color(0xff3A7AFF),
                          ),

                          child: Center(
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    'assets/images/Live_Auction/add_bid.png',
                                    width: 20,
                                    height: 20,
                                  ),
                                  SizedBox(width: size.width * 0.02),
                                  Text(
                                    "Add Bid",
                                    style: TextStyle(
                                      color: Color(0xffFFFFFF),
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
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
      ),
    );
  }
}