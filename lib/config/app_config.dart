import 'package:flutter/material.dart';
import '../services/storage/secure_storage_service.dart';
import '../services/storage/shared_preferences_service.dart';
import 'dart:developer' as developer;

enum AppThemeMode {
  light('light'),
  dark('dark'),
  system('system');

  final String value;
  const AppThemeMode(this.value);

  static AppThemeMode fromString(String value) {
    return values.firstWhere(
          (mode) => mode.value == value,
      orElse: () => AppThemeMode.light,
    );
  }
}

class Result<T> {
  final T? value;
  final String? error;

  Result.success(this.value) : error = null;
  Result.failure(this.error) : value = null;

  bool get isSuccess => error == null;
}

class AppConfig {
  static double? _deviceWidth;
  static double? _deviceHeight;
  static double get deviceWidth => _deviceWidth ?? 300;
  static double get deviceHeight => _deviceHeight ?? 300;
  static set deviceWidth(double? value) => _deviceWidth = value;
  static set deviceHeight(double? value) => _deviceHeight = value;

  static bool _isBiometricEnabled = false;
  static bool _isNotificationsEnabled = true;
  static String _language = 'en';
  static AppThemeMode _themeMode = AppThemeMode.light;

  static bool get isBiometricEnabled => _isBiometricEnabled;
  static bool get isNotificationsEnabled => _isNotificationsEnabled;
  static String get language => _language;
  static AppThemeMode get theme => _themeMode;

  static const bool enableBiometrics = true;
  static const bool enablePushNotifications = true;
  static const String languageKey = 'app_language';
  static const String themeKey = 'app_theme';
  static const String notificationsEnabledKey = 'notifications_enabled';
  static const String biometricEnabledKey = 'biometric_enabled';
  static const String defaultLanguage = 'en';
  static const String defaultTheme = 'light';

  static final ValueNotifier<String> languageNotifier = ValueNotifier<String>(_language);
  static final ValueNotifier<String> themeNotifier = ValueNotifier<String>(_themeMode.value);
  static bool _isLoadingSettings = false;

  static Future<void> initializeSettings() async {
    developer.log('Initializing app settings', name: 'AppConfig');
    await SharedPreferenceService.init();
    await loadSettings();
  }

  static Future<void> loadSettings() async {
    if (_isLoadingSettings) return;
    _isLoadingSettings = true;
    try {
      final secureStorage = SecureStorageService();
      final biometricValue = await secureStorage.read(biometricEnabledKey);
      _isBiometricEnabled = biometricValue == 'true';
      _isNotificationsEnabled = await SharedPreferenceService.getBool(notificationsEnabledKey) ?? enablePushNotifications;
      _language = await SharedPreferenceService.getString(languageKey) ?? defaultLanguage;
      _themeMode = AppThemeMode.fromString(await SharedPreferenceService.getString(themeKey) ?? defaultTheme);
      languageNotifier.value = _language;
      themeNotifier.value = _themeMode.value;
      developer.log('Settings loaded: language=$_language, theme=${_themeMode.value}', name: 'AppConfig');
    } finally {
      _isLoadingSettings = false;
    }
  }

  static Future<Result<void>> setBiometricEnabled(bool value) async {
    try {
      _isBiometricEnabled = value;
      final secureStorage = SecureStorageService();
      await secureStorage.write(biometricEnabledKey, value.toString());
      developer.log('Biometric enabled set to $value', name: 'AppConfig');
      return Result.success(null);
    } catch (e) {
      developer.log('Error setting biometric: $e', name: 'AppConfig', error: e);
      return Result.failure(e.toString());
    }
  }

  static Future<Result<void>> setNotificationsEnabled(bool value) async {
    try {
      _isNotificationsEnabled = value;
      await SharedPreferenceService.setBool(notificationsEnabledKey, value);
      developer.log('Notifications enabled set to $value', name: 'AppConfig');
      return Result.success(null);
    } catch (e) {
      developer.log('Error setting notifications: $e', name: 'AppConfig', error: e);
      return Result.failure(e.toString());
    }
  }

  static Future<Result<void>> setLanguage(String value) async {
    if (!isValidLanguage(value)) {
      developer.log('Unsupported language attempted: $value', name: 'AppConfig');
      return Result.failure('Unsupported language: $value');
    }
    try {
      _language = value;
      languageNotifier.value = value;
      await SharedPreferenceService.setString(languageKey, value);
      developer.log('Language set to $value', name: 'AppConfig');
      return Result.success(null);
    } catch (e) {
      developer.log('Error setting language: $e', name: 'AppConfig', error: e);
      return Result.failure(e.toString());
    }
  }

  static Future<Result<void>> setTheme(AppThemeMode mode) async {
    try {
      _themeMode = mode;
      themeNotifier.value = mode.value;
      await SharedPreferenceService.setString(themeKey, mode.value);
      developer.log('Theme set to ${mode.value}', name: 'AppConfig');
      return Result.success(null);
    } catch (e) {
      developer.log('Error setting theme: $e', name: 'AppConfig', error: e);
      return Result.failure(e.toString());
    }
  }

  static Future<void> resetToDefaults() async {
    try {
      _isBiometricEnabled = false;
      _isNotificationsEnabled = true;
      _language = defaultLanguage;
      _themeMode = AppThemeMode.light;

      final secureStorage = SecureStorageService();
      await secureStorage.delete(biometricEnabledKey);
      await SharedPreferenceService.clear();

      await initializeSettings();
      developer.log('Settings reset to defaults', name: 'AppConfig');
    } catch (e) {
      developer.log('Error resetting settings: $e', name: 'AppConfig', error: e);
      rethrow;
    }
  }

  static bool isValidLanguage(String code) {
    const supportedLanguages = ['en', 'hi', 'mr'];
    return supportedLanguages.contains(code);
  }

  static void listenToChanges({
    required VoidCallback onLanguageChanged,
    required VoidCallback onThemeChanged,
  }) {
    languageNotifier.addListener(onLanguageChanged);
    themeNotifier.addListener(onThemeChanged);
    developer.log('Listeners added for language and theme changes', name: 'AppConfig');
  }

  static void removeListeners({
    required VoidCallback onLanguageChanged,
    required VoidCallback onThemeChanged,
  }) {
    languageNotifier.removeListener(onLanguageChanged);
    themeNotifier.removeListener(onThemeChanged);
    developer.log('Listeners removed for language and theme changes', name: 'AppConfig');
  }

  static String getLanguageText(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'hi':
        return 'Hindi';
      case 'mr':
        return 'Marathi';
      default:
        return 'English';
    }
  }

  static String getThemeText(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.system:
        return 'System Default';
    }
  }
}