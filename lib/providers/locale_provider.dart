import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_config.dart';

class LocaleProvider extends ChangeNotifier {
  Locale get locale => Locale(AppConfig.language);

  LocaleProvider() {
    // Listen for language changes from AppConfig
    AppConfig.languageNotifier.addListener(() {
      notifyListeners();
    });
  }

  void setLocale(String languageCode) {
    AppConfig.setLanguage(languageCode);
    // No need to call notifyListeners here as it's handled by the listener above
  }

  // Helper method to get language name from code
  String getLanguageName(String code) {
    return AppConfig.getLanguageText(code);
  }

  // List of supported languages
  List<Map<String, String>> get supportedLanguages => [
    {'code': 'en', 'name': AppConfig.getLanguageText('en')},
    {'code': 'hi', 'name': AppConfig.getLanguageText('hi')},
    {'code': 'mr', 'name': AppConfig.getLanguageText('mr')}
  ];
}