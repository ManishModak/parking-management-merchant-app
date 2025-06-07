// merchant_app/lib/services/core/ticket_service.dart
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
      'Accept': 'application/json', // Expect JSON response
      // Content-Type for the request body is set specifically in each method
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
      // For GET requests, 'Content-Type' in the request header is usually not needed.
      developer.log('[TICKET] Headers Sent for getOpenTickets: $headers', name: 'TicketService');
      final response = await _client.get(
        serverUrl,
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      developer.log('[TICKET] Response Status Code for getOpenTickets: ${response.statusCode}', name: 'TicketService');
      developer.log('[TICKET] Response Body for getOpenTickets: ${response.body}', name: 'TicketService');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        // CORRECTED: Check for the presence of the "data" array.
        // This endpoint's success is implied by 200 OK and the presence of "data".
        if (responseData["data"] != null && responseData["data"] is List) {
          final List<dynamic> ticketListJson = responseData['data'];
          if (ticketListJson.isEmpty) {
            developer.log('[TICKET] Successfully retrieved 0 open tickets (empty data array).', name: 'TicketService');
            return [];
          }
          final List<Ticket> tickets = ticketListJson
              .map((ticketJson) => Ticket.fromJson(ticketJson))
              .toList();
          developer.log('[TICKET] Successfully retrieved and parsed ${tickets.length} open tickets.', name: 'TicketService');
          return tickets;
        }
        // If "data" is null or not a list, even with 200 OK, treat as an issue.
        developer.log('[TICKET] "data" field is null or not a list in 200 OK response for getOpenTickets. Response: $responseData', name: 'TicketService');
        return []; // Or throw ServiceException if this state is unexpected
      } else if (response.statusCode == 404) {
        developer.log('[TICKET] No open tickets found (404), returning empty list', name: 'TicketService');
        return [];
      }

      throw _handleErrorResponse(response, 'Failed to fetch open tickets');
    } on SocketException catch (e, stackTrace) {
      developer.log('[TICKET] SocketException in getOpenTickets: $e', name: 'TicketService', error: e, stackTrace: stackTrace);
      throw ServerConnectionException('Failed to connect to the ticket server: $e');
    } on TimeoutException catch (e, stackTrace) {
      developer.log('[TICKET] TimeoutException in getOpenTickets', name: 'TicketService', error: e, stackTrace: stackTrace);
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
      developer.log('[TICKET] Headers Sent for getAllTickets: $headers', name: 'TicketService');
      final response = await _client.get(
        serverUrl,
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      developer.log('[TICKET] Response Status Code for getAllTickets: ${response.statusCode}', name: 'TicketService');
      developer.log('[TICKET] Response Body for getAllTickets: ${response.body}', name: 'TicketService');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        // Assuming a similar structure {"message": "...", "data": [...]} or {"success":true, "data": [...]}
        // Let's be flexible and primarily check for the 'data' array.
        final ticketData = responseData['data'] as List<dynamic>?;

        if (ticketData != null) {
          if (ticketData.isEmpty) {
            developer.log('[TICKET] Successfully retrieved 0 all tickets (empty data array).', name: 'TicketService');
            return [];
          }
          final tickets = ticketData.map((ticketJson) => Ticket.fromJson(ticketJson)).toList();
          developer.log('[TICKET] Successfully retrieved and parsed ${tickets.length} all tickets.', name: 'TicketService');
          return tickets;
        }
        developer.log('[TICKET] "data" field is null or not a list in 200 OK response for getAllTickets. Response: $responseData', name: 'TicketService');
        return [];
      }

      throw _handleErrorResponse(response, 'Failed to fetch all tickets');
    } on SocketException catch (e, stackTrace) {
      developer.log('[TICKET] SocketException in getAllTickets: $e', name: 'TicketService', error: e, stackTrace: stackTrace);
      throw ServerConnectionException('Failed to connect to the ticket server: $e');
    } on TimeoutException catch (e, stackTrace) {
      developer.log('[TICKET] TimeoutException in getAllTickets', name: 'TicketService', error: e, stackTrace: stackTrace);
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

    developer.log('[TICKET] Creating ticket (no images) at URL: $url', name: 'TicketService');
    final body = json.encode(ticket.toCreateRequest());
    developer.log('[TICKET] Request Body: $body', name: 'TicketService');

    try {
      final headers = await _getHeaders();
      headers['Content-Type'] = 'application/json'; // Body is JSON
      developer.log('[TICKET] Headers Sent for createTicket: $headers', name: 'TicketService');
      final response = await _client.post(
        serverUrl,
        headers: headers,
        body: body,
      ).timeout(const Duration(seconds: 10));

      developer.log('[TICKET] Response Status Code for createTicket: ${response.statusCode}', name: 'TicketService');
      developer.log('[TICKET] Response Body for createTicket: ${response.body}', name: 'TicketService');

      if (response.statusCode == 201 || response.statusCode == 200) { // Common success codes for POST
        final responseData = json.decode(response.body);
        final createdTicketJson = responseData['ticket'] ?? responseData['data']; // Adapt if structure varies

        if (createdTicketJson != null && createdTicketJson['ticket_id'] != null && (responseData['success'] == true || responseData['status'] == 200 || responseData['status'] == 201 )) {
          final createdTicket = Ticket.fromJson(createdTicketJson);
          developer.log('[TICKET] Successfully created ticket (no images): ${createdTicket.ticketId}', name: 'TicketService');
          return createdTicket;
        }
        developer.log('[TICKET] Invalid response format after createTicket. Response: $responseData', name: 'TicketService');
        throw ServiceException(responseData['message'] ?? 'Invalid response format after ticket creation');
      }

      throw _handleErrorResponse(response, 'Failed to create ticket');
    } on SocketException catch (e, stackTrace) {
      developer.log('[TICKET] SocketException in createTicket: $e', name: 'TicketService', error: e, stackTrace: stackTrace);
      throw ServerConnectionException('Failed to connect to the ticket server: $e');
    } on TimeoutException catch (e, stackTrace) {
      developer.log('[TICKET] TimeoutException in createTicket', name: 'TicketService', error: e, stackTrace: stackTrace);
      throw RequestTimeoutException('Request timed out');
    } catch (e, stackTrace) {
      developer.log('[TICKET] Error in createTicket: $e',
          name: 'TicketService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }


  /// Creates a new ticket with associated images.
  /// Returns a map containing 'ticket_ref_id' and 'ticket_id_uuid' upon success, or null.
  Future<Map<String, String?>?> createTicketWithImages(
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

    developer.log('[TICKET] Initiating ticket creation with images. URL: $url', name: 'TicketService');

    try {
      var request = http.MultipartRequest('POST', serverUrl);
      final headers = await _getHeaders();
      request.headers.addAll(headers);
      // Content-Type for multipart is set by MultipartRequest itself.
      developer.log('[TICKET] Headers Sent for createTicketWithImages: ${request.headers}', name: 'TicketService');

      request.fields['plaza_id'] = ticket.plazaId?.toString() ?? '';
      request.fields['lane_id'] = ticket.entryLaneId ?? '';
      request.fields['channel_id'] = channelId;
      request.fields['request_type'] = requestType;
      request.fields['entry_time'] = ticket.entryTime?.toIso8601String() ?? '';
      request.fields['camera_id'] = cameraId;
      request.fields['cameraReadTime'] = cameraReadTime;
      request.fields['geo_latitude'] = geoLatitude;
      request.fields['geo_longitude'] = geoLongitude;

      if (requestType == '1') { // Manual Ticket
        request.fields['vehicle_number'] = ticket.vehicleNumber ?? '';
        request.fields['vehicle_type'] = ticket.vehicleType ?? '';
      }
      developer.log('[TICKET] Request Fields: ${request.fields}', name: 'TicketService');

      for (var i = 0; i < imagePaths.length; i++) {
        final file = File(imagePaths[i]);
        if (await file.exists()) {
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
      developer.log('[TICKET] Attached Files: ${request.files.map((f) => f.filename).toList()}', name: 'TicketService');

      final streamedResponse = await request.send().timeout(const Duration(seconds: 180));
      final response = await http.Response.fromStream(streamedResponse);

      developer.log('[TICKET] Response Status Code for createTicketWithImages: ${response.statusCode}', name: 'TicketService');
      developer.log('[TICKET] Response Headers: ${response.headers}', name: 'TicketService');
      developer.log('[TICKET] Response Body: ${response.body}', name: 'TicketService');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 200 &&
            responseData['data'] != null &&
            responseData['data']['data'] != null) {

          final innerTicketData = responseData['data']['data'];
          final String? ticketRefId = innerTicketData['ticket_ref_id'] as String?;
          final String? ticketIdUuid = innerTicketData['ticket_id'] as String?;

          if (ticketRefId != null && ticketIdUuid != null) {
            developer.log('[TICKET] Successfully created ticket. Ticket ID (UUID): $ticketIdUuid, Ticket Ref ID: $ticketRefId', name: 'TicketService');
            return {
              'ticket_ref_id': ticketRefId,
              'ticket_id_uuid': ticketIdUuid,
            };
          } else {
            developer.log('[TICKET] Invalid response format: missing ticket_ref_id or ticket_id in inner data. InnerData: $innerTicketData', name: 'TicketService');
            return null;
          }
        } else {
          developer.log('[TICKET] Invalid response format: top-level status not 200 or data/inner-data missing. Response: $responseData', name: 'TicketService');
          return null;
        }
      } else if (response.statusCode == 400 && requestType == '0') {
        final responseData = json.decode(response.body);
        developer.log('[TICKET] ANPR Failure Details: $responseData', name: 'TicketService');
        if (responseData['message']?.contains('ANPR') == true) {
          developer.log('[TICKET] ANPR processing failed for request type 0.', name: 'TicketService');
          throw AnprFailureException('ANPR processing failed: ${responseData['message']}');
        }
      }
      developer.log('[TICKET] Failed to create ticket with images. Status: ${response.statusCode}', name: 'TicketService');
      throw _handleErrorResponse(response, 'Failed to create ticket with images');
    } on SocketException catch (e, stackTrace) {
      developer.log('[TICKET] SocketException in createTicketWithImages: $e', name: 'TicketService', error: e, stackTrace: stackTrace);
      throw ServerConnectionException('Failed to connect to the ticket server: $e');
    } on TimeoutException catch (e, stackTrace) {
      developer.log('[TICKET] TimeoutException in createTicketWithImages', name: 'TicketService', error: e, stackTrace: stackTrace);
      throw RequestTimeoutException('Request timed out');
    } catch (e, stackTrace) {
      if (e is AnprFailureException || e is ServiceException) rethrow;
      developer.log('[TICKET] Unexpected error in createTicketWithImages: $e', name: 'TicketService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

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

    try {
      final headers = await _getHeaders();
      developer.log('[TICKET] Headers Sent for getTicketDetails: $headers', name: 'TicketService');
      final response = await _client.get(
        serverUrl,
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      developer.log('[TICKET] Response Status Code for getTicketDetails: ${response.statusCode}', name: 'TicketService');
      developer.log('[TICKET] Response Body for getTicketDetails: ${response.body}', name: 'TicketService');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final ticketJson = responseData['ticket'];

        if (responseData['success'] == true && ticketJson != null && ticketJson['ticket_id'] != null) {
          final ticketDataMap = Map<String, dynamic>.from(ticketJson);
          _mapImageUrls(ticketDataMap);
          final ticket = Ticket.fromJson(ticketDataMap);
          developer.log('[TICKET] Successfully retrieved and parsed ticket details for ID: $ticketId', name: 'TicketService');
          return ticket;
        }
        developer.log('[TICKET] Invalid response format or missing ticket data for getTicketDetails. Success: ${responseData['success']}, TicketJson: $ticketJson', name: 'TicketService');
        throw ServiceException('Ticket data not found or invalid format for ID: $ticketId. Response: $responseData');
      }

      throw _handleErrorResponse(response, 'Failed to fetch ticket details');
    } on SocketException catch (e, stackTrace) {
      developer.log('[TICKET] SocketException in getTicketDetails: $e', name: 'TicketService', error: e, stackTrace: stackTrace);
      throw ServerConnectionException('Failed to connect to the ticket server: $e');
    } on TimeoutException catch (e, stackTrace) {
      developer.log('[TICKET] TimeoutException in getTicketDetails', name: 'TicketService', error: e, stackTrace: stackTrace);
      throw RequestTimeoutException('Request timed out');
    } catch (e, stackTrace) {
      developer.log('[TICKET] Error in getTicketDetails: $e', name: 'TicketService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

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
    final body = json.encode({'remarks': remarks});

    try {
      final headers = await _getHeaders();
      headers['Content-Type'] = 'application/json'; // Body is JSON
      developer.log('[TICKET] Headers Sent for rejectTicket: $headers', name: 'TicketService');
      final response = await _client.post(
        serverUrl,
        headers: headers,
        body: body,
      ).timeout(const Duration(seconds: 10));

      developer.log('[TICKET] Response Status Code for rejectTicket: ${response.statusCode}', name: 'TicketService');
      developer.log('[TICKET] Response Body for rejectTicket: ${response.body}', name: 'TicketService');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true || responseData['status'] == 200) {
          developer.log('[TICKET] Successfully rejected ticket: $ticketId', name: 'TicketService');
          return true;
        }
        developer.log('[TICKET] Ticket rejection failed server-side: ${responseData['message']}', name: 'TicketService');
        return false;
      }

      throw _handleErrorResponse(response, 'Failed to reject ticket');
    } on SocketException catch (e, stackTrace) {
      developer.log('[TICKET] SocketException in rejectTicket: $e', name: 'TicketService', error: e, stackTrace: stackTrace);
      throw ServerConnectionException('Failed to connect to the ticket server: $e');
    } on TimeoutException catch (e, stackTrace) {
      developer.log('[TICKET] TimeoutException in rejectTicket', name: 'TicketService', error: e, stackTrace: stackTrace);
      throw RequestTimeoutException('Request timed out');
    } catch (e, stackTrace) {
      developer.log('[TICKET] Error in rejectTicket: $e', name: 'TicketService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

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
    final body = json.encode(ticket.toModifyRequest());

    try {
      final headers = await _getHeaders();
      headers['Content-Type'] = 'application/json'; // Body is JSON
      developer.log('[TICKET] Headers Sent for modifyTicket: $headers', name: 'TicketService');
      final response = await _client.post(
        serverUrl,
        headers: headers,
        body: body,
      ).timeout(const Duration(seconds: 10));

      developer.log('[TICKET] Response Status Code for modifyTicket: ${response.statusCode}', name: 'TicketService');
      developer.log('[TICKET] Response Body for modifyTicket: ${response.body}', name: 'TicketService');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final modifiedTicketJson = responseData['ticket'] ?? responseData['data'];
        if ((responseData['success'] == true || responseData['status'] == 200) && modifiedTicketJson != null && modifiedTicketJson['ticket_id'] != null) {
          final modifiedTicket = Ticket.fromJson(modifiedTicketJson);
          developer.log('[TICKET] Successfully modified ticket: ${modifiedTicket.ticketId}', name: 'TicketService');
          return modifiedTicket;
        }
        throw ServiceException(responseData['message'] ?? 'Invalid response format after ticket modification');
      }

      throw _handleErrorResponse(response, 'Failed to modify ticket');
    } on SocketException catch (e, stackTrace) {
      developer.log('[TICKET] SocketException in modifyTicket: $e', name: 'TicketService', error: e, stackTrace: stackTrace);
      throw ServerConnectionException('Failed to connect to the ticket server: $e');
    } on TimeoutException catch (e, stackTrace) {
      developer.log('[TICKET] TimeoutException in modifyTicket', name: 'TicketService', error: e, stackTrace: stackTrace);
      throw RequestTimeoutException('Request timed out');
    } catch (e, stackTrace) {
      developer.log('[TICKET] Error in modifyTicket: $e', name: 'TicketService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

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

    try {
      final headers = await _getHeaders();
      developer.log('[TICKET] Headers Sent for markTicketExit: $headers', name: 'TicketService');
      final response = await _client.get( // Or POST if it's a state change with potential body
        serverUrl,
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      developer.log('[TICKET] Response Status Code for markTicketExit: ${response.statusCode}', name: 'TicketService');
      developer.log('[TICKET] Response Body for markTicketExit: ${response.body}', name: 'TicketService');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final exitedTicketJson = responseData['ticket'] ?? responseData['data'];
        if (exitedTicketJson != null && exitedTicketJson['ticket_id'] != null) {
          final ticketDataMap = Map<String, dynamic>.from(exitedTicketJson);
          _mapImageUrls(ticketDataMap);
          developer.log('[TICKET] Successfully marked ticket as exited for ID: $ticketId', name: 'TicketService');
          return ticketDataMap;
        }
        throw ServiceException(responseData['message'] ?? 'Invalid response format: No ticket data for exit');
      }

      throw _handleErrorResponse(response, 'Failed to mark ticket as exited');
    } on SocketException catch (e, stackTrace) {
      developer.log('[TICKET] SocketException in markTicketExit: $e', name: 'TicketService', error: e, stackTrace: stackTrace);
      throw ServerConnectionException('Failed to connect to the ticket server: $e');
    } on TimeoutException catch (e, stackTrace) {
      developer.log('[TICKET] TimeoutException in markTicketExit', name: 'TicketService', error: e, stackTrace: stackTrace);
      throw RequestTimeoutException('Request timed out');
    } catch (e, stackTrace) {
      developer.log('[TICKET] Error in markTicketExit: $e', name: 'TicketService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  HttpException _handleErrorResponse(http.Response response, String defaultMessage) {
    String? serverMessage;
    try {
      final errorData = json.decode(response.body);
      serverMessage = errorData['message'] as String?;
    } catch (_) {
      // serverMessage remains null if parsing fails
    }
    return HttpException(
      defaultMessage,
      statusCode: response.statusCode,
      serverMessage: serverMessage ?? response.reasonPhrase ?? 'Unknown server error',
    );
  }

  void _mapImageUrls(Map<String, dynamic> ticketDataMap) {
    final baseUrl = ApiConfig.baseUrl.replaceAll(RegExp(r'/+$'), '');

    if (ticketDataMap['images'] is List) {
      List<String> capturedImageUrls = (ticketDataMap['images'] as List)
          .map((imgObject) {
        if (imgObject is Map && imgObject['image_path'] is String) {
          String path = imgObject['image_path'] as String;
          if (path.isNotEmpty) {
            if (path.startsWith('http://') || path.startsWith('https://')) {
              return path;
            }
            final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
            return '$baseUrl/$normalizedPath';
          }
        }
        return null;
      })
          .whereType<String>()
          .toList();
      ticketDataMap['captured_images'] = capturedImageUrls;
    } else {
      ticketDataMap['captured_images'] = <String>[];
    }
    developer.log('[TICKET] Mapped image URLs for captured_images: ${ticketDataMap['captured_images']}', name: 'TicketService');
  }
}