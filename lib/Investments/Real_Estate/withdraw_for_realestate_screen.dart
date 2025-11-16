import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';

import '../../Models/Investments/Realestate/real_estate_transaction_model.dart';
import '../../Services/secure_storage.dart';
import 'RE_add_account.dart';

class withdraw_for_realestate extends StatefulWidget {
  const withdraw_for_realestate({super.key});

  @override
  State<withdraw_for_realestate> createState() => _withdraw_for_realestateState();
}

class _withdraw_for_realestateState extends State<withdraw_for_realestate> {
  final storage = const FlutterSecureStorage();
  static const String _apiUrlBase = "https://foxlchits.com/api/InvestmentWithdraws/vallet-with-investments";

  // 🔑 Updated State Variables
  double valletAmount = 0.0;
  bool isLoading = true;
  String? _profileId;
  String? _userName; // 🔑 NEW: Variable to hold the user's name
  List<RealEstateTxModel> transactions = [];

  @override
  void initState() {
    super.initState();
    fetchWalletData();
  }

  // 🔑 Function to fetch and bind wallet data
  Future<void> fetchWalletData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // 1. Get Profile ID and Name from Secure Storage
      _profileId = await storage.read(key: 'profileId');
      _userName = await storage.read(key: 'userName'); // 🔑 Read User Name

      if (_profileId == null || _profileId!.isEmpty) {
        print("❌ ERROR: Profile ID not found in secure storage.");
        setState(() => isLoading = false);
        return;
      }

      // 2. Construct Dynamic API URL
      final String apiUrl = '$_apiUrlBase/$_profileId';
      print("🎯 API CALL: Fetching wallet data from $apiUrl");

      // 3. Make API Call
      final Token = await SecureStorageService.getToken();
      final response = await http.get(Uri.parse(apiUrl), headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $Token",
      },);
      print("✅ Response Status Code: ${response.statusCode}");
      print("✅ Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        setState(() {
          valletAmount = (data['valletAmount'] as num?)?.toDouble() ?? 0.0;
          isLoading = false;
        });
      } else {
        print("❌ API Error: ${response.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("⚠ Exception during API call: $e");
      setState(() => isLoading = false);
    }
    fetchTransactions();
  }

  // Helper to format currency
  String formatCurrency(double amount) {
    String formatted = amount.toStringAsFixed(0);
    final parts = <String>[];
    int length = formatted.length;
    int firstGroup = length % 3;

    if (firstGroup != 0) {
      parts.add(formatted.substring(0, firstGroup));
    }

    for (int i = firstGroup; i < length; i += 3) {
      parts.add(formatted.substring(i, i + 3));
    }

    return parts.join(',');
  }

  // Shimmer Widget for the Wallet Card
  Widget _buildWalletShimmer(Size size) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade800,
      highlightColor: Colors.grey.shade600,
      child: Container(
        width: size.width,
        height: 198,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/images/My_Chits/withdraw_card.png',
            ),
            fit: BoxFit.fill,
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
                  Container(width: 80, height: 15, color: Colors.black),
                  Container(width: 50, height: 15, color: Colors.black),
                ],
              ),
              SizedBox(height: size.height * 0.03),
              Align(
                alignment: Alignment.bottomRight,
                child: Container(width: 150, height: 32, color: Colors.black),
              ),
              SizedBox(height: size.height * 0.035),
              Container(width: 200, height: 13, color: Colors.black), // User Name/ID shimmer
            ],
          ),
        ),
      ),
    );
  }
  Future<void> fetchTransactions() async {
    final Token = await SecureStorageService.getToken();
    final url = Uri.parse(
      "https://foxlchits.com/api/PaymentHistory/by-profile-REInvestment/$_profileId",
    );

    try {
      final response = await http.get(url, headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $Token",
      },);

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        setState(() {
          transactions =
              data.map((json) => RealEstateTxModel.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error fetching transactions: $e");
      setState(() => isLoading = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    String displayValletAmount = isLoading ? '...' : '₹${formatCurrency(valletAmount)}';

    // 🔑 Dynamic Card Footer Text
    String cardFooterText = '# ${_userName ?? 'User'}';
    // Use the fetched name if available, otherwise use a fallback.

    return Scaffold(
      backgroundColor: const Color(0xff000000),
      body: SafeArea(
        child: Column(
          children: [
            // TOP FIXED CARD
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.02),
                  headerWidget(size),
                  SizedBox(height: size.height * 0.04),
                  isLoading ? _buildWalletShimmer(size) : walletCard(size),
                ],
              ),
            ),
            SizedBox(height: size.height*0.02),
            // MIDDLE SCROLLABLE LIST
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
                child: isLoading
                    ? shimmerTransactionList(size)
                    : transactionList(size),
              ),
            ),

            // BOTTOM FIXED BUTTON
            withdrawButton(size),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  Widget shimmerTransactionList(Size size) {
    return ListView.builder(
      itemCount: 4,
      itemBuilder: (_, __) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade800,
          highlightColor: Colors.grey.shade600,
          child: Container(
            margin: EdgeInsets.only(bottom: 12),
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              color: Colors.black,
            ),
          ),
        );
      },
    );
  }
  Widget transactionList(Size size) {
    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final tx = transactions[index];
        String TID = tx.paymentId;
        String date = tx.dateTime.split("T")[0];
        String amount = "₹${tx.amount.toStringAsFixed(2)}";

        return Container(
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            color: const Color(0xff101010),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Payment Details",
                  style: GoogleFonts.urbanist(
                    textStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  )),
              SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // LEFT
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      label("Debited To"),
                      value("Foxl Chit Funds"),
                      SizedBox(height: 12),
                      label("Total Amount Paid"),
                      value("- $amount"),
                    ],
                  ),

                  // RIGHT
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      label("Debited Date"),
                      value(date),
                      SizedBox(height: 12),
                      label("Transaction ID"),
                      value(TID),
                    ],
                  )
                ],
              ),
            ],
          ),
        );
      },
    );
  }
  Widget label(String text) {
    return Text(text, style: GoogleFonts.urbanist(
      textStyle: TextStyle(
        color: Color(0xff6E6E6E),
        fontSize: 9,
        fontWeight: FontWeight.w600,
      ),
    ));
  }

  Widget value(String text) {
    return Text(text, style: GoogleFonts.urbanist(
      textStyle: TextStyle(
        color: Color(0xff989898),
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    ));
  }
  Widget withdrawButton(Size size) {
    return GestureDetector(
      onTap: isLoading
          ? null
          : () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RE_add_account(withdrawalAmount: valletAmount),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: size.width * 0.03),
        height: 45,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(11),
          color: isLoading ? Colors.blue.withOpacity(0.4) : Color(0xff4770CB),
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
    );
  }
  Widget headerWidget(Size size) {
    return Row(
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
    );
  }
  Widget walletCard(Size size) {
    String displayValletAmount = '₹${formatCurrency(valletAmount)}';
    String cardFooterText = '# ${_userName ?? 'User'}';

    return Container(
      width: size.width,
      height: 198,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            'assets/images/My_Chits/withdraw_card.png',
          ),
          fit: BoxFit.fill,
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
                displayValletAmount,
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
              cardFooterText,
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
    );
  }
}