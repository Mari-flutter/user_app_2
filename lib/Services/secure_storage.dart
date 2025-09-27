import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static final _storage = FlutterSecureStorage();

  static const _keyProfileId = 'profileId';
  static const _keyToken = 'token';

  /// Save profileId & token
  static Future<void> saveSession(String profileId, String token) async {
    await _storage.write(key: _keyProfileId, value: profileId);
    await _storage.write(key: _keyToken, value: token);
  }

  /// Read profileId
  static Future<String?> getProfileId() async {
    return await _storage.read(key: _keyProfileId);
  }

  /// Read token
  static Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }

  /// Clear all
  static Future<void> clearSession() async {
    await _storage.delete(key: _keyProfileId);
    await _storage.delete(key: _keyToken);
  }
}
