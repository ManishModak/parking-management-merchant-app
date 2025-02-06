import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/plaza_fare.dart';

class FareService {
  final http.Client _client;

  FareService({http.Client? client}) : _client = client ?? http.Client();

  /// Adds a list of fares in bulk.
  Future<List<PlazaFare>> addFare(List<PlazaFare> fares) async {
    final url = ApiConfig.getFullUrl(ApiConfig.addFareEndpoint);
    print('[FARE] Adding fares at URL: $url');

    try {
      final body = json.encode(fares.map((fare) => fare.toJson()).toList());
      print('[FARE] Request Body: $body');

      final response = await _client.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          // Add authorization header here if needed
        },
        body: body,
      );

      print('[FARE] Response Status Code: ${response.statusCode}');
      print('[FARE] Response Body: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        print('[FARE] ERROR: Failed to add fares with status: ${response.statusCode}');
        throw Exception('Failed to add fares: ${response.statusCode}');
      }

      final responseData = json.decode(response.body);
      if (responseData['success'] == true && responseData['data'] != null) {
        final List<PlazaFare> addedFares = (responseData['data'] as List)
            .map((fareJson) => PlazaFare.fromJson(fareJson))
            .toList();
        print('[FARE] Successfully added ${addedFares.length} fares.');
        return addedFares;
      } else {
        print('[FARE] ERROR: ${responseData['msg'] ?? 'Failed to add fares'}');
        throw Exception(responseData['msg'] ?? 'Failed to add fares');
      }
    } catch (e) {
      print('[FARE] ERROR: Exception while adding fares: $e');
      throw Exception('Error adding fares: $e');
    }
  }

  /// Retrieves all fares for a given plaza ID.
  Future<List<PlazaFare>> getFaresByPlazaId(int plazaId) async {
    final url = ApiConfig.getFullUrl(ApiConfig.getFaresByPlazaIdEndpoint);
    final uri = Uri.parse(url).replace(queryParameters: {'plazaId': plazaId.toString()});
    print('[FARE] Fetching fares by Plaza ID at URL: $uri');
    print('[FARE] Plaza ID: $plazaId');

    try {
      final response = await _client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          // Add authorization header here if needed
        },
      );

      print('[FARE] Response Status Code: ${response.statusCode}');
      print('[FARE] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          final List<PlazaFare> fares = (responseData['data'] as List)
              .map((fareJson) => PlazaFare.fromJson(fareJson))
              .toList();
          print('[FARE] Successfully retrieved ${fares.length} fares.');
          return fares;
        } else {
          print('[FARE] ERROR: No fares found for plaza ID: $plazaId');
          throw Exception('No fares found for plaza ID: $plazaId');
        }
      } else {
        print('[FARE] ERROR: Failed to get fares with status: ${response.statusCode}');
        throw Exception('Failed to get fares: ${response.statusCode}');
      }
    } catch (e) {
      print('[FARE] ERROR: Exception while getting fares: $e');
      throw Exception('Error getting fares: $e');
    }
  }

  /// Retrieves a fare by its ID.
  Future<PlazaFare> getFareById(int fareId) async {
    final url = ApiConfig.getFullUrl(ApiConfig.getFareByIdEndpoint);
    final uri = Uri.parse(url).replace(queryParameters: {'fareId': fareId.toString()});
    print('[FARE] Fetching fare by ID at URL: $uri');
    print('[FARE] Fare ID: $fareId');

    try {
      final response = await _client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          // Add authorization header here if needed
        },
      );

      print('[FARE] Response Status Code: ${response.statusCode}');
      print('[FARE] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          final PlazaFare fare = PlazaFare.fromJson(responseData['data']);
          print('[FARE] Successfully retrieved fare.');
          return fare;
        } else {
          print('[FARE] ERROR: Fare not found with ID: $fareId');
          throw Exception('Fare not found with ID: $fareId');
        }
      } else {
        print('[FARE] ERROR: Failed to get fare with status: ${response.statusCode}');
        throw Exception('Failed to get fare: ${response.statusCode}');
      }
    } catch (e) {
      print('[FARE] ERROR: Exception while getting fare: $e');
      throw Exception('Error getting fare: $e');
    }
  }

  /// Updates an existing fare.
  Future<bool> updateFare(PlazaFare fare) async {
    if (fare.fareId == null) {
      print('[FARE] ERROR: Fare ID is required for update');
      throw Exception('Fare ID is required for update');
    }

    final url = ApiConfig.getFullUrl(ApiConfig.updateFareEndpoint);
    print('[FARE] Updating fare at URL: $url');

    try {
      final body = json.encode(fare.toJson());
      print('[FARE] Request Body: $body');

      final response = await _client.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          // Add authorization header here if needed
        },
        body: body,
      );

      print('[FARE] Response Status Code: ${response.statusCode}');
      print('[FARE] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final bool success = responseData['success'] == true;
        print('[FARE] Update operation ${success ? 'successful' : 'failed'}');
        return success;
      } else {
        print('[FARE] ERROR: Failed to update fare with status: ${response.statusCode}');
        throw Exception('Failed to update fare: ${response.statusCode}');
      }
    } catch (e) {
      print('[FARE] ERROR: Exception while updating fare: $e');
      throw Exception('Error updating fare: $e');
    }
  }

  /// Deletes a fare by its ID.
  Future<bool> deleteFare(int fareId) async {
    final url = ApiConfig.getFullUrl(ApiConfig.deleteFareEndpoint);
    final uri = Uri.parse(url).replace(queryParameters: {'fareId': fareId.toString()});
    print('[FARE] Deleting fare at URL: $uri');
    print('[FARE] Fare ID: $fareId');

    try {
      final response = await _client.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          // Add authorization header here if needed
        },
      );

      print('[FARE] Response Status Code: ${response.statusCode}');
      print('[FARE] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final bool success = responseData['success'] == true;
        print('[FARE] Delete operation ${success ? 'successful' : 'failed'}');
        return success;
      } else {
        print('[FARE] ERROR: Failed to delete fare with status: ${response.statusCode}');
        throw Exception('Failed to delete fare: ${response.statusCode}');
      }
    } catch (e) {
      print('[FARE] ERROR: Exception while deleting fare: $e');
      throw Exception('Error deleting fare: $e');
    }
  }
}
