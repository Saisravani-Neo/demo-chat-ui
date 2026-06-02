import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  LocalStorage._();

  static const _keyUserId = 'user_id';
  static const _keyMobileNumber = 'mobile_number';

  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ---------- User ----------

  static Future<void> saveUser({
    required String userId,
    required String mobileNumber,
  }) async {
    await Future.wait([
      _prefs.setString(_keyUserId, userId),
      _prefs.setString(_keyMobileNumber, mobileNumber),
    ]);
  }

  static String? get userId => _prefs.getString(_keyUserId);
  static String? get mobileNumber => _prefs.getString(_keyMobileNumber);

  static bool get isLoggedIn => userId != null && userId!.isNotEmpty;

  static Future<void> clearAll() async {
    await _prefs.clear();
  }
}
