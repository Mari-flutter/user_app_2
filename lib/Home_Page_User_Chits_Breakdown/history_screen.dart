import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user_app/Bottom_Navbar/bottom_navigation_bar.dart';
import 'package:user_app/Home_Page_User_Chits_Breakdown/total_chits.dart';
import 'package:user_app/Home_Page_User_Chits_Breakdown/upcomming_auction.dart';
import '../Models/User_chit_breakdown/pending_payment_model.dart';
import '../Models/User_chit_breakdown/user_chit_breakdown_model.dart';
import '../Services/pending_payment_service.dart';
import '../Services/secure_storage.dart';
import 'pay_a_month.dart';
import 'pending_payments.dart';

class History extends StatefulWidget {
  final Function(int)? onTabChange;
  final int initialTab;
  final UserChitBreakdownModel? chitSummary;

  const History({
    super.key,
    this.onTabChange,
    required this.initialTab,
    required this.chitSummary,
  });

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  String? userName;
  late int _selectedIndex;
  List<PendingPayment> _pendingPayments = [];
  double _totalPendingAmount = 0;
  bool _isPendingLoading = true;
  int _upcomingAuctionCount = 0;

  @override
  void initState() {
    super.initState();
    _loadPendingPayments();
    _loadProfileId();
    _loadUpcomingCount();
    _selectedIndex = widget.initialTab;
  }
  void _loadUpcomingCount() async {
    final count = await SecureStorageService.getUpcomingAuctionCount();
    setState(() {
      _upcomingAuctionCount = count;
    });
  }

  Future<void> _loadPendingPayments() async {
    try {
      final payments = await PendingPaymentService.fetchPendingPayments();

      // ✅ Only include real pending ones
      final filtered = payments.where((p) => p.pendingAmount > 0).toList();

      // ✅ Calculate total pending
      final total = filtered.fold<double>(0, (sum, p) => sum + p.pendingAmount);

      setState(() {
        _pendingPayments = filtered;
        _totalPendingAmount = total;
        _isPendingLoading = false;
      });

      print("✅ Home loaded ${filtered.length} pending payments");
    } catch (e) {
      print("⚠️ Error fetching pending payments on Home: $e");
      setState(() => _isPendingLoading = false);
    }
  }

  Future<void> _loadProfileId() async {
    final username = await SecureStorageService.getUserName();
    setState(() {
      userName = username;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    widget.onTabChange?.call(index);
  }

  List<String> get chitTypeTags => [
    "Total Chits ${widget.chitSummary?.totalChits ?? 0}",
    "Upcoming Auction $_upcomingAuctionCount",
    "Pay a month",
    "Pending Payments",
  ];

  late final List<Widget> pages = [
    TotalChitsPage(chitList: widget.chitSummary?.chits ?? const []),
    UpcomingAuctionPage(
      chitList: widget.chitSummary?.chits ?? const [],
      onCountUpdated: (count) {
        setState(() {
          _upcomingAuctionCount = count;
        });
      },
    ),
    const PayMonthPage(),
    const PendingPaymentsPage(),
  ];

  String _calculateTotalContribution() {
    if (widget.chitSummary == null) return '0';
    final total = widget.chitSummary!.chits.fold<double>(
      0,
          (sum, chit) => sum + chit.contribution,
    );
    return total.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xff000000),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.02),
          child: Column(
            children: [
              SizedBox(height: size.height * 0.02),
              // 🔹 Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: const Color(0xff282828),
                      ),
                      child: Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomeLayout(),
                              ),
                            );
                          },
                          child: Image.asset(
                            'assets/images/Home_Page_User_Chits_Breakdown/back.png',
                            width: 15,
                            height: 15,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: size.width * 0.03),
                    Text(
                      'Breakdown',
                      style: GoogleFonts.urbanist(
                        color: const Color(0xffFFFFFF),
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: size.height * 0.02),

              // 🔹 Card section
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 189,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                          'assets/images/Home/Home_screen_main card_1.jpg',
                        ),
                        fit: BoxFit.fill,
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
                          Text(
                            'Hi ${userName ?? ''},',
                            style: GoogleFonts.urbanist(
                              color: const Color(0xffF8F8F8),
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: size.height * 0.005),
                          Row(
                            children: [
                              Text(
                                '₹ ${widget.chitSummary?.totalChitValue.toStringAsFixed(0) ?? '0'}',
                                style: GoogleFonts.urbanist(
                                  color: const Color(0xffFFFFFF),
                                  fontSize: 32,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: size.width * 0.03),
                              Text(
                                'total subscription value',
                                style: GoogleFonts.urbanist(
                                  color: const Color(0xffFFFFFF),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: size.height * 0.02),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Chit Taken : ${widget.chitSummary?.totalChits ?? 0}',
                                style: GoogleFonts.urbanist(
                                  color: const Color(0xffF8F8F8),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: size.height * 0.002),
                              _isPendingLoading
                                  ? Container(
                                width: 140,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: Color(0xff3A7AFF).withOpacity(0.76),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              )
                                  : Text(
                                'Wants to pay a month : ₹${_totalPendingAmount.toStringAsFixed(2)}/-',
                                style: GoogleFonts.urbanist(
                                  color: const Color(0xffF8F8F8),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 15,
                    child: Image.asset(
                      'assets/images/Home/container.png',
                      width: 107,
                      height: 90,
                    ),
                  ),
                ],
              ),

              SizedBox(height: size.height * 0.03),

              // 🔹 Tabs
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
                child: Row(
                  children: List.generate(chitTypeTags.length, (index) {
                    final bool isSelected = _selectedIndex == index;
                    return GestureDetector(
                      onTap: () => _onItemTapped(index),
                      child: Container(
                        height: 25,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xff3A7AFF).withOpacity(0.76)
                              : const Color(0xff262626).withOpacity(0.76),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.02,
                            vertical: size.height * 0.003,
                          ),
                          child: Text(
                            chitTypeTags[index],
                            style: GoogleFonts.urbanist(
                              color: const Color(0xffFFFFFF),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              SizedBox(height: size.height * 0.02),

              // 🔹 Expanded Tab Content
              Expanded(
                child: pages[_selectedIndex],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
