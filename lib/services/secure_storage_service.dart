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