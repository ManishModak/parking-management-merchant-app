import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/plaza_fare.dart';
import '../../models/ticket.dart';
import '../../services/core/ticket_service.dart';
import '../../utils/exceptions.dart';

class OpenTicketViewModel extends ChangeNotifier {
  final TicketService _ticketService;

  bool isLoading = false;
  Exception? error;
  List<Map<String, dynamic>> tickets = [];
  Ticket? ticket; // Explicitly define ticket property

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
  List<String> get vehicleTypes => VehicleTypes.values;

  List<String>? capturedImageUrls;

  OpenTicketViewModel({TicketService? ticketService})
      : _ticketService = ticketService ?? TicketService() {
    developer.log('OpenTicketViewModel initialized', name: 'OpenTicketViewModel');
  }

  void resetErrors() {
    developer.log('Resetting all error states', name: 'OpenTicketViewModel');
    vehicleNumberError = null;
    floorIdError = null;
    slotIdError = null;
    vehicleTypeError = null;
    apiError = null;
    error = null;
    notifyListeners();
  }

  bool validateForm() {
    developer.log('Validating form data', name: 'OpenTicketViewModel');
    bool isValid = true;
    resetErrors();

    if (vehicleNumberController.text.isEmpty || vehicleNumberController.text.length > 20) {
      vehicleNumberError = 'Vehicle number must be between 1 and 20 characters';
      developer.log('Validation failed: $vehicleNumberError', name: 'OpenTicketViewModel');
      isValid = false;
    }

    if (vehicleTypeController.text.isEmpty) {
      vehicleTypeError = 'Vehicle type is required';
      developer.log('Validation failed: $vehicleTypeError', name: 'OpenTicketViewModel');
      isValid = false;
    }

    if (floorIdController.text.isEmpty || floorIdController.text.length > 20) {
      floorIdError = 'Floor ID must be between 1 and 20 characters';
      developer.log('Validation failed: $floorIdError', name: 'OpenTicketViewModel');
      isValid = false;
    }

    if (slotIdController.text.isEmpty || slotIdController.text.length > 20) {
      slotIdError = 'Slot ID must be between 1 and 20 characters';
      developer.log('Validation failed: $slotIdError', name: 'OpenTicketViewModel');
      isValid = false;
    }

    notifyListeners();
    developer.log('Form validation result: $isValid', name: 'OpenTicketViewModel');
    return isValid;
  }

  Future<bool> markExit(String ticketId) async {
    developer.log('Attempting to mark exit for ticketId: $ticketId', name: 'OpenTicketViewModel');
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      await _ticketService.markTicketExit(ticketId);
      developer.log('Successfully marked exit for ticketId: $ticketId', name: 'OpenTicketViewModel');
      await fetchOpenTickets();
      return true;
    } catch (e) {
      error = e as Exception;
      developer.log('Error marking exit for ticketId: $ticketId: $error',
          name: 'OpenTicketViewModel', error: e);
      notifyListeners();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
      developer.log('Mark exit operation completed, isLoading: $isLoading', name: 'OpenTicketViewModel');
    }
  }

  Future<void> fetchOpenTickets() async {
    developer.log('Fetching open tickets', name: 'OpenTicketViewModel');
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
        'plazaName': ticket.plazaId,
        'entryTime': ticket.entryTime,
        'ticketStatus': ticket.status.toString().split('.').last,
        'entryLaneId': ticket.entryLaneId,
        'entryLaneDirection': ticket.entryLaneDirection,
        'ticketCreationTime': ticket.createdTime.toIso8601String(),
        'floorId': ticket.floorId ?? 'N/A',
        'slotId': ticket.slotId ?? 'N/A',
        'capturedImages': ticket.capturedImages,
        'modificationTime': ticket.modificationTime?.toIso8601String(),
      }).toList();

      developer.log('Fetched ${tickets.length} open tickets', name: 'OpenTicketViewModel');
    } catch (e) {
      error = e as Exception;
      developer.log('Error fetching open tickets: $error', name: 'OpenTicketViewModel', error: e);
    } finally {
      isLoading = false;
      notifyListeners();
      developer.log('Fetch open tickets completed, isLoading: $isLoading', name: 'OpenTicketViewModel');
    }
  }

  Future<void> fetchTicketDetails(String ticketId) async {
    developer.log('Fetching ticket details for ticketId: $ticketId', name: 'OpenTicketViewModel');
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      ticket = await _ticketService.getTicketDetails(ticketId);
      initializeTicketData(ticket!);
      developer.log('Successfully fetched ticket details for ticketId: $ticketId',
          name: 'OpenTicketViewModel');
    } catch (e) {
      error = e as Exception;
      developer.log('Error fetching ticket details for ticketId: $ticketId: $error',
          name: 'OpenTicketViewModel', error: e);
    } finally {
      isLoading = false;
      notifyListeners();
      developer.log('Fetch ticket details completed, isLoading: $isLoading', name: 'OpenTicketViewModel');
    }
  }

  void initializeTicketData(Ticket ticket) {
    developer.log('Initializing ticket data for ticketId: ${ticket.ticketId}',
        name: 'OpenTicketViewModel');
    currentTicketId = ticket.ticketId;
    ticketIdController.text = ticket.ticketId ?? '';
    ticketRefIdController.text = ticket.ticketRefId ?? '';
    plazaIdController.text = ticket.plazaId!;
    entryLaneIdController.text = ticket.entryLaneId;
    entryLaneDirectionController.text = ticket.entryLaneDirection ?? '';
    floorIdController.text = ticket.floorId ?? 'N/A';
    slotIdController.text = ticket.slotId ?? 'N/A';
    vehicleNumberController.text = ticket.vehicleNumber ?? '';
    vehicleTypeController.text = ticket.vehicleType ?? '';
    selectedVehicleType = ticket.vehicleType;
    vehicleEntryTimestampController.text = ticket.entryTime ?? '';
    ticketCreationTimeController.text = ticket.createdTime.toIso8601String();
    ticketStatusController.text = ticket.status.toString().split('.').last;
    capturedImageUrls = ticket.capturedImages;
    modificationTimeController.text = ticket.modificationTime?.toIso8601String() ?? '';
    developer.log('Ticket data initialized, capturedImageUrls: $capturedImageUrls',
        name: 'OpenTicketViewModel');
    notifyListeners();
  }

  Future<bool> saveTicketChanges() async {
    developer.log('Attempting to save ticket changes for ticketId: $currentTicketId',
        name: 'OpenTicketViewModel');
    if (!validateForm()) {
      error = ServiceException('Please correct the validation errors');
      developer.log('Validation failed, cannot save changes', name: 'OpenTicketViewModel');
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
        floorId: floorIdController.text == 'N/A' ? '' : floorIdController.text,
        slotId: slotIdController.text == 'N/A' ? '' : slotIdController.text,
        vehicleNumber: vehicleNumberController.text,
        vehicleType: vehicleTypeController.text,
        status: Status.pending,
        capturedImages: capturedImageUrls,
        modifiedBy: 'System',
        modificationTime: DateTime.now(),
      );

      await _ticketService.modifyTicket(currentTicketId!, updatedTicket);
      developer.log('Successfully saved ticket changes for ticketId: $currentTicketId',
          name: 'OpenTicketViewModel');
      await fetchOpenTickets();
      return true;
    } catch (e) {
      error = e as Exception;
      apiError = error.toString();
      developer.log('Error saving ticket changes for ticketId: $currentTicketId: $error',
          name: 'OpenTicketViewModel', error: e);
      notifyListeners();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
      developer.log('Save ticket changes completed, isLoading: $isLoading', name: 'OpenTicketViewModel');
    }
  }

  String getFormattedEntryTime() {
    if (ticket?.entryTime == null) {
      developer.log('No entry time available', name: 'OpenTicketViewModel');
      return 'N/A';
    }
    final formatted = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(ticket!.entryTime!));
    developer.log('Formatted entry time: $formatted', name: 'OpenTicketViewModel');
    return formatted;
  }

  String getFormattedCreationTime() {
    if (ticket?.createdTime == null) {
      developer.log('No creation time available', name: 'OpenTicketViewModel');
      return 'N/A';
    }
    final formatted = DateFormat('dd MMM yyyy, hh:mm a').format(ticket!.createdTime);
    developer.log('Formatted creation time: $formatted', name: 'OpenTicketViewModel');
    return formatted;
  }

  void updateVehicleType(String? type) {
    developer.log('Updating vehicle type to: $type', name: 'OpenTicketViewModel');
    selectedVehicleType = type;
    if (type != null) {
      vehicleTypeController.text = type;
      vehicleTypeError = null;
      developer.log('Vehicle type updated, error cleared', name: 'OpenTicketViewModel');
    }
    notifyListeners();
  }

  @override
  void dispose() {
    developer.log('Disposing OpenTicketViewModel', name: 'OpenTicketViewModel');
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