import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class my_investment_realestate extends StatefulWidget {
  final int totalMonths;
  final int completedMonths;

  const my_investment_realestate({
    super.key,
    required this.totalMonths,
    required this.completedMonths,
  });

  @override
  State<my_investment_realestate> createState() =>
      _my_investment_realestateState();
}

class _my_investment_realestateState extends State<my_investment_realestate> {
  // 🔑 API Constants and Storage
  final storage = const FlutterSecureStorage();
  static const String _apiUrlBase =
      "https://foxlchits.com/api/JoinToREInvestment/by-profile";
  static const String _imageBaseUrl = "https://foxlchits.com";

  // 🔑 NEW API URL for Exit
  static const String _exitApiUrl =
      "https://foxlchits.com/api/JoinToREInvestment/exit";

  // 🔑 State Variables for dynamic data
  List<Map<String, dynamic>> active = [];
  List<Map<String, dynamic>> history = [];

  // Summary Data
  int joinedCount = 0;
  double roiSum = 0.0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchInvestmentData();
  }

  // --- API LOGIC: EXIT INVESTMENT ---
  Future<void> exitInvestment(Map<String, dynamic> item) async {
    final investmentId = item['investmentId'];
    setState(() => isLoading = true); // Start loading while exiting

    try {
      final String? profileId = await storage.read(key: 'profileId');

      if (profileId == null || investmentId == null) {
        throw Exception("Profile ID or Investment ID is missing.");
      }

      final Map<String, dynamic> requestBody = {
        "profileId": profileId,
        "investmentId": investmentId,
      };

      print("🎯 EXIT API CALL: Ending Plan $investmentId");
      print("   Body: ${jsonEncode(requestBody)}");

      final response = await http.post(
        Uri.parse(_exitApiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      final responseBody = jsonDecode(response.body);
      final message =
          responseBody['message']?.toString() ?? 'An unknown error occurred.';

      // Handle specific responses
      if (response.statusCode == 200) {
        // Success response logic
        if (message.contains("Exited investment successfully")) {
          // 1. Show Success Message
          _showFinalStatusDialog(
            context,
            'Success',
            'Plan ended successfully. Credited Amount: ₹${formatCurrency(responseBody['creditedAmount'] ?? 0.0)}',
            const Color(0xff07C66A),
          );

          // 2. Update local state: Move item to history
          setState(() {
            active.removeWhere((i) => i['investmentId'] == investmentId);

            // Create a history item copy and mark as exited
            Map<String, dynamic> exitedItem = Map.from(item);
            exitedItem['hasExited'] = true;
            history.add(exitedItem);
          });
        } else {
          // Unexpected success message (e.g., already exited)
          _showFinalStatusDialog(context, 'Notice', message, Colors.orange);
        }
      } else {
        // Handle failure/error messages
        String displayMessage = 'Failed to end plan: $message';

        if (message.contains(
          "cannot exit this investment before the minimum duration completes",
        )) {
          displayMessage =
          'Cannot leave investment before Minimum Duration Period.';
        }

        _showFinalStatusDialog(
          context,
          'Error',
          displayMessage,
          const Color(0xFFE53935),
        );
      }
    } catch (e) {
      print("⚠ Exception during exit: $e");
      _showFinalStatusDialog(
        context,
        'Critical Error',
        'Network error or internal failure: $e',
        const Color(0xFFE53935),
      );
    } finally {
      // Re-fetch all data to refresh summary cards and ensure server sync
      fetchInvestmentData();
    }
  }

  // Helper for displaying final status after API call (replaces simple dialog/snackbar)
  void _showFinalStatusDialog(
      BuildContext context,
      String title,
      String message,
      Color color,
      ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xffD9D9D9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
          title: Text(
            title,
            style: GoogleFonts.urbanist(
              fontSize: 18,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            message,
            style: GoogleFonts.urbanist(
              color: const Color(0xff434343),
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: GoogleFonts.urbanist(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // 🔑 API Function to fetch and process investment data (remains mostly the same)
  Future<void> fetchInvestmentData() async {
    setState(() => isLoading = true);

    try {
      final String? profileId = await storage.read(key: 'profileId');

      if (profileId == null || profileId.isEmpty) {
        print("❌ ERROR: Profile ID not found in secure storage.");
        setState(() => isLoading = false);
        return;
      }

      final String apiUrl = '$_apiUrlBase/$profileId';

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> investments = data['investments'] ?? [];

        List<Map<String, dynamic>> newActive = [];
        List<Map<String, dynamic>> newHistory = [];

        for (var item in investments) {
          final isExited = item['hasExited'] ?? false;
          final totalDuration = item['durationMonths'] ?? 1;
          final rawTargetAmount =
              (item['targetAmount'] as num?)?.toDouble() ?? 0.0;
          final rawTotalInvested =
              (item['totalAddedAmount'] as num?)?.toDouble() ?? 0.0;
          final rawRoiSum = (item['roiSum'] as num?)?.toDouble() ?? 0.0;
          final roiPercentageValue =
              (item['roiPercentage'] as num?)?.toDouble() ?? 0.0;

          final minimumduration = (item["minimumDuration"] as num);
          final joinDate =
              DateTime.tryParse(item['joinDate'] ?? '') ?? DateTime.now();
          final maturityDate =
              DateTime.tryParse(item['maturityDate'] ?? '') ?? DateTime.now();

          // Calculate duration in months passed (Transaction Count - 1)
          final int transactionsCount =
              (item['transactionsCount'] as int?) ?? 0;
          int completedMonths = (transactionsCount - 1)
              .clamp(0, totalDuration)
              .toInt();

          // --- ROI EARNED CALCULATION (Total Added - Target) ---
          final double roiEarnedDifference = rawTotalInvested - rawTargetAmount;
          final String roiEarnedDisplay =
              '₹${formatCurrency(roiEarnedDifference)}';

          // --- MONTHLY ROI CALCULATION (Target Amount * ROI % / 100) ---
          double estimatedMonthlyRoi = 0.0;
          if (rawTargetAmount > 0) {
            estimatedMonthlyRoi = (rawTargetAmount * roiPercentageValue / 100);
          }
          final monthlyRoiDisplay = '₹${formatCurrency(estimatedMonthlyRoi)}';

          final mappedItem = {
            'minimumduration' : minimumduration,
            'investmentId': item['investmentId'],
            'image': item['imagePaths'] != null && item['imagePaths'].isNotEmpty
                ? '$_imageBaseUrl${item['imagePaths'][0]}'
                : 'assets/images/My_Investments/land_sample_pic.jpg',
            'planName': item['name'] ?? 'N/A',
            'hasExited': isExited,
            'totalMonths': totalDuration,
            'completedMonths': completedMonths,
            'startDate': DateFormat('MMM yyyy').format(joinDate),
            'maturity': DateFormat('MMM yyyy').format(maturityDate),
            'roiPercentage': item['roiPercentage'] ?? 'N/A',
            'targetAmountDisplay': '₹${formatCurrency(rawTargetAmount)}',
            'roiEarned': roiEarnedDisplay,
            'monthlyRoi': monthlyRoiDisplay,
            'data': item,


          };

          if (isExited || completedMonths >= totalDuration) {
            newHistory.add(mappedItem);
          } else {
            newActive.add(mappedItem);
          }
        }

        setState(() {
          joinedCount = data['joinedCount'] ?? 0;
          roiSum = (data['roiSum'] as num?)?.toDouble() ?? 0.0;
          active = newActive;
          history = newHistory;
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
  }

  // Helper to format currency (remains unchanged)
  String formatCurrency(double amount) {
    if (amount.isNaN || amount.isInfinite) return '0';
    return NumberFormat('#,##0', 'en_IN').format(amount);
  }

  // Helper Shimmer Widget (remains unchanged)
  Widget _buildShimmerCard(Size size) {
    return Container(
      width: double.infinity,
      height: 292,
      margin: EdgeInsets.only(bottom: size.height * 0.02),
      decoration: BoxDecoration(
        color: const Color(0xff1D1D1D),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade800,
        highlightColor: Colors.grey.shade600,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 120,
                color: Colors.black,
              ),
              const SizedBox(height: 10),
              Container(width: 200, height: 15, color: Colors.black),
              const SizedBox(height: 10),
              Container(width: double.infinity, height: 4, color: Colors.black),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(width: 80, height: 13, color: Colors.black),
                  Container(width: 80, height: 13, color: Colors.black),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Summary Cards ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Active Investments (Joined Count)
            _summaryCard(
              size,
              'Active Investments',
              isLoading
                  ? '...'
                  : active.length
                  .toString(), // Use active list count for accuracy
            ),
            // Total ROI Earned (using the API's roiSum for the summary card)
            _summaryCard(
              size,
              'Total ROI Earned',
              isLoading ? '...' : '₹${formatCurrency(roiSum)}',
            ),
          ],
        ),
        SizedBox(height: size.height * 0.02),

        // --- Active Investments Section ---
        Text(
          'Active Investments',
          style: GoogleFonts.urbanist(
            color: const Color(0xffAFC9FF),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: size.height * 0.02),

        // Active List / Shimmer
        isLoading
            ? _buildShimmerList(size, count: 2)
            : active.isEmpty
            ? _buildEmptyState('No active investments yet. Start a new plan!')
            : Column(
          children: List.generate(active.length, (index) {
            final item = active[index];
            final progress =
                (item['completedMonths'] as int) /
                    (item['totalMonths'] as int);
            return _investmentCard(
              context,
              size,
              progress,
              item,
              isCompleted: false,
              onCancelPlan: () =>
                  _showCancelDialog(context, size, item, index),
            );
          }),
        ),

        SizedBox(height: size.height * 0.02),

        // --- Completed Investments Section ---
        Text(
          'Completed/Exited Investments',
          style: GoogleFonts.urbanist(
            color: const Color(0xffAFC9FF),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: size.height * 0.03),

        // History List / Empty State
        isLoading
            ? _buildShimmerList(size, count: 1)
            : history.isEmpty
            ? _buildEmptyState('No completed or exited investments.')
            : Column(
          children: List.generate(history.length, (index) {
            final item = history[index];
            return _investmentCard(
              context,
              size,
              1.0,
              item,
              isCompleted: true,
              isCanceled: item['hasExited'] ?? false,
            );
          }),
        ),
      ],
    );
  }

  // Helper for Summary Cards (Unchanged)
  Widget _summaryCard(Size size, String title, String value) {
    return Container(
      width: size.width * 0.45,
      height: 68,
      decoration: BoxDecoration(
        color: const Color(0xff323B48),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: size.height * 0.01,
          horizontal: size.width * 0.04,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.urbanist(
                textStyle: const TextStyle(
                  color: Color(0xffDBDBDB),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              value,
              style: GoogleFonts.urbanist(
                textStyle: const TextStyle(
                  color: Color(0xff5B8EF8),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper for Investment Card (Fixed logic, uses item data)
  Widget _investmentCard(
      BuildContext context,
      Size size,
      double progress,
      Map<String, dynamic> item, {
        required bool isCompleted,
        bool isCanceled = false,
        VoidCallback? onCancelPlan,
      }) {
    // Determine the image source
    Widget imageWidget;
    final imagePath =
        item['image'] ?? 'assets/images/My_Investments/land_sample_pic.jpg';

    bool isNetwork = imagePath.startsWith('http');

    if (isNetwork) {
      imageWidget = Image.network(
        imagePath,
        width: double.infinity,
        height: 174,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          'assets/images/My_Investments/land_sample_pic.jpg',
          width: double.infinity,
          height: 174,
          fit: BoxFit.cover,
        ),
      );
    } else {
      imageWidget = Image.asset(
        imagePath,
        width: double.infinity,
        height: 174,
        fit: BoxFit.cover,
      );
    }

    // Apply darkening effect if completed or canceled
    if (isCompleted || isCanceled) {
      imageWidget = ColorFiltered(
        colorFilter: ColorFilter.mode(
          Colors.black.withOpacity(0.5),
          BlendMode.darken,
        ),
        child: imageWidget,
      );
    }

    // Determine the duration text
    String durationText;
    if (isCompleted) {
      durationText = 'Completed';
    } else {
      durationText =
      '${item['completedMonths']} of ${item['totalMonths']} months completed';
    }

    return Column(
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(11),
                topRight: Radius.circular(11),
              ),
              child: imageWidget,
            ),
            // Canceled Overlay Text
            if (isCanceled)
              Positioned.fill(
                child: Center(
                  child: Text(
                    'Plan Canceled by User',
                    style: GoogleFonts.urbanist(
                      color: const Color(0xffFFFFFF),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            // Plan Name Overlay
            Positioned(
              top: 10,
              left: 10,
              child: Text(
                item['planName'] ?? 'Investment Plan',
                style: GoogleFonts.urbanist(
                  color: const Color(0xffFFFFFF),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        Container(
          width: double.infinity,
          height: isCompleted ? 240 : 292,
          margin: EdgeInsets.only(bottom: size.height * 0.02),
          decoration: const BoxDecoration(
            color: Color(0xff1D1D1D),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(11),
              bottomRight: Radius.circular(11),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.05,
              vertical: size.height * 0.02,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: size.height * 0.005),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${item['totalMonths']} months @ ${item['roiPercentage'] ?? 'N/A'}% ROI',
                      style: GoogleFonts.urbanist(
                        color: const Color(0xffFFFFFF),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "minimumDuration : ${item["minimumduration"]}",
                      style: GoogleFonts.urbanist(
                        color: const Color(0xffFFFFFF),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Duration',
                      style: GoogleFonts.urbanist(
                        color: const Color(0xffDBDBDB),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      durationText,
                      style: GoogleFonts.urbanist(
                        color: const Color(0xffDBDBDB),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.01),
                // --- Progress Bar ---
                LayoutBuilder(
                  builder: (context, constraints) {
                    final width =
                        constraints.maxWidth * progress.clamp(0.0, 1.0);
                    return Container(
                      width: double.infinity,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xffE5E5E5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Stack(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 600),
                            width: width,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(height: size.height * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Start Date: ${item['startDate']}',
                      style: GoogleFonts.urbanist(
                        color: const Color(0xffFFFFFF),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Maturity: ${item['maturity']}',
                      style: GoogleFonts.urbanist(
                        color: const Color(0xffFFFFFF),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.035),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 1. Target Amount
                    _infoColumn(
                      'Target Amount',
                      item['targetAmountDisplay'] ?? 'N/A',
                    ),

                    // 2. ROI Earned (Total Added - Target)
                    _infoColumn('ROI Earned', item['roiEarned'] ?? 'N/A'),

                    // 3. Monthly ROI (Calculated from Target Amount)
                    _infoColumn('Monthly ROI', item['monthlyRoi'] ?? 'N/A'),
                  ],
                ),
                SizedBox(height: size.height * .02),
                // End Plan Button (Only visible if NOT completed)
                if (!isCompleted)
                  Align(
                    alignment: Alignment.bottomRight,
                    child: GestureDetector(
                      onTap: () => _showCancelDialog(
                        context,
                        size,
                        item,
                        -1,
                        onCancelPlan: onCancelPlan,
                      ),
                      child: Container(
                        width: 66,
                        height: 26,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                          gradient: const LinearGradient(
                            colors: [Color(0xff2C5DC2), Color(0xff4C71BC)],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'End Plan',
                            style: GoogleFonts.urbanist(
                              color: const Color(0xffFFFFFF),
                              fontSize: 12,
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
      ],
    );
  }

  // Helper for Info Columns (Unchanged)
  Widget _infoColumn(String title, String value) {
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
        Text(
          value,
          style: GoogleFonts.urbanist(
            color: const Color(0xff5B8EF8),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // Helper for Empty/No Investments State (Unchanged)
  Widget _buildEmptyState(String message) {
    return Column(
      children: [
        const SizedBox(height: 30),
        Center(
          child: Image.asset(
            'assets/images/My_Investments/no_completed_investment.png',
            width: 48,
            height: 48,
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: Text(
            message,
            style: GoogleFonts.urbanist(
              color: const Color(0xff8D8D8D),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // Helper for Shimmer List (Uses existing _buildShimmerCard)
  Widget _buildShimmerList(Size size, {required int count}) {
    return Column(
      children: List.generate(count, (index) => _buildShimmerCard(size)),
    );
  }

  // Dialog Logic (Fixed signature and usage)
  void _showCancelDialog(
      BuildContext context,
      Size size,
      Map<String, dynamic> item,
      int index, {
        VoidCallback? onCancelPlan,
      }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xffD9D9D9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
          content: SizedBox(
            height: 150,
            child: Column(
              children: [
                Text(
                  'Confirmation',
                  style: GoogleFonts.urbanist(
                    fontSize: 16,
                    color: const Color(0xff000000),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                const Divider(height: 1, color: Color(0xffC0C0C0)),
                SizedBox(height: size.height * 0.02),
                Text(
                  'Are you sure you want to end the plan: ${item['planName']}?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.urbanist(
                    color: const Color(0xff434343),
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(width: size.width * 0.05),
                    // Cancel Button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 57,
                        height: 26,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                          color: const Color(0xff8B8B8B),
                        ),
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.urbanist(
                              color: const Color(0xffFFFFFF),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Confirm Button (MOCK ACTION)
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        // 🔑 Call the real exit function
                        exitInvestment(item);
                      },
                      child: Container(
                        width: 57,
                        height: 26,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                          gradient: const LinearGradient(
                            colors: [Color(0xff2C5DC2), Color(0xff4C71BC)],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Confirm',
                            style: GoogleFonts.urbanist(
                              color: const Color(0xffFFFFFF),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: size.width * 0.05),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}