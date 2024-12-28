import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:merchant_app/config/api_config.dart';
import '../models/user_model.dart';
import './secure_storage_service.dart';

class AuthService {
  final SecureStorageService _storage = SecureStorageService();

  Future<bool> login(String emailOrMobile, String password) async {
    const String url = '${ApiConfig.baseUrl}${ApiConfig.loginEndpoint}';
    final Map<String, String> headers = {'Content-Type': 'application/json'};
    final Map<String, String> body = {
      'emailOrMobile': emailOrMobile,
      'password': password
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );
      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        await _storage.storeAuthDetails(
          responseData['token'],
          responseData['user']['id'].toString(),
        );
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
    required String city,
    required String state,
    required String address,
    required bool isAppUserRegister,
    String? role,
    String? entity,
    String? subEntity,
  }) async {
    const String url = '${ApiConfig.baseUrl}${ApiConfig.registerEndpoint}';
    final Map<String, String> headers = {'Content-Type': 'application/json'};

    final Map<String, dynamic> userData = {
      'username': username,
      'email': email,
      'mobileNumber': mobileNumber,
      'password': password,
      'address': address,
      'state': state,
      'city': city,
      'role': role,
    };

    print(1);
    // Only include role, entity and subEntity if not app register
    if (!isAppUserRegister) {
      if (entity != null) userData['entity'] = entity;
      if (subEntity != null) userData['subEntity'] = subEntity;
    }

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(userData),
      );
      print(response.statusCode);
      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        if(isAppUserRegister) {
          await _storage.storeAuthDetails(
              responseData['token'], responseData['user']['id'].toString());
        }

        return true;
      } else {
        throw Exception(
            jsonDecode(response.body)['msg'] ?? 'Registration failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _storage.clearAll();
  }

  Future<bool> isAuthenticated() async {
    return await _storage.isAuthenticated();
  }

  Future<String?> getAuthToken() async => await _storage.getAuthToken();

  Future<String?> getUserId() async => await _storage.getUserId();
}
