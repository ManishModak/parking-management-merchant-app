import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../models/plaza.dart';
import '../../config/api_config.dart';
import '../../utils/exceptions.dart';
import '../network/connectivity_service.dart';
import '../storage/secure_storage_service.dart';

class PlazaService {
  final http.Client _client;
  final ConnectivityService _connectivityService;
  final SecureStorageService _secureStorageService;
  final String baseUrl = ApiConfig.baseUrl;

  /// Constructor with dependency injection for http.Client, ConnectivityService, and SecureStorageService
  PlazaService({
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

  /// Fetches plazas for a given user by userId.
  Future<List<Plaza>> fetchUserPlazas(String userId) async {
    if (!(await _connectivityService.isConnected())) {
      throw NoInternetException(
          'No internet connection. Please check your network settings.');
    }

    final fullUrl = '${ApiConfig.getFullUrl(PlazaApi.getByOwnerId)}$userId';
    final serverUrl = Uri.parse(fullUrl);

    if (!(await _connectivityService.canReachServer(serverUrl.host))) {
      developer.log('[PLAZA] Server unreachable: ${serverUrl.host}',
          name: 'PlazaService');
      throw ServerConnectionException(
          'Cannot reach the plaza server. The server may be down or unreachable.',
          host: serverUrl.host);
    }

    developer.log(
        '[PLAZA] Fetching user plazas at URL: $fullUrl', name: 'PlazaService');
    developer.log('[PLAZA] User ID: $userId', name: 'PlazaService');

    try {
      final response = await _client
          .get(
        Uri.parse(fullUrl),
        headers: await _getHeaders(),
      )
          .timeout(const Duration(seconds: 10));

      developer.log('[PLAZA] Response Status Code: ${response.statusCode}',
          name: 'PlazaService');
      developer.log(
          '[PLAZA] Response Body: ${response.body}', name: 'PlazaService');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        developer.log(
            '[PLAZA] Decoded response: $responseData', name: 'PlazaService');

        if (responseData['success'] == true) {
          final List<dynamic> plazaJson = responseData['plazas'];
          developer.log(
              '[PLAZA] Found ${plazaJson.length} plazas', name: 'PlazaService');

          final plazas = plazaJson.map((json) => Plaza.fromJson(json)).toList();
          developer.log(
              '[PLAZA] Successfully converted plazas', name: 'PlazaService');
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
    } on SocketException catch (e) {
      developer.log('[PLAZA] Socket exception: $e', name: 'PlazaService');
      throw ServerConnectionException(
          'Failed to connect to the plaza server. The server may be temporarily unavailable.');
    } on TimeoutException {
      throw RequestTimeoutException(
          'The server is taking too long to respond. Please try again later.');
    } catch (e, stackTrace) {
      developer.log('[PLAZA] Error in fetchUserPlazas: $e',
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

    final fullUrl = '${ApiConfig.getFullUrl(PlazaApi.get)}$plazaId';
    final serverUrl = Uri.parse(fullUrl);

    if (!(await _connectivityService.canReachServer(serverUrl.host))) {
      developer.log('[PLAZA] Server unreachable: ${serverUrl.host}',
          name: 'PlazaService');
      throw ServerConnectionException(
          'Cannot reach the plaza server. The server may be down or unreachable.',
          host: serverUrl.host);
    }

    developer.log(
        '[PLAZA] Getting plaza by ID at URL: $fullUrl', name: 'PlazaService');
    developer.log('[PLAZA] Plaza ID: $plazaId', name: 'PlazaService');

    try {
      final response = await _client
          .get(
        Uri.parse(fullUrl),
        headers: await _getHeaders(),
      )
          .timeout(const Duration(seconds: 10));

      developer.log('[PLAZA] Response Status Code: ${response.statusCode}',
          name: 'PlazaService');
      developer.log(
          '[PLAZA] Response Body: ${response.body}', name: 'PlazaService');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['plaza'] != null) {
          developer.log('[PLAZA] Plaza found and converted successfully',
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
    } on SocketException catch (e) {
      developer.log('[PLAZA] Socket exception: $e', name: 'PlazaService');
      throw ServerConnectionException(
          'Failed to connect to the plaza server. The server may be temporarily unavailable.');
    } on TimeoutException {
      throw RequestTimeoutException(
          'The server is taking too long to respond. Please try again later.');
    } catch (e, stackTrace) {
      developer.log('[PLAZA] Error in getPlazaById: $e',
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

    final fullUrl = ApiConfig.getFullUrl(PlazaApi.create);
    final serverUrl = Uri.parse(fullUrl);

    if (!(await _connectivityService.canReachServer(serverUrl.host))) {
      developer.log('[PLAZA] Server unreachable: ${serverUrl.host}',
          name: 'PlazaService');
      throw ServerConnectionException(
          'Cannot reach the plaza server. The server may be down or unreachable.',
          host: serverUrl.host);
    }

    final body = json.encode(plaza.toJson());
    developer.log(
        '[PLAZA] Creating plaza at URL: $fullUrl', name: 'PlazaService');
    developer.log('[PLAZA] Request Body: $body', name: 'PlazaService');

    try {
      final response = await _client
          .post(
        Uri.parse(fullUrl),
        headers: await _getHeaders(),
        body: body,
      )
          .timeout(const Duration(seconds: 10));

      developer.log('[PLAZA] Response Status Code: ${response.statusCode}',
          name: 'PlazaService');
      developer.log(
          '[PLAZA] Response Body: ${response.body}', name: 'PlazaService');

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
        developer.log(
            '[PLAZA] Plaza created successfully: ${responseBody['plaza']['plazaId']}',
            name: 'PlazaService');
        return responseBody['plaza']['plazaId'].toString();
      }
      throw PlazaException('Plaza creation failed: ${responseBody['msg']}');
    } on SocketException catch (e) {
      developer.log('[PLAZA] Socket exception: $e', name: 'PlazaService');
      throw ServerConnectionException(
          'Failed to connect to the plaza server. The server may be temporarily unavailable.');
    } on TimeoutException {
      throw RequestTimeoutException(
          'The server is taking too long to respond. Please try again later.');
    } catch (e, stackTrace) {
      developer.log('[PLAZA] Error in addPlaza: $e',
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

    final fullUrl = '${ApiConfig.getFullUrl(PlazaApi.update)}$plazaId';
    final serverUrl = Uri.parse(fullUrl);

    if (!(await _connectivityService.canReachServer(serverUrl.host))) {
      developer.log('[PLAZA] Server unreachable: ${serverUrl.host}',
          name: 'PlazaService');
      throw ServerConnectionException(
          'Cannot reach the plaza server. The server may be down or unreachable.',
          host: serverUrl.host);
    }

    final body = json.encode(plaza.toJson());
    developer.log(
        '[PLAZA] Updating plaza at URL: $fullUrl', name: 'PlazaService');
    developer.log('[PLAZA] Plaza ID: $plazaId', name: 'PlazaService');
    developer.log('[PLAZA] Request Body: $body', name: 'PlazaService');

    try {
      final response = await _client
          .put(
        Uri.parse(fullUrl),
        headers: await _getHeaders(),
        body: body,
      )
          .timeout(const Duration(seconds: 10));

      developer.log('[PLAZA] Response Status Code: ${response.statusCode}',
          name: 'PlazaService');
      developer.log(
          '[PLAZA] Response Body: ${response.body}', name: 'PlazaService');

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
      developer.log('[PLAZA] Plaza updated successfully', name: 'PlazaService');
      return true;
    } on SocketException catch (e) {
      developer.log('[PLAZA] Socket exception: $e', name: 'PlazaService');
      throw ServerConnectionException(
          'Failed to connect to the plaza server. The server may be temporarily unavailable.');
    } on TimeoutException {
      throw RequestTimeoutException(
          'The server is taking too long to respond. Please try again later.');
    } catch (e, stackTrace) {
      developer.log('[PLAZA] Error in updatePlaza: $e',
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

    final fullUrl = '${ApiConfig.getFullUrl(PlazaApi.delete)}$plazaId';
    final serverUrl = Uri.parse(fullUrl);

    if (!(await _connectivityService.canReachServer(serverUrl.host))) {
      developer.log('[PLAZA] Server unreachable: ${serverUrl.host}',
          name: 'PlazaService');
      throw ServerConnectionException(
          'Cannot reach the plaza server. The server may be down or unreachable.',
          host: serverUrl.host);
    }

    developer.log(
        '[PLAZA] Deleting plaza at URL: $fullUrl', name: 'PlazaService');
    developer.log('[PLAZA] Plaza ID: $plazaId', name: 'PlazaService');

    try {
      final response = await _client
          .delete(
        Uri.parse(fullUrl),
        headers: await _getHeaders(),
      )
          .timeout(const Duration(seconds: 10));

      developer.log('[PLAZA] Response Status Code: ${response.statusCode}',
          name: 'PlazaService');
      developer.log(
          '[PLAZA] Response Body: ${response.body}', name: 'PlazaService');

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
      developer.log('[PLAZA] Plaza deleted successfully', name: 'PlazaService');
    } on SocketException catch (e) {
      developer.log('[PLAZA] Socket exception: $e', name: 'PlazaService');
      throw ServerConnectionException(
          'Failed to connect to the plaza server. The server may be temporarily unavailable.');
    } on TimeoutException {
      throw RequestTimeoutException(
          'The server is taking too long to respond. Please try again later.');
    } catch (e, stackTrace) {
      developer.log('[PLAZA] Error in deletePlaza: $e',
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

    final fullUrl = ApiConfig.getFullUrl(PlazaApi.getAllOwners);
    final serverUrl = Uri.parse(fullUrl);

    if (!(await _connectivityService.canReachServer(serverUrl.host))) {
      developer.log('[PLAZA] Server unreachable: ${serverUrl.host}',
          name: 'PlazaService');
      throw ServerConnectionException(
          'Cannot reach the plaza server. The server may be down or unreachable.',
          host: serverUrl.host);
    }

    developer.log('[PLAZA] Fetching all plaza owners at URL: $fullUrl',
        name: 'PlazaService');

    try {
      final response = await _client
          .get(
        Uri.parse(fullUrl),
        headers: await _getHeaders(),
      )
          .timeout(const Duration(seconds: 10));

      developer.log('[PLAZA] Response Status Code: ${response.statusCode}',
          name: 'PlazaService');
      developer.log(
          '[PLAZA] Response Body: ${response.body}', name: 'PlazaService');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['owners'] != null) {
          final owners = List<String>.from(responseData['owners']);
          developer.log(
              '[PLAZA] Successfully retrieved ${owners.length} plaza owners',
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
    } on SocketException catch (e) {
      developer.log('[PLAZA] Socket exception: $e', name: 'PlazaService');
      throw ServerConnectionException(
          'Failed to connect to the plaza server. The server may be temporarily unavailable.');
    } on TimeoutException {
      throw RequestTimeoutException(
          'The server is taking too long to respond. Please try again later.');
    } catch (e, stackTrace) {
      developer.log('[PLAZA] Error in getAllPlazaOwners: $e',
          name: 'PlazaService', error: e, stackTrace: stackTrace);
      throw PlazaException('Error fetching plaza owners: $e');
    }
  }
}