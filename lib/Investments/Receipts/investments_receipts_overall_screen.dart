import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:user_app/Bottom_Navbar/bottom_navigation_bar.dart';
import 'package:user_app/Services/secure_storage.dart';
import 'package:shimmer/shimmer.dart';

import '../../Models/Receipt/receipt_model.dart';

class investments_receipts_overall extends StatefulWidget {
  const investments_receipts_overall({super.key});

  @override
  State<investments_receipts_overall> createState() =>
      _investments_receipts_overallState();
}

class _investments_receipts_overallState
    extends State<investments_receipts_overall> {
  Future<List<ReceiptModel>> fetchAllReceipts() async {
    final Token = await SecureStorageService.getToken();
    final profileID = "f864ab0d-dfd0-4c28-901e-df65cbfe9a1b";

    final buyGoldUrl =
        "https://foxlchits.com/api/PaymentHistory/buy-profile/$profileID";

    final sellGoldUrl =
        "https://foxlchits.com/api/AddYourGold/selling/$profileID";

    final physicalGoldUrl =
        "https://foxlchits.com/api/SchemeMember/physical-gold/$profileID";

    final investmentsUrl =
        "https://foxlchits.com/api/PaymentHistory/by-profile/all-investments/$profileID";

    // Fetch all
    final responses = await Future.wait([
      http.get(Uri.parse(buyGoldUrl),headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $Token",
      },), // 0
      http.get(Uri.parse(sellGoldUrl),headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $Token",
      },), // 1
      http.get(Uri.parse(physicalGoldUrl),headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $Token",
      },), // 2
      http.get(Uri.parse(investmentsUrl),headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $Token",
      },), // 3
    ]);

    List<ReceiptModel> all = [];

    // ==================== GOLD BUY ====================
    final goldBuy = jsonDecode(responses[0].body);
    for (var item in goldBuy) {
      all.add(
        ReceiptModel(
          type: "gold_buy",
          title: "Gold Purchased",
          amount: item["amount"],
          grams: item["goldGrams"],
          bookingId: item["paymentID"],
          date: DateTime.parse(item["dateTime"]),
          description: "you have successfully purchased Gold in our store",
          GoldRate: item['goldRate'],
        ),
      );
    }

    // ==================== GOLD SELL ====================
    final goldSell = jsonDecode(responses[1].body);
    for (var item in goldSell) {
      all.add(
        ReceiptModel(
          type: "gold_sell",
          title: "Gold Sold",
          amount: item["amount"],
          grams: item["grams"],
          bookingId: item["id"],
          date: DateTime.parse(item["dateTime"]),
          description:
              "Your gold has been sold successfully.\nThe proceeds will be transferred to your account soon.",
          GoldRate: item['goldRate'],
        ),
      );
    }

    // ==================== PHYSICAL GOLD ====================
    final physical = jsonDecode(responses[2].body);
    for (var item in physical) {
      all.add(
        ReceiptModel(
          type: "physical_gold",
          title: "Physical Gold Booking",
          amount: item["toDayRate"] * item["goldGram"],
          grams: item["goldGram"],
          bookingId: item["goldShopID"],
          date: DateTime.parse(item["date"]),
          description:
              "Your physical gold conversion has been scheduled\nsuccessfully.",
          GoldRate: item['toDayRate'],
        ),
      );
    }

    // ==================== RE + GOLD SCHEME ====================
    final investData = jsonDecode(responses[3].body);

    final transactions = investData["transactions"] as List;

    for (var item in transactions) {
      final type = item["investmentType"];

      if (type == "REInvestment") {
        all.add(
          ReceiptModel(
            type: "re_investment",
            title: "Real Estate Investment",
            amount: item["amount"],
            bookingId: item["paymentID"],
            date: DateTime.parse(item["dateTime"]),
            description: "You have successfully invested",
            referenceName: item["referenceName"],
          ),
        );
      } else if (type == "GoldScheme") {
        all.add(
          ReceiptModel(
            type: "gold_scheme",
            title: "Gold Scheme Payment",
            amount: item["amount"],
            bookingId: item["paymentID"],
            date: DateTime.parse(item["dateTime"]),
            description: "Gold scheme due paid successfully",
            referenceName: item["referenceName"],
          ),
        );
      }
    }

    // Sort by latest
    all.sort((a, b) => b.date.compareTo(a.date));

    return all;
  }

  List<ReceiptModel> receipts = [];
  late String Username;
  late String UserId;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadReceipts();
  }

  Future<void> loadReceipts() async {
    final username = await SecureStorageService.getUserName();
    final userid = await SecureStorageService.getUserId();
    receipts = await fetchAllReceipts();
    setState(() {
      Username = username!;
      UserId = userid!;
      loading = false;
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
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomeLayout(initialTab: 2),
                          ),
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
                SizedBox(height: size.height * 0.02),
                loading
                    ? shimmerReceipt(size)
                    : Column(
                children: List.generate(
                          receipts.length,
                          (index) => Padding(
                            padding: EdgeInsets.only(bottom: 20),
                            child: FoxlReceiptCard(
                              receipt: receipts[index],
                              Username: Username,
                              UserId: UserId,
                            ),
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
  Widget shimmerReceipt(Size size) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade800,
      highlightColor: Colors.grey.shade600,
      child: Column(
        children: List.generate(4, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Container(
              width: double.infinity,
              height: 426, // 111 (header) + 315 (body)
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(11),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class FoxlReceiptCard extends StatelessWidget {
  final ReceiptModel receipt;
  final String Username;
  final String UserId;

  const FoxlReceiptCard({
    super.key,
    required this.receipt,
    required this.Username,
    required this.UserId,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    bool isRealEstate = receipt.type == "re_investment";

    final Color topStart = isRealEstate ? Color(0xff347899) : Color(0xff795124);
    final Color topEnd = isRealEstate ? Color(0xff44266C) : Color(0xffD4B277);

    final Color bottomStart = isRealEstate
        ? Color(0xff347899)
        : Color(0xff7D5628);
    final Color bottomEnd = isRealEstate
        ? Color(0xff44266C)
        : Color(0xffD2B075);
    final Color icon = isRealEstate
        ? Color(0xff44266C)
        : Color(0xff7A5225);

    final Color iconBg = isRealEstate ? Color(0xff347899) : Color(0xffD3B176);
    final Color iconBorder = isRealEstate
        ? Color(0xff44266C)
        : Color(0xff7A5225);
    final Color statusTextColor = isRealEstate ? Colors.white : Colors.white;
    final Color subTextColor = isRealEstate
        ? Color(0xff347899)
        : Color(0xffCBA86F);

    String formattedDate =
        "${receipt.date.day}-${receipt.date.month}-${receipt.date.year}";

    return Column(
      children: [
        // ================= HEADER =================
        Container(
          width: double.infinity,
          height: 111,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [topStart, topEnd]),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(11),
              topLeft: Radius.circular(11),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.04,
              vertical: size.height * 0.03,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TITLE + USER NAME
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Foxl Chit Funds", // DYNAMIC
                      style: GoogleFonts.urbanist(
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      Username,
                      style: GoogleFonts.urbanist(
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                // SUBTITLE
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Official Confirmation Receipt',
                      style: GoogleFonts.urbanist(
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      UserId,
                      style: GoogleFonts.urbanist(
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
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

        // ================= BODY =================
        Container(
          width: double.infinity,
          height: 315,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [bottomStart, bottomEnd]),
            borderRadius: const BorderRadius.only(
              bottomRight: Radius.circular(11),
              bottomLeft: Radius.circular(11),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(1),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(11),
                  bottomLeft: Radius.circular(11),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.04,
                  vertical: size.height * 0.03,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // STATUS BOX
                    Row(
                      children: [
                        Container(width: 4, height: 60, color: subTextColor),
                        Expanded(
                          child: Container(
                            height: 60,
                            color: const Color(0xff2E2E2E),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: size.width * 0.03,
                              ),
                              child: Row(
                                children: [
                                  // ICON
                                  Container(
                                    width: 33,
                                    height: 33,
                                    decoration: BoxDecoration(
                                      color: iconBg,
                                      border: Border.all(
                                        color: iconBorder,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: Center(
                                      child: Image.asset(
                                        'assets/images/Investments/booking_confirmed.png',
                                        color:icon,
                                        width: 15,
                                        height: 15,
                                      ),
                                    ),
                                  ),

                                  SizedBox(width: size.width * 0.03),

                                  // STATUS TEXT
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: size.height * 0.015),
                                      Text(
                                        receipt.title,
                                        style: GoogleFonts.urbanist(
                                          textStyle: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        receipt.description ?? "",
                                        style: GoogleFonts.urbanist(
                                          textStyle: TextStyle(
                                            color: subTextColor,
                                            fontSize: 9,
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
                        ),
                      ],
                    ),

                    SizedBox(height: size.height * 0.02),

                    // BOOKING DETAILS BOX
                    Container(
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(
                        color: const Color(0xff2E2E2E),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.04,
                          vertical: size.height * 0.02,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Booking Details',
                              style: GoogleFonts.urbanist(
                                textStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(height: size.height * 0.015),

                            // FIRST ROW
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // LEFT SIDE
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Transaction Date:',
                                      style: textSmallGrey(),
                                    ),
                                    Text(formattedDate, style: textValue()),
                                  ],
                                ),
                                if (receipt.type == "gold_buy" ||
                                    receipt.type == "gold_scheme" ||
                                    receipt.type == "re_investment") ...[
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Transaction ID',
                                        style: textSmallGrey(),
                                      ),
                                      Text(
                                        receipt.bookingId ?? '-',
                                        style: textValue(),
                                      ),
                                    ],
                                  ),
                                ],

                                // RIGHT SIDE
                              ],
                            ),

                            SizedBox(height: 10),

                            // SECOND ROW
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Amount', style: textSmallGrey()),
                                    Text(
                                      '₹${receipt.amount.toStringAsFixed(2)}',
                                      style: textValue(),
                                    ),
                                  ],
                                ),

                                // SHOW GOLD SECTION ONLY FOR gold_buy, gold_sell, physical_gold
                                if (receipt.type == "gold_buy" ||
                                    receipt.type == "gold_sell" ||
                                    receipt.type == "physical_gold") ...[
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text('Gold', style: textSmallGrey()),
                                      Text(
                                        receipt.grams != null
                                            ? '${receipt.grams} g'
                                            : '-',
                                        style: textValue(),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),

                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                            if (receipt.type == "re_investment" ||
                                receipt.type == "gold_scheme") ...[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Plan Name', style: textSmallGrey()),
                                  Text(
                                    receipt.referenceName ?? "",
                                    style: textValue(),
                                  ),
                                ],
                              ),
                            ],
                                if (receipt.type == "gold_buy" ||
                                    receipt.type == "physical_gold" ||
                                    receipt.type == "gold_sell") ...[
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Today Gold Rate', style: textSmallGrey()),
                                      Text(
                                        receipt.GoldRate != null
                                            ? "${receipt.GoldRate!.toStringAsFixed(2)}/g"
                                            : "-",
                                        style: textValue(),
                                      ),
                                    ],
                                  ),
                                ],
                            ],
                            )
                          ],
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
    );
  }

  TextStyle textSmallGrey() => GoogleFonts.urbanist(
    textStyle: const TextStyle(
      color: Color(0xff6E6E6E),
      fontSize: 9,
      fontWeight: FontWeight.w600,
    ),
  );

  TextStyle textValue() => GoogleFonts.urbanist(
    textStyle: const TextStyle(
      color: Color(0xff989898),
      fontSize: 11,
      fontWeight: FontWeight.w600,
    ),
  );
}
