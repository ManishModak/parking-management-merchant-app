import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/dispute.dart';
import '../../services/core/dispute_service.dart';

class RaiseDisputeViewModel extends ChangeNotifier {
  final DisputesService _disputesService;
  final ImagePicker _imagePicker = ImagePicker();

  String? selectedReason;
  String disputeAmount = '';
  String remark = '';
  List<String> imagePaths = [];
  bool isLoading = false;
  String? reasonError;
  String? amountError;
  String? remarkError;
  String? imageError;
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
      imageError = 'Error capturing image: $e';
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
    if (remark.trim().isEmpty) {
      remarkError = 'Please enter a remark';
      isValid = false;
    } else if (remark.trim().length < 3 || remark.trim().length > 255) {
      remarkError = 'Remark must be between 3 and 255 characters';
      isValid = false;
    }
    notifyListeners();
    return isValid;
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
      final dispute = Dispute(
        userId: userId,
        ticketId: ticketId,
        plazaId: plazaId,
        ticketCreationTime: ticketCreationTime,
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

      final validationError = dispute.validateForCreate();
      if (validationError != null) {
        generalError = validationError;
        developer.log('Validation error: $validationError', name: 'RaiseDisputeViewModel.Validation');
        isLoading = false;
        notifyListeners();
        return false;
      }

      final createdDispute = await _disputesService.createDispute(
        dispute,
        uploadedFiles: imagePaths,
      );

      developer.log('Dispute created successfully: ${createdDispute.disputeId}',
          name: 'RaiseDisputeViewModel.Success');

      selectedReason = null;
      disputeAmount = '';
      remark = '';
      imagePaths.clear();
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
    imagePaths.clear();
    reasonError = null;
    amountError = null;
    remarkError = null;
    imageError = null;
    generalError = null;
    isLoading = false;
    notifyListeners();
  }
}