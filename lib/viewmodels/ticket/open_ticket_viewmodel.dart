import 'dart:developer';
import 'package:flutter/material.dart';
import '../../models/plaza_fare.dart';
import '../../models/ticket.dart';
import '../../services/core/ticket_service.dart';

class OpenTicketViewModel extends ChangeNotifier {
  final TicketService _ticketService;

  bool isLoading = false;
  String? error;
  List<Map<String, dynamic>> tickets = [];

  // Controllers
  final TextEditingController ticketIdController = TextEditingController(); // Added for ticket_id
  final TextEditingController ticketRefIdController = TextEditingController();
  final TextEditingController plazaIdController = TextEditingController();
  final TextEditingController entryLaneIdController = TextEditingController();
  final TextEditingController entryLaneDirectionController = TextEditingController();
  final TextEditingController floorIdController = TextEditingController();
  final TextEditingController slotIdController = TextEditingController();
  final TextEditingController capturedImageController = TextEditingController();
  final TextEditingController vehicleNumberController = TextEditingController();
  final TextEditingController vehicleTypeController = TextEditingController();
  final TextEditingController vehicleEntryTimestampController = TextEditingController();
  final TextEditingController ticketCreationTimeController = TextEditingController();
  final TextEditingController ticketStatusController = TextEditingController();
  final TextEditingController modificationTimeController = TextEditingController(); // Added for modification_time

  // Field-specific error states for editable fields
  String? vehicleNumberError;
  String? floorIdError;
  String? slotIdError;
  String? vehicleTypeError;
  String? apiError;
  String? currentTicketId;

  String? selectedVehicleType;
  List<String> get vehicleTypes => VehicleTypes.values;

  String? capturedImageUrl;

  OpenTicketViewModel({TicketService? ticketService})
      : _ticketService = ticketService ?? TicketService();

  void resetErrors() {
    vehicleNumberError = null;
    floorIdError = null;
    slotIdError = null;
    vehicleTypeError = null;
    apiError = null;
    error = null;
    notifyListeners();
  }

  bool validateForm() {
    bool isValid = true;
    resetErrors();

    if (vehicleNumberController.text.isEmpty || vehicleNumberController.text.length > 20) {
      vehicleNumberError = 'Vehicle number must be between 1 and 20 characters';
      isValid = false;
    }

    if (vehicleTypeController.text.isEmpty) {
      vehicleTypeError = 'Vehicle type is required';
      isValid = false;
    }

    if (floorIdController.text.isEmpty || floorIdController.text.length > 20) {
      floorIdError = 'Floor ID must be between 1 and 20 characters';
      isValid = false;
    }

    if (slotIdController.text.isEmpty || slotIdController.text.length > 20) {
      slotIdError = 'Slot ID must be between 1 and 20 characters';
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
        'plazaId': {ticket.plazaId},
        'entryTime': ticket.entryTime,
        'status': ticket.status.toString().split('.').last,
        'entryLaneId': ticket.entryLaneId,
        'entryLaneDirection': ticket.entryLaneDirection,
        'ticketCreationTime': ticket.createdTime.toIso8601String(),
        'floorId': ticket.floorId.isEmpty ? 'N/A' : ticket.floorId, // Check for null or empty
        'slotId': ticket.slotId.isEmpty ? 'N/A' : ticket.slotId,     // Check for null or empty
        'capturedImage': ticket.capturedImage,
        'modificationTime': ticket.modificationTime?.toIso8601String(),
      }).toList();

      if (tickets.isEmpty) {
        log('[OpenTicketViewModel] No open tickets found, setting empty list.', name: 'OpenTicketViewModel');
      }
    } catch (e) {
      error = 'Failed to load tickets: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveTicketChanges() async {
    if (!validateForm()) {
      error = 'Please correct the validation errors';
      notifyListeners();
      return false;
    }

    try {
      isLoading = true;
      apiError = null;
      error = null;
      notifyListeners();

      final updatedTicket = Ticket(
        ticketId: ticketIdController.text.isEmpty ? null : ticketIdController.text,
        ticketRefId: ticketRefIdController.text,
        plazaId: plazaIdController.text,
        entryLaneId: entryLaneIdController.text,
        entryLaneDirection: entryLaneDirectionController.text,
        floorId: floorIdController.text,
        slotId: slotIdController.text,
        vehicleNumber: vehicleNumberController.text,
        vehicleType: vehicleTypeController.text,
        status: Status.pending,
        capturedImage: capturedImageUrl,
        modifiedBy: 'System', // Assuming current user is 'System' for now
        modificationTime: DateTime.now(),
      );

      await _ticketService.modifyTicket(ticketRefIdController.text, updatedTicket);
      await fetchOpenTickets();

      return true;
    } catch (e) {
      apiError = 'Failed to update ticket: $e';
      error = apiError;
      notifyListeners();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void updateVehicleType(String? type) {
    selectedVehicleType = type;
    if (type != null) {
      vehicleTypeController.text = type;
      vehicleTypeError = null;
    }
    notifyListeners();
  }

  void initializeTicketData(Map<String, dynamic> ticketData) {
    resetErrors();
    currentTicketId = ticketData['ticketID']?.toString() ?? '';
    ticketIdController.text = ticketData['ticketID']?.toString() ?? '';
    ticketRefIdController.text = ticketData['ticketRefID']?.toString() ?? '';
    plazaIdController.text = ticketData['plazaID']?.toString() ?? '';
    entryLaneIdController.text = ticketData['entryLaneId']?.toString() ?? '';
    entryLaneDirectionController.text = ticketData['entryLaneDirection']?.toString() ?? '';
    floorIdController.text = ticketData['floorId']?.toString() ?? '';
    slotIdController.text = ticketData['slotId']?.toString() ?? '';
    vehicleNumberController.text = ticketData['vehicleNumber']?.toString() ?? '';
    vehicleTypeController.text = ticketData['vehicleType']?.toString() ?? '';
    selectedVehicleType = ticketData['vehicleType']?.toString();
    vehicleEntryTimestampController.text = ticketData['entryTime']?.toString() ?? '';
    ticketCreationTimeController.text = ticketData['ticketCreationTime']?.toString() ?? '';
    ticketStatusController.text = ticketData['status']?.toString() ?? '';
    capturedImageUrl = ticketData['capturedImage']?.toString();
    modificationTimeController.text = ticketData['modificationTime']?.toString() ?? '';
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
    capturedImageController.dispose();
    vehicleNumberController.dispose();
    vehicleTypeController.dispose();
    vehicleEntryTimestampController.dispose();
    ticketCreationTimeController.dispose();
    ticketStatusController.dispose();
    modificationTimeController.dispose();
    super.dispose();
  }
}