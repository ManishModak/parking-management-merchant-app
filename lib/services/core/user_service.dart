import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:merchant_app/config/api_config.dart';
import 'package:merchant_app/models/user_model.dart';
import 'package:merchant_app/utils/exceptions.dart';
import '../storage/secure_storage_service.dart';
import '../network/connectivity_service.dart';

class UserService {
  final SecureStorageService _storage;
  final http.Client _client;
  final ConnectivityService _connectivityService;

  UserService({
    http.Client? client,
    SecureStorageService? storage,
    ConnectivityService? connectivityService,
  })  : _client = client ?? http.Client(),
        _storage = storage ?? SecureStorageService(),
        _connectivityService = connectivityService ?? ConnectivityService();

  /// Helper method to get headers with Authorization token
  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Registers a new user and optionally stores auth details for app users.
  Future<Map<String, dynamic>> userRegister({
    required String username,
    required String email,
    required String mobileNumber,
    required String password,
    required String city,
    required String state,
    required String address,
    required String pincode,
    required bool isAppUserRegister,
    String? role,
    String? entity,
    List<String>? subEntity,
    String? entityId,
  }) async {
    final url = ApiConfig.getFullUrl(AuthApi.register);
    final serverUrl = Uri.parse(url);

    if (!(await _connectivityService.isConnected())) {
      throw NoInternetException(
          'No internet connection. Please check your network settings.');
    }
    if (!(await _connectivityService.canReachServer(serverUrl.host))) {
      throw ServerConnectionException('Cannot reach the auth server.',
          host: serverUrl.host);
    }

    developer.log('[USER] Starting registration at URL: $url',
        name: 'UserService');

    final userData = {
      'username': username,
      'email': email,
      'mobileNumber': mobileNumber,
      'password': password,
      'address': address,
      'state': state,
      'city': city,
      'pincode': pincode,
      if (role != null) 'role': role,
      if (entity != null) 'entityName': entity,
      if (!isAppUserRegister && subEntity != null && subEntity.isNotEmpty)
        'subEntity': subEntity,
      if (!isAppUserRegister && entityId != null) 'entityId': entityId,
    };

    final body = json.encode(userData);
    if (kDebugMode) {
      developer.log('[USER] Request payload: $body', name: 'UserService');
    }

    try {
      final response = await _client
          .post(
        serverUrl,
        headers: await _getHeaders(),
        body: body,
      )
          .timeout(const Duration(seconds: 10));

      developer.log('[USER] Response Status Code: ${response.statusCode}',
          name: 'UserService');
      developer.log('[USER] Response Body: ${response.body}',
          name: 'UserService');

      final responseData = json.decode(response.body);

      if (response.statusCode == 201) {
        if (isAppUserRegister) {
          if (responseData['token'] == null ||
              responseData['user']?['id'] == null) {
            throw ServiceException(
                'Invalid response format: missing token or user ID');
          }
          await _storage.storeAuthDetails(
            responseData['token'],
            responseData['user']['id'].toString(),
          );
          developer.log('[USER] Successfully stored auth details for app user',
              name: 'UserService');
        }
        developer.log('[USER] Successfully registered user',
            name: 'UserService');
        return Map<String, dynamic>.from(responseData['user']);
      } else if (response.statusCode == 500 &&
          responseData['msg']?.contains('email') == true &&
          responseData['msg']?.contains('already taken') == true) {
        throw EmailInUseException('Email is already in use');
      }

      throw _handleErrorResponse(response, 'Registration failed');
    } on SocketException catch (e) {
      throw ServerConnectionException(
          'Failed to connect to the auth server: $e');
    } on TimeoutException {
      throw RequestTimeoutException('Request timed out');
    } catch (e, stackTrace) {
      developer.log('[USER] Error in userRegister: $e',
          name: 'UserService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Fetches user information by ID, optionally storing data for the current app user.
  Future<User> fetchUserInfo(String userId, bool isCurrentAppUser) async {
    final url = ApiConfig.getFullUrl('${AuthApi.getUser}$userId');
    final serverUrl = Uri.parse(url);

    if (!(await _connectivityService.isConnected())) {
      throw NoInternetException(
          'No internet connection. Please check your network settings.');
    }
    if (!(await _connectivityService.canReachServer(serverUrl.host))) {
      throw ServerConnectionException('Cannot reach the auth server.',
          host: serverUrl.host);
    }

    developer.log('[USER] Fetching user info at URL: $url',
        name: 'UserService');

    try {
      final response = await _client
          .get(serverUrl, headers: await _getHeaders())
          .timeout(const Duration(seconds: 10));

      developer.log('[USER] Response Status Code: ${response.statusCode}',
          name: 'UserService');
      developer.log('[USER] Response Body: ${response.body}',
          name: 'UserService');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['user'] != null) {
          final userData = Map<String, dynamic>.from(responseData['user']);
          if (isCurrentAppUser) {
            await _storage.storeUserData(userData);
          }
          developer.log('[USER] Successfully fetched user info for ID: $userId',
              name: 'UserService');
          return User.fromJson(userData);
        }
        throw ServiceException('Invalid response format: missing user data');
      }

      throw _handleErrorResponse(response, 'Failed to fetch user info');
    } on SocketException catch (e) {
      throw ServerConnectionException(
          'Failed to connect to the auth server: $e');
    } on TimeoutException {
      throw RequestTimeoutException('Request timed out');
    } catch (e, stackTrace) {
      developer.log('[USER] Error in fetchUserInfo: $e',
          name: 'UserService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Updates user information for the specified user ID.
  Future<bool> updateUserInfo(
      String userId, {
        required String username,
        required String email,
        String? mobileNumber,
        String? address,
        String? city,
        String? state,
        String? pincode,
        String? role,
        List<String>? subEntity,
      }) async {
    final url = ApiConfig.getFullUrl('${AuthApi.updateProfile}$userId');
    final serverUrl = Uri.parse(url);

    if (!(await _connectivityService.isConnected())) {
      throw NoInternetException(
          'No internet connection. Please check your network settings.');
    }
    if (!(await _connectivityService.canReachServer(serverUrl.host))) {
      throw ServerConnectionException('Cannot reach the auth server.',
          host: serverUrl.host);
    }

    developer.log('[USER] Updating user info at URL: $url', name: 'UserService');

    final userData = {
      'username': username,
      'email': email,
      if (mobileNumber != null) 'mobileNumber': mobileNumber,
      if (address != null) 'address': address,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (pincode != null) 'pincode': pincode,
      if (role != null) 'role': role,
      if (subEntity != null && subEntity.isNotEmpty) 'subEntity': subEntity,
    };

    final body = json.encode(userData);
    developer.log('[USER] Request payload: $body', name: 'UserService');

    try {
      final response = await _client
          .put(
        serverUrl,
        headers: await _getHeaders(),
        body: body,
      )
          .timeout(const Duration(seconds: 10));

      developer.log('[USER] Response Status Code: ${response.statusCode}',
          name: 'UserService');
      developer.log('[USER] Response Body: ${response.body}',
          name: 'UserService');

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (responseData['success'] == true) {
          developer.log('[USER] Successfully updated user info for ID: $userId',
              name: 'UserService');
          return true;
        }
        return false;
      }
      else if (response.statusCode == 400) { // **** MODIFICATION STARTS HERE ****
        // Check for the specific validation error structure
        // responseData is already decoded: {"success":false,"msg":"Validation error occurred","errors":[{"field":"email","message":"email must be unique"}]}
        if (responseData is Map && responseData.containsKey('errors')) {
          final errors = responseData['errors'] as List?;
          if (errors != null) {
            for (var error in errors) {
              if (error is Map && error['field'] == 'email' &&
                  error['message'] != null) {
                developer.log(
                    '[USER] Email in use detected via 400: ${error['message']}',
                    name: 'UserService');
                throw EmailInUseException(
                    error['message']); // Use the server's specific message
              }
              // You could add more specific checks for other fields here if needed for 400 errors
              // e.g., if (error is Map && error['field'] == 'mobileNumber' && ...) { throw MobileNumberInUseException(...) }
            }
          }
        }
        // If it's a 400 error but not the specific "email in use" format we're looking for,
        // let it fall through to _handleErrorResponse.
        // _handleErrorResponse will use responseData['msg'] which is "Validation error occurred"
      }
        else if (response.statusCode == 500 &&
          responseData['msg']?.contains('email') == true &&
          responseData['msg']?.contains('already taken') == true) {
        throw EmailInUseException('Email $email is already taken');
      }

      throw _handleErrorResponse(response, 'Failed to update user info');
    } on SocketException catch (e) {
      throw ServerConnectionException(
          'Failed to connect to the auth server: $e');
    } on TimeoutException {
      throw RequestTimeoutException('Request timed out');
    } catch (e, stackTrace) {
      developer.log('[USER] Error in updateUserInfo: $e',
          name: 'UserService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Retrieves a list of all users.
  Future<List<User>> getUserList() async {
    final url = ApiConfig.getFullUrl(AuthApi.userList);
    final serverUrl = Uri.parse(url);

    if (!(await _connectivityService.isConnected())) {
      throw NoInternetException(
          'No internet connection. Please check your network settings.');
    }
    if (!(await _connectivityService.canReachServer(serverUrl.host))) {
      throw ServerConnectionException('Cannot reach the auth server.',
          host: serverUrl.host);
    }

    developer.log('[USER] Fetching user list at URL: $url',
        name: 'UserService');

    try {
      final response = await _client
          .get(serverUrl, headers: await _getHeaders())
          .timeout(const Duration(seconds: 10));

      developer.log('[USER] Response Status Code: ${response.statusCode}',
          name: 'UserService');
      developer.log('[USER] Response Body: ${response.body}',
          name: 'UserService');

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        final List<dynamic> users = responseData['users'] ?? [];
        final userList = users.map((user) => User.fromJson(user)).toList();
        developer.log('[USER] Successfully fetched ${userList.length} users',
            name: 'UserService');
        return userList;
      }

      throw _handleErrorResponse(response, 'Failed to fetch user list');
    } on SocketException catch (e) {
      throw ServerConnectionException(
          'Failed to connect to the auth server: $e');
    } on TimeoutException {
      throw RequestTimeoutException('Request timed out');
    } catch (e, stackTrace) {
      developer.log('[USER] Error in getUserList: $e',
          name: 'UserService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Resets the password for a specified user.
  Future<bool> resetPassword(String userId, String newPassword) async {
    final url = ApiConfig.getFullUrl(AuthApi.resetPassword);
    final serverUrl = Uri.parse(url);

    if (!(await _connectivityService.isConnected())) {
      throw NoInternetException(
          'No internet connection. Please check your network settings.');
    }
    if (!(await _connectivityService.canReachServer(serverUrl.host))) {
      throw ServerConnectionException('Cannot reach the auth server.',
          host: serverUrl.host);
    }

    developer.log('[USER] Resetting password at URL: $url',
        name: 'UserService');

    final passwordData = {'userId': userId, 'newPassword': newPassword};
    final body = json.encode(passwordData);
    developer.log('[USER] Request payload: $body', name: 'UserService');

    try {
      final response = await _client
          .post(
        serverUrl,
        headers: await _getHeaders(),
        body: body,
      )
          .timeout(const Duration(seconds: 10));

      developer.log('[USER] Response Status Code: ${response.statusCode}',
          name: 'UserService');
      developer.log('[USER] Response Body: ${response.body}',
          name: 'UserService');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          developer.log(
              '[USER] Successfully reset password for user ID: $userId',
              name: 'UserService');
          return true;
        }
        return false;
      }

      throw _handleErrorResponse(response, 'Failed to reset password');
    } on SocketException catch (e) {
      throw ServerConnectionException(
          'Failed to connect to the auth server: $e');
    } on TimeoutException {
      throw RequestTimeoutException('Request timed out');
    } catch (e, stackTrace) {
      developer.log('[USER] Error in resetPassword: $e',
          name: 'UserService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Retrieves users associated with a specific entity ID.
  Future<List<User>> getUsersList() async {
    final url = ApiConfig.getFullUrl(AuthApi.getUsersList);
    final serverUrl = Uri.parse(url);

    if (!(await _connectivityService.isConnected())) {
      throw NoInternetException(
          'No internet connection. Please check your network settings.');
    }
    if (!(await _connectivityService.canReachServer(serverUrl.host))) {
      throw ServerConnectionException('Cannot reach the auth server.',
          host: serverUrl.host);
    }

    developer.log('[USER] Fetching users by entity ID at URL: $url',
        name: 'UserService');

    try {
      final response = await _client
          .get(serverUrl, headers: await _getHeaders())
          .timeout(const Duration(seconds: 10));

      developer.log('[USER] Response Status Code: ${response.statusCode}',
          name: 'UserService');
      developer.log('[USER] Response Body: ${response.body}',
          name: 'UserService');

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        final List<dynamic> users = responseData['users'] ?? [];
        final userList = users.map((user) => User.fromJson(user)).toList();
        return userList;
      }

      throw _handleErrorResponse(
          response, 'Failed to fetch users by entity ID');
    } on SocketException catch (e) {
      throw ServerConnectionException(
          'Failed to connect to the auth server: $e');
    } on TimeoutException {
      throw RequestTimeoutException('Request timed out');
    } catch (e, stackTrace) {
      developer.log('[USER] Error in getUsersByEntityId: $e',
          name: 'UserService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Retrieves the stored authentication token.
  Future<String?> getAuthToken() async {
    developer.log('[USER] Retrieving auth token from storage',
        name: 'UserService');
    final token = await _storage.getAuthToken();
    developer.log(
        '[USER] Auth token ${token != null ? 'retrieved' : 'not found'}',
        name: 'UserService');
    return token;
  }

  /// Retrieves the stored user ID.
  Future<String?> getUserId() async {
    developer.log('[USER] Retrieving user ID from storage',
        name: 'UserService');
    final userId = await _storage.getUserId();
    developer.log(
        '[USER] User ID ${userId != null ? 'retrieved' : 'not found'}',
        name: 'UserService');
    return userId;
  }

  HttpException _handleErrorResponse(
      http.Response response, String defaultMessage) {
    String? serverMessage;
    try {
      final responseData = json.decode(response.body);
      // Prefer 'msg' if available, then 'message', then a generic one
      serverMessage = responseData['msg'] as String? ?? responseData['message'] as String?;
    } catch (_) {
      // If parsing fails or keys don't exist, serverMessage remains null
    }
    developer.log('[USER] Handling error response. Status: ${response.statusCode}. Server Message: "$serverMessage". Default: "$defaultMessage"', name: 'UserService');
    return HttpException(
      serverMessage ?? defaultMessage, // Use server message if available, else default
      statusCode: response.statusCode,
      serverMessage: serverMessage ?? response.body, // For logging, use full body if msg is not parsable
    );
  }
}