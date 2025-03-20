import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:merchant_app/config/api_config.dart';
import 'package:merchant_app/utils/exceptions.dart';
import '../network/connectivity_service.dart';
import 'dart:developer' as developer;

class VerificationService {
  final http.Client _client;
  final ConnectivityService _connectivityService;

  VerificationService({
    http.Client? client,
    ConnectivityService? connectivityService,
  })  : _client = client ?? http.Client(),
        _connectivityService = connectivityService ?? ConnectivityService();

  /// Sends an OTP to the provided mobile number via the backend API.
  Future<void> sendOtp(String mobileNumber) async {
    final url = ApiConfig.getFullUrl(AuthApi.mobileVerification);
    final serverUrl = Uri.parse(url);

    // Check network connectivity
    if (!(await _connectivityService.isConnected())) {
      throw NoInternetException('No internet connection.');
    }
    if (!(await _connectivityService.canReachServer(serverUrl.host))) {
      throw ServerConnectionException('Cannot reach the server.', host: serverUrl.host);
    }

    developer.log('[VERIFICATION] Sending OTP to $mobileNumber at URL: $url', name: 'VerificationService');

    final requestData = {'mobileNumber': mobileNumber};
    final body = json.encode(requestData);

    try {
      final response = await _client
          .post(
        serverUrl,
        headers: {'Content-Type': 'application/json'},
        body: body,
      )
          .timeout(const Duration(seconds: 10));

      developer.log('[VERIFICATION] Response Status Code: ${response.statusCode}', name: 'VerificationService');
      developer.log('[VERIFICATION] Response Body: ${response.body}', name: 'VerificationService');

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        developer.log('[VERIFICATION] OTP sent successfully to $mobileNumber', name: 'VerificationService');
        return;
      }

      throw Exception('Failed to send OTP: ${responseData['msg'] ?? 'Unknown error'}');
    } catch (e) {
      developer.log('[VERIFICATION] Error in sendOtp: $e', name: 'VerificationService', error: e);
      rethrow;
    }
  }

  /// Verifies the OTP for the provided mobile number via the backend API.
  Future<VerificationResult> verifyOtp({
    required String mobileNumber,
    required String otp,
  }) async {
    final url = ApiConfig.getFullUrl(AuthApi.verifyOtp);
    final serverUrl = Uri.parse(url);

    // Check network connectivity
    if (!(await _connectivityService.isConnected())) {
      throw NoInternetException('No internet connection.');
    }
    if (!(await _connectivityService.canReachServer(serverUrl.host))) {
      throw ServerConnectionException('Cannot reach the server.', host: serverUrl.host);
    }

    developer.log('[VERIFICATION] Verifying OTP for $mobileNumber at URL: $url', name: 'VerificationService');

    final requestData = {'mobileNumber': mobileNumber, 'otp': otp};
    final body = json.encode(requestData);

    try {
      final response = await _client
          .post(
        serverUrl,
        headers: {'Content-Type': 'application/json'},
        body: body,
      )
          .timeout(const Duration(seconds: 10));

      developer.log('[VERIFICATION] Response Status Code: ${response.statusCode}', name: 'VerificationService');
      developer.log('[VERIFICATION] Response Body: ${response.body}', name: 'VerificationService');

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (responseData['success'] == true) {
          developer.log('[VERIFICATION] OTP verified successfully for $mobileNumber', name: 'VerificationService');
          return VerificationResult(
            success: true,
            message: 'OTP verified successfully!',
          );
        } else {
          return VerificationResult(
            success: false,
            message: responseData['msg'] ?? 'Invalid OTP. Please try again.',
          );
        }
      }

      throw Exception('Failed to verify OTP: ${response.statusCode}');
    } catch (e) {
      developer.log('[VERIFICATION] Error in verifyOtp: $e', name: 'VerificationService', error: e);
      throw Exception('Error verifying OTP: $e');
    }
  }
}

class VerificationResult {
  final bool success;
  final String message;

  VerificationResult({
    required this.success,
    required this.message,
  });
}