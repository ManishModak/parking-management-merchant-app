import 'package:flutter/foundation.dart';
import 'package:merchant_app/models/user_model.dart';
import 'package:merchant_app/services/storage/secure_storage_service.dart';
import 'package:merchant_app/utils/exceptions.dart';
import 'dart:developer' as developer;

import '../services/core/user_service.dart';

class SettingsViewModel extends ChangeNotifier {
  final UserService _userService;
  final SecureStorageService _secureStorage;

  User? _currentUser;
  bool _isLoading = false;
  final Map<String, String> _errors = {};

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  Map<String, String> get errors => Map.unmodifiable(_errors);

  SettingsViewModel({
    UserService? userService,
    SecureStorageService? secureStorage,
  })  : _userService = userService ?? UserService(),
        _secureStorage = secureStorage ?? SecureStorageService();

  Future<void> fetchUser({required String userId, required bool isCurrentAppUser}) async {
    try {
      _setLoading(true);
      final user = await _userService.fetchUserInfo(userId, isCurrentAppUser);
      _currentUser = user;
      developer.log('Fetched user: id=${user.id}, name=${user.name}', name: 'SettingsViewModel');
      notifyListeners();
    } catch (e) {
      developer.log('Error fetching user: $e', name: 'SettingsViewModel', error: e);
      _errors['general'] = 'Failed to load user profile';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // New method to fetch and store user data
  Future<bool> fetchAndStoreUserData({required String userId, required bool isCurrentAppUser}) async {
    try {
      _setLoading(true);
      final user = await _userService.fetchUserInfo(userId, isCurrentAppUser);
      _currentUser = user;

      // Prepare user data for storage
      final userData = {
        'id': user.id,
        'username': user.name,
        'email': user.email,
        'role': user.role,
        'mobileNumber': user.mobileNumber,
        'address': user.address ?? '',
        'state': user.state ?? '',
        'city': user.city ?? '',
        'subEntity': user.subEntity ?? [],
        'entityName': user.entityName, // Adjust based on actual entity name field
        'entityId': user.entityId,     // Adjust based on actual entity ID field
      };

      // Store user data in secure storage
      await _secureStorage.storeUserData(userData);
      developer.log('Stored user data: $userData', name: 'SettingsViewModel');

      clearErrors();
      notifyListeners();
      return true;
    } catch (e) {
      developer.log('Error fetching and storing user data: $e', name: 'SettingsViewModel', error: e);
      _errors['general'] = 'Failed to load and store user profile';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateUser({
    required String userId,
    required String username,
    required String email,
    required String mobileNumber,
    String? address,
    String? city,
    String? state,
    String? role,
    required bool isCurrentAppUser,
  }) async {
    try {
      _setLoading(true);
      final success = await _userService.updateUserInfo(
        userId,
        username: username,
        email: email,
        mobileNumber: mobileNumber,
        address: address,
        city: city,
        state: state,
        role: role,
      );
      if (success) {
        // Fetch and store updated user data
        final updated = await fetchAndStoreUserData(userId: userId, isCurrentAppUser: isCurrentAppUser);
        if (!updated) {
          _errors['general'] = 'Failed to refresh user data after update';
          return false;
        }
        developer.log('Updated user: id=$userId, name=$username', name: 'SettingsViewModel');
        clearErrors();
      }
      return success;
    } on EmailInUseException catch (e) {
      _errors['email'] = 'Email is already in use';
      developer.log('Email in use: $email', name: 'SettingsViewModel', error: e);
      return false;
    } catch (e) {
      _errors['general'] = 'Failed to update profile';
      developer.log('Error updating user: $e', name: 'SettingsViewModel', error: e);
      return false;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Map<String, String> validateUpdate({
    required String username,
    required String email,
    required String mobile,
    String? address,
    String? city,
    String? state,
    String? role,
    String? subEntity,
    required bool isMobileVerified,
    required String? originalMobile,
    required bool isProfile,
  }) {
    final errors = <String, String>{};

    if (username.isEmpty) {
      errors['username'] = 'Username is required';
    }
    if (email.isEmpty || !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      errors['email'] = 'Invalid email format';
    }
    if (mobile.isEmpty || !RegExp(r'^\d{10}$').hasMatch(mobile)) {
      errors['mobile'] = 'Invalid mobile number';
    } else if (mobile != originalMobile && !isMobileVerified) {
      errors['mobile'] = 'Mobile number must be verified';
    }
    if (isProfile) {
      if (address?.isEmpty ?? true) {
        errors['address'] = 'Address is required';
      }
      if (city?.isEmpty ?? true) {
        errors['city'] = 'City is required';
      }
      if (state?.isEmpty ?? true) {
        errors['state'] = 'State is required';
      }
    }

    return errors;
  }

  void setError(String key, String message) {
    _errors[key] = message;
    notifyListeners();
  }

  void clearError(String key) {
    _errors.remove(key);
    notifyListeners();
  }

  void clearErrors() {
    _errors.clear();
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}