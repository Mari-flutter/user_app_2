import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:user_app/Bottom_Navbar/bottom_navigation_bar.dart';
import '../../Models/My_Chits/explore_chit_model.dart';
import '../../Services/secure_storage.dart';

class chit_monthly_pay_due extends StatefulWidget {
  final List<ExploreChit> paymentHistory;
  final String chitID; // Passed Chit ID

  const chit_monthly_pay_due({
    super.key,
    required this.chitID,
    required this.paymentHistory,
  });

  @override
  State<chit_monthly_pay_due> createState() => _chit_monthly_pay_dueState();
}

class _chit_monthly_pay_dueState extends State<chit_monthly_pay_due> {

  // --- Razorpay Setup ---
  late Razorpay _razorpay;
  static const String _razorpayKeyId = "rzp_test_RdXmFYwsCqyYkW";

  // 🔑 Order Creation API (Updated to the correct URL format)
  static const String _orderApiUrl = "https://foxlchits.com/api/OrderRequest/chit-Payment-create-order";

  // 🔑 Final Payment Confirmation API
  static const String _confirmPaymentApiUrl = "https://foxlchits.com/api/RazorpayPayment/confirm-and-pay-chit";


  // Helper to format DateTime to DD-MM-YYYY
  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    if (date is DateTime) {
      final dateString = date.toLocal().toString().split(' ')[0];
      try {
        final parts = dateString.split('-');
        return '${parts[2]}-${parts[1]}-${parts[0]}';
      } catch (e) {
        return dateString;
      }
    }
    return date.toString();
  }

  @override
  void initState() {
    super.initState();
    // Initialize Razorpay
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
    print('--- RAZORPAY SUCCESS CALLBACK START ---');

    final profileId = await SecureStorageService.getProfileId();
    final paymentId = response.paymentId;
    final orderId = response.orderId;

    // Get the installment details (we assume the user is only paying the first due one)
    final nextDueInstallment = widget.paymentHistory.firstWhere((chit) => chit.paid == false, orElse: () => throw Exception("No due installment found."));
    final auctionNumber = nextDueInstallment.action;

    print('SUCCESS DATA - Profile ID: $profileId, Payment ID: $paymentId, Order ID: $orderId, Auction: $auctionNumber');

    if (profileId == null) {
      _showSnackBar('Error: Profile ID missing for confirmation.', Colors.red);
      return;
    }

    // 2. Call the final confirmation API
    await _finalizePayment(profileId, widget.chitID, auctionNumber, paymentId, orderId);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print('--- RAZORPAY ERROR CALLBACK START ---');
    print('ERROR CODE: ${response.code}');
    print('ERROR MESSAGE: ${response.message}');

    final msg = response.message?.contains("user cancelled") == true
        ? "Payment cancelled by user."
        : "Payment failed. Code: ${response.code}";
    _showSnackBar(msg, Colors.red);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('EXTERNAL WALLET SELECTED: ${response.walletName}');
    _showSnackBar('External Wallet Selected: ${response.walletName}', Colors.yellow);
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  /// 🔑 STEP 3: Final Confirmation API Call
  Future<void> _finalizePayment(
      String profileId,
      String chitId,
      int auctionNumber,
      String? paymentId,
      String? orderId
      ) async {
    _showSnackBar('Confirming payment status...', Colors.orange);
    try {
      final Map<String, dynamic> requestBody = {
        "profileID": profileId,
        "chitID": chitId,
        "paymentId": paymentId,
        "orderId": orderId,
        "auction": auctionNumber, // 🔑 Auction Number
      };

      // 🛑 DEBUGGING FINAL PAYLOAD 🛑
      print('--- CONFIRMATION API REQUEST ---');
      print('URL: $_confirmPaymentApiUrl');
      print('PAYLOAD SENT: ${jsonEncode(requestBody)}');
      final Token = await SecureStorageService.getToken();
      final response = await http.post(
        Uri.parse(_confirmPaymentApiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $Token",
        },
        body: jsonEncode(requestBody),
      );

      // 🛑 DEBUGGING FINAL RESPONSE 🛑
      print('CONFIRMATION RESPONSE STATUS: ${response.statusCode}');
      print('CONFIRMATION RESPONSE BODY: ${response.body}');
      print('----------------------------------');

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnackBar('Payment confirmed and installment processed!', Colors.green);
        // After success, reload the list or navigate back
        Navigator.pop(context);
      } else {
        final message = jsonDecode(response.body)['message'] ?? 'Server error during finalization.';
        _showSnackBar('Error confirming payment: $message', Colors.red);
      }
    } catch (e) {
      print('❌ CONFIRMATION EXCEPTION: $e');
      _showSnackBar('Network error during final confirmation: $e', Colors.red);
    }
  }


  /// 🔑 STEP 1: Order Creation and Razorpay Launch
  Future<void> _startPaymentFlow(ExploreChit installment) async {
    final profileId = await SecureStorageService.getProfileId();
    final amountInRupees = installment.howMuchToPay.round();
    final auctionNumber = installment.action;
    final email = await SecureStorageService.getMail();
    final phnum = await SecureStorageService.getMobileNumber();

    if (profileId == null) {
      _showSnackBar('User not logged in.', Colors.red);
      return;
    }

    _showSnackBar('Creating payment order...', Colors.blue);

    try {
      // 1. Prepare Order Body
      final Map<String, dynamic> orderBody = {
        "chitID": widget.chitID,
        "profileID": profileId,
        "amount": amountInRupees,
        "auctionNumber": auctionNumber, // 🔑 Auction Number
      };
      final Token = await SecureStorageService.getToken();
      // 2. Call Order API
      final orderResponse = await http.post(
        Uri.parse(_orderApiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $Token",
        },
        body: jsonEncode(orderBody),
      );

      // 🛑 CRITICAL DEBUGGING PRINTS (Order API Response) 🛑
      print('--- ORDER API RESPONSE DEBUG ---');
      print('URL: $_orderApiUrl');
      print('PAYLOAD SENT: ${jsonEncode(orderBody)}');
      print('STATUS: ${orderResponse.statusCode}');
      print('BODY: ${orderResponse.body.isNotEmpty ? orderResponse.body : "[Empty body]"}');
      print('----------------------------------');

      // Check for non-successful status code first
      if (orderResponse.statusCode != 200 && orderResponse.statusCode != 201) {
        final msg = orderResponse.body.isNotEmpty
            ? (jsonDecode(orderResponse.body)['message'] ?? 'Order API failed (Server Error).')
            : 'Order API failed: Empty response on non-200/201 status.';
        throw Exception(msg);
      }

      // Check if body is empty before decoding
      if (orderResponse.body.isEmpty || orderResponse.body == 'null') {
        throw Exception("API returned success status but body is empty.");
      }

      final orderResponseBody = jsonDecode(orderResponse.body);
      final String orderId = orderResponseBody['orderId']?.toString() ?? '';

      if (orderId.isEmpty) {
        throw Exception("Order ID missing from response. Ensure key is 'orderId'.");
      }

      print('ORDER ID RETRIEVED FOR CHECKOUT: $orderId');

      // 3. Open Razorpay Checkout (Amount must be in PAiSE)
      final int amountInPaiseForCheckout = amountInRupees * 100;

      var options = {
        'key': _razorpayKeyId,
        'amount': amountInPaiseForCheckout,
        'order_id': orderId,
        'name': 'FoxlChits',
        'description': 'Installment Payment',
        'prefill': {
          'contact': phnum,
          'email': email,
        },
      };

      _razorpay.open(options);

    } catch (e) {
      // Catch network errors, JSON decoding errors, and custom exceptions
      print('❌ PAYMENT SETUP EXCEPTION: $e');
      _showSnackBar('Payment setup failed: ${e.toString()}', Colors.red);
    }
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final List<ExploreChit> duePayments =
    widget.paymentHistory.where((chit) => chit.paid == false).toList();

    return Scaffold(
      backgroundColor: const Color(0xff000000),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height * 0.02),
              // --- Header ---
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context); // Navigate back to explore_chit
                    },
                    child: Image.asset(
                      'assets/images/My_Chits/back_arrow.png',
                      width: 24,
                      height: 24,
                    ),
                  ),
                  SizedBox(width: size.width * 0.03),
                  Text(
                    'Installment Details',
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

              // --- List of Installment Cards ---
              Expanded(
                child:duePayments.isEmpty
                    ? Center(
                  child: Text(
                    'No pending installments.',
                    style: GoogleFonts.urbanist(
                      color: const Color(0xffDDDDDD),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
                    : ListView.builder(
                  itemCount: duePayments.length,
                  itemBuilder: (context, index) {
                    final installment = duePayments[index];
                    // The next due is always index 0 of the filtered list
                    final isNextDue = index == 0;
                    return _buildInstallmentCard(
                        size,
                        installment,
                        isNextDue
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔑 Installment Card Widget
  Widget _buildInstallmentCard(
      Size size,
      ExploreChit installment,
      bool isNextDue,
      ) {
    final statusColor = installment.paid ? const Color(0xff07C66A) : const Color(0xffC60F12);
    final dueDateDisplay = _formatDate(installment.dueDate);

    return Padding(
      padding: EdgeInsets.only(bottom: size.height * 0.02),
      child: Container(
        width: double.infinity,
        height: size.height * 0.1,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            // Use a slight highlight for the next due card
            colors:[const Color(0xff232323), const Color(0xff383836)],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.04,
            vertical: size.height * 0.01,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left Section: Amount and Date
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Installment ${installment.action}', // Use action property for installment number/label
                    style: GoogleFonts.urbanist(
                      textStyle: const TextStyle(
                        color: Color(0xffFFFFFF),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Amount: ₹${installment.howMuchToPay.toStringAsFixed(0)}',
                    style: GoogleFonts.urbanist(
                      textStyle: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _buildInfoRow(
                    "Due Date",
                    dueDateDisplay,
                    isWhite: true,
                  ),
                ],
              ),

              // Right Section: Pay Button
              if (isNextDue) // Only show Pay Due for the next due installment
                GestureDetector(
                  onTap: () => _startPaymentFlow(installment), // 🔑 Call the payment flow
                  child: Container(
                    width: 100,
                    height: 24,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7),
                      color: const Color(0xff3A7AFF),
                    ),
                    child: Center(
                      child: Text(
                        'Pay Due',
                        style: GoogleFonts.urbanist(
                          textStyle: const TextStyle(
                            color: Color(0xffFFFFFF),
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
    );
  }

  // Helper for displaying info rows
  Widget _buildInfoRow(String left, String right, {bool isWhite = false}) {
    const textColor = Color(0xffF8F8F8);
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$left: ',
            style: GoogleFonts.urbanist(
              textStyle: const TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            right,
            style: GoogleFonts.urbanist(
              textStyle: const TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}