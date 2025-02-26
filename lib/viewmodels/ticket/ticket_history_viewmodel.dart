import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/core/ticket_service.dart';

class TicketHistoryViewModel extends ChangeNotifier {
  final TicketService _ticketService;

  // Controllers for form fields
  final TextEditingController ticketIdController = TextEditingController();
  final TextEditingController plazaIdController = TextEditingController();
  final TextEditingController plazaNameController = TextEditingController();
  final TextEditingController entryLaneIdController = TextEditingController();
  final TextEditingController entryLaneDirectionController = TextEditingController();
  final TextEditingController floorIdController = TextEditingController();
  final TextEditingController slotIdController = TextEditingController();
  final TextEditingController vehicleNumberController = TextEditingController();
  final TextEditingController vehicleTypeController = TextEditingController();
  final TextEditingController entryTimeController = TextEditingController();
  final TextEditingController ticketCreationTimeController = TextEditingController();
  final TextEditingController ticketStatusController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();

  bool isLoading = false;
  Exception? error;
  List<Map<String, dynamic>> tickets = [];

  TicketHistoryViewModel({TicketService? ticketService})
      : _ticketService = ticketService ?? TicketService();

  Future<void> fetchTicketHistory() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      // Note: Assuming getOpenTickets is a placeholder; replace with actual history endpoint if available
      final fetchedTickets = await _ticketService.getOpenTickets();
      tickets = fetchedTickets.map((ticket) => {
        'ticketId': ticket.ticketId,
        'ticketRefId': ticket.ticketRefId,
        'plazaId': ticket.plazaId,
        'vehicleNumber': ticket.vehicleNumber,
        'vehicleType': ticket.vehicleType,
        'plazaName': 'Plaza ${ticket.plazaId}', // Replace with actual plaza name if available
        'entryTime': ticket.entryTime,
        'ticketStatus': ticket.status.toString().split('.').last,
        'entryLaneId': ticket.entryLaneId,
        'entryLaneDirection': ticket.entryLaneDirection,
        'ticketCreationTime': ticket.createdTime.toIso8601String(),
        'floorId': ticket.floorId.isEmpty ? 'N/A' : ticket.floorId,
        'slotId': ticket.slotId.isEmpty ? 'N/A' : ticket.slotId,
        //'capturedImage': ticket.capturedImage,
        'modificationTime': ticket.modificationTime?.toIso8601String(),
        'remarks': ticket.remarks ?? '',
      }).toList();

      if (tickets.isEmpty) {
        developer.log('[TicketHistoryViewModel] No tickets found in history.', name: 'TicketHistoryViewModel');
      }
    } catch (e) {
      error = e as Exception;
      developer.log('[TicketHistoryViewModel] Error fetching ticket history: $error', name: 'TicketHistoryViewModel');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void initializeTicketData(Map<String, dynamic> ticket) {
    ticketIdController.text = ticket['ticketId']?.toString() ?? '';
    plazaIdController.text = ticket['plazaId']?.toString() ?? '';
    plazaNameController.text = ticket['plazaName']?.toString() ?? '';
    entryLaneIdController.text = ticket['entryLaneId']?.toString() ?? '';
    entryLaneDirectionController.text = ticket['entryLaneDirection']?.toString() ?? '';
    floorIdController.text = ticket['floorId']?.toString() ?? '';
    slotIdController.text = ticket['slotId']?.toString() ?? '';
    vehicleNumberController.text = ticket['vehicleNumber']?.toString() ?? '';
    vehicleTypeController.text = ticket['vehicleType']?.toString() ?? '';
    ticketStatusController.text = ticket['ticketStatus']?.toString() ?? '';
    remarksController.text = ticket['remarks']?.toString() ?? '';

    if (ticket['entryTime'] != null) {
      final entryTime = DateTime.parse(ticket['entryTime']);
      entryTimeController.text = DateFormat('dd MMM yyyy, hh:mm a').format(entryTime);
    }
    if (ticket['ticketCreationTime'] != null) {
      final creationTime = DateTime.parse(ticket['ticketCreationTime']);
      ticketCreationTimeController.text = DateFormat('dd MMM yyyy, hh:mm a').format(creationTime);
    }

    notifyListeners();
  }

  Future<void> loadTicketDetails(String ticketId) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final ticket = await _ticketService.getTicketDetails(ticketId);
      initializeTicketData({
        'ticketId': ticket.ticketId,
        'ticketRefId': ticket.ticketRefId,
        'plazaId': ticket.plazaId,
        'vehicleNumber': ticket.vehicleNumber,
        'vehicleType': ticket.vehicleType,
        'plazaName': 'Plaza ${ticket.plazaId}', // Replace with actual plaza name if available
        'entryTime': ticket.entryTime,
        'ticketStatus': ticket.status.toString().split('.').last,
        'entryLaneId': ticket.entryLaneId,
        'entryLaneDirection': ticket.entryLaneDirection,
        'ticketCreationTime': ticket.createdTime.toIso8601String(),
        'floorId': ticket.floorId.isEmpty ? 'N/A' : ticket.floorId,
        'slotId': ticket.slotId.isEmpty ? 'N/A' : ticket.slotId,
        //'capturedImage': ticket.capturedImage,
        'modificationTime': ticket.modificationTime?.toIso8601String(),
        'remarks': ticket.remarks ?? '',
      });
    } catch (e) {
      error = e as Exception;
      developer.log('[TicketHistoryViewModel] Error loading ticket details: $error', name: 'TicketHistoryViewModel');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    ticketIdController.dispose();
    plazaIdController.dispose();
    plazaNameController.dispose();
    entryLaneIdController.dispose();
    entryLaneDirectionController.dispose();
    floorIdController.dispose();
    slotIdController.dispose();
    vehicleNumberController.dispose();
    vehicleTypeController.dispose();
    entryTimeController.dispose();
    ticketCreationTimeController.dispose();
    ticketStatusController.dispose();
    remarksController.dispose();
    super.dispose();
  }
}