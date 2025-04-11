import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:merchant_app/generated/l10n.dart';
import 'package:merchant_app/models/bank.dart';
import 'package:merchant_app/models/lane.dart';
import 'package:merchant_app/models/plaza.dart';
import 'package:merchant_app/services/core/lane_service.dart';
import 'package:merchant_app/services/core/plaza_service.dart';
import 'package:merchant_app/services/payment/bank_service.dart';
import 'package:merchant_app/services/utils/image_service.dart';
import 'package:merchant_app/utils/exceptions.dart';
import 'package:merchant_app/viewmodels/plaza/plaza_form_validation.dart';
import 'package:merchant_app/viewmodels/plaza/restoration_helper.dart';

class PlazaModificationFormState {
  final PlazaFormValidation formValidation = PlazaFormValidation();
  final Map<String, String?> errors = {};
  Map<String, dynamic> basicDetails = {};
  Map<String, dynamic> bankDetails = {};
  List<String> fetchedImages = [];
  List<String> plazaImages = [];
  Map<String, String> imageIds = {};

  bool validateBasicDetails(BuildContext context) {
    errors.clear();
    final errorMessage = formValidation.validateBasicDetails(context, basicDetails, errors);
    developer.log('[PlazaFormState] Validating Basic Details. Result: ${errorMessage == null}, Errors: $errors', name: 'PlazaModify.Validation');
    return errorMessage == null;
  }

  bool validateBankDetails(BuildContext context) {
    errors.clear();
    final errorMessage = formValidation.validateBankDetails(context, bankDetails, errors);
    developer.log('[PlazaFormState] Validating Bank Details. Result: ${errorMessage == null}, Errors: $errors', name: 'PlazaModify.Validation');
    return errorMessage == null;
  }
}


class PlazaModificationViewModel extends ChangeNotifier {
  final PlazaService _plazaService = PlazaService();
  final LaneService _laneService = LaneService();
  final ImageService _imageService = ImageService();
  final BankService _bankService = BankService();

  final PlazaModificationFormState formState = PlazaModificationFormState();

  bool _isLoading = false;
  bool _isSavingLane = false; // Added specific flag for lane operations
  Exception? _error;
  String? _plazaId;
  List<Lane> _lanes = [];
  Lane? _selectedLane;
  bool _isBasicDetailsEditable = false;
  bool _isBankEditable = false;

  // --- Getters ---
  bool get isLoading => _isLoading;
  bool get isSavingLane => _isSavingLane; // Getter for the new flag
  Exception? get error => _error;
  String? get plazaId => _plazaId;
  List<Lane> get lanes => List.unmodifiable(_lanes);
  Lane? get selectedLane => _selectedLane;
  bool get isBasicDetailsEditable => _isBasicDetailsEditable;
  bool get isBankEditable => _isBankEditable;

  // --- Text Editing Controllers ---
  final TextEditingController plazaNameController = TextEditingController();
  final TextEditingController plazaOwnerController = TextEditingController();
  final TextEditingController plazaOwnerIdController = TextEditingController();
  final TextEditingController operatorNameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController districtController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController geoLatitudeController = TextEditingController();
  final TextEditingController geoLongitudeController = TextEditingController();
  final TextEditingController noOfParkingSlotsController = TextEditingController();
  final TextEditingController capacityBikeController = TextEditingController();
  final TextEditingController capacity3WheelerController = TextEditingController();
  final TextEditingController capacity4WheelerController = TextEditingController();
  final TextEditingController capacityBusController = TextEditingController();
  final TextEditingController capacityTruckController = TextEditingController();
  final TextEditingController capacityHeavyMachineryController = TextEditingController();
  final TextEditingController plazaOpenTimingsController = TextEditingController();
  final TextEditingController plazaClosingTimeController = TextEditingController();
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController accountHolderController = TextEditingController();
  final TextEditingController ifscCodeController = TextEditingController();

  PlazaModificationViewModel() {
    developer.log('[PlazaModifyVM] ViewModel created.', name: 'PlazaModify');
    _addListeners();
  }

  // --- Helper Function for Time Formatting ---
  String _formatTimeHHMM(String? timeString) {
    if (timeString == null || timeString.isEmpty) {
      return ''; // Return empty for null or empty input
    }
    // Try to parse HH:mm:ss or HH:mm
    final match = RegExp(r'^(\d{2}):(\d{2})(?::\d{2})?$').firstMatch(timeString);
    if (match != null) {
      final hh = match.group(1);
      final mm = match.group(2);
      return '$hh:$mm'; // Return formatted HH:mm
    }
    // Log unexpected format and return empty or a default
    developer.log('Unexpected time format received: $timeString. Returning empty.', name: 'PlazaModifyVM.TimeFormat');
    // You might want a default like '00:00' instead of empty:
    // return '00:00';
    return ''; // Defaulting to empty if format is wrong
  }

  void _addListeners() {
    // Basic Details Listeners
    plazaNameController.addListener(() => formState.basicDetails['plazaName'] = plazaNameController.text.trim());
    plazaOwnerController.addListener(() => formState.basicDetails['plazaOwner'] = plazaOwnerController.text.trim());
    plazaOwnerIdController.addListener(() => formState.basicDetails['plazaOwnerId'] = plazaOwnerIdController.text.trim());
    operatorNameController.addListener(() => formState.basicDetails['plazaOperatorName'] = operatorNameController.text.trim());
    mobileController.addListener(() => formState.basicDetails['mobileNumber'] = mobileController.text.trim());
    emailController.addListener(() => formState.basicDetails['email'] = emailController.text.trim());
    addressController.addListener(() => formState.basicDetails['address'] = addressController.text.trim());
    cityController.addListener(() => formState.basicDetails['city'] = cityController.text.trim());
    districtController.addListener(() => formState.basicDetails['district'] = districtController.text.trim());
    stateController.addListener(() => formState.basicDetails['state'] = stateController.text.trim());
    pincodeController.addListener(() => formState.basicDetails['pincode'] = pincodeController.text.trim());
    geoLatitudeController.addListener(() => formState.basicDetails['geoLatitude'] = geoLatitudeController.text.trim());
    geoLongitudeController.addListener(() => formState.basicDetails['geoLongitude'] = geoLongitudeController.text.trim());
    noOfParkingSlotsController.addListener(() => formState.basicDetails['noOfParkingSlots'] = noOfParkingSlotsController.text.trim());
    capacityBikeController.addListener(() => formState.basicDetails['capacityBike'] = capacityBikeController.text.trim());
    capacity3WheelerController.addListener(() => formState.basicDetails['capacity3Wheeler'] = capacity3WheelerController.text.trim());
    capacity4WheelerController.addListener(() => formState.basicDetails['capacity4Wheeler'] = capacity4WheelerController.text.trim());
    capacityBusController.addListener(() => formState.basicDetails['capacityBus'] = capacityBusController.text.trim());
    capacityTruckController.addListener(() => formState.basicDetails['capacityTruck'] = capacityTruckController.text.trim());
    capacityHeavyMachineryController.addListener(() => formState.basicDetails['capacityHeavyMachinaryVehicle'] = capacityHeavyMachineryController.text.trim());

    // *** Apply time formatting in listeners ***
    plazaOpenTimingsController.addListener(() {
      formState.basicDetails['plazaOpenTimings'] = _formatTimeHHMM(plazaOpenTimingsController.text.trim());
    });
    plazaClosingTimeController.addListener(() {
      formState.basicDetails['plazaClosingTime'] = _formatTimeHHMM(plazaClosingTimeController.text.trim());
    });

    // Bank Details Listeners
    bankNameController.addListener(() => formState.bankDetails['bankName'] = bankNameController.text.trim());
    accountNumberController.addListener(() => formState.bankDetails['accountNumber'] = accountNumberController.text.trim());
    accountHolderController.addListener(() => formState.bankDetails['accountHolderName'] = accountHolderController.text.trim());
    ifscCodeController.addListener(() => formState.bankDetails['IFSCcode'] = ifscCodeController.text.trim());
  }


  // --- Fetch Methods ---

  Future<void> fetchBasicPlazaDetails(String plazaId) async {
    developer.log('Starting fetchBasicPlazaDetails for plaza: $plazaId', name: 'PlazaModifyVM');
    _setLoading(true);
    _clearError();
    _plazaId = plazaId;

    try {
      final plaza = await _plazaService.getPlazaById(plazaId);
      formState.basicDetails = plaza.toJson(); // Assuming Plaza.toJson exists
      // *** Format time before populating controllers ***
      formState.basicDetails['plazaOpenTimings'] = _formatTimeHHMM(formState.basicDetails['plazaOpenTimings']?.toString());
      formState.basicDetails['plazaClosingTime'] = _formatTimeHHMM(formState.basicDetails['plazaClosingTime']?.toString());
      _populateBasicDetailsControllers(); // Now populates with HH:mm
      developer.log('Fetched and populated basic details.', name: 'PlazaModifyVM');
    } catch (e) {
      developer.log('Error fetching basic plaza details: $e', name: 'PlazaModifyVM', error: e);
      _setError(e is Exception ? e : Exception('Failed to fetch plaza details: $e'));
      formState.basicDetails = {};
      _populateBasicDetailsControllers();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchBankPlazaDetails(String plazaId) async {
    developer.log('Starting fetchBankPlazaDetails for plaza: $plazaId', name: 'PlazaModifyVM');
    _setLoading(true);
    _clearError();
    _plazaId ??= plazaId;

    try {
      final bank = await _fetchBankDetails(plazaId);
      if (bank != null) {
        formState.bankDetails = bank.toJson(); // Initial population

        // *** START: Key Normalization ***
        if (formState.bankDetails.containsKey('ifscCode') &&
            !formState.bankDetails.containsKey('IFSCcode')) {
          formState.bankDetails['IFSCcode'] = formState.bankDetails.remove('ifscCode');
          developer.log('Normalized bankDetails key from ifscCode to IFSCcode', name: 'PlazaModifyVM');
        }
        // *** END: Key Normalization ***

        _populateBankDetailsControllers();
        developer.log('Fetched and populated bank details.', name: 'PlazaModifyVM');
      } else {
        formState.bankDetails = {};
        _clearBankDetailsControllers();
        developer.log('No bank details found (404 handled).', name: 'PlazaModifyVM');
      }
    } catch (e) {
      developer.log('Error fetching bank details: $e', name: 'PlazaModifyVM', error: e);
      _setError(e is Exception ? e : Exception("Failed to fetch bank details: $e"));
      formState.bankDetails = {};
      _clearBankDetailsControllers();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchLanes(String plazaId) async {
    _setLoading(true); // Use general loading for fetches
    _clearError();
    _plazaId ??= plazaId;
    developer.log('Fetching lanes for plazaId: $plazaId', name: 'PlazaModifyVM.LaneOps');
    try {
      _lanes = await _laneService.getLanesByPlazaId(plazaId);
      developer.log('Fetched ${_lanes.length} lanes.', name: 'PlazaModifyVM.LaneOps');
      notifyListeners();
    } catch (e) {
      developer.log('Error fetching lanes: $e', name: 'PlazaModifyVM.LaneOps', error: e);
      _setError(e is Exception ? e : Exception('Error fetching lanes: $e'));
      _lanes = [];
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false); // Use general loading
    }
  }

  Future<void> fetchPlazaImages(String plazaId) async {
    _setLoading(true);
    _clearError();
    _plazaId ??= plazaId;
    developer.log('Fetching images for plaza ID: $plazaId', name: 'PlazaModifyVM.ImageOps');
    try {
      formState.fetchedImages.clear();
      formState.plazaImages.clear();
      formState.imageIds.clear();

      final imageDataList = await _imageService.getImagesByPlazaId(plazaId);
      developer.log('Fetched ${imageDataList.length} image data items for plaza $plazaId', name: 'PlazaModifyVM.ImageOps');
      for (var imageData in imageDataList) {
        final url = imageData['imageUrl'] as String?;
        final id = imageData['imageId'] as String?;
        if (url != null && id != null) {
          formState.fetchedImages.add(url);
          formState.plazaImages.add(url);
          formState.imageIds[url] = id;
        } else {
          developer.log('Skipping image data due to null URL or ID: $imageData', name: 'PlazaModifyVM.ImageOps', level: 900);
        }
      }
      developer.log('Finished fetching images. Total loaded: ${formState.plazaImages.length}', name: 'PlazaModifyVM.ImageOps');
      notifyListeners();
    } catch (e) {
      developer.log('Error fetching images: $e', name: 'PlazaModifyVM.ImageOps', error: e);
      _setError(e is Exception ? e : Exception('Failed to fetch images: $e'));
      formState.fetchedImages.clear();
      formState.plazaImages.clear();
      formState.imageIds.clear();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchAllPlazaDetails(String plazaId) async {
    developer.log('Starting fetchAllPlazaDetails for plaza: $plazaId', name: 'PlazaModifyVM');
    _setLoading(true);
    _clearError();
    _plazaId = plazaId;

    Exception? firstOverallError;
    bool basicFetchDidSucceed = false; // Flag to track success explicitly

    try {
      // We don't strictly need the results list if we set flags directly
      await Future.wait([
        // --- Basic Details Fetch ---
        fetchBasicPlazaDetails(plazaId)
            .then((_) {
          // Set flag on successful completion
          basicFetchDidSucceed = true;
          developer.log('fetchBasicPlazaDetails completed successfully within fetchAll.', name: 'PlazaModifyVM');
        })
            .catchError((e) {
          // Flag remains false on error
          developer.log('Failed fetching basic details within fetchAll: $e', name: 'PlazaModifyVM');
          firstOverallError ??= (e is Exception ? e : Exception(e.toString()));
          // No need to return anything from catchError here
        }),

        // --- Other Fetches (can still use catchError to capture firstOverallError) ---
        fetchBankPlazaDetails(plazaId).catchError((e) {
          developer.log('Failed fetching bank details within fetchAll: $e', name: 'PlazaModifyVM');
          firstOverallError ??= (e is Exception ? e : Exception(e.toString()));
        }),
        fetchPlazaImages(_plazaId!).catchError((e) {
          developer.log('Failed fetching images within fetchAll: $e', name: 'PlazaModifyVM');
          firstOverallError ??= (e is Exception ? e : Exception(e.toString()));
        }),
        fetchLanes(_plazaId!).catchError((e) {
          developer.log('Failed fetching lanes within fetchAll: $e', name: 'PlazaModifyVM');
          firstOverallError ??= (e is Exception ? e : Exception(e.toString()));
        }),
      ]);

      // --- Now check the flag directly ---
      final bool basicSuccess = basicFetchDidSucceed; // Use the flag

      developer.log('Completed fetchAllPlazaDetails. Basic details fetch success: $basicSuccess, First overall error encountered: $firstOverallError', name: 'PlazaModifyVM');

    } catch (e) {
      developer.log('Unexpected error during Future.wait in fetchAll: $e', name: 'PlazaModifyVM');
      firstOverallError ??= (e is Exception ? e : Exception(e.toString()));
    }
    finally {
      _setLoading(false);
      if (firstOverallError != null) {
        _setError(firstOverallError);
        developer.log('Finished fetchAllPlazaDetails with errors.', name: 'PlazaModifyVM');
      } else {
        developer.log('Finished fetchAllPlazaDetails (all promises resolved without critical error).', name: 'PlazaModifyVM');
      }
    }
  }


  Future<Bank?> _fetchBankDetails(String plazaId) async {
    developer.log('Fetching bank details for plazaId: $plazaId', name: 'PlazaModifyVM._fetchBankDetails');
    try {
      return await _bankService.getBankDetailsByPlazaId(plazaId);
    } on HttpException catch (e) {
      if (e.statusCode == 404) {
        developer.log('No bank details found (404) for plazaId: $plazaId - Handling in ViewModel.', name: 'PlazaModifyVM._fetchBankDetails');
        return null;
      } else {
        developer.log('HttpException fetching bank details (Code: ${e.statusCode}): ${e.message} - Rethrowing.', name: 'PlazaModifyVM._fetchBankDetails', error: e);
        rethrow;
      }
    } on TimeoutException catch (e) {
      developer.log('TimeoutException fetching bank details: $e - Rethrowing.', name: 'PlazaModifyVM._fetchBankDetails', error: e);
      rethrow;
    } on ServerConnectionException catch (e) {
      developer.log('ServerConnectionException fetching bank details: $e - Rethrowing.', name: 'PlazaModifyVM._fetchBankDetails', error: e);
      rethrow;
    } catch (e) {
      developer.log('Unexpected error fetching bank details: $e - Wrapping.', name: 'PlazaModifyVM._fetchBankDetails', error: e);
      if (e is ServiceException) rethrow;
      throw ServiceException('Unexpected error occurred while fetching bank details: $e');
    }
  }

  // --- Controller Population Methods ---
  void _populateBasicDetailsControllers() {
    developer.log('Populating basic details controllers.', name: 'PlazaModifyVM');
    plazaNameController.text = formState.basicDetails['plazaName']?.toString() ?? '';
    plazaOwnerController.text = formState.basicDetails['plazaOwner']?.toString() ?? '';
    plazaOwnerIdController.text = formState.basicDetails['plazaOwnerId']?.toString() ?? '';
    operatorNameController.text = formState.basicDetails['plazaOperatorName']?.toString() ?? '';
    mobileController.text = formState.basicDetails['mobileNumber']?.toString() ?? '';
    emailController.text = formState.basicDetails['email']?.toString() ?? '';
    addressController.text = formState.basicDetails['address']?.toString() ?? '';
    cityController.text = formState.basicDetails['city']?.toString() ?? '';
    districtController.text = formState.basicDetails['district']?.toString() ?? '';
    stateController.text = formState.basicDetails['state']?.toString() ?? '';
    pincodeController.text = formState.basicDetails['pincode']?.toString() ?? '';
    geoLatitudeController.text = formState.basicDetails['geoLatitude']?.toString() ?? '';
    geoLongitudeController.text = formState.basicDetails['geoLongitude']?.toString() ?? '';
    noOfParkingSlotsController.text = formState.basicDetails['noOfParkingSlots']?.toString() ?? '';
    capacityBikeController.text = formState.basicDetails['capacityBike']?.toString() ?? '';
    capacity3WheelerController.text = formState.basicDetails['capacity3Wheeler']?.toString() ?? '';
    capacity4WheelerController.text = formState.basicDetails['capacity4Wheeler']?.toString() ?? '';
    capacityBusController.text = formState.basicDetails['capacityBus']?.toString() ?? '';
    capacityTruckController.text = formState.basicDetails['capacityTruck']?.toString() ?? '';
    capacityHeavyMachineryController.text = formState.basicDetails['capacityHeavyMachinaryVehicle']?.toString() ?? '';
    // *** Populate with already formatted time ***
    plazaOpenTimingsController.text = formState.basicDetails['plazaOpenTimings']?.toString() ?? '';
    plazaClosingTimeController.text = formState.basicDetails['plazaClosingTime']?.toString() ?? '';
  }

  void _populateBankDetailsControllers() {
    developer.log('Populating bank details controllers.', name: 'PlazaModifyVM');
    bankNameController.text = formState.bankDetails['bankName']?.toString() ?? '';
    accountNumberController.text = formState.bankDetails['accountNumber']?.toString() ?? '';
    accountHolderController.text = formState.bankDetails['accountHolderName']?.toString() ?? '';
    ifscCodeController.text = formState.bankDetails['IFSCcode']?.toString() ?? '';
  }

  void _clearBankDetailsControllers() {
    developer.log('Clearing bank details controllers.', name: 'PlazaModifyVM');
    bankNameController.clear();
    accountNumberController.clear();
    accountHolderController.clear();
    ifscCodeController.clear();
  }

  // --- Edit Mode Toggles & Cancellation ---
  void toggleBasicDetailsEditable() {
    if (!_isBasicDetailsEditable) {
      developer.log('Entering basic details edit mode. Saving original state.', name: 'PlazaModifyVM');
      RestorationHelper.saveOriginalBasicDetails(formState.basicDetails);
    } else {
      developer.log('Exiting basic details edit mode.', name: 'PlazaModifyVM');
    }
    _isBasicDetailsEditable = !_isBasicDetailsEditable;
    notifyListeners();
  }

  void cancelBasicDetailsEdit() {
    developer.log('Cancelling basic details edit. Restoring original state.', name: 'PlazaModifyVM');
    RestorationHelper.restoreBasicDetails(formState.basicDetails);
    // *** Format time again after restoring ***
    formState.basicDetails['plazaOpenTimings'] = _formatTimeHHMM(formState.basicDetails['plazaOpenTimings']?.toString());
    formState.basicDetails['plazaClosingTime'] = _formatTimeHHMM(formState.basicDetails['plazaClosingTime']?.toString());
    _populateBasicDetailsControllers();
    _isBasicDetailsEditable = false;
    formState.errors.clear();
    notifyListeners();
  }

  void toggleBankEditable() {
    if (!_isBankEditable) {
      developer.log('Entering bank details edit mode. Saving original state.', name: 'PlazaModifyVM');
      RestorationHelper.saveOriginalBankDetails(formState.bankDetails);
    } else {
      developer.log('Exiting bank details edit mode.', name: 'PlazaModifyVM');
    }
    _isBankEditable = !_isBankEditable;
    notifyListeners();
  }

  void setBankDetailsEditable(bool value) {
    developer.log('Setting bank details editable to: $value', name: 'PlazaModifyVM');
    _isBankEditable = value;
    if (!value) {
      formState.errors.clear();
    }
    notifyListeners();
  }

  void cancelBankDetailsEdit() {
    developer.log('Cancelling bank details edit. Restoring original state.', name: 'PlazaModifyVM');
    RestorationHelper.restoreBankDetails(formState.bankDetails);
    _populateBankDetailsControllers();
    _isBankEditable = false;
    formState.errors.clear();
    notifyListeners();
  }

  void setBasicDetailsEditable(bool value) {
    developer.log('Setting basic details editable to: $value', name: 'PlazaModifyVM');
    _isBasicDetailsEditable = value;
    if (!value) {
      formState.errors.clear();
    }
    notifyListeners();
  }

  // --- Update/Save Methods ---
  Future<void> updateBasicDetails(BuildContext context) async {
    final strings = S.of(context);
    if (!formState.validateBasicDetails(context)) {
      developer.log('Basic details validation failed.', name: 'PlazaModifyVM', level: 900);
      _showSnackBar(context, strings.correctBasicDetailsErrors, isError: true);
      return;
    }
    developer.log('Basic details validation passed. Proceeding with update.', name: 'PlazaModifyVM');

    _setLoading(true);
    _clearError();

    try {
      String formatCoordinate(dynamic value) {
        if (value == null || value.toString().isEmpty) return "0.00000000";
        double coord = double.tryParse(value.toString()) ?? 0.0;
        return coord.toStringAsFixed(8);
      }
      int parseInt(dynamic value, [int defaultValue = 0]) {
        return int.tryParse(value?.toString() ?? '') ?? defaultValue;
      }

      // *** Ensure time is formatted before creating Plaza object ***
      final String openTime = _formatTimeHHMM(formState.basicDetails['plazaOpenTimings']?.toString());
      final String closeTime = _formatTimeHHMM(formState.basicDetails['plazaClosingTime']?.toString());

      final updatedPlaza = Plaza(
        plazaId: _plazaId,
        plazaName: formState.basicDetails['plazaName'] ?? '',
        plazaOwner: formState.basicDetails['plazaOwner'] ?? '',
        plazaOwnerId: formState.basicDetails['plazaOwnerId'] ?? '',
        plazaOperatorName: formState.basicDetails['plazaOperatorName'] ?? '',
        mobileNumber: formState.basicDetails['mobileNumber'] ?? '',
        email: formState.basicDetails['email'] ?? '',
        address: formState.basicDetails['address'] ?? '',
        city: formState.basicDetails['city'] ?? '',
        district: formState.basicDetails['district'] ?? '',
        state: formState.basicDetails['state'] ?? '',
        pincode: formState.basicDetails['pincode'] ?? '',
        geoLatitude: double.parse(formatCoordinate(formState.basicDetails['geoLatitude'])),
        geoLongitude: double.parse(formatCoordinate(formState.basicDetails['geoLongitude'])),
        plazaCategory: formState.basicDetails['plazaCategory'] ?? Plaza.validPlazaCategories.first,
        plazaSubCategory: formState.basicDetails['plazaSubCategory'] ?? Plaza.validPlazaSubCategories.first,
        structureType: formState.basicDetails['structureType'] ?? Plaza.validStructureTypes.first,
        plazaStatus: formState.basicDetails['plazaStatus'] ?? Plaza.validPlazaStatuses.first,
        noOfParkingSlots: parseInt(formState.basicDetails['noOfParkingSlots']),
        freeParking: formState.basicDetails['freeParking'] ?? false,
        priceCategory: formState.basicDetails['priceCategory'] ?? Plaza.validPriceCategories.first,
        capacityBike: parseInt(formState.basicDetails['capacityBike']),
        capacity3Wheeler: parseInt(formState.basicDetails['capacity3Wheeler']),
        capacity4Wheeler: parseInt(formState.basicDetails['capacity4Wheeler']),
        capacityBus: parseInt(formState.basicDetails['capacityBus']),
        capacityTruck: parseInt(formState.basicDetails['capacityTruck']),
        capacityHeavyMachinaryVehicle: parseInt(formState.basicDetails['capacityHeavyMachinaryVehicle']),
        // *** Use the formatted time ***
        plazaOpenTimings: openTime.isEmpty ? '00:00' : openTime, // Provide default if empty after format
        plazaClosingTime: closeTime.isEmpty ? '23:59' : closeTime, // Provide default if empty after format
        isDeleted: formState.basicDetails['isDeleted'] ?? false,
      );
      developer.log('Updating plaza with data: ${updatedPlaza.toJson()}', name: 'PlazaModifyVM');

      final success = await _plazaService.updatePlaza(updatedPlaza, _plazaId!);
      if (success) {
        developer.log('Plaza update successful.', name: 'PlazaModifyVM');
        _isBasicDetailsEditable = false;
        // Update local state immediately after successful save
        formState.basicDetails['plazaOpenTimings'] = openTime;
        formState.basicDetails['plazaClosingTime'] = closeTime;
        _populateBasicDetailsControllers(); // Repopulate controllers to reflect saved state

        await _showSuccessDialog(
          context,
          message: strings.basicDetailsUpdateSuccess,
          onConfirmed: () {},
        );
      } else {
        developer.log('Plaza update failed (service returned false).', name: 'PlazaModifyVM', level: 900);
        _showSnackBar(context, strings.updatePlazaFailed, isError: true);
      }
    } catch (e) {
      developer.log('Error updating plaza: $e', name: 'PlazaModifyVM', error: e, level: 1000);
      _setError(e is Exception ? e : Exception('Error updating plaza: $e'));
      _showSnackBar(context, "Error updating plaza: ${e.toString()}", isError: true);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> saveBankDetails(BuildContext context, {required bool modify}) async {
    final strings = S.of(context);
    if (!formState.validateBankDetails(context)) {
      developer.log('Bank details validation failed.', name: 'PlazaModifyVM', level: 900);
      _showSnackBar(context, strings.correctBankDetailsErrors, isError: true);
      return;
    }

    if (_plazaId == null) {
      developer.log('Cannot save bank details: Plaza ID is null.', name: 'PlazaModifyVM', level: 1000);
      _showSnackBar(context, strings.invalidPlazaId, isError: true);
      return;
    }
    developer.log('Bank details validation passed. Proceeding with save/update (modify: $modify).', name: 'PlazaModifyVM');

    _setLoading(true);
    _clearError();

    try {
      final existingBankId = formState.bankDetails['id'] as String?;
      final bool isUpdate = existingBankId != null && existingBankId.isNotEmpty;
      final String operation = isUpdate ? strings.updateOperation : strings.addOperation;

      developer.log('Saving bank details. Is Update: $isUpdate, Bank ID: $existingBankId', name: 'PlazaModifyVM');

      final bank = Bank(
        id: existingBankId,
        plazaId: _plazaId!,
        bankName: formState.bankDetails['bankName'] ?? '',
        accountNumber: formState.bankDetails['accountNumber'] ?? '',
        accountHolderName: formState.bankDetails['accountHolderName'] ?? '',
        ifscCode: formState.bankDetails['IFSCcode'] ?? '',
      );
      developer.log('Bank details object for API: ${bank.toJson()}', name: 'PlazaModifyVM');

      bool isOperationSuccessful;
      if (isUpdate) {
        developer.log('Calling updateBankDetails...', name: 'PlazaModifyVM');
        isOperationSuccessful = await _bankService.updateBankDetails(bank);
      } else {
        developer.log('Calling addBankDetails...', name: 'PlazaModifyVM');
        final responseMap = await _bankService.addBankDetails(bank);
        isOperationSuccessful = responseMap['success'] == true;
        if (isOperationSuccessful && responseMap['bankDetails'] != null) {
          formState.bankDetails['id'] = responseMap['bankDetails']['id']?.toString();
          developer.log('Add successful, updated local bank ID: ${formState.bankDetails['id']}', name: 'PlazaModifyVM');
        }
      }

      if (isOperationSuccessful) {
        developer.log('Bank details $operation successful.', name: 'PlazaModifyVM');
        _isBankEditable = false;
        _populateBankDetailsControllers(); // Repopulate after save
        await _showSuccessDialog(
          context,
          message: strings.bankDetailsSuccess(operation),
          onConfirmed: () {},
        );
      } else {
        developer.log('Bank details $operation failed (service returned false).', name: 'PlazaModifyVM', level: 900);
        _showSnackBar(context, strings.bankDetailsFailed(operation), isError: true);
      }
    } catch (e) {
      developer.log('Error saving bank details: $e', name: 'PlazaModifyVM', error: e, level: 1000);
      _setError(e is Exception ? e : Exception('Error saving bank details: $e'));
      _showSnackBar(context, "Error saving bank details: ${e.toString()}", isError: true);
    } finally {
      _setLoading(false);
    }
  }

  // --- Lane Operations ---
  Future<void> fetchLaneById(String laneId) async {
    if (laneId.isEmpty) {
      developer.log('fetchLaneById called with empty ID.', name: 'PlazaModifyVM.LaneOps', level: 1000);
      throw ArgumentError('Lane ID cannot be empty');
    }
    _setLoading(true); // Use general loading
    _clearError();
    developer.log('Fetching details for laneId: $laneId', name: 'PlazaModifyVM.LaneOps');
    try {
      // Assuming laneService.getLaneById handles String ID
      _selectedLane = await _laneService.getLaneById(laneId);
      // --- CORRECTED LOGGING ---
      developer.log('Fetched lane: ${_selectedLane?.toJsonForUpdate()}', name: 'PlazaModifyVM.LaneOps');
    } catch (e) {
      developer.log('Error fetching lane by ID: $e', name: 'PlazaModifyVM.LaneOps', error: e);
      _setError(e is Exception ? e : Exception('Error fetching lane: $e'));
      _selectedLane = null;
      rethrow;
    } finally {
      _setLoading(false); // Use general loading
    }
  }

  Future<void> updateLane(String laneId, Lane updatedLane) async {
    _clearError();
    _setSavingLane(true); // Use specific flag for lane save
    // --- CORRECTED LOGGING ---
    developer.log('Updating laneId: $laneId with data: ${updatedLane.toJsonForUpdate()}', name: 'PlazaModifyVM.LaneOps');
    try {
      // Assume laneService.updateLane handles the Lane object correctly
      final success = await _laneService.updateLane(updatedLane);
      if (success) {
        developer.log('Lane update successful. Updating local list.', name: 'PlazaModifyVM.LaneOps');
        final index = _lanes.indexWhere((lane) => lane.laneId?.toString() == laneId);
        if (index != -1) _lanes[index] = updatedLane;
        if (_selectedLane?.laneId?.toString() == laneId) {
          _selectedLane = updatedLane;
        }
        notifyListeners();
      } else {
        developer.log('Lane update failed (service returned false).', name: 'PlazaModifyVM.LaneOps', level: 900);
        throw ServiceException('Failed to update lane (API returned false)');
      }
    } catch (e) {
      developer.log('Error updating lane: $e', name: 'PlazaModifyVM.LaneOps', error: e);
      _setError(e is Exception ? e : Exception('Error updating lane: $e'));
      rethrow; // Rethrow to be caught by UI
    } finally {
      _setSavingLane(false); // Reset specific flag
    }
  }

  Future<void> addLane(Lane lane) async {
    _clearError();
    _setSavingLane(true); // Use specific flag for lane save
    // --- CORRECTED LOGGING ---
    developer.log('Adding new lane: ${lane.toJsonForCreate()}', name: 'PlazaModifyVM.LaneOps');
    try {
      // Model validation should happen in the dialog before calling this
      final createdLanes = await _laneService.addLane([lane]);
      if (createdLanes.isNotEmpty) {
        developer.log('Lane added successfully via service.', name: 'PlazaModifyVM.LaneOps');
        // Refreshing the list is handled by the caller screen (_handleAddLane)
        // by calling fetchLanes after this completes.
        // await fetchLanes(_plazaId!); // Avoid redundant fetch here
      } else {
        developer.log('Add lane call succeeded but no lane data returned.', name: 'PlazaModifyVM.LaneOps', level: 900);
        throw ServiceException('Failed to add lane (No data returned)');
      }
    } catch (e) {
      developer.log('Error adding lane: $e', name: 'PlazaModifyVM.LaneOps', error: e);
      _setError(e is Exception ? e : Exception('Error adding lane: $e'));
      rethrow; // Rethrow to be caught by UI
    } finally {
      _setSavingLane(false); // Reset specific flag
    }
  }

  // --- Image Operations ---
  Future<void> pickImages() async {
    _clearError();
    developer.log('Attempting to pick images.', name: 'PlazaModifyVM.ImageOps');
    try {
      final picker = ImagePicker();
      final images = await picker.pickMultiImage(imageQuality: 70);
      if (images.isNotEmpty) {
        developer.log('Picked ${images.length} images.', name: 'PlazaModifyVM.ImageOps');
        formState.plazaImages.addAll(images.map((image) => image.path));
        notifyListeners();
      } else {
        developer.log('Image picking cancelled or no images selected.', name: 'PlazaModifyVM.ImageOps');
      }
    } catch (e) {
      developer.log('Error picking images: $e', name: 'PlazaModifyVM.ImageOps', error: e);
      _setError(e is Exception ? e : Exception('Failed to pick images: $e'));
    }
  }

  Future<void> saveImages(BuildContext context, {bool wantPop = true}) async {
    final strings = S.of(context);
    _setLoading(true); // Use general loading for image uploads
    _clearError();
    developer.log('Attempting to save images.', name: 'PlazaModifyVM.ImageOps');

    try {
      final newImageFiles = formState.plazaImages
          .where((imagePath) => !formState.fetchedImages.contains(imagePath) && !imagePath.startsWith('http'))
          .map((path) => File(path))
          .toList();

      developer.log('Found ${newImageFiles.length} new images to upload.', name: 'PlazaModifyVM.ImageOps');

      if (newImageFiles.isNotEmpty && _plazaId != null) {
        developer.log('Uploading new images...', name: 'PlazaModifyVM.ImageOps');
        await _imageService.uploadMultipleImages(_plazaId!, newImageFiles);
        // Refresh image list after upload completes successfully
        await fetchPlazaImages(_plazaId!);
      } else if (newImageFiles.isEmpty) {
        developer.log('No new images to upload.', name: 'PlazaModifyVM.ImageOps');
      } else if (_plazaId == null) {
        developer.log('Cannot upload images: Plaza ID is null.', name: 'PlazaModifyVM.ImageOps', level: 1000);
        throw ServiceException("Plaza ID not available for image upload.");
      }

      await _showSuccessDialog(
        context,
        message: newImageFiles.isNotEmpty ? strings.imagesUploadedSuccess : strings.noNewImagesToUpload,
        onConfirmed: wantPop ? () => Navigator.maybePop(context) : null,
      );

    } catch (e) {
      developer.log('Error saving images: $e', name: 'PlazaModifyVM.ImageOps', error: e);
      _setError(e is Exception ? e : Exception('Failed to upload images: $e'));
      _showSnackBar(context, '${strings.imagesUploadFailed}: ${e.toString()}', isError: true);
    } finally {
      _setLoading(false); // Use general loading
    }
  }


  Future<bool> removeImage(String imageUrl) async {
    _setLoading(true); // Use general loading
    _clearError();
    developer.log('Attempting to remove image: $imageUrl', name: 'PlazaModifyVM.ImageOps');

    try {
      final imageId = formState.imageIds[imageUrl];
      if (imageId != null) {
        developer.log('Found image ID: $imageId. Calling delete service...', name: 'PlazaModifyVM.ImageOps');
        final success = await _imageService.deleteImage(imageId);
        if (success) {
          developer.log('Image deletion successful via service.', name: 'PlazaModifyVM.ImageOps');
          formState.plazaImages.remove(imageUrl);
          formState.fetchedImages.remove(imageUrl);
          formState.imageIds.remove(imageUrl);
          notifyListeners();
          return true;
        } else {
          developer.log('Image deletion failed (service returned false).', name: 'PlazaModifyVM.ImageOps', level: 900);
          throw ServiceException("Failed to remove image (API returned false).");
        }
      } else if (formState.plazaImages.contains(imageUrl) && !imageUrl.startsWith('http')) {
        developer.log('Removing locally picked image (not uploaded): $imageUrl', name: 'PlazaModifyVM.ImageOps');
        formState.plazaImages.remove(imageUrl);
        notifyListeners();
        return true;
      }
      else {
        developer.log('Cannot remove image: ID not found for URL $imageUrl', name: 'PlazaModifyVM.ImageOps', level: 1000);
        throw ServiceException("Cannot remove image: ID not found.");
      }
    } catch (e) {
      developer.log('Error removing image: $e', name: 'PlazaModifyVM.ImageOps', error: e);
      _setError(e is Exception ? e : Exception('Failed to remove image: $e'));
      return false; // Indicate failure
    } finally {
      _setLoading(false); // Use general loading
    }
  }

  void resetImageState() {
    developer.log('Resetting image state to fetched images.', name: 'PlazaModifyVM.ImageOps');
    formState.plazaImages = List.from(formState.fetchedImages);
    notifyListeners();
  }

  // --- State Management Helpers ---
  void _setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      developer.log('Loading state set to: $value', name: 'PlazaModifyVM.State');
      notifyListeners();
    }
  }

  // Added specific setter for lane saving state
  void _setSavingLane(bool value) {
    if (_isSavingLane != value) {
      _isSavingLane = value;
      developer.log('isSavingLane state set to: $value', name: 'PlazaModifyVM.State');
      notifyListeners(); // Notify listeners for UI updates (like FAB)
    }
  }

  void _setError(Exception? error) {
    if (_error?.toString() != error?.toString()) {
      _error = error;
      developer.log('Error state set: ${error?.runtimeType} - ${error?.toString()}', name: 'PlazaModifyVM.State', level: error == null ? 0 : 900);
      notifyListeners();
    }
  }

  void _clearError() {
    if (_error != null) {
      _error = null;
      developer.log('Error state cleared.', name: 'PlazaModifyVM.State');
      notifyListeners();
    }
  }

  void _showSnackBar(BuildContext context, String message, {bool isError = false}) {
    if (!context.mounted) return;
    developer.log('Showing SnackBar: "$message", isError: $isError', name: 'PlazaModifyVM.Feedback');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }

  Future<void> _showSuccessDialog(
      BuildContext context, {
        required String message,
        VoidCallback? onConfirmed,
      }) async {
    if (!context.mounted) return;
    developer.log('Showing Success Dialog: Message="$message"', name: 'PlazaModifyVM.Feedback');
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final strings = S.of(dialogContext);
        return AlertDialog(
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  onConfirmed?.call();
                });
              },
              child: Text(strings.ok),
            ),
          ],
        );
      },
    );
  }

  void _resetState() {
    developer.log('Resetting entire ViewModel state (private method).', name: 'PlazaModifyVM.State');
    formState.basicDetails.clear();
    formState.bankDetails.clear();
    formState.plazaImages.clear();
    formState.fetchedImages.clear();
    formState.imageIds.clear();
    formState.errors.clear();
    _plazaId = null;
    _lanes.clear();
    _selectedLane = null;
    _isLoading = false;
    _isSavingLane = false; // Reset specific flag
    _error = null;
    _populateBasicDetailsControllers();
    _clearBankDetailsControllers();
    _isBasicDetailsEditable = false;
    _isBankEditable = false;
  }

  void resetState() {
    developer.log('Public resetState called.', name: 'PlazaModifyVM.State');
    _resetState();
    notifyListeners();
  }

  // --- Dispose ---
  @override
  void dispose() {
    developer.log('[PlazaModifyVM] ViewModel disposing.', name: 'PlazaModify');
    // Dispose all controllers
    plazaNameController.dispose();
    plazaOwnerController.dispose();
    plazaOwnerIdController.dispose();
    operatorNameController.dispose();
    mobileController.dispose();
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
    capacityHeavyMachineryController.dispose();
    plazaOpenTimingsController.dispose();
    plazaClosingTimeController.dispose();
    bankNameController.dispose();
    accountNumberController.dispose();
    accountHolderController.dispose();
    ifscCodeController.dispose();
    super.dispose();
  }
}