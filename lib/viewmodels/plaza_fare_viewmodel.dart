import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/plaza.dart';
import '../models/plaza_fare.dart';
import '../services/core/plaza_service.dart';
import '../services/payment/fare_service.dart';
import '../services/storage/secure_storage_service.dart';
import '../config/app_strings.dart';

/// ViewModel for managing plaza fare operations including creation, validation,
/// and submission of fares.
class PlazaFareViewModel extends ChangeNotifier {
  final PlazaService _plazaService;
  final FareService _fareService;
  final SecureStorageService _storageService;

  PlazaFareViewModel({
    PlazaService? plazaService,
    FareService? fareService,
    SecureStorageService? storageService,
  })  : _plazaService = plazaService ?? PlazaService(),
        _fareService = fareService ?? FareService(),
        _storageService = storageService ?? SecureStorageService();

  // State variables
  bool _isLoading = false;
  String? _selectedFareType;
  String? _selectedVehicleType;
  String? _selectedPlazaId;
  Plaza? _selectedPlaza;
  List<Plaza> _plazaList = [];
  final List<PlazaFare> _temporaryFares = [];
  List<PlazaFare> _existingFares = [];
  Map<String, dynamic>? _createdBy;

  // Flag to indicate if a plaza is pre-selected (passed from another screen)
  bool _isPlazaPreSelected = false;
  bool get isPlazaPreSelected => _isPlazaPreSelected;

  // Getters
  bool get isLoading => _isLoading;
  String? get selectedFareType => _selectedFareType;
  String? get selectedVehicleType => _selectedVehicleType;
  String? get selectedPlazaId => _selectedPlazaId;
  Plaza? get selectedPlaza => _selectedPlaza;
  List<Plaza> get plazaList => _plazaList;
  List<PlazaFare> get temporaryFares => _temporaryFares;
  List<PlazaFare> get existingFares => _existingFares;
  Map<String, dynamic>? get createdBy => _createdBy;

  // Controllers
  final TextEditingController dailyFareController = TextEditingController();
  final TextEditingController hourlyFareController = TextEditingController();
  final TextEditingController baseHoursController = TextEditingController();
  final TextEditingController baseHourlyFareController = TextEditingController();
  final TextEditingController monthlyFareController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController plazaController = TextEditingController();

  // Validation errors
  Map<String, String?> validationErrors = {};

  // Constants
  List<String> get fareTypes => FareTypes.values;
  List<String> get vehicleTypes => VehicleTypes.values;

  // Visibility flags
  bool get isDailyFareVisible => _selectedFareType == FareTypes.daily;
  bool get isHourlyFareVisible => _selectedFareType == FareTypes.hourly;
  bool get isHourWiseCustomVisible => _selectedFareType == FareTypes.hourWiseCustom;
  bool get isMonthlyFareVisible => _selectedFareType == FareTypes.monthlyPass;
  bool get canAddFare => _selectedPlazaId != null;
  // If a plaza is pre-selected, disable changing it
  bool get canChangePlaza => !_isPlazaPreSelected && _temporaryFares.isEmpty;

  /// Initializes the ViewModel by fetching necessary data.
  Future<void> initialize() async {
    _setLoading(true);
    try {
      await Future.wait([
        _fetchPlazas(),
        _fetchUserData(),
      ]);
    } catch (e) {
      print('Initialization error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Fetches plazas associated with the current user.
  Future<void> _fetchPlazas() async {
    try {
      final userId = await _storageService.getUserId();
      if (userId != null) {
        _plazaList = await _plazaService.fetchUserPlazas(userId);
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching plazas: $e');
      _plazaList = [];
    }
  }

  /// Fetches user data from secure storage.
  Future<void> _fetchUserData() async {
    try {
      _createdBy = await _storageService.getUserData();
      notifyListeners();
    } catch (e) {
      print('Error fetching user data: $e');
      _createdBy = null;
    }
  }

  /// Fetches existing fares for a given plaza.
  Future<void> fetchExistingFares(String plazaId) async {
    try {
      _existingFares = await _fareService.getFaresByPlazaId(plazaId);
      notifyListeners();
    } catch (e) {
      print('Error in fetchExistingFares: $e');
      _existingFares = [];
      notifyListeners();
    }
  }

  /// Sets the selected plaza and fetches its existing fares.
  void setSelectedPlaza(Plaza plaza) {
    if (canChangePlaza) {
      _selectedPlaza = plaza;
      _selectedPlazaId = plaza.plazaId;
      fetchExistingFares(_selectedPlazaId!);
      notifyListeners();
    }
  }

  /// Sets a pre-selected plaza (passed from another screen).
  void setPreSelectedPlaza(Plaza plaza) {
    _selectedPlaza = plaza;
    _selectedPlazaId = plaza.plazaId;
    _isPlazaPreSelected = true;
    fetchExistingFares(_selectedPlazaId!);
    notifyListeners();
  }

  void setPlazaName(String plazaName) {
    plazaController.text = plazaName;
  }

  /// Sets the selected fare type.
  void setFareType(String fareType) {
    _selectedFareType = fareType;
    notifyListeners();
  }

  /// Sets the selected vehicle type.
  void setVehicleType(String vehicleType) {
    _selectedVehicleType = vehicleType;
    notifyListeners();
  }

  /// Handles the selection of start date.
  Future<void> selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      startDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      notifyListeners();
    }
  }

  /// Handles the selection of end date.
  Future<void> selectEndDate(BuildContext context) async {
    if (startDateController.text.isEmpty) {
      _showValidationError(context, 'Please select start date first');
      return;
    }

    final DateTime startDate = DateTime.parse(startDateController.text);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate.add(const Duration(days: 1)),
      firstDate: startDate.add(const Duration(days: 1)),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      endDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      notifyListeners();
    }
  }

  /// Validates all input fields.
  bool validateFields() {

    validationErrors = {};
    bool isValid = true;

    // Required field validations
    if (_selectedFareType == null) {
      validationErrors['fareType'] = 'Fare type selection is required';
      isValid = false;
    }

    if (_selectedVehicleType == null) {
      validationErrors['vehicleType'] = 'Vehicle type selection is required';
      isValid = false;
    }

    // Fare amount validations
    if (!_validateFareAmount()) {
      isValid = false;
    }

    // Base hours validation for Hour-wise Custom
    if (!_validateBaseHours()) {
      isValid = false;
    }

    // Date validations
    if (!_validateDates()) {
      isValid = false;
    }

    // Discount validation
    if (!_validateDiscount()) {
      isValid = false;
    }

    notifyListeners();
    return isValid;
  }

  /// Validates the fare amount based on selected fare type.
  bool _validateFareAmount() {
    switch (_selectedFareType) {
      case FareTypes.daily:
        if (dailyFareController.text.isEmpty) {
          validationErrors['dailyFare'] = 'Daily fare is required';
          return false;
        }
        final dailyFare = double.tryParse(dailyFareController.text);
        if (dailyFare == null || dailyFare <= 0) {
          validationErrors['dailyFare'] = 'Daily fare must be greater than 0';
          return false;
        }
        break;
      case FareTypes.hourly:
        if (hourlyFareController.text.isEmpty) {
          validationErrors['hourlyFare'] = 'Hourly fare is required';
          return false;
        }
        final hourlyFare = double.tryParse(hourlyFareController.text);
        if (hourlyFare == null || hourlyFare <= 0) {
          validationErrors['hourlyFare'] = 'Hourly fare must be greater than 0';
          return false;
        }
        break;
      case FareTypes.hourWiseCustom:
        if (baseHourlyFareController.text.isEmpty) {
          validationErrors['baseHourlyFare'] = 'Base hourly fare is required';
          return false;
        }
        final baseHourlyFare = double.tryParse(baseHourlyFareController.text);
        if (baseHourlyFare == null || baseHourlyFare <= 0) {
          validationErrors['baseHourlyFare'] = 'Base hourly fare must be greater than 0';
          return false;
        }
        break;
      case FareTypes.monthlyPass:
        if (monthlyFareController.text.isEmpty) {
          validationErrors['monthlyFare'] = 'Monthly fare is required';
          return false;
        }
        final monthlyFare = double.tryParse(monthlyFareController.text);
        if (monthlyFare == null || monthlyFare <= 0) {
          validationErrors['monthlyFare'] = 'Monthly fare must be greater than 0';
          return false;
        }
        break;
      default:
        validationErrors['fareRate'] = 'Invalid fare type selected';
        return false;
    }
    return true;
  }

  /// Validates base hours for Hour-wise Custom fare type.
  bool _validateBaseHours() {
    if (_selectedFareType == FareTypes.hourWiseCustom) {
      if (baseHoursController.text.isEmpty) {
        validationErrors['baseHours'] = 'Base hours is required';
        return false;
      }

      final hours = int.tryParse(baseHoursController.text);
      if (hours == null || hours <= 0) {
        validationErrors['baseHours'] = 'Base hours must be a positive integer';
        return false;
      }
    }
    return true;
  }

  /// Validates the start and end dates.
  /// - Both start date and end date are required.
  /// - End date must be later than the start date.
  bool _validateDates() {
    bool isValid = true;

    if (startDateController.text.isEmpty) {
      validationErrors['startDate'] = 'Start date is required';
      isValid = false;
    }

    if (endDateController.text.isEmpty) {
      validationErrors['endDate'] = 'End date is required';
      isValid = false;
    }

    if (!isValid) {
      return false;
    }

    final startDate = DateTime.parse(startDateController.text);
    final endDate = DateTime.parse(endDateController.text);

    if (!endDate.isAfter(startDate)) {
      validationErrors['endDate'] = 'End date must be later than start date';
      return false;
    }

    return true;
  }

  /// Validates discount rate if provided.
  bool _validateDiscount() {
    if (_selectedFareType == FareTypes.hourWiseCustom) {
      if (discountController.text.isEmpty) {
        validationErrors['discount'] = 'Discount for extended hours is required';
        return false;
      }
    }
    if (discountController.text.isNotEmpty) {
      final discount = double.tryParse(discountController.text);
      if (discount == null || discount <= 0) {
        validationErrors['discount'] = 'Discount must be greater than 0';
        return false;
      }
    }
    return true;
  }

  /// Creates a new PlazaFare object from the current input values.
  PlazaFare _createFareObject() {
    double fareRate;
    switch (_selectedFareType) {
      case FareTypes.daily:
        fareRate = double.parse(dailyFareController.text);
        break;
      case FareTypes.hourly:
        fareRate = double.parse(hourlyFareController.text);
        break;
      case FareTypes.hourWiseCustom:
        fareRate = double.parse(baseHourlyFareController.text);
        break;
      case FareTypes.monthlyPass:
        fareRate = double.parse(monthlyFareController.text);
        break;
      default:
        throw Exception('Invalid fare type');
    }

    return PlazaFare(
      plazaId: int.parse(_selectedPlazaId!),
      vehicleType: _selectedVehicleType!,
      fareType: _selectedFareType!,
      baseHours: _selectedFareType == FareTypes.hourWiseCustom
          ? int.parse(baseHoursController.text)
          : null,
      fareRate: fareRate,
      discountRate: discountController.text.isNotEmpty
          ? double.parse(discountController.text)
          : null,
      startEffectDate: DateTime.parse(startDateController.text),
      endEffectDate: endDateController.text.isNotEmpty
          ? DateTime.parse(endDateController.text)
          : null,
    );
  }

  /// Adds a new fare to the temporary fares list.
  Future<bool> addFareToList(BuildContext context) async {
    if (!validateFields()) {
      _showValidationError(context, 'Please correct the errors before adding the fare');
      return false;
    }

    try {
      final newFare = _createFareObject();

      bool duplicate = false;
      if (_isPlazaPreSelected) {
        // Check both temporary and existing fares if plaza is pre-selected.
        duplicate = _temporaryFares.any((fare) =>
        fare.plazaId == newFare.plazaId &&
            fare.vehicleType == newFare.vehicleType &&
            fare.fareType == newFare.fareType) ||
            _existingFares.any((fare) =>
            fare.plazaId == newFare.plazaId &&
                fare.vehicleType == newFare.vehicleType &&
                fare.fareType == newFare.fareType);
      } else {
        // Otherwise, check only temporary fares.
        duplicate = _temporaryFares.any((fare) =>
        fare.plazaId == newFare.plazaId &&
            fare.vehicleType == newFare.vehicleType &&
            fare.fareType == newFare.fareType);
      }

      if (duplicate) {
        validationErrors['duplicateFare'] = 'A similar fare already exists';
        notifyListeners();
        return false;
      } else {
        validationErrors.remove('duplicateFare');
      }

      _temporaryFares.add(newFare);
      notifyListeners();
      return true;
    } catch (e) {
      _showValidationError(context, 'Error adding fare: ${e.toString()}');
      return false;
    }
  }

  /// Submits all temporary fares to the backend.
  Future<void> submitAllFares(BuildContext context) async {
    if (_temporaryFares.isEmpty) {
      _showValidationError(context, AppStrings.warningNoFaresAdded);
      return;
    }

    _setLoading(true);
    try {
      await _fareService.addFare(_temporaryFares);
      _temporaryFares.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.successFareSubmission)),
      );
    } catch (e) {
      _showValidationError(context, '${AppStrings.errorSubmissionFailed} $e');
    } finally {
      _setLoading(false);
    }
  }

  bool isLoadingFare = false;
  void setLoadingFare(bool loading) {
    isLoadingFare = loading;
  }

  Future<PlazaFare?> getFareById(int fareId) async {
    try {
      final fare = await _fareService.getFareById(fareId);
      return fare;
    } catch (e) {
      print('Error fetching fare by ID: $e');
      return null;
    }
  }

  bool _isUpdating = false;
  bool get isUpdating => _isUpdating;

  // Method to update a fare
  Future<bool> updateFare(int fareId) async {
    if (!validateFields()) {
      return false;
    }

    _isUpdating = true;
    notifyListeners();

    try {
      double? fareRate;
      switch (selectedFareType) {
        case FareTypes.daily:
          fareRate = double.tryParse(dailyFareController.text);
          break;
        case FareTypes.hourly:
          fareRate = double.tryParse(hourlyFareController.text);
          break;
        case FareTypes.hourWiseCustom:
          fareRate = double.tryParse(baseHourlyFareController.text);
          break;
        case FareTypes.monthlyPass:
          fareRate = double.tryParse(monthlyFareController.text);
          break;
        default:
      }

      if (fareRate == null) {
        throw Exception("Invalid fare rate");
      }

      final double? discountRate = discountController.text.isNotEmpty
          ? double.tryParse(discountController.text)
          : null;


      final int? baseHours = baseHoursController.text.isNotEmpty
          ? int.tryParse(baseHoursController.text)
          : null;


      final startEffectDate = DateTime.parse(startDateController.text);

      DateTime? endEffectDate;
      if (endDateController.text.isNotEmpty) {
        endEffectDate = DateTime.parse(endDateController.text);

      }

      final updatedFare = PlazaFare(
        fareId: fareId,
        plazaId: selectedPlazaId != null ? int.parse(selectedPlazaId!) : 0,
        vehicleType: selectedVehicleType!,
        fareType: selectedFareType!,
        baseHours: baseHours,
        fareRate: fareRate,
        discountRate: discountRate,
        startEffectDate: startEffectDate,
        endEffectDate: endEffectDate,
        isDeleted: false,
      );
      final success = await _fareService.updateFare(updatedFare);
      if (success) {
        final index = _existingFares.indexWhere((f) => f.fareId == fareId);
        if (index != -1) {
          _existingFares[index] = updatedFare;
          notifyListeners();
        }
      } else {
      }
      return success;
    } catch (e) {
      return false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  // Helper method to populate controllers with fare data
  void populateFareData(PlazaFare fare) {
    setFareType(fare.fareType);
    setVehicleType(fare.vehicleType);

    startDateController.text = DateFormat('yyyy-MM-dd').format(fare.startEffectDate);
    if (fare.endEffectDate != null) {
      endDateController.text = DateFormat('yyyy-MM-dd').format(fare.endEffectDate!);
    } else {
      endDateController.clear();
    }

    discountController.text = fare.discountRate?.toString() ?? "";
    baseHoursController.text = fare.baseHours?.toString() ?? "";

    switch (fare.fareType) {
      case FareTypes.daily:
        dailyFareController.text = fare.fareRate.toString();
        break;
      case FareTypes.hourly:
        hourlyFareController.text = fare.fareRate.toString();
        break;
      case FareTypes.hourWiseCustom:
        baseHourlyFareController.text = fare.fareRate.toString();
        break;
      case FareTypes.monthlyPass:
        monthlyFareController.text = fare.fareRate.toString();
        break;
    }
    notifyListeners();
  }

  /// Shows a validation error message.
  void _showValidationError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// Updates the loading state.
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Resets all input fields except plaza selection.
  void resetFields() {
    _selectedFareType = null;
    _selectedVehicleType = null;
    dailyFareController.clear();
    hourlyFareController.clear();
    baseHoursController.clear();
    baseHourlyFareController.clear();
    monthlyFareController.clear();
    discountController.clear();
    startDateController.clear();
    endDateController.clear();
    validationErrors.clear();
    notifyListeners();
  }

  @override
  void dispose() {
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
