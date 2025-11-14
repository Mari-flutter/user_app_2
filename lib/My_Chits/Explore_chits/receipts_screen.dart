import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:user_app/Services/secure_storage.dart';

import '../../Models/My_Chits/chit_receipt_model.dart';
import 'download_receipts_screen.dart';
import 'package:intl/intl.dart';
import 'explore_chit_screen.dart';

class receipts extends StatefulWidget {
  final String chitId;
  final String chitName;
  final String chitType;
  final int timePeriod;
  const receipts({super.key,required this.chitId, required this.chitName, required this.timePeriod, required this.chitType});

  @override
  State<receipts> createState() => _receiptsState();
}

class _receiptsState extends State<receipts> {
  String? userName;
  String? userID;
  String? mobilenumber;
  List<ChitReceiptModel> receiptsList = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    print("🔵 RECEIPTS SCREEN OPENED");
    print("🔵 chitId = ${widget.chitId}");
    print("🔵 chitName = ${widget.chitName}");
    print("🔵 chitType = ${widget.chitType}");
    print("🔵 timePeriod = ${widget.timePeriod}");

    _loadReceipts();
  }


  Future<void> _loadReceipts() async {
    setState(() => isLoading = true);

    try {
      // Load user info (async)
      final userNameFuture = SecureStorageService.getUserName();
      final userIdFuture = SecureStorageService.getUserId();
      final mobileFuture = SecureStorageService.getMobileNumber();

      String? profileId = await SecureStorageService.getProfileId();
      print("🟡 profileId = $profileId");
      print("🟡 chitId = ${widget.chitId}");

      final url = Uri.parse(
        "https://foxlchits.com/api/PaymentHistory/by-profile-and-chit?profileId=$profileId&chitId=${widget.chitId}",
      );
      print("🟡 API URL = $url");

      final response = await http.get(url);
      print("🟣 API STATUS = ${response.statusCode}");
      print("🟣 API BODY = ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);

        // Parse receipts
        receiptsList =
            jsonData.map((e) => ChitReceiptModel.fromJson(e)).toList();

        // Await user info
        userName = await userNameFuture;
        userID = await userIdFuture;
        mobilenumber = await mobileFuture;

        // Update UI
        setState(() {});
      } else {
        setState(() => receiptsList = []);
      }
    } catch (e) {
      print("❌ Exception: $e");
      setState(() => receiptsList = []);
    }

    setState(() => isLoading = false);
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
                      'Receipts',
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
                // 🔹 Outer Rectangle (Main Card)
                Container(
                  width: double.infinity,
                  height: 92,
                  decoration: BoxDecoration(
                    color: const Color(0xFF151515),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(11),
                      topRight: Radius.circular(11),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: size.height * 0.02,
                      horizontal: size.width * 0.06,
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
                                  'Chit Name',
                                  style: GoogleFonts.urbanist(
                                    color: const Color(0xFFDDDDDD),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${widget.chitName}',
                                  style: GoogleFonts.urbanist(
                                    color: const Color(0xFF3A7AFF),
                                    fontSize: 25,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),

                            // Right side (Monthly)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${widget.chitType}',
                                  style: GoogleFonts.urbanist(
                                    color: const Color(0xFFDDDDDD),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${receiptsList.length}/${widget.timePeriod}',
                                  style: GoogleFonts.urbanist(
                                    color: const Color(0xFF3A7AFF),
                                    fontSize: 25,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFF3F3F3F),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(11),
                      bottomRight: Radius.circular(11),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.04,
                    vertical: size.height * 0.02,
                  ),
                  child: isLoading
                      ? Center(child: CircularProgressIndicator(color: Colors.white))
                      : receiptsList.isEmpty
                      ? Center(
                    child: Text(
                      "No receipts available",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                      : Column(
                    children: receiptsList.asMap().entries.map((entry) {
                      final index = entry.key;
                      final receipt = entry.value;

                      final dt = DateTime.parse(receipt.dateTime.toString());
                      final formattedDate = DateFormat('d MMMM yyyy').format(dt);

                      return Padding(
                        padding: EdgeInsets.only(bottom: size.height * 0.008),
                        child: _receiptRow(
                          "${index + 1} Month - $formattedDate",
                          receipt,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _receiptRow(String title, ChitReceiptModel receipt) {
    DateTime dt = DateTime.parse(receipt.dateTime.toString());

    String formattedDate = DateFormat('d MMMM yyyy').format(dt);
    String formattedTime = DateFormat('hh:mm a').format(dt);
    String status = receipt.status == true ? "Success" : "Failed";

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.urbanist(
            color: const Color(0xFFDDDDDD),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => download_receipts(
                  userName: userName ?? "",
                  userID: userID ?? "",
                  date: formattedDate,
                  time: formattedTime,
                  chitName: receipt.chit.chitsName,
                  chitID:receipt.chit.chitsID,
                  orderId: receipt.orderId,
                  amount: receipt.amount,
                  status: status,
                  mobilenumber:mobilenumber,
                  timeperiod:widget.timePeriod,
                  totaltimeperiod:receiptsList.length,
                ),
              ),
            );
          },
          child: Container(
            width: 73,
            height: 20,
            decoration: BoxDecoration(
              color: const Color(0xFF9B9B9B),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Center(
              child: Text(
                'Download Receipt',
                style: GoogleFonts.urbanist(
                  color: Colors.black,
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
