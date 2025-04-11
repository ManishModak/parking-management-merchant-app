import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:merchant_app/models/ticket.dart';
import '../../services/core/ticket_service.dart';

class TicketHistoryViewModel extends ChangeNotifier {
  final TicketService _ticketService;

  Ticket? _ticket;
  Ticket? get ticket => _ticket;

  bool isLoading = false;
  Exception? error;
  List<Map<String, dynamic>> tickets = [];
  List<String>? capturedImageUrls;

  TicketHistoryViewModel({TicketService? ticketService})
      : _ticketService = ticketService ?? TicketService();

  Future<void> fetchTicketHistory() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final fetchedTickets = await _ticketService.getAllTickets();
      tickets = fetchedTickets.map((ticket) => {
        'ticketId': ticket.ticketId,
        'ticketRefId': ticket.ticketRefId,
        'plazaId': ticket.plazaId,
        'vehicleNumber': ticket.vehicleNumber,
        'vehicleType': ticket.vehicleType,
        'plazaName': 'Plaza ${ticket.plazaId}', // TODO  Replace with actual plazaName if available
        'entryTime': ticket.entryTime ?? ticket.createdTime.toIso8601String(),
        'ticketStatus': ticket.status.toString().split('.').last,
        'entryLaneId': ticket.entryLaneId,
        'entryLaneDirection': ticket.entryLaneDirection,
        'ticketCreationTime': ticket.createdTime.toIso8601String(), // Use createdTime
        'floorId': ticket.floorId ?? 'N/A',
        'slotId': ticket.slotId ?? 'N/A',
        'modificationTime': ticket.modificationTime?.toIso8601String(),
        'exitTime': ticket.exitTime?.toIso8601String(),
        'capturedImages': ticket.capturedImages ?? [],
        'remarks': ticket.remarks ?? '',
      }).toList();

      developer.log('[TicketHistoryViewModel] Fetched ${tickets.length} tickets: $tickets',
          name: 'TicketHistoryViewModel');
    } catch (e) {
      error = e as Exception;
      developer.log('[TicketHistoryViewModel] Error fetching ticket history: $error',
          name: 'TicketHistoryViewModel');
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

      _ticket = await _ticketService.getTicketDetails(ticketId);
      capturedImageUrls = _ticket?.capturedImages ?? [];
      developer.log('[TicketHistoryViewModel] Fetched ticket details for $ticketId: ${_ticket?.ticketId}',
          name: 'TicketHistoryViewModel');
    } catch (e) {
      error = e as Exception;
      developer.log('[TicketHistoryViewModel] Error fetching ticket details: $e',
          name: 'TicketHistoryViewModel');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String getFormattedEntryTime() {
    if (_ticket?.entryTime == null) return 'N/A';
    final entryTime = DateTime.parse(_ticket!.entryTime!);
    return DateFormat('dd MMM yyyy, hh:mm a').format(entryTime);
  }

  String getFormattedExitTime() {
    if (_ticket?.exitTime == null) return 'N/A';
    return DateFormat('dd MMM yyyy, hh:mm a').format(_ticket!.exitTime!);
  }

  String getFormattedCreationTime() {
    if (_ticket == null) return 'N/A';
    return DateFormat('dd MMM yyyy, hh:mm a').format(_ticket!.createdTime);
  }

  String getFormattedModificationTime() {
    if (_ticket?.modificationTime == null) return 'N/A';
    return DateFormat('dd MMM yyyy, hh:mm a').format(_ticket!.modificationTime!);
  }

  @override
  void dispose() {
    capturedImageUrls = null;
    super.dispose();
  }
}