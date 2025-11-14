import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:user_app/Investments/Gold/gold_investment_screen.dart';

import '../../Models/Investments/Gold/gold_transaction_model.dart';
import '../../Services/secure_storage.dart';

class withdraw_for_gold extends StatefulWidget {


  const withdraw_for_gold({
    super.key,
  });

  @override
  State<withdraw_for_gold> createState() => _withdraw_for_goldState();
}

class _withdraw_for_goldState extends State<withdraw_for_gold> {
  String? userName;
  String? UserId;
  String? profileId;
  double? walletBalance;


  @override
  void initState() {
    super.initState();
    _loadProfileId();  // ONLY THIS
  }

  void filterList(String type) {
    setState(() {
      if (type == "all") {
        filteredTransactions = allTransactions;
      } else {
        filteredTransactions =
            allTransactions.where((t) => t.type == type).toList();
      }
    });
  }

  Future<void> _fetchGoldWallet() async {
    if (profileId == null) return;

    final url = "https://foxlchits.com/api/AddYourGold/wallet/$profileId";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          walletBalance = (data["walletBalance"] ?? 0).toDouble();
        });
      }
    } catch (e) {
      print("Error fetching wallet: $e");
    }
  }

  List<GoldTransaction> allTransactions = [];
  List<GoldTransaction> filteredTransactions = [];

  Future<void> loadAllTransactions() async {
    print("------------ 🔥 LOADING GOLD TRANSACTIONS 🔥 ------------");

    if (profileId == null) {
      print("❌ ERROR: profileId is NULL. Cannot load transactions.");
      return;
    }

    final String buyUrl =
        "https://foxlchits.com/api/PaymentHistory/buy-profile/$profileId";

    final String sellUrl =
        "https://foxlchits.com/api/AddYourGold/selling/$profileId";

    try {
      print("🔵 BUY API CALL: $buyUrl");
      final buyResponse = await http.get(Uri.parse(buyUrl));
      print("🟢 BUY STATUS CODE: ${buyResponse.statusCode}");

      if (buyResponse.body.isEmpty) {
        print("⚠ BUY API returned an EMPTY BODY");
      } else {
        print("📦 BUY RESPONSE BODY:\n${buyResponse.body}");
      }

      print("\n🟠 SELL API CALL: $sellUrl");
      final sellResponse = await http.get(Uri.parse(sellUrl));
      print("🟣 SELL STATUS CODE: ${sellResponse.statusCode}");

      if (sellResponse.body.isEmpty) {
        print("⚠ SELL API returned an EMPTY BODY");
      } else {
        print("📦 SELL RESPONSE BODY:\n${sellResponse.body}");
      }

      // Temporary list
      List<GoldTransaction> tempList = [];

      // ----------------------
      // Parse BUY transactions
      // ----------------------
      if (buyResponse.statusCode == 200) {
        try {
          final List buyData = jsonDecode(buyResponse.body);
          tempList.addAll(
            buyData.map((e) => GoldTransaction.fromBuy(e)).toList(),
          );
          print("✅ BUY DATA PARSED: ${buyData.length} records");
        } catch (e) {
          print("❌ ERROR parsing BUY JSON: $e");
        }
      } else {
        print("❌ BUY API FAILED with ${buyResponse.statusCode}");
      }

      // ----------------------
      // Parse SELL transactions
      // ----------------------
      if (sellResponse.statusCode == 200) {
        try {
          final List sellData = jsonDecode(sellResponse.body);
          tempList.addAll(
            sellData.map((e) => GoldTransaction.fromSell(e)).toList(),
          );
          print("✅ SELL DATA PARSED: ${sellData.length} records");
        } catch (e) {
          print("❌ ERROR parsing SELL JSON: $e");
        }
      } else {
        print("❌ SELL API FAILED with ${sellResponse.statusCode}");
      }

      // Sort newest first
      tempList.sort((a, b) => b.dateTime.compareTo(a.dateTime));

      // Update UI
      setState(() {
        allTransactions = tempList;
        filteredTransactions = tempList;
      });

      print("✔ FINAL TRANSACTION COUNT: ${tempList.length}");
      print("------------ ✅ LOAD COMPLETE ✅ ------------\n");

    } catch (e, stack) {
      print("❌ FATAL ERROR in loadAllTransactions(): $e");
      print("📌 STACK TRACE:\n$stack");
    }
  }


  Future<void> _loadProfileId() async {
    final username = await SecureStorageService.getUserName();
    final userId = await SecureStorageService.getUserId();
    final ProfileId = await SecureStorageService.getProfileId();

    print("PROFILE ID LOADED: $ProfileId");

    setState(() {
      userName = username;
      UserId = userId;
      profileId = ProfileId;
    });

    // MUST BE CALLED HERE 🔥 AFTER profileId is set
    await _fetchGoldWallet();
    await loadAllTransactions();
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Color(0xff000000),
      body: SafeArea(
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
                          builder: (context) =>
                              gold_investment(initialTab: 0),
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
                    'Withdraw',
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
              Container(
                width: size.width,
                height: 198,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      'assets/images/My_Chits/withdraw_card.png',
                    ),
                    fit: BoxFit.fill, // full screen
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.05,
                    vertical: size.height * 0.03,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Your Wallet',
                            style: GoogleFonts.urbanist(
                              textStyle: const TextStyle(
                                color: Color(0xffFFFFFF),
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            'Credit',
                            style: GoogleFonts.urbanist(
                              textStyle: const TextStyle(
                                color: Color(0xff484848),
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.03),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                            '₹${walletBalance?.toStringAsFixed(2) ?? "0.00"}',
                            style: GoogleFonts.urbanist(
                            textStyle: const TextStyle(
                              color: Color(0xff07C66A),
                              fontSize: 32,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.035),
                      Text(
                        '${userName} (${UserId})',
                        style: GoogleFonts.urbanist(
                          textStyle: const TextStyle(
                            color: Color(0xffFFFFFF),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.03),
              Expanded(
                child: ListView.builder(
                    itemCount: filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final t = filteredTransactions[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 12),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(11),
                          color: Color(0xff101010),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.05,
                            vertical: size.height * 0.015,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceBetween,
                                children: [
                                  Text(
                                    'Payment Details',
                                    style: GoogleFonts.urbanist(
                                      textStyle: const TextStyle(
                                        color: Color(0xffFFFFFF),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),

                                  // 🔥 Buy or Sell Label
                                  Text(
                                    t.type == "buy"
                                        ? 'Bought Gold'
                                        : 'Sold Gold',
                                    style: GoogleFonts.urbanist(
                                      textStyle: const TextStyle(
                                        color: Color(0xffFFFFFF),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: size.height * 0.02),

                              Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceBetween,
                                children: [
                                  // LEFT SIDE
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,
                                    children: [
                                      Text(
                                        t.type == "buy"
                                            ? 'Debited To'
                                            : 'Credited From',
                                        style: GoogleFonts.urbanist(
                                          textStyle: const TextStyle(
                                            color: Color(0xff6E6E6E),
                                            fontSize: 9,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        'Foxl Chit Funds',
                                        style: GoogleFonts.urbanist(
                                          textStyle: const TextStyle(
                                            color: Color(0xff989898),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),

                                      SizedBox(height: size.height * 0.02),

                                      Text(
                                        t.type == "buy"
                                            ? 'Debited Amount'
                                            : 'Credited Amount',
                                        style: GoogleFonts.urbanist(
                                          textStyle: const TextStyle(
                                            color: Color(0xff6E6E6E),
                                            fontSize: 9,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${t.amount}',
                                        style: GoogleFonts.urbanist(
                                          textStyle: const TextStyle(
                                            color: Color(0xff989898),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),

                                      SizedBox(height: size.height * 0.02),

                                      Text(
                                        'Gold Rate',
                                        style: GoogleFonts.urbanist(
                                          textStyle: const TextStyle(
                                            color: Color(0xff6E6E6E),
                                            fontSize: 9,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${t.goldRate}',
                                        style: GoogleFonts.urbanist(
                                          textStyle: const TextStyle(
                                            color: Color(0xff989898),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  // RIGHT SIDE
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        t.type == "buy"
                                            ? 'Debited Date'
                                            : 'Credited Date',
                                        style: GoogleFonts.urbanist(
                                          textStyle: const TextStyle(
                                            color: Color(0xff6E6E6E),
                                            fontSize: 9,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        t.dateTime.toLocal().toString().split(
                                            ' ')[0],
                                        style: GoogleFonts.urbanist(
                                          textStyle: const TextStyle(
                                            color: Color(0xff989898),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),

                                      SizedBox(height: size.height * 0.02),

                                      if (t.type == "buy") ...[
                                        Text(
                                          'Payment Id',
                                          style: GoogleFonts.urbanist(
                                            textStyle: const TextStyle(
                                              color: Color(0xff6E6E6E),
                                              fontSize: 9,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),

                                        Text(
                                          (t.paymentId != null && t.paymentId!.trim().isNotEmpty)
                                              ? t.paymentId!
                                              : " ",  // blank space to keep layout
                                          style: GoogleFonts.urbanist(
                                            textStyle: const TextStyle(
                                              color: Color(0xff989898),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),

                                        // 🔥 This SizedBox will always be here
                                        SizedBox(height: size.height * 0.02),
                                      ]
                                      else ...[
                                        // 🔥 Add SAME SizedBox even for SELL so spacing stays perfect
                                        SizedBox(height: size.height * 0.02),
                                      ],
                                      Text(
                                        'Gold',
                                        style: GoogleFonts.urbanist(
                                          textStyle: const TextStyle(
                                            color: Color(0xff6E6E6E),
                                            fontSize: 9,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${t.goldGrams} g',
                                        style: GoogleFonts.urbanist(
                                          textStyle: const TextStyle(
                                            color: Color(0xff989898),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                ),
              ),
              SizedBox(height: size.height*0.01),
              GestureDetector(
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => add_account()),
                  // );
                },
                child: Container(
                  width: double.infinity,
                  height: 38,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(11),
                    color: Color(0xff4770CB),
                  ),
                  child: Center(
                    child: Text(
                      'Withdraw Amount',
                      style: GoogleFonts.urbanist(
                        textStyle: const TextStyle(
                          color: Color(0xffFFFFFF),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
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
    );
  }
}
