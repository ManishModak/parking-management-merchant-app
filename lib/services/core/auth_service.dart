import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:merchant_app/config/api_config.dart';
import '../../utils/exceptions.dart';
import '../storage/secure_storage_service.dart';
import '../network/connectivity_service.dart';
import 'dart:developer' as developer;

class AuthService {
  final SecureStorageService _storage = SecureStorageService();
  final http.Client _client;
  final ConnectivityService _connectivityService;

  AuthService({
    http.Client? client,
    ConnectivityService? connectivityService,
  })  : _client = client ?? http.Client(),
        _connectivityService = connectivityService ?? ConnectivityService();

  Future<bool> login(String emailOrMobile, String password) async {
    try {
      if (!(await _connectivityService.isConnected())) {
        developer.log('[AUTH] No internet connection detected before login attempt', name: 'AuthService');
        throw NoInternetException('No internet connection available. Please check your network settings.');
      }

      final serverUrl = Uri.parse(ApiConfig.getFullUrl(AuthApi.login));
      if (!(await _connectivityService.canReachServer(serverUrl.host))) {
        developer.log('[AUTH] Server unreachable: ${serverUrl.host}', name: 'AuthService');
        throw ServerConnectionException('Cannot reach the authentication server. The server may be down or unreachable.', host: serverUrl.host);
      }

      final String url = ApiConfig.getFullUrl(AuthApi.login);
      final body = jsonEncode({
        'emailOrMobile': emailOrMobile.toLowerCase(),
        'password': password,
      });
      developer.log('[AUTH] Login attempt at: $url', name: 'AuthService');
      developer.log('[AUTH] Request body: $body', name: 'AuthService');

      try {
        final response = await _client.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: body,
        ).timeout(const Duration(seconds: 30));

        developer.log('[AUTH] Response: ${response.statusCode} - ${response.body}', name: 'AuthService');

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          if (responseData['token'] != null && responseData['user']?['id'] != null) {
            await _storage.storeAuthDetails(
              responseData['token'],
              responseData['user']['id'].toString(),
            );
            developer.log('[AUTH] Login successful, token stored', name: 'AuthService');
            return true;
          }
          throw ServiceException('Invalid response: Missing token or user ID');
        }

        final responseData = json.decode(response.body);
        String serverMessage = responseData['msg'] ?? responseData['message'] ?? 'Unknown error';
        switch (response.statusCode) {
          case 400:
            serverMessage = 'Invalid request data';
            break;
          case 401:
            serverMessage = 'Invalid credentials';
            break;
          case 403:
            serverMessage = 'Access denied';
            break;
          case 404:
            serverMessage = 'User not found';
            break;
          case 500:
            serverMessage = 'Server error';
            break;
          case 502:
            serverMessage = 'Failed to reach user service';
            break;
        }
        throw HttpException(
          'Login failed',
          statusCode: response.statusCode,
          serverMessage: serverMessage,
        );
      } on SocketException catch (e) {
        developer.log('[AUTH] Socket exception: $e', name: 'AuthService');
        throw ServerConnectionException('Failed to connect to the authentication server. The server may be temporarily unavailable.');
      } on TimeoutException catch (e) {
        developer.log('[AUTH] Timeout exception: $e', name: 'AuthService');
        throw RequestTimeoutException('Request timed out. The server is taking too long to respond.');
      } catch (e, stackTrace) {
        developer.log('[AUTH] Error: $e', name: 'AuthService', stackTrace: stackTrace);
        rethrow;
      }
    } catch (e) {
      developer.log('[AUTH] Outer catch block: $e', name: 'AuthService');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createPlazaOwner({
    required String userName,
    required String name,
    required String mobileNumber,
    required String email,
    required String password,
    required String address,
    required String city,
    required String state,
    required String pincode,
    required String companyName,
    required String companyType,
    String? aadhaarNumber,
    String? panNumber,
    String? bankName,
    String? accountNumber,
    String? ifscCode,
  }) async {
    if (!(await _connectivityService.isConnected())) {
      throw NoInternetException('No internet connection available. Please check your network settings.');
    }

    final serverUrl = Uri.parse(ApiConfig.getFullUrl(AuthApi.createOwner));
    if (!(await _connectivityService.canReachServer(serverUrl.host))) {
      developer.log('[AUTH] Server unreachable: ${serverUrl.host}', name: 'AuthService');
      throw ServerConnectionException('Cannot reach the registration server. The server may be down or unreachable.', host: serverUrl.host);
    }

    final String url = ApiConfig.getFullUrl(AuthApi.createOwner);
    final body = jsonEncode({
      'role': 'Plaza Owner',
      'userName': userName,
      'name': name,
      'mobileNumber': mobileNumber,
      'email': email,
      'password': password,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'companyName': companyName,
      'companyType': companyType,
      'aadharNumber': aadhaarNumber,
      'panNumber': panNumber,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'ifscCode': ifscCode,
    });
    developer.log('[AUTH] Registering Plaza Owner at: $url', name: 'AuthService');
    developer.log('[AUTH] Request body: $body', name: 'AuthService');

    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      ).timeout(const Duration(seconds: 30));

      developer.log('[AUTH] Response: ${response.statusCode} - ${response.body}', name: 'AuthService');

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        if (responseData['data'] != null) {
          developer.log('[AUTH] Registration successful', name: 'AuthService');
          return responseData['data'];
        }
        throw ServiceException('Invalid response: Missing user data');
      }

      final responseData = json.decode(response.body);
      String serverMessage = responseData['message'] ?? responseData['msg'] ?? 'Unknown error';
      switch (response.statusCode) {
        case 400:
          if (serverMessage.contains('Email already in use')) {
            throw EmailInUseException('This email is already in use. Please try a different email.');
          } else if (serverMessage.contains('companyType')) {
            serverMessage = 'Invalid company type';
          } else {
            serverMessage = 'Invalid registration data';
          }
          break;
        case 409:
          serverMessage = 'User already exists';
          break;
        case 500:
          if (serverMessage.contains('userName must be unique')) {
            serverMessage = 'Username must be unique';
          } else if (serverMessage.contains('aadhaarNumber must be unique')) {
            serverMessage = 'Aadhaar number already exists';
          } else if (serverMessage.contains('panNumber must be unique')) {
            serverMessage = 'PAN number already exists';
          } else if (serverMessage.contains('accountNumber must be unique')) {
            serverMessage = 'Account number already exists';
          } else {
            serverMessage = 'Server error';
          }
          break;
        case 502:
          serverMessage = 'Failed to reach user service';
          break;
      }
      throw HttpException(
        'Registration failed',
        statusCode: response.statusCode,
        serverMessage: serverMessage,
      );
    } on SocketException {
      throw ServerConnectionException('Failed to connect to the registration server. The server may be temporarily unavailable.');
    } on TimeoutException {
      throw RequestTimeoutException('Request timed out. The server is taking too long to respond.');
    } catch (e, stackTrace) {
      developer.log('[AUTH] Error: $e', name: 'AuthService', stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> logout() async {
    developer.log('[AUTH] Logging out', name: 'AuthService');
    await _storage.clearAll();
    developer.log('[AUTH] All stored data cleared', name: 'AuthService');
  }

  Future<bool> isAuthenticated() async {
    final result = await _storage.isAuthenticated();
    developer.log('[AUTH] Authentication check: $result', name: 'AuthService');
    return result;
  }

  Future<String?> getAuthToken() async {
    final token = await _storage.getAuthToken();
    developer.log('[AUTH] Auth token retrieved: ${token != null ? 'exists' : 'null'}', name: 'AuthService');
    return token;
  }

  Future<String?> getUserId() async {
    final userId = await _storage.getUserId();
    developer.log('[AUTH] User ID retrieved: ${userId != null ? 'exists' : 'null'}', name: 'AuthService');
    return userId;
  }
}