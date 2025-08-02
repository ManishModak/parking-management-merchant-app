// merchant_app/lib/viewmodels/ticket/new_ticket_viewmodel.dart
import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';
import 'package:merchant_app/models/plaza.dart';
import 'package:merchant_app/models/lane.dart';
import 'package:merchant_app/models/ticket.dart';
import 'package:merchant_app/services/core/ticket_service.dart';
import 'package:merchant_app/services/core/lane_service.dart';
import 'package:merchant_app/services/core/user_service.dart';
import 'package:merchant_app/services/storage/secure_storage_service.dart';
import 'package:merchant_app/utils/exceptions.dart';
import 'package:merchant_app/viewmodels/plaza/plaza_list_viewmodel.dart';
import '../../../generated/l10n.dart';
import '../../models/plaza_fare.dart';

class NewTicketViewmodel extends ChangeNotifier {
  final TicketService _ticketService = TicketService();
  final SecureStorageService _secureStorage = SecureStorageService();
  final PlazaListViewModel _plazaListViewModel = PlazaListViewModel();
  final LaneService _laneService = LaneService();
  final UserService _userService = UserService();
  final ImagePicker _imagePicker = ImagePicker();

  // Controllers
  final TextEditingController vehicleNumberController = TextEditingController();
  final TextEditingController entryTimeController = TextEditingController();

  // Selected values
  String? selectedPlazaId;
  String? selectedEntryLaneId;
  String? selectedVehicleType;
  String? geoLatitude;
  String? geoLongitude;
  String? selectedLaneDirection;

  // Field-specific error states
  String? vehicleNumberError;
  String? vehicleTypeError;
  String? apiError;
  String? plazaIdError;
  String? entryLaneIdError;
  String? imageCaptureError;
  String? locationError;

  bool isLoading = false;
  bool isManualTicketExpanded = false;

  // Image related properties
  List<String> selectedImagePaths = [];
  DateTime? firstImageCaptureTime;

  // Vehicle types
  List<String> get vehicleTypes => VehicleTypes.values;

  // Plaza and Lane properties
  List<Plaza> _userPlazas = [];
  List<Plaza> get userPlazas => _userPlazas;
  List<Lane> _lanes = [];
  List<Lane> get lanes => _lanes;

  String? userRole;

  // << NEW >> To store the actual UUID ticket_id for navigation
  String? _createdTicketUuid;
  String? get createdTicketUuid => _createdTicketUuid;

  NewTicketViewmodel() {
    _initialize();
  }

  Future<void> _initialize() async {
    isLoading = true;
    notifyListeners();
    try {
      final userId = await _secureStorage.getUserId();
      final entityId = await _secureStorage.getEntityId();
      userRole = await _secureStorage.getUserRole();

      if (userId != null) {
        if (userRole == 'Plaza Owner') {
          await fetchUserPlazas(entityId!);
        } else if (userRole == 'Plaza Admin' || userRole == 'Plaza Operator') {
          await fetchUserPlazasForNonOwner(userId);
        }
        if (apiError == null) {
          await _fetchLocation();
        }
      } else {
        apiError = S.current.noUserIdError;
      }
    } catch (e) {
      apiError = S.current.initializationError(e.toString());
      developer.log('[NewTicketViewmodel] Initialization Error: $e',
          name: 'NewTicketViewmodel');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Improved location fetching with better permission handling
  Future<void> _fetchLocation() async {
    locationError = null;
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        locationError = S.current.locationServiceDisabled;
        developer.log('[NewTicketViewmodel] Location services are disabled',
            name: 'NewTicketViewmodel');
        notifyListeners();
        return;
      }

      // Check current permission status
      LocationPermission permission = await Geolocator.checkPermission();
      developer.log(
          '[NewTicketViewmodel] Current location permission: $permission',
          name: 'NewTicketViewmodel');

      // Handle permission logic
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        developer.log(
            '[NewTicketViewmodel] Permission after request: $permission',
            name: 'NewTicketViewmodel');

        if (permission == LocationPermission.denied) {
          locationError = S.current.locationPermissionDenied;
          developer.log(
              '[NewTicketViewmodel] Location permission denied by user',
              name: 'NewTicketViewmodel');
          notifyListeners();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        locationError = S.current.locationPermissionDeniedForever;
        developer.log('[NewTicketViewmodel] Location permission denied forever',
            name: 'NewTicketViewmodel');
        notifyListeners();
        return;
      }

      // Fetch location with timeout and better accuracy settings
      developer.log('[NewTicketViewmodel] Fetching current location...',
          name: 'NewTicketViewmodel');

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 30), // Add timeout
      );

      geoLatitude = position.latitude.toStringAsFixed(6);
      geoLongitude = position.longitude.toStringAsFixed(6);

      developer.log(
          '[NewTicketViewmodel] Location fetched successfully: Lat=$geoLatitude, Lon=$geoLongitude, Accuracy=${position.accuracy}m',
          name: 'NewTicketViewmodel');

      // Try to get address for better UX (optional, non-blocking)
      try {
        await _getAddressFromLocation(position.latitude, position.longitude);
      } catch (e) {
        developer.log(
            '[NewTicketViewmodel] Address lookup failed (non-critical): $e',
            name: 'NewTicketViewmodel');
        // Don't set error - location is still valid
      }
    } on LocationServiceDisabledException catch (e) {
      locationError = S.current.locationServiceDisabled;
      developer.log('[NewTicketViewmodel] Location services disabled: $e',
          name: 'NewTicketViewmodel', error: e);
    } on PermissionDeniedException catch (e) {
      locationError = S.current.locationPermissionDenied;
      developer.log('[NewTicketViewmodel] Location permission denied: $e',
          name: 'NewTicketViewmodel', error: e);
    } on TimeoutException catch (e) {
      locationError = S.current.locationFetchTimeoutError;
      developer.log('[NewTicketViewmodel] Location fetch timeout: $e',
          name: 'NewTicketViewmodel', error: e);
    } on PositionUpdateException catch (e) {
      locationError = S.current.locationFetchError;
      developer.log('[NewTicketViewmodel] Position update error: $e',
          name: 'NewTicketViewmodel', error: e);
    } catch (e) {
      locationError = S.current.locationFetchError;
      developer.log('[NewTicketViewmodel] Unexpected location fetch error: $e',
          name: 'NewTicketViewmodel', error: e);
    }
    notifyListeners();
  }

  /// Optional address lookup for better UX
  Future<void> _getAddressFromLocation(
      double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        final addressParts = [
          place.name,
          place.thoroughfare,
          place.subLocality,
          place.locality,
          place.administrativeArea,
        ].where((part) => part != null && part.isNotEmpty).toList();

        final address = addressParts.join(', ');
        developer.log('[NewTicketViewmodel] Address resolved: $address',
            name: 'NewTicketViewmodel');
      }
    } catch (e) {
      // Non-critical error - don't propagate
      developer.log('[NewTicketViewmodel] Geocoding failed: $e',
          name: 'NewTicketViewmodel');
    }
  }

  /// Manual retry for location fetching (called from UI)
  Future<void> retryLocationFetch() async {
    developer.log('[NewTicketViewmodel] Manual location retry requested',
        name: 'NewTicketViewmodel');
    isLoading = true;
    notifyListeners();
    try {
      await _fetchLocation();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Check if location can be retried or needs settings
  bool get canRetryLocation {
    return locationError != null &&
        locationError != S.current.locationPermissionDeniedForever;
  }

  /// Check if location settings need to be opened
  bool get needsLocationSettings {
    return locationError == S.current.locationServiceDisabled ||
        locationError == S.current.locationPermissionDeniedForever;
  }

  /// Open location settings
  Future<void> openLocationSettings() async {
    try {
      if (locationError == S.current.locationServiceDisabled) {
        developer.log('[NewTicketViewmodel] Opening location settings',
            name: 'NewTicketViewmodel');
        await Geolocator.openLocationSettings();
      } else if (locationError == S.current.locationPermissionDeniedForever) {
        developer.log(
            '[NewTicketViewmodel] Opening app settings for location permission',
            name: 'NewTicketViewmodel');
        await openAppSettings();
      }
    } catch (e) {
      developer.log('[NewTicketViewmodel] Error opening settings: $e',
          name: 'NewTicketViewmodel', error: e);
    }
  }

  /// Get user-friendly location status message
  String? get locationStatusMessage {
    if (geoLatitude != null && geoLongitude != null) {
      return 'Location obtained successfully';
    } else if (locationError != null) {
      return locationError;
    } else if (isLoading) {
      return 'Obtaining location...';
    }
    return null;
  }

  /// Check if location is available for ticket creation
  bool get isLocationAvailable {
    return geoLatitude != null &&
        geoLongitude != null &&
        geoLatitude!.isNotEmpty &&
        geoLongitude!.isNotEmpty;
  }

  Future<void> fetchUserPlazas(String userId) async {
    isLoading = true;
    apiError = null;
    notifyListeners();
    try {
      await _plazaListViewModel.fetchUserPlazas(userId);
      _userPlazas = _plazaListViewModel.userPlazas;
      if (_plazaListViewModel.error != null) {
        apiError =
            S.current.plazaFetchError(_plazaListViewModel.error.toString());
      } else if (_userPlazas.isEmpty) {
        apiError = S.current.noPlazasFound;
      }
    } catch (e) {
      apiError = S.current.plazaFetchError(e.toString());
      developer.log("Error fetching plazas: $e", name: "NewTicketViewmodel");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUserPlazasForNonOwner(String userId) async {
    isLoading = true;
    apiError = null;
    notifyListeners();
    try {
      final user = await _userService.fetchUserInfo(userId, true);

      if (user.subEntityData != null && user.subEntityData!.isNotEmpty) {
        _userPlazas = user.subEntityData!.map((subEntityMap) {
          return Plaza(
            plazaId: subEntityMap['plazaId']?.toString() ?? 'error_id',
            plazaName:
                subEntityMap['plazaName']?.toString() ?? S.current.unnamedPlaza,
          );
        }).toList();

        developer.log(
            '[NewTicketViewmodel] Mapped ${_userPlazas.length} plazas from subEntityData for role: $userRole',
            name: 'NewTicketViewmodel');

        if (_userPlazas.length == 1) {
          selectedPlazaId = _userPlazas.first.plazaId;
          if (selectedPlazaId != 'error_id' && selectedPlazaId != null) {
            await fetchLanes(selectedPlazaId!);
          } else {
            selectedPlazaId = null;
            apiError = S.current.invalidPlazaData;
          }
        } else if (_userPlazas.isEmpty) {
          apiError = S.current.noPlazaAssigned;
        }
      } else {
        _userPlazas = [];
        apiError = S.current.noPlazaAssigned;
        developer.log(
            '[NewTicketViewmodel] No valid subEntityData (or empty) found for user ID: $userId, Role: $userRole',
            name: 'NewTicketViewmodel');
      }
    } catch (e, stackTrace) {
      apiError = S.current.plazaFetchError(e.toString());
      _userPlazas = [];
      developer.log("Error fetching user plazas for non-owner: $e\n$stackTrace",
          name: "NewTicketViewmodel");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchLanes(String plazaId) async {
    isLoading = true;
    apiError = null;
    _lanes = [];
    notifyListeners();
    try {
      _lanes = await _laneService.getLanesByPlazaId(plazaId);
      if (_lanes.isEmpty) {
        apiError = S.current.noLanesFoundForPlaza;
      }
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
        return androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor;
      }
      return 'unknown_platform_${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      developer.log('Error getting camera ID: $e', name: 'NewTicketViewmodel');
      return 'error_camera_id_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  Future<File> _processImage(XFile inputImage) async {
    final inputFile = File(inputImage.path);
    if (!await inputFile.exists()) {
      developer.log(
          '[NewTicketViewmodel] Input image file does not exist: ${inputImage.path}',
          name: 'NewTicketViewmodel',
          error: 'FileNotExists');
      throw Exception('Input image file does not exist: ${inputImage.path}');
    }
    developer.log(
      '[NewTicketViewmodel] Using original image: ${inputImage.path}, MIME: ${inputImage.mimeType}',
      name: 'NewTicketViewmodel',
    );
    return inputFile;
  }

  Future<void> pickImageFromCamera() async {
    try {
      imageCaptureError = null;
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 100,
      );
      if (image != null) {
        isLoading = true;
        notifyListeners();
        try {
          developer.log(
              '[NewTicketViewmodel] Image picked from camera: ${image.path}',
              name: 'NewTicketViewmodel');
          final processedImageFile = await _processImage(image);
          developer.log(
              '[NewTicketViewmodel] Image processed successfully: ${processedImageFile.path}',
              name: 'NewTicketViewmodel');

          if (selectedImagePaths.isEmpty) {
            firstImageCaptureTime = DateTime.now();
          }
          selectedImagePaths.add(processedImageFile.path);
          imageCaptureError = null;
        } catch (e, stackTrace) {
          developer.log(
              '[NewTicketViewmodel] Error processing camera image: $e\n$stackTrace',
              name: 'NewTicketViewmodel',
              error: e);
          imageCaptureError = S.current.imageProcessingError(e.toString());
        } finally {
          isLoading = false;
          notifyListeners();
        }
      } else {
        developer.log('[NewTicketViewmodel] No image picked from camera.',
            name: 'NewTicketViewmodel');
      }
    } catch (e, stackTrace) {
      developer.log(
          '[NewTicketViewmodel] Error picking/processing camera image: $e\n$stackTrace',
          name: 'NewTicketViewmodel',
          error: e);
      imageCaptureError = S.current.imageCaptureError;
      isLoading = false;
      notifyListeners();
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < selectedImagePaths.length) {
      final filePath = selectedImagePaths[index];
      selectedImagePaths.removeAt(index);
      developer.log(
          '[NewTicketViewmodel] Removed image path from list: $filePath',
          name: 'NewTicketViewmodel');
      if (selectedImagePaths.isEmpty) {
        firstImageCaptureTime = null;
      }
      if (selectedImagePaths.isEmpty &&
          imageCaptureError == S.current.imageRequired) {
        imageCaptureError = null;
      }
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
    vehicleNumberError = null;
    vehicleTypeError = null;
    plazaIdError = null;
    entryLaneIdError = null;
    imageCaptureError = null;

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
    if (geoLatitude == null || geoLongitude == null) {
      locationError ??= S.current.locationNotAvailableError;
      isValid = false;
    }

    if (isManualTicketExpanded) {
      if (vehicleNumberController.text.trim().isEmpty) {
        vehicleNumberError = S.current.vehicleNumberRequiredError;
        isValid = false;
      } else if (vehicleNumberController.text.trim().length > 20) {
        vehicleNumberError = S.current.vehicleNumberTooLongError;
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

  /// Returns the ticket_ref_id for the success dialog.
  /// Internally stores ticket_id (UUID) in _createdTicketUuid for navigation.
  Future<String?> createTicket() async {
    if (!validateForm()) return null;

    isLoading = true;
    apiError = null;
    _createdTicketUuid = null; // Reset before attempt
    notifyListeners();

    String? ticketRefIdForDialog;

    try {
      final cameraId = await _getCameraId();
      final entryTime = DateTime.now().toIso8601String();
      final cameraReadTime =
          firstImageCaptureTime?.toIso8601String() ?? entryTime;

      final ticket = Ticket(
        plazaId: int.tryParse(selectedPlazaId!) ?? 0,
        entryLaneId: selectedEntryLaneId!,
        entryTime: DateTime.now().toUtc(),
        vehicleNumber:
            isManualTicketExpanded ? vehicleNumberController.text.trim() : null,
        vehicleType: isManualTicketExpanded ? selectedVehicleType : null,
        geoLatitude: geoLatitude,
        geoLongitude: geoLongitude,
      );

      // TicketService's createTicketWithImages now returns a Map<String, String?>
      // containing both 'ticket_ref_id' and 'ticket_id_uuid'
      final Map<String, String?>? ticketIds =
          await _ticketService.createTicketWithImages(
        ticket,
        selectedImagePaths,
        channelId: '3',
        requestType: isManualTicketExpanded ? '1' : '0',
        cameraId: cameraId!,
        cameraReadTime: cameraReadTime,
        geoLatitude: geoLatitude!,
        geoLongitude: geoLongitude!,
      );

      if (ticketIds != null) {
        ticketRefIdForDialog = ticketIds['ticket_ref_id'];
        _createdTicketUuid = ticketIds['ticket_id_uuid']; // Store the UUID

        if (ticketRefIdForDialog == null || _createdTicketUuid == null) {
          // This case means service returned 200 OK but didn't find the IDs in the response.
          apiError =
              S.current.failedToParseTicketIds; // Or a more specific error.
          developer.log(
              '[NewTicketViewmodel] Failed to parse ticket IDs from service response.',
              name: 'NewTicketViewmodel');
          ticketRefIdForDialog =
              null; // Ensure dialog doesn't show partial success.
          _createdTicketUuid = null;
        }
      } else {
        // This implies the service method itself returned null, possibly due to an internal issue
        // before an exception was thrown, or if the API was 200 OK but the structure was unexpected.
        // apiError should have been set by the service if it was an HTTP error.
        // If apiError is still null here, it's an unexpected state.
        apiError ??= S.current.failedToCreateTicket; // Generic fallback
        developer.log(
            '[NewTicketViewmodel] Service returned null for ticket IDs. API Error: $apiError',
            name: 'NewTicketViewmodel');
      }
    } on AnprFailureException catch (e) {
      apiError = 'ANPR Failed: $e';
      developer.log('[NewTicketViewmodel] ANPR Failure: $e',
          name: 'NewTicketViewmodel', error: e);
    } on HttpException catch (e) {
      developer.log('[NewTicketViewmodel] HttpException creating ticket: $e',
          name: 'NewTicketViewmodel', error: e);
      if (e.statusCode == 500) {
        apiError = S.current.internalServerError;
      } else if (e.statusCode == 400) {
        if (e.serverMessage != null && e.serverMessage!.isNotEmpty) {
          apiError = e.serverMessage;
        } else {
          apiError = S.current.badRequestError;
        }
      } else if (e.statusCode == 401) {
        apiError = S.current.unauthorizedError;
      } else if (e.statusCode == 403) {
        apiError = S.current.forbiddenError;
      } else {
        apiError = S.current.httpRequestFailedWithCode(
            e.statusCode?.toString() ?? S.current.unknownCode);
      }
    } on NoInternetException catch (e) {
      developer.log('[NewTicketViewmodel] NoInternetException: $e',
          name: 'NewTicketViewmodel', error: e);
      apiError = S.current.noInternetConnection;
    } on ServerConnectionException catch (e) {
      developer.log('[NewTicketViewmodel] ServerConnectionException: $e',
          name: 'NewTicketViewmodel', error: e);
      apiError = S.current.serverConnectionError;
    } on RequestTimeoutException catch (e) {
      developer.log('[NewTicketViewmodel] RequestTimeoutException: $e',
          name: 'NewTicketViewmodel', error: e);
      apiError = S.current.requestTimeoutError;
    } on SocketException catch (e) {
      developer.log('[NewTicketViewmodel] SocketException: $e',
          name: 'NewTicketViewmodel', error: e);
      apiError = S.current.networkError;
    } catch (e, stackTrace) {
      developer.log(
          '[NewTicketViewmodel] Unexpected error creating ticket: $e\n$stackTrace',
          name: 'NewTicketViewmodel',
          error: e);
      apiError = S.current.unexpectedErrorOccurred(e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }

    // If an error occurred and set apiError, ticketRefIdForDialog would be null or should be treated as such by UI.
    // The success dialog relies on ticketRefIdForDialog not being null.
    return ticketRefIdForDialog;
  }

  void toggleManualTicketExpanded({bool? forceExpand}) {
    final bool previousState = isManualTicketExpanded;
    if (forceExpand != null) {
      isManualTicketExpanded = forceExpand;
    } else {
      isManualTicketExpanded = !isManualTicketExpanded;
    }

    if (previousState == true && isManualTicketExpanded == false) {
      vehicleNumberController.clear();
      selectedVehicleType = null;
      vehicleNumberError = null;
      vehicleTypeError = null;
    }
    notifyListeners();
  }

  void updateVehicleType(String? type) {
    if (selectedVehicleType != type) {
      selectedVehicleType = type;
      if (type != null) vehicleTypeError = null;
      notifyListeners();
    }
  }

  void updatePlazaId(dynamic id) {
    final newPlazaId = id?.toString();
    if (selectedPlazaId != newPlazaId) {
      selectedPlazaId = newPlazaId;
      selectedEntryLaneId = null;
      selectedLaneDirection = null;
      _lanes = [];
      plazaIdError = null;
      entryLaneIdError = null;
      apiError = null;

      if (selectedPlazaId != null && selectedPlazaId!.isNotEmpty) {
        fetchLanes(selectedPlazaId!);
      } else {
        notifyListeners();
      }
    }
  }

  void updateEntryLaneId(dynamic id, String? direction) {
    final newLaneId = id?.toString();
    if (selectedEntryLaneId != newLaneId) {
      selectedEntryLaneId = newLaneId;
      selectedLaneDirection = direction;
      if (newLaneId != null) entryLaneIdError = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    vehicleNumberController.dispose();
    entryTimeController.dispose();
    developer.log(
        '[NewTicketViewmodel] Clearing selectedImagePaths without deleting original files',
        name: 'NewTicketViewmodel');
    selectedImagePaths.clear();
    super.dispose();
  }

  // Future<void> pickImageFromGallery() async {
  //   try {
  //     imageCaptureError = null;
  //     final XFile? image = await _imagePicker.pickImage(
  //       source: ImageSource.gallery,
  //       imageQuality: 80,
  //     );
  //     if (image != null) {
  //       isLoading = true;
  //       notifyListeners();
  //       try {
  //         final processedImageFile = await _processImage(image);
  //         if (selectedImagePaths.isEmpty) {
  //           firstImageCaptureTime = DateTime.now();
  //         }
  //         selectedImagePaths.add(processedImageFile.path);
  //       } catch (e) {
  //         developer.log(
  //             '[NewTicketViewmodel] Error processing gallery image: $e',
  //             name: 'NewTicketViewmodel');
  //         imageCaptureError = S.current.imageProcessingError(e.toString());
  //       } finally {
  //         isLoading = false;
  //         notifyListeners();
  //       }
  //     }
  //   } catch (e) {
  //     developer.log('[NewTicketViewmodel] Error picking gallery image: $e',
  //         name: 'NewTicketViewmodel');
  //     imageCaptureError = S.current.imageCaptureError;
  //     notifyListeners();
  //   }
  // }
}
