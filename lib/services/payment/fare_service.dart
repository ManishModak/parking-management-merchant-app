import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:merchant_app/services/storage/secure_storage_service.dart';
import '../../config/api_config.dart';
import '../../models/plaza_fare.dart';
import '../../utils/exceptions.dart';

class FareService {
  final http.Client _client;
  final SecureStorageService _secureStorage = SecureStorageService();

  FareService({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _secureStorage.getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Adds a list of fares in bulk.
  Future<List<PlazaFare>> addFare(List<PlazaFare> fares) async {
    final url = ApiConfig.getFullUrl(PlazaApi.addFare);
    developer.log('[FARE] Adding fares at URL: $url', name: 'FareService');

    try {
      final headers = await _getHeaders();
      final body = json.encode(fares.map((fare) => fare.toJson()).toList());
      developer.log('[FARE] Request Headers: $headers', name: 'FareService');
      developer.log('[FARE] Request Body: $body', name: 'FareService');

      final response = await _client
          .post(
        Uri.parse(url),
        headers: headers,
        body: body,
      )
          .timeout(const Duration(seconds: 30));

      developer.log('[FARE] Response Status Code: ${response.statusCode}', name: 'FareService');
      developer.log('[FARE] Response Body: ${response.body}', name: 'FareService');

      if (response.statusCode != 200 && response.statusCode != 201) {
        final errorData = json.decode(response.body);
        developer.log('[FARE] Failed to add fares: ${errorData['message'] ?? 'Unknown error'}',
            name: 'FareService');
        throw HttpException(
          'Failed to add fares',
          statusCode: response.statusCode,
          serverMessage: errorData['message'],
        );
      }

      final responseData = json.decode(response.body);
      if (responseData['success'] == true && responseData['data'] != null) {
        final List<PlazaFare> addedFares = (responseData['data'] as List)
            .map((fareJson) => PlazaFare.fromJson(fareJson))
            .toList();
        developer.log('[FARE] Successfully added ${addedFares.length} fares', name: 'FareService');
        return addedFares;
      } else {
        developer.log('[FARE] Failed to add fares: ${responseData['msg'] ?? 'Unknown error'}',
            name: 'FareService');
        throw ServiceException(responseData['msg'] ?? 'Failed to add fares');
      }
    } on TimeoutException {
      developer.log('[FARE] Request timed out while adding fares', name: 'FareService');
      throw RequestTimeoutException('Request timed out while adding fares');
    } catch (e, stackTrace) {
      developer.log('[FARE] Error while adding fares: $e',
          name: 'FareService', error: e, stackTrace: stackTrace);
      throw ServiceException('Error adding fares: $e');
    }
  }

  /// Retrieves all fares for a given plaza ID.
  Future<List<PlazaFare>> getFaresByPlazaId(String plazaId) async {
    final baseUrl = ApiConfig.getFullUrl(PlazaApi.getFaresByPlaza);
    developer.log('[FARE] Fetching fares by Plaza ID at URL: $baseUrl', name: 'FareService');
    final url = Uri.parse(baseUrl).replace(queryParameters: {'plazaId': plazaId});
    developer.log('[FARE] Fetching fares by Plaza ID at URL: $url', name: 'FareService');
    developer.log('[FARE] Plaza ID: $plazaId', name: 'FareService');

    try {
      final headers = await _getHeaders();
      developer.log('[FARE] Request Headers: $headers', name: 'FareService');

      final response = await _client
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 30));

      developer.log('[FARE] Response Status Code: ${response.statusCode}', name: 'FareService');
      developer.log('[FARE] Response Body: ${response.body}', name: 'FareService');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          final List<PlazaFare> fares = (responseData['data'] as List)
              .map((fareJson) => PlazaFare.fromJson(fareJson))
              .toList();
          developer.log('[FARE] Successfully retrieved ${fares.length} fares', name: 'FareService');
          return fares;
        } else {
          developer.log('[FARE] No fares found for plaza ID: $plazaId', name: 'FareService');
          throw PlazaException('No fares found for plaza ID: $plazaId');
        }
      } else {
        final errorData = json.decode(response.body);
        developer.log('[FARE] Failed to get fares: ${errorData['message'] ?? 'Unknown error'}',
            name: 'FareService');
        throw HttpException(
          'Failed to get fares',
          statusCode: response.statusCode,
          serverMessage: errorData['message'],
        );
      }
    } on TimeoutException {
      developer.log('[FARE] Request timed out while fetching fares by plaza ID', name: 'FareService');
      throw RequestTimeoutException('Request timed out while fetching fares');
    } catch (e, stackTrace) {
      developer.log('[FARE] Error while getting fares by plaza ID: $e',
          name: 'FareService', error: e, stackTrace: stackTrace);
      throw ServiceException('Error getting fares: $e');
    }
  }

  /// Retrieves a fare by its ID.
  Future<PlazaFare> getFareById(int fareId) async {
    final url = ApiConfig.getFullUrl(PlazaApi.getFareById);
    final uri = Uri.parse(url).replace(queryParameters: {'fareId': fareId.toString()});
    developer.log('[FARE] Fetching fare by ID at URL: $uri', name: 'FareService');
    developer.log('[FARE] Fare ID: $fareId', name: 'FareService');

    try {
      final headers = await _getHeaders();
      developer.log('[FARE] Request Headers: $headers', name: 'FareService');

      final response = await _client
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 30));

      developer.log('[FARE] Response Status Code: ${response.statusCode}', name: 'FareService');
      developer.log('[FARE] Response Body: ${response.body}', name: 'FareService');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          final PlazaFare fare = PlazaFare.fromJson(responseData['data']);
          developer.log('[FARE] Successfully retrieved fare', name: 'FareService');
          return fare;
        } else {
          developer.log('[FARE] Fare not found with ID: $fareId', name: 'FareService');
          throw PlazaException('Fare not found with ID: $fareId');
        }
      } else {
        final errorData = json.decode(response.body);
        developer.log('[FARE] Failed to get fare: ${errorData['message'] ?? 'Unknown error'}',
            name: 'FareService');
        throw HttpException(
          'Failed to get fare',
          statusCode: response.statusCode,
          serverMessage: errorData['message'],
        );
      }
    } on TimeoutException {
      developer.log('[FARE] Request timed out while fetching fare by ID', name: 'FareService');
      throw RequestTimeoutException('Request timed out while fetching fare');
    } catch (e, stackTrace) {
      developer.log('[FARE] Error while getting fare by ID: $e',
          name: 'FareService', error: e, stackTrace: stackTrace);
      throw ServiceException('Error getting fare: $e');
    }
  }

  /// Updates an existing fare.
  Future<bool> updateFare(PlazaFare fare) async {
    if (fare.fareId == null) {
      developer.log('[FARE] Fare ID is required for update', name: 'FareService');
      throw PlazaException('Fare ID is required for update');
    }

    final url = ApiConfig.getFullUrl(PlazaApi.updateFare);
    developer.log('[FARE] Updating fare at URL: $url', name: 'FareService');
    developer.log('[FARE] Fare ID: ${fare.fareId}', name: 'FareService');

    try {
      final headers = await _getHeaders();
      final body = json.encode(fare.toJson());
      developer.log('[FARE] Request Headers: $headers', name: 'FareService');
      developer.log('[FARE] Request Body: $body', name: 'FareService');

      final response = await _client
          .put(
        Uri.parse(url),
        headers: headers,
        body: body,
      )
          .timeout(const Duration(seconds: 30));

      developer.log('[FARE] Response Status Code: ${response.statusCode}', name: 'FareService');
      developer.log('[FARE] Response Body: ${response.body}', name: 'FareService');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final bool success = responseData['success'] == true;
        developer.log('[FARE] Update operation ${success ? 'successful' : 'failed'}',
            name: 'FareService');
        return success;
      } else {
        final errorData = json.decode(response.body);
        developer.log('[FARE] Failed to update fare: ${errorData['message'] ?? 'Unknown error'}',
            name: 'FareService');
        throw HttpException(
          'Failed to update fare',
          statusCode: response.statusCode,
          serverMessage: errorData['message'],
        );
      }
    } on TimeoutException {
      developer.log('[FARE] Request timed out while updating fare', name: 'FareService');
      throw RequestTimeoutException('Request timed out while updating fare');
    } catch (e, stackTrace) {
      developer.log('[FARE] Error while updating fare: $e',
          name: 'FareService', error: e, stackTrace: stackTrace);
      throw ServiceException('Error updating fare: $e');
    }
  }

  /// Deletes a fare by its ID.
  Future<bool> deleteFare(int fareId) async {
    final url = ApiConfig.getFullUrl(PlazaApi.deleteFare);
    final uri = Uri.parse(url).replace(queryParameters: {'fareId': fareId.toString()});
    developer.log('[FARE] Deleting fare at URL: $uri', name: 'FareService');
    developer.log('[FARE] Fare ID: $fareId', name: 'FareService');

    try {
      final headers = await _getHeaders();
      developer.log('[FARE] Request Headers: $headers', name: 'FareService');

      final response = await _client
          .delete(uri, headers: headers)
          .timeout(const Duration(seconds: 30));

      developer.log('[FARE] Response Status Code: ${response.statusCode}', name: 'FareService');
      developer.log('[FARE] Response Body: ${response.body}', name: 'FareService');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final bool success = responseData['success'] == true;
        developer.log('[FARE] Delete operation ${success ? 'successful' : 'failed'}',
            name: 'FareService');
        return success;
      } else {
        final errorData = json.decode(response.body);
        developer.log('[FARE] Failed to delete fare: ${errorData['message'] ?? 'Unknown error'}',
            name: 'FareService');
        throw HttpException(
          'Failed to delete fare',
          statusCode: response.statusCode,
          serverMessage: errorData['message'],
        );
      }
    } on TimeoutException {
      developer.log('[FARE] Request timed out while deleting fare', name: 'FareService');
      throw RequestTimeoutException('Request timed out while deleting fare');
    } catch (e, stackTrace) {
      developer.log('[FARE] Error while deleting fare: $e',
          name: 'FareService', error: e, stackTrace: stackTrace);
      throw ServiceException('Error deleting fare: $e');
    }
  }
}