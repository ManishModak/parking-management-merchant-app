import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for input formatters
import 'package:merchant_app/generated/l10n.dart';
import 'package:merchant_app/models/lane.dart';
import 'package:merchant_app/utils/components/dropdown.dart';
import 'package:merchant_app/utils/components/form_field.dart';
import 'package:merchant_app/viewmodels/plaza/plaza_viewmodel.dart';
// import 'package:merchant_app/viewmodels/plaza/plaza_form_validation.dart'; // Can likely be removed
import 'package:merchant_app/utils/exceptions.dart';

class EditNewLaneDialog extends StatefulWidget {
  final Lane lane; // The initial lane data (likely with some defaults)
  final int index; // Index in the newlyAddedLanes list
  final Function(int indexInList, Lane updatedLane) onSave; // Callback
  final PlazaViewModel plazaViewModel; // Access to plazaId, etc.

  const EditNewLaneDialog({
    super.key,
    required this.lane,
    required this.index,
    required this.onSave,
    required this.plazaViewModel,
  });

  @override
  _EditNewLaneDialogState createState() => _EditNewLaneDialogState();
}

class _EditNewLaneDialogState extends State<EditNewLaneDialog> {
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
  // final PlazaFormValidation _validator = PlazaFormValidation(); // REMOVE this line

  @override
  void initState() {
    super.initState();
    developer.log('[EditNewLaneDialog] initState for editing NEW lane at index ${widget.index}: ${widget.lane.laneName}', name: 'EditNewLaneDialog');
    _laneNameController = TextEditingController(text: widget.lane.laneName);
    // --- ADDED Initialization ---
    // Initialize with existing value if available, otherwise empty.
    _plazaLaneIdController = TextEditingController(text: widget.lane.plazaLaneId != null ? widget.lane.plazaLaneId.toString() : '');
    // --- END ADDED ---
    _rfidReaderController = TextEditingController(text: widget.lane.rfidReaderId ?? '');
    _cameraController = TextEditingController(text: widget.lane.cameraId ?? '');
    _wimController = TextEditingController(text: widget.lane.wimId ?? '');
    _boomerBarrierController = TextEditingController(text: widget.lane.boomerBarrierId ?? '');
    _ledScreenController = TextEditingController(text: widget.lane.ledScreenId ?? '');
    _magneticLoopController = TextEditingController(text: widget.lane.magneticLoopId ?? '');
    _selectedDirection = widget.lane.laneDirection;
    _selectedType = widget.lane.laneType;
    _selectedStatus = widget.lane.laneStatus;

    // Default status if needed
    if (_selectedStatus == null || !Lane.validStatuses.map((s) => s.toLowerCase()).contains(_selectedStatus?.toLowerCase())) {
      _selectedStatus = Lane.validStatuses.firstWhere(
            (s) => s.toLowerCase() == 'active',
        orElse: () => Lane.validStatuses.first,
      );
      developer.log('[EditNewLaneDialog] Corrected _selectedStatus in initState to: $_selectedStatus', name: 'EditNewLaneDialog');
    }

    // Check if essential plazaId is available
    if (widget.plazaViewModel.plazaId == null) {
      developer.log('[EditNewLaneDialog] CRITICAL: Missing plazaId from ViewModel in initState.', name: 'EditNewLaneDialog', level: 1200);
    }
  }

  @override
  void dispose() {
    developer.log('[EditNewLaneDialog] dispose', name: 'EditNewLaneDialog');
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
      developer.log('[EditNewLaneDialog] Save attempt ignored: Already saving.', name: 'EditNewLaneDialog');
      return;
    }
    setState(() { _isSaving = true; _errors.clear(); });
    developer.log('[EditNewLaneDialog] Handle Save: Starting process...', name: 'EditNewLaneDialog');

    // --- 1. Get and PARSE required plazaId from ViewModel ---
    final String? plazaIdString = widget.plazaViewModel.plazaId;
    int? parsedPlazaId; // Change variable name slightly for clarity

    if (plazaIdString == null || plazaIdString.isEmpty) {
      developer.log('[EditNewLaneDialog] Handle Save: CRITICAL - Plaza ID is missing from ViewModel.', name: 'EditNewLaneDialog', level: 1000);
      setState(() {
        _errors['general'] = S.of(context).errorMissingPlazaData;
        _isSaving = false;
      });
      return;
    }

    try {
      parsedPlazaId = int.parse(plazaIdString);
      // Add check based on create schema (min: 0)
      if (parsedPlazaId < 0) {
        throw FormatException("Plaza ID cannot be negative. Value: $parsedPlazaId");
      }
    } catch (e) {
      developer.log('[EditNewLaneDialog] Handle Save: Invalid Plaza ID format in ViewModel: "$plazaIdString". Error: $e', name: 'EditNewLaneDialog', level: 1000);
      setState(() {
        _errors['general'] = S.of(context).errorInvalidPlazaId; // Use a specific error string
        _isSaving = false;
      });
      return;
    }
    // --- END Parse plazaId ---

    // --- 2. Parse plazaLaneId from form ---
    int? parsedPlazaLaneId;
    final plazaLaneIdString = _plazaLaneIdController.text.trim();
    if (plazaLaneIdString.isEmpty) {
      developer.log('[EditNewLaneDialog] Handle Save: Plaza Lane ID field is empty.', name: 'EditNewLaneDialog', level: 900);
      setState(() {
        _errors['plazaLaneId'] = S.of(context).validationFieldRequired("Plaza Lane ID"); // Assuming you have such a string
        _isSaving = false;
      });
      return;
    }
    try {
      parsedPlazaLaneId = int.parse(plazaLaneIdString);
      if (parsedPlazaLaneId <= 0) {
        // Add specific check for positive number if required by schema/logic
        developer.log('[EditNewLaneDialog] Handle Save: Plaza Lane ID must be positive.', name: 'EditNewLaneDialog', level: 900);
        setState(() {
          _errors['plazaLaneId'] = S.of(context).validationNumberPositive("Plaza Lane ID"); // Assuming you have such a string
          _isSaving = false;
        });
        return;
      }
    } catch (e) {
      developer.log('[EditNewLaneDialog] Handle Save: Failed to parse Plaza Lane ID: "$plazaLaneIdString"', name: 'EditNewLaneDialog', level: 900);
      setState(() {
        _errors['plazaLaneId'] = S.of(context).validationNumberInvalid("Plaza Lane ID"); // Assuming you have such a string
        _isSaving = false;
      });
      return;
    }
    // --- END Parse plazaLaneId ---


    final updatedLaneCandidate = Lane(
      plazaId: parsedPlazaId, // Use the parsed int value
      plazaLaneId: parsedPlazaLaneId,

      // ... rest of the fields ...
      laneName: _laneNameController.text.trim(),
      laneDirection: _selectedDirection ?? '',
      laneType: _selectedType ?? '',
      laneStatus: _selectedStatus ?? '',
      rfidReaderId: _rfidReaderController.text.trim().isEmpty ? null : _rfidReaderController.text.trim(),
      cameraId: _cameraController.text.trim().isEmpty ? null : _cameraController.text.trim(),
      wimId: _wimController.text.trim().isEmpty ? null : _wimController.text.trim(),
      boomerBarrierId: _boomerBarrierController.text.trim().isEmpty ? null : _boomerBarrierController.text.trim(),
      ledScreenId: _ledScreenController.text.trim().isEmpty ? null : _ledScreenController.text.trim(),
      magneticLoopId: _magneticLoopController.text.trim().isEmpty ? null : _magneticLoopController.text.trim(),
      laneId: null,
      recordStatus: null,
    );
    developer.log('[EditNewLaneDialog] Handle Save: Created updated Lane candidate for validation: ${updatedLaneCandidate.toJsonForCreate()}', name: 'EditNewLaneDialog');

    // --- 4. Validate using model's method ---
    final String? validationError = updatedLaneCandidate.validateForCreate(); // USE THIS

    if (validationError != null) {
      developer.log('[EditNewLaneDialog] Handle Save: Model Validation Failed: "$validationError"', name: 'EditNewLaneDialog', level: 900);
      // Set the general error from the model's validation message
      setState(() {
        _errors['general'] = validationError;
        _isSaving = false;
      });
      return;
    }
    developer.log('[EditNewLaneDialog] Handle Save: Model Validation Successful.', name: 'EditNewLaneDialog');

    // --- 5. Perform Duplicate Check (Local) ---
    final laneDetailsVM = widget.plazaViewModel.laneDetails;
    final List<Lane> otherLanesToCheck = [
      ...laneDetailsVM.savedLanes,
      ...laneDetailsVM.newlyAddedLanes.where((l) => l != widget.lane && l.hashCode != widget.lane.hashCode),
    ];
    developer.log('[EditNewLaneDialog] Handle Save: Performing duplicate check against ${otherLanesToCheck.length} other lanes.', name: 'EditNewLaneDialog');
    final Map<String, String> duplicateErrors = _checkForDuplicates(updatedLaneCandidate, otherLanesToCheck);
    if (duplicateErrors.isNotEmpty) {
      developer.log('[EditNewLaneDialog] Handle Save: Local Duplicate Check Failed. Duplicates: $duplicateErrors', name: 'EditNewLaneDialog', level: 900);
      setState(() {
        _errors.addAll(duplicateErrors);
        _errors['general'] = S.of(context).validationDuplicateGeneral;
        _isSaving = false;
      });
      return;
    }
    developer.log('[EditNewLaneDialog] Handle Save: Local Duplicate Check Successful.', name: 'EditNewLaneDialog');

    // --- 6. Call onSave Callback ---
    try {
      developer.log('[EditNewLaneDialog] Handle Save: Calling widget.onSave callback...', name: 'EditNewLaneDialog');
      widget.onSave(widget.index, updatedLaneCandidate);
      developer.log('[EditNewLaneDialog] Handle Save: widget.onSave callback completed successfully.', name: 'EditNewLaneDialog');
      if (mounted) {
        Navigator.pop(context);
      }
    } on PlazaException catch (e) {
      developer.log('[EditNewLaneDialog] Handle Save: Caught PlazaException from onSave callback: ${e.message}', name: 'EditNewLaneDialog', error: e, level: 1000);
      if (mounted) {
        setState(() {
          _errors['general'] = e.serverMessage ?? e.message;
          _isSaving = false;
        });
      }
    } catch (e, stackTrace) {
      developer.log('[EditNewLaneDialog] Handle Save: Caught unexpected error during onSave callback: $e', error: e, stackTrace: stackTrace, name: 'EditNewLaneDialog', level: 1200);
      if (mounted) {
        setState(() {
          _errors['general'] = S.of(context).errorUnexpected;
          _isSaving = false;
        });
      }
    }
    // Removed finally block that reset _isSaving, better to reset only on failure path
  }


  // Duplicate check function remains the same
  Map<String, String> _checkForDuplicates(Lane laneToCheck, List<Lane> againstLanes) {
    final duplicateErrors = <String, String>{};
    developer.log('[EditNewLaneDialog] Checking duplicates for lane "${laneToCheck.laneName}" against ${againstLanes.length} other lanes.', name: '_checkForDuplicates');
    bool isDuplicateValue(String? newValue, String? existingValue) {
      if (newValue == null || newValue.trim().isEmpty) return false;
      if (existingValue == null || existingValue.trim().isEmpty) return false;
      return newValue.trim().toLowerCase() == existingValue.trim().toLowerCase();
    }
    for (var existingLane in againstLanes) {
      if (isDuplicateValue(laneToCheck.laneName, existingLane.laneName)) duplicateErrors['LaneName'] = S.of(context).validationDuplicate('Lane name');
      if (isDuplicateValue(laneToCheck.rfidReaderId, existingLane.rfidReaderId)) duplicateErrors['RFIDReaderID'] = S.of(context).validationDuplicate('RFID Reader ID');
      if (isDuplicateValue(laneToCheck.cameraId, existingLane.cameraId)) duplicateErrors['CameraID'] = S.of(context).validationDuplicate('Camera ID');
      if (isDuplicateValue(laneToCheck.wimId, existingLane.wimId)) duplicateErrors['WIMID'] = S.of(context).validationDuplicate('WIM ID');
      if (isDuplicateValue(laneToCheck.boomerBarrierId, existingLane.boomerBarrierId)) duplicateErrors['BoomerBarrierID'] = S.of(context).validationDuplicate('Boomer Barrier ID');
      if (isDuplicateValue(laneToCheck.ledScreenId, existingLane.ledScreenId)) duplicateErrors['LEDScreenID'] = S.of(context).validationDuplicate('LED Screen ID');
      if (isDuplicateValue(laneToCheck.magneticLoopId, existingLane.magneticLoopId)) duplicateErrors['MagneticLoopID'] = S.of(context).validationDuplicate('Magnetic Loop ID');
    }
    if (duplicateErrors.isNotEmpty) {
      developer.log('[EditNewLaneDialog] Duplicate check found issues: $duplicateErrors', name: '_checkForDuplicates');
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
                  strings.titleEditNewLane,
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
                        errorText: _errors['LaneName'], // Keep specific error key
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
                        onChanged: (value) => setState(() { _selectedDirection = value; _errors.remove('LaneDirection'); }), // Clear specific error
                        errorText: _errors['LaneDirection'], // Keep specific error key
                        prefixIcon: Icon(Icons.compare_arrows_outlined, color: iconColor),
                      ),
                      const SizedBox(height: 16),
                      CustomDropDown.normalDropDown(
                        context: context,
                        label: '${strings.labelType} *',
                        value: _selectedType,
                        items: Lane.validTypes,
                        enabled: !_isSaving,
                        onChanged: (value) => setState(() { _selectedType = value; _errors.remove('LaneType'); }), // Clear specific error
                        errorText: _errors['LaneType'], // Keep specific error key
                        prefixIcon: Icon(Icons.merge_type_outlined, color: iconColor),
                      ),
                      const SizedBox(height: 16),
                      CustomDropDown.normalDropDown(
                        context: context,
                        label: '${strings.labelStatus} *',
                        value: _selectedStatus,
                        items: Lane.validStatuses,
                        enabled: !_isSaving,
                        onChanged: (value) => setState(() { _selectedStatus = value; _errors.remove('LaneStatus'); }), // Clear specific error
                        errorText: _errors['LaneStatus'], // Keep specific error key
                        prefixIcon: Icon(Icons.toggle_on_outlined, color: iconColor),
                      ),
                      const SizedBox(height: 16),
                      CustomFormFields.normalSizedTextFormField(
                        context: context,
                        label: strings.labelRfidReaderId,
                        controller: _rfidReaderController,
                        enabled: !_isSaving,
                        isPassword: false,
                        errorText: _errors['RFIDReaderID'], // Keep specific error key
                        onChanged: (_) => setState(() => _errors.remove('RFIDReaderID')), // Clear specific error
                        prefixIcon: Icon(Icons.wifi_tethering, color: iconColor),
                      ),
                      const SizedBox(height: 16),
                      CustomFormFields.normalSizedTextFormField(
                        context: context,
                        label: strings.labelCameraId,
                        controller: _cameraController,
                        enabled: !_isSaving,
                        isPassword: false,
                        errorText: _errors['CameraID'], // Keep specific error key
                        onChanged: (_) => setState(() => _errors.remove('CameraID')), // Clear specific error
                        prefixIcon: Icon(Icons.camera_alt_outlined, color: iconColor),
                      ),
                      const SizedBox(height: 16),
                      CustomFormFields.normalSizedTextFormField(
                        context: context,
                        label: strings.labelWimId,
                        controller: _wimController,
                        enabled: !_isSaving,
                        isPassword: false,
                        errorText: _errors['WIMID'], // Keep specific error key
                        onChanged: (_) => setState(() => _errors.remove('WIMID')), // Clear specific error
                        prefixIcon: Icon(Icons.speed_outlined, color: iconColor),
                      ),
                      const SizedBox(height: 16),
                      CustomFormFields.normalSizedTextFormField(
                        context: context,
                        label: strings.labelBoomerBarrierId,
                        controller: _boomerBarrierController,
                        enabled: !_isSaving,
                        isPassword: false,
                        errorText: _errors['BoomerBarrierID'], // Keep specific error key
                        onChanged: (_) => setState(() => _errors.remove('BoomerBarrierID')), // Clear specific error
                        prefixIcon: Icon(Icons.traffic_outlined, color: iconColor),
                      ),
                      const SizedBox(height: 16),
                      CustomFormFields.normalSizedTextFormField(
                        context: context,
                        label: strings.labelLedScreenId,
                        controller: _ledScreenController,
                        enabled: !_isSaving,
                        isPassword: false,
                        errorText: _errors['LEDScreenID'], // Keep specific error key
                        onChanged: (_) => setState(() => _errors.remove('LEDScreenID')), // Clear specific error
                        prefixIcon: Icon(Icons.screenshot_monitor_outlined, color: iconColor),
                      ),
                      const SizedBox(height: 16),
                      CustomFormFields.normalSizedTextFormField(
                        context: context,
                        label: strings.labelMagneticLoopId,
                        controller: _magneticLoopController,
                        enabled: !_isSaving,
                        isPassword: false,
                        errorText: _errors['MagneticLoopID'], // Keep specific error key
                        onChanged: (_) => setState(() => _errors.remove('MagneticLoopID')), // Clear specific error
                        prefixIcon: Icon(Icons.sensors_outlined, color: iconColor),
                      ),

                      // Display General Error (if any)
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return FadeTransition(opacity: animation, child: child);
                        },
                        child: _errors['general'] != null
                            ? Padding(
                          key: const ValueKey('general_error'),
                          padding: const EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0),
                          child: Text(
                            _errors['general']!,
                            style: TextStyle(color: theme.colorScheme.error, fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                        )
                            : const SizedBox.shrink(key: ValueKey('no_general_error')),
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
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(strings.buttonSave), // Changed button text to Save
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