import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_config.dart';
import 'package:merchant_app/utils/components/button.dart';
import 'package:provider/provider.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:merchant_app/utils/components/form_field.dart';
import 'package:shimmer/shimmer.dart';
import '../../../generated/l10n.dart';
import '../../../utils/exceptions.dart';
import '../../../viewmodels/ticket/reject_ticket_viewmodel.dart';
import 'dart:developer' as developer;

class ModifyViewRejectTicketScreen extends StatefulWidget {
  final String ticketId;

  const ModifyViewRejectTicketScreen({super.key, required this.ticketId});

  @override
  State<ModifyViewRejectTicketScreen> createState() =>
      _ModifyViewRejectTicketScreenState();
}

class _ModifyViewRejectTicketScreenState
    extends State<ModifyViewRejectTicketScreen> {
  int _currentImagePage = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel =
      Provider.of<RejectTicketViewModel>(context, listen: false);
      viewModel.fetchTicketDetails(widget.ticketId);
    });
  }

  void _showZoomableImageDialog(String imageUrl) {
    developer.log(
        '[ModifyViewRejectTicketScreen] Showing zoomable image dialog for URL: $imageUrl');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final strings = S.of(context);
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
                        const Icon(Icons.broken_image_outlined,
                            size: 48, color: Colors.red),
                        const SizedBox(height: 8),
                        Text(strings.errorImageLoadFailed,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 12)),
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

  void _showRemarksDialog(RejectTicketViewModel viewModel) {
    final strings = S.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(strings.buttonRejectTicket),
          content: CustomFormFields.largeSizedTextFormField(
              label: strings.labelRemarks,
              controller: viewModel.remarksController,
              enabled: true, context: context),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(strings.buttonCancel),
            ),
            TextButton(
              onPressed: () async {
                if (viewModel.validateForm()) {
                  Navigator.pop(context);
                  await _handleReject(viewModel);
                }
              },
              child: Text(strings.buttonSubmit),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleReject(RejectTicketViewModel viewModel) async {
    final strings = S.of(context);
    final success = await viewModel.rejectTicket();
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.messageTicketRejectedSuccess),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      String errorMessage =
          viewModel.apiError ?? strings.errorFailedToRejectTicket;
      if (viewModel.error is HttpException) {
        final httpError = viewModel.error as HttpException;
        errorMessage = httpError.statusCode == 404
            ? strings.errorTicketNotFound
            : httpError.serverMessage ?? strings.errorServerError;
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

  Widget _buildImageSection(RejectTicketViewModel viewModel) {
    final strings = S.of(context);
    developer.log(
        '[ModifyViewRejectTicketScreen] Building image section with capturedImageUrls: ${viewModel.capturedImageUrls}');
    if (viewModel.isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(height: 150, color: Colors.grey.shade300),
        ),
      );
    }

    if (viewModel.capturedImageUrls == null ||
        viewModel.capturedImageUrls!.isEmpty) {
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
                Text(strings.messageNoImagesAvailable,
                    style: const TextStyle(color: Colors.red, fontSize: 16)),
              ],
            ),
          ),
        ),
      );
    }

    final totalImages = viewModel.capturedImageUrls!.length;
    final totalPages = (totalImages / 3).ceil();
    final startIndex = _currentImagePage * 3;
    final endIndex =
    (startIndex + 3) > totalImages ? totalImages : (startIndex + 3);
    final currentImages =
    viewModel.capturedImageUrls!.sublist(startIndex, endIndex);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(strings.labelCapturedImages,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: currentImages.length,
              itemBuilder: (context, index) {
                final imageUrl = currentImages[index];
                developer.log(
                    '[ModifyViewRejectTicketScreen] Rendering image at index $index: $imageUrl');
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
                                Text(strings.errorImageLoadFailed,
                                    style: const TextStyle(
                                        color: Colors.red, fontSize: 12)),
                              ],
                            ),
                          ),
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
                    ? () => setState(() => _currentImagePage--)
                    : null,
              ),
              Text(
                  '${strings.labelPage} ${_currentImagePage + 1} ${strings.labelOf} $totalPages',
                  style: const TextStyle(fontSize: 14)),
              IconButton(
                icon: const Icon(Icons.arrow_right),
                onPressed: _currentImagePage < totalPages - 1
                    ? () => setState(() => _currentImagePage++)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField(String label, TextEditingController controller) {
    return CustomFormFields.normalSizedTextFormField(
      label: label,
      controller: controller,
      enabled: false,
      errorText: null,
      isPassword: false, context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    return Consumer<RejectTicketViewModel>(
      builder: (context, viewModel, child) {
        developer.log(
            '[ModifyViewRejectTicketScreen] Building UI with capturedImageUrls: ${viewModel.capturedImageUrls}');
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildImageSection(viewModel),
                        const SizedBox(height: 16),
                        _buildReadOnlyField(
                            strings.labelTicketId, viewModel.ticketIdController),
                        const SizedBox(height: 16),
                        _buildReadOnlyField(strings.labelTicketReferenceId,
                            viewModel.ticketRefIdController),
                        const SizedBox(height: 16),
                        _buildReadOnlyField(
                            strings.labelPlazaId, viewModel.plazaIdController),
                        const SizedBox(height: 16),
                        _buildReadOnlyField(strings.labelEntryLaneId,
                            viewModel.entryLaneIdController),
                        const SizedBox(height: 16),
                        _buildReadOnlyField(strings.labelEntryLaneDirection,
                            viewModel.entryLaneDirectionController),
                        const SizedBox(height: 16),
                        _buildReadOnlyField(
                            strings.labelFloorId, viewModel.floorIdController),
                        const SizedBox(height: 16),
                        _buildReadOnlyField(
                            strings.labelSlotId, viewModel.slotIdController),
                        const SizedBox(height: 16),
                        _buildReadOnlyField(strings.labelVehicleNumber,
                            viewModel.vehicleNumberController),
                        const SizedBox(height: 16),
                        _buildReadOnlyField(strings.labelVehicleType,
                            viewModel.vehicleTypeController),
                        const SizedBox(height: 16),
                        _buildReadOnlyField(strings.labelVehicleEntryTimestamp,
                            viewModel.entryTimeController),
                        const SizedBox(height: 16),
                        _buildReadOnlyField(strings.labelTicketCreationTime,
                            viewModel.ticketCreationTimeController),
                        const SizedBox(height: 16),
                        _buildReadOnlyField(strings.labelTicketStatus,
                            viewModel.ticketStatusController),
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
                      valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                ),
            ],
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomButtons.primaryButton(
              text: strings.buttonRejectTicket,
              onPressed: viewModel.isLoading
                  ? null
                  : () {
                viewModel.resetRemarks();
                _showRemarksDialog(viewModel);
              }, context: context,
            ),
          ),
        );
      },
    );
  }
}