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
  // baseUrl is not directly used here, ApiConfig.getFullUrl handles it
  // final String baseUrl = ApiConfig.baseUrl;

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
      developer.log('[PAYMENT_SERVICE] Server unreachable: ${serverUrl.host}',
          name: 'PaymentService.createOrderQrCode');
      throw ServerConnectionException(
          'Cannot reach the payment server. The server may be down or unreachable.',
          host: serverUrl.host);
    }

    final body = json.encode({'ticket_id': ticketId});
    developer.log(
        '[PAYMENT_SERVICE] Creating order QR code at URL: $fullUrl', name: 'PaymentService.createOrderQrCode');
    developer.log('[PAYMENT_SERVICE] Ticket ID: $ticketId', name: 'PaymentService.createOrderQrCode');
    developer.log('[PAYMENT_SERVICE] Request Body: $body', name: 'PaymentService.createOrderQrCode');

    try {
      final response = await _client
          .post(
        Uri.parse(fullUrl),
        headers: await _getHeaders(),
        body: body,
      )
          .timeout(ApiConfig.defaultTimeout); // Using defaultTimeout from ApiConfig

      developer.log('[PAYMENT_SERVICE] QR Code Response Status Code: ${response.statusCode}',
          name: 'PaymentService.createOrderQrCode');
      developer.log('[PAYMENT_SERVICE] QR Code Response Body: ${response.body}', name: 'PaymentService.createOrderQrCode');

      if (response.statusCode == 200 || response.statusCode == 201) { // Allow 201 Created
        final responseData = json.decode(response.body);
        if (responseData is Map<String, dynamic> && responseData['success'] == true) {
          developer.log('[PAYMENT_SERVICE] Order QR code created successfully', name: 'PaymentService.createOrderQrCode');
          return responseData;
        }
        throw HttpException(
          'Invalid response format when creating order QR code: ${response.body}',
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
      developer.log('[PAYMENT_SERVICE] Socket exception (QR Code): $e', name: 'PaymentService.createOrderQrCode');
      throw ServerConnectionException(
          'Failed to connect to the payment server. The server may be temporarily unavailable.');
    } on TimeoutException {
      throw RequestTimeoutException(
          'The server is taking too long to respond. Please try again later.');
    } catch (e, stackTrace) {
      developer.log('[PAYMENT_SERVICE] Error in createOrderQrCode: $e',
          name: 'PaymentService.createOrderQrCode', error: e, stackTrace: stackTrace);
      if (e is HttpException) rethrow;
      throw PaymentException('Error creating order QR code: ${e.toString()}');
    }
  }

  /// Records a cash payment using the /cashpayment endpoint
  Future<Map<String, dynamic>> recordCashPayment(String ticketId) async {
    if (!(await _connectivityService.isConnected())) {
      throw NoInternetException(
          'No internet connection. Please check your network settings.');
    }

    final fullUrl = ApiConfig.getFullUrl(TransactionsApi.recordCashPayment);
    final serverUrl = Uri.parse(fullUrl);

    if (!(await _connectivityService.canReachServer(serverUrl.host))) {
      developer.log('[PAYMENT_SERVICE] Server unreachable: ${serverUrl.host}',
          name: 'PaymentService.recordCashPayment');
      throw ServerConnectionException(
          'Cannot reach the payment server. The server may be down or unreachable.',
          host: serverUrl.host);
    }

    final body = json.encode({'ticket_id': ticketId});
    developer.log(
        '[PAYMENT_SERVICE] Recording cash payment at URL: $fullUrl', name: 'PaymentService.recordCashPayment');
    developer.log('[PAYMENT_SERVICE] Ticket ID: $ticketId', name: 'PaymentService.recordCashPayment');
    developer.log('[PAYMENT_SERVICE] Request Body: $body', name: 'PaymentService.recordCashPayment');

    try {
      final response = await _client
          .post(
        Uri.parse(fullUrl),
        headers: await _getHeaders(),
        body: body,
      )
          .timeout(ApiConfig.defaultTimeout); // Using defaultTimeout from ApiConfig

      developer.log('[PAYMENT_SERVICE] Cash Payment Response Status Code: ${response.statusCode}',
          name: 'PaymentService.recordCashPayment');
      developer.log('[PAYMENT_SERVICE] Cash Payment Response Body: ${response.body}', name: 'PaymentService.recordCashPayment');

      if (response.statusCode == 200 || response.statusCode == 201) { // Allow 201 Created
        final responseData = json.decode(response.body);
        // Backend response: {"success": true, "message": "Cash payment recorded successfully"}
        if (responseData is Map<String, dynamic> && responseData['success'] == true) {
          developer.log('[PAYMENT_SERVICE] Cash payment recorded successfully', name: 'PaymentService.recordCashPayment');
          return responseData; // Contains success and message
        }
        throw HttpException(
          'Invalid response format when recording cash payment: ${response.body}',
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
        'Failed to record cash payment',
        statusCode: response.statusCode,
        serverMessage: serverMessage,
      );
    } on SocketException catch (e) {
      developer.log('[PAYMENT_SERVICE] Socket exception (Cash Payment): $e', name: 'PaymentService.recordCashPayment');
      throw ServerConnectionException(
          'Failed to connect to the payment server. The server may be temporarily unavailable.');
    } on TimeoutException {
      throw RequestTimeoutException(
          'The server is taking too long to respond. Please try again later.');
    } catch (e, stackTrace) {
      developer.log('[PAYMENT_SERVICE] Error in recordCashPayment: $e',
          name: 'PaymentService.recordCashPayment', error: e, stackTrace: stackTrace);
      if (e is HttpException) rethrow;
      throw PaymentException('Error recording cash payment: ${e.toString()}');
    }
  }
}