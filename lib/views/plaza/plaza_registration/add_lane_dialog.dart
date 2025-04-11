import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for input formatters
import 'package:merchant_app/generated/l10n.dart';
import 'package:merchant_app/models/lane.dart';
import 'package:merchant_app/utils/components/dropdown.dart';
import 'package:merchant_app/utils/components/form_field.dart';
import 'package:merchant_app/viewmodels/plaza/plaza_viewmodel.dart';
// import 'package:merchant_app/viewmodels/plaza/plaza_form_validation.dart'; // REMOVE
import 'package:merchant_app/utils/exceptions.dart';

class AddLaneDialog extends StatefulWidget {
  final Function(Lane newLaneCandidate) onSave;
  final String plazaId; // Passed as String
  final PlazaViewModel plazaViewModel; // Still needed for context/duplicate check

  const AddLaneDialog({
    super.key,
    required this.onSave,
    required this.plazaId, // Keep as String to match original signature
    required this.plazaViewModel,
  });

  @override
  _AddLaneDialogState createState() => _AddLaneDialogState();
}

class _AddLaneDialogState extends State<AddLaneDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _laneNameController;
  // --- ADDED Controller ---
  late final TextEditingController _plazaLaneIdController;
  // --- END ADDED ---
  late final TextEditingController _rfidReaderController;
  late final TextEditingController _cameraController;
  late final TextEditingController _wimController;
  late final TextEditingController _boomerBarrierController;
  late final TextEditingController _ledScreenController;
  late final TextEditingController _magneticLoopController;
  String? _selectedDirection;
  String? _selectedType;
  String? _selectedStatus;
  final Map<String, String?> _errors = {};
  bool _isSaving = false;
  // final PlazaFormValidation _validator = PlazaFormValidation(); // REMOVE

  @override
  void initState() {
    super.initState();
    developer.log('[AddLaneDialog] initState', name: 'AddLaneDialog');
    _laneNameController = TextEditingController();
    // --- ADDED Initialization ---
    _plazaLaneIdController = TextEditingController();
    // --- END ADDED ---
    _rfidReaderController = TextEditingController();
    _cameraController = TextEditingController();
    _wimController = TextEditingController();
    _boomerBarrierController = TextEditingController();
    _ledScreenController = TextEditingController();
    _magneticLoopController = TextEditingController();
    // Default status
    _selectedStatus = Lane.validStatuses.firstWhere(
          (s) => s.toLowerCase() == 'active',
      orElse: () => Lane.validStatuses.first,
    );
    developer.log('[AddLaneDialog] Default status set to: $_selectedStatus', name: 'AddLaneDialog');

    // Validate passed plazaId early? Optional but good practice.
    if (int.tryParse(widget.plazaId) == null || int.parse(widget.plazaId) < 0) { // Adjust check based on create schema (min 0)
      developer.log('[AddLaneDialog] WARNING: Invalid plazaId passed to dialog: ${widget.plazaId}', name: 'AddLaneDialog', level: 1000);
      // Optionally disable save button or show an immediate error
    }
  }

  @override
  void dispose() {
    developer.log('[AddLaneDialog] dispose', name: 'AddLaneDialog');
    _laneNameController.dispose();
    // --- ADDED Dispose ---
    _plazaLaneIdController.dispose();
    // --- END ADDED ---
    _rfidReaderController.dispose();
    _cameraController.dispose();
    _wimController.dispose();
    _boomerBarrierController.dispose();
    _ledScreenController.dispose();
    _magneticLoopController.dispose();
    super.dispose();
  }

  void _handleSave() async {
    if (_isSaving) {
      developer.log('[AddLaneDialog] Save attempt ignored: Already saving.', name: 'AddLaneDialog');
      return;
    }
    setState(() { _isSaving = true; _errors.clear(); });
    developer.log('[AddLaneDialog] Handle Save: Starting process...', name: 'AddLaneDialog');

    // --- 1. Parse plazaId from widget parameter ---
    int? parsedPlazaId;
    try {
      parsedPlazaId = int.parse(widget.plazaId);
      // Optional: Add check based on create schema (min: 0)
      if (parsedPlazaId < 0) throw const FormatException("Plaza ID cannot be negative.");
    } catch (e) {
      developer.log('[AddLaneDialog] Handle Save: Invalid plazaId passed to widget: "${widget.plazaId}"', name: 'AddLaneDialog', level: 1000);
      setState(() {
        _errors['general'] = S.of(context).errorInvalidPlazaId; // Add specific string
        _isSaving = false;
      });
      return;
    }
    // --- END Parse plazaId ---

    // --- 2. Parse plazaLaneId from form ---
    int? parsedPlazaLaneId;
    final plazaLaneIdString = _plazaLaneIdController.text.trim();
    if (plazaLaneIdString.isEmpty) {
      developer.log('[AddLaneDialog] Handle Save: Plaza Lane ID field is empty.', name: 'AddLaneDialog', level: 900);
      setState(() {
        _errors['plazaLaneId'] = S.of(context).validationFieldRequired("Plaza Lane ID");
        _isSaving = false;
      });
      return;
    }
    try {
      parsedPlazaLaneId = int.parse(plazaLaneIdString);
      if (parsedPlazaLaneId <= 0) { // Assuming plazaLaneId must be positive
        developer.log('[AddLaneDialog] Handle Save: Plaza Lane ID must be positive.', name: 'AddLaneDialog', level: 900);
        setState(() {
          _errors['plazaLaneId'] = S.of(context).validationNumberPositive("Plaza Lane ID");
          _isSaving = false;
        });
        return;
      }
    } catch (e) {
      developer.log('[AddLaneDialog] Handle Save: Failed to parse Plaza Lane ID: "$plazaLaneIdString"', name: 'AddLaneDialog', level: 900);
      setState(() {
        _errors['plazaLaneId'] = S.of(context).validationNumberInvalid("Plaza Lane ID");
        _isSaving = false;
      });
      return;
    }
    // --- END Parse plazaLaneId ---


    // --- 3. Construct Lane object for validation ---
    // Use parsed IDs. Set laneId and recordStatus to null.
    final newLaneCandidate = Lane(
      // IDs needed for validation/creation
      plazaId: parsedPlazaId, // Use parsed int
      plazaLaneId: parsedPlazaLaneId, // Use parsed int

      // Fields from the form
      laneName: _laneNameController.text.trim(),
      laneDirection: _selectedDirection ?? '', // Validate non-null if required by schema
      laneType: _selectedType ?? '', // Validate non-null if required by schema
      laneStatus: _selectedStatus ?? '', // Validate non-null if required by schema

      // Optional fields from the form
      rfidReaderId: _rfidReaderController.text.trim().isEmpty ? null : _rfidReaderController.text.trim(),
      cameraId: _cameraController.text.trim().isEmpty ? null : _cameraController.text.trim(),
      wimId: _wimController.text.trim().isEmpty ? null : _wimController.text.trim(),
      boomerBarrierId: _boomerBarrierController.text.trim().isEmpty ? null : _boomerBarrierController.text.trim(),
      ledScreenId: _ledScreenController.text.trim().isEmpty ? null : _ledScreenController.text.trim(),
      magneticLoopId: _magneticLoopController.text.trim().isEmpty ? null : _magneticLoopController.text.trim(),

      // Fields NOT part of create schema / should be null
      laneId: null,
      recordStatus: null,
    );
    developer.log('[AddLaneDialog] Handle Save: Created Lane candidate for validation: ${newLaneCandidate.toJsonForCreate()}', name: 'AddLaneDialog');

    // --- 4. Validate using model's method ---
    // final Map<String, dynamic> laneDataForValidation = newLaneCandidate.toJson(); // REMOVE
    // laneDataForValidation['plazaId'] = widget.plazaId; // REMOVE
    // final String? validationError = _validator.validateLaneDetails(context, laneDataForValidation, _errors); // REMOVE
    final String? validationError = newLaneCandidate.validateForCreate(); // USE THIS

    if (validationError != null) {
      developer.log('[AddLaneDialog] Handle Save: Model Validation Failed: "$validationError"', name: 'AddLaneDialog', level: 900);
      setState(() {
        _errors['general'] = validationError; // Assign model validation error
        _isSaving = false;
      });
      // _updateGeneralErrorIfNeeded(validationError); // REMOVE
      return;
    }
    developer.log('[AddLaneDialog] Handle Save: Model Validation Successful.', name: 'AddLaneDialog');

    // --- 5. Perform Duplicate Check (Local) ---
    // This logic remains valid
    final laneDetailsVM = widget.plazaViewModel.laneDetails;
    final List<Lane> allCurrentLanes = [...laneDetailsVM.savedLanes, ...laneDetailsVM.newlyAddedLanes];
    developer.log('[AddLaneDialog] Handle Save: Performing duplicate check against ${allCurrentLanes.length} lanes.', name: 'AddLaneDialog');
    final Map<String, String> duplicateErrors = _checkForDuplicates(newLaneCandidate, allCurrentLanes);
    if (duplicateErrors.isNotEmpty) {
      developer.log('[AddLaneDialog] Handle Save: Local Duplicate Check Failed. Duplicates: $duplicateErrors', name: 'AddLaneDialog', level: 900);
      setState(() {
        _errors.addAll(duplicateErrors);
        _errors['general'] = S.of(context).validationDuplicateGeneral;
        _isSaving = false;
      });
      return;
    }
    developer.log('[AddLaneDialog] Handle Save: Local Duplicate Check Successful.', name: 'AddLaneDialog');

    // --- 6. Call onSave Callback ---
    // Pass the fully validated newLaneCandidate
    try {
      developer.log('[AddLaneDialog] Handle Save: Calling widget.onSave callback...', name: 'AddLaneDialog');
      widget.onSave(newLaneCandidate);
      developer.log('[AddLaneDialog] Handle Save: widget.onSave callback completed successfully.', name: 'AddLaneDialog');
      if (mounted) {
        Navigator.pop(context);
      }
    } on PlazaException catch (e) {
      developer.log('[AddLaneDialog] Handle Save: Caught PlazaException from onSave callback: ${e.message}', name: 'AddLaneDialog', error: e, level: 1000);
      if (mounted) {
        setState(() {
          _errors['general'] = e.serverMessage ?? e.message;
          _isSaving = false;
        });
      }
    } catch (e, stackTrace) {
      developer.log('[AddLaneDialog] Handle Save: Caught unexpected error during onSave callback: $e', error: e, stackTrace: stackTrace, name: 'AddLaneDialog', level: 1200);
      if (mounted) {
        setState(() {
          _errors['general'] = S.of(context).errorUnexpected;
          _isSaving = false;
        });
      }
    }
  }

  // _updateGeneralErrorIfNeeded removed as it's less relevant now

  // _checkForDuplicates function remains the same
  Map<String, String> _checkForDuplicates(Lane newLane, List<Lane> existingLanes) {
    final duplicateErrors = <String, String>{};
    developer.log('[AddLaneDialog] Checking for duplicates for "${newLane.laneName}" against ${existingLanes.length} lanes.', name: '_checkForDuplicates');
    bool isDuplicateValue(String? newValue, String? existingValue) {
      if (newValue == null || newValue.trim().isEmpty) return false;
      if (existingValue == null || existingValue.trim().isEmpty) return false;
      return newValue.trim().toLowerCase() == existingValue.trim().toLowerCase();
    }
    for (var existingLane in existingLanes) {
      if (isDuplicateValue(newLane.laneName, existingLane.laneName)) duplicateErrors['LaneName'] = S.of(context).validationDuplicate('Lane name');
      if (isDuplicateValue(newLane.rfidReaderId, existingLane.rfidReaderId)) duplicateErrors['RFIDReaderID'] = S.of(context).validationDuplicate('RFID Reader ID');
      if (isDuplicateValue(newLane.cameraId, existingLane.cameraId)) duplicateErrors['CameraID'] = S.of(context).validationDuplicate('Camera ID');
      if (isDuplicateValue(newLane.wimId, existingLane.wimId)) duplicateErrors['WIMID'] = S.of(context).validationDuplicate('WIM ID');
      if (isDuplicateValue(newLane.boomerBarrierId, existingLane.boomerBarrierId)) duplicateErrors['BoomerBarrierID'] = S.of(context).validationDuplicate('Boomer Barrier ID');
      if (isDuplicateValue(newLane.ledScreenId, existingLane.ledScreenId)) duplicateErrors['LEDScreenID'] = S.of(context).validationDuplicate('LED Screen ID');
      if (isDuplicateValue(newLane.magneticLoopId, existingLane.magneticLoopId)) duplicateErrors['MagneticLoopID'] = S.of(context).validationDuplicate('Magnetic Loop ID');
    }
    if (duplicateErrors.isNotEmpty) {
      developer.log('[AddLaneDialog] Duplicate check found issues: $duplicateErrors', name: '_checkForDuplicates');
    }
    return duplicateErrors;
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final theme = Theme.of(context);
    final Color iconColor = !_isSaving ? theme.iconTheme.color ?? theme.primaryColor : theme.disabledColor;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Text(
                  strings.titleAddLane,
                  style: theme.dialogTheme.titleTextStyle ?? theme.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 16),
                      CustomFormFields.normalSizedTextFormField(
                        context: context,
                        label: '${strings.labelLaneName} *',
                        controller: _laneNameController,
                        enabled: !_isSaving,
                        errorText: _errors['LaneName'],
                        isPassword: false,
                        prefixIcon: Icon(Icons.drive_file_rename_outline, color: iconColor),
                        onChanged: (_) => setState(() => _errors.remove('LaneName')), // Clear specific error
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 16),
                      // --- ADDED Form Field ---
                      CustomFormFields.normalSizedTextFormField(
                        context: context,
                        label: '${"Plaza Lane ID"} *', // Replace with S.of(context).labelPlazaLaneId if available
                        controller: _plazaLaneIdController,
                        enabled: !_isSaving,
                        errorText: _errors['plazaLaneId'], // Use specific error key
                        isPassword: false,
                        prefixIcon: Icon(Icons.confirmation_number_outlined, color: iconColor),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Allow only numbers
                        onChanged: (_) => setState(() => _errors.remove('plazaLaneId')), // Clear specific error
                      ),
                      // --- END ADDED ---
                      const SizedBox(height: 16),
                      CustomDropDown.normalDropDown(
                        context: context,
                        label: '${strings.labelDirection} *',
                        value: _selectedDirection,
                        items: Lane.validDirections,
                        enabled: !_isSaving,
                        onChanged: (value) => setState(() { _selectedDirection = value; _errors.remove('LaneDirection'); }),
                        errorText: _errors['LaneDirection'],
                        prefixIcon: Icon(Icons.compare_arrows_outlined, color: iconColor),
                      ),
                      const SizedBox(height: 16),
                      CustomDropDown.normalDropDown(
                        context: context,
                        label: '${strings.labelType} *',
                        value: _selectedType,
                        items: Lane.validTypes,
                        enabled: !_isSaving,
                        onChanged: (value) => setState(() { _selectedType = value; _errors.remove('LaneType'); }),
                        errorText: _errors['LaneType'],
                        prefixIcon: Icon(Icons.merge_type_outlined, color: iconColor),
                      ),
                      const SizedBox(height: 16),
                      CustomDropDown.normalDropDown(
                        context: context,
                        label: '${strings.labelStatus} *',
                        value: _selectedStatus,
                        items: Lane.validStatuses,
                        enabled: !_isSaving,
                        onChanged: (value) => setState(() { _selectedStatus = value; _errors.remove('LaneStatus'); }),
                        errorText: _errors['LaneStatus'],
                        prefixIcon: Icon(Icons.toggle_on_outlined, color: iconColor),
                      ),
                      const SizedBox(height: 16),
                      // Other optional fields remain the same
                      CustomFormFields.normalSizedTextFormField(
                        context: context,
                        label: strings.labelRfidReaderId,
                        controller: _rfidReaderController,
                        enabled: !_isSaving,
                        isPassword: false,
                        errorText: _errors['RFIDReaderID'],
                        onChanged: (_) => setState(() => _errors.remove('RFIDReaderID')),
                        prefixIcon: Icon(Icons.wifi_tethering, color: iconColor),
                      ),
                      const SizedBox(height: 16),
                      CustomFormFields.normalSizedTextFormField(
                        context: context,
                        label: strings.labelCameraId,
                        controller: _cameraController,
                        enabled: !_isSaving,
                        isPassword: false,
                        errorText: _errors['CameraID'],
                        onChanged: (_) => setState(() => _errors.remove('CameraID')),
                        prefixIcon: Icon(Icons.camera_alt_outlined, color: iconColor),
                      ),
                      const SizedBox(height: 16),
                      CustomFormFields.normalSizedTextFormField(
                        context: context,
                        label: strings.labelWimId,
                        controller: _wimController,
                        enabled: !_isSaving,
                        isPassword: false,
                        errorText: _errors['WIMID'],
                        onChanged: (_) => setState(() => _errors.remove('WIMID')),
                        prefixIcon: Icon(Icons.speed_outlined, color: iconColor),
                      ),
                      const SizedBox(height: 16),
                      CustomFormFields.normalSizedTextFormField(
                        context: context,
                        label: strings.labelBoomerBarrierId,
                        controller: _boomerBarrierController,
                        enabled: !_isSaving,
                        isPassword: false,
                        errorText: _errors['BoomerBarrierID'],
                        onChanged: (_) => setState(() => _errors.remove('BoomerBarrierID')),
                        prefixIcon: Icon(Icons.traffic_outlined, color: iconColor),
                      ),
                      const SizedBox(height: 16),
                      CustomFormFields.normalSizedTextFormField(
                        context: context,
                        label: strings.labelLedScreenId,
                        controller: _ledScreenController,
                        enabled: !_isSaving,
                        isPassword: false,
                        errorText: _errors['LEDScreenID'],
                        onChanged: (_) => setState(() => _errors.remove('LEDScreenID')),
                        prefixIcon: Icon(Icons.screenshot_monitor_outlined, color: iconColor),
                      ),
                      const SizedBox(height: 16),
                      CustomFormFields.normalSizedTextFormField(
                        context: context,
                        label: strings.labelMagneticLoopId,
                        controller: _magneticLoopController,
                        enabled: !_isSaving,
                        isPassword: false,
                        errorText: _errors['MagneticLoopID'],
                        onChanged: (_) => setState(() => _errors.remove('MagneticLoopID')),
                        prefixIcon: Icon(Icons.sensors_outlined, color: iconColor),
                      ),

                      // General Error Display
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return FadeTransition(opacity: animation, child: child);
                        },
                        child: _errors['general'] != null
                            ? Padding(
                          key: const ValueKey('general_error_add'),
                          padding: const EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0),
                          child: Text(
                            _errors['general']!,
                            style: TextStyle(color: theme.colorScheme.error, fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                        )
                            : const SizedBox.shrink(key: ValueKey('no_general_error_add')),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isSaving ? null : () => Navigator.pop(context),
                      child: Text(strings.buttonCancel),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _handleSave,
                      style: ElevatedButton.styleFrom(minimumSize: const Size(80, 36)),
                      child: _isSaving
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                          : Text(strings.buttonAdd), // Correct button label
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}