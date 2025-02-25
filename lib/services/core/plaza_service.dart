import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../../models/plaza.dart';
import '../../config/api_config.dart';
import '../../utils/exceptions.dart';
import '../network/connectivity_service.dart';

class PlazaService {
  final http.Client _client;
  final ConnectivityService _connectivityService;
  final String baseUrl = ApiConfig.apiGateway;

  /// Constructor with dependency injection for http.Client and ConnectivityService
  PlazaService({http.Client? client, ConnectivityService? connectivityService})
      : _client = client ?? http.Client(),
        _connectivityService = connectivityService ?? ConnectivityService();

  /// Fetches plazas for a given user by userId.
  Future<List<Plaza>> fetchUserPlazas(String userId) async {
    if (!(await _connectivityService.isConnected())) {
      throw NoInternetException(
          'No internet connection. Please check your network settings.');
    }

    final fullUrl =
        '${ApiConfig.getFullUrl(ApiConfig.getPlazaByOwnerIdEndpoint)}$userId';
    log('[PLAZA] Fetching user plazas at URL: $fullUrl', name: 'PlazaService');
    log('[PLAZA] User ID: $userId', name: 'PlazaService');

    try {
      final response = await _client
          .get(
        Uri.parse(fullUrl),
        headers: {'Content-Type': 'application/json'},
      )
          .timeout(const Duration(seconds: 20));

      log('[PLAZA] Response Status Code: ${response.statusCode}',
          name: 'PlazaService');
      log('[PLAZA] Response Body: ${response.body}', name: 'PlazaService');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        log('[PLAZA] Decoded response: $responseData', name: 'PlazaService');

        if (responseData['success'] == true) {
          final List<dynamic> plazaJson = responseData['plazas'];
          log('[PLAZA] Found ${plazaJson.length} plazas', name: 'PlazaService');

          final plazas = plazaJson.map((json) => Plaza.fromJson(json)).toList();
          log('[PLAZA] Successfully converted plazas', name: 'PlazaService');
          return plazas;
        }
        throw HttpException(
          'Invalid response format when fetching plazas',
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
        'Failed to fetch plazas',
        statusCode: response.statusCode,
        serverMessage: serverMessage,
      );
    } on TimeoutException {
      throw RequestTimeoutException(
          'The server is taking too long to respond. Please try again later.');
    } catch (e, stackTrace) {
      log('[PLAZA] Exception in fetchUserPlazas: $e',
          name: 'PlazaService', error: e, stackTrace: stackTrace);
      if (e is HttpException) {
        throw PlazaException(
          'Error fetching plazas',
          statusCode: e.statusCode,
          serverMessage: e.serverMessage,
        );
      }
      throw PlazaException('Error fetching plazas: $e');
    }
  }

  /// Retrieves a single plaza by its ID.
  Future<Plaza> getPlazaById(String plazaId) async {
    if (!(await _connectivityService.isConnected())) {
      throw NoInternetException(
          'No internet connection. Please check your network settings.');
    }

    final fullUrl =
        '${ApiConfig.getFullUrl(ApiConfig.getPlazaEndpoint)}$plazaId';
    log('[PLAZA] Getting plaza by ID at URL: $fullUrl', name: 'PlazaService');
    log('[PLAZA] Plaza ID: $plazaId', name: 'PlazaService');

    try {
      final response = await _client
          .get(
        Uri.parse(fullUrl),
        headers: {'Content-Type': 'application/json'},
      )
          .timeout(const Duration(seconds: 10));

      log('[PLAZA] Response Status Code: ${response.statusCode}',
          name: 'PlazaService');
      log('[PLAZA] Response Body: ${response.body}', name: 'PlazaService');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['plaza'] != null) {
          log('[PLAZA] Plaza found and converted successfully',
              name: 'PlazaService');
          return Plaza.fromJson(responseData['plaza']);
        }
        throw HttpException(
          'Invalid response format when fetching plaza',
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
        'Failed to fetch plaza',
        statusCode: response.statusCode,
        serverMessage: serverMessage,
      );
    } on TimeoutException {
      throw RequestTimeoutException(
          'The server is taking too long to respond. Please try again later.');
    } catch (e, stackTrace) {
      log('[PLAZA] Exception in getPlazaById: $e',
          name: 'PlazaService', error: e, stackTrace: stackTrace);
      throw PlazaException('Error fetching plaza: $e');
    }
  }

  /// Creates a new plaza.
  Future<String> addPlaza(Plaza plaza) async {
    if (!(await _connectivityService.isConnected())) {
      throw NoInternetException(
          'No internet connection. Please check your network settings.');
    }

    final fullUrl = ApiConfig.getFullUrl(ApiConfig.createPlazaEndpoint);
    final body = json.encode(plaza.toJson());
    log('[PLAZA] Creating plaza at URL: $fullUrl', name: 'PlazaService');
    log('[PLAZA] Request Body: $body', name: 'PlazaService');

    try {
      final response = await _client
          .post(
        Uri.parse(fullUrl),
        headers: {'Content-Type': 'application/json'},
        body: body,
      )
          .timeout(const Duration(seconds: 10));

      log('[PLAZA] Response Status Code: ${response.statusCode}',
          name: 'PlazaService');
      log('[PLAZA] Response Body: ${response.body}', name: 'PlazaService');

      if (response.statusCode != 201) {
        String? serverMessage;
        try {
          final errorData = json.decode(response.body);
          serverMessage = errorData['message'] as String?;
        } catch (_) {
          serverMessage = null;
        }
        throw HttpException(
          'Failed to add plaza',
          statusCode: response.statusCode,
          serverMessage: serverMessage,
        );
      }

      final responseBody = json.decode(response.body) as Map<String, dynamic>;
      if (responseBody['success'] == true && responseBody['plaza'] != null) {
        log('[PLAZA] Plaza created successfully: ${responseBody['plaza']['plazaId']}',
            name: 'PlazaService');
        return responseBody['plaza']['plazaId'].toString();
      }
      throw PlazaException('Plaza creation failed: ${responseBody['msg']}');
    } on TimeoutException {
      throw RequestTimeoutException(
          'The server is taking too long to respond. Please try again later.');
    } catch (e, stackTrace) {
      log('[PLAZA] Exception in addPlaza: $e',
          name: 'PlazaService', error: e, stackTrace: stackTrace);
      throw PlazaException('Error adding plaza: $e');
    }
  }

  /// Updates an existing plaza.
  Future<bool> updatePlaza(Plaza plaza, String plazaId) async {
    if (!(await _connectivityService.isConnected())) {
      throw NoInternetException(
          'No internet connection. Please check your network settings.');
    }

    final fullUrl =
        '${ApiConfig.getFullUrl(ApiConfig.updatePlazaEndpoint)}$plazaId';
    final body = json.encode(plaza.toJson());
    log('[PLAZA] Updating plaza at URL: $fullUrl', name: 'PlazaService');
    log('[PLAZA] Plaza ID: $plazaId', name: 'PlazaService');
    log('[PLAZA] Request Body: $body', name: 'PlazaService');

    try {
      final response = await _client
          .put(
        Uri.parse(fullUrl),
        headers: {'Content-Type': 'application/json'},
        body: body,
      )
          .timeout(const Duration(seconds: 10));

      log('[PLAZA] Response Status Code: ${response.statusCode}',
          name: 'PlazaService');
      log('[PLAZA] Response Body: ${response.body}', name: 'PlazaService');

      if (response.statusCode != 200) {
        String? serverMessage;
        try {
          final errorData = json.decode(response.body);
          serverMessage = errorData['message'] as String?;
        } catch (_) {
          serverMessage = null;
        }
        throw HttpException(
          'Failed to update plaza',
          statusCode: response.statusCode,
          serverMessage: serverMessage,
        );
      }
      log('[PLAZA] Plaza updated successfully', name: 'PlazaService');
      return true;
    } on TimeoutException {
      throw RequestTimeoutException(
          'The server is taking too long to respond. Please try again later.');
    } catch (e, stackTrace) {
      log('[PLAZA] Exception in updatePlaza: $e',
          name: 'PlazaService', error: e, stackTrace: stackTrace);
      throw PlazaException('Error updating plaza: $e');
    }
  }

  /// Deletes a plaza by its ID.
  Future<void> deletePlaza(String plazaId) async {
    if (!(await _connectivityService.isConnected())) {
      throw NoInternetException(
          'No internet connection. Please check your network settings.');
    }

    final fullUrl =
        '${ApiConfig.getFullUrl(ApiConfig.deletePlazaEndpoint)}$plazaId';
    log('[PLAZA] Deleting plaza at URL: $fullUrl', name: 'PlazaService');
    log('[PLAZA] Plaza ID: $plazaId', name: 'PlazaService');

    try {
      final response = await _client
          .delete(
        Uri.parse(fullUrl),
        headers: {'Content-Type': 'application/json'},
      )
          .timeout(const Duration(seconds: 10));

      log('[PLAZA] Response Status Code: ${response.statusCode}',
          name: 'PlazaService');
      log('[PLAZA] Response Body: ${response.body}', name: 'PlazaService');

      if (response.statusCode != 200) {
        String? serverMessage;
        try {
          final errorData = json.decode(response.body);
          serverMessage = errorData['message'] as String?;
        } catch (_) {
          serverMessage = null;
        }
        throw HttpException(
          'Failed to delete plaza',
          statusCode: response.statusCode,
          serverMessage: serverMessage,
        );
      }
      log('[PLAZA] Plaza deleted successfully', name: 'PlazaService');
    } on TimeoutException {
      throw RequestTimeoutException(
          'The server is taking too long to respond. Please try again later.');
    } catch (e, stackTrace) {
      log('[PLAZA] Exception in deletePlaza: $e',
          name: 'PlazaService', error: e, stackTrace: stackTrace);
      throw PlazaException('Error deleting plaza: $e');
    }
  }

  /// Retrieves all plaza owners.
  Future<List<String>> getAllPlazaOwners() async {
    if (!(await _connectivityService.isConnected())) {
      throw NoInternetException(
          'No internet connection. Please check your network settings.');
    }

    final fullUrl = ApiConfig.getFullUrl(ApiConfig.getAllPlazaOwnersEndpoint);
    log('[PLAZA] Fetching all plaza owners at URL: $fullUrl',
        name: 'PlazaService');

    try {
      final response = await _client
          .get(
        Uri.parse(fullUrl),
        headers: {'Content-Type': 'application/json'},
      )
          .timeout(const Duration(seconds: 10));

      log('[PLAZA] Response Status Code: ${response.statusCode}',
          name: 'PlazaService');
      log('[PLAZA] Response Body: ${response.body}', name: 'PlazaService');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['owners'] != null) {
          final owners = List<String>.from(responseData['owners']);
          log('[PLAZA] Successfully retrieved ${owners.length} plaza owners',
              name: 'PlazaService');
          return owners;
        }
        throw HttpException(
          'Invalid response format when fetching plaza owners',
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
        'Failed to fetch plaza owners',
        statusCode: response.statusCode,
        serverMessage: serverMessage,
      );
    } on TimeoutException {
      throw RequestTimeoutException(
          'The server is taking too long to respond. Please try again later.');
    } catch (e, stackTrace) {
      log('[PLAZA] Exception in getAllPlazaOwners: $e',
          name: 'PlazaService', error: e, stackTrace: stackTrace);
      throw PlazaException('Error fetching plaza owners: $e');
    }
  }
}

