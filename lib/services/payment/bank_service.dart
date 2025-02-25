import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:merchant_app/services/storage/secure_storage_service.dart';
import '../../config/api_config.dart';
import '../../models/bank.dart';
import '../../utils/exceptions.dart';

class BankService {
  final http.Client _client;

  BankService({http.Client? client}) : _client = client ?? http.Client();

  Future<bool> addBankDetails(Bank bank) async {
    final url = ApiConfig.getFullUrl(ApiConfig.addBankDetailsEndpoint);
    print('[BANK] Adding bank details at URL: $url');

    try {
      final body = json.encode(bank.toJson());
      print('[BANK] Request Body: $body');

      final response = await _client.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print('[BANK] Response Status Code: ${response.statusCode}');
      print('[BANK] Response Body: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        print('[BANK] ERROR: Failed to add bank details with status: ${response.statusCode}');
        throw HttpException('Failed to add bank details: ${response.statusCode}');
      }

      final responseBody = json.decode(response.body) as Map<String, dynamic>;
      final success = responseBody['success'] == true;
      print('[BANK] Operation ${success ? 'successful' : 'failed'}');
      return success;
    } catch (e) {
      print('[BANK] ERROR: Exception while adding bank details: $e');
      throw ServiceException('Error adding bank details: $e');
    }
  }
  final SecureStorageService _secureStorage = SecureStorageService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _secureStorage.getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Bank> getBankDetailsByPlazaId(String plazaId) async {
    final url = ApiConfig.getFullUrl(ApiConfig.getBankDetailsByPlazaIdEndpoint);
    final uri = Uri.parse(url).replace(queryParameters: {'plazaId': plazaId});
    print('[BANK] Fetching bank details by Plaza ID at URL: $uri');
    print('[BANK] Plaza ID: $plazaId');

    try {
      final headers = await _getHeaders();  // Use the new headers method
      final response = await _client.get(
        uri,
        headers: headers,
      );

      print('[BANK] Response Status Code: ${response.statusCode}');
      print('[BANK] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          print('[BANK] Successfully retrieved bank details');
          return Bank.fromJson(responseData['data']);
        } else {
          print('[BANK] ERROR: Data not found in response');
          throw HttpException('Failed to fetch bank details: Data not found in response');
        }
      } else {
        print('[BANK] ERROR: Failed with status code: ${response.statusCode}');
        throw HttpException('Failed to fetch bank details: ${response.statusCode}');
      }
    } catch (e) {
      print('[BANK] ERROR: Exception while fetching bank details: $e');
      throw ServiceException('Error fetching bank details: $e');
    }
  }

  Future<Bank> getBankDetailsById(String id) async {
    final url = ApiConfig.getFullUrl(ApiConfig.getBankDetailsByIdEndpoint);
    final uri = Uri.parse(url).replace(queryParameters: {'id': id});
    print('[BANK] Fetching bank details by ID at URL: $uri');

    try {
      final response = await _client.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      print('[BANK] Response Status Code: ${response.statusCode}');
      print('[BANK] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['bankDetails'] != null) {
          print('[BANK] Successfully retrieved bank details');
          return Bank.fromJson(responseData['bankDetails']);
        } else {
          print('[BANK] ERROR: Invalid response format');
          throw HttpException('Failed to fetch bank details: Invalid response format');
        }
      } else {
        print('[BANK] ERROR: Failed with status code: ${response.statusCode}');
        throw HttpException('Failed to fetch bank details: ${response.statusCode}');
      }
    } catch (e) {
      print('[BANK] ERROR: Exception while fetching bank details: $e');
      throw ServiceException('Error fetching bank details: $e');
    }
  }

  Future<bool> updateBankDetails(Bank bank) async {
    final url = ApiConfig.getFullUrl(ApiConfig.updateBankDetailsEndpoint);
    print('[BANK] Updating bank details at URL: $url');

    try {
      final body = json.encode(bank.toJson());
      print('[BANK] Request Body: $body');

      final response = await _client.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print('[BANK] Response Status Code: ${response.statusCode}');
      print('[BANK] Response Body: ${response.body}');

      if (response.statusCode != 200) {
        print('[BANK] ERROR: Failed to update with status: ${response.statusCode}');
        throw HttpException('Failed to update bank details: ${response.statusCode}');
      }

      final responseBody = json.decode(response.body) as Map<String, dynamic>;
      final success = responseBody['success'] == true;
      print('[BANK] Update operation ${success ? 'successful' : 'failed'}');
      return success;
    } catch (e) {
      print('[BANK] ERROR: Exception while updating bank details: $e');
      throw ServiceException('Error updating bank details: $e');
    }
  }

  Future<bool> deleteBankDetails(String id) async {
    final url = ApiConfig.getFullUrl(ApiConfig.deleteBankDetailsEndpoint);
    final uri = Uri.parse(url).replace(queryParameters: {'id': id});
    print('[BANK] Deleting bank details at URL: $uri');

    try {
      final response = await _client.delete(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      print('[BANK] Response Status Code: ${response.statusCode}');
      print('[BANK] Response Body: ${response.body}');

      if (response.statusCode != 200) {
        print('[BANK] ERROR: Failed to delete with status: ${response.statusCode}');
        throw HttpException('Failed to delete bank details: ${response.statusCode}');
      }

      final responseBody = json.decode(response.body) as Map<String, dynamic>;
      final success = responseBody['success'] == true;
      print('[BANK] Delete operation ${success ? 'successful' : 'failed'}');
      return success;
    } catch (e) {
      print('[BANK] ERROR: Exception while deleting bank details: $e');
      throw ServiceException('Error deleting bank details: $e');
    }
  }

  Future<List<Bank>> getAllBankDetails() async {
    final url = ApiConfig.getFullUrl('plaza/bank/all'); // Add this endpoint to ApiConfig if needed
    print('[BANK] Fetching all bank details at URL: $url');

    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      print('[BANK] Response Status Code: ${response.statusCode}');
      print('[BANK] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['bankDetails'] != null) {
          final List<dynamic> bankDetailsJson = responseData['bankDetails'];
          print('[BANK] Successfully retrieved ${bankDetailsJson.length} bank details');
          return bankDetailsJson.map((json) => Bank.fromJson(json)).toList();
        } else {
          print('[BANK] ERROR: Invalid response format');
          throw HttpException('Failed to fetch bank details: Invalid response format');
        }
      } else {
        print('[BANK] ERROR: Failed with status code: ${response.statusCode}');
        throw HttpException('Failed to fetch bank details: ${response.statusCode}');
      }
    } catch (e) {
      print('[BANK] ERROR: Exception while fetching all bank details: $e');
      throw ServiceException('Error fetching bank details: $e');
    }
  }

  Future<bool> verifyBankDetails(String bankDetailsId) async {
    final url = ApiConfig.getFullUrl('plaza/bank/verify/$bankDetailsId'); // Add this endpoint to ApiConfig if needed
    print('[BANK] Verifying bank details at URL: $url');

    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      print('[BANK] Response Status Code: ${response.statusCode}');
      print('[BANK] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final success = responseData['success'] == true;
        print('[BANK] Verification ${success ? 'successful' : 'failed'}');
        return success;
      } else {
        print('[BANK] ERROR: Failed to verify with status: ${response.statusCode}');
        throw HttpException('Failed to verify bank details: ${response.statusCode}');
      }
    } catch (e) {
      print('[BANK] ERROR: Exception while verifying bank details: $e');
      throw ServiceException('Error verifying bank details: $e');
    }
  }
}