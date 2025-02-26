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

  // Controllers
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

  String? capturedImageUrl;

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

      final fetchedTickets = await _ticketService.getOpenTickets(); // Assuming this fetches rejectable tickets
      tickets = fetchedTickets.map((ticket) => {
        'ticketID': ticket.ticketId,
        'ticketRefID': ticket.ticketRefId,
        'plazaID': ticket.plazaId,
        'vehicleNumber': ticket.vehicleNumber,
        'vehicleType': ticket.vehicleType,
        'plazaName': 'Plaza ${ticket.plazaId}', // Replace with actual plaza name if available
        'entryTime': ticket.entryTime,
        'status': ticket.status.toString().split('.').last,
        'entryLaneId': ticket.entryLaneId,
        'entryLaneDirection': ticket.entryLaneDirection,
        'ticketCreationTime': ticket.createdTime.toIso8601String(),
        'floorId': ticket.floorId.isEmpty ? 'N/A' : ticket.floorId,
        'slotId': ticket.slotId.isEmpty ? 'N/A' : ticket.slotId,
        //'capturedImage': ticket.capturedImage,
        'modificationTime': ticket.modificationTime?.toIso8601String(),
      }).toList();

      if (tickets.isEmpty) {
        developer.log('[RejectTicketViewModel] No rejectable tickets found.', name: 'RejectTicketViewModel');
      }
    } catch (e) {
      error = e as Exception;
      developer.log('[RejectTicketViewModel] Error fetching tickets: $error', name: 'RejectTicketViewModel');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> rejectTicket() async {
    if (!validateForm()) {
      return false;
    }

    try {
      isLoading = true;
      apiError = null;
      error = null;
      notifyListeners();

      final success = await _ticketService.rejectTicket(
        ticketRefIdController.text,
        remarksController.text,
      );

      if (success) {
        await fetchOpenTickets(); // Refresh the list after rejection
        return true;
      }
      return false;
    } catch (e) {
      error = e as Exception;
      apiError = 'Failed to reject ticket: ${e.toString()}';
      developer.log('[RejectTicketViewModel] Error rejecting ticket: $error', name: 'RejectTicketViewModel');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void initializeTicketData(Map<String, dynamic> ticket) {
    resetErrors();
    currentTicketId = ticket['ticketID']?.toString() ?? '';
    ticketIdController.text = ticket['ticketID']?.toString() ?? '';
    ticketRefIdController.text = ticket['ticketRefID']?.toString() ?? '';
    plazaIdController.text = ticket['plazaID']?.toString() ?? '';
    entryLaneIdController.text = ticket['entryLaneId']?.toString() ?? '';
    entryLaneDirectionController.text = ticket['entryLaneDirection']?.toString() ?? '';
    floorIdController.text = ticket['floorId']?.toString() ?? '';
    slotIdController.text = ticket['slotId']?.toString() ?? '';
    vehicleNumberController.text = ticket['vehicleNumber']?.toString() ?? '';
    vehicleTypeController.text = ticket['vehicleType']?.toString() ?? '';
    ticketStatusController.text = ticket['status']?.toString() ?? '';
    capturedImageUrl = ticket['capturedImage']?.toString();

    if (ticket['entryTime'] != null) {
      final entryTime = DateTime.parse(ticket['entryTime']);
      entryTimeController.text = DateFormat('dd MMM yyyy, hh:mm a').format(entryTime);
    }
    if (ticket['ticketCreationTime'] != null) {
      final creationTime = DateTime.parse(ticket['ticketCreationTime']);
      ticketCreationTimeController.text = DateFormat('dd MMM yyyy, hh:mm a').format(creationTime);
    }

    notifyListeners();
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
    super.dispose();
  }
}