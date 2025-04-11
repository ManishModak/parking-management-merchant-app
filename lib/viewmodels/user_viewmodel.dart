import 'package:flutter/material.dart';
import 'package:merchant_app/models/plaza.dart';
import 'package:merchant_app/models/user_model.dart';
import 'package:merchant_app/services/storage/secure_storage_service.dart';
import 'package:merchant_app/services/core/user_service.dart';
import 'package:merchant_app/utils/exceptions.dart'; // Assuming this exists for exception types
import 'dart:developer' as developer;

import '../services/core/plaza_service.dart';

class UserViewModel extends ChangeNotifier {
  final UserService _userService = UserService();
  final PlazaService _plazaService = PlazaService();
  final SecureStorageService _secureStorageService = SecureStorageService();

  bool _isLoading = false;
  User? _currentUser; // Logged-in user
  User? _currentOperator; // Operator being viewed
  List<User> _users = [];
  List<Plaza> _userPlazas = [];
  Exception? _error;

  final Map<String, String> _errors = {
    'username': '',
    'email': '',
    'mobile': '',
    'address': '',
    'city': '',
    'state': '',
    'password': '',
    'confirmPassword': '',
    'role': '',
    'entity': '',
    'subEntity': '',
    'general': '',
  };

  User? get currentUser => _currentUser;
  User? get currentOperator => _currentOperator;
  List<User> get operators => _users;
  bool get isLoading => _isLoading;
  List<Plaza> get userPlazas => _userPlazas;
  Exception? get error => _error;

  String getError(String key) => _errors[key] ?? '';
  void setError(String key, String message) {
    _errors[key] = message;
    notifyListeners();
  }

  void clearError(String key) {
    _errors[key] = '';
    notifyListeners();
  }

  void resetErrors() {
    _errors.updateAll((key, value) => '');
    _error = null;
    notifyListeners();
  }

  // New method for fetching and storing the logged-in user
  Future<void> fetchAndStoreCurrentUser({
    required String userId,
    bool forceApiCall = false,
  }) async {
    try {
      _setLoading(true);
      _error = null;

      if (!forceApiCall) {
        final cachedUserData = await _secureStorageService.getUserData();
        if (cachedUserData != null) {
          _currentUser = User.fromJson(cachedUserData);
          developer.log("STORAGE CALL: Loaded currentUser: $_currentUser", name: 'UserViewModel');
          return;
        }
      }

      _currentUser = await _userService.fetchUserInfo(userId, true);
      developer.log("API CALL: Fetched currentUser: $_currentUser", name: 'UserViewModel');

      if (_currentUser != null) {
        final userDataMap = _currentUser!.toJson();
        await _secureStorageService.storeUserData(userDataMap);
        developer.log("Stored updated currentUser data: $userDataMap", name: 'UserViewModel');
      } else {
        developer.log("No currentUser data returned from API", name: 'UserViewModel', level: 900);
      }
      resetErrors();
    } on NoInternetException catch (e) {
      _error = e;
      developer.log('No internet: $e', name: 'UserViewModel');
    } on RequestTimeoutException catch (e) {
      _error = e;
      developer.log('Request timeout: $e', name: 'UserViewModel');
    } on HttpException catch (e) {
      _error = e;
      developer.log('HTTP error: $e', name: 'UserViewModel');
    } catch (e) {
      _error = ServiceException('Failed to load current user profile: $e');
      developer.log('Unexpected error: $e', name: 'UserViewModel');
    } finally {
      _setLoading(false);
    }
  }

  // Modified fetchUser to only fetch, not store
  Future<void> fetchUser({
    required String userId,
    required bool isCurrentAppUser,
  }) async {
    try {
      _setLoading(true);
      _error = null;

      if (isCurrentAppUser) {
        _currentUser = await _userService.fetchUserInfo(userId, isCurrentAppUser);
        developer.log("API CALL: Fetched currentUser: $_currentUser", name: 'UserViewModel');
      } else {
        _currentOperator = await _userService.fetchUserInfo(userId, isCurrentAppUser);
        developer.log("API CALL: Fetched currentOperator: $_currentOperator", name: 'UserViewModel');
      }

      if (isCurrentAppUser && _currentUser == null) {
        developer.log("No currentUser data returned from API", name: 'UserViewModel', level: 900);
      } else if (!isCurrentAppUser && _currentOperator == null) {
        developer.log("No currentOperator data returned from API", name: 'UserViewModel', level: 900);
      }
      resetErrors();
    } on NoInternetException catch (e) {
      _error = e;
      developer.log('No internet: $e', name: 'UserViewModel');
    } on RequestTimeoutException catch (e) {
      _error = e;
      developer.log('Request timeout: $e', name: 'UserViewModel');
    } on HttpException catch (e) {
      _error = e;
      developer.log('HTTP error: $e', name: 'UserViewModel');
    } catch (e) {
      _error = ServiceException('Failed to load user profile: $e');
      developer.log('Unexpected error: $e', name: 'UserViewModel');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchUserList(String entityId) async {
    try {
      _setLoading(true);
      _error = null;
      _users = await _userService.getUsersByEntityId(entityId);
      resetErrors();
    } on NoInternetException catch (e) {
      _error = e;
      _users = [];
      developer.log('No internet: $e', name: 'UserViewModel');
    } on RequestTimeoutException catch (e) {
      _error = e;
      _users = [];
      developer.log('Request timeout: $e', name: 'UserViewModel');
    } on HttpException catch (e) {
      _error = e;
      _users = [];
      developer.log('HTTP error: $e', name: 'UserViewModel');
    } catch (e) {
      _error = ServiceException('Failed to fetch operators: $e');
      _users = [];
      developer.log('Unexpected error: $e', name: 'UserViewModel');
    } finally {
      _setLoading(false);
    }
  }

  void clearUserImages() {
    notifyListeners();
  }

  Future<void> fetchUserPlazas(String userId) async {
    try {
      _setLoading(true);
      _error = null;
      developer.log('Fetching plazas for userId: $userId', name: 'UserViewModel');
      _userPlazas = await _plazaService.fetchUserPlazas(userId);
      developer.log('Fetched ${_userPlazas.length} plazas', name: 'UserViewModel');
    } on NoInternetException catch (e) {
      _error = e;
      _userPlazas = [];
      developer.log('No internet: $e', name: 'UserViewModel');
    } on RequestTimeoutException catch (e) {
      _error = e;
      _userPlazas = [];
      developer.log('Request timeout: $e', name: 'UserViewModel');
    } on HttpException catch (e) {
      _error = e;
      _userPlazas = [];
      developer.log('HTTP error: $e', name: 'UserViewModel');
    } catch (e) {
      _error = ServiceException('Error fetching plazas: $e');
      _userPlazas = [];
      developer.log('Unexpected error: $e', name: 'UserViewModel');
    } finally {
      _setLoading(false);
    }
  }

  Map<String, String> validateRegistration({
    required String username,
    required String email,
    required String mobile,
    required String city,
    required String state,
    required String address,
    required String password,
    required String confirmPassword,
    required String? role,
    required String? entity,
    required String? subEntity,
    required bool isMobileVerified,
    required String? verifiedMobileNumber,
  }) {
    final errors = <String, String>{};

    if (username.isEmpty) errors['username'] = 'Full name is required';
    if (email.isEmpty || !RegExp(r'^[\w.%+-]+@[\w.-]+\.(com|in)$').hasMatch(email)) {
      errors['email'] = 'Valid email is required';
    }
    errors['mobile'] = validateMobile(mobile, isMobileVerified, verifiedMobileNumber) ?? '';
    if (city.isEmpty) errors['city'] = 'City is required';
    if (state.isEmpty) errors['state'] = 'State is required';
    if (address.isEmpty) errors['address'] = 'Address is required';
    if (password.isEmpty) {
      errors['password'] = 'Password is required';
    } else if (password.length < 6) {
      errors['password'] = 'Password must be at least 6 characters';
    }
    if (confirmPassword.isEmpty) {
      errors['confirmPassword'] = 'Confirm password is required';
    } else if (password != confirmPassword) {
      errors['confirmPassword'] = 'Passwords do not match';
    }
    if (role == null) errors['role'] = 'Role is required';
    if (entity == null) errors['entity'] = 'Entity is required';
    if (subEntity == null) errors['subEntity'] = 'Sub-entity is required';

    return errors..removeWhere((key, value) => value.isEmpty);
  }

  Map<String, String> validateUpdate({
    required String username,
    required String email,
    required String mobile,
    required String address,
    required String city,
    required String state,
    required String? role,
    required String? subEntity,
    required bool isMobileVerified,
    required String? originalMobile,
  }) {
    final errors = <String, String>{};

    if (username.isEmpty) errors['username'] = 'Full name is required';
    if (username.length > 100) errors['username'] = 'Name must be less than 100 characters';
    if (email.isEmpty) {
      errors['email'] = 'Email is required';
    } else if (!RegExp(r'^[\w.%+-]+@[\w.-]+\.(com|in)$').hasMatch(email)) {
      errors['email'] = 'Valid email is required';
    } else if (email.length > 50) {
      errors['email'] = 'Email must be less than 50 characters';
    }
    if (mobile.isEmpty) {
      errors['mobile'] = 'Mobile number is required';
    } else if (!RegExp(r'^\d{10}$').hasMatch(mobile)) {
      errors['mobile'] = 'Mobile must be a 10-digit number';
    } else if (mobile != originalMobile && !isMobileVerified) {
      errors['mobile'] = 'Mobile number verification required';
    }
    if (address.isEmpty) errors['address'] = 'Address is required';
    if (address.length > 256) errors['address'] = 'Address must be less than 256 characters';
    if (city.isEmpty) errors['city'] = 'City is required';
    if (city.length > 50) errors['city'] = 'City must be less than 50 characters';
    if (state.isEmpty) errors['state'] = 'State is required';
    if (state.length > 50) errors['state'] = 'State must be less than 50 characters';
    if (role == null || role.isEmpty) errors['role'] = 'Role is required';
    if (subEntity == null || subEntity.isEmpty) errors['subEntity'] = 'Sub-entity is required';

    return errors..removeWhere((key, value) => value.isEmpty);
  }

  Map<String, String> validateResetPassword({
    required String newPassword,
    required String confirmPassword,
  }) {
    final errors = <String, String>{};

    if (newPassword.isEmpty) {
      errors['newPassword'] = 'New password is required';
    } else if (newPassword.length < 6) {
      errors['newPassword'] = 'Password must be at least 6 characters';
    }
    if (confirmPassword.isEmpty) {
      errors['confirmPassword'] = 'Confirm password is required';
    } else if (newPassword != confirmPassword) {
      errors['confirmPassword'] = 'Passwords do not match';
    }

    return errors..removeWhere((key, value) => value.isEmpty);
  }

  String? validateMobile(String mobile, bool isMobileVerified, String? verifiedMobileNumber) {
    if (mobile.isEmpty || !RegExp(r'^\d{10}$').hasMatch(mobile)) {
      return 'Valid 10-digit mobile number is required';
    } else if (!isMobileVerified) {
      return 'Mobile number must be verified';
    } else if (verifiedMobileNumber != mobile) {
      return 'Mobile number has changed, please re-verify';
    }
    return null;
  }

  Future<bool> updateUser({
    required String username,
    required String email,
    String? mobileNumber,
    String? address,
    String? city,
    String? state,
    String? role,
    String? subEntity,
    required bool isCurrentAppUser,
  }) async {
    try {
      _setLoading(true);
      _error = null;
      if (currentUser?.id == null) {
        throw Exception('No user selected for update');
      }

      final success = await _userService.updateUserInfo(
        currentUser!.id,
        username: username,
        email: email,
        mobileNumber: mobileNumber,
        address: address,
        city: city,
        state: state,
        role: role,
        subEntity: subEntity,
      );

      if (success) {
        _currentUser = await _userService.fetchUserInfo(currentUser!.id, isCurrentAppUser);
        resetErrors();
        return true;
      } else {
        throw ServiceException('Update failed');
      }
    } on NoInternetException catch (e) {
      _error = e;
      developer.log('No internet: $e', name: 'UserViewModel');
      return false;
    } on RequestTimeoutException catch (e) {
      _error = e;
      developer.log('Request timeout: $e', name: 'UserViewModel');
      return false;
    } on HttpException catch (e) {
      _error = e;
      developer.log('HTTP error: $e', name: 'UserViewModel');
      return false;
    } catch (e) {
      _error = ServiceException('Failed to update user: $e');
      developer.log('Unexpected error: $e', name: 'UserViewModel');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword(String userId, String newPassword) async {
    try {
      _setLoading(true);
      _error = null;
      if (userId.isEmpty) {
        throw Exception('User ID is required');
      }

      final success = await _userService.resetPassword(userId, newPassword);

      if (success) {
        resetErrors();
        return true;
      } else {
        throw ServiceException('Password reset failed');
      }
    } on NoInternetException catch (e) {
      _error = e;
      developer.log('No internet: $e', name: 'UserViewModel');
      return false;
    } on RequestTimeoutException catch (e) {
      _error = e;
      developer.log('Request timeout: $e', name: 'UserViewModel');
      return false;
    } on HttpException catch (e) {
      _error = e;
      developer.log('HTTP error: $e', name: 'UserViewModel');
      return false;
    } catch (e) {
      _error = ServiceException('Failed to reset password: $e');
      developer.log('Unexpected error: $e', name: 'UserViewModel');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> registerUser({
    required String username,
    required String email,
    required String mobileNumber,
    required String password,
    required String city,
    required String state,
    required String address,
    required bool isAppUserRegister,
    String? role,
    String? entity,
    String? subEntity,
    String? entityId,
  }) async {
    try {
      _setLoading(true);
      _error = null;
      resetErrors();

      final userData = await _userService.userRegister(
        username: username,
        email: email,
        mobileNumber: mobileNumber,
        password: password,
        city: city,
        state: state,
        address: address,
        isAppUserRegister: isAppUserRegister,
        role: role,
        entity: entity,
        subEntity: subEntity,
        entityId: entityId,
      );

      if (userData != null) {
        return true;
      } else {
        throw ServiceException('Registration failed');
      }
    } on NoInternetException catch (e) {
      _error = e;
      developer.log('No internet: $e', name: 'UserViewModel');
      return false;
    } on RequestTimeoutException catch (e) {
      _error = e;
      developer.log('Request timeout: $e', name: 'UserViewModel');
      return false;
    } on HttpException catch (e) {
      _error = e;
      developer.log('HTTP error: $e', name: 'UserViewModel');
      return false;
    } catch (e) {
      _error = ServiceException('Failed to register user: $e');
      developer.log('Unexpected error: $e', name: 'UserViewModel');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}