import 'package:flutter/material.dart';
import 'package:merchant_app/config/api_config.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/config/app_config.dart';
import 'package:provider/provider.dart';

import '../../../models/lane.dart';
import '../../../utils/components/appbar.dart';
import '../../../utils/components/dropdown.dart';
import '../../../utils/components/form_field.dart';
import '../../../viewmodels/plaza_viewmodel/plaza_viewmodel.dart';
import '../../../utils/screens/loading_screen.dart';

class LaneDetailsModificationScreen extends StatefulWidget {
  const LaneDetailsModificationScreen({super.key});

  @override
  State<LaneDetailsModificationScreen> createState() =>
      _LaneDetailsModificationScreenState();
}

class _LaneDetailsModificationScreenState
    extends State<LaneDetailsModificationScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool isEditable = false;
  String _searchQuery = '';
  int _currentPage = 1;
  static const int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    final viewModel = context.read<PlazaViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.fetchLanes(viewModel.plazaId ?? '');
    });

    _searchController.addListener(() {
      setState(() => _currentPage = 1);
      _handleSearch();
    });
  }

  void _handleSearch() {
    setState(() => _searchQuery = _searchController.text.toLowerCase());
  }

  List<Lane> _getFilteredLanes(List<Lane> lanes) {
    if (_searchQuery.isEmpty) return lanes;
    return lanes.where((lane) {
      return lane.laneName.toLowerCase().contains(_searchQuery) ||
          lane.laneId.toString().contains(_searchQuery) ||
          lane.laneDirection.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  List<Lane> _getPaginatedLanes(List<Lane> filteredLanes) {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    return endIndex > filteredLanes.length
        ? filteredLanes.sublist(startIndex)
        : filteredLanes.sublist(startIndex, endIndex);
  }

  void _updatePage(int newPage) {
    if (newPage < 1 || newPage > _calculateTotalPages()) return;
    setState(() => _currentPage = newPage);
  }

  int _calculateTotalPages() {
    final viewModel = context.read<PlazaViewModel>();
    final filteredCount = _getFilteredLanes(viewModel.lanes).length;
    return (filteredCount / _itemsPerPage).ceil();
  }

  Widget _buildPaginationControls(int currentPage, int totalPages) {
    return Container(
      height: 60, // Reduced height
      padding: const EdgeInsets.symmetric(vertical: 4.0), // Reduced padding
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.first_page, size: 20),
            // Smaller icon
            onPressed: currentPage > 1 ? () => _updatePage(1) : null,
            color: AppColors.primary,
            tooltip: 'First page',
            padding: EdgeInsets.zero, // Remove padding
          ),
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 20),
            // Smaller icon
            onPressed:
                currentPage > 1 ? () => _updatePage(currentPage - 1) : null,
            color: AppColors.primary,
            tooltip: 'Previous page',
            padding: EdgeInsets.zero, // Remove padding
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6), // Smaller radius
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            // Reduced padding
            child: Text(
              '$currentPage / $totalPages',
              style: const TextStyle(
                fontSize: 14, // Smaller font
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 20),
            // Smaller icon
            onPressed: currentPage < totalPages
                ? () => _updatePage(currentPage + 1)
                : null,
            color: AppColors.primary,
            tooltip: 'Next page',
            padding: EdgeInsets.zero, // Remove padding
          ),
          IconButton(
            icon: const Icon(Icons.last_page, size: 20),
            // Smaller icon
            onPressed:
                currentPage < totalPages ? () => _updatePage(totalPages) : null,
            color: AppColors.primary,
            tooltip: 'Last page',
            padding: EdgeInsets.zero, // Remove padding
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return CustomFormFields.searchFormField(
      controller: _searchController,
      hintText: 'Search lanes by name, ID or direction...',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightThemeBackground,
      appBar: CustomAppBar.appBarWithNavigation(
          screenTitle: "Lane Details",
          onPressed: () => Navigator.pop(context),
          darkBackground: true),
      body: Center(
        child: Column(
          children: [
            Consumer<PlazaViewModel>(
              builder: (context, viewModel, _) {
                final plazaName =
                    viewModel.formState.basicDetails['plazaName'] ??
                        'Unknown Plaza';
                final plazaId =  viewModel.plazaId ??
                    'Unknown ID';
                return Card(
                  margin: const EdgeInsets.only(top: 8, left: 16, right: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_city,
                          color: Colors.grey.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "$plazaName",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                "ID: $plazaId",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            _buildSearchField(),
            Expanded(
              child: Consumer<PlazaViewModel>(
                builder: (context, viewModel, _) {
                  if (viewModel.isLoading) return const LoadingScreen();
                  if (viewModel.error != null) {
                    return _buildErrorState(viewModel);
                  }

                  final filteredLanes = _getFilteredLanes(viewModel.lanes);
                  final paginatedLanes = _getPaginatedLanes(filteredLanes);

                  return RefreshIndicator(
                    onRefresh: () =>
                        viewModel.fetchLanes(viewModel.plazaId ?? ''),
                    child: Scrollbar(
                      controller: _scrollController,
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        itemCount: paginatedLanes.length,
                        itemBuilder: (context, index) {
                          final lane = paginatedLanes[index];
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
                                    onTap: isEditable
                                        ? () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => _EditLaneDialog(
                                          lane: lane,
                                          onSave: (updatedLane) async {
                                            final viewModel = context.read<PlazaViewModel>();
                                            await viewModel.updateLane(
                                                lane.laneId.toString(),
                                                updatedLane
                                            );
                                            await viewModel.fetchLanes(viewModel.plazaId ?? '');
                                          },
                                        ),
                                      );
                                    }
                                        : null,
                                    borderRadius: BorderRadius.circular(8),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              _buildStatusBadge(
                                                  lane.laneStatus),
                                            ],
                                          ),
                                          const SizedBox(height: 8),

                                          // Direction and Type in a compact row
                                          Row(
                                            children: [
                                              _buildInfoChip(Icons.directions,
                                                  lane.laneDirection),
                                              const SizedBox(width: 16),
                                              _buildInfoChip(Icons.category,
                                                  lane.laneType),
                                            ],
                                          ),
                                          const SizedBox(height: 8),

                                          // Device IDs in a compact grid
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Left column
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    _buildDeviceInfo('RFID',
                                                        lane.rfidReaderId),
                                                    const SizedBox(height: 4),
                                                    _buildDeviceInfo('Camera',
                                                        lane.cameraId),
                                                    const SizedBox(height: 4),
                                                    _buildDeviceInfo(
                                                        'WIM', lane.wimId),
                                                  ],
                                                ),
                                              ),
                                              // Right column
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    _buildDeviceInfo('Barrier',
                                                        lane.boomerBarrierId),
                                                    const SizedBox(height: 4),
                                                    _buildDeviceInfo('LED',
                                                        lane.ledScreenId),
                                                    const SizedBox(height: 4),
                                                    _buildDeviceInfo('Loop',
                                                        lane.magneticLoopId),
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
                                if (isEditable)
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
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (!isEditable) ...[
            FloatingActionButton(
              heroTag: 'addLaneFAB',
              onPressed: () {
                final viewModel = context.read<PlazaViewModel>();
                showDialog(
                  context: context,
                  builder: (context) => _AddLaneDialog(
                    onSave: (newLanes) async {
                      await viewModel.addLane(newLanes);
                      await viewModel.fetchLanes(viewModel.plazaId ?? '');
                    },
                    plazaId: viewModel.plazaId ?? '',
                  ),
                );
              },
              child: const Icon(Icons.add),
            ),
            const SizedBox(width: 16),
            FloatingActionButton(
              heroTag: 'editToggleFAB',
              onPressed: () => setState(() => isEditable = true),
              child: const Icon(Icons.edit),
            ),
          ] else
            FloatingActionButton(
              heroTag: 'saveFAB',
              onPressed: () => setState(() => isEditable = false),
              backgroundColor: Colors.green,
              child: const Icon(Icons.check),
            ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Consumer<PlazaViewModel>(
        builder: (context, viewModel, _) {
          final filteredLanes = _getFilteredLanes(viewModel.lanes);
          final totalPages = (filteredLanes.length / _itemsPerPage).ceil();
          if (filteredLanes.isEmpty) return const SizedBox.shrink();
          return _buildPaginationControls(_currentPage, totalPages);
        },
      ),
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
              color:
                  displayValue == 'N/A' ? Colors.grey.shade400 : Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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
          color:
              status == 'active' ? Colors.green.shade800 : Colors.red.shade800,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildErrorState(PlazaViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            viewModel.error!,
            style: TextStyle(color: Colors.red.shade700),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => viewModel.fetchLanes(viewModel.plazaId ?? ''),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

// AddLaneDialog Widget
class _AddLaneDialog extends StatefulWidget {
  final Function(List<Lane>) onSave;
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

  void _handleSave(BuildContext context) {
    try {
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

      // Create a list to hold multiple lanes
      List<Lane> lanes = [];

      // Only validate when saving
      if (viewModel.validateLaneDetailsStep() != null) {
        setState(() {}); // Refresh UI to show validation errors
        return;
      }

      // Add the current lane to the list
      lanes.add(
        Lane(
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
        ),
      );
      // Pass the list of lanes to the onSave callback
      widget.onSave(lanes);

      // Close the dialog
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error saving lanes: ${e.toString()}"),
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
            onPressed: () => _handleSave(context),
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

  void _handleSave(BuildContext context) {
    // Update all lane details at once when saving
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

    // Only validate when saving
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
    final viewModel = context.watch<PlazaViewModel>();

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
            onPressed: () => _handleSave(context),
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
