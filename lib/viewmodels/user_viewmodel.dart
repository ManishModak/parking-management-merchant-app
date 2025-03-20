import 'package:flutter/material.dart';
import 'package:merchant_app/models/user_model.dart';
import 'package:merchant_app/services/storage/secure_storage_service.dart';
import 'package:merchant_app/services/core/user_service.dart';
import 'dart:developer' as developer;

class UserViewModel extends ChangeNotifier {
  final UserService _userService;
  final SecureStorageService _secureStorageService = SecureStorageService();

  bool _isLoading = false;
  User? currentUser;
  List<User> _users = [];

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

  User? get currentOperator => currentUser;
  List<User> get operators => _users;
  bool get isLoading => _isLoading;

  UserViewModel(this._userService);

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
    notifyListeners();
  }

  Future<void> fetchUserList(String userId) async {
    try {
      _setLoading(true);
      _users = await _userService.getUsersByEntityId(userId);
      resetErrors();
    } catch (e) {
      setError('general', 'Failed to fetch operators: $e');
      _users = [];
      developer.log('Failed to fetch operators: $e', name: 'UserViewModel');
    } finally {
      _setLoading(false);
    }
  }

  void clearUserImages() {
    notifyListeners();
  }

  Future<void> fetchUser({required String userId, required bool isCurrentAppUser}) async {
    try {
      _setLoading(true);
      final cachedUserData = await _secureStorageService.getUserData();
      if (cachedUserData != null && isCurrentAppUser) {
        currentUser = User.fromJson(cachedUserData);
        developer.log("STORAGE CALL: $currentUser", name: 'UserViewModel');
      } else {
        currentUser = await _userService.fetchUserInfo(userId, isCurrentAppUser);
        developer.log("API CALL: $currentUser", name: 'UserViewModel');
      }
      resetErrors();
    } catch (e) {
      setError('general', 'Failed to load user profile: $e');
      developer.log('Error: $e', name: 'UserViewModel');
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
        currentUser = await _userService.fetchUserInfo(currentUser!.id, isCurrentAppUser);
        resetErrors();
        return true;
      } else {
        throw Exception('Update failed');
      }
    } catch (e) {
      setError('general', 'Failed to update user: $e');
      developer.log('Error: $e', name: 'UserViewModel');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword(String userId, String newPassword) async {
    try {
      _setLoading(true);
      if (userId.isEmpty) {
        throw Exception('User ID is required');
      }

      final success = await _userService.resetPassword(userId, newPassword);

      if (success) {
        resetErrors();
        return true;
      } else {
        throw Exception('Password reset failed');
      }
    } catch (e) {
      setError('general', 'Failed to reset password: $e');
      developer.log('Error: $e', name: 'UserViewModel');
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
        setError('general', 'Registration failed');
        return false;
      }
    } catch (e) {
      setError('general', 'Failed to register user: $e');
      developer.log('Error: $e', name: 'UserViewModel');
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