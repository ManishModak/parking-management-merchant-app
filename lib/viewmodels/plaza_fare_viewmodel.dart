import 'dart:async';
import 'dart:convert'; // Import for jsonEncode used in logging
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Make sure these paths are correct for your project structure
import '../generated/l10n.dart';
import '../models/plaza.dart';
import '../models/plaza_fare.dart';
import '../services/core/plaza_service.dart';
import '../services/payment/fare_service.dart';
import '../services/storage/secure_storage_service.dart';
import '../utils/exceptions.dart'; // Assuming ServiceException, etc. are here

class PlazaFareViewModel extends ChangeNotifier {
  final PlazaService _plazaService;
  final FareService _fareService;
  final SecureStorageService _storageService;

  // --- Constants ---
  static const String _logName = 'PlazaFareViewModel'; // Consistent log name

  PlazaFareViewModel({
    PlazaService? plazaService,
    FareService? fareService,
    SecureStorageService? storageService,
  })  : _plazaService = plazaService ?? PlazaService(),
        _fareService = fareService ?? FareService(),
        _storageService = storageService ?? SecureStorageService();

  // --- State Variables ---
  bool _isLoading = false;
  bool _isLoadingFare = false; // Specific loading state for fetching/updating a single fare
  bool _isUpdating = false; // Specific state for when an update operation is in progress
  bool _isPlazaPreSelected = false; // Flag to track if plaza was passed initially

  Plaza? _selectedPlaza;
  int? _selectedPlazaIdInt; // Store the parsed Int ID for creating PlazaFare objects
  String? _selectedFareType;
  String? _selectedVehicleType;

  List<Plaza> _plazaList = [];
  final List<PlazaFare> _temporaryFares = []; // Fares staged before submitting
  List<PlazaFare> _existingFares = []; // Fares already saved for the selected plaza
  Map<String, dynamic>? _createdBy; // User data for auditing

  Map<String, String?> validationErrors = {}; // Stores validation errors for form fields

  // --- Controllers ---
  final TextEditingController dailyFareController = TextEditingController();
  final TextEditingController hourlyFareController = TextEditingController();
  final TextEditingController baseHoursController = TextEditingController();
  final TextEditingController baseHourlyFareController = TextEditingController();
  final TextEditingController monthlyFareController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController plazaController = TextEditingController(); // Displays selected plaza name
  // NEW Controllers for Progressive Fare Type
  final TextEditingController fromController = TextEditingController();
  final TextEditingController toCustomController = TextEditingController();
  final TextEditingController progressiveFareController = TextEditingController(); // For the "Fare" field in Progressive

  // --- Getters ---
  bool get isLoading => _isLoading;
  bool get isLoadingFare => _isLoadingFare;
  bool get isUpdating => _isUpdating;
  bool get isPlazaPreSelected => _isPlazaPreSelected;

  String? get selectedFareType => _selectedFareType;
  String? get selectedVehicleType => _selectedVehicleType;
  Plaza? get selectedPlaza => _selectedPlaza;
  String? get selectedPlazaIdString => _selectedPlaza?.plazaId; // Get the String ID
  int? get selectedPlazaIdAsInt => _selectedPlazaIdInt; // Get the parsed Int ID

  List<Plaza> get plazaList => _plazaList;
  List<PlazaFare> get temporaryFares => _temporaryFares;
  List<PlazaFare> get existingFares => _existingFares;
  Map<String, dynamic>? get createdBy => _createdBy;

  List<String> get fareTypes => FareTypes.values;
  List<String> get vehicleTypes => VehicleTypes.values;

  // --- Computed Properties (for UI logic) ---
  bool get isProgressiveFareVisible => _selectedFareType == FareTypes.progressive;
  bool get isFreePassSelected => _selectedFareType == FareTypes.freePass;

  // Modify existing ones to hide if Progressive or FreePass selected
  bool get isDailyFareVisible => _selectedFareType == FareTypes.daily && !isProgressiveFareVisible && !isFreePassSelected;
  bool get isHourlyFareVisible => _selectedFareType == FareTypes.hourly && !isProgressiveFareVisible && !isFreePassSelected;
  bool get isHourWiseCustomVisible => _selectedFareType == FareTypes.hourWiseCustom && !isProgressiveFareVisible && !isFreePassSelected;
  bool get isMonthlyFareVisible => _selectedFareType == FareTypes.monthlyPass && !isProgressiveFareVisible && !isFreePassSelected;

  // Helper to determine if ANY amount field (excluding Progressive's specific ones) should be shown
  bool get shouldShowStandardAmountFields => !isProgressiveFareVisible && !isFreePassSelected;

  bool get canAddFare => _selectedPlaza?.plazaId != null; // Enable adding if a plaza is selected
  bool get canChangePlaza => !_isPlazaPreSelected && _temporaryFares.isEmpty; // Allow changing plaza only if not pre-selected and no temporary fares exist

  // --- Initialization ---
  Future<void> initialize({Plaza? preSelectedPlaza}) async {
    developer.log('Initializing ViewModel... Pre-selected: ${preSelectedPlaza?.plazaId}', name: _logName);
    _setLoading(true);
    // Reset state *before* potentially setting pre-selected plaza
    _resetInternalState(); // Clear previous selections etc.
    _isPlazaPreSelected = false; // Reset pre-selected flag

    try {
      if (preSelectedPlaza != null) {
        developer.log('Pre-selected plaza received: ${preSelectedPlaza.plazaName}', name: _logName);
        setPreSelectedPlaza(preSelectedPlaza); // Set pre-selected plaza data AND flag
      } else {
        // If not pre-selected, ensure plaza state is clear
        resetPlazaSelection();
      }

      await Future.wait([
        _fetchPlazas(), // Fetch available plazas (if needed/not preselected)
        _fetchUserData(), // Get logged-in user info
      ]);
      // If a plaza is selected (pre-selected or otherwise), fetch its existing fares
      if (_selectedPlaza?.plazaId != null) {
        developer.log('Fetching initial fares for selected plaza ID: ${_selectedPlaza!.plazaId!}', name: _logName);
        await fetchExistingFares(_selectedPlaza!.plazaId!);
      } else {
        developer.log('No plaza selected initially, skipping initial fare fetch.', name: _logName);
        _existingFares = []; // Ensure existing fares are clear if no plaza selected
        if (hasListeners) notifyListeners(); // Update UI if needed
      }
    } catch (e, s) { // Catch stack trace
      developer.log('Initialization error: $e', name: _logName, error: e, stackTrace: s);
      _plazaList = [];
      _existingFares = [];
      // Handle initialization error (e.g., show error message via a state variable)
    } finally {
      _setLoading(false);
      developer.log('Initialization complete. Loading: $_isLoading, PreSelected: $_isPlazaPreSelected', name: _logName);
    }
  }

  // --- Data Fetching ---
  Future<void> _fetchPlazas() async {
    // Avoid unnecessary fetches if pre-selected and list likely only contains that one
    if (_isPlazaPreSelected && _plazaList.isNotEmpty && _plazaList.length == 1 && _plazaList[0].plazaId == _selectedPlaza?.plazaId) {
      developer.log('Skipping plaza fetch: Plaza is pre-selected and list likely contains only it.', name: _logName);
      return;
    }
    developer.log('Attempting to fetch plazas...', name: _logName);
    List<Plaza> fetchedPlazas = [];
    try {
      final Map<String, dynamic>? userData = await _storageService.getUserData();
      if (userData != null) {
        final dynamic entityIdValue = userData['entityId'];
        if (entityIdValue != null) {
          final String entityIdString = entityIdValue.toString();
          developer.log('Found entityId: $entityIdString. Fetching plazas...', name: _logName);
          fetchedPlazas = await _plazaService.fetchUserPlazas(entityIdString);
          developer.log('Successfully fetched ${fetchedPlazas.length} plazas.', name: _logName);
        } else {
          developer.log('Could not fetch plazas: entityId key found but value is null in user data.', name: _logName);
        }
      } else {
        developer.log('Could not fetch plazas: User data not found in secure storage.', name: _logName);
      }
    } catch (e, s) {
      developer.log('Error fetching plazas: $e', name: _logName, error: e, stackTrace: s);
      // Rethrow or handle error appropriately
    } finally {
      // Update state only if data changed or if list is empty
      if (fetchedPlazas.isNotEmpty || _plazaList.isNotEmpty) {
        _plazaList = fetchedPlazas;
        if (hasListeners) notifyListeners();
      }
    }
  }

  Future<void> _fetchUserData() async {
    developer.log('Fetching user data...', name: _logName);
    try {
      _createdBy = await _storageService.getUserData();
      developer.log('User data fetched: ${_createdBy != null}', name: _logName);
      // No need to notify unless UI specifically depends on _createdBy directly
    } catch (e, s) {
      developer.log('Error fetching user data: $e', name: _logName, error: e, stackTrace: s);
      _createdBy = null;
    }
  }

  Future<void> fetchExistingFares(String plazaId) async {
    if (_isLoadingFare) {
      developer.log('Skipping fetchExistingFares for $plazaId: Already loading.', name: _logName);
      return;
    }
    developer.log('Fetching existing fares for plazaId: $plazaId', name: _logName);
    setLoadingFare(true); // Use specific loader for this action
    try {
      _existingFares = await _fareService.getFaresByPlazaId(plazaId);
      developer.log('Fetched ${_existingFares.length} existing fares for plazaId: $plazaId.', name: _logName);
    } catch (e, s) {
      developer.log('Error fetching existing fares for plazaId $plazaId: $e', name: _logName, error: e, stackTrace: s);
      _existingFares = []; // Reset on error
      // Handle fetch error (e.g., show message via state variable)
    } finally {
      setLoadingFare(false); // This will notify listeners
    }
  }

  Future<PlazaFare?> getFareById(int fareId) async {
    developer.log('Fetching fare by ID: $fareId', name: _logName);
    setLoadingFare(true);
    try {
      final fare = await _fareService.getFareById(fareId);
      developer.log('Fare fetched for ID $fareId: ${fare != null}', name: _logName);
      return fare;
    } catch (e, s) {
      developer.log('Error fetching fare by ID $fareId: $e', name: _logName, error: e, stackTrace: s);
      return null;
    } finally {
      setLoadingFare(false);
    }
  }

  // --- State Management & UI Interaction ---

  void setSelectedPlaza(Plaza plaza) {
    if (!canChangePlaza) {
      developer.log('Cannot change plaza. Pre-selected: $_isPlazaPreSelected, Temp Fares: ${_temporaryFares.length}', name: _logName);
      return;
    }
    if (plaza.plazaId == null) {
      developer.log('Selected plaza has a null ID. Cannot set.', name: _logName);
      return;
    }

    if (_selectedPlaza?.plazaId != plaza.plazaId) {
      developer.log('Setting selected plaza to: ${plaza.plazaName} (ID: ${plaza.plazaId})', name: _logName);
      _selectedPlaza = plaza;
      plazaController.text = plaza.plazaName!;

      _selectedPlazaIdInt = int.tryParse(plaza.plazaId!);
      if (_selectedPlazaIdInt == null) {
        developer.log('ERROR: Could not parse plazaId "${plaza.plazaId}" to int.', name: _logName);
        validationErrors['plaza'] = 'Invalid Plaza ID format.';
        _selectedPlaza = null;
        plazaController.clear();
        _existingFares = [];
      } else {
        developer.log('Selected Plaza Parsed Int ID: $_selectedPlazaIdInt', name: _logName);
        validationErrors.remove('plaza');
        fetchExistingFares(plaza.plazaId!); // Fetch fares for the new plaza
      }
      notifyListeners();
    } else {
      developer.log('Plaza ${plaza.plazaName} already selected.', name: _logName);
    }
  }

  void setPreSelectedPlaza(Plaza plaza) {
    developer.log('Setting pre-selected plaza: ${plaza.plazaName} (ID: ${plaza.plazaId})', name: _logName);
    if (plaza.plazaId == null) {
      developer.log("ERROR: Pre-selected plaza is missing an ID.", name: _logName);
      return;
    }
    _selectedPlaza = plaza;
    plazaController.text = plaza.plazaName!;

    _selectedPlazaIdInt = int.tryParse(plaza.plazaId!);
    if (_selectedPlazaIdInt == null) {
      developer.log('ERROR: Could not parse pre-selected plazaId "${plaza.plazaId}" to int.', name: _logName);
      _selectedPlaza = null;
      plazaController.text = "Invalid Plaza";
      _isPlazaPreSelected = false; // Treat as invalid selection
    } else {
      developer.log('Pre-selected Plaza Parsed Int ID: $_selectedPlazaIdInt', name: _logName);
      _isPlazaPreSelected = true; // Set flag correctly
      // Ensure plaza list contains the pre-selected one if not fetched
      if (!_plazaList.any((p) => p.plazaId == plaza.plazaId)) {
        _plazaList = [plaza, ..._plazaList]; // Add to start
      }
    }
    // No notifyListeners() here, expect it to be called by initialize() later
  }

  // Resets only the plaza selection part of the state
  void resetPlazaSelection() {
    developer.log('Resetting plaza selection.', name: _logName);
    _selectedPlaza = null;
    _selectedPlazaIdInt = null;
    plazaController.clear();
    _existingFares = [];
    _isPlazaPreSelected = false; // Ensure flag is reset
    validationErrors.remove('plaza');
  }

  void setPlazaName(String plazaName) {
    developer.log('Setting plaza name display: $plazaName (Is PreSelected: $_isPlazaPreSelected)', name: _logName);
    plazaController.text = plazaName;
    // No notifyListeners() needed as this is usually for display only in Edit Screen
  }

  void setFareType(String? fareType) {
    developer.log('Setting Fare Type: $fareType (Previous: $_selectedFareType)', name: _logName);
    if (_selectedFareType != fareType) {
      _selectedFareType = fareType;
      _clearFareAmountFields(); // Clears standard AND progressive amount fields
      // Clear relevant validation errors
      validationErrors.remove('fareType');
      validationErrors.remove('fareRate'); // Generic fareRate error
      validationErrors.remove('dailyFare');
      validationErrors.remove('hourlyFare');
      validationErrors.remove('baseHourlyFare');
      validationErrors.remove('monthlyFare');
      validationErrors.remove('baseHours');
      validationErrors.remove('discount');
      validationErrors.remove('from'); // NEW
      validationErrors.remove('toCustom'); // NEW
      validationErrors.remove('progressiveFare'); // NEW specific error key
      validationErrors.remove('duplicateFare');
      validationErrors.remove('dateOverlap');
      notifyListeners();
    }
  }

  void setVehicleType(String? vehicleType) {
    developer.log('Setting Vehicle Type: $vehicleType (Previous: $_selectedVehicleType)', name: _logName);
    if (_selectedVehicleType != vehicleType) {
      _selectedVehicleType = vehicleType;
      validationErrors.remove('vehicleType');
      validationErrors.remove('duplicateFare');
      validationErrors.remove('dateOverlap');
      notifyListeners();
    }
  }

  // --- Date Selection ---
  Future<void> selectStartDate(BuildContext context) async {
    developer.log('Opening start date picker. Current value: ${startDateController.text}', name: _logName);
    final DateTime initial = startDateController.text.isNotEmpty
        ? (DateTime.tryParse(startDateController.text) ?? DateTime.now())
        : DateTime.now();
    // Allow selecting today as start date
    final DateTime first = DateTime.now(); //.subtract(const Duration(days: 1)); // Allow today
    final DateTime last = DateTime(2101);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(first) ? first : initial, // Default to today if initial is invalid past
      firstDate: first, // Allow selecting today
      lastDate: last,
    );

    if (picked != null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      developer.log('Start date picked: $formattedDate', name: _logName);
      if (startDateController.text != formattedDate) {
        startDateController.text = formattedDate;
        validationErrors.remove('startDate');
        if (endDateController.text.isNotEmpty) {
          final currentEndDate = DateTime.tryParse(endDateController.text);
          if (currentEndDate != null && !currentEndDate.isAfter(picked)) {
            developer.log('Clearing end date because it\'s no longer after new start date.', name: _logName);
            endDateController.clear();
            validationErrors.remove('endDate');
          }
        }
        validationErrors.remove('dateOverlap');
        notifyListeners();
      }
    }
  }

  Future<void> selectEndDate(BuildContext context) async {
    developer.log('Opening end date picker. Current value: ${endDateController.text}', name: _logName);
    final strings = S.of(context);
    if (startDateController.text.isEmpty) {
      developer.log('Cannot select end date: Start date is empty.', name: _logName);
      _showValidationErrorSnackbar(context, strings.warningSelectStartDateFirst);
      return;
    }

    DateTime initialDatePickerDate;
    DateTime firstDatePickerDate;
    try {
      final startDate = DateTime.parse(startDateController.text);
      // End date must be strictly AFTER start date according to schema Joi.ref('startEffectDate')
      firstDatePickerDate = startDate.add(const Duration(days: 1));

      if (endDateController.text.isNotEmpty) {
        final currentEndDate = DateTime.parse(endDateController.text);
        initialDatePickerDate = currentEndDate.isBefore(firstDatePickerDate) ? firstDatePickerDate : currentEndDate;
      } else {
        initialDatePickerDate = firstDatePickerDate;
      }
      developer.log('End date picker: Initial=$initialDatePickerDate, First=$firstDatePickerDate', name: _logName);
    } catch (e) {
      developer.log("Error parsing start date for end date picker: $e", name: _logName);
      _showValidationErrorSnackbar(context, strings.errorInvalidStartDate);
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDatePickerDate,
      firstDate: firstDatePickerDate,
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      developer.log('End date picked: $formattedDate', name: _logName);
      if (endDateController.text != formattedDate) {
        endDateController.text = formattedDate;
        validationErrors.remove('endDate');
        validationErrors.remove('dateOverlap');
        notifyListeners();
      }
    }
  }

  // --- Validation ---
  bool validateFields({bool isUpdate = false, int? updatingFareId}) {
    validationErrors = {}; // Reset errors
    bool isValid = true;
    final strings = S.current;

    developer.log('--- Starting Validation (isUpdate: $isUpdate, updatingFareId: $updatingFareId) ---', name: _logName);

    // 1. Plaza Selection
    if (_selectedPlazaIdInt == null) {
      developer.log('Validation Error: Plaza ID is null', name: _logName);
      validationErrors['plaza'] = strings.errorPlazaRequired;
      isValid = false;
    } else {
      developer.log('Validation OK: Plaza ID: $_selectedPlazaIdInt', name: _logName);
    }

    // 2. Fare Type and Vehicle Type
    if (_selectedFareType == null) {
      developer.log('Validation Error: Fare Type is null', name: _logName);
      validationErrors['fareType'] = strings.errorFareTypeRequired;
      isValid = false;
    } else {
      developer.log('Validation OK: Fare Type: $_selectedFareType', name: _logName);
    }
    if (_selectedVehicleType == null) {
      developer.log('Validation Error: Vehicle Type is null', name: _logName);
      validationErrors['vehicleType'] = strings.errorVehicleTypeRequired;
      isValid = false;
    } else {
      developer.log('Validation OK: Vehicle Type: $_selectedVehicleType', name: _logName);
    }

    // 3. Fare Amount (handles different types including Progressive and FreePass)
    if (_selectedFareType != null && !_validateFareAmount()) {
      developer.log('Validation Error: Fare Amount/Progressive fields failed validation', name: _logName);
      isValid = false;
    }

    // 4. Base Hours (for Hour-Wise Custom ONLY)
    if (_selectedFareType == FareTypes.hourWiseCustom && !_validateBaseHours()) {
      developer.log('Validation Error: Base Hours failed validation', name: _logName);
      isValid = false;
    }

    // 5. Dates
    if (!_validateDates()) {
      developer.log('Validation Error: Dates failed validation', name: _logName);
      isValid = false;
    }

    // 6. Discount (Not applicable to Progressive/FreePass based on UI/Schema)
    if (_selectedFareType != FareTypes.progressive && _selectedFareType != FareTypes.freePass && !_validateDiscount()) {
      developer.log('Validation Error: Discount failed validation', name: _logName);
      isValid = false;
    }

    // 7. Duplicate/Overlap Check
    if (isValid) {
      try {
        final newFare = _createFareObject();
        developer.log('Checking for overlap with Fare: ${jsonEncode(newFare.toJsonLog())}', name: _logName);
        if (_isDuplicateOrOverlappingFare(newFare, isUpdate: isUpdate, updatingFareId: updatingFareId)) {
          developer.log('Validation Error: Duplicate or Overlapping Fare detected', name: _logName);
          validationErrors['duplicateFare'] = strings.errorDuplicateFare;
          validationErrors['dateOverlap'] = strings.errorDateOverlap;
          isValid = false;
        } else {
          developer.log('Validation OK: No overlapping fare found', name: _logName);
          validationErrors.remove('duplicateFare');
          validationErrors.remove('dateOverlap');
        }
      } catch (e, s) {
        developer.log("Validation Exception: Error during overlap check: $e", name: _logName, error: e, stackTrace: s);
        validationErrors['general'] = strings.errorGeneralValidation;
        isValid = false;
      }
    } else {
      developer.log('Skipping overlap check due to previous validation errors.', name: _logName);
    }

    developer.log('--- Validation Complete --- Result: $isValid, Errors: $validationErrors', name: _logName);
    notifyListeners(); // Notify UI to show validation errors if any
    return isValid;
  }

  // --- Validation Helper Methods --- (Implementations unchanged)

  bool _validateFareAmount() {
    final strings = S.current;
    if (_selectedFareType == FareTypes.freePass) {
      developer.log('Fare Amount OK (FreePass): Skipping validation.', name: _logName);
      validationErrors.remove('fareRate');
      validationErrors.remove('progressiveFare');
      return true;
    }
    if (_selectedFareType == FareTypes.progressive) {
      return _validateProgressiveFields();
    }
    String? errorKey;
    String? value;
    String fieldName = '';
    switch (_selectedFareType) {
      case FareTypes.daily: errorKey = 'dailyFare'; value = dailyFareController.text; fieldName = strings.fieldDailyFare; break;
      case FareTypes.hourly: errorKey = 'hourlyFare'; value = hourlyFareController.text; fieldName = strings.fieldHourlyFare; break;
      case FareTypes.hourWiseCustom: errorKey = 'baseHourlyFare'; value = baseHourlyFareController.text; fieldName = strings.fieldBaseHourlyFare; break;
      case FareTypes.monthlyPass: errorKey = 'monthlyFare'; value = monthlyFareController.text; fieldName = strings.fieldMonthlyFare; break;
      default:
        developer.log('Fare Amount Error: Unknown fare type "$_selectedFareType" in _validateFareAmount.', name: _logName);
        validationErrors['fareType'] = strings.errorInvalidFareType; return false;
    }
    if (value == null || value.isEmpty) {
      developer.log('Fare Amount Error ($errorKey): Value is empty.', name: _logName);
      validationErrors[errorKey] = '$fieldName ${strings.errorIsRequired}'; return false;
    }
    final fareValue = double.tryParse(value);
    if (fareValue == null || fareValue < 0) {
      developer.log('Fare Amount Error ($errorKey): Value "$value" is not a non-negative number.', name: _logName);
      validationErrors[errorKey] = '$fieldName ${strings.errorMustBeNonNegativeNumber}'; return false;
    }
    developer.log('Fare Amount OK ($errorKey): Value "$value"', name: _logName);
    validationErrors.remove(errorKey);
    validationErrors.remove('fareRate');
    return true;
  }

  bool _validateProgressiveFields() {
    final strings = S.current;
    bool isValid = true;
    int? fromValue;
    int? toValue;
    if (fromController.text.isEmpty) {
      validationErrors['from'] = strings.errorFromMinutesRequired;
      isValid = false;
    } else {
      fromValue = int.tryParse(fromController.text);
      if (fromValue == null || fromValue < 0) {
        validationErrors['from'] = strings.errorFromMinutesNonNegative;
        isValid = false;
      } else {
        validationErrors.remove('from');
      }
    }
    if (toCustomController.text.isEmpty) {
      validationErrors['toCustom'] = strings.errorToMinutesRequired;
      isValid = false;
    } else {
      toValue = int.tryParse(toCustomController.text);
      if (toValue == null || toValue <= 0) {
        validationErrors['toCustom'] = strings.errorToMinutesPositive;
        isValid = false;
      } else if (fromValue != null && toValue <= fromValue) {
        validationErrors['toCustom'] = strings.errorToMinutesGreaterThanFrom;
        isValid = false;
      } else {
        validationErrors.remove('toCustom');
      }
    }
    if (progressiveFareController.text.isEmpty) {
      validationErrors['progressiveFare'] = strings.errorProgressiveFareRequired;
      isValid = false;
    } else {
      final fareValue = double.tryParse(progressiveFareController.text);
      if (fareValue == null || fareValue < 0) {
        validationErrors['progressiveFare'] = strings.errorProgressiveFareNonNegative;
        isValid = false;
      } else {
        validationErrors.remove('progressiveFare');
        validationErrors.remove('fareRate');
      }
    }
    developer.log('Progressive Fields Validation Result: $isValid', name: _logName);
    return isValid;
  }

  bool _validateBaseHours() {
    final strings = S.current;
    if (_selectedFareType != FareTypes.hourWiseCustom) {
      validationErrors.remove('baseHours'); return true;
    }
    if (baseHoursController.text.isEmpty) {
      developer.log('Base Hours Error: Value is empty.', name: _logName);
      validationErrors['baseHours'] = strings.errorBaseHoursRequired; return false;
    }
    final hours = int.tryParse(baseHoursController.text);
    if (hours == null || hours <= 0) {
      developer.log('Base Hours Error: Value "${baseHoursController.text}" is not a positive integer.', name: _logName);
      validationErrors['baseHours'] = strings.errorBaseHoursPositive; return false;
    }
    developer.log('Base Hours OK: Value "$hours"', name: _logName);
    validationErrors.remove('baseHours');
    return true;
  }

  bool _validateDates() {
    final strings = S.current;
    bool isValid = true;
    DateTime? startDate;
    DateTime? endDate;
    developer.log('Validating Dates: Start="${startDateController.text}", End="${endDateController.text}"', name: _logName);
    if (startDateController.text.isEmpty) {
      developer.log('Date Validation Error: Start date is empty.', name: _logName);
      validationErrors['startDate'] = strings.errorStartDateRequired; isValid = false;
    } else {
      try {
        startDate = DateTime.parse(startDateController.text);
        developer.log('Date Validation OK: Parsed Start Date: $startDate', name: _logName);
        validationErrors.remove('startDate');
      } catch (e) {
        developer.log('Date Validation Error: Failed to parse start date "${startDateController.text}"', name: _logName);
        validationErrors['startDate'] = strings.errorInvalidDateFormat; isValid = false;
      }
    }
    if (endDateController.text.isEmpty) {
      developer.log('Date Validation Error: End date is empty.', name: _logName);
      validationErrors['endDate'] = strings.errorEndDateRequired; isValid = false;
    } else {
      try {
        endDate = DateTime.parse(endDateController.text);
        developer.log('Date Validation OK: Parsed End Date: $endDate', name: _logName);
        validationErrors.remove('endDate');
      } catch (e) {
        developer.log('Date Validation Error: Failed to parse end date "${endDateController.text}"', name: _logName);
        validationErrors['endDate'] = strings.errorInvalidDateFormat; isValid = false;
      }
    }
    if (isValid && startDate != null && endDate != null) {
      if (!endDate.isAfter(startDate)) {
        developer.log('Date Validation Error: End date $endDate is not strictly after start date $startDate', name: _logName);
        validationErrors['endDate'] = strings.errorEndDateStrictlyAfterStart; isValid = false;
      } else {
        developer.log('Date Validation OK: End date $endDate is after start date $startDate', name: _logName);
        if (validationErrors['endDate'] == strings.errorEndDateStrictlyAfterStart) {
          validationErrors.remove('endDate');
        }
      }
    }
    developer.log('Date Validation Result: $isValid', name: _logName);
    return isValid;
  }

  bool _validateDiscount() {
    final strings = S.current;
    developer.log('Validating Discount: Value="${discountController.text}"', name: _logName);
    if (discountController.text.isEmpty) {
      developer.log('Discount OK: Empty value (optional).', name: _logName);
      validationErrors.remove('discount');
      return true;
    }
    final discount = double.tryParse(discountController.text);
    if (discount == null) {
      developer.log('Discount Error: Value "${discountController.text}" is not numeric.', name: _logName);
      validationErrors['discount'] = strings.errorDiscountNumeric; return false;
    }
    if (discount <= 0 || discount > 100) {
      developer.log('Discount Error: Value "$discount" is not strictly positive and <= 100.', name: _logName);
      validationErrors['discount'] = strings.errorDiscountRangeStrictPositive; return false;
    }
    developer.log('Discount OK: Value "$discount"', name: _logName);
    validationErrors.remove('discount');
    return true;
  }

  bool _isDuplicateOrOverlappingFare(PlazaFare newFare, {bool isUpdate = false, int? updatingFareId}) {
    // (Implementation unchanged)
    developer.log('Overlap Check: Checking fare ${isUpdate ? "(Update ID: $updatingFareId)" : "(New)"}: ${jsonEncode(newFare.toJsonLog())}', name: _logName);
    List<PlazaFare> allFaresToCheck = [
      ..._existingFares.where((f) {
        bool exclude = isUpdate && f.fareId == updatingFareId;
        if(exclude) developer.log('Overlap Check: Excluding existing fare ID ${f.fareId} (self)', name: _logName);
        return !exclude;
      }),
      ..._temporaryFares.where((f) {
        bool exclude = isUpdate && updatingFareId == null && f == newFare;
        if(exclude) developer.log('Overlap Check: Excluding temporary fare (self)', name: _logName);
        return !exclude;
      })
    ];
    developer.log('Overlap Check: Comparing against ${allFaresToCheck.length} other fares.', name: _logName);
    bool overlaps = allFaresToCheck.any((existingFare) {
      developer.log('Overlap Check: Comparing with existing Fare ID: ${existingFare.fareId ?? "N/A (Temp)"}', name: _logName);
      if (existingFare.plazaId == newFare.plazaId &&
          existingFare.vehicleType == newFare.vehicleType &&
          existingFare.fareType == newFare.fareType &&
          !existingFare.isDeleted) {
        if (newFare.fareType == FareTypes.progressive && existingFare.fareType == FareTypes.progressive) {
          final existingFrom = existingFare.from ?? -1;
          final existingTo = existingFare.toCustom ?? -1;
          final newFrom = newFare.from ?? -1;
          final newTo = newFare.toCustom ?? -1;
          bool timeRangesOverlap = (newFrom < existingTo) && (newTo > existingFrom);
          if (!timeRangesOverlap) {
            developer.log('Overlap Check: Progressive time ranges do not overlap.', name: _logName);
            return false;
          }
          developer.log('Overlap Check FOUND Progressive Time Range with Fare ID ${existingFare.fareId ?? "N/A (Temp)"}!', name: _logName);
        }
        final existingStart = existingFare.startEffectDate;
        final existingEnd = existingFare.endEffectDate ?? DateTime(9999, 12, 31);
        final newStart = newFare.startEffectDate;
        final newEnd = newFare.endEffectDate ?? DateTime(9999, 12, 31);
        developer.log('Overlap Check Details: Existing=[$existingStart to $existingEnd], New=[$newStart to $newEnd]', name: _logName);
        DateTime existingEndDay = existingEnd.add(const Duration(days: 1));
        DateTime newEndDay = newEnd.add(const Duration(days: 1));
        bool startsBeforeExistingEnd = newStart.isBefore(existingEndDay);
        bool endsAfterExistingStart = newEndDay.isAfter(existingStart);
        bool isOverlapping = startsBeforeExistingEnd && endsAfterExistingStart;
        if(isOverlapping) {
          developer.log('Overlap Check FOUND Date Range with Fare ID ${existingFare.fareId ?? "N/A (Temp)"}!', name: _logName);
        }
        return isOverlapping;
      } else {
        developer.log('Overlap Check: Skipping Fare ID ${existingFare.fareId ?? "N/A (Temp)"} (Criteria mismatch or deleted)', name: _logName);
        return false;
      }
    });
    developer.log('Overlap Check Result: $overlaps', name: _logName);
    return overlaps;
  }

  // --- Core Actions ---

  PlazaFare _createFareObject() {
    // (Implementation unchanged)
    developer.log('Creating fare object from form fields...', name: _logName);
    if (_selectedPlazaIdInt == null) {
      developer.log('!!! CRITICAL ERROR IN _createFareObject: _selectedPlazaIdInt is NULL !!!', name: _logName);
      throw Exception('Cannot create fare: Plaza ID is not selected or invalid.');
    }
    if (_selectedVehicleType == null) {
      throw Exception('Cannot create fare: Vehicle Type is not selected.');
    }
    if (_selectedFareType == null) {
      throw Exception('Cannot create fare: Fare Type is not selected.');
    }
    double fareRate = 0;
    int? baseHours;
    double? discountRate;
    int? from;
    int? toCustom;
    try {
      switch (_selectedFareType) {
        case FareTypes.daily: fareRate = double.parse(dailyFareController.text); break;
        case FareTypes.hourly: fareRate = double.parse(hourlyFareController.text); break;
        case FareTypes.hourWiseCustom:
          fareRate = double.parse(baseHourlyFareController.text);
          baseHours = int.tryParse(baseHoursController.text);
          break;
        case FareTypes.monthlyPass: fareRate = double.parse(monthlyFareController.text); break;
        case FareTypes.progressive:
          fareRate = double.parse(progressiveFareController.text);
          from = int.parse(fromController.text);
          toCustom = int.parse(toCustomController.text);
          break;
        case FareTypes.freePass:
          fareRate = 0;
          break;
        default: throw Exception('Invalid fare type encountered during object creation.');
      }
      if (_selectedFareType != FareTypes.progressive && _selectedFareType != FareTypes.freePass && discountController.text.isNotEmpty) {
        discountRate = double.tryParse(discountController.text);
      }
    } catch (e) {
      developer.log("Error parsing values during fare object creation: $e", name: _logName);
      throw Exception('Invalid numeric format in form fields.');
    }
    final DateTime startEffectDate = DateTime.parse(startDateController.text);
    final DateTime? endEffectDate = endDateController.text.isNotEmpty
        ? DateTime.parse(endDateController.text) : null;
    final fare = PlazaFare(
      plazaId: _selectedPlazaIdInt!,
      vehicleType: _selectedVehicleType!,
      fareType: _selectedFareType!,
      baseHours: baseHours,
      fareRate: fareRate,
      discountRate: discountRate,
      startEffectDate: startEffectDate,
      endEffectDate: endEffectDate,
      isDeleted: false,
      from: from,
      toCustom: toCustom,
    );
    developer.log('Fare object created: ${jsonEncode(fare.toJsonLog())}', name: _logName);
    return fare;
  }

  Future<bool> addFareToList(BuildContext context) async {
    // (Implementation unchanged)
    final strings = S.of(context);
    developer.log('Attempting to add fare to temporary list...', name: _logName);
    if (!validateFields(isUpdate: false)) {
      developer.log('Add fare validation failed.', name: _logName);
      _showValidationErrorSnackbar(context, strings.errorValidationFailed);
      return false;
    }
    try {
      final newFare = _createFareObject();
      _temporaryFares.add(newFare);
      developer.log('Fare added to temporary list. Count: ${_temporaryFares.length}', name: _logName);
      resetFieldsAfterAdd();
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.successFareAddedToList), duration: const Duration(seconds: 2)),
      );
      return true;
    } catch (e, s) {
      developer.log("Error creating or adding fare object: $e", name: _logName, error: e, stackTrace: s);
      _showValidationErrorSnackbar(context, '${strings.errorAddingFare}: ${e.toString()}');
      return false;
    }
  }

  Future<void> submitAllFares(BuildContext context) async {
    // (Implementation with Success Dialog logic)
    final strings = S.of(context);
    if (_temporaryFares.isEmpty) {
      developer.log('Submit aborted: No temporary fares to submit.', name: _logName);
      _showValidationErrorSnackbar(context, strings.warningNoFaresAdded);
      return;
    }
    developer.log('Submitting ${_temporaryFares.length} temporary fares...', name: _logName);
    _setLoading(true);
    try {
      final faresToSend = _temporaryFares.map((fare) { return fare; }).toList();
      developer.log('Fares being sent to service: ${jsonEncode(faresToSend.map((f)=>f.toJsonLog()).toList())}', name: _logName);
      await _fareService.addFare(faresToSend);

      developer.log('Temporary fares submitted successfully.', name: _logName);
      _temporaryFares.clear();
      resetFieldsAfterAdd(); // Reset form but keep plaza

      if (_selectedPlaza?.plazaId != null) {
        developer.log('Refreshing existing fares list after submission.', name: _logName);
        await fetchExistingFares(_selectedPlaza!.plazaId!);
      }

      // --- SUCCESS DIALOG ---
      if (context.mounted) {
        await _showSuccessDialog(context, strings.successFareSubmission);
        if (context.mounted) { // Check mounted again after await
          Navigator.pop(context, true); // Pop AddFareScreen and indicate success
        }
      }
      // --- END SUCCESS DIALOG ---

    } catch (e, s) {
      developer.log("Error submitting temporary fares: $e", name: _logName, error: e, stackTrace: s);
      if (context.mounted) {
        _showValidationErrorDialog(context, '${strings.errorSubmissionFailed}: ${e.toString()}');
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateFare(BuildContext context, int fareId, int originalPlazaIdAsInt) async {
    // (Implementation unchanged)
    final strings = S.of(context);
    developer.log('Attempting to update fare ID: $fareId for Plaza ID: $originalPlazaIdAsInt', name: _logName);
    if(_selectedPlazaIdInt == null) {
      developer.log("!!! WARNING in updateFare: _selectedPlazaIdInt is NULL before validation. Attempting to set from originalPlazaIdAsInt.", name: _logName);
      _selectedPlazaIdInt = originalPlazaIdAsInt;
    }
    if (!validateFields(isUpdate: true, updatingFareId: fareId)) {
      developer.log('Update fare validation failed for Fare ID: $fareId', name: _logName);
      _showValidationErrorSnackbar(context, strings.errorValidationFailed);
      return false;
    }
    _setIsUpdating(true);
    _setLoading(true);
    notifyListeners();
    try {
      final updatedFareData = _createFareObject();
      final fareToUpdate = PlazaFare(
        fareId: fareId,
        plazaId: originalPlazaIdAsInt,
        vehicleType: updatedFareData.vehicleType,
        fareType: updatedFareData.fareType,
        baseHours: updatedFareData.baseHours,
        fareRate: updatedFareData.fareRate,
        discountRate: updatedFareData.discountRate,
        startEffectDate: updatedFareData.startEffectDate,
        endEffectDate: updatedFareData.endEffectDate,
        isDeleted: false,
        from: updatedFareData.from,
        toCustom: updatedFareData.toCustom,
      );
      developer.log('Calling fare service to update fare: ${jsonEncode(fareToUpdate.toJsonLog())}', name: _logName);
      final success = await _fareService.updateFare(fareToUpdate);
      if (success) {
        developer.log('Fare update successful via service for ID: $fareId', name: _logName);
        developer.log('Refreshing existing fares list after update.', name: _logName);
        await fetchExistingFares(originalPlazaIdAsInt.toString());
        return true;
      } else {
        developer.log('Fare update failed via service (returned false) for ID: $fareId', name: _logName);
        if (context.mounted) {
          _showValidationErrorDialog(context, strings.errorUpdateFailed);
        }
        return false;
      }
    } catch (e, s) {
      developer.log("Error updating fare $fareId: $e", name: _logName, error: e, stackTrace: s);
      if (context.mounted) {
        _showValidationErrorDialog(context, '${strings.errorUpdateFailed}: ${e.toString()}');
      }
      return false;
    } finally {
      _setIsUpdating(false);
      _setLoading(false);
      notifyListeners();
    }
  }

  // --- Helper Methods ---

  void populateFareData(PlazaFare fare) {
    // (Implementation unchanged)
    developer.log('populateFareData START for fare ID: ${fare.fareId}, Plaza ID: ${fare.plazaId}', name: _logName);
    developer.log('Fare Data: ${jsonEncode(fare.toJsonLog())}', name: _logName);
    _selectedPlazaIdInt = fare.plazaId;
    developer.log('populateFareData: Set internal _selectedPlazaIdInt to: $_selectedPlazaIdInt', name: _logName);
    setFareType(fare.fareType);
    setVehicleType(fare.vehicleType);
    startDateController.text = DateFormat('yyyy-MM-dd').format(fare.startEffectDate);
    endDateController.text = fare.endEffectDate != null ? DateFormat('yyyy-MM-dd').format(fare.endEffectDate!) : "";
    _clearFareAmountFields();
    switch (fare.fareType) {
      case FareTypes.daily: dailyFareController.text = fare.fareRate.toStringAsFixed(2); break;
      case FareTypes.hourly: hourlyFareController.text = fare.fareRate.toStringAsFixed(2); break;
      case FareTypes.hourWiseCustom:
        baseHourlyFareController.text = fare.fareRate.toStringAsFixed(2);
        baseHoursController.text = fare.baseHours?.toString() ?? "";
        break;
      case FareTypes.monthlyPass: monthlyFareController.text = fare.fareRate.toStringAsFixed(2); break;
      case FareTypes.progressive:
        progressiveFareController.text = fare.fareRate.toStringAsFixed(2);
        fromController.text = fare.from?.toString() ?? "";
        toCustomController.text = fare.toCustom?.toString() ?? "";
        break;
      case FareTypes.freePass:
        break;
    }
    if (fare.fareType != FareTypes.progressive && fare.fareType != FareTypes.freePass) {
      discountController.text = fare.discountRate?.toString() ?? "";
    } else {
      discountController.clear();
    }
    validationErrors.clear();
    developer.log('populateFareData END.', name: _logName);
    notifyListeners();
  }

  void _clearFareAmountFields() {
    // (Implementation unchanged - doesn't notify)
    developer.log('Clearing fare amount fields (no notification).', name: _logName);
    dailyFareController.clear();
    hourlyFareController.clear();
    baseHourlyFareController.clear();
    monthlyFareController.clear();
    fromController.clear();
    toCustomController.clear();
    progressiveFareController.clear();
  }

  void resetFieldsAfterAdd() {
    // (Implementation unchanged - does notify)
    developer.log('Resetting fields after add (keeping plaza).', name: _logName);
    setFareType(null);
    setVehicleType(null);
    startDateController.clear();
    endDateController.clear();
    _clearFareAmountFields();
    baseHoursController.clear();
    discountController.clear();
    validationErrors.clear();
    notifyListeners();
  }

  void resetFields() {
    // (Implementation unchanged - does notify)
    developer.log('Resetting all fields (including plaza if not pre-selected).', name: _logName);
    bool needsNotification = false;
    if (!isPlazaPreSelected) {
      if (_selectedPlaza != null) {
        resetPlazaSelection(); // Use helper to reset plaza state
        needsNotification = true;
        developer.log('Plaza selection cleared.', name: _logName);
      }
    }
    resetFieldsAfterAdd(); // Reset remaining fields and notifies
    if (needsNotification && !hasListeners) {
      // If resetFieldsAfterAdd didn't notify (e.g., types were already null), notify here
      notifyListeners();
    }
  }

  // --- NEW --- Helper to reset internal state, used by initialize
  void _resetInternalState() {
    developer.log('Resetting internal state variables.', name: _logName);
    _selectedPlaza = null;
    _selectedPlazaIdInt = null;
    plazaController.clear();
    _selectedFareType = null;
    _selectedVehicleType = null;
    _existingFares.clear();
    _temporaryFares.clear();
    _clearFareAmountFields();
    baseHoursController.clear();
    discountController.clear();
    startDateController.clear();
    endDateController.clear();
    validationErrors.clear();
    // _isPlazaPreSelected is reset separately in initialize
    // _plazaList and _createdBy are handled by their fetch methods
  }

  /// Resets fields without notifying listeners, intended for use during disposal.
  void resetStateForDisposal() {
    developer.log('Resetting state for disposal (no notification).', name: _logName);
    // Only reset plaza if it wasn't pre-selected for this screen instance
    if (!isPlazaPreSelected) {
      resetPlazaSelection(); // Use helper (doesn't notify by itself)
      developer.log('Plaza selection cleared during disposal reset.', name: _logName);
    } else {
      developer.log('Keeping pre-selected plaza during disposal reset.', name: _logName);
    }
    // Resetting other fields directly
    _selectedFareType = null;
    _selectedVehicleType = null;
    startDateController.clear();
    endDateController.clear();
    _clearFareAmountFields(); // Does not notify
    baseHoursController.clear();
    discountController.clear();
    validationErrors.clear();
    _temporaryFares.clear();
    // DO NOT CALL notifyListeners() here
  }

  // Show success dialog (Implementation unchanged)
  Future<void> _showSuccessDialog(BuildContext context, String message) async {
    developer.log('Showing Success Dialog: "$message"', name: _logName);
    if (!context.mounted) return;
    final strings = S.of(context);
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(strings.successTitle),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text(strings.buttonOK),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
          ],
        );
      },
    );
  }

  // Show error dialog (Implementation unchanged)
  Future<void> _showValidationErrorDialog(BuildContext context, String message) async {
    developer.log('Showing Validation Error Dialog: "$message"', name: _logName);
    if (!context.mounted) return;
    final strings = S.of(context);
    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text(strings.buttonOK),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
          ],
        );
      },
    );
  }

  // Show error snackbar (Implementation unchanged)
  void _showValidationErrorSnackbar(BuildContext context, String message) {
    developer.log('Showing Validation Error Snackbar: "$message"', name: _logName);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // --- Loading State Setters --- (Implementations unchanged)
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      developer.log('Setting global loading state: $loading', name: _logName);
      _isLoading = loading;
      notifyListeners();
    }
  }

  void setLoadingFare(bool loading) {
    if (_isLoadingFare != loading) {
      developer.log('Setting fare loading state: $loading', name: _logName);
      _isLoadingFare = loading;
      notifyListeners();
    }
  }

  void _setIsUpdating(bool updating) {
    if (_isUpdating != updating) {
      developer.log('Setting updating state: $updating', name: _logName);
      _isUpdating = updating;
      // No notifyListeners here, usually called with setLoading
    }
  }

  // --- Cleanup ---
  @override
  void dispose() {
    developer.log('Disposing PlazaFareViewModel', name: _logName);
    // Dispose all text controllers
    plazaController.dispose();
    dailyFareController.dispose();
    hourlyFareController.dispose();
    baseHoursController.dispose();
    baseHourlyFareController.dispose();
    monthlyFareController.dispose();
    discountController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    fromController.dispose();
    toCustomController.dispose();
    progressiveFareController.dispose();
    super.dispose();
  }
}

// Helper extension for logging PlazaFare details easily
extension PlazaFareLogHelper on PlazaFare {
  Map<String, dynamic> toJsonLog() => {
    'fareId': fareId,
    'plazaId': plazaId,
    'vehicleType': vehicleType,
    'fareType': fareType,
    'fareRate': fareRate,
    'startEffectDate': startEffectDate.toIso8601String(),
    'endEffectDate': endEffectDate?.toIso8601String(),
    'baseHours': baseHours,
    'discountRate': discountRate,
    'isDeleted': isDeleted,
    'from': from,
    'toCustom': toCustom,
  };
}