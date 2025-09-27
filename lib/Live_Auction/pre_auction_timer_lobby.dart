import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user_app/Live_Auction/Auction_screen.dart';

class auction_timer_lobby extends StatefulWidget {
  const auction_timer_lobby({super.key});

  @override
  State<auction_timer_lobby> createState() => _auction_timer_lobbyState();
}

class _auction_timer_lobbyState extends State<auction_timer_lobby> {
  late DateTime auctionStartTime; // API provided auction start datetime
  Duration remainingTime = Duration.zero;
  Timer? countdownTimer;

  @override
  void initState() {
    super.initState();
    // Set a default auction datetime for now
    auctionStartTime = DateTime.now().add(Duration(minutes:1)); // Auction 1 minutes from now

    // Start countdown
    startCountdown();
  }

  void startCountdown() {
    countdownTimer = Timer.periodic(Duration(seconds: 1), (_) {
      final now = DateTime.now();
      // Calculate time until auction minus 30 seconds
      final targetTime = auctionStartTime.subtract(Duration(seconds: 30));
      setState(() {
        remainingTime = targetTime.difference(now);

        // If countdown reaches zero, navigate to auction screen
        if (remainingTime.inSeconds <= 0) {
          countdownTimer?.cancel();
          navigateToAuctionScreen();
        }
      });
    });
  }

  void navigateToAuctionScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => auction_screen(wsUrl: '', myUserId: '', myUsername: '',), // Replace with your auction screen
      ),
    );
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Color(0xff000000),
      body: Column(
        children: [
          SizedBox(height: size.height * 0.35),
          Image.asset(
            'assets/images/Live_Auction/auction_pre timer.png',
            width: 278,
            height: 176,
          ),
          SizedBox(height: size.height * 0.05),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Countdown: Auction begins in',
                  style: GoogleFonts.urbanist(
                    textStyle: const TextStyle(
                      color: Color(0xffBBBBBB),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(width: size.width * 0.02),
                Text(
                  formatDuration(remainingTime),
                  style: GoogleFonts.urbanist(
                    textStyle: const TextStyle(
                      color: Color(0xff3A7AFF),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: size.height * 0.25),
          Container(
            width: 199,
            height: 38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              color: Color(0xff959494).withOpacity(.23),
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/Live_Auction/participants.png',
                    width: 18,
                    height: 18,
                  ),
                  SizedBox(width: size.width * 0.02),
                  Text(
                    'Participants : 12/20',
                    style: GoogleFonts.urbanist(
                      textStyle: const TextStyle(
                        color: Color(0xffFFFFFF),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
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
  }
}
