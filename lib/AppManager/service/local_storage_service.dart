import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _userUidKey = 'userUid';
  static const String _userEmailKey = 'userEmail';
  static const String _usernameKey = 'username';
  static const String _languageKey = 'language';
  static const String _investmentCacheKey = 'cached_investment_tiers';

  static Future<void> saveUserLoginStatus(bool isLoggedIn, String uid, String email, String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, isLoggedIn);
    await prefs.setString(_userUidKey, uid);
    await prefs.setString(_userEmailKey, email);
    await prefs.setString(_usernameKey, username);
  }

  static Future<void> saveLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);
  }

  static Future<String?> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  static Future<String?> getUserUid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userUidKey);
  }

  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString(_languageKey);
    await prefs.clear(); // Complete wipe to handle "new user" fresh state requirement
    if (lang != null) {
      await prefs.setString(_languageKey, lang); // Preserve language preference
    }
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
