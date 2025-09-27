import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user_app/Investments/investments_screen.dart';
import 'package:user_app/Profile/profile_screen.dart';
import 'package:user_app/Profile/setup_profile_screen.dart';
import 'package:user_app/Transactions/transactions_screen.dart';
import '../Home/home_screen.dart';
import '../Chit_Groups/chit_group_screen.dart';
import '../Investments/Gold/gold_investment_screen.dart';

class HomeLayout extends StatefulWidget {
  const HomeLayout({super.key});

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {
  bool isKycCompleted = true; // Default false; update after verification
  int _selectedIndex = 0;
  int _goldTabIndex = 0; // 0 = Buy Gold, 1 = Sell Gold, 2 = Schemes
  bool _showGoldScreen = false; // true when Gold Investment screen is active
  late final List<Widget> _screens;

  final List<String> icons = [
    'assets/images/Bottom_Navbar/home.png',
    'assets/images/Bottom_Navbar/chit group.png',
    'assets/images/Bottom_Navbar/investment.png',
    'assets/images/Bottom_Navbar/transactions.png',
    'assets/images/Bottom_Navbar/profile.png',
  ];

  final List<String> labels = [
    'Home',
    'Chit Groups',
    'Investments',
    'Transactions',
    'Profile',
  ];

  // In HomeLayout
  void navigateToGold() {
    setState(() {
      _selectedIndex = 2; // Investments tab
    });

    // Pass initialTab = 0 to gold_investment screen
    _screens[2] = investment(
      onGoldTap: () {
        setState(() {
          _selectedIndex = 2; // Keep Investments tab selected
        });
      }, // optional if you want gold tab active in investments
    );
  }

  @override
  void initState() {
    super.initState();

    // Initialize screens here, passing callback to home()
    _screens = [
      home(
        onGoldTap: () {
          setState(() {
            _selectedIndex = 2; // Investments tab
            _showGoldScreen = true; // Show Gold screen
            _goldTabIndex = 0; // default Buy Gold
          });
        },
        onTabChange: (index) {},
      ),
      chit_groups(),
      investment(
        onGoldTap: () {
          setState(() {
            _showGoldScreen = true;
            _goldTabIndex = 0; // default Buy Gold
          });
        },
      ),
      transactions(initialTab: 0),
      isKycCompleted
          ? const profile()
          : setup_profile(
        onKycCompleted: () {
          setState(() {
            isKycCompleted = true;
            _screens[4] = const profile(); // replace with verified profile
          });
        },
      ),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _showGoldScreen = false; // hide Gold Investment if navigating tabs
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: _showGoldScreen
          ? WillPopScope(
              onWillPop: () async {
                setState(() {
                  _showGoldScreen = false;
                  _selectedIndex = 2; // return to Investments tab
                });
                return false; // prevent default pop
              },
              child: gold_investment(
                initialTab: _goldTabIndex,
                onTabChange: (index) {
                  setState(() {
                    _goldTabIndex = index;
                  });
                },
              ),
            )
          : _screens[_selectedIndex],

      bottomNavigationBar: Container(
        width: double.infinity,
        decoration: BoxDecoration(color: Color(0xff000000)),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(5, (index) {
            final bool isSelected = _selectedIndex == index;

            return GestureDetector(
              onTap: () => _onItemTapped(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: size.width * 0.02,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF3966CA).withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      icons[index],
                      width: 25,
                      height: 25,
                      color: isSelected ? Color(0xFF4770CB) : Color(0xffFFFFFF),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      labels[index],
                      style: GoogleFonts.urbanist(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? const Color(0xFF1762FC)
                            : Color(0xffFFFFFF),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
