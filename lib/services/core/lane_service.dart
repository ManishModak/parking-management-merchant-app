import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../models/lane.dart';
import '../../config/api_config.dart';
import '../../utils/exceptions.dart';
import '../network/connectivity_service.dart';

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
  Future<String> addLane(List<Lane> lanes) async {
    final fullUrl = ApiConfig.getFullUrl(PlazaApi.createLane);
    final serverUrl = Uri.parse(fullUrl);

    if (!(await _connectivityService.isConnected())) {
      throw NoInternetException('No internet connection. Please check your network settings.');
    }
    if (!(await _connectivityService.canReachServer(serverUrl.host))) {
      throw ServerConnectionException('Cannot reach the lane server.', host: serverUrl.host);
    }

    developer.log('[LANE] Adding lanes at URL: $fullUrl', name: 'LaneService');

    try {
      for (var lane in lanes) {
        final validationError = lane.validate();
        if (validationError != null) {
          throw ServiceException('Lane validation failed: $validationError');
        }
      }

      final body = json.encode(lanes.map((lane) => lane.toJson()).toList());
      developer.log('[LANE] Request Body: $body', name: 'LaneService');

      final response = await _client
          .post(
        serverUrl,
        headers: {'Content-Type': 'application/json'},
        body: body,
      )
          .timeout(const Duration(seconds: 10));

      developer.log('[LANE] Response Status Code: ${response.statusCode}', name: 'LaneService');
      developer.log('[LANE] Response Body: ${response.body}', name: 'LaneService');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = json.decode(response.body) as Map<String, dynamic>;
        if (responseBody['success'] == true) {
          developer.log('[LANE] Successfully added ${lanes.length} lanes', name: 'LaneService');
          return responseBody['msg'] ?? 'Lanes added successfully';
        }
        throw ServiceException('Lane creation failed: ${responseBody['msg'] ?? 'Unknown error'}');
      }

      throw _handleErrorResponse(response, 'Failed to add lanes');
    } on SocketException catch (e) {
      throw ServerConnectionException('Failed to connect to the lane server: $e');
    } on TimeoutException {
      throw RequestTimeoutException('Request timed out');
    } catch (e, stackTrace) {
      developer.log('[LANE] Error in addLane: $e', name: 'LaneService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Deletes a lane by its ID.
  Future<bool> deleteLane(String laneId) async {
    final fullUrl = '${ApiConfig.getFullUrl(PlazaApi.updateLane)}$laneId';
    final serverUrl = Uri.parse(fullUrl);

    if (!(await _connectivityService.isConnected())) {
      throw NoInternetException('No internet connection. Please check your network settings.');
    }
    if (!(await _connectivityService.canReachServer(serverUrl.host))) {
      throw ServerConnectionException('Cannot reach the lane server.', host: serverUrl.host);
    }

    developer.log('[LANE] Deleting lane at URL: $fullUrl', name: 'LaneService');
    developer.log('[LANE] Lane ID: $laneId', name: 'LaneService');

    try {
      final response = await _client
          .delete(
        serverUrl,
        headers: {'Content-Type': 'application/json'},
      )
          .timeout(const Duration(seconds: 10));

      developer.log('[LANE] Response Status Code: ${response.statusCode}', name: 'LaneService');
      developer.log('[LANE] Response Body: ${response.body}', name: 'LaneService');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          developer.log('[LANE] Successfully deleted lane ID: $laneId', name: 'LaneService');
          return true;
        }
        return false;
      }

      throw _handleErrorResponse(response, 'Failed to delete lane');
    } on SocketException catch (e) {
      throw ServerConnectionException('Failed to connect to the lane server: $e');
    } on TimeoutException {
      throw RequestTimeoutException('Request timed out');
    } catch (e, stackTrace) {
      developer.log('[LANE] Error in deleteLane: $e', name: 'LaneService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Toggles the active status of a lane.
  Future<bool> toggleLaneStatus(String laneId, bool isActive) async {
    final fullUrl = '${ApiConfig.getFullUrl(PlazaApi.updateLane)}$laneId';
    final serverUrl = Uri.parse(fullUrl);

    if (!(await _connectivityService.isConnected())) {
      throw NoInternetException('No internet connection. Please check your network settings.');
    }
    if (!(await _connectivityService.canReachServer(serverUrl.host))) {
      throw ServerConnectionException('Cannot reach the lane server.', host: serverUrl.host);
    }

    developer.log('[LANE] Toggling lane status at URL: $fullUrl', name: 'LaneService');
    developer.log('[LANE] Lane ID: $laneId, New Status: $isActive', name: 'LaneService');

    final body = json.encode({'isActive': isActive});
    developer.log('[LANE] Request Body: $body', name: 'LaneService');

    try {
      final response = await _client
          .put(
        serverUrl,
        headers: {'Content-Type': 'application/json'},
        body: body,
      )
          .timeout(const Duration(seconds: 10));

      developer.log('[LANE] Response Status Code: ${response.statusCode}', name: 'LaneService');
      developer.log('[LANE] Response Body: ${response.body}', name: 'LaneService');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          developer.log('[LANE] Successfully toggled lane status for ID: $laneId', name: 'LaneService');
          return true;
        }
        return false;
      }

      throw _handleErrorResponse(response, 'Failed to toggle lane status');
    } on SocketException catch (e) {
      throw ServerConnectionException('Failed to connect to the lane server: $e');
    } on TimeoutException {
      throw RequestTimeoutException('Request timed out');
    } catch (e, stackTrace) {
      developer.log('[LANE] Error in toggleLaneStatus: $e', name: 'LaneService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Retrieves a lane by its ID.
  Future<Lane> getLaneById(String laneId) async {
    final uri = Uri.parse(ApiConfig.getFullUrl(PlazaApi.getLane)).replace(queryParameters: {'id': laneId});

    if (!(await _connectivityService.isConnected())) {
      throw NoInternetException('No internet connection. Please check your network settings.');
    }
    if (!(await _connectivityService.canReachServer(uri.host))) {
      throw ServerConnectionException('Cannot reach the lane server.', host: uri.host);
    }

    developer.log('[LANE] Fetching lane by ID at URL: $uri', name: 'LaneService');
    developer.log('[LANE] Lane ID: $laneId', name: 'LaneService');

    try {
      final response = await _client
          .get(
        uri,
        headers: {'Content-Type': 'application/json'},
      )
          .timeout(const Duration(seconds: 10));

      developer.log('[LANE] Response Status Code: ${response.statusCode}', name: 'LaneService');
      developer.log('[LANE] Response Body: ${response.body}', name: 'LaneService');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body) as Map<String, dynamic>;
        if (responseData['success'] == true && responseData['laneData'] != null) {
          developer.log('[LANE] Successfully fetched lane ID: $laneId', name: 'LaneService');
          return Lane.fromJson(responseData['laneData']);
        }
        throw ServiceException('Invalid response format: missing lane data');
      }

      throw _handleErrorResponse(response, 'Failed to fetch lane');
    } on SocketException catch (e) {
      throw ServerConnectionException('Failed to connect to the lane server: $e');
    } on TimeoutException {
      throw RequestTimeoutException('Request timed out');
    } catch (e, stackTrace) {
      developer.log('[LANE] Error in getLaneById: $e', name: 'LaneService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Retrieves all lanes associated with a plaza by its ID.
  Future<List<Lane>> getLanesByPlazaId(String plazaId) async {
    final uri = Uri.parse(ApiConfig.getFullUrl(PlazaApi.getLanesByPlaza)).replace(queryParameters: {'plazaId': plazaId});

    if (!(await _connectivityService.isConnected())) {
      throw NoInternetException('No internet connection. Please check your network settings.');
    }
    if (!(await _connectivityService.canReachServer(uri.host))) {
      throw ServerConnectionException('Cannot reach the lane server.', host: uri.host);
    }

    developer.log('[LANE] Fetching lanes by plaza ID at URL: $uri', name: 'LaneService');
    developer.log('[LANE] Plaza ID: $plazaId', name: 'LaneService');

    try {
      final response = await _client
          .get(
        uri,
        headers: {'Content-Type': 'application/json'},
      )
          .timeout(const Duration(seconds: 10));

      developer.log('[LANE] Response Status Code: ${response.statusCode}', name: 'LaneService');
      developer.log('[LANE] Response Body: ${response.body}', name: 'LaneService');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body) as Map<String, dynamic>;
        if (responseData['success'] == true) {
          final List<dynamic> lanesJson = responseData['laneData'] ?? [];
          final lanes = lanesJson.map((json) => Lane.fromJson(json)).toList();
          developer.log('[LANE] Successfully fetched ${lanes.length} lanes for plaza ID: $plazaId', name: 'LaneService');
          return lanes;
        }
        throw ServiceException('Invalid response format: missing lane data');
      }

      throw _handleErrorResponse(response, 'Failed to fetch lanes');
    } on SocketException catch (e) {
      throw ServerConnectionException('Failed to connect to the lane server: $e');
    } on TimeoutException {
      throw RequestTimeoutException('Request timed out');
    } catch (e, stackTrace) {
      developer.log('[LANE] Error in getLanesByPlazaId: $e', name: 'LaneService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Updates an existing lane.
  Future<bool> updateLane(Lane lane) async {
    final fullUrl = ApiConfig.getFullUrl(PlazaApi.updateLane);
    final serverUrl = Uri.parse(fullUrl);

    if (!(await _connectivityService.isConnected())) {
      throw NoInternetException('No internet connection. Please check your network settings.');
    }
    if (!(await _connectivityService.canReachServer(serverUrl.host))) {
      throw ServerConnectionException('Cannot reach the lane server.', host: serverUrl.host);
    }

    developer.log('[LANE] Updating lane at URL: $fullUrl', name: 'LaneService');

    try {
      final validationError = lane.validate();
      if (validationError != null) {
        throw ServiceException('Lane validation failed: $validationError');
      }

      final body = json.encode(lane.toJson());
      developer.log('[LANE] Request Body: $body', name: 'LaneService');

      final response = await _client
          .put(
        serverUrl,
        headers: {'Content-Type': 'application/json'},
        body: body,
      )
          .timeout(const Duration(seconds: 10));

      developer.log('[LANE] Response Status Code: ${response.statusCode}', name: 'LaneService');
      developer.log('[LANE] Response Body: ${response.body}', name: 'LaneService');

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body) as Map<String, dynamic>;
        if (responseBody['success'] == true) {
          developer.log('[LANE] Successfully updated lane', name: 'LaneService');
          return true;
        }
        return false;
      }

      throw _handleErrorResponse(response, 'Failed to update lane');
    } on SocketException catch (e) {
      throw ServerConnectionException('Failed to connect to the lane server: $e');
    } on TimeoutException {
      throw RequestTimeoutException('Request timed out');
    } catch (e, stackTrace) {
      developer.log('[LANE] Error in updateLane: $e', name: 'LaneService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Helper method to handle error responses consistently.
  HttpException _handleErrorResponse(http.Response response, String defaultMessage) {
    String? serverMessage;
    try {
      final responseData = json.decode(response.body);
      serverMessage = responseData['msg'] as String?;
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