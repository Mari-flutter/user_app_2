import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../Receipt_Generate/investment_receipt.dart';
import '../../Services/secure_storage.dart';

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
  String? userName;
  String? userID;
  String? mobilenumber;
  String convertAmountToWords(int number) {
    if (number == 0) return "Zero Rupees Only";

    final List<String> units = [
      "",
      "One",
      "Two",
      "Three",
      "Four",
      "Five",
      "Six",
      "Seven",
      "Eight",
      "Nine",
      "Ten",
      "Eleven",
      "Twelve",
      "Thirteen",
      "Fourteen",
      "Fifteen",
      "Sixteen",
      "Seventeen",
      "Eighteen",
      "Nineteen"
    ];

    final List<String> tens = [
      "",
      "",
      "Twenty",
      "Thirty",
      "Forty",
      "Fifty",
      "Sixty",
      "Seventy",
      "Eighty",
      "Ninety"
    ];

    String twoDigit(int n) {
      if (n < 20) return units[n];
      return "${tens[n ~/ 10]} ${units[n % 10]}".trim();
    }

    String threeDigit(int n) {
      if (n == 0) return "";
      if (n < 100) return twoDigit(n);
      return "${units[n ~/ 100]} Hundred ${twoDigit(n % 100)}".trim();
    }

    String words = "";

    if ((number ~/ 10000000) > 0) {
      words += "${twoDigit(number ~/ 10000000)} Crore ";
      number %= 10000000;
    }
    if ((number ~/ 100000) > 0) {
      words += "${twoDigit(number ~/ 100000)} Lakh ";
      number %= 100000;
    }
    if ((number ~/ 1000) > 0) {
      words += "${twoDigit(number ~/ 1000)} Thousand ";
      number %= 1000;
    }
    if ((number ~/ 100) > 0) {
      words += "${twoDigit(number ~/ 100)} Hundred ";
      number %= 100;
    }
    if (number > 0) {
      words += twoDigit(number);
    }

    return "${words.trim()} Rupees Only";
  }
  // --- State Variables and Storage ---
  final storage = const FlutterSecureStorage();
  bool _isJoining = false;
  String? _statusMessage;
  Color _statusColor = Colors.transparent;
  // --- Razorpay Variables & Endpoints ---
  late Razorpay _razorpay;

  // ⚠ REPLACE WITH YOUR ACTUAL TEST/LIVE KEY ID
  static const String _razorpayKeyId = "rzp_test_RdXmFYwsCqyYkW";

  // 🔑 Order ID Creation API
  static const String _orderApiUrl = "https://foxlchits.com/api/OrderRequest/Investcreate-order";

  // 🔑 Payment Confirmation API
  static const String _confirmPaymentApiUrl = "https://foxlchits.com/api/RazorpayPayment/join-with-REINVESTpayment";

  // 🔑 NEW: Dedicated Check API
  static const String _checkJoinApiUrl = "https://foxlchits.com/api/JoinToREInvestment/check-join";

  // --- Initialization and Disposal ---
  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  // --- Razorpay Handlers ---
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    _updateStatus("Payment Successful. Confirming payment with server...", const Color(0xff07C66A));

    // Pass paymentId and orderId to the confirmation function
    await _confirmPaymentAndJoin(response.paymentId, response.orderId);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() => _isJoining = false);
    String errorMsg;
    if (response.message?.contains("user cancelled") == true) {
      errorMsg = "Payment cancelled by user.";
    } else {
      errorMsg = "Payment failed. Code: ${response.code}";
    }
    _updateStatus(errorMsg, const Color(0xFFE53935));
  }
  void _handleExternalWallet(ExternalWalletResponse response) {
    _updateStatus("External Wallet Selected: ${response.walletName}", const Color(0xFFFFA726));
  }





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

  String _monthName(int month) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return months[month - 1];
  }
  Future<void> _confirmPaymentAndJoin(String? paymentId, String? orderId) async {
    try {
      final DateTime now = DateTime.now();

      final String transactionDate =
          "${now.day.toString().padLeft(2, '0')} ${_monthName(now.month)} ${now.year}";

      int hour = now.hour;
      String period = "AM";

      if (hour >= 12) period = "PM";
      if (hour > 12) hour -= 12;
      if (hour == 0) hour = 12;

      final String transactionTime =
          "${hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} $period";

      final String? profileId = await storage.read(key: 'profileId');
      final String? investmentId = widget.planDetails['id']?.toString();

      if (profileId == null || investmentId == null) {
        throw Exception("Missing required IDs for confirmation.");
      }
      final String planName = _safeGet('name');
      final String targetAmount = _safeGet('targetAmount', defaultValue: '0');

      // Clean number → convert to int
      final cleanedValue = targetAmount.replaceAll(RegExp(r'[^0-9]'), "");
      final int numericValue = int.tryParse(cleanedValue) ?? 0;

      final String maturityDate = _safeGetDate('maturityDate');
      final String duration = _safeGet('minimumDuration', defaultValue: 'N/A');
      final String roiPercentage = _safeGet('roiPercentage', defaultValue: '0%');
      final String propertytype = _safeGet('propertyType',defaultValue: '--');
      final String otherCharges = _safeGet('otherCharges', defaultValue: '0.00');
      final String description = _safeGet('description',
          defaultValue: 'No description available for this plan.');

      final String amountInWords = convertAmountToWords(numericValue);

      // ---------------------------------------------------------
      // 📌 4. User details
      // ---------------------------------------------------------
      userName = await SecureStorageService.getUserName();
      userID = await SecureStorageService.getUserId();
      mobilenumber = await SecureStorageService.getMobileNumber();
      // Prepare request body matching the required structure
      final Map<String, dynamic> requestBody = {
        "profileID": profileId,    // Note the capital D required by API body
        "investmentId": investmentId,
        "paymentId": paymentId,
        "orderId": orderId,
      };

      final response = await http.post(
        Uri.parse(_confirmPaymentApiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      final responseBody = jsonDecode(response.body);
      final String message = responseBody['message']?.toString() ?? 'An unknown error occurred during confirmation.';

      const Color successColor = Color(0xff07C66A);
      const Color errorColor = Color(0xFFE53935);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final msg = message.toLowerCase();

        if (msg.contains("joined") && msg.contains("success")) {
          await InvestmentReceiptPDF(context, {
            'investmentName': planName,
            'propertytype': propertytype,
            'customerName': userName ?? "",
            'customerId': userID ?? "",
            'contactNumber': mobilenumber ?? "",
            'transactionDate': transactionDate,
            'transactionTime': transactionTime,
            'maturitydate': maturityDate,
            'ROI Percentage': roiPercentage,
            'Minimumduration': duration,
            'amount': targetAmount.replaceAll(RegExp(r'[^0-9]'), ""),
            'TotalAmountPaidWords': amountInWords,
          });
          _updateStatus("Payment Confirmed and Joined!", successColor);

        }
        else {
          _updateStatus("Payment Confirmed, check profile for details.", successColor);

        }
      } else {
        if (message.contains("already joined")) {
          _updateStatus("Already an active member.", Color(0xFFFFA726));

        } else {
          _updateStatus("Confirmation Failed: $message. Contact Support.", errorColor);


        }
      }

    } catch (e) {
      _updateStatus("Confirmation Error: Failed to reach server. ${e.toString()}", Colors.redAccent);
    } finally {
      setState(() {
        _isJoining = false;
      });
    }
  }

  void _openRazorpayCheckout(String orderId, int amountInPaise) async {
    final phnum = await SecureStorageService.getMobileNumber();
    final email = await SecureStorageService.getMail();
    final name = await SecureStorageService.getUserName();

    var options = {
      'key': _razorpayKeyId,
      'amount': amountInPaise,
      'order_id': orderId,
      'name': 'FoxlChits Investment',
      'description': _safeGet(name!),
      'prefill': {
        'contact': phnum,
        'email': email,
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      _updateStatus("Error launching payment interface.", Colors.redAccent);
      setState(() => _isJoining = false);
    }
  }

  // --- Pre-Check and Order Creation Trigger (Main Logic) ---
  Future<void> _startPreCheckAndPayment() async {
    setState(() {
      _isJoining = true;
      _statusMessage = null;
    });

    try {
      final String? profileId = await storage.read(key: 'profileId');
      final String? investmentId = widget.planDetails['id']?.toString();

      // Get the amount value
      final dynamic rawAmountValue = widget.planDetails['initialPaymentAmount'] ?? widget.planDetails['targetAmount'];

      // Calculate amount in Rupees (Base unit)
      final double rawAmount = double.tryParse(
          rawAmountValue?.toString().replaceAll('₹', '').replaceAll(',', '').split('.').first ?? '0'
      ) ?? 0.0;
      final int amountInRupees = rawAmount.round(); // Use round() to get the integer Rupee value

      if (profileId == null || investmentId == null || amountInRupees <= 0) {
        throw Exception("Missing required data (IDs or Amount).");
      }

      // 1. --- NEW MEMBERSHIP CHECK ---
      _updateStatus("Checking membership...", Colors.blue);

      final Map<String, dynamic> checkBody = {
        "profileId": profileId,
        "investmentId": investmentId,
      };

      final checkResponse = await http.post(
        Uri.parse(_checkJoinApiUrl), // 🔑 Using the new dedicated check API
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(checkBody),
      );

      if (checkResponse.statusCode == 200 || checkResponse.statusCode == 201) {
        final checkResponseBody = jsonDecode(checkResponse.body);
        final bool isJoined = checkResponseBody['joined'] ?? false;

        if (isJoined) {
          _updateStatus("You are already an active member in this Investment.", Color(0xFFFFA726));
          setState(() => _isJoining = false);
          return; // Stop the flow
        }
      } else {
        // If the check API itself fails, we stop, as we cannot be sure of membership status.
        final errorBody = jsonDecode(checkResponse.body);
        final errorMessage = errorBody['message'] ?? "Could not verify membership status.";
        _updateStatus("Pre-check failed: $errorMessage", Colors.redAccent);
        setState(() => _isJoining = false);
        return;
      }

      // 2. --- ORDER CREATION (If check passed) ---
      _updateStatus("Creating payment order...", Colors.blue);

      final Map<String, dynamic> orderBody = {
        "profileId": profileId,
        "investmentId": investmentId,
        "amount": amountInRupees, // Amount in Rupees
      };

      final orderResponse = await http.post(
        Uri.parse(_orderApiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(orderBody),
      );

      // --- Error Handling ---
      if (orderResponse.statusCode != 200 && orderResponse.statusCode != 201) {
        String apiMessage = orderResponse.body;
        try {
          apiMessage = jsonDecode(orderResponse.body)['message'] ?? orderResponse.body;
        } catch (_) {}

        // This should not happen since we checked above, but included as a safety fallback
        if (apiMessage.contains("User already joined")) {
          _updateStatus("You are already an active member in this Investment.", Color(0xFFFFA726));
          setState(() => _isJoining = false);
          return;
        }

        throw Exception("Order API failed. Status: ${orderResponse.statusCode}. Message: $apiMessage");
      }

      // --- Order ID Retrieval ---
      final orderResponseBody = jsonDecode(orderResponse.body);
      final String orderId = orderResponseBody['orderId']?.toString() ?? '';

      if (orderId.isEmpty) {
        throw Exception("Order ID missing in response. Check backend response structure.");
      }

      // 3. Open Checkout
      _updateStatus("Opening payment gateway...", Colors.blue);

      // CRUCIAL: Convert amount to PAISE (Rupees * 100) ONLY for the Razorpay SDK
      final int amountInPaiseForCheckout = amountInRupees * 100;
      _openRazorpayCheckout(orderId, amountInPaiseForCheckout);

    } catch (e) {
      // Final Catch Block for all exceptions
      print("❌ Order Creation Error: $e");
      _updateStatus("Payment setup failed: ${e.toString().split(':').first}", Colors.redAccent);
      setState(() => _isJoining = false);
    }
  }


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
                        fit: BoxFit.fill,
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
        Text(label, style: labelStyle),
        const SizedBox(height: 4),
        Text(value, style: valueStyle),
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
        onPressed: _isJoining ? null : _startPreCheckAndPayment,

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