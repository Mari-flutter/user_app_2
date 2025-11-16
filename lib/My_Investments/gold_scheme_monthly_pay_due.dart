import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../Services/secure_storage.dart';
import '../Models/Investments/Gold/CurrentGoldValue_Model.dart';
import '../Models/My_Investment/gold_scheme_pending_payments.dart';
import '../Receipt_Generate/gold_scheme_receipt.dart';
import '../Services/Gold_price.dart';
import 'package:shimmer/shimmer.dart';

class gold_scheme_monthly_pay_due extends StatefulWidget {
  final String schemeId; // The ID of the scheme passed to this screen

  const gold_scheme_monthly_pay_due({super.key, required this.schemeId});

  @override
  State<gold_scheme_monthly_pay_due> createState() =>
      _gold_scheme_monthly_pay_dueState();
}

class _gold_scheme_monthly_pay_dueState
    extends State<gold_scheme_monthly_pay_due> {
  // --- State Variables ---
  bool isDownloading = false;
  String? UserName;
  String? UserId;
  String? UserMobileNumber;
  String convertionDate = '';
  List<GoldSchemeDueModel> duePayments = [];
  bool isGoldLoading = true;
  bool isDueLoading = true;
  CurrentGoldValue? _goldValue;

  // --- Razorpay Setup & Endpoints ---
  late Razorpay _razorpay;
  static const String _razorpayKeyId = "rzp_test_RdXmFYwsCqyYkW";

  // 🔑 Order Creation API
  static const String _orderApiUrl = "https://foxlchits.com/api/OrderRequest/gold-scheme-create-order";

  // 🔑 Payment Confirmation API
  static const String _confirmPaymentApiUrl = "https://foxlchits.com/api/RazorpayPayment/confirm-and-pay-scheme";


  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    convertionDate =
    "${now.day.toString().padLeft(2, '0')} ${_monthName(now.month)} ${now.year}";
    _loadProfileId();

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

  // ... (inside _gold_scheme_monthly_pay_dueState)

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    print('--- RAZORPAY SUCCESS CALLBACK START ---');
    print('PAYMENT ID: ${response.paymentId}');
    print('ORDER ID: ${response.orderId}');

    final profileId = await SecureStorageService.getProfileId();

    // CRITICAL: We need the data from the payment that was just made.
    // Assuming the duePayments list still holds the installment data that
    // was used to create the order, which should be the first item.
    final GoldSchemeDueModel? nextDueInstallment = duePayments.isNotEmpty ? duePayments.first : null;

    if (profileId == null || nextDueInstallment == null) {
      _showSnackBar('Error: Context missing after payment. (Missing user data or due installment details)', Colors.red);
      // Even if context is missing, attempt to confirm payment based on the received IDs
      if (profileId != null) {
        await _confirmPayment(
            profileId: profileId,
            schemeId: widget.schemeId,
            paymentId: response.paymentId,
            orderId: response.orderId
        );
      }
      // Reload data in case payment was confirmed
      fetchDueData();
      return;
    }

    _showSnackBar('Payment successful. Confirming payment and generating receipt...', Colors.green);

    // 1. CONFIRM PAYMENT with your backend
    await _confirmPayment(
        profileId: profileId,
        schemeId: widget.schemeId,
        paymentId: response.paymentId,
        orderId: response.orderId
    );

    // 2. GENERATE PDF RECEIPT

    // Calculate the amount in words
    final amountInWords = convertAmountToWords(nextDueInstallment.totalPaid.round());

    // Calculate Gold Grams
    double goldRate = _goldValue?.goldValue ?? 0; // ₹ per gram
    double grams = 0;

    if (goldRate > 0) {
      // totalPaid is the payment amount, which should be the monthly contribution
      // Note: If totalPaid is the scheme total, use nextDueInstallment.contribution instead.
      // Based on the 'handlePayNow' logic: amountInRupees = data.totalPaid.round()
      // It seems 'totalPaid' is used as the amount for this installment.
      grams = nextDueInstallment.totalPaid / goldRate;
    }

    // Generate the PDF
    await GoldschemeReceiptPDF(context, {
      'customerName': UserName ?? '',
      'contactNumber': UserMobileNumber ?? '',
      'customerId': UserId ?? '',
      'transactionDate': convertionDate,
      // Safely format time (optional, can be done better)
      'transactionTime': "${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}",

      'goldDetails': grams.toStringAsFixed(3), // e.g. 3.333 g
      'NextDueDate': nextDueInstallment.nextDueDate,
      'totalinvested': nextDueInstallment.totalPaid.toStringAsFixed(2),
      'schemename': nextDueInstallment.schemeName,
      'GoldRate': _goldValue?.goldValue.toStringAsFixed(2) ?? "0.00",
      'amountinWords': amountInWords,
    });

    // 3. RELOAD DATA after confirmation and receipt generation attempt
    fetchDueData();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print('--- RAZORPAY ERROR CALLBACK START ---');
    print('ERROR CODE: ${response.code}');
    print('ERROR MESSAGE: ${response.message}');

    _showSnackBar('Payment failed. Try again.', Colors.redAccent);
    setState(() => isDownloading = false);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _showSnackBar('External Wallet Selected.', Colors.yellow);
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  // --- Final Confirmation Logic ---
  Future<void> _confirmPayment({
    required String profileId,
    required String schemeId,
    required String? paymentId,
    required String? orderId,
  }) async {
    try {
      final Map<String, dynamic> requestBody = {
        "profileId": profileId,
        "schemeId": schemeId,
        "paymentId": paymentId,
        "orderId": orderId,
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
        _showSnackBar('Monthly contribution confirmed!', Colors.green);
      } else {
        final message = jsonDecode(response.body)['message'] ?? 'Server error during finalization.';
        _showSnackBar('Error confirming payment: $message', Colors.red);
      }
    } catch (e) {
      print('❌ CONFIRMATION EXCEPTION: $e');
      _showSnackBar('Network error during final confirmation: $e', Colors.red);
    }
  }

  // --- Payment Initiation Logic (Order Creation) ---
  void _handlePayNow(GoldSchemeDueModel data) async {
    if (isDownloading) return;
    setState(() => isDownloading = true);

    try {
      final profileId = await SecureStorageService.getProfileId();
      if (profileId == null) {
        _showSnackBar('User not logged in.', Colors.red);
        return;
      }

      final amountInRupees = data.totalPaid.round();

      // 1. Prepare Order Body
      final Map<String, dynamic> orderBody = {
        "profileId": profileId,
        "schemeId": widget.schemeId, // Use the schemeId from the Widget
        "amount": amountInRupees,
      };

      // 2. Call Order API
      _showSnackBar('Creating payment order...', Colors.blue);
      final Token = await SecureStorageService.getToken();
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

      if (orderResponse.statusCode != 200 && orderResponse.statusCode != 201) {
        String errorMessage = orderResponse.body.isNotEmpty
            ? jsonDecode(orderResponse.body)['message'] ?? 'Order API failed.'
            : 'Order API failed: Empty response on non-200/201 status.';
        _showSnackBar('Order setup failed: $errorMessage', Colors.red);
        return;
      }

      final orderResponseBody = jsonDecode(orderResponse.body);
      final String orderId = orderResponseBody['orderId']?.toString() ?? '';

      if (orderId.isEmpty) {
        throw Exception("Order ID missing from response.");
      }

      // 3. Open Razorpay Checkout
      final int amountInPaiseForCheckout = amountInRupees * 100;

      _openRazorpayCheckout(orderId, amountInPaiseForCheckout, data.schemeName);

    } catch (e) {
      print('❌ PAYMENT SETUP EXCEPTION: $e');
      _showSnackBar('Payment setup failed: ${e.toString()}', Colors.red);
    } finally {
      setState(() => isDownloading = false);
    }
  }

  // --- Razorpay Checkout Launcher ---
  void _openRazorpayCheckout(String orderId, int amountInPaise, String schemeName) {
    // Note: Fetch actual user contact/email from SecureStorage here if needed

    var options = {
      'key': _razorpayKeyId,
      'amount': amountInPaise,
      'order_id': orderId,
      'name': 'FoxlChits Gold',
      'description': 'Monthly Contribution for $schemeName',
      'prefill': {
        'contact': UserMobileNumber ?? '9876543210',
        'email': UserName ?? 'user@demo.com',
      },
      'theme': {'color': '#F8C545'},
    };

    try {
      _razorpay.open(options);
      // Loading remains TRUE until payment handler fires
    } catch (e) {
      _showSnackBar('Error launching Razorpay: $e', Colors.red);
    }
  }


  // --- Data Loading and Helper Methods (Omitted for brevity) ---
  Future<void> _loadProfileId() async {
    final username = await SecureStorageService.getUserName();
    final userId = await SecureStorageService.getUserId();
    final userMobileNumber = await SecureStorageService.getMobileNumber();
    setState(() {
      UserName = username;
      UserId = userId;
      UserMobileNumber = userMobileNumber;
    });
    _loadGoldValue();
    fetchDueData();
  }

  Future<void> _loadGoldValue() async {
    try {
      final cachedValue = await GoldService.getCachedGoldValue();

      if (cachedValue != null) {
        setState(() {
          _goldValue = cachedValue;
          isGoldLoading = false;
        });
      }

      final latestValue = await GoldService.fetchAndCacheGoldValue();

      setState(() {
        _goldValue = latestValue ?? _goldValue;
        isGoldLoading = false;
      });

    } catch (e) {
      setState(() {
        isGoldLoading = false;
      });
    }
  }


  Future<void> fetchDueData() async {
    try {
      final profileId = await SecureStorageService.getProfileId();

      final url =
          "https://foxlchits.com/api/SchemeMember/pending/user/$profileId/scheme/${widget.schemeId}";

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        // We only show the next single payment due
        duePayments = data.map((e) => GoldSchemeDueModel.fromJson(e)).toList();
      }

    } catch (e) {
      print("Error loading API: $e");

    } finally {
      setState(() {
        isDueLoading = false;
      });
    }
  }


  String _monthName(int month) {
    const months = [
      "January", "February", "March", "April", "May", "June", "July", "August",
      "September", "October", "November", "December",
    ];
    return months[month - 1];
  }

  String convertAmountToWords(int number) {
    if (number == 0) return "Zero Rupees Only";
    final List<String> units = ["", "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Ten", "Eleven", "Twelve", "Thirteen", "Fourteen", "Fifteen", "Sixteen", "Seventeen", "Eighteen", "Nineteen",];
    final List<String> tens = ["", "", "Twenty", "Thirty", "Forty", "Fifty", "Sixty", "Seventy", "Eighty", "Ninety",];
    String twoDigit(int n) {
      if (n < 20) return units[n];
      return "${tens[n ~/ 10]} ${units[n % 10]}".trim();
    }
    String words = "";
    if ((number ~/ 10000000) > 0) { words += "${twoDigit(number ~/ 10000000)} Crore "; number %= 10000000; }
    if ((number ~/ 100000) > 0) { words += "${twoDigit(number ~/ 100000)} Lakh "; number %= 100000; }
    if ((number ~/ 1000) > 0) { words += "${twoDigit(number ~/ 1000)} Thousand "; number %= 1000; }
    if ((number ~/ 100) > 0) { words += "${twoDigit(number ~/ 100)} Hundred "; number %= 100; }
    if (number > 0) { words += twoDigit(number); }
    return "${words.trim()} Rupees Only";
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

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
                child: (isGoldLoading || isDueLoading)
                    ? ListView.builder(
                  itemCount: 6,
                  itemBuilder: (context, index) {
                    return shimmerCard(size);
                  },
                )
                    : duePayments.isEmpty
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
                    final item = duePayments[index];
                    return _buildSchemeCard(size, item);
                  },
                ),
              )

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSchemeCard(Size size, GoldSchemeDueModel data) {
    // 🔑 FIX: Assuming the schemeId on the model is named 'id' or that the list only contains this scheme
    // final bool isNextDue = duePayments.isNotEmpty && duePayments.first.schemeId == widget.schemeId;

    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xff232323),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.schemeName,
            style: GoogleFonts.urbanist(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6),

          _info("Next Due Date", data.nextDueDate),
          _info("Monthly Contribution", "₹${data.contribution}"),
          _info("Duration", "${data.duration} months"),

          SizedBox(height: 10),

          Align(
            alignment: AlignmentGeometry.centerRight,
            child: GestureDetector(
              onTap: () {
                _handlePayNow(data); // Calls the payment initializer
              },
              child: Container(
                width: 110,
                height: 36,
                decoration: BoxDecoration(
                  color: isDownloading ? Colors.grey : Color(0xff3A7AFF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    isDownloading ? "Processing..." : "Pay Due",
                    style: GoogleFonts.urbanist(
                      color: Colors.white,
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
    );
  }

  Widget _info(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: Colors.white70, fontSize: 13)),
          Text(value, style: TextStyle(color: Colors.white, fontSize: 13)),
        ],
      ),
    );
  }

  Widget shimmerCard(Size size) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xff1E1E1E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade800,
        highlightColor: Colors.grey.shade700,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 140, height: 18, color: Colors.white),
            SizedBox(height: 10),
            Container(width: 220, height: 14, color: Colors.white),
            SizedBox(height: 10),
            Container(width: 180, height: 14, color: Colors.white),
            SizedBox(height: 10),
            Container(width: 120, height: 14, color: Colors.white),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: 110,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}