import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../../models/dispute.dart';
import '../../models/ticket.dart';
import '../../services/core/dispute_service.dart';
import '../../services/core/ticket_service.dart';

class ProcessDisputeViewModel extends ChangeNotifier {
  final DisputesService _disputesService;
  final TicketService _ticketService;

  Dispute? dispute;
  Ticket? ticket;
  String? selectedAction;
  String remark = '';
  List<String> filePaths = [];
  List<String>? capturedImageUrls;
  bool isLoading = false;
  String? actionError;
  String? remarkError;
  String? fileError;
  String? error;

  final List<String> disputeActions = ['Accepted', 'Rejected'];
  final _dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

  ProcessDisputeViewModel({
    DisputesService? disputesService,
    TicketService? ticketService,
  })  : _disputesService = disputesService ?? DisputesService(),
        _ticketService = ticketService ?? TicketService();

  void updateAction(String? action) {
    selectedAction = action;
    actionError = null;
    error = null;
    notifyListeners();
  }

  void updateRemark(String value) {
    remark = value;
    remarkError = null;
    error = null;
    notifyListeners();
  }

  Future<void> pickFile() async {
    try {
      developer.log('Attempting to pick files with FileType.custom',
          name: 'ProcessDisputeViewModel.PickFile');
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        allowMultiple: true,
      );
      developer.log('FilePicker result: ${result?.paths}',
          name: 'ProcessDisputeViewModel.PickFile');

      if (result != null) {
        filePaths
            .addAll(result.paths.where((path) => path != null).cast<String>());
        fileError = null;
      } else {
        fileError = 'No files selected';
      }
    } catch (e) {
      fileError = 'Error picking files: $e';
      developer.log('Error picking files: $e',
          name: 'ProcessDisputeViewModel.PickFile');
      if (e.toString().contains('MissingPluginException')) {
        try {
          FilePickerResult? fallbackResult =
              await FilePicker.platform.pickFiles(
            type: FileType.any,
            allowMultiple: true,
          );
          if (fallbackResult != null) {
            final allowedExtensions = ['jpg', 'jpeg', 'png', 'pdf'];
            filePaths.addAll(fallbackResult.paths
                .where((path) =>
                    path != null &&
                    allowedExtensions
                        .contains(path.split('.').last.toLowerCase()))
                .cast<String>());
            fileError = filePaths.isEmpty ? 'No valid files selected' : null;
          } else {
            fileError = 'No files selected';
          }
        } catch (fallbackError) {
          fileError = 'Fallback file picking failed: $fallbackError';
          developer.log('Fallback file picking failed: $fallbackError',
              name: 'ProcessDisputeViewModel.PickFile');
        }
      }
    }
    notifyListeners();
  }

  void removeFile(int index) {
    if (index >= 0 && index < filePaths.length) {
      filePaths.removeAt(index);
      fileError = null;
      notifyListeners();
    }
  }

  bool validateInputs() {
    bool isValid = true;
    if (selectedAction == null) {
      actionError = 'Please select an action';
      isValid = false;
    }
    if (remark.trim().isEmpty) {
      remarkError = 'Please provide a remark';
      isValid = false;
    }

    if (filePaths.isEmpty) {
      fileError = 'Please upload at least one file';
      isValid = false;
    }
    notifyListeners();
    return isValid;
  }

  Future<void> fetchDisputeDetails(String ticketId) async {
    if (isLoading) return;

    isLoading = true;
    notifyListeners();

    try {
      ticket = await _ticketService.getTicketDetails(ticketId);
      capturedImageUrls = ticket!.capturedImages ?? [];
      final disputes = await _disputesService.getDisputesByTicket(ticketId);
      if (disputes.isNotEmpty) {
        dispute = disputes.first;
        developer.log(
            '[ProcessDisputeViewModel] Fetched dispute for ticket $ticketId',
            name: 'ProcessDisputeViewModel');
      } else {
        error = 'No dispute found for ticket ID: $ticketId';
      }
    } catch (e) {
      error = 'Failed to fetch dispute details: $e';
      developer.log('[ProcessDisputeViewModel] Error: $e',
          name: 'ProcessDisputeViewModel');
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
            name: 'ProcessDisputeViewModel.FormatDate');
        return 'N/A';
      }
    }

    return {
      'ticketId': dispute!.ticketId ?? 'N/A',
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

  Future<bool> submitDisputeAction(String processedBy) async {
    if (isLoading ||
        !validateInputs() ||
        dispute == null ||
        dispute!.disputeId == null) {
      error = dispute == null || dispute!.disputeId == null
          ? 'No dispute loaded to process'
          : error;
      notifyListeners();
      return false;
    }

    isLoading = true;
    notifyListeners();

    try {
      final success = await _disputesService.processDispute(
        disputeId: dispute!.disputeId!.toString(),
        processStatus: selectedAction!,
        remark: remark.trim(),
        processedBy: processedBy,
        uploadedFiles: filePaths,
      );

      if (success) {
        selectedAction = null;
        remark = '';
        filePaths.clear();
        await fetchDisputeDetails(dispute!.ticketId);
        developer.log(
            '[ProcessDisputeViewModel] Processed dispute ID: ${dispute!.disputeId}',
            name: 'ProcessDisputeViewModel');
      }
      return success;
    } catch (e) {
      error = 'Failed to process dispute: $e';
      developer.log('[ProcessDisputeViewModel] Error processing: $e',
          name: 'ProcessDisputeViewModel');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    dispute = null;
    ticket = null;
    selectedAction = null;
    remark = '';
    filePaths.clear();
    capturedImageUrls = null;
    actionError = null;
    remarkError = null;
    fileError = null;
    error = null;
    isLoading = false;
    notifyListeners();
  }
}
