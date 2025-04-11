import 'dart:developer';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:merchant_app/models/plaza_fare.dart';
import '../../models/plaza.dart';
import '../../models/lane.dart';
import '../../models/ticket.dart';
import '../../services/core/ticket_service.dart';
import '../../services/core/lane_service.dart';
import '../../services/storage/secure_storage_service.dart';
import '../../utils/exceptions.dart';
import '../../viewmodels/plaza/plaza_list_viewmodel.dart';
import '../../../generated/l10n.dart';

class NewTicketViewmodel extends ChangeNotifier {
  final TicketService _ticketService = TicketService();
  final SecureStorageService _secureStorage = SecureStorageService();
  final PlazaListViewModel _plazaListViewModel = PlazaListViewModel();
  final LaneService _laneService = LaneService();
  final ImagePicker _imagePicker = ImagePicker();

  // Controllers
  final TextEditingController vehicleNumberController = TextEditingController();
  final TextEditingController entryTimeController = TextEditingController();

  // Selected values
  String? selectedPlazaId;
  String? selectedEntryLaneId;
  String? selectedVehicleType;

  // Field-specific error states
  String? vehicleNumberError;
  String? vehicleTypeError;
  String? apiError;
  String? plazaIdError;
  String? entryLaneIdError;
  String? imageCaptureError;

  bool isLoading = false;
  bool isManualTicketExpanded = false;

  // Image related properties
  List<String> selectedImagePaths = [];
  DateTime? firstImageCaptureTime;

  // Vehicle types
  List<String> get vehicleTypes => VehicleTypes.values; // Adjust as per your backend

  // Plaza and Lane properties
  List<Plaza> get userPlazas => _plazaListViewModel.userPlazas;
  List<Lane> _lanes = [];
  List<Lane> get lanes => _lanes;

  NewTicketViewmodel() {
    _initialize();
  }

  Future<void> _initialize() async {
    final userId = await _secureStorage.getUserId();
    if (userId != null) {
      await fetchUserPlazas(userId);
    } else {
      apiError = S.current.noUserIdError;
      notifyListeners();
    }
  }

  Future<void> fetchUserPlazas(String userId) async {
    try {
      isLoading = true;
      notifyListeners();
      await _plazaListViewModel.fetchUserPlazas(userId);
      if (_plazaListViewModel.error != null) {
        apiError = S.current.plazaFetchError(_plazaListViewModel.error.toString());
      }
    } catch (e) {
      apiError = S.current.plazaFetchError(e.toString());
      log("Error fetching plazas: $e", name: "NewTicketViewmodel");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchLanes(String plazaId) async {
    try {
      isLoading = true;
      apiError = null;
      notifyListeners();
      _lanes = await _laneService.getLanesByPlazaId(plazaId);
    } catch (e) {
      apiError = S.current.laneFetchError(e.toString());
      _lanes = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> _getCameraId() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id; // Unique device ID as a proxy for camera ID
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor;
      }
      return 'unknown'; // Fallback for unsupported platforms
    } catch (e) {
      developer.log('Error getting camera ID: $e', name: 'NewTicketViewmodel');
      return 'unknown'; // Fallback in case of plugin failure
    }
  }

  Future<void> pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 80,
      );
      if (image != null) {
        if (selectedImagePaths.isEmpty) {
          firstImageCaptureTime = DateTime.now();
        }
        selectedImagePaths.add(image.path);
        notifyListeners();
      }
    } catch (e) {
      imageCaptureError = S.current.imageCaptureError(e.toString());
      notifyListeners();
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < selectedImagePaths.length) {
      selectedImagePaths.removeAt(index);
      if (selectedImagePaths.isEmpty) firstImageCaptureTime = null;
      notifyListeners();
    }
  }

  void resetErrors() {
    vehicleNumberError = null;
    vehicleTypeError = null;
    plazaIdError = null;
    entryLaneIdError = null;
    imageCaptureError = null;
    apiError = null;
    notifyListeners();
  }

  bool validateForm() {
    bool isValid = true;
    resetErrors();

    if (selectedPlazaId == null || selectedPlazaId!.isEmpty) {
      plazaIdError = S.current.plazaIdRequired;
      isValid = false;
    }
    if (selectedEntryLaneId == null || selectedEntryLaneId!.isEmpty) {
      entryLaneIdError = S.current.laneIdRequired;
      isValid = false;
    }
    if (selectedImagePaths.isEmpty) {
      imageCaptureError = S.current.imageRequired;
      isValid = false;
    }
    if (isManualTicketExpanded) {
      if (vehicleNumberController.text.isEmpty || vehicleNumberController.text.length > 20) {
        vehicleNumberError = S.current.vehicleNumberError;
        isValid = false;
      }
      if (selectedVehicleType == null) {
        vehicleTypeError = S.current.vehicleTypeRequired;
        isValid = false;
      }
    }
    notifyListeners();
    return isValid;
  }

  Future<bool> createTicket() async {
    if (!validateForm()) return false;

    isLoading = true;
    notifyListeners();

    try {
      final cameraId = await _getCameraId() ?? 'unknown';
      final entryTime = DateTime.now().toIso8601String();
      final cameraReadTime = firstImageCaptureTime?.toIso8601String() ?? entryTime;

      final ticket = Ticket(
        plazaId: selectedPlazaId!, // String, matches backend
        entryLaneId: selectedEntryLaneId!, // String, matches backend
        entryTime: entryTime,
        vehicleNumber: isManualTicketExpanded ? vehicleNumberController.text : null,
        vehicleType: isManualTicketExpanded ? selectedVehicleType : null,
        channelId: '3',
        requestType: isManualTicketExpanded ? '1' : '0',
        cameraId: cameraId,
        cameraReadTime: cameraReadTime,
      );

      await _ticketService.createTicketWithImages(
        ticket,
        selectedImagePaths,
        channelId: '3',
        requestType: isManualTicketExpanded ? '1' : '0',
        cameraId: cameraId,
        cameraReadTime: cameraReadTime,
      );

      isLoading = false;
      notifyListeners();
      return true;
    } on AnprFailureException catch (e) {
      apiError = 'ANPR Failed';
      isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      apiError = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void updateVehicleType(String? type) {
    selectedVehicleType = type;
    notifyListeners();
  }

  void toggleManualTicketExpanded({bool? forceExpand}) {
    if (forceExpand != null) {
      isManualTicketExpanded = forceExpand;
    } else {
      isManualTicketExpanded = !isManualTicketExpanded;
    }
    notifyListeners();
  }

  void updatePlazaId(dynamic id) {
    selectedPlazaId = id?.toString(); // Convert to String, handles int or String
    if (selectedPlazaId != null) {
      fetchLanes(selectedPlazaId!); // Already String, no conversion needed
    } else {
      _lanes = [];
      notifyListeners();
    }
  }

  void updateEntryLaneId(dynamic id) {
    selectedEntryLaneId = id?.toString(); // Convert to String, handles int or String
    notifyListeners();
  }

  @override
  void dispose() {
    vehicleNumberController.dispose();
    entryTimeController.dispose();
    super.dispose();
  }
}