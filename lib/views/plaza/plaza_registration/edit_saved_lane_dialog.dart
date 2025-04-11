import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:merchant_app/generated/l10n.dart';
import 'package:merchant_app/models/lane.dart';
import 'package:merchant_app/utils/components/dropdown.dart';
import 'package:merchant_app/utils/components/form_field.dart';
import 'package:merchant_app/viewmodels/plaza/plaza_viewmodel.dart';
import 'package:merchant_app/viewmodels/plaza/plaza_form_validation.dart';
import 'package:merchant_app/utils/exceptions.dart';

class EditSavedLaneDialog extends StatefulWidget {
  final Lane lane;
  final int index;
  final Future<void> Function(int indexInSavedList, Lane updatedLane) onSave;
  final PlazaViewModel plazaViewModel;

  const EditSavedLaneDialog({
    super.key,
    required this.lane,
    required this.index,
    required this.onSave,
    required this.plazaViewModel,
  });

  @override
  _EditSavedLaneDialogState createState() => _EditSavedLaneDialogState();
}

class _EditSavedLaneDialogState extends State<EditSavedLaneDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _laneNameController;
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
  final PlazaFormValidation _validator = PlazaFormValidation();
  bool _hasInitError = false;

  @override
  void initState() {
    super.initState();
    developer.log('[EditSavedLaneDialog] initState for editing SAVED lane ID: ${widget.lane.laneId}, Name: ${widget.lane.laneName}', name: 'EditSavedLaneDialog');

    bool isValidId = widget.lane.laneId != null && widget.lane.laneId! > 0; // Direct check for non-null positive int

    if (!isValidId) {
      developer.log('CRITICAL ERROR: EditSavedLaneDialog initialized without a valid laneId! Passed laneId: ${widget.lane.laneId}', name: 'EditSavedLaneDialog', level: 1200);
      _hasInitError = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _errors['general'] = S.of(context).errorInvalidLaneId;
            _isSaving = true;
          });
        }
      });
    }

    _laneNameController = TextEditingController(text: widget.lane.laneName);
    _rfidReaderController = TextEditingController(text: widget.lane.rfidReaderId ?? '');
    _cameraController = TextEditingController(text: widget.lane.cameraId ?? '');
    _wimController = TextEditingController(text: widget.lane.wimId ?? '');
    _boomerBarrierController = TextEditingController(text: widget.lane.boomerBarrierId ?? '');
    _ledScreenController = TextEditingController(text: widget.lane.ledScreenId ?? '');
    _magneticLoopController = TextEditingController(text: widget.lane.magneticLoopId ?? '');
    _selectedDirection = widget.lane.laneDirection;
    _selectedType = widget.lane.laneType;
    _selectedStatus = widget.lane.laneStatus;

    if (_selectedStatus == null || !Lane.validStatuses.map((s) => s.toLowerCase()).contains(_selectedStatus?.toLowerCase())) {
      _selectedStatus = Lane.validStatuses.firstWhere(
            (s) => s.toLowerCase() == 'active',
        orElse: () => Lane.validStatuses.first,
      );
      developer.log('[EditSavedLaneDialog] Corrected _selectedStatus in initState to: $_selectedStatus', name: 'EditSavedLaneDialog');
    }
  }

  @override
  void dispose() {
    developer.log('[EditSavedLaneDialog] dispose', name: 'EditSavedLaneDialog');
    _laneNameController.dispose();
    _rfidReaderController.dispose();
    _cameraController.dispose();
    _wimController.dispose();
    _boomerBarrierController.dispose();
    _ledScreenController.dispose();
    _magneticLoopController.dispose();
    super.dispose();
  }

  void _handleSave() async {
    if (_isSaving || _hasInitError) {
      developer.log('[EditSavedLaneDialog] Save attempt ignored: isSaving=$_isSaving, hasInitError=$_hasInitError', name: 'EditSavedLaneDialog');
      return;
    }
    setState(() { _isSaving = true; _errors.clear(); });
    developer.log('[EditSavedLaneDialog] Handle Save: Starting process...', name: 'EditSavedLaneDialog');

    final updatedLaneCandidate = Lane(
      // Fields that MUST be carried over from the original saved lane
      laneId: widget.lane.laneId, // CRUCIAL: Must exist for saved lane
      plazaId: widget.lane.plazaId, // CRUCIAL: Assume this exists on widget.lane
      plazaLaneId: widget.lane.plazaLaneId, // CRUCIAL: Assume this exists
      recordStatus: widget.lane.recordStatus, // CRUCIAL: Must exist for update

      // Fields updated from the form
      laneName: _laneNameController.text.trim(),
      laneDirection: _selectedDirection ?? widget.lane.laneDirection, // Use original if null? Or validate non-null? Schema requires it.
      laneType: _selectedType ?? widget.lane.laneType, // Schema requires it.
      laneStatus: _selectedStatus ?? widget.lane.laneStatus, // Schema requires it.

      // Optional fields from the form (handle empty strings as null)
      rfidReaderId: _rfidReaderController.text.trim().isEmpty ? null : _rfidReaderController.text.trim(),
      cameraId: _cameraController.text.trim().isEmpty ? null : _cameraController.text.trim(),
      wimId: _wimController.text.trim().isEmpty ? null : _wimController.text.trim(),
      boomerBarrierId: _boomerBarrierController.text.trim().isEmpty ? null : _boomerBarrierController.text.trim(),
      ledScreenId: _ledScreenController.text.trim().isEmpty ? null : _ledScreenController.text.trim(),
      magneticLoopId: _magneticLoopController.text.trim().isEmpty ? null : _magneticLoopController.text.trim(),
    );
    developer.log('[EditSavedLaneDialog] Handle Save: Created updated Lane candidate via instantiation: ${updatedLaneCandidate.toJsonForUpdate()}', name: 'EditSavedLaneDialog');

    final String? validationError = updatedLaneCandidate.validateForUpdate(); // Use the model's method

    if (validationError != null) {
      developer.log('[EditSavedLaneDialog] Handle Save: Model Validation Failed: "$validationError"', name: 'EditSavedLaneDialog', level: 900);
      // Adapt error display. Since validateForUpdate returns a single string,
      // usually set it to the 'general' error key. You might need more
      // sophisticated parsing if the error string contains field info.
      setState(() {
        _errors['general'] = validationError; // Assign the validation message
        _isSaving = false;
      });
      return;
    }
    developer.log('[EditSavedLaneDialog] Handle Save: Model Validation Successful.', name: 'EditSavedLaneDialog');

    final laneDetailsVM = widget.plazaViewModel.laneDetails;
    final List<Lane> otherLanesToCheck = [
      ...laneDetailsVM.savedLanes.where((l) => l.laneId != widget.lane.laneId),
      ...laneDetailsVM.newlyAddedLanes,
    ];
    developer.log('[EditSavedLaneDialog] Handle Save: Performing duplicate check against ${otherLanesToCheck.length} other lanes.', name: 'EditSavedLaneDialog');
    final Map<String, String> duplicateErrors = _checkForDuplicates(updatedLaneCandidate, otherLanesToCheck);
    if (duplicateErrors.isNotEmpty) {
      developer.log('[EditSavedLaneDialog] Handle Save: Local Duplicate Check Failed. Duplicates: $duplicateErrors', name: 'EditSavedLaneDialog', level: 900);
      setState(() {
        _errors.addAll(duplicateErrors);
        _errors['general'] = S.of(context).validationDuplicateGeneral;
        _isSaving = false;
      });
      return;
    }
    developer.log('[EditSavedLaneDialog] Handle Save: Local Duplicate Check Successful.', name: 'EditSavedLaneDialog');

    try {
      developer.log('[EditSavedLaneDialog] Handle Save: Calling and awaiting widget.onSave callback (triggers VM updateSavedLane)...', name: 'EditSavedLaneDialog');
      await widget.onSave(widget.index, updatedLaneCandidate);
      developer.log('[EditSavedLaneDialog] Handle Save: await widget.onSave completed successfully.', name: 'EditSavedLaneDialog');
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      developer.log('[EditSavedLaneDialog] Handle Save: Caught error during awaited onSave callback: $e', name: 'EditSavedLaneDialog', error: e, level: 1000);
      if (mounted) {
        final vmError = widget.plazaViewModel.laneDetails.errors['update_validation'] ??
            widget.plazaViewModel.laneDetails.errors['update_duplicate'] ??
            widget.plazaViewModel.laneDetails.errors['general'] ??
            (e is PlazaException ? (e.serverMessage ?? e.message) : null) ??
            S.of(context).errorUpdatingLane;
        setState(() {
          _errors['general'] = vmError;
          _isSaving = false;
        });
      }
    }
  }

  void _updateGeneralErrorIfNeeded(String? mainValidationError) {
    bool hasSpecificErrors = _errors.entries.any((e) => e.key != 'general' && e.value != null);
    if (hasSpecificErrors && !_errors.containsKey('general')) {
      _errors['general'] = S.of(context).validationGeneralLaneError;
      developer.log('[EditSavedLaneDialog] Added general validation error hint.', name: 'EditSavedLaneDialog');
    } else if (!hasSpecificErrors && mainValidationError != null && mainValidationError.isNotEmpty) {
      _errors['general'] = mainValidationError;
      developer.log('[EditSavedLaneDialog] Set general error from validator summary: $mainValidationError', name: 'EditSavedLaneDialog');
    }
  }

  Map<String, String> _checkForDuplicates(Lane laneToCheck, List<Lane> existingLanes) {
    final duplicateErrors = <String, String>{};
    developer.log('[EditSavedLaneDialog] Checking duplicates for lane "${laneToCheck.laneName}" (ID: ${laneToCheck.laneId}) against ${existingLanes.length} other lanes.', name: '_checkForDuplicates');
    bool isDuplicateValue(String? newValue, String? existingValue) {
      if (newValue == null || newValue.trim().isEmpty) return false;
      if (existingValue == null || existingValue.trim().isEmpty) return false;
      return newValue.trim().toLowerCase() == existingValue.trim().toLowerCase();
    }
    for (var existingLane in existingLanes) {
      if (laneToCheck.laneId != null && laneToCheck.laneId == existingLane.laneId) {
        continue;
      }
      if (isDuplicateValue(laneToCheck.laneName, existingLane.laneName)) duplicateErrors['LaneName'] = S.of(context).validationDuplicate('Lane name');
      if (isDuplicateValue(laneToCheck.rfidReaderId, existingLane.rfidReaderId)) duplicateErrors['RFIDReaderID'] = S.of(context).validationDuplicate('RFID Reader ID');
      if (isDuplicateValue(laneToCheck.cameraId, existingLane.cameraId)) duplicateErrors['CameraID'] = S.of(context).validationDuplicate('Camera ID');
      if (isDuplicateValue(laneToCheck.wimId, existingLane.wimId)) duplicateErrors['WIMID'] = S.of(context).validationDuplicate('WIM ID');
      if (isDuplicateValue(laneToCheck.boomerBarrierId, existingLane.boomerBarrierId)) duplicateErrors['BoomerBarrierID'] = S.of(context).validationDuplicate('Boomer Barrier ID');
      if (isDuplicateValue(laneToCheck.ledScreenId, existingLane.ledScreenId)) duplicateErrors['LEDScreenID'] = S.of(context).validationDuplicate('LED Screen ID');
      if (isDuplicateValue(laneToCheck.magneticLoopId, existingLane.magneticLoopId)) duplicateErrors['MagneticLoopID'] = S.of(context).validationDuplicate('Magnetic Loop ID');
    }
    if (duplicateErrors.isNotEmpty) {
      developer.log('[EditSavedLaneDialog] Duplicate check found issues: $duplicateErrors', name: '_checkForDuplicates');
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
                  strings.titleEditSavedLane,
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
                        onChanged: (_) { if (_errors.containsKey('LaneName')) setState(() => _errors.remove('LaneName')); },
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 16),
                      CustomDropDown.normalDropDown(
                        context: context,
                        label: '${strings.labelDirection} *',
                        value: _selectedDirection,
                        items: Lane.validDirections,
                        enabled: !_isSaving,
                        onChanged: (value) => setState(() { _selectedDirection = value; if (_errors.containsKey('LaneDirection')) _errors.remove('LaneDirection'); }),
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
                        onChanged: (value) => setState(() { _selectedType = value; if (_errors.containsKey('LaneType')) _errors.remove('LaneType'); }),
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
                        onChanged: (value) => setState(() { _selectedStatus = value; if (_errors.containsKey('LaneStatus')) _errors.remove('LaneStatus'); }),
                        errorText: _errors['LaneStatus'],
                        prefixIcon: Icon(Icons.toggle_on_outlined, color: iconColor),
                      ),
                      const SizedBox(height: 16),
                      CustomFormFields.normalSizedTextFormField(
                        context: context,
                        label: strings.labelRfidReaderId,
                        controller: _rfidReaderController,
                        enabled: !_isSaving,
                        isPassword: false,
                        errorText: _errors['RFIDReaderID'],
                        onChanged: (_) { if (_errors.containsKey('RFIDReaderID')) setState(() => _errors.remove('RFIDReaderID')); },
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
                        onChanged: (_) { if (_errors.containsKey('CameraID')) setState(() => _errors.remove('CameraID')); },
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
                        onChanged: (_) { if (_errors.containsKey('WIMID')) setState(() => _errors.remove('WIMID')); },
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
                        onChanged: (_) { if (_errors.containsKey('BoomerBarrierID')) setState(() => _errors.remove('BoomerBarrierID')); },
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
                        onChanged: (_) { if (_errors.containsKey('LEDScreenID')) setState(() => _errors.remove('LEDScreenID')); },
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
                        onChanged: (_) { if (_errors.containsKey('MagneticLoopID')) setState(() => _errors.remove('MagneticLoopID')); },
                        prefixIcon: Icon(Icons.sensors_outlined, color: iconColor),
                      ),
                      if (_errors['general'] != null) ...[
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            _errors['general']!,
                            style: TextStyle(color: theme.colorScheme.error, fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
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
                      onPressed: (_isSaving || _hasInitError) ? null : () => Navigator.pop(context),
                      child: Text(strings.buttonCancel),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: (_isSaving || _hasInitError) ? null : _handleSave,
                      style: ElevatedButton.styleFrom(minimumSize: const Size(80, 36)),
                      child: _isSaving
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(strings.buttonUpdate),
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