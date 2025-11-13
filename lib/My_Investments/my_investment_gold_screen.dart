import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:user_app/Investments/Gold/gold_investment_screen.dart';

import '../Helper/Local_storage_manager.dart';
import '../Investments/Gold/Get Physical Gold/get_physical_gold_screen.dart';
import '../Models/My_Investment/myinvestment_gold_model.dart';
import '../Services/secure_storage.dart';
import 'package:shimmer/shimmer.dart';

class my_investment_gold extends StatefulWidget {
  final VoidCallback? onGoldSellTap;
  final int totalMonths;
  final int completedMonths;
  final int chitValue;
  final int totalContribution;

  const my_investment_gold({
    super.key,
    this.onGoldSellTap,
    required this.totalMonths,
    required this.completedMonths,
    required this.chitValue,
    required this.totalContribution,
  });

  @override
  State<my_investment_gold> createState() => _my_investment_goldState();
}

class _my_investment_goldState extends State<my_investment_gold> {
  Timer? _autoRefreshTimer;
  final chit_month = 20;
  final completed_chits = 6;
  MyInvestmentGoldModel? myInvestmentGold;
  bool _loadingInvestment = true;

  @override
  void initState() {
    super.initState();
    _autoRefreshTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      if (mounted) _fetchMyInvestmentGold(); // silent refresh
    });
    _fetchMyInvestmentGold(showLoader: true); // initial with spinner
  }

  Future<void> _fetchMyInvestmentGold({bool showLoader = false}) async {
    if (mounted && showLoader) setState(() => _loadingInvestment = true);

    try {
      final profileId = await SecureStorageService.getProfileId();
      if (profileId == null || profileId.isEmpty) {
        print('⚠️ No profileId found for MyInvestmentGold API');
        return;
      }

      // 🧠 1️⃣ Load cached data immediately (instant display)
      final cached = LocalStorageManager.getMyInvestmentGold(profileId);
      if (cached != null && myInvestmentGold == null) {
        setState(() {
          myInvestmentGold = cached;
          _loadingInvestment = false;
        });
        print('💾 Showing cached MyInvestmentGoldModel data');
      }

      // 🧠 2️⃣ Fetch new data in background
      final url = Uri.parse(
        'https://foxlchits.com/api/SchemeMember/user/$profileId',
      );
      print('📡 Fetching latest MyInvestmentGoldModel → $url');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final model = MyInvestmentGoldModel.fromJson(data);

        // 🧠 Check if data changed
        if (jsonEncode(model.toJson()) !=
            jsonEncode(myInvestmentGold?.toJson())) {
          print('🔄 MyInvestmentGoldModel updated — saving new data.');
          await LocalStorageManager.saveMyInvestmentGold(model, profileId);
          if (mounted) {
            setState(() => myInvestmentGold = model);
          }
        } else {
          print('✅ MyInvestmentGoldModel already up-to-date.');
        }
      } else {
        print(
          '⚠️ Failed to load MyInvestmentGoldModel: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Error fetching MyInvestmentGoldModel: $e');
    } finally {
      if (mounted) setState(() => _loadingInvestment = false);
    }
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }
  Widget _buildShimmerContainer(double height, double borderRadius) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade900.withOpacity(0.3),
      highlightColor: Colors.grey.shade700.withOpacity(0.4),
      period: const Duration(seconds: 2), //
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade900.withOpacity(0.5),
          borderRadius: BorderRadius.circular(borderRadius),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: size.width * 0.45,
              height: 68,
              decoration: BoxDecoration(
                color: Color(0xff323B48),
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
                      'Total Gold',
                      style: GoogleFonts.urbanist(
                        textStyle: const TextStyle(
                          color: Color(0xffDBDBDB),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '${myInvestmentGold?.totalGoldValue?.toStringAsFixed(1) ?? '--'} grams',
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
            ),
            Container(
              width: size.width * 0.45,
              height: 68,
              decoration: BoxDecoration(
                color: Color(0xff323B48),
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
                      'Current Value',
                      style: GoogleFonts.urbanist(
                        textStyle: const TextStyle(
                          color: Color(0xffDBDBDB),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '₹${myInvestmentGold?.currentGoldPrice?.toStringAsFixed(1) ?? '--'}',
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
            ),
          ],
        ),
        SizedBox(height: size.height * 0.02),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: size.width * 0.45,
              height: 68,
              decoration: BoxDecoration(
                color: Color(0xff323B48),
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
                      'Investment',
                      style: GoogleFonts.urbanist(
                        textStyle: const TextStyle(
                          color: Color(0xffDBDBDB),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '₹${myInvestmentGold?.totalAmountPaid?.toStringAsFixed(1) ?? '--'}',
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
            ),
            Container(
              width: size.width * 0.45,
              height: 68,
              decoration: BoxDecoration(
                color: Color(0xff323B48),
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
                      'Returns',
                      style: GoogleFonts.urbanist(
                        textStyle: const TextStyle(
                          color: Color(0xffDBDBDB),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Builder(
                      builder: (_) {
                        final worth = myInvestmentGold?.currentGoldWorth ?? 0;
                        final paid = myInvestmentGold?.totalAmountPaid ?? 0;
                        final diff = worth - paid;
                        final percent = paid > 0 ? (diff / paid) * 100 : 0;

                        final isProfit = diff >= 0;
                        final color = isProfit
                            ? Color(0xff07C66A)
                            : Color(0xffF85B5B);
                        final sign = isProfit ? '+' : '-';

                        return Row(
                          children: [
                            Text(
                              '${sign}₹${diff.abs().toStringAsFixed(0)}',
                              style: GoogleFonts.urbanist(
                                textStyle: TextStyle(
                                  color: color,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              '(${percent.abs().toStringAsFixed(1)}%)',
                              style: GoogleFonts.urbanist(
                                textStyle: TextStyle(
                                  color: color,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: size.height * 0.03),
        if (_loadingInvestment)
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: _buildShimmerContainer(68, 11)),
                  SizedBox(width: 10),
                  Expanded(child: _buildShimmerContainer(68, 11)),
                ],
              ),

              SizedBox(height: size.height * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: _buildShimmerContainer(68, 11)),
                  SizedBox(width: 10),
                  Expanded(child: _buildShimmerContainer(68, 11)),
                ],
              ),

              SizedBox(height: size.height * 0.03),
              _buildShimmerContainer(273, 11),
              SizedBox(height: size.height * 0.03),
              _buildShimmerContainer(208, 11),
            ],
          )
        else if (myInvestmentGold == null ||
            myInvestmentGold!.joinedSchemes == null ||
            myInvestmentGold!.joinedSchemes!.isEmpty)
          Center(
            child: Text(
              'No joined schemes yet.',
              style: GoogleFonts.urbanist(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        else
          Column(
            children: List.generate(myInvestmentGold!.joinedSchemes!.length, (
              index,
            ) {
              final scheme = myInvestmentGold!.joinedSchemes![index];
              final totalMonths = scheme.duration ?? 0;
              final completedMonths = scheme.payments.length??0;
              final progress = totalMonths > 0
                  ? completedMonths / totalMonths
                  : 0.0;

              return Container(
                width: double.infinity,
                height: 273,
                decoration: BoxDecoration(
                  color: Color(0xff1D1D1D),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$totalMonths Months',
                            style: GoogleFonts.urbanist(
                              color: Color(0xffFFFFFF),
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '₹${scheme.contribution}/month',
                            style: GoogleFonts.urbanist(
                              color: Color(0xffFFFFFF),
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
                            'Progress',
                            style: GoogleFonts.urbanist(
                              color: Color(0xffDBDBDB),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '$completedMonths of $totalMonths months completed',
                            style: GoogleFonts.urbanist(
                              color: Color(0xffDBDBDB),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.01),
                      // --- Gradient Progress Bar ---
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final width = constraints.maxWidth * progress;
                          return Container(
                            width: double.infinity,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Color(0xffE5E5E5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Stack(
                              children: [
                                // Blue Gradient Progress Fill
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 600),
                                  width: width,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF2196F3),
                                        Color(0xFF64B5F6),
                                      ],
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
                      SizedBox(height: size.height * 0.025),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Invested',
                                style: GoogleFonts.urbanist(
                                  color: Color(0xffDBDBDB),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${scheme.totalPaid}',
                                style: GoogleFonts.urbanist(
                                  color: Color(0xff5B8EF8),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: size.height * 0.015),
                              Text(
                                'Gold Accumulated',
                                style: GoogleFonts.urbanist(
                                  color: Color(0xffDBDBDB),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${scheme.schemeGoldSum}',
                                style: GoogleFonts.urbanist(
                                  color: Color(0xff5B8EF8),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Target Amount',
                                style: GoogleFonts.urbanist(
                                  color: Color(0xffDBDBDB),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${scheme.totalValue}',
                                style: GoogleFonts.urbanist(
                                  color: Color(0xff5B8EF8),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: size.height * 0.015),
                              Text(
                                'Maturity Date',
                                style: GoogleFonts.urbanist(
                                  color: const Color(0xffDBDBDB),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              Builder(
                                builder: (context) {
                                  String maturityText = '--';
                                  try {
                                    if (scheme.joinDate != null && scheme.duration != null) {
                                      // Parse join date
                                      final joinDate = DateTime.parse(scheme.joinDate!);

                                      // Add (duration - 1) months to get maturity
                                      final maturityDate = DateTime(
                                        joinDate.year,
                                        joinDate.month + (scheme.duration! - 1),
                                        joinDate.day,
                                      );

                                      // Format to something like "Apr 2026"
                                      const monthNames = [
                                        "Jan", "Feb", "Mar", "Apr", "May", "Jun",
                                        "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
                                      ];
                                      maturityText =
                                      "${monthNames[maturityDate.month - 1]} ${maturityDate.year}";
                                    }
                                  } catch (e) {
                                    print('⚠️ Error calculating maturity date: $e');
                                  }

                                  return Text(
                                    maturityText,
                                    style: GoogleFonts.urbanist(
                                      color: const Color(0xff5B8EF8),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.02),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          width: 66,
                          height: 26,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(11),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xff2C5DC2), Color(0xff4C71BC)],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Pay Now',
                              style: GoogleFonts.urbanist(
                                color: Color(0xffFFFFFF),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        SizedBox(height: size.height * 0.03),
        Container(
          width: double.infinity,
          height: 208,
          decoration: BoxDecoration(
            color: Color(0xff1D1D1D),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: size.height * 0.02,
              horizontal: size.width * 0.05,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Redemption Options',
                  style: GoogleFonts.urbanist(
                    textStyle: const TextStyle(
                      color: Color(0xffFFFFFF),
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.03),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                gold_investment(initialTab: 1),
                          ),
                        );
                      },
                      child: Container(
                        width: size.width * 0.4,
                        height: 47,
                        decoration: BoxDecoration(
                          color: Color(0xffD9D9D9),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: size.height * 0.01,
                            horizontal: size.width * 0.05,
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Sell as Digital Gold',
                                style: GoogleFonts.urbanist(
                                  textStyle: const TextStyle(
                                    color: Color(0xff000000),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              SizedBox(width: size.width * 0.015),
                              Image.asset(
                                'assets/images/My_Investments/sell_as_digital_gold.png',
                                width: 13,
                                height: 13,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => get_physical_gold(),
                          ),
                        );
                      },
                      child: Container(
                        width: size.width * 0.4,
                        height: 47,
                        decoration: BoxDecoration(
                          color: Color(0xffD9D9D9),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: size.height * 0.01,
                            horizontal: size.width * 0.03,
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Convert Physical Gold',
                                style: GoogleFonts.urbanist(
                                  textStyle: const TextStyle(
                                    color: Color(0xff000000),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              SizedBox(width: size.width * 0.015),
                              Image.asset(
                                'assets/images/My_Investments/convert_physical_gold.png',
                                width: 13,
                                height: 13,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.035),
                Text(
                  'Note: Physical gold can be collected from our partner jewellery\nstores. A voucher will be generated for redemption',
                  style: GoogleFonts.urbanist(
                    textStyle: const TextStyle(
                      color: Color(0xffA5A5A5),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
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
}
