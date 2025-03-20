import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:merchant_app/models/lane.dart';
import 'package:merchant_app/services/core/lane_service.dart';
import 'package:merchant_app/viewmodels/plaza/plaza_viewmodel.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:merchant_app/utils/components/form_field.dart';
import 'package:merchant_app/utils/components/dropdown.dart';

class ModifyViewLaneDetailsScreen extends StatefulWidget {
  final String laneId;

  const ModifyViewLaneDetailsScreen({super.key, required this.laneId});

  @override
  State<ModifyViewLaneDetailsScreen> createState() =>
      _ModifyViewLaneDetailsScreenState();
}

class _ModifyViewLaneDetailsScreenState
    extends State<ModifyViewLaneDetailsScreen> {
  bool isEditing = false;
  bool isLoading = true;
  Lane? lane;

  // Controllers for lane fields
  final TextEditingController laneNameController = TextEditingController();
  final TextEditingController rfidReaderController = TextEditingController();
  final TextEditingController cameraController = TextEditingController();
  final TextEditingController wimController = TextEditingController();
  final TextEditingController boomerBarrierController =
  TextEditingController();
  final TextEditingController ledScreenController = TextEditingController();
  final TextEditingController magneticLoopController =
  TextEditingController();

  // Selected dropdown values
  String? selectedDirection;
  String? selectedType;
  String? selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadLaneData();
  }

  Future<void> _loadLaneData() async {
    setState(() {
      isLoading = true;
    });
    try {
      // Retrieve lane data using the LaneService
      final laneService = LaneService();
      final fetchedLane = await laneService.getLaneById(widget.laneId);
      lane = fetchedLane;

      // Populate controllers and selected values with fetched data
      laneNameController.text = fetchedLane.laneName;
      rfidReaderController.text = fetchedLane.rfidReaderId ?? '';
      cameraController.text = fetchedLane.cameraId ?? '';
      wimController.text = fetchedLane.wimId ?? '';
      boomerBarrierController.text = fetchedLane.boomerBarrierId ?? '';
      ledScreenController.text = fetchedLane.ledScreenId ?? '';
      magneticLoopController.text = fetchedLane.magneticLoopId ?? '';

      selectedDirection = fetchedLane.laneDirection;
      selectedType = fetchedLane.laneType;
      selectedStatus = fetchedLane.laneStatus;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading lane data: $e")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildLaneFields() {
    return Column(
      children: [
        CustomFormFields.normalSizedTextFormField(context:context,
          label: "Lane Name",
          controller: laneNameController,
          keyboardType: TextInputType.text,
          enabled: isEditing,
          isPassword: false,
        ),
        const SizedBox(height: 16),
        CustomDropDown.normalDropDown(context:context,
          label: "Lane Direction",
          items: Lane.validDirections,
          value: selectedDirection,
          onChanged: (value) {
            setState(() {
              selectedDirection = value;
            });
          },
          enabled: isEditing,
        ),
        const SizedBox(height: 16),
        CustomDropDown.normalDropDown(context:context,
          label: "Lane Type",
          items: Lane.validTypes,
          value: selectedType,
          onChanged:(value) {
            setState(() {
              selectedType = value;
            });
          },
          enabled: isEditing,
        ),
        const SizedBox(height: 16),
        CustomDropDown.normalDropDown(context:context,
          label: "Lane Status",
          items: Lane.validStatuses,
          value: selectedStatus,
          onChanged: (value) {
            setState(() {
              selectedStatus = value;
            });
          },
          enabled: isEditing,
        ),
        const SizedBox(height: 16),
        CustomFormFields.normalSizedTextFormField(context:context,
          label: "RFID Reader ID",
          controller: rfidReaderController,
          keyboardType: TextInputType.text,
          enabled: isEditing,
          isPassword: false,
        ),
        const SizedBox(height: 16),
        CustomFormFields.normalSizedTextFormField(context:context,
          label: "Camera ID",
          controller: cameraController,
          keyboardType: TextInputType.text,
          enabled: isEditing,
          isPassword: false,
        ),
        const SizedBox(height: 16),
        CustomFormFields.normalSizedTextFormField(context:context,
          label: "WIM ID",
          controller: wimController,
          keyboardType: TextInputType.text,
          enabled: isEditing,
          isPassword: false,
        ),
        const SizedBox(height: 16),
        CustomFormFields.normalSizedTextFormField(context:context,
          label: "Boomer Barrier ID",
          controller: boomerBarrierController,
          keyboardType: TextInputType.text,
          enabled: isEditing,
          isPassword: false,
        ),
        const SizedBox(height: 16),
        CustomFormFields.normalSizedTextFormField(context:context,
          label: "LED Screen ID",
          controller: ledScreenController,
          keyboardType: TextInputType.text,
          enabled: isEditing,
          isPassword: false,
        ),
        const SizedBox(height: 16),
        CustomFormFields.normalSizedTextFormField(context:context,
          label: "Magnetic Loop ID",
          controller: magneticLoopController,
          keyboardType: TextInputType.text,
          enabled: isEditing,
          isPassword: false,
        ),
      ],
    );
  }

  void _handleSave() async {
    if (lane == null) return;

    // Construct the updated lane object
    final updatedLane = Lane(
      laneId: lane!.laneId,
      plazaId: lane!.plazaId,
      laneName: laneNameController.text.trim(),
      laneDirection: selectedDirection ?? lane!.laneDirection,
      laneType: selectedType ?? lane!.laneType,
      laneStatus: selectedStatus ?? lane!.laneStatus,
      rfidReaderId: rfidReaderController.text.trim(),
      cameraId: cameraController.text.trim(),
      wimId: wimController.text.trim(),
      boomerBarrierId: boomerBarrierController.text.trim(),
      ledScreenId: ledScreenController.text.trim(),
      magneticLoopId: magneticLoopController.text.trim(),
      recordStatus: "active"
    );

    // Update the lane using the viewmodel methods
    final viewModel = context.read<PlazaViewModel>();
    await viewModel.updateLane(lane!.laneId.toString(), updatedLane);
    await viewModel.fetchLanes(viewModel.plazaId ?? '');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Lane updated successfully")),
    );
    setState(() {
      isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: CustomAppBar.appBarWithNavigation(
          screenTitle: "Edit Lane\nDetails",
          onPressed: () => Navigator.pop(context),
          darkBackground: true, context: context,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: CustomAppBar.appBarWithNavigation(
        screenTitle: "Edit Lane\nDetails",
        onPressed: () => Navigator.pop(context),
        darkBackground: true, context: context,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _buildLaneFields(),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (isEditing) ...[
            FloatingActionButton(
              onPressed: () {
                // Cancel editing: reload lane data to revert changes
                _loadLaneData();
                setState(() {
                  isEditing = false;
                });
              },
              heroTag: 'cancelFab',
              backgroundColor: Colors.red,
              child: const Icon(Icons.close),
            ),
            const SizedBox(width: 16),
          ],
          FloatingActionButton(
            onPressed: () {
              if (isEditing) {
                _handleSave();
              } else {
                setState(() {
                  isEditing = true;
                });
              }
            },
            heroTag: 'mainFab',
            child: Icon(isEditing ? Icons.save : Icons.edit),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    laneNameController.dispose();
    rfidReaderController.dispose();
    cameraController.dispose();
    wimController.dispose();
    boomerBarrierController.dispose();
    ledScreenController.dispose();
    magneticLoopController.dispose();
    super.dispose();
  }
}
