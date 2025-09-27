import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user_app/Bottom_Navbar/bottom_navigation_bar.dart';

class referal extends StatefulWidget {
  const referal({super.key});

  @override
  State<referal> createState() => _referalState();
}

class _referalState extends State<referal> {
  @override
  Widget build(BuildContext context) {
    final TextEditingController referalCodeController = TextEditingController();
    String? errorMessage;
    bool isLoading = false;

    Future<bool> validateReferralCode(String code) async {
      // Simulated API call delay
      await Future.delayed(const Duration(seconds: 1));

      // You will replace this with actual API logic later
      // For example:
      // final response = await http.post(...);
      // return response.statusCode == 200 && response.body['valid'] == true;

      if (code.trim().toUpperCase() == "STYLIQ100") {
        return true;
      } else {
        return false;
      }
    }

    void handleSubmit() async {
      setState(() {
        errorMessage = null;
        isLoading = true;
      });

      String code = referalCodeController.text.trim();

      if (code.isEmpty) {
        setState(() {
          errorMessage = "Please enter your referral code";
          isLoading = false;
        });
        return;
      }

      bool isValid = await validateReferralCode(code);

      setState(() {
        isLoading = false;
      });

      if (isValid) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeLayout()),
        );
      } else {
        setState(() {
          errorMessage = "Invalid referral code. Please try again.";
        });
      }
    }

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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Comes from Referal ?',
                      style: GoogleFonts.urbanist(
                        textStyle: const TextStyle(
                          color: Color(0xffFFFFFF),
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HomeLayout()),
                        );
                      },
                      child: Text(
                        'Skip',
                        style: GoogleFonts.urbanist(
                          textStyle: const TextStyle(
                            color: Color(0xff3A7AFF),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.04),
                Text(
                  'Enter Referal Code',
                  style: GoogleFonts.urbanist(
                    textStyle: const TextStyle(
                      color: Color(0xffADADAD),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: TextFormField(
                    cursorColor: Colors.white,
                    controller: referalCodeController,
                    style: GoogleFonts.urbanist(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(11),
                        borderSide: const BorderSide(
                          color: Color(0xFF323232),
                          // Border color when not focused
                          width: 1.0,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.05,
                        vertical: size.height * 0.017,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(11),
                        borderSide: const BorderSide(
                          color: Color(0xFF323232),
                          // Border color when not focused
                          width: 1.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(11),
                        borderSide: const BorderSide(
                          color: Color(0xFF323232),
                          width: 2.0,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(11),
                        borderSide: const BorderSide(
                          color: Color.fromARGB(220, 166, 42, 42),
                          width: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
                // Error message
                if (errorMessage != null) ...[
                  SizedBox(height: size.height * 0.01),
                  Text(
                    errorMessage!,
                    style: GoogleFonts.urbanist(
                      textStyle: const TextStyle(
                        color: Color.fromARGB(255, 255, 80, 80),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
                SizedBox(height: size.height * 0.08),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: isLoading ? null : handleSubmit,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: isLoading
                            ? Colors.grey[700]
                            : const Color(0xff686763),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Color(0xffFFFFFF),
                                size: 18,
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
