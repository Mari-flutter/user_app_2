import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:user_app/Profile/setup_profile_screen.dart';

class DiditKYCWebviewScreen extends StatelessWidget {
  final String kycUrl;
  final String profileID;

  const DiditKYCWebviewScreen({
    super.key,
    required this.kycUrl,
    required this.profileID,
  });

  // 1. HELPER FUNCTION (VOID) - Handles Flutter Navigation
  void _handleKycCompletion(BuildContext context, String? status) {
    if (!context.mounted) return;

    final normalizedStatus = status?.toLowerCase() ?? '';

    if (normalizedStatus == 'approved' || normalizedStatus == 'completed') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const setup_profile()),
            (Route<dynamic> route) => false,
      );
    } else {
      Navigator.pop(context); // Return to the previous screen

      String message;
      Color color;

      if (normalizedStatus == 'declined') {
        message = 'KYC Declined. Please contact support.';
        color = Colors.red;
      } else {
        message = 'KYC is currently In Review. We will notify you when approved.';
        color = Colors.orange;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  // 2. WEBVIEW HANDLER (EXPLICIT FUNCTION DEFINITION) - Fixes the Type Error
  // This explicitly declares the required return type: Future<NavigationActionPolicy>
  Future<NavigationActionPolicy> _kycOnLoadStartHandler(
      InAppWebViewController controller, WebUri? url, BuildContext context) async {

    final urlString = url.toString();
    final uri = Uri.tryParse(urlString);

    // Ensure we are checking the correct callback endpoint (using the log's URL)
    if (urlString.contains("foxlchits.com/api/KYCDidit/Profile-kyc-callback")) {

      final kycStatus = uri?.queryParameters['status'];
      print('DIDIT CALLBACK INTERCEPTED. Status: $kycStatus');

      // Call the Flutter navigation handler
      _handleKycCompletion(context, kycStatus);

      // CRITICAL: Return CANCEL to stop the native webview from attempting to load the URL,
      // which is what causes the internal crash/error messages.
      return NavigationActionPolicy.CANCEL;
    }

    // Allow all other normal page navigation
    return NavigationActionPolicy.ALLOW;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KYC Verification'),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(kycUrl)),

        onPermissionRequest: (controller, request) async {
          return PermissionResponse(
              action: PermissionResponseAction.GRANT,
              resources: request.resources);
        },

        // Assign the external function to the callback
        onLoadStart: (controller, url) => _kycOnLoadStartHandler(controller, url, context),
      ),
    );
  }
}