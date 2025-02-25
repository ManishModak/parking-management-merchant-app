import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_config.dart';
import 'package:provider/provider.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/config/app_strings.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:merchant_app/utils/components/form_field.dart';
import '../../../utils/components/dropdown.dart';
import '../../../viewmodels/ticket/open_ticket_viewmodel.dart';
import 'package:shimmer/shimmer.dart';

class ModifyViewOpenTicketScreen extends StatefulWidget {
  const ModifyViewOpenTicketScreen({super.key});

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _storeOriginalValues();
    });
  }

  void _storeOriginalValues() {
    final viewModel = Provider.of<OpenTicketViewModel>(context, listen: false);
    originalValues = {
      'floorId': viewModel.floorIdController.text,
      'slotId': viewModel.slotIdController.text,
      'capturedImage': viewModel.capturedImageController.text,
      'vehicleNumber': viewModel.vehicleNumberController.text,
      'vehicleType': viewModel.vehicleTypeController.text,
    };
  }

  void _handleCancel() {
    final viewModel = Provider.of<OpenTicketViewModel>(context, listen: false);
    viewModel.floorIdController.text = originalValues['floorId'] ?? '';
    viewModel.slotIdController.text = originalValues['slotId'] ?? '';
    viewModel.capturedImageController.text = originalValues['capturedImage'] ?? '';
    viewModel.vehicleNumberController.text = originalValues['vehicleNumber'] ?? '';
    viewModel.vehicleTypeController.text = originalValues['vehicleType'] ?? '';

    setState(() {
      isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Changes discarded')),
    );
  }

  void _handleSave() {
    if (!isEditing) return;

    final viewModel = Provider.of<OpenTicketViewModel>(context, listen: false);
    viewModel.saveTicketChanges().then((success) {
      if (success) {
        setState(() {
          isEditing = false;
        });
        _storeOriginalValues();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ticket details saved successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all mandatory fields')),
        );
      }
    });
  }

  Widget _buildImageSection(OpenTicketViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Captured Image',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Container(
            height: 250,
            width: AppConfig.deviceWidth * 0.9,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: viewModel.capturedImageUrl == null
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'No Image Available',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
                  : CachedNetworkImage(
                imageUrl: viewModel.capturedImageUrl!,
                fit: BoxFit.contain,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(color: Colors.grey.shade300),
                ),
                errorWidget: (context, url, error) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image_outlined,
                          size: 48, color: AppColors.primary),
                      const SizedBox(height: 8),
                      const Text(
                        'Failed to load image',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OpenTicketViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: CustomAppBar.appBarWithNavigation(
            screenTitle: AppStrings.titleModifyViewTicketDetails,
            onPressed: () => Navigator.pop(context),
            darkBackground: true,
          ),
          backgroundColor: AppColors.lightThemeBackground,
          body: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildImageSection(viewModel),
                  const SizedBox(height: 16),
                  CustomFormFields.primaryFormField(
                    label: 'Ticket ID',
                    controller: viewModel.ticketRefIdController,
                    enabled: false,
                    errorText: null,
                    isPassword: false,
                  ),
                  const SizedBox(height: 16),
                  CustomFormFields.primaryFormField(
                    label: 'Plaza ID',
                    controller: viewModel.plazaIdController,
                    enabled: false,
                    errorText: null,
                    isPassword: false,
                  ),
                  const SizedBox(height: 16),
                  CustomFormFields.primaryFormField(
                    label: 'Entry Lane ID',
                    controller: viewModel.entryLaneIdController,
                    enabled: false,
                    errorText: null,
                    isPassword: false,
                  ),
                  const SizedBox(height: 16),
                  CustomFormFields.primaryFormField(
                    label: 'Entry Lane Direction',
                    controller: viewModel.entryLaneDirectionController,
                    enabled: false,
                    errorText: null,
                    isPassword: false,
                  ),
                  const SizedBox(height: 16),
                  CustomFormFields.primaryFormField(
                    label: 'Floor ID',
                    controller: viewModel.floorIdController,
                    enabled: isEditing,
                    errorText: viewModel.floorIdError,
                    isPassword: false,
                  ),
                  const SizedBox(height: 16),
                  CustomFormFields.primaryFormField(
                    label: 'Slot ID',
                    controller: viewModel.slotIdController,
                    enabled: isEditing,
                    errorText: viewModel.slotIdError,
                    isPassword: false,
                  ),
                  const SizedBox(height: 16),
                  CustomFormFields.primaryFormField(
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
                  ),
                  const SizedBox(height: 16),
                  CustomFormFields.primaryFormField(
                    label: 'Vehicle Entry Timestamp',
                    controller: viewModel.vehicleEntryTimestampController,
                    enabled: false,
                    errorText: null,
                    isPassword: false,
                  ),
                  const SizedBox(height: 16),
                  CustomFormFields.primaryFormField(
                    label: 'Ticket Creation Time',
                    controller: viewModel.ticketCreationTimeController,
                    enabled: false,
                    errorText: null,
                    isPassword: false,
                  ),
                  const SizedBox(height: 16),
                  CustomFormFields.primaryFormField(
                    label: 'Ticket Status',
                    controller: viewModel.ticketStatusController,
                    enabled: false,
                    errorText: null,
                    isPassword: false,
                  ),
                  if (viewModel.modificationTimeController.text.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    CustomFormFields.primaryFormField(
                      label: 'Modification Time',
                      controller: viewModel.modificationTimeController,
                      enabled: false,
                      errorText: null,
                      isPassword: false,
                    ),
                  ],
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (isEditing) ...[
                FloatingActionButton(
                  onPressed: _handleCancel,
                  heroTag: 'cancel',
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.close),
                ),
                const SizedBox(width: 16),
              ],
              FloatingActionButton(
                onPressed: isEditing
                    ? _handleSave
                    : () {
                  setState(() {
                    isEditing = true;
                  });
                },
                heroTag: 'editSave',
                child: Icon(isEditing ? Icons.save : Icons.edit),
              ),
            ],
          ),
        );
      },
    );
  }
}