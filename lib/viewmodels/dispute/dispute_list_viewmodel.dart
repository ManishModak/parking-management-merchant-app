import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import '../../services/core/dispute_service.dart';
import '../../services/core/ticket_service.dart';

class DisputeListViewModel extends ChangeNotifier{
  final TicketService _ticketService;

  bool isLoading = false;
  Exception? error;
  List<Map<String, dynamic>> tickets = [];

  DisputeListViewModel({
    TicketService? ticketService,
  }) :_ticketService = ticketService ?? TicketService();

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
        'plazaName': "Plaza ${ticket.plazaId}",
        'entryTime': ticket.entryTime,
        'status': ticket.status.toString().split('.').last,
        'entryLaneId': ticket.entryLaneId,
        'entryLaneDirection': ticket.entryLaneDirection,
        'ticketCreationTime': ticket.createdTime.toIso8601String(),
        'floorId': ticket.floorId != null ? 'N/A' : ticket.floorId,
        'slotId': ticket.slotId != null ? 'N/A' : ticket.slotId,
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
}