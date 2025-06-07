import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import intl
import '../../services/core/ticket_service.dart';
import '../../services/utils/socket_service.dart';
import '../../models/ticket.dart'; // Assuming Ticket model is used by TicketService

class MarkExitViewModel extends ChangeNotifier {
  final TicketService _ticketService;
  final SocketService _socketService;

  bool isLoading = false;
  Exception? error;
  List<Map<String, dynamic>> tickets = [];
  String? apiError;
  Map<String, dynamic>? ticketDetails;
  String? paymentStatus;

  MarkExitViewModel({
    TicketService? ticketService,
    SocketService? socketService,
  })  : _ticketService = ticketService ?? TicketService(),
        _socketService = socketService ?? SocketService();

  // Helper function for IST formatting
  String _formatUtcToIstString(DateTime? utcTime, {String format = 'dd MMM yyyy, hh:mm a'}) {
    if (utcTime == null) {
      developer.log('[MarkExitViewModel] No time provided for IST conversion and formatting', name: 'MarkExitViewModel');
      return 'N/A';
    }
    final DateTime ensuredUtcTime = utcTime.isUtc ? utcTime : utcTime.toUtc();
    final DateTime istEquivalentTime = ensuredUtcTime.add(const Duration(hours: 5, minutes: 30));

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
    final String formatted = DateFormat(format).format(localRepresentationOfIst);
    developer.log('[MarkExitViewModel] Formatted UTC to IST string: $formatted (format: $format), original UTC: $utcTime', name: 'MarkExitViewModel');
    return formatted;
  }

  // Helper to parse string to DateTime, assuming UTC if not specified
  DateTime? _parseUtcDateTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) return null;
    try {
      DateTime parsed = DateTime.parse(dateTimeString);
      return parsed.isUtc ? parsed : parsed.toUtc(); // Ensure it's UTC
    } catch (e) {
      developer.log('[MarkExitViewModel] Error parsing date string "$dateTimeString": $e', name: 'MarkExitViewModel');
      return null; // Or handle error appropriately
    }
  }


  void initializeSocket(String userId, String socketUrl) {
    _socketService.initialize(userId, socketUrl);
    _listenForPaymentResults();
  }

  void _listenForPaymentResults() {
    _socketService.onPaymentResult('notification', (data) {
      try {
        final paymentData = data as Map<String, dynamic>;
        paymentStatus = paymentData['status']?.toString() ?? 'unknown';
        developer.log('[MarkExitViewModel] Payment result received: $paymentStatus', name: 'MarkExitViewModel');
        notifyListeners();
      } catch (e) {
        developer.log('[MarkExitViewModel] Error processing payment result: $e', name: 'MarkExitViewModel');
      }
    });
  }

  Future<void> fetchOpenTickets() async {
    try {
      isLoading = true;
      error = null;
      apiError = null; // Reset apiError
      notifyListeners();

      final List<Ticket> fetchedTicketsModels = await _ticketService.getOpenTickets();
      tickets = fetchedTicketsModels.map((ticket) => {
        'ticketID': ticket.ticketId,
        'ticketRefID': ticket.ticketRefId,
        'plazaID': ticket.plazaId,
        'vehicleNumber': ticket.vehicleNumber,
        'vehicleType': ticket.vehicleType,
        'plazaName': ticket.plazaName ?? 'Plaza ${ticket.plazaId}', // Use plazaName if available
        'entryTime': ticket.entryTime, // Store as DateTime (UTC)
        'entryLaneId': ticket.entryLaneId,
        'entryLaneDirection': ticket.entryLaneDirection,
        'ticketCreationTime': ticket.createdTime, // Store as DateTime (UTC)
        'floorId': ticket.floorId ?? 'N/A',
        'slotId': ticket.slotId ?? 'N/A',
        'ticketStatus': ticket.status.toString().split('.').last,
        'modificationTime': ticket.modificationTime, // Store as DateTime (UTC)
      }).toList();

      if (tickets.isEmpty) {
        developer.log('[MarkExitViewModel] No open tickets found to mark as exited.', name: 'MarkExitViewModel');
      }
    } catch (e) {
      error = e as Exception;
      apiError = e.toString(); // Set apiError
      developer.log('[MarkExitViewModel] Error fetching tickets: $error', name: 'MarkExitViewModel');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> markTicketAsExited(String ticketId) async {
    try {
      isLoading = true;
      apiError = null;
      error = null;
      notifyListeners();

      // Assuming _ticketService.markTicketExit returns a Map<String, dynamic>
      // where date fields are ISO8601 UTC strings
      final Map<String, dynamic> responseData = await _ticketService.markTicketExit(ticketId);

      // Parse date strings from responseData into DateTime objects (UTC)
      DateTime? entryTimeUtc = _parseUtcDateTime(responseData['entry_time'] as String?);
      DateTime? exitTimeUtc = _parseUtcDateTime(responseData['exit_time'] as String?);
      // If exit_time is not in response, default to DateTime.now().toUtc()
      exitTimeUtc ??= DateTime.now().toUtc();


      ticketDetails = {
        'ticket_ref_id': responseData['ticket_ref_id'] ?? '',
        'status': responseData['status'] ?? 'complete',
        'entry_lane_id': responseData['entry_lane_id'] ?? '',
        'exit_lane_id': responseData['exit_lane_id'] ?? 'Not filled',
        'floor_id': responseData['floor_id']?.isEmpty ?? true ? 'N/A' : responseData['floor_id'],
        'slot_id': responseData['slot_id']?.isEmpty ?? true ? 'N/A' : responseData['slot_id'],
        'vehicle_number': responseData['vehicle_number'] ?? '',
        'vehicle_type': responseData['vehicle_type'] ?? '',
        'entry_time_utc': entryTimeUtc, // Store as DateTime UTC
        'exit_time_utc': exitTimeUtc,   // Store as DateTime UTC
        'parking_duration': responseData['duration']?.toString() ?? '',
        'fare_type': responseData['fare_type'] ?? '',
        'fare_amount': responseData['fare_amount']?.toString() ?? '',
        'total_charges': responseData['total_transaction']?.toString() ?? '',
        'captured_images': (responseData['captured_images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [], // Ensure list of strings
      };
      developer.log('[MarkExitViewModel] Ticket marked as exited (raw details): $ticketDetails', name: 'MarkExitViewModel');
      return true;
    } catch (e) {
      error = e as Exception;
      apiError = 'Failed to mark ticket as exited: ${e.toString()}';
      developer.log('[MarkExitViewModel] Error marking ticket as exited: $error', name: 'MarkExitViewModel');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Getters for formatted times to be used by the UI
  String getFormattedEntryTime() {
    return _formatUtcToIstString(ticketDetails?['entry_time_utc'] as DateTime?);
  }

  String getFormattedExitTime() {
    return _formatUtcToIstString(ticketDetails?['exit_time_utc'] as DateTime?);
  }


  Future<void> markTicketAsCashPending(String ticketId) async {
    try {
      // Potentially update local state or call a service
      paymentStatus = 'Cash Pending'; // Example local update
      developer.log('[MarkExitViewModel] Ticket $ticketId marked as Cash Pending locally.', name: 'MarkExitViewModel');
      notifyListeners();
    } catch (e) {
      developer.log('[MarkExitViewModel] Error marking ticket as cash pending: $e', name: 'MarkExitViewModel');
    }
  }

  @override
  void dispose() {
    _socketService.disconnect();
    super.dispose();
  }
}