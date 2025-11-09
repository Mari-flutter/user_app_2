import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

// 🧩 Models
import '../Models/Investments/Gold/CurrentGoldValue_Model.dart';
import '../Models/My_Chits/active_chits_model.dart';
import '../Models/My_Chits/explore_chit_model.dart';
import '../Models/Profile/profile_model.dart';
import '../Models/Chit_Groups/chit_groups.dart';

class LocalStorageManager {
  // 🧠 Initialize Hive and open boxes
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox('authBox');
    await Hive.openBox('profileBox');
    await Hive.openBox('chitBox');
    await Hive.openBox('activitiesBox');
    await Hive.openBox('chitGroupBox');
  }

  // ===========================================================
  // 🔹 AUTH TOKEN SECTION
  // ===========================================================
  static Future<void> saveToken(String token) async {
    final box = Hive.box('authBox');
    await box.put('accessToken', token);
  }

  static String? getToken() {
    final box = Hive.box('authBox');
    return box.get('accessToken');
  }

  static Future<void> clearAuth() async {
    await Hive.box('authBox').clear();
  }

  // ===========================================================
  // 🔹 PROFILE SECTION
  // ===========================================================
  static Future<void> saveProfile(Profile profile, String profileId) async {
    final box = Hive.box('profileBox');
    await box.put('profile_$profileId', jsonEncode(profile.toJson()));
  }

  static Profile? getProfile(String profileId) {
    final box = Hive.box('profileBox');
    final jsonString = box.get('profile_$profileId');
    if (jsonString != null) {
      final data = jsonDecode(jsonString);
      return Profile.fromJson(data);
    }
    return null;
  }

  static Future<void> clearProfile(String profileId) async {
    final box = Hive.box('profileBox');
    await box.delete('profile_$profileId');
  }

  // ===========================================================
  // 🔹 CHITS SECTION
  // ===========================================================
  static Future<void> saveChits(List<Chit_Group_Model> chits) async {
    final box = Hive.box('chitBox');
    final jsonString = jsonEncode(chits.map((e) => e.toJson()).toList());
    await box.put('all_chits', jsonString);
    print('✅ Chits saved to Hive (${chits.length} items)');
  }

  static List<Chit_Group_Model>? getChits() {
    final box = Hive.box('chitBox');
    final jsonString = box.get('all_chits');
    if (jsonString != null) {
      final data = jsonDecode(jsonString) as List;
      print('📦 Loaded ${data.length} chits from Hive cache');
      return data.map((e) => Chit_Group_Model.fromJson(e)).toList();
    }
    print('⚠️ No chits found in Hive');
    return null;
  }

  static Future<void> clearChits() async {
    final box = Hive.box('chitBox');
    await box.delete('all_chits');
  }

  // ===========================================================
  // 🔹 CHIT GROUPS SECTION (New)
  // ===========================================================

  /// Save a single selected chit group details
  static Future<void> saveSelectedChitGroup(Chit_Group_Model chit) async {
    final box = Hive.box('chitGroupBox');
    await box.put('selected_chit_group', jsonEncode(chit.toJson()));
    print('✅ Selected chit group saved (${chit.chitsName})');
  }

  /// Get last selected chit group
  static Chit_Group_Model? getSelectedChitGroup() {
    final box = Hive.box('chitGroupBox');
    final jsonString = box.get('selected_chit_group');
    if (jsonString != null) {
      return Chit_Group_Model.fromJson(jsonDecode(jsonString));
    }
    return null;
  }

  /// Save user’s requested chit groups (like RequestedChitNotifier)
  static Future<void> saveRequestedChits(
    List<Map<String, dynamic>> chits,
  ) async {
    final box = Hive.box('chitGroupBox');
    await box.put('requested_chits', jsonEncode(chits));
    print('✅ Requested chits saved (${chits.length})');
  }

  static List<Map<String, dynamic>> getRequestedChits() {
    final box = Hive.box('chitGroupBox');
    final jsonString = box.get('requested_chits');
    if (jsonString != null) {
      final decoded = jsonDecode(jsonString) as List;
      return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return [];
  }

  /// Save joined chit groups (optional)
  static Future<void> saveJoinedChits(List<Map<String, dynamic>> chits) async {
    final box = Hive.box('chitGroupBox');
    await box.put('joined_chits', jsonEncode(chits));
    print('✅ Joined chits saved (${chits.length})');
  }

  static List<Map<String, dynamic>> getJoinedChits() {
    final box = Hive.box('chitGroupBox');
    final jsonString = box.get('joined_chits');
    if (jsonString != null) {
      final decoded = jsonDecode(jsonString) as List;
      return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return [];
  }

  /// Clear all chit group related caches
  static Future<void> clearChitGroups() async {
    final box = Hive.box('chitGroupBox');
    await box.clear();
  }

  // ===========================================================
  // 🔹 ACTIVITIES SECTION (Optional)
  // ===========================================================
  static Future<void> saveActivities(List<dynamic> activities) async {
    final box = Hive.box('activitiesBox');
    await box.put('recentActivities', jsonEncode(activities));
  }

  static List<dynamic> getActivities() {
    final box = Hive.box('activitiesBox');
    if (box.containsKey('recentActivities')) {
      return jsonDecode(box.get('recentActivities'));
    }
    return [];
  }

  static Future<void> clearActivities() async {
    await Hive.box('activitiesBox').delete('recentActivities');
  }

  // ===========================================================
  // 🔹 ACTIVE CHITS SECTION
  // ===========================================================
  /// Save Active Chits from API
  static Future<void> saveActiveChitsApi(
    List<ActiveChit> chits,
    String userId,
  ) async {
    final box = Hive.box('chitBox');
    final List<Map<String, dynamic>> chitMaps = chits
        .map((chit) => chit.toJson())
        .toList();
    await box.put('active_chits_api_$userId', jsonEncode(chitMaps));
    print('✅ Active chits from API saved (${chits.length}) for user: $userId');
  }

  /// Get cached Active Chits from Hive
  static List<ActiveChit> getActiveChitsApi(String userId) {
    final box = Hive.box('chitBox');
    final jsonString = box.get('active_chits_api_$userId');
    if (jsonString != null) {
      final decoded = jsonDecode(jsonString) as List;
      return decoded
          .map((e) => ActiveChit.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  /// Clear cached Active Chits
  static Future<void> clearActiveChitsApi(String userId) async {
    final box = Hive.box('chitBox');
    await box.delete('active_chits_api_$userId');
    print('🗑️ Active chits API cache cleared for user: $userId');
  }

  // ===========================================================
  // 🔹 REQUESTED CHITS API CACHING
  // ===========================================================

  /// Save requested chits to Hive (after API fetch)
  static Future<void> saveRequestedChitsApi(
    List<Map<String, dynamic>> chits,
  ) async {
    final box = Hive.box('chitGroupBox');
    await box.put('requested_chits_api', jsonEncode(chits));
    print('✅ Requested chits from API saved (${chits.length})');
  }

  /// Get cached requested chits from Hive
  static List<Map<String, dynamic>> getRequestedChitsApi() {
    final box = Hive.box('chitGroupBox');
    final jsonString = box.get('requested_chits_api');
    if (jsonString != null) {
      final decoded = jsonDecode(jsonString) as List;
      return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return [];
  }

  /// Clear cached requested chits
  static Future<void> clearRequestedChitsApi() async {
    final box = Hive.box('chitGroupBox');
    await box.delete('requested_chits_api');
    print('🗑️ Requested chits API cache cleared');
  }
  // ===========================================================
// 🔹 GOLD PRICE SECTION
// ===========================================================
  static Future<void> saveGoldValue(CurrentGoldValue gold) async {
    final box = Hive.box('chitBox'); // or make a 'goldBox' if you prefer
    await box.put('current_gold_value', jsonEncode(gold.toJson()));
    print('✅ Gold value stored in Hive: ₹${gold.goldValue}');
  }

  static CurrentGoldValue? getGoldValue() {
    final box = Hive.box('chitBox');
    final jsonString = box.get('current_gold_value');
    if (jsonString != null) {
      final data = jsonDecode(jsonString);
      print('📦 Loaded gold value from cache: ₹${data['goldValue']}');
      return CurrentGoldValue.fromJson(data);
    }
    print('⚠️ No gold value found in Hive cache');
    return null;
  }

  static Future<void> clearGoldValue() async {
    final box = Hive.box('chitBox');
    await box.delete('current_gold_value');
    print('🗑️ Gold value cache cleared');
  }
  // ===========================================================
// 🔹 EXPLORE CHIT CACHE (payment history)
// ===========================================================
  static Future<void> saveExploreChitCache(
      String chitId,
      String userId,
      List<ExploreChit> payments,
      ) async {
    final box = Hive.box('chitBox');
    await box.put(
      'explore_chit_${chitId}_$userId',
      jsonEncode(payments.map((e) => e.toJson()).toList()),
    );
    print('✅ Saved explore chit cache for $chitId & user $userId');
  }

  static List<ExploreChit> getExploreChitCache(String chitId, String userId) {
    final box = Hive.box('chitBox');
    final jsonString = box.get('explore_chit_${chitId}_$userId');
    if (jsonString != null) {
      final decoded = jsonDecode(jsonString) as List;
      return decoded
          .map((e) => ExploreChit.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  static Future<void> clearExploreChitCache(String chitId, String userId) async {
    final box = Hive.box('chitBox');
    await box.delete('explore_chit_${chitId}_$userId');
    print('🗑️ Cleared explore chit cache for $chitId');
  }


  // ===========================================================
  // 🔹 CLEAR ALL (useful for logout)
  // ===========================================================
  static Future<void> clearAll() async {
    await Hive.box('authBox').clear();
    await Hive.box('profileBox').clear();
    await Hive.box('chitBox').clear();
    await Hive.box('activitiesBox').clear();
    await Hive.box('chitGroupBox').clear();
    await Hive.box('chitGroupBox').clear();
  }
}
