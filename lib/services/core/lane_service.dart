import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../models/lane.dart';
import '../../config/api_config.dart';
import '../../utils/exceptions.dart';
import '../network/connectivity_service.dart';
import '../storage/secure_storage_service.dart';

class LaneService {
  final http.Client _client;
  final ConnectivityService _connectivityService;
  final SecureStorageService _secureStorageService;
  final String baseUrl = ApiConfig.baseUrl;

  LaneService({
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

  /// Adds one or more lanes to a plaza.
  /// Uses `toJsonForCreate()` for serialization.
  Future<List<Lane>> addLane(List<Lane> lanes) async {
    final fullUrl = ApiConfig.getFullUrl(PlazaApi.createLane);
    final serverUrl = Uri.parse(fullUrl);

    // --- Connectivity Checks ---
    await _checkConnectivity(serverUrl.host, 'LaneService.addLane');

    developer.log('[LANE SVC] Adding ${lanes.length} lanes at URL: $fullUrl',
        name: 'LaneService.addLane');

    try {
      // --- Validate Lanes Before Sending ---
      for (final lane in lanes) {
        final validationError = lane.validateForCreate();
        if (validationError != null) {
          developer.log(
              '[LANE SVC] Validation failed for a lane during add: $validationError',
              name: 'LaneService.addLane',
              level: 900);
          throw ServiceException(
              'Lane validation failed before sending: $validationError');
        }
        if (lane.laneId != null) {
          developer.log(
              '[LANE SVC] Warning: Lane ID ${lane.laneId} provided for creation. It should be null.',
              name: 'LaneService.addLane',
              level: 800);
        }
      }

      // --- Prepare Request Body ---
      developer.log(
          '[LANE SVC] Preparing request body for ${lanes.length} lanes using toJsonForCreate',
          name: 'LaneService.addLane');
      final laneJsonList = lanes.map((lane) => lane.toJsonForCreate()).toList();
      developer.log(
          '[LANE SVC] Converted ${laneJsonList.length} lanes to JSON for creation',
          name: 'LaneService.addLane');
      final body = json.encode(laneJsonList);
      developer.log(
          '[LANE SVC] Request Body (encoded - truncated): ${body.substring(0, body.length > 500 ? 500 : body.length)}...',
          name: 'LaneService.addLane');

      // --- Make API Call ---
      developer.log('[LANE SVC] Sending POST request to $serverUrl',
          name: 'LaneService.addLane');
      final response = await _client
          .post(
            serverUrl,
            headers: await _getHeaders(),
            body: body,
          )
          .timeout(ApiConfig.longTimeout);

      developer.log('[LANE SVC] Response Status Code: ${response.statusCode}',
          name: 'LaneService.addLane');
      developer.log(
          '[LANE SVC] Response Body (truncated): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}...',
          name: 'LaneService.addLane');

      // --- Process Response ---
      if (response.statusCode == 200 || response.statusCode == 201) {
        developer.log('[LANE SVC] Decoding response body',
            name: 'LaneService.addLane');
        try {
          final responseBody =
              json.decode(response.body) as Map<String, dynamic>;
          developer.log(
              '[LANE SVC] Response success flag: ${responseBody['success']}',
              name: 'LaneService.addLane');

          if (responseBody['success'] == true) {
            if (responseBody['laneData'] != null &&
                responseBody['laneData'] is List) {
              final List<dynamic> createdLanesJson = responseBody['laneData'];
              developer.log(
                  '[LANE SVC] Found ${createdLanesJson.length} lanes in response data',
                  name: 'LaneService.addLane');

              try {
                final List<Lane> createdLanes = createdLanesJson
                    .map((json) => Lane.fromJson(json as Map<String, dynamic>))
                    .toList();
                developer.log(
                    '[LANE SVC] Successfully parsed ${createdLanes.length} lanes from response',
                    name: 'LaneService.addLane');
                return createdLanes;
              } catch (e, stackTrace) {
                developer.log('[LANE SVC] Error parsing created lane data: $e',
                    name: 'LaneService.addLane',
                    error: e,
                    stackTrace: stackTrace,
                    level: 1000);
                throw ServiceException(
                    'Lane creation succeeded, but failed to parse response data.');
              }
            } else {
              developer.log(
                  '[LANE SVC] Missing or invalid "laneData" list in successful response',
                  name: 'LaneService.addLane',
                  level: 1000);
              throw ServiceException(
                  'Lane creation succeeded, but response data format is invalid (expected list)');
            }
          } else {
            final serverMsg = responseBody['msg'] ?? 'Unknown server error';
            developer.log(
                '[LANE SVC] Lane creation failed by server: $serverMsg',
                name: 'LaneService.addLane',
                level: 900);
            throw ServiceException('Lane creation failed: $serverMsg');
          }
        } catch (e, stackTrace) {
          developer.log('[LANE SVC] Error decoding success response JSON: $e',
              name: 'LaneService.addLane',
              error: e,
              stackTrace: stackTrace,
              level: 1000);
          throw ServiceException(
              'Lane creation succeeded (status ${response.statusCode}), but failed to decode response body.');
        }
      } else {
        throw _handleErrorResponse(response, 'Failed to add lanes');
      }
    } on SocketException catch (e) {
      developer.log('[LANE SVC] SocketException: $e',
          name: 'LaneService.addLane', error: e);
      throw ServerConnectionException(
          'Failed to connect to the lane server: ${e.message}');
    } on TimeoutException catch (e) {
      developer.log('[LANE SVC] TimeoutException: $e',
          name: 'LaneService.addLane', error: e);
      throw RequestTimeoutException('Request timed out while adding lanes');
    } catch (e, stackTrace) {
      developer.log('[LANE SVC] Unexpected error: $e',
          name: 'LaneService.addLane',
          error: e,
          stackTrace: stackTrace,
          level: 1000);
      if (e is PlazaException) {
        rethrow;
      }
      throw ServiceException(
          'An unexpected error occurred while adding lanes: ${e.toString()}');
    }
  }

  /// Deletes a lane by its ID.
  Future<bool> deleteLane(String laneId) async {
    final fullUrl = '${ApiConfig.getFullUrl(PlazaApi.updateLane)}/$laneId';
    final serverUrl = Uri.parse(fullUrl);

    await _checkConnectivity(serverUrl.host, 'LaneService.deleteLane');

    developer.log('[LANE SVC] Deleting lane at URL: $fullUrl',
        name: 'LaneService.deleteLane');
    developer.log('[LANE SVC] Lane ID: $laneId',
        name: 'LaneService.deleteLane');

    try {
      developer.log('[LANE SVC] Sending DELETE request to $serverUrl',
          name: 'LaneService.deleteLane');
      final response = await _client
          .delete(
            serverUrl,
            headers: await _getHeaders(),
          )
          .timeout(ApiConfig.defaultTimeout);

      developer.log('[LANE SVC] Response Status Code: ${response.statusCode}',
          name: 'LaneService.deleteLane');
      developer.log('[LANE SVC] Response Body: ${response.body}',
          name: 'LaneService.deleteLane');

      if (response.statusCode == 200) {
        try {
          final responseData =
              json.decode(response.body) as Map<String, dynamic>;
          developer.log(
              '[LANE SVC] Response success flag: ${responseData['success']}',
              name: 'LaneService.deleteLane');
          if (responseData['success'] == true) {
            developer.log('[LANE SVC] Successfully deleted lane ID: $laneId',
                name: 'LaneService.deleteLane');
            return true;
          } else {
            developer.log(
                '[LANE SVC] Delete failed according to server response: ${responseData['msg']}',
                name: 'LaneService.deleteLane');
            return false;
          }
        } catch (e, stackTrace) {
          developer.log('[LANE SVC] Error parsing delete success response: $e',
              name: 'LaneService.deleteLane',
              error: e,
              stackTrace: stackTrace,
              level: 1000);
          throw ServiceException(
              'Delete request succeeded (status 200), but failed to parse response.');
        }
      } else if (response.statusCode == 204) {
        developer.log(
            '[LANE SVC] Successfully deleted lane ID: $laneId (Status 204 No Content)',
            name: 'LaneService.deleteLane');
        return true;
      } else {
        throw _handleErrorResponse(response, 'Failed to delete lane');
      }
    } on SocketException catch (e) {
      developer.log('[LANE SVC] SocketException: $e',
          name: 'LaneService.deleteLane', error: e);
      throw ServerConnectionException(
          'Failed to connect to the lane server: ${e.message}');
    } on TimeoutException catch (e) {
      developer.log('[LANE SVC] TimeoutException: $e',
          name: 'LaneService.deleteLane', error: e);
      throw RequestTimeoutException('Request timed out while deleting lane');
    } catch (e, stackTrace) {
      developer.log('[LANE SVC] Error in deleteLane: $e',
          name: 'LaneService.deleteLane', error: e, stackTrace: stackTrace);
      if (e is PlazaException) rethrow;
      throw ServiceException(
          'An unexpected error occurred during delete: ${e.toString()}');
    }
  }

  /// Toggles the active status of a lane.
  Future<bool> toggleLaneStatus(String laneId, bool isActive) async {
    final fullUrl = '${ApiConfig.getFullUrl(PlazaApi.updateLane)}/$laneId';
    final serverUrl = Uri.parse(fullUrl);

    await _checkConnectivity(serverUrl.host, 'LaneService.toggleLaneStatus');

    developer.log('[LANE SVC] Toggling lane status at URL: $fullUrl',
        name: 'LaneService.toggleLaneStatus');
    developer.log('[LANE SVC] Lane ID: $laneId, New Status: $isActive',
        name: 'LaneService.toggleLaneStatus');

    final body = json.encode({'isActive': isActive});
    developer.log('[LANE SVC] Request Body (encoded): $body',
        name: 'LaneService.toggleLaneStatus');

    try {
      developer.log('[LANE SVC] Sending PUT request to $serverUrl',
          name: 'LaneService.toggleLaneStatus');
      final response = await _client
          .put(
            serverUrl,
            headers: await _getHeaders(),
            body: body,
          )
          .timeout(ApiConfig.defaultTimeout);

      developer.log('[LANE SVC] Response Status Code: ${response.statusCode}',
          name: 'LaneService.toggleLaneStatus');
      developer.log('[LANE SVC] Response Body: ${response.body}',
          name: 'LaneService.toggleLaneStatus');

      if (response.statusCode == 200) {
        try {
          final responseData =
              json.decode(response.body) as Map<String, dynamic>;
          developer.log(
              '[LANE SVC] Response success flag: ${responseData['success']}',
              name: 'LaneService.toggleLaneStatus');
          if (responseData['success'] == true) {
            developer.log(
                '[LANE SVC] Successfully toggled lane status for ID: $laneId',
                name: 'LaneService.toggleLaneStatus');
            return true;
          } else {
            developer.log(
                '[LANE SVC] Toggle status failed according to server response: ${responseData['msg']}',
                name: 'LaneService.toggleLaneStatus');
            return false;
          }
        } catch (e, stackTrace) {
          developer.log('[LANE SVC] Error parsing toggle success response: $e',
              name: 'LaneService.toggleLaneStatus',
              error: e,
              stackTrace: stackTrace,
              level: 1000);
          throw ServiceException(
              'Toggle request succeeded (status 200), but failed to parse response.');
        }
      } else if (response.statusCode == 204) {
        developer.log(
            '[LANE SVC] Successfully toggled lane status for ID: $laneId (Status 204 No Content)',
            name: 'LaneService.toggleLaneStatus');
        return true;
      } else {
        throw _handleErrorResponse(response, 'Failed to toggle lane status');
      }
    } on SocketException catch (e) {
      developer.log('[LANE SVC] SocketException: $e',
          name: 'LaneService.toggleLaneStatus', error: e);
      throw ServerConnectionException(
          'Failed to connect to the lane server: ${e.message}');
    } on TimeoutException catch (e) {
      developer.log('[LANE SVC] TimeoutException: $e',
          name: 'LaneService.toggleLaneStatus', error: e);
      throw RequestTimeoutException('Request timed out while toggling status');
    } catch (e, stackTrace) {
      developer.log('[LANE SVC] Error in toggleLaneStatus: $e',
          name: 'LaneService.toggleLaneStatus',
          error: e,
          stackTrace: stackTrace);
      if (e is PlazaException) rethrow;
      throw ServiceException(
          'An unexpected error occurred during toggle: ${e.toString()}');
    }
  }

  /// Retrieves a lane by its ID.
  Future<Lane> getLaneById(String laneId) async {
    final uri = Uri.parse(ApiConfig.getFullUrl(PlazaApi.getLane))
        .replace(queryParameters: {'id': laneId});

    await _checkConnectivity(uri.host, 'LaneService.getLaneById');

    developer.log('[LANE SVC] Fetching lane by ID at URL: $uri',
        name: 'LaneService.getLaneById');
    developer.log('[LANE SVC] Lane ID: $laneId',
        name: 'LaneService.getLaneById');

    try {
      developer.log('[LANE SVC] Sending GET request to $uri',
          name: 'LaneService.getLaneById');
      final response = await _client
          .get(
            uri,
            headers: await _getHeaders(),
          )
          .timeout(ApiConfig.defaultTimeout);

      developer.log('[LANE SVC] Response Status Code: ${response.statusCode}',
          name: 'LaneService.getLaneById');
      developer.log(
          '[LANE SVC] Response Body (truncated): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}...',
          name: 'LaneService.getLaneById');

      if (response.statusCode == 200) {
        try {
          final responseData =
              json.decode(response.body) as Map<String, dynamic>;
          developer.log(
              '[LANE SVC] Response success flag: ${responseData['success']}',
              name: 'LaneService.getLaneById');
          if (responseData['success'] == true &&
              responseData['laneData'] != null &&
              responseData['laneData'] is Map) {
            developer.log('[LANE SVC] Successfully fetched lane ID: $laneId',
                name: 'LaneService.getLaneById');
            return Lane.fromJson(
                responseData['laneData'] as Map<String, dynamic>);
          } else {
            final serverMsg = responseData['msg'] ?? 'Invalid response format';
            developer.log(
                '[LANE SVC] Failed to fetch lane or invalid format: $serverMsg',
                name: 'LaneService.getLaneById',
                level: 900);
            throw ServiceException('Failed to fetch lane: $serverMsg');
          }
        } catch (e, stackTrace) {
          developer.log(
              '[LANE SVC] Error parsing getLaneById success response: $e',
              name: 'LaneService.getLaneById',
              error: e,
              stackTrace: stackTrace,
              level: 1000);
          throw ServiceException(
              'Request succeeded (status 200), but failed to parse response data.');
        }
      } else {
        throw _handleErrorResponse(response, 'Failed to fetch lane');
      }
    } on SocketException catch (e) {
      developer.log('[LANE SVC] SocketException: $e',
          name: 'LaneService.getLaneById', error: e);
      throw ServerConnectionException(
          'Failed to connect to the lane server: ${e.message}');
    } on TimeoutException catch (e) {
      developer.log('[LANE SVC] TimeoutException: $e',
          name: 'LaneService.getLaneById', error: e);
      throw RequestTimeoutException('Request timed out while fetching lane');
    } catch (e, stackTrace) {
      developer.log('[LANE SVC] Error in getLaneById: $e',
          name: 'LaneService.getLaneById', error: e, stackTrace: stackTrace);
      if (e is PlazaException) rethrow;
      throw ServiceException(
          'An unexpected error occurred fetching lane: ${e.toString()}');
    }
  }

  Future<List<Lane>> getLanesByPlazaId(String plazaId) async {
    final uri = Uri.parse(ApiConfig.getFullUrl(PlazaApi.getLanesByPlaza))
        .replace(queryParameters: {'plazaId': plazaId});

    await _checkConnectivity(uri.host, 'LaneService.getLanesByPlazaId');

    developer.log('[LANE SVC] Fetching lanes by plaza ID at URL: $uri',
        name: 'LaneService.getLanesByPlazaId');
    developer.log('[LANE SVC] Plaza ID: $plazaId',
        name: 'LaneService.getLanesByPlazaId');

    try {
      developer.log('[LANE SVC] Sending GET request to $uri',
          name: 'LaneService.getLanesByPlazaId');
      final response = await _client
          .get(
            uri,
            headers: await _getHeaders(),
          )
          .timeout(ApiConfig.defaultTimeout);

      developer.log('[LANE SVC] Response Status Code: ${response.statusCode}',
          name: 'LaneService.getLanesByPlazaId');
      developer.log('[LANE SVC] Response Body: ${response.body}',
          name: 'LaneService.getLanesByPlazaId');

      if (response.statusCode == 200) {
        try {
          final responseData =
              json.decode(response.body) as Map<String, dynamic>;
          developer.log(
              '[LANE SVC] Response success flag: ${responseData['success']}',
              name: 'LaneService.getLanesByPlazaId');
          if (responseData['success'] == true) {
            final List<dynamic> lanesJson =
                responseData['laneData'] as List<dynamic>? ?? [];
            developer.log('[LANE SVC] Parsing ${lanesJson.length} lanes',
                name: 'LaneService.getLanesByPlazaId');
            final lanes = lanesJson.map((json) {
              try {
                return Lane.fromJson(json as Map<String, dynamic>);
              } catch (e) {
                developer.log(
                    '[LANE SVC] Failed to parse lane JSON: $json, Error: $e',
                    name: 'LaneService.getLanesByPlazaId',
                    level: 1000);
                rethrow;
              }
            }).toList();
            developer.log(
                '[LANE SVC] Successfully fetched ${lanes.length} lanes for plaza ID: $plazaId',
                name: 'LaneService.getLanesByPlazaId');
            return lanes;
          } else {
            final serverMsg = responseData['msg'] ?? 'Server indicated failure';
            developer.log(
                '[LANE SVC] Failed to fetch lanes for plaza: $serverMsg',
                name: 'LaneService.getLanesByPlazaId',
                level: 900);
            throw ServiceException('Failed to fetch lanes: $serverMsg');
          }
        } catch (e, stackTrace) {
          developer.log(
              '[LANE SVC] Error parsing getLanesByPlazaId response: $e',
              name: 'LaneService.getLanesByPlazaId',
              error: e,
              stackTrace: stackTrace,
              level: 1000);
          throw ServiceException(
              'Request succeeded (status 200), but failed to parse response data: $e');
        }
      } else {
        throw _handleErrorResponse(response, 'Failed to fetch lanes');
      }
    } on SocketException catch (e) {
      developer.log('[LANE SVC] SocketException: $e',
          name: 'LaneService.getLanesByPlazaId', error: e);
      throw ServerConnectionException(
          'Failed to connect to the lane server: ${e.message}');
    } on TimeoutException catch (e) {
      developer.log('[LANE SVC] TimeoutException: $e',
          name: 'LaneService.getLanesByPlazaId', error: e);
      throw RequestTimeoutException('Request timed out while fetching lanes');
    } catch (e, stackTrace) {
      developer.log('[LANE SVC] Error in getLanesByPlazaId: $e',
          name: 'LaneService.getLanesByPlazaId',
          error: e,
          stackTrace: stackTrace);
      if (e is PlazaException) rethrow;
      throw ServiceException(
          'An unexpected error occurred fetching lanes: ${e.toString()}');
    }
  }

  /// Updates an existing lane.
  Future<bool> updateLane(Lane lane) async {
    final fullUrl = ApiConfig.getFullUrl(PlazaApi.updateLane);
    final serverUrl = Uri.parse(fullUrl);

    await _checkConnectivity(serverUrl.host, 'LaneService.updateLane');

    developer.log(
        '[LANE SVC] Updating lane (ID: ${lane.laneId}) at URL: $fullUrl',
        name: 'LaneService.updateLane');

    try {
      // --- Validate Lane Before Sending ---
      final validationError = lane.validateForUpdate();
      if (validationError != null) {
        developer.log(
            '[LANE SVC] Validation failed before update: $validationError',
            name: 'LaneService.updateLane',
            level: 900);
        throw ServiceException(
            'Lane validation failed before sending update: $validationError');
      }
      if (lane.laneId == null) {
        developer.log(
            '[LANE SVC] Validation failed: Lane ID is missing for update.',
            name: 'LaneService.updateLane',
            level: 1000);
        throw ServiceException(
            'Lane validation failed: Lane ID is required for update.');
      }

      // --- Prepare Request Body ---
      developer.log(
          '[LANE SVC] Preparing request body for lane update using toJsonForUpdate',
          name: 'LaneService.updateLane');
      final laneJson = lane.toJsonForUpdate();
      developer.log('[LANE SVC] Lane JSON for update: $laneJson',
          name: 'LaneService.updateLane');
      final body = json.encode(laneJson);
      developer.log(
          '[LANE SVC] Request Body (encoded - truncated): ${body.substring(0, body.length > 500 ? 500 : body.length)}...',
          name: 'LaneService.updateLane');

      // --- Make API Call ---
      developer.log('[LANE SVC] Sending PUT request to $serverUrl',
          name: 'LaneService.updateLane');
      final response = await _client
          .put(
            serverUrl,
            headers: await _getHeaders(),
            body: body,
          )
          .timeout(ApiConfig.defaultTimeout);

      developer.log('[LANE SVC] Response Status Code: ${response.statusCode}',
          name: 'LaneService.updateLane');
      developer.log('[LANE SVC] Response Body: ${response.body}',
          name: 'LaneService.updateLane');

      // --- Process Response ---
      if (response.statusCode == 200) {
        try {
          final responseBody =
              json.decode(response.body) as Map<String, dynamic>;
          developer.log(
              '[LANE SVC] Response success flag: ${responseBody['success']}',
              name: 'LaneService.updateLane');
          if (responseBody['success'] == true) {
            developer.log(
                '[LANE SVC] Successfully updated lane ID: ${lane.laneId}',
                name: 'LaneService.updateLane');
            return true;
          } else {
            developer.log(
                '[LANE SVC] Update failed according to server response: ${responseBody['msg']}',
                name: 'LaneService.updateLane');
            return false;
          }
        } catch (e, stackTrace) {
          developer.log('[LANE SVC] Error parsing update success response: $e',
              name: 'LaneService.updateLane',
              error: e,
              stackTrace: stackTrace,
              level: 1000);
          throw ServiceException(
              'Update request succeeded (status 200), but failed to parse response.');
        }
      } else if (response.statusCode == 204) {
        developer.log(
            '[LANE SVC] Successfully updated lane ID: ${lane.laneId} (Status 204 No Content)',
            name: 'LaneService.updateLane');
        return true;
      } else {
        throw _handleErrorResponse(response, 'Failed to update lane');
      }
    } on SocketException catch (e) {
      developer.log('[LANE SVC] SocketException: $e',
          name: 'LaneService.updateLane', error: e);
      throw ServerConnectionException(
          'Failed to connect to the lane server: ${e.message}');
    } on TimeoutException catch (e) {
      developer.log('[LANE SVC] TimeoutException: $e',
          name: 'LaneService.updateLane', error: e);
      throw RequestTimeoutException('Request timed out while updating lane');
    } catch (e, stackTrace) {
      developer.log('[LANE SVC] Error in updateLane: $e',
          name: 'LaneService.updateLane', error: e, stackTrace: stackTrace);
      if (e is PlazaException) rethrow;
      throw ServiceException(
          'An unexpected error occurred during update: ${e.toString()}');
    }
  }

  /// Helper method to check connectivity.
  Future<void> _checkConnectivity(String host, String logName) async {
    if (!(await _connectivityService.isConnected())) {
      developer.log('[LANE SVC] No internet connection detected',
          name: logName);
      throw NoInternetException(
          'No internet connection. Please check your network settings.');
    }
  }

  /// Helper method to handle error responses consistently.
  HttpException _handleErrorResponse(
      http.Response response, String defaultMessage) {
    String? serverMessage;
    try {
      final responseData = json.decode(response.body);
      if (responseData is Map<String, dynamic>) {
        serverMessage = responseData['msg'] as String?;
      }
      developer.log(
          '[LANE SVC] Error response decoded - Server message: $serverMessage',
          name: 'LaneService.handleErrorResponse');
    } catch (e) {
      developer.log('[LANE SVC] Failed to decode error response or get msg: $e',
          name: 'LaneService.handleErrorResponse', error: e);
      serverMessage = null;
    }
    final exception = HttpException(
      defaultMessage,
      statusCode: response.statusCode,
      serverMessage:
          serverMessage ?? 'Unknown server error or non-JSON response',
    );
    developer.log('[LANE SVC] Created HttpException: ${exception.toString()}',
        name: 'LaneService.handleErrorResponse');
    return exception;
  }
}
