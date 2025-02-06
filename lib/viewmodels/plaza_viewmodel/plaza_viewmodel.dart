import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:merchant_app/services/bank_service.dart';
import 'package:merchant_app/services/image_service.dart';
import 'package:merchant_app/services/lane_service.dart';
import 'package:merchant_app/viewmodels/plaza_viewmodel/plaza_form_validation.dart';
import 'package:merchant_app/viewmodels/plaza_viewmodel/restoration_helper.dart';
import '../../config/api_config.dart';
import '../../models/bank.dart';
import '../../models/lane.dart';
import '../../models/plaza.dart';
import '../../models/user_model.dart';
import '../../services/plaza_service.dart';
import '../../services/secure_storage_service.dart';
import '../../utils/exceptions.dart';

class PlazaFormState {
  final PlazaFormValidation formValidation = PlazaFormValidation();
  final Map<String, String?> errors = {};

  // Consolidate all fields into basicDetails
  Map<String, dynamic> basicDetails = {};
  Map<String, dynamic> laneDetails = {};
  Map<String, dynamic> bankDetails = {};
  List<String> fetchedImages = []; // Existing list of image URLs
  List<String> plazaImages = []; // Used for UI display
  Map<String, String> imageIds =
      {}; // New map to store image URLs and their IDs

  bool validateStep(int step) {
    errors.clear(); // Clear previous errors for the step

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
  final formValidation = PlazaFormValidation();

  int _currentStep = 0;
  int _completeTillStep = -1;

  // API-related state
  List<Plaza> _userPlazas = [];
  final Map<String, String> plazaImages =
      {}; // Store plaza ID and corresponding image URL
  bool _isLoading = false;
  String? _error;
  String? _plazaId;
  final List<Lane> _temporaryLanes = []; // To store newly added lanes
  late List<Lane> _existingLanes = []; // To store existing lanes from the backend
  List<Lane> lanes = [];


  List<Lane> get temporaryLanes => List.unmodifiable(_temporaryLanes);
  List<Lane> get existingLanes => List.unmodifiable(_existingLanes);

  // Step 1: Basic Details
  bool _isBasicDetailsEditable = false;

  bool get isBasicDetailsEditable => _isBasicDetailsEditable;

  bool _isBasicDetailsFirstTime = true;

  bool get isBasicDetailsFirstTime => _isBasicDetailsFirstTime;

  // Step 2: Lane Details
  bool _isLaneEditable = false;

  bool get isLaneEditable => _isLaneEditable;

  bool _isLaneDetailsFirstTime = true;

  bool get isLaneDetailsFirstTime => _isLaneDetailsFirstTime;

  bool _isBankEditable = false; // Tracks edit mode for Step 3
  bool get isBankEditable => _isBankEditable;

  bool _isBankDetailsFirstTime = true; // Tracks first-time entry for Step 3
  bool get isBankDetailsFirstTime => _isBankDetailsFirstTime;

  final Map<String, dynamic> _laneDetails = {};

  Map<String, dynamic> get laneDetails => _laneDetails;

  // Step completion flags
  bool _isBasicDetailsCompleted = false;
  bool _isLaneDetailsCompleted = false;
  bool _isBankDetailsCompleted = false;
  bool _isPlazaImagesCompleted = false;

  // Controllers for form fields
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


  // Getters
  List<Plaza> get userPlazas => _userPlazas;

  bool get isLoading => _isLoading;

  String? get error => _error;

  String? get plazaId => _plazaId;

  int get currentStep => _currentStep;

  int get completeTillStep => _completeTillStep;

  bool get isBasicDetailsCompleted => _isBasicDetailsCompleted;

  bool get isLaneDetailsCompleted => _isLaneDetailsCompleted;

  bool get isBankDetailsCompleted => _isBankDetailsCompleted;

  bool get isPlazaImagesCompleted => _isPlazaImagesCompleted;

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

  // Initialize controllers
  void initControllers() async {
    final cachedUserData = await _secureStorageService.getUserData();
    if (cachedUserData == null) {
      return;
    }

    var currentUser = User.fromJson(cachedUserData);
    print(currentUser.toString());

    // Set text for existing controller instead of creating new one
    if (currentUser.role == "Plaza Owner") {
      formState.basicDetails['plazaOwner'] =
          currentUser.entityName?.trim() ?? '';
      formState.basicDetails['ownerId'] = currentUser.id.trim();
      plazaOwnerController.text =
          '${currentUser.entityName?.trim()} (ID:${currentUser.id.trim()})';
    } else {
      formState.basicDetails['plazaOwner'] =
          plazaOwnerController.text = currentUser.entityName?.trim() ?? '';
      formState.basicDetails['ownerId'] = currentUser.entityId?.trim() ?? '';
      plazaOwnerController.text =
          '${currentUser.entityName?.trim()} (ID:${currentUser.entityId?.trim()})';
    }

    _completeTillStep = -1;

    addListeners();
  }

  void addListeners() {
    plazaNameController.addListener(() {
      formState.basicDetails['plazaName'] = plazaNameController.text.trim();
    });

    operatorNameController.addListener(() {
      formState.basicDetails['operatorName'] =
          operatorNameController.text.trim();
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

    // Capacity fields
    totalParkingSlotsController.addListener(() {
      formState.basicDetails['totalParkingSlots'] =
          totalParkingSlotsController.text.trim();
    });
    twoWheelerCapacityController.addListener(() {
      formState.basicDetails['twoWheelerCapacity'] =
          twoWheelerCapacityController.text.trim();
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

    // Timing fields
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
      formState.bankDetails['accountNumber'] =
          accountNumberController.text.trim();
    });
    accountHolderController.addListener(() {
      formState.bankDetails['accountHolderName'] =
          accountHolderController.text.trim();
    });
    ifscCodeController.addListener(() {
      formState.bankDetails['ifscCode'] = ifscCodeController.text.trim();
    });
  }

  void validateBasicDetailsStep() {
    print('Basic Details Before Validation: ${formState.basicDetails}');
    formState.errors.clear();

    final validationError = formValidation.validateBasicDetails(
      formState.basicDetails,
      formState.errors,
    );

    _isBasicDetailsCompleted = validationError == null;

    print('Validation Errors: ${formState.errors}');
    notifyListeners();
  }

  void validateBankDetailsStep() {
    print('Bank Details Before Validation: ${formState.bankDetails}');
    formState.errors.clear();

    // Use the updated validateBankDetails method
    formValidation.validateBankDetails(formState.bankDetails, formState.errors);

    _isBankDetailsCompleted = formState.errors.isEmpty;

    print('Validation Errors: ${formState.errors}');
    notifyListeners();
  }

  String? validateLaneDetailsStep() {
    print('Lane Details Before Validation: $_laneDetails');
    formState.errors.clear();

    final validationResult = formValidation.validateLaneDetails(_laneDetails, formState.errors);
    _isLaneDetailsCompleted = formState.errors.isEmpty;

    print('Validation Errors: ${formState.errors}');
    notifyListeners();
    return validationResult;
  }

  // Form validation
  void validateStepCompletion() {
    switch (_currentStep) {
      case 0:
        validateBasicDetailsStep();
        break;
      case 1:
        // Add Lane Details validation logic
        break;
      case 2:
        validateBankDetailsStep();
        break;
      case 3:
        // Add Plaza Images validation logic
        break;
    }
    notifyListeners();
  }

  // Navigation methods
  void goToStep(int step) {
    if (step <= _completeTillStep + 1) {
      _currentStep = step;
      // If going to lane details step (step 1), fetch lanes
      if (step == 1 && plazaId != null) {
        print('Fetching lanes for plaza: $plazaId'); // Debug print
        fetchExistingLanes(plazaId!);
      }
      notifyListeners();
    }
  }

  // Complete Step 1 (Basic Details)
  void completeBasicDetails() {
    _isBasicDetailsFirstTime = false;
    _isBasicDetailsEditable = false;
    if (_completeTillStep < 0) _completeTillStep = 0; // Update progress
    notifyListeners();
  }

// Complete Step 2 (Lane Details)
  void completeLaneDetails() {
    _isLaneDetailsFirstTime = false;
    _isLaneEditable = false;
    if (_completeTillStep < 1) _completeTillStep = 1; // Update progress
    notifyListeners();
  }

// Move to the next step
  void nextStep() {
    if (_currentStep < 3) {
      _currentStep++;
      if (_currentStep > _completeTillStep) {
        _completeTillStep = _currentStep; // Ensure step is marked as completed
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

      print('ViewModel: Fetching lanes for Plaza ID: $plazaId');
      final newLanes = await _laneService.getLanesByPlazaId(plazaId);
      print('Fetched lanes: $newLanes');

      lanes = newLanes;
      _error = null;
    } catch (e) {
      _error = e.toString();
      print('Error in fetchLanes: $e');
      lanes = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addLane(List<Lane> lanes) async {
    try {
      // Send the array of lanes to the service
      final newLaneId = await _laneService.addLane(lanes);

      // Update the local data or refresh the UI
      for (var lane in lanes) {
        lane.laneId = newLaneId;
      }
      notifyListeners(); // Notify listeners to refresh UI
    } catch (e) {
      print(e.toString());
      _error = 'Error adding lanes: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> updateLane(String laneId, Lane updatedLane) async {
    try {
      // Update the lane using the service layer
      final success = await _laneService.updateLane(updatedLane);

      if (success) {
        notifyListeners(); // Notify listeners to update UI
      } else {
        _error = 'Failed to update lane';
      }
    } catch (e) {
      _error = 'Error updating lane: ${e.toString()}';
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
      // Save the current state before editing
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
    _isLaneEditable = !_isLaneEditable; // Toggle the edit mode
    notifyListeners();
  }

  // When enabling edit mode for Bank Details
  void toggleBankEditable() {
    if (!isBankEditable) {
      // Save the current state before editing
      RestorationHelper.saveOriginalBankDetails(formState.bankDetails);
    }
    _isBankEditable = !_isBankEditable;
    notifyListeners();
  }

  // When canceling changes for Bank Details
  void cancelBankDetailsEdit() {
    RestorationHelper.restoreBankDetails(formState.bankDetails);
    _populateBankDetailsControllers();
    _isBankEditable = false;
    notifyListeners();
  }

  void setLaneDetailsCompleted() {
    _isLaneDetailsFirstTime = false; // Mark Lane Details as completed
    notifyListeners();
  }

  Future<void> saveBankDetails(BuildContext context, {bool? modify}) async {
    print("Bank Details before validation: ${formState.bankDetails}");
    validateBankDetailsStep();

    if (!_isBankDetailsCompleted) {
      print("Validation failed: ${formState.errors}");
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

    print("Prepared Bank Details: $bankDetails");

    print(isBankEditable);

    try {
      String operation = "added";
      bool isOperationSuccessful = false;

      if (modify == true) {
        print("Updating existing Bank Details...");
        isOperationSuccessful = await updateBankDetails();
        if (isOperationSuccessful) {
          toggleBankEditable();
          operation = "updated";
        }
      } else if (_isBankDetailsFirstTime) {
        print("Adding new Bank Details...");
        isOperationSuccessful = await addBankDetails();
        if (isOperationSuccessful) {
          completeBankDetails();
        }
      } else if (_isBankEditable) {
        print("Updating existing Bank Details...");
        isOperationSuccessful = await updateBankDetails();
        if (isOperationSuccessful) {
          toggleBankEditable();
          operation = "updated";
        }
      } else {
        print("Toggling edit mode...");
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
        showSnackBar(
            context, 'Failed to $operation bank details. Please try again.');
      }
    } catch (e) {
      print("Error in saveBankDetails: $e");
      showSnackBar(context, 'Error: Failed to save Bank Details: $e');
    }
  }
  // Save all lanes
  Future<void> saveLanes(String plazaId) async {
    try {
      if (_isLaneDetailsFirstTime) {
        if (_temporaryLanes.isNotEmpty) {
          await _laneService.addLane(_temporaryLanes);
          _temporaryLanes.clear();
        }
        _isLaneDetailsFirstTime = false;
        await fetchExistingLanes(plazaId); // Refresh existing lanes
        nextStep();
      } else if (_isLaneEditable) {
        if (_temporaryLanes.isNotEmpty) {
          await _laneService.addLane(_temporaryLanes);
          _temporaryLanes.clear();
        }
        await fetchExistingLanes(plazaId); // Refresh existing lanes
        toggleLaneEditable();
        nextStep();
      } else {
        toggleLaneEditable();
      }
      notifyListeners();
    } catch (e) {
      print('Error saving lanes: $e');
    }
  }

  Future<void> saveBasicDetails(BuildContext context) async {
    validateStepCompletion(); // Validate Step 0
    if (!isBasicDetailsCompleted) {
      print("Validation failed: ${formState.errors}");
      showSnackBar(context, 'Please correct the errors in Basic Details.');
      return;
    }

    try {
      String operation = "added";
      bool isOperationSuccessful = false;

      if (_isBasicDetailsFirstTime) {
        print("Adding new Basic Details...");
        isOperationSuccessful = await registerPlaza(); // Add a new plaza
        if (!isOperationSuccessful) {
          showSnackBar(context,
              'API Error: Failed to register plaza. Please try again.');
          return;
        }
        completeBasicDetails();
        operation = "added";
      } else if (_isBasicDetailsEditable) {
        print("Updating existing Basic Details...");
        isOperationSuccessful = await updatePlaza(); // Save updates
        if (!isOperationSuccessful) {
          showSnackBar(
              context, 'API Error: Failed to update plaza. Please try again.');
          return;
        }
        completeBasicDetails();
        operation = "updated";
      } else {
        print("Toggling edit mode...");
        toggleBasicDetailsEditable();
        return;
      }

      // Only show success dialog if API call succeeded
      await showSuccessDialog(
        context,
        title: "Success",
        message: "Basic details have been successfully $operation.",
        onConfirmed: () {
          nextStep();
        },
      );
    } catch (e) {
      print("Error in saveBasicDetails: $e");
      showSnackBar(context, 'API Error: Failed to save Basic Details: $e');
    }
  }

  Future<void> updateBasicDetails(BuildContext context) async {
    validateStepCompletion(); // Validate the form data
    if (!isBasicDetailsCompleted) {
      showSnackBar(context, 'Please correct the errors in Basic Details.');
      return;
    }

    try {
      print("Updating existing plaza with ID: $_plazaId...");
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
      print("Error picking images: $e");
      throw Exception('Failed to pick images. Please try again.');
    }
  }

  Future<void> saveImages(BuildContext context, {bool wantPop = true}) async {
    try {
      // Only upload new images
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

      formState.fetchedImages
          .addAll(newImages); // Merge new images with fetched images

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
      final validIds = plazaIds.whereType<String>().toList();

      final fetchTasks = validIds.map((plazaId) async {
        if (plazaImages.containsKey(plazaId)) return;

        try {
          final imageDataList = await _imageService.getImagesByPlazaId(plazaId);

          // Clear previous data
          formState.fetchedImages.removeWhere((url) => url.startsWith(plazaId));
          formState.imageIds.clear();

          if (imageDataList.isNotEmpty) {
            // Process new images
            for (var imageData in imageDataList) {
              final url = imageData['imageUrl'];
              final imageId = imageData['imageId'];

              formState.fetchedImages.add(url);
              formState.imageIds[url] = imageId;
            }

            // Store first image for thumbnail
            plazaImages[plazaId] = imageDataList.first['imageUrl'];
          } else {
            plazaImages[plazaId] = '';
          }
        } catch (e) {
          plazaImages[plazaId] = '';
        }
      });

      await Future.wait(fetchTasks);
      notifyListeners();
    } catch (e) {
      _error = 'Image load failed: ${e.toString()}';
      notifyListeners();
    }
  }

  void removeImage(String imageUrl) async {
    final index = formState.plazaImages.indexOf(imageUrl);
    if (index != -1) {
      String? imageId = formState.fetchedImages.contains(imageUrl)
          ? formState.imageIds[imageUrl] // Fetch stored ID
          : null;

      if (imageId != null) {
        await _imageService.deleteImage(imageId);
      }
      formState.plazaImages.removeAt(index);
      notifyListeners();
    }
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
  // Complete Bank Details Step
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
    required String message, VoidCallback? onConfirmed,
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
                Navigator.of(context).pop(); // Close the dialog
                onConfirmed!(); // Execute the callback
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

// Helper function to parse and format time
  String formatTime(String? time) {
    print("Formatting time: $time");
    if (time == null || time.isEmpty) return ''; // Handle null/empty time
    try {
      final parsedTime = DateFormat('HH:mm:ss').parse(time); // Backend format
      final formattedTime = DateFormat('HH:mm').format(parsedTime);
      print("Formatted Time: $formattedTime");
      return formattedTime;
    } catch (e) {
      print("Error formatting time: $e");
      return ''; // Fallback if parsing fails
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
    print('Starting fetchPlazaDetailsById for plaza: $plazaId');
    resetState(); // Reset state before fetching new data
    print('State reset completed');

    try {
      _isLoading = true;
      notifyListeners();
      print('Loading state set to true');

      // Fetch Plaza Details
      Plaza? plaza;
      try {
        print('Attempting to fetch plaza details...');
        plaza = await _plazaService.getPlazaById(plazaId);
        print('Successfully fetched plaza details');
      } catch (e) {
        print('Error fetching plaza details: $e');
        throw Exception('Failed to fetch plaza details: $e');
      }

      // Fetch Images
      List<dynamic> images = [];
      try {
        print('Attempting to fetch plaza images...');
        images = await _imageService.getImagesByPlazaId(plazaId);
        print('Successfully fetched ${images.length} images');
      } catch (e) {
        print("Error fetching images: $e");
        // Proceed without images, but log the error
      }

      // Clear previous image data
      print('Clearing previous image data');
      formState.fetchedImages.clear();
      formState.imageIds.clear();

      // Process fetched images
      print('Processing fetched images...');
      final String baseUrl = ApiConfig.getFullUrl(''); // Use ApiConfig to get base URL
      String? imageUrl;
      for (var image in images) {
        try {
          String relativePath = image['imageUrl']?.toString() ?? '';

          // Add this validation:
          if (relativePath.startsWith(baseUrl)) {
            // If server returns full URL, use directly
            imageUrl = relativePath;
          } else {
            // Handle relative paths
            imageUrl = '$baseUrl${relativePath.startsWith('/') ? relativePath : '/$relativePath'}';
          }

          String imageId = image['imageId']?.toString() ?? '';
          if (imageUrl.isNotEmpty && imageId.isNotEmpty) {
            formState.fetchedImages.add(imageUrl);
            formState.imageIds[imageUrl] = imageId;
          }
        } catch (e) {
          print("Error processing image data: $e");
        }
      }
      formState.plazaImages = List.from(formState.fetchedImages);
      print('Finished processing ${formState.fetchedImages.length} valid images');

      _plazaId = plazaId;
      print('Setting plaza basic details...');

      formState.basicDetails.addAll({
        'plazaName': plaza.plazaName,
        'plazaId' : plaza.plazaId,
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
        'openingTime': plaza.plazaOpenTimings,    // Added opening time
        'closingTime': plaza.plazaClosingTime,    // Added closing time
      });
      print('Basic details set successfully');

      // Fetch Bank Details
      print('Attempting to fetch bank details...');
      await _fetchBankDetails(plazaId);
      print('Bank details fetched successfully');

      // Update UI Controllers
      print('Updating UI controllers...');
      _populateBasicDetailsControllers();
      _populateBankDetailsControllers();
      print('UI controllers updated successfully');

    } catch (e) {
      print('Error in fetchPlazaDetailsById: $e');
      _error = 'Failed to fetch plaza details: ${e.toString()}';
      // Reset partial state on error
      print('Resetting state due to error');
      resetState();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
      print('fetchPlazaDetailsById completed. Loading state set to false');
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
      if (e.message.contains('404')) {
        // Handle optional bank details without error
        formState.bankDetails.addAll({
          'bankName': '',
          'accountNumber': '',
          'accountHolderName': '',
          'ifscCode': ''
        });
        _error = null; // Clear any previous error
      } else {
        _error = 'Bank details error: ${e.message}';
      }
    } catch (e) {
      _error = 'Unexpected error: $e';
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
    totalParkingSlotsController.text =
        formState.basicDetails['totalParkingSlots'] ?? '';
    twoWheelerCapacityController.text =
        formState.basicDetails['twoWheelerCapacity'] ?? '';
    lmvCapacityController.text = formState.basicDetails['lmvCapacity'] ?? '';
    lcvCapacityController.text = formState.basicDetails['lcvCapacity'] ?? '';
    hmvCapacityController.text = formState.basicDetails['hmvCapacity'] ?? '';
    openingTimeController.text = formState.basicDetails['openingTime'] ?? '';
    closingTimeController.text = formState.basicDetails['closingTime'] ?? '';
    notifyListeners();
  }

  void _populateBankDetailsControllers() {
    bankNameController.text = formState.bankDetails['bankName'];
    accountNumberController.text = formState.bankDetails['accountNumber'];
    accountHolderController.text = formState.bankDetails['accountHolderName'];
    ifscCodeController.text = formState.bankDetails['ifscCode'];
    notifyListeners();
  }

  Future<void> fetchExistingLanes(String plazaId) async {
    try {
      print('Starting fetchExistingLanes for plaza: $plazaId');
      // Instead of just clearing and then adding, directly assign the new list
      final lanes = await _laneService.getLanesByPlazaId(plazaId);
      print('Received lanes: ${lanes.length}');

      _existingLanes = List<Lane>.from(lanes); // Replace instead of add
      print('Updated existingLanes length: ${_existingLanes.length}');

      notifyListeners();
    } catch (e) {
      print('Error fetching lanes: $e');
      throw PlazaException('Failed to fetch lanes: $e');
    }
  }

  // Update an existing lane
  Future<void> updateExistingLane(Lane lane) async {
    try {
      await _laneService.updateLane(lane);
      notifyListeners();
    } catch (e) {
      print('Error updating lane: $e');
    }
  }

  // API Methods
  Future<void> fetchUserPlazas(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _userPlazas = await _plazaService.fetchUserPlazas(userId);
    } catch (e) {
      print(e.toString());
      _error = e is PlazaException || e is HttpException
          ? e.toString()
          : 'Failed to fetch plazas: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> registerPlaza() async {
    print("Step1");
    try {
      _isLoading = true;
      notifyListeners();
      print("step2");
      print('Plaza details: ${formState.basicDetails}');

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
        geoLatitude: double.parse(
            formatCoordinate(formState.basicDetails['latitude'])
        ),
        geoLongitude: double.parse(
            formatCoordinate(formState.basicDetails['longitude'])
        ),
        noOfParkingSlots:
            int.tryParse(formState.basicDetails['totalParkingSlots'] ?? '') ??
                0,
        capacityTwoWheeler:
            int.tryParse(formState.basicDetails['twoWheelerCapacity'] ?? '') ??
                0,
        capacityFourLMV:
            int.tryParse(formState.basicDetails['lmvCapacity'] ?? '') ?? 0,
        capacityFourLCV:
            int.tryParse(formState.basicDetails['lcvCapacity'] ?? '') ?? 0,
        capacityHMV:
            int.tryParse(formState.basicDetails['hmvCapacity'] ?? '') ?? 0,
        plazaOpenTimings: formState.basicDetails['openingTime'] ?? '',
        plazaClosingTime: formState.basicDetails['closingTime'] ?? '',
        plazaCategory: formState.basicDetails['plazaCategory'] ?? '',
        plazaSubCategory: formState.basicDetails['plazaSubCategory'] ?? '',
        structureType: formState.basicDetails['structureType'] ?? '',
        plazaStatus: formState.basicDetails['plazaStatus'] ?? '',
        freeParking: formState.basicDetails['freeParking'] ?? false,
        priceCategory: formState.basicDetails['priceCategory'] ?? '',
      );

      print("Step3");
      // Call addPlaza and get the plazaId
      final plazaId = await _plazaService.addPlaza(plaza);
      print(plazaId);
      _plazaId = plazaId; // Store plazaId in the ViewModel
      notifyListeners();

      return true;
    } catch (e) {
      _error = e.toString();
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
        geoLatitude: double.parse(
            formatCoordinate(formState.basicDetails['latitude'])
        ),
        geoLongitude: double.parse(
            formatCoordinate(formState.basicDetails['longitude'])
        ),
        noOfParkingSlots:
            int.tryParse(formState.basicDetails['totalParkingSlots'] ?? '') ??
                0,
        capacityTwoWheeler:
            int.tryParse(formState.basicDetails['twoWheelerCapacity'] ?? '') ??
                0,
        capacityFourLMV:
            int.tryParse(formState.basicDetails['lmvCapacity'] ?? '') ?? 0,
        capacityFourLCV:
            int.tryParse(formState.basicDetails['lcvCapacity'] ?? '') ?? 0,
        capacityHMV:
            int.tryParse(formState.basicDetails['hmvCapacity'] ?? '') ?? 0,
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
      _error = e.toString();
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
      _error = e is PlazaException || e is HttpException
          ? e.toString()
          : 'Failed to delete plaza: ${e.toString()}';
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
        print("Bank Details Added Successfully");
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      print("Error adding bank details: $e");
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
      _error = e.toString();
      print("Error updating bank details: $e");
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteBankDetails(String id) async {
    try {
      print("Deleting Bank Details with ID: $id");
      final success = await _bankService.deleteBankDetails(id);
      if (success) {
        print("Bank Details Deleted Successfully");
        formState.bankDetails.clear(); // Clear local data
        notifyListeners();
      } else {
        throw Exception("Failed to delete bank details");
      }
    } catch (e) {
      _error = e.toString();
      print("Error deleting bank details: $e");
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
    formState.basicDetails.clear(); // Clear state to avoid residual values
    super.dispose();
  }
}
