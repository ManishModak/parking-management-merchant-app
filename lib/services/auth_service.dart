import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:merchant_app/config/api_config.dart';

import '../models/user_model.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();

  // Keys for secure storage
  static const _tokenKey = 'authToken';
  static const _userIdKey = 'userId';

  Future<bool> login(String emailOrMobile, String password) async {
    const String url = '${ApiConfig.authBaseUrl}${ApiConfig.loginEndpoint}';
    final Map<String, String> headers = {'Content-Type': 'application/json'};
    final Map<String, String> body = {'emailOrMobile': emailOrMobile, 'password': password};

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );
      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        await _storeAuthDetails(responseData['token'], responseData['user']['id'].toString());
        return true;
      } else {
        throw Exception(responseData['msg'] ?? 'Login failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> register({
    required String username,
    required String email,
    required String mobileNumber,
    required String password,
  }) async {
    const String url = '${ApiConfig.authBaseUrl}${ApiConfig.registerEndpoint}';
    final Map<String, String> headers = {'Content-Type': 'application/json'};

    final Map<String, dynamic> userData = {
      'username': username,
      'email': email,
      'mobileNumber': mobileNumber,
      'password': password,
      'address': 'temp',
      'state': 'temp',
      'city': 'temp',
      'role': 'Plaza Owner',
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(userData),
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        await _storeAuthDetails(responseData['token'], responseData['user']['id'].toString());
        return true;
      } else {
        throw Exception(jsonDecode(response.body)['msg'] ?? 'Registration failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> updateUserProfile(
      String userId, {
        required String username,
        required String email,
        String? mobileNumber,
        String? address,
        String? city,
        String? state,
      }) async {

    print('im here');
    final String url = '${ApiConfig.authBaseUrl}${ApiConfig.updateProfileEndpoint}$userId';
    final token = await _storage.read(key: _tokenKey);

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final Map<String, dynamic> userData = {
      'username': username,
      'email': email,
      if (mobileNumber != null) 'mobileNumber': mobileNumber,
      if (address != null) 'address': address,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
    };

    try {
      print(userData);

      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(userData),
      );

      final responseData = json.decode(response.body);
      print(responseData);
      if (response.statusCode == 200) {
        return responseData.success;
      } else {
        throw Exception(json.decode(response.body)['msg'] ?? 'Profile update failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<User> fetchUserProfile(String userId) async {
    final String url = '${ApiConfig.authBaseUrl}${ApiConfig.getUserEndpoint}$userId';
    final token = await _storage.read(key: _tokenKey);

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        return User.fromJson(json.decode(response.body)['user']);
      } else {
        throw Exception(json.decode(response.body)['msg'] ?? 'Failed to fetch user profile');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }

  Future<bool> isAuthenticated() async {
    return await _storage.read(key: _tokenKey) != null;
  }

  Future<String?> getAuthToken() async => await _storage.read(key: _tokenKey);

  Future<String?> getUserId() async => await _storage.read(key: _userIdKey);

  Future<void> _storeAuthDetails(String token, String userId) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _userIdKey, value: userId);
  }
}
