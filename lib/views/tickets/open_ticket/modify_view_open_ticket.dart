import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_config.dart';
import 'package:provider/provider.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:merchant_app/utils/components/form_field.dart';
import '../../../generated/l10n.dart';
import '../../../utils/components/dropdown.dart';
import '../../../utils/exceptions.dart';
import '../../../viewmodels/ticket/open_ticket_viewmodel.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:developer' as developer;

class ModifyViewOpenTicketScreen extends StatefulWidget {
  final String ticketId;

  const ModifyViewOpenTicketScreen({super.key, required this.ticketId});

  @override
  State<ModifyViewOpenTicketScreen> createState() => _ModifyViewOpenTicketScreenState();
}

class _ModifyViewOpenTicketScreenState extends State<ModifyViewOpenTicketScreen> {
  bool isEditing = false;
  Map<String, String> originalValues = {};
  int _currentImagePage = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<OpenTicketViewModel>(context, listen: false);
      viewModel.fetchTicketDetails(widget.ticketId);
    });
  }

  void _showZoomableImageDialog(String imageUrl) {
    developer.log('[ModifyViewOpenTicketScreen] Showing zoomable image dialog for URL: $imageUrl', name: 'ModifyViewOpenTicketScreen');
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
                  errorWidget: (context, url, error) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image_outlined, size: 48, color: Colors.red),
                        const SizedBox(height: 8),
                        Text('Failed to load image: $url', style: TextStyle(color: Colors.red, fontSize: 16)),
                      ],
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

  Widget _buildImageSection(OpenTicketViewModel viewModel) {
    developer.log('[ModifyViewOpenTicketScreen] Building image section with capturedImageUrls: ${viewModel.capturedImageUrls}', name: 'ModifyViewOpenTicketScreen');
    if (viewModel.isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 150,
            color: Colors.grey.shade300,
          ),
        ),
      );
    }

    if (viewModel.capturedImageUrls == null || viewModel.capturedImageUrls!.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        child: SizedBox(
          height: 150,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: AppColors.primary),
                const SizedBox(height: 8),
                const Text(
                  'No Images Available',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final totalImages = viewModel.capturedImageUrls!.length;
    final totalPages = (totalImages / 3).ceil();
    final startIndex = _currentImagePage * 3;
    final endIndex = (startIndex + 3) > totalImages ? totalImages : (startIndex + 3);
    final currentImages = viewModel.capturedImageUrls!.sublist(startIndex, endIndex);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Captured Images',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: currentImages.length,
              itemBuilder: (context, index) {
                final imageUrl = currentImages[index];
                developer.log('[ModifyViewOpenTicketScreen] Rendering image at index $index (global: ${startIndex + index}) with URL: $imageUrl', name: 'ModifyViewOpenTicketScreen');
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Container(
                    width: AppConfig.deviceWidth / 3 - 16,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: GestureDetector(
                        onTap: () => _showZoomableImageDialog(imageUrl),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) {
                            developer.log('[ModifyViewOpenTicketScreen] Loading placeholder for image URL: $url', name: 'ModifyViewOpenTicketScreen');
                            return Shimmer.fromColors(
                              baseColor: Colors.grey.shade300,
                              highlightColor: Colors.grey.shade100,
                              child: Container(color: Colors.grey.shade300),
                            );
                          },
                          errorWidget: (context, url, error) {
                            developer.log('[ModifyViewOpenTicketScreen] Failed to load image URL: $url, Error: $error', name: 'ModifyViewOpenTicketScreen');
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.broken_image_outlined, size: 48, color: AppColors.primary),
                                  const SizedBox(height: 8),
                                  Text('Failed to load', style: TextStyle(color: Colors.red, fontSize: 12)),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_left),
                onPressed: _currentImagePage > 0
                    ? () {
                  setState(() {
                    _currentImagePage--;
                  });
                }
                    : null,
              ),
              Text(
                'Page ${_currentImagePage + 1} of $totalPages',
                style: const TextStyle(fontSize: 14),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_right),
                onPressed: _currentImagePage < totalPages - 1
                    ? () {
                  setState(() {
                    _currentImagePage++;
                  });
                }
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _storeOriginalValues(OpenTicketViewModel viewModel) {
    originalValues = {
      'floorId': viewModel.floorIdController.text,
      'slotId': viewModel.slotIdController.text,
      'vehicleNumber': viewModel.vehicleNumberController.text,
      'vehicleType': viewModel.vehicleTypeController.text,
    };
  }

  void _restoreOriginalValues(OpenTicketViewModel viewModel) {
    viewModel.floorIdController.text = originalValues['floorId'] ?? '';
    viewModel.slotIdController.text = originalValues['slotId'] ?? '';
    viewModel.vehicleNumberController.text = originalValues['vehicleNumber'] ?? '';
    viewModel.vehicleTypeController.text = originalValues['vehicleType'] ?? '';
    viewModel.selectedVehicleType = originalValues['vehicleType'];
    viewModel.resetErrors();
  }

  void _handleCancel() {
    final viewModel = Provider.of<OpenTicketViewModel>(context, listen: false);
    _restoreOriginalValues(viewModel);
    setState(() {
      isEditing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Changes discarded')),
    );
  }

  Future<void> _handleSave() async {
    if (!isEditing) return;

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
      Navigator.pop(context);
    } else if (mounted) {
      String errorMessage = viewModel.apiError ?? 'Failed to save changes';
      if (viewModel.error is HttpException) {
        final httpError = viewModel.error as HttpException;
        switch (httpError.statusCode) {
          case 400:
            errorMessage = 'Invalid request. Please check your input.';
            break;
          case 401:
            errorMessage = 'Unauthorized. Please log in again.';
            break;
          case 403:
            errorMessage = 'Access denied. You lack permission.';
            break;
          case 404:
            errorMessage = 'Ticket not found. It may have been deleted.';
            break;
          case 500:
            errorMessage = 'Server error. Please try again later.';
            break;
          default:
            errorMessage = httpError.serverMessage ?? 'Server error occurred';
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildReadOnlyField(String label, TextEditingController controller) {
    return CustomFormFields.normalSizedTextFormField(context:context,
      label: label,
      controller: controller,
      enabled: false,
      errorText: null,
      isPassword: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context); // Localization instance
    return Consumer<OpenTicketViewModel>(
      builder: (context, viewModel, child) {
        developer.log('[ModifyViewOpenTicketScreen] Building UI with capturedImageUrls: ${viewModel.capturedImageUrls}', name: 'ModifyViewOpenTicketScreen');
        return Scaffold(
          appBar: CustomAppBar.appBarWithNavigation(
            screenTitle: strings.titleModifyViewTicketDetails,
            onPressed: () => Navigator.pop(context),
            darkBackground: true, context: context,
          ),
          backgroundColor: AppColors.lightThemeBackground,
          body: Stack(
            children: [
              Center(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildImageSection(viewModel),
                      const SizedBox(height: 16),
                      _buildReadOnlyField('Ticket ID', viewModel.ticketRefIdController),
                      const SizedBox(height: 16),
                      _buildReadOnlyField('Plaza ID', viewModel.plazaIdController),
                      const SizedBox(height: 16),
                      _buildReadOnlyField('Entry Lane ID', viewModel.entryLaneIdController),
                      const SizedBox(height: 16),
                      _buildReadOnlyField('Entry Lane Direction', viewModel.entryLaneDirectionController),
                      const SizedBox(height: 16),
                      CustomFormFields.normalSizedTextFormField(context:context,
                        label: 'Floor ID',
                        controller: viewModel.floorIdController,
                        enabled: isEditing,
                        errorText: viewModel.floorIdError,
                        isPassword: false,
                      ),
                      const SizedBox(height: 16),
                      CustomFormFields.normalSizedTextFormField(context:context,
                        label: 'Slot ID',
                        controller: viewModel.slotIdController,
                        enabled: isEditing,
                        errorText: viewModel.slotIdError,
                        isPassword: false,
                      ),
                      const SizedBox(height: 16),
                      CustomFormFields.normalSizedTextFormField(context:context,
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
                        errorText: viewModel.vehicleTypeError, context: context,
                      ),
                      const SizedBox(height: 16),
                      _buildReadOnlyField('Vehicle Entry Timestamp', viewModel.vehicleEntryTimestampController),
                      const SizedBox(height: 16),
                      _buildReadOnlyField('Ticket Creation Time', viewModel.ticketCreationTimeController),
                      const SizedBox(height: 16),
                      _buildReadOnlyField('Ticket Status', viewModel.ticketStatusController),
                      if (viewModel.modificationTimeController.text.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildReadOnlyField('Modification Time', viewModel.modificationTimeController),
                      ],
                      const SizedBox(height: 80),
                    ],
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
                  onPressed: viewModel.isLoading ? null : _handleCancel,
                  heroTag: 'cancel',
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.close),
                ),
                const SizedBox(width: 16),
              ],
              FloatingActionButton(
                onPressed: viewModel.isLoading
                    ? null
                    : isEditing
                    ? _handleSave
                    : () {
                  _storeOriginalValues(viewModel);
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