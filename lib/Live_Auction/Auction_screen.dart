import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user_app/Live_Auction/winner_screen_demo.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'draw_for_loosers.dart';


// Minimal BidMessage model
class BidMessage {
  final String userId;
  final String username;
  final int bid;
  final DateTime timestamp;

  BidMessage({
    required this.userId,
    required this.username,
    required this.bid,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'username': username,
    'bid': bid,
    'timestamp': timestamp.toIso8601String(),
  };

  factory BidMessage.fromJson(Map<String, dynamic> json) => BidMessage(
    userId: json['userId'] as String,
    username: json['username'] as String,
    bid: (json['bid'] is int) ? json['bid'] : int.parse(json['bid'].toString()),
    timestamp: DateTime.parse(json['timestamp'] as String),
  );
}

class auction_screen extends StatefulWidget {
  final String wsUrl;
  final String myUserId;
  final String myUsername;

  const auction_screen({
    super.key,
    required this.wsUrl,
    required this.myUserId,
    required this.myUsername,
  });

  @override
  State<auction_screen> createState() => _auction_screenState();
}

class _auction_screenState extends State<auction_screen> {
  int participantsCount = 0;
  TextEditingController _controller = TextEditingController();
  final last_minute = true;
  bool _showBackWarning = false;
  String? _errorMessage; // 🔹 dynamic error message text

  // WebSocket setup
  late WebSocketChannel _channel;

  // List of messages/bids
  List<BidMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    connect();
  }

  // Call this whenever a new bid is received
  void startBidTimer() {
    _auctionTimer?.cancel(); // cancel previous timer if running
    setState(() {
      _remainingSeconds = 60;
      _timerColor = Color(0xff3A7AFF); // blue
    });

    _auctionTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!mounted) return;

      setState(() {
        _remainingSeconds--;

        if (_remainingSeconds <= 30) {
          _timerColor = Color(0xffC60F12); // red for last 30s
        }

        if (_remainingSeconds <= 0) {
          timer.cancel();
          _remainingSeconds = 0;
          // Auction round over, you can trigger winner logic here
        }
      });
    });
  }

  void navigateToWinner() {
    if (_messages.isEmpty) return;

    // Get the highest bid
    final winner = _messages.reduce((a, b) => a.bid > b.bid ? a : b);

    if (winner.userId == widget.myUserId) {
      // Current user is the winner
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              WinnerScreen(winnerName: winner.username, winnerBid: winner.bid),
        ),
      );
    } else {
      // Current user is NOT the winner
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const draw_for_loosers()),
      );
    }
  }

  //Listener
  bool _maxBidMessageShown = false;

  void connect() {
    try {
      _channel = IOWebSocketChannel.connect(widget.wsUrl);
      print('[WS] connecting to ${widget.wsUrl}');
      _channel.stream.listen((event) {
        final jsonData = jsonDecode(event);

        if (jsonData['type'] == 'BID') {
          final bidMessage = BidMessage.fromJson(jsonData);
          setState(() {
            _messages.insert(0, BidMessage.fromJson(jsonData));
          });
          if (bidMessage.bid >= 40000 && !_maxBidMessageShown) {
            _showInlineError("Maximum bid reached!");
            _maxBidMessageShown = true;
          }
        } else if (jsonData['type'] == 'TIMER_UPDATE') {
          setState(() {
            _remainingSeconds = jsonData['seconds'];
            _timerColor = (_remainingSeconds <= 30)
                ? Color(0xffC60F12)
                : Color(0xff3A7AFF);
          });
        } else if (jsonData['type'] == 'AUCTION_END') {
          navigateToWinner();
        } else if (jsonData['type'] == 'PARTICIPANTS_UPDATE') {
          setState(() {
            participantsCount = jsonData['count'];
          });
        }
      });
    } catch (e) {
      print('[WS] connect error: $e');
    }
  }

  void resetAuctionTimer() {
    _auctionTimer.cancel(); // stop previous timer
    _remainingSeconds = 60;
    _timerColor = const Color(0xff3A7AFF); // blue

    _auctionTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!mounted) return;

      setState(() {
        _remainingSeconds--;

        if (_remainingSeconds <= 30) {
          _timerColor = const Color(0xffC60F12); // red
        }

        if (_remainingSeconds <= 0) {
          timer.cancel();
          navigateToWinner();
        }
      });
    });
  }

  void sendBid() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      _showInlineError("Please enter a bid amount.");
      return;
    }

    final bid = int.tryParse(text);
    if (bid == null || bid <= 0) {
      _showInlineError("Please enter a valid number.");
      return;
    }

    // 🔹 Define min & max bid limits
    const minBid = 1000;
    const maxBid = 40000;

    // 🔹 Get the current highest (last) bid
    int? lastBid;
    if (_messages.isNotEmpty) {
      lastBid = _messages.first.bid;
    }

    // Normal bidding
    if (lastBid != null && lastBid < maxBid) {
      if (bid <= lastBid) {
        _showInlineError("Your bid must be higher than ₹$lastBid.");
        return;
      }
      if (bid > maxBid) {
        _showInlineError("Maximum bid is ₹$maxBid.");
        return;
      }
    }
    // Once max bid reached
    if (lastBid != null && lastBid >= maxBid && bid != maxBid) {
      _showInlineError("Only ₹$maxBid is allowed.");
      return;
    }

    // if (bid > maxBid) {
    //   _showInlineError("Maximum bid is ₹$maxBid.");
    //   return;
    // }

    // // 🧱 Must be higher than the last bid
    // if (lastBid != null && bid <= lastBid) {
    //   _showInlineError("Your bid must be higher than ₹$lastBid.");
    //   return;
    // }

    // Passed all checks → send bid
    final msg = {
      "type": "BID",
      "userId": widget.myUserId,
      "username": widget.myUsername,
      "bid": bid,
      "timestamp": DateTime.now().toIso8601String(),
    };

    _channel.sink.add(jsonEncode(msg));
    _controller.clear();
  }

  @override
  void dispose() {
    _auctionTimer.cancel();
    _channel.sink.close();
    _controller.dispose();
    super.dispose();
  }

  late Timer _auctionTimer;
  int _remainingSeconds = 60; // 1 minute
  Color _timerColor = Color(0xff3A7AFF); // initial blue
  bool get isLastMinute => _remainingSeconds <= 30;

  final isSystem = false;
  final isMe = true;
  final isMax = true;

  void _showInlineError(String message) {
    setState(() => _errorMessage = message);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _errorMessage = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
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
                              '₹2 Lakh Chit',
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
                              '#F025271',
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
                                    color: _timerColor,
                                    width: 17,
                                    height: 17,
                                  ),
                                  SizedBox(width: size.width * 0.01),
                                  Text(
                                    'Time Remaining : ${_remainingSeconds ~/ 60}:${(_remainingSeconds % 60).toString().padLeft(2, '0')}',
                                    style: GoogleFonts.urbanist(
                                      textStyle: TextStyle(
                                        color: _timerColor,
                                        // 🔹 changes automatically
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
                                    'Participants: $participantsCount/20',
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
                                    ? '${_messages.first.username} (#${_messages.first.userId})'
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
                                    ? '₹ ${_messages.first.bid}'
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
                                  reverse: true,
                                  itemCount: _messages.length,
                                  itemBuilder: (context, i) {
                                    final m = _messages[i];
                                    final isMe = m.userId == widget.myUserId;
                                    final isMaxBid = m.bid >= 40000;

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
                                              ? '${m.username} - ₹${m.bid} Max limit Reached'
                                              : '${m.username} - ₹${m.bid}',
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
                    "*Minimum Bed Starts from 1,000/- and Maximum 40,000/-",
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
