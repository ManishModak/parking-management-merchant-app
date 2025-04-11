import 'dart:developer' as developer;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/app_config.dart';
import '../../../../utils/components/appbar.dart';
import '../../../../utils/components/button.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _markTicketAsExited();
      _checkNfcStatus();
    });
  }

  Future<void> _checkNfcStatus() async {
    final isAvailable = await NfcManager.instance.isAvailable();
    setState(() {
      _isNfcSupported = isAvailable;
      _isNfcEnabled = isAvailable;
    });
    developer.log(isAvailable ? 'NFC is supported and enabled' : 'NFC not supported or disabled', name: 'NFC Check');
  }

  Future<void> _markTicketAsExited() async {
    final viewModel = Provider.of<MarkExitViewModel>(context, listen: false);
    await viewModel.markTicketAsExited(widget.ticketId);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showZoomableImageDialog(String imageUrl) {
    developer.log('[MarkExitDetailsScreen] Showing zoomable image dialog for URL: $imageUrl');
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
              color: value.toLowerCase() == 'open' ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
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
                  ? (value.toLowerCase() == 'open' ? Colors.green : Colors.orange)
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

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
                          value: ticketData['fare_type'] ?? 'Pending',
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

  Widget _buildActionButton(MarkExitViewModel viewModel, S strings) {
    final ticketData = viewModel.ticketDetails ?? {};
    final totalChargesStr = ticketData['total_charges']?.toString() ?? '0';
    final totalCharges = double.tryParse(totalChargesStr) ?? 0.0;

    void initiateRazorpayPayment() {
      if (totalCharges <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid amount for payment')),
        );
        return;
      }

      var options = {
        'key': 'rzp_test_v4QApxVP1vzbl7', // Replace with your Razorpay test/live key
        'amount': (totalCharges * 100).toInt(), // Amount in paise (₹1 = 100 paise)
        'name': 'Parking Payment',
        'description': 'Payment for Ticket #${ticketData['ticket_ref_id']}',
        'prefill': {
          'contact': "9356384431" ?? '', // Optional: Replace with user contact if available
          'email': 'user@example.com', // Optional: Replace with user email if available
        },
        'external': {
          'wallets': ['paytm', 'googlepay', 'phonepe'] // Optional: Add supported wallets
        },
        'method': {
          'upi': true, // Enable UPI payment method (QR code will be shown by UPI apps)
          'card': false, // Disable other methods if not needed
          'netbanking': false,
          'wallet': false,
        },
      };

      try {
        //_razorpay.open(options);
      } catch (e) {
        developer.log('Error initiating Razorpay payment: $e', name: 'MarkExitDetailsScreen');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initiating payment: $e')),
        );
      }
    }

    void initiateNfcCardPayment() async {
      if (!_isNfcSupported) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This device does not support NFC')),
        );
        return;
      }
      if (!_isNfcEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enable NFC in Settings')),
        );
        return;
      }
      try {
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('NFC Error: $e')));
        await NfcManager.instance.stopSession();
      }
    }

    void initiateCashPayment() {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please pay cash at the exit gate')));
      viewModel.markTicketAsCashPending(widget.ticketId);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            InkWell(
              onTap: initiateRazorpayPayment,
              child: _buildOptionRow('Pay via UPI (Razorpay)', Icons.qr_code),
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

  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
    } catch (e) {
      return dateTimeStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    return Consumer<MarkExitViewModel>(
      builder: (context, viewModel, child) {
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