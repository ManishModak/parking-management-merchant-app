import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../../models/dashboard.dart';
import '../../utils/exceptions.dart';
import '../network/connectivity_service.dart';

class DashboardService {
  final http.Client _client;
  final ConnectivityService _connectivityService;

  DashboardService({
    http.Client? client,
    ConnectivityService? connectivityService,
  })  : _client = client ?? http.Client(),
        _connectivityService = connectivityService ?? ConnectivityService();

  Future<List<DashboardStats>> getPlazaBookings({
    String frequency = 'daily',
    String? plazaOwnerId,
    String? plazaId,
  }) async {
    final queryParams = {
      'frequency': frequency,
      if (plazaOwnerId != null) 'plazaOwnerId': plazaOwnerId,
      if (plazaId != null) 'plazaId': plazaId,
    };
    final url = Uri.parse(ApiConfig.getFullUrl(DashboardApi.getPlazaBookings)).replace(queryParameters: queryParams);
    final serverUrl = url;

    if (!(await _connectivityService.isConnected())) {
      throw NoInternetException('No internet connection. Please check your network settings.');
    }
    if (!(await _connectivityService.canReachServer(serverUrl.host))) {
      throw ServerConnectionException('Cannot reach the dashboard server.', host: serverUrl.host);
    }

    developer.log('[DASHBOARD] Fetching plaza bookings at URL: $url', name: 'DashboardService');

    try {
      final response = await _client.get(
        serverUrl,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      developer.log('[DASHBOARD] Response Status Code: ${response.statusCode}', name: 'DashboardService');
      developer.log('[DASHBOARD] Response Body: ${response.body}', name: 'DashboardService');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          final List<DashboardStats> stats = (responseData['data'] as List)
              .map((statsJson) => DashboardStats.fromJson(statsJson))
              .toList();
          for (var stat in stats) {
            final validationError = stat.validate();
            if (validationError != null) {
              throw ServiceException('Invalid plaza booking data: $validationError');
            }
          }
          developer.log('[DASHBOARD] Successfully retrieved ${stats.length} plaza booking stats', name: 'DashboardService');
          return stats;
        }
        developer.log('[DASHBOARD] No data in response, returning empty list', name: 'DashboardService');
        return [];
      }

      throw _handleErrorResponse(response, 'Failed to fetch plaza bookings');
    } on SocketException catch (e) {
      throw ServerConnectionException('Failed to connect to the dashboard server: $e');
    } on TimeoutException {
      throw RequestTimeoutException('Request timed out');
    } catch (e, stackTrace) {
      developer.log('[DASHBOARD] Error in getPlazaBookings: $e',
          name: 'DashboardService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<DashboardStats> getPlazaDetails({
    String frequency = 'daily',
    String? ownerId,
    String? plazaId,
  }) async {
    final queryParams = {
      'frequency': frequency,
      if (ownerId != null) 'ownerId': ownerId,
      if (plazaId != null) 'plazaId': plazaId,
    };
    final url = Uri.parse(ApiConfig.getFullUrl(DashboardApi.getPlazaDetails)).replace(queryParameters: queryParams);
    final serverUrl = url;

    if (!(await _connectivityService.isConnected())) {
      throw NoInternetException('No internet connection. Please check your network settings.');
    }
    if (!(await _connectivityService.canReachServer(serverUrl.host))) {
      throw ServerConnectionException('Cannot reach the dashboard server.', host: serverUrl.host);
    }

    developer.log('[DASHBOARD] Fetching plaza details at URL: $url', name: 'DashboardService');

    try {
      final response = await _client.get(
        serverUrl,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      developer.log('[DASHBOARD] Response Status Code: ${response.statusCode}', name: 'DashboardService');
      developer.log('[DASHBOARD] Response Body: ${response.body}', name: 'DashboardService');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['plazas'] != null) {
          final stats = DashboardStats.fromJson(responseData);
          final validationError = stats.validate();
          if (validationError != null) {
            throw ServiceException('Invalid plaza details data: $validationError');
          }
          developer.log('[DASHBOARD] Successfully retrieved plaza details', name: 'DashboardService');
          return stats;
        }
        throw ServiceException('No plaza details found');
      }

      throw _handleErrorResponse(response, 'Failed to fetch plaza details');
    } on SocketException catch (e) {
      throw ServerConnectionException('Failed to connect to the dashboard server: $e');
    } on TimeoutException {
      throw RequestTimeoutException('Request timed out');
    } catch (e, stackTrace) {
      developer.log('[DASHBOARD] Error in getPlazaDetails: $e',
          name: 'DashboardService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  HttpException _handleErrorResponse(http.Response response, String defaultMessage) {
    String? serverMessage;
    try {
      final errorData = json.decode(response.body);
      serverMessage = errorData['message'] as String?;
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