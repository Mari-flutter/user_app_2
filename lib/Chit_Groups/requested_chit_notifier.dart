import 'package:user_app/Helper/Local_storage_manager.dart';

class RequestedChitNotifier {
  static List<Map<String, dynamic>> requestedChits = [];

  /// Initialize from Hive
  static Future<void> init() async {
    requestedChits = LocalStorageManager.getRequestedChits();
    print('📦 Loaded ${requestedChits.length} requested chits from Hive');
  }

  /// Add a chit to requested list
  static Future<void> addRequestedChit(Map<String, dynamic> chit) async {
    // Avoid duplicates
    if (!requestedChits.any((c) => c['chitsName'] == chit['chitsName'])) {
      requestedChits.add(chit);
      await LocalStorageManager.saveRequestedChits(requestedChits);
      print('✅ Chit requested: ${chit['chitsName']}');
    }
  }

  /// Check if a chit is requested
  static bool isRequested(String chitName) {
    return requestedChits.any((c) => c['chitsName'] == chitName);
  }
}
