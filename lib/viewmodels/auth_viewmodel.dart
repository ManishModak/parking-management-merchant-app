import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/core/auth_service.dart';
import '../utils/exceptions.dart';
import 'dart:developer' as developer;
import '../../generated/l10n.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService;

  bool isLoading = false;
  Exception? error;
  User? _currentUser;
  bool isMobileVerified = false;

  final Map<String, TextEditingController> _controllers = {
    'username': TextEditingController(),
    'name': TextEditingController(),
    'mobile': TextEditingController(),
    'email': TextEditingController(),
    'city': TextEditingController(),
    'state': TextEditingController(),
    'address': TextEditingController(),
    'pincode': TextEditingController(),
    'password': TextEditingController(),
    'confirmPassword': TextEditingController(),
  };

  final Map<String, String?> _errors = {
    'username': null,
    'name': null,
    'mobile': null,
    'email': null,
    'city': null,
    'state': null,
    'address': null,
    'pincode': null,
    'password': null,
    'confirmPassword': null,
    'api': null,
  };

  AuthViewModel(this._authService);

  TextEditingController get usernameController => _controllers['username']!;
  TextEditingController get passwordController => _controllers['password']!;
  TextEditingController get nameController => _controllers['name']!;
  TextEditingController get mobileController => _controllers['mobile']!;
  TextEditingController get emailController => _controllers['email']!;
  TextEditingController get cityController => _controllers['city']!;
  TextEditingController get stateController => _controllers['state']!;
  TextEditingController get addressController => _controllers['address']!;
  TextEditingController get pincodeController => _controllers['pincode']!;
  TextEditingController get confirmPasswordController => _controllers['confirmPassword']!;
  String? getError(String key) => _errors[key];
  User? get currentUser => _currentUser;

  void resetErrors() {
    _errors.clear();
    notifyListeners();
  }

  void setError(String key, String? value) {
    _errors[key] = value;
    notifyListeners();
  }

  void clearError(String key) {
    _errors.remove(key);
    notifyListeners();
  }

  bool validateLoginData(BuildContext context) {
    final strings = S.of(context);
    bool isValid = true;
    resetErrors();

    if (usernameController.text.isEmpty) {
      setError('username', strings.errorUsernameRequired);
      isValid = false;
    } else {
      if (usernameController.text.contains('@')) {
        final emailPattern = RegExp(r'^[\w.%+-]+@[\w.-]+\.[a-zA-Z]{2,}$', caseSensitive: false);
        if (!emailPattern.hasMatch(usernameController.text)) {
          setError('username', strings.errorEmailInvalid);
          isValid = false;
        }
      } else {
        final mobilePattern = RegExp(r'^(?:\+?91)?[6-9]\d{9}$');
        if (!mobilePattern.hasMatch(usernameController.text.replaceAll(RegExp(r'\D'), ''))) {
          setError('username', strings.errorMobileInvalidFormat);
          isValid = false;
        }
      }
    }

    if (passwordController.text.isEmpty) {
      setError('password', strings.errorPasswordRequired);
      isValid = false;
    } else if (passwordController.text.length < 8) {
      setError('password', strings.errorPasswordMinLength);
      isValid = false;
    }

    return isValid;
  }

  Future<bool> login(BuildContext context, String username, String password) async {
    final strings = S.of(context);
    usernameController.text = username;
    passwordController.text = password;

    if (!validateLoginData(context)) {
      developer.log('[AuthVM] Login validation failed', name: 'AuthViewModel');
      return false; // No api error set; rely on field-level errors
    }

    try {
      isLoading = true;
      error = null;
      resetErrors();
      notifyListeners();

      final success = await _authService.login(username, password);
      developer.log('[AuthVM] Login result: $success', name: 'AuthViewModel');
      return success;
    } on NoInternetException catch (e) {
      error = e;
      setError('api', strings.errorNoInternet);
      developer.log('[AuthVM] No internet: $e', name: 'AuthViewModel');
      return false;
    } on RequestTimeoutException catch (e) {
      error = e;
      setError('api', strings.errorRequestTimeout);
      developer.log('[AuthVM] Timeout: $e', name: 'AuthViewModel');
      return false;
    } on ServerConnectionException catch (e) {
      error = e;
      setError('api', strings.errorServerUnavailable);
      developer.log('[AuthVM] Server connection error: $e', name: 'AuthViewModel');
      return false;
    } on HttpException catch (e) {
      error = e;
      setError('api', e.serverMessage ?? strings.errorServerError);
      developer.log('[AuthVM] HTTP error: $e', name: 'AuthViewModel');
      return false;
    } catch (e, stackTrace) {
      error = ServiceException('Unexpected error: $e');
      setError('api', strings.errorUnexpected);
      developer.log('[AuthVM] Unexpected error: $e', name: 'AuthViewModel', stackTrace: stackTrace);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  bool validatePlazaOwnerData(BuildContext context) {
    final strings = S.of(context);
    bool isValid = true;
    resetErrors();

    if (usernameController.text.isEmpty || usernameController.text.length > 100) {
      setError('username', usernameController.text.isEmpty
          ? strings.errorUsernameRequired
          : strings.errorUsernameLength);
      isValid = false;
    }

    if (nameController.text.isEmpty || nameController.text.length > 100) {
      setError('name', nameController.text.isEmpty
          ? strings.errorFullNameRequired
          : strings.errorFullNameLength);
      isValid = false;
    }

    if (mobileController.text.isEmpty || mobileController.text.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(mobileController.text)) {
      setError('mobile', mobileController.text.isEmpty
          ? strings.errorMobileRequired
          : !RegExp(r'^[0-9]+$').hasMatch(mobileController.text)
          ? strings.errorMobileInvalidFormat
          : strings.errorMobileLength);
      isValid = false;
    }

    final emailPattern = RegExp(r'^[\w.%+-]+@[\w.-]+\.[a-zA-Z]{2,}$', caseSensitive: false);
    if (emailController.text.isEmpty || emailController.text.length < 10 || emailController.text.length > 50 || !emailPattern.hasMatch(emailController.text)) {
      setError('email', emailController.text.isEmpty
          ? strings.errorEmailRequired
          : emailController.text.length < 10
          ? strings.errorEmailMinLength
          : emailController.text.length > 50
          ? strings.errorEmailLength
          : strings.errorEmailInvalid);
      isValid = false;
    }

    if (addressController.text.isEmpty || addressController.text.length > 256) {
      setError('address', addressController.text.isEmpty
          ? strings.errorAddressRequired
          : strings.errorAddressLength);
      isValid = false;
    }

    if (cityController.text.isEmpty || cityController.text.length > 50) {
      setError('city', cityController.text.isEmpty
          ? strings.errorCityRequired
          : strings.errorCityLength);
      isValid = false;
    }

    if (stateController.text.isEmpty || stateController.text.length > 50) {
      setError('state', stateController.text.isEmpty
          ? strings.errorStateRequired
          : strings.errorStateLength);
      isValid = false;
    }

    if (pincodeController.text.isEmpty || pincodeController.text.length != 6 || !RegExp(r'^[0-9]+$').hasMatch(pincodeController.text)) {
      setError('pincode', pincodeController.text.isEmpty
          ? strings.errorPincodeRequired
          : pincodeController.text.length != 6
          ? strings.errorPincodeLength
          : strings.errorPincodeInvalid);
      isValid = false;
    }

    final passwordRegEx = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>])[A-Za-z\d!@#$%^&*(),.?":{}|<>]{8,20}$');
    if (passwordController.text.isEmpty || !passwordRegEx.hasMatch(passwordController.text)) {
      setError('password', passwordController.text.isEmpty
          ? strings.errorPasswordRequired
          : strings.errorPasswordFormat);
      isValid = false;
    }

    if (confirmPasswordController.text.isEmpty || passwordController.text != confirmPasswordController.text) {
      setError('confirmPassword', confirmPasswordController.text.isEmpty
          ? strings.errorConfirmPasswordRequired
          : strings.errorPasswordMismatch);
      isValid = false;
    }

    return isValid;
  }

  Future<bool> registerPlazaOwner(BuildContext context) async {
    final strings = S.of(context);
    if (!isMobileVerified) {
      setError('api', strings.errorMobileVerificationRequired);
      developer.log('[AuthVM] Registration failed: Mobile not verified', name: 'AuthViewModel');
      return false;
    }

    if (!validatePlazaOwnerData(context)) {
      developer.log('[AuthVM] Registration validation failed', name: 'AuthViewModel');
      return false;
    }

    try {
      isLoading = true;
      error = null;
      resetErrors();
      notifyListeners();

      final userData = await _authService.createPlazaOwner(
        userName: usernameController.text,
        name: nameController.text,
        mobileNumber: mobileController.text,
        email: emailController.text,
        password: passwordController.text,
        address: addressController.text,
        city: cityController.text,
        state: stateController.text,
        pincode: pincodeController.text,
      );

      _currentUser = User.fromJson(userData);
      developer.log('[AuthVM] Registration successful, user: ${_currentUser?.id}', name: 'AuthViewModel');
      return true;
    } on NoInternetException catch (e) {
      error = e;
      setError('api', strings.errorNoInternet);
      developer.log('[AuthVM] No internet: $e', name: 'AuthViewModel');
      return false;
    } on RequestTimeoutException catch (e) {
      error = e;
      setError('api', strings.errorRequestTimeout);
      developer.log('[AuthVM] Timeout: $e', name: 'AuthViewModel');
      return false;
    } on HttpException catch (e) {
      error = e;
      setError('api', e.serverMessage ?? strings.errorServerError);
      developer.log('[AuthVM] HTTP error: $e', name: 'AuthViewModel');
      return false;
    } catch (e, stackTrace) {
      error = ServiceException('Unexpected error: $e');
      setError('api', strings.errorUnexpected);
      developer.log('[AuthVM] Unexpected error: $e', name: 'AuthViewModel', stackTrace: stackTrace);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setMobileVerified(bool value) {
    isMobileVerified = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }
}