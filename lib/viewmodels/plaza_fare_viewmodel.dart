import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:merchant_app/services/plaza_service.dart';
import '../config/app_strings.dart';
import '../models/plaza.dart';
import '../models/plaza_fare.dart';
import '../services/fare_service.dart';
import '../services/secure_storage_service.dart';

class PlazaFareViewModel extends ChangeNotifier {
  final _plazaService = PlazaService();
  final _fareService = FareService();
  final SecureStorageService _storageService = SecureStorageService();

  // State variables
  String? selectedFareType;
  String? selectedVehicleType;
  String? selectedPlazaId;
  Plaza? selectedPlaza;
  bool isLoading = false;
  List<Plaza> plazaList = [];
  List<PlazaFare> temporaryFares = [];
  List<PlazaFare> existingFares = [];
  Map<String, dynamic>? createdBy;

  // Controllers
  final TextEditingController dailyFareController = TextEditingController();
  final TextEditingController hourlyFareController = TextEditingController();
  final TextEditingController baseHourlyFareController = TextEditingController();
  final TextEditingController monthlyFareController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();

  // Validation
  Map<String, String?> validationErrors = {
    'plaza': null,
    'fareType': null,
    'vehicleType': null,
    'dailyFare': null,
    'hourlyFare': null,
    'baseHourlyFare': null,
    'monthlyFare': null,
    'discount': null,
    'startDate': null,
    'endDate': null,
  };

  // Constants
  final List<String> fareTypes = [
    "Fixed 24-Hour Fare",
    "Hourly Fare",
    "Hour-wise Custom Fare",
    "Monthly Pass"
  ];

  final List<String> vehicleTypes = [
    "Bike", "3-wheeler", "Car", "Jeep",
    "Van", "Bus", "Truck", "Heavy Machinery Vehicle"
  ];

  // Getters for visibility in UI
  bool get isDailyFareVisible => selectedFareType == "Fixed 24-Hour Fare";
  bool get isHourlyFareVisible => selectedFareType == "Hourly Fare";
  bool get isBaseHourVisible => selectedFareType == "Hour-wise Custom Fare";
  bool get isMonthlyFareVisible => selectedFareType == "Monthly Pass";

  Future<void> initialize() async {
    isLoading = true;
    notifyListeners();

    try {
      await fetchPlazas();
      final userData = await _storageService.getUserData();
      createdBy = userData;
    } catch (e) {
      print('Initialization error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPlazas() async {
    final userId = await _storageService.getUserId();
    if (userId != null) {
      try {
        plazaList = await _plazaService.fetchUserPlazas(userId);
      } catch (e) {
        print("Error fetching plazas: $e");
      }
    }
  }

  Future<void> fetchExistingFares(String plazaId) async {
    try {
      // Uncomment and implement when _plazaService.getExistingFares is available:
      // existingFares = await _plazaService.getExistingFares(plazaId);
    } catch (e) {
      print("Error fetching existing fares: $e");
    }
  }

  void setSelectedPlaza(Plaza plaza) {
    selectedPlaza = plaza;
    selectedPlazaId = plaza.plazaId; // Assuming plazaId is stored as a String.
    fetchExistingFares(selectedPlazaId!);
    notifyListeners();
  }

  void setFareType(String fareType) {
    selectedFareType = fareType;
    _autoPopulateFareFields();
    notifyListeners();
  }

  void _autoPopulateFareFields() {
    if (selectedFareType == "Fixed 24-Hour Fare") {
      dailyFareController.text = "100";
    } else if (selectedFareType == "Hourly Fare") {
      hourlyFareController.text = "20";
    } else if (selectedFareType == "Hour-wise Custom Fare") {
      baseHourlyFareController.text = "50";
    } else if (selectedFareType == "Monthly Pass") {
      monthlyFareController.text = "500";
    }
  }

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

  Future<void> selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      endDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      notifyListeners();
    }
  }

  void setVehicleType(String vehicleType) {
    selectedVehicleType = vehicleType;
    notifyListeners();
  }

  bool validateFields() {
    bool isValid = true;
    // Reset all validation errors.
    validationErrors = {
      'plaza': null,
      'fareType': null,
      'vehicleType': null,
      'dailyFare': null,
      'hourlyFare': null,
      'baseHourlyFare': null,
      'monthlyFare': null,
      'discount': null,
      'startDate': null,
      'endDate': null,
    };

    // Plaza validation
    if (selectedPlazaId == null || selectedPlazaId!.isEmpty) {
      validationErrors['plaza'] = AppStrings.errorPlazaSelectionRequired;
      isValid = false;
    }

    if (selectedFareType == null || selectedFareType!.isEmpty) {
      validationErrors['fareType'] = AppStrings.errorFareTypeSelectionRequired;
      isValid = false;
    }

    if (selectedVehicleType == null || selectedVehicleType!.isEmpty) {
      validationErrors['vehicleType'] = AppStrings.errorVehicleTypeSelectionRequired;
      isValid = false;
    }

    // Fare amount validations
    _validateFareAmounts();

    // Date validations
    _validateDates();

    // Discount validation
    _validateDiscount();

    notifyListeners();
    return isValid;
  }

  void _validateFareAmounts() {
    if (isDailyFareVisible) {
      _validateAmountField(
        controller: dailyFareController,
        fieldName: 'dailyFare',
        errorMessage: 'Please enter Daily Fare',
      );
    }

    if (isHourlyFareVisible) {
      _validateAmountField(
        controller: hourlyFareController,
        fieldName: 'hourlyFare',
        errorMessage: 'Please enter Hourly Fare',
      );
    }

    if (isBaseHourVisible) {
      _validateAmountField(
        controller: baseHourlyFareController,
        fieldName: 'baseHourlyFare',
        errorMessage: 'Please enter Base Hourly Fare',
      );
    }

    if (isMonthlyFareVisible) {
      _validateAmountField(
        controller: monthlyFareController,
        fieldName: 'monthlyFare',
        errorMessage: 'Please enter Monthly Fare',
      );
    }
  }

  void _validateAmountField({
    required TextEditingController controller,
    required String fieldName,
    required String errorMessage,
  }) {
    if (controller.text.isEmpty) {
      validationErrors[fieldName] = errorMessage;
    } else {
      final amount = double.tryParse(controller.text);
      if (amount == null || amount <= 0) {
        validationErrors[fieldName] = 'Amount must be greater than 0';
      }
    }
  }

  void _validateDates() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (startDateController.text.isEmpty) {
      validationErrors['startDate'] = AppStrings.errorStartDateRequired;
    } else {
      final startDate = DateTime.parse(startDateController.text);
      if (startDate.isBefore(today)) {
        validationErrors['startDate'] = AppStrings.errorPastDateNotAllowed;
      }
    }

    if (endDateController.text.isEmpty) {
      validationErrors['endDate'] = AppStrings.errorEndDateRequired;
    } else if (startDateController.text.isNotEmpty) {
      final startDate = DateTime.parse(startDateController.text);
      final endDate = DateTime.parse(endDateController.text);

      // Allow end date to be equal to the start date.
      if (endDate.isBefore(startDate)) {
        validationErrors['endDate'] = 'End date must be later than or equal to the start date';
      }
    }
  }

  void _validateDiscount() {
    if (discountController.text.isEmpty) {
      validationErrors['discount'] = AppStrings.errorDiscountRequired;
    } else {
      final discount = double.tryParse(discountController.text);
      if (discount == null || discount <= 0) {
        validationErrors['discount'] = AppStrings.errorInvalidDiscount;
      }
    }
  }

  /// Helper method to convert a vehicle type string into the corresponding enum.
  VehicleType _convertStringToVehicleType(String vehicleType) {
    if (vehicleType == "Bike") {
      return VehicleType.Bike;
    } else if (vehicleType == "3-wheeler" || vehicleType == "ThreeWheeler") {
      return VehicleType.ThreeWheeler;
    } else if (vehicleType == "Car" || vehicleType == "FourWheeler") {
      return VehicleType.FourWheeler;
    } else if (vehicleType == "Bus") {
      return VehicleType.Bus;
    } else if (vehicleType == "Truck") {
      return VehicleType.Truck;
    } else if (vehicleType == "Heavy Machinery Vehicle") {
      return VehicleType.HeavyMachineryVehicle;
    } else {
      return VehicleType.InvalidCarriage;
    }
  }

  Future<bool> addFareToList(BuildContext context) async {
    if (!validateFields()) {
      _showValidationError(context, 'Please correct errors');
      return false;
    }

    // Convert the selected plaza ID to an int.
    final int parsedPlazaId = int.parse(selectedPlazaId!);
    // Convert the selected vehicle type to the corresponding enum.
    final VehicleType selectedVehicleEnum = _convertStringToVehicleType(selectedVehicleType!);

    // Check against existing system fares.
    if (existingFares.any((fare) => fare.plazaId == parsedPlazaId)) {
      _showValidationError(context, 'Fare already exists for this plaza in system');
      return false;
    }

    // Check temporary fares.
    if (temporaryFares.any((fare) => fare.plazaId == parsedPlazaId)) {
      _showValidationError(context, 'Fare already exists for this plaza');
      return false;
    }

    if (temporaryFares.any((fare) =>
    fare.plazaId == parsedPlazaId && fare.vehicleType == selectedVehicleEnum)) {
      _showValidationError(context, 'Vehicle class already exists for this plaza');
      return false;
    }

    try {
      temporaryFares.add(_createFareObject());
      notifyListeners();
      return true;
    } catch (e) {
      _showValidationError(context, 'Error adding fare: ${e.toString()}');
      return false;
    }
  }

  PlazaFare _createFareObject() {
    // Convert selectedFareType string to enum FareType.
    FareType fareTypeEnum;
    if (selectedFareType == "Fixed 24-Hour Fare") {
      fareTypeEnum = FareType.Fixed24Hour;
    } else if (selectedFareType == "Hourly Fare") {
      fareTypeEnum = FareType.Hourly;
    } else if (selectedFareType == "Hour-wise Custom Fare") {
      fareTypeEnum = FareType.HourWiseCustom;
    } else if (selectedFareType == "Monthly Pass") {
      fareTypeEnum = FareType.MonthlyPass;
    } else {
      throw Exception("Invalid fare type selected");
    }

    // Convert selectedVehicleType string to enum VehicleType.
    VehicleType vehicleTypeEnum = _convertStringToVehicleType(selectedVehicleType!);

    // Determine fareRate and baseHours based on the fare type.
    double fareRate;
    int? baseHours;
    if (fareTypeEnum == FareType.Fixed24Hour) {
      fareRate = double.parse(dailyFareController.text);
    } else if (fareTypeEnum == FareType.Hourly) {
      fareRate = double.parse(hourlyFareController.text);
    } else if (fareTypeEnum == FareType.HourWiseCustom) {
      // For Hour-wise Custom Fare, assume the input is used for both rate and base hours.
      fareRate = double.parse(baseHourlyFareController.text);
      baseHours = int.tryParse(baseHourlyFareController.text);
    } else if (fareTypeEnum == FareType.MonthlyPass) {
      fareRate = double.parse(monthlyFareController.text);
    } else {
      fareRate = 0;
    }

    return PlazaFare(
      // Convert selectedPlazaId (if stored as String) to int.
      plazaId: int.parse(selectedPlazaId!),
      vehicleType: vehicleTypeEnum,
      fareType: fareTypeEnum,
      baseHours: baseHours,
      fareRate: fareRate,
      discountRate: double.tryParse(discountController.text),
      startEffectDate: DateTime.parse(startDateController.text),
      endEffectDate: endDateController.text.isNotEmpty
          ? DateTime.parse(endDateController.text)
          : null,
    );
  }

  void _showValidationError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> submitAllFares(BuildContext context) async {
    if (temporaryFares.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.warningNoFaresAdded)),
      );
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      // Call addFare with the list of fares.
      final responseFares = await _fareService.addFare(temporaryFares);

      // Optionally update state with responseFares if needed.
      // For now, clear the temporary fares list.
      temporaryFares.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.successFareSubmission)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppStrings.errorSubmissionFailed} $e')),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    dailyFareController.dispose();
    hourlyFareController.dispose();
    baseHourlyFareController.dispose();
    monthlyFareController.dispose();
    discountController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    super.dispose();
  }

  void resetFields() {
    selectedPlaza = null;
    selectedPlazaId = null;
    selectedFareType = null;
    selectedVehicleType = null;
    validationErrors = {
      'plaza': null,
      'fareType': null,
      'vehicleType': null,
      'dailyFare': null,
      'hourlyFare': null,
      'baseHourlyFare': null,
      'monthlyFare': null,
      'discount': null,
      'startDate': null,
      'endDate': null,
    };
    dailyFareController.clear();
    hourlyFareController.clear();
    baseHourlyFareController.clear();
    monthlyFareController.clear();
    discountController.clear();
    startDateController.clear();
    endDateController.clear();
    notifyListeners();
  }
}
