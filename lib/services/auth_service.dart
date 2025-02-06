import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:merchant_app/config/api_config.dart';
import './secure_storage_service.dart';

class AuthService {
  final SecureStorageService _storage = SecureStorageService();

  Future<bool> login(String emailOrMobile, String password) async {
    final String url = ApiConfig.getFullUrl(ApiConfig.loginEndpoint);
    print('[LOGIN] Attempting login at URL: $url');
    print('[LOGIN] Attempting with email/mobile: $emailOrMobile');

    try {
      print('[LOGIN] Sending request...');
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'emailOrMobile': emailOrMobile.toLowerCase(),
          'password': password
        }),
      );

      print('[LOGIN] Response status code: ${response.statusCode}');
      print('[LOGIN] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('[LOGIN] Successfully decoded response data');

        if (responseData['token'] == null || responseData['user']?['id'] == null) {
          print('[LOGIN] ERROR: Missing token or user ID in response');
          throw Exception('Invalid response format');
        }

        print('[LOGIN] Storing auth details...');
        await _storage.storeAuthDetails(
          responseData['token'],
          responseData['user']['id'].toString(),
        );
        print('[LOGIN] Successfully stored auth details');
        return true;
      }

      final responseData = json.decode(response.body);
      print('[LOGIN] ERROR: Failed with message: ${responseData['msg']}');
      throw Exception(responseData['msg'] ?? 'Login failed');
    } catch (e) {
      print('[LOGIN] ERROR: Exception occurred: $e');
      if (e is FormatException) {
        throw Exception('Invalid response format');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String mobileNumber,
    required String password,
    required String city,
    required String state,
    required String address,
    required bool isAppUserRegister,
    String? role,
    String? entity,
    String? subEntity,
    String? entityId
  }) async {
    final String url = ApiConfig.getFullUrl(ApiConfig.registerEndpoint);
    print('[REGISTER] Starting registration at URL: $url');

    final Map<String, dynamic> userData = {
      'username': username,
      'email': email,
      'mobileNumber': mobileNumber,
      'password': password,
      'address': address,
      'state': state,
      'city': city,
      'role': role,
      'entityName': entity,
      if (!isAppUserRegister && subEntity != null) 'subEntity': [subEntity],
      if (!isAppUserRegister && entityId != null) 'entityId': entityId,
    };

    print('[REGISTER] Request payload: ${json.encode(userData)}');

    try {
      print('[REGISTER] Sending request...');
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      print('[REGISTER] Response status code: ${response.statusCode}');
      print('[REGISTER] Response body: ${response.body}');

      final responseData = json.decode(response.body);

      if (response.statusCode == 201) {
        print('[REGISTER] Successfully created user');

        if (isAppUserRegister) {
          if (responseData['token'] == null || responseData['user']?['id'] == null) {
            print('[REGISTER] ERROR: Missing token or user ID in response');
            throw Exception('Invalid response format');
          }

          print('[REGISTER] Storing auth details...');
          await _storage.storeAuthDetails(
            responseData['token'],
            responseData['user']['id'].toString(),
          );
          print('[REGISTER] Successfully stored auth details');
        }
        return responseData['user'];
      }

      print('[REGISTER] ERROR: Failed with message: ${responseData['msg']}');
      throw Exception(responseData['msg'] ?? 'Registration failed');
    } catch (e) {
      print('[REGISTER] ERROR: Exception occurred: $e');
      if (e is FormatException) {
        throw Exception('Invalid response format');
      }
      rethrow;
    }
  }

  Future<void> logout() async {
    print('[LOGOUT] Clearing stored data...');
    await _storage.clearAll();
    print('[LOGOUT] Successfully cleared all stored data');
  }

  Future<bool> isAuthenticated() async {
    final result = await _storage.isAuthenticated();
    print('[AUTH] Authentication status: ${result ? 'authenticated' : 'not authenticated'}');
    return result;
  }

  Future<String?> getAuthToken() async {
    final token = await _storage.getAuthToken();
    print('[AUTH] Token status: ${token != null ? 'retrieved' : 'not found'}');
    return token;
  }

  Future<String?> getUserId() async {
    final userId = await _storage.getUserId();
    print('[AUTH] User ID status: ${userId != null ? 'retrieved' : 'not found'}');
    return userId;
  }
}