import 'dart:convert';

import 'package:merchant_app/config/api_config.dart';
import 'package:merchant_app/models/user_model.dart';
import 'package:http/http.dart' as http;
import '../storage/secure_storage_service.dart';

class UserService {
  final SecureStorageService _storage = SecureStorageService();

  Future<User> fetchUserInfo(String userId, bool isCurrentAppUser) async {
    final String url = ApiConfig.getFullUrl('${ApiConfig.getUserEndpoint}$userId');
    print('Fetching user info - URL: $url');

    final token = await _storage.getAuthToken();
    print('Auth token retrieved for user fetch');

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      print('Making GET request to fetch user info');
      final response = await http.get(Uri.parse(url), headers: headers);
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final userData = json.decode(response.body)['user'];
        if(isCurrentAppUser) {
          print('Storing user data for current app user');
          await _storage.storeUserData(userData);
        }
        return User.fromJson(userData);
      } else {
        final error = json.decode(response.body)['msg'] ?? 'Failed to fetch user profile';
        print('Error fetching user info: $error');
        throw Exception(error);
      }
    } catch (e) {
      print('Exception in fetchUserInfo: $e');
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
        String? subEntity
      }) async {
    final String url = ApiConfig.getFullUrl('${ApiConfig.updateProfileEndpoint}$userId');
    print('Updating user info - URL: $url');

    final token = await _storage.getAuthToken();
    print('Auth token retrieved for user update');

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
      if (subEntity != null) 'subEntity': [subEntity]
    };

    print('Update user payload: ${json.encode(userData)}');

    try {
      print('Making PUT request to update user info');
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(userData),
      );
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        print('User update successful');
        return responseData['success'];
      } else {
        final error = responseData['msg'] ?? 'Profile update failed';
        print('Error updating user info: $error');
        throw Exception(error);
      }
    } catch (e) {
      print('Exception in updateUserInfo: $e');
      rethrow;
    }
  }

  Future<List<User>> getUserList() async {
    final String url = ApiConfig.getFullUrl(ApiConfig.userListEndpoint);
    print('Fetching user list - URL: $url');

    final Map<String, String> headers = {'Content-Type': 'application/json'};

    try {
      print('Making GET request to fetch user list');
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        final List<dynamic> users = responseData['users'];
        print('Successfully fetched ${users.length} users');
        return users.map((user) => User.fromJson(user)).toList();
      } else {
        final error = responseData['msg'] ?? 'Failed to fetch users';
        print('Error fetching user list: $error');
        throw Exception(error);
      }
    } catch (e) {
      print('Exception in getUserList: $e');
      rethrow;
    }
  }

  Future<bool> resetPassword(String userId, String newPassword) async {
    final String url = ApiConfig.getFullUrl('${ApiConfig.resetPasswordEndpoint}/$userId');
    print('Resetting password - URL: $url');

    final token = await _storage.getAuthToken();
    print('Auth token retrieved for password reset');

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final Map<String, dynamic> passwordData = {
      'newPassword': newPassword,
    };

    try {
      print('Making POST request to reset password');
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(passwordData),
      );
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        print('Password reset successful');
        return true;
      } else {
        final error = responseData['msg'] ?? 'Password reset failed';
        print('Error resetting password: $error');
        throw Exception(error);
      }
    } catch (e) {
      print('Exception in resetPassword: $e');
      rethrow;
    }
  }

  Future<List<User>> getUsersByEntityId(String entityId) async {
    final String url = ApiConfig.getFullUrl('${ApiConfig.getUsersByEntityEndpoint}$entityId');
    print('Fetching users by entity ID - URL: $url');

    final token = await _storage.getAuthToken();
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      // Add this to see the full error response
      if (response.statusCode != 200) {
        throw Exception('HTTP Error: ${response.statusCode} - ${response.body}');
      }

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        final List<dynamic> users = responseData['users'];
        print('Successfully fetched ${users.length} users for entity $entityId');
        return users.map((user) => User.fromJson(user)).toList();
      } else {
        final error = responseData['msg'] ?? 'Failed to fetch users by entity ID';
        print('Error fetching users: $error');
        throw Exception(error);
      }
    } catch (e) {
      print('Exception in getUsersByEntityId: $e');
      rethrow;
    }
  }

  Future<String?> getAuthToken() async {
    print('Retrieving security token from storage');
    final token = await _storage.getAuthToken();
    print('Auth token ${token != null ? 'found' : 'not found'}');
    return token;
  }

  Future<String?> getUserId() async {
    print('Retrieving user ID from storage');
    final userId = await _storage.getUserId();
    print('User ID ${userId != null ? 'found' : 'not found'}');
    return userId;
  }
}