import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static bool get isLoggedIn => _prefs?.getBool('isLoggedIn') ?? false;

  static String? get userId => _prefs?.getString('userId');

  static String? get mobileNumber => _prefs?.getString('mobileNumber');

  static String? get chatToken => _prefs?.getString('chatToken');

  static Future<void> saveChatToken(String token) async {
    await _prefs?.setString('chatToken', token);
  }

  static Future<void> saveContactName(String userId, String name) async {
    await _prefs?.setString('contact_name_$userId', name);
  }

  static String? getContactName(String userId) {
    return _prefs?.getString('contact_name_$userId');
  }

  static Future<void> saveChannelName(String userId, String channelName) async {
    await _prefs?.setString('channel_name_$userId', channelName);
  }

  static String? getChannelName(String userId) {
    return _prefs?.getString('channel_name_$userId');
  }

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