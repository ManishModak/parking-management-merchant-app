import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/config/app_config.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:merchant_app/utils/components/button.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:developer' as developer;
import '../../../generated/l10n.dart';
import 'process_dispute_dialog.dart';
import '../../viewmodels/dispute/process_dispute_viewmodel.dart';

class ProcessDisputeDetailsScreen extends StatefulWidget {
  final String ticketId;

  const ProcessDisputeDetailsScreen({super.key, required this.ticketId});

  @override
  State<ProcessDisputeDetailsScreen> createState() =>
      _ProcessDisputeDetailsScreenState();
}

class _ProcessDisputeDetailsScreenState
    extends State<ProcessDisputeDetailsScreen> {
  int _currentImagePage = 0;
  bool _isImagesExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _fetchDisputeDetails();
    });
  }

  Future<void> _fetchDisputeDetails() async {
    final viewModel =
        Provider.of<ProcessDisputeViewModel>(context, listen: false);
    final strings = S.of(context);
    try {
      await viewModel.fetchDisputeDetails(widget.ticketId);
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(strings.errorLoadDisputeDetails, e.toString());
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
          onPressed: _fetchDisputeDetails,
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
            children: [
              InteractiveViewer(
                boundaryMargin: const EdgeInsets.all(20.0),
                minScale: 0.5,
                maxScale: 4.0,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => _buildShimmerPlaceholder(),
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

  Widget _buildLoadingState() {
    final strings = S.of(context);
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildShimmerPlaceholder(width: 24, height: 24),
                      const SizedBox(width: 12),
                      _buildShimmerPlaceholder(width: 150, height: 22),
                    ],
                  ),
                  _buildShimmerPlaceholder(width: 24, height: 24),
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
                      _buildShimmerPlaceholder(width: 140, height: 22),
                      _buildShimmerPlaceholder(width: 80, height: 18),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildShimmerFieldPair(strings.labelTicketId),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: _buildShimmerFieldPair(strings.labelPlazaName),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child:
                            _buildShimmerFieldPair(strings.labelVehicleNumber),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: _buildShimmerFieldPair(strings.labelVehicleType),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _buildShimmerFieldPair(strings.labelEntryTime),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: _buildShimmerFieldPair(strings.labelExitTime),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _buildShimmerFieldPair(strings.labelDuration),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child:
                            _buildShimmerFieldPair(strings.labelPaymentAmount),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _buildShimmerFieldPair(strings.labelFareType),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: _buildShimmerFieldPair(strings.labelFareRate),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _buildShimmerFieldPair(strings.labelPaymentDate),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: _buildShimmerFieldPair(
                            strings.labelDisputeExpiryDate),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child:
                            _buildShimmerFieldPair(strings.labelDisputeReason),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child:
                            _buildShimmerFieldPair(strings.labelDisputeAmount),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _buildShimmerFieldPair(strings.labelDisputeRemark),
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
                    height: 150,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: List.generate(
                        3,
                        (index) => Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: _buildShimmerPlaceholder(
                            width: (AppConfig.deviceWidth - 64) / 3,
                            height: 150,
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildShimmerPlaceholder(width: 110, height: 16),
          const SizedBox(height: 6),
          _buildShimmerPlaceholder(height: 22),
        ],
      ),
    );
  }

  Widget _buildImageSection(ProcessDisputeViewModel viewModel) {
    final strings = S.of(context);
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
        initiallyExpanded: false,
        onExpansionChanged: (expanded) =>
            setState(() => _isImagesExpanded = expanded),
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
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
                                        Text(
                                          strings.errorImageLoadFailed,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
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

  void _showAuditDetailsDialog(Map<String, dynamic> displayData) {
    final strings = S.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      strings.labelAuditDetails,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close,
                          color: Theme.of(context).colorScheme.onSurface),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 4),
                _buildDetailItem(
                  title: strings.labelDisputeRaisedBy,
                  value: displayData['disputeRaisedBy'] ?? strings.labelNA,
                ),
                _buildDetailItem(
                  title: strings.labelDisputeRaisedDate,
                  value: displayData['disputeRaisedDate'] ?? strings.labelNA,
                ),
                _buildDetailItem(
                  title: strings.labelDisputeProcessedBy,
                  value: displayData['disputeProcessedBy'] ?? strings.labelNA,
                ),
                _buildDetailItem(
                  title: strings.labelDisputeProcessedDate,
                  value: displayData['disputeProcessedDate'] ?? strings.labelNA,
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: CustomButtons.primaryButton(
                    text: strings.buttonClose,
                    onPressed: () => Navigator.of(context).pop(),
                    context: context,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDisputeDetailWithAuditLink(Map<String, dynamic> displayData) {
    final strings = S.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.labelDisputeInformation,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        GestureDetector(
          onTap: () => _showAuditDetailsDialog(displayData),
          child: Text(
            strings.labelAuditDetails,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                  decoration: TextDecoration.underline,
                ),
          ),
        ),
      ],
    );
  }

  List<String> _getCurrentImages(ProcessDisputeViewModel viewModel) {
    if (viewModel.capturedImageUrls == null ||
        viewModel.capturedImageUrls!.isEmpty) {
      return [];
    }
    final totalImages = viewModel.capturedImageUrls!.length;
    final startIndex = _currentImagePage * 3;
    final endIndex =
        (startIndex + 3) > totalImages ? totalImages : startIndex + 3;
    return viewModel.capturedImageUrls!.sublist(startIndex, endIndex);
  }

  int _getTotalPages(ProcessDisputeViewModel viewModel) {
    if (viewModel.capturedImageUrls == null ||
        viewModel.capturedImageUrls!.isEmpty) {
      return 0;
    }
    return (viewModel.capturedImageUrls!.length / 3).ceil();
  }

  Widget _buildDetailItem({
    required String title,
    required String value,
    bool highlight = false,
    bool isBadge = false,
  }) {
    final strings = S.of(context);
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
                        : Theme.of(context).colorScheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: value.toLowerCase() == 'open'
                          ? Colors.green
                          : Theme.of(context).colorScheme.error,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: value.toLowerCase() == 'open'
                              ? Colors.green
                              : Theme.of(context).colorScheme.error,
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
                                : Colors.red)
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
    required Widget title,
    required List<Widget> children,
    Widget? trailing,
  }) {
    return Card(
      elevation: Theme.of(context).cardTheme.elevation,
      margin: Theme.of(context).cardTheme.margin,
      shape: Theme.of(context).cardTheme.shape,
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                title,
                if (trailing != null) trailing,
              ],
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(ProcessDisputeViewModel viewModel) {
    final strings = S.of(context);
    if (viewModel.dispute == null) {
      return const SizedBox.shrink();
    }

    final bool canProcess = viewModel.dispute!.status.toLowerCase() == 'open';

    return Card(
      elevation: Theme.of(context).cardTheme.elevation,
      margin: Theme.of(context).cardTheme.margin,
      shape: Theme.of(context).cardTheme.shape,
      color: Theme.of(context).cardColor,
      child: InkWell(
        onTap: canProcess ? () => _handleActionButtonTap(viewModel) : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.fact_check_outlined,
                    color: canProcess
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.5),
                    size: Theme.of(context).iconTheme.size,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    strings.buttonProcessDispute,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: canProcess
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.5),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              Icon(
                Icons.chevron_right,
                color: canProcess
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                size: Theme.of(context).iconTheme.size,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleActionButtonTap(ProcessDisputeViewModel viewModel) {
    developer.log('Showing dispute dialog', name: 'Navigation');
    showDialog(
      context: context,
      builder: (context) => ChangeNotifierProvider.value(
        value: viewModel,
        child: ProcessDisputeDialog(ticketId: widget.ticketId),
      ),
    );
  }

  PreferredSizeWidget _buildCustomAppBar(ProcessDisputeViewModel viewModel) {
    final strings = S.of(context);
    final displayData = viewModel.getDisputeDisplayData();
    return CustomAppBar.appBarWithNavigation(
      screenTitle: viewModel.dispute == null
          ? "${strings.titleProcessingDispute}\n${strings.labelLoading}"
          : "${strings.labelTicket} #${displayData['ticketRefId']}\n${strings.labelStatus}: ${displayData['disputeStatus']}",
      onPressed: () => Navigator.pop(context),
      darkBackground: Theme.of(context).brightness == Brightness.dark,
      fontSize: 14,
      centreTitle: false,
      context: context,
    );
  }

  Widget _buildErrorContent(ProcessDisputeViewModel viewModel) {
    final strings = S.of(context);
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
              viewModel.error.toString(),
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
              onPressed: _fetchDisputeDetails,
              context: context,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisputeDetails(ProcessDisputeViewModel viewModel) {
    final strings = S.of(context);
    if (viewModel.dispute == null) {
      return Center(
          child: Text(
        strings.messageNoDisputeData,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
      ));
    }

    final displayData = viewModel.getDisputeDisplayData();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          _buildActionButton(viewModel),
          _buildCompactSection(
            title: _buildDisputeDetailWithAuditLink(displayData),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(displayData['disputeStatus'])
                    .withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getStatusColor(displayData['disputeStatus']),
                  width: 1.5,
                ),
              ),
              child: Text(
                displayData['disputeStatus'],
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: _getStatusColor(displayData['disputeStatus']),
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      title: strings.labelTicketId,
                      value: displayData['ticketId'] ?? strings.labelNA,
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      title: strings.labelPlazaName,
                      value: displayData['plazaName'] ?? strings.labelNA,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      title: strings.labelVehicleNumber,
                      value: displayData['vehicleNumber'] ?? strings.labelNA,
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      title: strings.labelVehicleType,
                      value: displayData['vehicleType'] ?? strings.labelNA,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      title: strings.labelEntryTime,
                      value: displayData['vehicleEntryTime'] ?? strings.labelNA,
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      title: strings.labelExitTime,
                      value: displayData['vehicleExitTime'] ?? strings.labelNA,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      title: strings.labelDuration,
                      value: displayData['parkingDuration'] ?? strings.labelNA,
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      title: strings.labelPaymentAmount,
                      value: displayData['paymentAmount'] ?? strings.labelNA,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      title: strings.labelFareType,
                      value: displayData['fareType'] ?? strings.labelNA,
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      title: strings.labelFareRate,
                      value: displayData['fareAmount'] ?? strings.labelNA,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      title: strings.labelPaymentDate,
                      value: displayData['paymentDate'] ?? strings.labelNA,
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      title: strings.labelDisputeExpiryDate,
                      value:
                          displayData['disputeExpiryDate'] ?? strings.labelNA,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      title: strings.labelDisputeReason,
                      value: displayData['disputeReason'] ?? strings.labelNA,
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      title: strings.labelDisputeAmount,
                      value: displayData['disputeAmount'] ?? strings.labelNA,
                    ),
                  ),
                ],
              ),
              _buildDetailItem(
                title: strings.labelDisputeRemark,
                value: displayData['disputeRemark'] ?? strings.labelNA,
              ),
            ],
          ),
          _buildImageSection(viewModel),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return Colors.green;
      case 'inprogress':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'rejected':
        return Colors.red;
      default:
        return Theme.of(context).colorScheme.onSurface.withOpacity(0.6);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProcessDisputeViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: _buildCustomAppBar(viewModel),
          body: RefreshIndicator(
            onRefresh: _fetchDisputeDetails,
            child: viewModel.isLoading
                ? _buildLoadingState()
                : viewModel.error != null
                    ? _buildErrorContent(viewModel)
                    : _buildDisputeDetails(viewModel),
          ),
        );
      },
    );
  }
}
