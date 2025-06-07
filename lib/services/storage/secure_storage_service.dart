import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

/*
Stored user data: {id: 19, username: Aman Munjewar, email: aman@gmail.com, role: Plaza Admin, mobileNumber: 9968735416, address: Pune, state: Maharashtra , city: Pune, subEntity: [{plazaId: 2, companyName: Sociante, companyType: LLP, plazaName: Laxmi Plaza, plazaOwner: Manish Modak, plazaOrgId: 21345, plazaOwnerId: 3, email: laxmiplaza@gmail.com, mobileNumber: 9966342189, address: Hinjewadi phase 1, Pune, city: Pune, district: Pune, state: Maharashtra, pincode: 411057, geoLatitude: 18.58510000, geoLongitude: 73.73630000, plazaCategory: Public, plazaSubCategory: Apartment, structureType: Open, plazaStatus: Active, noOfParkingSlots: 30, freeParking: false, priceCategory: Premium, capacityBike: 5, capacity3Wheeler: 5, capacity4Wheeler: 5, capacityBus: 5, capacityTruck: 5, capacityHeavyMachinaryVehicle: 5, plazaOpenTimings: 08:00:00, plazaClosingTime: 18:00:00, haveLanes: false, haveBankDetails: false, haveImages: false, isDeleted: false, createdAt: 2025-03-10T17:28:32.731Z, updatedAt: 2025-04-10T05:21:25.492Z}], entityName: Manish, entityId: 3}
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

  Future<String?> getEntityName() async {
    final data = await getUserData();
    return data?['entityName'] as String?;
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
