import 'dart:developer' as developer;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
// import 'package:intl/intl.dart'; // Keep for other formatting if needed, but not for entry/exit time here
import 'package:merchant_app/config/api_config.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/app_config.dart';
import '../../../../utils/components/appbar.dart';
import '../../../../utils/components/button.dart';
import '../../../services/payment/payment_service.dart';
import '../../../viewmodels/ticket/mark_exit_viewmodel.dart';
import '../../../../generated/l10n.dart';

class MarkExitDetailsScreen extends StatefulWidget {
  final String ticketId;

  const MarkExitDetailsScreen({super.key, required this.ticketId});

  @override
  State<MarkExitDetailsScreen> createState() => _MarkExitDetailsScreenState();
}

class _MarkExitDetailsScreenState extends State<MarkExitDetailsScreen> {
  int _currentImagePage = 0;
  // bool _isImagesExpanded = false; // Not used, can be removed if not needed
  bool _isNfcSupported = false;
  bool _isNfcEnabled = false;
  final PaymentService _paymentService =
      PaymentService(); // Instantiate PaymentService

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _markTicketAsExited();
      _checkNfcStatus();
      final viewModel = Provider.of<MarkExitViewModel>(context, listen: false);
      // Ensure ApiConfig.baseUrl does not end with a slash if socket URL needs specific format
      String socketBaseUrl = ApiConfig.baseUrl;
      if (socketBaseUrl.endsWith('/')) {
        socketBaseUrl = socketBaseUrl.substring(0, socketBaseUrl.length - 1);
      }
      viewModel.initializeSocket('user-${widget.ticketId}', socketBaseUrl);
    });
  }

  Future<void> _checkNfcStatus() async {
    try {
      final isAvailable = await NfcManager.instance.isAvailable();
      if (mounted) {
        setState(() {
          _isNfcSupported = isAvailable;
          _isNfcEnabled =
              isAvailable; // Assuming if available, it's enabled initially
        });
      }
      developer.log(
          isAvailable
              ? 'NFC is supported'
              : 'NFC not supported', // Simplified log
          name: 'NFC Check');
    } catch (e) {
      developer.log('NFC check error: $e', name: 'NFC Check');
      if (mounted) {
        setState(() {
          _isNfcSupported = false;
          _isNfcEnabled = false;
        });
      }
    }
  }

  Future<void> _markTicketAsExited() async {
    final viewModel = Provider.of<MarkExitViewModel>(context, listen: false);
    final strings = S.of(context);
    try {
      await viewModel.markTicketAsExited(widget.ticketId);
      if (viewModel.error != null && mounted) {
        // Check for error after marking
        String errorMessage;
        if (viewModel.apiError == 'errorFareNotConfigured') {
          errorMessage = strings.errorFareNotConfigured;
        } else {
          errorMessage = '${strings.errorMarkExitFailed}: ${viewModel.apiError ?? viewModel.error.toString()}';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      // This catch might be redundant if viewModel handles and sets its error state
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${strings.errorMarkExitFailed}: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    // ViewModel's dispose handles socket disconnection
    // Let the Provider handle the disposal of the ViewModel
    super.dispose();
  }

  void _showZoomableImageDialog(String imageUrl) {
    developer.log('Showing zoomable image dialog for URL: $imageUrl',
        name: 'MarkExitDetailsScreen');
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
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimaryContainer), // Adjusted for visibility
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
      baseColor: Theme.of(context).brightness == Brightness.light
          ? AppColors.shimmerBaseLight
          : AppColors.shimmerBaseDark,
      highlightColor: Theme.of(context).brightness == Brightness.light
          ? AppColors.shimmerHighlightLight
          : AppColors.shimmerHighlightDark,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Theme.of(context)
              .cardColor, // Use cardColor for shimmer bg consistency
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
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildShimmerPlaceholder(width: 140, height: 24),
                      _buildShimmerPlaceholder(width: 80, height: 18),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                          child: _buildShimmerFieldPair(strings.ticketIdLabel)),
                      const SizedBox(width: 24),
                      Expanded(
                          child: _buildShimmerFieldPair(strings.labelFloorId)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                          child: _buildShimmerFieldPair(strings.labelSlotId)),
                      const SizedBox(width: 24),
                      Expanded(
                          child: _buildShimmerFieldPair(
                              strings.labelVehicleNumber)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                          child:
                              _buildShimmerFieldPair(strings.labelVehicleType)),
                      const SizedBox(width: 24),
                      Expanded(
                          child:
                              _buildShimmerFieldPair(strings.labelEntryLane)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                          child: _buildShimmerFieldPair(strings.labelExitLane)),
                      const SizedBox(width: 24),
                      Expanded(
                          child:
                              _buildShimmerFieldPair(strings.labelEntryTime)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                          child: _buildShimmerFieldPair(strings.labelExitTime)),
                      const SizedBox(width: 24),
                      Expanded(
                          child: _buildShimmerFieldPair(strings.labelDuration)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                          child: _buildShimmerFieldPair(strings.labelFareType)),
                      const SizedBox(width: 24),
                      Expanded(
                          child: _buildShimmerFieldPair(strings.labelFareRate)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                          child: _buildShimmerFieldPair(
                              strings.labelTotalCharges)),
                      const SizedBox(width: 24),
                      Expanded(
                          child: _buildShimmerFieldPair(
                              strings.labelPaymentStatus)),
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
              padding: const EdgeInsets.all(12.0),
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
                            width: (AppConfig.deviceWidth - 64) /
                                3, // Use context for AppConfig
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
          Card(
            elevation: Theme.of(context).cardTheme.elevation,
            margin: Theme.of(context).cardTheme.margin,
            shape: Theme.of(context).cardTheme.shape,
            color: Theme.of(context).cardColor,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  _buildShimmerOptionRow(),
                  _buildShimmerOptionRow(),
                  _buildShimmerOptionRow(),
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

  Widget _buildShimmerOptionRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _buildShimmerPlaceholder(width: 24, height: 24),
              const SizedBox(width: 12),
              _buildShimmerPlaceholder(width: 120, height: 22),
            ],
          ),
          _buildShimmerPlaceholder(width: 24, height: 24),
        ],
      ),
    );
  }

  Widget _buildImageSection(MarkExitViewModel viewModel, S strings) {
    final capturedImageUrls =
        viewModel.ticketDetails?['captured_images'] as List<String>? ?? [];
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
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            if (capturedImageUrls.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${capturedImageUrls.length}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
          ],
        ),
        initiallyExpanded: false, // Default to collapsed
        onExpansionChanged: (expanded) => setState(() {
          /* _isImagesExpanded = expanded; */
        }), // Not used, can remove state var
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
                if (capturedImageUrls.isEmpty)
                  SizedBox(
                    height: 150,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_not_supported_outlined,
                              size: 48,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant
                                  .withOpacity(0.6)),
                          const SizedBox(height: 8),
                          Text(
                            strings.messageNoImagesAvailable,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant
                                      .withOpacity(0.6),
                                ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _getCurrentImages(capturedImageUrls).length,
                      itemBuilder: (context, index) {
                        final imageUrl =
                            _getCurrentImages(capturedImageUrls)[index];
                        final imageWidth =
                            (AppConfig.deviceWidth - 64) / 3; // Use context
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Container(
                            width: imageWidth,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outline
                                      .withOpacity(0.5)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(11),
                              child: GestureDetector(
                                onTap: () => _showZoomableImageDialog(imageUrl),
                                child: CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  fit: BoxFit.cover,
                                  memCacheWidth: 300,
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
                                                .error),
                                        const SizedBox(height: 4),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4.0),
                                          child: Text(
                                            strings.errorImageLoadFailed,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .error,
                                                ),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
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
                if (_getTotalPages(capturedImageUrls) > 1) ...[
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
                          '${strings.labelPage} ${_currentImagePage + 1} ${strings.labelOf} ${_getTotalPages(capturedImageUrls)}',
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
                        color: _currentImagePage <
                                _getTotalPages(capturedImageUrls) - 1
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.5),
                        onPressed: _currentImagePage <
                                _getTotalPages(capturedImageUrls) - 1
                            ? () => setState(() => _currentImagePage++)
                            : null,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getCurrentImages(List<String> capturedImageUrls) {
    if (capturedImageUrls.isEmpty) return [];
    final startIndex = _currentImagePage * 3;
    final endIndex = (startIndex + 3).clamp(0, capturedImageUrls.length);
    return capturedImageUrls.sublist(startIndex, endIndex);
  }

  int _getTotalPages(List<String> capturedImageUrls) {
    if (capturedImageUrls.isEmpty) return 0;
    return (capturedImageUrls.length / 3).ceil();
  }

  Widget _buildErrorState(MarkExitViewModel viewModel, S strings) {
    final isFareNotConfigured = viewModel.apiError == 'errorFareNotConfigured';
    
    return Center(
      child: SingleChildScrollView(
        // Added SingleChildScrollView for smaller screens
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                size: 48, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text(
              strings.errorFailedToMarkExit, // More specific error title
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isFareNotConfigured
                  ? strings.errorFareNotConfigured
                  : (viewModel.apiError ??
                      viewModel.error?.toString() ??
                      strings.errorUnknown),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (isFareNotConfigured) ...[
              // For fare configuration errors, show both retry and configure options
              CustomButtons.primaryButton(
                width: 200,
                height: 40,
                text: strings.buttonRetry,
                onPressed: _markTicketAsExited,
                context: context,
              ),
              const SizedBox(height: 12),
              Text(
                strings.labelOr,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.5),
                    ),
              ),
              const SizedBox(height: 12),
              CustomButtons.secondaryButton(
                width: 200,
                height: 40,
                text: strings.buttonConfigureFare,
                onPressed: () {
                  // Navigate to fare configuration screen
                  Navigator.pop(context); // Go back to previous screen
                  // You can add navigation to fare configuration here if needed
                },
                context: context,
              ),
            ] else ...[
              // For other errors, just show retry button
              CustomButtons.primaryButton(
                width: 150,
                height: 40,
                text: strings.buttonRetry,
                onPressed: _markTicketAsExited,
                context: context,
              ),
            ],
          ],
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
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withOpacity(0.8), // Adjusted for better contrast
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 4),
          isBadge
              ? Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: value.toLowerCase() == 'open' // Example badge logic
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
                            ? (value.toLowerCase() == 'success'
                                ? Colors.green.shade700
                                : (value.toLowerCase() == 'pending'
                                    ? Colors.orange.shade700
                                    : Colors.red
                                        .shade700)) // Adjusted highlight colors
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
                Expanded(child: title), // Ensure title can expand
                if (trailing != null)
                  Flexible(child: trailing), // Allow trailing to take space
              ],
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTicketDetails(MarkExitViewModel viewModel, S strings) {
    final ticketData = viewModel.ticketDetails ?? {};
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          _buildCompactSection(
            title: Text(
              strings.labelTicketInformation,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: (ticketData['status']?.toString().toLowerCase() ==
                            'open' // Defensive toString
                        ? AppColors.successLight // Use AppColors
                        : AppColors.warningLight)
                    .withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color:
                      ticketData['status']?.toString().toLowerCase() == 'open'
                          ? AppColors.successDark
                          : AppColors.warningDark,
                  width: 1.5,
                ),
              ),
              child: Text(
                ticketData['status']?.toString() ?? strings.labelNA,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: ticketData['status']?.toString().toLowerCase() ==
                              'open'
                          ? AppColors.successDark
                          : AppColors.warningDark,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      title: strings.ticketIdLabel,
                      value: ticketData['ticket_ref_id']?.toString() ??
                          strings.labelNA,
                      strings: strings,
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      title: strings.labelFloorId,
                      value:
                          ticketData['floor_id']?.toString() ?? strings.labelNA,
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
                      value:
                          ticketData['slot_id']?.toString() ?? strings.labelNA,
                      strings: strings,
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      title: strings.labelVehicleNumber,
                      value: ticketData['vehicle_number']?.toString() ??
                          strings.labelNA,
                      strings: strings,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      title: strings.labelVehicleType,
                      value: ticketData['vehicle_type']?.toString() ??
                          strings.labelNA,
                      strings: strings,
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      title: strings.labelEntryLane,
                      value: ticketData['entry_lane_id']?.toString() ??
                          strings.labelNA,
                      strings: strings,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      title: strings.labelExitLane,
                      value: ticketData['exit_lane_id']?.toString() ??
                          strings.labelNotFilled,
                      strings: strings,
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      title: strings.labelEntryTime,
                      // USE THE FORMATTED GETTER FROM VIEWMODEL
                      value: viewModel.getFormattedEntryTime(),
                      strings: strings,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      title: strings.labelExitTime,
                      // USE THE FORMATTED GETTER FROM VIEWMODEL
                      value: viewModel.getFormattedExitTime(),
                      strings: strings,
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      title: strings.labelDuration,
                      value: ticketData['parking_duration']?.toString() ??
                          strings.labelCalculating,
                      strings: strings,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      title: strings.labelFareType,
                      value: ticketData['fare_type']?.toString() ??
                          strings.labelPending,
                      strings: strings,
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      title: strings.labelFareRate,
                      value: ticketData['fare_amount']?.toString() ??
                          strings.labelPending,
                      strings: strings,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      title: strings.labelTotalCharges,
                      value: ticketData['total_charges']?.toString() ??
                          strings.labelPending,
                      strings: strings,
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      title: strings.labelPaymentStatus,
                      value: viewModel.paymentStatus?.toString() ??
                          strings.labelPending,
                      highlight: true,
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

  /// START: NEW DIALOG WIDGET
  Future<bool?> _showCashPaymentDialog(
      BuildContext context, String totalCharges, S strings) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // User must interact with the dialog
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          icon: Icon(Icons.money_outlined,
              color: Theme.of(context).colorScheme.primary, size: 48),
          title: Text(strings.buttonPayCash,
              style: Theme.of(context).textTheme.titleLarge),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                strings.messageCollectCashConfirmation,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text(
                '₹ $totalCharges', // Assuming INR currency symbol
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: <Widget>[
            SizedBox(
              width: double.infinity,
              child: CustomButtons.primaryButton(
                text: strings.buttonDone,
                onPressed: () {
                  Navigator.of(dialogContext).pop(true);
                  //Navigator.pushReplacement(context, newRoute)
                },
                context: context,
              ),
            ),
          ],
        );
      },
    );
  }

  /// END: NEW DIALOG WIDGET

  Widget _buildActionButton(MarkExitViewModel viewModel, S strings) {
    final ticketData = viewModel.ticketDetails ?? {};
    final totalChargesStr = ticketData['total_charges']?.toString() ?? '0';
    final totalCharges = double.tryParse(totalChargesStr) ?? 0.0;

    void initiateUpiPayment() async {
      if (totalCharges <= 0) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings.errorInvalidAmount),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }

      try {
        developer.log('Generating QR code for ticket: ${widget.ticketId}',
            name: 'MarkExitDetailsScreen');
        final qrCodeResponse =
            await _paymentService.createOrderQrCode(widget.ticketId);
        developer.log('QR Code Response: $qrCodeResponse',
            name: 'MarkExitDetailsScreen');
        final qrCodeUrl = qrCodeResponse['qrUrl']?.toString() ?? '';

        if (qrCodeUrl.isEmpty) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(strings.errorQrCodeFailed),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
          return;
        }
        if (!mounted) return;
        _showZoomableImageDialog(qrCodeUrl);
      } catch (e) {
        developer.log('Error generating QR code: $e',
            name: 'MarkExitDetailsScreen');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${strings.errorQrCodeFailed}: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }

    void initiateNfcCardPayment() async {
      if (!_isNfcSupported) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings.errorNfcNotSupported),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }

      try {
        bool isSessionOpen = false;
        await NfcManager.instance.startSession(
          pollingOptions: {
            NfcPollingOption.iso14443, // For EMV cards (NFC-A and NFC-B)
            NfcPollingOption.iso15693, // Optional: For NFC-V tags, if needed
          },
          alertMessageIos:
              strings.messageNfcScanPrompt, // iOS: Prompt user to scan
          noPlatformSoundsAndroid: true, // Android: Disable platform sounds
          invalidateAfterFirstReadIos: true, // iOS: Stop after first tag read
          onDiscovered: (NfcTag tag) async {
            isSessionOpen = true;
            developer.log('NFC Tag Discovered: ${tag.data}',
                name: 'MarkExitDetailsScreen');

            // Cast tag.data to Map<String, dynamic> for type safety
            final tagData = tag.data as Map<String, dynamic>;

            // Check for supported tag types (e.g., isodep for EMV cards)
            if (tagData.containsKey('isodep') ||
                tagData.containsKey('mifareclassic') ||
                tagData.containsKey('nfca')) {
              // Placeholder for EMV card processing
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(strings.messageEmvCardDetected),
                    backgroundColor: Colors.green,
                  ),
                );
              }
              // TODO: Implement actual EMV payment processing with a payment SDK
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(strings.errorUnsupportedCard),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              }
            }

            // Stop session after processing
            try {
              await NfcManager.instance.stopSession();
              isSessionOpen = false;
              developer.log('NFC Session stopped after discovery.',
                  name: 'MarkExitDetailsScreen');
            } catch (e) {
              developer.log('Error stopping NFC session after discovery: $e',
                  name: 'MarkExitDetailsScreen');
            }
          },
          onSessionErrorIos: (error) async {
            isSessionOpen = true;
            developer.log('iOS NFC Session Error: $error',
                name: 'MarkExitDetailsScreen');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${strings.errorNfc}: $error'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
            // Stop session on iOS error
            try {
              await NfcManager.instance.stopSession();
              isSessionOpen = false;
              developer.log('NFC Session stopped after iOS error.',
                  name: 'MarkExitDetailsScreen');
            } catch (e) {
              developer.log('Error stopping NFC session after iOS error: $e',
                  name: 'MarkExitDetailsScreen');
            }
          },
        );
        developer.log('NFC session started, waiting for tag...',
            name: 'MarkExitDetailsScreen');

        // Timeout to stop session if no tag is detected
        Future.delayed(const Duration(seconds: 15), () async {
          if (isSessionOpen && mounted) {
            try {
              await NfcManager.instance.stopSession();
              isSessionOpen = false;
              developer.log('NFC Session stopped due to timeout.',
                  name: 'MarkExitDetailsScreen');
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(strings.errorNfcTimeout),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              }
            } catch (e) {
              developer.log('Error stopping NFC session on timeout: $e',
                  name: 'MarkExitDetailsScreen');
            }
          }
        });
      } catch (e) {
        developer.log('Error starting NFC session: $e',
            name: 'MarkExitDetailsScreen');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${strings.errorNfc}: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }

    /// START: UPDATED CASH PAYMENT FUNCTION
    void initiateCashPayment() async {
      if (!mounted) return;

      // Show the confirmation dialog first
      final bool? confirmed =
          await _showCashPaymentDialog(context, totalChargesStr, strings);

      // Only proceed if the user clicked "Done" (confirmed == true)
      if (confirmed != true) {
        developer.log('Cash payment cancelled by user.',
            name: 'MarkExitDetailsScreen.initiateCashPayment');
        return;
      }

      // If confirmed, show processing message and call the service
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings.messageProcessingPayment),
            backgroundColor: Colors.blue,
          ),
        );
      }

      try {
        developer.log('Initiating cash payment for ticket: ${widget.ticketId}',
            name: 'MarkExitDetailsScreen.initiateCashPayment');
        final response =
            await _paymentService.recordCashPayment(widget.ticketId);
        developer.log('Cash payment response: $response',
            name: 'MarkExitDetailsScreen.initiateCashPayment');

        if (mounted) {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message']?.toString() ??
                  strings.messageCashPaymentSuccess),
              backgroundColor: AppColors.successDark,
            ),
          );
          // Wait a moment before popping to let user see the success message
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              Navigator.pop(context, true);
            }
          });
        }
      } catch (e) {
        developer.log('Error recording cash payment: $e',
            name: 'MarkExitDetailsScreen.initiateCashPayment');
        if (mounted) {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('${strings.errorCashPaymentFailed}: ${e.toString()}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }

    /// END: UPDATED CASH PAYMENT FUNCTION

    return Card(
      elevation: Theme.of(context).cardTheme.elevation,
      margin: Theme.of(context).cardTheme.margin,
      shape: Theme.of(context).cardTheme.shape,
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            InkWell(
              onTap: viewModel.isLoading ? null : initiateUpiPayment,
              borderRadius: BorderRadius.circular(12),
              child: _buildOptionRow(
                  strings.buttonPayUpi, Icons.qr_code_2_outlined),
            ),
            if (_isNfcSupported)
              InkWell(
                onTap: viewModel.isLoading ? null : initiateNfcCardPayment,
                borderRadius: BorderRadius.circular(12),
                child:
                    _buildOptionRow(strings.buttonPayNfc, Icons.nfc_outlined),
              ),
            InkWell(
              onTap: viewModel.isLoading ? null : initiateCashPayment,
              borderRadius: BorderRadius.circular(12),
              child: _buildOptionRow(
                  strings.buttonPayCash, Icons.payments_outlined),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionRow(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: 12.0), // Increased vertical padding
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28), // Slightly larger icon
              const SizedBox(width: 16), // Increased spacing
              Text(
                text,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          Icon(Icons.chevron_right,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
              size: 28), // Adjusted opacity
        ],
      ),
    );
  }

  PreferredSizeWidget _buildCustomAppBar(
      MarkExitViewModel viewModel, S strings) {
    final ticketRefId = viewModel.ticketDetails?['ticket_ref_id']?.toString() ??
        strings.labelNA;
    return CustomAppBar.appBarWithNavigation(
      screenTitle: "${strings.markExitLabel} #$ticketRefId",
      onPressed: () => Navigator.pop(
          context,
          viewModel.paymentStatus?.toLowerCase() ==
              'success'), // Pass back success status
      darkBackground: Theme.of(context).brightness == Brightness.dark,
      fontSize: 16, // Adjusted font size
      centreTitle: false,
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    return Consumer<MarkExitViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.paymentStatus != null &&
            viewModel.paymentStatus != "processing_payment_notification") {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              if (viewModel.paymentStatus?.toLowerCase() == 'success' ||
                  viewModel.paymentStatus?.toLowerCase() == 'failed' ||
                  viewModel.paymentStatus?.toLowerCase() == 'paid_cash') {
                ScaffoldMessenger.of(context)
                    .removeCurrentSnackBar(); // Remove previous if any
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        '${strings.labelPaymentStatus}: ${viewModel.paymentStatus?.capitalize() ?? strings.labelUnknown.capitalize()}'),
                    backgroundColor:
                        viewModel.paymentStatus?.toLowerCase() == 'success' ||
                                viewModel.paymentStatus?.toLowerCase() ==
                                    'paid_cash'
                            ? AppColors.successDark // Use AppColors
                            : AppColors.errorDark,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                if (viewModel.paymentStatus?.toLowerCase() == 'success' ||
                    viewModel.paymentStatus?.toLowerCase() == 'paid_cash') {
                  // Optionally pop the screen on success after a delay
                  Future.delayed(const Duration(seconds: 2), () {
                    if (mounted) {
                      Navigator.pop(context, true);
                    } // Pop with success
                  });
                }
              }
            }
          });
        }
        return PopScope(
          // Use PopScope for more control over back navigation
          canPop: !(viewModel.isLoading), // Prevent pop if loading
          onPopInvoked: (didPop) {
            if (didPop) return;
            // Handle custom back press logic if needed, e.g., confirm exit
          },
          child: Scaffold(
            appBar: _buildCustomAppBar(viewModel, strings),
            body: RefreshIndicator(
              onRefresh: _markTicketAsExited,
              color: Theme.of(context)
                  .colorScheme
                  .primary, // Set refresh indicator color
              child: viewModel.isLoading &&
                      viewModel.ticketDetails ==
                          null // Show loading only if no details yet
                  ? _buildLoadingState(strings)
                  : viewModel.error != null &&
                          viewModel.ticketDetails ==
                              null // Show error only if no details yet
                      ? _buildErrorState(viewModel, strings)
                      : viewModel.ticketDetails ==
                              null // Fallback for unexpected null details
                          ? _buildErrorState(viewModel,
                              strings) // Or a specific "No details" message
                          : _buildTicketDetails(viewModel, strings),
            ),
          ),
        );
      },
    );
  }
}

// Add capitalize extension if not already present globally
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
