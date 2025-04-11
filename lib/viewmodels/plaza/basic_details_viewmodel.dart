import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:merchant_app/viewmodels/plaza/plaza_form_validation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:merchant_app/generated/l10n.dart';
import 'package:merchant_app/models/plaza.dart';
import 'package:merchant_app/services/core/plaza_service.dart';
import 'package:merchant_app/utils/components/snackbar.dart';
import 'package:merchant_app/utils/exceptions.dart';
import 'package:merchant_app/services/utils/navigation_service.dart';

class BasicDetailsViewModel extends ChangeNotifier {
  final PlazaService _plazaService = PlazaService();
  final PlazaFormValidation _validator = PlazaFormValidation();

  final TextEditingController plazaNameController = TextEditingController();
  final TextEditingController plazaOwnerController = TextEditingController();
  final TextEditingController plazaOperatorNameController =
      TextEditingController();
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

  Map<String, dynamic> basicDetails = {};
  Map<String, String?> errors = {};
  bool _isFirstTime = true;
  bool _isEditable = true;
  bool _isLoading = false;
  String? _plazaId;

  bool get isFirstTime => _isFirstTime;

  bool get isEditable => _isEditable;

  bool get isLoading => _isLoading;

  String? get plazaId => _plazaId;

  BasicDetailsViewModel() {
    _initializeMap();
    _addControllerListeners();
    developer.log(
        '[BasicDetailsViewModel] Initialized. isEditable: $_isEditable, isFirstTime: $_isFirstTime',
        name: 'BasicDetailsViewModel');
  }

  void _initializeMap() {
    basicDetails = {
      'plazaName': null,
      'plazaOwner': null,
      'plazaOwnerId': null,
      'plazaOperatorName': null,
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
      'plazaOpenTimings': plazaOpenTimingsController.text,
      'plazaClosingTime': plazaClosingTimeController.text,
      'plazaCategory': null,
      'plazaSubCategory': null,
      'structureType': null,
      'plazaStatus': Plaza.validPlazaStatuses.firstWhere(
          (s) => s.toLowerCase() == 'active',
          orElse: () => Plaza.validPlazaStatuses.first),
      'priceCategory': null,
      'freeParking': false,
      'isDeleted': false,
    };
  }

  void _addControllerListeners() {
    void setupListener(TextEditingController controller, String key) {
      controller.addListener(() {
        final currentValue = basicDetails[key];
        final newValue = controller.text;
        if (currentValue != newValue) {
          basicDetails[key] = newValue;
          if (errors.containsKey(key)) {
            errors.remove(key);
            if (!errors.keys.any((k) => k != 'general' && errors[k] != null)) {
              errors.remove('general');
            }
            notifyListeners();
          }
        }
      });
    }

    setupListener(plazaNameController, 'plazaName');
    setupListener(plazaOperatorNameController, 'plazaOperatorName');
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
  }

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
      if (plazaOpenTimingsController.text != value) {
        plazaOpenTimingsController.text = value;
      }
    } else if (key == 'plazaClosingTime') {
      if (plazaClosingTimeController.text != value) {
        plazaClosingTimeController.text = value;
      }
    }
    if (basicDetails[key] != value) {
      basicDetails[key] = value;
      clearError(key);
      notifyListeners();
    }
  }

  void setOwnerDetails({required String ownerId, String? ownerName}) {
    basicDetails['plazaOwnerId'] = ownerId;
    basicDetails['plazaOwner'] = ownerName;
    notifyListeners();
  }

  void clearError(String key) {
    if (errors.containsKey(key)) {
      errors.remove(key);
      if (!errors.keys.any((k) => k != 'general' && errors[k] != null)) {
        errors.remove('general');
      }
      notifyListeners();
    }
  }

  void toggleEditable() {
    if (_isFirstTime || _isLoading) return;
    _isEditable = !_isEditable;
    notifyListeners();
  }

  void resetToEditableState() {
    _isEditable = true;
    _isFirstTime = true;
    errors.clear();
  }

  void populateForModification(Plaza existingPlazaData) {
    _plazaId = existingPlazaData.plazaId;

    plazaNameController.text = existingPlazaData.plazaName;
    plazaOperatorNameController.text = existingPlazaData.plazaOperatorName;
    mobileNumberController.text = existingPlazaData.mobileNumber.toString();
    emailController.text = existingPlazaData.email;
    addressController.text = existingPlazaData.address;
    cityController.text = existingPlazaData.city;
    districtController.text = existingPlazaData.district;
    stateController.text = existingPlazaData.state;
    pincodeController.text = existingPlazaData.pincode.toString();
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
    plazaOpenTimingsController.text = existingPlazaData.plazaOpenTimings;
    plazaClosingTimeController.text = existingPlazaData.plazaClosingTime;

    basicDetails['plazaOwnerId'] = existingPlazaData.plazaOwnerId;
    basicDetails['plazaOwner'] = existingPlazaData.plazaOwner;
    basicDetails['plazaCategory'] = existingPlazaData.plazaCategory;
    basicDetails['plazaSubCategory'] = existingPlazaData.plazaSubCategory;
    basicDetails['structureType'] = existingPlazaData.structureType;
    basicDetails['plazaStatus'] = existingPlazaData.plazaStatus;
    basicDetails['priceCategory'] = existingPlazaData.priceCategory;
    basicDetails['freeParking'] = existingPlazaData.freeParking;
    basicDetails['isDeleted'] = existingPlazaData.isDeleted;

    _isEditable = false;
    _isFirstTime = false;
    _isLoading = false;
    errors.clear();
  }

  bool _validateForm(BuildContext context) {
    errors.clear();
    _syncMapWithControllers();
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
      notifyListeners();
      return false;
    }
    return true;
  }

  void _syncMapWithControllers() {
    basicDetails['plazaName'] = plazaNameController.text;
    basicDetails['plazaOperatorName'] = plazaOperatorNameController.text;
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
  }

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
      final Map<String, dynamic> payload = _preparePayload();
      final Plaza plaza = Plaza(
        plazaId: _plazaId,
        plazaName: payload['plazaName'],
        plazaOwner: basicDetails['plazaOwner'],
        plazaOwnerId: payload['plazaOwnerId'],
        plazaOperatorName: payload['plazaOperatorName'],
        mobileNumber: payload['mobileNumber']!.toString(),
        address: payload['address'],
        email: payload['email'],
        city: payload['city'],
        district: payload['district'],
        state: payload['state'],
        pincode: payload['pincode']!.toString(),
        geoLatitude: (payload['geoLatitude'] as double?)!,
        geoLongitude: (payload['geoLongitude'] as double?)!,
        plazaCategory: payload['plazaCategory'],
        plazaSubCategory: payload['plazaSubCategory'],
        structureType: payload['structureType'],
        plazaStatus: payload['plazaStatus'],
        priceCategory: payload['priceCategory'],
        freeParking: (payload['freeParking'] as bool?)!,
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
      bool isUpdate = _plazaId != null && _plazaId!.isNotEmpty;

      if (!isUpdate) {
        String newPlazaId = await _plazaService.addPlaza(plaza);
        if (newPlazaId.isNotEmpty) {
          _plazaId = newPlazaId;
          success = true;
        } else {
          throw PlazaException(
              "Failed to create plaza: Service did not return a valid ID.");
        }
      } else {
        success = await _plazaService.updatePlaza(plaza, _plazaId!);
        if (!success) {
          throw PlazaException(
              "Plaza update failed: Service indicated failure.");
        }
      }

      _isFirstTime = false;
      _isEditable = false;
      errors.clear();
      _setLoading(false);
      notifyListeners();
      return true;
    } on HttpException catch (e) {
      _handleServiceError(context, e, S.of(context).apiErrorGeneric);
      _setLoading(false);
      return false;
    } on PlazaException catch (e) {
      _handleServiceError(context, e, S.of(context).messageErrorSavingPlaza);
      _setLoading(false);
      return false;
    } on RequestTimeoutException catch (e) {
      _handleServiceError(context, e, S.of(context).errorTimeout);
      _setLoading(false);
      return false;
    } on NoInternetException catch (e) {
      _handleServiceError(context, e, S.of(context).errorNoInternet);
      _setLoading(false);
      return false;
    } on ServerConnectionException catch (e) {
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
    final Map<String, dynamic> payload = Map.from(basicDetails);

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
          : null;
    }

    final numericKeysDouble = ['geoLatitude', 'geoLongitude'];
    for (var key in numericKeysDouble) {
      final valueStr = payload[key]?.toString().trim();
      payload[key] = (valueStr != null && valueStr.isNotEmpty)
          ? double.tryParse(valueStr)
          : null;
    }

    payload['freeParking'] ??= false;
    payload['isDeleted'] ??= false;

    final stringKeys = [
      'plazaName',
      'plazaOperatorName',
      'email',
      'address',
      'city',
      'district',
      'state',
      'plazaOpenTimings',
      'plazaClosingTime'
    ];
    for (var key in stringKeys) {
      if (payload[key] is String) {
        payload[key] = payload[key].toString().trim();
      }
    }
    payload['plazaOwnerId'] = basicDetails['plazaOwnerId'];

    return payload;
  }

  Future<void> getCurrentLocation(BuildContext context) async {
    final currentContext =
        NavigationService.navigatorKey.currentContext ?? context;
    if (!currentContext.mounted) return;

    final scaffoldMessenger = ScaffoldMessenger.of(currentContext);
    final strings = S.of(currentContext);

    _setLoading(true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (currentContext.mounted) {
          _showLocationServiceDisabledDialog(currentContext);
        }
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
        if (currentContext.mounted) {
          _showPermissionDeniedForeverDialog(currentContext);
        }
        _setLoading(false);
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      geoLatitudeController.text = position.latitude.toStringAsFixed(6);
      geoLongitudeController.text = position.longitude.toStringAsFixed(6);

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
      if (context.mounted) {
        _showPermissionDeniedSnackbar(
            scaffoldMessenger, strings.errorFetchingLocation);
      }
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
        final addressLine = [place.street, place.subLocality]
            .where((s) => s != null && s.isNotEmpty)
            .join(', ');
        addressController.text = addressLine;
        cityController.text = place.locality ?? '';
        districtController.text = place.subAdministrativeArea ?? '';
        stateController.text = place.administrativeArea ?? '';
        pincodeController.text = place.postalCode ?? '';

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
      if (context.mounted) {
        _showPermissionDeniedSnackbar(
            scaffoldMessenger, strings.errorFetchingAddress);
      }
    }
  }

  void _showLocationServiceDisabledDialog(BuildContext context) {
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
              await openAppSettings();
            },
          ),
        ],
      ),
    );
  }

  void _showPermissionDeniedSnackbar(
      ScaffoldMessengerState messenger, String message) {
    try {
      messenger.showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.orangeAccent,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      developer.log('[BasicDetailsViewModel] Error showing snackbar: $e',
          name: '_showPermissionDeniedSnackbar', level: 900);
    }
  }

  void _handleServiceError(
      BuildContext context, Exception e, String defaultMessage) {
    String errorMessage = defaultMessage;
    if (e is HttpException) {
      errorMessage = e.serverMessage ?? e.message;
    } else if (e is ServiceException)
      errorMessage = e.serverMessage ?? e.message;
    else if (e is PlazaException)
      errorMessage = e.serverMessage ?? e.message;
    else if (e is RequestTimeoutException)
      errorMessage = S.of(context).errorTimeout;
    else if (e is NoInternetException)
      errorMessage = S.of(context).errorNoInternet;
    else if (e is ServerConnectionException)
      errorMessage = S.of(context).errorServerConnection;
    else
      errorMessage = S.of(context).errorUnexpected;

    errors['general'] = errorMessage;
    if (context.mounted) {
      AppSnackbar.showSnackbar(
          context: context, message: errorMessage, type: SnackbarType.error);
    }
    notifyListeners();
  }

  void _handleGenericError(BuildContext context, dynamic e) {
    final message = S.of(context).errorUnexpected;
    errors['general'] = message;
    if (context.mounted) {
      AppSnackbar.showSnackbar(
          context: context, message: message, type: SnackbarType.error);
    }
    notifyListeners();
  }

  void _setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      if (_isLoading && errors.containsKey('general')) {
        errors.remove('general');
      }
      notifyListeners();
    }
  }

  void clearFieldsAndNotify() {
    plazaNameController.clear();
    plazaOwnerController.clear();
    plazaOperatorNameController.clear();
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

    final ownerId = basicDetails['plazaOwnerId'];
    final ownerName = basicDetails['plazaOwner'];
    _initializeMap();
    basicDetails['plazaOwnerId'] = ownerId;
    basicDetails['plazaOwner'] = ownerName;

    errors.clear();
    _plazaId = null;
    _isFirstTime = true;
    _isEditable = true;
    _isLoading = false;
  }

  @override
  void dispose() {
    plazaNameController.dispose();
    plazaOwnerController.dispose();
    plazaOperatorNameController.dispose();
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
    super.dispose();
  }
}
