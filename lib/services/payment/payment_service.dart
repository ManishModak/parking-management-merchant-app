import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../../utils/exceptions.dart';
import '../network/connectivity_service.dart';
import '../storage/secure_storage_service.dart';

class PaymentService {
  final http.Client _client;
  final ConnectivityService _connectivityService;
  final SecureStorageService _secureStorageService;
  final String baseUrl = ApiConfig.baseUrl;

  /// Constructor with dependency injection for http.Client, ConnectivityService, and SecureStorageService
  PaymentService({
    http.Client? client,
    ConnectivityService? connectivityService,
    SecureStorageService? secureStorageService,
  })  : _client = client ?? http.Client(),
        _connectivityService = connectivityService ?? ConnectivityService(),
        _secureStorageService = secureStorageService ?? SecureStorageService();

  /// Helper method to get headers with Authorization token
  Future<Map<String, String>> _getHeaders() async {
    final token = await _secureStorageService.getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Creates an order QR code using the /create-order-Qr-code endpoint
  Future<Map<String, dynamic>> createOrderQrCode(String ticketId) async {
    if (!(await _connectivityService.isConnected())) {
      throw NoInternetException(
          'No internet connection. Please check your network settings.');
    }

    final fullUrl = ApiConfig.getFullUrl(TransactionsApi.createOrderQrCode);
    final serverUrl = Uri.parse(fullUrl);

    if (!(await _connectivityService.canReachServer(serverUrl.host))) {
      developer.log('[PAYMENT] Server unreachable: ${serverUrl.host}',
          name: 'PaymentService');
      throw ServerConnectionException(
          'Cannot reach the payment server. The server may be down or unreachable.',
          host: serverUrl.host);
    }

    final body = json.encode({'ticket_id': ticketId});
    developer.log(
        '[PAYMENT] Creating order QR code at URL: $fullUrl', name: 'PaymentService');
    developer.log('[PAYMENT] Ticket ID: $ticketId', name: 'PaymentService');
    developer.log('[PAYMENT] Request Body: $body', name: 'PaymentService');

    try {
      final response = await _client
          .post(
        Uri.parse(fullUrl),
        headers: await _getHeaders(),
        body: body,
      )
          .timeout(const Duration(seconds: 10));

      developer.log('[PAYMENT] Response Status Code: ${response.statusCode}',
          name: 'PaymentService');
      developer.log('[PAYMENT] Response Body: ${response.body}', name: 'PaymentService');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData is Map<String, dynamic> && responseData['success'] == true) {
          developer.log('[PAYMENT] Order QR code created successfully', name: 'PaymentService');
          return responseData;
        }
        throw HttpException(
          'Invalid response format when creating order QR code',
          statusCode: response.statusCode,
        );
      }

      String? serverMessage;
      try {
        final errorData = json.decode(response.body);
        serverMessage = errorData['message'] as String?;
      } catch (_) {
        serverMessage = null;
      }
      throw HttpException(
        'Failed to create order QR code',
        statusCode: response.statusCode,
        serverMessage: serverMessage,
      );
    } on SocketException catch (e) {
      developer.log('[PAYMENT] Socket exception: $e', name: 'PaymentService');
      throw ServerConnectionException(
          'Failed to connect to the payment server. The server may be temporarily unavailable.');
    } on TimeoutException {
      throw RequestTimeoutException(
          'The server is taking too long to respond. Please try again later.');
    } catch (e, stackTrace) {
      developer.log('[PAYMENT] Error in createOrderQrCode: $e',
          name: 'PaymentService', error: e, stackTrace: stackTrace);
      throw PaymentException('Error creating order QR code: $e');
    }
  }
}