import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user_app/Investments/investments_screen.dart';

import 'Gold/gold_investment_screen.dart';
import 'Real_Estate/real_estate_investment_screen.dart';

class toggle_gold_realestate extends StatefulWidget {
  final int initialTab;
  final bool initialIsGold;
  const toggle_gold_realestate({super.key,this.initialIsGold = true, required this.initialTab,});

  @override
  State<toggle_gold_realestate> createState() => _toggle_gold_realestateState();
}

class _toggle_gold_realestateState extends State<toggle_gold_realestate> {
  late bool isGold;
  late int _selectedTab;

  @override
  void initState() {
    super.initState();
    isGold = widget.initialIsGold; // initialize from parameter
    _selectedTab = widget.initialTab;
  }

  String selectedTab = 'Gold'; // default

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xff000000),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
          child: Column(
            children: [
              SizedBox(height: size.height * 0.02),
              Row(
                children: [
                  GestureDetector(
                    onTap: (){Navigator.push(context,MaterialPageRoute(builder: (context)=>investment()));},
                    child: Image.asset(
                      'assets/images/My_Chits/back_arrow.png',
                      width: 24,
                      height: 24,
                    ),
                  ),
                  SizedBox(width: size.width * 0.03),
                  Text(
                    'Investments',
                    style: GoogleFonts.urbanist(
                      textStyle: const TextStyle(
                        color: Color(0xffE2E2E2),
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: size.width * 0.05),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isGold = !isGold;
                      });
                    },
                    child: AnimatedContainer(
                      height: 20,
                      width: 70,
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: isGold
                            ? const Color(0xffF8C545)
                            : const Color(0xff1D3D74),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          isGold ? 'Gold' : 'Real Estate',
                          style: GoogleFonts.urbanist(
                            textStyle: const TextStyle(
                              color: Color(0xffFFFFFF),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: size.height * 0.02),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds:500),
                  child: isGold
                      ? gold_investment(initialTab:_selectedTab)
                      : const real_estate_investment(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
