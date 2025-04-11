import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:merchant_app/generated/l10n.dart';
import 'package:merchant_app/models/bank.dart';
import 'package:merchant_app/services/payment/bank_service.dart';
import 'package:merchant_app/utils/components/snackbar.dart';
import 'package:merchant_app/utils/exceptions.dart';
import 'package:merchant_app/viewmodels/plaza/plaza_form_validation.dart';


class BankDetailsViewModel extends ChangeNotifier {
  final BankService _bankService = BankService();
  final PlazaFormValidation _validator = PlazaFormValidation();

  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController accountHolderController = TextEditingController();
  final TextEditingController ifscCodeController = TextEditingController();

  Map<String, dynamic> bankDetails = {};
  Map<String, String?> errors = {};
  bool _isFirstTime = true;
  bool _isEditable = true;
  bool _isLoading = false;
  String? _bankDetailsId;

  bool get isFirstTime => _isFirstTime;
  bool get isEditable => _isEditable;
  bool get isLoading => _isLoading;

  BankDetailsViewModel() {
    _initializeMap();
    _addControllerListeners();
    developer.log('[BankDetailsViewModel] Initialized. isEditable: $_isEditable, isFirstTime: $_isFirstTime', name: 'BankDetailsViewModel');
  }

  void _initializeMap() {
    bankDetails = {
      'id': null,
      'plazaId': null,
      'bankName': null,
      'accountNumber': null,
      'accountHolderName': null,
      'IFSCcode': null, // Use the key expected by fromJson/toJson if consistent
    };
    developer.log('[BankDetailsViewModel] Map initialized with defaults.', name: 'BankDetailsViewModel');
  }

  void _addControllerListeners() {
    developer.log('[BankDetailsViewModel] Adding listeners to controllers', name: 'BankDetailsViewModel');
    void setupListener(TextEditingController controller, String key) {
      controller.addListener(() {
        final currentValue = bankDetails[key];
        final newValue = controller.text;
        if (currentValue != newValue) {
          bankDetails[key] = newValue;
          developer.log('[BankDetailsViewModel] Controller Listener: Updated map key "$key" to "$newValue"', name: 'BankDetailsViewModel');
          if (errors.containsKey(key)) {
            errors.remove(key);
            if (!errors.keys.any((k) => k != 'general' && errors[k] != null)) {
              errors.remove('general');
            }
            developer.log('[BankDetailsViewModel] Controller Listener: Cleared error for key "$key"', name: 'BankDetailsViewModel');
            notifyListeners();
          }
        }
      });
    }
    setupListener(bankNameController, 'bankName');
    setupListener(accountNumberController, 'accountNumber');
    setupListener(accountHolderController, 'accountHolderName');
    setupListener(ifscCodeController, 'IFSCcode'); // Use the key required by backend/model
  }

  void clearError(String key) {
    if (errors.containsKey(key)) {
      developer.log('[BankDetailsViewModel] Clearing error for key: $key', name: 'BankDetailsViewModel');
      errors.remove(key);
      if (!errors.keys.any((k) => k != 'general' && errors[k] != null)) {
        errors.remove('general');
        developer.log('[BankDetailsViewModel] Cleared general error as no specific errors remain.', name: 'BankDetailsViewModel');
      }
      notifyListeners();
    }
  }

  void toggleEditable() {
    if (_isFirstTime) {
      developer.log('[BankDetailsViewModel] Cannot toggle editable: isFirstTime is true.', name: 'BankDetailsViewModel.toggleEditable');
      return;
    }
    if (_isLoading) {
      developer.log('[BankDetailsViewModel] Cannot toggle editable: isLoading is true.', name: 'BankDetailsViewModel.toggleEditable');
      return;
    }
    _isEditable = !_isEditable;
    developer.log('[BankDetailsViewModel] Toggled editable state to: $_isEditable', name: 'BankDetailsViewModel.toggleEditable');
    notifyListeners();
  }

  void resetToEditableState() {
    _isEditable = true;
    _isFirstTime = true;
    errors.clear();
    developer.log('[BankDetailsViewModel] Reset to initial editable state.', name: 'BankDetailsViewModel.resetToEditableState');
  }

  void populateForModification(Bank existingBankData) {
    developer.log('[BankDetailsViewModel] Populating for modification with Bank ID: ${existingBankData.id}', name: 'BankDetailsViewModel.populateForModification');
    _bankDetailsId = existingBankData.id;
    bankDetails['id'] = existingBankData.id;
    bankDetails['plazaId'] = existingBankData.plazaId;
    bankNameController.text = existingBankData.bankName;
    accountNumberController.text = existingBankData.accountNumber;
    accountHolderController.text = existingBankData.accountHolderName;
    // Note: The Bank model's ifscCode property (camelCase) holds the value from fromJson.
    // The controller gets this value. The listener will update the map using the 'IFSCcode' key.
    ifscCodeController.text = existingBankData.ifscCode;
    // Manually update the map with the correct key after setting controller
    bankDetails['IFSCcode'] = existingBankData.ifscCode;

    _isEditable = false;
    _isFirstTime = false;
    _isLoading = false;
    errors.clear();
    developer.log('[BankDetailsViewModel] Population complete. isEditable: $_isEditable, isFirstTime: $_isFirstTime, BankID: $_bankDetailsId', name: 'BankDetailsViewModel.populateForModification');
  }

  void _syncMapWithControllers() {
    developer.log('[BankDetailsViewModel] Syncing map with controller values...', name: 'BankDetailsViewModel._syncMapWithControllers');
    bankDetails['bankName'] = bankNameController.text.trim();
    bankDetails['accountNumber'] = accountNumberController.text.trim();
    bankDetails['accountHolderName'] = accountHolderController.text.trim();
    bankDetails['IFSCcode'] = ifscCodeController.text.trim(); // Use the key required by backend/model
    developer.log('[BankDetailsViewModel] Sync complete. Map: $bankDetails', name: 'BankDetailsViewModel._syncMapWithControllers');
  }

  bool _validateForm(BuildContext context) {
    errors.clear();
    _syncMapWithControllers();
    developer.log('[BankDetailsViewModel] Starting validation...', name: 'BankDetailsViewModel._validateForm');
    final String? validationErrorSummary = _validator.validateBankDetails(context, bankDetails, errors);
    if (validationErrorSummary != null) {
      if (!errors.containsKey('general') && errors.isNotEmpty) {
        errors['general'] = S.of(context).validationGeneralBankError;
      } else if (errors.isEmpty) {
        errors['general'] = validationErrorSummary;
      }
      developer.log('[BankDetailsViewModel] Validation FAILED. Errors: $errors', name: 'BankDetailsViewModel._validateForm');
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
    developer.log('[BankDetailsViewModel] Validation SUCCESSFUL.', name: 'BankDetailsViewModel._validateForm');
    return true;
  }

  Future<bool> saveBankDetails(BuildContext context, String plazaId) async {
    developer.log('[BankDetailsViewModel] Attempting saveBankDetails for plazaId: $plazaId. Current Bank ID: $_bankDetailsId, isEditable: $_isEditable', name: 'BankDetailsViewModel.saveBankDetails');
    if (!_isEditable) {
      developer.log('[BankDetailsViewModel] Save attempt denied: Not in editable state.', name: 'BankDetailsViewModel.saveBankDetails');
      return false;
    }
    if (!_validateForm(context)) {
      developer.log('[BankDetailsViewModel] Validation failed. Aborting save.', name: 'BankDetailsViewModel.saveBankDetails');
      _setLoading(false);
      return false;
    }
    _setLoading(true);

    final Bank bank = Bank(
      id: _bankDetailsId,
      plazaId: plazaId,
      bankName: bankDetails['bankName']?.toString() ?? '',
      accountNumber: bankDetails['accountNumber']?.toString() ?? '',
      accountHolderName: bankDetails['accountHolderName']?.toString() ?? '',
      ifscCode: bankDetails['IFSCcode']?.toString() ?? '', // Read using the correct map key
    );

    developer.log('[BankDetailsViewModel] Bank object prepared for API: ${bank.toJson()}', name: 'BankDetailsViewModel.saveBankDetails');

    try {
      bool success = false;
      bool isUpdate = _bankDetailsId != null && _bankDetailsId!.isNotEmpty;
      if (!isUpdate) {
        developer.log('[BankDetailsViewModel] Calling addBankDetails service...', name: 'BankDetailsViewModel.saveBankDetails');
        final Map<String, dynamic> response = await _bankService.addBankDetails(bank);
        success = response['success'] == true;
        if (success && response['data']?['id'] != null) {
          _bankDetailsId = response['data']['id'].toString();
          bankDetails['id'] = _bankDetailsId;
          developer.log('[BankDetailsViewModel] Bank Details ADDED successfully. New Bank ID: $_bankDetailsId', name: 'BankDetailsViewModel.saveBankDetails');
        } else {
          developer.log('[BankDetailsViewModel] addBankDetails API call failed. Response: $response', name: 'BankDetailsViewModel.saveBankDetails', level: 900);
          String apiErrorMsg = response['msg'] ?? S.of(context).messageErrorSavingBankDetails;
          throw HttpException('Add bank details failed', serverMessage: apiErrorMsg);
        }
      } else {
        developer.log('[BankDetailsViewModel] Calling updateBankDetails service for ID: $_bankDetailsId...', name: 'BankDetailsViewModel.saveBankDetails');
        final bankToUpdate = bank.copyWith(id: _bankDetailsId);
        success = await _bankService.updateBankDetails(bankToUpdate);
        if (success) {
          developer.log('[BankDetailsViewModel] Bank Details UPDATED successfully for ID: $_bankDetailsId', name: 'BankDetailsViewModel.saveBankDetails');
        } else {
          developer.log('[BankDetailsViewModel] updateBankDetails API call returned false for ID: $_bankDetailsId', name: 'BankDetailsViewModel.saveBankDetails', level: 900);
          throw ServiceException('Update bank details failed');
        }
      }
      _isFirstTime = false;
      _isEditable = false;
      errors.clear();
      _setLoading(false);
      notifyListeners();
      return true;
    } on HttpException catch (e) {
      developer.log('[BankDetailsViewModel] HttpException during save: ${e.message}', name: 'BankDetailsViewModel.saveBankDetails', error: e);
      _handleServiceError(context, e, S.of(context).apiErrorGeneric);
      _setLoading(false);
      return false;
    } on ServiceException catch (e) {
      developer.log('[BankDetailsViewModel] ServiceException during save: ${e.message}', name: 'BankDetailsViewModel.saveBankDetails', error: e);
      _handleServiceError(context, e, S.of(context).messageErrorSavingBankDetails);
      _setLoading(false);
      return false;
    } on PlazaException catch (e) {
      developer.log('[BankDetailsViewModel] PlazaException during save: ${e.message}', name: 'BankDetailsViewModel.saveBankDetails', error: e);
      _handleServiceError(context, e, S.of(context).messageErrorSavingBankDetails);
      _setLoading(false);
      return false;
    } on RequestTimeoutException catch (e) {
      developer.log('[BankDetailsViewModel] TimeoutException during save', name: 'BankDetailsViewModel.saveBankDetails', error: e);
      _handleServiceError(context, e, S.of(context).errorTimeout);
      _setLoading(false);
      return false;
    } on NoInternetException catch (e) {
      developer.log('[BankDetailsViewModel] NoInternetException during save', name: 'BankDetailsViewModel.saveBankDetails', error: e);
      _handleServiceError(context, e, S.of(context).errorNoInternet);
      _setLoading(false);
      return false;
    } on ServerConnectionException catch (e) {
      developer.log('[BankDetailsViewModel] ServerConnectionException during save', name: 'BankDetailsViewModel.saveBankDetails', error: e);
      _handleServiceError(context, e, S.of(context).errorServerConnection);
      _setLoading(false);
      return false;
    } catch (e, stackTrace) {
      developer.log('[BankDetailsViewModel] UNEXPECTED Error saving bank details', error: e, stackTrace: stackTrace, name: 'BankDetailsViewModel.saveBankDetails', level: 1200);
      _handleGenericError(context, e);
      _setLoading(false);
      return false;
    }
  }

  void _handleServiceError(BuildContext context, Exception e, String defaultMessage) {
    String errorMessage = defaultMessage;
    int? statusCode;
    if (e is HttpException) {
      errorMessage = e.serverMessage ?? e.message;
      statusCode = e.statusCode;
    } else if (e is ServiceException) {
      errorMessage = e.serverMessage ?? e.message;
      statusCode = e.statusCode;
    } else if (e is PlazaException) {
      errorMessage = e.serverMessage ?? e.message;
      statusCode = e.statusCode;
    } else if (e is RequestTimeoutException) {
      errorMessage = S.of(context).errorTimeout;
    } else if (e is NoInternetException) {
      errorMessage = S.of(context).errorNoInternet;
    } else if (e is ServerConnectionException) {
      errorMessage = S.of(context).errorServerConnection;
    } else {
      errorMessage = S.of(context).errorUnexpected;
    }
    developer.log('[BankDetailsViewModel] Handling Service Error: ${e.runtimeType} - "$errorMessage" ${statusCode != null ? '(Status: $statusCode)' : ''}', error: e, name: 'BankDetailsViewModel._handleServiceError', level: 900);
    errors['general'] = errorMessage;
    if (context.mounted) {
      AppSnackbar.showSnackbar(context: context, message: errorMessage, type: SnackbarType.error);
    }
    notifyListeners();
  }

  void _handleGenericError(BuildContext context, dynamic e) {
    final message = S.of(context).errorUnexpected;
    errors['general'] = message;
    if (context.mounted) {
      AppSnackbar.showSnackbar(context: context, message: message, type: SnackbarType.error);
    }
    notifyListeners();
  }

  void _setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      developer.log('[BankDetailsViewModel] isLoading set to: $_isLoading', name: 'BankDetailsViewModel');
      if (_isLoading && errors.containsKey('general')) {
        errors.remove('general');
      }
      notifyListeners();
    }
  }

  void clearFieldsAndNotify() {
    developer.log('[BankDetailsViewModel] Clearing state and controllers...', name: 'BankDetailsViewModel.clearFieldsAndNotify');
    bankNameController.clear();
    accountNumberController.clear();
    accountHolderController.clear();
    ifscCodeController.clear();
    _initializeMap();
    errors.clear();
    _bankDetailsId = null;
    _isFirstTime = true;
    _isEditable = true;
    _isLoading = false;
    developer.log('[BankDetailsViewModel] State cleared.', name: 'BankDetailsViewModel.clearFieldsAndNotify');
  }

  @override
  void dispose() {
    developer.log('[BankDetailsViewModel] Disposing...', name: 'BankDetailsViewModel');
    bankNameController.dispose();
    accountNumberController.dispose();
    accountHolderController.dispose();
    ifscCodeController.dispose();
    super.dispose();
    developer.log('[BankDetailsViewModel] Dispose complete.', name: 'BankDetailsViewModel');
  }
}