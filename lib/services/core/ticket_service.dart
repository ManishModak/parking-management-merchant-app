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

class TicketService {
  final http.Client _client;
  final ConnectivityService _connectivityService;

  TicketService({
    http.Client? client,
    ConnectivityService? connectivityService,
  })  : _client = client ?? http.Client(),
        _connectivityService = connectivityService ?? ConnectivityService();

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
      final response = await _client.get(
        serverUrl,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      developer.log('[TICKET] Response Status Code: ${response.statusCode}', name: 'TicketService');
      developer.log('[TICKET] Response Body: ${response.body}', name: 'TicketService');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData["data"] != null) { // Check only for "data"
          final List<Ticket> tickets = (responseData['data'] as List)
              .map((ticketJson) => Ticket.fromJson(ticketJson))
              .toList();
          developer.log('[TICKET] Successfully retrieved ${tickets.length} tickets', name: 'TicketService');
          return tickets;
        }
        developer.log('[TICKET] No tickets in response data, returning empty list', name: 'TicketService');
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
      final response = await _client.get(
        serverUrl,
        headers: {'Content-Type': 'application/json'},
        // body: jsonEncode(["plazaId":1]),
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
      final response = await _client.post(
        serverUrl,
        headers: {'Content-Type': 'application/json'},
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

  // /// Creates a new ticket with associated images.
  // Future<Ticket> createTicketWithImages(Ticket ticket, List<String> imagePaths) async {
  //   final url = ApiConfig.getFullUrl(TicketApi.createTicket);
  //   final serverUrl = Uri.parse(url);
  //
  //   if (!(await _connectivityService.isConnected())) {
  //     throw NoInternetException('No internet connection. Please check your network settings.');
  //   }
  //   if (!(await _connectivityService.canReachServer(serverUrl.host))) {
  //     throw ServerConnectionException('Cannot reach the ticket server.', host: serverUrl.host);
  //   }
  //
  //   developer.log('[TICKET] Creating ticket with images at URL: $url', name: 'TicketService');
  //
  //   try {
  //     var request = http.MultipartRequest('POST', serverUrl);
  //     Map<String, dynamic> ticketData = ticket.toCreateRequest();
  //     request.fields.addAll(ticketData.map((key, value) => MapEntry(key, value.toString())));
  //
  //     for (var i = 0; i < imagePaths.length; i++) {
  //       final file = File(imagePaths[i]);
  //       if (await file.exists()) {
  //         final bytes = await file.readAsBytes();
  //         request.files.add(http.MultipartFile.fromBytes(
  //           'images',
  //           bytes,
  //           filename: 'vehicle_image_${i + 1}.jpg',
  //           contentType: MediaType('image', 'jpeg'),
  //         ));
  //       }
  //     }
  //
  //     developer.log('[TICKET] Request Fields: ${request.fields}', name: 'TicketService');
  //     developer.log('[TICKET] Request Files: ${request.files.map((f) => f.filename).toList()}', name: 'TicketService');
  //
  //     final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
  //     final response = await http.Response.fromStream(streamedResponse);
  //
  //     developer.log('[TICKET] Response Status Code: ${response.statusCode}', name: 'TicketService');
  //     developer.log('[TICKET] Response Body: ${response.body}', name: 'TicketService');
  //
  //     if (response.statusCode == 201) {
  //       final responseData = json.decode(response.body);
  //       if (responseData['success'] == true && responseData['data'] != null) {
  //         final createdTicket = Ticket.fromJson(responseData['data']);
  //         developer.log('[TICKET] Successfully created ticket with images: ${createdTicket.ticketId}', name: 'TicketService');
  //         return createdTicket;
  //       }
  //       throw ServiceException(responseData['message'] ?? 'Invalid response format');
  //     }
  //
  //     throw _handleErrorResponse(response, 'Failed to create ticket with images');
  //   } on SocketException catch (e) {
  //     throw ServerConnectionException('Failed to connect to the ticket server: $e');
  //   } on TimeoutException {
  //     throw RequestTimeoutException('Request timed out');
  //   } catch (e, stackTrace) {
  //     developer.log('[TICKET] Error in createTicketWithImages: $e',
  //         name: 'TicketService', error: e, stackTrace: stackTrace);
  //     rethrow;
  //   }
  // }

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
      final response = await _client.get(
        serverUrl,
        headers: {'Content-Type': 'application/json'},
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
      final response = await _client.post(
        serverUrl,
        headers: {'Content-Type': 'application/json'},
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
      final response = await _client.post(
        serverUrl,
        headers: {'Content-Type': 'application/json'},
        body: body,
      ).timeout(const Duration(seconds: 10));

      developer.log('[TICKET] Response Status Code: ${response.statusCode}', name: 'TicketService');
      developer.log('[TICKET] Response Body: ${response.body}', name: 'TicketService');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['ticket'] != null) {
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
      final response = await _client.get(
        serverUrl,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      developer.log('[TICKET] Response Status Code: ${response.statusCode}', name: 'TicketService');
      developer.log('[TICKET] Response Body: ${response.body}', name: 'TicketService');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        // Check for 'ticket' field instead of 'success' to determine success
        if (responseData['ticket'] != null) {
          final ticketData = Map<String, dynamic>.from(responseData['ticket']);
          _mapImageUrls(ticketData);
          developer.log('[TICKET] Successfully marked ticket as exited for ID: $ticketId', name: 'TicketService');
          return ticketData;
        }
        // Throw exception if 'ticket' is missing, using message if available
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

  /// Helper method to map image paths to full URLs
  void _mapImageUrls(Map<String, dynamic> ticketData) {
    final baseUrl = ApiConfig.baseUrl.endsWith('/') ? ApiConfig.baseUrl : '${ApiConfig.baseUrl}/';
    if (ticketData['images'] != null) {
      List<String> capturedImages = [];
      if (ticketData['images'] is List) {
        final imagesList = ticketData['images'] as List;
        capturedImages = imagesList
            .map((img) => img['image_path']?.toString())
            .where((path) => path != null && path.isNotEmpty)
            .map((path) {
          final normalizedPath = path!.startsWith('/') ? path.substring(1) : path;
          return '$baseUrl$normalizedPath';
        })
            .toList();
      }
      ticketData['captured_images'] = capturedImages;
      developer.log('[TICKET] Mapped images to: ${ticketData['captured_images']}', name: 'TicketService');
    } else {
      ticketData['captured_images'] = [];
    }
  }

  Future<Ticket> createTicketWithImages(
      Ticket ticket,
      List<String> imagePaths, {
        required String channelId,
        required String requestType,
        required String cameraId,
        required String cameraReadTime,
      }) async {
    final url = ApiConfig.getFullUrl(TicketApi.newTicket);
    final serverUrl = Uri.parse(url);

    if (!(await _connectivityService.isConnected())) {
      throw NoInternetException('No internet connection.');
    }
    if (!(await _connectivityService.canReachServer(serverUrl.host))) {
      throw ServerConnectionException('Cannot reach the ticket server.', host: serverUrl.host);
    }

    developer.log('[TICKET] Creating ticket with images at URL: $url', name: 'TicketService');

    try {
      var request = http.MultipartRequest('POST', serverUrl);

      // Add required fields
      request.fields['channel_id'] = channelId;
      request.fields['request_type'] = requestType;
      request.fields['plaza_id'] = ticket.plazaId!;
      request.fields['lane_id'] = ticket.entryLaneId;
      request.fields['entry_time'] = ticket.entryTime!;
      request.fields['camera_id'] = cameraId;
      request.fields['cameraReadTime'] = cameraReadTime;

      // Add optional fields if manual
      if (requestType == '1') {
        request.fields['vehicle_number'] = ticket.vehicleNumber ?? '';
        request.fields['vehicle_type'] = ticket.vehicleType ?? '';
      }

      // Add images
      for (var i = 0; i < imagePaths.length; i++) {
        final file = File(imagePaths[i]);
        if (await file.exists()) {
          request.files.add(await http.MultipartFile.fromPath(
            'images',
            file.path,
            filename: 'image_$i.jpg',
            contentType: MediaType('image', 'jpeg'),
          ));
        }
      }

      developer.log('[TICKET] Request Fields: ${request.fields}', name: 'TicketService');
      developer.log('[TICKET] Request Files: ${request.files.map((f) => f.filename).toList()}', name: 'TicketService');

      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);

      developer.log('[TICKET] Response Status Code: ${response.statusCode}', name: 'TicketService');
      developer.log('[TICKET] Response Body: ${response.body}', name: 'TicketService');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['data'] != null) {
          final createdTicket = Ticket.fromJson(responseData['data']);
          developer.log('[TICKET] Successfully created ticket with images: ${createdTicket.ticketId}', name: 'TicketService');
          return createdTicket;
        } else {
          throw ServiceException(responseData['message'] ?? 'Invalid response format');
        }
      } else if (response.statusCode == 400 && requestType == '0') {
        final responseData = json.decode(response.body);
        if (responseData['message']?.contains('ANPR processing failed') == true) {
          throw AnprFailureException('ANPR processing failed'); // Custom exception
        }
      }

      throw _handleErrorResponse(response, 'Failed to create ticket with images');
    } on SocketException catch (e) {
      throw ServerConnectionException('Failed to connect to the ticket server: $e');
    } on TimeoutException {
      throw RequestTimeoutException('Request timed out');
    } catch (e, stackTrace) {
      developer.log('[TICKET] Error in createTicketWithImages: $e',
          name: 'TicketService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}