import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user_app/Live_Auction/Attach_files/attach_file_screen.dart';

import '../Services/secure_storage.dart';

class WinnerScreen extends StatefulWidget {
  final String winnerName;
  final int winnerBid;
  final String chitName;
  final double chitValue;

  const WinnerScreen({
    super.key,
    required this.winnerName,
    required this.winnerBid,
    required this.chitName,
    required this.chitValue,
  });

  @override
  State<WinnerScreen> createState() => _WinnerScreenState();
}

class _WinnerScreenState extends State<WinnerScreen> {
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadUserDataAndChits();
  }

  Future<void> _loadUserDataAndChits() async {
    final id = await SecureStorageService.getUserId();
    setState(() {
      userId = id;
    });
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "₹${widget.chitName}",
                          style: GoogleFonts.urbanist(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFE2E2E2),
                          ),
                        ),
                        Text(
                          "${userId}",
                          style: GoogleFonts.urbanist(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFFADADAD),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 103,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFF353535),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 7),
                          Image.asset(
                            "assets/images/Live_Auction/bid_on_live.png",
                            width: 15,
                            height: 20,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            "Draw Result",
                            style: GoogleFonts.urbanist(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Center(
                  child: Image.asset(
                    "assets/images/Live_Auction/live_auction_draw_winner.png",
                    width: 281,
                    height: 281,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ShaderMask(
                    shaderCallback: (bounds) =>
                        const LinearGradient(
                          colors: [Colors.white, Color(0xFFD47A18)],
                        ).createShader(
                          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                        ),
                    child: Text(
                      "Congratulations ${widget.winnerName}!",
                      style: GoogleFonts.urbanist(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    "You have won the chit fund auction",
                    style: GoogleFonts.urbanist(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFB6B6B6),
                      height: 1.0,
                      letterSpacing: 0.0,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Spacer(),
                    Container(
                      height: 39,
                      width: size.width * 0.4,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(11),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF6CA57), Color(0xFF79570A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(0.4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1D1D1D),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Center(
                          child: Text(
                            "Prize Amount : ₹${widget.chitValue.toStringAsFixed(0)}",
                            style: GoogleFonts.urbanist(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFB6B6B6),
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 39,
                      width: size.width * 0.4,
                      margin: const EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(11),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF6CA57), Color(0xFF79570A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(0.4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1D1D1D),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Center(
                          child: Text(
                            "Winning Bid : ₹${widget.winnerBid}",
                            style: GoogleFonts.urbanist(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFB6B6B6),
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ),
                      ),
                    ),
                    Spacer(),
                  ],
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                  child: Container(
                    width: size.width * 0.85,
                    height: 39,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(11),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF6CA57), Color(0xFF79570A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(0.4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D1D1D),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Center(
                        child: Text(
                          "Winning Amount : ₹${(widget.chitValue - widget.winnerBid).toStringAsFixed(0)}",
                          style: GoogleFonts.urbanist(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFB6B6B6),
                            height: 2,
                            letterSpacing: 0.0,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 70),
                Text(
                  "Next Steps",
                  style: GoogleFonts.urbanist(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFF6CA57),
                  ),
                ),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Winning Amount",
                      style: GoogleFonts.urbanist(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFB6B6B6),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "   • The declared winner will receive the prize amount of ₹1,88,000.",
                      style: GoogleFonts.urbanist(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFB6B6B6),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Document Submission",
                      style: GoogleFonts.urbanist(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFB6B6B6),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "   • The winner must upload and send the required documents via\n   the official mail ID provided.",
                      style: GoogleFonts.urbanist(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFB6B6B6),
                      ),
                    ),
                    Text(
                      "   • Failure to submit proper documents may delay or cancel the\n   prize release.",
                      style: GoogleFonts.urbanist(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFB6B6B6),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Verification Process",
                      style: GoogleFonts.urbanist(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFB6B6B6),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "   • The submitted documents will be reviewed by the admin team.\n"
                      "   • Once the verification is complete and successful, the account\n   will be confirmed.",
                      style: GoogleFonts.urbanist(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFB6B6B6),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Prize Release",
                      style: GoogleFonts.urbanist(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFB6B6B6),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "   • After verification, the winning amount will be processed and\n   released within a few working days.",
                      style: GoogleFonts.urbanist(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFB6B6B6),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Note",
                      style: GoogleFonts.urbanist(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFB6B6B6),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "   • The decision of the admin/organizing team will be final in case\n   of disputes.",
                      style: GoogleFonts.urbanist(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFB6B6B6),
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // 🔹 Continue Button (scrolls with content)
                Align(
                  alignment: Alignment.bottomRight,
                  child: GestureDetector(
                    onTap: (){Navigator.push(context,MaterialPageRoute(builder: (context)=>attach_file()));},
                    child: Container(
                      width: 104,
                      height: 37,
                      padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF585858),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Center(
                        child: Text(
                          "Continue",
                          style: GoogleFonts.urbanist(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
