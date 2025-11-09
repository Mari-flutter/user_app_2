import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class SecureStorageService {
  static final _storage = FlutterSecureStorage();

  static const _keyProfileId = 'profileId';
  static const _keyToken = 'token';
  static const _keyUserId = 'userId';
  static const _keyReferId = 'referId';
  static const _keyUserName = 'userName';



  // ✅ Save after login
  static Future<void> saveSession(String profileId, String token) async {
    await _storage.write(key: _keyProfileId, value: profileId);
    await _storage.write(key: _keyToken, value: token);
  }

  // ✅ Fetch profile details and save userId, referId, and userName
  static Future<void> updateUserAndReferIdsFromApi() async {
    final profileId = await _storage.read(key: _keyProfileId);
    if (profileId == null || profileId.isEmpty) {
      print("⚠️ No profileId found in secure storage");
      return;
    }

    final url = Uri.parse("https://foxlchits.com/api/Profile/profile/$profileId");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final userId = data['userID']?.toString();
        final referId = data['referId']?.toString();
        final userName = data['name']?.toString();
        print("📦 Profile API response: ${response.body}");


        if (userId != null) await _storage.write(key: _keyUserId, value: userId);
        if (referId != null) await _storage.write(key: _keyReferId, value: referId);
        if (userName != null) await _storage.write(key: _keyUserName, value: userName);

        print("✅ Stored userId=$userId, referId=$referId, userName=$userName in SecureStorage");
      } else {
        print("❌ Profile fetch failed: ${response.statusCode}");
      }
    } catch (e) {
      print("⚠️ Error fetching profile details: $e");
    }
  }

  // ✅ Getters
  static Future<String?> getUserId() async => await _storage.read(key: _keyUserId);
  static Future<String?> getReferId() async => await _storage.read(key: _keyReferId);
  static Future<String?> getProfileId() async => await _storage.read(key: _keyProfileId);
  static Future<String?> getUserName() async => await _storage.read(key: _keyUserName);
  static Future<String?> getToken() async => await _storage.read(key: _keyToken);

  // ✅ Clear all
  static Future<void> clearSession() async => await _storage.deleteAll();
}
