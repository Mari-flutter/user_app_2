import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // 🔑 1. Import Secure Storage
import 'package:user_app/Investments/Real_Estate/real_estate_Details.dart';
import 'package:user_app/Investments/Real_Estate/withdraw_for_realestate_screen.dart';

class real_estate_investment extends StatefulWidget {
  const real_estate_investment({super.key});

  @override
  State<real_estate_investment> createState() => real_estate_investmentState();
}

class real_estate_investmentState extends State<real_estate_investment> {
  // 🔑 2. Initialize Flutter Secure Storage
  final storage = const FlutterSecureStorage();

  List<Map<String, dynamic>> activeInvestments = [];
  double totalInvested = 0.0;
  double totalRoiEarned = 0.0;
  double annualRoiPercentage = 0.0;
  int totalinvestments = 0;
  bool isLoading = true;
  String? _currentProfileId; // 🔑 NEW: Variable to hold the retrieved Profile ID

  @override
  void initState() {
    super.initState();
    loadAllData();
  }

  // Combined loading function for both APIs
  Future<void> loadAllData() async {
    setState(() => isLoading = true);

    // 🔑 Read Profile ID FIRST
    _currentProfileId = await storage.read(key: 'profileId');
    print("🔑 Retrieved Profile ID: $_currentProfileId");

    // Use Future.wait to execute both API calls simultaneously
    await Future.wait([
      fetchRealEstateData(),
      fetchInvestmentSummary(),
    ]);

    // Set loading to false once both are complete
    setState(() => isLoading = false);
  }

  // Function to fetch the list of active investments (Unchanged logic)
  Future<void> fetchRealEstateData() async {
    const String apiUrl = "https://foxlchits.com/api/REInvestment";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      print("🔹 API Status Code: ${response.statusCode}");
      print("🔹 API Response: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        setState(() {
          activeInvestments = data.map<Map<String, dynamic>>((item) {
            return {
              'imagePath':
              item['imagePaths'] != null && item['imagePaths'].isNotEmpty
                  ? "https://foxlchits.com${item['imagePaths'][0]}"
                  : 'assets/images/Investments/land_sample_2.png',
              'planName': item['name'] ?? 'N/A',
              'duration': '${item['minimumDuration'] ?? 0} months',
              'roi': '${item['roiPercentage'] ?? 0}%',
              'invested': '₹${item['targetAmount'] ?? 0}',
              'roiEarned': '₹${item['otherCharges'] ?? 0}',
              'monthlyRoi':
              '₹${((item['roiPercentage'] ?? 0) / 12).toStringAsFixed(0)}',
              'points': [
                'Property Type: ${item['propertyType'] ?? 'N/A'}',
                'Location: ${item['location'] ?? 'N/A'}',
                'Maturity Date: ${item['maturityDate'] ?? 'N/A'}',
              ],
              'data': item,
            };
          }).toList();
        });
      } else {
        print("❌ Error: ${response.statusCode}");
      }
    } catch (e) {
      print("⚠ Exception (RE Investments): $e");
    }
  }

  // 🔑 Function to fetch and process the total investment summary
  Future<void> fetchInvestmentSummary() async {
    // 🔑 If profile ID is missing, we cannot proceed.
    if (_currentProfileId == null || _currentProfileId!.isEmpty) {
      print("❌ Error: Profile ID not found in secure storage.");
      return;
    }

    // 🔑 USE THE DYNAMICALLY RETRIEVED PROFILE ID
    final String apiUrl = "https://foxlchits.com/api/JoinToREInvestment/by-profile/$_currentProfileId";

    try {
      final response = await http.get(Uri.parse(apiUrl));

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

  // Helper to format currency
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
      backgroundColor: const Color(0xff000000),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: size.width,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  'assets/images/Investments/realestate_background.png',
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: size.height * 0.02),
                  // ... (Header Row)
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Image.asset(
                          'assets/images/My_Chits/back_arrow.png',
                          width: 24,
                          height: 24,
                        ),
                      ),
                      SizedBox(width: size.width * 0.03),
                      Text(
                        'Investments',
                        style: GoogleFonts.urbanist(
                          color: const Color(0xffE2E2E2),
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: size.width * 0.05),
                      GestureDetector(
                        onTap: () {},
                        child: AnimatedContainer(
                          height: 20,
                          width: 70,
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xff1D3D74), Color(0xff071020)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              'Real Estate',
                              style: GoogleFonts.urbanist(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: size.height * 0.02),

                  // Top Card (Total Invested)
                  Container(
                    width: double.infinity,
                    height: 194,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                          'assets/images/Investments/realestate_card.png',
                        ),
                        fit: BoxFit.fill,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.05,
                        vertical: size.height * 0.03,
                      ),
                      child: isLoading
                          ? _buildSummaryShimmer(size)
                          : Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total Invested',
                                    style: GoogleFonts.urbanist(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '₹${formatCurrency(totalInvested)}',
                                    style: GoogleFonts.urbanist(
                                      color: Colors.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '${annualRoiPercentage.toStringAsFixed(2)}% Annual ROI',
                                    style: GoogleFonts.urbanist(
                                      color: const Color(0xff07C66A),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total ROI Earned',
                                    style: GoogleFonts.urbanist(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '₹${formatCurrency(totalRoiEarned)}',
                                    style: GoogleFonts.urbanist(
                                      color: const Color(0xff07C66A),
                                      fontSize: 30,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: size.height * 0.04),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Number of Investments : $totalinvestments',
                                style: GoogleFonts.urbanist(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                    const withdraw_for_realestate(),
                                  ),
                                ),
                                child: Container(
                                  width: 73,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: const Color(0xff07C66A),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Withdraw',
                                      style: GoogleFonts.urbanist(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
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

                  SizedBox(height: size.height * 0.02),
                  Text(
                    'Active Investments',
                    style: GoogleFonts.urbanist(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),

                  // Shimmer effect while loading for list
                  if (isLoading)
                    Column(
                      children: List.generate(
                        2,
                            (index) => Shimmer.fromColors(
                          baseColor: Colors.grey.shade800,
                          highlightColor: Colors.grey.shade600,
                          child: Container(
                            margin:
                            EdgeInsets.only(bottom: size.height * 0.02),
                            height: 400,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade900,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    Column(
                      children: List.generate(activeInvestments.length, (
                          index,
                          ) {
                        final item = activeInvestments[index];
                        return Column(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(11),
                                topRight: Radius.circular(11),
                              ),
                              child: Image.network(
                                item['imagePath'],
                                width: double.infinity,
                                height: 174,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    'assets/images/Investments/land_sample_2.png',
                                    width: double.infinity,
                                    height: 174,
                                    fit: BoxFit.cover,
                                  );
                                },
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              height: 290,
                              margin: EdgeInsets.only(
                                bottom: size.height * 0.02,
                              ),
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(
                                    'assets/images/Investments/realestatecard_2.png',
                                  ),
                                  fit: BoxFit.fill,
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: size.width * 0.05,
                                  vertical: size.height * 0.015,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['planName'],
                                      style: GoogleFonts.urbanist(
                                        color: const Color(0xff6FA7FF),
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '${item['duration']} @ ${item['roi']} ROI',
                                      style: GoogleFonts.urbanist(
                                        color: const Color(0xffDBDBDB),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: size.height * 0.01),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildInfoColumn(
                                            'Investment Amount',
                                            item['invested'],
                                          ),
                                        ),
                                        SizedBox(width: size.width * 0.03),
                                        Expanded(
                                          child: _buildInfoColumn(
                                            'Monthly ROI percentage',
                                            item['roi'],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: size.height * 0.02),
                                    ...item['points'].map<Widget>((text) {
                                      return Padding(
                                        padding:
                                        const EdgeInsets.only(bottom: 4),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.play_arrow_rounded,
                                              color: Color(0xff6FA7FF),
                                              size: 16,
                                            ),
                                            SizedBox(width: size.width * 0.02),
                                            Expanded(
                                              child: Text(
                                                text,
                                                style: GoogleFonts.urbanist(
                                                  color: const Color(
                                                    0xffDBDBDB,
                                                  ),
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),

                                    SizedBox(height: size.height * 0.02),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                InvestmentPlanDetailScreen(
                                                  planDetails: item['data']!,
                                                ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        height: 38,
                                        decoration: BoxDecoration(
                                          color: const Color(0xff6FA7FF),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Center(
                                          child: Text(
                                            'View More Details',
                                            style: GoogleFonts.urbanist(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
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
                        );
                      }),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget for the summary card shimmer effect (Unchanged logic)
  Widget _buildSummaryShimmer(Size size) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade800,
      highlightColor: Colors.grey.shade600,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 80, height: 13, color: Colors.grey.shade900),
                  SizedBox(height: 8),
                  Container(width: 120, height: 30, color: Colors.grey.shade900),
                  SizedBox(height: 4),
                  Container(width: 90, height: 10, color: Colors.grey.shade900),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 80, height: 13, color: Colors.grey.shade900),
                  SizedBox(height: 8),
                  Container(width: 120, height: 30, color: Colors.grey.shade900),
                ],
              ),
            ],
          ),
          SizedBox(height: size.height * 0.04),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(width: 180, height: 14, color: Colors.grey.shade900),
              Container(width: 73, height: 22, color: Colors.grey.shade900),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.urbanist(
            color: const Color(0xffDBDBDB),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.urbanist(
            color: const Color(0xff6FA7FF),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}