  import 'dart:convert';
  import 'package:http/http.dart' as http;
  import '../models/plaza.dart';
  import '../config/api_config.dart';
  import '../utils/exceptions.dart';
  
  class PlazaService {
    final http.Client _client;
    final String baseUrl = ApiConfig.apiGateway;
  
    PlazaService({http.Client? client}) : _client = client ?? http.Client();
  
    Future<List<Plaza>> fetchUserPlazas(String userId) async {
      try {
        final fullUrl = '${ApiConfig.getFullUrl(ApiConfig.getPlazaByOwnerIdEndpoint)}$userId';
  
        print('Request - Fetch User Plazas:');
        print('  Base URL: $baseUrl');
        print('  Endpoint: ${ApiConfig.getPlazaByOwnerIdEndpoint}$userId');
        print('  Full URL: $fullUrl');
        print('  User ID: $userId');
  
        final response = await _client.get(
          Uri.parse(fullUrl),
          headers: {'Content-Type': 'application/json'},
        );
  
        print('Response - Fetch User Plazas:');
        print('  Status Code: ${response.statusCode}');
        print('  Body: ${response.body}');
  
        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = json.decode(response.body);
          print('  Decoded response data: $responseData');
  
          if (responseData['success'] == true) {
            final List<dynamic> plazaJson = responseData['plazas'];
            print('  Found ${plazaJson.length} plazas in response');
  
            final plazas = plazaJson.map((json) => Plaza.fromJson(json)).toList();
            print('  Successfully converted all plazas');
            return plazas;
          }
  
          throw HttpException('Failed to fetch plazas: Invalid response format');
        }
        throw HttpException('Failed to fetch plazas: ${response.statusCode}');
      } catch (e) {
        print('Error - Fetch User Plazas:');
        print('  Error details: $e');
        throw PlazaException('Error fetching plazas: $e');
      }
    }
  
    Future<Plaza> getPlazaById(String plazaId) async {
      try {
        final fullUrl = '${ApiConfig.getFullUrl(ApiConfig.getPlazaEndpoint)}$plazaId';
  
        print('Request - Get Plaza By ID:');
        print('  Base URL: $baseUrl');
        print('  Endpoint: ${ApiConfig.getPlazaEndpoint}$plazaId');
        print('  Full URL: $fullUrl');
        print('  Plaza ID: $plazaId');
  
        final response = await _client.get(
          Uri.parse(fullUrl),
          headers: {'Content-Type': 'application/json'},
        );
  
        print('Response - Get Plaza By ID:');
        print('  Status Code: ${response.statusCode}');
        print('  Body: ${response.body}');
  
        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = json.decode(response.body);
          if (responseData['success'] == true && responseData['plaza'] != null) {
            return Plaza.fromJson(responseData['plaza']);
          }
          throw HttpException('Failed to fetch plaza: Invalid response format');
        }
        throw HttpException('Failed to fetch plaza: ${response.statusCode}');
      } catch (e) {
        print('Error - Get Plaza By ID:');
        print('  Error details: $e');
        throw PlazaException('Error fetching plaza: $e');
      }
    }
  
    Future<String> addPlaza(Plaza plaza) async {
      try {
        final fullUrl = ApiConfig.getFullUrl(ApiConfig.createPlazaEndpoint);
        final body = json.encode(plaza.toJson());
  
        print('Request - Add Plaza:');
        print('  Base URL: $baseUrl');
        print('  Endpoint: ${ApiConfig.createPlazaEndpoint}');
        print('  Full URL: $fullUrl');
        print('  Body: $body');
  
        final response = await _client.post(
          Uri.parse(fullUrl),
          headers: {'Content-Type': 'application/json'},
          body: body,
        );
  
        print('Response - Add Plaza:');
        print('  Status Code: ${response.statusCode}');
        print('  Body: ${response.body}');
  
        if (response.statusCode != 201) {
          throw HttpException('Failed to add plaza: ${response.statusCode}');
        }
  
        final responseBody = json.decode(response.body) as Map<String, dynamic>;
        if (responseBody['success'] == true && responseBody['plaza'] != null) {
          return responseBody['plaza']['plazaId'].toString();
        }
        throw PlazaException('Plaza creation failed: ${responseBody['msg']}');
      } catch (e) {
        print('Error - Add Plaza:');
        print('  Error details: $e');
        throw PlazaException('Error adding plaza: $e');
      }
    }
  
    Future<bool> updatePlaza(Plaza plaza, String plazaId) async {
      try {
        final fullUrl = '${ApiConfig.getFullUrl(ApiConfig.updatePlazaEndpoint)}$plazaId';
        final body = json.encode(plaza.toJson());
  
        print('Request - Update Plaza:');
        print('  Base URL: $baseUrl');
        print('  Endpoint: ${ApiConfig.updatePlazaEndpoint}$plazaId');
        print('  Full URL: $fullUrl');
        print('  Plaza ID: $plazaId');
        print('  Body: $body');
  
        final response = await _client.put(
          Uri.parse(fullUrl),
          headers: {'Content-Type': 'application/json'},
          body: body,
        );
  
        print('Response - Update Plaza:');
        print('  Status Code: ${response.statusCode}');
        print('  Body: ${response.body}');
  
        if (response.statusCode != 200) {
          throw HttpException('Failed to update plaza: ${response.statusCode}');
        }
        return true;
      } catch (e) {
        print('Error - Update Plaza:');
        print('  Error details: $e');
        throw PlazaException('Error updating plaza: $e');
      }
    }
  
    Future<void> deletePlaza(String plazaId) async {
      try {
        final fullUrl = '${ApiConfig.getFullUrl(ApiConfig.deletePlazaEndpoint)}$plazaId';
  
        print('Request - Delete Plaza:');
        print('  Base URL: $baseUrl');
        print('  Endpoint: ${ApiConfig.deletePlazaEndpoint}$plazaId');
        print('  Full URL: $fullUrl');
        print('  Plaza ID: $plazaId');
  
        final response = await _client.delete(
          Uri.parse(fullUrl),
          headers: {'Content-Type': 'application/json'},
        );
  
        print('Response - Delete Plaza:');
        print('  Status Code: ${response.statusCode}');
        print('  Body: ${response.body}');
  
        if (response.statusCode != 200) {
          throw HttpException('Failed to delete plaza: ${response.statusCode}');
        }
      } catch (e) {
        print('Error - Delete Plaza:');
        print('  Error details: $e');
        throw PlazaException('Error deleting plaza: $e');
      }
    }
  
    Future<List<String>> getAllPlazaOwners() async {
      try {
        final fullUrl = ApiConfig.getFullUrl(ApiConfig.getAllPlazaOwnersEndpoint);
  
        print('Request - Get All Plaza Owners:');
        print('  Base URL: $baseUrl');
        print('  Endpoint: ${ApiConfig.getAllPlazaOwnersEndpoint}');
        print('  Full URL: $fullUrl');
  
        final response = await _client.get(
          Uri.parse(fullUrl),
          headers: {'Content-Type': 'application/json'},
        );
  
        print('Response - Get All Plaza Owners:');
        print('  Status Code: ${response.statusCode}');
        print('  Body: ${response.body}');
  
        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = json.decode(response.body);
          if (responseData['success'] == true && responseData['owners'] != null) {
            return List<String>.from(responseData['owners']);
          }
          throw HttpException('Failed to fetch plaza owners: Invalid response format');
        }
        throw HttpException('Failed to fetch plaza owners: ${response.statusCode}');
      } catch (e) {
        print('Error - Get All Plaza Owners:');
        print('  Error details: $e');
        throw PlazaException('Error fetching plaza owners: $e');
      }
    }
  }