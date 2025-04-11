import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/ticket.dart';
import '../../services/core/ticket_service.dart';
import '../../utils/exceptions.dart';

class RejectTicketViewModel extends ChangeNotifier {
  final TicketService _ticketService;

  bool isLoading = false;
  Exception? error;
  List<Map<String, dynamic>> tickets = [];
  String? apiError;
  String? remarksError;
  String? currentTicketId;
  Ticket? ticket; // Added to store the current ticket object

  final TextEditingController ticketIdController = TextEditingController();
  final TextEditingController ticketRefIdController = TextEditingController();
  final TextEditingController plazaIdController = TextEditingController();
  final TextEditingController entryLaneIdController = TextEditingController();
  final TextEditingController entryLaneDirectionController = TextEditingController();
  final TextEditingController floorIdController = TextEditingController();
  final TextEditingController slotIdController = TextEditingController();
  final TextEditingController vehicleNumberController = TextEditingController();
  final TextEditingController vehicleTypeController = TextEditingController();
  final TextEditingController entryTimeController = TextEditingController();
  final TextEditingController ticketCreationTimeController = TextEditingController();
  final TextEditingController ticketStatusController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();

  List<String>? capturedImageUrls;

  RejectTicketViewModel({TicketService? ticketService})
      : _ticketService = ticketService ?? TicketService();

  void resetErrors() {
    remarksError = null;
    apiError = null;
    error = null;
    notifyListeners();
  }

  void resetRemarks() {
    remarksController.clear();
    resetErrors();
  }

  bool validateForm() {
    resetErrors();
    bool isValid = true;

    if (remarksController.text.isEmpty || remarksController.text.length < 10) {
      remarksError = 'Remarks must be at least 10 characters long';
      isValid = false;
    }

    notifyListeners();
    return isValid;
  }

  Future<void> fetchOpenTickets() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final fetchedTickets = await _ticketService.getOpenTickets();
      tickets = fetchedTickets.map((ticket) => {
        'ticketId': ticket.ticketId,
        'ticketRefId': ticket.ticketRefId,
        'plazaId': ticket.plazaId,
        'vehicleNumber': ticket.vehicleNumber,
        'vehicleType': ticket.vehicleType,
        'plazaName': "Plaza: ${ticket.plazaId}", // Consider fetching actual plaza name if available
        'entryTime': ticket.entryTime ?? DateTime.now().toIso8601String(),
        'ticketStatus': ticket.status.toString().split('.').last,
        'entryLaneId': ticket.entryLaneId,
        'entryLaneDirection': ticket.entryLaneDirection,
        'ticketCreationTime': ticket.createdTime.toIso8601String(),
        'floorId': ticket.floorId ?? 'N/A',
        'slotId': ticket.slotId ?? 'N/A',
        'capturedImages': ticket.capturedImages ?? [],
      }).toList();

      developer.log('[RejectTicketViewModel] Fetched ${tickets.length} tickets', name: 'RejectTicketViewModel');
    } catch (e) {
      error = e as Exception;
      apiError = _getErrorMessage(e);
      developer.log('[RejectTicketViewModel] Error fetching tickets: $e', name: 'RejectTicketViewModel');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTicketDetails(String ticketId) async {
    try {
      isLoading = true;
      error = null;
      ticket = null; // Reset ticket
      notifyListeners();

      final fetchedTicket = await _ticketService.getTicketDetails(ticketId);
      ticket = fetchedTicket; // Store the ticket object
      initializeTicketDataFromTicket(fetchedTicket);
      developer.log('[RejectTicketViewModel] Fetched ticket details for $ticketId: ${fetchedTicket.ticketId}');
    } catch (e) {
      error = e as Exception;
      apiError = _getErrorMessage(e);
      developer.log('[RejectTicketViewModel] Error fetching ticket details: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void initializeTicketDataFromTicket(Ticket ticket) {
    currentTicketId = ticket.ticketId;
    ticketIdController.text = ticket.ticketId ?? 'N/A';
    ticketRefIdController.text = ticket.ticketRefId ?? 'N/A';
    plazaIdController.text = ticket.plazaId ?? 'N/A';
    entryLaneIdController.text = ticket.entryLaneId ?? 'N/A';
    entryLaneDirectionController.text = ticket.entryLaneDirection ?? 'N/A';
    floorIdController.text = ticket.floorId ?? 'N/A';
    slotIdController.text = ticket.slotId ?? 'N/A';
    vehicleNumberController.text = ticket.vehicleNumber ?? 'N/A';
    vehicleTypeController.text = ticket.vehicleType ?? 'N/A';
    ticketStatusController.text = ticket.status.toString().split('.').last;
    capturedImageUrls = ticket.capturedImages ?? [];

    entryTimeController.text = ticket.entryTime != null
        ? DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(ticket.entryTime!))
        : 'N/A';
    ticketCreationTimeController.text = DateFormat('dd MMM yyyy, hh:mm a').format(ticket.createdTime);
    remarksController.text = ticket.remarks ?? '';

    resetErrors();
    notifyListeners();
  }

  Future<bool> rejectTicket() async {
    if (!validateForm() || currentTicketId == null) return false;

    try {
      isLoading = true;
      apiError = null;
      error = null;
      notifyListeners();

      await _ticketService.rejectTicket(currentTicketId!, remarksController.text);
      developer.log('[RejectTicketViewModel] Ticket $currentTicketId rejected successfully');
      return true;
    } catch (e) {
      error = e as Exception;
      apiError = _getErrorMessage(e);
      developer.log('[RejectTicketViewModel] Error rejecting ticket: $e');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String _getErrorMessage(Exception e) {
    if (e is HttpException) {
      switch (e.statusCode) {
        case 400:
          return 'Invalid request. Please check your input.';
        case 401:
          return 'Unauthorized. Please log in again.';
        case 403:
          return 'Access denied. You lack permission.';
        case 404:
          return 'Ticket not found. It may have been deleted.';
        case 500:
          return 'Server error. Please try again later.';
        default:
          return e.serverMessage ?? 'An unexpected error occurred.';
      }
    }
    return e.toString();
  }

  @override
  void dispose() {
    ticketIdController.dispose();
    ticketRefIdController.dispose();
    plazaIdController.dispose();
    entryLaneIdController.dispose();
    entryLaneDirectionController.dispose();
    floorIdController.dispose();
    slotIdController.dispose();
    vehicleNumberController.dispose();
    vehicleTypeController.dispose();
    entryTimeController.dispose();
    ticketCreationTimeController.dispose();
    ticketStatusController.dispose();
    remarksController.dispose();
    capturedImageUrls = null;
    super.dispose();
  }
}