import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:merchant_app/services/payment/bank_service.dart';
import 'package:merchant_app/services/utils/image_service.dart';
import 'package:merchant_app/services/core/lane_service.dart';
import 'package:merchant_app/viewmodels/plaza/plaza_form_validation.dart';
import 'package:merchant_app/viewmodels/plaza/restoration_helper.dart';
import '../../models/bank.dart';
import '../../models/lane.dart';
import '../../models/plaza.dart';
import '../../models/user_model.dart';
import '../../services/core/plaza_service.dart';
import '../../services/storage/secure_storage_service.dart';
import '../../utils/exceptions.dart';

class PlazaFormState {
  final PlazaFormValidation formValidation = PlazaFormValidation();
  final Map<String, String?> errors = {};

  Map<String, dynamic> basicDetails = {};
  Map<String, dynamic> laneDetails = {};
  Map<String, dynamic> bankDetails = {};
  List<String> fetchedImages = [];
  List<String> plazaImages = [];
  Map<String, String> imageIds = {};

  bool validateStep(int step) {
    errors.clear();
    switch (step) {
      case 0:
        formValidation.validateBasicDetails(basicDetails, errors);
        break;
      case 1:
        break;
      case 2:
        formValidation.validateBankDetails(bankDetails, errors);
        break;
      case 3:
        break;
    }
    return errors.isEmpty;
  }

  void clearStep(int step) {
    switch (step) {
      case 0:
        basicDetails = {};
        errors.remove('basicDetails');
        break;
      case 1:
        laneDetails = {};
        errors.remove('laneDetails');
        break;
      case 2:
        bankDetails = {};
        errors.remove('bankDetails');
        break;
      case 3:
        plazaImages = [];
        errors.remove('plazaImages');
        break;
    }
  }
}

class PlazaViewModel extends ChangeNotifier {
  final PlazaService _plazaService = PlazaService();
  final LaneService _laneService = LaneService();
  final ImageService _imageService = ImageService();
  final BankService _bankService = BankService();
  final PlazaFormState formState = PlazaFormState();
  final SecureStorageService _secureStorageService = SecureStorageService();

  int _currentStep = 0;
  int _completeTillStep = -1;

  List<Plaza> _userPlazas = [];
  final Map<String, String> plazaImages = {};
  bool _isLoading = false;
  Exception? _error; // Changed to Exception?
  String? _plazaId;
  final List<Lane> _temporaryLanes = [];
  late List<Lane> _existingLanes = [];
  List<Lane> lanes = [];

  List<Lane> get temporaryLanes => List.unmodifiable(_temporaryLanes);
  List<Lane> get existingLanes => List.unmodifiable(_existingLanes);
  List<Plaza> get userPlazas => _userPlazas;
  bool get isLoading => _isLoading;
  Exception? get error => _error;
  String? get plazaId => _plazaId;
  int get currentStep => _currentStep;
  int get completeTillStep => _completeTillStep;

  bool _isBasicDetailsEditable = false;
  bool get isBasicDetailsEditable => _isBasicDetailsEditable;
  bool _isBasicDetailsFirstTime = true;
  bool get isBasicDetailsFirstTime => _isBasicDetailsFirstTime;

  bool _isLaneEditable = false;
  bool get isLaneEditable => _isLaneEditable;
  bool _isLaneDetailsFirstTime = true;
  bool get isLaneDetailsFirstTime => _isLaneDetailsFirstTime;

  bool _isBankEditable = false;
  bool get isBankEditable => _isBankEditable;
  bool _isBankDetailsFirstTime = true;
  bool get isBankDetailsFirstTime => _isBankDetailsFirstTime;

  final Map<String, dynamic> _laneDetails = {};
  Map<String, dynamic> get laneDetails => _laneDetails;

  bool _isBasicDetailsCompleted = false;
  bool _isLaneDetailsCompleted = false;
  bool _isBankDetailsCompleted = false;
  bool _isPlazaImagesCompleted = false;

  bool get isBasicDetailsCompleted => _isBasicDetailsCompleted;
  bool get isLaneDetailsCompleted => _isLaneDetailsCompleted;
  bool get isBankDetailsCompleted => _isBankDetailsCompleted;
  bool get isPlazaImagesCompleted => _isPlazaImagesCompleted;

  TextEditingController plazaNameController = TextEditingController();
  TextEditingController plazaOwnerController = TextEditingController();
  TextEditingController operatorNameController = TextEditingController();
  TextEditingController operatorIdController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController districtController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController pincodeController = TextEditingController();
  TextEditingController latitudeController = TextEditingController();
  TextEditingController longitudeController = TextEditingController();
  TextEditingController totalParkingSlotsController = TextEditingController();
  TextEditingController twoWheelerCapacityController = TextEditingController();
  TextEditingController lmvCapacityController = TextEditingController();
  TextEditingController lcvCapacityController = TextEditingController();
  TextEditingController hmvCapacityController = TextEditingController();
  TextEditingController openingTimeController = TextEditingController();
  TextEditingController closingTimeController = TextEditingController();
  TextEditingController bankNameController = TextEditingController();
  TextEditingController accountNumberController = TextEditingController();
  TextEditingController accountHolderController = TextEditingController();
  TextEditingController ifscCodeController = TextEditingController();

  bool isStepValid(int step) {
    switch (step) {
      case 0:
        return isBasicDetailsCompleted;
      case 1:
        return isLaneDetailsCompleted;
      case 2:
        return isBankDetailsCompleted;
      case 3:
        return isPlazaImagesCompleted;
      default:
        return false;
    }
  }

  String getStepName(int step) {
    switch (step) {
      case 0:
        return 'Basic Details';
      case 1:
        return 'Lane Details';
      case 2:
        return 'Bank Details';
      case 3:
        return 'Plaza Images';
      default:
        return 'Unknown';
    }
  }

  PlazaViewModel() {
    initControllers();
  }

  bool isInEdit() {
    return (isLaneEditable && !isLaneDetailsFirstTime) ||
        (isBankEditable && !isBankDetailsFirstTime) ||
        (isBasicDetailsEditable && !isBasicDetailsFirstTime);
  }

  void initControllers() async {
    final cachedUserData = await _secureStorageService.getUserData();
    if (cachedUserData == null) {
      return;
    }

    var currentUser = User.fromJson(cachedUserData);
    log('Current user: $currentUser');

    if (currentUser.role == "Plaza Owner") {
      formState.basicDetails['plazaOwner'] = currentUser.entityName?.trim() ?? '';
      formState.basicDetails['ownerId'] = currentUser.id.trim();
      plazaOwnerController.text = '${currentUser.entityName?.trim()} (ID:${currentUser.id.trim()})';
    } else {
      formState.basicDetails['plazaOwner'] = plazaOwnerController.text = currentUser.entityName?.trim() ?? '';
      formState.basicDetails['ownerId'] = currentUser.entityId?.trim() ?? '';
      plazaOwnerController.text = '${currentUser.entityName?.trim()} (ID:${currentUser.entityId?.trim()})';
    }

    _completeTillStep = -1;
    addListeners();
  }

  void addListeners() {
    plazaNameController.addListener(() {
      formState.basicDetails['plazaName'] = plazaNameController.text.trim();
    });
    operatorNameController.addListener(() {
      formState.basicDetails['operatorName'] = operatorNameController.text.trim();
    });
    operatorIdController.addListener(() {
      formState.basicDetails['operatorId'] = operatorIdController.text.trim();
    });
    mobileController.addListener(() {
      formState.basicDetails['mobileNumber'] = mobileController.text.trim();
    });
    emailController.addListener(() {
      formState.basicDetails['email'] = emailController.text.trim();
    });
    addressController.addListener(() {
      formState.basicDetails['address'] = addressController.text.trim();
    });
    cityController.addListener(() {
      formState.basicDetails['city'] = cityController.text.trim();
    });
    districtController.addListener(() {
      formState.basicDetails['district'] = districtController.text.trim();
    });
    stateController.addListener(() {
      formState.basicDetails['state'] = stateController.text.trim();
    });
    pincodeController.addListener(() {
      formState.basicDetails['pincode'] = pincodeController.text.trim();
    });
    latitudeController.addListener(() {
      formState.basicDetails['latitude'] = latitudeController.text.trim();
    });
    longitudeController.addListener(() {
      formState.basicDetails['longitude'] = longitudeController.text.trim();
    });
    totalParkingSlotsController.addListener(() {
      formState.basicDetails['totalParkingSlots'] = totalParkingSlotsController.text.trim();
    });
    twoWheelerCapacityController.addListener(() {
      formState.basicDetails['twoWheelerCapacity'] = twoWheelerCapacityController.text.trim();
    });
    lmvCapacityController.addListener(() {
      formState.basicDetails['lmvCapacity'] = lmvCapacityController.text.trim();
    });
    lcvCapacityController.addListener(() {
      formState.basicDetails['lcvCapacity'] = lcvCapacityController.text.trim();
    });
    hmvCapacityController.addListener(() {
      formState.basicDetails['hmvCapacity'] = hmvCapacityController.text.trim();
    });
    openingTimeController.addListener(() {
      formState.basicDetails['openingTime'] = openingTimeController.text.trim();
    });
    closingTimeController.addListener(() {
      formState.basicDetails['closingTime'] = closingTimeController.text.trim();
    });
    bankNameController.addListener(() {
      formState.bankDetails['bankName'] = bankNameController.text.trim();
    });
    accountNumberController.addListener(() {
      formState.bankDetails['accountNumber'] = accountNumberController.text.trim();
    });
    accountHolderController.addListener(() {
      formState.bankDetails['accountHolderName'] = accountHolderController.text.trim();
    });
    ifscCodeController.addListener(() {
      formState.bankDetails['ifscCode'] = ifscCodeController.text.trim();
    });
  }

  void validateBasicDetailsStep() {
    log('Basic Details Before Validation: ${formState.basicDetails}');
    formState.errors.clear();

    final validationError = formState.formValidation.validateBasicDetails(
      formState.basicDetails,
      formState.errors,
    );

    _isBasicDetailsCompleted = validationError == null;

    log('Validation Errors: ${formState.errors}');
    notifyListeners();
  }

  void validateBankDetailsStep() {
    log('Bank Details Before Validation: ${formState.bankDetails}');
    formState.errors.clear();

    formState.formValidation.validateBankDetails(formState.bankDetails, formState.errors);

    _isBankDetailsCompleted = formState.errors.isEmpty;

    log('Validation Errors: ${formState.errors}');
    notifyListeners();
  }

  String? validateLaneDetailsStep() {
    log('Lane Details Before Validation: $_laneDetails');
    formState.errors.clear();

    final validationResult = formState.formValidation.validateLaneDetails(_laneDetails, formState.errors);
    _isLaneDetailsCompleted = formState.errors.isEmpty;

    log('Validation Errors: ${formState.errors}');
    notifyListeners();
    return validationResult;
  }

  void validateStepCompletion() {
    switch (_currentStep) {
      case 0:
        validateBasicDetailsStep();
        break;
      case 1:
        break;
      case 2:
        validateBankDetailsStep();
        break;
      case 3:
        break;
    }
    notifyListeners();
  }

  void goToStep(int step) {
    if (step <= _completeTillStep + 1) {
      _currentStep = step;
      if (step == 1 && plazaId != null) {
        log('Fetching lanes for plaza: $plazaId');
        fetchExistingLanes(plazaId!);
      }
      notifyListeners();
    }
  }

  void completeBasicDetails() {
    _isBasicDetailsFirstTime = false;
    _isBasicDetailsEditable = false;
    if (_completeTillStep < 0) _completeTillStep = 0;
    notifyListeners();
  }

  void completeLaneDetails() {
    _isLaneDetailsFirstTime = false;
    _isLaneEditable = false;
    if (_completeTillStep < 1) _completeTillStep = 1;
    notifyListeners();
  }

  void nextStep() {
    if (_currentStep < 3) {
      _currentStep++;
      if (_currentStep > _completeTillStep) {
        _completeTillStep = _currentStep;
      }
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  void setPlazaId(String id) {
    _plazaId = id;
    notifyListeners();
  }

  void setCompleteTillStep(int step) {
    _completeTillStep = step;
    notifyListeners();
  }

  Future<void> fetchLanes(String plazaId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      log('ViewModel: Fetching lanes for Plaza ID: $plazaId');
      final newLanes = await _laneService.getLanesByPlazaId(plazaId);
      log('Fetched lanes: $newLanes');

      lanes = newLanes;
      _error = null;
    } catch (e) {
      _error = e is Exception ? e : Exception('Error fetching lanes: $e');
      log('Error in fetchLanes: $e');
      lanes = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addLane(List<Lane> lanes) async {
    try {
      final newLaneId = await _laneService.addLane(lanes);
      for (var lane in lanes) {
        lane.laneId = newLaneId;
      }
      notifyListeners();
    } catch (e) {
      _error = Exception('Error adding lanes: $e');
      log('Error adding lanes: $e');
      notifyListeners();
    }
  }

  Future<void> updateLane(String laneId, Lane updatedLane) async {
    try {
      final success = await _laneService.updateLane(updatedLane);
      if (success) {
        notifyListeners();
      } else {
        _error = Exception('Failed to update lane');
      }
    } catch (e) {
      _error = Exception('Error updating lane: $e');
      notifyListeners();
    }
  }

  void setBasicDetailsEditable(bool setValue) {
    _isBasicDetailsEditable = setValue;
  }

  void setBankDetailsEditable(bool setValue) {
    _isBankEditable = setValue;
  }

  void toggleBasicDetailsEditable() {
    if (!isBasicDetailsEditable) {
      RestorationHelper.saveOriginalBasicDetails(formState.basicDetails);
    }
    _isBasicDetailsEditable = !_isBasicDetailsEditable;
    notifyListeners();
  }

  void cancelBasicDetailsEdit() {
    RestorationHelper.restoreBasicDetails(formState.basicDetails);
    _populateBasicDetailsControllers();
    _isBasicDetailsEditable = false;
    notifyListeners();
  }

  void toggleLaneEditable() {
    _isLaneEditable = !_isLaneEditable;
    notifyListeners();
  }

  void toggleBankEditable() {
    if (!isBankEditable) {
      RestorationHelper.saveOriginalBankDetails(formState.bankDetails);
    }
    _isBankEditable = !_isBankEditable;
    notifyListeners();
  }

  void cancelBankDetailsEdit() {
    RestorationHelper.restoreBankDetails(formState.bankDetails);
    _populateBankDetailsControllers();
    _isBankEditable = false;
    notifyListeners();
  }

  void setLaneDetailsCompleted() {
    _isLaneDetailsFirstTime = false;
    notifyListeners();
  }

  Future<void> saveBankDetails(BuildContext context, {bool? modify}) async {
    log("Bank Details before validation: ${formState.bankDetails}");
    validateBankDetailsStep();

    if (!_isBankDetailsCompleted) {
      log("Validation failed: ${formState.errors}");
      showSnackBar(context, 'Please correct the errors in Bank Details.');
      return;
    }

    final bankDetails = {
      'bankName': bankNameController.text.trim(),
      'accountNumber': accountNumberController.text.trim(),
      'accountHolderName': accountHolderController.text.trim(),
      'ifscCode': ifscCodeController.text.trim(),
      'plazaId': plazaId,
    };

    log("Prepared Bank Details: $bankDetails");

    try {
      String operation = "added";
      bool isOperationSuccessful = false;

      if (modify == true) {
        log("Updating existing Bank Details...");
        isOperationSuccessful = await updateBankDetails();
        if (isOperationSuccessful) {
          toggleBankEditable();
          operation = "updated";
        }
      } else if (_isBankDetailsFirstTime) {
        log("Adding new Bank Details...");
        isOperationSuccessful = await addBankDetails();
        if (isOperationSuccessful) {
          completeBankDetails();
        }
      } else if (_isBankEditable) {
        log("Updating existing Bank Details...");
        isOperationSuccessful = await updateBankDetails();
        if (isOperationSuccessful) {
          toggleBankEditable();
          operation = "updated";
        }
      } else {
        log("Toggling edit mode...");
        toggleBankEditable();
        return;
      }

      if (isOperationSuccessful) {
        await showSuccessDialog(
          context,
          title: "Success",
          message: "Bank details have been successfully $operation.",
          onConfirmed: () {
            nextStep();
          },
        );
      } else {
        showSnackBar(context, 'Failed to $operation bank details. Please try again.');
      }
    } catch (e) {
      log("Error in saveBankDetails: $e");
      showSnackBar(context, 'Error: Failed to save Bank Details: $e');
    }
  }

  Future<void> saveLanes(String plazaId) async {
    try {
      if (_isLaneDetailsFirstTime) {
        if (_temporaryLanes.isNotEmpty) {
          await _laneService.addLane(_temporaryLanes);
          _temporaryLanes.clear();
        }
        _isLaneDetailsFirstTime = false;
        await fetchExistingLanes(plazaId);
        nextStep();
      } else if (_isLaneEditable) {
        if (_temporaryLanes.isNotEmpty) {
          await _laneService.addLane(_temporaryLanes);
          _temporaryLanes.clear();
        }
        await fetchExistingLanes(plazaId);
        toggleLaneEditable();
        nextStep();
      } else {
        toggleLaneEditable();
      }
      notifyListeners();
    } catch (e) {
      log('Error saving lanes: $e');
    }
  }

  Future<void> saveBasicDetails(BuildContext context) async {
    validateStepCompletion();
    if (!isBasicDetailsCompleted) {
      log("Validation failed: ${formState.errors}");
      showSnackBar(context, 'Please correct the errors in Basic Details.');
      return;
    }

    try {
      String operation = "added";
      bool isOperationSuccessful = false;

      if (_isBasicDetailsFirstTime) {
        log("Adding new Basic Details...");
        isOperationSuccessful = await registerPlaza();
        if (!isOperationSuccessful) {
          showSnackBar(context, 'API Error: Failed to register plaza. Please try again.');
          return;
        }
        completeBasicDetails();
        operation = "added";
      } else if (_isBasicDetailsEditable) {
        log("Updating existing Basic Details...");
        isOperationSuccessful = await updatePlaza();
        if (!isOperationSuccessful) {
          showSnackBar(context, 'API Error: Failed to update plaza. Please try again.');
          return;
        }
        completeBasicDetails();
        operation = "updated";
      } else {
        log("Toggling edit mode...");
        toggleBasicDetailsEditable();
        return;
      }

      await showSuccessDialog(
        context,
        title: "Success",
        message: "Basic details have been successfully $operation.",
        onConfirmed: () {
          nextStep();
        },
      );
    } catch (e) {
      log("Error in saveBasicDetails: $e");
      showSnackBar(context, 'API Error: Failed to save Basic Details: $e');
    }
  }

  Future<void> updateBasicDetails(BuildContext context) async {
    validateStepCompletion();
    if (!isBasicDetailsCompleted) {
      showSnackBar(context, 'Please correct the errors in Basic Details.');
      return;
    }

    try {
      log("Updating existing plaza with ID: $_plazaId...");
      final isUpdated = await updatePlaza();
      if (isUpdated) {
        await showSuccessDialog(
          context,
          title: "Success",
          message: "Basic details have been successfully Updated.",
          onConfirmed: () {},
        );
        _isBasicDetailsEditable = false;
        notifyListeners();
      } else {
        showSnackBar(context, 'Failed to update plaza. Please try again.');
      }
    } catch (e) {
      showSnackBar(context, 'Error: $e');
    }
  }

  Future<void> pickImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage();

      if (images.isNotEmpty) {
        formState.plazaImages.addAll(images.map((image) => image.path));
        notifyListeners();
      }
    } catch (e) {
      log("Error picking images: $e");
      throw Exception('Failed to pick images. Please try again.');
    }
  }

  Future<void> saveImages(BuildContext context, {bool wantPop = true}) async {
    try {
      final newImages = formState.plazaImages
          .where((image) => !formState.fetchedImages.contains(image))
          .toList();

      if (newImages.isEmpty) {
        throw Exception('No new images to upload.');
      }

      await _imageService.uploadMultipleImages(
        _plazaId!,
        newImages.map((path) => File(path)).toList(),
      );

      formState.fetchedImages.addAll(newImages);

      await showSuccessDialog(
        context,
        title: "Success",
        message: "New images uploaded successfully!",
        onConfirmed: wantPop ? () => Navigator.pop(context) : null,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload images: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> fetchPlazaImages(List<String?> plazaIds) async {
    try {
      log('Starting fetchPlazaImages with plazaIds: $plazaIds');
      log('Current formState.plazaImages before fetch: ${formState.plazaImages}');

      final validIds = plazaIds.whereType<String>().toList();
      if (validIds.isEmpty) {
        log('No valid plaza IDs provided');
        return;
      }

      final fetchTasks = validIds.map((plazaId) async {
        if (plazaImages.containsKey(plazaId) && plazaImages[plazaId] != null) {
          log('Skipping fetch for plazaId $plazaId - already in cache');
          return;
        }

        try {
          final imageDataList = await _imageService.getImagesByPlazaId(plazaId);
          log('Fetched image data for plazaId $plazaId: $imageDataList');

          formState.fetchedImages.clear();
          formState.imageIds.clear();
          formState.plazaImages.clear();

          if (imageDataList.isNotEmpty) {
            for (var imageData in imageDataList) {
              final url = imageData['imageUrl'] as String;
              final imageId = imageData['imageId'] as String;

              formState.fetchedImages.add(url);
              formState.imageIds[url] = imageId;
              formState.plazaImages.add(url);
              log('Added image URL: $url with ID: $imageId');
            }

            plazaImages[plazaId] = imageDataList.first['imageUrl'] as String;
          } else {
            plazaImages[plazaId] = '';
            log('No images found for plazaId $plazaId');
          }

          log('Updated formState.plazaImages: ${formState.plazaImages}');
        } catch (e) {
          plazaImages[plazaId] = '';
          log('Error fetching images for plazaId $plazaId: $e');
          _error = e is Exception ? e : Exception('Image fetch error: $e');
        }
      });

      await Future.wait(fetchTasks);
      log('Completed fetchPlazaImages - final formState.plazaImages: ${formState.plazaImages}');
      notifyListeners();
    } catch (e) {
      _error = e is Exception ? e : Exception('Image load failed: $e');
      log('fetchPlazaImages failed: $_error');
      notifyListeners();
    }
  }

  Future<bool> removeImage(String imageUrl) async {
    final index = formState.plazaImages.indexOf(imageUrl);
    if (index == -1) {
      log('[REMOVE IMAGE] Image not found in the list.');
      return false;
    }

    String? imageId = formState.fetchedImages.contains(imageUrl)
        ? formState.imageIds[imageUrl]
        : null;

    bool success = true;

    if (imageId != null) {
      success = await _imageService.deleteImage(imageId);
    }

    if (success) {
      formState.plazaImages.removeAt(index);
      notifyListeners();
      log('[REMOVE IMAGE] Image removed successfully.');
    } else {
      log('[REMOVE IMAGE] Failed to delete image from the server.');
    }

    return success;
  }

  void removeImageAt(int index) {
    formState.plazaImages.removeAt(index);
    notifyListeners();
  }

  void addNewLane(Lane lane) {
    _temporaryLanes.add(lane);
    notifyListeners();
  }

  void modifyTemporaryLane(int index, Lane updatedLane) {
    _temporaryLanes[index] = updatedLane;
    notifyListeners();
  }

  void completeBankDetails() {
    _isBankDetailsFirstTime = false;
    _isBankEditable = false;
    notifyListeners();
  }

  void clearCurrentStep() {
    switch (_currentStep) {
      case 0:
        plazaNameController.clear();
        plazaOwnerController.clear();
        operatorNameController.clear();
        operatorIdController.clear();
        mobileController.clear();
        emailController.clear();
        addressController.clear();
        cityController.clear();
        districtController.clear();
        stateController.clear();
        pincodeController.clear();
        latitudeController.clear();
        longitudeController.clear();
        _isBasicDetailsCompleted = false;
        break;
      case 1:
        _isLaneDetailsCompleted = false;
        break;
      case 2:
        _isBankDetailsCompleted = false;
        break;
      case 3:
        _isPlazaImagesCompleted = false;
        break;
    }
    notifyListeners();
  }

  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> showSuccessDialog(
      BuildContext context, {
        required String title,
        required String message,
        VoidCallback? onConfirmed,
      }) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirmed?.call();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void clearPlazaImages() {
    plazaImages.clear();
    notifyListeners();
  }

  String formatTime(String? time) {
    log("Formatting time: $time");
    if (time == null || time.isEmpty) return '';
    try {
      final parsedTime = DateFormat('HH:mm:ss').parse(time);
      final formattedTime = DateFormat('HH:mm').format(parsedTime);
      log("Formatted Time: $formattedTime");
      return formattedTime;
    } catch (e) {
      log("Error formatting time: $e");
      return '';
    }
  }

  void resetState() {
    formState.basicDetails.clear();
    formState.bankDetails.clear();
    formState.plazaImages.clear();
    formState.fetchedImages.clear();
    formState.imageIds.clear();
    _plazaId = null;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  Future<void> fetchPlazaDetailsById(String plazaId) async {
    log('Starting fetchPlazaDetailsById for plaza: $plazaId');
    resetState();
    log('State reset completed');

    try {
      _isLoading = true;
      notifyListeners();
      log('Loading state set to true');

      Plaza? plaza;
      try {
        log('Attempting to fetch plaza details...');
        plaza = await _plazaService.getPlazaById(plazaId);
        log('Successfully fetched plaza details');
      } catch (e) {
        log('Error fetching plaza details: $e');
        throw Exception('Failed to fetch plaza details: $e');
      }

      List<dynamic> images = [];
      try {
        log('Attempting to fetch plaza images...');
        images = await _imageService.getImagesByPlazaId(plazaId);
        log('Successfully fetched ${images.length} images');
      } catch (e) {
        log("Error fetching images: $e");
      }

      log('Clearing previous image data');
      formState.fetchedImages.clear();
      formState.imageIds.clear();
      formState.plazaImages.clear();

      log('Processing fetched images...');
      for (var image in images) {
        try {
          String imageUrl = image['imageUrl']?.toString() ?? '';
          String imageId = image['imageId']?.toString() ?? '';

          if (imageUrl.isNotEmpty && imageId.isNotEmpty) {
            formState.fetchedImages.add(imageUrl);
            formState.imageIds[imageUrl] = imageId;
            formState.plazaImages.add(imageUrl);
            log('Added image URL: $imageUrl with ID: $imageId');
          }
        } catch (e) {
          log("Error processing image data: $e");
        }
      }
      log('Finished processing ${formState.fetchedImages.length} valid images');

      _plazaId = plazaId;
      log('Setting plaza basic details...');

      String convertTimeFormat(String? time) {
        if (time == null || time.isEmpty) return '';
        try {
          final parts = time.split(':');
          if (parts.length >= 2) {
            return '${parts[0]}:${parts[1]}';
          }
          return time;
        } catch (e) {
          log('Error converting time format: $e');
          return time;
        }
      }

      String formattedOpeningTime = convertTimeFormat(plaza.plazaOpenTimings);
      String formattedClosingTime = convertTimeFormat(plaza.plazaClosingTime);

      formState.basicDetails.addAll({
        'plazaName': plaza.plazaName,
        'plazaId': plaza.plazaId,
        'operatorName': plaza.plazaOperatorName,
        'operatorId': plaza.plazaOperatorId,
        'plazaOwner': plaza.plazaOwner,
        'ownerId': plaza.plazaOwnerId,
        'mobileNumber': plaza.mobileNumber,
        'email': plaza.email,
        'address': plaza.address,
        'city': plaza.city,
        'district': plaza.district,
        'state': plaza.state,
        'pincode': plaza.pincode,
        'latitude': plaza.geoLatitude.toString(),
        'longitude': plaza.geoLongitude.toString(),
        'totalParkingSlots': plaza.noOfParkingSlots.toString(),
        'twoWheelerCapacity': plaza.capacityTwoWheeler.toString(),
        'lmvCapacity': plaza.capacityFourLMV.toString(),
        'lcvCapacity': plaza.capacityFourLCV.toString(),
        'hmvCapacity': plaza.capacityHMV.toString(),
        'plazaCategory': plaza.plazaCategory,
        'plazaSubCategory': plaza.plazaSubCategory,
        'structureType': plaza.structureType,
        'priceCategory': plaza.priceCategory,
        'plazaStatus': plaza.plazaStatus,
        'openingTime': formattedOpeningTime,
        'closingTime': formattedClosingTime,
      });
      log('Basic details set successfully');

      log('Attempting to fetch bank details...');
      await _fetchBankDetails(plazaId);
      log('Bank details fetched successfully');

      log('Updating UI controllers...');
      _populateBasicDetailsControllers();
      _populateBankDetailsControllers();
      log('UI controllers updated successfully');
    } catch (e) {
      log('Error in fetchPlazaDetailsById: $e');
      _error = Exception('Failed to fetch plaza details: $e');
      resetState();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
      log('fetchPlazaDetailsById completed. Loading state set to false');
    }
  }

  Future<void> _fetchBankDetails(String plazaId) async {
    try {
      final bank = await _bankService.getBankDetailsByPlazaId(plazaId);
      formState.bankDetails.addAll({
        'bankName': bank.bankName,
        'accountNumber': bank.accountNumber,
        'accountHolderName': bank.accountHolderName,
        'ifscCode': bank.ifscCode
      });
    } on HttpException catch (e) {
      if (e.statusCode == 404) {
        formState.bankDetails.addAll({
          'bankName': '',
          'accountNumber': '',
          'accountHolderName': '',
          'ifscCode': ''
        });
        _error = null;
      } else {
        _error = e;
      }
    } catch (e) {
      _error = Exception('Unexpected error: $e');
      formState.bankDetails.addAll({
        'bankName': '',
        'accountNumber': '',
        'accountHolderName': '',
        'ifscCode': ''
      });
    }
  }

  void _populateBasicDetailsControllers() {
    plazaNameController.text = formState.basicDetails['plazaName'] ?? '';
    operatorNameController.text = formState.basicDetails['operatorName'] ?? '';
    operatorIdController.text = formState.basicDetails['operatorId'] ?? '';
    mobileController.text = formState.basicDetails['mobileNumber'] ?? '';
    emailController.text = formState.basicDetails['email'] ?? '';
    addressController.text = formState.basicDetails['address'] ?? '';
    cityController.text = formState.basicDetails['city'] ?? '';
    districtController.text = formState.basicDetails['district'] ?? '';
    stateController.text = formState.basicDetails['state'] ?? '';
    pincodeController.text = formState.basicDetails['pincode'] ?? '';
    latitudeController.text = formState.basicDetails['latitude'] ?? '';
    longitudeController.text = formState.basicDetails['longitude'] ?? '';
    totalParkingSlotsController.text = formState.basicDetails['totalParkingSlots'] ?? '';
    twoWheelerCapacityController.text = formState.basicDetails['twoWheelerCapacity'] ?? '';
    lmvCapacityController.text = formState.basicDetails['lmvCapacity'] ?? '';
    lcvCapacityController.text = formState.basicDetails['lcvCapacity'] ?? '';
    hmvCapacityController.text = formState.basicDetails['hmvCapacity'] ?? '';
    openingTimeController.text = formState.basicDetails['openingTime'] ?? '';
    closingTimeController.text = formState.basicDetails['closingTime'] ?? '';
    notifyListeners();
  }

  void _populateBankDetailsControllers() {
    bankNameController.text = formState.bankDetails['bankName'] ?? '';
    accountNumberController.text = formState.bankDetails['accountNumber'] ?? '';
    accountHolderController.text = formState.bankDetails['accountHolderName'] ?? '';
    ifscCodeController.text = formState.bankDetails['ifscCode'] ?? '';
    notifyListeners();
  }

  Future<void> fetchExistingLanes(String plazaId) async {
    try {
      log('Starting fetchExistingLanes for plaza: $plazaId');
      final lanes = await _laneService.getLanesByPlazaId(plazaId);
      log('Received lanes: ${lanes.length}');

      _existingLanes = List<Lane>.from(lanes);
      log('Updated existingLanes length: ${_existingLanes.length}');

      notifyListeners();
    } catch (e) {
      log('Error fetching lanes: $e');
      throw PlazaException('Failed to fetch lanes: $e');
    }
  }

  Future<void> updateExistingLane(Lane lane) async {
    try {
      await _laneService.updateLane(lane);
      notifyListeners();
    } catch (e) {
      log('Error updating lane: $e');
    }
  }

  Future<void> fetchUserPlazas(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _userPlazas = await _plazaService.fetchUserPlazas(userId);
    } catch (e) {
      log('Error in fetchUserPlazas: $e');
      _error = e is Exception ? e : Exception('Unknown error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> registerPlaza() async {
    try {
      _isLoading = true;
      notifyListeners();
      log('Plaza details: ${formState.basicDetails}');

      String formatCoordinate(String? value) {
        if (value == null || value.isEmpty) return "0.00000000";
        double coord = double.tryParse(value) ?? 0.0;
        return coord.toStringAsFixed(8);
      }

      final plaza = Plaza(
        plazaName: formState.basicDetails['plazaName'] ?? '',
        plazaOwner: formState.basicDetails['plazaOwner'] ?? '',
        plazaOwnerId: formState.basicDetails['ownerId'] ?? '',
        plazaOperatorName: formState.basicDetails['operatorName'] ?? '',
        plazaOperatorId: formState.basicDetails['operatorId'] ?? '',
        mobileNumber: formState.basicDetails['mobileNumber'] ?? '',
        email: formState.basicDetails['email'] ?? '',
        address: formState.basicDetails['address'] ?? '',
        city: formState.basicDetails['city'] ?? '',
        district: formState.basicDetails['district'] ?? '',
        state: formState.basicDetails['state'] ?? '',
        pincode: formState.basicDetails['pincode'] ?? '',
        geoLatitude: double.parse(formatCoordinate(formState.basicDetails['latitude'])),
        geoLongitude: double.parse(formatCoordinate(formState.basicDetails['longitude'])),
        noOfParkingSlots: int.tryParse(formState.basicDetails['totalParkingSlots'] ?? '') ?? 0,
        capacityTwoWheeler: int.tryParse(formState.basicDetails['twoWheelerCapacity'] ?? '') ?? 0,
        capacityFourLMV: int.tryParse(formState.basicDetails['lmvCapacity'] ?? '') ?? 0,
        capacityFourLCV: int.tryParse(formState.basicDetails['lcvCapacity'] ?? '') ?? 0,
        capacityHMV: int.tryParse(formState.basicDetails['hmvCapacity'] ?? '') ?? 0,
        plazaOpenTimings: formState.basicDetails['openingTime'] ?? '',
        plazaClosingTime: formState.basicDetails['closingTime'] ?? '',
        plazaCategory: formState.basicDetails['plazaCategory'] ?? '',
        plazaSubCategory: formState.basicDetails['plazaSubCategory'] ?? '',
        structureType: formState.basicDetails['structureType'] ?? '',
        plazaStatus: formState.basicDetails['plazaStatus'] ?? '',
        freeParking: formState.basicDetails['freeParking'] ?? false,
        priceCategory: formState.basicDetails['priceCategory'] ?? '',
      );

      final plazaId = await _plazaService.addPlaza(plaza);
      log('Plaza ID: $plazaId');
      _plazaId = plazaId;
      notifyListeners();

      return true;
    } catch (e) {
      _error = e is Exception ? e : Exception('Error registering plaza: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updatePlaza() async {
    try {
      _isLoading = true;
      notifyListeners();

      String formatCoordinate(String? value) {
        if (value == null || value.isEmpty) return "0.00000000";
        double coord = double.tryParse(value) ?? 0.0;
        return coord.toStringAsFixed(8);
      }

      final updatedPlaza = Plaza(
        plazaName: formState.basicDetails['plazaName'] ?? '',
        plazaOwner: formState.basicDetails['plazaOwner'] ?? '',
        plazaOwnerId: formState.basicDetails['ownerId'] ?? '',
        plazaOperatorName: formState.basicDetails['operatorName'] ?? '',
        plazaOperatorId: formState.basicDetails['operatorId'] ?? '',
        mobileNumber: formState.basicDetails['mobileNumber'] ?? '',
        email: formState.basicDetails['email'] ?? '',
        address: formState.basicDetails['address'] ?? '',
        city: formState.basicDetails['city'] ?? '',
        district: formState.basicDetails['district'] ?? '',
        state: formState.basicDetails['state'] ?? '',
        pincode: formState.basicDetails['pincode'] ?? '',
        geoLatitude: double.parse(formatCoordinate(formState.basicDetails['latitude'])),
        geoLongitude: double.parse(formatCoordinate(formState.basicDetails['longitude'])),
        noOfParkingSlots: int.tryParse(formState.basicDetails['totalParkingSlots'] ?? '') ?? 0,
        capacityTwoWheeler: int.tryParse(formState.basicDetails['twoWheelerCapacity'] ?? '') ?? 0,
        capacityFourLMV: int.tryParse(formState.basicDetails['lmvCapacity'] ?? '') ?? 0,
        capacityFourLCV: int.tryParse(formState.basicDetails['lcvCapacity'] ?? '') ?? 0,
        capacityHMV: int.tryParse(formState.basicDetails['hmvCapacity'] ?? '') ?? 0,
        plazaOpenTimings: formState.basicDetails['openingTime'] ?? '',
        plazaClosingTime: formState.basicDetails['closingTime'] ?? '',
        plazaCategory: formState.basicDetails['plazaCategory'] ?? '',
        plazaSubCategory: formState.basicDetails['plazaSubCategory'] ?? '',
        structureType: formState.basicDetails['structureType'] ?? '',
        plazaStatus: formState.basicDetails['plazaStatus'] ?? '',
        freeParking: formState.basicDetails['freeParking'] ?? false,
        priceCategory: formState.basicDetails['priceCategory'] ?? '',
      );

      final success = await _plazaService.updatePlaza(updatedPlaza, _plazaId!);

      return success;
    } catch (e) {
      _error = e is Exception ? e : Exception('Error updating plaza: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deletePlaza(String plazaId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _plazaService.deletePlaza(plazaId);
      _userPlazas.removeWhere((plaza) => plaza.plazaId == plazaId);
      return true;
    } catch (e) {
      _error = e is Exception ? e : Exception('Failed to delete plaza: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addBankDetails() async {
    try {
      final bank = Bank(
        plazaId: _plazaId!,
        bankName: formState.bankDetails['bankName'],
        accountNumber: formState.bankDetails['accountNumber'],
        accountHolderName: formState.bankDetails['accountHolderName'],
        ifscCode: formState.bankDetails['ifscCode'],
      );
      final success = await _bankService.addBankDetails(bank);

      if (success) {
        log("Bank Details Added Successfully");
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = Exception('Error adding bank details: $e');
      log("Error adding bank details: $e");
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateBankDetails() async {
    try {
      final bank = Bank(
        id: formState.bankDetails['id'],
        plazaId: _plazaId!,
        bankName: formState.bankDetails['bankName'],
        accountNumber: formState.bankDetails['accountNumber'],
        accountHolderName: formState.bankDetails['accountHolderName'],
        ifscCode: formState.bankDetails['ifscCode'],
      );
      final success = await _bankService.updateBankDetails(bank);

      return success;
    } catch (e) {
      _error = Exception('Error updating bank details: $e');
      log("Error updating bank details: $e");
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteBankDetails(String id) async {
    try {
      log("Deleting Bank Details with ID: $id");
      final success = await _bankService.deleteBankDetails(id);
      if (success) {
        log("Bank Details Deleted Successfully");
        formState.bankDetails.clear();
        notifyListeners();
      } else {
        throw Exception("Failed to delete bank details");
      }
    } catch (e) {
      _error = Exception('Error deleting bank details: $e');
      log("Error deleting bank details: $e");
      notifyListeners();
    }
  }

  void clearErrors() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    plazaNameController.dispose();
    plazaOwnerController.dispose();
    operatorNameController.dispose();
    operatorIdController.dispose();
    mobileController.dispose();
    emailController.dispose();
    addressController.dispose();
    cityController.dispose();
    districtController.dispose();
    stateController.dispose();
    pincodeController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    totalParkingSlotsController.dispose();
    twoWheelerCapacityController.dispose();
    lmvCapacityController.dispose();
    lcvCapacityController.dispose();
    hmvCapacityController.dispose();
    openingTimeController.dispose();
    closingTimeController.dispose();
    formState.basicDetails.clear();
    super.dispose();
  }
}