import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../config/api_config.dart';
import '../../models/dispute.dart';
import '../../utils/exceptions.dart';
import '../network/connectivity_service.dart';
import '../storage/secure_storage_service.dart';

class DisputesService {
  final http.Client _client;
  final ConnectivityService _connectivityService;
  final SecureStorageService _secureStorageService;

  DisputesService({
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

  Future<Dispute> createDispute(Dispute dispute, {List<String> uploadedFiles = const []}) async {
    final url = ApiConfig.getFullUrl(DisputesApi.createDispute);
    final serverUrl = Uri.parse(url);

    if (!(await _connectivityService.isConnected())) {
      throw NoInternetException('No internet connection. Please check your network settings.');
    }
    if (!(await _connectivityService.canReachServer(serverUrl.host))) {
      throw ServerConnectionException('Cannot reach the disputes server.', host: serverUrl.host);
    }

    final validationError = dispute.validateForCreate();
    if (validationError != null) {
      throw ServiceException('Invalid dispute data: $validationError');
    }

    developer.log('[DISPUTE] Creating dispute at URL: $url', name: 'DisputesService');

    try {
      var request = http.MultipartRequest('POST', serverUrl);
      final headers = await _getHeaders();
      headers['Accept'] = 'application/json';
      headers['Content-Type'] = 'multipart/form-data';
      request.headers.addAll(headers);
      developer.log('[DISPUTE] Headers Sent: $headers', name: 'DisputesService');

      request.fields['dispute'] = jsonEncode(dispute.toJsonForCreate());
      developer.log('[DISPUTE] Dispute Data: ${request.fields['dispute']}', name: 'DisputesService');

      for (var i = 0; i < uploadedFiles.length; i++) {
        final file = File(uploadedFiles[i]);
        if (await file.exists()) {
          final ext = file.path.split('.').last.toLowerCase();
          if (!['jpeg', 'jpg', 'png', 'pdf'].contains(ext)) {
            throw ServiceException('Unsupported file type: $ext');
          }
          developer.log(
            '[DISPUTE] Adding file $i: ${uploadedFiles[i]} (Extension: $ext)',
            name: 'DisputesService',
          );
          request.files.add(await http.MultipartFile.fromPath(
            'uploadedFiles',
            file.path,
            filename: 'dispute_file_$i.$ext',
            contentType: MediaType(ext == 'pdf' ? 'application' : 'image', ext),
          ));
        } else {
          developer.log('[DISPUTE] File $i not found: ${uploadedFiles[i]}', name: 'DisputesService');
          throw ServiceException('File not found: ${uploadedFiles[i]}');
        }
      }

      developer.log('[DISPUTE] Request Fields: ${request.fields}', name: 'DisputesService');
      developer.log('[DISPUTE] Request Files: ${request.files.map((f) => f.filename).toList()}', name: 'DisputesService');

      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);

      developer.log('[DISPUTE] Response Status Code: ${response.statusCode}', name: 'DisputesService');
      developer.log('[DISPUTE] Response Body: ${response.body}', name: 'DisputesService');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          if (responseData['dispute'] != null) {
            final createdDispute = Dispute.fromJson(responseData['dispute']);
            developer.log('[DISPUTE] Successfully created dispute: ${createdDispute.disputeId}', name: 'DisputesService');
            return createdDispute;
          }
          // Handle case where success is true but dispute data is not returned
          developer.log('[DISPUTE] Dispute created but no dispute data returned', name: 'DisputesService');
          return dispute; // Return the input dispute as a fallback
        }
        throw ServiceException(responseData['message'] ?? 'Invalid response format');
      }

      throw _handleErrorResponse(response, 'Failed to create dispute');
    } on SocketException catch (e, stackTrace) {
      developer.log('[DISPUTE] SocketException: Failed to connect to server: $e',
          name: 'DisputesService', error: e, stackTrace: stackTrace);
      throw ServerConnectionException('Failed to connect to the disputes server: $e');
    } on TimeoutException catch (e, stackTrace) {
      developer.log('[DISPUTE] TimeoutException: Request timed out after 30 seconds',
          name: 'DisputesService', error: e, stackTrace: stackTrace);
      throw RequestTimeoutException('Request timed out');
    } catch (e, stackTrace) {
      developer.log('[DISPUTE] Error in createDispute: $e',
          name: 'DisputesService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<List<Dispute>> getAllOpenDisputes() async {
    final url = ApiConfig.getFullUrl(DisputesApi.getDisputesByUser);
    final serverUrl = Uri.parse(url);

    if (!(await _connectivityService.isConnected())) {
      throw NoInternetException('No internet connection. Please check your network settings.');
    }
    if (!(await _connectivityService.canReachServer(serverUrl.host))) {
      throw ServerConnectionException('Cannot reach the disputes server.', host: serverUrl.host);
    }

    developer.log('[DISPUTE] Fetching all open disputes at URL: $url', name: 'DisputesService');

    try {
      final headers = await _getHeaders();
      developer.log('[DISPUTE] Headers Sent: $headers', name: 'DisputesService');
      final response = await _client.get(
        serverUrl,
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      developer.log('[DISPUTE] Response Status Code: ${response.statusCode}', name: 'DisputesService');
      developer.log('[DISPUTE] Response Body: ${response.body}', name: 'DisputesService');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['data'] != null) {
          final List<Dispute> disputes = (responseData['data'] as List)
              .map((disputeJson) => Dispute.fromJson(disputeJson))
              .toList();
          for (var dispute in disputes) {
            final validationError = dispute.validateForUpdate();
            if (validationError != null) {
              throw ServiceException('Invalid dispute data: $validationError');
            }
          }
          developer.log('[DISPUTE] Successfully retrieved ${disputes.length} open disputes', name: 'DisputesService');
          return disputes;
        }
        developer.log('[DISPUTE] No disputes in response, returning empty list', name: 'DisputesService');
        return [];
      }

      throw _handleErrorResponse(response, 'Failed to fetch open disputes');
    } on SocketException catch (e, stackTrace) {
      developer.log('[DISPUTE] SocketException: Failed to connect to server: $e',
          name: 'DisputesService', error: e, stackTrace: stackTrace);
      throw ServerConnectionException('Failed to connect to the disputes server: $e');
    } on TimeoutException catch (e, stackTrace) {
      developer.log('[DISPUTE] TimeoutException: Request timed out after 10 seconds',
          name: 'DisputesService', error: e, stackTrace: stackTrace);
      throw RequestTimeoutException('Request timed out');
    } catch (e, stackTrace) {
      developer.log('[DISPUTE] Error in getAllOpenDisputes: $e',
          name: 'DisputesService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<Dispute> getDisputeById(String disputeId) async {
    final url = Uri.parse(ApiConfig.getFullUrl(DisputesApi.getDisputeById)).replace(queryParameters: {'disputeId': disputeId});
    final serverUrl = url;

    if (!(await _connectivityService.isConnected())) {
      throw NoInternetException('No internet connection. Please check your network settings.');
    }
    if (!(await _connectivityService.canReachServer(serverUrl.host))) {
      throw ServerConnectionException('Cannot reach the disputes server.', host: serverUrl.host);
    }

    developer.log('[DISPUTE] Fetching dispute details at URL: $url', name: 'DisputesService');

    try {
      final headers = await _getHeaders();
      developer.log('[DISPUTE] Headers Sent: $headers', name: 'DisputesService');
      final response = await _client.get(
        serverUrl,
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      developer.log('[DISPUTE] Response Status Code: ${response.statusCode}', name: 'DisputesService');
      developer.log('[DISPUTE] Response Body: ${response.body}', name: 'DisputesService');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          final dispute = Dispute.fromJson(responseData['data']);
          final validationError = dispute.validateForUpdate();
          if (validationError != null) {
            throw ServiceException('Invalid dispute data: $validationError');
          }
          developer.log('[DISPUTE] Successfully retrieved dispute: $disputeId', name: 'DisputesService');
          return dispute;
        }
        throw ServiceException('Dispute not found with ID: $disputeId');
      }

      throw _handleErrorResponse(response, 'Failed to fetch dispute details');
    } on SocketException catch (e, stackTrace) {
      developer.log('[DISPUTE] SocketException: Failed to connect to server: $e',
          name: 'DisputesService', error: e, stackTrace: stackTrace);
      throw ServerConnectionException('Failed to connect to the disputes server: $e');
    } on TimeoutException catch (e, stackTrace) {
      developer.log('[DISPUTE] TimeoutException: Request timed out after 10 seconds',
          name: 'DisputesService', error: e, stackTrace: stackTrace);
      throw RequestTimeoutException('Request timed out');
    } catch (e, stackTrace) {
      developer.log('[DISPUTE] Error in getDisputeById: $e',
          name: 'DisputesService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<List<Dispute>> getDisputesByPlaza(String plazaId) async {
    final url = Uri.parse(ApiConfig.getFullUrl(DisputesApi.getDisputesByPlaza)).replace(queryParameters: {'plazaId': plazaId});
    final serverUrl = url;

    if (!(await _connectivityService.isConnected())) {
      throw NoInternetException('No internet connection. Please check your network settings.');
    }
    if (!(await _connectivityService.canReachServer(serverUrl.host))) {
      throw ServerConnectionException('Cannot reach the disputes server.', host: serverUrl.host);
    }

    developer.log('[DISPUTE] Fetching disputes by plaza at URL: $url', name: 'DisputesService');

    try {
      final headers = await _getHeaders();
      developer.log('[DISPUTE] Headers Sent: $headers', name: 'DisputesService');
      final response = await _client.get(
        serverUrl,
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      developer.log('[DISPUTE] Response Status Code: ${response.statusCode}', name: 'DisputesService');
      developer.log('[DISPUTE] Response Body: ${response.body}', name: 'DisputesService');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['data'] != null) {
          final List<Dispute> disputes = (responseData['data'] as List)
              .map((disputeJson) => Dispute.fromJson(disputeJson))
              .toList();
          for (var dispute in disputes) {
            final validationError = dispute.validateForUpdate();
            if (validationError != null) {
              throw ServiceException('Invalid dispute data: $validationError');
            }
          }
          developer.log('[DISPUTE] Successfully retrieved ${disputes.length} disputes for plaza: $plazaId', name: 'DisputesService');
          return disputes;
        }
        developer.log('[DISPUTE] No disputes in response, returning empty list', name: 'DisputesService');
        return [];
      }

      throw _handleErrorResponse(response, 'Failed to fetch disputes by plaza');
    } on SocketException catch (e, stackTrace) {
      developer.log('[DISPUTE] SocketException: Failed to connect to server: $e',
          name: 'DisputesService', error: e, stackTrace: stackTrace);
      throw ServerConnectionException('Failed to connect to the disputes server: $e');
    } on TimeoutException catch (e, stackTrace) {
      developer.log('[DISPUTE] TimeoutException: Request timed out after 10 seconds',
          name: 'DisputesService', error: e, stackTrace: stackTrace);
      throw RequestTimeoutException('Request timed out');
    } catch (e, stackTrace) {
      developer.log('[DISPUTE] Error in getDisputesByPlaza: $e',
          name: 'DisputesService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<List<Dispute>> getDisputesByTicket(String ticketId) async {
    final url = Uri.parse(ApiConfig.getFullUrl(DisputesApi.getDisputesByTicket)).replace(queryParameters: {'ticketId': ticketId});
    final serverUrl = url;

    if (!(await _connectivityService.isConnected())) {
      throw NoInternetException('No internet connection. Please check your network settings.');
    }
    if (!(await _connectivityService.canReachServer(serverUrl.host))) {
      throw ServerConnectionException('Cannot reach the disputes server.', host: serverUrl.host);
    }

    developer.log('[DISPUTE] Fetching disputes by ticket at URL: $url', name: 'DisputesService');

    try {
      final headers = await _getHeaders();
      developer.log('[DISPUTE] Headers Sent: $headers', name: 'DisputesService');
      final response = await _client.get(
        serverUrl,
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      developer.log('[DISPUTE] Response Status Code: ${response.statusCode}', name: 'DisputesService');
      developer.log('[DISPUTE] Response Body: ${response.body}', name: 'DisputesService');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['data'] != null) {
          final List<Dispute> disputes = (responseData['data'] as List)
              .map((disputeJson) => Dispute.fromJson(disputeJson))
              .toList();
          for (var dispute in disputes) {
            final validationError = dispute.validateForUpdate();
            if (validationError != null) {
              throw ServiceException('Invalid dispute data: $validationError');
            }
          }
          developer.log('[DISPUTE] Successfully retrieved ${disputes.length} disputes for ticket: $ticketId', name: 'DisputesService');
          return disputes;
        }
        developer.log('[DISPUTE] No disputes in response, returning empty list', name: 'DisputesService');
        return [];
      }

      throw _handleErrorResponse(response, 'Failed to fetch disputes by ticket');
    } on SocketException catch (e, stackTrace) {
      developer.log('[DISPUTE] SocketException: Failed to connect to server: $e',
          name: 'DisputesService', error: e, stackTrace: stackTrace);
      throw ServerConnectionException('Failed to connect to the disputes server: $e');
    } on TimeoutException catch (e, stackTrace) {
      developer.log('[DISPUTE] TimeoutException: Request timed out after 10 seconds',
          name: 'DisputesService', error: e, stackTrace: stackTrace);
      throw RequestTimeoutException('Request timed out');
    } catch (e, stackTrace) {
      developer.log('[DISPUTE] Error in getDisputesByTicket: $e',
          name: 'DisputesService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<List<Dispute>> getDisputesByVehicleNumber(String vehicleNumber) async {
    final url = Uri.parse(ApiConfig.getFullUrl(DisputesApi.getDisputesByVehicleNumber)).replace(queryParameters: {'vehicleNumber': vehicleNumber});
    final serverUrl = url;

    if (!(await _connectivityService.isConnected())) {
      throw NoInternetException('No internet connection. Please check your network settings.');
    }
    if (!(await _connectivityService.canReachServer(serverUrl.host))) {
      throw ServerConnectionException('Cannot reach the disputes server.', host: serverUrl.host);
    }

    developer.log('[DISPUTE] Fetching disputes by vehicle number at URL: $url', name: 'DisputesService');

    try {
      final headers = await _getHeaders();
      developer.log('[DISPUTE] Headers Sent: $headers', name: 'DisputesService');
      final response = await _client.get(
        serverUrl,
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      developer.log('[DISPUTE] Response Status Code: ${response.statusCode}', name: 'DisputesService');
      developer.log('[DISPUTE] Response Body: ${response.body}', name: 'DisputesService');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['data'] != null) {
          final List<Dispute> disputes = (responseData['data'] as List)
              .map((disputeJson) => Dispute.fromJson(disputeJson))
              .toList();
          for (var dispute in disputes) {
            final validationError = dispute.validateForUpdate();
            if (validationError != null) {
              throw ServiceException('Invalid dispute data: $validationError');
            }
          }
          developer.log('[DISPUTE] Successfully retrieved ${disputes.length} disputes for vehicle: $vehicleNumber', name: 'DisputesService');
          return disputes;
        }
        developer.log('[DISPUTE] No disputes in response, returning empty list', name: 'DisputesService');
        return [];
      }

      throw _handleErrorResponse(response, 'Failed to fetch disputes by vehicle number');
    } on SocketException catch (e, stackTrace) {
      developer.log('[DISPUTE] SocketException: Failed to connect to server: $e',
          name: 'DisputesService', error: e, stackTrace: stackTrace);
      throw ServerConnectionException('Failed to connect to the disputes server: $e');
    } on TimeoutException catch (e, stackTrace) {
      developer.log('[DISPUTE] TimeoutException: Request timed out after 10 seconds',
          name: 'DisputesService', error: e, stackTrace: stackTrace);
      throw RequestTimeoutException('Request timed out');
    } catch (e, stackTrace) {
      developer.log('[DISPUTE] Error in getDisputesByVehicleNumber: $e',
          name: 'DisputesService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<List<Dispute>> getDisputesByDate({
    required String start,
    required String end,
  }) async {
    final url = ApiConfig.getFullUrl(DisputesApi.getDisputesByDate);
    final serverUrl = Uri.parse(url);

    if (!(await _connectivityService.isConnected())) {
      throw NoInternetException('No internet connection. Please check your network settings.');
    }
    if (!(await _connectivityService.canReachServer(serverUrl.host))) {
      throw ServerConnectionException('Cannot reach the disputes server.', host: serverUrl.host);
    }

    developer.log('[DISPUTE] Fetching disputes by date range at URL: $url', name: 'DisputesService');
    final body = json.encode({'start': start, 'end': end});
    developer.log('[DISPUTE] Request Body: $body', name: 'DisputesService');

    try {
      final headers = await _getHeaders();
      developer.log('[DISPUTE] Headers Sent: $headers', name: 'DisputesService');
      final response = await _client.post(
        serverUrl,
        headers: headers,
        body: body,
      ).timeout(const Duration(seconds: 10));

      developer.log('[DISPUTE] Response Status Code: ${response.statusCode}', name: 'DisputesService');
      developer.log('[DISPUTE] Response Body: ${response.body}', name: 'DisputesService');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['data'] != null) {
          final List<Dispute> disputes = (responseData['data'] as List)
              .map((disputeJson) => Dispute.fromJson(disputeJson))
              .toList();
          for (var dispute in disputes) {
            final validationError = dispute.validateForUpdate();
            if (validationError != null) {
              throw ServiceException('Invalid dispute data: $validationError');
            }
          }
          developer.log('[DISPUTE] Successfully retrieved ${disputes.length} disputes for date range', name: 'DisputesService');
          return disputes;
        }
        developer.log('[DISPUTE] No disputes in response, returning empty list', name: 'DisputesService');
        return [];
      }

      throw _handleErrorResponse(response, 'Failed to fetch disputes by date range');
    } on SocketException catch (e, stackTrace) {
      developer.log('[DISPUTE] SocketException: Failed to connect to server: $e',
          name: 'DisputesService', error: e, stackTrace: stackTrace);
      throw ServerConnectionException('Failed to connect to the disputes server: $e');
    } on TimeoutException catch (e, stackTrace) {
      developer.log('[DISPUTE] TimeoutException: Request timed out after 10 seconds',
          name: 'DisputesService', error: e, stackTrace: stackTrace);
      throw RequestTimeoutException('Request timed out');
    } catch (e, stackTrace) {
      developer.log('[DISPUTE] Error in getDisputesByDate: $e',
          name: 'DisputesService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<bool> processDispute({
    required String disputeId,
    required String processStatus,
    required String remark,
    required String processedBy,
    List<String> uploadedFiles = const [],
  }) async {
    final url = ApiConfig.getFullUrl(DisputesApi.processDispute);
    final serverUrl = Uri.parse(url);

    if (!(await _connectivityService.isConnected())) {
      throw NoInternetException('No internet connection. Please check your network settings.');
    }
    if (!(await _connectivityService.canReachServer(serverUrl.host))) {
      throw ServerConnectionException('Cannot reach the disputes server.', host: serverUrl.host);
    }

    if (!Dispute.validStatuses.contains(processStatus)) {
      throw ServiceException('Invalid process status: $processStatus. Must be one of: ${Dispute.validStatuses.join(", ")}');
    }

    developer.log('[DISPUTE] Processing dispute at URL: $url', name: 'DisputesService');

    try {
      var request = http.MultipartRequest('POST', serverUrl);
      final headers = await _getHeaders();
      headers['Accept'] = 'application/json';
      headers['Content-Type'] = 'multipart/form-data';
      request.headers.addAll(headers);
      developer.log('[DISPUTE] Headers Sent: $headers', name: 'DisputesService');

      request.fields.addAll({
        'disputeId': disputeId,
        'processStatus': processStatus,
        'remark': remark,
        'processedBy': processedBy,
      });

      for (var i = 0; i < uploadedFiles.length; i++) {
        final file = File(uploadedFiles[i]);
        if (await file.exists()) {
          final ext = file.path.split('.').last.toLowerCase();
          if (!['jpeg', 'jpg', 'png', 'pdf'].contains(ext)) {
            throw ServiceException('Unsupported file type: $ext');
          }
          developer.log(
            '[DISPUTE] Adding file $i: ${uploadedFiles[i]} (Extension: $ext)',
            name: 'DisputesService',
          );
          request.files.add(await http.MultipartFile.fromPath(
            'uploadedFiles',
            file.path,
            filename: 'dispute_file_$i.$ext',
            contentType: MediaType(ext == 'pdf' ? 'application' : 'image', ext),
          ));
        } else {
          developer.log('[DISPUTE] File $i not found: ${uploadedFiles[i]}', name: 'DisputesService');
          throw ServiceException('File not found: ${uploadedFiles[i]}');
        }
      }

      developer.log('[DISPUTE] Request Fields: ${request.fields}', name: 'DisputesService');
      developer.log('[DISPUTE] Request Files: ${request.files.map((f) => f.filename).toList()}', name: 'DisputesService');

      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);

      developer.log('[DISPUTE] Response Status Code: ${response.statusCode}', name: 'DisputesService');
      developer.log('[DISPUTE] Response Body: ${response.body}', name: 'DisputesService');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          developer.log('[DISPUTE] Successfully processed dispute: $disputeId', name: 'DisputesService');
          return true;
        }
        throw ServiceException(responseData['message'] ?? 'Failed to process dispute');
      }

      throw _handleErrorResponse(response, 'Failed to process dispute');
    } on SocketException catch (e, stackTrace) {
      developer.log('[DISPUTE] SocketException: Failed to connect to server: $e',
          name: 'DisputesService', error: e, stackTrace: stackTrace);
      throw ServerConnectionException('Failed to connect to the disputes server: $e');
    } on TimeoutException catch (e, stackTrace) {
      developer.log('[DISPUTE] TimeoutException: Request timed out after 30 seconds',
          name: 'DisputesService', error: e, stackTrace: stackTrace);
      throw RequestTimeoutException('Request timed out');
    } catch (e, stackTrace) {
      developer.log('[DISPUTE] Error in processDispute: $e',
          name: 'DisputesService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  HttpException _handleErrorResponse(http.Response response, String defaultMessage) {
    String? serverMessage;
    try {
      final errorData = json.decode(response.body);
      serverMessage = errorData['message'] as String?;
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