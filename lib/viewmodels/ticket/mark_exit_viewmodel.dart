import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import '../../models/ticket.dart';
import '../../services/core/ticket_service.dart';

class MarkExitViewModel extends ChangeNotifier {
  final TicketService _ticketService;

  bool isLoading = false;
  Exception? error;
  List<Map<String, dynamic>> tickets = [];
  String? apiError;
  Map<String, dynamic>? ticketDetails; // Store detailed ticket data

  MarkExitViewModel({TicketService? ticketService})
      : _ticketService = ticketService ?? TicketService();

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
        'plazaName': 'Plaza ${ticket.plazaId}', // Replace with actual plaza name if available
        'entryTime': ticket.entryTime,
        'entryLaneId': ticket.entryLaneId,
        'entryLaneDirection': ticket.entryLaneDirection,
        'ticketCreationTime': ticket.createdTime.toIso8601String(),
        'floorId': ticket.floorId != null ? 'N/A' : ticket.floorId,
        'slotId': ticket.slotId != null ? 'N/A' : ticket.slotId,
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
        'captured_images': responseData['captured_images'] ?? [], // Use pre-mapped full URLs
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
      // Update your backend API to mark the ticket as "Cash Payment Pending"
      // Example: await apiService.updateTicketStatus(ticketId, 'cash_pending');
      notifyListeners();
    } catch (e) {
      // Handle error
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}