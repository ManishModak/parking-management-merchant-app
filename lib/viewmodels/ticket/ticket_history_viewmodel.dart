import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TicketHistoryViewModel extends ChangeNotifier {
  // Controllers for form fields
  final TextEditingController ticketIdController = TextEditingController();
  final TextEditingController plazaIdController = TextEditingController();
  final TextEditingController plazaNameController = TextEditingController();
  final TextEditingController entryLaneIdController = TextEditingController();
  final TextEditingController entryLaneDirectionController = TextEditingController();
  final TextEditingController floorIdController = TextEditingController();
  final TextEditingController slotIdController = TextEditingController();
  final TextEditingController vehicleNumberController = TextEditingController();
  final TextEditingController vehicleTypeController = TextEditingController();
  final TextEditingController entryTimeController = TextEditingController();
  final TextEditingController ticketCreationTimeController = TextEditingController();
  final TextEditingController ticketStatusController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();

  Map<String, dynamic>? _selectedTicket;
  bool _isLoading = false;

  Map<String, dynamic>? get selectedTicket => _selectedTicket;
  bool get isLoading => _isLoading;

  // Initialize ticket data and update controllers
  void initializeTicketData(Map<String, dynamic> ticket) {
    _selectedTicket = ticket;
    _updateControllers();
    notifyListeners();
  }

  // Update all controllers with ticket data
  void _updateControllers() {
    if (_selectedTicket != null) {
      ticketIdController.text = _selectedTicket?['ticketId'] ?? '';
      plazaIdController.text = _selectedTicket?['plazaId'] ?? '';
      plazaNameController.text = _selectedTicket?['plazaName'] ?? '';
      entryLaneIdController.text = _selectedTicket?['entryLaneId'] ?? '';
      entryLaneDirectionController.text = _selectedTicket?['entryLaneDirection'] ?? '';
      floorIdController.text = _selectedTicket?['floorId'] ?? '';
      slotIdController.text = _selectedTicket?['slotId'] ?? '';
      vehicleNumberController.text = _selectedTicket?['vehicleNumber'] ?? '';
      vehicleTypeController.text = _selectedTicket?['vehicleType'] ?? '';

      // Format timestamps
      if (_selectedTicket?['entryTime'] != null) {
        final entryTime = DateTime.parse(_selectedTicket!['entryTime']);
        entryTimeController.text = DateFormat('dd MMM yyyy, hh:mm a').format(entryTime);
      }

      if (_selectedTicket?['ticketCreationTime'] != null) {
        final creationTime = DateTime.parse(_selectedTicket!['ticketCreationTime']);
        ticketCreationTimeController.text = DateFormat('dd MMM yyyy, hh:mm a').format(creationTime);
      }

      ticketStatusController.text = _selectedTicket?['ticketStatus'] ?? '';
      remarksController.text = _selectedTicket?['remarks'] ?? '';
    }
  }

  Future<void> loadTicketDetails() async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    _isLoading = false;
    notifyListeners();
  }

  void clearSelectedTicket() {
    _selectedTicket = null;
    _clearControllers();
    notifyListeners();
  }

  // Clear all controllers
  void _clearControllers() {
    ticketIdController.clear();
    plazaIdController.clear();
    plazaNameController.clear();
    entryLaneIdController.clear();
    entryLaneDirectionController.clear();
    floorIdController.clear();
    slotIdController.clear();
    vehicleNumberController.clear();
    vehicleTypeController.clear();
    entryTimeController.clear();
    ticketCreationTimeController.clear();
    ticketStatusController.clear();
    remarksController.clear();
  }

  @override
  void dispose() {
    // Dispose all controllers
    ticketIdController.dispose();
    plazaIdController.dispose();
    plazaNameController.dispose();
    entryLaneIdController.dispose();
    entryLaneDirectionController.dispose();
    floorIdController.dispose();
    slotIdController.dispose();
    vehicleNumberController.dispose();
    vehicleTypeController.dispose();
    entryTimeController.dispose();
    ticketCreationTimeController.dispose();
    ticketStatusController.dispose();
    remarksController.dispose();
    super.dispose();
  }
}