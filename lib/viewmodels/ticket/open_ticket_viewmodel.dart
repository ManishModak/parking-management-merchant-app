import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:merchant_app/models/plaza_fare.dart';
import '../../models/ticket.dart';
import '../../services/core/ticket_service.dart';
import '../../utils/exceptions.dart';

class OpenTicketViewModel extends ChangeNotifier {
  final TicketService _ticketService;

  bool isLoading = false;
  Exception? error;
  List<Map<String, dynamic>> tickets = [];

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
  final TextEditingController vehicleEntryTimestampController = TextEditingController();
  final TextEditingController ticketCreationTimeController = TextEditingController();
  final TextEditingController ticketStatusController = TextEditingController();
  final TextEditingController modificationTimeController = TextEditingController();

  // Field-specific error states
  String? vehicleNumberError;
  String? floorIdError;
  String? slotIdError;
  String? vehicleTypeError;
  String? apiError;
  String? currentTicketId;

  String? selectedVehicleType;
  List<String> get vehicleTypes => VehicleTypes.values; // Adjust as per your needs

  List<String>? capturedImageUrls;

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
        'plazaName': ticket.plazaId, // Adjust if plazaName is available
        'entryTime': ticket.entryTime,
        'status': ticket.status.toString().split('.').last,
        'entryLaneId': ticket.entryLaneId,
        'entryLaneDirection': ticket.entryLaneDirection,
        'ticketCreationTime': ticket.createdTime.toIso8601String(),
        'floorId': ticket.floorId.isEmpty ? 'N/A' : ticket.floorId,
        'slotId': ticket.slotId.isEmpty ? 'N/A' : ticket.slotId,
        'capturedImages': ticket.capturedImages,
        'modificationTime': ticket.modificationTime?.toIso8601String(),
      }).toList();

      if (tickets.isEmpty) {
        developer.log('[OpenTicketViewModel] No open tickets found.', name: 'OpenTicketViewModel');
      }
    } catch (e) {
      error = e as Exception;
      developer.log('[OpenTicketViewModel] Error fetching tickets: $error', name: 'OpenTicketViewModel');
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
      initializeTicketData(ticket);
      developer.log('[OpenTicketViewModel] Initialized ticket data with capturedImageUrls: $capturedImageUrls', name: 'OpenTicketViewModel');
    } catch (e) {
      error = e as Exception;
      developer.log('[OpenTicketViewModel] Error fetching ticket details: $error', name: 'OpenTicketViewModel');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void initializeTicketData(Ticket ticket) {
    currentTicketId = ticket.ticketId;
    ticketIdController.text = ticket.ticketId ?? '';
    ticketRefIdController.text = ticket.ticketRefId ?? '';
    plazaIdController.text = ticket.plazaId;
    entryLaneIdController.text = ticket.entryLaneId;
    entryLaneDirectionController.text = ticket.entryLaneDirection;
    floorIdController.text = ticket.floorId.isEmpty ? 'N/A' : ticket.floorId; // Updated to handle empty string
    slotIdController.text = ticket.slotId.isEmpty ? 'N/A' : ticket.slotId;     // Updated to handle empty string
    vehicleNumberController.text = ticket.vehicleNumber;
    vehicleTypeController.text = ticket.vehicleType;
    selectedVehicleType = ticket.vehicleType;
    vehicleEntryTimestampController.text = ticket.entryTime ?? '';
    ticketCreationTimeController.text = ticket.createdTime.toIso8601String();
    ticketStatusController.text = ticket.status.toString().split('.').last;
    capturedImageUrls = ticket.capturedImages;
    modificationTimeController.text = ticket.modificationTime?.toIso8601String() ?? '';
    developer.log('[OpenTicketViewModel] Captured Image URLs set to: $capturedImageUrls', name: 'OpenTicketViewModel');
    notifyListeners();
  }

  Future<bool> saveTicketChanges() async {
    if (!validateForm()) {
      error = ServiceException('Please correct the validation errors');
      notifyListeners();
      return false;
    }

    try {
      isLoading = true;
      apiError = null;
      error = null;
      notifyListeners();

      final updatedTicket = Ticket(
        ticketId: currentTicketId,
        ticketRefId: ticketRefIdController.text,
        plazaId: plazaIdController.text,
        entryLaneId: entryLaneIdController.text,
        entryLaneDirection: entryLaneDirectionController.text,
        floorId: floorIdController.text == 'N/A' ? '' : floorIdController.text, // Convert back to empty string for API
        slotId: slotIdController.text == 'N/A' ? '' : slotIdController.text,   // Convert back to empty string for API
        vehicleNumber: vehicleNumberController.text,
        vehicleType: vehicleTypeController.text,
        status: Status.pending,
        capturedImages: capturedImageUrls,
        modifiedBy: 'System',
        modificationTime: DateTime.now(),
      );

      await _ticketService.modifyTicket(currentTicketId!, updatedTicket);
      await fetchOpenTickets();
      return true;
    } catch (e) {
      error = e as Exception;
      apiError = error.toString();
      developer.log('[OpenTicketViewModel] Error saving ticket changes: $error', name: 'OpenTicketViewModel');
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
    vehicleEntryTimestampController.dispose();
    ticketCreationTimeController.dispose();
    ticketStatusController.dispose();
    modificationTimeController.dispose();
    super.dispose();
  }
}