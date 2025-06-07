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

  Future<BookingStats> getPlazaBookings({
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

    developer.log('[DASHBOARD] Fetching plaza bookings at URL: $url with params: $queryParams', name: 'DashboardService');

    try {
      final response = await _client.get(
        serverUrl,
        headers: {'Content-Type': 'application/json'},
      ).timeout(ApiConfig.defaultTimeout);

      developer.log('[DASHBOARD] Response Status Code: ${response.statusCode}', name: 'DashboardService');
      developer.log('[DASHBOARD] Response Body: ${response.body}', name: 'DashboardService');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          final dashboardStats = DashboardStats.fromJson(responseData);
          developer.log('[DASHBOARD] Parsed DashboardStats: $dashboardStats', name: 'DashboardService');
          final validationError = dashboardStats.validate();
          if (validationError != null) {
            throw ServiceException('Invalid plaza booking data: $validationError');
          }
          final bookingStats = BookingStats(
            totalBookings: dashboardStats.totalBookings ?? 0,
            reserved: dashboardStats.reservedBookings ?? 0,
            cancelled: dashboardStats.cancelledBookings ?? 0,
            noShow: dashboardStats.noShowBookings ?? 0,
            percentageChange: dashboardStats.percentageChange ?? 0.0,
          );
          final bookingValidationError = bookingStats.validate();
          if (bookingValidationError != null) {
            throw ServiceException('Invalid booking stats: $bookingValidationError');
          }
          developer.log('[DASHBOARD] Successfully retrieved plaza booking stats: $bookingStats', name: 'DashboardService');
          return bookingStats;
        }
        developer.log('[DASHBOARD] No data in response, returning default BookingStats', name: 'DashboardService');
        return BookingStats(
          totalBookings: 0,
          reserved: 0,
          cancelled: 0,
          noShow: 0,
          percentageChange: 0.0,
        );
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

    developer.log('[DASHBOARD] Fetching plaza details at URL: $url with params: $queryParams', name: 'DashboardService');

    try {
      final response = await _client.get(
        serverUrl,
        headers: {'Content-Type': 'application/json'},
      ).timeout(ApiConfig.defaultTimeout);

      developer.log('[DASHBOARD] Response Status Code: ${response.statusCode}', name: 'DashboardService');
      developer.log('[DASHBOARD] Response Body: ${response.body}', name: 'DashboardService');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['plazas'] != null || responseData['totalPlazas'] != null) {
          final stats = DashboardStats.fromJson(responseData);
          developer.log('[DASHBOARD] Parsed DashboardStats: $stats', name: 'DashboardService');
          final validationError = stats.validate();
          if (validationError != null) {
            throw ServiceException('Invalid plaza details data: $validationError');
          }
          developer.log('[DASHBOARD] Successfully retrieved plaza details: $stats', name: 'DashboardService');
          return stats;
        }
        throw ServiceException('No plaza details found: ${responseData['message'] ?? 'Unknown error'}');
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

  Future<TicketStats> getTicketCollectionStats({
    String frequency = 'daily',
    String? plazaOwnerId,
    String? plazaId,
  }) async {
    final queryParams = {
      'frequency': frequency,
      if (plazaOwnerId != null) 'plazaOwnerId': plazaOwnerId,
      if (plazaId != null) 'plazaId': plazaId,
    };
    final url = Uri.parse(ApiConfig.getFullUrl(DashboardApi.getTicketCollectionStats))
        .replace(queryParameters: queryParams);
    final serverUrl = url;

    if (!(await _connectivityService.isConnected())) {
      throw NoInternetException('No internet connection. Please check your network settings.');
    }
    if (!(await _connectivityService.canReachServer(serverUrl.host))) {
      throw ServerConnectionException('Cannot reach the dashboard server.', host: serverUrl.host);
    }

    developer.log('[DASHBOARD] Fetching ticket collection stats at URL: $url with params: $queryParams', name: 'DashboardService');

    try {
      final response = await _client.get(
        serverUrl,
        headers: {'Content-Type': 'application/json'},
      ).timeout(ApiConfig.defaultTimeout);

      developer.log('[DASHBOARD] Response Status Code: ${response.statusCode}', name: 'DashboardService');
      developer.log('[DASHBOARD] Response Body: ${response.body}', name: 'DashboardService');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          final stats = TicketStats.fromJson(responseData);
          developer.log('[DASHBOARD] Parsed TicketStats: $stats', name: 'DashboardService');
          final validationError = stats.validate();
          if (validationError != null) {
            throw ServiceException('Invalid ticket collection stats data: $validationError');
          }
          developer.log('[DASHBOARD] Successfully retrieved ticket collection stats: $stats', name: 'DashboardService');
          return stats;
        }
        throw ServiceException('No ticket collection stats found: ${responseData['message'] ?? 'Unknown error'}');
      }

      throw _handleErrorResponse(response, 'Failed to fetch ticket collection stats');
    } on SocketException catch (e) {
      throw ServerConnectionException('Failed to connect to the dashboard server: $e');
    } on TimeoutException {
      throw RequestTimeoutException('Request timed out');
    } catch (e, stackTrace) {
      developer.log('[DASHBOARD] Error in getTicketCollectionStats: $e',
          name: 'DashboardService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<TicketOverview> getTicketOverview({
    String frequency = 'daily',
    String? plazaOwnerId,
    String? plazaId,
  }) async {
    final queryParams = {
      'frequency': frequency,
      if (plazaOwnerId != null) 'plazaOwnerId': plazaOwnerId,
      if (plazaId != null) 'plazaId': plazaId,
    };
    final url = Uri.parse(ApiConfig.getFullUrl(DashboardApi.getTicketOverview))
        .replace(queryParameters: queryParams);
    final serverUrl = url;

    if (!(await _connectivityService.isConnected())) {
      throw NoInternetException('No internet connection. Please check your network settings.');
    }
    if (!(await _connectivityService.canReachServer(serverUrl.host))) {
      throw ServerConnectionException('Cannot reach the dashboard server.', host: serverUrl.host);
    }

    developer.log('[DASHBOARD] Fetching ticket overview at URL: $url with params: $queryParams',
        name: 'DashboardService');

    try {
      final response = await _client.get(
        serverUrl,
        headers: {'Content-Type': 'application/json'},
      ).timeout(ApiConfig.defaultTimeout);

      developer.log('[DASHBOARD] Response Status Code: ${response.statusCode}', name: 'DashboardService');
      developer.log('[DASHBOARD] Response Body: ${response.body}', name: 'DashboardService');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['totalStats'] != null) {
          final overview = TicketOverview.fromJson(responseData['totalStats']).copyWith(
            plazas: (responseData['data'] as List<dynamic>?)
                ?.map((p) => PlazaTicketOverview.fromJson(p as Map<String, dynamic>))
                .toList(),
          );
          developer.log('[DASHBOARD] Parsed TicketOverview: $overview', name: 'DashboardService');
          final validationError = overview.validate();
          if (validationError != null) {
            throw ServiceException('Invalid ticket overview data: $validationError');
          }
          developer.log('[DASHBOARD] Successfully retrieved ticket overview: $overview',
              name: 'DashboardService');
          return overview;
        }
        throw ServiceException('No ticket overview found: ${responseData['message'] ?? 'Unknown error'}');
      }

      throw _handleErrorResponse(response, 'Failed to fetch ticket overview');
    } on SocketException catch (e) {
      throw ServerConnectionException('Failed to connect to the dashboard server: $e');
    } on TimeoutException {
      throw RequestTimeoutException('Request timed out');
    } catch (e, stackTrace) {
      developer.log('[DASHBOARD] Error in getTicketOverview: $e',
          name: 'DashboardService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<DisputeSummary> getDisputeSummary({
    String frequency = 'daily',
    String? plazaOwnerId,
    String? plazaId,
  }) async {
    final queryParams = {
      'frequency': frequency,
      if (plazaOwnerId != null) 'plazaOwnerId': plazaOwnerId,
      if (plazaId != null) 'plazaId': plazaId,
    };
    final url = Uri.parse(ApiConfig.getFullUrl(DashboardApi.getDisputeSummary))
        .replace(queryParameters: queryParams);
    final serverUrl = url;

    if (!(await _connectivityService.isConnected())) {
      throw NoInternetException('No internet connection. Please check your network settings.');
    }
    if (!(await _connectivityService.canReachServer(serverUrl.host))) {
      throw ServerConnectionException('Cannot reach the dashboard server.', host: serverUrl.host);
    }

    developer.log('[DASHBOARD] Fetching dispute summary at URL: $url with params: $queryParams', name: 'DashboardService');

    try {
      final response = await _client.get(
        serverUrl,
        headers: {'Content-Type': 'application/json'},
      ).timeout(ApiConfig.defaultTimeout);

      developer.log('[DASHBOARD] Response Status Code: ${response.statusCode}', name: 'DashboardService');
      developer.log('[DASHBOARD] Response Body: ${response.body}', name: 'DashboardService');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['summary'] != null) {
          final summary = DisputeSummary.fromJson(responseData);
          developer.log('[DASHBOARD] Parsed DisputeSummary: $summary', name: 'DashboardService');
          final validationError = summary.validate();
          if (validationError != null) {
            throw ServiceException('Invalid dispute summary data: $validationError');
          }
          developer.log('[DASHBOARD] Successfully retrieved dispute summary: $summary', name: 'DashboardService');
          return summary;
        }
        throw ServiceException('No dispute summary found: ${responseData['message'] ?? 'Unknown error'}');
      }

      throw _handleErrorResponse(response, 'Failed to fetch dispute summary');
    } on SocketException catch (e) {
      throw ServerConnectionException('Failed to connect to the dashboard server: $e');
    } on TimeoutException {
      throw RequestTimeoutException('Request timed out');
    } catch (e, stackTrace) {
      developer.log('[DASHBOARD] Error in getDisputeSummary: $e',
          name: 'DashboardService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<PaymentMethodAnalysis> getPaymentMethodAnalysis({
    String frequency = 'daily',
    String? plazaOwnerId,
    String? plazaId,
  }) async {
    final queryParams = {
      'frequency': frequency,
      if (plazaOwnerId != null) 'plazaOwnerId': plazaOwnerId,
      if (plazaId != null) 'plazaId': plazaId,
    };
    final url = Uri.parse(ApiConfig.getFullUrl(DashboardApi.getPaymentMethodAnalysis))
        .replace(queryParameters: queryParams);
    final serverUrl = url;

    if (!(await _connectivityService.isConnected())) {
      throw NoInternetException('No internet connection. Please check your network settings.');
    }
    if (!(await _connectivityService.canReachServer(serverUrl.host))) {
      throw ServerConnectionException('Cannot reach the dashboard server.', host: serverUrl.host);
    }

    developer.log('[DASHBOARD] Fetching payment method analysis at URL: $url with params: $queryParams', name: 'DashboardService');

    try {
      final response = await _client.get(
        serverUrl,
        headers: {'Content-Type': 'application/json'},
      ).timeout(ApiConfig.defaultTimeout);

      developer.log('[DASHBOARD] Response Status Code: ${response.statusCode}', name: 'DashboardService');
      developer.log('[DASHBOARD] Response Body: ${response.body}', name: 'DashboardService');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['summary'] != null) {
          final analysis = PaymentMethodAnalysis.fromJson(responseData);
          developer.log('[DASHBOARD] Parsed PaymentMethodAnalysis: $analysis', name: 'DashboardService');
          final validationError = analysis.validate();
          if (validationError != null) {
            throw ServiceException('Invalid payment method analysis data: $validationError');
          }
          developer.log('[DASHBOARD] Successfully retrieved payment method analysis: $analysis', name: 'DashboardService');
          return analysis;
        }
        throw ServiceException('No payment method analysis found: ${responseData['message'] ?? 'Unknown error'}');
      }

      throw _handleErrorResponse(response, 'Failed to fetch payment method analysis');
    } on SocketException catch (e) {
      throw ServerConnectionException('Failed to connect to the dashboard server: $e');
    } on TimeoutException {
      throw RequestTimeoutException('Request timed out');
    } catch (e, stackTrace) {
      developer.log('[DASHBOARD] Error in getPaymentMethodAnalysis: $e',
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