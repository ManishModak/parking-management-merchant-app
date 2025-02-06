class AppConfig {
  // Private nullable static variables
  static double? _deviceWidth;
  static double? _deviceHeight;

  // Public getters with fallback to 300
  static double get deviceWidth => _deviceWidth ?? 300;
  static double get deviceHeight => _deviceHeight ?? 300;

  // Setters to update the private values
  static set deviceWidth(double? value) => _deviceWidth = value;
  static set deviceHeight(double? value) => _deviceHeight = value;

  // Feature flags
  static const bool enableBiometrics = true;
  static const bool enablePushNotifications = true;
}