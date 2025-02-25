import 'dart:developer';
import 'package:flutter/material.dart';
import '../../services/core/ticket_service.dart';

class RejectTicketViewModel extends ChangeNotifier {
  final TicketService _ticketService;

  // Controllers for all fields
  final TextEditingController ticketIdController = TextEditingController();
  final TextEditingController ticketRefIdController = TextEditingController();
  final TextEditingController plazaIdController = TextEditingController();
  final TextEditingController plazaNameController = TextEditingController();
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

  // Error handling and state
  String? error; // Changed from errorText to error
  String? remarksError;
  bool isLoading = false;
  List<Map<String, dynamic>> tickets = [];

  // Captured image URL
  String? capturedImageUrl;
  String? _originalRemarks;

  RejectTicketViewModel({TicketService? ticketService})
      : _ticketService = ticketService ?? TicketService();

  // Fetch open tickets
  Future<void> fetchOpenTickets() async {
    try {
      isLoading = true;
      error = null; // Updated to use error
      notifyListeners();

      final fetchedTickets = await _ticketService.getOpenTickets();
      tickets = fetchedTickets.map((ticket) => {
        'ticketID': ticket.ticketId,
        'ticketRefId': ticket.ticketRefId,
        'plazaID': ticket.plazaId,
        'vehicleNumber': ticket.vehicleNumber,
        'vehicleType': ticket.vehicleType,
        'plazaName': 'Plaza ${ticket.plazaId}',
        'entryTime': ticket.entryTime,
        'status': ticket.status.toString().split('.').last,
        'entryLaneId': ticket.entryLaneId,
        'entryLaneDirection': ticket.entryLaneDirection,
        'ticketCreationTime': ticket.createdTime.toIso8601String(),
        'floorId': ticket.floorId.isEmpty ? 'N/A' : ticket.floorId,
        'slotId': ticket.slotId.isEmpty ? 'N/A' : ticket.slotId,
        'capturedImage': ticket.capturedImage,
        'modificationTime': ticket.modificationTime?.toIso8601String(),
      }).toList();

      if (tickets.isEmpty) {
        log('[RejectTicketViewModel] No open tickets found, setting empty list.', name: 'RejectTicketViewModel');
      }
    } catch (e) {
      error = 'Failed to load tickets: $e'; // Updated to use error
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Initialize with ticket data
  void initializeTicketData(Map<String, dynamic> ticketData) {
    ticketIdController.text = ticketData['ticketID'] ?? '';
    ticketRefIdController.text = ticketData['ticketRefId'] ?? '';
    plazaIdController.text = ticketData['plazaID'] ?? '';
    plazaNameController.text = ticketData['plazaName'] ?? '';
    entryLaneIdController.text = ticketData['entryLaneId'] ?? '';
    entryLaneDirectionController.text = ticketData['entryLaneDirection'] ?? '';
    floorIdController.text = ticketData['floorId'] ?? '';
    slotIdController.text = ticketData['slotId'] ?? '';
    vehicleNumberController.text = ticketData['vehicleNumber'] ?? '';
    vehicleTypeController.text = ticketData['vehicleType'] ?? '';
    entryTimeController.text = ticketData['entryTime'] ?? '';
    ticketCreationTimeController.text = ticketData['ticketCreationTime'] ?? '';
    ticketStatusController.text = ticketData['status'] ?? '';
    remarksController.text = ticketData['remarks'] ?? '';
    _originalRemarks = ticketData['remarks'] ?? '';
    capturedImageUrl = ticketData['capturedImage'];
    error = null; // Updated to use error
    remarksError = null;
    notifyListeners();
  }

  // Reset remarks to original value
  void resetRemarks() {
    remarksController.text = _originalRemarks ?? '';
    remarksError = null;
    notifyListeners();
  }

  // Validate remarks on change
  void validateRemarks(String value) {
    if (value.trim().isEmpty) {
      remarksError = 'Remarks are required';
    } else if (value.trim().length < 10) {
      remarksError = 'Remarks must be at least 10 characters long';
    } else {
      remarksError = null;
    }
    notifyListeners();
  }

  // Validation
  bool validateForm() {
    validateRemarks(remarksController.text);
    return remarksError == null;
  }

  // Save ticket changes
  Future<bool> rejectTicket() async {
    if (!validateForm()) return false;

    isLoading = true;
    error = null; // Updated to use error
    notifyListeners();

    try {
      final success = await _ticketService.rejectTicket(
        ticketRefIdController.text,
        remarksController.text.trim(),
      );

      isLoading = false;

      if (success) {
        _originalRemarks = remarksController.text;
        error = null; // Updated to use error
      } else {
        error = 'Failed to reject ticket. Please try again.'; // Updated to use error
      }

      notifyListeners();
      return success;
    } catch (e) {
      isLoading = false;
      error = 'Error rejecting ticket: ${e.toString()}'; // Updated to use error
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    ticketIdController.dispose();
    ticketRefIdController.dispose();
    plazaIdController.dispose();
    plazaNameController.dispose();
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