import 'package:flutter/material.dart';
import '../../models/dispute.dart';

class ViewDisputeViewModel with ChangeNotifier {
  Dispute? dispute;
  bool isLoading = true;
  List<String>? capturedImageUrls;

  Future<void> fetchDisputeDetails(String ticketId) async {
    isLoading = true;
    notifyListeners();
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
      disputeExpiryDate: '29-02-2025 12:20:28',
      disputeStatus: 'Open',
      disputeRemark: '',
      disputeRaisedDate: '29-02-2025 12:20:28'
    );
    capturedImageUrls = ['https://example.com/image1.jpg', 'https://example.com/image2.jpg'];
    isLoading = false;
    notifyListeners();
  }
}