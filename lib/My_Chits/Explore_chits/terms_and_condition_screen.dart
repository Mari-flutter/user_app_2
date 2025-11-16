import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';

import '../../Services/secure_storage.dart';

class terms_condition extends StatefulWidget {
  const terms_condition({super.key});

  @override
  State<terms_condition> createState() => _terms_conditionState();
}

class _terms_conditionState extends State<terms_condition> {
  bool isLoading = true;
  String termsText = "";

  @override
  void initState() {
    super.initState();
    fetchTerms();
  }

  Future<void> fetchTerms() async {
    try {
      final Token = await SecureStorageService.getToken();
      final url = Uri.parse("https://foxlchits.com/api/Termsconditions/chit");
      final response = await http.get(url,headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $Token",
      },);

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        if (data.isNotEmpty) {
          setState(() {
            termsText = data[0]["termsandconditions"] ?? "";
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error loading terms: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Color(0xff000000),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height * 0.02),

              // ---------------- Header ------------------
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Image.asset(
                      'assets/images/My_Chits/back_arrow.png',
                      width: 24,
                      height: 24,
                    ),
                  ),
                  SizedBox(width: size.width * 0.03),
                  Text(
                    'Terms and Conditions',
                    style: GoogleFonts.urbanist(
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: size.height * 0.03),

              // ---------------- BODY (Shimmer + API Text) ------------------
              Expanded(
                child: isLoading
                    ?shimmerLoader(size)
                    : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Please read the following carefully:",
                        style: GoogleFonts.urbanist(
                          textStyle: TextStyle(
                            color: Color(0xffB6B6B6),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(height: 15),

                      Text(
                        "* ${termsText}",
                        style: GoogleFonts.urbanist(
                          textStyle: TextStyle(
                            color: Color(0xffE5E5E5),
                            fontSize: 13,
                            height: 1.5,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------- SHIMMER LOADER -------------------
  Widget shimmerLoader(Size size) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade800,
      highlightColor: Colors.grey.shade600,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 15,
            width: 200,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          SizedBox(height: 15),

          Container(
            height: 12,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          SizedBox(height: 10),

          Container(
            height: 12,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          SizedBox(height: 10),

          Container(
            height: 12,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          SizedBox(height: 10),

          Container(
            height: 12,
            width: size.width * 0.7,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }


}
