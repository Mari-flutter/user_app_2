import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

// 🧩 Models
import '../Models/Investments/Gold/CurrentGoldValue_Model.dart';
import '../Models/Investments/Gold/gold_scheme_model.dart';
import '../Models/Investments/Gold/store_model.dart';
import '../Models/My_Chits/active_chits_model.dart';
import '../Models/My_Chits/explore_chit_model.dart';
import '../Models/My_Chits/past_auction_result_model.dart';
import '../Models/My_Investment/myinvestment_gold_model.dart';
import '../Models/Profile/profile_model.dart';
import '../Models/Chit_Groups/chit_groups.dart';
import '../Models/User_chit_breakdown/user_chit_breakdown_model.dart';

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
    print("saved token $token");
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
  // 🔹 ACTIVE & UPCOMING CHITS CACHE
  // ===========================================================

  static Future<void> saveActiveUpcomingChits(List<Chit_Group_Model> chits) async {
    final box = Hive.box('chitBox');
    final jsonString = jsonEncode(chits.map((e) => e.toJson()).toList());
    await box.put('active_upcoming_chits', jsonString);
    print('✅ Active-Upcoming Chits saved to Hive (${chits.length} items)');
  }

  static List<Chit_Group_Model> getActiveUpcomingChits() {
    final box = Hive.box('chitBox');
    final jsonString = box.get('active_upcoming_chits');
    if (jsonString != null) {
      final data = jsonDecode(jsonString) as List;
      print('📦 Loaded ${data.length} Active-Upcoming Chits from Hive');
      return data.map((e) => Chit_Group_Model.fromJson(e)).toList();
    }
    print('⚠️ No Active-Upcoming Chits found in Hive');
    return [];
  }

  static Future<void> clearActiveUpcomingChits() async {
    final box = Hive.box('chitBox');
    await box.delete('active_upcoming_chits');
    print('🗑️ Active-Upcoming Chits cache cleared');
  }

// ===========================================================
// 🔹 GOLD SCHEME SECTION
// ===========================================================



  /// Save list of gold schemes from API
  static Future<void> saveGoldSchemes(List<GoldScheme> schemes) async {
  final box = Hive.box('chitBox'); // reuse chitBox or create a new one if you prefer
  final jsonString = jsonEncode(schemes.map((e) => e.toJson()).toList());
  await box.put('gold_schemes', jsonString);
  print('✅ Gold Schemes saved to Hive (${schemes.length} items)');
  }

  /// Retrieve cached gold schemes
  static List<GoldScheme> getGoldSchemes() {
  final box = Hive.box('chitBox');
  final jsonString = box.get('gold_schemes');
  if (jsonString != null) {
  final data = jsonDecode(jsonString) as List;
  print('📦 Loaded ${data.length} gold schemes from cache');
  return data.map((e) => GoldScheme.fromJson(e)).toList();
  }
  print('⚠️ No gold schemes found in Hive cache');
  return [];
  }

  /// Clear cached gold schemes
  static Future<void> clearGoldSchemes() async {
  final box = Hive.box('chitBox');
  await box.delete('gold_schemes');
  print('🗑️ Gold schemes cache cleared');
  }
  static Future<void> saveMyInvestmentGold(
      MyInvestmentGoldModel data, String profileId) async {
    final box = Hive.box('chitBox');
    await box.put('my_investment_gold_$profileId', jsonEncode(data.toJson()));
    print('✅ MyInvestmentGoldModel cached for $profileId');
  }

  static MyInvestmentGoldModel? getMyInvestmentGold(String profileId) {
    final box = Hive.box('chitBox');
    final jsonString = box.get('my_investment_gold_$profileId');
    if (jsonString != null) {
      final data = jsonDecode(jsonString);
      return MyInvestmentGoldModel.fromJson(data);
    }
    print('⚠️ No MyInvestmentGoldModel cached for $profileId');
    return null;
  }

  static Future<void> clearMyInvestmentGold(String profileId) async {
    final box = Hive.box('chitBox');
    await box.delete('my_investment_gold_$profileId');
    print('🗑️ MyInvestmentGoldModel cache cleared for $profileId');
  }


// ===========================================================
// 🔹 STORE SELECTION SECTION (for /api/SchemeMember/all)
// ===========================================================

  /// Save list of all scheme members (stores/shops)
  static Future<void> saveStoreSelections(List<StoreSelectionModel> stores) async {
    final box = Hive.box('chitBox'); // Reusing 'chitBox' for general data
    final jsonString = jsonEncode(stores.map((e) => e.toJson()).toList());
    // The cache key has been updated to reflect the new model name
    await box.put('all_store_selections', jsonString);
    print('✅ Store Selections saved to Hive (${stores.length} items)');
  }

  /// Retrieve cached list of scheme members (stores/shops)
  static List<StoreSelectionModel> getStoreSelections() {
    final box = Hive.box('chitBox');
    final jsonString = box.get('all_store_selections');
    if (jsonString != null) {
      final data = jsonDecode(jsonString) as List;
      print('📦 Loaded ${data.length} store selections from cache');
      return data.map((e) => StoreSelectionModel.fromJson(e)).toList();
    }
    print('⚠️ No store selections found in Hive cache');
    return [];
  }

  /// Clear cached scheme members
  static Future<void> clearStoreSelections() async {
    final box = Hive.box('chitBox');
    await box.delete('all_store_selections');
    print('🗑️ Store selections cache cleared');
  }

// ===========================================================
// 🔹 USER CHIT BREAKDOWN (for /api/JoinToChit/profile/.../chits-summary)
// ===========================================================


  /// Save UserChitBreakdownModel to Hive (per profile)
  static Future<void> saveUserChitBreakdown(
      UserChitBreakdownModel data,
      String profileId,
      ) async {
    final box = Hive.box('chitBox');
    await box.put('user_chit_breakdown_$profileId', jsonEncode(data.toJson()));
    print('✅ UserChitBreakdownModel cached for $profileId');
  }

  /// Get cached UserChitBreakdownModel (to avoid reloads)
  static UserChitBreakdownModel? getUserChitBreakdown(String profileId) {
    final box = Hive.box('chitBox');
    final jsonString = box.get('user_chit_breakdown_$profileId');
    if (jsonString != null) {
      final data = jsonDecode(jsonString);
      print('📦 Loaded UserChitBreakdownModel for $profileId from cache');
      return UserChitBreakdownModel.fromJson(data);
    }
    print('⚠️ No UserChitBreakdownModel cached for $profileId');
    return null;
  }

  /// Clear UserChitBreakdownModel cache (optional for logout)
  static Future<void> clearUserChitBreakdown(String profileId) async {
    final box = Hive.box('chitBox');
    await box.delete('user_chit_breakdown_$profileId');
    print('🗑️ UserChitBreakdownModel cache cleared for $profileId');
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
