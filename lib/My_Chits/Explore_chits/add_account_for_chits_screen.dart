import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user_app/My_Chits/Explore_chits/processing_transfer_screen.dart';
import 'package:user_app/My_Chits/Explore_chits/withdraw_for_chits_screen.dart';
import 'instant_transfer_screen.dart';

class add_account_for_chits extends StatefulWidget {
  const add_account_for_chits({super.key});

  @override
  State<add_account_for_chits> createState() => _add_account_for_chitsState();
}

class _add_account_for_chitsState extends State<add_account_for_chits> {
  final _formKey = GlobalKey<FormState>();

  final banknamecontroller = TextEditingController();
  final accountNumbercontroller = TextEditingController();
  final reenteraccountNumbercontroller = TextEditingController();
  final ifsccontroller = TextEditingController();

  String? accountMismatchError;

  @override
  void initState() {
    super.initState();
    reenteraccountNumbercontroller.addListener(_checkAccountMatch);
  }

  void _checkAccountMatch() {
    setState(() {
      if (reenteraccountNumbercontroller.text.isNotEmpty &&
          accountNumbercontroller.text != reenteraccountNumbercontroller.text) {
        accountMismatchError = "Account numbers do not match";
      } else {
        accountMismatchError = null;
      }
    });
  }

  void _showTransferOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) {
        int selectedOption = 0; // 0 -> Instant, 1 -> Processing
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.32,
              decoration: BoxDecoration(
                color: const Color(0xff0E0E0E),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  OptionRow(
                    title: 'Instant Transfer',
                    subtitle:
                        'Transfer charges may apply for instant transfers.',
                    isSelected: selectedOption == 0,
                    onTap: () => setState(() => selectedOption = 0),
                  ),
                  const SizedBox(height: 15),
                  const Divider(color: Color(0xff343434), height: 1),
                  const SizedBox(height: 15),
                  OptionRow(
                    title: 'Processing Transfer',
                    subtitle:
                        'This transfer may take up to 7 working days to process.\nTaxes are not applied.',
                    isSelected: selectedOption == 1,
                    onTap: () => setState(() => selectedOption = 1),
                  ),
                  const SizedBox(height: 25),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      if (selectedOption == 0) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const instant_transfer(),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const processing_transfer(),
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(11),
                        color: const Color(0xff4770CB),
                      ),
                      child: Center(
                        child: Text(
                          'Withdraw to Account',
                          style: GoogleFonts.urbanist(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xff000000),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
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
                        'Add Account',
                        style: GoogleFonts.urbanist(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.04),

                  // Bank Name
                  _buildLabel('Bank Name*'),
                  SizedBox(height: size.height * 0.02),
                  inputTextField('', banknamecontroller),

                  SizedBox(height: size.height * 0.03),

                  // Account Number
                  _buildLabel('Account Number*'),
                  SizedBox(height: size.height * 0.02),
                  inputTextField('', accountNumbercontroller),

                  SizedBox(height: size.height * 0.03),

                  // Re-enter Account Number
                  _buildLabel('Re-enter Account Number*'),
                  SizedBox(height: size.height * 0.02),
                  inputTextField(
                    '',
                    reenteraccountNumbercontroller,
                    errorText: accountMismatchError,
                  ),

                  SizedBox(height: size.height * 0.03),

                  // IFSC
                  _buildLabel('IFSC*'),
                  SizedBox(height: size.height * 0.02),
                  inputTextField('', ifsccontroller),

                  SizedBox(height: size.height * 0.28),

                  GestureDetector(
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        if (accountMismatchError != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Account numbers do not match. Please check again.',
                              ),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        } else {
                          _showTransferOptions(context);
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please fill all required fields'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 38,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(11),
                        color: const Color(0xff4770CB),
                      ),
                      child: Center(
                        child: Text(
                          'Withdraw to Account',
                          style: GoogleFonts.urbanist(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
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
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.urbanist(
        color: const Color(0xffADADAD),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget inputTextField(
    String hintText,
    TextEditingController controller, {
    String? errorText,
  }) {
    return TextFormField(
      controller: controller,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "This field cannot be empty";
        }
        return null;
      },
      style: GoogleFonts.urbanist(
        color: const Color(0xffADADAD),
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.black,
        hintText: hintText,
        errorText: errorText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: Color(0xFF323232)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: Color(0xFF323232)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: Color(0xFF323232)),
        ),
      ),
    );
  }
}

class OptionRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const OptionRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.urbanist(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: GoogleFonts.urbanist(
                    color: const Color(0xff656565),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: const Color(0xffD9D9D9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xff3A7AFF)
                      : const Color(0xffD9D9D9),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
