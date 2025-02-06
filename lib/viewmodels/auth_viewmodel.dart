import 'package:flutter/foundation.dart';
import 'package:merchant_app/config/app_strings.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService;
  final Map<String, String> _errors = {
    'username': '',
    'password': '',
    'general': '',
    'email': '',
    'mobile': '',
    'role': '',
    'entity': '',
    'address': '',
    'confirmPassword': '',
    'city': '',
    'state': '',
  };
  bool _isLoading = false;
  User? _currentUser;

  // Getters
  bool get isLoading => _isLoading;
  String get usernameError => _errors['username'] ?? '';
  String get passwordError => _errors['password'] ?? '';
  String get generalError => _errors['general'] ?? '';
  String get emailError => _errors['email'] ?? '';
  String get mobileError => _errors['mobile'] ?? '';
  String get roleError => _errors['role'] ?? '';
  String get entityError => _errors['entity'] ?? '';
  String get addressError => _errors['address'] ?? '';
  String get confirmPasswordError => _errors['confirmPassword'] ?? '';
  String get cityError => _errors['city'] ?? '';
  String get stateError => _errors['state'] ?? '';
  User? get currentUser => _currentUser;

  AuthViewModel(this._authService);

  void clearError(String errorType) {
    if (_errors[errorType]?.isNotEmpty ?? false) {
      _errors[errorType] = '';
      notifyListeners();
    }
  }

  void clearAllErrors() {
    bool hasChanges = _errors.values.any((error) => error.isNotEmpty);
    _errors.updateAll((key, value) => '');
    if (hasChanges) {
      notifyListeners();
    }
  }

  bool validateRegistrationData({
    required String fullName, // Changed from username to fullName
    required String email,
    required String mobileNo,
    required String password,
    required String confirmPassword,
    required String city,
    required String state,
    required String address,
    required bool isAppRegister,
    String? selectedRole,
    String? entityName,
    String? selectedSubEntity,
    required bool isMobileVerified,
    String? entityId,
  }) {
    bool isValid = true;
    clearAllErrors();

    // Full Name validation (previously username)
    if (fullName.isEmpty || fullName.length > 100) {
      _errors['username'] = fullName.isEmpty
          ? AppStrings.errorFullNameRequired // Updated error message
          : AppStrings.errorFullNameLength;
      isValid = false;
    }

    // Entity Name validation (Plaza Owner Name)
    if (entityName == null || entityName.trim().isEmpty) {
      _errors['entity'] = AppStrings.errorPlazaOwnerNameRequired;
      isValid = false;
    } else if (entityName.trim().length > 100) {
      _errors['entity'] = AppStrings.errorPlazaOwnerNameLength;
      isValid = false;
    }

    // Role selection validation (NEW)
    if (selectedRole == null || selectedRole.isEmpty) {
      _errors['role'] = AppStrings.errorRoleRequired; // Add to AppStrings
      isValid = false;
    }

    // Sub-Entity selection validation (NEW)
    if (selectedSubEntity == null || selectedSubEntity!.isEmpty) {
      _errors['subEntity'] = AppStrings.errorSubEntityRequired; // Add to AppStrings
      isValid = false;
    }

    // Mobile Number validation
    if (mobileNo.isEmpty || mobileNo.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(mobileNo)) {
      _errors['mobile'] = mobileNo.isEmpty
          ? AppStrings.errorMobileRequired
          : !RegExp(r'^[0-9]+$').hasMatch(mobileNo)
          ? AppStrings.errorMobileInvalidFormat
          : AppStrings.errorMobileLength;
      isValid = false;
    }

    // Email validation (fixed length check and regex)
    final emailPattern = RegExp(
      r'^[\w.%+-]+@[\w.-]+\.(com|in)$',
      caseSensitive: false, // Allow case insensitivity
    );
    if (email.isEmpty || email.length < 10 || email.length > 50 || !emailPattern.hasMatch(email)) {
      _errors['email'] = email.isEmpty
          ? AppStrings.errorEmailRequired
          : email.length < 10
          ? AppStrings.errorEmailMinLength
          : email.length > 50
          ? AppStrings.errorEmailLength
          : AppStrings.errorEmailInvalid;
      isValid = false;
    }

    // Address validation
    if (address.isEmpty || address.length > 256) {
      _errors['address'] = address.isEmpty
          ? AppStrings.errorAddressRequired
          : AppStrings.errorAddressLength;
      isValid = false;
    }

    // City validation
    if (city.isEmpty || city.length > 50) {
      _errors['city'] = city.isEmpty
          ? AppStrings.errorCityRequired
          : AppStrings.errorCityLength;
      isValid = false;
    }

    // State validation
    if (state.isEmpty || state.length > 50) {
      _errors['state'] = state.isEmpty
          ? AppStrings.errorStateRequired
          : AppStrings.errorStateLength;
      isValid = false;
    }

    // Password validation
    final passwordRegEx = RegExp(
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>])[A-Za-z\d!@#$%^&*(),.?":{}|<>]{8,20}$'
    );
    if (password.isEmpty || !passwordRegEx.hasMatch(password)) {
      _errors['password'] = password.isEmpty
          ? AppStrings.errorPasswordRequired
          : AppStrings.errorPasswordFormat;
      isValid = false;
    }

    // Confirm Password validation
    if (confirmPassword.isEmpty || password != confirmPassword) {
      _errors['confirmPassword'] = confirmPassword.isEmpty
          ? AppStrings.errorConfirmPasswordRequired
          : AppStrings.errorPasswordMismatch;
      isValid = false;
    }

    if (!isValid) {
      notifyListeners();
    }
    return isValid;
  }

  bool validateLoginData(String username, String password) {
    bool isValid = true;
    clearAllErrors();

    // Username/Email validation
    if (username.isEmpty) {
      _errors['username'] = 'Email ID/Mobile no. field is required';
      isValid = false;
    } else {
      // Validation for both email and mobile number
      if (username.contains('@')) {
        // Email validation
        final emailPattern = RegExp(
          r'^[\w.%+-]+@[\w.-]+\.[a-zA-Z]{2,}$',
          caseSensitive: false,
        );
        if (!emailPattern.hasMatch(username)) {
          _errors['username'] = 'Please enter a valid email or mobile number';
          isValid = false;
        }
      } else {
        // Mobile number validation
        final mobilePattern = RegExp(r'^(?:\+?91)?[6-9]\d{9}$');
        if (!mobilePattern.hasMatch(username.replaceAll(RegExp(r'\D'), ''))) {
          _errors['username'] = 'Please enter a valid email or mobile number';
          isValid = false;
        }
      }
    }

    // Password validation
    if (password.isEmpty) {
      _errors['password'] = 'Password field is required';
      isValid = false;
    } else if (password.length < 8) {
      _errors['password'] = 'Password must be at least 8 characters long';
      isValid = false;
    }

    if (!isValid) {
      notifyListeners();
    }
    return isValid;
  }

  Future<bool> login(String emailOrMobile, String password) async {
    if (!validateLoginData(emailOrMobile, password)) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final success = await _authService.login(emailOrMobile, password);
      return success;
    } catch (e) {
      _errors['general'] = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> register({
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
    String? entityName,
    String? selectedSubEntity,
    required bool isMobileVerified,
    String? entityId,
  }) async {
    if (!validateRegistrationData(
      fullName: username,
      email: email,
      mobileNo: mobileNo,
      password: password,
      confirmPassword: confirmPassword,
      city: city,
      state: state,
      address: address,
      isAppRegister: isAppRegister,
      selectedRole: selectedRole,
      entityName: entityName,
      selectedSubEntity: selectedSubEntity,
      isMobileVerified: isMobileVerified,
    )) {
      return null;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final userData = await _authService.register(
          username: username,
          email: email,
          mobileNumber: mobileNo,
          password: password,
          city: city,
          state: state,
          address: address,
          isAppUserRegister: isAppRegister,
          role: selectedRole ?? 'Plaza Owner',
          entity: entityName,
          subEntity: selectedSubEntity,
          entityId: entityId
      );

      return userData;
    } catch (e) {
      _errors['general'] = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setError(String field, String message) {
    _errors[field] = message;
    notifyListeners();
  }
}