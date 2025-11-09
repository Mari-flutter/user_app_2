import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:user_app/Models/Investments/Gold/user_hold_gold_model.dart';
import 'package:user_app/Services/secure_storage.dart';

class GoldHoldingsService {
  static const _goldHoldingsKey = 'gold_holdings';
  static const _goldHoldingsUpdatedAtKey = 'gold_holdings_updated_at';

  /// 🟡 Fetch holdings from backend and cache in Hive
  static Future<GoldHoldings?> fetchAndCacheGoldHoldings() async {
    try {
      final profileId = await SecureStorageService.getProfileId();
      if (profileId == null || profileId.isEmpty) {
        print("⚠️ No profileId found in secure storage");
        return null;
      }

      final url = Uri.parse("https://foxlchits.com/api/AddYourGold/$profileId");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final holdings = GoldHoldings.fromJson(data);

        final box = await Hive.openBox('goldBox');
        await box.put(_goldHoldingsKey, jsonEncode(holdings.toJson()));
        await box.put(_goldHoldingsUpdatedAtKey, DateTime.now().toIso8601String());

        print("✅ Gold holdings cached: ${holdings.toJson()}");
        return holdings;
      } else {
        print("❌ Failed to fetch gold holdings: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("⚠️ Error fetching gold holdings: $e");
      return null;
    }
  }

  /// 🟢 Get cached holdings if available
  static Future<GoldHoldings?> getCachedGoldHoldings() async {
    final box = await Hive.openBox('goldBox');
    final cached = box.get(_goldHoldingsKey);
    if (cached == null) return null;

    final decoded = jsonDecode(cached);
    return GoldHoldings.fromJson(decoded);
  }

  /// 🔁 Check how old cache is
  static Future<bool> isCacheStale({Duration maxAge = const Duration(minutes:1)}) async {
    final box = await Hive.openBox('goldBox');
    final ts = box.get(_goldHoldingsUpdatedAtKey);
    if (ts == null) return true;

    final lastUpdated = DateTime.parse(ts);
    return DateTime.now().difference(lastUpdated) > maxAge;
  }
}
