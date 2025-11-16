import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../../Helper/Local_storage_manager.dart';
import '../../Models/My_Chits/past_auction_result_model.dart';
import '../../Services/secure_storage.dart';

class auction_result extends StatefulWidget {
  final String chitId;
  final double chitValue;
  final String chitName;

  const auction_result({super.key, required this.chitId,
    required this.chitName,required this.chitValue,
});

  @override
  State<auction_result> createState() => _auction_resultState();
}

class _auction_resultState extends State<auction_result> {
  List<PastAuctionResultModel> pastResults = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    _loadPastAuctionResults();
  }

  Future<void> _loadPastAuctionResults() async {
    final Token = await SecureStorageService.getToken();
    // 🔹 Fetch fresh data from API
    try {
      final response = await http.get(
        Uri.parse(
          "https://foxlchits.com/api/AddUsertoachit/whotakesachit/${widget.chitId}/Members",
        ),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $Token",
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        var fetched = data
            .map((e) => PastAuctionResultModel.fromJson(e))
            .where((item) => item.chitTaken == true)
            .toList();

// NOW: Latest item becomes Auction #1
        fetched = fetched.reversed.toList();

        setState(() {
          pastResults = fetched;
          isLoading = false;
        });



      } else {
        print('❌ API failed: ${response.statusCode}');
      }
    } catch (e) {
      print('⚠️ Error fetching API: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Color(0xff000000),
      body: SafeArea(
        child:SingleChildScrollView(
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
                        Navigator.pop(context);
                      },
                      child: Image.asset(
                        'assets/images/My_Chits/back_arrow.png',
                        width: 24,
                        height: 24,
                      ),
                    ),
                    SizedBox(width: size.width * 0.03),
                    Text(
                      'Past Auction Results',
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
                isLoading
                    ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
                    : pastResults.isEmpty
                    ? Column(
                      children: [
                        SizedBox(height:300),
                        const Center(
                                          child: Text(
                        'No Past Auction Results Found',
                        style: TextStyle(color: Colors.white),
                                          ),
                                        ),
                      ],
                    )
                    :
                SizedBox(height: size.height * 0.04),
                ...List.generate(pastResults.length, (index) {
                  final result = pastResults[index];
                  return Padding(
                    padding: EdgeInsets.only(bottom: size.height * 0.02),
                    child: Container(
                      width: double.infinity,
                      height: 285,
                      decoration: BoxDecoration(
                        color: Color(0xff151515),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.045,
                          vertical: size.height * 0.025,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Auction #${index + 1}',
                                      style: GoogleFonts.urbanist(
                                        textStyle: const TextStyle(
                                          color: Color(0xff3A7AFF),
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${result.chitTakenDate.toLocal()}'
                                          .split('.')[0],
                                      style: GoogleFonts.urbanist(
                                        textStyle: const TextStyle(
                                          color: Color(0xffDDDDDD),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '${widget.chitName}',
                                  style: GoogleFonts.urbanist(
                                    textStyle: const TextStyle(
                                      color: Color(0xffDDDDDD),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: size.height * 0.03),
                            Container(
                              width: double.infinity,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(11),
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xff5081EC),
                                    Color(0xff8F20DE),
                                  ],
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: size.width * 0.045,
                                  vertical: size.height * 0.005,
                                ),
                                child: Column(
                                  children: [
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: Text(
                                        'Winner',
                                        style: GoogleFonts.urbanist(
                                          textStyle: const TextStyle(
                                            color: Color(0xffB5B5B5),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        '${result.name} (${result.userID})',
                                        style: GoogleFonts.urbanist(
                                          textStyle: const TextStyle(
                                            color: Color(0xffE2E2E2),
                                            fontSize: 17,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: size.height * 0.03),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Winning Bid',
                                      style: GoogleFonts.urbanist(
                                        textStyle: const TextStyle(
                                          color: Color(0xffDDDDDD),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '₹${result.amountTaken.toStringAsFixed(0)}',
                                      style: GoogleFonts.urbanist(
                                        textStyle: const TextStyle(
                                          color: Color(0xff3A7AFF),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Amount Received',
                                      style: GoogleFonts.urbanist(
                                        textStyle: const TextStyle(
                                          color: Color(0xffDDDDDD),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Text(
                                        '₹${(widget.chitValue-result.amountTaken).toStringAsFixed(0)}',
                                        style: GoogleFonts.urbanist(
                                        textStyle: const TextStyle(
                                          color: Color(0xff3A7AFF),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: size.height * 0.02),
                            Center(
                              child:Center(
                                child: Text(
                                  result.bidHistories.isNotEmpty
                                      ? 'Winner Selected by Auction'
                                      : 'Winner Selected by Draw',
                                  style: GoogleFonts.urbanist(
                                    textStyle: const TextStyle(
                                      color: Color(0xff6C6C6C),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
