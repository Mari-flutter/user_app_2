import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:user_app/My_Chits/Explore_chits/add_account_for_chits_screen.dart';
import 'package:user_app/Services/secure_storage.dart';

import '../../Models/My_Chits/withdraw_for_chit_model.dart';
import 'explore_chit_screen.dart';

class withdraw_for_chits extends StatefulWidget {
  const withdraw_for_chits({super.key});

  @override
  State<withdraw_for_chits> createState() => _withdraw_for_chitsState();
}

class _withdraw_for_chitsState extends State<withdraw_for_chits> {
  String? Username;
  String? UserID;
  String?Profileid;
  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    await _loadUserName();     // 🔥 ensures Profileid is ready
    await fetchWithdrawAmount();
  }



  Future<void> _loadUserName() async {
    final username = await SecureStorageService.getUserName();
    final userId = await SecureStorageService.getUserId();
    final profileid = await SecureStorageService.getProfileId();
    setState(() {
      Username = username;
      UserID = userId;
      Profileid = profileid;
    });
  }
  double? withdrawAmount;
  bool isLoading = true;

  Future<void> fetchWithdrawAmount() async {
    final Token = await SecureStorageService.getToken();
    try {
      final url = Uri.parse(
          'https://foxlchits.com/api/Auctionwinner/$Profileid'
      );


      final response = await http.get(url,headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $Token",
      },);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final list = data['withdrawAmounts'] as List;

        if (list.isNotEmpty) {
          final model = WithdrawAmountModel.fromJson(list[0]);

          setState(() {
            withdrawAmount = model.withdrawAmount;
            isLoading = false;
          });
        } else {
          setState(() {
            withdrawAmount = 0;
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error fetching withdraw amount: $e");
      setState(() {
        withdrawAmount = 0;
        isLoading = false;
      });
    }
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
                        Navigator.pop(context);
                      },
                      child: Image.asset(
                        'assets/images/My_Chits/back_arrow.png',
                        width: 24,
                        height: 24,
                      ),
                    ),
                    SizedBox(width: size.width * 0.03),
                    Text(
                      'Withdraw',
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
                Container(
                  width: size.width,
                  height: 198,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        'assets/images/My_Chits/withdraw_card.png',
                      ),
                      fit: BoxFit.fill, // full screen
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.05,
                      vertical: size.height * 0.03,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Your Wallet',
                              style: GoogleFonts.urbanist(
                                textStyle: const TextStyle(
                                  color: Color(0xffFFFFFF),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              'Credit',
                              style: GoogleFonts.urbanist(
                                textStyle: const TextStyle(
                                  color: Color(0xff484848),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: size.height * 0.03),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            '₹${(withdrawAmount ?? 0).toStringAsFixed(0)}',
                            style: GoogleFonts.urbanist(
                              textStyle: const TextStyle(
                                color: Color(0xff07C66A),
                                fontSize: 32,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: size.height * 0.035),
                        Text(
                          '${UserID?? 'UserID'} ${Username??'UserName'}',
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
                  ),
                ),
                SizedBox(height: size.height*0.57),
                GestureDetector(
                  onTap: (){Navigator.push(context,MaterialPageRoute(builder: (context)=>Chit_add_account(withdrawalAmount: withdrawAmount!)));},
                  child: Container(
                    width: double.infinity,
                    height: 38,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(11),
                      color: Color(0xff4770CB),
                    ),
                    child: Center(
                      child: Text(
                        'Withdraw Amount',
                        style: GoogleFonts.urbanist(
                          textStyle: const TextStyle(
                            color: Color(0xffFFFFFF),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
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
  }
}