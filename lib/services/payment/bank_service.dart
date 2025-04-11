import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:merchant_app/services/storage/secure_storage_service.dart';
import '../../config/api_config.dart';
import '../../models/bank.dart';
import '../../utils/exceptions.dart';

class BankService {
  final http.Client _client;
  final SecureStorageService _secureStorage = SecureStorageService();

  BankService({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _secureStorage.getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> addBankDetails(Bank bank) async {
    final url = ApiConfig.getFullUrl(PlazaApi.addBankDetails); // /plaza/bank/addbankdetails
    developer.log('[BANK] Adding bank details at URL: $url', name: 'BankService');

    try {
      final headers = await _getHeaders();
      final body = json.encode(bank.toJson());
      developer.log('[BANK] Request Headers: $headers', name: 'BankService');
      developer.log('[BANK] Request Body: $body', name: 'BankService');

      final response = await _client
          .post(
        Uri.parse(url),
        headers: headers,
        body: body,
      )
          .timeout(const Duration(seconds: 30));

      developer.log('[BANK] Response Status Code: ${response.statusCode}', name: 'BankService');
      developer.log('[BANK] Response Body: ${response.body}', name: 'BankService');

      final responseBody = json.decode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 || response.statusCode == 201) {
        final success = responseBody['success'] == true;
        developer.log('[BANK] Add operation ${success ? 'successful' : 'failed'}', name: 'BankService');
        return responseBody; // Return full response
      } else {
        final errorMsg = responseBody['msg'] ?? 'Unknown error';
        developer.log('[BANK] Failed to add bank details: $errorMsg', name: 'BankService');
        throw HttpException(
          'Failed to add bank details: $errorMsg',
          statusCode: response.statusCode,
          serverMessage: errorMsg,
        );
      }
    } on TimeoutException {
      developer.log('[BANK] Request timed out while adding bank details', name: 'BankService');
      throw RequestTimeoutException('Request timed out while adding bank details');
    } catch (e, stackTrace) {
      developer.log('[BANK] Error while adding bank details: $e',
          name: 'BankService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Inside BankService class

  Future<Bank> getBankDetailsByPlazaId(String plazaId) async {
    final url = ApiConfig.getFullUrl(PlazaApi.getBankByPlaza); // /plaza/bank/pid
    final uri = Uri.parse(url).replace(queryParameters: {'plazaId': plazaId});
    developer.log('[BANK] Fetching bank details by Plaza ID at URL: $uri', name: 'BankService');
    developer.log('[BANK] Plaza ID: $plazaId', name: 'BankService');

    try {
      final headers = await _getHeaders();
      developer.log('[BANK] Request Headers: $headers', name: 'BankService');

      final response = await _client
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 30)); // Keep timeout

      developer.log('[BANK] Response Status Code: ${response.statusCode}', name: 'BankService');
      developer.log('[BANK] Response Body: ${response.body}', name: 'BankService');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        // Check for success true AND presence of data map
        if (responseData['success'] == true && responseData['data'] != null && responseData['data'] is Map<String, dynamic>) {
          developer.log('[BANK] Successfully retrieved bank details', name: 'BankService');
          return Bank.fromJson(responseData['data']);
        } else {
          // Handle cases where status is 200 but data is missing or success is false
          String message = responseData['message'] ?? 'Bank details data not found in successful response.';
          if (responseData['success'] == false && responseData['message'] != null) {
            message = responseData['message']; // Use server message if success is false
          }
          developer.log('[BANK] Failed to fetch: $message', name: 'BankService', level: 900);
          // Throw a ServiceException for logical errors in response, not HttpException
          throw ServiceException('Failed to fetch bank details: $message');
        }
      } else {
        // Handle non-200 status codes by throwing HttpException directly
        Map<String, dynamic>? errorData;
        String serverMsg = 'Unknown server error';
        try {
          errorData = json.decode(response.body);
          serverMsg = errorData?['message'] ?? serverMsg;
        } catch (_) {
          // Ignore JSON decode error if body is not valid JSON
          serverMsg = response.body.isNotEmpty ? response.body : serverMsg;
        }
        developer.log('[BANK] Failed with status code: ${response.statusCode}, message: $serverMsg', name: 'BankService');
        throw HttpException(
          'Failed to fetch bank details', // Keep default message consistent
          statusCode: response.statusCode,
          serverMessage: serverMsg,
        );
      }
    } on TimeoutException { // Catch specific exceptions first
      developer.log('[BANK] Request timed out while fetching bank details by plaza ID', name: 'BankService');
      throw RequestTimeoutException('Request timed out while fetching bank details');
    } on SocketException catch (e) { // Catch specific network errors
      developer.log('[BANK] SocketException fetching bank details: $e', name: 'BankService', error: e);
      throw ServerConnectionException('Failed to connect to bank service: $e');
    } on HttpException catch (e) { // Catch specific HttpException (less likely here now)
      developer.log('[BANK] HttpException caught: $e', name: 'BankService', error: e);
      rethrow; // Re-throw it as is
    } catch (e, stackTrace) { // Catch *other* unexpected errors (JSON parsing, etc.)
      developer.log('[BANK] Unexpected Error while fetching bank details by plaza ID: $e',
          name: 'BankService', error: e, stackTrace: stackTrace, level: 1000);
      // Wrap ONLY unexpected errors
      throw ServiceException('Unexpected error fetching bank details: $e');
    }
  }

  Future<Bank> getBankDetailsById(String id) async {
    final url = ApiConfig.getFullUrl(PlazaApi.getBankById); // /plaza/bank/id
    final uri = Uri.parse(url).replace(queryParameters: {'id': id});
    developer.log('[BANK] Fetching bank details by ID at URL: $uri', name: 'BankService');
    developer.log('[BANK] Bank ID: $id', name: 'BankService');

    try {
      final headers = await _getHeaders();
      developer.log('[BANK] Request Headers: $headers', name: 'BankService');

      final response = await _client
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 30));

      developer.log('[BANK] Response Status Code: ${response.statusCode}', name: 'BankService');
      developer.log('[BANK] Response Body: ${response.body}', name: 'BankService');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['bankDetails'] != null) {
          developer.log('[BANK] Successfully retrieved bank details', name: 'BankService');
          return Bank.fromJson(responseData['bankDetails']);
        } else {
          developer.log('[BANK] Invalid response format', name: 'BankService');
          throw HttpException('Failed to fetch bank details: Invalid response format');
        }
      } else {
        final errorData = json.decode(response.body);
        developer.log('[BANK] Failed with status code: ${response.statusCode}, message: ${errorData['message'] ?? 'Unknown error'}',
            name: 'BankService');
        throw HttpException(
          'Failed to fetch bank details',
          statusCode: response.statusCode,
          serverMessage: errorData['message'],
        );
      }
    } on TimeoutException {
      developer.log('[BANK] Request timed out while fetching bank details by ID', name: 'BankService');
      throw RequestTimeoutException('Request timed out while fetching bank details');
    } catch (e, stackTrace) {
      developer.log('[BANK] Error while fetching bank details by ID: $e',
          name: 'BankService', error: e, stackTrace: stackTrace);
      throw ServiceException('Error fetching bank details: $e');
    }
  }

  Future<bool> updateBankDetails(Bank bank) async {
    if (bank.id == null) {
      throw ArgumentError('Bank ID is required for update');
    }
    final url = ApiConfig.getFullUrl(PlazaApi.updateBank); // /plaza/bank/update
    developer.log('[BANK] Updating bank details at URL: $url', name: 'BankService');

    try {
      final headers = await _getHeaders();
      final body = json.encode(bank.toJson());
      developer.log('[BANK] Request Headers: $headers', name: 'BankService');
      developer.log('[BANK] Request Body: $body', name: 'BankService');

      final response = await _client
          .put(
        Uri.parse(url),
        headers: headers,
        body: body,
      )
          .timeout(const Duration(seconds: 30));

      developer.log('[BANK] Response Status Code: ${response.statusCode}', name: 'BankService');
      developer.log('[BANK] Response Body: ${response.body}', name: 'BankService');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = json.decode(response.body) as Map<String, dynamic>;
        final success = responseBody['success'] == true;
        developer.log('[BANK] Update operation ${success ? 'successful' : 'failed'}', name: 'BankService');
        return success;
      } else {
        final errorData = json.decode(response.body) as Map<String, dynamic>;
        final errorMsg = errorData['msg'] ?? 'Unknown error';
        developer.log('[BANK] Failed to update bank details: $errorMsg', name: 'BankService');
        throw HttpException(
          'Failed to update bank details: $errorMsg',
          statusCode: response.statusCode,
          serverMessage: errorMsg,
        );
      }
    } on TimeoutException {
      developer.log('[BANK] Request timed out while updating bank details', name: 'BankService');
      throw RequestTimeoutException('Request timed out while updating bank details');
    } catch (e, stackTrace) {
      developer.log('[BANK] Error while updating bank details: $e',
          name: 'BankService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<bool> deleteBankDetails(String id) async {
    final url = ApiConfig.getFullUrl(PlazaApi.deleteBank); // /plaza/bank/delete
    final uri = Uri.parse(url).replace(queryParameters: {'id': id});
    developer.log('[BANK] Deleting bank details at URL: $uri', name: 'BankService');
    developer.log('[BANK] Bank ID: $id', name: 'BankService');

    try {
      final headers = await _getHeaders();
      developer.log('[BANK] Request Headers: $headers', name: 'BankService');

      final response = await _client
          .delete(uri, headers: headers)
          .timeout(const Duration(seconds: 30));

      developer.log('[BANK] Response Status Code: ${response.statusCode}', name: 'BankService');
      developer.log('[BANK] Response Body: ${response.body}', name: 'BankService');

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body) as Map<String, dynamic>;
        final success = responseBody['success'] == true;
        developer.log('[BANK] Delete operation ${success ? 'successful' : 'failed'}', name: 'BankService');
        return success;
      } else {
        final errorData = json.decode(response.body);
        developer.log('[BANK] Failed to delete with status: ${response.statusCode}, message: ${errorData['message'] ?? 'Unknown error'}',
            name: 'BankService');
        throw HttpException(
          'Failed to delete bank details',
          statusCode: response.statusCode,
          serverMessage: errorData['message'],
        );
      }
    } on TimeoutException {
      developer.log('[BANK] Request timed out while deleting bank details', name: 'BankService');
      throw RequestTimeoutException('Request timed out while deleting bank details');
    } catch (e, stackTrace) {
      developer.log('[BANK] Error while deleting bank details: $e',
          name: 'BankService', error: e, stackTrace: stackTrace);
      throw ServiceException('Error deleting bank details: $e');
    }
  }

  Future<List<Bank>> getAllBankDetails() async {
    // Note: Using PlazaApi.getBankByPlaza as a base since there's no direct "all" endpoint
    final url = ApiConfig.getFullUrl(PlazaApi.getBankByPlaza); // Adjust if a specific "all" endpoint exists
    developer.log('[BANK] Fetching all bank details at URL: $url', name: 'BankService');

    try {
      final headers = await _getHeaders();
      developer.log('[BANK] Request Headers: $headers', name: 'BankService');

      final response = await _client
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 30));

      developer.log('[BANK] Response Status Code: ${response.statusCode}', name: 'BankService');
      developer.log('[BANK] Response Body: ${response.body}', name: 'BankService');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['bankDetails'] != null) {
          final List<dynamic> bankDetailsJson = responseData['bankDetails'];
          developer.log('[BANK] Successfully retrieved ${bankDetailsJson.length} bank details',
              name: 'BankService');
          return bankDetailsJson.map((json) => Bank.fromJson(json)).toList();
        } else {
          developer.log('[BANK] Invalid response format', name: 'BankService');
          throw HttpException('Failed to fetch bank details: Invalid response format');
        }
      } else {
        final errorData = json.decode(response.body);
        developer.log('[BANK] Failed with status code: ${response.statusCode}, message: ${errorData['message'] ?? 'Unknown error'}',
            name: 'BankService');
        throw HttpException(
          'Failed to fetch bank details',
          statusCode: response.statusCode,
          serverMessage: errorData['message'],
        );
      }
    } on TimeoutException {
      developer.log('[BANK] Request timed out while fetching all bank details', name: 'BankService');
      throw RequestTimeoutException('Request timed out while fetching all bank details');
    } catch (e, stackTrace) {
      developer.log('[BANK] Error while fetching all bank details: $e',
          name: 'BankService', error: e, stackTrace: stackTrace);
      throw ServiceException('Error fetching bank details: $e');
    }
  }

  Future<bool> verifyBankDetails(String bankDetailsId) async {
    final url = ApiConfig.getFullUrl('${PlazaApi.bankBasePath}verify/$bankDetailsId');
    developer.log('[BANK] Verifying bank details at URL: $url', name: 'BankService');
    developer.log('[BANK] Bank Details ID: $bankDetailsId', name: 'BankService');

    try {
      final headers = await _getHeaders();
      developer.log('[BANK] Request Headers: $headers', name: 'BankService');

      final response = await _client
          .post(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 30));

      developer.log('[BANK] Response Status Code: ${response.statusCode}', name: 'BankService');
      developer.log('[BANK] Response Body: ${response.body}', name: 'BankService');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final success = responseData['success'] == true;
        developer.log('[BANK] Verification ${success ? 'successful' : 'failed'}', name: 'BankService');
        return success;
      } else {
        final errorData = json.decode(response.body);
        developer.log('[BANK] Failed to verify with status: ${response.statusCode}, message: ${errorData['message'] ?? 'Unknown error'}',
            name: 'BankService');
        throw HttpException(
          'Failed to verify bank details',
          statusCode: response.statusCode,
          serverMessage: errorData['message'],
        );
      }
    } on TimeoutException {
      developer.log('[BANK] Request timed out while verifying bank details', name: 'BankService');
      throw RequestTimeoutException('Request timed out while verifying bank details');
    } catch (e, stackTrace) {
      developer.log('[BANK] Error while verifying bank details: $e',
          name: 'BankService', error: e, stackTrace: stackTrace);
      throw ServiceException('Error verifying bank details: $e');
    }
  }
}