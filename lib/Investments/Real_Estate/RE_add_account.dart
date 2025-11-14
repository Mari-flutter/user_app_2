import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user_app/My_Chits/Explore_chits/processing_transfer_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../My_Chits/Explore_chits/add_account_for_chits_screen.dart';
import '../../My_Chits/Explore_chits/instant_transfer_screen.dart';
import '../../Services/secure_storage.dart';

class RE_add_account extends StatefulWidget {
  const RE_add_account({super.key, required this.withdrawalAmount});
  final double withdrawalAmount;


  @override
  State<RE_add_account> createState() => _RE_add_accountState();
}

class _RE_add_accountState extends State<RE_add_account> {
  final _formKey = GlobalKey<FormState>();


  // --- State for Loading and API Details ---
  bool _isLoading = false;

  // NOTE: Replace with actual profileID, email, phone, and userID.
  // final String _profileID = "3fa85f64-5717-4562-b3fc-2c963f66afa6";
  // final String _userID = "YOUR_USER_ID";
  // final String _email = "test@example.com";
  // final String _phone = "1234567890";
  // The amount variable is no longer needed here, we use widget.withdrawalAmount
  // ----------------------------------------

  final banknamecontroller = TextEditingController();
  final accountNumbercontroller = TextEditingController();
  final reenteraccountNumbercontroller = TextEditingController();
  final ifsccontroller = TextEditingController();

  String? accountMismatchError;

  @override
  void initState() {
    super.initState();
    reenteraccountNumbercontroller.addListener(_checkAccountMatch);
    print('DEBUG: Amount received in RE_add_account: ${widget.withdrawalAmount}');
  }

  @override
  void dispose() {
    reenteraccountNumbercontroller.removeListener(_checkAccountMatch);
    banknamecontroller.dispose();
    accountNumbercontroller.dispose();
    reenteraccountNumbercontroller.dispose();
    ifsccontroller.dispose();
    super.dispose();
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

  // --- API Call Functions with Debug Prints ---

  // API for Instant Transfer
  Future<void> _instantTransfer(BuildContext context) async {
    const String apiUrl = "https://foxlchits.com/api/RazorPayWithdraw/RNwithdraw";
    final String accountHolderName = banknamecontroller.text.trim();
    final _email = await SecureStorageService.getMail();
    final mobilenumber = await SecureStorageService.getMobileNumber();
    final _profileID = await SecureStorageService.getProfileId();

    final Map<String, dynamic> body = {
      "profileID": _profileID,
      "name": accountHolderName,
      "email": _email,
      "phone": mobilenumber,
      "accountHolderName": accountHolderName,
      "accountNumber": accountNumbercontroller.text,
      "ifsc": ifsccontroller.text,
      "amount": widget.withdrawalAmount, // 🔑 Using passed amount
      "narration": "Instant Withdrawal",
    };

    print('DEBUG: Calling Instant Transfer API: $apiUrl');
    print('DEBUG: Request Body: ${jsonEncode(body)}');

    // Start loading
    if (mounted) setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(body),
      );

      print('DEBUG: Instant Transfer Response Status: ${response.statusCode}');
      print('DEBUG: Instant Transfer Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // Handle successful response
        if (mounted) {
          Navigator.pop(context); // Close modal
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const instant_transfer(),
            ),
          );
        }
      } else {
        // Handle API error response
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Instant Transfer Failed: ${response.statusCode} - ${response.body}'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      // Handle network/exception error
      print('ERROR: Instant Transfer Exception: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred during instant transfer: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      // Stop loading
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // API for Processing Transfer
  Future<void> _processingTransfer(BuildContext context) async {
    const String apiUrl = "https://foxlchits.com/api/WithdrawAmount/RE-withdraw-request";
    final String accountHolderName = banknamecontroller.text.trim();
    final _email = await SecureStorageService.getMail();
    final _profileID = await SecureStorageService.getProfileId();
    final _userID = await SecureStorageService.getUserId();


    final Map<String, dynamic> body = {
      "profileId": _profileID,
      "name": accountHolderName,
      "accountNumber": accountNumbercontroller.text,
      "email": _email,
      "userID": _userID,
      "ifsc": ifsccontroller.text,
      "amount": widget.withdrawalAmount, // 🔑 Using passed amount
    };

    print('DEBUG: Calling Processing Transfer API: $apiUrl');
    print('DEBUG: Request Body: ${jsonEncode(body)}');

    // Start loading
    if (mounted) setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(body),
      );

      print('DEBUG: Processing Transfer Response Status: ${response.statusCode}');
      print('DEBUG: Processing Transfer Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // Handle successful response
        if (mounted) {
          Navigator.pop(context); // Close modal
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const processing_transfer(),
            ),
          );
        }
      } else {
        // Handle API error response
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Processing Transfer Failed: ${response.statusCode} - ${response.body}'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      // Handle network/exception error
      print('ERROR: Processing Transfer Exception: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred during processing transfer: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      // Stop loading
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- Updated Modal Sheet with Progress Indicator ---
  void _showTransferOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) {
        int selectedOption = 0; // 0 -> Instant, 1 -> Processing
        return StatefulBuilder(
          builder: (context, setStateInModal) { // Use setStateInModal for the modal's state
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
                    onTap: () => setStateInModal(() => selectedOption = 0),
                  ),
                  const SizedBox(height: 15),
                  const Divider(color: Color(0xff343434), height: 1),
                  const SizedBox(height: 15),
                  OptionRow(
                    title: 'Processing Transfer',
                    subtitle:
                    'This transfer may take up to 7 working days to process.\nTaxes are not applied.',
                    isSelected: selectedOption == 1,
                    onTap: () => setStateInModal(() => selectedOption = 1),
                  ),
                  const SizedBox(height: 25),
                  GestureDetector(
                    // Disable tap when loading
                    onTap: _isLoading
                        ? null
                        : () {
                      if (selectedOption == 0) {
                        _instantTransfer(context);
                      } else {
                        _processingTransfer(context);
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(11),
                        color: _isLoading ? const Color(0xff777777) : const Color(0xff4770CB), // Gray out when loading
                      ),
                      child: Center(
                        child: _isLoading
                            ? const SizedBox( // Progress Indicator when loading
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : Text( // Button text when not loading
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

  // 🔑 MISSING METHOD ADDED HERE
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
                          // Note: Use Navigator.pop() if you want to go back to the previous screen
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
                  // Display the amount for verification (Optional)
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      'Amount to withdraw: ₹${widget.withdrawalAmount.toStringAsFixed(2)}',
                      style: GoogleFonts.urbanist(
                        color: Colors.greenAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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
                  inputTextField('', accountNumbercontroller, isNumeric: true),

                  SizedBox(height: size.height * 0.03),

                  // Re-enter Account Number
                  _buildLabel('Re-enter Account Number*'),
                  SizedBox(height: size.height * 0.02),
                  inputTextField(
                    '',
                    reenteraccountNumbercontroller,
                    errorText: accountMismatchError,
                    isNumeric: true,
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
                          // All fields valid and accounts match, show transfer options
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
    // ... (Your _buildLabel implementation)
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
        bool isNumeric = false,
      }) {
    // ... (Your inputTextField implementation)
    return TextFormField(
      controller: controller,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
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
// ... (OptionRow class remains the same)