import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/config/app_config.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../viewmodels/dispute/view_dispute_viewmodel.dart';

class ViewDisputeDetailsScreen extends StatefulWidget {
  final String ticketId;

  const ViewDisputeDetailsScreen({super.key, required this.ticketId});

  @override
  _ViewDisputeDetailsScreenState createState() =>
      _ViewDisputeDetailsScreenState();
}

class _ViewDisputeDetailsScreenState extends State<ViewDisputeDetailsScreen> {
  int _currentImagePage = 0;
  bool _isImagesExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchDisputeDetails();
    });
  }

  Future<void> _fetchDisputeDetails() async {
    final viewModel = Provider.of<ViewDisputeViewModel>(context, listen: false);
    try {
      await viewModel.fetchDisputeDetails(widget.ticketId);
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(e.toString());
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Failed to load dispute details: $message',
          style: Theme.of(context).snackBarTheme.contentTextStyle,
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).snackBarTheme.backgroundColor,
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
                    child: Icon(
                      Icons.broken_image_outlined,
                      size: 48,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
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
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildShimmerPlaceholder(width: 150, height: 24),
                        const SizedBox(height: 4),
                        _buildShimmerPlaceholder(width: 75, height: 20),
                      ],
                    ),
                    _buildShimmerPlaceholder(width: 40, height: 30),
                  ],
                ),
                const SizedBox(height: 24),
                for (int i = 0; i < 7; i++) ...[
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildShimmerPlaceholder(width: 110, height: 16),
                            const SizedBox(height: 6),
                            _buildShimmerPlaceholder(
                              width: i % 2 == 0 ? 160 : 200,
                              height: 18,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildShimmerPlaceholder(width: 110, height: 16),
                            const SizedBox(height: 6),
                            _buildShimmerPlaceholder(
                              width: i % 2 == 1 ? 160 : 200,
                              height: 18,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildShimmerPlaceholder(width: 130, height: 16),
                    const SizedBox(height: 6),
                    _buildShimmerPlaceholder(
                        width: double.infinity, height: 18),
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
                _buildShimmerPlaceholder(width: 220, height: 22),
                const SizedBox(height: 12),
                SizedBox(
                  height: 160,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: _buildShimmerPlaceholder(
                          width: (AppConfig.deviceWidth - 64) / 3 +
                              (index % 2 == 0 ? 15 : -15),
                          height: 160,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildShimmerPlaceholder(width: 28, height: 28),
                    const SizedBox(width: 12),
                    _buildShimmerPlaceholder(width: 90, height: 26),
                    const SizedBox(width: 12),
                    _buildShimmerPlaceholder(width: 28, height: 28),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection(ViewDisputeViewModel viewModel) {
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
              'Uploaded Documents',
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
                          Icon(
                            Icons.image_not_supported,
                            size: 48,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No Images Available',
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
                                    child: Icon(
                                      Icons.broken_image_outlined,
                                      size: 32,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.6),
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
                            'Page ${_currentImagePage + 1} of ${_getTotalPages(viewModel)}',
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: Theme.of(context).dialogTheme.shape,
          backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
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
                      'Audit Details',
                      style: Theme.of(context)
                          .dialogTheme
                          .titleTextStyle
                          ?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 4),
                _buildDetailItem(
                  title: 'Dispute Raised By',
                  value: displayData['disputeRaisedBy'] ?? 'N/A',
                ),
                _buildDetailItem(
                  title: 'Dispute Raised Date',
                  value: displayData['disputeRaisedDate'] ?? 'N/A',
                ),
                _buildDetailItem(
                  title: 'Dispute Processed By',
                  value: displayData['disputeProcessedBy'] ?? 'N/A',
                ),
                _buildDetailItem(
                  title: 'Dispute Processed Date',
                  value: displayData['disputeProcessedDate'] ?? 'N/A',
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style:
                        Theme.of(context).elevatedButtonTheme.style?.copyWith(
                              padding: WidgetStateProperty.all(
                                  const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8)),
                            ),
                    child: Text(
                      'Close',
                      style: Theme.of(context)
                          .elevatedButtonTheme
                          .style
                          ?.textStyle
                          ?.resolve({})?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimary),
                    ),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Dispute Information',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        GestureDetector(
          onTap: () => _showAuditDetailsDialog(displayData),
          child: Text(
            'Audit Details',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
          ),
        ),
      ],
    );
  }

  List<String> _getCurrentImages(ViewDisputeViewModel viewModel) {
    if (viewModel.capturedImageUrls == null ||
        viewModel.capturedImageUrls!.isEmpty) return [];
    final totalImages = viewModel.capturedImageUrls!.length;
    final startIndex = _currentImagePage * 3;
    final endIndex =
        (startIndex + 3) > totalImages ? totalImages : (startIndex + 3);
    return viewModel.capturedImageUrls!.sublist(startIndex, endIndex);
  }

  int _getTotalPages(ViewDisputeViewModel viewModel) {
    if (viewModel.capturedImageUrls == null ||
        viewModel.capturedImageUrls!.isEmpty) return 0;
    return (viewModel.capturedImageUrls!.length / 3).ceil();
  }

  Widget _buildDetailItem({
    required String title,
    required String value,
    bool highlight = false,
    bool isBadge = false,
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
                    color: _getStatusColor(value).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getStatusColor(value),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: _getStatusColor(value),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                )
              : Text(
                  value.isEmpty ? 'N/A' : value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight:
                            highlight ? FontWeight.bold : FontWeight.normal,
                        color: highlight
                            ? _getStatusColor(value)
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

  PreferredSizeWidget _buildCustomAppBar(ViewDisputeViewModel viewModel) {
    final displayData = viewModel.getDisputeDisplayData();
    return CustomAppBar.appBarWithNavigation(
      screenTitle: viewModel.dispute == null
          ? "Dispute Details\nLoading..."
          : "Ticket #${displayData['ticketId']}\nStatus: ${displayData['disputeStatus']}",
      onPressed: () => Navigator.pop(context),
      darkBackground: Theme.of(context).brightness == Brightness.dark,
      fontSize: 14,
      centreTitle: false,
      context: context,
    );
  }

  Widget _buildDisputeDetails(ViewDisputeViewModel viewModel) {
    if (viewModel.dispute == null) {
      return const Center(child: Text('No dispute data available'));
    }

    final displayData = viewModel.getDisputeDisplayData();

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
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
                    title: 'Ticket ID',
                    value: displayData['ticketId'],
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    title: 'Plaza Name',
                    value: displayData['plazaName'],
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    title: 'Vehicle Number',
                    value: displayData['vehicleNumber'],
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    title: 'Vehicle Type',
                    value: displayData['vehicleType'],
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    title: 'Entry Time',
                    value: displayData['vehicleEntryTime'],
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    title: 'Exit Time',
                    value: displayData['vehicleExitTime'],
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    title: 'Parking Duration',
                    value: displayData['parkingDuration'],
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    title: 'Payment Amount',
                    value: displayData['paymentAmount'],
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    title: 'Fare Type',
                    value: displayData['fareType'],
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    title: 'Fare Amount',
                    value: displayData['fareAmount'],
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    title: 'Payment Date',
                    value: displayData['paymentDate'],
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    title: 'Expiry Date',
                    value: displayData['disputeExpiryDate'],
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    title: 'Dispute Reason',
                    value: displayData['disputeReason'],
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    title: 'Dispute Amount',
                    value: displayData['disputeAmount'],
                  ),
                ),
              ],
            ),
            _buildDetailItem(
              title: 'Dispute Remark',
              value: displayData['disputeRemark'],
            ),
          ],
        ),
        _buildImageSection(viewModel),
      ],
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
    return Consumer<ViewDisputeViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: _buildCustomAppBar(viewModel),
          body: RefreshIndicator(
            onRefresh: _fetchDisputeDetails,
            child: viewModel.isLoading
                ? _buildLoadingState()
                : _buildDisputeDetails(viewModel),
          ),
        );
      },
    );
  }
}
