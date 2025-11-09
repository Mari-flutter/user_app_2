import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user_app/Live_Auction/winner_screen_demo.dart';

import '../Services/websocket_service.dart';
import 'draw_for_loosers.dart';

class draw_auction_loading extends StatefulWidget {
  final String chitName;
  final double chitValue;
  final String userId;
  final List<String> maxBidders;
  final double maxBid;

  const draw_auction_loading({
    super.key,
    required this.chitName,
    required this.chitValue,
    required this.userId,
    required this.maxBidders,
    required this.maxBid,
  });

  @override
  State<draw_auction_loading> createState() => _draw_auction_loadingState();
}

class _draw_auction_loadingState extends State<draw_auction_loading> {
  final ws = WebSocketService();
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _listenForWinnerUpdates();
  }

  void _listenForWinnerUpdates() {
    ws.connect();
    ws.onMessage = (data) {
      if (_navigated) return; // prevent duplicate navigation

      print("📩 [DRAW_SCREEN] WS Message: $data");

      if (data['type'] == 'WINNER_RANDOM' || data['type'] == 'WINNER_FINAL') {
        _navigated = true;
        final winnerUserId = data['winner'] ?? '';
        final winnerName = data['winnerName'] ?? data['winner'] ?? 'Unknown';
        final amount = (data['amount'] as num?)?.toInt() ?? 0;

        // 🎯 Small suspense delay for smooth animation feel
        Future.delayed(const Duration(seconds: 3), () {
          if (winnerUserId == widget.userId) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => WinnerScreen(
                  winnerName: winnerName,
                  winnerBid: amount,
                  chitName: widget.chitName,
                  chitValue: widget.chitValue,
                ),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => draw_for_loosers(
                  winnerName: winnerName,
                  winnerBid: amount,
                  chitName: widget.chitName,
                  chitValue: widget.chitValue,
                ),
              ),
            );
          }
        });
      }
    };
  }

  @override
  Widget build(BuildContext context) {
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
                            '${widget.userId}',
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
                SizedBox(height: size.height * 0.04),
                Container(
                  width: double.infinity,
                  height: 35,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: Color(0xffDFDFDF),
                  ),

                  child: Center(
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
                            'You cannot go back until the auction is over.',
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
                Stack(
                  children: [
                    Image.asset(
                      'assets/images/Live_Auction/draw_gif.gif',
                      width: 362,
                      height: 398,
                    ),
                    Positioned(
                      left: size.width * 0.1,
                      bottom: 0,
                      child: Column(
                        children: [
                          Center(
                            child: Text(
                              'Draw in Progress..',
                              style: GoogleFonts.urbanist(
                                textStyle: const TextStyle(
                                  color: Color(0xffFFFFFF),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: size.height * 0.01),
                          Center(
                            child: Text(
                              'Randomly selecting the winner from tied participants',
                              style: GoogleFonts.urbanist(
                                textStyle: const TextStyle(
                                  color: Color(0xff555555),
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
                  ],
                ),
                SizedBox(height: size.height * 0.1),
                Container(
                  width: double.infinity,
                  height: 165,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(17),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Color(0xff03DF96).withOpacity(.26),
                        Color(0xff8F20DE).withOpacity(.26),
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.045,
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
                              'Maximum Bid Reachers',
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
                        SizedBox(height: size.height * 0.004),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: List.generate(
                                widget.maxBidders.length,
                                    (index) => Padding(
                                  padding: EdgeInsets.only(bottom: size.height * 0.002),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        widget.maxBidders[index],
                                        style: GoogleFonts.urbanist(
                                          textStyle: const TextStyle(
                                            color: Color(0xffFFFFFF),
                                            fontSize: 17,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        '₹ ${widget.maxBid.toStringAsFixed(0)}',
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
          ),
        ),
      ),
    );
  }
}
