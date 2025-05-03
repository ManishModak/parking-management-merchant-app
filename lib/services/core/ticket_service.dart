import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../config/api_config.dart';
import '../../models/ticket.dart';
import '../../utils/exceptions.dart';
import '../network/connectivity_service.dart';
import '../storage/secure_storage_service.dart';

class TicketService {
  final http.Client _client;
  final ConnectivityService _connectivityService;
  final SecureStorageService _secureStorageService;

  TicketService({
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

  /// Fetches all open tickets.
  Future<List<Ticket>> getOpenTickets() async {
    final url = ApiConfig.getFullUrl(TicketApi.getOpenTickets);
    final serverUrl = Uri.parse(url);

    if (!(await _connectivityService.isConnected())) {
      throw NoInternetException('No internet connection. Please check your network settings.');
    }
    if (!(await _connectivityService.canReachServer(serverUrl.host))) {
      throw ServerConnectionException('Cannot reach the ticket server.', host: serverUrl.host);
    }

    developer.log('[TICKET] Fetching open tickets at URL: $url', name: 'TicketService');

    try {
      final headers = await _getHeaders();
      developer.log('[TICKET] Headers Sent: $headers', name: 'TicketService'); // Log headers
      final response = await _client.get(
        serverUrl,
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      developer.log('[TICKET] Response Status Code: ${response.statusCode}', name: 'TicketService');
      developer.log('[TICKET] Response Body: ${response.body}', name: 'TicketService');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData["data"] != null) {
          final List<Ticket> tickets = (responseData['data'] as List)
              .map((ticketJson) => Ticket.fromJson(ticketJson))
              .toList();
          developer.log('[TICKET] Successfully retrieved ${tickets.length} tickets', name: 'TicketService');
          return tickets;
        }
        developer.log('[TICKET] No tickets in response data, returning empty list', name: 'TicketService');
        return [];
      } else if (response.statusCode == 404) {
        developer.log('[TICKET] No open tickets found (404), returning empty list', name: 'TicketService');
        return [];
      }

      throw _handleErrorResponse(response, 'Failed to fetch open tickets');
    } on SocketException catch (e) {
      throw ServerConnectionException('Failed to connect to the ticket server: $e');
    } on TimeoutException {
      throw RequestTimeoutException('Request timed out');
    } catch (e, stackTrace) {
      developer.log('[TICKET] Error in getOpenTickets: $e',
          name: 'TicketService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Fetches all tickets regardless of status.
  Future<List<Ticket>> getAllTickets() async {
    final url = ApiConfig.getFullUrl(TicketApi.getAllTickets);
    final serverUrl = Uri.parse(url);

    if (!(await _connectivityService.isConnected())) {
      throw NoInternetException('No internet connection. Please check your network settings.');
    }
    if (!(await _connectivityService.canReachServer(serverUrl.host))) {
      throw ServerConnectionException('Cannot reach the ticket server.', host: serverUrl.host);
    }

    developer.log('[TICKET] Fetching all tickets at URL: $url', name: 'TicketService');

    try {
      final headers = await _getHeaders();
      developer.log('[TICKET] Headers Sent: $headers', name: 'TicketService'); // Log headers
      final response = await _client.get(
        serverUrl,
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      developer.log('[TICKET] Response Status Code: ${response.statusCode}', name: 'TicketService');
      developer.log('[TICKET] Response Body: ${response.body}', name: 'TicketService');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final ticketData = responseData['data'] as List<dynamic>?;

        if (ticketData == null || ticketData.isEmpty) {
          developer.log('[TICKET] No tickets in response, returning empty list', name: 'TicketService');
          return [];
        }

        final tickets = ticketData.map((ticketJson) => Ticket.fromJson(ticketJson)).toList();
        developer.log('[TICKET] Successfully retrieved ${tickets.length} tickets', name: 'TicketService');
        return tickets;
      }

      throw _handleErrorResponse(response, 'Failed to fetch all tickets');
    } on SocketException catch (e) {
      throw ServerConnectionException('Failed to connect to the ticket server: $e');
    } on TimeoutException {
      throw RequestTimeoutException('Request timed out');
    } catch (e, stackTrace) {
      developer.log('[TICKET] Error in getAllTickets: $e',
          name: 'TicketService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Creates a new ticket without images.
  Future<Ticket> createTicket(Ticket ticket) async {
    final url = ApiConfig.getFullUrl(TicketApi.createTicket);
    final serverUrl = Uri.parse(url);

    if (!(await _connectivityService.isConnected())) {
      throw NoInternetException('No internet connection. Please check your network settings.');
    }
    if (!(await _connectivityService.canReachServer(serverUrl.host))) {
      throw ServerConnectionException('Cannot reach the ticket server.', host: serverUrl.host);
    }

    developer.log('[TICKET] Creating ticket at URL: $url', name: 'TicketService');
    final body = json.encode(ticket.toCreateRequest());
    developer.log('[TICKET] Request Body: $body', name: 'TicketService');

    try {
      final headers = await _getHeaders();
      developer.log('[TICKET] Headers Sent: $headers', name: 'TicketService'); // Log headers
      final response = await _client.post(
        serverUrl,
        headers: headers,
        body: body,
      ).timeout(const Duration(seconds: 10));

      developer.log('[TICKET] Response Status Code: ${response.statusCode}', name: 'TicketService');
      developer.log('[TICKET] Response Body: ${response.body}', name: 'TicketService');

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['ticket'] != null) {
          final createdTicket = Ticket.fromJson(responseData['ticket']);
          developer.log('[TICKET] Successfully created ticket: ${createdTicket.ticketId}', name: 'TicketService');
          return createdTicket;
        }
        throw ServiceException(responseData['message'] ?? 'Invalid response format');
      }

      throw _handleErrorResponse(response, 'Failed to create ticket');
    } on SocketException catch (e) {
      throw ServerConnectionException('Failed to connect to the ticket server: $e');
    } on TimeoutException {
      throw RequestTimeoutException('Request timed out');
    } catch (e, stackTrace) {
      developer.log('[TICKET] Error in createTicket: $e',
          name: 'TicketService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Creates a new ticket with associated images.
  Future<Ticket> createTicketWithImages(
      Ticket ticket,
      List<String> imagePaths, {
        required String channelId,
        required String requestType,
        required String cameraId,
        required String cameraReadTime,
        required String geoLatitude,
        required String geoLongitude,
      }) async {
    final url = ApiConfig.getFullUrl(TicketApi.newTicket);
    final serverUrl = Uri.parse(url);

    if (!(await _connectivityService.isConnected())) {
      developer.log('[TICKET] No internet connection detected', name: 'TicketService');
      throw NoInternetException('No internet connection.');
    }
    if (!(await _connectivityService.canReachServer(serverUrl.host))) {
      developer.log('[TICKET] Cannot reach server at host: ${serverUrl.host}', name: 'TicketService');
      throw ServerConnectionException('Cannot reach the ticket server.', host: serverUrl.host);
    }

    developer.log('[TICKET] Initiating ticket creation with images', name: 'TicketService');
    developer.log('[TICKET] Request URL: $url', name: 'TicketService');
    developer.log('[TICKET] Channel ID: $channelId', name: 'TicketService');
    developer.log('[TICKET] Requestanego Type: $requestType', name: 'TicketService');
    developer.log('[TICKET] Camera ID: $cameraId', name: 'TicketService');
    developer.log('[TICKET] Camera Read Time: $cameraReadTime', name: 'TicketService');
    developer.log('[TICKET] Geo Latitude: $geoLatitude', name: 'TicketService');
    developer.log('[TICKET] Geo Longitude: $geoLongitude', name: 'TicketService');
    developer.log('[TICKET] Number of images: ${imagePaths.length}', name: 'TicketService');

    try {
      var request = http.MultipartRequest('POST', serverUrl);

      // Use headers with token for multipart request
      final headers = await _getHeaders();
      headers['Accept'] = 'application/json';
      headers['Content-Type'] = 'multipart/form-data';
      request.headers.addAll(headers);
      developer.log('[TICKET] Headers Sent: ${request.headers}', name: 'TicketService'); // Log headers

      developer.log('[TICKET] Preparing request fields:', name: 'TicketService');
      request.fields['plaza_id'] = ticket.plazaId?.toString() ?? '';
      developer.log('[TICKET] Plaza ID: ${request.fields['plaza_id']}', name: 'TicketService');
      request.fields['lane_id'] = ticket.entryLaneId ?? '';
      request.fields['channel_id'] = channelId;
      developer.log('[TICKET] Channel ID: ${request.fields['channel_id']}', name: 'TicketService');
      request.fields['request_type'] = requestType;
      developer.log('[TICKET] Request Type: ${request.fields['request_type']}', name: 'TicketService');
      request.fields['entry_time'] = ticket.entryTime?.toIso8601String() ?? '';
      developer.log('[TICKET] Entry Time: ${request.fields['entry_time']}', name: 'TicketService');
      request.fields['camera_id'] = cameraId;
      developer.log('[TICKET] Camera ID: ${request.fields['camera_id']}', name: 'TicketService');
      request.fields['cameraReadTime'] = cameraReadTime;
      developer.log('[TICKET] Camera Read Time: ${request.fields['cameraReadTime']}', name: 'TicketService');
      request.fields['geo_latitude'] = geoLatitude;
      developer.log('[TICKET] Geo Latitude: ${request.fields['geo_latitude']}', name: 'TicketService');
      request.fields['geo_longitude'] = geoLongitude;
      developer.log('[TICKET] Geo Longitude: ${request.fields['geo_longitude']}', name: 'TicketService');

      if (requestType == '1') {
        request.fields['vehicle_number'] = ticket.vehicleNumber ?? '';
        developer.log('[TICKET] Vehicle Number: ${request.fields['vehicle_number']}', name: 'TicketService');
        request.fields['vehicle_type'] = ticket.vehicleType ?? '';
        developer.log('[TICKET] Vehicle Type: ${request.fields['vehicle_type']}', name: 'TicketService');
      } else {
        developer.log('[TICKET] Request type is $requestType, skipping vehicle details', name: 'TicketService');
      }

      developer.log('[TICKET] Processing images:', name: 'TicketService');
      for (var i = 0; i < imagePaths.length; i++) {
        final file = File(imagePaths[i]);
        if (await file.exists()) {
          final fileSize = await file.length();
          final fileBytes = await file.readAsBytes();
          developer.log(
            '[TICKET] Adding image $i: ${imagePaths[i]} (Size: ${fileSize ~/ 1024} KB, First 10 bytes: ${fileBytes.take(10).toList()})',
            name: 'TicketService',
          );
          request.files.add(await http.MultipartFile.fromPath(
            'images',
            file.path,
            filename: 'image_$i.jpg',
            contentType: MediaType('image', 'jpeg'),
          ));
        } else {
          developer.log('[TICKET] Image $i not found: ${imagePaths[i]}', name: 'TicketService');
          throw ServiceException('Image file not found: ${imagePaths[i]}');
        }
      }

      developer.log('[TICKET] Final Request Fields: ${request.fields}', name: 'TicketService');
      developer.log('[TICKET] Attached Files: ${request.files.map((f) => f.filename).toList()}', name: 'TicketService');

      final streamedResponse = await request.send().timeout(const Duration(seconds: 180));
      final response = await http.Response.fromStream(streamedResponse);

      developer.log('[TICKET] Response Status Code: ${response.statusCode}', name: 'TicketService');
      developer.log('[TICKET] Response Headers: ${response.headers}', name: 'TicketService');
      developer.log('[TICKET] Response Body: ${response.body}', name: 'TicketService');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['data'] != null) {
          final createdTicket = Ticket.fromJson(responseData['data']);
          developer.log('[TICKET] Successfully created ticket with ID: ${createdTicket.ticketId}', name: 'TicketService');
          developer.log('[TICKET] Ticket Details: ${createdTicket.toJson()}', name: 'TicketService');
          return createdTicket;
        } else {
          developer.log('[TICKET] Invalid response format: ${responseData['message']}', name: 'TicketService');
          throw ServiceException(responseData['message'] ?? 'Invalid response format');
        }
      } else if (response.statusCode == 400 && requestType == '0') {
        final responseData = json.decode(response.body);
        developer.log('[TICKET] ANPR Failure Details: ${responseData.toString()}', name: 'TicketService');
        if (responseData['message']?.contains('ANPR') == true) {
          developer.log('[TICKET] ANPR processing failed for request type 0', name: 'TicketService');
          throw AnprFailureException('ANPR processing failed: ${responseData['message']}');
        }
      }

      developer.log('[TICKET] Failed to create ticket. Status: ${response.statusCode}', name: 'TicketService');
      throw _handleErrorResponse(response, 'Failed to create ticket with images');
    } on SocketException catch (e, stackTrace) {
      developer.log('[TICKET] SocketException: Failed to connect to server: BP$e',
          name: 'TicketService', error: e, stackTrace: stackTrace);
      throw ServerConnectionException('Failed to connect to the ticket server: $e');
    } on TimeoutException catch (e, stackTrace) {
      developer.log('[TICKET] TimeoutException: Request timed out after 180 seconds',
          name: 'TicketService', error: e, stackTrace: stackTrace);
      throw RequestTimeoutException('Request timed out');
    } catch (e, stackTrace) {
      developer.log('[TICKET] Unexpected error in createTicketWithImages: $e',
          name: 'TicketService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Retrieves detailed information for a specific ticket.
  Future<Ticket> getTicketDetails(String ticketId) async {
    final url = ApiConfig.getFullUrl('${TicketApi.getTicketDetails}$ticketId');
    final serverUrl = Uri.parse(url);

    if (!(await _connectivityService.isConnected())) {
      throw NoInternetException('No internet connection. Please check your network settings.');
    }
    if (!(await _connectivityService.canReachServer(serverUrl.host))) {
      throw ServerConnectionException('Cannot reach the ticket server.', host: serverUrl.host);
    }

    developer.log('[TICKET] Fetching ticket details at URL: $url', name: 'TicketService');
    developer.log('[TICKET] Ticket ID: $ticketId', name: 'TicketService');

    try {
      final headers = await _getHeaders();
      developer.log('[TICKET] Headers Sent: $headers', name: 'TicketService'); // Log headers
      final response = await _client.get(
        serverUrl,
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      developer.log('[TICKET] Response Status Code: ${response.statusCode}', name: 'TicketService');
      developer.log('[TICKET] Response Body: ${response.body}', name: 'TicketService');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['ticket'] != null) {
          final ticketData = Map<String, dynamic>.from(responseData['ticket']);
          _mapImageUrls(ticketData);
          final ticket = Ticket.fromJson(ticketData);
          developer.log('[TICKET] Successfully retrieved ticket details for ID: $ticketId', name: 'TicketService');
          return ticket;
        }
        throw ServiceException('Ticket not found with ID: $ticketId');
      }

      throw _handleErrorResponse(response, 'Failed to fetch ticket details');
    } on SocketException catch (e) {
      throw ServerConnectionException('Failed to connect to the ticket server: $e');
    } on TimeoutException {
      throw RequestTimeoutException('Request timed out');
    } catch (e, stackTrace) {
      developer.log('[TICKET] Error in getTicketDetails: $e',
          name: 'TicketService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Rejects a ticket with provided remarks.
  Future<bool> rejectTicket(String ticketId, String remarks) async {
    final url = ApiConfig.getFullUrl('${TicketApi.rejectTicket}$ticketId');
    final serverUrl = Uri.parse(url);

    if (!(await _connectivityService.isConnected())) {
      throw NoInternetException('No internet connection. Please check your network settings.');
    }
    if (!(await _connectivityService.canReachServer(serverUrl.host))) {
      throw ServerConnectionException('Cannot reach the ticket server.', host: serverUrl.host);
    }

    developer.log('[TICKET] Rejecting ticket at URL: $url', name: 'TicketService');
    developer.log('[TICKET] Ticket ID: $ticketId', name: 'TicketService');
    final body = json.encode({'remarks': remarks});
    developer.log('[TICKET] Request Body: $body', name: 'TicketService');

    try {
      final headers = await _getHeaders();
      developer.log('[TICKET] Headers Sent: $headers', name: 'TicketService'); // Log headers
      final response = await _client.post(
        serverUrl,
        headers: headers,
        body: body,
      ).timeout(const Duration(seconds: 10));

      developer.log('[TICKET] Response Status Code: ${response.statusCode}', name: 'TicketService');
      developer.log('[TICKET] Response Body: ${response.body}', name: 'TicketService');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          developer.log('[TICKET] Successfully rejected ticket: $ticketId', name: 'TicketService');
          return true;
        }
        return false;
      }

      throw _handleErrorResponse(response, 'Failed to reject ticket');
    } on SocketException catch (e) {
      throw ServerConnectionException('Failed to connect to the ticket server: $e');
    } on TimeoutException {
      throw RequestTimeoutException('Request timed out');
    } catch (e, stackTrace) {
      developer.log('[TICKET] Error in rejectTicket: $e',
          name: 'TicketService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Modifies an existing ticket.
  Future<Ticket> modifyTicket(String ticketId, Ticket ticket) async {
    final url = ApiConfig.getFullUrl('${TicketApi.modifyTicket}$ticketId');
    final serverUrl = Uri.parse(url);

    if (!(await _connectivityService.isConnected())) {
      throw NoInternetException('No internet connection. Please check your network settings.');
    }
    if (!(await _connectivityService.canReachServer(serverUrl.host))) {
      throw ServerConnectionException('Cannot reach the ticket server.', host: serverUrl.host);
    }

    developer.log('[TICKET] Modifying ticket at URL: $url', name: 'TicketService');
    developer.log('[TICKET] Ticket ID: $ticketId', name: 'TicketService');
    final body = json.encode(ticket.toModifyRequest());
    developer.log('[TICKET] Request Body: $body', name: 'TicketService');

    try {
      final headers = await _getHeaders();
      developer.log('[TICKET] Headers Sent: $headers', name: 'TicketService'); // Log headers
      final response = await _client.post(
        serverUrl,
        headers: headers,
        body: body,
      ).timeout(const Duration(seconds: 10));

      developer.log('[TICKET] Response Status Code: ${response.statusCode}', name: 'TicketService');
      developer.log('[TICKET] Response Body: ${response.body}', name: 'TicketService');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['ticket'] != null) {
          final modifiedTicket = Ticket.fromJson(responseData['ticket']);
          developer.log('[TICKET] Successfully modified ticket: ${modifiedTicket.ticketId}', name: 'TicketService');
          return modifiedTicket;
        }
        throw ServiceException(responseData['message'] ?? 'Invalid response format');
      }

      throw _handleErrorResponse(response, 'Failed to modify ticket');
    } on SocketException catch (e) {
      throw ServerConnectionException('Failed to connect to the ticket server: $e');
    } on TimeoutException {
      throw RequestTimeoutException('Request timed out');
    } catch (e, stackTrace) {
      developer.log('[TICKET] Error in modifyTicket: $e',
          name: 'TicketService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Marks a ticket as exited and returns detailed exit data.
  Future<Map<String, dynamic>> markTicketExit(String ticketId) async {
    final url = ApiConfig.getFullUrl('${TicketApi.markVehicleExit}$ticketId');
    final serverUrl = Uri.parse(url);

    if (!(await _connectivityService.isConnected())) {
      throw NoInternetException('No internet connection. Please check your network settings.');
    }
    if (!(await _connectivityService.canReachServer(serverUrl.host))) {
      throw ServerConnectionException('Cannot reach the ticket server.', host: serverUrl.host);
    }

    developer.log('[TICKET] Marking ticket as exited at URL: $url', name: 'TicketService');
    developer.log('[TICKET] Ticket ID: $ticketId', name: 'TicketService');

    try {
      final headers = await _getHeaders();
      developer.log('[TICKET] Headers Sent: $headers', name: 'TicketService'); // Log headers
      final response = await _client.get(
        serverUrl,
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      developer.log('[TICKET] Response Status Code: ${response.statusCode}', name: 'TicketService');
      developer.log('[TICKET] Response Body: ${response.body}', name: 'TicketService');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['ticket'] != null) {
          final ticketData = Map<String, dynamic>.from(responseData['ticket']);
          _mapImageUrls(ticketData);
          developer.log('[TICKET] Successfully marked ticket as exited for ID: $ticketId', name: 'TicketService');
          return ticketData;
        }
        throw ServiceException(responseData['message'] ?? 'Invalid response format: No ticket data');
      }

      throw _handleErrorResponse(response, 'Failed to mark ticket as exited');
    } on SocketException catch (e) {
      throw ServerConnectionException('Failed to connect to the ticket server: $e');
    } on TimeoutException {
      throw RequestTimeoutException('Request timed out');
    } catch (e, stackTrace) {
      developer.log('[TICKET] Error in markTicketExit: $e',
          name: 'TicketService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Helper method to handle error responses consistently
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

  void _mapImageUrls(Map<String, dynamic> ticketData) {
    final baseUrl = ApiConfig.baseUrl.replaceAll(RegExp(r'/+$'), '');
    if (ticketData['images'] != null) {
      List<String> capturedImages = [];
      if (ticketData['images'] is List) {
        final imagesList = ticketData['images'] as List;
        capturedImages = imagesList
            .map((img) => img['image_path']?.toString())
            .where((path) => path != null && path.isNotEmpty)
            .map((path) {
          final normalizedPath = path!.startsWith('/') ? path.substring(1) : path;
          return '$baseUrl/$normalizedPath';
        })
            .toList();
      }
      ticketData['captured_images'] = capturedImages;
      developer.log('[TICKET] Mapped images to: ${ticketData['captured_images']}', name: 'TicketService');
    } else {
      ticketData['captured_images'] = [];
    }
  }
}