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
        'ticketID': ticket.ticketId,
        'ticketRefID': ticket.ticketRefId,
        'plazaID': ticket.plazaId,
        'vehicleNumber': ticket.vehicleNumber,
        'vehicleType': ticket.vehicleType,
        'plazaName': "Plaza: ${ticket.plazaId}", // Fixed plazaName mapping
        'entryTime': ticket.entryTime ?? DateTime.now().toIso8601String(),
        'status': ticket.status.toString().split('.').last,
        'entryLaneId': ticket.entryLaneId,
        'entryLaneDirection': ticket.entryLaneDirection,
        'ticketCreationTime': ticket.createdTime.toIso8601String(),
        'floorId': ticket.floorId.isEmpty ? 'N/A' : ticket.floorId,
        'slotId': ticket.slotId.isEmpty ? 'N/A' : ticket.slotId,
        'capturedImages': ticket.capturedImages ?? [],
      }).toList();

      if (tickets.isEmpty) {
        developer.log('[RejectTicketViewModel] No rejectable tickets found.');
      }
    } catch (e) {
      error = e as Exception;
      developer.log('[RejectTicketViewModel] Error fetching tickets: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTicketDetails(String ticketId) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final ticket = await _ticketService.getTicketDetails(ticketId);
      initializeTicketDataFromTicket(ticket);
      developer.log('[RejectTicketViewModel] Fetched ticket details for $ticketId: ${ticket.ticketId}');
    } catch (e) {
      error = e as Exception;
      developer.log('[RejectTicketViewModel] Error fetching ticket details: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void initializeTicketDataFromTicket(Ticket ticket) {
    currentTicketId = ticket.ticketId;
    ticketIdController.text = ticket.ticketId ?? '';
    ticketRefIdController.text = ticket.ticketRefId ?? '';
    plazaIdController.text = ticket.plazaId ?? '';
    entryLaneIdController.text = ticket.entryLaneId;
    entryLaneDirectionController.text = ticket.entryLaneDirection;
    floorIdController.text = ticket.floorId.isEmpty ? 'N/A' : ticket.floorId;
    slotIdController.text = ticket.slotId.isEmpty ? 'N/A' : ticket.slotId;
    vehicleNumberController.text = ticket.vehicleNumber ?? '';
    vehicleTypeController.text = ticket.vehicleType;
    ticketStatusController.text = ticket.status.toString().split('.').last;
    capturedImageUrls = ticket.capturedImages ?? [];

    if (ticket.entryTime != null) {
      entryTimeController.text = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(ticket.entryTime!));
    } else {
      entryTimeController.text = 'N/A';
    }

    ticketCreationTimeController.text = DateFormat('dd MMM yyyy, hh:mm a').format(ticket.createdTime);
    remarksController.text = ticket.remarks ?? '';

    resetErrors();
    notifyListeners();
  }

  Future<bool> rejectTicket() async {
    if (!validateForm()) return false;

    try {
      isLoading = true;
      apiError = null;
      error = null;
      notifyListeners();

      await _ticketService.rejectTicket(currentTicketId!, remarksController.text);
      await fetchOpenTickets();
      return true;
    } catch (e) {
      error = e as Exception;
      apiError = e.toString();
      developer.log('[RejectTicketViewModel] Error rejecting ticket: $e');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
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
    capturedImageUrls = null; // Clear capturedImageUrls to prevent memory leaks
    super.dispose();
  }
}