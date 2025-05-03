import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/dispute.dart';
import '../../models/ticket.dart';
import '../../services/core/dispute_service.dart';
import '../../services/core/ticket_service.dart';

class ViewDisputeViewModel with ChangeNotifier {
  final DisputesService _disputesService;
  final TicketService _ticketService;

  Dispute? dispute;
  Ticket? ticket;
  bool isLoading = false;
  String? errorMessage;
  List<String>? capturedImageUrls;

  ViewDisputeViewModel({
    DisputesService? disputesService,
    TicketService? ticketService,
  })  : _disputesService = disputesService ?? DisputesService(),
        _ticketService = ticketService ?? TicketService();

  Future<void> fetchDisputeDetails(String ticketId) async {
    if (isLoading) return;

    isLoading = true;
    errorMessage = null;
    dispute = null;
    ticket = null;
    capturedImageUrls = null;
    notifyListeners();

    try {
      // Fetch ticket details
      ticket = await _ticketService.getTicketDetails(ticketId);
      capturedImageUrls = ticket?.capturedImages;

      // Fetch dispute details
      final disputes = await _disputesService.getDisputesByTicket(ticketId);
      if (disputes.isNotEmpty) {
        dispute = disputes.first; // Take the first dispute for this ticket
      } else {
        errorMessage = 'No dispute found for ticket ID: $ticketId';
      }
    } catch (e) {
      errorMessage = 'Failed to fetch dispute details: $e';
      debugPrint('Error in fetchDisputeDetails: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Map<String, dynamic> getDisputeDisplayData() {
    if (dispute == null || ticket == null) {
      return {};
    }

    final payment = ticket!.payments?.isNotEmpty ?? false ? ticket!.payments!.first : null;
    final entryTime = ticket!.entryTime;
    final exitTime = ticket!.exitTime;

    String? parkingDuration;
    if (entryTime != null && exitTime != null) {
      final duration = exitTime.difference(entryTime);
      parkingDuration = '${duration.inHours}h ${duration.inMinutes % 60}m';
    }

    return {
      'ticketId': dispute!.ticketId ?? 'N/A',
      // TODO: Replace with actual plaza name lookup from plazaId
      'plazaName': dispute!.plazaId != null ? 'Plaza ${dispute!.plazaId}' : 'N/A',
      'vehicleNumber': dispute!.vehicleNumber ?? 'N/A',
      'vehicleType': dispute!.vehicleType ?? 'N/A',
      'vehicleEntryTime': entryTime != null
          ? DateFormat('dd-MM-yyyy HH:mm:ss').format(entryTime)
          : 'N/A',
      'vehicleExitTime': exitTime != null
          ? DateFormat('dd-MM-yyyy HH:mm:ss').format(exitTime)
          : 'N/A',
      'parkingDuration': parkingDuration ?? dispute!.parkingDuration ?? 'N/A',
      'paymentAmount': dispute!.paymentAmount != null ? '₹${dispute!.paymentAmount}' : 'N/A',
      'fareType': payment?.fareType ?? 'N/A',
      'fareAmount': dispute!.fareAmount != null ? '₹${dispute!.fareAmount}' : 'N/A',
      'paymentDate': dispute!.paymentTime ?? 'N/A',
      'disputeExpiryDate': dispute!.ticketCreationTime ?? 'N/A',
      'disputeReason': dispute!.disputeReason ?? 'N/A',
      'disputeAmount': dispute!.disputeAmount != null ? '₹${dispute!.disputeAmount}' : 'N/A',
      'disputeRemark': dispute!.remarks ?? 'N/A',
      'disputeStatus': dispute!.status ?? 'N/A',
      'disputeRaisedBy': dispute!.userId != null ? 'User ${dispute!.userId}' : 'N/A',
      'disputeRaisedDate': dispute!.ticketCreationTime ?? 'N/A',
      'disputeProcessedBy': dispute!.processedBy ?? 'N/A',
      'disputeProcessedDate': dispute!.latestRemark != null ? dispute!.ticketCreationTime : 'N/A',
    };
  }

  void reset() {
    dispute = null;
    ticket = null;
    isLoading = false;
    errorMessage = null;
    capturedImageUrls = null;
    notifyListeners();
  }
}