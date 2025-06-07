// lib/services/notification_api_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;
import 'package:merchant_app/utils/exceptions.dart';

import '../../config/api_config.dart';
import '../storage/secure_storage_service.dart'; // Assuming you have this

class NotificationApiService {
  final http.Client _client;
  final SecureStorageService _secureStorageService; // Add this

  NotificationApiService({
    http.Client? client,
    SecureStorageService? secureStorageService, // Add to constructor
  })  : _client = client ?? http.Client(),
        _secureStorageService = secureStorageService ?? SecureStorageService(); // Initialize

  Future<Map<String, String>> _getHeaders() async {
    final token = await _secureStorageService.getAuthToken(); // Use the service
    if (token == null) {
      developer.log('Auth token is null. API calls may fail.', name: 'NotificationApiService');
      // Depending on your app's logic, you might throw an UnauthenticatedException here
      // or proceed, letting the server return a 401.
    }
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Helper for error handling (copied from your TicketService for consistency)
  HttpException _handleErrorResponse(http.Response response, String defaultMessage) {
    String? serverMessage;
    try {
      final errorData = json.decode(response.body);
      serverMessage = errorData['message'] as String?;
    } catch (_) {
      serverMessage = null;
    }
    developer.log(
        '[NOTIFICATION_API_SERVICE] Error: $defaultMessage, Status: ${response.statusCode}, Server Msg: $serverMessage, Body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}',
        name: 'NotificationApiService');
    return HttpException(
      defaultMessage,
      statusCode: response.statusCode,
      serverMessage: serverMessage ?? 'Unknown server error. Status: ${response.statusCode}',
    );
  }


  Future<bool> markNotificationAsRead(String notificationId) async {
    final url = Uri.parse(NotificationApi.markAsRead(notificationId));
    developer.log('API MarkAsRead: $url', name: 'NotificationApiService');
    try {
      final headers = await _getHeaders();
      final response = await _client.patch(
        url,
        headers: headers,
      ).timeout(ApiConfig.defaultTimeout);

      if (response.statusCode == 200) {
        developer.log('Notification $notificationId marked as read via API.', name: 'NotificationApiService');
        return true;
      } else if (response.statusCode == 401) {
        throw UnauthenticatedException('Authentication failed. Please log in again.');
      }
      throw _handleErrorResponse(response, 'Failed to mark notification as read');
    } on UnauthenticatedException { // Propagate unauthenticated exception
      rethrow;
    } on TimeoutException {
      throw RequestTimeoutException('Request to mark notification as read timed out.');
    } catch (e) {
      developer.log('Error marking notification as read: $e', name: 'NotificationApiService', error: e);
      if (e is HttpException) rethrow;
      throw ServiceException('An unexpected error occurred while marking notification as read: ${e.toString()}');
    }
  }

  Future<bool> deleteNotification(String notificationId) async {
    final url = Uri.parse(NotificationApi.delete(notificationId));
    developer.log('API DeleteNotification: $url', name: 'NotificationApiService');
    try {
      final headers = await _getHeaders();
      final response = await _client.delete(
        url,
        headers: headers,
      ).timeout(ApiConfig.defaultTimeout);

      if (response.statusCode == 200) {
        developer.log('Notification $notificationId deleted via API.', name: 'NotificationApiService');
        return true;
      } else if (response.statusCode == 401) {
        throw UnauthenticatedException('Authentication failed. Please log in again.');
      }
      throw _handleErrorResponse(response, 'Failed to delete notification');
    } on UnauthenticatedException {
      rethrow;
    } on TimeoutException {
      throw RequestTimeoutException('Request to delete notification timed out.');
    } catch (e) {
      developer.log('Error deleting notification: $e', name: 'NotificationApiService', error: e);
      if (e is HttpException) rethrow;
      throw ServiceException('An unexpected error occurred while deleting notification: ${e.toString()}');
    }
  }

  Future<bool> markAllNotificationsAsRead(String userId) async {
    final url = Uri.parse(NotificationApi.markAllAsRead(userId));
    developer.log('API MarkAllAsRead for user $userId: $url', name: 'NotificationApiService');
    try {
      final headers = await _getHeaders();
      final response = await _client.patch(
        url,
        headers: headers,
      ).timeout(ApiConfig.defaultTimeout);

      if (response.statusCode == 200) {
        developer.log('All notifications for user $userId marked as read via API.', name: 'NotificationApiService');
        return true;
      } else if (response.statusCode == 401) {
        throw UnauthenticatedException('Authentication failed. Please log in again.');
      }
      throw _handleErrorResponse(response, 'Failed to mark all notifications as read');
    } on UnauthenticatedException {
      rethrow;
    } on TimeoutException {
      throw RequestTimeoutException('Request to mark all notifications as read timed out.');
    } catch (e) {
      developer.log('Error marking all notifications as read: $e', name: 'NotificationApiService', error: e);
      if (e is HttpException) rethrow;
      throw ServiceException('An unexpected error occurred while marking all notifications as read: ${e.toString()}');
    }
  }
}