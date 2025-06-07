import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import '../../models/dispute.dart';
import '../../services/core/dispute_service.dart';
import '../../utils/exceptions.dart';

class DisputeListViewModel extends ChangeNotifier {
  final DisputesService _disputesService = DisputesService();
  List<Map<String, dynamic>> _disputes = [];
  bool _isLoading = false;
  String? _errorMessage;

  DisputeListViewModel();

  List<Map<String, dynamic>> get disputes => _disputes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchOpenDisputes({bool reset = false}) async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    if (reset) {
      _disputes.clear();
    }
    notifyListeners();

    try {
      developer.log('Fetching all open disputes', name: 'DisputeListViewModel');
      final disputes = await _disputesService.getAllOpenDisputes(); // Fetch all disputes
      _disputes = disputes.map((dispute) => _mapDisputeToMap(dispute)).toList();
      developer.log('Fetched ${_disputes.length} disputes', name: 'DisputeListViewModel');
    } catch (e, stackTrace) {
      _errorMessage = _handleError(e);
      developer.log('Error fetching disputes: $e', name: 'DisputeListViewModel', error: e, stackTrace: stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Map<String, dynamic> _mapDisputeToMap(Dispute dispute) {
    return {
      'disputeId': dispute.disputeId?.toString() ?? '',
      'ticketId': dispute.ticketId,
      'plazaId': dispute.plazaId.toString(),
      'plazaName': dispute.plazaId.toString(), // Replace with actual plazaName if available
      'entryTime': dispute.ticketCreationTime,
      'status': dispute.status.toLowerCase(),
      'vehicleNumber': dispute.vehicleNumber,
      'vehicleType': dispute.vehicleType.toLowerCase(),
      'disputeAmount': dispute.disputeAmount,
      'disputeReason': dispute.disputeReason,
      'latestRemark': dispute.latestRemark ?? '',
    };
  }

  String _handleError(dynamic e) {
    // Same error handling as provided
    if (e is NoInternetException) {
      return 'No internet connection. Please check your network.';
    } else if (e is ServerConnectionException) {
      return 'Failed to connect to the server${e.host != null ? ' at ${e.host}' : ''}.';
    } else if (e is RequestTimeoutException) {
      return 'Request timed out. Please try again.';
    } else if (e is HttpException) {
      return 'HTTP error: ${e.message}${e.statusCode != null ? ' (Status: ${e.statusCode})' : ''}';
    } else if (e is ServiceException) {
      return 'Service error: ${e.message}${e.serverMessage != null ? ' - ${e.serverMessage}' : ''}';
    } else if (e is PlazaException) {
      return 'Plaza error: ${e.message}${e.serverMessage != null ? ' - ${e.serverMessage}' : ''}';
    } else if (e is PaymentException) {
      return 'Payment error: ${e.message}${e.serverMessage != null ? ' - ${e.serverMessage}' : ''}';
    } else if (e is StorageException) {
      return 'Storage error: ${e.message}';
    } else if (e is AnprFailureException) {
      return 'ANPR failure: ${e.message}';
    } else if (e is MobileNumberInUseException || e is EmailInUseException) {
      return e.message;
    } else {
      return 'An unexpected error occurred.';
    }
  }

  void reset() {
    _disputes.clear();
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}