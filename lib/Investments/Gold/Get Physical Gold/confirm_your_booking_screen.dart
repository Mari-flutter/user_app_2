import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http; // Import HTTP package
import 'dart:convert'; // Import dart:convert for JSON encoding
import 'package:user_app/Models/Investments/Gold/store_model.dart';
import 'package:user_app/Services/secure_storage.dart';

import '../../../Models/Investments/Gold/CurrentGoldValue_Model.dart';
import 'confirmation_receipts_screen.dart';

// You'll likely need to import your local storage helper here
// import '../../Helper/Local_storage_manager.dart';

class confirm_your_booking extends StatefulWidget {
  final StoreSelectionModel selectedStore;
  final double selectedGrams;
  final double EstimatedValue;
  final String Storecontact;
  final CurrentGoldValue? goldvalue;

  const confirm_your_booking({
    super.key,
    required this.selectedStore,
    required this.selectedGrams,
    required this.EstimatedValue,
    required this.Storecontact,
    required this.goldvalue,
  });

  @override
  State<confirm_your_booking> createState() => _confirm_your_bookingState();
}

class _confirm_your_bookingState extends State<confirm_your_booking> {
  // --- State for API call management ---
  bool _isConfirming = false;

  // NOTE: REPLACE THIS WITH THE ACTUAL PROFILE ID FROM YOUR AUTH/STORAGE
  // For demonstration, using a placeholder GUID.

  // --- API Endpoint and Fixed Fee ---
  static const String _API_URL =
      'https://foxlchits.com/api/SchemeMember/BuyPhysicalGold';
  final double _platformFee = 210.0; // ₹210

  // Placeholder function (assuming it's not needed since EstimatedValue is passed)
  // Removed _calculateEstimatePrice as EstimatedValue is now passed from the previous screen.

  // =======================================================
  // 1. API Confirmation Logic
  // =======================================================
  Future<void> _confirmBooking() async {
    final Token = await SecureStorageService.getToken();
    final profileId = await SecureStorageService.getProfileId();
    if (_isConfirming) return;

    setState(() {
      _isConfirming = true;
    });

    // ✅ Calculate final grams
    final double pricePerGram = widget.goldvalue?.goldValue ?? 0.0;
    final double finalAmount = widget.EstimatedValue - _platformFee;
    final double finalGoldGram =
    pricePerGram > 0 ? (finalAmount / pricePerGram) : 0.0;

    print("💸 Final Amount (after fee): $finalAmount");
    print("🏅 Final Gold Gram sent to API: $finalGoldGram");

    final Map<String, dynamic> requestBody = {
      "profileId": profileId,
      "goldShopId": widget.selectedStore.id,
      "goldGram": finalGoldGram,
    };

    try {
      final response = await http.post(
        Uri.parse(_API_URL),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $Token",
        },
        body: jsonEncode(requestBody),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => confirmation_receipts(
              store: widget.selectedStore.shopName,
              selectedGrams: finalGoldGram, // ✔ Send final grams to UI also
              storecontact: widget.Storecontact,
              storelocation: widget.selectedStore.address,
            ),
          ),
        );
      } else {
        _showErrorSnackBar('Booking failed. Please try again.');
      }
    } catch (e) {
      _showErrorSnackBar('Network error. Check your connection.');
    } finally {
      if (mounted) {
        setState(() {
          _isConfirming = false;
        });
      }
    }
  }


  // Helper method to display errors
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // =======================================================
  // 2. Build Method
  // =======================================================
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    final double grams = widget.selectedGrams;
    final String storeName = widget.selectedStore.shopName;

    final double pricePerGram = widget.goldvalue?.goldValue ?? 0.0;

// 🔥 NEW CALCULATIONS
    final double finalAmount = widget.EstimatedValue - _platformFee;
    final double finalGrams = pricePerGram > 0 ? (finalAmount / pricePerGram) : 0.0;



    return Scaffold(
      backgroundColor: const Color(0xff000000),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ... (Header and back button) ...
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
                      'Confirm your Booking',
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

                // --- Booking Details Container ---
                Container(
                  width: double.infinity,
                  // Adjusted height to accommodate the CircularProgressIndicator
                  height: size.height * 0.53,
                  decoration: BoxDecoration(
                    color: const Color(0xff1F1F1F),
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(
                      color: const Color(0xff61512B),
                      width: .5,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.04,
                      vertical: size.height * 0.02,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Please review your booking details\nbefore confirming',
                          style: GoogleFonts.urbanist(
                            textStyle: const TextStyle(
                              color: Color(0xffDDDDDD),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(height: size.height * 0.02),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.04,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // --- Gold Amount ---
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Gold Amount',
                                    style: GoogleFonts.urbanist(
                                      textStyle: const TextStyle(
                                        color: Color(0xff989898),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${grams.toStringAsFixed(2)}g',
                                    style: GoogleFonts.urbanist(
                                      textStyle: const TextStyle(
                                        color: Color(0xff989898),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: size.height * 0.005),

                              // --- Estimate ---
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Estimate',
                                    style: GoogleFonts.urbanist(
                                      textStyle: const TextStyle(
                                        color: Color(0xff989898),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '₹${widget.EstimatedValue.toStringAsFixed(0)}',
                                    style: GoogleFonts.urbanist(
                                      textStyle: const TextStyle(
                                        color: Color(0xff989898),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: size.height * 0.005),

                              // --- Format ---
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Format',
                                    style: GoogleFonts.urbanist(
                                      textStyle: const TextStyle(
                                        color: Color(0xff989898),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const Text(
                                    'Physical Gold',
                                    style: TextStyle(
                                      color: Color(0xff989898),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: size.height * 0.005),

                              // --- Store Name (Binding the ID in the payload, but displaying name) ---
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Store',
                                    style: GoogleFonts.urbanist(
                                      textStyle: const TextStyle(
                                        color: Color(0xff989898),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    storeName,
                                    style: GoogleFonts.urbanist(
                                      textStyle: const TextStyle(
                                        color: Color(0xff989898),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: size.height * 0.005),

                              // --- Platform Fee ---
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Platform Fee',
                                    style: GoogleFonts.urbanist(
                                      textStyle: const TextStyle(
                                        color: Color(0xff989898),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '₹${_platformFee.toStringAsFixed(0)}',
                                    style: GoogleFonts.urbanist(
                                      textStyle: const TextStyle(
                                        color: Color(0xff989898),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: size.height * 0.025),

                              const Divider(
                                color: Color(0xff61512B),
                                height: 1,
                              ),
                              SizedBox(height: size.height * 0.025),

                              // --- Total Gold Value ---
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total Gold Value',
                                    style: GoogleFonts.urbanist(
                                      textStyle: const TextStyle(
                                        color: Color(0xffD1AF74),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${finalGrams.toStringAsFixed(2)} g',
                                    style: GoogleFonts.urbanist(
                                      textStyle: const TextStyle(
                                        color: Color(0xffD1AF74),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: size.height * 0.035),

                              // --- Alert Container ---
                              Container(
                                width: double.infinity,
                                height: 51,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: const Color(0xff515151),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(width: size.width * 0.02),
                                    Center(
                                      child: Image.asset(
                                        'assets/images/Investments/alert_2.png',
                                        width: 16,
                                        height: 16,
                                      ),
                                    ),
                                    SizedBox(width: size.width * 0.02),
                                    Center(
                                      child: Text(
                                        'By confirming, you agree to convert ${grams.toStringAsFixed(2)}g of digital gold to\nphysical gold. The amount will be deducted from your holdings\nand charges from your wallet.',
                                        style: GoogleFonts.urbanist(
                                          textStyle: const TextStyle(
                                            color: Color(0xff989898),
                                            fontSize: 9,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: size.height * 0.04),

                              // --- Confirm Button ---
                              GestureDetector(
                                onTap: _isConfirming ? null : _confirmBooking,
                                // Disable tap when loading
                                child: Container(
                                  width: double.infinity,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(11),
                                    // Dim color if loading
                                    color: _isConfirming
                                        ? const Color(0xffA09068)
                                        : const Color(0xffD4B373),
                                  ),
                                  child: Center(
                                    child: _isConfirming
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              color: Color(0xff544B35),
                                              strokeWidth: 3,
                                            ),
                                          )
                                        : Text(
                                            'Confirm Booking',
                                            style: GoogleFonts.urbanist(
                                              textStyle: const TextStyle(
                                                color: Color(0xff544B35),
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
                      ],
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
