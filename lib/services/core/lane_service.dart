import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../models/lane.dart'; // Assuming Lane model is here
import '../../config/api_config.dart'; // Assuming ApiConfig is here
import '../../utils/exceptions.dart'; // Assuming custom exceptions are here
import '../network/connectivity_service.dart'; // Assuming connectivity service is here

class LaneService {
  final http.Client _client;
  final ConnectivityService _connectivityService;
  final String baseUrl = ApiConfig.baseUrl;

  LaneService({
    http.Client? client,
    ConnectivityService? connectivityService,
  })  : _client = client ?? http.Client(),
        _connectivityService = connectivityService ?? ConnectivityService();

  /// Adds one or more lanes to a plaza.
  /// Uses `toJsonForCreate()` for serialization.
  Future<List<Lane>> addLane(List<Lane> lanes) async {
    final fullUrl = ApiConfig.getFullUrl(PlazaApi.createLane);
    final serverUrl = Uri.parse(fullUrl);

    // --- Connectivity Checks ---
    // Refactored connectivity check for brevity
    await _checkConnectivity(serverUrl.host, 'LaneService.addLane');

    developer.log('[LANE SVC] Adding ${lanes.length} lanes at URL: $fullUrl',
        name: 'LaneService.addLane');

    try {
      // --- Validate Lanes Before Sending ---
      for (final lane in lanes) {
        final validationError =
            lane.validateForCreate(); // USE CREATE VALIDATION
        if (validationError != null) {
          developer.log(
              '[LANE SVC] Validation failed for a lane during add: $validationError',
              name: 'LaneService.addLane',
              level: 900);
          throw ServiceException(
              'Lane validation failed before sending: $validationError');
        }
        // Optional: Check if laneId is null, as expected for creation
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
      // USE toJsonForCreate
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
            headers: {'Content-Type': 'application/json'},
            // Content-Length often automatic
            body: body,
          )
          .timeout(ApiConfig
              .longTimeout); // Using a potentially longer timeout for create

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
        // Use the original _handleErrorResponse logic
        throw _handleErrorResponse(response, 'Failed to add lanes');
      }
    } on SocketException catch (e) {
      // Keep original exception handling structure
      developer.log('[LANE SVC] SocketException: $e',
          name: 'LaneService.addLane', error: e);
      throw ServerConnectionException(
          'Failed to connect to the lane server: ${e.message}'); // Use message
    } on TimeoutException catch (e) {
      developer.log('[LANE SVC] TimeoutException: $e',
          name: 'LaneService.addLane', error: e);
      throw RequestTimeoutException('Request timed out while adding lanes');
    } catch (e, stackTrace) {
      // Keep generic catch block
      developer.log('[LANE SVC] Unexpected error: $e',
          name: 'LaneService.addLane',
          error: e,
          stackTrace: stackTrace,
          level: 1000);
      if (e is PlazaException) {
        // Rethrow custom exceptions if needed
        rethrow;
      }
      // Wrap other errors as ServiceException
      throw ServiceException(
          'An unexpected error occurred while adding lanes: ${e.toString()}');
    }
  }

  /// Deletes a lane by its ID. (Kept original signature with String laneId)
  Future<bool> deleteLane(String laneId) async {
    // Original URL structure: base + / + laneId
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
      final response = await _client.delete(
        serverUrl,
        headers: {'Content-Type': 'application/json'},
      ).timeout(ApiConfig.defaultTimeout); // Using default timeout

      developer.log('[LANE SVC] Response Status Code: ${response.statusCode}',
          name: 'LaneService.deleteLane');
      developer.log('[LANE SVC] Response Body: ${response.body}',
          name: 'LaneService.deleteLane');

      if (response.statusCode == 200) {
        try {
          final responseData =
              json.decode(response.body) as Map<String, dynamic>; // Expect Map
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
            // Keep original behavior of returning false on success:false
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
        // Explicitly handle 204 No Content as success
        developer.log(
            '[LANE SVC] Successfully deleted lane ID: $laneId (Status 204 No Content)',
            name: 'LaneService.deleteLane');
        return true;
      } else {
        // Use original error handling
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
      throw RequestTimeoutException(
          'Request timed out while deleting lane'); // Adjusted message slightly
    } catch (e, stackTrace) {
      // Keep original rethrow logic
      developer.log('[LANE SVC] Error in deleteLane: $e',
          name: 'LaneService.deleteLane', error: e, stackTrace: stackTrace);
      if (e is PlazaException) rethrow;
      throw ServiceException(
          'An unexpected error occurred during delete: ${e.toString()}');
    }
  }

  /// Toggles the active status of a lane. (Restored original logic)
  /// NOTE: This sends only {'isActive': ...} to the update endpoint.
  /// This might not be standard REST PUT behavior and depends heavily on the specific API implementation.
  /// Consider using a dedicated PATCH endpoint or the full `updateLane` method if this causes issues.
  Future<bool> toggleLaneStatus(String laneId, bool isActive) async {
    // Original URL structure
    final fullUrl = '${ApiConfig.getFullUrl(PlazaApi.updateLane)}/$laneId';
    final serverUrl = Uri.parse(fullUrl);

    await _checkConnectivity(serverUrl.host, 'LaneService.toggleLaneStatus');

    developer.log('[LANE SVC] Toggling lane status at URL: $fullUrl',
        name: 'LaneService.toggleLaneStatus');
    developer.log('[LANE SVC] Lane ID: $laneId, New Status: $isActive',
        name: 'LaneService.toggleLaneStatus');

    // Original body structure
    final body = json.encode({'isActive': isActive});
    developer.log('[LANE SVC] Request Body (encoded): $body',
        name: 'LaneService.toggleLaneStatus');

    try {
      developer.log('[LANE SVC] Sending PUT request to $serverUrl',
          name: 'LaneService.toggleLaneStatus');
      // Original used PUT for toggle
      final response = await _client
          .put(
            serverUrl,
            headers: {'Content-Type': 'application/json'},
            // Content-Length automatic
            body: body,
          )
          .timeout(ApiConfig.defaultTimeout); // Default timeout

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
            return false; // Original behavior
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
        // Use original error handling
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
      throw RequestTimeoutException(
          'Request timed out while toggling status'); // Adjusted message
    } catch (e, stackTrace) {
      // Keep original rethrow
      developer.log('[LANE SVC] Error in toggleLaneStatus: $e',
          name: 'LaneService.toggleLaneStatus',
          error: e,
          stackTrace: stackTrace);
      if (e is PlazaException) rethrow;
      throw ServiceException(
          'An unexpected error occurred during toggle: ${e.toString()}');
    }
  }

  /// Retrieves a lane by its ID. (Kept original signature with String laneId)
  Future<Lane> getLaneById(String laneId) async {
    // Original uses query parameter
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
      final response = await _client.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      ).timeout(ApiConfig.defaultTimeout);

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
          // Original check
          if (responseData['success'] == true &&
              responseData['laneData'] != null &&
              responseData['laneData'] is Map) {
            developer.log('[LANE SVC] Successfully fetched lane ID: $laneId',
                name: 'LaneService.getLaneById');
            // Parse the single lane object
            return Lane.fromJson(
                responseData['laneData'] as Map<String, dynamic>);
          } else {
            // Handle cases where success might be false or data is missing/wrong type
            final serverMsg = responseData['msg'] ?? 'Invalid response format';
            developer.log(
                '[LANE SVC] Failed to fetch lane or invalid format: $serverMsg',
                name: 'LaneService.getLaneById',
                level: 900);
            throw ServiceException(
                'Failed to fetch lane: $serverMsg'); // Throw specific error
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
        // Use original error handling
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
      throw RequestTimeoutException(
          'Request timed out while fetching lane'); // Adjusted message
    } catch (e, stackTrace) {
      // Keep original rethrow
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
      final response = await _client.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      ).timeout(ApiConfig.defaultTimeout);

      developer.log('[LANE SVC] Response Status Code: ${response.statusCode}',
          name: 'LaneService.getLanesByPlazaId');
      developer.log('[LANE SVC] Response Body: ${response.body}', // Full body
          name: 'LaneService.getLanesByPlazaId');

      if (response.statusCode == 200) {
        try {
          final responseData = json.decode(response.body) as Map<String, dynamic>;
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
          name: 'LaneService.getLanesByPlazaId', error: e, stackTrace: stackTrace);
      if (e is PlazaException) rethrow;
      throw ServiceException(
          'An unexpected error occurred fetching lanes: ${e.toString()}');
    }
  }

  /// Updates an existing lane.
  /// Uses `validateForUpdate()` and `toJsonForUpdate()`.
  /// Assumes PUT request to the base collection URL (e.g., /lanes).
  Future<bool> updateLane(Lane lane) async {
    // Assumes PUT to the base URL, ID is in the body
    final fullUrl = ApiConfig.getFullUrl(PlazaApi.updateLane);
    final serverUrl = Uri.parse(fullUrl);

    await _checkConnectivity(serverUrl.host, 'LaneService.updateLane');

    developer.log(
        '[LANE SVC] Updating lane (ID: ${lane.laneId}) at URL: $fullUrl',
        name: 'LaneService.updateLane');

    try {
      // --- Validate Lane Before Sending ---
      final validationError = lane.validateForUpdate(); // USE UPDATE VALIDATION
      if (validationError != null) {
        developer.log(
            '[LANE SVC] Validation failed before update: $validationError',
            name: 'LaneService.updateLane',
            level: 900);
        throw ServiceException(
            'Lane validation failed before sending update: $validationError');
      }
      // Crucial check: laneId MUST exist for an update based on update schema
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
      final laneJson = lane.toJsonForUpdate(); // USE toJsonForUpdate
      developer.log('[LANE SVC] Lane JSON for update: $laneJson',
          name:
              'LaneService.updateLane'); // Log full JSON for update if not too large
      final body = json.encode(laneJson);
      developer.log(
          '[LANE SVC] Request Body (encoded - truncated): ${body.substring(0, body.length > 500 ? 500 : body.length)}...',
          name: 'LaneService.updateLane');

      // --- Make API Call ---
      developer.log('[LANE SVC] Sending PUT request to $serverUrl',
          name: 'LaneService.updateLane');
      final response = await _client
          .put(
            // Original used PUT
            serverUrl,
            headers: {'Content-Type': 'application/json'},
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
          // Original check
          if (responseBody['success'] == true) {
            developer.log(
                '[LANE SVC] Successfully updated lane ID: ${lane.laneId}',
                name: 'LaneService.updateLane');
            return true;
          } else {
            developer.log(
                '[LANE SVC] Update failed according to server response: ${responseBody['msg']}',
                name: 'LaneService.updateLane');
            return false; // Original behavior
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
        // Handle No Content success
        developer.log(
            '[LANE SVC] Successfully updated lane ID: ${lane.laneId} (Status 204 No Content)',
            name: 'LaneService.updateLane');
        return true;
      } else {
        // Use original error handling
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
      throw RequestTimeoutException(
          'Request timed out while updating lane'); // Adjusted message
    } catch (e, stackTrace) {
      // Keep original rethrow
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
    // NOTE: canReachServer check removed as per previous refinement discussion (can be slow/unreliable)
    // if (!(await _connectivityService.canReachServer(host))) {
    //   developer.log('[LANE SVC] Cannot reach server: $host', name: logName);
    //   throw ServerConnectionException('Cannot reach the lane server.', host: host);
    // }
  }

  /// Helper method to handle error responses consistently (original simpler version).
  HttpException _handleErrorResponse(
      http.Response response, String defaultMessage) {
    String? serverMessage;
    try {
      // Attempt to decode msg field from JSON body
      final responseData = json.decode(response.body);
      if (responseData is Map<String, dynamic>) {
        // Check if it's a map
        serverMessage = responseData['msg'] as String?;
      }
      developer.log(
          '[LANE SVC] Error response decoded - Server message: $serverMessage',
          name: 'LaneService.handleErrorResponse');
    } catch (e) {
      developer.log('[LANE SVC] Failed to decode error response or get msg: $e',
          name: 'LaneService.handleErrorResponse', error: e);
      // Keep serverMessage as null if decoding fails or 'msg' is not found
      serverMessage = null;
    }
    // Create the generic HttpException as in the original code
    final exception = HttpException(
      defaultMessage,
      statusCode: response.statusCode,
      serverMessage: serverMessage ??
          'Unknown server error or non-JSON response', // Provide default if null
    );
    developer.log('[LANE SVC] Created HttpException: ${exception.toString()}',
        name: 'LaneService.handleErrorResponse');
    return exception;
  }
}


