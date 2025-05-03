import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../models/dispute.dart';
import '../../models/ticket.dart';
import '../../services/core/dispute_service.dart';
import '../../services/core/ticket_service.dart';

class ProcessDisputeViewModel extends ChangeNotifier {
  final DisputesService _disputesService;
  final TicketService _ticketService;
  final ImagePicker _imagePicker = ImagePicker();

  Dispute? dispute;
  Ticket? ticket;
  String? selectedAction;
  String remark = '';
  List<String> imagePaths = [];
  List<String>? capturedImageUrls;
  bool isLoading = false;
  String? actionError;
  String? remarkError;
  String? imageError;
  String? generalError;

  final List<String> disputeActions = ['Accepted', 'Rejected', 'Inprogress'];

  ProcessDisputeViewModel({
    DisputesService? disputesService,
    TicketService? ticketService,
  })  : _disputesService = disputesService ?? DisputesService(),
        _ticketService = ticketService ?? TicketService();

  void updateAction(String? action) {
    selectedAction = action;
    actionError = null;
    generalError = null;
    notifyListeners();
  }

  void updateRemark(String value) {
    remark = value;
    remarkError = null;
    generalError = null;
    notifyListeners();
  }

  Future<void> pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
      );
      if (image != null) {
        imagePaths.add(image.path);
        imageError = null;
        notifyListeners();
      }
    } catch (e) {
      imageError = 'Failed to capture image: $e';
      notifyListeners();
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < imagePaths.length) {
      imagePaths.removeAt(index);
      imageError = null;
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
    notifyListeners();
    return isValid;
  }

  Future<void> fetchDisputeDetails(String ticketId) async {
    if (isLoading) return;

    isLoading = true;
    generalError = null;
    dispute = null;
    ticket = null;
    capturedImageUrls = null;
    notifyListeners();

    try {
      // Fetch ticket details
      ticket = await _ticketService.getTicketDetails(ticketId);
      capturedImageUrls = ticket!.capturedImages ?? [];

      // Fetch dispute details
      final disputes = await _disputesService.getDisputesByTicket(ticketId);
      if (disputes.isNotEmpty) {
        dispute = disputes.first;
        developer.log('[ProcessDisputeViewModel] Fetched dispute for ticket $ticketId',
            name: 'ProcessDisputeViewModel');
      } else {
        generalError = 'No dispute found for ticket ID: $ticketId';
      }
    } catch (e) {
      generalError = 'Failed to fetch dispute details: $e';
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

  Future<bool> submitDisputeAction(String processedBy) async {
    if (isLoading || !validateInputs() || dispute == null || dispute!.disputeId == null) {
      generalError = dispute == null || dispute!.disputeId == null
          ? 'No dispute loaded to process'
          : generalError;
      notifyListeners();
      return false;
    }

    isLoading = true;
    generalError = null;
    notifyListeners();

    try {
      final success = await _disputesService.processDispute(
        disputeId: dispute!.disputeId!.toString(),
        processStatus: selectedAction!,
        remark: remark.trim(),
        processedBy: processedBy,
        uploadedFiles: imagePaths,
      );

      if (success) {
        selectedAction = null;
        remark = '';
        imagePaths.clear();
        await fetchDisputeDetails(dispute!.ticketId!); // Refresh details
        developer.log('[ProcessDisputeViewModel] Processed dispute ID: ${dispute!.disputeId}',
            name: 'ProcessDisputeViewModel');
      }
      return success;
    } catch (e) {
      generalError = 'Failed to process dispute: $e';
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
    imagePaths.clear();
    capturedImageUrls = null;
    actionError = null;
    remarkError = null;
    imageError = null;
    generalError = null;
    isLoading = false;
    notifyListeners();
  }
}