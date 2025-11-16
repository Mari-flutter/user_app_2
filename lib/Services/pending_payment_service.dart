import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Models/User_chit_breakdown/pending_payment_model.dart';
import '../Services/secure_storage.dart';
import 'package:flutter/material.dart';


class PendingPaymentService {
  static Future<List<PendingPayment>> fetchPendingPayments(BuildContext context) async {
    try {
      final profileId = await SecureStorageService.getProfileId();
      final Token = await SecureStorageService.getToken();

      if (profileId == null || profileId.isEmpty) {
        throw Exception("Profile ID not found in secure storage");
      }

      final url = Uri.parse(
        'https://foxlchits.com/api/ChitPayment/pending-payments/profile/$profileId',
      );

      final response = await http.get(url, headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $Token",
      });

      // ⭐ AUTO LOGOUT ON 401
      if (response.statusCode == 401) {
        await SecureStorageService.handleUnauthorized(context);
        return []; // empty list to avoid crashing Home screen
      }

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch pending payments: ${response.statusCode}');
      }

      final List<dynamic> data = jsonDecode(response.body);

      final List<PendingPayment> allPayments =
      data.map((e) => PendingPayment.fromJson(e)).toList();

      // --- your grouping + filtering logic remains EXACT SAME ---
      final Map<String, List<PendingPayment>> grouped = {};
      for (var p in allPayments) {
        if (p.chitId != null && p.chitId!.isNotEmpty) {
          grouped.putIfAbsent(p.chitId!, () => []).add(p);
        }
      }

      final List<PendingPayment> filtered = [];
      for (var entry in grouped.entries) {
        final chitPayments = entry.value;
        chitPayments.sort((a, b) => a.month.compareTo(b.month));

        final unpaid = chitPayments.firstWhere(
              (p) => p.pendingAmount > 0,
          orElse: () => chitPayments.last,
        );

        if (unpaid.pendingAmount > 0) filtered.add(unpaid);
      }

      return filtered;
    } catch (e) {
      print("⚠️ Error fetching pending payments: $e");
      rethrow;
    }
  }

  static Future<List<PendingPayment>> fetchAllChitPayments(BuildContext context) async {
    try {
      final profileId = await SecureStorageService.getProfileId();
      final Token = await SecureStorageService.getToken();

      if (profileId == null || profileId.isEmpty) {
        throw Exception("Profile ID not found in secure storage");
      }

      final url = Uri.parse(
        'https://foxlchits.com/api/ChitPayment/pending-payments/profile/$profileId',
      );

      final response = await http.get(url, headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $Token",
      },);
      if (response.statusCode == 401) {
        await SecureStorageService.handleUnauthorized(context);
        return []; // empty list to avoid crashing Home screen
      }
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
