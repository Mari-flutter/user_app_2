import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user_app/Investments/Gold/Get%20Physical%20Gold/store_selection_screen.dart';
import 'package:user_app/Investments/Gold/gold_investment_screen.dart';

import '../../../Models/Investments/Gold/CurrentGoldValue_Model.dart';
import '../../../Models/Investments/Gold/user_hold_gold_model.dart';
import '../../../Services/Gold_holdings.dart';
import '../../../Services/Gold_price.dart';

class get_physical_gold extends StatefulWidget {
  final VoidCallback? onBackToGold;

  const get_physical_gold({super.key, this.onBackToGold});

  @override
  State<get_physical_gold> createState() => _get_physical_goldState();
}

class _get_physical_goldState extends State<get_physical_gold> {
  GoldHoldings? goldHoldings;
  CurrentGoldValue? _goldValue;
  bool _loading = true;
  TextEditingController _controller = TextEditingController();
  double approxAmount = 0.0;
  @override
  @override
  void initState() {
    super.initState();
    // Call the API data loading methods
    _loadGoldValue();
    _loadGoldHoldings();

    // Set up the listener for the TextField
    _controller.addListener(_calculateEstimate);
  }
  bool get _isInputValid {
    final grams = double.tryParse(_controller.text) ?? 0.0;
    // Check if grams is greater than zero
    return grams > 0.0;
    // You could also add a check for holdings here:
    // return grams > 0.0 && grams <= (goldHoldings?.userGold ?? 0.0);
  }
  void _calculateEstimate() {
    // 1. Get the current rate safely. If the API data hasn't loaded yet (_goldValue is null), use 0.0.
    // The value is stored as a double in the model's 'goldValue' property.
    double currentRate = _goldValue?.goldValue ?? 0.0;

    // 2. Get the input grams safely.
    double grams = double.tryParse(_controller.text) ?? 0.0;

    // 3. Update the state with the new calculated amount.
    setState(() {
      approxAmount = grams * currentRate;
    });
  }
  Future<void> _loadGoldHoldings() async {
    // Step 1️⃣ — Load cached data immediately
    final cached = await GoldHoldingsService.getCachedGoldHoldings();
    if (cached != null) {
      setState(() {
        goldHoldings = cached;
      });
    }

    // Step 2️⃣ — Background fetch new data silently
    final latest = await GoldHoldingsService.fetchAndCacheGoldHoldings();
    if (latest != null) {
      // If new data differs, update UI automatically
      if (latest.userGold != goldHoldings?.userGold ||
          latest.userInvestment != goldHoldings?.userInvestment) {
        setState(() {
          goldHoldings = latest;
        });
      }
    }
  }


  Future<void> _loadGoldValue() async {
    // ... (Your existing loading logic) ...

    // 1️⃣ Load cached value first
    final cachedValue = await GoldService.getCachedGoldValue();
    if (cachedValue != null) {
      print('💾 Showing cached gold value: ₹${cachedValue.goldValue}');
      setState(() {
        _goldValue = cachedValue;
        _loading = false;
        _calculateEstimate(); // <--- Run calculation with cached data
      });
    } else {
      // ... (Your existing loader logic) ...
    }

    // 2️⃣ Fetch updated gold value in background
    try {
      // ... (Your existing fetch logic) ...
      final latestValue = await GoldService.fetchAndCacheGoldValue();
      if (!mounted) return;
      if (latestValue != null) {
        setState(() {
          _goldValue = latestValue;
          _loading = false;
          _calculateEstimate(); // <--- Run calculation with NEW data
        });
        // ... (Your existing print) ...
      }
    } catch (e) {
      // ... (Your existing error print) ...
    }
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Color(0xff000000),
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                gold_investment(initialTab: 0),
                          ),
                        );
                      },
                      child: Image.asset(
                        'assets/images/My_Chits/back_arrow.png',
                        width: 24,
                        height: 24,
                      ),
                    ),
                    SizedBox(width: size.width * 0.03),
                    Text(
                      'Get Physical Gold',
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
                SizedBox(height: size.height * 0.02),
                Container(
                  width: double.infinity,
                  height: 95,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(11),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Color(0xff70481C), Color(0xffF5D695)],
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.05,
                      vertical: size.height * 0.01,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Current Gold Price ',
                                  style: GoogleFonts.urbanist(
                                    textStyle: const TextStyle(
                                      color: Color(0xffCCAF78),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                _loading
                                    ? const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                )
                                    :
                                Text(
                                  '₹${_goldValue?.goldValue.toStringAsFixed(2) ?? '--'}/g',
                                  style: GoogleFonts.urbanist(
                                    textStyle: const TextStyle(
                                      color: Color(0xffFFFFFF),
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  _goldValue != null
                                      ? 'Updated on ${_goldValue!.date.toLocal().toString().split(" ").first}'
                                      : '',
                                  style: GoogleFonts.urbanist(
                                    textStyle: const TextStyle(
                                      color: Color(0xffFFFFFF),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Your Holdings',
                                  style: GoogleFonts.urbanist(
                                    textStyle: const TextStyle(
                                      color: Color(0xffF9F5EC),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${goldHoldings?.userGold.toStringAsFixed(2) ?? '--'} g',
                                  style: GoogleFonts.urbanist(
                                    textStyle: const TextStyle(
                                      color: Color(0xffFFFFFF),
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  '₹${goldHoldings?.userInvestment.toStringAsFixed(0) ?? '--'}',
                                  style: GoogleFonts.urbanist(
                                    textStyle: const TextStyle(
                                      color: Color(0xffFFFFFF),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.03),
                Container(
                  width: double.infinity,
                  height: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(11),
                    color: Color(0xff3E3E3E),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.05,
                      vertical: size.height * 0.025,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: size.width * 0.02),
                        Text(
                          'Select Gold Amount',
                          style: GoogleFonts.urbanist(
                            textStyle: const TextStyle(
                              color: Color(0xffFFFFFF),
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(height: size.height * 0.045),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Enter grams (₹)',
                                  style: GoogleFonts.urbanist(
                                    textStyle: const TextStyle(
                                      color: Color(0xffDBDBDB),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                SizedBox(height: size.height * 0.01),
                                SizedBox(
                                  width: size.width * 0.41,
                                  height: 38,
                                  child: TextField(
                                    style: TextStyle(
                                      color: Color(0xffFFFFFF),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    cursorColor: Color(0xffFFFFFF),
                                    controller: _controller,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      filled: true,
                                      // 👈 must enable to show background color
                                      fillColor: Color(0xff2A2A2A),

                                      // 👈 background color
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 10,
                                          ),

                                      // 👇 Focused border (when you tap on it)
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0xff2A2A2A),
                                        ),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0xff2A2A2A),
                                        ),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Estimate',
                                  style: GoogleFonts.urbanist(
                                    textStyle: const TextStyle(
                                      color: Color(0xffDBDBDB),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                SizedBox(height: size.height * 0.01),
                                Container(
                                  width: size.width * 0.41,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: Color(0xff525252),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(width: size.width * 0.02),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          '₹ ${approxAmount.toStringAsFixed(0)}',
                                          style: GoogleFonts.urbanist(
                                            textStyle: const TextStyle(
                                              color: Color(0xffDBDBDB),
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: size.height * 0.05),
                        GestureDetector(
                          onTap: () {
                            // 1. VALIDATION CHECK: Only proceed if input is valid
                            if (_isInputValid) {
                              final grams = double.tryParse(_controller.text) ?? 0.0;

                              // 2. Navigation
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => store_selection(selectedGrams: grams,EstimateValue:approxAmount,goldvalue:_goldValue),
                                ),
                              );
                            } else {
                              // Optional: Show a Snackbar error message if validation fails
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Please enter a gold amount greater than 0 grams.'),
                                  backgroundColor: Colors.red,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            height: 42,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(11),
                              color: Color(0xffD4B373),
                            ),
                            child: Center(
                              child: Text(
                                'Continue to Store Selection >',
                                style: GoogleFonts.urbanist(
                                  textStyle: const TextStyle(
                                    color: Color(0xff141414),
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
                ),
                SizedBox(height: size.height * 0.04),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
