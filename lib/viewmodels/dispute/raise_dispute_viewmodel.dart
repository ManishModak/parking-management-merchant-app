import 'dart:developer' as developer;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/dispute.dart';
import '../../services/core/dispute_service.dart';

class RaiseDisputeViewModel extends ChangeNotifier {
  final DisputesService _disputesService;
  final _dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

  String? selectedReason;
  String disputeAmount = '';
  String remark = '';
  List<String> filePaths = [];
  bool isLoading = false;
  String? reasonError;
  String? amountError;
  String? remarkError;
  String? fileError;
  String? generalError;

  final List<String> disputeReasons = [
    'Duplicate Transaction',
    'Incorrect Charged',
    'Service Not Availed',
  ];

  RaiseDisputeViewModel({DisputesService? disputesService})
      : _disputesService = disputesService ?? DisputesService();

  void updateReason(String? reason) {
    selectedReason = reason;
    reasonError = null;
    generalError = null;
    notifyListeners();
  }

  void updateAmount(String amount) {
    disputeAmount = amount;
    amountError = null;
    generalError = null;
    notifyListeners();
  }

  void updateRemark(String value) {
    remark = value;
    remarkError = null;
    generalError = null;
    notifyListeners();
  }

  Future<void> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        allowMultiple: true,
      );

      if (result != null) {
        filePaths.addAll(result.paths.where((path) => path != null).cast<String>());
        fileError = null;
      } else {
        fileError = 'No files selected';
      }
    } catch (e) {
      fileError = 'Error picking files: $e';
      developer.log('Error picking files: $e', name: 'RaiseDisputeViewModel.PickFile');
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

  bool validate() {
    bool isValid = true;
    if (selectedReason == null) {
      reasonError = 'Please select a reason';
      isValid = false;
    }
    if (disputeAmount.isEmpty) {
      amountError = 'Please enter an amount';
      isValid = false;
    } else {
      final amount = double.tryParse(disputeAmount);
      if (amount == null || amount < 0) {
        amountError = 'Please enter a valid non-negative number';
        isValid = false;
      }
    }
    // if (remark.trim().isEmpty) {
    //   remarkError = 'Please enter a remark';
    //   isValid = false;
    // } else if (remark.trim().length < 3 || remark.trim().length > 255) {
    //   remarkError = 'Remark must be between 3 and 255 characters';
    //   isValid = false;
    // }
    // if (filePaths.isEmpty) {
    //   fileError = 'Please upload at least one file';
    //   isValid = false;
    // }
    notifyListeners();
    return isValid;
  }

  String? formatDateTime(String? dateTime) {
    if (dateTime == null) return null;
    try {
      final parsedDate = DateTime.parse(dateTime);
      return '${_dateFormat.format(parsedDate)}, IST';
    } catch (e) {
      developer.log('Error formatting date: $dateTime, error: $e',
          name: 'RaiseDisputeViewModel.FormatDate');
      return dateTime;
    }
  }

  Future<bool> submitDispute({
    required String ticketId,
    required int userId,
    required int plazaId,
    required String ticketCreationTime,
    required String vehicleNumber,
    required String vehicleType,
    required String? parkingDuration,
    required double fareAmount,
    required double paymentAmount,
    String? paymentTime,
    String? paymentMode,
  }) async {
    if (isLoading || !validate()) {
      developer.log('Submit dispute aborted: isLoading=$isLoading, validationPassed=${validate()}',
          name: 'RaiseDisputeViewModel.Submit');
      return false;
    }

    isLoading = true;
    generalError = null;
    notifyListeners();

    try {
      final formattedTicketCreationTime = formatDateTime(ticketCreationTime) ?? ticketCreationTime;
      final formattedPaymentTime = formatDateTime(paymentTime) ?? paymentTime;

      final dispute = Dispute(
        userId: userId,
        ticketId: ticketId,
        plazaId: plazaId,
        ticketCreationTime: ticketCreationTime, // Keep original for backend
        vehicleNumber: vehicleNumber,
        vehicleType: vehicleType,
        parkingDuration: parkingDuration ?? 'Unknown',
        fareAmount: fareAmount,
        paymentAmount: paymentAmount,
        disputeAmount: double.parse(disputeAmount),
        disputeReason: selectedReason!,
        remarks: remark.trim(),
        paymentTime: paymentTime,
        paymentMode: paymentMode ?? 'Unknown',
        status: 'Open',
      );

      developer.log('Dispute Object: ${dispute.toJsonForCreate()}', name: 'RaiseDisputeViewModel.Dispute');

      final createdDispute = await _disputesService.createDispute(
        dispute,
        uploadedFiles: filePaths,
      );

      developer.log('Dispute created successfully: ${createdDispute.disputeId}',
          name: 'RaiseDisputeViewModel.Success');

      selectedReason = null;
      disputeAmount = '';
      remark = '';
      filePaths.clear();
      return true;
    } catch (e) {
      generalError = 'Failed to submit dispute: $e';
      developer.log('Error in submitDispute: $e', name: 'RaiseDisputeViewModel.Error');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    selectedReason = null;
    disputeAmount = '';
    remark = '';
    filePaths.clear();
    reasonError = null;
    amountError = null;
    remarkError = null;
    fileError = null;
    generalError = null;
    isLoading = false;
    notifyListeners();
  }
}