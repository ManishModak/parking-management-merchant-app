import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_routes.dart';
import 'package:merchant_app/generated/l10n.dart';
import 'package:merchant_app/models/lane.dart';
import 'package:merchant_app/models/plaza.dart';
import 'package:merchant_app/models/bank.dart';
import 'package:merchant_app/services/storage/secure_storage_service.dart';
import 'package:merchant_app/viewmodels/plaza/basic_details_viewmodel.dart';
import 'package:merchant_app/viewmodels/plaza/lane_details_viewmodel.dart';
import 'package:merchant_app/viewmodels/plaza/bank_details_viewmodel.dart';
import 'package:merchant_app/viewmodels/plaza/plaza_images_viewmodel.dart';
import 'package:merchant_app/services/core/plaza_service.dart';
import 'package:merchant_app/services/core/lane_service.dart';
import 'package:merchant_app/services/payment/bank_service.dart';
import 'package:merchant_app/utils/exceptions.dart';
import 'package:merchant_app/utils/components/snackbar.dart';

class PlazaViewModel extends ChangeNotifier {
  final SecureStorageService _secureStorage = SecureStorageService();
  final PlazaService _plazaService = PlazaService();
  final LaneService _laneService = LaneService();
  final BankService _bankService = BankService();

  final BasicDetailsViewModel basicDetails;
  final LaneDetailsViewModel laneDetails;
  final BankDetailsViewModel bankDetails;
  final PlazaImagesViewModel plazaImages;

  int _currentStep = 0;
  int _completeTillStep = -1;
  String? _plazaId;
  bool _isModificationMode = false;
  bool _isDataInitialized = false;
  String? _generalError;

  TabController? _laneTabController;
  bool _isLaneTabControllerInitialized = false;

  int get currentStep => _currentStep;
  int get completeTillStep => _completeTillStep;
  String? get plazaId => _plazaId;
  bool get isModificationMode => _isModificationMode;
  TabController? get laneTabController => _laneTabController;
  bool get isLaneTabControllerInitialized => _isLaneTabControllerInitialized;
  String? get generalError => _generalError;

  bool get isLoading {
    try {
      switch (_currentStep) {
        case 0:
          return basicDetails.isLoading;
        case 1:
          return laneDetails.isLoading;
        case 2:
          return bankDetails.isLoading;
        case 3:
          return plazaImages.isLoading;
        default:
          return false;
      }
    } catch (e, s) {
      developer.log(
          "[PlazaViewModel] Error accessing isLoading for step $_currentStep: $e",
          name: "PlazaViewModel",
          error: e,
          stackTrace: s,
          level: 1000);
      return false;
    }
  }

  PlazaViewModel({String? plazaIdForModification})
      : basicDetails = BasicDetailsViewModel(),
        laneDetails = LaneDetailsViewModel(),
        bankDetails = BankDetailsViewModel(),
        plazaImages = PlazaImagesViewModel() {
    developer.log(
        '[PlazaViewModel] ########## CONSTRUCTOR CALLED ########## Instance: $hashCode',
        name: 'PlazaViewModel');

    basicDetails.addListener(_notifySubViewModelChange);
    laneDetails.addListener(_notifySubViewModelChange);
    bankDetails.addListener(_notifySubViewModelChange);
    plazaImages.addListener(_notifySubViewModelChange);

    if (plazaIdForModification != null && plazaIdForModification.isNotEmpty) {
      _isModificationMode = true;
      _plazaId = plazaIdForModification;
      _completeTillStep = 3;
      developer.log(
          "[PlazaViewModel] Initialized in MODIFICATION mode for Plaza ID: $_plazaId.",
          name: "PlazaViewModel");
    } else {
      _isModificationMode = false;
      _completeTillStep = -1;
      developer.log("[PlazaViewModel] Initialized in REGISTRATION mode.",
          name: "PlazaViewModel");
    }
  }

  void _notifySubViewModelChange() {
    if (!_disposed) {
      developer.log(
          '[PlazaViewModel] Sub-viewmodel change detected. Current Step: $_currentStep, isLoading: $isLoading',
          name: 'PlazaViewModel');
      notifyListeners();
    }
  }

  void initializeTabController(TickerProvider vsync) {
    if (_laneTabController == null) {
      _laneTabController?.dispose();
      _laneTabController = TabController(length: 2, vsync: vsync);
      _isLaneTabControllerInitialized = true;
      developer.log("[PlazaViewModel] Lane TabController initialized.",
          name: "PlazaViewModel.initializeTabController");
      notifyListeners();
    }
  }

  Future<void> initializeData(BuildContext context) async {
    if (_isDataInitialized) return;
    _isDataInitialized = true;
    _generalError = null;

    developer.log(
        '[PlazaViewModel] Initializing data... Mode: ${_isModificationMode ? 'Modification' : 'Registration'}',
        name: 'PlazaViewModel.initializeData');

    try {
      if (_isModificationMode && _plazaId != null) {
        await _loadExistingPlazaData(context, _plazaId!);
      } else {
        await _loadOwnerData();
        basicDetails.resetToEditableState();
        developer.log(
            '[PlazaViewModel] Registration mode: Owner data loaded, Basic Details set to editable.',
            name: 'PlazaViewModel.initializeData');
      }
    } catch (e, stackTrace) {
      developer.log('[PlazaViewModel] CRITICAL ERROR during initializeData: $e',
          name: 'PlazaViewModel.initializeData',
          error: e,
          stackTrace: stackTrace,
          level: 1200);
      _generalError = "Failed to initialize registration: ${e.toString()}";
    } finally {
      if (!_disposed) notifyListeners();
    }
  }

  Future<void> _loadExistingPlazaData(
      BuildContext context, String plazaId) async {
    developer.log(
        '[PlazaViewModel] Loading existing data for Plaza ID: $plazaId',
        name: 'PlazaViewModel._loadExistingPlazaData');
    try {
      final Plaza existingPlaza = await _plazaService.getPlazaById(plazaId);
      await _loadOwnerData();
      basicDetails.populateForModification(existingPlaza);

      final List<Lane> existingLanes =
          await _laneService.getLanesByPlazaId(plazaId);
      laneDetails.populateForModification(existingLanes);

      try {
        final Bank existingBank =
            await _bankService.getBankDetailsByPlazaId(plazaId);
        bankDetails.populateForModification(existingBank);
      } on HttpException catch (e) {
        if (e.statusCode == 404) {
          bankDetails.resetToEditableState();
        } else {
          rethrow;
        }
      }

      plazaImages.resetToInitialState();
      _completeTillStep = 3;
    } catch (e, stackTrace) {
      developer.log('[PlazaViewModel] Error loading existing plaza data: $e',
          name: 'PlazaViewModel._loadExistingPlazaData',
          error: e,
          stackTrace: stackTrace,
          level: 1000);
      _generalError = "Failed to load existing plaza data. Please try again.";
      _completeTillStep = 3;
      if (!_disposed) notifyListeners();
    }
  }

  Future<void> _loadOwnerData() async {
    try {
      final userData = await _secureStorage.getUserData();
      if (userData != null && userData['entityId'] != null) {
        final entityId = userData['entityId'].toString();
        final entityName = userData['entityName'] as String?;
        basicDetails.setOwnerDetails(ownerId: entityId, ownerName: entityName);
      } else {
        _generalError = "Critical error: User data not found. Cannot proceed.";
        if (!_disposed) notifyListeners();
      }
    } catch (e, stackTrace) {
      developer.log('[PlazaViewModel] Error loading owner data: $e',
          name: 'PlazaViewModel._loadOwnerData',
          error: e,
          stackTrace: stackTrace,
          level: 1000);
      _generalError = "Failed to load user data.";
      if (!_disposed) notifyListeners();
    }
  }

  void goToStep(int step) {
    final int maxAllowedStep =
        _isModificationMode ? 3 : (_completeTillStep + 1).clamp(0, 3);
    if (step >= 0 && step <= 3 && step <= maxAllowedStep) {
      if (_currentStep != step) {
        _currentStep = step;
        if (!_disposed) notifyListeners();
      }
    }
  }

  Future<bool> saveBasicDetails(BuildContext context) async {
    _generalError = null;
    bool success = await basicDetails.saveBasicDetails(context);
    if (success) {
      if (basicDetails.plazaId != null && basicDetails.plazaId!.isNotEmpty) {
        _plazaId = basicDetails.plazaId;
        developer.log(
            "[PlazaViewModel] Basic Details Save SUCCESS. Plaza ID set/confirmed: $_plazaId.",
            name: "PlazaViewModel.saveBasicDetails");

        bool wasFirstSave =
            _completeTillStep < 0; // Check if this was the initial save
        if (wasFirstSave) {
          _completeTillStep = 0;
          developer.log(
              "[PlazaViewModel] Updated completeTillStep to: $_completeTillStep",
              name: "PlazaViewModel.saveBasicDetails");
        }

        final strings = S.of(context);
        final String dialogTitle = strings.dialogTitleSuccess; // "Success"
        final String dialogContent = wasFirstSave
            ? strings.dialogContentBasicDetailsRegistered
            : strings.dialogContentBasicDetailsModified;

        onOkAction() {
          developer.log(
              '[PlazaViewModel.saveBasicDetails] Dialog OK action triggered.',
              name: 'PlazaViewModel.saveBasicDetails');
          // Navigate only in registration mode after OK
          if (!_isModificationMode) {
            goToStep(1); // Proceed to Lane Details
          } else {
            // In modification mode, just ensure UI reflects non-editable state
            if (!_disposed) notifyListeners();
          }
        }

        _showSuccessDialog(context, dialogTitle, dialogContent, onOkAction);

        return true; // Report success
      }
    }
    return false;
  }

  Future<bool> saveLaneDetails(BuildContext context) async {
    _generalError = null;
    if (_plazaId == null || _plazaId!.isEmpty) {
      AppSnackbar.showSnackbar(
          context: context,
          message: S.of(context).messageErrorPlazaIdNotSet,
          type: SnackbarType.error);
      return false;
    }
    bool success = await laneDetails.saveNewlyAddedLanes(context, _plazaId!);
    if (success) {
      developer.log(
          "[PlazaViewModel] Lane Details Step Save SUCCESS (New lanes processed or none to process).",
          name: "PlazaViewModel.saveLaneDetails");

      bool wasFirstSave =
          _completeTillStep < 1; // Check if this step was completed before
      if (wasFirstSave) {
        _completeTillStep = 1;
        developer.log(
            "[PlazaViewModel] Updated completeTillStep to: $_completeTillStep",
            name: "PlazaViewModel.saveLaneDetails");
      }

      final strings = S.of(context);
      final String dialogTitle = strings.dialogTitleSuccess;

      final String dialogContent = wasFirstSave
          ? strings.dialogContentLanesRegistered
          : strings
              .dialogContentLanesModified; // "Lane Details Updated Successfully" (Covers adding more later or just reviewing)

      onOkAction() {
        developer.log(
            '[PlazaViewModel.saveLaneDetails] Dialog OK action triggered.',
            name: 'PlazaViewModel.saveLaneDetails');
        if (!_isModificationMode) {
          goToStep(2); // Proceed to Bank Details
        } else {
          if (!_disposed) notifyListeners();
        }
      }

      _showSuccessDialog(context, dialogTitle, dialogContent, onOkAction);

      return true;
    }
    return false;
  }

  Future<bool> saveBankDetails(BuildContext context) async {
    _generalError = null;
    if (_plazaId == null || _plazaId!.isEmpty) {
      AppSnackbar.showSnackbar(
          context: context,
          message: S.of(context).messageErrorPlazaIdNotSet,
          type: SnackbarType.error);
      return false;
    }
    bool success = await bankDetails.saveBankDetails(context, _plazaId!);
    if (success) {
      developer.log("[PlazaViewModel] Bank Details Save SUCCESS.",
          name: "PlazaViewModel.saveBankDetails");

      bool wasFirstSave = _completeTillStep < 2;
      if (wasFirstSave) {
        _completeTillStep = 2;
        developer.log(
            "[PlazaViewModel] Updated completeTillStep to: $_completeTillStep",
            name: "PlazaViewModel.saveBankDetails");
      }

      // --- ADD DIALOG LOGIC HERE ---
      final strings = S.of(context);
      final String dialogTitle = strings.dialogTitleSuccess;
      final String dialogContent = wasFirstSave
          ? strings
              .dialogContentBankDetailsRegistered // "Bank Details Added Successfully"
          : strings
              .dialogContentBankDetailsModified; // "Bank Details Updated Successfully"

      onOkAction() {
        developer.log(
            '[PlazaViewModel.saveBankDetails] Dialog OK action triggered.',
            name: 'PlazaViewModel.saveBankDetails');
        if (!_isModificationMode) {
          goToStep(3); // Proceed to Plaza Images
        } else {
          if (!_disposed) notifyListeners();
        }
      }

      _showSuccessDialog(context, dialogTitle, dialogContent, onOkAction);
      // --- END DIALOG LOGIC ---

      return true;
    }
    return false;
  }

  Future<bool> savePlazaImages(BuildContext context) async {
    _generalError = null;
    if (_plazaId == null || _plazaId!.isEmpty) {
      AppSnackbar.showSnackbar(
          context: context,
          message: S.of(context).messageErrorPlazaIdNotSet,
          type: SnackbarType.error);
      return false;
    }
    bool success = await plazaImages.savePlazaImages(context, _plazaId!);
    if (success) {
      developer.log("[PlazaViewModel] Plaza Images Save SUCCESS.",
          name: "PlazaViewModel.savePlazaImages");

      bool wasFirstCompletion =
          _completeTillStep < 3; // Check if flow completed before
      if (wasFirstCompletion) {
        _completeTillStep = 3;
        developer.log(
            "[PlazaViewModel] Updated completeTillStep to: $_completeTillStep. Registration/Modification Complete.",
            name: "PlazaViewModel.savePlazaImages");
      }

      // --- ADD DIALOG LOGIC HERE ---
      final strings = S.of(context);
      final String dialogTitle = strings.dialogTitleSuccess;
      // Different message based on overall flow mode (Registration vs Modification)
      final String dialogContent =
          strings.plazaRegisteredSuccessfully; // "Plaza Registration Complete"

      // Action after OK: Pop the screen
      onOkAction() {
        developer.log(
            "[PlazaViewModel.savePlazaImages] Dialog OK action triggered. Popping screen.",
            name: "PlazaViewModel.savePlazaImages");
        // Ensure context is still valid before popping
        if (context.mounted) {
          Navigator.pushReplacementNamed(context,
              AppRoutes.plazaList); // Pop this registration/modification screen
        }
      }

      _showSuccessDialog(context, dialogTitle, dialogContent, onOkAction);
      // --- END DIALOG LOGIC ---

      return true;
    }
    return false;
  }

  void toggleEditForCurrentStep() {
    _generalError = null;
    try {
      switch (_currentStep) {
        case 0:
          basicDetails.toggleEditable();
          break;
        case 1:
          laneDetails.toggleEditable();
          break;
        case 2:
          bankDetails.toggleEditable();
          break;
      }
    } catch (e, stackTrace) {
      developer.log(
          '[PlazaViewModel] Error toggling edit for step $_currentStep: $e',
          name: 'PlazaViewModel.toggleEditForCurrentStep',
          error: e,
          stackTrace: stackTrace,
          level: 1000);
      _generalError = "Error enabling editing for this step.";
      if (!_disposed) notifyListeners();
    }
  }

  /// Helper method to show a standardized success dialog.
  void _showSuccessDialog(BuildContext context, String title, String content,
      VoidCallback onOkPressed) {
    // Ensure context is still valid before showing dialog
    if (!context.mounted) {
      developer.log(
          '[PlazaViewModel._showSuccessDialog] Context is not mounted. Skipping dialog.',
          name: 'PlazaViewModel._showSuccessDialog',
          level: 900);
      // Directly call onOkPressed if context is lost? Or just return?
      // Let's just return for safety. The state is already updated.
      return;
    }

    final strings = S.of(context); // For OK button text
    final theme = Theme.of(context); // For dialog styling

    developer.log(
        '[PlazaViewModel._showSuccessDialog] Showing dialog: Title="$title", Content="$content"',
        name: 'PlazaViewModel._showSuccessDialog');

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (dialogContext) => AlertDialog(
        // Use theme defaults for consistency
        backgroundColor: theme.dialogTheme.backgroundColor,
        shape: theme.dialogTheme.shape ??
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        content: Text(content,
            style: theme.dialogTheme.contentTextStyle ??
                theme.textTheme.bodyMedium),
        actions: <Widget>[
          TextButton(
            child: Text(strings.buttonOk),
            onPressed: () {
              developer.log(
                  '[PlazaViewModel._showSuccessDialog] OK button pressed.',
                  name: 'PlazaViewModel._showSuccessDialog');
              Navigator.of(dialogContext).pop(); // Close the dialog first
              // Use Future.microtask to ensure dialog is closed before executing the action
              Future.microtask(onOkPressed);
            },
          ),
        ],
      ),
    );
  }

  void addNewLane(BuildContext context, Lane lane) {
    try {
      laneDetails.addNewLaneToList(lane);
      if (_isLaneTabControllerInitialized &&
          _laneTabController != null &&
          _laneTabController!.index != 0) {
        _laneTabController!.animateTo(0);
      }
    } on PlazaException catch (e) {
      if (context.mounted) {
        AppSnackbar.showSnackbar(
            context: context,
            message:
                e.serverMessage ?? e.message ?? S.of(context).errorAddingLane,
            type: SnackbarType.error);
      }
    } catch (e, stackTrace) {
      developer.log("[PlazaViewModel] Unexpected error adding lane: $e",
          name: "PlazaViewModel.addNewLane",
          error: e,
          stackTrace: stackTrace,
          level: 1000);
      if (context.mounted) {
        AppSnackbar.showSnackbar(
            context: context,
            message: S.of(context).errorUnexpected,
            type: SnackbarType.error);
      }
    }
  }

  void reset() {
    _currentStep = 0;
    _completeTillStep = -1;
    _plazaId = null;
    _isModificationMode = false;
    _isDataInitialized = false;
    _generalError = null;

    basicDetails.clearFieldsAndNotify();
    laneDetails.clearFieldsAndNotify();
    bankDetails.clearFieldsAndNotify();
    plazaImages.clearFieldsAndNotify();

    if (_isLaneTabControllerInitialized &&
        _laneTabController != null &&
        !_laneTabController!.indexIsChanging &&
        _laneTabController!.index != 0) {
      _laneTabController!.animateTo(0);
    }
    if (!_disposed) notifyListeners();
  }

  bool _disposed = false;

  @override
  void dispose() {
    developer.log(
        '[PlazaViewModel] ########## DISPOSE CALLED ########## Instance: $hashCode',
        name: 'PlazaViewModel.dispose');
    if (_disposed) return;
    _disposed = true;
    developer.log("[PlazaViewModel] Disposing...",
        name: "PlazaViewModel.dispose");

    basicDetails.removeListener(_notifySubViewModelChange);
    laneDetails.removeListener(_notifySubViewModelChange);
    bankDetails.removeListener(_notifySubViewModelChange);
    plazaImages.removeListener(_notifySubViewModelChange);

    basicDetails.dispose();
    laneDetails.dispose();
    bankDetails.dispose();
    plazaImages.dispose();

    _laneTabController?.dispose();
    _isLaneTabControllerInitialized = false;

    super.dispose();
  }
}
