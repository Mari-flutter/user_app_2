import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:user_app/Models/Investments/Gold/CurrentGoldValue_Model.dart';
import 'package:user_app/Helper/Local_storage_manager.dart';

class GoldService {
  static const String _apiUrl = 'https://foxlchits.com/api/GoldInvestments';

  // ✅ Fetch from API and cache in Hive
  static Future<CurrentGoldValue?> fetchAndCacheGoldValue() async {
    print('🔹 Fetching gold price...');
    final response = await http.get(Uri.parse(_apiUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      if (data.isNotEmpty) {
        final gold = CurrentGoldValue.fromJson(data[0]);
        await LocalStorageManager.saveGoldValue(gold);
        print('✅ Gold value saved locally: ₹${gold.goldValue}');
        return gold;
      }
    } else {
      print('❌ Failed to fetch gold value, status: ${response.statusCode}');
    }
    return null;
  }

  // ✅ Read cached value
  static Future<CurrentGoldValue?> getCachedGoldValue() async {
    final cached = LocalStorageManager.getGoldValue();
    if (cached != null) {
      print('💾 Cached gold value loaded: ₹${cached.goldValue}');
    } else {
      print('⚠️ No cached gold found');
    }
    return cached;
  }
}
