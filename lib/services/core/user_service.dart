import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:merchant_app/config/api_config.dart';
import 'package:merchant_app/models/user_model.dart';
import 'package:merchant_app/utils/exceptions.dart'; // Import custom exceptions
import '../storage/secure_storage_service.dart';

class UserService {
  final SecureStorageService _storage = SecureStorageService();
  final http.Client _client;

  UserService({http.Client? client}) : _client = client ?? http.Client();

  Future<User> fetchUserInfo(String userId, bool isCurrentAppUser) async {
    final String url = ApiConfig.getFullUrl('${ApiConfig.getUserEndpoint}$userId');
    developer.log('[USER] Fetching user info at URL: $url', name: 'UserService');

    final token = await _storage.getAuthToken();
    developer.log('[USER] Auth token retrieved for user fetch', name: 'UserService');

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      developer.log('[USER] Making GET request to fetch user info', name: 'UserService');
      final response = await _client
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 30));

      developer.log('[USER] Response Status Code: ${response.statusCode}', name: 'UserService');
      developer.log('[USER] Response Body: ${response.body}', name: 'UserService');

      if (response.statusCode == 200) {
        final userData = json.decode(response.body)['user'];
        if (isCurrentAppUser) {
          developer.log('[USER] Storing user data for current app user', name: 'UserService');
          await _storage.storeUserData(userData);
        }
        return User.fromJson(userData);
      }
      throw HttpException(
        json.decode(response.body)['msg'] ?? 'Failed to fetch user profile',
        statusCode: response.statusCode,
        serverMessage: json.decode(response.body)['msg'],
      );
    } on SocketException {
      throw NoInternetException('No internet connection available');
    } on TimeoutException {
      throw RequestTimeoutException('Request timed out');
    } catch (e, stackTrace) {
      developer.log('[USER] Unexpected error while fetching user info: $e',
          name: 'UserService', error: e, stackTrace: stackTrace);
      throw ServiceException('Error fetching user info: $e');
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
        String? subEntity,
      }) async {
    final String url = ApiConfig.getFullUrl('${ApiConfig.updateProfileEndpoint}$userId');
    developer.log('[USER] Updating user info at URL: $url', name: 'UserService');

    final token = await _storage.getAuthToken();
    developer.log('[USER] Auth token retrieved for user update', name: 'UserService');

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
      if (subEntity != null) 'subEntity': [subEntity],
    };

    final body = json.encode(userData);
    developer.log('[USER] Update user payload: $body', name: 'UserService');

    try {
      developer.log('[USER] Making PUT request to update user info', name: 'UserService');
      final response = await _client
          .put(
        Uri.parse(url),
        headers: headers,
        body: body,
      )
          .timeout(const Duration(seconds: 30));

      developer.log('[USER] Response Status Code: ${response.statusCode}', name: 'UserService');
      developer.log('[USER] Response Body: ${response.body}', name: 'UserService');

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        final bool success = responseData['success'] == true;
        developer.log('[USER] User update ${success ? 'successful' : 'failed'}', name: 'UserService');
        return success;
      }
      throw HttpException(
        responseData['msg'] ?? 'Profile update failed',
        statusCode: response.statusCode,
        serverMessage: responseData['msg'],
      );
    } on SocketException {
      throw NoInternetException('No internet connection available');
    } on TimeoutException {
      throw RequestTimeoutException('Request timed out');
    } catch (e, stackTrace) {
      developer.log('[USER] Unexpected error while updating user info: $e',
          name: 'UserService', error: e, stackTrace: stackTrace);
      throw ServiceException('Error updating user info: $e');
    }
  }

  Future<List<User>> getUserList() async {
    final String url = ApiConfig.getFullUrl(ApiConfig.userListEndpoint);
    developer.log('[USER] Fetching user list at URL: $url', name: 'UserService');

    final Map<String, String> headers = {'Content-Type': 'application/json'};

    try {
      developer.log('[USER] Making GET request to fetch user list', name: 'UserService');
      final response = await _client
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 30));

      developer.log('[USER] Response Status Code: ${response.statusCode}', name: 'UserService');
      developer.log('[USER] Response Body: ${response.body}', name: 'UserService');

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        final List<dynamic> users = responseData['users'];
        final userList = users.map((user) => User.fromJson(user)).toList();
        developer.log('[USER] Successfully fetched ${userList.length} users', name: 'UserService');
        return userList;
      } else if (response.statusCode == 404) {
        if (responseData['msg'] == 'No users found') {
          developer.log('[USER] No users found, returning empty list', name: 'UserService');
          return [];
        }
      }
      throw HttpException(
        responseData['msg'] ?? 'Failed to fetch users',
        statusCode: response.statusCode,
        serverMessage: responseData['msg'],
      );
    } on SocketException {
      throw NoInternetException('No internet connection available');
    } on TimeoutException {
      throw RequestTimeoutException('Request timed out');
    } catch (e, stackTrace) {
      developer.log('[USER] Unexpected error while fetching user list: $e',
          name: 'UserService', error: e, stackTrace: stackTrace);
      throw ServiceException('Error fetching user list: $e');
    }
  }

  Future<bool> resetPassword(String userId, String newPassword) async {
    final String url = ApiConfig.getFullUrl('${ApiConfig.resetPasswordEndpoint}/$userId');
    developer.log('[USER] Resetting password at URL: $url', name: 'UserService');

    final token = await _storage.getAuthToken();
    developer.log('[USER] Auth token retrieved for password reset', name: 'UserService');

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final Map<String, dynamic> passwordData = {'newPassword': newPassword};
    final body = json.encode(passwordData);
    developer.log('[USER] Reset password payload: $body', name: 'UserService');

    try {
      developer.log('[USER] Making POST request to reset password', name: 'UserService');
      final response = await _client
          .post(
        Uri.parse(url),
        headers: headers,
        body: body,
      )
          .timeout(const Duration(seconds: 30));

      developer.log('[USER] Response Status Code: ${response.statusCode}', name: 'UserService');
      developer.log('[USER] Response Body: ${response.body}', name: 'UserService');

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        developer.log('[USER] Password reset successful', name: 'UserService');
        return true;
      }
      throw HttpException(
        responseData['msg'] ?? 'Password reset failed',
        statusCode: response.statusCode,
        serverMessage: responseData['msg'],
      );
    } on SocketException {
      throw NoInternetException('No internet connection available');
    } on TimeoutException {
      throw RequestTimeoutException('Request timed out');
    } catch (e, stackTrace) {
      developer.log('[USER] Unexpected error while resetting password: $e',
          name: 'UserService', error: e, stackTrace: stackTrace);
      throw ServiceException('Error resetting password: $e');
    }
  }

  Future<List<User>> getUsersByEntityId(String entityId) async {
    final String url = ApiConfig.getFullUrl('${ApiConfig.getUsersByEntityEndpoint}$entityId');
    developer.log('[USER] Fetching users by entity ID at URL: $url', name: 'UserService');

    final token = await _storage.getAuthToken();
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      developer.log('[USER] Making GET request to fetch users by entity', name: 'UserService');
      final response = await _client
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 30));

      developer.log('[USER] Response Status Code: ${response.statusCode}', name: 'UserService');
      developer.log('[USER] Response Body: ${response.body}', name: 'UserService');

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        final List<dynamic> users = responseData['users'];
        final userList = users.map((user) => User.fromJson(user)).toList();
        developer.log('[USER] Successfully fetched ${userList.length} users for entity $entityId',
            name: 'UserService');
        return userList;
      } else if (response.statusCode == 404) {
        if (responseData['msg'] == 'No users found') {
          developer.log('[USER] No users found for entity $entityId, returning empty list',
              name: 'UserService');
          return [];
        }
      }
      throw HttpException(
        responseData['msg'] ?? 'Failed to fetch users by entity ID',
        statusCode: response.statusCode,
        serverMessage: responseData['msg'],
      );
    } on SocketException {
      throw NoInternetException('No internet connection available');
    } on TimeoutException {
      throw RequestTimeoutException('Request timed out');
    } catch (e, stackTrace) {
      developer.log('[USER] Unexpected error while fetching users by entity: $e',
          name: 'UserService', error: e, stackTrace: stackTrace);
      throw ServiceException('Error fetching users by entity: $e');
    }
  }

  Future<String?> getAuthToken() async {
    developer.log('[USER] Retrieving security token from storage', name: 'UserService');
    final token = await _storage.getAuthToken();
    developer.log('[USER] Auth token ${token != null ? 'found' : 'not found'}', name: 'UserService');
    return token;
  }

  Future<String?> getUserId() async {
    developer.log('[USER] Retrieving user ID from storage', name: 'UserService');
    final userId = await _storage.getUserId();
    developer.log('[USER] User ID ${userId != null ? 'found' : 'not found'}', name: 'UserService');
    return userId;
  }
}