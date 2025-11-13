import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

class InvestmentPlanDetailScreen extends StatefulWidget {
  final Map<String, dynamic> planDetails;

  const InvestmentPlanDetailScreen({
    super.key,
    required this.planDetails,
  });

  @override
  State<InvestmentPlanDetailScreen> createState() => _InvestmentPlanDetailScreenState();
}

class _InvestmentPlanDetailScreenState extends State<InvestmentPlanDetailScreen> {
  // --- State Variables and Storage ---
  final storage = const FlutterSecureStorage();
  bool _isJoining = false;
  String? _statusMessage;
  Color _statusColor = Colors.transparent;

  static const String _joinApiUrl = "https://foxlchits.com/api/JoinToREInvestment/join";

  // --- Helper Methods ---

  String _safeGet(String key, {String defaultValue = 'N/A'}) {
    return widget.planDetails[key]?.toString() ?? defaultValue;
  }

  String _safeGetDate(String key, {String defaultValue = 'N/A'}) {
    final rawDate = widget.planDetails[key]?.toString();
    if (rawDate != null && rawDate.length >= 10) {
      return rawDate.substring(0, 10);
    }
    return defaultValue;
  }

  // Helper method to update the status banner
  void _updateStatus(String message, Color color) {
    setState(() {
      _statusMessage = message;
      _statusColor = color;
    });
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && _statusMessage == message) {
        setState(() {
          _statusMessage = null;
        });
      }
    });
  }

  // --- Core Logic: Joining the Investment ---
  Future<void> joinInvestment() async {
    setState(() {
      _isJoining = true;
      _statusMessage = null;
    });

    try {
      final String? profileId = await storage.read(key: 'profileId');
      final String? investmentId = widget.planDetails['id']?.toString();
      final String planName = _safeGet('name');

      if (profileId == null || investmentId == null) {
        print("❌ DEBUG JOIN: Missing required IDs. Profile ID: $profileId, Investment ID: $investmentId");
        throw Exception("Missing required IDs for joining.");
      }

      final Map<String, dynamic> requestBody = {
        "profileId": profileId,
        "investmentId": investmentId,
      };

      print("🎯 API CALL: Joining Plan '$planName'");
      print("   URL: $_joinApiUrl");
      print("   Body: ${jsonEncode(requestBody)}");

      final response = await http.post(
        Uri.parse(_joinApiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      print("✅ Response Status Code: ${response.statusCode}");
      print("   Response Body: ${response.body}");

      final responseBody = jsonDecode(response.body);
      final String message = responseBody['message']?.toString() ?? 'An unknown error occurred.';

      const Color successColor = Color(0xff07C66A);
      const Color errorColor = Color(0xFFE53935);
      const Color warningColor = Color(0xFFFFA726);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (message.contains("joined investment successfully")) {
          _updateStatus("You have joined this investment successfully.", successColor);
        } else if (message.contains("User already joined")) {
          _updateStatus("You are already an active member in this Investment.", warningColor);
        } else {
          print("⚠ Unexpected 200 Message: $message");
          _updateStatus("Join successful", successColor);
        }
      } else {
        if (message.contains("already matured")) {
          _updateStatus("The investment plan is going to end soon. You cannot join this investment.", errorColor);
        } else if (message.contains("User already joined")) {
          _updateStatus("You are already an active member in this Investment.", warningColor);
        } else {
          _updateStatus("Failed to join investment: $message", errorColor);
        }
      }
    } catch (e) {
      print("❌ DEBUG JOIN CATCH: ${e.toString()}");
      _updateStatus("Error: Failed to process join request. ${e.toString()}", Colors.redAccent);
    } finally {
      setState(() {
        _isJoining = false;
      });
    }
  }

  // --- Build Methods ---

  @override
  Widget build(BuildContext context) {
    const Color darkBackground = Color(0xFF000000);
    const Color buttonBackground = Color(0xFF444444);
    const Color primaryText = Color(0xFFFFFFFF);
    const Color accentColor = Color(0xFF6FA7FF);

    final String planName = _safeGet('name', defaultValue: 'Fixed Term Plan');
    final String location = _safeGet('location'); // Still used in details grid
    final String targetAmount = '₹${_safeGet('targetAmount', defaultValue: '0')}';
    final String maturityDate = _safeGetDate('maturityDate');
    final String duration = _safeGet('minimumDuration', defaultValue: 'N/A');
    final String roiPercentage = _safeGet('roiPercentage', defaultValue: '0%');
    final String otherCharges = _safeGet('otherCharges', defaultValue: '0.00');
    final String description = _safeGet('description', defaultValue: 'No description available for this plan.');
    final String termsAndConditions = description;

    return Scaffold(
      backgroundColor: darkBackground,
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(top: 8),
        color: darkBackground,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusBanner(),
            _buildSubscribeButton(),
          ],
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildNavButton(
                      child: const Icon(Icons.arrow_back_ios_new, size: 16, color: Color(0xFFDBDBDB)),
                      onTap: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 2. Image Card (Location text removed from here)
                ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: Container(
                    width: double.infinity,
                    height: 387,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                          widget.planDetails['imagePaths'] != null && widget.planDetails['imagePaths'].isNotEmpty
                              ? "https://foxlchits.com${widget.planDetails['imagePaths'][0]}"
                              : 'https://via.placeholder.com/380x387/000000/FFFFFF?text=PLAN+IMAGE',
                        ),
                        fit: BoxFit.cover,
                        colorFilter: const ColorFilter.mode(
                          Colors.black54,
                          BlendMode.darken,
                        ),
                      ),
                    ),
                    // 🔑 Removed the Center widget containing the Location Text
                  ),
                ),
                const SizedBox(height: 20),

                // 3. Plan Name and Subtitle
                Text(
                  planName,
                  style: GoogleFonts.urbanist(fontSize: 22, fontWeight: FontWeight.w600, color: accentColor),
                ),
                const SizedBox(height: 4),
                Text(
                  "$duration months @ $roiPercentage ROI",
                  style: GoogleFonts.urbanist(fontSize: 15, fontWeight: FontWeight.w500, color: const Color(0xFFDBDBDB)),
                ),
                const SizedBox(height: 20),

                // 4. Plan Details Section
                _buildTitleContainer("Plan Details", buttonBackground),
                const SizedBox(height: 12),

                _buildDetailsGrid(
                  maturityDate,
                  location,
                  targetAmount,
                  duration,
                  roiPercentage,
                  otherCharges,
                ),
                const SizedBox(height: 30),

                // 5. Description Section
                _buildTitleContainer("Description", buttonBackground, width: 95),
                const SizedBox(height: 16),
                Text(
                  description,
                  style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w500, height: 1.73, color: const Color(0xFFDBDBDB)),
                ),
                const SizedBox(height: 30),

                // 6. Terms & Conditions Section
                _buildTitleContainer("Terms & Conditions", buttonBackground, width: 150),
                const SizedBox(height: 16),
                Text(
                  termsAndConditions,
                  style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w500, height: 1.73, color: const Color(0xFFDBDBDB)),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required Widget child,
    required VoidCallback onTap,
    double width = 24,
    double height = 24,
    double borderRadius = 6,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }

  Widget _buildTitleContainer(String title, Color color, {double width = 100}) {
    return Container(
      width: width,
      height: 26,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Center(
        child: Text(
          title,
          style: GoogleFonts.urbanist(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFDBDBDB),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsGrid(
      String maturityDate,
      String location,
      String targetAmount,
      String duration,
      String roiPercentage,
      String otherCharges,
      ) {
    const TextStyle labelStyle = TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFFDBDBDB));
    const TextStyle valueStyle = TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF6FA7FF));

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: _buildDetailItem(label: "Maturity Date", value: maturityDate, labelStyle: labelStyle, valueStyle: valueStyle)),
            Expanded(child: _buildDetailItem(label: "Location", value: location, labelStyle: labelStyle, valueStyle: valueStyle)),
            Expanded(child: _buildDetailItem(label: "Target Amount", value: targetAmount, labelStyle: labelStyle, valueStyle: valueStyle)),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: _buildDetailItem(label: "Minimum Duration", value: duration, labelStyle: labelStyle, valueStyle: valueStyle)),
            Expanded(child: _buildDetailItem(label: "ROI Percentage", value: roiPercentage, labelStyle: labelStyle, valueStyle: valueStyle)),
            Expanded(child: _buildDetailItem(label: "Other Charges", value: otherCharges, labelStyle: labelStyle, valueStyle: valueStyle)),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailItem({
    required String label,
    required String value,
    required TextStyle labelStyle,
    required TextStyle valueStyle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: valueStyle),
        const SizedBox(height: 4),
        Text(label, style: labelStyle),
      ],
    );
  }

  Widget _buildStatusBanner() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _statusMessage != null ? 40 : 0,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: _statusColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            _statusMessage ?? '',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildSubscribeButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: ElevatedButton(
        onPressed: _isJoining ? null : joinInvestment,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7),
          ),
          backgroundColor: const Color(0xFF5A8FAB),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF5A8FAB), Color(0xFF09283A)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Container(
            constraints: const BoxConstraints(minWidth: double.infinity, minHeight: 56.0),
            alignment: Alignment.center,
            child: _isJoining
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            )
                : Text(
              'Subscribe',
              style: GoogleFonts.urbanist(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}