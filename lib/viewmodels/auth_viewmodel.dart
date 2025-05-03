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
    'companyName': TextEditingController(),
    'companyType': TextEditingController(),
    'aadhaarNumber': TextEditingController(),
    'panNumber': TextEditingController(),
    'bankName': TextEditingController(),
    'accountNumber': TextEditingController(),
    'ifscCode': TextEditingController(),
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
    'companyName': null,
    'companyType': null,
    'aadhaarNumber': null,
    'panNumber': null,
    'bankName': null,
    'accountNumber': null,
    'ifscCode': null,
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
  TextEditingController get companyNameController => _controllers['companyName']!;
  TextEditingController get companyTypeController => _controllers['companyType']!;
  TextEditingController get aadhaarNumberController => _controllers['aadhaarNumber']!;
  TextEditingController get panNumberController => _controllers['panNumber']!;
  TextEditingController get bankNameController => _controllers['bankName']!;
  TextEditingController get accountNumberController => _controllers['accountNumber']!;
  TextEditingController get ifscCodeController => _controllers['ifscCode']!;
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
      return false;
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

    // Username validation (3-50 characters)
    if (usernameController.text.isEmpty || usernameController.text.length < 3 || usernameController.text.length > 50) {
      setError('username', usernameController.text.isEmpty
          ? strings.errorUsernameRequired
          : strings.errorUsernameLength);
      isValid = false;
    }

    // Name validation (3-50 characters)
    if (nameController.text.isEmpty || nameController.text.length < 3 || nameController.text.length > 50) {
      setError('name', nameController.text.isEmpty
          ? strings.errorFullNameRequired
          : strings.errorFullNameLength);
      isValid = false;
    }

    // Mobile validation (10 digits, no +91 required)
    final mobilePattern = RegExp(r'^\d{10}$');
    if (mobileController.text.isEmpty || !mobilePattern.hasMatch(mobileController.text)) {
      setError('mobile', mobileController.text.isEmpty
          ? strings.errorMobileRequired
          : strings.errorMobileInvalidFormat);
      isValid = false;
    }

    // Email validation
    final emailPattern = RegExp(r'^[\w.%+-]+@[\w.-]+\.[a-zA-Z]{2,}$', caseSensitive: false);
    if (emailController.text.isEmpty || !emailPattern.hasMatch(emailController.text)) {
      setError('email', emailController.text.isEmpty
          ? strings.errorEmailRequired
          : strings.errorEmailInvalid);
      isValid = false;
    }

    // Address validation
    if (addressController.text.isEmpty || addressController.text.length > 256) {
      setError('address', addressController.text.isEmpty
          ? strings.errorAddressRequired
          : strings.errorAddressLength);
      isValid = false;
    }

    // City validation (max 50 characters)
    if (cityController.text.isEmpty || cityController.text.length > 50) {
      setError('city', cityController.text.isEmpty
          ? strings.errorCityRequired
          : strings.errorCityLength);
      isValid = false;
    }

    // State validation (max 50 characters)
    if (stateController.text.isEmpty || stateController.text.length > 50) {
      setError('state', cityController.text.isEmpty
          ? strings.errorStateRequired
          : strings.errorStateLength);
      isValid = false;
    }

    // Pincode validation (6 digits)
    if (pincodeController.text.isEmpty || pincodeController.text.length != 6 || !RegExp(r'^\d{6}$').hasMatch(pincodeController.text)) {
      setError('pincode', pincodeController.text.isEmpty
          ? strings.errorPincodeRequired
          : strings.errorPincodeInvalid);
      isValid = false;
    }

    // Password validation
    final passwordRegEx = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>])[A-Za-z\d!@#$%^&*(),.?":{}|<>]{8,20}$');
    if (passwordController.text.isEmpty || !passwordRegEx.hasMatch(passwordController.text)) {
      setError('password', passwordController.text.isEmpty
          ? strings.errorPasswordRequired
          : strings.errorPasswordFormat);
      isValid = false;
    }

    // Confirm Password validation
    if (confirmPasswordController.text.isEmpty || passwordController.text != confirmPasswordController.text) {
      setError('confirmPassword', confirmPasswordController.text.isEmpty
          ? strings.errorConfirmPasswordRequired
          : strings.errorPasswordMismatch);
      isValid = false;
    }

    // Company Name validation (3-50 characters)
    if (companyNameController.text.isEmpty || companyNameController.text.length < 3 || companyNameController.text.length > 50) {
      setError('companyName', companyNameController.text.isEmpty
          ? strings.errorCompanyNameRequired
          : strings.errorCompanyNameLength);
      isValid = false;
    }

    // Company Type validation (must be one of the allowed values)
    final allowedCompanyTypes = ['Individual', 'LLP', 'Private Limited', 'Public Limited'];
    if (companyTypeController.text.isEmpty || !allowedCompanyTypes.contains(companyTypeController.text)) {
      setError('companyType', companyTypeController.text.isEmpty
          ? strings.errorCompanyTypeRequired
          : strings.errorCompanyTypeInvalid);
      isValid = false;
    }

    // Aadhaar Number validation (12 digits, optional)
    if (aadhaarNumberController.text.isNotEmpty) {
      if (aadhaarNumberController.text.length != 12 || !RegExp(r'^\d{12}$').hasMatch(aadhaarNumberController.text)) {
        setError('aadhaarNumber', strings.errorAadhaarInvalid);
        isValid = false;
      }
    }

    // PAN Number validation (matches regex, optional)
    if (panNumberController.text.isNotEmpty) {
      if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(panNumberController.text)) {
        setError('panNumber', strings.errorPanInvalid);
        isValid = false;
      }
    }

    // Bank Name validation (max 100 characters, optional)
    if (bankNameController.text.isNotEmpty && bankNameController.text.length > 100) {
      setError('bankName', strings.errorBankNameLength);
      isValid = false;
    }

    // Account Number validation (numeric, optional)
    if (accountNumberController.text.isNotEmpty) {
      if (!RegExp(r'^\d+$').hasMatch(accountNumberController.text)) {
        setError('accountNumber', strings.errorAccountNumberInvalid);
        isValid = false;
      }
    }

    // IFSC Code validation (matches regex, optional)
    if (ifscCodeController.text.isNotEmpty) {
      if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(ifscCodeController.text)) {
        setError('ifscCode', strings.errorIfscInvalid);
        isValid = false;
      }
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
        companyName: companyNameController.text,
        companyType: companyTypeController.text,
        aadhaarNumber: aadhaarNumberController.text.isEmpty ? null : aadhaarNumberController.text,
        panNumber: panNumberController.text.isEmpty ? null : panNumberController.text,
        bankName: bankNameController.text.isEmpty ? null : bankNameController.text,
        accountNumber: accountNumberController.text.isEmpty ? null : accountNumberController.text,
        ifscCode: ifscCodeController.text.isEmpty ? null : ifscCodeController.text,
      );

      _currentUser = User.fromJson(userData);
      developer.log('[AuthVM] Registration successful, user: ${_currentUser?.id}', name: 'AuthViewModel');
      return true;
    } on EmailInUseException catch (e) {
      error = e;
      setError('email', 'This email is already in use. Please try a different email.');
      developer.log('[AuthVM] Email in use: ${emailController.text}', name: 'AuthViewModel', error: e);
      return false;
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