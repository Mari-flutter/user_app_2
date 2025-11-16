import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:user_app/Models/Investments/Gold/CurrentGoldValue_Model.dart';
import 'package:user_app/Helper/Local_storage_manager.dart';
import 'package:user_app/Services/secure_storage.dart';

// In user_app/Services/Gold_price.dart (formerly GoldService)

// ... existing imports ...

class GoldService {
  static const String _apiUrl = 'https://foxlchits.com/api/GoldInvestments';

  // ✅ Fetch from API and cache in Hive
  static Future<CurrentGoldValue?> fetchAndCacheGoldValue() async {
    final Token = await SecureStorageService.getToken();
    print('🔹 Fetching gold price...');
    final response = await http.get(Uri.parse(_apiUrl), headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $Token",
    },);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      if (data.isNotEmpty) {
        // 🔑 MODIFICATION HERE: Use data.last to get the last/latest item
        // in the list, assuming the API sends the newest price last.
        final gold = CurrentGoldValue.fromJson(data.last);

        await LocalStorageManager.saveGoldValue(gold);
        print('✅ Latest gold value saved locally: ₹${gold.goldValue}');
        return gold;
      }
    } else {
      print('❌ Failed to fetch gold value, status: ${response.statusCode}');
    }
    return null;
  }

  // ✅ Read cached value (This can remain the same)
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
