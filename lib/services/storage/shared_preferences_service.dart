import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceService {
  static SharedPreferences? _preferences;

  // Initialize SharedPreferences
  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // Get instance (with initialization if needed)
  static Future<SharedPreferences> get instance async {
    if (_preferences == null) {
      await init();
    }
    return _preferences!;
  }

  // String operations
  static Future<bool> setString(String key, String value) async {
    final prefs = await instance;
    return prefs.setString(key, value);
  }

  static Future<String?> getString(String key) async {
    final prefs = await instance;
    return prefs.getString(key);
  }

  // Boolean operations
  static Future<bool> setBool(String key, bool value) async {
    final prefs = await instance;
    return prefs.setBool(key, value);
  }

  static Future<bool?> getBool(String key) async {
    final prefs = await instance;
    return prefs.getBool(key);
  }

  // Int operations
  static Future<bool> setInt(String key, int value) async {
    final prefs = await instance;
    return prefs.setInt(key, value);
  }

  static Future<int?> getInt(String key) async {
    final prefs = await instance;
    return prefs.getInt(key);
  }

  // Double operations
  static Future<bool> setDouble(String key, double value) async {
    final prefs = await instance;
    return prefs.setDouble(key, value);
  }

  static Future<double?> getDouble(String key) async {
    final prefs = await instance;
    return prefs.getDouble(key);
  }

  // Clear specific key
  static Future<bool> remove(String key) async {
    final prefs = await instance;
    return prefs.remove(key);
  }

  // Clear all preferences
  static Future<bool> clear() async {
    final prefs = await instance;
    return prefs.clear();
  }
}
