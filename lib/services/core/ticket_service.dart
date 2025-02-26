import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../config/api_config.dart';
import '../../models/ticket.dart';
import '../../utils/exceptions.dart';

class TicketService {
  final http.Client _client;

  TicketService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches all open tickets.
  Future<List<Ticket>> getOpenTickets() async {
    final url = ApiConfig.getFullUrl(ApiConfig.getOpenTicketsEndpoint);
    developer.log('[TICKET] Fetching open tickets at URL: $url', name: 'TicketService');

    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      developer.log('[TICKET] Response Status Code: ${response.statusCode}', name: 'TicketService');
      developer.log('[TICKET] Response Body: ${response.body}', name: 'TicketService');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData["message"] == "Open tickets fetched successfully." &&
            responseData["data"] != null) {
          final List<Ticket> tickets = (responseData['data'] as List)
              .map((ticketJson) => Ticket.fromJson(ticketJson))
              .toList();
          developer.log('[TICKET] Successfully retrieved ${tickets.length} tickets.', name: 'TicketService');
          return tickets;
        }
        return [];
      } else if (response.statusCode == 404) {
        final responseData = json.decode(response.body);
        if (responseData["message"] == "No open tickets found.") {
          developer.log('[TICKET] No open tickets found, returning empty list.', name: 'TicketService');
          return [];
        }
      }
      throw HttpException(
        'Failed to get tickets',
        statusCode: response.statusCode,
        serverMessage: json.decode(response.body)['message'] ?? 'Unknown server error',
      );
    } on SocketException {
      throw NoInternetException('No internet connection available');
    } on TimeoutException {
      throw RequestTimeoutException('Request timed out');
    } catch (e, stackTrace) {
      developer.log(
        '[TICKET] Unexpected error while getting tickets: $e',
        name: 'TicketService',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Creates a new ticket.
  Future<Ticket> createTicket(Ticket ticket) async {
    final url = ApiConfig.getFullUrl(ApiConfig.createTicketEndpoint);
    developer.log('[TICKET] Creating ticket at URL: $url', name: 'TicketService');

    try {
      final body = json.encode(ticket.toCreateRequest());
      developer.log('[TICKET] Request Body: $body', name: 'TicketService');

      final response = await _client.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      ).timeout(const Duration(seconds: 10));

      developer.log('[TICKET] Response Status Code: ${response.statusCode}', name: 'TicketService');
      developer.log('[TICKET] Response Body: ${response.body}', name: 'TicketService');

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['ticket'] != null) {
          final Ticket createdTicket = Ticket.fromJson(responseData['ticket']);
          developer.log('[TICKET] Successfully created ticket: ${createdTicket.ticketId}', name: 'TicketService');
          return createdTicket;
        }
        throw ServiceException(responseData['msg'] ?? 'Failed to create ticket');
      }
      throw HttpException(
        'Failed to create ticket',
        statusCode: response.statusCode,
        serverMessage: json.decode(response.body)['message'] ?? 'Unknown server error',
      );
    } on SocketException {
      throw NoInternetException('No internet connection available');
    } on TimeoutException {
      throw RequestTimeoutException('Request timed out');
    } catch (e, stackTrace) {
      developer.log(
        '[TICKET] Unexpected error while creating ticket: $e',
        name: 'TicketService',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Creates a new ticket with images.
  Future<Ticket> createTicketWithImages(Ticket ticket, List<String> imagePaths) async {
    final url = ApiConfig.getFullUrl(ApiConfig.createTicketEndpoint);
    developer.log('[TICKET] Creating ticket with images at URL: $url', name: 'TicketService');

    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));

      // Add ticket data as fields.
      Map<String, dynamic> ticketData = ticket.toCreateRequest();
      ticketData.forEach((key, value) {
        request.fields[key] = value.toString();
      });
      developer.log('[TICKET] Request Fields: ${request.fields}', name: 'TicketService');

      // Add image files.
      if (imagePaths.isNotEmpty) {
        for (var i = 0; i < imagePaths.length; i++) {
          final file = File(imagePaths[i]);
          if (await file.exists()) {
            final bytes = await file.readAsBytes();
            final filename = 'vehicle_image_${i + 1}.jpg';
            request.files.add(http.MultipartFile.fromBytes(
              'images',
              bytes,
              filename: filename,
              contentType: MediaType('image', 'jpeg'),
            ));
            developer.log('[TICKET] Added image: $filename (size: ${bytes.length} bytes)', name: 'TicketService');
          } else {
            developer.log('[TICKET] File not found at path: ${imagePaths[i]}', name: 'TicketService');
          }
        }
      }

      // Log headers and file details.
      developer.log('[TICKET] Request Headers: ${request.headers}', name: 'TicketService');
      developer.log('[TICKET] Request Files: ${request.files.map((f) => f.filename).toList()}', name: 'TicketService');

      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);

      developer.log('[TICKET] Response Status Code: ${response.statusCode}', name: 'TicketService');
      developer.log('[TICKET] Response Body: ${response.body}', name: 'TicketService');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        if (responseData['data'] != null) {
          final Ticket createdTicket = Ticket.fromJson(responseData['data']);
          developer.log('[TICKET] Successfully created ticket with images: ${createdTicket.ticketId}', name: 'TicketService');
          return createdTicket;
        }
        throw ServiceException(responseData['message'] ?? 'Failed to create ticket');
      }
      throw HttpException(
        'Failed to create ticket',
        statusCode: response.statusCode,
        serverMessage: json.decode(response.body)['message'] ?? 'Unknown server error',
      );
    } on SocketException {
      throw NoInternetException('No internet connection available');
    } on TimeoutException {
      throw RequestTimeoutException('Request timed out');
    } catch (e, stackTrace) {
      developer.log(
        '[TICKET] Unexpected error while creating ticket with images: $e',
        name: 'TicketService',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Gets ticket details by ID.
  Future<Ticket> getTicketDetails(String ticketId) async {
    final url = ApiConfig.getFullUrl(ApiConfig.ticketDetailsEndpoint + ticketId);
    developer.log('[TICKET] Fetching ticket details at URL: $url', name: 'TicketService');
    developer.log('[TICKET] Ticket ID: $ticketId', name: 'TicketService');

    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      developer.log('[TICKET] Response Status Code: ${response.statusCode}', name: 'TicketService');
      developer.log('[TICKET] Response Body: ${response.body}', name: 'TicketService');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['ticket'] != null) {
          final Ticket ticket = Ticket.fromJson(responseData['ticket']);
          developer.log('[TICKET] Successfully retrieved ticket details', name: 'TicketService');
          return ticket;
        }
        throw ServiceException('Ticket not found with ID: $ticketId');
      }
      throw HttpException(
        'Failed to get ticket',
        statusCode: response.statusCode,
        serverMessage: json.decode(response.body)['message'] ?? 'Unknown server error',
      );
    } on SocketException {
      throw NoInternetException('No internet connection available');
    } on TimeoutException {
      throw RequestTimeoutException('Request timed out');
    } catch (e, stackTrace) {
      developer.log(
        '[TICKET] Unexpected error while getting ticket details: $e',
        name: 'TicketService',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Rejects a ticket.
  Future<bool> rejectTicket(String ticketId, String remarks) async {
    final url = ApiConfig.getFullUrl(ApiConfig.rejectTicketEndpoint + ticketId);
    developer.log('[TICKET] Rejecting ticket at URL: $url', name: 'TicketService');
    developer.log('[TICKET] Ticket ID: $ticketId', name: 'TicketService');

    try {
      final body = json.encode({'remarks': remarks});
      developer.log('[TICKET] Request Body: $body', name: 'TicketService');

      final response = await _client.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      ).timeout(const Duration(seconds: 10));

      developer.log('[TICKET] Response Status Code: ${response.statusCode}', name: 'TicketService');
      developer.log('[TICKET] Response Body: ${response.body}', name: 'TicketService');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final bool success = responseData['success'] == true;
        developer.log('[TICKET] Reject operation ${success ? 'successful' : 'failed'}', name: 'TicketService');
        return success;
      }
      throw HttpException(
        'Failed to reject ticket',
        statusCode: response.statusCode,
        serverMessage: json.decode(response.body)['message'] ?? 'Unknown server error',
      );
    } on SocketException {
      throw NoInternetException('No internet connection available');
    } on TimeoutException {
      throw RequestTimeoutException('Request timed out');
    } catch (e, stackTrace) {
      developer.log(
        '[TICKET] Unexpected error while rejecting ticket: $e',
        name: 'TicketService',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Modifies a ticket.
  Future<Ticket> modifyTicket(String ticketId, Ticket ticket) async {
    final url = ApiConfig.getFullUrl(ApiConfig.modifyTicketEndpoint + ticketId);
    developer.log('[TICKET] Modifying ticket at URL: $url', name: 'TicketService');
    developer.log('[TICKET] Ticket ID: $ticketId', name: 'TicketService');

    try {
      final body = json.encode(ticket.toModifyRequest());
      developer.log('[TICKET] Request Body: $body', name: 'TicketService');

      final response = await _client.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      ).timeout(const Duration(seconds: 10));

      developer.log('[TICKET] Response Status Code: ${response.statusCode}', name: 'TicketService');
      developer.log('[TICKET] Response Body: ${response.body}', name: 'TicketService');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['ticket'] != null) {
          final Ticket modifiedTicket = Ticket.fromJson(responseData['ticket']);
          developer.log('[TICKET] Successfully modified ticket', name: 'TicketService');
          return modifiedTicket;
        }
        throw ServiceException(responseData['msg'] ?? 'Failed to modify ticket');
      }
      throw HttpException(
        'Failed to modify ticket',
        statusCode: response.statusCode,
        serverMessage: json.decode(response.body)['message'] ?? 'Unknown server error',
      );
    } on SocketException {
      throw NoInternetException('No internet connection available');
    } on TimeoutException {
      throw RequestTimeoutException('Request timed out');
    } catch (e, stackTrace) {
      developer.log(
        '[TICKET] Unexpected error while modifying ticket: $e',
        name: 'TicketService',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
