import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:merchant_app/utils/components/form_field.dart';
import '../../../generated/l10n.dart';
import '../../../utils/components/dropdown.dart';
import '../../../viewmodels/ticket/open_ticket_viewmodel.dart';
import 'dart:developer' as developer;

class ModifyViewOpenTicketScreen extends StatefulWidget {
  final String ticketId;

  const ModifyViewOpenTicketScreen({super.key, required this.ticketId});

  @override
  State<ModifyViewOpenTicketScreen> createState() =>
      _ModifyViewOpenTicketScreenState();
}

class _ModifyViewOpenTicketScreenState
    extends State<ModifyViewOpenTicketScreen> {
  bool isEditing = false;
  Map<String, String> originalValues = {};

  @override
  void initState() {
    super.initState();
    developer.log(
        'Initializing ModifyViewOpenTicketScreen for ticketId: ${widget.ticketId}',
        name: 'ModifyViewOpenTicketScreen');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel =
          Provider.of<OpenTicketViewModel>(context, listen: false);
      developer.log(
          'Fetching ticket details in post frame callback for ticketId: ${widget.ticketId}',
          name: 'ModifyViewOpenTicketScreen');
      viewModel.fetchTicketDetails(widget.ticketId);
    });
  }

  void _storeOriginalValues(OpenTicketViewModel viewModel) {
    developer.log('Storing original values for ticketId: ${widget.ticketId}',
        name: 'ModifyViewOpenTicketScreen');
    originalValues = {
      'floorId': viewModel.floorIdController.text,
      'slotId': viewModel.slotIdController.text,
      'vehicleNumber': viewModel.vehicleNumberController.text,
      'vehicleType': viewModel.vehicleTypeController.text,
    };
    developer.log('Original values stored: $originalValues',
        name: 'ModifyViewOpenTicketScreen');
  }

  void _restoreOriginalValues(OpenTicketViewModel viewModel) {
    developer.log('Restoring original values for ticketId: ${widget.ticketId}',
        name: 'ModifyViewOpenTicketScreen');
    viewModel.floorIdController.text = originalValues['floorId'] ?? '';
    viewModel.slotIdController.text = originalValues['slotId'] ?? '';
    viewModel.vehicleNumberController.text =
        originalValues['vehicleNumber'] ?? '';
    viewModel.vehicleTypeController.text = originalValues['vehicleType'] ?? '';
    viewModel.selectedVehicleType = originalValues['vehicleType'];
    viewModel.resetErrors();
    developer.log('Original values restored: $originalValues',
        name: 'ModifyViewOpenTicketScreen');
  }

  void _handleCancel() {
    developer.log('Cancel button pressed for ticketId: ${widget.ticketId}',
        name: 'ModifyViewOpenTicketScreen');
    final viewModel = Provider.of<OpenTicketViewModel>(context, listen: false);
    _restoreOriginalValues(viewModel);
    setState(() {
      isEditing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Changes discarded')),
    );
    developer.log('Editing cancelled, changes discarded',
        name: 'ModifyViewOpenTicketScreen');
  }

  Future<void> _handleSave() async {
    if (!isEditing) {
      developer.log('Save attempted but not in editing mode',
          name: 'ModifyViewOpenTicketScreen');
      return;
    }

    developer.log('Save button pressed for ticketId: ${widget.ticketId}',
        name: 'ModifyViewOpenTicketScreen');
    final viewModel = Provider.of<OpenTicketViewModel>(context, listen: false);
    final success = await viewModel.saveTicketChanges();

    if (success && mounted) {
      setState(() {
        isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Ticket Details Modified Successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      developer.log('Ticket details saved successfully, navigating back',
          name: 'ModifyViewOpenTicketScreen');
      Navigator.pop(context);
    } else if (mounted) {
      String errorMessage = viewModel.apiError ?? 'Failed to save changes';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      developer.log('Failed to save ticket details: $errorMessage',
          name: 'ModifyViewOpenTicketScreen');
    }
  }

  Widget _buildReadOnlyField(String label, TextEditingController controller) {
    developer.log('Building read-only field: $label',
        name: 'ModifyViewOpenTicketScreen');
    return CustomFormFields.normalSizedTextFormField(
      context: context,
      label: label,
      controller: controller,
      enabled: false,
      errorText: null,
      isPassword: false,
    );
  }

  PreferredSizeWidget _buildCustomAppBar(
      OpenTicketViewModel viewModel, S strings) {
    developer.log(
        'Building custom app bar, ticketRefId: ${viewModel.ticket?.ticketRefId ?? "loading"}',
        name: 'ModifyViewOpenTicketScreen');
    return CustomAppBar.appBarWithNavigation(
      screenTitle: viewModel.ticket == null
          ? strings.titleModifyViewTicketDetails
          : "${strings.titleModifyViewTicketDetails}\n#${viewModel.ticket!.ticketRefId ?? strings.labelNA}",
      onPressed: () {
        developer.log('App bar back button pressed',
            name: 'ModifyViewOpenTicketScreen');
        Navigator.pop(context);
      },
      darkBackground: Theme.of(context).brightness == Brightness.dark,
      fontSize: 16,
      centreTitle: false,
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    developer.log(
        'Building ModifyViewOpenTicketScreen for ticketId: ${widget.ticketId}',
        name: 'ModifyViewOpenTicketScreen');
    return Consumer<OpenTicketViewModel>(
      builder: (context, viewModel, child) {
        developer.log(
            'Consumer rebuilding, isLoading: ${viewModel.isLoading}, isEditing: $isEditing',
            name: 'ModifyViewOpenTicketScreen');
        return Scaffold(
          appBar: _buildCustomAppBar(viewModel, strings),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Stack(
            children: [
              SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildReadOnlyField(
                        'Ticket ID', viewModel.ticketRefIdController),
                    const SizedBox(height: 16),
                    _buildReadOnlyField(
                        'Plaza Name', viewModel.plazaNameController),
                    const SizedBox(height: 16),
                    _buildReadOnlyField(
                        'Entry Lane ID', viewModel.entryLaneIdController),
                    const SizedBox(height: 16),
                    _buildReadOnlyField('Entry Lane Direction',
                        viewModel.entryLaneDirectionController),
                    const SizedBox(height: 16),
                    CustomFormFields.normalSizedTextFormField(
                      context: context,
                      label: 'Floor ID',
                      controller: viewModel.floorIdController,
                      enabled: isEditing,
                      errorText: viewModel.floorIdError,
                      isPassword: false,
                    ),
                    const SizedBox(height: 16),
                    CustomFormFields.normalSizedTextFormField(
                      context: context,
                      label: 'Slot ID',
                      controller: viewModel.slotIdController,
                      enabled: isEditing,
                      errorText: viewModel.slotIdError,
                      isPassword: false,
                    ),
                    const SizedBox(height: 16),
                    CustomFormFields.normalSizedTextFormField(
                      context: context,
                      label: 'Vehicle Number',
                      controller: viewModel.vehicleNumberController,
                      enabled: isEditing,
                      errorText: viewModel.vehicleNumberError,
                      isPassword: false,
                    ),
                    const SizedBox(height: 16),
                    CustomDropDown.normalDropDown(
                      label: 'Vehicle Type',
                      value: viewModel.selectedVehicleType,
                      items: viewModel.vehicleTypes,
                      onChanged: viewModel.updateVehicleType,
                      icon: Icons.directions_car,
                      enabled: isEditing,
                      errorText: viewModel.vehicleTypeError,
                      context: context,
                    ),
                    const SizedBox(height: 16),
                    _buildReadOnlyField('Vehicle Entry Timestamp',
                        viewModel.vehicleEntryTimestampController),
                    const SizedBox(height: 16),
                    _buildReadOnlyField('Ticket Creation Time',
                        viewModel.ticketCreationTimeController),
                    const SizedBox(height: 16),
                    _buildReadOnlyField(
                        'Ticket Status', viewModel.ticketStatusController),
                    if (viewModel
                        .modificationTimeController.text.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildReadOnlyField('Modification Time',
                          viewModel.modificationTimeController),
                    ],
                    const SizedBox(height: 80),
                  ],
                ),
              ),
              if (viewModel.isLoading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                ),
            ],
          ),
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (isEditing) ...[
                FloatingActionButton(
                  onPressed: viewModel.isLoading ? null : _handleCancel,
                  heroTag: 'cancel',
                  backgroundColor: Colors.red,
                  mini: true,
                  child: const Icon(Icons.close, size: 20),
                ),
                const SizedBox(width: 16),
              ],
              FloatingActionButton(
                onPressed: viewModel.isLoading
                    ? null
                    : isEditing
                        ? _handleSave
                        : () {
                            developer.log(
                                'Edit button pressed, entering edit mode',
                                name: 'ModifyViewOpenTicketScreen');
                            _storeOriginalValues(viewModel);
                            setState(() {
                              isEditing = true;
                            });
                          },
                heroTag: 'editSave',
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Icon(isEditing ? Icons.save : Icons.edit),
              ),
            ],
          ),
        );
      },
    );
  }
}
