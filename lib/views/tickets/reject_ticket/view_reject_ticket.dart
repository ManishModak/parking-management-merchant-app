import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_config.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:merchant_app/utils/components/button.dart';
import 'package:merchant_app/utils/components/form_field.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../generated/l10n.dart';
import '../../../viewmodels/ticket/reject_ticket_viewmodel.dart';

class ViewRejectTicketScreen extends StatefulWidget {
  final String ticketId;

  const ViewRejectTicketScreen({super.key, required this.ticketId});

  @override
  State<ViewRejectTicketScreen> createState() => _ViewRejectTicketScreenState();
}

class _ViewRejectTicketScreenState extends State<ViewRejectTicketScreen> {
  int _currentImagePage = 0;
  bool _isImagesExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchTicketDetails();
    });
  }

  Future<void> _fetchTicketDetails() async {
    final viewModel =
        Provider.of<RejectTicketViewModel>(context, listen: false);
    final strings = S.of(context);
    try {
      await viewModel.fetchTicketDetails(widget.ticketId);
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(strings.errorLoadTicketDetails, e.toString());
      }
    }
  }

  void _showErrorSnackBar(String message, String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$message: $error',
            style: Theme.of(context).snackBarTheme.contentTextStyle),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).snackBarTheme.backgroundColor,
        action: SnackBarAction(
          label: S.of(context).buttonRetry,
          textColor: Theme.of(context).colorScheme.onSurface,
          onPressed: _fetchTicketDetails,
        ),
      ),
    );
  }

  void _showZoomableImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(10),
          child: Stack(
            alignment: Alignment.center,
            children: [
              InteractiveViewer(
                boundaryMargin: const EdgeInsets.all(20.0),
                minScale: 0.5,
                maxScale: 4.0,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) =>
                      _buildShimmerPlaceholder(height: 300),
                  errorWidget: (context, url, error) => Center(
                    child: Icon(Icons.broken_image_outlined,
                        size: 48, color: Theme.of(context).colorScheme.error),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: Icon(Icons.close,
                      color: Theme.of(context).colorScheme.onPrimary),
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
        return Dialog(
          child: SizedBox(
            width: AppConfig.deviceWidth * 0.9,
            height: 300,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomFormFields.largeSizedTextFormField(
                    label: strings.labelRemarks,
                    controller: viewModel.remarksController,
                    enabled: true,
                    context: context,
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
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
                  )
                ],
              ),
            ),
          ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildShimmerPlaceholder(
      {double width = double.infinity, double height = 20}) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBaseLight,
      highlightColor: AppColors.shimmerHighlightLight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildLoadingState(S strings) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Card(
            elevation: Theme.of(context).cardTheme.elevation,
            margin: Theme.of(context).cardTheme.margin,
            shape: Theme.of(context).cardTheme.shape,
            color: Theme.of(context).cardColor,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildShimmerPlaceholder(width: 180, height: 24),
                      _buildShimmerPlaceholder(width: 100, height: 30),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                          child: _buildShimmerFieldPair(
                              strings.labelVehicleNumber)),
                      const SizedBox(width: 20),
                      Expanded(
                          child:
                              _buildShimmerFieldPair(strings.labelVehicleType)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                          child:
                              _buildShimmerFieldPair(strings.labelPlazaName)),
                      const SizedBox(width: 20),
                      Expanded(
                          child:
                              _buildShimmerFieldPair(strings.labelEntryLaneId)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                          child:
                              _buildShimmerFieldPair(strings.labelEntryTime)),
                      const SizedBox(width: 20),
                      Expanded(
                          child: _buildShimmerFieldPair(strings.labelFloorId)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Card(
            elevation: Theme.of(context).cardTheme.elevation,
            margin: Theme.of(context).cardTheme.margin,
            shape: Theme.of(context).cardTheme.shape,
            color: Theme.of(context).cardColor,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildShimmerPlaceholder(width: 140, height: 24),
                      _buildShimmerPlaceholder(width: 30, height: 24),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 140,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: List.generate(
                        3,
                        (index) => Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: _buildShimmerPlaceholder(
                            width: (AppConfig.deviceWidth - 70) / 3,
                            height: 140,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerFieldPair(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildShimmerPlaceholder(width: 110, height: 16),
        const SizedBox(height: 10),
        _buildShimmerPlaceholder(height: 22),
      ],
    );
  }

  Widget _buildImageSection(RejectTicketViewModel viewModel, S strings) {
    return Card(
      elevation: Theme.of(context).cardTheme.elevation,
      margin: Theme.of(context).cardTheme.margin,
      shape: Theme.of(context).cardTheme.shape,
      color: Theme.of(context).cardColor,
      child: ExpansionTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              strings.labelUploadedDocuments,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            if (viewModel.capturedImageUrls != null &&
                viewModel.capturedImageUrls!.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${viewModel.capturedImageUrls!.length}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
          ],
        ),
        initiallyExpanded: true,
        onExpansionChanged: (expanded) =>
            setState(() => _isImagesExpanded = expanded),
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (viewModel.capturedImageUrls == null ||
                    viewModel.capturedImageUrls!.isEmpty)
                  SizedBox(
                    height: 150,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_not_supported,
                              size: 48,
                              color: Theme.of(context).colorScheme.primary),
                          const SizedBox(height: 8),
                          Text(
                            strings.messageNoImagesAvailable,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.6),
                                ),
                          ),
                        ],
                      ),
                    ),
                  )
                else ...[
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _getCurrentImages(viewModel).length,
                      itemBuilder: (context, index) {
                        final imageUrl = _getCurrentImages(viewModel)[index];
                        final imageWidth = (AppConfig.deviceWidth - 64) / 3;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Container(
                            width: imageWidth,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Theme.of(context).colorScheme.primary),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(11),
                              child: GestureDetector(
                                onTap: () => _showZoomableImageDialog(imageUrl),
                                child: CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      _buildShimmerPlaceholder(
                                          width: imageWidth, height: 150),
                                  errorWidget: (context, url, error) => Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.broken_image_outlined,
                                            size: 32,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withOpacity(0.6)),
                                        const SizedBox(height: 8),
                                        Text(strings.errorImageLoadFailed,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface
                                                      .withOpacity(0.6),
                                                )),
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
                  if (_getTotalPages(viewModel) > 1) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios, size: 18),
                          color: _currentImagePage > 0
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.5),
                          onPressed: _currentImagePage > 0
                              ? () => setState(() => _currentImagePage--)
                              : null,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${strings.labelPage} ${_currentImagePage + 1} ${strings.labelOf} ${_getTotalPages(viewModel)}',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios, size: 18),
                          color:
                              _currentImagePage < _getTotalPages(viewModel) - 1
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.5),
                          onPressed:
                              _currentImagePage < _getTotalPages(viewModel) - 1
                                  ? () => setState(() => _currentImagePage++)
                                  : null,
                        ),
                      ],
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getCurrentImages(RejectTicketViewModel viewModel) {
    if (viewModel.capturedImageUrls == null ||
        viewModel.capturedImageUrls!.isEmpty) {
      return [];
    }
    final startIndex = _currentImagePage * 3;
    final endIndex =
        (startIndex + 3).clamp(0, viewModel.capturedImageUrls!.length);
    return viewModel.capturedImageUrls!.sublist(startIndex, endIndex);
  }

  int _getTotalPages(RejectTicketViewModel viewModel) {
    if (viewModel.capturedImageUrls == null ||
        viewModel.capturedImageUrls!.isEmpty) {
      return 0;
    }
    return (viewModel.capturedImageUrls!.length / 3).ceil();
  }

  Widget _buildActionButton(RejectTicketViewModel viewModel, S strings) {
    if (viewModel.ticket == null) return const SizedBox.shrink();

    return Card(
      elevation: Theme.of(context).cardTheme.elevation,
      margin: Theme.of(context).cardTheme.margin,
      shape: Theme.of(context).cardTheme.shape,
      color: Theme.of(context).cardColor,
      child: InkWell(
        onTap: viewModel.isLoading
            ? null
            : () {
                viewModel.resetRemarks();
                _showRemarksDialog(viewModel);
              },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.cancel,
                      color: Theme.of(context).colorScheme.error),
                  const SizedBox(width: 12),
                  Text(
                    strings.buttonRejectTicket,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              Icon(Icons.chevron_right,
                  color: Theme.of(context).colorScheme.error),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required String title,
    required String value,
    bool highlight = false,
    bool isBadge = false,
    required S strings,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          isBadge
              ? Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: value.toLowerCase() == 'open'
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: value.toLowerCase() == 'open'
                          ? Colors.green
                          : Colors.orange,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: value.toLowerCase() == 'open'
                              ? Colors.green
                              : Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                )
              : Text(
                  value.isEmpty ? strings.labelNA : value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight:
                            highlight ? FontWeight.bold : FontWeight.normal,
                        color: highlight
                            ? (value.toLowerCase() == 'open'
                                ? Colors.green
                                : Colors.orange)
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.9),
                      ),
                ),
        ],
      ),
    );
  }

  Widget _buildCompactSection({
    required String title,
    required List<Widget> children,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: Theme.of(context).cardTheme.elevation,
      margin: Theme.of(context).cardTheme.margin,
      shape: Theme.of(context).cardTheme.shape,
      color: Theme.of(context).cardColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (trailing != null) trailing,
                ],
              ),
              const SizedBox(height: 8),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildCustomAppBar(
      RejectTicketViewModel viewModel, S strings) {
    return CustomAppBar.appBarWithNavigation(
      screenTitle: viewModel.ticket == null
          ? "${strings.titleModifyViewTicketDetails}\n${strings.labelLoading}"
          : "${strings.titleModifyViewTicketDetails} #${viewModel.ticket!.ticketRefId ?? strings.labelNA}",
      onPressed: () => Navigator.pop(context),
      darkBackground: Theme.of(context).brightness == Brightness.dark,
      fontSize: 14,
      centreTitle: false,
      context: context,
    );
  }

  Widget _buildErrorContent(RejectTicketViewModel viewModel, S strings) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                size: 48, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text(
              strings.errorGeneric,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              viewModel.apiError ?? strings.errorFailedToRejectTicket,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            CustomButtons.primaryButton(
              text: strings.buttonRetry,
              onPressed: _fetchTicketDetails,
              context: context,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketDetails(RejectTicketViewModel viewModel, S strings) {
    if (viewModel.ticket == null) return const SizedBox.shrink();
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          _buildCompactSection(
            title: strings.labelTicketDetails,
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange, width: 1.5),
              ),
              child: Text(
                viewModel.ticketStatusController.text.isEmpty
                    ? strings.labelNA
                    : viewModel.ticketStatusController.text,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      title: strings.labelVehicleNumber,
                      value: viewModel.vehicleNumberController.text,
                      strings: strings,
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      title: strings.labelVehicleType,
                      value: viewModel.vehicleTypeController.text,
                      strings: strings,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      title: strings.labelPlazaName,
                      value: viewModel.plazaNameController.text,
                      strings: strings,
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      title: strings.labelEntryLaneId,
                      value: viewModel.entryLaneIdController.text,
                      strings: strings,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      title: strings.labelEntryTime,
                      value: viewModel.entryTimeController.text,
                      strings: strings,
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      title: strings.labelFloorId,
                      value: viewModel.floorIdController.text,
                      strings: strings,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      title: strings.labelSlotId,
                      value: viewModel.slotIdController.text,
                      strings: strings,
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      title: strings.labelEntryLaneDirection,
                      value: viewModel.entryLaneDirectionController.text,
                      strings: strings,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      title: strings.labelTicketCreationTime,
                      value: viewModel.ticketCreationTimeController.text,
                      strings: strings,
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      title: strings.labelTicketStatus,
                      value: viewModel.ticketStatusController.text,
                      strings: strings,
                    ),
                  ),
                ],
              ),
            ],
          ),
          _buildImageSection(viewModel, strings),
          _buildActionButton(viewModel, strings),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    return Consumer<RejectTicketViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: _buildCustomAppBar(viewModel, strings),
          body: RefreshIndicator(
            onRefresh: _fetchTicketDetails,
            child: viewModel.isLoading
                ? _buildLoadingState(strings)
                : viewModel.apiError != null
                    ? _buildErrorContent(viewModel, strings)
                    : _buildTicketDetails(viewModel, strings),
          ),
        );
      },
    );
  }
}
