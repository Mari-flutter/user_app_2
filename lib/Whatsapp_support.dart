import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io' show Platform;

import 'package:url_launcher/url_launcher.dart';

import 'Bottom_Navbar/bottom_navigation_bar.dart'; // Required to check the operating system

// --- COMPANY DETAILS (Constants) ---
// Your company number (no +, no 0, just digits)
const String companyNumber = '6382826863';
// The pre-filled message for the user
const String initialMessage = 'I need Help in Foxl App';
// -----------------------------------

class WhatsAppScreen extends StatelessWidget {
  const WhatsAppScreen({super.key});

  // --- 1. THE PLATFORM-AWARE LAUNCH FUNCTION (FIXED) ---
  Future<void> launchWhatsAppChat(BuildContext context) async {
    // 1. URL Encoding
    final String encodedMessage = Uri.encodeComponent(initialMessage);
    String url;

    // 2. Platform-Specific URL Construction
    // Explicitly use the native scheme on Android/iOS for highest reliability
    if (Platform.isAndroid) {
      // Use the direct scheme on Android (requires <queries> block in Manifest)
      url = "whatsapp://send?phone=$companyNumber&text=$encodedMessage";
    } else if (Platform.isIOS) {
      // Use the universal HTTPS link on iOS (most reliable)
      url = "https://wa.me/$companyNumber?text=$encodedMessage";
    } else {
      // Fallback for Web/Desktop
      url = "https://wa.me/$companyNumber?text=$encodedMessage";
    }

    final Uri whatsappUri = Uri.parse(url);

    // 3. Launching the URL
    if (await canLaunchUrl(whatsappUri)) {
      // Launch the URL, forcing external application use.
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      // Fallback: This is triggered if the OS reports it can't handle the URL
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Could not open WhatsApp. Please ensure the app is installed and check platform configurations."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // --- 2. THE UI WIDGET ---
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xff000000),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
          child: Column(
            children: [

              SizedBox(height: size.height * 0.02),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HomeLayout()),
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
                    'Contact & Support',
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
              SizedBox(height: size.height*0.2,),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(32.0),
                  margin: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Icon(Icons.support_agent, size: 60, color: Color(0xFF25D366)),
                      const SizedBox(height: 20),
                      const Text(
                        'Need immediate help?',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF128C7E)),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Click the button below to start a chat with our support team on WhatsApp. Your message will be pre-filled for convenience.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      const SizedBox(height: 40),

                      // The WhatsApp Button
                      ElevatedButton.icon(
                        onPressed: () => launchWhatsAppChat(context), // Call the function
                        icon: const Icon(Icons.help, color: Colors.white, size: 24),
                        label: const Text('Chat with Foxl Support'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366), // WhatsApp Green
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          elevation: 5,
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
}