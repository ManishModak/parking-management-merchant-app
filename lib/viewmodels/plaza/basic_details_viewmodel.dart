import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:merchant_app/viewmodels/plaza/plaza_form_validation.dart'; // Uses updated validation
import 'package:permission_handler/permission_handler.dart';
import 'package:merchant_app/generated/l10n.dart';
import 'package:merchant_app/models/plaza.dart'; // Uses updated model
import 'package:merchant_app/services/core/plaza_service.dart';
import 'package:merchant_app/utils/components/snackbar.dart';
import 'package:merchant_app/utils/exceptions.dart';
import 'package:merchant_app/services/utils/navigation_service.dart';

class BasicDetailsViewModel extends ChangeNotifier {
  final PlazaService _plazaService = PlazaService();
  final PlazaFormValidation _validator =
      PlazaFormValidation(); // Uses updated validation

  // --- Controllers ---
  // *** ADDED plazaIdController ***
  final TextEditingController plazaIdController = TextEditingController();

  // --- End Added ---
  final TextEditingController plazaNameController = TextEditingController();
  final TextEditingController plazaOwnerController =
      TextEditingController(); // Often disabled, shows owner info
  final TextEditingController mobileNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController districtController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController geoLatitudeController = TextEditingController();
  final TextEditingController geoLongitudeController = TextEditingController();
  final TextEditingController noOfParkingSlotsController =
      TextEditingController();
  final TextEditingController capacityBikeController = TextEditingController();
  final TextEditingController capacity3WheelerController =
      TextEditingController();
  final TextEditingController capacity4WheelerController =
      TextEditingController();
  final TextEditingController capacityBusController = TextEditingController();
  final TextEditingController capacityTruckController = TextEditingController();
  final TextEditingController capacityHeavyMachinaryVehicleController =
      TextEditingController();
  final TextEditingController plazaOpenTimingsController =
      TextEditingController(text: '00:00');
  final TextEditingController plazaClosingTimeController =
      TextEditingController(text: '23:59');
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController plazaOrgIdController = TextEditingController();

  // --- State ---
  Map<String, dynamic> basicDetails = {};
  Map<String, String?> errors = {};
  bool _isFirstTime = true;
  bool _isEditable = true; // Controls if fields are editable
  bool _isLoading = false;
  String? _createdPlazaId; // Stores the ID *after* successful creation

  // --- Getters ---
  bool get isFirstTime => _isFirstTime;

  bool get isEditable => _isEditable;

  bool get isLoading => _isLoading;

  // Expose the ID that was *created* or being *modified* (null during initial creation)
  String? get plazaId => _createdPlazaId;

  BasicDetailsViewModel() {
    _initializeMap();
    _addControllerListeners();
    developer.log(
        '[BasicDetailsViewModel] Initialized. isEditable: $_isEditable, isFirstTime: $_isFirstTime',
        name: 'BasicDetailsViewModel');
  }

  void _initializeMap() {
    basicDetails = {
      // *** ADDED plazaId map entry ***
      'plazaId': null, // For user input during creation
      // --- End Added ---
      'plazaName': null,
      'plazaOwner': null, // Usually set by setOwnerDetails
      'plazaOwnerId': null, // Usually set by setOwnerDetails
      'mobileNumber': null,
      'email': null,
      'address': null,
      'city': null,
      'district': null,
      'state': null,
      'pincode': null,
      'geoLatitude': null,
      'geoLongitude': null,
      'noOfParkingSlots': null,
      'capacityBike': null,
      'capacity3Wheeler': null,
      'capacity4Wheeler': null,
      'capacityBus': null,
      'capacityTruck': null,
      'capacityHeavyMachinaryVehicle': null,
      'plazaOpenTimings': plazaOpenTimingsController.text, // Default
      'plazaClosingTime': plazaClosingTimeController.text, // Default
      'plazaCategory': null,
      'plazaSubCategory': null,
      'structureType': null,
      'plazaStatus': Plaza.validPlazaStatuses.firstWhere(
          (s) => s.toLowerCase() == 'active',
          orElse: () => Plaza.validPlazaStatuses.first), // Default
      'priceCategory': null,
      'freeParking': false, // Default
      'isDeleted': false, // Default
      'companyName': null,
      'companyType': Plaza.validCompanyTypes.first, // Default
      'plazaOrgId': null,
    };
  }

  void _addControllerListeners() {
    void setupListener(TextEditingController controller, String key) {
      controller.addListener(() {
        final currentValue = basicDetails[key];
        final newValue = controller.text;
        if (currentValue != newValue) {
          basicDetails[key] = newValue;
          // Auto-clear error for the field when user types
          if (errors.containsKey(key)) {
            errors.remove(key);
            // Clear general error only if no other specific field errors remain
            if (!errors.keys.any((k) => k != 'general' && errors[k] != null)) {
              errors.remove('general');
            }
            notifyListeners();
          }
        }
      });
    }

    // *** ADDED listener for plazaIdController ***
    setupListener(plazaIdController, 'plazaId');
    // --- End Added ---
    setupListener(plazaNameController, 'plazaName');
    setupListener(mobileNumberController, 'mobileNumber');
    setupListener(emailController, 'email');
    setupListener(addressController, 'address');
    setupListener(cityController, 'city');
    setupListener(districtController, 'district');
    setupListener(stateController, 'state');
    setupListener(pincodeController, 'pincode');
    setupListener(geoLatitudeController, 'geoLatitude');
    setupListener(geoLongitudeController, 'geoLongitude');
    setupListener(noOfParkingSlotsController, 'noOfParkingSlots');
    setupListener(capacityBikeController, 'capacityBike');
    setupListener(capacity3WheelerController, 'capacity3Wheeler');
    setupListener(capacity4WheelerController, 'capacity4Wheeler');
    setupListener(capacityBusController, 'capacityBus');
    setupListener(capacityTruckController, 'capacityTruck');
    setupListener(capacityHeavyMachinaryVehicleController,
        'capacityHeavyMachinaryVehicle');
    setupListener(plazaOpenTimingsController, 'plazaOpenTimings');
    setupListener(plazaClosingTimeController, 'plazaClosingTime');
    setupListener(companyNameController, 'companyName');
    setupListener(plazaOrgIdController, 'plazaOrgId');
    // Note: plazaOwnerController listener is not needed as it's usually set programmatically
  }

  // --- Update Methods for Dropdowns, Booleans, Time (Unchanged) ---
  void updateDropdownValue(String key, String? value) {
    if (basicDetails[key] != value) {
      basicDetails[key] = value;
      clearError(key);
      notifyListeners();
    }
  }

  void updateBooleanValue(String key, bool value) {
    if (basicDetails[key] != value) {
      basicDetails[key] = value;
      clearError(key);
      notifyListeners();
    }
  }

  void updateTimeValue(String key, String value) {
    if (key == 'plazaOpenTimings') {
      if (plazaOpenTimingsController.text != value)
        plazaOpenTimingsController.text = value;
    } else if (key == 'plazaClosingTime') {
      if (plazaClosingTimeController.text != value)
        plazaClosingTimeController.text = value;
    }
    if (basicDetails[key] != value) {
      basicDetails[key] = value;
      clearError(key);
      notifyListeners();
    }
  }

  // --- Owner Details ---
  void setOwnerDetails({required String ownerId, String? ownerName}) {
    basicDetails['plazaOwnerId'] = ownerId;
    basicDetails['plazaOwner'] = ownerName;
    // Update display controller if needed
    if (plazaOwnerController.text != (ownerName ?? '')) {
      plazaOwnerController.text = ownerName ?? '';
    }
    notifyListeners();
  }

  // --- Error Handling ---
  void clearError(String key) {
    if (errors.containsKey(key)) {
      errors.remove(key);
      if (!errors.keys.any((k) => k != 'general' && errors[k] != null)) {
        errors.remove('general');
      }
      notifyListeners();
    }
  }

  // --- Edit Mode Control ---
  void toggleEditable() {
    // This might be less relevant in pure registration, but kept for consistency
    if (_isFirstTime || _isLoading) return;
    _isEditable = !_isEditable;
    notifyListeners();
  }

  void resetToEditableState() {
    // Used when starting fresh or resetting
    _isEditable = true;
    _isFirstTime = true; // Allow edits on reset
    errors.clear();
    // No notify here, usually called before building UI
  }

  // --- Populate for Modification (Less relevant for pure creation, but good practice) ---
  void populateForModification(Plaza existingPlazaData) {
    _createdPlazaId = existingPlazaData.plazaId; // Store the ID being modified

    // *** ADDED: Populate plazaIdController ***
    plazaIdController.text =
        existingPlazaData.plazaId ?? ''; // Populate input field
    // --- End Added ---
    plazaNameController.text = existingPlazaData.plazaName!;
    mobileNumberController.text = existingPlazaData.mobileNumber!;
    emailController.text = existingPlazaData.email!;
    addressController.text = existingPlazaData.address!;
    cityController.text = existingPlazaData.city!;
    districtController.text = existingPlazaData.district!;
    stateController.text = existingPlazaData.state!;
    pincodeController.text = existingPlazaData.pincode!;
    geoLatitudeController.text = existingPlazaData.geoLatitude.toString();
    geoLongitudeController.text = existingPlazaData.geoLongitude.toString();
    noOfParkingSlotsController.text =
        existingPlazaData.noOfParkingSlots.toString();
    capacityBikeController.text = existingPlazaData.capacityBike.toString();
    capacity3WheelerController.text =
        existingPlazaData.capacity3Wheeler.toString();
    capacity4WheelerController.text =
        existingPlazaData.capacity4Wheeler.toString();
    capacityBusController.text = existingPlazaData.capacityBus.toString();
    capacityTruckController.text = existingPlazaData.capacityTruck.toString();
    capacityHeavyMachinaryVehicleController.text =
        existingPlazaData.capacityHeavyMachinaryVehicle.toString();
    plazaOpenTimingsController.text = existingPlazaData.plazaOpenTimings!;
    plazaClosingTimeController.text = existingPlazaData.plazaClosingTime!;
    companyNameController.text = existingPlazaData.companyName!;
    plazaOrgIdController.text = existingPlazaData.plazaOrgId!;

    // Set owner details in map and controller
    setOwnerDetails(
        ownerId: existingPlazaData.plazaOwnerId!,
        ownerName: existingPlazaData.plazaOwner);

    // Populate map details (dropdowns, booleans etc.)
    basicDetails['plazaId'] = existingPlazaData.plazaId; // Also update map
    basicDetails['companyName'] = existingPlazaData.companyName;
    basicDetails['companyType'] = existingPlazaData.companyType;
    basicDetails['plazaOrgId'] = existingPlazaData.plazaOrgId;
    basicDetails['plazaCategory'] = existingPlazaData.plazaCategory;
    basicDetails['plazaSubCategory'] = existingPlazaData.plazaSubCategory;
    basicDetails['structureType'] = existingPlazaData.structureType;
    basicDetails['plazaStatus'] = existingPlazaData.plazaStatus;
    basicDetails['priceCategory'] = existingPlazaData.priceCategory;
    basicDetails['freeParking'] = existingPlazaData.freeParking;
    basicDetails['isDeleted'] = existingPlazaData.isDeleted;

    // Set state after populating
    _isEditable = false; // Start in non-editable mode for modification view
    _isFirstTime = false;
    _isLoading = false;
    errors.clear();
    // Don't notify here, assumes this is called during init before build
  }

  // --- Validation ---
  bool _validateForm(BuildContext context) {
    errors.clear();
    _syncMapWithControllers(); // Ensure map has latest controller values BEFORE validation
    // Validation uses the updated PlazaFormValidation
    final String? validationErrorSummary =
        _validator.validateBasicDetails(context, basicDetails, errors);

    if (validationErrorSummary != null) {
      if (!errors.containsKey('general') && errors.isNotEmpty) {
        errors['general'] = S.of(context).validationGeneralError;
      } else if (errors.isEmpty) {
        errors['general'] = validationErrorSummary;
      }
      if (context.mounted) {
        AppSnackbar.showSnackbar(
          context: context,
          message: errors['general'] ?? validationErrorSummary,
          type: SnackbarType.error,
        );
      }
      notifyListeners(); // Update UI to show errors
      return false;
    }
    return true;
  }

  void _syncMapWithControllers() {
    // Sync all text controllers to the basicDetails map
    basicDetails['plazaId'] = plazaIdController.text; // *** ADDED ***
    basicDetails['plazaName'] = plazaNameController.text;
    basicDetails['mobileNumber'] = mobileNumberController.text;
    basicDetails['email'] = emailController.text;
    basicDetails['address'] = addressController.text;
    basicDetails['city'] = cityController.text;
    basicDetails['district'] = districtController.text;
    basicDetails['state'] = stateController.text;
    basicDetails['pincode'] = pincodeController.text;
    basicDetails['geoLatitude'] = geoLatitudeController.text;
    basicDetails['geoLongitude'] = geoLongitudeController.text;
    basicDetails['noOfParkingSlots'] = noOfParkingSlotsController.text;
    basicDetails['capacityBike'] = capacityBikeController.text;
    basicDetails['capacity3Wheeler'] = capacity3WheelerController.text;
    basicDetails['capacity4Wheeler'] = capacity4WheelerController.text;
    basicDetails['capacityBus'] = capacityBusController.text;
    basicDetails['capacityTruck'] = capacityTruckController.text;
    basicDetails['capacityHeavyMachinaryVehicle'] =
        capacityHeavyMachinaryVehicleController.text;
    basicDetails['plazaOpenTimings'] = plazaOpenTimingsController.text;
    basicDetails['plazaClosingTime'] = plazaClosingTimeController.text;
    basicDetails['companyName'] = companyNameController.text;
    basicDetails['plazaOrgId'] = plazaOrgIdController.text;
    // Note: plazaOwnerController might not need syncing if always disabled/programmatically set
    // basicDetails['plazaOwner'] = plazaOwnerController.text;
  }

  // --- Save Logic ---
  Future<bool> saveBasicDetails(BuildContext context) async {
    if (!_validateForm(context)) {
      _setLoading(false);
      return false;
    }

    if (basicDetails['plazaOwnerId'] == null ||
        basicDetails['plazaOwnerId'].toString().isEmpty) {
      errors['general'] = S.of(context).messageErrorUserDataNotFound;
      _setLoading(false);
      notifyListeners();
      return false;
    }

    _setLoading(true);

    try {
      // Prepare payload AFTER validation and owner check
      // _syncMapWithControllers(); // Ensure map is up-to-date (already called in _validateForm)
      final Map<String, dynamic> payload = _preparePayload();

      // *** CRITICAL CHANGE: Create Plaza object including plazaId from the map ***
      final Plaza plaza = Plaza(
        // Use the user-provided ID from the map for creation
        plazaId: payload['plazaId']?.toString(),
        // Get ID from payload
        plazaName: payload['plazaName'],
        plazaOwner: basicDetails['plazaOwner'],
        // Get owner name from map state
        plazaOwnerId: payload['plazaOwnerId'],
        companyName: payload['companyName'],
        companyType: payload['companyType'],
        plazaOrgId: payload['plazaOrgId'],
        mobileNumber: payload['mobileNumber']!.toString(),
        address: payload['address'],
        email: payload['email'],
        city: payload['city'],
        district: payload['district'],
        state: payload['state'],
        pincode: payload['pincode']!.toString(),
        geoLatitude: (payload['geoLatitude'] as double),
        geoLongitude: (payload['geoLongitude'] as double),
        plazaCategory: payload['plazaCategory'],
        plazaSubCategory: payload['plazaSubCategory'],
        structureType: payload['structureType'],
        plazaStatus: payload['plazaStatus'],
        priceCategory: payload['priceCategory'],
        freeParking: (payload['freeParking'] as bool),
        noOfParkingSlots: (payload['noOfParkingSlots'] as int?) ?? 0,
        capacityBike: (payload['capacityBike'] as int?) ?? 0,
        capacity3Wheeler: (payload['capacity3Wheeler'] as int?) ?? 0,
        capacity4Wheeler: (payload['capacity4Wheeler'] as int?) ?? 0,
        capacityBus: (payload['capacityBus'] as int?) ?? 0,
        capacityTruck: (payload['capacityTruck'] as int?) ?? 0,
        capacityHeavyMachinaryVehicle:
            (payload['capacityHeavyMachinaryVehicle'] as int?) ?? 0,
        plazaOpenTimings: payload['plazaOpenTimings'],
        plazaClosingTime: payload['plazaClosingTime'],
        isDeleted: payload['isDeleted'] as bool? ?? false,
      );

      bool success = false;
      // Determine if it's an update or create based on whether _createdPlazaId is set
      bool isUpdate = _createdPlazaId != null && _createdPlazaId!.isNotEmpty;

      if (!isUpdate) {
        developer.log(
            '[BasicDetailsViewModel] Attempting to add new plaza with provided ID: ${plaza.plazaId}',
            name: 'BasicDetailsViewModel.saveBasicDetails');
        // Call addPlaza - backend now expects plazaId in the body
        String createdIdResponse = await _plazaService.addPlaza(plaza);
        // The backend *should* ideally still return the ID it accepted/used
        if (createdIdResponse.isNotEmpty &&
            createdIdResponse == plaza.plazaId) {
          _createdPlazaId = createdIdResponse; // Store the successfully used ID
          success = true;
          developer.log(
              '[BasicDetailsViewModel] Plaza added successfully with ID: $_createdPlazaId',
              name: 'BasicDetailsViewModel.saveBasicDetails');
        } else {
          developer.log(
              '[BasicDetailsViewModel] Add plaza failed: Service returned empty or mismatched ID. Expected: ${plaza.plazaId}, Got: $createdIdResponse',
              name: 'BasicDetailsViewModel.saveBasicDetails',
              level: 1000);
          // Handle potential mismatch or empty return even if status was 201
          throw PlazaException(
              "Failed to create plaza: Service response inconsistent. Expected ID ${plaza.plazaId}, received ${createdIdResponse.isEmpty ? 'nothing' : createdIdResponse}.");
        }
      } else {
        // Update logic remains the same, using _createdPlazaId for the URL param
        developer.log(
            '[BasicDetailsViewModel] Attempting to update plaza ID: $_createdPlazaId',
            name: 'BasicDetailsViewModel.saveBasicDetails');
        // Ensure the plaza object being sent has the correct _createdPlazaId
        final plazaForUpdate = plaza.copyWith(plazaId: _createdPlazaId);
        success =
            await _plazaService.updatePlaza(plazaForUpdate, _createdPlazaId!);
        if (!success) {
          developer.log(
              '[BasicDetailsViewModel] Update plaza failed: Service returned false.',
              name: 'BasicDetailsViewModel.saveBasicDetails',
              level: 1000);
          throw PlazaException(
              "Plaza update failed: Service indicated failure.");
        }
        developer.log('[BasicDetailsViewModel] Plaza updated successfully.',
            name: 'BasicDetailsViewModel.saveBasicDetails');
      }

      // If successful, transition state
      _isFirstTime = false;
      _isEditable = false; // Make non-editable after save
      errors.clear();
      _setLoading(false);
      notifyListeners();
      return true;
    } on HttpException catch (e) {
      developer.log(
          '[BasicDetailsViewModel] HttpException saving details: ${e.message} (Code: ${e.statusCode})',
          error: e,
          name: 'BasicDetailsViewModel.saveBasicDetails');
      _handleServiceError(context, e, S.of(context).apiErrorGeneric);
      _setLoading(false);
      return false;
    } on PlazaException catch (e) {
      developer.log(
          '[BasicDetailsViewModel] PlazaException saving details: ${e.message}',
          error: e,
          name: 'BasicDetailsViewModel.saveBasicDetails');
      _handleServiceError(context, e, S.of(context).messageErrorSavingPlaza);
      _setLoading(false);
      return false;
    } on RequestTimeoutException catch (e) {
      developer.log(
          '[BasicDetailsViewModel] RequestTimeoutException saving details',
          error: e,
          name: 'BasicDetailsViewModel.saveBasicDetails');
      _handleServiceError(context, e, S.of(context).errorTimeout);
      _setLoading(false);
      return false;
    } on NoInternetException catch (e) {
      developer.log(
          '[BasicDetailsViewModel] NoInternetException saving details',
          error: e,
          name: 'BasicDetailsViewModel.saveBasicDetails');
      _handleServiceError(context, e, S.of(context).errorNoInternet);
      _setLoading(false);
      return false;
    } on ServerConnectionException catch (e) {
      developer.log(
          '[BasicDetailsViewModel] ServerConnectionException saving details',
          error: e,
          name: 'BasicDetailsViewModel.saveBasicDetails');
      _handleServiceError(context, e, S.of(context).errorServerConnection);
      _setLoading(false);
      return false;
    } catch (e, stackTrace) {
      developer.log(
          '[BasicDetailsViewModel] UNEXPECTED Error saving basic details',
          error: e,
          stackTrace: stackTrace,
          name: 'BasicDetailsViewModel.saveBasicDetails',
          level: 1200);
      _handleGenericError(context, e);
      _setLoading(false);
      return false;
    }
  }

  Map<String, dynamic> _preparePayload() {
    // Start with a fresh copy of basicDetails which should be synced
    final Map<String, dynamic> payload = Map.from(basicDetails);

    // Convert numeric strings -> numbers
    final numericKeysInt = [
      'mobileNumber',
      'pincode',
      'noOfParkingSlots',
      'capacityBike',
      'capacity3Wheeler',
      'capacity4Wheeler',
      'capacityBus',
      'capacityTruck',
      'capacityHeavyMachinaryVehicle'
    ];
    for (var key in numericKeysInt) {
      final valueStr = payload[key]?.toString().trim();
      payload[key] = (valueStr != null && valueStr.isNotEmpty)
          ? int.tryParse(valueStr)
          : null; // Allow nulls if optional/validated
    }
    final numericKeysDouble = ['geoLatitude', 'geoLongitude'];
    for (var key in numericKeysDouble) {
      final valueStr = payload[key]?.toString().trim();
      payload[key] = (valueStr != null && valueStr.isNotEmpty)
          ? double.tryParse(valueStr)
          : null; // Allow nulls if optional/validated
    }

    // Ensure booleans have defaults
    payload['freeParking'] ??= false;
    payload['isDeleted'] ??= false;

    // Trim relevant string fields
    final stringKeys = [
      'plazaId', // *** ADDED ***
      'plazaName', 'companyName', 'plazaOrgId', 'email', 'address', 'city',
      'district', 'state', 'plazaOpenTimings', 'plazaClosingTime'
      // Dropdown values usually don't need trimming
    ];
    for (var key in stringKeys) {
      if (payload[key] is String) {
        payload[key] = payload[key].toString().trim();
      }
    }

    // Ensure essential IDs are present (ownerId is critical)
    payload['plazaOwnerId'] = basicDetails['plazaOwnerId'];
    // Ensure plazaId from user input is included (needed for backend create)
    payload['plazaId'] = basicDetails['plazaId']; // *** ENSURED ***

    developer.log('[BasicDetailsViewModel] Prepared payload: $payload',
        name: 'BasicDetailsViewModel._preparePayload');
    return payload;
  }

  // --- Location Methods (Unchanged, but ensure they update map) ---
  Future<void> getCurrentLocation(BuildContext context) async {
    final currentContext =
        NavigationService.navigatorKey.currentContext ?? context;
    if (!currentContext.mounted) return;
    final scaffoldMessenger = ScaffoldMessenger.of(currentContext);
    final strings = S.of(currentContext);
    _setLoading(true);
    try {
      // ... (Permission checks remain the same) ...
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (currentContext.mounted)
          _showLocationServiceDisabledDialog(currentContext);
        _setLoading(false);
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showPermissionDeniedSnackbar(
              scaffoldMessenger, strings.locationPermissionDenied);
          _setLoading(false);
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        if (currentContext.mounted)
          _showPermissionDeniedForeverDialog(currentContext);
        _setLoading(false);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      // Update Controllers
      geoLatitudeController.text = position.latitude.toStringAsFixed(6);
      geoLongitudeController.text = position.longitude.toStringAsFixed(6);
      // *** Update Map State Directly ***
      basicDetails['geoLatitude'] = geoLatitudeController.text;
      basicDetails['geoLongitude'] = geoLongitudeController.text;
      clearError('geoLatitude');
      clearError('geoLongitude');

      if (currentContext.mounted) {
        await _getAddressFromLatLng(
            currentContext, position.latitude, position.longitude);
      }
    } catch (e, stackTrace) {
      developer.log(
          '[BasicDetailsViewModel] Error getting location/address: $e',
          error: e,
          stackTrace: stackTrace,
          name: 'BasicDetailsViewModel.getCurrentLocation',
          level: 1000);
      if (context.mounted)
        _showPermissionDeniedSnackbar(
            scaffoldMessenger, strings.errorFetchingLocation);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _getAddressFromLatLng(
      BuildContext context, double latitude, double longitude) async {
    if (!context.mounted) return;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final strings = S.of(context);
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty && context.mounted) {
        Placemark place = placemarks[0];
        final addressLine = [place.name, place.thoroughfare, place.subLocality]
            .where((s) => s != null && s.isNotEmpty)
            .join(', ');
        // Update Controllers
        addressController.text = addressLine;
        cityController.text = place.locality ?? '';
        districtController.text = place.subAdministrativeArea ?? '';
        stateController.text = place.administrativeArea ?? '';
        pincodeController.text = place.postalCode ?? '';
        // *** Update Map State Directly ***
        basicDetails['address'] = addressController.text;
        basicDetails['city'] = cityController.text;
        basicDetails['district'] = districtController.text;
        basicDetails['state'] = stateController.text;
        basicDetails['pincode'] = pincodeController.text;
        clearError('address');
        clearError('city');
        clearError('district');
        clearError('state');
        clearError('pincode');
      } else if (context.mounted) {
        _showPermissionDeniedSnackbar(
            scaffoldMessenger, strings.errorFetchingAddress);
      }
    } catch (e, stackTrace) {
      developer.log('[BasicDetailsViewModel] Error during geocoding: $e',
          error: e,
          stackTrace: stackTrace,
          name: 'BasicDetailsViewModel._getAddressFromLatLng',
          level: 1000);
      if (context.mounted)
        _showPermissionDeniedSnackbar(
            scaffoldMessenger, strings.errorFetchingAddress);
    }
  }

  // --- Dialog/Snackbar Helpers (Unchanged) ---
  void _showLocationServiceDisabledDialog(BuildContext context) {
    /* ... unchanged ... */
    if (!context.mounted) return;
    final strings = S.of(context);
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(strings.locationServicesDisabledTitle),
        content: Text(strings.locationServicesDisabledMessage),
        actions: <Widget>[
          TextButton(
            child: Text(strings.buttonCancel),
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          TextButton(
            child: Text(strings.buttonSettings),
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await Geolocator.openLocationSettings();
            },
          ),
        ],
      ),
    );
  }

  void _showPermissionDeniedForeverDialog(BuildContext context) {
    /* ... unchanged ... */
    if (!context.mounted) return;
    final strings = S.of(context);
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(strings.locationPermissionDeniedTitle),
        content: Text(strings.locationPermissionDeniedMessage),
        actions: <Widget>[
          TextButton(
            child: Text(strings.buttonCancel),
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          TextButton(
            child: Text(strings.buttonSettings),
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await openAppSettings(); // From permission_handler
            },
          ),
        ],
      ),
    );
  }

  void _showPermissionDeniedSnackbar(
      ScaffoldMessengerState messenger, String message) {
    /* ... unchanged ... */
    try {
      messenger.showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.orangeAccent,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating, // Or fixed based on design
        ),
      );
    } catch (e) {
      developer.log('[BasicDetailsViewModel] Error showing snackbar: $e',
          name: '_showPermissionDeniedSnackbar', level: 900);
    }
  }

  // --- Error Handling and State (Unchanged) ---
  void _handleServiceError(
      BuildContext context, Exception e, String defaultMessage) {
    /* ... unchanged ... */
    String errorMessage = defaultMessage;
    if (e is HttpException) {
      errorMessage = e.serverMessage ?? e.message;
    } else if (e is ServiceException) {
      errorMessage = e.serverMessage ?? e.message;
    } else if (e is PlazaException) {
      errorMessage = e.serverMessage ?? e.message;
    } else if (e is RequestTimeoutException) {
      errorMessage = S.of(context).errorTimeout;
    } else if (e is NoInternetException) {
      errorMessage = S.of(context).errorNoInternet;
    } else if (e is ServerConnectionException) {
      errorMessage = S.of(context).errorServerConnection;
    } else {
      errorMessage = S.of(context).errorUnexpected;
    }

    errors['general'] = errorMessage;
    if (context.mounted) {
      AppSnackbar.showSnackbar(
          context: context, message: errorMessage, type: SnackbarType.error);
    }
    notifyListeners(); // Ensure UI updates with the error
  }

  void _handleGenericError(BuildContext context, dynamic e) {
    /* ... unchanged ... */
    final message = S.of(context).errorUnexpected;
    errors['general'] = message;
    if (context.mounted) {
      AppSnackbar.showSnackbar(
          context: context, message: message, type: SnackbarType.error);
    }
    notifyListeners();
  }

  void _setLoading(bool value) {
    /* ... unchanged ... */
    if (_isLoading != value) {
      _isLoading = value;
      if (_isLoading && errors.containsKey('general')) {
        errors.remove('general');
      }
      notifyListeners();
    }
  }

  // --- Reset ---
  void clearFieldsAndNotify() {
    // *** ADDED: Clear plazaIdController ***
    plazaIdController.clear();
    // --- End Added ---
    plazaNameController.clear();
    plazaOwnerController.clear();
    mobileNumberController.clear();
    emailController.clear();
    addressController.clear();
    cityController.clear();
    districtController.clear();
    stateController.clear();
    pincodeController.clear();
    geoLatitudeController.clear();
    geoLongitudeController.clear();
    noOfParkingSlotsController.clear();
    capacityBikeController.clear();
    capacity3WheelerController.clear();
    capacity4WheelerController.clear();
    capacityBusController.clear();
    capacityTruckController.clear();
    capacityHeavyMachinaryVehicleController.clear();
    plazaOpenTimingsController.text = '00:00';
    plazaClosingTimeController.text = '23:59';
    companyNameController.clear();
    plazaOrgIdController.clear();

    // Preserve owner details
    final ownerId = basicDetails['plazaOwnerId'];
    final ownerName = basicDetails['plazaOwner'];

    _initializeMap(); // Re-initialize map to defaults (includes plazaId: null)

    // Restore owner details
    basicDetails['plazaOwnerId'] = ownerId;
    basicDetails['plazaOwner'] = ownerName;
    if (plazaOwnerController.text != (ownerName ?? '')) {
      plazaOwnerController.text = ownerName ?? '';
    }

    // Reset state variables
    errors.clear();
    _createdPlazaId = null; // Reset the stored ID
    _isFirstTime = true;
    _isEditable = true;
    _isLoading = false;

    notifyListeners();
  }

  // --- Dispose ---
  @override
  void dispose() {
    // *** ADDED: Dispose plazaIdController ***
    plazaIdController.dispose();
    // --- End Added ---
    plazaNameController.dispose();
    plazaOwnerController.dispose();
    mobileNumberController.dispose();
    emailController.dispose();
    addressController.dispose();
    cityController.dispose();
    districtController.dispose();
    stateController.dispose();
    pincodeController.dispose();
    geoLatitudeController.dispose();
    geoLongitudeController.dispose();
    noOfParkingSlotsController.dispose();
    capacityBikeController.dispose();
    capacity3WheelerController.dispose();
    capacity4WheelerController.dispose();
    capacityBusController.dispose();
    capacityTruckController.dispose();
    capacityHeavyMachinaryVehicleController.dispose();
    plazaOpenTimingsController.dispose();
    plazaClosingTimeController.dispose();
    companyNameController.dispose();
    plazaOrgIdController.dispose();
    super.dispose();
  }
}
