import 'package:flutter/foundation.dart';
import 'package:merchant_app/config/app_strings.dart';

import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService;

  String _userIdError = '';
  String _passwordError = '';
  String _generalError = '';
  bool _isLoading = false;

  AuthViewModel(this._authService);

  bool get isLoading => _isLoading;

  String get userIdError => _userIdError;

  String get passwordError => _passwordError;

  String get generalError => _generalError;

  void clearErrors() {
    if (_userIdError.isNotEmpty ||
        _passwordError.isNotEmpty ||
        _generalError.isNotEmpty) {
      _userIdError = '';
      _passwordError = '';
      _generalError = '';
      notifyListeners();
    }
  }

  bool validateCredentials(
      String userId, String password, String repeatPassword, bool isLogin) {
    bool isValid = true;
    bool shouldNotify = false;

    if(userId.isEmpty) {
      _userIdError = AppStrings.errorUserIdEmpty ;
      isValid = false;
      shouldNotify = true;
    } else if (userId.isNotEmpty) {
      _userIdError = "";
      shouldNotify = true;
    }

    if (password.isEmpty) {
      _passwordError = AppStrings.errorPasswordEmpty;
      isValid = false;
      shouldNotify = true;
    } else if (password.length < 8) {
      _passwordError = 'Password must be at least 8 characters long';
      isValid = false;
      shouldNotify = true;
    } else if (_passwordError.isNotEmpty) {
      _passwordError = '';
      shouldNotify = true;
    }

    if(!isLogin) {
      if(password != repeatPassword) {
        _passwordError = AppStrings.errorPasswordMismatch;
        isValid = false;
        shouldNotify = true;
      }
    }

    if(shouldNotify) {
      notifyListeners();
    }
    return isValid;
  }
}
