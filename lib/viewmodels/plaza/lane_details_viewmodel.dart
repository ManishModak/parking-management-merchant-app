import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:merchant_app/generated/l10n.dart';
import 'package:merchant_app/models/lane.dart';
import 'package:merchant_app/services/core/lane_service.dart';
import 'package:merchant_app/utils/exceptions.dart';
// Removed PlazaFormValidation import
// import 'package:merchant_app/viewmodels/plaza/plaza_form_validation.dart';
import 'package:merchant_app/utils/components/snackbar.dart';

class LaneDetailsViewModel extends ChangeNotifier {
  final LaneService _laneService = LaneService();
  // Removed _validator
  // final PlazaFormValidation _validator = PlazaFormValidation();

  final List<Lane> newlyAddedLanes = [];
  final List<Lane> savedLanes = [];
  Map<String, String?> errors = {};
  bool _isEditable = true;
  bool _isFirstTime = true;
  bool _isLoading = false;

  bool get isEditable => _isEditable;
  bool get isFirstTime => _isFirstTime;
  bool get isLoading => _isLoading;

  LaneDetailsViewModel() {
    developer.log('[LaneDetailsViewModel] Initialized. isEditable: $_isEditable, isFirstTime: $_isFirstTime', name: 'LaneDetailsViewModel');
  }

  void toggleEditable() {
    if (_isFirstTime) {
      developer.log('[LaneDetailsViewModel] Cannot toggle editable: isFirstTime is true.', name: 'LaneDetailsViewModel.toggleEditable');
      return;
    }
    if (_isLoading) {
      developer.log('[LaneDetailsViewModel] Cannot toggle editable: isLoading is true.', name: 'LaneDetailsViewModel.toggleEditable');
      return;
    }
    _isEditable = !_isEditable;
    developer.log('[LaneDetailsViewModel] Toggled editable state to: $_isEditable', name: 'LaneDetailsViewModel.toggleEditable');
    notifyListeners();
  }

  void resetToEditableState() {
    _isEditable = true;
    _isFirstTime = true;
    errors.clear();
    developer.log('[LaneDetailsViewModel] Reset to initial editable state.', name: 'LaneDetailsViewModel.resetToEditableState');
    // Note: Does not clear lanes here, happens in clearFieldsAndNotify if called
  }

  // CAUTION: This clears ALL lanes, including saved ones. Ensure this is intended behavior.
  void clearFieldsAndNotify() {
    developer.log('[LaneDetailsViewModel] Clearing ALL lane data and resetting state.', name: 'LaneDetailsViewModel.clearFieldsAndNotify', level: 1000);
    newlyAddedLanes.clear();
    savedLanes.clear(); // <<< Clears fetched/saved lanes too!
    errors.clear();
    _isEditable = true;
    _isFirstTime = true;
    _isLoading = false;
    notifyListeners(); // Notify UI after clearing
  }


  void populateForModification(List<Lane> initialLanes) {
    developer.log('[LaneDetailsViewModel] Populating for modification with ${initialLanes.length} saved lanes.', name: 'LaneDetailsViewModel.populateForModification');
    savedLanes.clear();
    savedLanes.addAll(initialLanes);
    newlyAddedLanes.clear();
    errors.clear();
    _isEditable = false; // Start in non-editable mode for modification
    _isFirstTime = false;
    _isLoading = false;
    developer.log('[LaneDetailsViewModel] Population complete. isEditable: $_isEditable, isFirstTime: $_isFirstTime', name: 'LaneDetailsViewModel.populateForModification');
    // No notifyListeners needed here usually, as it's part of initial setup
  }

  void clearError(String key) {
    if (errors.containsKey(key)) {
      developer.log('[LaneDetailsViewModel] Clearing error for key: $key', name: 'LaneDetailsViewModel.clearError');
      errors.remove(key);
      // Clear general error only if no specific errors remain (excluding 'general' itself)
      if (!errors.keys.any((k) => k != 'general' && errors[k] != null)) {
        errors.remove('general');
        developer.log('[LaneDetailsViewModel] Cleared general error as no specific errors remain.', name: 'LaneDetailsViewModel.clearError');
      }
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      developer.log('[LaneDetailsViewModel] isLoading set to: $_isLoading', name: 'LaneDetailsViewModel');
      if (_isLoading && errors.containsKey('general')) {
        // Optionally clear general errors when loading starts
        // errors.remove('general');
      }
      notifyListeners();
    }
  }

  // Assumes `lane` comes validated from AddLaneDialog (including duplicate check)
  void addNewLaneToList(Lane lane) {
    developer.log('[LaneDetailsViewModel] Adding validated NEW lane to list: ${lane.laneName}', name: 'LaneDetailsViewModel.addNewLaneToList');
    // Duplicate check should ideally happen in the dialog before calling this,
    // but we can add a final check here if necessary (though it adds complexity).
    // For simplicity, assuming dialog handles final validation & duplicate checks.

    // errors.remove('add_duplicate'); // Error keys might need adjustment if dialog handles this
    // errors.remove('general');
    // final List<Lane> combinedLanes = [...savedLanes, ...newlyAddedLanes];
    // final Map<String, String> duplicateErrors = _checkForDuplicates(lane, combinedLanes);
    // if (duplicateErrors.isNotEmpty) { /* Handle error */ } else { /* Add lane */ }

    newlyAddedLanes.add(lane);
    developer.log('[LaneDetailsViewModel] Added NEW lane: ${lane.laneName}. New count: ${newlyAddedLanes.length}. Notifying listeners...', name: 'LaneDetailsViewModel.addNewLaneToList');
    notifyListeners();
  }

  // Assumes `updatedLane` comes validated from EditNewLaneDialog (including duplicate check)
  void modifyNewLaneInList(int indexInNewList, Lane updatedLane) {
    developer.log('[LaneDetailsViewModel] Modifying NEW lane in list at index $indexInNewList: ${updatedLane.laneName}', name: 'LaneDetailsViewModel.modifyNewLaneInList');
    // Validation and duplicate checks should happen in the dialog.

    // errors.remove('edit_duplicate');
    // errors.remove('general');
    if (indexInNewList < 0 || indexInNewList >= newlyAddedLanes.length) {
      developer.log('[LaneDetailsViewModel] Error modifying new lane: Invalid index $indexInNewList', name: 'LaneDetailsViewModel.modifyNewLaneInList', level: 1000);
      // Optionally throw or handle error appropriately
      return; // Or throw
    }
    // Final duplicate check can optionally happen here

    newlyAddedLanes[indexInNewList] = updatedLane;
    developer.log('[LaneDetailsViewModel] Modified NEW lane at index $indexInNewList to: ${updatedLane.laneName}. Notifying listeners...', name: 'LaneDetailsViewModel.modifyNewLaneInList');
    notifyListeners();
  }

  void removeNewLaneFromList(int indexInNewList) {
    if (indexInNewList >= 0 && indexInNewList < newlyAddedLanes.length) {
      final removedLaneName = newlyAddedLanes[indexInNewList].laneName;
      newlyAddedLanes.removeAt(indexInNewList);
      developer.log('[LaneDetailsViewModel] Removed NEW lane at index $indexInNewList: $removedLaneName. New count: ${newlyAddedLanes.length}. Notifying listeners...', name: 'LaneDetailsViewModel.removeNewLaneFromList');
      errors.clear(); // Clear errors after successful removal
      notifyListeners();
    } else {
      developer.log('[LaneDetailsViewModel] Error removing new lane: Invalid index $indexInNewList', name: 'LaneDetailsViewModel.removeNewLaneFromList', level: 900);
    }
  }

  // Renamed fetch function as it's used outside modification context too
  Future<List<Lane>> fetchLanes(BuildContext context, String plazaId) async {
    if (_isLoading) {
      developer.log("[LaneDetailsViewModel] Fetch ignored: Already loading.", name: "LaneDetailsViewModel.fetchLanes");
      return savedLanes; // Return current list if loading
    }
    _setLoading(true);
    errors.clear();
    developer.log("[LaneDetailsViewModel] Attempting to fetch lanes for Plaza ID: $plazaId", name: "LaneDetailsViewModel.fetchLanes");
    try {
      // Assuming service handles String ID
      savedLanes.clear(); // Clear before fetching
      savedLanes.addAll(await _laneService.getLanesByPlazaId(plazaId));
      developer.log("[LaneDetailsViewModel] Fetched ${savedLanes.length} lanes successfully.", name: "LaneDetailsViewModel.fetchLanes");
      return savedLanes; // Return the fetched list
    } on PlazaException catch (e) { // Catch specific exception types first
      _handleServiceError(context, e, S.of(context).messageErrorLoadingLanes);
    } catch (e, stackTrace) {
      developer.log('[LaneDetailsViewModel] UNEXPECTED Error fetching lanes', error: e, stackTrace: stackTrace, name: 'LaneDetailsViewModel.fetchLanes', level: 1200);
      _handleGenericError(context, e);
    } finally {
      _setLoading(false);
    }
    return []; // Return empty list on error
  }

  // --- UPDATED saveNewlyAddedLanes ---
  Future<bool> saveNewlyAddedLanes(BuildContext context, String plazaId) async {
    developer.log('[LaneDetailsViewModel] Attempting saveNewlyAddedLanes: Count=${newlyAddedLanes.length}, isEditable=$_isEditable, isFirstTime=$_isFirstTime', name: 'LaneDetailsViewModel.saveNewlyAddedLanes');

    if (!_isEditable && !_isFirstTime) { // Allow save if first time, even if not 'editable'
      developer.log('[LaneDetailsViewModel] Save prevented: Step is not editable and not first time.', name: 'LaneDetailsViewModel.saveNewlyAddedLanes');
      return false; // Should not happen in normal flow but added guard
    }
    errors.clear();

    if (newlyAddedLanes.isEmpty) {
      developer.log('[LaneDetailsViewModel] No new lanes to save via API. Marking step as complete and locking.', name: 'LaneDetailsViewModel.saveNewlyAddedLanes');
      // Only lock if it was the first time saving this step
      if (_isFirstTime) {
        _isEditable = false;
        _isFirstTime = false;
      }
      _isLoading = false; // Ensure loading is off
      notifyListeners();
      return true; // Indicate success (nothing to save)
    }

    _setLoading(true);

    int? parsedPlazaId;
    try {
      parsedPlazaId = int.parse(plazaId);
      // Check based on create schema (min: 0)
      if (parsedPlazaId < 0) throw const FormatException("Invalid Plaza ID");
    } catch (_) {
      developer.log('[LaneDetailsViewModel] Invalid Plaza ID ($plazaId) for saving lanes.', name: 'LaneDetailsViewModel.saveNewlyAddedLanes', level: 1000);
      errors['general'] = S.of(context).errorInvalidPlazaId;
      _setLoading(false);
      return false;
    }

    List<Lane> validatedLanesToSend = [];
    List<String> validationErrorMessages = [];
    bool hasValidationErrors = false;

    // 1. Construct final Lane objects and validate using model method
    for (int i = 0; i < newlyAddedLanes.length; i++) {
      final originalNewLane = newlyAddedLanes[i];

      // Construct the final object - ensure plazaId and plazaLaneId are correct
      // If plazaLaneId is 0 or null from dialog, validation will catch it if required > 0
      final laneToValidate = Lane(
        plazaId: parsedPlazaId, // Use parsed ID
        plazaLaneId: originalNewLane.plazaLaneId, // Value from dialog
        laneName: originalNewLane.laneName,
        laneDirection: originalNewLane.laneDirection,
        laneType: originalNewLane.laneType,
        laneStatus: originalNewLane.laneStatus,
        rfidReaderId: originalNewLane.rfidReaderId,
        cameraId: originalNewLane.cameraId,
        wimId: originalNewLane.wimId,
        boomerBarrierId: originalNewLane.boomerBarrierId,
        ledScreenId: originalNewLane.ledScreenId,
        magneticLoopId: originalNewLane.magneticLoopId,
        laneId: null, // Should be null for new
        recordStatus: null, // Should be null for new
      );

      // Use the Lane model's validation method
      final String? validationError = laneToValidate.validateForCreate();
      if (validationError != null) {
        hasValidationErrors = true;
        // Improve error message format
        String errorMsg = "Lane '${laneToValidate.laneName}' (Index $i): $validationError";
        validationErrorMessages.add(errorMsg);
        developer.log('[LaneDetailsViewModel] Validation failed for lane "${laneToValidate.laneName}": $errorMsg', name: 'LaneDetailsViewModel.saveNewlyAddedLanes');
      } else {
        validatedLanesToSend.add(laneToValidate); // Add only if valid
      }
    }

    if (hasValidationErrors) {
      // Combine specific errors into the general error message
      errors['general'] = "Please correct errors in New Lanes:\n- ${validationErrorMessages.join('\n- ')}";
      developer.log('[LaneDetailsViewModel] Validation failed for one or more new lanes.', name: 'LaneDetailsViewModel.saveNewlyAddedLanes');
      _setLoading(false);
      return false;
    }

    // 2. Duplicate Check against ALL lanes (optional here if done thoroughly in dialogs)
    final duplicateCheckErrors = _checkForDuplicatesAgainstAll(context, validatedLanesToSend);
    if (duplicateCheckErrors.isNotEmpty) {
      errors['general'] = "Duplicate entries found (check names/IDs):\n- ${duplicateCheckErrors.join('\n- ')}";
      developer.log('[LaneDetailsViewModel] Duplicate check failed before API call.', name: 'LaneDetailsViewModel.saveNewlyAddedLanes');
      _setLoading(false);
      return false;
    }
    developer.log('[LaneDetailsViewModel] Pre-save validation and duplicate checks passed.', name: 'LaneDetailsViewModel.saveNewlyAddedLanes');

    // 3. API Call with validated list
    try {
      developer.log('[LaneDetailsViewModel] Calling _laneService.addLane API for ${validatedLanesToSend.length} validated lanes...', name: 'LaneDetailsViewModel.saveNewlyAddedLanes');
      List<Lane> createdLanesFromApi = await _laneService.addLane(validatedLanesToSend); // Pass validated list
      developer.log('[LaneDetailsViewModel] addLane API successful. Received ${createdLanesFromApi.length} lanes back.', name: 'LaneDetailsViewModel.saveNewlyAddedLanes');

      // 4. Update State
      savedLanes.addAll(createdLanesFromApi); // Add newly saved lanes to the saved list
      newlyAddedLanes.clear(); // Clear the temporary list
      _isEditable = false; // Lock editing after successful save
      _isFirstTime = false; // Mark step as completed
      errors.clear();
      _setLoading(false);
      notifyListeners(); // Notify UI of changes
      return true; // Indicate success

    } on PlazaException catch (e) { // Catch specific exceptions first
      _handleServiceError(context, e, S.of(context).messageErrorSavingLane);
      _setLoading(false);
      return false;
    } on RequestTimeoutException catch (e) {
      _handleServiceError(context, e, S.of(context).errorTimeout);
      _setLoading(false);
      return false;
    } on NoInternetException catch (e) {
      _handleServiceError(context, e, S.of(context).errorNoInternet);
      _setLoading(false);
      return false;
    } on ServerConnectionException catch (e) {
      _handleServiceError(context, e, S.of(context).errorServerConnection);
      _setLoading(false);
      return false;
    } catch (e, stackTrace) {
      developer.log('[LaneDetailsViewModel] UNEXPECTED Error saving new lanes', error: e, stackTrace: stackTrace, name: 'LaneDetailsViewModel.saveNewlyAddedLanes', level: 1200);
      _handleGenericError(context, e);
      _setLoading(false);
      return false;
    }
  }
  // --- END UPDATED saveNewlyAddedLanes ---


  // --- UPDATED updateSavedLane ---
  Future<bool> updateSavedLane(int indexInSavedList, Lane updatedLaneFromDialog, BuildContext context) async {
    developer.log('[LaneDetailsViewModel] Attempting updateSavedLane at index $indexInSavedList for Lane Name: ${updatedLaneFromDialog.laneName}', name: 'LaneDetailsViewModel.updateSavedLane');

    // --- Initial Checks ---
    if (!_isEditable) {
      developer.log("[LaneDetailsViewModel] Cannot update saved lane: Step not editable.", name: "LaneDetailsViewModel.updateSavedLane");
      // Throwing here makes the dialog show the error, which is good UX
      throw PlazaException(S.of(context).errorEditingDisabled);
    }
    if (indexInSavedList < 0 || indexInSavedList >= savedLanes.length) {
      developer.log("[LaneDetailsViewModel] Cannot update saved lane: Invalid index $indexInSavedList.", name: "LaneDetailsViewModel.updateSavedLane", level: 1000);
      throw PlazaException(S.of(context).errorInvalidLaneIndex);
    }

    final originalLane = savedLanes[indexInSavedList];
    // Validate the ORIGINAL lane ID before proceeding
    if (originalLane.laneId == null || originalLane.laneId! <= 0) {
      developer.log("[LaneDetailsViewModel] Cannot update saved lane: Original lane data missing valid ID.", name: "LaneDetailsViewModel.updateSavedLane", level: 1000);
      throw PlazaException(S.of(context).errorInvalidLaneData);
    }
    // Validate the ORIGINAL record status needed for update
    if (originalLane.recordStatus == null || !Lane.validRecordStatuses.contains(originalLane.recordStatus?.toLowerCase())) {
      developer.log("[LaneDetailsViewModel] Cannot update saved lane: Original lane data missing valid RecordStatus.", name: "LaneDetailsViewModel.updateSavedLane", level: 1000);
      throw PlazaException(S.of(context).errorInvalidRecordStatus);
    }


    _setLoading(true);
    errors.clear(); // Clear previous errors specific to this operation

    // --- Construct the FINAL Lane object to send ---
    // Combine original essential IDs/status with data from the dialog
    final laneToSend = Lane(
      // Essential fields from ORIGINAL lane that don't change or are needed for update
      laneId: originalLane.laneId, // Must be valid
      plazaId: originalLane.plazaId, // Must exist
      plazaLaneId: originalLane.plazaLaneId, // Must exist
      recordStatus: originalLane.recordStatus, // Must exist and be valid

      // Fields potentially updated in the dialog
      laneName: updatedLaneFromDialog.laneName,
      laneDirection: updatedLaneFromDialog.laneDirection,
      laneType: updatedLaneFromDialog.laneType,
      laneStatus: updatedLaneFromDialog.laneStatus,
      rfidReaderId: updatedLaneFromDialog.rfidReaderId,
      cameraId: updatedLaneFromDialog.cameraId,
      wimId: updatedLaneFromDialog.wimId,
      boomerBarrierId: updatedLaneFromDialog.boomerBarrierId,
      ledScreenId: updatedLaneFromDialog.ledScreenId,
      magneticLoopId: updatedLaneFromDialog.magneticLoopId,
    );
    developer.log('[LaneDetailsViewModel] Constructed laneToSend: ${laneToSend.toJsonForUpdate()}', name: 'LVM.updateSavedLane');

    // --- Validate using Model Method ---
    final String? validationError = laneToSend.validateForUpdate(); // USE Model validator

    if (validationError != null) {
      errors['update_validation'] = validationError; // Use direct error message
      developer.log("[LaneDetailsViewModel] Validation failed for update: $validationError", name: "LaneDetailsViewModel.updateSavedLane");
      _setLoading(false);
      throw PlazaException(S.of(context).validationFailed, serverMessage: validationError); // Pass validation error back
    }
    developer.log('[LaneDetailsViewModel] Model validation successful for update.', name: 'LVM.updateSavedLane');

    // --- Duplicate Check ---
    final List<Lane> otherLanesToCheck = [
      ...savedLanes.where((l) => l.laneId != originalLane.laneId), // Exclude self
      ...newlyAddedLanes
    ];
    final Map<String, String> duplicateErrors = _checkForDuplicates(laneToSend, otherLanesToCheck);
    if (duplicateErrors.isNotEmpty) {
      final String errorMsg = "Duplicate entries found:\n- ${duplicateErrors.entries.map((e) => e.value).join('\n- ')}";
      errors['update_duplicate'] = errorMsg;
      errors['general'] = S.of(context).validationDuplicateGeneral;
      developer.log("[LaneDetailsViewModel] Duplicate check failed for update: $errorMsg", name: "LaneDetailsViewModel.updateSavedLane");
      _setLoading(false);
      throw PlazaException(S.of(context).validationDuplicateGeneral, serverMessage: errorMsg); // Pass duplicate error back
    }
    developer.log('[LaneDetailsViewModel] Duplicate check successful for update.', name: 'LVM.updateSavedLane');


    // --- API Call ---
    try {
      developer.log('[LaneDetailsViewModel] Calling _laneService.updateLane API for lane ID: ${laneToSend.laneId}...', name: 'LaneDetailsViewModel.updateSavedLane');
      bool success = await _laneService.updateLane(laneToSend); // Pass the validated object
      if (success) {
        savedLanes[indexInSavedList] = laneToSend; // Update local list
        errors.clear();
        developer.log("[LaneDetailsViewModel] Successfully Updated SAVED lane ID: ${laneToSend.laneId}. Notifying.", name: "LaneDetailsViewModel.updateSavedLane");
        _setLoading(false);
        notifyListeners();
        return true; // Indicate success
      } else {
        developer.log("[LaneDetailsViewModel] updateLane API returned false for ID: ${laneToSend.laneId}.", name: "LaneDetailsViewModel.updateSavedLane", level: 900);
        throw ServiceException(S.of(context).messageErrorUpdatingLaneServer); // Specific message
      }
    } on PlazaException catch (e) { // Catch specific exceptions first
      _handleServiceError(context, e, S.of(context).messageErrorUpdatingLane);
      _setLoading(false);
      rethrow; // Rethrow to signal failure to the caller (dialog)
    } on RequestTimeoutException catch (e) {
      _handleServiceError(context, e, S.of(context).errorTimeout);
      _setLoading(false);
      rethrow;
    } on NoInternetException catch (e) {
      _handleServiceError(context, e, S.of(context).errorNoInternet);
      _setLoading(false);
      rethrow;
    } on ServerConnectionException catch (e) {
      _handleServiceError(context, e, S.of(context).errorServerConnection);
      _setLoading(false);
      rethrow;
    } catch (e, stackTrace) {
      developer.log('[LaneDetailsViewModel] UNEXPECTED Error updating saved lane', error: e, stackTrace: stackTrace, name: 'LaneDetailsViewModel.updateSavedLane', level: 1200);
      _handleGenericError(context, e);
      _setLoading(false);
      rethrow; // Rethrow to signal failure
    }
  }
  // --- END UPDATED updateSavedLane ---


  // Performs duplicate check for a single lane against a list of others
  Map<String, String> _checkForDuplicates(Lane laneToCheck, List<Lane> againstLanes) {
    final duplicateErrors = <String, String>{};
    developer.log('[LaneDetailsViewModel] Checking duplicates for lane "${laneToCheck.laneName}" (ID: ${laneToCheck.laneId}) against ${againstLanes.length} other lanes.', name: '_checkForDuplicates');
    bool isDuplicateValue(String? newValue, String? existingValue) {
      if (newValue == null || newValue.trim().isEmpty) return false;
      if (existingValue == null || existingValue.trim().isEmpty) return false;
      return newValue.trim().toLowerCase() == existingValue.trim().toLowerCase();
    }

    for (var existingLane in againstLanes) {
      // Skip self-comparison if both lanes have valid IDs and they match
      if (laneToCheck.laneId != null && existingLane.laneId != null && laneToCheck.laneId == existingLane.laneId) {
        // developer.log('[LaneDetailsViewModel] Skipping self-comparison for lane ID ${laneToCheck.laneId}', name: '_checkForDuplicates');
        continue;
      }

      // Check other potential unique fields
      if (isDuplicateValue(laneToCheck.laneName, existingLane.laneName)) {
        duplicateErrors['LaneName'] = "Duplicate Lane name";
        developer.log('[LaneDetailsViewModel] Duplicate LaneName found: ${laneToCheck.laneName}', name: '_checkForDuplicates');
      }
      if (isDuplicateValue(laneToCheck.plazaId.toString() + laneToCheck.plazaLaneId.toString(),
          existingLane.plazaId.toString() + existingLane.plazaLaneId.toString())) {
        duplicateErrors['plazaLaneId'] = "Duplicate Plaza Lane ID";
        developer.log('[LaneDetailsViewModel] Duplicate PlazaLaneID found: ${laneToCheck.plazaLaneId} for Plaza ${laneToCheck.plazaId}', name: '_checkForDuplicates');
      }
      if (isDuplicateValue(laneToCheck.rfidReaderId, existingLane.rfidReaderId)) {
        duplicateErrors['RFIDReaderID'] = "Duplicate RFID ID";
        developer.log('[LaneDetailsViewModel] Duplicate RFIDReaderID found: ${laneToCheck.rfidReaderId}', name: '_checkForDuplicates');
      }
      if (isDuplicateValue(laneToCheck.cameraId, existingLane.cameraId)) {
        duplicateErrors['CameraID'] = "Duplicate Camera ID";
        developer.log('[LaneDetailsViewModel] Duplicate CameraID found: ${laneToCheck.cameraId}', name: '_checkForDuplicates');
      }
      if (isDuplicateValue(laneToCheck.wimId, existingLane.wimId)) {
        duplicateErrors['WIMID'] = "Duplicate WIM ID";
        developer.log('[LaneDetailsViewModel] Duplicate WIMID found: ${laneToCheck.wimId}', name: '_checkForDuplicates');
      }
      if (isDuplicateValue(laneToCheck.boomerBarrierId, existingLane.boomerBarrierId)) {
        duplicateErrors['BoomerBarrierID'] = "Duplicate Boomer Barrier ID";
        developer.log('[LaneDetailsViewModel] Duplicate BoomerBarrierID found: ${laneToCheck.boomerBarrierId}', name: '_checkForDuplicates');
      }
      if (isDuplicateValue(laneToCheck.ledScreenId, existingLane.ledScreenId)) {
        duplicateErrors['LEDScreenID'] = "Duplicate LED Screen ID";
        developer.log('[LaneDetailsViewModel] Duplicate LEDScreenID found: ${laneToCheck.ledScreenId}', name: '_checkForDuplicates');
      }
      if (isDuplicateValue(laneToCheck.magneticLoopId, existingLane.magneticLoopId)) {
        duplicateErrors['MagneticLoopID'] = "Duplicate Magnetic Loop ID";
        developer.log('[LaneDetailsViewModel] Duplicate MagneticLoopID found: ${laneToCheck.magneticLoopId}', name: '_checkForDuplicates');
      }
    }
    developer.log('[LaneDetailsViewModel] Duplicate check result for "${laneToCheck.laneName}": Found ${duplicateErrors.length} duplicates.', name: '_checkForDuplicates');
    return duplicateErrors;
  }

  // Checks for duplicates across all lanes (saved + candidates) - useful before batch save
  List<String> _checkForDuplicatesAgainstAll(BuildContext context, List<Lane> candidateLanes) {
    developer.log('[LaneDetailsViewModel] Checking for duplicates against ALL (${savedLanes.length} saved) for ${candidateLanes.length} candidates.', name: '_checkForDuplicatesAgainstAll');
    final List<Lane> combinedPotentialLanes = [...savedLanes, ...candidateLanes];
    List<String> duplicateErrorMessages = [];
    // Use sets to track seen values efficiently
    Set<String> seenLaneNames = {};
    Set<String> seenPlazaLaneIds = {}; // Key: "plazaId_plazaLaneId"
    Set<String> seenRfidIds = {};
    Set<String> seenCameraIds = {};
    Set<String> seenWimIds = {};
    Set<String> seenBoomerIds = {};
    Set<String> seenLedIds = {};
    Set<String> seenLoopIds = {};

    void checkAndAddDuplicate(Set<String> seenSet, String? value, String fieldNameForError, {String? mapKey}) {
      if (value == null || value.trim().isEmpty) return;
      final key = mapKey ?? value.trim().toLowerCase(); // Use mapKey if provided (for combined IDs)
      if (seenSet.contains(key)) {
        // Only add the error message once per unique duplicate value
        String errorMsg = S.of(context).validationDuplicate("$fieldNameForError '${value.trim()}'");
        if (!duplicateErrorMessages.contains(errorMsg)){
          duplicateErrorMessages.add(errorMsg);
          developer.log('[LaneDetailsViewModel] Duplicate found for $fieldNameForError: $value', name: '_checkForDuplicatesAgainstAll');
        }
      } else {
        seenSet.add(key);
      }
    }

    for (final lane in combinedPotentialLanes) {
      checkAndAddDuplicate(seenLaneNames, lane.laneName, "Lane name");
      // Check combined Plaza ID + Plaza Lane ID for uniqueness
      checkAndAddDuplicate(seenPlazaLaneIds, lane.plazaLaneId.toString(), "Plaza Lane ID", mapKey: "${lane.plazaId}_${lane.plazaLaneId}");
      checkAndAddDuplicate(seenRfidIds, lane.rfidReaderId, "RFID ID");
      checkAndAddDuplicate(seenCameraIds, lane.cameraId, "Camera ID");
      checkAndAddDuplicate(seenWimIds, lane.wimId, "WIM ID");
      checkAndAddDuplicate(seenBoomerIds, lane.boomerBarrierId, "Boomer Barrier ID");
      checkAndAddDuplicate(seenLedIds, lane.ledScreenId, "LED Screen ID");
      checkAndAddDuplicate(seenLoopIds, lane.magneticLoopId, "Magnetic Loop ID");
    }

    developer.log('[LaneDetailsViewModel] Duplicate check against all found ${duplicateErrorMessages.length} issues.', name: '_checkForDuplicatesAgainstAll');
    return duplicateErrorMessages;
  }


  // --- Error Handling ---
  void _handleServiceError(BuildContext context, Exception e, String defaultMessage) {
    String errorMessage = defaultMessage;
    int? statusCode;
    if (e is HttpException) {
      errorMessage = e.serverMessage ?? e.message ?? defaultMessage;
      statusCode = e.statusCode;
    } else if (e is ServiceException) {
      errorMessage = e.serverMessage ?? e.message ?? defaultMessage;
      statusCode = e.statusCode;
    } else if (e is PlazaException) { // Assuming PlazaException has message/serverMessage/statusCode
      errorMessage = e.serverMessage ?? e.message ?? defaultMessage;
      statusCode = e.statusCode;
    } else if (e is RequestTimeoutException) {
      errorMessage = S.of(context).errorTimeout;
    } else if (e is NoInternetException) {
      errorMessage = S.of(context).errorNoInternet;
    } else if (e is ServerConnectionException) {
      errorMessage = S.of(context).errorServerConnection;
    } else {
      errorMessage = S.of(context).errorUnexpected; // Fallback for other Exceptions
    }
    developer.log('[LaneDetailsViewModel] Handling Service Error: ${e.runtimeType} - "$errorMessage" ${statusCode != null ? '(Status: $statusCode)' : ''}', error: e, stackTrace: StackTrace.current, name: 'LaneDetailsViewModel._handleServiceError', level: 900);
    errors['general'] = errorMessage; // Set the general error for UI display
    if (context.mounted) {
      // Optional: Show snackbar immediately, or let the UI react to the error state
      // AppSnackbar.showSnackbar(context: context, message: errorMessage, type: SnackbarType.error);
    }
    notifyListeners(); // Notify UI about the error state
  }

  void _handleGenericError(BuildContext context, dynamic e) {
    final message = S.of(context).errorUnexpected;
    errors['general'] = message;
    developer.log('[LaneDetailsViewModel] Handling Generic Error: $e', error: e, stackTrace: StackTrace.current, name: 'LaneDetailsViewModel._handleGenericError', level: 1000);
    if (context.mounted) {
      // AppSnackbar.showSnackbar(context: context, message: message, type: SnackbarType.error);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    developer.log('[LaneDetailsViewModel] Disposing...', name: 'LaneDetailsViewModel');
    super.dispose();
    developer.log('[LaneDetailsViewModel] Dispose complete.', name: 'LaneDetailsViewModel');
  }
}