import 'dart:developer' as developer;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  bool _isImagesExpanded = false;
  bool _isNfcSupported = false;
  bool _isNfcEnabled = false;

  @override
  void initState() {
    super.initState();
    // Schedule post-frame callback to mark ticket as exited, check NFC status, and initialize Socket.IO
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _markTicketAsExited();
      _checkNfcStatus();
      final viewModel = Provider.of<MarkExitViewModel>(context, listen: false);
      viewModel.initializeSocket('user-${widget.ticketId}', ApiConfig.baseUrl);
    });
  }

  // Check NFC availability and update state
  Future<void> _checkNfcStatus() async {
    final isAvailable = await NfcManager.instance.isAvailable();
    setState(() {
      _isNfcSupported = isAvailable;
      _isNfcEnabled = isAvailable;
    });
    developer.log(isAvailable ? 'NFC is supported and enabled' : 'NFC not supported or disabled', name: 'NFC Check');
  }

  // Mark ticket as exited using the view model
  Future<void> _markTicketAsExited() async {
    final viewModel = Provider.of<MarkExitViewModel>(context, listen: false);
    await viewModel.markTicketAsExited(widget.ticketId);
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Display a zoomable image dialog for QR code or ticket images
  void _showZoomableImageDialog(String imageUrl) {
    developer.log('[MarkExitDetailsScreen] Showing zoomable image dialog for URL: $imageUrl', name: 'MarkExitDetailsScreen');
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
                  placeholder: (context, url) => _buildShimmerPlaceholder(height: 300),
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
                  icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onPrimary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Build a shimmer placeholder for loading states
  Widget _buildShimmerPlaceholder({double width = double.infinity, double height = 20}) {
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

  // Build the image section for ticket images
  Widget _buildImageSection(MarkExitViewModel viewModel, S strings) {
    final capturedImageUrls = viewModel.ticketDetails?['captured_images'] as List<String>? ?? [];
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
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
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
        initiallyExpanded: true,
        onExpansionChanged: (expanded) => setState(() => _isImagesExpanded = expanded),
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
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
                          Icon(Icons.image_not_supported,
                              size: 48, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(height: 8),
                          Text(
                            strings.messageNoImagesAvailable,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
                        final imageUrl = _getCurrentImages(capturedImageUrls)[index];
                        final imageWidth = (AppConfig.deviceWidth - 64) / 3;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Container(
                            width: imageWidth,
                            decoration: BoxDecoration(
                              border: Border.all(color: Theme.of(context).colorScheme.primary),
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
                                      _buildShimmerPlaceholder(width: imageWidth, height: 150),
                                  errorWidget: (context, url, error) => Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.broken_image_outlined,
                                            size: 32,
                                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                                        const SizedBox(height: 8),
                                        Text(strings.errorImageLoadFailed,
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
                if (_getTotalPages(capturedImageUrls) > 1) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, size: 18),
                        color: _currentImagePage > 0
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        onPressed: _currentImagePage > 0
                            ? () => setState(() => _currentImagePage--)
                            : null,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${strings.labelPage} ${_currentImagePage + 1} ${strings.labelOf} ${_getTotalPages(capturedImageUrls)}',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios, size: 18),
                        color: _currentImagePage < _getTotalPages(capturedImageUrls) - 1
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        onPressed: _currentImagePage < _getTotalPages(capturedImageUrls) - 1
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

  // Get current images for pagination
  List<String> _getCurrentImages(List<String> capturedImageUrls) {
    if (capturedImageUrls.isEmpty) return [];
    final startIndex = _currentImagePage * 3;
    final endIndex = (startIndex + 3).clamp(0, capturedImageUrls.length);
    return capturedImageUrls.sublist(startIndex, endIndex);
  }

  // Calculate total pages for image pagination
  int _getTotalPages(List<String> capturedImageUrls) {
    if (capturedImageUrls.isEmpty) return 0;
    return (capturedImageUrls.length / 3).ceil();
  }

  // Build error state UI
  Widget _buildErrorState(MarkExitViewModel viewModel, S strings) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
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
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            CustomButtons.primaryButton(
              width: 150,
              height: 40,
              text: strings.buttonRetry,
              onPressed: _markTicketAsExited,
              context: context,
            ),
          ],
        ),
      ),
    );
  }

  // Build detail item for ticket details
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: value.toLowerCase() == 'open'
                  ? Colors.green.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: value.toLowerCase() == 'open' ? Colors.green : Colors.orange,
                width: 1,
              ),
            ),
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: value.toLowerCase() == 'open' ? Colors.green : Colors.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
              : Text(
            value.isEmpty ? strings.labelNA : value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
              color: highlight
                  ? (value.toLowerCase() == 'success' ? Colors.green : Colors.red)
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  // Build ticket details UI
  Widget _buildTicketDetails(MarkExitViewModel viewModel, S strings) {
    final ticketData = viewModel.ticketDetails ?? {};
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailItem(
                          title: strings.ticketIdLabel,
                          value: ticketData['ticket_ref_id'] ?? 'N/A',
                          strings: strings,
                        ),
                        _buildDetailItem(
                          title: strings.labelStatus,
                          value: ticketData['status'] ?? 'N/A',
                          strings: strings,
                          isBadge: true,
                        ),
                        _buildDetailItem(
                          title: strings.labelEntryLane,
                          value: ticketData['entry_lane_id'] ?? 'N/A',
                          strings: strings,
                        ),
                        _buildDetailItem(
                          title: 'Exit Lane',
                          value: ticketData['exit_lane_id'] ?? 'Not filled',
                          strings: strings,
                        ),
                        _buildDetailItem(
                          title: strings.labelFloorId,
                          value: ticketData['floor_id'] ?? 'N/A',
                          strings: strings,
                        ),
                        _buildDetailItem(
                          title: strings.labelSlotId,
                          value: ticketData['slot_id'] ?? 'N/A',
                          strings: strings,
                        ),
                        _buildDetailItem(
                          title: strings.labelVehicleNumber,
                          value: ticketData['vehicle_number'] ?? 'N/A',
                          strings: strings,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailItem(
                          title: strings.labelVehicleType,
                          value: ticketData['vehicle_type'] ?? 'N/A',
                          strings: strings,
                        ),
                        _buildDetailItem(
                          title: strings.labelEntryTime,
                          value: _formatDateTime(ticketData['entry_time']),
                          strings: strings,
                        ),
                        _buildDetailItem(
                          title: 'Exit Time',
                          value: _formatDateTime(ticketData['exit_time']),
                          strings: strings,
                        ),
                        _buildDetailItem(
                          title: 'Parking Duration',
                          value: ticketData['parking_duration']?.toString() ?? 'Calculating...',
                          strings: strings,
                        ),
                        _buildDetailItem(
                          title: 'Fare Type',
                          value: ticketData['fare_type']?.toString() ?? 'Pending',
                          strings: strings,
                        ),
                        _buildDetailItem(
                          title: 'Fare Amount',
                          value: ticketData['fare_amount']?.toString() ?? 'Pending',
                          strings: strings,
                        ),
                        _buildDetailItem(
                          title: 'Total Charges',
                          value: ticketData['total_charges']?.toString() ?? 'Pending',
                          strings: strings,
                        ),
                        _buildDetailItem(
                          title: 'Payment Status',
                          value: viewModel.paymentStatus?.toString() ?? 'Pending',
                          highlight: true,
                          strings: strings,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildImageSection(viewModel, strings),
          _buildActionButton(viewModel, strings),
        ],
      ),
    );
  }

  // Build action buttons for payment options
  Widget _buildActionButton(MarkExitViewModel viewModel, S strings) {
    final ticketData = viewModel.ticketDetails ?? {};
    final totalChargesStr = ticketData['total_charges']?.toString() ?? '0';
    final totalCharges = double.tryParse(totalChargesStr) ?? 0.0;

    // Initiate UPI payment by generating and displaying a QR code
    void initiateUpiPayment() async {
      // Validate the payment amount to ensure it's positive
      if (totalCharges <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid amount for payment')),
        );
        return;
      }

      try {
        // Initialize PaymentService to call the createOrderQrCode method
        final paymentService = PaymentService();

        // Log the attempt to generate the QR code
        developer.log('[MarkExitDetailsScreen] Generating QR code for ticket: ${widget.ticketId}',
            name: 'MarkExitDetailsScreen');

        // Call the createOrderQrCode method with the ticket ID
        final qrCodeResponse = await paymentService.createOrderQrCode(widget.ticketId);

        // Log the response for debugging
        developer.log('[MarkExitDetailsScreen] QR Code Response: $qrCodeResponse',
            name: 'MarkExitDetailsScreen');

        // Extract the QR code URL (backend returns 'qrUrl')
        final qrCodeUrl = qrCodeResponse['qrUrl']?.toString() ?? '';

        // Check if QR code URL is valid
        if (qrCodeUrl.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to retrieve QR code URL')),
          );
          return;
        }

        // Display the QR code in a dialog
        _showZoomableImageDialog(qrCodeUrl);
      } catch (e) {
        // Log any errors during QR code generation
        developer.log('Error generating QR code: $e', name: 'MarkExitDetailsScreen');

        // Show error message to the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating QR code: $e')),
        );
      }
    }

    // Initiate NFC card payment
    void initiateNfcCardPayment() async {
      // Check if NFC is supported
      if (!_isNfcSupported) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This device does not support NFC')),
        );
        return;
      }
      // Check if NFC is enabled
      if (!_isNfcEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enable NFC in Settings')),
        );
        return;
      }
      try {
        // Start NFC session to detect card
        await NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
          if (tag.data.containsKey('isodep') || tag.data.containsKey('nfca')) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('EMV card detected - processing...')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Unsupported card type')),
            );
          }
          await NfcManager.instance.stopSession();
        });
      } catch (e) {
        // Handle NFC errors
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('NFC Error: $e')));
        await NfcManager.instance.stopSession();
      }
    }

    // Initiate cash payment
    void initiateCashPayment() {
      // Notify user to pay cash
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please pay cash at the exit gate')));
      // Update ticket status to cash pending
      viewModel.markTicketAsCashPending(widget.ticketId);
    }

    // Build the payment options card
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            InkWell(
              onTap: initiateUpiPayment,
              child: _buildOptionRow('Pay via UPI', Icons.qr_code),
            ),
            if (_isNfcSupported)
              InkWell(
                onTap: initiateNfcCardPayment,
                child: _buildOptionRow('Pay via Card (NFC)', Icons.nfc),
              ),
            InkWell(
              onTap: initiateCashPayment,
              child: _buildOptionRow('Pay with Cash', Icons.money),
            ),
          ],
        ),
      ),
    );
  }

  // Build a row for payment options
  Widget _buildOptionRow(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 12),
              Text(
                text,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.primary),
        ],
      ),
    );
  }

  // Build custom app bar with ticket reference ID
  PreferredSizeWidget _buildCustomAppBar(MarkExitViewModel viewModel, S strings) {
    final ticketRefId = viewModel.ticketDetails?['ticket_ref_id'] ?? 'N/A';
    return CustomAppBar.appBarWithNavigation(
      screenTitle: "${strings.markExitLabel} #$ticketRefId",
      onPressed: () => Navigator.pop(context),
      darkBackground: Theme.of(context).brightness == Brightness.dark,
      fontSize: 14,
      centreTitle: false,
      context: context,
    );
  }

  // Format date-time string
  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
    } catch (e) {
      return dateTimeStr;
    }
  }

  // Build the main scaffold
  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    return Consumer<MarkExitViewModel>(
      builder: (context, viewModel, child) {
        // Show SnackBar when payment status changes
        if (viewModel.paymentStatus != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Payment Status: ${viewModel.paymentStatus}'),
                backgroundColor: viewModel.paymentStatus?.toLowerCase() == 'success'
                    ? Colors.green
                    : Colors.red,
              ),
            );
          });
        }
        return Scaffold(
          appBar: _buildCustomAppBar(viewModel, strings),
          body: Stack(
            children: [
              viewModel.error != null
                  ? _buildErrorState(viewModel, strings)
                  : _buildTicketDetails(viewModel, strings),
              if (viewModel.isLoading && viewModel.error == null)
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
        );
      },
    );
  }
}