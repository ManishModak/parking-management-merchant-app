import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/dispute.dart';

class ProcessDisputeViewModel extends ChangeNotifier {
  String? selectedAction;
  String remark = '';
  List<String> imagePaths = [];  // Added for local image paths
  String? actionError;
  String? remarkError;
  String? imageError;  // Added for image validation
  bool isLoading = false;
  Dispute? dispute;
  List<String>? capturedImageUrls;

  final List<String> disputeActions = [
    'Approve',
    'Reject',
    'Pending',
  ];

  final ImagePicker _imagePicker = ImagePicker();  // Added for image picking

  void updateAction(String? action) {
    selectedAction = action;
    actionError = null;
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
    if (selectedAction == null) {
      actionError = 'Please select an action';
      isValid = false;
    }
    if (remark.isEmpty) {
      remarkError = 'Please enter a remark';
      isValid = false;
    }
    // Optional: Add image validation if required
    // if (imagePaths.isEmpty) {
    //   imageError = 'Please upload at least one image';
    //   isValid = false;
    // }
    notifyListeners();
    return isValid;
  }

  Future<void> fetchDisputeDetails(String ticketId) async {
    isLoading = true;
    notifyListeners();
    try {
      // Simulate fetching data
      await Future.delayed(const Duration(seconds: 2));
      dispute = Dispute(
        disputeId: '12221',
        ticketId: '48775',
        plazaName: 'ABC Plaza',
        vehicleNumber: 'MH12UM2301',
        vehicleType: 'Bus',
        vehicleEntryTime: '29-01-2025 12:20:28',
        vehicleExitTime: '29-01-2025 14:20:28',
        parkingDuration: '2 Hours',
        fareType: 'Daily',
        fareAmount: '200',
        paymentAmount: '200',
        paymentDate: '29-01-2025 14:20:28',
        disputeReason: 'Duplicate Transaction',
        disputeAmount: '200',
        disputeExpiryDate: '28-02-2025 12:20:28',
        disputeStatus: 'Open',
        disputeRemark: '',
        disputeRaisedDate: '29-01-2025 12:20:28',
      );
      capturedImageUrls = [
        'https://example.com/image1.jpg',
        'https://example.com/image2.jpg',
      ];
    } catch (e) {
      debugPrint('Error fetching dispute details: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitDisputeAction(String ticketId) async {
    if (!validate()) return;

    isLoading = true;
    notifyListeners();
    try {
      // TODO: Implement actual API call including imagePaths
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      debugPrint('Dispute processed for ticket $ticketId: $selectedAction, $remark, $imagePaths');
    } catch (e) {
      debugPrint('Error submitting dispute: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}