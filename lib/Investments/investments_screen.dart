import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as storage;
import 'package:http/http.dart' as http;
import 'package:user_app/Investments/Gold/gold_investment_screen.dart';
import 'package:user_app/Investments/Real_Estate/real_estate_investment_screen.dart';
import 'package:user_app/Investments/Receipts/investments_receipts_overall_screen.dart';
import 'package:user_app/My_Investments/my_investments_screen.dart';

import '../Models/Investments/Gold/CurrentGoldValue_Model.dart';
import '../Models/Investments/Gold/user_hold_gold_model.dart';
import '../Services/Gold_holdings.dart';
import '../Services/Gold_price.dart';
import '../Services/secure_storage.dart';

class investment extends StatefulWidget {
  const investment({super.key});

  @override
  State<investment> createState() => _investmentState();
}

class _investmentState extends State<investment> {
  GoldHoldings? goldHoldings;
  CurrentGoldValue? _goldValue;
  double totalInvested = 0.0;
  double totalRoiEarned = 0.0;
  double annualRoiPercentage = 0.0;
  int totalinvestments = 0;
  bool _loading = true;
  String? profileId;
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadGoldValue();
    _loadGoldHoldings();
    fetchInvestmentSummary();
  }

  Future<void> fetchInvestmentSummary() async {
    profileId = await _storage.read(key: 'profileId');
    // 🔑 If profile ID is missing, we cannot proceed.
    if (profileId == null || profileId!.isEmpty) {
      print("❌ Error: Profile ID not found in secure storage.");
      return;
    }
    final Token = await SecureStorageService.getToken();
    // 🔑 USE THE DYNAMICALLY RETRIEVED PROFILE ID
    final String apiUrl = "https://foxlchits.com/api/JoinToREInvestment/by-profile/$profileId";

    try {
      final response = await http.get(Uri.parse(apiUrl),headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $Token",
      },);

      print("⭐ Summary API Status Code: ${response.statusCode}");
      print("⭐ Summary API Response: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        setState(() {
          totalInvested = (data['totalAddedAmount'] as num?)?.toDouble() ?? 0.0;
          totalRoiEarned = (data['roiSum'] as num?)?.toDouble() ?? 0.0;
          totalinvestments = (data["joinedCount"] as num?)?.toInt() ?? 0;

          if (totalInvested != 0) {
            annualRoiPercentage = (totalRoiEarned / totalInvested) * 100;
          } else {
            annualRoiPercentage = 0.0;
          }
        });
      } else {
        print("❌ Summary Error: ${response.statusCode}");
      }
    } catch (e) {
      print("⚠ Exception (Summary): $e");
    }
  }

  Future<void> _loadGoldHoldings() async {
    // Step 1️⃣ — Load cached data immediately
    final cached = await GoldHoldingsService.getCachedGoldHoldings();
    if (cached != null) {
      setState(() {
        goldHoldings = cached;
      });
    }

    // Step 2️⃣ — Background fetch new data silently
    final latest = await GoldHoldingsService.fetchAndCacheGoldHoldings();
    if (latest != null) {
      // If new data differs, update UI automatically
      if (latest.userGold != goldHoldings?.userGold ||
          latest.userInvestment != goldHoldings?.userInvestment) {
        setState(() {
          goldHoldings = latest;
        });
      }
    }
  }

// In _investmentState in investment.dart

  Future<void> _loadGoldValue() async {
    // 1️⃣ Load cached value first
    // ... (Uses the cached value, which is now the latest from the last fetch)

    // 2️⃣ Fetch updated gold value in background
    try {
      print('🔹 Fetching latest gold price...');

      // 🔑 This call now returns the LAST item of the list, thanks to the GoldService update
      final latestValue = await GoldService.fetchAndCacheGoldValue();

      if (!mounted) return;
      if (latestValue != null) {
        setState(() {
          _goldValue = latestValue; // _goldValue is set to the LAST item
          _loading = false;
        });
        print('🌐 Updated to latest gold value: ₹${latestValue.goldValue}');
      }
    } catch (e) {
      print('❌ Error fetching gold value: $e');
    }
  }
  String formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
    );
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
                Text(
                  'Investments',
                  style: GoogleFonts.urbanist(
                    textStyle: const TextStyle(
                      color: Color(0xffE2E2E2),
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            size.width * 0.03,
                          ),
                          gradient: const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Color(0xff666666), Color(0xff000000)],
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(size.width * 0.003),
                          child: Container(
                            width: size.width * 0.3,
                            height: size.height * 0.08,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                size.width * 0.03,
                              ),
                              color: const Color(0xff1A1A1A),
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(left: size.width * 0.02),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: size.height * 0.008),
                                  Text(
                                    'Gold',
                                    style: GoogleFonts.urbanist(
                                      textStyle: TextStyle(
                                        color: const Color(0xff626262),
                                        fontSize: size.width * 0.03,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                      left: size.width * 0.14,
                                    ),
                                    child: Image.asset(
                                      'assets/images/Investments/gold.png',
                                      width: size.width * 0.15,
                                      height: size.height * 0.04,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => real_estate_investment(),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            size.width * 0.03,
                          ),
                          gradient: const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Color(0xff666666), Color(0xff000000)],
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(size.width * 0.003),
                          child: Container(
                            width: size.width * 0.3,
                            height: size.height * 0.08,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                size.width * 0.03,
                              ),
                              color: const Color(0xff1A1A1A),
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(left: size.width * 0.02),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: size.height * 0.008),
                                  Text(
                                    'Real Estate',
                                    style: GoogleFonts.urbanist(
                                      textStyle: TextStyle(
                                        color: const Color(0xff626262),
                                        fontSize: size.width * 0.03,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                      left: size.width * 0.14,
                                    ),
                                    child: Image.asset(
                                      'assets/images/Investments/real_estate.png',
                                      width: size.width * 0.15,
                                      height: size.height * 0.04,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                investments_receipts_overall(),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            size.width * 0.03,
                          ),
                          gradient: const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Color(0xff666666), Color(0xff000000)],
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(size.width * 0.003),
                          child: Container(
                            width: size.width * 0.3,
                            height: size.height * 0.08,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                size.width * 0.03,
                              ),
                              color: const Color(0xff1A1A1A),
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(left: size.width * 0.02),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: size.height * 0.008),
                                  Text(
                                    'Receipts',
                                    style: GoogleFonts.urbanist(
                                      textStyle: TextStyle(
                                        color: const Color(0xff626262),
                                        fontSize: size.width * 0.03,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: size.height * 0.004),
                                  Padding(
                                    padding: EdgeInsets.only(
                                      left: size.width * 0.14,
                                    ),
                                    child: Image.asset(
                                      'assets/images/Investments/receipts_1.png',
                                      width: size.width * 0.15,
                                      height: size.height * 0.035,
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
                SizedBox(height: size.height * 0.04),
                Text(
                  'Your Investments',
                  style: GoogleFonts.urbanist(
                    textStyle: const TextStyle(
                      color: Color(0xffE2E2E2),
                      fontSize: 25,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.04),
                Container(
                  width: double.infinity,
                  height: 110,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(11),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Color(0xff775022), Color(0xffDCBB7E)],
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.05,
                      vertical: size.height * 0.01,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'On Gold',
                          style: GoogleFonts.urbanist(
                            textStyle: const TextStyle(
                              color: Color(0xffFFFFFF),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(height: size.height * 0.005),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Current Gold Price ',
                                  style: GoogleFonts.urbanist(
                                    textStyle: const TextStyle(
                                      color: Color(0xffFFFFFF),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                _loading
                                    ? const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                )
                                    : Text(
                                  '₹${_goldValue?.goldValue.toStringAsFixed(2) ?? '--'}/g',
                                  style: GoogleFonts.urbanist(
                                    textStyle: const TextStyle(
                                      color: Color(0xffFFFFFF),
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  _goldValue != null
                                      ? 'Updated on ${_goldValue!.date.toLocal().toString().split(" ").first}'
                                      : '',
                                  style: GoogleFonts.urbanist(
                                    textStyle: const TextStyle(
                                      color: Color(0xffFFFFFF),
                                      fontSize: 10,
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
                                  'Your Holdings',
                                  style: GoogleFonts.urbanist(
                                    textStyle: const TextStyle(
                                      color: Color(0xffF9F5EC),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${goldHoldings?.userGold.toStringAsFixed(2) ?? '--'} g',
                                  style: GoogleFonts.urbanist(
                                    textStyle: const TextStyle(
                                      color: Color(0xffFFFFFF),
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  '₹${goldHoldings?.userInvestment.toStringAsFixed(0) ?? '--'}',
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
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.03),
                Container(
                  width: double.infinity,
                  height: 110,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(11),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Color(0xff347899), Color(0xff44266C)],
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.05,
                      vertical: size.height * 0.01,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'On Real Estate',
                          style: GoogleFonts.urbanist(
                            textStyle: const TextStyle(
                              color: Color(0xffFFFFFF),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(height: size.height * 0.008),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Invested',
                                  style: GoogleFonts.urbanist(
                                    textStyle: const TextStyle(
                                      color: Color(0xffFFFFFF),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  '₹${formatCurrency(totalInvested)}',
                                  style: GoogleFonts.urbanist(
                                    textStyle: const TextStyle(
                                      color: Color(0xffFFFFFF),
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${annualRoiPercentage.toStringAsFixed(2)}% Annual ROI',
                                  style: GoogleFonts.urbanist(
                                    textStyle: const TextStyle(
                                      color: Color(0xffFFFFFF),
                                      fontSize: 10,
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
                                  'Total ROI Earned',
                                  style: GoogleFonts.urbanist(
                                    textStyle: const TextStyle(
                                      color: Color(0xffF9F5EC),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  '₹${formatCurrency(totalRoiEarned)}',
                                  style: GoogleFonts.urbanist(
                                    textStyle: const TextStyle(
                                      color: Color(0xffFFFFFF),
                                      fontSize: 24,
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
                ),
                SizedBox(height: size.height * 0.03),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => my_investments(initialTab: 0),
                      ),
                    );
                  },

                  child: Container(
                    width: double.infinity,
                    height: 37,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(11),
                      color: Color(0xff303030),
                    ),
                    child: Center(
                      child: Text(
                        'View More Details >>',
                        style: GoogleFonts.urbanist(
                          textStyle: const TextStyle(
                            color: Color(0xffFFFFFF),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
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
      ),
    );
  }
}
