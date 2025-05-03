import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

/*
* stored updated user data in SecureStorageService: {id: 3, username: Manish, email: manishmodak88874@gmail.com, role: Plaza Owner, mobileNumber: 9356344112, address: Hinjewadi, Pune1, state: Maharashtra, city: Pune, subEntity: [], entityName: Manish Modak, entityId: 3}
*
* */

class SecureStorageService {
  final _storage = const FlutterSecureStorage();

  static const String tokenKey = 'authToken';
  static const String userIdKey = 'userId';
  static const String userDataKey = 'userData';

  Future<void> storeAuthToken(String token) async {
    await _storage.write(key: tokenKey, value: token);
  }

  Future<String?> getAuthToken() async {
    return await _storage.read(key: tokenKey);
  }

  Future<void> storeUserId(String userId) async {
    await _storage.write(key: userIdKey, value: userId);
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: userIdKey);
  }

  Future<String?> getUserRole() async {
    final data = await getUserData();
    return data?['role'] as String?;
  }

  Future<String?> getEntityId() async {
    final data = await getUserData();
    return data?['entityId'] as String?;
  }

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

  Future<void> storeAuthDetails(String token, String userId) async {
    await storeAuthToken(token);
    await storeUserId(userId);
  }

  Future<bool> isAuthenticated() async {
    return await getAuthToken() != null;
  }

  Future<void> clearUserData() async {
    await _storage.delete(key: userDataKey);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  Future<void> clearAuthDetails() async {
    await _storage.delete(key: tokenKey);
    await _storage.delete(key: userIdKey);
  }

  Future<void> clearAllData() async {
    await clearAuthDetails();
    await clearUserData();
  }

  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }
}
