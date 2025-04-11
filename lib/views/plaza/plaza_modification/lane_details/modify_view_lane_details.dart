import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:merchant_app/generated/l10n.dart';
import 'package:merchant_app/models/lane.dart';
// Import PlazaModificationViewModel assuming it holds the selected lane and lanes list
import 'package:merchant_app/viewmodels/plaza/plaza_modification_viewmodel.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:merchant_app/utils/components/dropdown.dart';
import 'package:merchant_app/utils/components/form_field.dart';
import 'package:merchant_app/utils/components/button.dart';
import 'package:merchant_app/utils/exceptions.dart';
import 'dart:developer' as developer;

class ModifyViewLaneDetailsScreen extends StatefulWidget {
  final String laneId; // Keep String here as passed via routing

  const ModifyViewLaneDetailsScreen({super.key, required this.laneId});

  @override
  State<ModifyViewLaneDetailsScreen> createState() =>
      _ModifyViewLaneDetailsScreenState();
}

class _ModifyViewLaneDetailsScreenState
    extends State<ModifyViewLaneDetailsScreen> {
  bool _isEditing = false;
  bool _isInitialized = false;
  // Local saving state for the FAB, independent of general ViewModel loading
  bool _isSavingLane = false;

  late final TextEditingController _laneNameController;
  late final TextEditingController _rfidReaderIdController;
  late final TextEditingController _cameraIdController;
  late final TextEditingController _wimIdController;
  late final TextEditingController _boomerBarrierIdController;
  late final TextEditingController _ledScreenIdController;
  late final TextEditingController _magneticLoopIdController;

  // Add state variables for dropdowns to avoid direct model mutation
  String? _selectedDirection;
  String? _selectedType;
  String? _selectedStatus;


  @override
  void initState() {
    super.initState();
    developer.log('[ModifyViewLaneDetailsScreen] initState for laneId (String): ${widget.laneId}', name: 'ModifyViewLaneDetailsScreen');
    _laneNameController = TextEditingController();
    _rfidReaderIdController = TextEditingController();
    _cameraIdController = TextEditingController();
    _wimIdController = TextEditingController();
    _boomerBarrierIdController = TextEditingController();
    _ledScreenIdController = TextEditingController();
    _magneticLoopIdController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fetchLaneDetails();
      }
    });
  }

  @override
  void dispose() {
    developer.log('[ModifyViewLaneDetailsScreen] dispose', name: 'ModifyViewLaneDetailsScreen');
    _laneNameController.dispose();
    _rfidReaderIdController.dispose();
    _cameraIdController.dispose();
    _wimIdController.dispose();
    _boomerBarrierIdController.dispose();
    _ledScreenIdController.dispose();
    _magneticLoopIdController.dispose();
    super.dispose();
  }

  Future<void> _fetchLaneDetails() async {
    if (!mounted) return;
    final viewModel = context.read<PlazaModificationViewModel>();
    developer.log('[ModifyViewLaneDetailsScreen] Fetching lane details for laneId (String): ${widget.laneId}', name: 'ModifyViewLaneDetailsScreen');
    // Reset flags and potentially clear form before fetching
    setState(() {
      _isInitialized = false;
      _isEditing = false; // Ensure not in edit mode during fetch
      _isSavingLane = false;
      // Clear previous data? Optional, depends on desired UX on retry.
      // _populateFormFields(null);
    });
    try {
      // Assume viewModel.fetchLaneById can handle the String ID internally
      await viewModel.fetchLaneById(widget.laneId);
      _isInitialized = true;
      // Populate controllers and local state *after* fetching
      _populateFormFields(viewModel.selectedLane);
      if (mounted) setState(() {}); // Trigger rebuild after fetch and populate
    } catch (e, stackTrace) {
      developer.log('[ModifyViewLaneDetailsScreen] Error fetching lane details: $e', name: 'ModifyViewLaneDetailsScreen', error: e, stackTrace: stackTrace, level: 1000);
      _isInitialized = true; // Mark as initialized even on error to show error state
      if (mounted) setState(() {});
    }
  }

  // Populate controllers AND local dropdown state variables
  void _populateFormFields(Lane? lane) {
    developer.log('[ModifyViewLaneDetailsScreen] Populating form fields. Lane: ${lane?.laneName}', name: 'ModifyViewLaneDetailsScreen');
    if (lane != null) {
      _laneNameController.text = lane.laneName;
      _rfidReaderIdController.text = lane.rfidReaderId ?? '';
      _cameraIdController.text = lane.cameraId ?? '';
      _wimIdController.text = lane.wimId ?? '';
      _boomerBarrierIdController.text = lane.boomerBarrierId ?? '';
      _ledScreenIdController.text = lane.ledScreenId ?? '';
      _magneticLoopIdController.text = lane.magneticLoopId ?? '';
      // Populate local state for dropdowns
      _selectedDirection = lane.laneDirection;
      _selectedType = lane.laneType;
      _selectedStatus = lane.laneStatus;
    } else {
      // Clear fields if lane is null
      _laneNameController.clear();
      _rfidReaderIdController.clear();
      _cameraIdController.clear();
      _wimIdController.clear();
      _boomerBarrierIdController.clear();
      _ledScreenIdController.clear();
      _magneticLoopIdController.clear();
      _selectedDirection = null;
      _selectedType = null;
      _selectedStatus = null;
    }
  }

  // Builds the form fields, reading from controllers and local state
  Widget _buildLaneFields(PlazaModificationViewModel viewModel, S strings) {
    final lane = viewModel.selectedLane; // Primarily used to check existence

    // Guard clauses for loading/error/no data states are handled in the main build method
    if (lane == null) {
      // This case should ideally be handled by the main build method logic
      // If it gets here, it implies an error state that wasn't caught earlier.
      developer.log('[ModifyViewLaneDetailsScreen] _buildLaneFields called but selectedLane is null.', name: 'ModifyViewLaneDetailsScreen', level: 1000);
      return Center(child: Text(strings.errorLoadingLaneDetails)); // Show generic error
    }

    // No need for the postFrameCallback here, controllers are populated after fetch

    return Column(
      children: [
        CustomFormFields.normalSizedTextFormField(
          context: context,
          label: strings.laneName,
          controller: _laneNameController,
          keyboardType: TextInputType.text,
          enabled: _isEditing,
        ),
        const SizedBox(height: 16),
        CustomDropDown.normalDropDown(
          context: context,
          label: strings.laneDirection,
          items: Lane.validDirections,
          value: _selectedDirection, // Use local state variable
          onChanged: _isEditing
              ? (value) => setState(() => _selectedDirection = value) // Update local state
              : null,
          enabled: _isEditing,
        ),
        const SizedBox(height: 16),
        CustomDropDown.normalDropDown(
          context: context,
          label: strings.laneType,
          items: Lane.validTypes,
          value: _selectedType, // Use local state variable
          onChanged: _isEditing
              ? (value) => setState(() => _selectedType = value) // Update local state
              : null,
          enabled: _isEditing,
        ),
        const SizedBox(height: 16),
        CustomDropDown.normalDropDown(
          context: context,
          label: strings.laneStatus,
          items: Lane.validStatuses,
          value: _selectedStatus, // Use local state variable
          onChanged: _isEditing
              ? (value) => setState(() => _selectedStatus = value) // Update local state
              : null,
          enabled: _isEditing,
        ),
        const SizedBox(height: 16),
        // Text fields remain the same, reading from controllers
        CustomFormFields.normalSizedTextFormField(
          context: context,
          label: strings.rfidReaderId,
          controller: _rfidReaderIdController,
          keyboardType: TextInputType.text,
          enabled: _isEditing,
        ),
        const SizedBox(height: 16),
        CustomFormFields.normalSizedTextFormField(
          context: context,
          label: strings.cameraId,
          controller: _cameraIdController,
          keyboardType: TextInputType.text,
          enabled: _isEditing,
        ),
        const SizedBox(height: 16),
        CustomFormFields.normalSizedTextFormField(
          context: context,
          label: strings.wimId,
          controller: _wimIdController,
          keyboardType: TextInputType.text,
          enabled: _isEditing,
        ),
        const SizedBox(height: 16),
        CustomFormFields.normalSizedTextFormField(
          context: context,
          label: strings.boomerBarrierId,
          controller: _boomerBarrierIdController,
          keyboardType: TextInputType.text,
          enabled: _isEditing,
        ),
        const SizedBox(height: 16),
        CustomFormFields.normalSizedTextFormField(
          context: context,
          label: strings.ledScreenId,
          controller: _ledScreenIdController,
          keyboardType: TextInputType.text,
          enabled: _isEditing,
        ),
        const SizedBox(height: 16),
        CustomFormFields.normalSizedTextFormField(
          context: context,
          label: strings.magneticLoopId,
          controller: _magneticLoopIdController,
          keyboardType: TextInputType.text,
          enabled: _isEditing,
        ),
        const SizedBox(height: 80), // Space for FAB
      ],
    );
  }

  // Updated duplicate check uses int? laneId
  Map<String, String> _checkForDuplicates(Lane updatedLane, List<Lane> existingLanes) {
    final duplicateErrors = <String, String>{};
    final int? currentLaneIdInt = updatedLane.laneId; // Use int? ID

    developer.log('[ModifyViewLaneDetailsScreen] Checking duplicates for lane "${updatedLane.laneName}" (ID: $currentLaneIdInt) against ${existingLanes.length} other lanes.', name: 'ModifyViewLaneDetailsScreen._checkForDuplicates');

    bool isDuplicateValue(String? newValue, String? existingValue) {
      if (newValue == null || newValue.trim().isEmpty) return false;
      if (existingValue == null || existingValue.trim().isEmpty) return false;
      return newValue.trim().toLowerCase() == existingValue.trim().toLowerCase();
    }

    for (var existingLane in existingLanes) {
      // Compare int? IDs
      if (existingLane.laneId == currentLaneIdInt) {
        developer.log('[ModifyViewLaneDetailsScreen] Skipping self-comparison for lane ID: $currentLaneIdInt', name: 'ModifyViewLaneDetailsScreen._checkForDuplicates');
        continue;
      }

      // Rest of the checks...
      if (isDuplicateValue(updatedLane.laneName, existingLane.laneName)) {
        duplicateErrors['LaneName'] = S.of(context).validationDuplicate('Lane name');
      }
      if (isDuplicateValue(updatedLane.rfidReaderId, existingLane.rfidReaderId)) {
        duplicateErrors['RFIDReaderID'] = S.of(context).validationDuplicate('RFID Reader ID');
      }
      if (isDuplicateValue(updatedLane.cameraId, existingLane.cameraId)) { duplicateErrors['CameraID'] = S.of(context).validationDuplicate('Camera ID'); }
      if (isDuplicateValue(updatedLane.wimId, existingLane.wimId)) { duplicateErrors['WIMID'] = S.of(context).validationDuplicate('WIM ID'); }
      if (isDuplicateValue(updatedLane.boomerBarrierId, existingLane.boomerBarrierId)) { duplicateErrors['BoomerBarrierID'] = S.of(context).validationDuplicate('Boomer Barrier ID'); }
      if (isDuplicateValue(updatedLane.ledScreenId, existingLane.ledScreenId)) { duplicateErrors['LEDScreenID'] = S.of(context).validationDuplicate('LED Screen ID'); }
      if (isDuplicateValue(updatedLane.magneticLoopId, existingLane.magneticLoopId)) { duplicateErrors['MagneticLoopID'] = S.of(context).validationDuplicate('Magnetic Loop ID'); }
      // Check plazaLaneId uniqueness within the same plaza
      if (updatedLane.plazaId == existingLane.plazaId && updatedLane.plazaLaneId == existingLane.plazaLaneId) {
        duplicateErrors['plazaLaneId'] = S.of(context).validationDuplicate('Plaza Lane ID');
      }
    }
    if (duplicateErrors.isNotEmpty) {
      developer.log('[ModifyViewLaneDetailsScreen] Duplicate check found issues: $duplicateErrors', name: 'ModifyViewLaneDetailsScreen._checkForDuplicates');
    }
    return duplicateErrors;
  }

  // Updated _handleSave
  Future<void> _handleSave(PlazaModificationViewModel viewModel, S strings) async {
    if (_isSavingLane) return;
    setState(() => _isSavingLane = true);

    FocusScope.of(context).unfocus();
    final originalLane = viewModel.selectedLane;

    if (originalLane == null || originalLane.laneId == null) {
      developer.log('[ModifyViewLaneDetailsScreen] Save failed: Original lane or laneId is null.',
          name: 'ModifyViewLaneDetailsScreen._handleSave', level: 1000);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.errorNoLaneToUpdate)),
      );
      setState(() => _isSavingLane = false);
      return;
    }

    // Construct Lane using instantiation, carrying over required fields
    final updatedLane = Lane(
      // Required fields from original lane
      laneId: originalLane.laneId,
      plazaId: originalLane.plazaId,
      plazaLaneId: originalLane.plazaLaneId ?? Random().nextInt(100000),
      recordStatus: originalLane.recordStatus, // IMPORTANT: Carry over recordStatus

      // Fields updated from form (using controllers and local state)
      laneName: _laneNameController.text.trim(),
      laneDirection: _selectedDirection ?? originalLane.laneDirection,
      laneType: _selectedType ?? originalLane.laneType,
      laneStatus: _selectedStatus ?? originalLane.laneStatus,

      // Optional fields updated from form
      rfidReaderId: _rfidReaderIdController.text.trim().isEmpty ? null : _rfidReaderIdController.text.trim(),
      cameraId: _cameraIdController.text.trim().isEmpty ? null : _cameraIdController.text.trim(),
      wimId: _wimIdController.text.trim().isEmpty ? null : _wimIdController.text.trim(),
      boomerBarrierId: _boomerBarrierIdController.text.trim().isEmpty ? null : _boomerBarrierIdController.text.trim(),
      ledScreenId: _ledScreenIdController.text.trim().isEmpty ? null : _ledScreenIdController.text.trim(),
      magneticLoopId: _magneticLoopIdController.text.trim().isEmpty ? null : _magneticLoopIdController.text.trim(),
    );
    // Log using the correct toJson method
    developer.log('[ModifyViewLaneDetailsScreen] Constructed updated Lane for validation/save: ${updatedLane.toJsonForUpdate()}',
        name: 'ModifyViewLaneDetailsScreen._handleSave');

    // Validate using model's update validator
    final validationError = updatedLane.validateForUpdate(); // USE THIS

    if (validationError != null) {
      developer.log('[ModifyViewLaneDetailsScreen] Model Validation Failed: "$validationError"',
          name: 'ModifyViewLaneDetailsScreen._handleSave', level: 900);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationError),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      setState(() => _isSavingLane = false);
      return;
    }
    developer.log('[ModifyViewLaneDetailsScreen] Model Validation Successful.',
        name: 'ModifyViewLaneDetailsScreen._handleSave');

    // Check for duplicates (pass the correctly constructed updatedLane)
    final duplicateErrors = _checkForDuplicates(updatedLane, viewModel.lanes);
    if (duplicateErrors.isNotEmpty) {
      developer.log('[ModifyViewLaneDetailsScreen] Duplicate Check Failed: $duplicateErrors',
          name: 'ModifyViewLaneDetailsScreen._handleSave', level: 900);
      String errorMessage = '${S.of(context).validationDuplicateGeneral}\n';
      duplicateErrors.forEach((key, value) { errorMessage += '- $value\n'; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage.trim()),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      setState(() => _isSavingLane = false);
      return;
    }
    developer.log('[ModifyViewLaneDetailsScreen] Duplicate Check Successful.',
        name: 'ModifyViewLaneDetailsScreen._handleSave');

    // Proceed with saving via ViewModel
    try {
      developer.log('[ModifyViewLaneDetailsScreen] Calling viewModel.updateLane with laneId (String): ${originalLane.laneId!.toString()}',
          name: 'ModifyViewLaneDetailsScreen._handleSave');
      // Convert int ID to String for the VM method call
      await viewModel.updateLane(originalLane.laneId!.toString(), updatedLane); // Pass ID as String
      developer.log('[ModifyViewLaneDetailsScreen] viewModel.updateLane completed.',
          name: 'ModifyViewLaneDetailsScreen._handleSave');

      // Refresh lane list (optional, depends on VM logic)
      // if (viewModel.plazaId != null) {
      //   developer.log('[ModifyViewLaneDetailsScreen] Refreshing lanes list after update.', name: 'ModifyViewLaneDetailsScreen._handleSave');
      //   await viewModel.fetchLanes(viewModel.plazaId!);
      // }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings.laneUpdatedSuccess),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Delay navigation to allow SnackBar to display
        await Future.delayed(const Duration(seconds: 2));
        if (mounted && Navigator.canPop(context)) {
          setState(() => _isEditing = false); // Exit editing mode
          Navigator.pop(context); // Navigate back after showing SnackBar
        }
      }
    } catch (e, stackTrace) {
      developer.log('[ModifyViewLaneDetailsScreen] Error during viewModel.updateLane: $e',
          name: 'ModifyViewLaneDetailsScreen._handleSave', error: e, stackTrace: stackTrace, level: 1000);
      if (mounted) {
        String errorMsg = strings.laneUpdateFailed;
        if (e is PlazaException) {
          errorMsg = e.serverMessage ?? e.message ?? errorMsg;
        } else {
          errorMsg = '$errorMsg: ${e.toString()}';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSavingLane = false); // Ensure flag is always reset
      }
    }
  }

  // Reset form to fetched data on cancel
  void _handleCancel(PlazaModificationViewModel viewModel, S strings) {
    FocusScope.of(context).unfocus();
    developer.log('[ModifyViewLaneDetailsScreen] Cancel edit.', name: 'ModifyViewLaneDetailsScreen._handleCancel');
    // Re-populate form with the original data from the view model
    _populateFormFields(viewModel.selectedLane);
    setState(() => _isEditing = false);
  }

  // Error state builder
  Widget _buildErrorState(PlazaModificationViewModel viewModel, S strings) {
    Exception? error = viewModel.error;
    String errorTitle = strings.errorUnableToLoadTicketDetails; // Might need a more specific title like "Error Loading Lane"
    String errorMessage = strings.errorMessageDefault;
    String? errorDetails;

    if (error is HttpException) { errorTitle = strings.errorTitleWithCode(error.statusCode ?? 0); errorMessage = error.message; errorDetails = error.serverMessage ?? strings.errorDetailsNoDetails; }
    else if (error is ServiceException) { errorTitle = strings.errorTitleService; errorMessage = error.message; errorDetails = error.serverMessage ?? strings.errorDetailsService; }
    else if (error != null) { errorTitle = strings.errorTitleUnexpected; errorMessage = strings.errorMessagePleaseTryAgain; errorDetails = error.toString(); }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text(errorTitle, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(errorMessage, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
            if (errorDetails != null && errorDetails.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(errorDetails, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)), textAlign: TextAlign.center),
            ],
            const SizedBox(height: 24),
            CustomButtons.primaryButton(text: strings.retry, onPressed: _fetchLaneDetails, context: context, width: 150, height: 40),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    return Consumer<PlazaModificationViewModel>(
      builder: (context, viewModel, _) {
        Widget bodyContent;

        // Determine body content based on state
        if (viewModel.isLoading && !_isInitialized) { bodyContent = const Center(child: CircularProgressIndicator()); }
        else if (viewModel.error != null && viewModel.selectedLane == null && _isInitialized) { bodyContent = _buildErrorState(viewModel, strings); }
        else if (viewModel.selectedLane == null && !viewModel.isLoading && _isInitialized) { bodyContent = Center(child: Text(strings.noLaneData)); }
        else if (viewModel.selectedLane != null) {
          bodyContent = SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            physics: const BouncingScrollPhysics(),
            child: _buildLaneFields(viewModel, strings),
          );
        }
        else { bodyContent = const Center(child: CircularProgressIndicator()); } // Initial loading before fetch starts

        return Scaffold(
          appBar: CustomAppBar.appBarWithNavigation(
            screenTitle: strings.editLaneDetails,
            onPressed: () => Navigator.pop(context),
            darkBackground: Theme.of(context).brightness == Brightness.dark,
            context: context,
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: AnimatedSwitcher( // Add fade transition between states
            duration: const Duration(milliseconds: 300),
            child: bodyContent,
          ),
          // Only show FAB if initialized, no error preventing display, and lane data exists
          floatingActionButton: _isInitialized && viewModel.error == null && viewModel.selectedLane != null
              ? Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (_isEditing) ...[
                FloatingActionButton.extended(
                  onPressed: _isSavingLane ? null : () => _handleCancel(viewModel, strings), // Use local flag
                  heroTag: 'cancelLaneFab',
                  tooltip: strings.cancel,
                  backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                  foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                  icon: const Icon(Icons.close),
                  label: Text(strings.cancel),
                ),
                const SizedBox(width: 16),
              ],
              FloatingActionButton.extended(
                onPressed: _isSavingLane ? null : () { // Use local flag
                  if (_isEditing) { _handleSave(viewModel, strings); }
                  else { setState(() => _isEditing = true); }
                },
                heroTag: 'mainLaneFab',
                tooltip: _isEditing ? strings.save : strings.edit,
                backgroundColor: _isSavingLane ? Colors.grey : Theme.of(context).colorScheme.primary, // Use local flag
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                // Use local _isSavingLane flag
                icon: _isSavingLane
                    ? Container(
                  width: 20, height: 20, margin: const EdgeInsets.only(right: 8),
                  child: CircularProgressIndicator( strokeWidth: 2, color: Theme.of(context).colorScheme.onPrimary ),
                )
                    : Icon(_isEditing ? Icons.save_outlined : Icons.edit_outlined), // Changed icons
                label: Text(_isEditing ? strings.save : strings.edit),
              ),
            ],
          )
              : null, // No FAB if not initialized or error or no lane data
        );
      },
    );
  }
}