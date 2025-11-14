import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:user_app/Investments/Gold/Buy%20Gold/confirmation_receipt_for_buy_gold.dart';
import '../../../Models/Investments/Gold/buy_gold_model.dart';
import '../../../Services/secure_storage.dart';
import 'package:shimmer/shimmer.dart';

class confirm_your_buying extends StatefulWidget {
  final double selectedGrams;
  final double EstimatedValue; // The amount user will pay (in Rupees)
  final double CurrentPrice;   // Current gold rate per gram

  const confirm_your_buying({
    super.key,
    required this.selectedGrams,
    required this.EstimatedValue,
    required this.CurrentPrice,
  });

  @override
  State<confirm_your_buying> createState() => _confirm_your_buyingState();
}

class _confirm_your_buyingState extends State<confirm_your_buying> {
  bool isLoading = false;
  String? _statusMessage;
  Color _statusColor = Colors.transparent;
  String? _currentOrderId; // 🔑 Store the generated Order ID

  // --- Razorpay Variables & Endpoints ---
  late Razorpay _razorpay;

  // ⚠ REPLACE WITH YOUR ACTUAL KEY ID
  static const String _razorpayKeyId = "rzp_test_RdXmFYwsCqyYkW";

  // 🔑 Endpoint for Order ID creation (Gold Purchase)
  static const String _orderApiUrl = "https://foxlchits.com/api/OrderRequest/create-generic-order";

  // 🔑 Payment Confirmation API (Used on payment success to confirm and fulfill gold)
  static const String _confirmPaymentApiUrl = "https://foxlchits.com/api/RazorpayPayment/confirm-and-buy";

  double gstPercent = 0;   // <-- Will update from API
  bool isTaxLoading = true;
  double serviceCharge = 0;
  bool isServiceChargeLoading = true;



  // --- Initialization and Disposal ---
  @override
  void initState() {
    super.initState();
    _fetchTaxFromApi();
    _fetchServiceCharge();
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
  Future<void> _fetchServiceCharge() async {
    try {
      final response = await http.get(
        Uri.parse("https://foxlchits.com/api/Termsconditions/Forbidden"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          serviceCharge = (data[0]["amount"] ?? 0).toDouble();
          isServiceChargeLoading = false;
        });
      } else {
        setState(() => isServiceChargeLoading = false);
      }
    } catch (e) {
      print("SERVICE CHARGE API ERROR: $e");
      setState(() => isServiceChargeLoading = false);
    }
  }

  Future<void> _fetchTaxFromApi() async {
    try {
      final response = await http.get(
        Uri.parse("https://foxlchits.com/api/Termsconditions/Tax"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Assuming API always returns a list with at least one object
        setState(() {
          gstPercent = (data[0]["taxs"] ?? 0).toDouble();
          isTaxLoading = false;
        });
      } else {
        setState(() => isTaxLoading = false);
      }
    } catch (e) {
      print("TAX API ERROR: $e");
      setState(() => isTaxLoading = false);
    }
  }

  // --- Razorpay Handlers ---
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    _updateStatus("Payment Successful. Confirming purchase with server...", const Color(0xffD4B373));

    // 🔑 Log the Order ID received from the successful payment
    print('DEBUG HANDLER: Order ID from Response: ${response.orderId}');

    // Call the dedicated confirmation API
    await _confirmPaymentAndFulfill(response.paymentId, response.orderId); // Pass Order ID from response
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() => isLoading = false);

    String errorMsg;
    if (response.message?.contains("user cancelled") == true) {
      errorMsg = "Payment cancelled by user.";
    } else {
      errorMsg = "Payment failed. Code: ${response.code}";
    }

    _updateStatus(errorMsg, const Color(0xFFE53935));
    _showFailureDialog(errorMsg);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _updateStatus("External Wallet Selected: ${response.walletName}", const Color(0xFFFFA726));
  }

  // --- Helper Methods ---

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

  void _showFailureDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xff1F1F1F),
          title: Text(
            "Transaction Failed ❌",
            style: GoogleFonts.urbanist(color: Colors.redAccent, fontWeight: FontWeight.bold),
          ),
          content: Text(
            message,
            style: GoogleFonts.urbanist(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "OK",
                style: GoogleFonts.urbanist(color: const Color(0xffD4B373), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  double _calculateFinalGrams(double enteredAmount, double currentPrice) {
    final double gstAmount = enteredAmount * (gstPercent / 100);
    final double netAmount = enteredAmount - gstAmount - serviceCharge;
    return netAmount / currentPrice;
  }

  void _navigateToReceipt(double gramsToBuy) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => confirmation_receipt_for_buy_gold_now(
          goldAmount: widget.EstimatedValue,
          estimate: widget.selectedGrams,
          format: "Digital Gold",
          gstPercent: gstPercent,
          serviceCharge: serviceCharge,
          totalGoldValue: gramsToBuy,
        ),
      ),
    );
  }

  // --- Core Logic: Confirm Payment and Fulfill Purchase ---
  // Updated to accept orderId from the payment success handler
  Future<void> _confirmPaymentAndFulfill(String? paymentId, String? orderId) async {
    final userId = await SecureStorageService.getProfileId();
    final amountInBaseUnit = widget.EstimatedValue.round();

    // Use the orderId passed from the handler, falling back to the stored state
    final finalOrderId = orderId ?? _currentOrderId;

    if (userId == null || finalOrderId == null) {
      _updateStatus("Internal Error: Order ID or User ID missing.", Colors.red);
      setState(() => isLoading = false);
      return;
    }

    try {
      // 1. Prepare request body for the final confirmation API
      final Map<String, dynamic> requestBody = {
        "profileId": userId,
        "amount": amountInBaseUnit,
        "paymentId": paymentId,
        "orderId": finalOrderId, // 🔑 Sending the Order ID
      };

      // 🔑 DEBUG: Log the Confirmation Payload
      print('DEBUG CONFIRMATION: Payload: ${jsonEncode(requestBody)}');

      final token = await SecureStorageService.getToken();
      final headers = {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      };

      // 2. Call the Confirmation API
      final response = await http.post(
        Uri.parse(_confirmPaymentApiUrl),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      final responseBody = jsonDecode(response.body);
      final String message = responseBody['message']?.toString() ?? 'An unknown error occurred during confirmation.';

      if (response.statusCode == 200 || response.statusCode == 201) {
        final double gramsToBuy = _calculateFinalGrams(widget.EstimatedValue, widget.CurrentPrice);
        _updateStatus("✅ Gold Purchased Successfully!", const Color(0xffD4B373));

        _navigateToReceipt(gramsToBuy);

      } else {
        String errorMessage = responseBody['message'] ?? "Purchase failed: Contact support with payment ID and order ID.";
        _updateStatus("Confirmation Failed!", Colors.red);
        _showFailureDialog(errorMessage);
      }
    } catch (e) {
      _updateStatus("Confirmation Error: Failed to reach server. ${e.toString()}", Colors.redAccent);
      _showFailureDialog("Confirmation Error: Network or server issue.");
    } finally {
      setState(() => isLoading = false);
    }
  }

  // --- Payment Flow: Create Order and Open Checkout ---
  void _startPaymentFlow() async {
    setState(() => isLoading = true);
    _statusMessage = null;
    _currentOrderId = null; // Reset Order ID at start of new flow

    try {
      final userId = await SecureStorageService.getProfileId();
      final token = await SecureStorageService.getToken();

      if (userId == null) {
        throw Exception("User not found. Please login again.");
      }

      // --- Get Transaction Amount ---
      final double rawAmount = widget.EstimatedValue;
      final int amountInBaseUnit = rawAmount.round();

      if (amountInBaseUnit <= 0) {
        throw Exception("Invalid transaction amount.");
      }

      // 🔑 Step 1: Call backend to create Razorpay Order ID
      final Map<String, dynamic> orderBody = {
        "profileId": userId,
        "amount": amountInBaseUnit,
      };

      final headers = {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      };

      final orderResponse = await http.post(
        Uri.parse(_orderApiUrl),
        headers: headers,
        body: jsonEncode(orderBody),
      );

      // Error Handling for Order Creation
      if (orderResponse.statusCode != 200 && orderResponse.statusCode != 201) {
        String apiMessage = orderResponse.body;
        try {
          apiMessage = jsonDecode(orderResponse.body)['message'] ?? apiMessage;
        } catch (_) {}
        throw Exception("Order API failed. Status: ${orderResponse.statusCode}. Message: $apiMessage");
      }

      final orderResponseBody = jsonDecode(orderResponse.body);
      final String orderId = orderResponseBody['orderId']?.toString() ?? '';

      if (orderId.isEmpty) {
        throw Exception("Order ID missing in response. Check backend response structure.");
      }

      // 🔑 CRITICAL: Store the Order ID for use in the confirmation step
      _currentOrderId = orderId;

      // 🔑 Step 2: Open Razorpay Checkout
      // Amount is sent to Razorpay in PAISE (base unit * 100)
      _openRazorpayCheckout(orderId, amountInBaseUnit * 100);

    } catch (e) {
      print("❌ Error starting payment: $e");
      _updateStatus("Error: Failed to start payment. ${e.toString().split(':')[0]}", Colors.redAccent);
      setState(() => isLoading = false);
    }
  }

  // --- Razorpay Checkout Launcher ---
  Future<void> _openRazorpayCheckout(String orderId, int amountInPaise) async {
    // 🔑 FIX: Retrieve prefill data securely
    final email = await SecureStorageService.getMail();
    final mobilenumber = await SecureStorageService.getMobileNumber();

    var options = {
      'key': _razorpayKeyId,
      'amount': amountInPaise, // PAISE
      'order_id': orderId,     // REQUIRED
      'name': 'FoxlChits Gold',
      'description': 'Purchase Digital Gold',
      'prefill': {
        // Use retrieved data, defaulting to empty string if null
        'contact': mobilenumber ?? '',
        'email': email ?? '',
      },
      'theme': {'color': '#D4B373'},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print("Error launching Razorpay: $e");
      _updateStatus("Error launching payment interface.", Colors.redAccent);
      setState(() => isLoading = false);
    }
  }


  // --- Build Methods (Omitted for brevity) ---

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    final double enteredAmount = widget.EstimatedValue;
    final double goldRate = widget.CurrentPrice;

    final double finalGrams = !isTaxLoading && !isServiceChargeLoading
        ? _calculateFinalGrams(enteredAmount, goldRate)
        : 0;
      if (isTaxLoading || isServiceChargeLoading) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                SizedBox(height: 25),

                // Title shimmer
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade800,
                  highlightColor: Colors.grey.shade600,
                  child: Container(
                    width: 180,
                    height: 22,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),

                SizedBox(height: 25),

                // Main card shimmer
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade900,
                  highlightColor: Colors.grey.shade700,
                  child: Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.45,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                SizedBox(height: 25),

                // Button shimmer
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade800,
                  highlightColor: Colors.grey.shade600,
                  child: Container(
                    width: double.infinity,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    return  Scaffold(
      backgroundColor: const Color(0xff000000),
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
                      'Confirm your buying',
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

                // --- Booking Details ---
                Container(
                  width: double.infinity,
                  height: size.height * 0.45 + (size.height * 0.01),
                  decoration: BoxDecoration(
                    color: const Color(0xff1F1F1F),
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(
                      color: const Color(0xff61512B),
                      width: 0.5,
                    ),
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
                          'Please review your buying details before confirming',
                          style: GoogleFonts.urbanist(
                            textStyle: const TextStyle(
                              color: Color(0xffDDDDDD),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(height: size.height * 0.02),

                        // --- Details ---
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.04,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDetailRow("Gold Amount", "₹${widget.EstimatedValue.toStringAsFixed(0)}"),
                              _buildDetailRow("Estimate", "${widget.selectedGrams.toStringAsFixed(2)}g"),
                              _buildDetailRow("Format", "Digital Gold"),
                              _buildDetailRow("GST", "$gstPercent%"),
                              _buildDetailRow("Service Fee", "₹$serviceCharge"),

                              SizedBox(height: size.height * 0.025),
                              const Divider(color: Color(0xff61512B), height: 1),
                              SizedBox(height: size.height * 0.025),

                              _buildDetailRow(
                                "Total Gold Value",
                                "${finalGrams.toStringAsFixed(3)} g",
                                highlight: true,
                              ),

                              SizedBox(height: size.height * 0.035),

                              // --- Alert ---
                              Container(
                                width: double.infinity,
                                height: 30,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: const Color(0xff515151),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(width: size.width * 0.03),
                                    Image.asset(
                                      'assets/images/Investments/alert_2.png',
                                      width: 16,
                                      height: 16,
                                    ),
                                    SizedBox(width: size.width * 0.03),
                                    Expanded(
                                      child: Text(
                                        'By confirming, you agree to buying ${finalGrams.toStringAsFixed(3)}g of digital gold.',
                                        style: GoogleFonts.urbanist(
                                          textStyle: const TextStyle(
                                            color: Color(0xff989898),
                                            fontSize: 9,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: size.height * 0.025),

                              // --- Confirm Button ---
                              GestureDetector(
                                onTap: (isLoading || isTaxLoading || isServiceChargeLoading)
                                    ? null
                                    : _startPaymentFlow,
                                child: Container(
                                  width: double.infinity,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(11),
                                    color: isLoading
                                        ? const Color(0xffA09068)
                                        : const Color(0xffD4B373),
                                  ),
                                  child: Center(
                                    child: isLoading
                                        ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        color: Color(0xff544B35),
                                        strokeWidth: 3,
                                      ),
                                    )
                                        : Text(
                                      'Confirm to Pay',
                                      style: GoogleFonts.urbanist(
                                        textStyle: const TextStyle(
                                          color: Color(0xff544B35),
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
                      ],
                    ),
                  ),
                ),
                // Payment Status Banner
                _buildStatusBanner(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Helper for displaying key-value rows
  Widget _buildDetailRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.urbanist(
              textStyle: TextStyle(
                color: highlight
                    ? const Color(0xffD1AF74)
                    : const Color(0xff989898),
                fontSize: highlight ? 14 : 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.urbanist(
              textStyle: TextStyle(
                color: highlight
                    ? const Color(0xffD1AF74)
                    : const Color(0xff989898),
                fontSize: highlight ? 14 : 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Payment Status Banner Definition
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
}