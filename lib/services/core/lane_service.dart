import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/lane.dart';
import '../../config/api_config.dart';
import '../../utils/exceptions.dart';

class LaneService {
  final http.Client _client;
  final String baseUrl = ApiConfig.apiGateway;

  LaneService({http.Client? client}) : _client = client ?? http.Client();

  Future<String> addLane(List<Lane> lanes) async {
    try {
      // Validate each lane in the list
      for (var lane in lanes) {
        final validationError = lane.validate();
        if (validationError != null) {
          throw Exception(validationError);
        }
      }

      final fullUrl = ApiConfig.getFullUrl(ApiConfig.createLaneEndpoint);

      // Serialize the list of lanes into an array
      final body = json.encode(
        lanes.map((lane) => lane.toJson()).toList(),
      );

      print('Request - Add Lane:');
      print('  Base URL: $baseUrl');
      print('  Endpoint: ${ApiConfig.createLaneEndpoint}');
      print('  Full URL: $fullUrl');
      print('  Body: $body');

      // Make the POST request
      final response = await _client.post(
        Uri.parse(fullUrl),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print('Response - Add Lane:');
      print('  Status Code: ${response.statusCode}');
      print('  Body: ${response.body}');

      // Check if the request was successful
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw HttpException('Failed to add lane: ${response.statusCode}');
      }

      // Parse the response body
      final responseBody = json.decode(response.body) as Map<String, dynamic>;

      if (responseBody['success'] == true) {
        return responseBody['msg'] ?? 'Lanes added successfully';
      } else {
        throw PlazaException('Lane creation failed: ${responseBody['msg']}');
      }
    } catch (e) {
      print('Error - Add Lane:');
      print('  Error details: $e');
      throw PlazaException('Error adding lane: $e');
    }
  }

  Future<bool> deleteLane(String laneId) async {
    try {
      final fullUrl = '${ApiConfig.getFullUrl('plaza/lane/delete/')}$laneId';

      print('Request - Delete Lane:');
      print('  Base URL: $baseUrl');
      print('  Endpoint: plaza/lane/delete/$laneId');
      print('  Full URL: $fullUrl');

      final response = await _client.delete(
        Uri.parse(fullUrl),
        headers: {'Content-Type': 'application/json'},
      );

      print('Response - Delete Lane:');
      print('  Status Code: ${response.statusCode}');
      print('  Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData['success'] == true;
      }
      throw HttpException('Failed to delete lane: ${response.statusCode}');
    } catch (e) {
      print('Error - Delete Lane:');
      print('  Error details: $e');
      throw PlazaException('Error deleting lane: $e');
    }
  }

  Future<bool> toggleLaneStatus(String laneId, bool isActive) async {
    try {
      final fullUrl = '${ApiConfig.getFullUrl('plaza/lane/toggle-status/')}$laneId';
      final body = json.encode({'isActive': isActive});

      print('Request - Toggle Lane Status:');
      print('  Base URL: $baseUrl');
      print('  Endpoint: plaza/lane/toggle-status/$laneId');
      print('  Full URL: $fullUrl');
      print('  Body: $body');

      final response = await _client.put(
        Uri.parse(fullUrl),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print('Response - Toggle Lane Status:');
      print('  Status Code: ${response.statusCode}');
      print('  Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData['success'] == true;
      }
      throw HttpException('Failed to toggle lane status: ${response.statusCode}');
    } catch (e) {
      print('Error - Toggle Lane Status:');
      print('  Error details: $e');
      throw PlazaException('Error toggling lane status: $e');
    }
  }

  Future<Lane> getLaneById(String laneId) async {
    try {
      // Use 'id' as the query parameter key
      final uri = Uri.parse(ApiConfig.getFullUrl(ApiConfig.getLaneByIdEndpoint))
          .replace(queryParameters: {'id': laneId});

      print('Request - Get Lane By ID:');
      print('  Base URL: $baseUrl');
      print('  Endpoint: ${ApiConfig.getLaneByIdEndpoint}');
      print('  Full URL: $uri');
      print('  Parameters: id=$laneId');

      final response = await _client.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      print('Response - Get Lane By ID:');
      print('  Status Code: ${response.statusCode}');
      print('  Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body) as Map<String, dynamic>;

        // Check for laneData in the response
        if (responseData['success'] == true && responseData['laneData'] != null) {
          return Lane.fromJson(responseData['laneData']);
        }
        throw HttpException('Failed to fetch lane: Invalid response format');
      }
      throw HttpException('Failed to fetch lane: ${response.statusCode}');
    } catch (e) {
      print('Error - Get Lane By ID:');
      print('  Error details: $e');
      throw PlazaException('Error fetching lane: $e');
    }
  }

  Future<List<Lane>> getLanesByPlazaId(String plazaId) async {
    try {
      final uri = Uri.parse(ApiConfig.getFullUrl(ApiConfig.getLanesByPlazaIdEndpoint))
          .replace(queryParameters: {'plazaId': plazaId});

      print('Request - Get Lanes By Plaza ID:');
      print('  Base URL: $baseUrl');
      print('  Endpoint: ${ApiConfig.getLanesByPlazaIdEndpoint}');
      print('  Full URL: $uri');
      print('  Parameters: plazaId=$plazaId');

      final response = await _client.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      print('Response - Get Lanes By Plaza ID:');
      print('  Status Code: ${response.statusCode}');
      print('  Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['laneData'] != null) {
          final List<dynamic> lanesJson = responseData['laneData'];
          return lanesJson.map((json) => Lane.fromJson(json)).toList();
        }
        throw HttpException('Failed to fetch lanes: Invalid response format');
      }
      throw HttpException('Failed to fetch lanes: ${response.statusCode}');
    } catch (e) {
      print('Error - Get Lanes By Plaza ID:');
      print('  Error details: $e');
      throw PlazaException('Error fetching lanes: $e');
    }
  }

  Future<bool> updateLane(Lane lane) async {
    try {
      final validationError = lane.validate();
      if (validationError != null) {
        throw Exception(validationError);
      }

      final fullUrl = ApiConfig.getFullUrl(ApiConfig.updateLaneEndpoint);
      final body = json.encode(lane.toJson());

      print('Request - Update Lane:');
      print('  Base URL: $baseUrl');
      print('  Endpoint: ${ApiConfig.updateLaneEndpoint}');
      print('  Full URL: $fullUrl');
      print('  Body: $body');

      final response = await _client.put(
        Uri.parse(fullUrl),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print('Response - Update Lane:');
      print('  Status Code: ${response.statusCode}');
      print('  Body: ${response.body}');

      if (response.statusCode != 200) {
        throw HttpException('Failed to update lane: ${response.statusCode}');
      }

      final responseBody = json.decode(response.body) as Map<String, dynamic>;
      return responseBody['success'] == true;
    } catch (e) {
      print('Error - Update Lane:');
      print('  Error details: $e');
      throw PlazaException('Error updating lane: $e');
    }
  }
}