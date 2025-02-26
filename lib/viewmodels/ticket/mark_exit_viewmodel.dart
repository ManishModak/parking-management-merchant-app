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
        'floorId': ticket.floorId.isEmpty ? 'N/A' : ticket.floorId,
        'slotId': ticket.slotId.isEmpty ? 'N/A' : ticket.slotId,
        'ticketStatus': ticket.status.toString().split('.').last,
        //'capturedImage': ticket.capturedImage,
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

  Future<bool> markTicketAsExited(String ticketRefId) async {
    try {
      isLoading = true;
      apiError = null;
      error = null;
      notifyListeners();

      // Assuming TicketService has a method to mark a ticket as exited; adjust as needed
      final ticket = await _ticketService.getTicketDetails(ticketRefId);
      final updatedTicket = Ticket(
        ticketId: ticket.ticketId,
        ticketRefId: ticket.ticketRefId,
        plazaId: ticket.plazaId,
        entryLaneId: ticket.entryLaneId,
        entryLaneDirection: ticket.entryLaneDirection,
        floorId: ticket.floorId,
        slotId: ticket.slotId,
        status: ticket.status,
        vehicleNumber: ticket.vehicleNumber,
        vehicleType: ticket.vehicleType,
        //capturedImage: ticket.capturedImage,
        modifiedBy: 'System',
        modificationTime: DateTime.now(),
      );

      await _ticketService.modifyTicket(ticketRefId, updatedTicket);
      await fetchOpenTickets(); // Refresh the list after marking exit
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

  @override
  void dispose() {
    super.dispose();
  }
}