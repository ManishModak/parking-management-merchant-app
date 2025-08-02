import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../models/plaza_fare.dart'; // Assuming VehicleTypes is here or in Ticket
import '../../models/ticket.dart';
import '../../services/core/ticket_service.dart';
import '../../utils/exceptions.dart';

class OpenTicketViewModel extends ChangeNotifier {
  final String instanceId = const Uuid().v4();
  final TicketService _ticketService;

  bool isLoading = false;
  Exception? error;
  List<Map<String, dynamic>> tickets = [];
  Ticket? ticket;
  List<String>? capturedImageUrls;
  String? currentTicketId;

  // Controllers
  final TextEditingController ticketIdController = TextEditingController();
  final TextEditingController ticketRefIdController = TextEditingController();
  final TextEditingController plazaIdController = TextEditingController();
  final TextEditingController plazaNameController = TextEditingController();
  final TextEditingController entryLaneIdController = TextEditingController();
  final TextEditingController entryLaneDirectionController =
      TextEditingController();
  final TextEditingController floorIdController = TextEditingController();
  final TextEditingController slotIdController = TextEditingController();
  final TextEditingController vehicleNumberController = TextEditingController();
  final TextEditingController vehicleTypeController = TextEditingController();
  final TextEditingController vehicleEntryTimestampController =
      TextEditingController();
  final TextEditingController ticketCreationTimeController =
      TextEditingController();
  final TextEditingController ticketStatusController = TextEditingController();
  final TextEditingController modificationTimeController =
      TextEditingController();
  final TextEditingController remarksController = TextEditingController();

  // Field-specific error states
  String? vehicleNumberError;
  String? floorIdError;
  String? slotIdError;
  String? vehicleTypeError;
  String? remarksError;
  String? apiError;

  String? selectedVehicleType;
  List<String> get vehicleTypes =>
      VehicleTypes.values; // Ensure VehicleTypes is defined

  OpenTicketViewModel({TicketService? ticketService})
      : _ticketService = ticketService ?? TicketService() {
    developer.log('OpenTicketViewModel initialized, instanceId: $instanceId',
        name: 'OpenTicketViewModel');
  }

  void resetErrors() {
    developer.log('Resetting all error states, instanceId: $instanceId',
        name: 'OpenTicketViewModel');
    vehicleNumberError = null;
    floorIdError = null;
    slotIdError = null;
    vehicleTypeError = null;
    remarksError = null;
    apiError = null;
    error = null;
    notifyListeners();
  }

  void resetRemarks() {
    remarksController.clear();
    remarksError = null;
    apiError = null;
    notifyListeners();
    developer.log('Remarks reset, instanceId: $instanceId',
        name: 'OpenTicketViewModel');
  }

  bool validateForm() {
    developer.log(
        'Validating form data for modification, instanceId: $instanceId',
        name: 'OpenTicketViewModel');
    bool isValid = true;
    String? tempRemarksError =
        remarksError; // Preserve remarks error if any during general validation
    resetErrors();
    remarksError = tempRemarksError; // Restore remarks error

    if (vehicleNumberController.text.isEmpty ||
        vehicleNumberController.text.length > 20) {
      vehicleNumberError = 'Vehicle number must be between 1 and 20 characters';
      developer.log(
          'Validation failed: $vehicleNumberError, instanceId: $instanceId',
          name: 'OpenTicketViewModel');
      isValid = false;
    }

    if (vehicleTypeController.text.isEmpty) {
      vehicleTypeError = 'Vehicle type is required';
      developer.log(
          'Validation failed: $vehicleTypeError, instanceId: $instanceId',
          name: 'OpenTicketViewModel');
      isValid = false;
    }

    // Optional: Validate floorId and slotId if they are not "N/A" and have content
    // For now, assuming "N/A" is acceptable or they can be empty if not "N/A"
    // If "N/A" is typed by user and needs validation, it needs to be handled.
    // The current validation might fail if user types "N/A" and length > 20.
    // Let's assume if it's not "N/A", it must be within length, or empty.
    if (floorIdController.text.isNotEmpty &&
        floorIdController.text != 'N/A' &&
        floorIdController.text.length > 20) {
      floorIdError = 'Floor ID must be under 20 characters if provided';
      developer.log('Validation failed: $floorIdError, instanceId: $instanceId',
          name: 'OpenTicketViewModel');
      isValid = false;
    }

    if (slotIdController.text.isNotEmpty &&
        slotIdController.text != 'N/A' &&
        slotIdController.text.length > 20) {
      slotIdError = 'Slot ID must be under 20 characters if provided';
      developer.log('Validation failed: $slotIdError, instanceId: $instanceId',
          name: 'OpenTicketViewModel');
      isValid = false;
    }

    notifyListeners();
    developer.log(
        'Form validation result for modification: $isValid, instanceId: $instanceId',
        name: 'OpenTicketViewModel');
    return isValid;
  }

  bool validateRejectForm() {
    developer.log('Validating form data for rejection, instanceId: $instanceId',
        name: 'OpenTicketViewModel');
    remarksError = null;
    apiError = null;
    bool isValid = true;

    if (remarksController.text.isEmpty || remarksController.text.length < 10) {
      remarksError = 'Remarks must be at least 10 characters long';
      developer.log(
          'Reject validation failed: $remarksError, instanceId: $instanceId',
          name: 'OpenTicketViewModel');
      isValid = false;
    }

    notifyListeners();
    developer.log(
        'Reject form validation result: $isValid, instanceId: $instanceId',
        name: 'OpenTicketViewModel');
    return isValid;
  }

  Future<bool> markExit(String ticketId) async {
    developer.log(
        'Attempting to mark exit for ticketId: $ticketId, instanceId: $instanceId',
        name: 'OpenTicketViewModel');
    try {
      isLoading = true;
      error = null;
      apiError = null;
      notifyListeners();

      await _ticketService.markTicketExit(ticketId);
      developer.log(
          'Successfully marked exit for ticketId: $ticketId, instanceId: $instanceId',
          name: 'OpenTicketViewModel');
      await fetchOpenTickets();
      return true;
    } catch (e) {
      error = _handleException(e);
      apiError = error.toString();
      developer.log(
          'Error marking exit for ticketId: $ticketId: $error, instanceId: $instanceId',
          name: 'OpenTicketViewModel',
          error: e);
      notifyListeners();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
      developer.log(
          'Mark exit operation completed, isLoading: $isLoading, instanceId: $instanceId',
          name: 'OpenTicketViewModel');
    }
  }

  String _formatUtcToIstString(DateTime? utcTime,
      {String format = 'dd MMM yyyy, hh:mm a'}) {
    if (utcTime == null) {
      developer.log(
          'No time provided for IST conversion and formatting, instanceId: $instanceId',
          name: 'OpenTicketViewModel');
      return 'N/A';
    }
    // Ensure the input is UTC before adding offset
    final DateTime ensuredUtcTime = utcTime.isUtc ? utcTime : utcTime.toUtc();
    final DateTime istEquivalentTime =
        ensuredUtcTime.add(const Duration(hours: 5, minutes: 30));

    // Create a new DateTime object that is explicitly local for formatting purposes.
    // This represents the "wall clock" time in IST.
    final DateTime localRepresentationOfIst = DateTime(
      istEquivalentTime.year,
      istEquivalentTime.month,
      istEquivalentTime.day,
      istEquivalentTime.hour,
      istEquivalentTime.minute,
      istEquivalentTime.second,
      istEquivalentTime.millisecond,
      istEquivalentTime.microsecond,
    );
    final String formatted =
        DateFormat(format).format(localRepresentationOfIst);
    developer.log(
        'Formatted UTC to IST string: $formatted (format: $format), original UTC: $utcTime, instanceId: $instanceId',
        name: 'OpenTicketViewModel');
    return formatted;
  }

  Future<void> fetchOpenTickets() async {
    developer.log('Fetching open tickets, instanceId: $instanceId',
        name: 'OpenTicketViewModel');
    try {
      isLoading = true;
      error = null;
      apiError = null;
      notifyListeners();

      final List<Ticket> fetchedTicketsModels =
          await _ticketService.getOpenTickets();
      tickets = fetchedTicketsModels
          .map((ticketModel) => {
                'ticketId': ticketModel.ticketId,
                'ticketRefId': ticketModel.ticketRefId,
                'plazaId': ticketModel.plazaId,
                'plazaName': ticketModel.plazaName ??
                    ticketModel.plazaId?.toString() ??
                    'N/A',
                'vehicleNumber': ticketModel.vehicleNumber,
                'vehicleType': ticketModel.vehicleType,
                'entryTime':
                    ticketModel.entryTime, // Store original UTC DateTime
                'ticketStatus': ticketModel.status.toString().split('.').last,
                'entryLaneId': ticketModel.entryLaneId,
                'entryLaneDirection': ticketModel.entryLaneDirection,
                'ticketCreationTime':
                    ticketModel.createdTime, // Store original UTC DateTime
                'floorId': ticketModel.floorId ?? 'N/A',
                'slotId': ticketModel.slotId ?? 'N/A',
                'capturedImages': ticketModel.capturedImages,
                'modificationTime':
                    ticketModel.modificationTime, // Store original UTC DateTime
                'remarks':
                    ticketModel.remarks, // Assuming Ticket model has remarks
              })
          .toList();

      developer.log(
          'Fetched ${tickets.length} open tickets, instanceId: $instanceId',
          name: 'OpenTicketViewModel');
    } catch (e) {
      error = _handleException(e);
      apiError = error.toString();
      tickets = [];
      developer.log(
          'Error fetching open tickets: $error, instanceId: $instanceId',
          name: 'OpenTicketViewModel',
          error: e);
    } finally {
      isLoading = false;
      notifyListeners();
      developer.log(
          'Fetch open tickets completed, isLoading: $isLoading, ticketCount: ${tickets.length}, instanceId: $instanceId',
          name: 'OpenTicketViewModel');
    }
  }

  Future<void> fetchTicketDetails(String ticketId) async {
    developer.log(
        'Fetching ticket details for ticketId: $ticketId, instanceId: $instanceId',
        name: 'OpenTicketViewModel');
    try {
      isLoading = true;
      error = null;
      apiError = null;
      capturedImageUrls = null;
      notifyListeners();

      ticket = await _ticketService.getTicketDetails(ticketId);
      initializeTicketData(ticket!);
      developer.log(
          'Successfully fetched ticket details for ticketId: $ticketId, images: ${ticket!.capturedImages}, instanceId: $instanceId',
          name: 'OpenTicketViewModel');
    } catch (e) {
      error = _handleException(e);
      apiError = error.toString();
      capturedImageUrls = [];
      developer.log(
          'Error fetching ticket details for ticketId: $ticketId: $error, instanceId: $instanceId',
          name: 'OpenTicketViewModel',
          error: e);
    } finally {
      isLoading = false;
      notifyListeners();
      developer.log(
          'Fetch ticket details completed, isLoading: $isLoading, imageCount: ${capturedImageUrls?.length ?? 0}, instanceId: $instanceId',
          name: 'OpenTicketViewModel');
    }
  }

  void initializeTicketData(Ticket ticket) {
    developer.log(
        'Initializing ticket data for ticketId: ${ticket.ticketId}, instanceId: $instanceId',
        name: 'OpenTicketViewModel');
    this.ticket = ticket;
    currentTicketId = ticket.ticketId;
    ticketIdController.text = ticket.ticketId ?? '';
    ticketRefIdController.text = ticket.ticketRefId ?? '';
    plazaIdController.text = ticket.plazaId?.toString() ?? '';
    plazaNameController.text = ticket.plazaName?.isNotEmpty == true
        ? ticket.plazaName!
        : (ticket.plazaId != null ? 'Plaza ${ticket.plazaId}' : 'N/A');
    entryLaneIdController.text = ticket.entryLaneId ?? '';
    entryLaneDirectionController.text = ticket.entryLaneDirection ?? '';
    floorIdController.text = ticket.floorId ?? 'N/A';
    slotIdController.text = ticket.slotId ?? 'N/A';
    vehicleNumberController.text = ticket.vehicleNumber ?? '';
    vehicleTypeController.text = ticket.vehicleType ?? '';
    selectedVehicleType = ticket.vehicleType;

    // Use a more standard format for text fields if they are for display, or ISO if for data
    // Using a user-friendly IST display format for these controllers:
    const String displayFormat = 'dd MMM yyyy, hh:mm:ss a';
    vehicleEntryTimestampController.text =
        _formatUtcToIstString(ticket.entryTime, format: displayFormat);
    ticketCreationTimeController.text =
        _formatUtcToIstString(ticket.createdTime, format: displayFormat);
    modificationTimeController.text = ticket.modificationTime != null
        ? _formatUtcToIstString(ticket.modificationTime, format: displayFormat)
        : 'N/A';

    ticketStatusController.text = ticket.status.toString().split('.').last;
    capturedImageUrls = ticket.capturedImages?.isNotEmpty == true
        ? List<String>.from(ticket.capturedImages!)
        : [];
    resetRemarks(); // Remarks are typically fresh for rejection/modification action

    developer.log(
        'Ticket data initialized, capturedImageUrls: $capturedImageUrls (count: ${capturedImageUrls?.length ?? 0}), instanceId: $instanceId',
        name: 'OpenTicketViewModel');
    notifyListeners();
  }

  Future<bool> saveTicketChanges() async {
    developer.log(
        'Attempting to save ticket changes for ticketId: $currentTicketId, instanceId: $instanceId',
        name: 'OpenTicketViewModel');
    if (!validateForm()) {
      apiError = 'Please correct the validation errors';
      developer.log(
          'Validation failed, cannot save changes, instanceId: $instanceId',
          name: 'OpenTicketViewModel');
      notifyListeners();
      return false;
    }

    if (ticket == null || currentTicketId == null) {
      apiError = 'No ticket selected for modification.';
      developer.log(
          'Error: No ticket or currentTicketId, instanceId: $instanceId',
          name: 'OpenTicketViewModel');
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
        ticketRefId: ticketRefIdController.text.isNotEmpty
            ? ticketRefIdController.text
            : ticket!.ticketRefId,
        plazaId: plazaIdController.text.isNotEmpty
            ? int.tryParse(plazaIdController.text)
            : ticket!.plazaId,
        entryLaneId: entryLaneIdController.text.isNotEmpty
            ? entryLaneIdController.text
            : ticket!.entryLaneId,
        entryLaneDirection: entryLaneDirectionController.text.isNotEmpty
            ? entryLaneDirectionController.text
            : ticket!.entryLaneDirection,
        floorId: floorIdController.text == 'N/A'
            ? null
            : (floorIdController.text.isEmpty
                ? ticket!.floorId
                : floorIdController.text),
        slotId: slotIdController.text == 'N/A'
            ? null
            : (slotIdController.text.isEmpty
                ? ticket!.slotId
                : slotIdController.text),
        vehicleNumber: vehicleNumberController.text,
        vehicleType: vehicleTypeController.text,
        status: ticket!
            .status, // Status should generally not be changed here, preserve original
        capturedImages: capturedImageUrls ?? ticket!.capturedImages,
        modifiedBy: 'System', // TODO: Replace with actual logged-in user ID
        modificationTime:
            DateTime.now().toUtc(), // Set new modification time in UTC
        createdTime: ticket!.createdTime, // Preserve original createdTime (UTC)
        entryTime: ticket!.entryTime, // Preserve original entryTime (UTC)
        // Include other fields from the original ticket if they are not meant to be modified
        // but are required by the backend.
        fareId: ticket!.fareId,
        exitTime: ticket!.exitTime,
        disputeStatus: ticket!.disputeStatus,
        disputeId: ticket!.disputeId,
        remarks: ticket!
            .remarks, // Preserve original remarks unless explicitly changed by this action
        geoLatitude: ticket!.geoLatitude,
        geoLongitude: ticket!.geoLongitude,
        createdBy: ticket!.createdBy, // Preserve original createdBy
      );

      await _ticketService.modifyTicket(currentTicketId!, updatedTicket);
      developer.log(
          'Successfully saved ticket changes for ticketId: $currentTicketId, instanceId: $instanceId',
          name: 'OpenTicketViewModel');
      await fetchTicketDetails(
          currentTicketId!); // Re-fetch to get latest state
      return true;
    } catch (e) {
      error = _handleException(e);
      apiError = error.toString();
      developer.log(
          'Error saving ticket changes for ticketId: $currentTicketId: $error, instanceId: $instanceId',
          name: 'OpenTicketViewModel',
          error: e);
      notifyListeners();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
      developer.log(
          'Save ticket changes completed, isLoading: $isLoading, instanceId: $instanceId',
          name: 'OpenTicketViewModel');
    }
  }

  Future<bool> rejectTicket() async {
    developer.log(
        'Attempting to reject ticketId: $currentTicketId, remarks: ${remarksController.text}, instanceId: $instanceId',
        name: 'OpenTicketViewModel');
    if (!validateRejectForm() || currentTicketId == null) {
      apiError = remarksError ?? 'Ticket ID is missing.';
      developer.log(
          'Validation failed or no currentTicketId for reject, instanceId: $instanceId',
          name: 'OpenTicketViewModel');
      notifyListeners();
      return false;
    }

    try {
      isLoading = true;
      apiError = null;
      error = null;
      notifyListeners();

      await _ticketService.rejectTicket(
          currentTicketId!, remarksController.text);
      developer.log(
          'Successfully rejected ticketId: $currentTicketId, instanceId: $instanceId',
          name: 'OpenTicketViewModel');
      // After rejection, the ticket is no longer "Open".
      // Consider fetching updated list of open tickets or navigating away.
      // For now, just returning true. UI can decide next step.
      return true;
    } catch (e) {
      error = _handleException(e);
      apiError = error.toString();
      developer.log(
          'Error rejecting ticketId: $currentTicketId: $error, instanceId: $instanceId',
          name: 'OpenTicketViewModel',
          error: e);
      notifyListeners();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
      developer.log(
          'Reject ticket operation completed, isLoading: $isLoading, instanceId: $instanceId',
          name: 'OpenTicketViewModel');
    }
  }

  String getFormattedEntryTime() {
    final formatted = _formatUtcToIstString(ticket?.entryTime);
    developer.log(
        'Formatted entry time (as IST): $formatted, instanceId: $instanceId',
        name: 'OpenTicketViewModel');
    return formatted;
  }

  String getFormattedCreationTime() {
    final formatted = _formatUtcToIstString(ticket?.createdTime);
    developer.log(
        'Formatted creation time (as IST): $formatted, instanceId: $instanceId',
        name: 'OpenTicketViewModel');
    return formatted;
  }

  String getFormattedModificationTime() {
    final formatted = _formatUtcToIstString(ticket?.modificationTime);
    developer.log(
        'Formatted modification time (as IST): $formatted, instanceId: $instanceId',
        name: 'OpenTicketViewModel');
    return formatted;
  }

  void updateVehicleType(String? type) {
    developer.log('Updating vehicle type to: $type, instanceId: $instanceId',
        name: 'OpenTicketViewModel');
    selectedVehicleType = type;
    if (type != null) {
      vehicleTypeController.text = type;
      vehicleTypeError = null; // Clear error when type is selected
      developer.log(
          'Vehicle type updated, error cleared, instanceId: $instanceId',
          name: 'OpenTicketViewModel');
    }
    notifyListeners();
  }

  Exception _handleException(dynamic e) {
    developer.log('Handling exception: $e, instanceId: $instanceId',
        name: 'OpenTicketViewModel');
    if (e is NoInternetException) {
      return Exception('No internet connection. Please check your network.');
    } else if (e is RequestTimeoutException) {
      return Exception('Request timed out. Please try again later.');
    } else if (e is HttpException) {
      String message = e.serverMessage ?? e.message;
      if (message.isEmpty ||
          message.toLowerCase().contains("unknown") ||
          message.toLowerCase().contains("error")) {
        message = 'A server error occurred. Status code: ${e.statusCode}.';
      }
      return Exception(message);
    } else if (e is ServiceException) {
      return Exception(e.message);
    } else {
      return Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  void dispose() {
    developer.log('Disposing OpenTicketViewModel, instanceId: $instanceId',
        name: 'OpenTicketViewModel');
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
    vehicleEntryTimestampController.dispose();
    ticketCreationTimeController.dispose();
    ticketStatusController.dispose();
    modificationTimeController.dispose();
    remarksController.dispose();
    super.dispose();
  }
}
