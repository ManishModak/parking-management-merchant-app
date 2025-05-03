class Validation {
  static bool isValidUsername(String username) {
    return username.length >= 3;
  }

  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  static bool isValidMobile(String mobile) {
    final mobileRegex = RegExp(r'^\+?\d{10,12}$');
    return mobileRegex.hasMatch(mobile);
  }

  static bool isValidPassword(String password) {
    final passwordRegex = RegExp(
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
    return passwordRegex.hasMatch(password);
  }
}