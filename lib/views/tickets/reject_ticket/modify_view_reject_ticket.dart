import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_config.dart';
import 'package:provider/provider.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/config/app_strings.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:merchant_app/utils/components/form_field.dart';
import 'package:shimmer/shimmer.dart';
import '../../../viewmodels/ticket/reject_ticket_viewmodel.dart';

class ModifyViewRejectTicketScreen extends StatefulWidget {
  const ModifyViewRejectTicketScreen({super.key});

  @override
  State<ModifyViewRejectTicketScreen> createState() => _ModifyViewRejectTicketScreenState();
}

class _ModifyViewRejectTicketScreenState extends State<ModifyViewRejectTicketScreen> {
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    // Add listener to remarksController for real-time validation feedback
    final viewModel = Provider.of<RejectTicketViewModel>(context, listen: false);
    viewModel.remarksController.addListener(() {
      if (isEditing) {
        viewModel.validateForm(); // Trigger validation on change
      }
    });
  }

  void _handleCancel() {
    final viewModel = Provider.of<RejectTicketViewModel>(context, listen: false);
    viewModel.resetRemarks();
    setState(() {
      isEditing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Changes discarded')),
    );
  }

  Future<void> _handleSave() async {
    if (!isEditing) return;

    final viewModel = Provider.of<RejectTicketViewModel>(context, listen: false);

    if (!viewModel.validateForm()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.remarksError ?? 'Please check the remarks field'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await viewModel.rejectTicket();

    if (success && mounted) {
      setState(() {
        isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ticket rejected successfully')),
      );
      Navigator.pop(context); // Pop back to the previous screen after success
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.apiError ?? 'Failed to reject ticket'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showZoomableImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(10),
          child: Stack(
            children: [
              InteractiveViewer(
                boundaryMargin: const EdgeInsets.all(20.0),
                minScale: 0.5,
                maxScale: 4.0,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(color: Colors.grey.shade300),
                  ),
                  errorWidget: (context, url, error) => const Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      size: 48,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageSection(RejectTicketViewModel viewModel) {
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
                  : GestureDetector(
                onTap: () => _showZoomableImageDialog(viewModel.capturedImageUrl!),
                child: CachedNetworkImage(
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
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField(String label, TextEditingController controller) {
    return CustomFormFields.primaryFormField(
      label: label,
      controller: controller,
      enabled: false,
      errorText: null,
      isPassword: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RejectTicketViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: CustomAppBar.appBarWithNavigation(
            screenTitle: AppStrings.titleModifyViewTicketDetails,
            onPressed: () => Navigator.pop(context),
            darkBackground: true,
          ),
          backgroundColor: AppColors.lightThemeBackground,
          body: Stack(
            children: [
              Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildImageSection(viewModel),
                        const SizedBox(height: 16),
                        _buildReadOnlyField('Ticket ID', viewModel.ticketIdController),
                        const SizedBox(height: 16),
                        _buildReadOnlyField('Ticket Reference ID', viewModel.ticketRefIdController),
                        const SizedBox(height: 16),
                        _buildReadOnlyField('Plaza ID', viewModel.plazaIdController),
                        const SizedBox(height: 16),
                        _buildReadOnlyField('Entry Lane ID', viewModel.entryLaneIdController),
                        const SizedBox(height: 16),
                        _buildReadOnlyField('Entry Lane Direction', viewModel.entryLaneDirectionController),
                        const SizedBox(height: 16),
                        _buildReadOnlyField('Floor ID', viewModel.floorIdController),
                        const SizedBox(height: 16),
                        _buildReadOnlyField('Slot ID', viewModel.slotIdController),
                        const SizedBox(height: 16),
                        _buildReadOnlyField('Vehicle Number', viewModel.vehicleNumberController),
                        const SizedBox(height: 16),
                        _buildReadOnlyField('Vehicle Type', viewModel.vehicleTypeController),
                        const SizedBox(height: 16),
                        _buildReadOnlyField('Vehicle Entry Timestamp', viewModel.entryTimeController),
                        const SizedBox(height: 16),
                        _buildReadOnlyField('Ticket Creation Time', viewModel.ticketCreationTimeController),
                        const SizedBox(height: 16),
                        _buildReadOnlyField('Ticket Status', viewModel.ticketStatusController),
                        const SizedBox(height: 16),
                        CustomFormFields.remarksFormField(
                          label: 'Remarks (Required - minimum 10 characters)',
                          controller: viewModel.remarksController,
                          enabled: isEditing,
                          errorText: viewModel.remarksError,
                          onChanged: (value) {
                            if (isEditing) {
                              viewModel.validateForm(); // Trigger validation on change
                            }
                          },
                        ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ),
              if (viewModel.isLoading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
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
                  heroTag: 'cancel',
                  onPressed: viewModel.isLoading ? null : _handleCancel,
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.close),
                ),
                const SizedBox(width: 16),
              ],
              FloatingActionButton(
                heroTag: 'edit',
                onPressed: viewModel.isLoading
                    ? null
                    : () {
                  if (isEditing) {
                    _handleSave();
                  } else {
                    setState(() {
                      isEditing = true;
                    });
                  }
                },
                child: Icon(isEditing ? Icons.save : Icons.edit),
              ),
            ],
          ),
        );
      },
    );
  }
}