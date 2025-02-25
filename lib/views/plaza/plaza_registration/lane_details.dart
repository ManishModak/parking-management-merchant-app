import 'package:flutter/material.dart';
import 'package:merchant_app/utils/components/dropdown.dart';
import 'package:merchant_app/utils/components/form_field.dart';
import 'package:provider/provider.dart';
import '../../../config/app_config.dart';
import '../../../models/lane.dart';
import '../../../viewmodels/plaza/plaza_viewmodel.dart';

class LaneDetailsStep extends StatefulWidget {
  const LaneDetailsStep({super.key});

  @override
  State<LaneDetailsStep> createState() => _LaneDetailsStepState();
}

class _LaneDetailsStepState extends State<LaneDetailsStep> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<PlazaViewModel>();
      if (viewModel.plazaId != null) {
        viewModel.fetchExistingLanes(viewModel.plazaId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PlazaViewModel>();
    final isEditable =
        viewModel.isLaneDetailsFirstTime || viewModel.isLaneEditable;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Add Lane Button
              Center(
                child: ElevatedButton.icon(
                  onPressed: isEditable
                      ? () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return _AddLaneDialog(
                                onSave: (lane) => viewModel.addNewLane(lane),
                                plazaId: viewModel.plazaId!,
                              );
                            },
                          );
                        }
                      : null,
                  icon: const Icon(Icons.add_road),
                  label: const Text('Add Lane'),
                ),
              ),
              const SizedBox(height: 16),

              // Display Lane Errors if any
              if (viewModel.formState.errors['lanes'] != null)
                Container(
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.only(bottom: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          viewModel.formState.errors['lanes']!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    ],
                  ),
                ),

              // Edit Mode Indicator
              if (isEditable)
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.blue.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Edit mode active - Tap on any lane to modify its details',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // New Lanes Section
              _buildLaneList(
                context,
                title: "New Lanes",
                lanes: viewModel.temporaryLanes,
                editable: isEditable,
                onEdit: (updatedLane) {
                  final index = viewModel.temporaryLanes
                      .indexWhere((lane) => lane.laneId == updatedLane.laneId);
                  if (index != -1) {
                    viewModel.modifyTemporaryLane(index, updatedLane);
                  }
                },
              ),

              const SizedBox(height: 32),
              const Divider(thickness: 2),
              const SizedBox(height: 16),

              // Existing Lanes Section
              _buildLaneList(
                context,
                title: "Existing Lanes",
                lanes: viewModel.existingLanes,
                editable: isEditable,
                onEdit: (updatedLane) async {
                  await viewModel.updateExistingLane(updatedLane);
                  await viewModel.fetchExistingLanes(viewModel.plazaId!);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLaneList(
      BuildContext context, {
        required String title,
        required List<Lane> lanes,
        required bool editable,
        required Function(Lane) onEdit,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 8),
        if (lanes.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: Text(
                "No lanes available.",
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
        if (lanes.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: lanes.length,
            itemBuilder: (context, index) {
              final lane = lanes[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Stack(
                  children: [
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: InkWell(
                        onTap: editable
                            ? () {
                          showDialog(
                            context: context,
                            builder: (context) => _EditLaneDialog(
                              lane: lane,
                              onSave: onEdit,
                            ),
                          );
                        }
                            : null,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Lane Name and Status
                              Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      lane.laneName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        height: 1.2,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _buildStatusBadge(lane.laneStatus),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Direction and Type
                              Row(
                                children: [
                                  _buildInfoChip(Icons.directions, lane.laneDirection),
                                  const SizedBox(width: 16),
                                  _buildInfoChip(Icons.category, lane.laneType),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Device IDs
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Left column
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildDeviceInfo('RFID', lane.rfidReaderId),
                                        const SizedBox(height: 4),
                                        _buildDeviceInfo('Camera', lane.cameraId),
                                        const SizedBox(height: 4),
                                        _buildDeviceInfo('WIM', lane.wimId),
                                      ],
                                    ),
                                  ),
                                  // Right column
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildDeviceInfo('Barrier', lane.boomerBarrierId),
                                        const SizedBox(height: 4),
                                        _buildDeviceInfo('LED', lane.ledScreenId),
                                        const SizedBox(height: 4),
                                        _buildDeviceInfo('Loop', lane.magneticLoopId),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (editable)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade500,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: status == 'active' ? Colors.green.shade100 : Colors.red.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: status == 'active' ? Colors.green.shade800 : Colors.red.shade800,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(
          text.isNotEmpty ? text : 'N/A',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceInfo(String label, String? value) {
    final displayValue = value?.isNotEmpty == true ? value : 'N/A';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        Expanded(
          child: Text(
            displayValue!,
            style: TextStyle(
              fontSize: 12,
              color: displayValue == 'N/A' ? Colors.grey.shade400 : Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// Update AddLaneDialog
class _AddLaneDialog extends StatefulWidget {
  final Function(Lane) onSave;
  final String plazaId;

  const _AddLaneDialog({required this.onSave, required this.plazaId});

  @override
  State<_AddLaneDialog> createState() => _AddLaneDialogState();
}

class _AddLaneDialogState extends State<_AddLaneDialog> {
  final laneNameController = TextEditingController();
  final rfidReaderController = TextEditingController();
  final cameraController = TextEditingController();
  final wimController = TextEditingController();
  final boomerBarrierController = TextEditingController();
  final ledScreenController = TextEditingController();
  final magneticLoopController = TextEditingController();
  String? selectedDirection;
  String? selectedType;
  String? selectedStatus;
  late PlazaViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = context.read<PlazaViewModel>();
  }

  @override
  void dispose() {
    if (mounted) {
      viewModel.formState.errors.clear();
      viewModel.laneDetails.clear();
    }
    laneNameController.dispose();
    super.dispose();
  }

  void _handleSave() {
    viewModel.laneDetails.addAll({
      'laneName': laneNameController.text.trim(),
      'laneDirection': selectedDirection,
      'laneType': selectedType,
      'laneStatus': selectedStatus,
      'plazaId': widget.plazaId.toString(),
      'RFIDReaderID': rfidReaderController.text.trim(),
      'CameraID': cameraController.text.trim(),
      'WIMID': wimController.text.trim(),
      'BoomerBarrierID': boomerBarrierController.text.trim(),
      'LEDScreenID': ledScreenController.text.trim(),
      'MagneticLoopID': magneticLoopController.text.trim(),
    });

    if (viewModel.validateLaneDetailsStep() != null) {
      setState(() {}); // Refresh UI to show validation errors
      return;
    }

    try {
      final lane = Lane(
        plazaId: int.parse(widget.plazaId),
        laneName: laneNameController.text.trim(),
        laneDirection: selectedDirection!,
        laneType: selectedType!,
        laneStatus: selectedStatus!,
        rfidReaderId: rfidReaderController.text.trim(),
        cameraId: cameraController.text.trim(),
        wimId: wimController.text.trim(),
        boomerBarrierId: boomerBarrierController.text.trim(),
        ledScreenId: ledScreenController.text.trim(),
        magneticLoopId: magneticLoopController.text.trim(),
      );

      widget.onSave(lane);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error saving lane. Please check all fields."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (_) {
        if (mounted) {
          viewModel.formState.errors.clear();
          viewModel.laneDetails.clear();
        }
      },
      child: AlertDialog(
        insetPadding: EdgeInsets.all(16),
        title: const Text("Add Lane"),
        content: SizedBox(
          width: AppConfig.deviceWidth * 0.9,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                CustomFormFields.primaryFormField(
                  label: "Lane Name",
                  controller: laneNameController,
                  keyboardType: TextInputType.text,
                  enabled: true,
                  isPassword: false,
                  errorText: viewModel.formState.errors['laneName'],
                ),
                const SizedBox(height: 16),
                CustomDropDown.normalDropDown(
                  label: "Direction",
                  items: Lane.validDirections,
                  value: selectedDirection,
                  onChanged: (value) {
                    setState(() {
                      selectedDirection = value;
                      viewModel.laneDetails['laneDirection'] = value;
                    });
                  },
                  errorText: viewModel.formState.errors['laneDirection'],
                ),
                const SizedBox(height: 16),
                CustomDropDown.normalDropDown(
                  label: "Type",
                  items: Lane.validTypes,
                  value: selectedType,
                  onChanged: (value) {
                    setState(() {
                      selectedType = value;
                      viewModel.laneDetails['laneType'] = value;
                    });
                  },
                  errorText: viewModel.formState.errors['laneType'],
                ),
                const SizedBox(height: 16),
                CustomDropDown.normalDropDown(
                  label: "Status",
                  items: Lane.validStatuses,
                  value: selectedStatus,
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = value;
                      viewModel.laneDetails['laneStatus'] = value;
                    });
                  },
                  errorText: viewModel.formState.errors['laneStatus'],
                ),
                const SizedBox(height: 16),
                CustomFormFields.primaryFormField(
                  label: "RFID Reader ID",
                  controller: rfidReaderController,
                  keyboardType: TextInputType.text,
                  enabled: true,
                  isPassword: false,
                  errorText: viewModel.formState.errors['RFIDReaderID'],
                ),
                const SizedBox(height: 16),
                CustomFormFields.primaryFormField(
                  label: "Camera ID",
                  controller: cameraController,
                  keyboardType: TextInputType.text,
                  enabled: true,
                  isPassword: false,
                  errorText: viewModel.formState.errors['CameraID'],
                ),
                const SizedBox(height: 16),
                CustomFormFields.primaryFormField(
                  label: "WIM ID",
                  controller: wimController,
                  keyboardType: TextInputType.text,
                  enabled: true,
                  isPassword: false,
                  errorText: viewModel.formState.errors['WIMID'],
                ),
                const SizedBox(height: 16),
                CustomFormFields.primaryFormField(
                  label: "Boomer Barrier ID",
                  controller: boomerBarrierController,
                  keyboardType: TextInputType.text,
                  enabled: true,
                  isPassword: false,
                  errorText: viewModel.formState.errors['BoomerBarrierID'],
                ),
                const SizedBox(height: 16),
                CustomFormFields.primaryFormField(
                  label: "LED Screen ID",
                  controller: ledScreenController,
                  keyboardType: TextInputType.text,
                  enabled: true,
                  isPassword: false,
                  errorText: viewModel.formState.errors['LEDScreenID'],
                ),
                const SizedBox(height: 16),
                CustomFormFields.primaryFormField(
                  label: "Magnetic Loop ID",
                  controller: magneticLoopController,
                  keyboardType: TextInputType.text,
                  enabled: true,
                  isPassword: false,
                  errorText: viewModel.formState.errors['MagneticLoopID'],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: _handleSave,
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}

class _EditLaneDialog extends StatefulWidget {
  final Lane lane;
  final Function(Lane) onSave;

  const _EditLaneDialog({required this.lane, required this.onSave});

  @override
  State<_EditLaneDialog> createState() => _EditLaneDialogState();
}

class _EditLaneDialogState extends State<_EditLaneDialog> {
  final laneNameController = TextEditingController();
  final rfidReaderController = TextEditingController();
  final cameraController = TextEditingController();
  final wimController = TextEditingController();
  final boomerBarrierController = TextEditingController();
  final ledScreenController = TextEditingController();
  final magneticLoopController = TextEditingController();
  String? selectedDirection;
  String? selectedType;
  String? selectedStatus;
  late PlazaViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = context.read<PlazaViewModel>();
    laneNameController.text = widget.lane.laneName;
    selectedDirection = widget.lane.laneDirection;
    selectedType = widget.lane.laneType;
    selectedStatus = widget.lane.laneStatus;
    rfidReaderController.text = widget.lane.rfidReaderId ?? '';
    cameraController.text = widget.lane.cameraId ?? '';
    wimController.text = widget.lane.wimId ?? '';
    boomerBarrierController.text = widget.lane.boomerBarrierId ?? '';
    ledScreenController.text = widget.lane.ledScreenId ?? '';
    magneticLoopController.text = widget.lane.magneticLoopId ?? '';
  }

  @override
  void dispose() {
    if (mounted) {
      viewModel.formState.errors.clear();
      viewModel.laneDetails.clear();
    }
    laneNameController.dispose();
    super.dispose();
  }

  void _handleSave() {
    viewModel.laneDetails.addAll({
      'laneName': laneNameController.text.trim(),
      'laneDirection': selectedDirection,
      'laneType': selectedType,
      'laneStatus': selectedStatus,
      'plazaId': widget.lane.plazaId.toString(),
      'laneId': widget.lane.laneId,
      'RFIDReaderID': rfidReaderController.text.trim(),
      'CameraID': cameraController.text.trim(),
      'WIMID': wimController.text.trim(),
      'BoomerBarrierID': boomerBarrierController.text.trim(),
      'LEDScreenID': ledScreenController.text.trim(),
      'MagneticLoopID': magneticLoopController.text.trim(),
    });

    if (viewModel.validateLaneDetailsStep() != null) {
      setState(() {}); // Refresh UI to show validation errors
      return;
    }

    try {
      final updatedLane = Lane(
        laneId: widget.lane.laneId,
        plazaId: widget.lane.plazaId,
        laneName: laneNameController.text.trim(),
        laneDirection: selectedDirection!,
        laneType: selectedType!,
        laneStatus: selectedStatus!,
        recordStatus: widget.lane.recordStatus,
        rfidReaderId: rfidReaderController.text.trim(),
        cameraId: cameraController.text.trim(),
        wimId: wimController.text.trim(),
        boomerBarrierId: boomerBarrierController.text.trim(),
        ledScreenId: ledScreenController.text.trim(),
        magneticLoopId: magneticLoopController.text.trim(),
      );

      widget.onSave(updatedLane);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error updating lane. Please check all fields."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (_) {
        viewModel.formState.errors.clear();
        viewModel.laneDetails.clear();
      },
      child: AlertDialog(
        insetPadding: EdgeInsets.all(16),
        title: const Text("Edit Lane"),
        content: SizedBox(
          width: AppConfig.deviceWidth * 0.9,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                CustomFormFields.primaryFormField(
                  label: "Lane Name",
                  controller: laneNameController,
                  keyboardType: TextInputType.text,
                  enabled: true,
                  isPassword: false,
                  errorText: viewModel.formState.errors['laneName'],
                ),
                const SizedBox(height: 16),
                CustomDropDown.normalDropDown(
                  label: "Direction",
                  items: Lane.validDirections,
                  value: selectedDirection,
                  onChanged: (value) {
                    setState(() {
                      selectedDirection = value;
                      viewModel.laneDetails['laneDirection'] = value;
                    });
                  },
                  errorText: viewModel.formState.errors['laneDirection'],
                ),
                const SizedBox(height: 16),
                CustomDropDown.normalDropDown(
                  label: "Type",
                  items: Lane.validTypes,
                  value: selectedType,
                  onChanged: (value) {
                    setState(() {
                      selectedType = value;
                      viewModel.laneDetails['laneType'] = value;
                    });
                  },
                  errorText: viewModel.formState.errors['laneType'],
                ),
                const SizedBox(height: 16),
                CustomDropDown.normalDropDown(
                  label: "Status",
                  items: Lane.validStatuses,
                  value: selectedStatus,
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = value;
                      viewModel.laneDetails['laneStatus'] = value;
                    });
                  },
                  errorText: viewModel.formState.errors['laneStatus'],
                ),
                const SizedBox(height: 16),
                CustomFormFields.primaryFormField(
                  label: "RFID Reader ID",
                  controller: rfidReaderController,
                  keyboardType: TextInputType.text,
                  enabled: true,
                  isPassword: false,
                  errorText: viewModel.formState.errors['RFIDReaderID'],
                ),
                const SizedBox(height: 16),
                CustomFormFields.primaryFormField(
                  label: "Camera ID",
                  controller: cameraController,
                  keyboardType: TextInputType.text,
                  enabled: true,
                  isPassword: false,
                  errorText: viewModel.formState.errors['CameraID'],
                ),
                const SizedBox(height: 16),
                CustomFormFields.primaryFormField(
                  label: "WIM ID",
                  controller: wimController,
                  keyboardType: TextInputType.text,
                  enabled: true,
                  isPassword: false,
                  errorText: viewModel.formState.errors['WIMID'],
                ),
                const SizedBox(height: 16),
                CustomFormFields.primaryFormField(
                  label: "Boomer Barrier ID",
                  controller: boomerBarrierController,
                  keyboardType: TextInputType.text,
                  enabled: true,
                  isPassword: false,
                  errorText: viewModel.formState.errors['BoomerBarrierID'],
                ),
                const SizedBox(height: 16),
                CustomFormFields.primaryFormField(
                  label: "LED Screen ID",
                  controller: ledScreenController,
                  keyboardType: TextInputType.text,
                  enabled: true,
                  isPassword: false,
                  errorText: viewModel.formState.errors['LEDScreenID'],
                ),
                const SizedBox(height: 16),
                CustomFormFields.primaryFormField(
                  label: "Magnetic Loop ID",
                  controller: magneticLoopController,
                  keyboardType: TextInputType.text,
                  enabled: true,
                  isPassword: false,
                  errorText: viewModel.formState.errors['MagneticLoopID'],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: _handleSave,
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
