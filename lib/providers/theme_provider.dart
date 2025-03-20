import 'package:flutter/material.dart';
import '../config/app_config.dart';
import 'dart:developer' as developer;

class Result<T> {
  final T? value;
  final String? error;

  Result.success(this.value) : error = null;
  Result.failure(this.error) : value = null;

  bool get isSuccess => error == null;
}

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _initFromAppConfig();
    AppConfig.listenToChanges(
      onThemeChanged: _onAppConfigThemeChanged,
      onLanguageChanged: () {},
    );
    developer.log('ThemeProvider initialized with mode: ${_themeMode.name}', name: 'ThemeProvider');
  }

  void _initFromAppConfig() {
    _themeMode = _mapAppThemeModeToThemeMode(AppConfig.theme);
  }

  void _onAppConfigThemeChanged() {
    final newMode = _mapAppThemeModeToThemeMode(AppConfig.theme);
    if (_themeMode != newMode) {
      _themeMode = newMode;
      notifyListeners();
      developer.log('Theme changed to ${newMode.name}', name: 'ThemeProvider');
    }
  }

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<Object> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) {
      developer.log('Theme mode unchanged: ${mode.name}', name: 'ThemeProvider');
      return Result.success(null);
    }

    _themeMode = mode;
    final appThemeMode = _mapThemeModeToAppThemeMode(mode);

    final result = await AppConfig.setTheme(appThemeMode);
    if (result.isSuccess) {
      notifyListeners();
      developer.log('Theme mode set to ${mode.name}', name: 'ThemeProvider');
    } else {
      developer.log('Failed to set theme mode: ${result.error}', name: 'ThemeProvider');
    }
    return result;
  }

  Future<Future<Object>> toggleThemeMode() async {
    final newMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    return setThemeMode(newMode);
  }

  ThemeMode _mapAppThemeModeToThemeMode(AppThemeMode appMode) {
    switch (appMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  AppThemeMode _mapThemeModeToAppThemeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return AppThemeMode.light;
      case ThemeMode.dark:
        return AppThemeMode.dark;
      case ThemeMode.system:
        return AppThemeMode.system;
    }
  }

  @override
  void dispose() {
    AppConfig.removeListeners(
      onThemeChanged: _onAppConfigThemeChanged,
      onLanguageChanged: () {},
    );
    developer.log('ThemeProvider disposed', name: 'ThemeProvider');
    super.dispose();
  }
}