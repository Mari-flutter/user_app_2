import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Models/User_chit_breakdown/pending_payment_model.dart';
import '../Services/secure_storage.dart';

class PendingPaymentService {
  static Future<List<PendingPayment>> fetchPendingPayments() async {
    try {
      final profileId = await SecureStorageService.getProfileId();

      if (profileId == null || profileId.isEmpty) {
        throw Exception("Profile ID not found in secure storage");
      }

      final url = Uri.parse(
        'https://foxlchits.com/api/ChitPayment/pending-payments/profile/$profileId',
      );

      final response = await http.get(url);
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch pending payments: ${response.statusCode}');
      }

      final List<dynamic> data = jsonDecode(response.body);
      final List<PendingPayment> allPayments =
      data.map((e) => PendingPayment.fromJson(e)).toList();

      // ✅ Group payments by chitId
      final Map<String, List<PendingPayment>> grouped = {};
      print("🔹 Total payments fetched: ${allPayments.length}");
      for (var p in allPayments) {
        print("→ Chit: ${p.chitName} | ID: ${p.chitId} | Month: ${p.month} | Pending: ${p.pendingAmount}");
        if (p.chitId != null && p.chitId!.isNotEmpty) {
          grouped.putIfAbsent(p.chitId!, () => []).add(p);
        }
      }

      // ✅ Filter to only show the first *still pending* month for each chit
      final List<PendingPayment> filtered = [];
      print("🔸 Grouped Chits:");
      for (var entry in grouped.entries) {
        print("ChitId: ${entry.key} | Count: ${entry.value.length}");
        final chitPayments = entry.value;
        chitPayments.sort((a, b) => a.month.compareTo(b.month)); // sort ascending

        // find first payment that still has pending amount
        final unpaid = chitPayments.firstWhere(
              (p) => p.pendingAmount > 0,
          orElse: () => chitPayments.last,
        );

        // show only those which have pending balance
        if (unpaid.pendingAmount > 0) {
          filtered.add(unpaid);
        }
      }

      return filtered;
    } catch (e) {
      print("⚠️ Error fetching pending payments: $e");
      rethrow;
    }
  }
  static Future<List<PendingPayment>> fetchAllChitPayments() async {
    try {
      final profileId = await SecureStorageService.getProfileId();

      if (profileId == null || profileId.isEmpty) {
        throw Exception("Profile ID not found in secure storage");
      }

      final url = Uri.parse(
        'https://foxlchits.com/api/ChitPayment/pending-payments/profile/$profileId',
      );

      final response = await http.get(url);
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch chit payments: ${response.statusCode}');
      }

      final List<dynamic> data = jsonDecode(response.body);

      final List<PendingPayment> allPayments =
      data.map((e) => PendingPayment.fromJson(e)).toList();

      print("✅ Total chit payment records fetched: ${allPayments.length}");
      for (var p in allPayments) {
        print("→ ${p.chitName} | Month: ${p.month} | Pending: ${p.pendingAmount}");
      }

      return allPayments;
    } catch (e) {
      print("⚠️ Error fetching all chit payments: $e");
      rethrow;
    }
  }

}
