import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:user_app/My_Investments/my_investments_screen.dart';
import 'package:user_app/widgets/noise_background_container.dart';

import '../../Helper/Local_storage_manager.dart';
import '../../Models/Investments/Gold/gold_scheme_model.dart';
import '../../Services/secure_storage.dart';

class gold_scheme extends StatefulWidget {
  const gold_scheme({super.key});

  @override
  State<gold_scheme> createState() => _gold_schemeState();
}

class _gold_schemeState extends State<gold_scheme> {
  List<GoldScheme> goldSchemes = [];
  Set<String> subscribingSchemeIds = {};

  // --- Razorpay Variables & Endpoints ---
  late Razorpay _razorpay;
  static const String _razorpayKeyId = "rzp_test_RdXmFYwsCqyYkW";

  // 🔑 Order Creation API
  static const String _orderApiUrl = "https://foxlchits.com/api/OrderRequest/GoldScheme-create-order";

  // 🔑 Payment Confirmation API
  static const String _confirmPaymentApiUrl = "https://foxlchits.com/api/RazorpayPayment/join-and-GoldSchemepay";

  // 🔑 Dedicated Membership Check API
  static const String _checkMemberApiUrl = "https://foxlchits.com/api/RazorpayPayment/scheme/check-member";


  @override
  void initState() {
    super.initState();
    loadFromCacheThenFetch();

    // Initialize Razorpay and Handlers
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

  // --- UI Feedback Methods ---

  void _showMessageBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorDialog(String title, String content) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // --- Razorpay Handlers ---

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    _showMessageBar('Payment successful. Confirming purchase...', Colors.green);

    await _confirmSubscription(
      response.paymentId,
      response.orderId,
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    String errorMsg = response.message!.contains("user cancelled")
        ? "Payment cancelled by user."
        : "Payment failed. Please try again.";
    _showErrorDialog('Payment Failed', errorMsg);

    if (subscribingSchemeIds.isNotEmpty && mounted) {
      setState(() => subscribingSchemeIds.clear());
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _showMessageBar('External Wallet Selected: ${response.walletName}', Colors.yellow);
  }

  // --- Data & API Fetch Methods (Unchanged for brevity) ---
  Future<void> loadFromCacheThenFetch() async {
    final cachedSchemes = LocalStorageManager.getGoldSchemes();
    if (cachedSchemes.isNotEmpty) {
      setState(() => goldSchemes = cachedSchemes);
    }
    fetchGoldSchemesInBackground();
  }

  Future<void> fetchGoldSchemesInBackground() async {
    final Token = await SecureStorageService.getToken();
    try {
      final response = await http.get(
        Uri.parse('https://foxlchits.com/api/GoldScheme'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $Token",
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final fetchedSchemes = data.map((e) => GoldScheme.fromJson(e)).toList();

        bool isDifferent = _isListDifferent(fetchedSchemes, goldSchemes);

        if (isDifferent) {
          await LocalStorageManager.saveGoldSchemes(fetchedSchemes);
          if (mounted) setState(() => goldSchemes = fetchedSchemes);
        }
      }
    } catch (e) {}
  }

  bool _isListDifferent(List<GoldScheme> newList, List<GoldScheme> oldList) {
    if (newList.length != oldList.length) return true;
    for (int i = 0; i < newList.length; i++) {
      if (jsonEncode(newList[i].toJson()) != jsonEncode(oldList[i].toJson())) {
        return true;
      }
    }
    return false;
  }

  // --- FINAL CONFIRMATION LOGIC (Unchanged for this step) ---
  Future<void> _confirmSubscription(String? paymentId, String? orderId) async {
    final Token = await SecureStorageService.getToken();
    final profileId = await SecureStorageService.getProfileId();

    final schemeId = subscribingSchemeIds.isNotEmpty ? subscribingSchemeIds.first : null;

    if (profileId == null || paymentId == null || orderId == null || schemeId == null) {
      _showErrorDialog('System Error', 'Missing critical transaction data (Profile/Payment IDs).');
      if (mounted) setState(() => subscribingSchemeIds.clear());
      return;
    }

    try {
      final Map<String, dynamic> requestBody = {
        "schemeId": schemeId,
        "profileId": profileId,
        "paymentId": paymentId,
        "orderId": orderId,
      };

      final response = await http.post(
        Uri.parse(_confirmPaymentApiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $Token",
        },
        body: jsonEncode(requestBody),
      );

      // Final success check
      if (response.statusCode == 200 || response.statusCode == 201) {
        _showMessageBar('Subscription successfully confirmed!', Colors.green);

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const my_investments(initialTab: 0),
          ),
        );
      } else {
        String errorMessage = jsonDecode(response.body)['message']?.toString() ?? 'Server rejected confirmation.';

        if (errorMessage.contains("already subscribed")) {
          _showMessageBar('You are already subscribed to this scheme.', Colors.orange);
        } else {
          _showErrorDialog('Confirmation Failed', 'The server could not finalize your purchase. Details: $errorMessage');
        }
      }
    } catch (e) {
      _showErrorDialog('Network Error', 'An error occurred while communicating with the confirmation server.');
    } finally {
      if (mounted) setState(() => subscribingSchemeIds.clear());
    }
  }


  // --- MAIN PAYMENT INITIATION LOGIC (REVISED FOR DEBUGGING) ---
  Future<void> subscribeToScheme(String schemeId) async {
    final profileId = await SecureStorageService.getProfileId();
    final Token = await SecureStorageService.getToken();
    final scheme = goldSchemes.firstWhere((s) => s.id == schemeId);

    if (profileId == null || profileId.isEmpty) {
      _showErrorDialog('Login Required', 'Profile not found. Please login again to subscribe.');
      return;
    }

    // Start loading for this specific scheme
    setState(() => subscribingSchemeIds.add(schemeId));

    try {
      // 1. --- MEMBERSHIP PRE-CHECK ---

      final Map<String, dynamic> checkBody = {
        "schemeId": schemeId,
        "profileId": profileId,
      };

      print('--- DEBUG CHECK API: URL: $_checkMemberApiUrl');
      print('DEBUG CHECK API: PAYLOAD: ${jsonEncode(checkBody)}');

      final checkResponse = await http.post(
        Uri.parse(_checkMemberApiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $Token",
        },
        body: jsonEncode(checkBody),
      );

      print('DEBUG CHECK API: STATUS: ${checkResponse.statusCode}');

      if (checkResponse.statusCode == 200 || checkResponse.statusCode == 201) {
        final checkResponseBody = jsonDecode(checkResponse.body);
        final bool isJoined = checkResponseBody['joined'] ?? false;

        if (isJoined) {
          // User is already a member, stop the process
          _showMessageBar('You are already joined in this scheme.', Color(0xFFFFA726));
          if (mounted) setState(() => subscribingSchemeIds.remove(schemeId));
          return;
        }
      } else {
        // If the check API itself fails, we stop, as we cannot be sure of membership status.
        // This handles cases like 400 or 500 status codes.
        String errorMessage = jsonDecode(checkResponse.body)['message'] ?? 'Check API failed. Status: ${checkResponse.statusCode}';
        print('DEBUG CHECK API: Failed body: $errorMessage');
        _showErrorDialog('Membership Check Failed', '$errorMessage');
        if (mounted) setState(() => subscribingSchemeIds.remove(schemeId));
        return;
      }

      // 2. --- ORDER CREATION ---

      final int amountInRupees = scheme.contribution.round();

      final Map<String, dynamic> orderBody = {
        "profileId": profileId,
        "schemeId": schemeId,
        "amount": amountInRupees, // Amount in Rupees/Base Unit
      };

      print('DEBUG ORDER API: URL: $_orderApiUrl');
      print('DEBUG ORDER API: PAYLOAD: ${jsonEncode(orderBody)}');

      final orderResponse = await http.post(
        Uri.parse(_orderApiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $Token",
        },
        body: jsonEncode(orderBody),
      );

      if (orderResponse.statusCode != 200 && orderResponse.statusCode != 201) {
        String errorMessage = jsonDecode(orderResponse.body)['message']?.toString() ?? 'Server rejected order creation.';
        _showErrorDialog('Order Setup Failed', errorMessage);
        if (mounted) setState(() => subscribingSchemeIds.remove(schemeId));
        return;
      }

      final orderResponseBody = jsonDecode(orderResponse.body);
      final String orderId = orderResponseBody['orderId']?.toString() ?? '';

      if (orderId.isEmpty) {
        throw Exception("Order ID missing from server response.");
      }
      print('DEBUG ORDER API: Order ID received: $orderId');


      // 3. Open Razorpay Checkout
      final int amountInPaise = amountInRupees * 100;

      _openRazorpayCheckout(orderId, amountInPaise, scheme.duration);

    } catch (e) {
      print('❌ INIT PAYMENT FINAL EXCEPTION: $e');
      _showErrorDialog('Payment Initialization Error', 'Could not start payment flow. Details: ${e.toString().split(':')[0]}');
      if (mounted) setState(() => subscribingSchemeIds.remove(schemeId));
    }
  }

  // --- Razorpay Checkout Launcher ---
  Future<void> _openRazorpayCheckout(String orderId, int amountInPaise, int duration) async {
    final email = await SecureStorageService.getMail();
    final Phnum = await SecureStorageService.getMobileNumber();

    var options = {
      'key': _razorpayKeyId,
      'amount': amountInPaise,
      'order_id': orderId,
      'name': 'FoxlChits Gold',
      'description': 'Subscription for ${duration} Month Plan',
      'prefill': {
        'contact': Phnum ?? '9876543210',
        'email': email ?? 'user@demo.com',
      },
      'theme': {'color': '#F8C545'},
    };

    try {
      print('DEBUG: Launching Razorpay with Order ID: $orderId');
      _razorpay.open(options);
    } catch (e) {
      _showErrorDialog('Razorpay Launch Failed', 'Could not open the payment window. Check your internet connection.');
      if (mounted) setState(() => subscribingSchemeIds.clear());
    }
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Image.asset(
              'assets/images/Investments/gold_scheme.png',
              width: 24,
              height: 24,
            ),
            SizedBox(width: size.width * 0.02),
            Text(
              'Schemes',
              style: GoogleFonts.urbanist(
                textStyle: const TextStyle(
                  color: Color(0xffFFFFFF),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: size.height * 0.02),
        goldSchemes.isEmpty
            ? Center(
          child: Text(
            'No gold schemes available',
            style: GoogleFonts.urbanist(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        )
            : SingleChildScrollView(
          child: Column(
            children: List.generate(goldSchemes.length, (index) {
              final scheme = goldSchemes[index];
              final isCurrentSchemeLoading = subscribingSchemeIds.contains(scheme.id);
              return Padding(
                padding: EdgeInsets.only(bottom: size.width * 0.05),
                child: NoiseBackgroundContainer(
                  height: 145,
                  dotSize: 0.5,
                  density: 1,
                  opacity: 0.15,
                  color: Colors.white,
                  child: Container(
                    width: double.infinity,
                    height: 145,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(11),
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
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${scheme.duration} Month Plan',
                                style: GoogleFonts.urbanist(
                                  textStyle: const TextStyle(
                                    color: Color(0xffFFFFFF),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                '₹${scheme.contribution.toStringAsFixed(0)}/month',
                                style: GoogleFonts.urbanist(
                                  textStyle: const TextStyle(
                                    color: Color(0xffDBDBDB),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: size.height * 0.02),
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total Value',
                                    style: GoogleFonts.urbanist(
                                      textStyle: const TextStyle(
                                        color: Color(0xffDBDBDB),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '₹${scheme.totalValue.toStringAsFixed(0)}',
                                    style: GoogleFonts.urbanist(
                                      textStyle: const TextStyle(
                                        color: Color(0xffF8C545),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(width: size.width * 0.05),
                              Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Est. Gold',
                                    style: GoogleFonts.urbanist(
                                      textStyle: const TextStyle(
                                        color: Color(0xffDBDBDB),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${scheme.estimateValue.toStringAsFixed(0)}g',
                                    style: GoogleFonts.urbanist(
                                      textStyle: const TextStyle(
                                        color: Color(0xffF8C545),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          Align(
                            alignment: Alignment.bottomRight,
                            child: GestureDetector(
                              onTap: () async {
                                if (isCurrentSchemeLoading) return;
                                await subscribeToScheme(scheme.id);
                              },
                              child: Container(
                                width: 89,
                                height: 26,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(7),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xffF8C545),
                                      Color(0xff8F7021),
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child:isCurrentSchemeLoading
                                      ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child:
                                    CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                      :  Text(
                                    'Subscribe',
                                    style: GoogleFonts.urbanist(
                                      textStyle: const TextStyle(
                                        color: Color(0xffFFFFFF),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
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
            }),
          ),
        ),
      ],
    );
  }
}