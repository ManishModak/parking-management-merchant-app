import 'package:flutter/foundation.dart';
import 'package:merchant_app/config/app_strings.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService;

  // Error states
  String _userIdError = '';
  String _passwordError = '';
  String _generalError = '';
  String _emailError = '';
  String _mobileError = '';
  String _roleError = '';
  String _entityError = '';
  String _addressError = '';
  bool _isLoading = false;
  User? _currentUser;

  // Getters
  bool get isLoading => _isLoading;
  String get userIdError => _userIdError;
  String get passwordError => _passwordError;
  String get generalError => _generalError;
  String get emailError => _emailError;
  String get mobileError => _mobileError;
  String get roleError => _roleError;
  String get entityError => _entityError;
  String get addressError => _addressError;
  User? get currentUser => _currentUser;

  AuthViewModel(this._authService);

  void clearError(String errorType) {
    bool shouldNotify = false;

    switch (errorType) {
      case 'userId':
        if (_userIdError.isNotEmpty) {
          _userIdError = '';
          shouldNotify = true;
        }
        break;
      case 'password':
        if (_passwordError.isNotEmpty) {
          _passwordError = '';
          shouldNotify = true;
        }
        break;
      case 'email':
        if (_emailError.isNotEmpty) {
          _emailError = '';
          shouldNotify = true;
        }
        break;
      case 'mobile':
        if (_mobileError.isNotEmpty) {
          _mobileError = '';
          shouldNotify = true;
        }
        break;
      case 'role':
        if (_roleError.isNotEmpty) {
          _roleError = '';
          shouldNotify = true;
        }
        break;
      case 'entity':
        if (_entityError.isNotEmpty) {
          _entityError = '';
          shouldNotify = true;
        }
        break;
      case 'address':
        if (_addressError.isNotEmpty) {
          _addressError = '';
          shouldNotify = true;
        }
        break;
      case 'general':
        if (_generalError.isNotEmpty) {
          _generalError = '';
          shouldNotify = true;
        }
        break;
    }

    if (shouldNotify) {
      notifyListeners();
    }
  }

  void clearAllErrors() {
    bool shouldNotify = false;

    if (_userIdError.isNotEmpty) {
      _userIdError = '';
      shouldNotify = true;
    }
    if (_passwordError.isNotEmpty) {
      _passwordError = '';
      shouldNotify = true;
    }
    if (_generalError.isNotEmpty) {
      _generalError = '';
      shouldNotify = true;
    }
    if (_emailError.isNotEmpty) {
      _emailError = '';
      shouldNotify = true;
    }
    if (_mobileError.isNotEmpty) {
      _mobileError = '';
      shouldNotify = true;
    }
    if (_roleError.isNotEmpty) {
      _roleError = '';
      shouldNotify = true;
    }
    if (_entityError.isNotEmpty) {
      _entityError = '';
      shouldNotify = true;
    }
    if (_addressError.isNotEmpty) {
      _addressError = '';
      shouldNotify = true;
    }

    if (shouldNotify) {
      notifyListeners();
    }
  }

  bool validateRegistrationData({
    required String username,
    required String email,
    required String mobileNo,
    required String password,
    required String confirmPassword,
    required String city,
    required String state,
    required String address,
    required bool isAppRegister,
    String? selectedRole,
    String? selectedEntity,
    String? selectedSubEntity,
    required bool isMobileVerified,
  }) {
    bool isValid = true;
    bool shouldNotify = false;

    // Clear all previous errors first
    clearAllErrors();

    // Basic validations that apply to all registrations
    if (username.isEmpty) {
      _userIdError = AppStrings.errorUsernameEmpty;
      isValid = false;
      shouldNotify = true;
    }

    if (email.isEmpty) {
      _emailError = AppStrings.errorEmailEmpty;
      isValid = false;
      shouldNotify = true;
    } else if (!_isValidEmail(email)) {
      _emailError = AppStrings.errorInvalidEmail;
      isValid = false;
      shouldNotify = true;
    }

    if (mobileNo.isEmpty) {
      _mobileError = AppStrings.errorMobileNoEmpty;
      isValid = false;
      shouldNotify = true;
    } else if (!_isValidPhone(mobileNo)) {
      _mobileError = AppStrings.errorInvalidPhone;
      isValid = false;
      shouldNotify = true;
    } else if (!isMobileVerified) {
      _mobileError = 'Please verify your mobile number';
      isValid = false;
      shouldNotify = true;
    }

    if (address.isEmpty || city.isEmpty || state.isEmpty) {
      _addressError = 'Please fill in all address fields';
      isValid = false;
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
    } else if (password != confirmPassword) {
      _passwordError = AppStrings.errorPasswordMismatch;
      isValid = false;
      shouldNotify = true;
    }

    // Only validate role and entity if not app register
    if (!isAppRegister) {
      if (selectedRole == null) {
        _roleError = 'Please select a role';
        isValid = false;
        shouldNotify = true;
      }

      if (selectedEntity == null) {
        _entityError = 'Please select an entity';
        isValid = false;
        shouldNotify = true;
      }
    }

    if (shouldNotify) {
      notifyListeners();
    }
    return isValid;
  }

  Future<bool> login(String email, String password) async {
    clearAllErrors();

    _isLoading = true;
    notifyListeners();

    try {
      final success = await _authService.login(email, password);
      return success;
    } catch (e) {
      _generalError = _formatErrorMessage(e);
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String username,
    required String email,
    required String mobileNo,
    required String password,
    required String confirmPassword,
    required String city,
    required String state,
    required String address,
    required bool isAppRegister,
    String? selectedRole,
    String? selectedEntity,
    String? selectedSubEntity,
    required bool isMobileVerified,
  }) async {
    if (!validateRegistrationData(
      username: username,
      email: email,
      mobileNo: mobileNo,
      password: password,
      confirmPassword: confirmPassword,
      city: city,
      state: state,
      address: address,
      isAppRegister: isAppRegister,
      selectedRole: selectedRole,
      selectedEntity: selectedEntity,
      selectedSubEntity: selectedSubEntity,
      isMobileVerified: isMobileVerified,
    )) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final success = await _authService.register(
        username: username,
        email: email,
        mobileNumber: mobileNo,
        password: password,
        city: city,
        state: state,
        address: address,
        isAppUserRegister: isAppRegister,
        role: selectedRole,
        entity: selectedEntity,
        subEntity: selectedSubEntity,
      );
      print(success);
      return success;
    } catch (e) {
      print(_generalError);
      _generalError = _formatErrorMessage(e);
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
        .hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    return RegExp(r"^\d{10}$").hasMatch(phone);
  }

  String _formatErrorMessage(Object e) {
    return e.toString().replaceFirst('Exception: ', '');
  }
}