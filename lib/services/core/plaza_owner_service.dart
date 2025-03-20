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

class PlazaOwnerService {
  final SecureStorageService _storage;
  final http.Client _client;
  final ConnectivityService _connectivityService;

  PlazaOwnerService({
    http.Client? client,
    SecureStorageService? storage,
    ConnectivityService? connectivityService,
  })  : _client = client ?? http.Client(),
        _storage = storage ?? SecureStorageService(),
        _connectivityService = connectivityService ?? ConnectivityService();

  /// Creates a new plaza owner.
  Future<Map<String, dynamic>> createOwner({
    required String username,
    required String email,
    required String mobileNumber,
    required String password,
    required String address,
    required String city,
    required String state,
  }) async {
    final url = ApiConfig.getFullUrl(AuthApi.createOwner);
    final serverUrl = Uri.parse(url);

    if (!(await _connectivityService.isConnected())) {
      throw NoInternetException('No internet connection. Please check your network settings.');
    }
    if (!(await _connectivityService.canReachServer(serverUrl.host))) {
      throw ServerConnectionException('Cannot reach the auth server.', host: serverUrl.host);
    }

    developer.log('[OWNER] Starting owner creation at URL: $url', name: 'PlazaOwnerService');

    final ownerData = {
      'username': username,
      'email': email,
      'mobileNumber': mobileNumber,
      'password': password,
      'address': address,
      'city': city,
      'state': state,
      'role': 'plaza_owner',
    };

    final body = json.encode(ownerData);
    if (kDebugMode) {
      developer.log('[OWNER] Request payload: $body', name: 'PlazaOwnerService');
    }

    try {
      final response = await _client
          .post(
        serverUrl,
        headers: {'Content-Type': 'application/json'},
        body: body,
      )
          .timeout(const Duration(seconds: 10));

      developer.log('[OWNER] Response Status Code: ${response.statusCode}', name: 'PlazaOwnerService');
      developer.log('[OWNER] Response Body: ${response.body}', name: 'PlazaOwnerService');

      final responseData = json.decode(response.body);

      if (response.statusCode == 201) {
        if (responseData['success'] == true && responseData['owner'] != null) {
          developer.log('[OWNER] Successfully created plaza owner', name: 'PlazaOwnerService');
          return Map<String, dynamic>.from(responseData['owner']);
        }
        throw ServiceException('Invalid response format: missing owner data');
      }

      throw _handleErrorResponse(response, 'Failed to create owner');
    } on SocketException catch (e) {
      throw ServerConnectionException('Failed to connect to the auth server: $e');
    } on TimeoutException {
      throw RequestTimeoutException('Request timed out');
    } catch (e, stackTrace) {
      developer.log('[OWNER] Error in createOwner: $e', name: 'PlazaOwnerService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Initiates mobile number verification for an owner.
  Future<bool> mobileVerification(String mobileNumber) async {
    final url = ApiConfig.getFullUrl(AuthApi.mobileVerification);
    final serverUrl = Uri.parse(url);

    if (!(await _connectivityService.isConnected())) {
      throw NoInternetException('No internet connection. Please check your network settings.');
    }
    if (!(await _connectivityService.canReachServer(serverUrl.host))) {
      throw ServerConnectionException('Cannot reach the auth server.', host: serverUrl.host);
    }

    developer.log('[OWNER] Starting mobile verification at URL: $url', name: 'PlazaOwnerService');

    final requestData = {'mobileNumber': mobileNumber};
    final body = json.encode(requestData);
    developer.log('[OWNER] Request payload: $body', name: 'PlazaOwnerService');

    try {
      final response = await _client
          .post(
        serverUrl,
        headers: {'Content-Type': 'application/json'},
        body: body,
      )
          .timeout(const Duration(seconds: 10));

      developer.log('[OWNER] Response Status Code: ${response.statusCode}', name: 'PlazaOwnerService');
      developer.log('[OWNER] Response Body: ${response.body}', name: 'PlazaOwnerService');

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        developer.log('[OWNER] Mobile verification successful', name: 'PlazaOwnerService');
        return true;
      }

      throw _handleErrorResponse(response, 'Mobile verification failed');
    } on SocketException catch (e) {
      throw ServerConnectionException('Failed to connect to the auth server: $e');
    } on TimeoutException {
      throw RequestTimeoutException('Request timed out');
    } catch (e, stackTrace) {
      developer.log('[OWNER] Error in mobileVerification: $e', name: 'PlazaOwnerService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Verifies the OTP for a mobile number during owner registration/verification.
  Future<bool> verifyOtp(String mobileNumber, String otp) async {
    final url = ApiConfig.getFullUrl(AuthApi.verifyOtp);
    final serverUrl = Uri.parse(url);

    if (!(await _connectivityService.isConnected())) {
      throw NoInternetException('No internet connection. Please check your network settings.');
    }
    if (!(await _connectivityService.canReachServer(serverUrl.host))) {
      throw ServerConnectionException('Cannot reach the auth server.', host: serverUrl.host);
    }

    developer.log('[OWNER] Starting OTP verification at URL: $url', name: 'PlazaOwnerService');

    final requestData = {'mobileNumber': mobileNumber, 'otp': otp};
    final body = json.encode(requestData);
    developer.log('[OWNER] Request payload: $body', name: 'PlazaOwnerService');

    try {
      final response = await _client
          .post(
        serverUrl,
        headers: {'Content-Type': 'application/json'},
        body: body,
      )
          .timeout(const Duration(seconds: 10));

      developer.log('[OWNER] Response Status Code: ${response.statusCode}', name: 'PlazaOwnerService');
      developer.log('[OWNER] Response Body: ${response.body}', name: 'PlazaOwnerService');

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        developer.log('[OWNER] OTP verification successful', name: 'PlazaOwnerService');
        return true;
      }

      throw _handleErrorResponse(response, 'OTP verification failed');
    } on SocketException catch (e) {
      throw ServerConnectionException('Failed to connect to the auth server: $e');
    } on TimeoutException {
      throw RequestTimeoutException('Request timed out');
    } catch (e, stackTrace) {
      developer.log('[OWNER] Error in verifyOtp: $e', name: 'PlazaOwnerService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Fetches details of a specific plaza owner by ID.
  Future<User> getOwner(String ownerId) async {
    final url = ApiConfig.getFullUrl('${AuthApi.getOwner}$ownerId');
    final serverUrl = Uri.parse(url);

    if (!(await _connectivityService.isConnected())) {
      throw NoInternetException('No internet connection. Please check your network settings.');
    }
    if (!(await _connectivityService.canReachServer(serverUrl.host))) {
      throw ServerConnectionException('Cannot reach the auth server.', host: serverUrl.host);
    }

    developer.log('[OWNER] Fetching owner info at URL: $url', name: 'PlazaOwnerService');
    final headers = await _getAuthHeaders();

    try {
      final response = await _client
          .get(serverUrl, headers: headers)
          .timeout(const Duration(seconds: 10));

      developer.log('[OWNER] Response Status Code: ${response.statusCode}', name: 'PlazaOwnerService');
      developer.log('[OWNER] Response Body: ${response.body}', name: 'PlazaOwnerService');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['owner'] != null) {
          developer.log('[OWNER] Successfully fetched owner info for ID: $ownerId', name: 'PlazaOwnerService');
          return User.fromJson(responseData['owner']);
        }
        throw ServiceException('Invalid response format: missing owner data');
      }

      throw _handleErrorResponse(response, 'Failed to fetch owner info');
    } on SocketException catch (e) {
      throw ServerConnectionException('Failed to connect to the auth server: $e');
    } on TimeoutException {
      throw RequestTimeoutException('Request timed out');
    } catch (e, stackTrace) {
      developer.log('[OWNER] Error in getOwner: $e', name: 'PlazaOwnerService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Fetches owner details by email.
  Future<User> getOwnerByEmail(String email) async {
    final url = ApiConfig.getFullUrl('${AuthApi.getOwnerByEmail}?email=$email');
    final serverUrl = Uri.parse(url);

    if (!(await _connectivityService.isConnected())) {
      throw NoInternetException('No internet connection. Please check your network settings.');
    }
    if (!(await _connectivityService.canReachServer(serverUrl.host))) {
      throw ServerConnectionException('Cannot reach the auth server.', host: serverUrl.host);
    }

    developer.log('[OWNER] Fetching owner by email at URL: $url', name: 'PlazaOwnerService');
    final headers = await _getAuthHeaders();

    try {
      final response = await _client
          .get(serverUrl, headers: headers)
          .timeout(const Duration(seconds: 10));

      developer.log('[OWNER] Response Status Code: ${response.statusCode}', name: 'PlazaOwnerService');
      developer.log('[OWNER] Response Body: ${response.body}', name: 'PlazaOwnerService');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['owner'] != null) {
          developer.log('[OWNER] Successfully fetched owner by email: $email', name: 'PlazaOwnerService');
          return User.fromJson(responseData['owner']);
        }
        throw ServiceException('Invalid response format: missing owner data');
      }

      throw _handleErrorResponse(response, 'Failed to fetch owner by email');
    } on SocketException catch (e) {
      throw ServerConnectionException('Failed to connect to the auth server: $e');
    } on TimeoutException {
      throw RequestTimeoutException('Request timed out');
    } catch (e, stackTrace) {
      developer.log('[OWNER] Error in getOwnerByEmail: $e', name: 'PlazaOwnerService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Updates details of an existing plaza owner.
  Future<bool> updateOwner(String ownerId, Map<String, dynamic> updateData) async {
    final url = ApiConfig.getFullUrl('${AuthApi.updateOwner}$ownerId');
    final serverUrl = Uri.parse(url);

    if (!(await _connectivityService.isConnected())) {
      throw NoInternetException('No internet connection. Please check your network settings.');
    }
    if (!(await _connectivityService.canReachServer(serverUrl.host))) {
      throw ServerConnectionException('Cannot reach the auth server.', host: serverUrl.host);
    }

    developer.log('[OWNER] Updating owner info at URL: $url', name: 'PlazaOwnerService');
    final headers = await _getAuthHeaders();

    final body = json.encode(updateData);
    developer.log('[OWNER] Request payload: $body', name: 'PlazaOwnerService');

    try {
      final response = await _client
          .put(
        serverUrl,
        headers: headers,
        body: body,
      )
          .timeout(const Duration(seconds: 10));

      developer.log('[OWNER] Response Status Code: ${response.statusCode}', name: 'PlazaOwnerService');
      developer.log('[OWNER] Response Body: ${response.body}', name: 'PlazaOwnerService');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          developer.log('[OWNER] Successfully updated owner info for ID: $ownerId', name: 'PlazaOwnerService');
          return true;
        }
        return false;
      }

      throw _handleErrorResponse(response, 'Failed to update owner');
    } on SocketException catch (e) {
      throw ServerConnectionException('Failed to connect to the auth server: $e');
    } on TimeoutException {
      throw RequestTimeoutException('Request timed out');
    } catch (e, stackTrace) {
      developer.log('[OWNER] Error in updateOwner: $e', name: 'PlazaOwnerService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Deletes a plaza owner by ID.
  Future<bool> deleteOwner(String ownerId) async {
    final url = ApiConfig.getFullUrl('${AuthApi.deleteOwner}$ownerId');
    final serverUrl = Uri.parse(url);

    if (!(await _connectivityService.isConnected())) {
      throw NoInternetException('No internet connection. Please check your network settings.');
    }
    if (!(await _connectivityService.canReachServer(serverUrl.host))) {
      throw ServerConnectionException('Cannot reach the auth server.', host: serverUrl.host);
    }

    developer.log('[OWNER] Deleting owner at URL: $url', name: 'PlazaOwnerService');
    final headers = await _getAuthHeaders();

    try {
      final response = await _client
          .delete(serverUrl, headers: headers)
          .timeout(const Duration(seconds: 10));

      developer.log('[OWNER] Response Status Code: ${response.statusCode}', name: 'PlazaOwnerService');
      developer.log('[OWNER] Response Body: ${response.body}', name: 'PlazaOwnerService');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          developer.log('[OWNER] Successfully deleted owner ID: $ownerId', name: 'PlazaOwnerService');
          return true;
        }
        return false;
      }

      throw _handleErrorResponse(response, 'Failed to delete owner');
    } on SocketException catch (e) {
      throw ServerConnectionException('Failed to connect to the auth server: $e');
    } on TimeoutException {
      throw RequestTimeoutException('Request timed out');
    } catch (e, stackTrace) {
      developer.log('[OWNER] Error in deleteOwner: $e', name: 'PlazaOwnerService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Retrieves a list of all plaza owners.
  Future<List<User>> getOwnerList() async {
    final url = ApiConfig.getFullUrl(AuthApi.ownerList);
    final serverUrl = Uri.parse(url);

    if (!(await _connectivityService.isConnected())) {
      throw NoInternetException('No internet connection. Please check your network settings.');
    }
    if (!(await _connectivityService.canReachServer(serverUrl.host))) {
      throw ServerConnectionException('Cannot reach the auth server.', host: serverUrl.host);
    }

    developer.log('[OWNER] Fetching owner list at URL: $url', name: 'PlazaOwnerService');
    final headers = await _getAuthHeaders();

    try {
      final response = await _client
          .get(serverUrl, headers: headers)
          .timeout(const Duration(seconds: 10));

      developer.log('[OWNER] Response Status Code: ${response.statusCode}', name: 'PlazaOwnerService');
      developer.log('[OWNER] Response Body: ${response.body}', name: 'PlazaOwnerService');

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        final List<dynamic> owners = responseData['owners'] ?? [];
        final ownerList = owners.map((owner) => User.fromJson(owner)).toList();
        developer.log('[OWNER] Successfully fetched ${ownerList.length} owners', name: 'PlazaOwnerService');
        return ownerList;
      }

      throw _handleErrorResponse(response, 'Failed to fetch owner list');
    } on SocketException catch (e) {
      throw ServerConnectionException('Failed to connect to the auth server: $e');
    } on TimeoutException {
      throw RequestTimeoutException('Request timed out');
    } catch (e, stackTrace) {
      developer.log('[OWNER] Error in getOwnerList: $e', name: 'PlazaOwnerService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Helper method to get headers with authorization token.
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _storage.getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Helper method to handle error responses consistently.
  HttpException _handleErrorResponse(http.Response response, String defaultMessage) {
    String? serverMessage;
    try {
      final responseData = json.decode(response.body);
      serverMessage = responseData['msg'] as String?;
    } catch (_) {
      serverMessage = null;
    }
    return HttpException(
      defaultMessage,
      statusCode: response.statusCode,
      serverMessage: serverMessage ?? 'Unknown server error',
    );
  }
}