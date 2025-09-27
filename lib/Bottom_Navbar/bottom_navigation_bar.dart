import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:user_app/Investments/investments_screen.dart';
import 'package:user_app/Profile/profile_screen.dart';
import 'package:user_app/Profile/setup_profile_screen.dart';
import 'package:user_app/Transactions/transactions_screen.dart';
import '../Home/home_screen.dart';
import '../Chit_Groups/chit_group_screen.dart';
import '../Investments/Gold/gold_investment_screen.dart';

class HomeLayout extends StatefulWidget {
  final int initialTab;
  final bool? isKycCompleted;

  const HomeLayout({super.key, this.initialTab = 0, this.isKycCompleted});

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {
  final storage = FlutterSecureStorage();
  bool isKycCompleted = false;
  String? profileId;
  int _selectedIndex = 0;
  int _goldTabIndex = 0; // 0 = Buy Gold, 1 = Sell Gold, 2 = Schemes
  bool _showGoldScreen = false; // true when Gold Investment screen is active
  List<Widget>? _screens;

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


  @override
  void initState() {
    super.initState();

    // If KYC is completed, set it
    if (widget.isKycCompleted == true) {
      isKycCompleted = true;
    }

    // Set the initial tab from the widget
    _selectedIndex = widget.initialTab;

    _loadProfileData();
  }


  Future<void> _loadProfileData() async {
    final id = await storage.read(key: 'profileId');
    setState(() => profileId = id);

    if (id != null && id.isNotEmpty) {
      try {
        final response = await http.get(
          Uri.parse("https://foxlchits.com/api/Profile/profile/$id"),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final kyc = data['kycVerification'] ?? false;
          setState(() => isKycCompleted = kyc);
          print("✅ KYC Status: $kyc");
        } else {
          print("❌ Failed to load profile data: ${response.statusCode}");
        }
      } catch (e) {
        print("⚠️ Error fetching profile: $e");
      }
    } else {
      print("⚠️ No stored profileId found");
    }

    // after loading, setup your screens
    _setupScreens();
  }

  /// 🔹 Initialize your tab screens after data is loaded
  void _setupScreens() {
    _screens = [
      home(
        onTabChange: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      chit_groups(),
      investment(),
      transactions(initialTab: 0),
      isKycCompleted
          ? const profile()
          : setup_profile(
              onKycCompleted: () {
                setState(() {
                  isKycCompleted = true;
                  _screens![4] = const profile();
                });
              },
            ),
    ];
    setState(() {}); // refresh after setup
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _showGoldScreen = false;
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
          : (_screens == null
                ? const Center(child: CircularProgressIndicator())
                : _screens![_selectedIndex]),
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
