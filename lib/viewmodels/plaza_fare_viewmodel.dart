import 'dart:async';
// Import for jsonEncode used in logging
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// Make sure these paths are correct for your project structure
import '../generated/l10n.dart';
import '../models/plaza.dart';
import '../models/plaza_fare.dart';
import '../services/core/plaza_service.dart';
import '../services/payment/fare_service.dart';
import '../services/storage/secure_storage_service.dart';
import '../views/plaza/plaza fare/plaza_fares_list.dart';

class PlazaFareViewModel extends ChangeNotifier {
  final PlazaService _plazaService;
  final FareService _fareService;
  final SecureStorageService _storageService;

  // --- Constants ---
  static const String _logName = 'PlazaFareViewModel';

  PlazaFareViewModel({
    PlazaService? plazaService,
    FareService? fareService,
    SecureStorageService? storageService,
  })  : _plazaService = plazaService ?? PlazaService(),
        _fareService = fareService ?? FareService(),
        _storageService = storageService ?? SecureStorageService();

  // --- State Variables ---
  bool _isLoading = false;
  bool _isLoadingFare = false;
  bool _isUpdating = false;
  bool _isPlazaPreSelected = false;

  Plaza? _selectedPlaza;
  int? _selectedPlazaIdInt;
  String? _selectedFareType;
  String? _selectedVehicleType;

  List<Plaza> _plazaList = [];
  final List<PlazaFare> _temporaryFares = [];
  List<PlazaFare> _existingFares = [];
  Map<String, dynamic>? _createdBy;

  Map<String, String?> validationErrors = {};

  // --- Controllers ---
  final TextEditingController dailyFareController = TextEditingController();
  final TextEditingController hourlyFareController = TextEditingController();
  final TextEditingController baseHoursController = TextEditingController();
  final TextEditingController baseHourlyFareController =
  TextEditingController();
  final TextEditingController monthlyFareController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController plazaController = TextEditingController();
  final TextEditingController fromController = TextEditingController();
  final TextEditingController toCustomController = TextEditingController();
  final TextEditingController progressiveFareController =
  TextEditingController();

  // --- Getters ---
  bool get isLoading => _isLoading;
  bool get isLoadingFare => _isLoadingFare;
  bool get isUpdating => _isUpdating;
  bool get isPlazaPreSelected => _isPlazaPreSelected;
  String? get selectedFareType => _selectedFareType;
  String? get selectedVehicleType => _selectedVehicleType;
  Plaza? get selectedPlaza => _selectedPlaza;
  String? get selectedPlazaIdString => _selectedPlaza?.plazaId;
  int? get selectedPlazaIdAsInt => _selectedPlazaIdInt;
  List<Plaza> get plazaList => _plazaList;
  List<PlazaFare> get temporaryFares => _temporaryFares;
  List<PlazaFare> get existingFares => _existingFares;
  Map<String, dynamic>? get createdBy => _createdBy;
  List<String> get fareTypes => FareTypes.values;
  List<String> get vehicleTypes => VehicleTypes.values;

  // --- Computed Properties ---
  bool get isProgressiveFareVisible =>
      _selectedFareType == FareTypes.progressive;
  bool get isFreePassSelected => _selectedFareType == FareTypes.freePass;
  bool get isDailyFareVisible => _selectedFareType == FareTypes.daily;
  bool get isHourlyFareVisible => _selectedFareType == FareTypes.hourly;
  bool get isHourWiseCustomVisible =>
      _selectedFareType == FareTypes.hourWiseCustom;
  bool get isMonthlyFareVisible =>
      _selectedFareType == FareTypes.monthlyPass;
  bool get shouldShowStandardAmountFields =>
      !isProgressiveFareVisible && !isFreePassSelected;
  bool get canChangePlaza =>
      !_isPlazaPreSelected && _temporaryFares.isEmpty;

  // --- Initialization & Data Fetching ---
  Future<void> initialize({Plaza? preSelectedPlaza}) async {
    developer.log(
        'Initializing ViewModel... Pre-selected: ${preSelectedPlaza?.plazaId}',
        name: _logName);
    _setLoading(true);
    _resetInternalState();
    _isPlazaPreSelected = false;

    try {
      if (preSelectedPlaza != null) {
        developer.log(
            'Pre-selected plaza received: ${preSelectedPlaza.plazaName}',
            name: _logName);
        setPreSelectedPlaza(preSelectedPlaza);
      } else {
        resetPlazaSelection();
      }

      await Future.wait([
        _fetchPlazas(),
        _fetchUserData(),
      ]);
      if (_selectedPlaza?.plazaId != null) {
        developer.log(
            'Fetching initial fares for selected plaza ID: ${_selectedPlaza!.plazaId!}',
            name: _logName);
        await fetchExistingFares(_selectedPlaza!.plazaId!);
      } else {
        developer.log(
            'No plaza selected initially, skipping initial fare fetch.',
            name: _logName);
        _existingFares = [];
        if (hasListeners) notifyListeners();
      }
    } catch (e, s) {
      developer.log('Initialization error: $e',
          name: _logName, error: e, stackTrace: s);
      _plazaList = [];
      _existingFares = [];
    } finally {
      _setLoading(false);
      developer.log(
          'Initialization complete. Loading: $_isLoading, PreSelected: $_isPlazaPreSelected',
          name: _logName);
    }
  }

  Future<void> _fetchPlazas() async {
    if (_isPlazaPreSelected &&
        _plazaList.isNotEmpty &&
        _plazaList.length == 1 &&
        _plazaList[0].plazaId == _selectedPlaza?.plazaId) {
      return;
    }
    List<Plaza> fetchedPlazas = [];
    try {
      final Map<String, dynamic>? userData =
      await _storageService.getUserData();
      if (userData != null) {
        final dynamic entityIdValue = userData['entityId'];
        if (entityIdValue != null) {
          final String entityIdString = entityIdValue.toString();
          fetchedPlazas = await _plazaService.fetchUserPlazas(entityIdString);
        }
      }
    } catch (e, s) {
      developer.log('Error fetching plazas: $e',
          name: _logName, error: e, stackTrace: s);
    } finally {
      if (fetchedPlazas.isNotEmpty || _plazaList.isNotEmpty) {
        _plazaList = fetchedPlazas;
        if (hasListeners) notifyListeners();
      }
    }
  }

  Future<void> _fetchUserData() async {
    try {
      _createdBy = await _storageService.getUserData();
    } catch (e, s) {
      developer.log('Error fetching user data: $e',
          name: _logName, error: e, stackTrace: s);
      _createdBy = null;
    }
  }

  Future<void> fetchExistingFares(String plazaId) async {
    if (_isLoadingFare) {
      return;
    }
    setLoadingFare(true);
    try {
      _existingFares = await _fareService.getFaresByPlazaId(plazaId);
      developer.log(
          'Fetched ${_existingFares.length} existing fares for plazaId: $plazaId.',
          name: _logName);
    } catch (e, s) {
      developer.log('Error fetching existing fares for plazaId $plazaId: $e',
          name: _logName, error: e, stackTrace: s);
      _existingFares = [];
    } finally {
      setLoadingFare(false);
    }
  }

  Future<PlazaFare?> getFareById(int fareId) async {
    setLoadingFare(true);
    try {
      final fare = await _fareService.getFareById(fareId);
      return fare;
    } catch (e, s) {
      developer.log('Error fetching fare by ID $fareId: $e',
          name: _logName, error: e, stackTrace: s);
      return null;
    } finally {
      setLoadingFare(false);
    }
  }

  // --- State Management ---
  void setSelectedPlaza(Plaza plaza) {
    if (!canChangePlaza) {
      return;
    }
    if (plaza.plazaId == null) {
      return;
    }

    if (_selectedPlaza?.plazaId != plaza.plazaId) {
      _selectedPlaza = plaza;
      plazaController.text = plaza.plazaName!;

      _selectedPlazaIdInt = int.tryParse(plaza.plazaId!);
      if (_selectedPlazaIdInt == null) {
        validationErrors['plaza'] = 'Invalid Plaza ID format.';
        _selectedPlaza = null;
        plazaController.clear();
        _existingFares = [];
      } else {
        validationErrors.remove('plaza');
        fetchExistingFares(plaza.plazaId!);
      }
      notifyListeners();
    }
  }

  void setPreSelectedPlaza(Plaza plaza) {
    if (plaza.plazaId == null) {
      return;
    }
    _selectedPlaza = plaza;
    plazaController.text = plaza.plazaName!;

    _selectedPlazaIdInt = int.tryParse(plaza.plazaId!);
    if (_selectedPlazaIdInt == null) {
      _selectedPlaza = null;
      plazaController.text = "Invalid Plaza";
      _isPlazaPreSelected = false;
    } else {
      _isPlazaPreSelected = true;
      if (!_plazaList.any((p) => p.plazaId == plaza.plazaId)) {
        _plazaList = [plaza, ..._plazaList];
      }
    }
  }

  void resetPlazaSelection() {
    _selectedPlaza = null;
    _selectedPlazaIdInt = null;
    plazaController.clear();
    _existingFares = [];
    _isPlazaPreSelected = false;
    validationErrors.remove('plaza');
  }

  void setPlazaName(String plazaName) {
    plazaController.text = plazaName;
  }

  void setFareType(String? fareType) {
    if (_selectedFareType != fareType) {
      _selectedFareType = fareType;
      _clearFareAmountFields();
      validationErrors.clear();
      notifyListeners();
    }
  }

  void setVehicleType(String? vehicleType) {
    if (_selectedVehicleType != vehicleType) {
      _selectedVehicleType = vehicleType;
      validationErrors.remove('vehicleType');
      validationErrors.remove('duplicateFare');
      validationErrors.remove('dateOverlap');
      notifyListeners();
    }
  }

  Future<void> selectStartDate(BuildContext context) async {
    final DateTime initial = startDateController.text.isNotEmpty
        ? (DateTime.tryParse(startDateController.text) ?? DateTime.now())
        : DateTime.now();
    final DateTime first = DateTime.now();
    final DateTime last = DateTime(2101);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(first) ? first : initial,
      firstDate: first,
      lastDate: last,
    );

    if (picked != null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      if (startDateController.text != formattedDate) {
        startDateController.text = formattedDate;
        validationErrors.remove('startDate');
        if (endDateController.text.isNotEmpty) {
          final currentEndDate = DateTime.tryParse(endDateController.text);
          if (currentEndDate != null && !currentEndDate.isAfter(picked)) {
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
    final strings = S.of(context);
    if (startDateController.text.isEmpty) {
      _showValidationErrorSnackbar(
          context, strings.warningSelectStartDateFirst);
      return;
    }

    DateTime initialDatePickerDate;
    DateTime firstDatePickerDate;
    try {
      final startDate = DateTime.parse(startDateController.text);
      firstDatePickerDate = startDate.add(const Duration(days: 1));

      if (endDateController.text.isNotEmpty) {
        final currentEndDate = DateTime.parse(endDateController.text);
        initialDatePickerDate = currentEndDate.isBefore(firstDatePickerDate)
            ? firstDatePickerDate
            : currentEndDate;
      } else {
        initialDatePickerDate = firstDatePickerDate;
      }
    } catch (e) {
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
    validationErrors = {};
    bool isValid = true;
    final strings = S.current;

    if (_selectedPlazaIdInt == null) {
      validationErrors['plaza'] = strings.errorPlazaRequired;
      isValid = false;
    }
    if (_selectedFareType == null) {
      validationErrors['fareType'] = strings.errorFareTypeRequired;
      isValid = false;
    }
    if (_selectedVehicleType == null) {
      validationErrors['vehicleType'] = strings.errorVehicleTypeRequired;
      isValid = false;
    }
    if (_selectedFareType != null && !_validateFareAmount()) {
      isValid = false;
    }
    if (_selectedFareType == FareTypes.hourWiseCustom &&
        !_validateBaseHours()) {
      isValid = false;
    }
    if (!_validateDates()) {
      isValid = false;
    }
    if (_selectedFareType != FareTypes.progressive &&
        _selectedFareType != FareTypes.freePass &&
        !_validateDiscount()) {
      isValid = false;
    }
    if (isValid) {
      try {
        final newFare = _createFareObject();
        if (_isDuplicateOrOverlappingFare(newFare,
            isUpdate: isUpdate, updatingFareId: updatingFareId)) {
          validationErrors['duplicateFare'] = strings.errorDuplicateFare;
          validationErrors['dateOverlap'] = strings.errorDateOverlap;
          isValid = false;
        } else {
          validationErrors.remove('duplicateFare');
          validationErrors.remove('dateOverlap');
        }
      } catch (e, s) {
        developer.log("Validation Exception: Error during overlap check: $e",
            name: _logName, error: e, stackTrace: s);
        validationErrors['general'] = strings.errorGeneralValidation;
        isValid = false;
      }
    }
    notifyListeners();
    return isValid;
  }

  bool _validateFareAmount() {
    final strings = S.current;
    if (_selectedFareType == FareTypes.freePass) {
      return true;
    }
    if (_selectedFareType == FareTypes.progressive) {
      return _validateProgressiveFields();
    }
    String? errorKey;
    String? value;
    String fieldName = '';
    switch (_selectedFareType) {
      case FareTypes.daily:
        errorKey = 'dailyFare';
        value = dailyFareController.text;
        fieldName = strings.fieldDailyFare;
        break;
      case FareTypes.hourly:
        errorKey = 'hourlyFare';
        value = hourlyFareController.text;
        fieldName = strings.fieldHourlyFare;
        break;
      case FareTypes.hourWiseCustom:
        errorKey = 'baseHourlyFare';
        value = baseHourlyFareController.text;
        fieldName = strings.fieldBaseHourlyFare;
        break;
      case FareTypes.monthlyPass:
        errorKey = 'monthlyFare';
        value = monthlyFareController.text;
        fieldName = strings.fieldMonthlyFare;
        break;
      default:
        validationErrors['fareType'] = strings.errorInvalidFareType;
        return false;
    }
    if (value.isEmpty) {
      validationErrors[errorKey] = '$fieldName ${strings.errorIsRequired}';
      return false;
    }
    final fareValue = double.tryParse(value);
    if (fareValue == null || fareValue < 0) {
      validationErrors[errorKey] =
      '$fieldName ${strings.errorMustBeNonNegativeNumber}';
      return false;
    }
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
      validationErrors['progressiveFare'] =
          strings.errorProgressiveFareRequired;
      isValid = false;
    } else {
      final fareValue = double.tryParse(progressiveFareController.text);
      if (fareValue == null || fareValue < 0) {
        validationErrors['progressiveFare'] =
            strings.errorProgressiveFareNonNegative;
        isValid = false;
      } else {
        validationErrors.remove('progressiveFare');
        validationErrors.remove('fareRate');
      }
    }
    return isValid;
  }

  bool _validateBaseHours() {
    final strings = S.current;
    if (_selectedFareType != FareTypes.hourWiseCustom) {
      validationErrors.remove('baseHours');
      return true;
    }
    if (baseHoursController.text.isEmpty) {
      validationErrors['baseHours'] = strings.errorBaseHoursRequired;
      return false;
    }
    final hours = int.tryParse(baseHoursController.text);
    if (hours == null || hours <= 0) {
      validationErrors['baseHours'] = strings.errorBaseHoursPositive;
      return false;
    }
    validationErrors.remove('baseHours');
    return true;
  }

  bool _validateDates() {
    final strings = S.current;
    bool isValid = true;
    DateTime? startDate;
    DateTime? endDate;
    if (startDateController.text.isEmpty) {
      validationErrors['startDate'] = strings.errorStartDateRequired;
      isValid = false;
    } else {
      try {
        startDate = DateTime.parse(startDateController.text);
        validationErrors.remove('startDate');
      } catch (e) {
        validationErrors['startDate'] = strings.errorInvalidDateFormat;
        isValid = false;
      }
    }
    if (endDateController.text.isEmpty) {
      validationErrors['endDate'] = strings.errorEndDateRequired;
      isValid = false;
    } else {
      try {
        endDate = DateTime.parse(endDateController.text);
        validationErrors.remove('endDate');
      } catch (e) {
        validationErrors['endDate'] = strings.errorInvalidDateFormat;
        isValid = false;
      }
    }
    if (isValid && startDate != null && endDate != null) {
      if (!endDate.isAfter(startDate)) {
        validationErrors['endDate'] = strings.errorEndDateStrictlyAfterStart;
        isValid = false;
      } else {
        if (validationErrors['endDate'] ==
            strings.errorEndDateStrictlyAfterStart) {
          validationErrors.remove('endDate');
        }
      }
    }
    return isValid;
  }

  bool _validateDiscount() {
    final strings = S.current;
    if (discountController.text.isEmpty) {
      validationErrors.remove('discount');
      return true;
    }
    final discount = double.tryParse(discountController.text);
    if (discount == null) {
      validationErrors['discount'] = strings.errorDiscountNumeric;
      return false;
    }
    if (discount <= 0 || discount > 100) {
      validationErrors['discount'] = strings.errorDiscountRangeStrictPositive;
      return false;
    }
    validationErrors.remove('discount');
    return true;
  }

  bool _isDuplicateOrOverlappingFare(PlazaFare newFare,
      {bool isUpdate = false, int? updatingFareId}) {
    List<PlazaFare> allFaresToCheck = [
      ..._existingFares.where((f) => !(isUpdate && f.fareId == updatingFareId)),
      ..._temporaryFares.where((f) => !(isUpdate && updatingFareId == null && f == newFare))
    ];

    return allFaresToCheck.any((existingFare) {
      if (existingFare.plazaId == newFare.plazaId &&
          existingFare.vehicleType == newFare.vehicleType &&
          existingFare.fareType == newFare.fareType &&
          !existingFare.isDeleted) {
        if (newFare.fareType == FareTypes.progressive &&
            existingFare.fareType == FareTypes.progressive) {
          final existingFrom = existingFare.from ?? -1;
          final existingTo = existingFare.toCustom ?? -1;
          final newFrom = newFare.from ?? -1;
          final newTo = newFare.toCustom ?? -1;
          if (!((newFrom < existingTo) && (newTo > existingFrom))) {
            return false;
          }
        }
        final existingStart = existingFare.startEffectDate;
        final existingEnd =
            existingFare.endEffectDate ?? DateTime(9999, 12, 31);
        final newStart = newFare.startEffectDate;
        final newEnd = newFare.endEffectDate ?? DateTime(9999, 12, 31);
        DateTime existingEndDay = existingEnd.add(const Duration(days: 1));
        DateTime newEndDay = newEnd.add(const Duration(days: 1));
        return (newStart.isBefore(existingEndDay) && newEndDay.isAfter(existingStart));
      }
      return false;
    });
  }

  // --- Core Actions ---
  PlazaFare _createFareObject() {
    if (_selectedPlazaIdInt == null) {
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
        case FareTypes.daily:
          fareRate = double.parse(dailyFareController.text);
          break;
        case FareTypes.hourly:
          fareRate = double.parse(hourlyFareController.text);
          break;
        case FareTypes.hourWiseCustom:
          fareRate = double.parse(baseHourlyFareController.text);
          baseHours = int.tryParse(baseHoursController.text);
          break;
        case FareTypes.monthlyPass:
          fareRate = double.parse(monthlyFareController.text);
          break;
        case FareTypes.progressive:
          fareRate = double.parse(progressiveFareController.text);
          from = int.parse(fromController.text);
          toCustom = int.parse(toCustomController.text);
          break;
        case FareTypes.freePass:
          fareRate = 0;
          break;
      }
      if (_selectedFareType != FareTypes.progressive &&
          _selectedFareType != FareTypes.freePass &&
          discountController.text.isNotEmpty) {
        discountRate = double.tryParse(discountController.text);
      }
    } catch (e) {
      throw Exception('Invalid numeric format in form fields.');
    }
    final DateTime startEffectDate = DateTime.parse(startDateController.text);
    final DateTime? endEffectDate = endDateController.text.isNotEmpty
        ? DateTime.parse(endDateController.text)
        : null;
    return PlazaFare(
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
      toCustom: toCustom, // API expects string for toCustom
    );
  }

  Future<bool> addFareToList(BuildContext context) async {
    final strings = S.of(context);
    if (!validateFields(isUpdate: false)) {
      _showValidationErrorSnackbar(context, strings.errorValidationFailed);
      return false;
    }
    try {
      final newFare = _createFareObject();
      _temporaryFares.add(newFare);
      resetFieldsAfterAdd();
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(strings.successFareAddedToList),
            duration: const Duration(seconds: 2)),
      );
      return true;
    } catch (e, s) {
      developer.log("Error creating or adding fare object: $e",
          name: _logName, error: e, stackTrace: s);
      _showValidationErrorSnackbar(
          context, '${strings.errorAddingFare}: ${e.toString()}');
      return false;
    }
  }

  Future<void> submitAllFares(BuildContext context) async {
    final strings = S.of(context);
    if (_temporaryFares.isEmpty) {
      _showValidationErrorSnackbar(context, strings.warningNoFaresAdded);
      return;
    }
    _setLoading(true);

    try {
      final faresToSend = _temporaryFares.toList();
      await _fareService.addFare(faresToSend);

      developer.log('Temporary fares submitted successfully.', name: _logName);
      final submittedPlaza = _selectedPlaza;
      final wasPlazaPreselected = _isPlazaPreSelected;
      _temporaryFares.clear();
      resetFieldsAfterAdd(); // Resets form fields and notifies listeners

      if (!context.mounted) return;

      // ** CHANGE: Instead of SnackBar, call the success dialog method **
      await _showSuccessDialogAndNavigate(
        context,
        strings.successFareSubmission,
        submittedPlaza,
        wasPlazaPreselected,
      );

    } catch (e, s) {
      developer.log("Error submitting temporary fares: $e", name: _logName, error: e, stackTrace: s);
      if (context.mounted) {
        _showValidationErrorDialog(context, '${strings.errorSubmissionFailed}: ${e.toString()}');
      }
    } finally {
      // Note: setLoading(false) might be called before dialog is dismissed,
      // which is generally fine as the dialog is modal.
      _setLoading(false);
    }
  }

  Future<void> _showSuccessDialogAndNavigate(
      BuildContext context,
      String message,
      Plaza? submittedPlaza,
      bool wasPlazaPreselected,
      ) async {
    if (!context.mounted) return;

    final strings = S.of(context);

    // showDialog is a Future that completes when the dialog is popped.
    await showDialog(
      context: context,
      barrierDismissible: false, // User must press OK
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(strings.successTitle),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text(strings.buttonOK),
              onPressed: () {
                // First, pop the dialog itself.
                Navigator.of(dialogContext).pop();

                // Then, perform the screen navigation on the original context.
                if (!context.mounted) return;

                if (wasPlazaPreselected) {
                  // SCENARIO A: Came from the list screen. Pop back to it.
                  Navigator.pop(context, true);
                } else if (submittedPlaza != null) {
                  // SCENARIO B: Started on this screen. Replace it with the list screen.
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChangeNotifierProvider(
                        create: (_) => PlazaFareViewModel(),
                        child: PlazaFaresListScreen(plaza: submittedPlaza),
                      ),
                    ),
                  );
                } else {
                  // Fallback: Just pop if something went wrong.
                  Navigator.pop(context, true);
                }
              },
            ),
          ],
        );
      },
    );
  }


  Future<bool> updateFare(
      BuildContext context, int fareId, int originalPlazaIdAsInt) async {
    final strings = S.of(context);
    _selectedPlazaIdInt ??= originalPlazaIdAsInt;
    if (!validateFields(isUpdate: true, updatingFareId: fareId)) {
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
      final success = await _fareService.updateFare(fareToUpdate);
      if (success) {
        await fetchExistingFares(originalPlazaIdAsInt.toString());
        return true;
      } else {
        if (context.mounted) {
          _showValidationErrorDialog(context, strings.errorUpdateFailed);
        }
        return false;
      }
    } catch (e, s) {
      developer.log("Error updating fare $fareId: $e",
          name: _logName, error: e, stackTrace: s);
      if (context.mounted) {
        _showValidationErrorDialog(
            context, '${strings.errorUpdateFailed}: ${e.toString()}');
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
    _selectedPlazaIdInt = fare.plazaId;
    setFareType(fare.fareType);
    setVehicleType(fare.vehicleType);
    startDateController.text =
        DateFormat('yyyy-MM-dd').format(fare.startEffectDate);
    endDateController.text = fare.endEffectDate != null
        ? DateFormat('yyyy-MM-dd').format(fare.endEffectDate!)
        : "";
    _clearFareAmountFields();
    switch (fare.fareType) {
      case FareTypes.daily:
        dailyFareController.text = fare.fareRate.toStringAsFixed(2);
        break;
      case FareTypes.hourly:
        hourlyFareController.text = fare.fareRate.toStringAsFixed(2);
        break;
      case FareTypes.hourWiseCustom:
        baseHourlyFareController.text = fare.fareRate.toStringAsFixed(2);
        baseHoursController.text = fare.baseHours?.toString() ?? "";
        break;
      case FareTypes.monthlyPass:
        monthlyFareController.text = fare.fareRate.toStringAsFixed(2);
        break;
      case FareTypes.progressive:
        progressiveFareController.text = fare.fareRate.toStringAsFixed(2);
        fromController.text = fare.from?.toString() ?? "";
        toCustomController.text = fare.toCustom?.toString() ?? "";
        break;
      case FareTypes.freePass:
        break;
    }
    if (fare.fareType != FareTypes.progressive &&
        fare.fareType != FareTypes.freePass) {
      discountController.text = fare.discountRate?.toString() ?? "";
    } else {
      discountController.clear();
    }
    validationErrors.clear();
    notifyListeners();
  }

  void _clearFareAmountFields() {
    dailyFareController.clear();
    hourlyFareController.clear();
    baseHourlyFareController.clear();
    monthlyFareController.clear();
    fromController.clear();
    toCustomController.clear();
    progressiveFareController.clear();
  }

  void resetFieldsAfterAdd() {
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
    bool needsNotification = false;
    if (!isPlazaPreSelected) {
      if (_selectedPlaza != null) {
        resetPlazaSelection();
        needsNotification = true;
      }
    }
    resetFieldsAfterAdd();
    if (needsNotification && !hasListeners) {
      notifyListeners();
    }
  }

  void _resetInternalState() {
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
  }

  void resetStateForDisposal() {
    if (!isPlazaPreSelected) {
      resetPlazaSelection();
    }
    _selectedFareType = null;
    _selectedVehicleType = null;
    startDateController.clear();
    endDateController.clear();
    _clearFareAmountFields();
    baseHoursController.clear();
    discountController.clear();
    validationErrors.clear();
    _temporaryFares.clear();
  }

  Future<void> _showSuccessDialog(BuildContext context, String message) async {
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

  Future<void> _showValidationErrorDialog(
      BuildContext context, String message) async {
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

  void _showValidationErrorSnackbar(BuildContext context, String message) {
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
      _isLoading = loading;
      notifyListeners();
    }
  }

  void setLoadingFare(bool loading) {
    if (_isLoadingFare != loading) {
      _isLoadingFare = loading;
      notifyListeners();
    }
  }

  void _setIsUpdating(bool updating) {
    if (_isUpdating != updating) {
      _isUpdating = updating;
    }
  }

  // --- Cleanup ---
  @override
  void dispose() {
    developer.log('Disposing PlazaFareViewModel', name: _logName);
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