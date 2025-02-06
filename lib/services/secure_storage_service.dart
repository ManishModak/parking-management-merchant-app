import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class SecureStorageService {
  final _storage = const FlutterSecureStorage();

  // Storage keys
  static const String tokenKey = 'authToken';
  static const String userIdKey = 'userId';
  static const String userDataKey = 'userData';

  // Token management
  Future<void> storeAuthToken(String token) async {
    await _storage.write(key: tokenKey, value: token);
  }

  Future<String?> getAuthToken() async {
    return await _storage.read(key: tokenKey);
  }

  // User ID management
  Future<void> storeUserId(String userId) async {
    await _storage.write(key: userIdKey, value: userId);
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: userIdKey);
  }

  // User data management
  Future<void> storeUserData(Map<String, dynamic> userData) async {
    await _storage.write(key: userDataKey, value: json.encode(userData));
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final data = await _storage.read(key: userDataKey);
    if (data != null) {
      return json.decode(data);
    }
    return null;
  }

  // Store both token and user ID (commonly used together)
  Future<void> storeAuthDetails(String token, String userId) async {
    await storeAuthToken(token);
    await storeUserId(userId);
  }

  // Check authentication status
  Future<bool> isAuthenticated() async {
    return await getAuthToken() != null;
  }

  // Clear specific data
  Future<void> clearUserData() async {
    await _storage.delete(key: userDataKey);
  }

  // Clear all stored data
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}

class PlazaRegistrationStorage {
  static const String _formProgressKey = 'plaza_registration_progress';
  static const String _lastUpdatedKey = 'plaza_registration_last_updated';
  static const String _bankDetailsKey = 'plaza_registration_bank_details';

  final _storage = const FlutterSecureStorage();

  // Save form progress securely
  Future<void> saveFormProgress(Map<String, dynamic> formData) async {
    try {
      // Store bank details separately
      if (formData.containsKey('bankDetails')) {
        await _storage.write(
            key: _bankDetailsKey,
            value: json.encode(formData['bankDetails'])
        );
        // Remove bank details from main form data
        formData = Map.from(formData)..remove('bankDetails');
      }

      // Store main form data
      await _storage.write(
          key: _formProgressKey,
          value: json.encode(formData)
      );

      // Update last modified timestamp
      await _storage.write(
          key: _lastUpdatedKey,
          value: DateTime.now().toIso8601String()
      );
    } catch (e) {
      throw StorageException('Failed to save form progress: $e');
    }
  }

  // Retrieve form progress
  Future<Map<String, dynamic>?> getFormProgress() async {
    try {
      final formDataStr = await _storage.read(key: _formProgressKey);

      if (formDataStr == null) return null;

      // Get main form data
      final formData = json.decode(formDataStr) as Map<String, dynamic>;

      // Get bank details if they exist
      final bankDetailsStr = await _storage.read(key: _bankDetailsKey);
      if (bankDetailsStr != null) {
        formData['bankDetails'] = json.decode(bankDetailsStr);
      }

      return formData;
    } catch (e) {
      throw StorageException('Failed to retrieve form progress: $e');
    }
  }

  // Check if there's saved progress
  Future<bool> hasSavedProgress() async {
    try {
      final formData = await _storage.read(key: _formProgressKey);
      return formData != null;
    } catch (e) {
      return false;
    }
  }

  // Get last updated timestamp
  Future<DateTime?> getLastUpdated() async {
    try {
      final timestamp = await _storage.read(key: _lastUpdatedKey);
      return timestamp != null
          ? DateTime.parse(timestamp)
          : null;
    } catch (e) {
      return null;
    }
  }

  // Clear form progress
  Future<void> clearFormProgress() async {
    try {
      await _storage.delete(key: _formProgressKey);
      await _storage.delete(key: _lastUpdatedKey);
      await _storage.delete(key: _bankDetailsKey);
    } catch (e) {
      throw StorageException('Failed to clear form progress: $e');
    }
  }

  // Clear all storage
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw StorageException('Failed to clear storage: $e');
    }
  }
}

class StorageException implements Exception {
  final String message;
  StorageException(this.message);

  @override
  String toString() => message;
}