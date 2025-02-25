import 'dart:convert';
import 'dart:developer' as developer; // Added for log function
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../config/api_config.dart';
import '../../models/ticket.dart';

class TicketService {
  final http.Client _client;

  TicketService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches all open tickets
  Future<List<Ticket>> getOpenTickets() async {
    final url = ApiConfig.getFullUrl(ApiConfig.getOpenTicketsEndpoint);
    developer.log('[TICKET] Fetching open tickets at URL: $url', name: 'TicketService');

    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      developer.log('[TICKET] Response Status Code: ${response.statusCode}', name: 'TicketService');
      developer.log('[TICKET] Response Body: ${response.body}', name: 'TicketService');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData["message"] == "Open tickets fetched successfully." && responseData["data"] != null) {
          final List<Ticket> tickets = (responseData['data'] as List)
              .map((ticketJson) => Ticket.fromJson(ticketJson))
              .toList();
          developer.log('[TICKET] Successfully retrieved ${tickets.length} tickets.', name: 'TicketService');
          return tickets;
        }
        // If no tickets are found but the response is still valid, return an empty list
        return [];
      } else if (response.statusCode == 404) {
        final responseData = json.decode(response.body);
        if (responseData["message"] == "No open tickets found.") {
          developer.log('[TICKET] No open tickets found, returning empty list.', name: 'TicketService');
          return [];
        }
      }
      throw Exception('Failed to get tickets: ${response.statusCode}');
    } catch (e, stackTrace) {
      developer.log('[TICKET] Exception while getting tickets: $e', name: 'TicketService', error: e, stackTrace: stackTrace);
      throw Exception('Error fetching tickets: $e');
    }
  }

  /// Creates a new ticket
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
      );

      developer.log('[TICKET] Response Status Code: ${response.statusCode}', name: 'TicketService');
      developer.log('[TICKET] Response Body: ${response.body}', name: 'TicketService');

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['ticket'] != null) {
          final Ticket createdTicket = Ticket.fromJson(responseData['ticket']);
          developer.log('[TICKET] Successfully created ticket: ${createdTicket.ticketId}', name: 'TicketService');
          return createdTicket;
        }
        throw Exception(responseData['msg'] ?? 'Failed to create ticket');
      }
      throw Exception('Failed to create ticket: ${response.statusCode}');
    } catch (e, stackTrace) {
      developer.log('[TICKET] Exception while creating ticket: $e', name: 'TicketService', error: e, stackTrace: stackTrace);
      throw Exception('Error creating ticket: $e');
    }
  }

  /// Creates a new ticket with images
  Future<Ticket> createTicketWithImages(Ticket ticket, List<String> imagePaths) async {
    final url = ApiConfig.getFullUrl(ApiConfig.createTicketEndpoint);
    developer.log('[TICKET] Creating ticket at URL: $url', name: 'TicketService');

    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));

      // Add ticket data as fields
      Map<String, dynamic> ticketData = ticket.toCreateRequest();
      ticketData.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      // Add image files
      if (imagePaths.isNotEmpty) {
        for (var i = 0; i < imagePaths.length; i++) {
          final file = File(imagePaths[i]);
          if (await file.exists()) {
            final bytes = await file.readAsBytes();
            final filename = 'vehicle_image_${i+1}.jpg';

            // Changed field name to match backend expectation
            request.files.add(http.MultipartFile.fromBytes(
              'images', // Changed from 'file' to 'images' to match backend
              bytes,
              filename: filename,
              contentType: MediaType('image', 'jpeg'),
            ));
          }
        }
      }

      developer.log('[TICKET] Sending multipart request with ${imagePaths.length} images', name: 'TicketService');
      developer.log('[TICKET] Request fields: ${request.fields}', name: 'TicketService');
      developer.log('[TICKET] Request files field names: ${request.files.map((f) => f.field).toList()}', name: 'TicketService');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      developer.log('[TICKET] Response Status Code: ${response.statusCode}', name: 'TicketService');
      developer.log('[TICKET] Response Body: ${response.body}', name: 'TicketService');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        if (responseData['data'] != null) {
          final Ticket createdTicket = Ticket.fromJson(responseData['data']);
          developer.log('[TICKET] Successfully created ticket: ${createdTicket.ticketId}', name: 'TicketService');
          return createdTicket;
        }
        throw Exception(responseData['message'] ?? 'Failed to create ticket');
      }
      throw Exception('Failed to create ticket: ${response.statusCode}');
    } catch (e, stackTrace) {
      developer.log('[TICKET] Exception while creating ticket: $e', name: 'TicketService', error: e, stackTrace: stackTrace);
      throw Exception('Error creating ticket: $e');
    }
  }

  /// Gets ticket details by ID
  Future<Ticket> getTicketDetails(String ticketId) async {
    final url = ApiConfig.getFullUrl(ApiConfig.ticketDetailsEndpoint + ticketId);
    developer.log('[TICKET] Fetching ticket details at URL: $url', name: 'TicketService');
    developer.log('[TICKET] Ticket ID: $ticketId', name: 'TicketService');

    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      developer.log('[TICKET] Response Status Code: ${response.statusCode}', name: 'TicketService');
      developer.log('[TICKET] Response Body: ${response.body}', name: 'TicketService');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['ticket'] != null) {
          final Ticket ticket = Ticket.fromJson(responseData['ticket']);
          developer.log('[TICKET] Successfully retrieved ticket details', name: 'TicketService');
          return ticket;
        }
        throw Exception('Ticket not found with ID: $ticketId');
      }
      throw Exception('Failed to get ticket: ${response.statusCode}');
    } catch (e, stackTrace) {
      developer.log('[TICKET] Exception while getting ticket details: $e', name: 'TicketService', error: e, stackTrace: stackTrace);
      throw Exception('Error getting ticket details: $e');
    }
  }

  /// Rejects a ticket
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
      );

      developer.log('[TICKET] Response Status Code: ${response.statusCode}', name: 'TicketService');
      developer.log('[TICKET] Response Body: ${response.body}', name: 'TicketService');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final bool success = responseData['success'] == true;
        developer.log('[TICKET] Reject operation ${success ? 'successful' : 'failed'}', name: 'TicketService');
        return success;
      }
      throw Exception('Failed to reject ticket: ${response.statusCode}');
    } catch (e, stackTrace) {
      developer.log('[TICKET] Exception while rejecting ticket: $e', name: 'TicketService', error: e, stackTrace: stackTrace);
      throw Exception('Error rejecting ticket: $e');
    }
  }

  /// Modifies a ticket
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
      );

      developer.log('[TICKET] Response Status Code: ${response.statusCode}', name: 'TicketService');
      developer.log('[TICKET] Response Body: ${response.body}', name: 'TicketService');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['ticket'] != null) {
          final Ticket modifiedTicket = Ticket.fromJson(responseData['ticket']);
          developer.log('[TICKET] Successfully modified ticket', name: 'TicketService');
          return modifiedTicket;
        }
        throw Exception(responseData['msg'] ?? 'Failed to modify ticket');
      }
      throw Exception('Failed to modify ticket: ${response.statusCode}');
    } catch (e, stackTrace) {
      developer.log('[TICKET] Exception while modifying ticket: $e', name: 'TicketService', error: e, stackTrace: stackTrace);
      throw Exception('Error modifying ticket: $e');
    }
  }
}