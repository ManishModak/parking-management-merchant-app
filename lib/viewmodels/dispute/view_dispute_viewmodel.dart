import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import '../../models/dispute.dart';
import '../../models/ticket.dart';
import '../../services/core/dispute_service.dart';
import '../../services/core/ticket_service.dart';
import 'package:intl/intl.dart';

class ViewDisputeViewModel with ChangeNotifier {
  final DisputesService _disputesService;
  final TicketService _ticketService;
  final _dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

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

  Future<void> fetchDisputeDetails(String id,
      {bool useDisputeId = false}) async {
    if (isLoading) return;

    isLoading = true;
    errorMessage = null;
    dispute = null;
    ticket = null;
    capturedImageUrls = null;
    notifyListeners();

    try {
      if (useDisputeId) {
        // Fetch dispute by disputeId
        dispute = await _disputesService.getDisputeById(id);
        // Force ticketId access since it's guaranteed to be non-null
        ticket = await _ticketService.getTicketDetails(dispute!.ticketId);
        capturedImageUrls = ticket?.capturedImages;
      } else {
        // Fetch ticket details by ticketId
        ticket = await _ticketService.getTicketDetails(id);
        capturedImageUrls = ticket?.capturedImages;
        // Fetch dispute details by ticketId
        final disputes = await _disputesService.getDisputesByTicket(id);
        if (disputes.isNotEmpty) {
          dispute = disputes.first; // Take the first dispute for this ticket
        } else {
          errorMessage = 'No dispute found for ticket ID: $id';
        }
      }
    } catch (e) {
      errorMessage = 'Failed to fetch dispute details: $e';
      developer.log('Error in fetchDisputeDetails: $e',
          name: 'ViewDisputeViewModel');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Map<String, dynamic> getDisputeDisplayData() {
    if (dispute == null || ticket == null) {
      return {};
    }

    final payment =
        ticket!.payments?.isNotEmpty ?? false ? ticket!.payments!.first : null;
    final entryTime = ticket!.entryTime;
    final exitTime = ticket!.exitTime;

    String? parkingDuration;
    if (entryTime != null && exitTime != null) {
      final duration = exitTime.difference(entryTime);
      parkingDuration = '${duration.inHours}h ${duration.inMinutes % 60}m';
    }

    String? formatDateTime(dynamic dateTime) {
      if (dateTime == null) return 'N/A';
      try {
        final parsedDate = dateTime is String
            ? DateTime.parse(dateTime)
            : dateTime as DateTime;
        return _dateFormat.format(parsedDate);
      } catch (e) {
        developer.log('Error formatting date: $dateTime, error: $e',
            name: 'ViewDisputeViewModel.FormatDate');
        return 'N/A';
      }
    }

    return {
      'ticketId': dispute!.ticketId ?? 'N/A',
      'ticketRefId': ticket!.ticketRefId ?? 'N/A',
      'plazaName':
          dispute!.plazaId != null ? 'Plaza ${dispute!.plazaId}' : 'N/A',
      'vehicleNumber': dispute!.vehicleNumber ?? 'N/A',
      'vehicleType': dispute!.vehicleType ?? 'N/A',
      'vehicleEntryTime': formatDateTime(entryTime),
      'vehicleExitTime': formatDateTime(exitTime),
      'parkingDuration': parkingDuration ?? dispute!.parkingDuration ?? 'N/A',
      'paymentAmount':
          dispute!.paymentAmount != null ? '₹${dispute!.paymentAmount}' : 'N/A',
      'fareType': payment?.fareType ?? 'N/A',
      'fareAmount':
          dispute!.fareAmount != null ? '₹${dispute!.fareAmount}' : 'N/A',
      'paymentDate': formatDateTime(dispute!.paymentTime),
      'disputeExpiryDate': formatDateTime(dispute!.ticketCreationTime),
      'disputeReason': dispute!.disputeReason ?? 'N/A',
      'disputeAmount':
          dispute!.disputeAmount != null ? '₹${dispute!.disputeAmount}' : 'N/A',
      'disputeRemark': dispute!.remarks ?? 'N/A',
      'disputeStatus': dispute!.status ?? 'N/A',
      'disputeRaisedBy':
          dispute!.userId != null ? 'User ${dispute!.userId}' : 'N/A',
      'disputeRaisedDate': formatDateTime(dispute!.ticketCreationTime),
      'disputeProcessedBy': dispute!.processedBy ?? 'N/A',
      'disputeProcessedDate': dispute!.latestRemark != null
          ? formatDateTime(dispute!.ticketCreationTime)
          : 'N/A',
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

// Future<void> fetchDisputeDetails(String ticketId) async {
//   if (isLoading) return;
//
//   isLoading = true;
//   errorMessage = null;
//   dispute = null;
//   ticket = null;
//   capturedImageUrls = null;
//   notifyListeners();
//
//   try {
//     // Fetch ticket details
//     ticket = await _ticketService.getTicketDetails(ticketId);
//     capturedImageUrls = ticket?.capturedImages;
//
//     // Fetch dispute details
//     final disputes = await _disputesService.getDisputesByTicket(ticketId);
//     if (disputes.isNotEmpty) {
//       dispute = disputes.first; // Take the first dispute for this ticket
//     } else {
//       errorMessage = 'No dispute found for ticket ID: $ticketId';
//     }
//   } catch (e) {
//     errorMessage = 'Failed to fetch dispute details: $e';
//     developer.log('Error in fetchDisputeDetails: $e', name: 'ViewDisputeViewModel');
//   } finally {
//     isLoading = false;
//     notifyListeners();
//   }
// }
