import 'dart:convert';

import 'package:merchant_app/config/api_config.dart';
import 'package:merchant_app/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'secure_storage_service.dart';

class UserService {
  final SecureStorageService _storage = SecureStorageService();

  Future<User> fetchUserInfo(String userId,bool isCurrentAppUser) async {
    final String url = '${ApiConfig.baseUrl}${ApiConfig.getUserEndpoint}$userId';
    final token = await _storage.getAuthToken();

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final userData = json.decode(response.body)['user'];
        if(isCurrentAppUser) {
          await _storage.storeUserData(userData);
        }
        return User.fromJson(userData);
      } else {
        throw Exception(
            json.decode(response.body)['msg'] ?? 'Failed to fetch user profile');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> updateUserInfo(
      String userId, {
        required String username,
        required String email,
        String? mobileNumber,
        String? address,
        String? city,
        String? state,
        String? role,
      }) async {
    final String url = '${ApiConfig.baseUrl}${ApiConfig.updateProfileEndpoint}$userId';
    final token = await _storage.getAuthToken();

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
      if (role != null) 'role': role,
    };

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(userData),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return responseData['success'];
      } else {
        throw Exception(json.decode(response.body)['msg'] ?? 'Profile update failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<User>> getUserList() async {
    const String url = '${ApiConfig.baseUrl}${ApiConfig.userListEndpoint}';
    final Map<String, String> headers = {'Content-Type': 'application/json'};

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        final List<dynamic> users = responseData['users'];
        return users.map((user) => User.fromJson(user)).toList();
      } else {
        throw Exception(responseData['msg'] ?? 'Failed to fetch users');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> resetPassword(String userId, String newPassword) async {
    final String url = '${ApiConfig.baseUrl}${ApiConfig.resetPasswordEndpoint}/$userId';
    final token = await _storage.getAuthToken();

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final Map<String, dynamic> passwordData = {
      'newPassword': newPassword,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(passwordData),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        return true;
      } else {
        throw Exception(responseData['msg'] ?? 'Password reset failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> getAuthToken() async => await _storage.getAuthToken();

  Future<String?> getUserId() async => await _storage.getUserId();
}