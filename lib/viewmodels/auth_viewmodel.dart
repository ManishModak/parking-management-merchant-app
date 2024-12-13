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
    bool _isLoading = false;
    User? _currentUser;

    // Public getters
    bool get isLoading => _isLoading;
    String get userIdError => _userIdError;
    String get passwordError => _passwordError;
    String get generalError => _generalError;
    String get emailError => _emailError;
    User? get currentUser => _currentUser;
  
    AuthViewModel(this._authService);
  
    /// Clears all error messages and notifies listeners if there were changes.
    void clearErrors() {
      final hasErrors = _userIdError.isNotEmpty ||
          _passwordError.isNotEmpty ||
          _generalError.isNotEmpty ||
          _emailError.isNotEmpty;
  
      if (hasErrors) {
        _userIdError = '';
        _passwordError = '';
        _generalError = '';
        _emailError = '';
        notifyListeners();
      }
    }
  
    /// Validates user credentials for login or registration.
    bool validateCredentials({
      required String email,
      required String password,
      String? repeatPassword,
      String? username,
      String? mobileNo,
      required bool isLogin,
    }) {
      bool isValid = true;
      bool shouldNotify = false;
  
      // Email validation
      if (email.isEmpty) {
        _emailError = AppStrings.errorEmailEmpty;
        isValid = false;
        shouldNotify = true;
      } else if (!_isValidEmail(email)) {
        _emailError = AppStrings.errorInvalidEmail;
        isValid = false;
        shouldNotify = true;
      } else if (_emailError.isNotEmpty) {
        _emailError = '';
        shouldNotify = true;
      }
  
      // Password validation
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
  
      // Additional validations for registration
      if (!isLogin) {
        // Username validation
        if (username == null || username.isEmpty) {
          _userIdError = AppStrings.errorUsernameEmpty;
          isValid = false;
          shouldNotify = true;
        } else if (_userIdError.isNotEmpty) {
          _userIdError = '';
          shouldNotify = true;
        }
  
        // Phone validation
        if (mobileNo == null || mobileNo.isEmpty) {
          _generalError = AppStrings.errorPhoneEmpty;
          isValid = false;
          shouldNotify = true;
        } else if (!_isValidPhone(mobileNo)) {
          _generalError = AppStrings.errorInvalidPhone;
          isValid = false;
          shouldNotify = true;
        } else if (_generalError.isNotEmpty) {
          _generalError = '';
          shouldNotify = true;
        }
  
        // Repeat password validation
        if (repeatPassword == null || repeatPassword.isEmpty) {
          _passwordError = AppStrings.errorRepeatPasswordEmpty;
          isValid = false;
          shouldNotify = true;
        } else if (password != repeatPassword) {
          _passwordError = AppStrings.errorPasswordMismatch;
          isValid = false;
          shouldNotify = true;
        }
      }
  
      if (shouldNotify) {
        notifyListeners();
      }
      return isValid;
    }
  
    // Private email validation method
    bool _isValidEmail(String email) {
      return RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(email);
    }
  
    // Private phone validation method
    bool _isValidPhone(String phone) {
      return RegExp(r"^\d{10}$").hasMatch(phone);
    }
  
    /// Handles user login
    Future<bool> login(String email, String password) async {
      clearErrors();
      if (!validateCredentials(email: email, password: password, isLogin: true)) return false;
  
      _isLoading = true;
      notifyListeners();
      print('im here');
      try {
        final success = await _authService.login(email, password);
        if (success) {
          // Optionally fetch user profile after successful login
          //await fetchUserProfile();
          return true;
        }
        return false;
      } catch (e) {
        _generalError = _formatErrorMessage(e);
        notifyListeners();
        return false;
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    }
  
    /// Handles user registration
    Future<bool> register({
      required String username,
      required String email,
      required String mobileNo,
      required String password,
      required String repeatPassword,
    }) async {
      clearErrors();
  
      if (!validateCredentials(
        username: username,
        email: email,
        mobileNo: mobileNo,
        password: password,
        repeatPassword: repeatPassword,
        isLogin: false,
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
        );
  
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
  
    /// Fetches and updates current user profile
    Future<bool> updateProfile({
      required String username,
      required String email,
      String? mobileNumber,
      String? address,
      String? city,
      String? state,
    }) async {
      _isLoading = true;
      notifyListeners();

      try {
        final userId = await _authService.getUserId();

        if (userId == null) {
          throw Exception('User ID not found');
        }

         bool success = await _authService.updateUserProfile(
          userId,
          username: username,
          email: email,
          mobileNumber: mobileNumber,
          address: address,
          city: city,
          state: state,
        );

        if(success) {
          await fetchUserProfile();
        }

        print(success);
        _isLoading = false;
        notifyListeners();
        return success;
      } catch (e) {
        _generalError = _formatErrorMessage(e);
        _isLoading = false;
        notifyListeners();
        return false;
      }
    }

    Future<void> fetchUserProfile() async {
      try {
        final userId = await _authService.getUserId();

        if (userId != null) {
          final userDetails = await _authService.fetchUserProfile(userId);
          _currentUser = userDetails;
          notifyListeners();
        } else {
          _generalError = 'No user logged in';
          notifyListeners();
        }
      } catch (e) {
        _generalError = 'Failed to load user profile';
        notifyListeners();
      }
    }
  
    /// Helper method to format error messages
    String _formatErrorMessage(Object e) {
      return e.toString().replaceFirst('Exception: ', '');
    }
  }