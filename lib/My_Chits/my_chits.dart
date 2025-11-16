import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:user_app/Bottom_Navbar/bottom_navigation_bar.dart';
import 'package:user_app/My_Chits/Explore_chits/explore_chit_screen.dart';
import '../Helper/Local_storage_manager.dart';
import '../Models/My_Chits/active_chits_model.dart';
import '../Models/My_Chits/requested_chits_model.dart';
import '../Services/secure_storage.dart';
import 'package:shimmer/shimmer.dart';

// ---------------------------------------------------------------------
// 🔑 my_chits StatefulWidget
// ---------------------------------------------------------------------

class my_chits extends StatefulWidget {
  final Function(int)? onTabChange;
  final int initialTab;
  const my_chits({super.key, this.onTabChange, required this.initialTab});
  @override
  State<my_chits> createState() => _my_chitsState();
}

class _my_chitsState extends State<my_chits> {
  late int _selectedIndex;
  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTab;
  }
  Future<Map<String, String?>> _getUserIds() async {
    final profileId = await SecureStorageService.getProfileId();
    final userId = await SecureStorageService.getUserId();
    if (userId == null || userId.isEmpty) {
      await SecureStorageService.updateUserAndReferIdsFromApi();
    }
    final refreshedUserId = await SecureStorageService.getUserId();
    return {'profileId': profileId ?? '', 'userId': refreshedUserId ?? ''};
  }
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (widget.onTabChange != null) {
      widget.onTabChange!(index);
    }
  }
  final List<String> chitTypeTags = ["Active Chits", "Requsted"];
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
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HomeLayout()),
                      );
                    },
                    child: Image.asset('assets/images/My_Chits/back_arrow.png', width: 24, height: 24),
                  ),
                  SizedBox(width: size.width * 0.03),
                  Text('My Chits', style: GoogleFonts.urbanist(textStyle: const TextStyle(color: Color(0xffFFFFFF), fontSize: 22, fontWeight: FontWeight.w600))),
                ],
              ),
              SizedBox(height: size.height * 0.04),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(chitTypeTags.length, (index) {
                    final bool isSelected = _selectedIndex == index;
                    return GestureDetector(
                      onTap: () => _onItemTapped(index),
                      child: Container(
                        height: 25,
                        margin: const EdgeInsets.only(right: 13),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xff3A7AFF).withOpacity(0.76) : const Color(0xff262626).withOpacity(0.76),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: size.width * 0.02, vertical: size.height * 0.003),
                          child: Text(chitTypeTags[index], style: GoogleFonts.urbanist(textStyle: const TextStyle(color: Color(0xffFFFFFF), fontSize: 14, fontWeight: FontWeight.w500))),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              SizedBox(height: size.height * 0.03),
              Expanded(
                child: _selectedIndex == 0
                    ? FutureBuilder(
                  future: _getUserIds(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    final ids = snapshot.data!;
                    return ActiveChitsPage(profileId: ids['profileId'] ?? '', userId: ids['userId'] ?? '');
                  },
                )
                    : FutureBuilder(
                  future: _getUserIds(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    final ids = snapshot.data!;
                    return RequestedChitsPage(profileId: ids['profileId'] ?? '', userId: ids['userId'] ?? '');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// 🔑 ActiveChitsPage (LOGIC RESTORED AND CORRECT)
// ---------------------------------------------------------------------
class ActiveChitsPage extends StatefulWidget {
  final String profileId;
  final String userId;
  const ActiveChitsPage({super.key, required this.profileId, required this.userId});
  @override
  State<ActiveChitsPage> createState() => _ActiveChitsPageState();
}

class _ActiveChitsPageState extends State<ActiveChitsPage> {
  bool _isLoadedOnce = false;
  bool isLoading = true;
  List<ActiveChit> activeChits = [];

  @override
  void initState() {
    super.initState();
    if (!_isLoadedOnce) {
      _loadActiveChits();
      _isLoadedOnce = true;
    }
  }

  Future<void> _loadActiveChits() async {
    setState(() => isLoading = true);
    final Token = await SecureStorageService.getToken();
    try {
      final url = Uri.parse(
        "https://foxlchits.com/api/JoinToChit/profile/${widget.profileId}/chits?userID=${widget.userId}",
      );
      print('🌍 Active Chits API URL: $url');

      final response = await http.get(url,headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $Token",
      },);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final freshList = data.map((e) => ActiveChit.fromJson(e)).toList();

        if (freshList.isNotEmpty) {
          // ✅ API returned data — show & cache it
          // print('📦 Saving fresh active chits data.');
          // NOTE: Ensure your LocalStorageManager methods are correct
          await LocalStorageManager.saveActiveChitsApi(freshList, widget.userId);
          if (mounted) setState(() => activeChits = freshList);
        } else {
          // ❌ API returned empty — show "No chits"
          if (mounted) setState(() => activeChits = []);
        }
      } else {
        // print('⚠ API error: ${response.statusCode}');
        // 🌐 fallback to cache only if available
        final cached = LocalStorageManager.getActiveChitsApi(widget.userId);
        if (cached.isNotEmpty) {
          // print('📦 Showing cached chits due to API error');
          if (mounted) setState(() => activeChits = cached);
        } else {
          if (mounted) setState(() => activeChits = []);
        }
      }
    } catch (e) {
      // print('❌ Exception while fetching active chits: $e');
      // 🌐 fallback to cache only if available
      final cached = LocalStorageManager.getActiveChitsApi(widget.userId);
      if (cached.isNotEmpty) {
        // print('📦 Showing cached chits due to network error');
        if (mounted) setState(() => activeChits = cached);
      } else {
        if (mounted) setState(() => activeChits = []);
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return RefreshIndicator(
      color: Colors.white,
      backgroundColor: const Color(0xff3A7AFF),
      onRefresh: _loadActiveChits,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: isLoading
            ? Column(
          children: List.generate(4, (index) {
            return Shimmer.fromColors(
              baseColor: const Color(0xff2A2A2A),
              highlightColor: const Color(0xff3A3A3A),
              child: Container(
                width: double.infinity,
                height: size.height * 0.22,
                margin:
                EdgeInsets.only(bottom: size.height * 0.02),
                decoration: BoxDecoration(
                  color: const Color(0xff2A2A2A),
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            );
          }),
        )
            : activeChits.isEmpty
            ? Center(
          child: Column(
            children: [
              SizedBox(height: size.height * 0.15),
              Image.asset(
                'assets/images/My_Chits/no_active chits.png',
                width: 232,
                height: 232,
              ),
              SizedBox(height: size.height * 0.04),
              Text(
                "No active chits available right now!",
                style: GoogleFonts.urbanist(
                  color: const Color(0xffBBBBBB),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        )
            : Column(
          children: activeChits.map((chit) {
            return Padding(
              padding: EdgeInsets.only(bottom: size.height * 0.02),
              child: Column(
                children: [
                  // 🔹 Chit Card (Top section)
                  Container(
                    width: double.infinity,
                    height: size.height * 0.21,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Color(0xff232323), Color(0xff383836)],
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
                          // Title Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                chit.chitsName,
                                style: GoogleFonts.urbanist(
                                  textStyle: const TextStyle(
                                    color: Color(0xff3A7AFF),
                                    fontSize: 28,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                chit.chitsType,
                                style: GoogleFonts.urbanist(
                                  textStyle: const TextStyle(
                                    color: Color(0xffB5B4B4),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: size.height * 0.01),
                          // Info Rows
                          _buildInfoRow(
                            "Chit Value : ₹${chit.value.toStringAsFixed(0)}",
                            "Mon.Contribution : ₹${chit.contribution.toStringAsFixed(0)}",
                          ),
                          _buildInfoRow(
                            "Total Members : ${chit.totalMember}",
                            "Joined : ${chit.currentMemberCount}/${chit.totalMember}",
                          ),
                          _buildInfoRow(
                            "Duration : ${chit.timePeriod} months",
                            "Due Date : ${chit.duedate.toLocal().toString().split(' ')[0]}",
                          ),
                          SizedBox(height: size.height * 0.01),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => explore_chit(
                                      completedMonths: 3,
                                      chitValue: chit.value,
                                      totalContribution:chit.contribution,
                                      timePeriod: chit.timePeriod,
                                      otherCharges: chit.otherCharges ?? 0.0,
                                      penalty: chit.penalty ?? 0.0,
                                      taxes: chit.taxes ?? 0.0,
                                      chitId: chit.id,
                                      chitName : chit.chitsName,
                                      chitType : chit.chitsType,
                                      TotalMembers : chit.totalMember,
                                      CurrentMember : chit.currentMemberCount,
                                      auctionSchedules: chit.auctionSchedules,
                                      auctionDateTime: chit.duedate.toIso8601String(),
                                      formancommission:chit.commission,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                width: 78,
                                height: 24,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(7),
                                  color: const Color(0xffFFFFFF),
                                ),
                                child: Center(
                                  child: Text(
                                    'Explore',
                                    style: GoogleFonts.urbanist(
                                      textStyle: const TextStyle(
                                        color: Color(0xff000000),
                                        fontSize: 12,
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
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String left, String right) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            left,
            style: GoogleFonts.urbanist(
              textStyle: const TextStyle(
                color: Color(0xffF8F8F8),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            right,
            style: GoogleFonts.urbanist(
              textStyle: const TextStyle(
                color: Color(0xffF8F8F8),
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


// ---------------------------------------------------------------------
// 🔑 RequestedChitsPage (Payment Logic)
// ---------------------------------------------------------------------

class RequestedChitsPage extends StatefulWidget {
  final String profileId;
  final String userId;

  const RequestedChitsPage({
    super.key,
    required this.profileId,
    required this.userId,
  });

  @override
  State<RequestedChitsPage> createState() => _RequestedChitsPageState();
}

class _RequestedChitsPageState extends State<RequestedChitsPage> {
  bool _isLoadedOnce = false;
  List<RequestedChitModel> requestedChits = [];
  bool isLoading = true;

  // --- Razorpay Variables & Endpoints ---
  late Razorpay _razorpay;
  static const String _razorpayKeyId = "rzp_test_RdXmFYwsCqyYkW";

  static const String _orderApiUrl = "https://foxlchits.com/api/OrderRequest/chit-create-order";
  static const String _confirmPaymentApiUrl = "https://foxlchits.com/api/RazorpayPayment/chit-join-with-payment";

  String? _statusMessage;
  Color _statusColor = Colors.transparent;

  // 🔑 State variables to store necessary IDs during payment flow
  String? _pendingChitId;
  String? _pendingRequestId;

  @override
  void initState() {
    super.initState();
    if (!_isLoadedOnce) {
      _loadRequestedChits();
      _isLoadedOnce = true;
    }

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

  void _updateStatus(String message, Color color) {
    if (mounted) {
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
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    setState(() => isLoading = true);
    _updateStatus("Payment Successful. Confirming final request...", const Color(0xff3fea96));

    await _confirmPaymentAndJoin(
      response.paymentId,
      response.orderId,
      widget.profileId,
    );

    _loadRequestedChits();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() => isLoading = false);
    String errorMsg = response.message?.contains("user cancelled") == true
        ? "Payment cancelled by user."
        : "Payment failed. Code: ${response.code}";
    _updateStatus(errorMsg, const Color(0xFFE53935));
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _updateStatus("External Wallet Selected: ${response.walletName}", const Color(0xFFFFA726));
  }


  // --- Core API Logic ---

  Future<void> _loadRequestedChits() async {
    setState(() => isLoading = true);
    final Token = await SecureStorageService.getToken();
    try {
      final url = Uri.parse(
        "https://foxlchits.com/api/JoinToChit/${widget.profileId}/requests?userID=${widget.userId}",
      );
      print("request url:$url");

      final response = await http.get(url,headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $Token",
      },);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        final freshList = data
            .map((json) => RequestedChitModel.fromJson(json))
            .where((chit) => chit.status.toLowerCase() != 'userconfirmed')
            .toList();

        await LocalStorageManager.saveRequestedChitsApi(freshList.map((e) => e.toJson()).toList());
        if (mounted) setState(() => requestedChits = freshList);
      } else {
        final cached = LocalStorageManager.getRequestedChitsApi();
        final list = cached
            .map((e) => RequestedChitModel.fromJson(e))
            .where((chit) => chit.status.toLowerCase() != 'userconfirmed')
            .toList();
        if (mounted) setState(() => requestedChits = list);
      }
    } catch (e) {
      final cached = LocalStorageManager.getRequestedChitsApi();
      final list = cached
          .map((e) => RequestedChitModel.fromJson(e))
          .where((chit) => chit.status.toLowerCase() != 'userconfirmed')
          .toList();
      if (mounted) setState(() => requestedChits = list);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  /// 🔑 STEP 3: Final confirmation API call
  Future<void> _confirmPaymentAndJoin(
      String? paymentId,
      String? orderId,
      String profileId
      ) async {

    if (paymentId == null || orderId == null || _pendingChitId == null || _pendingRequestId == null) {
      _updateStatus("Confirmation failed: Missing payment details (IDs).", Colors.red);
      // Log the missing IDs for debugging
      print('❌ CONFIRMATION FAILED: paymentId: $paymentId, orderId: $orderId, chitId: $_pendingChitId, requestId: $_pendingRequestId');
      return;
    }

    try {
      // Build the payload using the IDs stored during order creation
      final Map<String, dynamic> requestBody = {
        "requestId": _pendingRequestId, // 🔑 FIXED: Sent from cached state
        "profileID": profileId,
        "chitID": _pendingChitId,     // 🔑 FIXED: Sent from cached state
        "paymentId": paymentId,
        "orderId": orderId,
      };
      final Token = await SecureStorageService.getToken();
      final response = await http.post(
        Uri.parse(_confirmPaymentApiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $Token",
        },
        body: jsonEncode(requestBody),
      );

      final responseBody = jsonDecode(response.body);
      final String message = responseBody['message'] ?? 'Unknown error.';

      if (response.statusCode == 200 || response.statusCode == 201) {
        _updateStatus("✅ Chit confirmed and joined!", const Color(0xff07C66A));
      } else {
        _updateStatus("Confirmation failed: $message", Colors.red);
      }
    } catch (e) {
      _updateStatus("Confirmation Network Error: $e", Colors.redAccent);
    }
  }


  /// 🔑 STEP 1: Initiates Order Creation and opens Razorpay
  Future<void> _startChitPayment(RequestedChitModel chit) async {
    setState(() => isLoading = true);
    _statusMessage = null;

    try {
      final profileId = widget.profileId;
      final token = await SecureStorageService.getToken();

      // 🔑 CRITICAL FIX: Store the necessary IDs before the asynchronous payment starts
      _pendingChitId = chit.chitId;
      _pendingRequestId = chit.requestId;

      // Amount is Monthly Contribution (assuming this is the payment due)
      final double rawAmount = chit.contribution;
      final int amountInBaseUnit = rawAmount.round();
      final int amountInPaiseForCheckout = amountInBaseUnit * 100; // Convert to paise for Razorpay

      if (amountInBaseUnit <= 0) {
        throw Exception("Invalid payment amount.");
      }

      // 1. Prepare Order Request Body (Body needs all chit details for the server to process the order)
      final Map<String, dynamic> orderBody = {
        "profileID": profileId,
        "chitID": chit.chitId,
        "requestId": chit.requestId, // Pass the request ID
        "amount": amountInBaseUnit, // Amount in Rupees
      };

      final headers = {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      };

      _updateStatus("Creating order...", Colors.blue);

      // Call the API endpoint which is expected to create the Order ID and return it
      final orderResponse = await http.post(
        Uri.parse(_orderApiUrl), // 🔑 Order Creation API
        headers: headers,
        body: jsonEncode(orderBody),
      );

      if (orderResponse.statusCode != 200 && orderResponse.statusCode != 201) {
        String apiMessage = jsonDecode(orderResponse.body)['message'] ?? orderResponse.body;
        throw Exception("Order API failed. Status: ${orderResponse.statusCode}. Message: $apiMessage");
      }

      final orderResponseBody = jsonDecode(orderResponse.body);
      final String orderId = orderResponseBody['orderId']?.toString() ?? '';

      if (orderId.isEmpty) {
        throw Exception("Order ID missing in response.");
      }

      // 2. Open Checkout
      _openRazorpayCheckout(orderId, amountInPaiseForCheckout, chit.chitsName);

      // Loading remains true until Razorpay callback fires
    } catch (e) {
      print("❌ Chit Payment Error: $e");
      _updateStatus("Payment setup failed: ${e.toString().split(':')[0]}", Colors.redAccent);
      setState(() => isLoading = false);
    }
  }

  /// 🔑 STEP 2: Opens Razorpay using Order ID
  void _openRazorpayCheckout(String orderId, int amountInPaise, String chitName) {
    // Note: Fetch actual user contact/email from SecureStorage here if needed

    var options = {
      'key': _razorpayKeyId,
      'amount': amountInPaise, // PAISE
      'order_id': orderId,     // REQUIRED
      'name': 'FoxlChits',
      'description': 'Monthly Contribution for $chitName',
      'prefill': {
        'contact': '9876543210',
        'email': 'user@demo.com',
      },
      'theme': {'color': '#3A7AFF'},
    };

    try {
      _razorpay.open(options);
      // Loading remains TRUE until payment handler fires
    } catch (e) {
      print("Error launching Razorpay: $e");
      _updateStatus("Error launching payment interface.", Colors.redAccent);
      setState(() => isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return RefreshIndicator(
      color: Colors.white,
      backgroundColor: const Color(0xff3A7AFF),
      onRefresh: _loadRequestedChits,
      child: Stack(
        children: [
          SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: isLoading
                ? Column(
              children: List.generate(4, (index) {
                return Shimmer.fromColors(
                  baseColor: const Color(0xff2A2A2A),
                  highlightColor: const Color(0xff3A3A3A),
                  child: Container(
                    width: double.infinity,
                    height: size.height * 0.22,
                    margin:
                    EdgeInsets.only(bottom: size.height * 0.02),
                    decoration: BoxDecoration(
                      color: const Color(0xff2A2A2A),
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                );
              }),
            )
                : requestedChits.isEmpty
                ? Center(
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.15),
                  Image.asset(
                    'assets/images/My_Chits/no_active chits.png',
                    width: 232,
                    height: 232,
                  ),
                  SizedBox(height: size.height * 0.04),
                  Text(
                    "No requested chits yet!",
                    style: GoogleFonts.urbanist(
                      color: const Color(0xffBBBBBB),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
                :Column(
              children: requestedChits.map((chit) {
                final bool isPending = chit.status.toLowerCase() !=( "mainboardapproved" )&& chit.status.toLowerCase() !=( 'userconfirmed');
                final String statusLabel = isPending ? "Requested" : "Approved";

                return Padding(
                  padding: EdgeInsets.only(bottom: size.height * 0.02),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: size.height * 0.21,
                        decoration: BoxDecoration(
                          borderRadius: isPending
                              ? BorderRadius.only(
                            topLeft: Radius.circular(25),
                            topRight: Radius.circular(25),
                          )
                              : BorderRadius.circular(25),
                          gradient: const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Color(0xff232323), Color(0xff383836)],
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
                              // Title + Type
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    chit.chitsName,
                                    style: GoogleFonts.urbanist(
                                      textStyle: const TextStyle(
                                        color: Color(0xff3A7AFF),
                                        fontSize: 28,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    chit.chitsType,
                                    style: GoogleFonts.urbanist(
                                      textStyle: const TextStyle(
                                        color: Color(0xffB5B4B4),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: size.height * 0.01),

                              // Info rows
                              _buildInfoRow(
                                "Chit Value : ₹${chit.value.toStringAsFixed(0)}",
                                "Mon.Contribution : ₹${chit.contribution.toStringAsFixed(0)}/-",
                              ),
                              _buildInfoRow(
                                "Duration : ${chit.timePeriod} months",
                                "Requested Date : ₹${chit.requestDate.toLocal().toString().split(' ')[0]}",
                              ),
                              _buildInfoRow(
                                "Status : ${chit.status}",
                                "Due Date : ${chit.duedate.toLocal().toString().split(' ')[0]}",
                              ),

                              SizedBox(height: size.height * 0.01),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (!isPending) // Show Pay Due button only if it is NOT pending/Requested
                                    GestureDetector(
                                      onTap: () => _startChitPayment(chit), // 👈 Calls payment flow
                                      child: Container(
                                        width: 100,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(7),
                                          color: const Color(0xffFFFFFF),
                                        ),
                                        child: Center(
                                          child: Text(
                                            'Pay Due',
                                            style: GoogleFonts.urbanist(
                                              textStyle: TextStyle(
                                                color: const Color(0xff000000),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  SizedBox(width: size.width * 0.02),
                                  Container(
                                    width: 100,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(7),
                                      color: isPending
                                          ? const Color(0xff626262)
                                          : const Color(0xff3fea96),
                                    ),
                                    child: Center(
                                      child: Text(
                                        statusLabel,
                                        style: GoogleFonts.urbanist(
                                          textStyle: TextStyle(
                                            color: isPending
                                                ? const Color(0xffC4C4C4)
                                                : const Color(0xff000000),
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

                      // Grey note section
                      if (isPending)
                        Container(
                          width: double.infinity,
                          height: 40,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(25),
                              bottomRight: Radius.circular(25),
                            ),
                            color: Color(0xffD6D6D6),
                          ),
                          child: Row(
                            children: [
                              SizedBox(width: size.width * 0.04),
                              Image.asset(
                                'assets/images/My_Chits/time.png',
                                width: 24,
                                height: 24,
                              ),
                              SizedBox(width: size.width * 0.02),
                              Text(
                                'Your chit request has been sent successfully. Once verified,\nyou’ll be added to the chit group.',
                                style: GoogleFonts.urbanist(
                                  textStyle: const TextStyle(
                                    color: Color(0xff6B6B6B),
                                    fontSize: 9,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          if (_statusMessage != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
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
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String left, String right) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            left,
            style: GoogleFonts.urbanist(
              textStyle: const TextStyle(
                color: Color(0xffF8F8F8),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            right,
            style: GoogleFonts.urbanist(
              textStyle: const TextStyle(
                color: Color(0xffF8F8F8),
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