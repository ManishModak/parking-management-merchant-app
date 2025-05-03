import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import '../../services/core/ticket_service.dart';
import '../../services/utils/socket_service.dart';

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
      notifyListeners();

      final fetchedTickets = await _ticketService.getOpenTickets();
      tickets = fetchedTickets.map((ticket) => {
        'ticketID': ticket.ticketId,
        'ticketRefID': ticket.ticketRefId,
        'plazaID': ticket.plazaId,
        'vehicleNumber': ticket.vehicleNumber,
        'vehicleType': ticket.vehicleType,
        'plazaName': 'Plaza ${ticket.plazaId}',
        'entryTime': ticket.entryTime,
        'entryLaneId': ticket.entryLaneId,
        'entryLaneDirection': ticket.entryLaneDirection,
        'ticketCreationTime': ticket.createdTime.toIso8601String(),
        'floorId': ticket.floorId ?? 'N/A',
        'slotId': ticket.slotId ?? 'N/A',
        'ticketStatus': ticket.status.toString().split('.').last,
        'modificationTime': ticket.modificationTime?.toIso8601String(),
      }).toList();

      if (tickets.isEmpty) {
        developer.log('[MarkExitViewModel] No open tickets found to mark as exited.', name: 'MarkExitViewModel');
      }
    } catch (e) {
      error = e as Exception;
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

      final responseData = await _ticketService.markTicketExit(ticketId);
      ticketDetails = {
        'ticket_ref_id': responseData['ticket_ref_id'] ?? '',
        'status': responseData['status'] ?? 'complete',
        'entry_lane_id': responseData['entry_lane_id'] ?? '',
        'exit_lane_id': responseData['exit_lane_id'] ?? 'Not filled',
        'floor_id': responseData['floor_id']?.isEmpty ?? true ? 'N/A' : responseData['floor_id'],
        'slot_id': responseData['slot_id']?.isEmpty ?? true ? 'N/A' : responseData['slot_id'],
        'vehicle_number': responseData['vehicle_number'] ?? '',
        'vehicle_type': responseData['vehicle_type'] ?? '',
        'entry_time': responseData['entry_time'] ?? '',
        'exit_time': responseData['exit_time'] ?? DateTime.now().toString(),
        'parking_duration': responseData['duration']?.toString() ?? '',
        'fare_type': responseData['fare_type'] ?? '',
        'fare_amount': responseData['fare_amount']?.toString() ?? '',
        'total_charges': responseData['total_transaction']?.toString() ?? '',
        'captured_images': responseData['captured_images'] ?? [],
      };
      developer.log('[MarkExitViewModel] Ticket marked as exited: $ticketDetails', name: 'MarkExitViewModel');
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

  Future<void> markTicketAsCashPending(String ticketId) async {
    try {
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