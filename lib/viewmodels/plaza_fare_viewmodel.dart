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
  bool _isPlazaPreSelected = false;

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
  bool get isDailyFareVisible => _selectedFareType == FareTypes.daily;
  bool get isHourlyFareVisible => _selectedFareType == FareTypes.hourly;
  bool get isHourWiseCustomVisible => _selectedFareType == FareTypes.hourWiseCustom;
  bool get isMonthlyFareVisible => _selectedFareType == FareTypes.monthlyPass;
  bool get canAddFare => _selectedPlaza?.plazaId != null; // Enable adding if a plaza is selected
  bool get canChangePlaza => !_isPlazaPreSelected && _temporaryFares.isEmpty; // Allow changing plaza only if not pre-selected and no temporary fares exist

  // --- Initialization ---
  Future<void> initialize({Plaza? preSelectedPlaza}) async {
    developer.log('Initializing ViewModel...', name: _logName);
    _setLoading(true);
    try {
      if (preSelectedPlaza != null) {
        developer.log('Pre-selected plaza received: ${preSelectedPlaza.plazaName}', name: _logName);
        setPreSelectedPlaza(preSelectedPlaza); // Set pre-selected plaza first
      }
      await Future.wait([
        _fetchPlazas(), // Fetch available plazas (if needed)
        _fetchUserData(), // Get logged-in user info
      ]);
      // If a plaza is selected (pre-selected or otherwise), fetch its existing fares
      if (_selectedPlaza?.plazaId != null) {
        developer.log('Fetching initial fares for selected plaza ID: ${_selectedPlaza!.plazaId!}', name: _logName);
        await fetchExistingFares(_selectedPlaza!.plazaId!);
      } else {
        developer.log('No plaza selected initially, skipping initial fare fetch.', name: _logName);
      }
    } catch (e, s) { // Catch stack trace
      developer.log('Initialization error: $e', name: _logName, error: e, stackTrace: s);
      // Handle initialization error (e.g., show error message via a state variable)
    } finally {
      _setLoading(false);
      developer.log('Initialization complete. Loading: $_isLoading', name: _logName);
    }
  }

  // --- Data Fetching ---
  Future<void> _fetchPlazas() async {
    if (_isPlazaPreSelected && _plazaList.isNotEmpty) {
      developer.log('Skipping plaza fetch: Plaza is pre-selected and list exists.', name: _logName);
      return; // Avoid unnecessary fetches if static list and pre-selected
    }
    developer.log('Attempting to fetch plazas...', name: _logName);
    try {
      final Map<String, dynamic>? userData = await _storageService.getUserData();
      if (userData != null) {
        final dynamic entityIdValue = userData['entityId'];
        if (entityIdValue != null) {
          final String entityIdString = entityIdValue.toString();
          developer.log('Found entityId: $entityIdString. Fetching plazas...', name: _logName);
          _plazaList = await _plazaService.fetchUserPlazas(entityIdString);
          developer.log('Successfully fetched ${_plazaList.length} plazas.', name: _logName);
          notifyListeners();
        } else {
          developer.log('Could not fetch plazas: entityId key found but value is null in user data.', name: _logName);
          _plazaList = [];
          notifyListeners();
        }
      } else {
        developer.log('Could not fetch plazas: User data not found in secure storage.', name: _logName);
        _plazaList = [];
        notifyListeners();
      }
    } catch (e, s) {
      developer.log('Error fetching plazas: $e', name: _logName, error: e, stackTrace: s);
      _plazaList = []; // Ensure list is empty on error
      notifyListeners();
      // Rethrow or handle error appropriately
    }
  }

  Future<void> _fetchUserData() async {
    developer.log('Fetching user data...', name: _logName);
    try {
      _createdBy = await _storageService.getUserData();
      developer.log('User data fetched: ${_createdBy != null}', name: _logName);
      notifyListeners();
    } catch (e, s) {
      developer.log('Error fetching user data: $e', name: _logName, error: e, stackTrace: s);
      _createdBy = null;
      notifyListeners();
    }
  }

  // Fetches existing fares for a given PLAZA ID (String)
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
      notifyListeners();
    } catch (e, s) {
      developer.log('Error fetching existing fares for plazaId $plazaId: $e', name: _logName, error: e, stackTrace: s);
      _existingFares = []; // Reset on error
      notifyListeners(); // Update UI even on error
      // Handle fetch error (e.g., show message via state variable)
    } finally {
      setLoadingFare(false);
    }
  }

  // Fetches a single fare by its Fare ID (int) - Used for editing
  Future<PlazaFare?> getFareById(int fareId) async {
    // *** REMOVED THE INCORRECT LOADING CHECK FROM HERE ****

    developer.log('Fetching fare by ID: $fareId', name: _logName);
    setLoadingFare(true);
    try {
      // Now the actual service call will proceed
      final fare = await _fareService.getFareById(fareId);
      developer.log('Fare fetched for ID $fareId: ${fare != null}', name: _logName);
      return fare;
    } catch (e, s) {
      developer.log('Error fetching fare by ID $fareId: $e', name: _logName, error: e, stackTrace: s);
      return null;
    } finally {
      // The flag is correctly reset here after the operation completes or fails
      setLoadingFare(false);
    }
  }

  // --- State Management & UI Interaction ---

  // Sets the plaza when selected from a dropdown or similar UI element
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
      plazaController.text = plaza.plazaName;

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

  // Sets the plaza when it's passed initially
  void setPreSelectedPlaza(Plaza plaza) {
    developer.log('Setting pre-selected plaza: ${plaza.plazaName} (ID: ${plaza.plazaId})', name: _logName);
    if (plaza.plazaId == null) {
      developer.log("ERROR: Pre-selected plaza is missing an ID.", name: _logName);
      return;
    }
    _selectedPlaza = plaza;
    plazaController.text = plaza.plazaName;

    _selectedPlazaIdInt = int.tryParse(plaza.plazaId!);
    if (_selectedPlazaIdInt == null) {
      developer.log('ERROR: Could not parse pre-selected plazaId "${plaza.plazaId}" to int.', name: _logName);
      _selectedPlaza = null;
      plazaController.text = "Invalid Plaza";
    } else {
      developer.log('Pre-selected Plaza Parsed Int ID: $_selectedPlazaIdInt', name: _logName);
      _isPlazaPreSelected = true;
    }
    // No notifyListeners() here, expect it to be called by initialize() later
  }

  // Called by PlazaFaresListScreen to display the name when editing/viewing
  void setPlazaName(String plazaName) {
    developer.log('Setting plaza name display: $plazaName (Is PreSelected: $_isPlazaPreSelected)', name: _logName);
    // Only set if not pre-selected to avoid overwriting
    // Or maybe always set it? Depends on desired behavior when navigating back/forth.
    // Let's always set it for consistency for now.
    plazaController.text = plazaName;
    // No notifyListeners() needed as this is usually for display only
  }

  void setFareType(String? fareType) {
    developer.log('Setting Fare Type: $fareType (Previous: $_selectedFareType)', name: _logName);
    if (_selectedFareType != fareType) {
      _selectedFareType = fareType;
      _clearFareAmountFields(); // Clear related amount fields
      // Clear relevant validation errors
      validationErrors.remove('fareType');
      validationErrors.remove('fareRate');
      validationErrors.remove('dailyFare');
      validationErrors.remove('hourlyFare');
      validationErrors.remove('baseHourlyFare');
      validationErrors.remove('monthlyFare');
      validationErrors.remove('baseHours');
      validationErrors.remove('discount');
      validationErrors.remove('duplicateFare'); // Clear potential duplicate error if type changes
      validationErrors.remove('dateOverlap');
      notifyListeners();
    }
  }

  void setVehicleType(String? vehicleType) {
    developer.log('Setting Vehicle Type: $vehicleType (Previous: $_selectedVehicleType)', name: _logName);
    if (_selectedVehicleType != vehicleType) {
      _selectedVehicleType = vehicleType;
      validationErrors.remove('vehicleType');
      validationErrors.remove('duplicateFare'); // Clear potential duplicate error if type changes
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
    final DateTime first = DateTime.now().subtract(const Duration(days: 1));
    final DateTime last = DateTime(2101);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(first) ? first : initial,
      firstDate: first,
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
        notifyListeners(); // Ensure UI updates if date changes
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
        notifyListeners(); // Ensure UI updates if date changes
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

    // 3. Fare Amount
    if (_selectedFareType != null && !_validateFareAmount()) {
      developer.log('Validation Error: Fare Amount failed validation', name: _logName);
      isValid = false;
    }

    // 4. Base Hours (for Hour-Wise Custom)
    if (_selectedFareType == FareTypes.hourWiseCustom && !_validateBaseHours()) {
      developer.log('Validation Error: Base Hours failed validation', name: _logName);
      isValid = false;
    }

    // 5. Dates
    if (!_validateDates()) {
      developer.log('Validation Error: Dates failed validation', name: _logName);
      isValid = false;
    }

    // 6. Discount
    if (!_validateDiscount()) {
      developer.log('Validation Error: Discount failed validation', name: _logName);
      isValid = false;
    }

    // 7. Duplicate/Overlap Check
    if (isValid) {
      try {
        final newFare = _createFareObject();
        // Use jsonEncode for potentially large objects in logs
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

  // --- Validation Helper Methods with Logging ---

  bool _validateFareAmount() {
    String? errorKey;
    String? value;
    String fieldName = '';
    final strings = S.current;

    switch (_selectedFareType) {
      case FareTypes.daily: errorKey = 'dailyFare'; value = dailyFareController.text; fieldName = strings.fieldDailyFare; break;
      case FareTypes.hourly: errorKey = 'hourlyFare'; value = hourlyFareController.text; fieldName = strings.fieldHourlyFare; break;
      case FareTypes.hourWiseCustom: errorKey = 'baseHourlyFare'; value = baseHourlyFareController.text; fieldName = strings.fieldBaseHourlyFare; break;
      case FareTypes.monthlyPass: errorKey = 'monthlyFare'; value = monthlyFareController.text; fieldName = strings.fieldMonthlyFare; break;
      default: validationErrors['fareType'] = strings.errorInvalidFareType; return false;
    }

    if (value == null || value.isEmpty) {
      developer.log('Fare Amount Error ($errorKey): Value is empty.', name: _logName);
      validationErrors[errorKey] = '$fieldName ${strings.errorIsRequired}'; return false;
    }
    final fareValue = double.tryParse(value);
    if (fareValue == null || fareValue <= 0) {
      developer.log('Fare Amount Error ($errorKey): Value "$value" is not a positive number.', name: _logName);
      validationErrors[errorKey] = '$fieldName ${strings.errorMustBePositiveNumber}'; return false;
    }

    developer.log('Fare Amount OK ($errorKey): Value "$value"', name: _logName);
    validationErrors.remove(errorKey);
    validationErrors.remove('fareRate'); // Clear generic error too
    return true;
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

    // End date might be optional, adjust validation if needed
    if (endDateController.text.isEmpty) {
      developer.log('Date Validation Info: End date is empty (optional?).', name: _logName);
      // If required:
      // validationErrors['endDate'] = strings.errorEndDateRequired; isValid = false;
      validationErrors.remove('endDate'); // Assuming optional for now
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

    // Validate Start < End only if both are present and valid so far
    if (isValid && startDate != null && endDate != null) {
      if (!endDate.isAfter(startDate)) {
        developer.log('Date Validation Error: End date $endDate is not after start date $startDate', name: _logName);
        validationErrors['endDate'] = strings.errorEndDateAfterStart; isValid = false;
      } else {
        developer.log('Date Validation OK: End date $endDate is after start date $startDate', name: _logName);
        // Don't remove the error here if it was set for parsing error before
        if (validationErrors['endDate'] == strings.errorEndDateAfterStart) {
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
    if (discount < 0 || discount > 100) {
      developer.log('Discount Error: Value "$discount" is not between 0 and 100.', name: _logName);
      validationErrors['discount'] = strings.errorDiscountRange; return false;
    }

    developer.log('Discount OK: Value "$discount"', name: _logName);
    validationErrors.remove('discount');
    return true;
  }

  // Checks for overlap with existing and temporary fares
  bool _isDuplicateOrOverlappingFare(PlazaFare newFare, {bool isUpdate = false, int? updatingFareId}) {
    developer.log('Overlap Check: Checking fare ${isUpdate ? "(Update ID: $updatingFareId)" : "(New)"}: ${jsonEncode(newFare.toJsonLog())}', name: _logName);
    List<PlazaFare> allFaresToCheck = [
      ..._existingFares.where((f) {
        bool exclude = isUpdate && f.fareId == updatingFareId;
        if(exclude) developer.log('Overlap Check: Excluding existing fare ID ${f.fareId} (self)', name: _logName);
        return !exclude;
      }),
      ..._temporaryFares.where((f) { // Exclude self if modifying a temporary fare (unlikely in Edit screen)
        bool exclude = isUpdate && updatingFareId == null && f == newFare; // Heuristic for updating temp fare
        if(exclude) developer.log('Overlap Check: Excluding temporary fare (self)', name: _logName);
        return !exclude;
      })
    ];
    developer.log('Overlap Check: Comparing against ${allFaresToCheck.length} other fares.', name: _logName);

    bool overlaps = allFaresToCheck.any((existingFare) {
      developer.log('Overlap Check: Comparing with existing Fare ID: ${existingFare.fareId ?? "N/A (Temp)"}', name: _logName);
      // Ensure all required fields are non-null before comparison
      if (existingFare.plazaId == newFare.plazaId &&
          existingFare.vehicleType == newFare.vehicleType &&
          existingFare.fareType == newFare.fareType &&
          !existingFare.isDeleted) {

        final existingStart = existingFare.startEffectDate;
        final existingEnd = existingFare.endEffectDate ?? DateTime(9999, 12, 31);
        final newStart = newFare.startEffectDate;
        final newEnd = newFare.endEffectDate ?? DateTime(9999, 12, 31);

        developer.log('Overlap Check Details: Existing=[$existingStart to $existingEnd], New=[$newStart to $newEnd]', name: _logName);

        // Overlap logic: (StartA <= EndB) and (EndA >= StartB)
        bool startsBeforeOrSameAsExistingEnd = !newStart.isAfter(existingEnd);
        bool endsAfterOrSameAsExistingStart = !newEnd.isBefore(existingStart);
        bool isOverlapping = startsBeforeOrSameAsExistingEnd && endsAfterOrSameAsExistingStart;

        if(isOverlapping) {
          developer.log('Overlap Check FOUND with Fare ID ${existingFare.fareId ?? "N/A (Temp)"}!', name: _logName);
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

  // Creates a PlazaFare object from the current form fields
  PlazaFare _createFareObject() {
    developer.log('Creating fare object from form fields...', name: _logName);
    if (_selectedPlazaIdInt == null) {
      developer.log('!!! CRITICAL ERROR IN _createFareObject: _selectedPlazaIdInt is NULL !!!', name: _logName); // Added emphasis
      throw Exception('Cannot create fare: Plaza ID is not selected or invalid.');
    }
    if (_selectedVehicleType == null) {
      throw Exception('Cannot create fare: Vehicle Type is not selected.');
    }
    if (_selectedFareType == null) {
      throw Exception('Cannot create fare: Fare Type is not selected.');
    }

    double fareRate;
    try {
      switch (_selectedFareType) {
        case FareTypes.daily: fareRate = double.parse(dailyFareController.text); break;
        case FareTypes.hourly: fareRate = double.parse(hourlyFareController.text); break;
        case FareTypes.hourWiseCustom: fareRate = double.parse(baseHourlyFareController.text); break;
        case FareTypes.monthlyPass: fareRate = double.parse(monthlyFareController.text); break;
        default: throw Exception('Invalid fare type encountered during object creation.');
      }
    } catch (e) {
      throw Exception('Invalid fare amount format.');
    }

    final int? baseHours = (_selectedFareType == FareTypes.hourWiseCustom && baseHoursController.text.isNotEmpty)
        ? int.tryParse(baseHoursController.text) : null;
    final double? discountRate = discountController.text.isNotEmpty
        ? double.tryParse(discountController.text) : null;
    final DateTime startEffectDate = DateTime.parse(startDateController.text);
    final DateTime? endEffectDate = endDateController.text.isNotEmpty
        ? DateTime.parse(endDateController.text) : null;

    final fare = PlazaFare(
      plazaId: _selectedPlazaIdInt!, // This is where the null check failure happens if it's null
      vehicleType: _selectedVehicleType!,
      fareType: _selectedFareType!,
      baseHours: baseHours,
      fareRate: fareRate,
      discountRate: discountRate,
      startEffectDate: startEffectDate,
      endEffectDate: endEffectDate,
      isDeleted: false,
    );
    developer.log('Fare object created: ${jsonEncode(fare.toJsonLog())}', name: _logName);
    return fare;
  }

  // Adds the currently configured fare to the temporary list
  Future<bool> addFareToList(BuildContext context) async {
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

  // Submits all fares currently in the temporary list
  Future<void> submitAllFares(BuildContext context) async {
    final strings = S.of(context);
    if (_temporaryFares.isEmpty) {
      developer.log('Submit aborted: No temporary fares to submit.', name: _logName);
      _showValidationErrorSnackbar(context, strings.warningNoFaresAdded);
      return;
    }
    developer.log('Submitting ${_temporaryFares.length} temporary fares...', name: _logName);
    _setLoading(true);
    try {
      final faresToSend = _temporaryFares; // Add createdBy etc. if needed
      await _fareService.addFare(faresToSend);
      developer.log('Temporary fares submitted successfully.', name: _logName);
      _temporaryFares.clear();
      resetFieldsAfterAdd(); // Reset form but keep plaza

      if (_selectedPlaza?.plazaId != null) {
        developer.log('Refreshing existing fares list after submission.', name: _logName);
        await fetchExistingFares(_selectedPlaza!.plazaId!);
      }

      if (context.mounted) {
        await _showSuccessDialog(context, strings.successFareSubmission);
      }
    } catch (e, s) {
      developer.log("Error submitting temporary fares: $e", name: _logName, error: e, stackTrace: s);
      if (context.mounted) {
        _showValidationErrorDialog(context, '${strings.errorSubmissionFailed}: ${e.toString()}');
      }
    } finally {
      _setLoading(false);
    }
  }

  // Updates an existing fare
  Future<bool> updateFare(BuildContext context, int fareId, int originalPlazaIdAsInt) async {
    final strings = S.of(context);
    developer.log('Attempting to update fare ID: $fareId for Plaza ID: $originalPlazaIdAsInt', name: _logName);

    // *** Ensure _selectedPlazaIdInt is set correctly before validation ***
    // This should be guaranteed if populateFareData ran correctly, but let's double-check
    if(_selectedPlazaIdInt == null) {
      developer.log("!!! WARNING in updateFare: _selectedPlazaIdInt is NULL before validation. Attempting to set from originalPlazaIdAsInt.", name: _logName);
      _selectedPlazaIdInt = originalPlazaIdAsInt; // Fallback: set it from the argument
    }

    if (!validateFields(isUpdate: true, updatingFareId: fareId)) {
      developer.log('Update fare validation failed for Fare ID: $fareId', name: _logName);
      _showValidationErrorSnackbar(context, strings.errorValidationFailed);
      return false; // Indicate failure due to validation
    }

    _setIsUpdating(true);
    _setLoading(true); // Use general loading as well
    notifyListeners();

    try {
      // _createFareObject will now use the potentially fallback-set _selectedPlazaIdInt
      final updatedFareData = _createFareObject();
      final fareToUpdate = PlazaFare(
        fareId: fareId,
        plazaId: originalPlazaIdAsInt, // Use the passed original INT ID for the final payload
        vehicleType: updatedFareData.vehicleType,
        fareType: updatedFareData.fareType,
        baseHours: updatedFareData.baseHours,
        fareRate: updatedFareData.fareRate,
        discountRate: updatedFareData.discountRate,
        startEffectDate: updatedFareData.startEffectDate,
        endEffectDate: updatedFareData.endEffectDate,
        isDeleted: false,
      );

      developer.log('Calling fare service to update fare: ${jsonEncode(fareToUpdate.toJsonLog())}', name: _logName);
      final success = await _fareService.updateFare(fareToUpdate);

      if (success) {
        developer.log('Fare update successful via service for ID: $fareId', name: _logName);
        developer.log('Refreshing existing fares list after update.', name: _logName);
        await fetchExistingFares(originalPlazaIdAsInt.toString());
        return true; // Indicate success
      } else {
        developer.log('Fare update failed via service (returned false) for ID: $fareId', name: _logName);
        if (context.mounted) {
          _showValidationErrorDialog(context, strings.errorUpdateFailed); // Show generic failure
        }
        return false; // Indicate failure
      }
    } catch (e, s) {
      developer.log("Error updating fare $fareId: $e", name: _logName, error: e, stackTrace: s);
      if (context.mounted) {
        _showValidationErrorDialog(context, '${strings.errorUpdateFailed}: ${e.toString()}');
      }
      return false; // Indicate failure due to exception
    } finally {
      _setIsUpdating(false);
      _setLoading(false);
      notifyListeners(); // Ensure UI updates after loading/updating finishes
    }
  }

  // --- Helper Methods ---

  // Populates form fields when editing an existing fare
  void populateFareData(PlazaFare fare) {
    developer.log('populateFareData START for fare ID: ${fare.fareId}, Plaza ID: ${fare.plazaId}', name: _logName);
    developer.log('Fare Data: ${jsonEncode(fare.toJsonLog())}', name: _logName);

    // *** THIS IS THE CRUCIAL FIX from the previous step ***
    // Ensure the internal plaza ID state is set from the fetched fare data
    _selectedPlazaIdInt = fare.plazaId;
    developer.log('populateFareData: Set internal _selectedPlazaIdInt to: $_selectedPlazaIdInt', name: _logName);

    // Set dropdowns first
    setFareType(fare.fareType); // Use setters to ensure consistency
    setVehicleType(fare.vehicleType);

    // Set dates
    startDateController.text = DateFormat('yyyy-MM-dd').format(fare.startEffectDate);
    endDateController.text = fare.endEffectDate != null ? DateFormat('yyyy-MM-dd').format(fare.endEffectDate!) : "";

    // Clear existing amount fields before setting the correct one
    _clearFareAmountFields();

    // Set the correct amount field based on fare type
    switch (fare.fareType) {
      case FareTypes.daily: dailyFareController.text = fare.fareRate.toStringAsFixed(2); break;
      case FareTypes.hourly: hourlyFareController.text = fare.fareRate.toStringAsFixed(2); break;
      case FareTypes.hourWiseCustom: baseHourlyFareController.text = fare.fareRate.toStringAsFixed(2); break;
      case FareTypes.monthlyPass: monthlyFareController.text = fare.fareRate.toStringAsFixed(2); break;
    }

    // Set optional fields
    baseHoursController.text = fare.baseHours?.toString() ?? "";
    discountController.text = fare.discountRate?.toString() ?? ""; // Assuming discount is stored 0-100

    validationErrors.clear(); // Clear any previous validation errors
    developer.log('populateFareData END.', name: _logName);
    notifyListeners(); // Update UI with populated data
  }


  // Clears only the fare amount input fields
  void _clearFareAmountFields() {
    developer.log('Clearing fare amount fields.', name: _logName);
    dailyFareController.clear();
    hourlyFareController.clear();
    baseHourlyFareController.clear();
    monthlyFareController.clear();
  }

  // Resets most fields, keeping Plaza selection if appropriate
  void resetFieldsAfterAdd() {
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

  // Resets all fields including Plaza selection
  void resetFields() {
    developer.log('Resetting all fields (including plaza if not pre-selected).', name: _logName);
    if (!isPlazaPreSelected) {
      _selectedPlaza = null;
      _selectedPlazaIdInt = null;
      plazaController.clear();
      _existingFares = []; // Clear existing fares if plaza is cleared
      developer.log('Plaza selection cleared.', name: _logName);
    }
    resetFieldsAfterAdd(); // Reset remaining fields
  }

  // Show success dialog
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

  // Show error dialog
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

  // Show error snackbar
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

  // --- Loading State Setters ---
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
  };
}