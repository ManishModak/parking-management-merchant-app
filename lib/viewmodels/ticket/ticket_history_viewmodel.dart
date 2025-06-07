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

  String _formatUtcToIstDisplay(DateTime? utcTime, {String format = 'dd MMM yyyy, hh:mm a'}) {
    if (utcTime == null) {
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
    return DateFormat(format).format(localRepresentationOfIst);
  }

  Future<void> fetchTicketHistory() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final List<Ticket> fetchedTicketsModels = await _ticketService.getAllTickets();
      tickets = fetchedTicketsModels.map((ticketModel) {
        return {
          'ticketId': ticketModel.ticketId,
          'ticketRefId': ticketModel.ticketRefId,
          'plazaId': ticketModel.plazaId,
          'vehicleNumber': ticketModel.vehicleNumber,
          'vehicleType': ticketModel.vehicleType,
          'plazaName': ticketModel.plazaName ?? 'Plaza ${ticketModel.plazaId}',
          'entryTime': ticketModel.entryTime,
          'ticketStatus': ticketModel.status.toString().split('.').last,
          'disputeStatus': ticketModel.disputeStatus ?? 'Not Raised',
          'entryLaneId': ticketModel.entryLaneId,
          'entryLaneDirection': ticketModel.entryLaneDirection,
          'ticketCreationTime': ticketModel.createdTime,
          'floorId': ticketModel.floorId ?? 'N/A',
          'slotId': ticketModel.slotId ?? 'N/A',
          'modificationTime': ticketModel.modificationTime,
          'exitTime': ticketModel.exitTime,
          'capturedImages': ticketModel.capturedImages ?? [],
          'remarks': ticketModel.remarks ?? '',
          'fareAmount': ticketModel.fareAmount,
          'totalCharges': ticketModel.totalCharges,
          'paymentMode': ticketModel.paymentMode,
          'parkingDuration': ticketModel.parkingDuration,
          'fareType': ticketModel.fareType,
          'disputeId': ticketModel.disputeId,
        };
      }).toList();
      developer.log('[TicketHistoryViewModel] Fetched ${tickets.length} tickets', name: 'TicketHistoryViewModel');
    } catch (e) {
      error = e as Exception;
      developer.log('[TicketHistoryViewModel] Error fetching ticket history: $e', name: 'TicketHistoryViewModel');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String formatTicketTime(DateTime? time) {
    return _formatUtcToIstDisplay(time);
  }

  Future<void> fetchTicketDetails(String ticketId) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      _ticket = await _ticketService.getTicketDetails(ticketId);
      capturedImageUrls = _ticket?.capturedImages?.map((e) => e.toString()).toList() ?? [];
      developer.log('[TicketHistoryViewModel] Fetched ticket details for $ticketId: ${_ticket?.ticketId}', name: 'TicketHistoryViewModel');
    } catch (e) {
      error = e as Exception;
      developer.log('[TicketHistoryViewModel] Error fetching ticket details: $e', name: 'TicketHistoryViewModel');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String getFormattedEntryTime() {
    return _formatUtcToIstDisplay(_ticket?.entryTime);
  }

  String getFormattedExitTime() {
    return _formatUtcToIstDisplay(_ticket?.exitTime);
  }

  String getFormattedCreationTime() {
    return _formatUtcToIstDisplay(_ticket?.createdTime);
  }

  String getFormattedModificationTime() {
    return _formatUtcToIstDisplay(_ticket?.modificationTime);
  }
}