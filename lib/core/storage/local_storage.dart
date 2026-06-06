import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static bool get isLoggedIn => _prefs?.getBool('isLoggedIn') ?? false;

  static String? get userId => _prefs?.getString('userId');

  static String? get mobileNumber => _prefs?.getString('mobileNumber');

  static Future<void> saveUser({
    required String userId,
    required String mobileNumber,
  }) async {
    await _prefs?.setBool('isLoggedIn', true);
    await _prefs?.setString('userId', userId);
    await _prefs?.setString('mobileNumber', mobileNumber);
  }

  static Future<void> clear() async {
    await _prefs?.clear();
  }
}