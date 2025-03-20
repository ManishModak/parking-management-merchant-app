import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class RaiseDisputeViewModel extends ChangeNotifier {
  String? selectedReason;
  String disputeAmount = '';
  String remark = '';
  List<String> imagePaths = [];
  String? reasonError;
  String? amountError;
  String? remarkError;
  String? imageError;

  final List<String> disputeReasons = [
    'Duplicate Transaction',
    'Incorrect Amount',
    'Service Not Provided',
    'Other',
  ];

  final ImagePicker _imagePicker = ImagePicker();

  void updateReason(String? reason) {
    selectedReason = reason;
    reasonError = null;
    notifyListeners();
  }

  void updateAmount(String amount) {
    disputeAmount = amount;
    amountError = null;
    notifyListeners();
  }

  void updateRemark(String remark) {
    this.remark = remark;
    remarkError = null;
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
    } else if (double.tryParse(disputeAmount) == null) {
      amountError = 'Please enter a valid number';
      isValid = false;
    }
    if (remark.isEmpty) {
      remarkError = 'Please enter a remark';
      isValid = false;
    }
    notifyListeners();
    return isValid;
  }

  Future<void> submitDispute(String ticketId) async {
    if (!validate()) return;
    // TODO: Implement API call to submit dispute
    print('Dispute submitted for ticket $ticketId: $selectedReason, $disputeAmount, $remark, $imagePaths');
  }
}