import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:merchant_app/models/lane.dart';
import 'package:merchant_app/models/plaza_fare.dart';
import '../../models/ticket.dart';
import '../../services/core/ticket_service.dart';

class NewTicketViewmodel extends ChangeNotifier {
  final TicketService _ticketService = TicketService();

  // Controllers
  final TextEditingController vehicleNumberController = TextEditingController();
  final TextEditingController floorIdController = TextEditingController();
  final TextEditingController slotIdController = TextEditingController();
  final TextEditingController plazaIdController = TextEditingController();
  final TextEditingController entryLaneIdController = TextEditingController();
  final TextEditingController entryTimeController = TextEditingController();
  final TextEditingController entryLaneDirectionController = TextEditingController();

  // Field-specific error states
  String? vehicleNumberError;
  String? floorIdError;
  String? slotIdError;
  String? vehicleTypeError;
  String? laneDirectionError;
  String? apiError;
  String? plazaIdError;
  String? entryLaneIdError;
  String? entryTimeError;
  String? imageCaptureError;

  String? selectedVehicleType;
  String? selectedDirection;
  bool isLoading = false;

  // Image related properties
  final ImagePicker _imagePicker = ImagePicker();
  List<String> selectedImagePaths = [];
  List<String> get vehicleTypes => VehicleTypes.values;
  List<String> get laneDirections => Lane.validDirections;

  Future<void> showImageSourceDialog(BuildContext context) async {
    // Directly call camera instead of showing dialog
    await pickImageFromCamera();
  }

  Future<void> pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (image != null) {
        selectedImagePaths.add(image.path);
        notifyListeners();
      }
    } catch (e) {
      imageCaptureError = 'Error capturing image: $e';
      notifyListeners();
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < selectedImagePaths.length) {
      selectedImagePaths.removeAt(index);
      notifyListeners();
    }
  }

  void resetErrors() {
    vehicleNumberError = null;
    floorIdError = null;
    slotIdError = null;
    vehicleTypeError = null;
    plazaIdError = null;
    entryLaneIdError = null;
    entryTimeError = null;
    imageCaptureError = null;
    apiError = null;
    notifyListeners();
  }

  bool validateForm() {
    bool isValid = true;

    resetErrors();
    log("Form validation started, errors reset");

    if (vehicleNumberController.text.isEmpty || vehicleNumberController.text.length > 20) {
      vehicleNumberError = 'Vehicle number must be between 1 and 20 characters';
      isValid = false;
      log("Validation error: $vehicleNumberError");
    }

    if (selectedVehicleType == null) {
      vehicleTypeError = 'Vehicle type is required';
      isValid = false;
      log("Validation error: $vehicleTypeError");
    }

    if (selectedDirection == null) {
      laneDirectionError = 'Lane Direction is required';
      isValid = false;
      log("Validation error: $laneDirectionError");
    }

    if (floorIdController.text.isEmpty || floorIdController.text.length > 20) {
      floorIdError = 'Floor ID must be between 1 and 20 characters';
      isValid = false;
      log("Validation error: $floorIdError");
    }

    if (slotIdController.text.isEmpty || slotIdController.text.length > 20) {
      slotIdError = 'Slot ID must be between 1 and 20 characters';
      isValid = false;
      log("Validation error: $slotIdError");
    }

    if (plazaIdController.text.isEmpty) {
      plazaIdError = 'Plaza ID is required';
      isValid = false;
      log("Validation error: $plazaIdError");
    }

    if (entryLaneIdController.text.isEmpty) {
      entryLaneIdError = 'Entry Lane ID is required';
      isValid = false;
      log("Validation error: $entryLaneIdError");
    }

    if (entryTimeController.text.isEmpty) {
      entryTimeError = 'Entry Time is required';
      isValid = false;
      log("Validation error: $entryTimeError");
    }

    if (selectedImagePaths.isEmpty) {
      imageCaptureError = 'Please capture at least one vehicle image';
      isValid = false;
      log("Validation error: $imageCaptureError");
    }

    notifyListeners();
    log("Form validation completed, isValid: $isValid");
    return isValid;
  }

  Future<bool> createTicket() async {
    entryTimeController.text = DateTime.now().toString();

    log("Entered CreateTicket Viewmodel Method");
    if (!validateForm()) {
      log("Form validation failed");
      return false;
    }

    log("Form validated successfully, starting ticket creation process");
    isLoading = true;
    notifyListeners();

    try {
      log("Creating new Ticket object");
      Ticket newTicket = Ticket(
        plazaId: plazaIdController.text,
        entryLaneId: entryLaneIdController.text,
        entryLaneDirection: selectedDirection!,
        floorId: floorIdController.text,
        slotId: slotIdController.text,
        vehicleNumber: vehicleNumberController.text,
        vehicleType: selectedVehicleType!,
        entryTime: entryTimeController.text,
      );
      log("Ticket object created successfully with vehicle number: ${newTicket.vehicleNumber}");

      log("Calling ticket service to create ticket with images");
      await _ticketService.createTicketWithImages(newTicket, selectedImagePaths);
      log("Ticket created successfully in service layer");

      isLoading = false;
      notifyListeners();
      log("Ticket creation completed successfully");
      return true;
    } catch (e) {
      log("Error occurred during ticket creation: ${e.toString()}");
      // Refine the error message based on the exception
      if (e.toString().contains("502")) {
        apiError = 'Failed to create ticket: Unable to reach plaza service.';
      } else {
        apiError = 'Failed to create ticket: ${e.toString()}';
      }
      isLoading = false;
      notifyListeners();
      log("Notified listeners about creation failure with apiError: $apiError");
      return false;
    }
  }

  void updateVehicleType(String? type) {
    selectedVehicleType = type;
    notifyListeners();
  }

  void updateDirection(String? direction) {
    selectedDirection = direction;
    notifyListeners();
  }

  @override
  void dispose() {
    vehicleNumberController.dispose();
    floorIdController.dispose();
    slotIdController.dispose();
    plazaIdController.dispose();
    entryLaneIdController.dispose();
    entryTimeController.dispose();
    entryLaneDirectionController.dispose();
    super.dispose();
  }
}