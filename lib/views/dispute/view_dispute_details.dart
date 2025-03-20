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
  _ViewDisputeDetailsScreenState createState() => _ViewDisputeDetailsScreenState();
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
        content: Text('Failed to load dispute details: $message'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.error,
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
                  errorWidget: (context, url, error) => const Center(
                    child: Icon(Icons.broken_image_outlined, size: 48, color: Colors.red),
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

  Widget _buildShimmerPlaceholder({double width = double.infinity, double height = 20}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
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
          elevation: 2,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: AppColors.formBackground,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title with Audit Link and Status Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _buildShimmerPlaceholder(width: 200, height: 24), // "Dispute Information" (increased)
                        const SizedBox(width: 12),
                        _buildShimmerPlaceholder(width: 100, height: 20), // "Audit Details" (increased)
                      ],
                    ),
                    _buildShimmerPlaceholder(width: 40, height: 30), // Status Badge (increased)
                  ],
                ),
                const SizedBox(height: 24),
                // Detail Rows (7 rows of two items each)
                for (int i = 0; i < 7; i++) ...[
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildShimmerPlaceholder(width: 110, height: 16), // Label (increased)
                            const SizedBox(height: 6),
                            _buildShimmerPlaceholder(
                              width: i % 2 == 0 ? 160 : 200, // Vary widths, increased
                              height: 18, // Increased
                            ), // Value
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildShimmerPlaceholder(width: 110, height: 16), // Label (increased)
                            const SizedBox(height: 6),
                            _buildShimmerPlaceholder(
                              width: i % 2 == 1 ? 160 : 200, // Alternate widths, increased
                              height: 18, // Increased
                            ), // Value
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
                // Dispute Remark (full width)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildShimmerPlaceholder(width: 130, height: 16), // Label (increased)
                    const SizedBox(height: 6),
                    _buildShimmerPlaceholder(width: double.infinity, height: 18), // Value (increased)
                  ],
                ),
              ],
            ),
          ),
        ),
        Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: AppColors.formBackground,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShimmerPlaceholder(width: 220, height: 22), // "Captured Images" (increased)
                const SizedBox(height: 12),
                SizedBox(
                  height: 160, // Slightly taller images
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 3, // Show 3 image placeholders
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: _buildShimmerPlaceholder(
                          width: (AppConfig.deviceWidth - 64) / 3 + (index % 2 == 0 ? 15 : -15), // Slightly more variation
                          height: 160, // Increased
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildShimmerPlaceholder(width: 28, height: 28), // Left arrow (increased)
                    const SizedBox(width: 12),
                    _buildShimmerPlaceholder(width: 90, height: 26), // Page indicator (increased)
                    const SizedBox(width: 12),
                    _buildShimmerPlaceholder(width: 28, height: 28), // Right arrow (increased)
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
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: AppColors.formBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Uploaded Documents',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.textPrimary),
            ),
            if (viewModel.capturedImageUrls != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${viewModel.capturedImageUrls!.length}',
                  style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w500),
                ),
              ),
          ],
        ),
        initiallyExpanded: true,
        onExpansionChanged: (expanded) => setState(() => _isImagesExpanded = expanded),
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (viewModel.capturedImageUrls == null || viewModel.capturedImageUrls!.isEmpty)
                  SizedBox(
                    height: 150,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_not_supported, size: 48, color: AppColors.primary),
                          const SizedBox(height: 8),
                          const Text('No Images Available', style: TextStyle(color: Colors.grey, fontSize: 16)),
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
                              border: Border.all(color: AppColors.primary),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(11),
                              child: GestureDetector(
                                onTap: () => _showZoomableImageDialog(imageUrl),
                                child: CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => _buildShimmerPlaceholder(width: imageWidth, height: 150),
                                  errorWidget: (context, url, error) => const Center(
                                    child: Icon(Icons.broken_image_outlined, size: 32, color: Colors.grey),
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
                          color: _currentImagePage > 0 ? AppColors.primary : Colors.grey,
                          onPressed: _currentImagePage > 0 ? () => setState(() => _currentImagePage--) : null,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Page ${_currentImagePage + 1} of ${_getTotalPages(viewModel)}',
                            style: const TextStyle(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.w500),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios, size: 18),
                          color: _currentImagePage < _getTotalPages(viewModel) - 1 ? AppColors.primary : Colors.grey,
                          onPressed: _currentImagePage < _getTotalPages(viewModel) - 1
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

  void _showAuditDetailsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Audit Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textPrimary),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 4),
                _buildDetailItem(title: 'Dispute Raised By', value: 'User1@mail.com'),
                _buildDetailItem(title: 'Dispute Raised Date', value: '30-01-2025  10:20:28'),
                _buildDetailItem(title: 'Dispute Processed By', value: 'Admin1@mail.com'),
                _buildDetailItem(title: 'Dispute Processed Date', value: '31-01-2025  15:20:28'),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(color: Colors.white),
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

 // Add this to the Dispute Information card in _buildCompactSection
  Widget _buildDisputeDetailWithAuditLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Dispute Information',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
        ),
        SizedBox(width: 36,),
        GestureDetector(
          onTap: _showAuditDetailsDialog,
          child: const Text(
            'Audit Details',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }


  List<String> _getCurrentImages(ViewDisputeViewModel viewModel) {
    if (viewModel.capturedImageUrls == null || viewModel.capturedImageUrls!.isEmpty) return [];
    final totalImages = viewModel.capturedImageUrls!.length;
    final startIndex = _currentImagePage * 3;
    final endIndex = (startIndex + 3) > totalImages ? totalImages : (startIndex + 3);
    return viewModel.capturedImageUrls!.sublist(startIndex, endIndex);
  }

  int _getTotalPages(ViewDisputeViewModel viewModel) {
    if (viewModel.capturedImageUrls == null || viewModel.capturedImageUrls!.isEmpty) return 0;
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
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          isBadge
              ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: value.toLowerCase() == 'open' ? Colors.green.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: value.toLowerCase() == 'open' ? Colors.green : AppColors.error,
                width: 1,
              ),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: value.toLowerCase() == 'open' ? Colors.green : AppColors.error,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          )
              : Text(
            value.isEmpty ? 'N/A' : value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
              color: highlight
                  ? (value.toLowerCase() == 'open' ? Colors.green : Colors.red)
                  : AppColors.textPrimary.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactSection({
    required Widget title, // Changed from String to Widget
    required List<Widget> children,
    Widget? trailing,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppColors.formBackground,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                title, // Now accepting a Widget instead of Text widget
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
    return CustomAppBar.appBarWithNavigation(
      screenTitle: viewModel.dispute == null
          ? "Dispute Details\nLoading..."
          : "Dispute #${viewModel.dispute!.disputeId ?? 'N/A'}\nRaised: ${viewModel.dispute!.disputeRaisedDate ?? 'N/A'}",
      onPressed: () => Navigator.pop(context),
      darkBackground: true,
      fontSize: 18,
      centreTitle: false, context: context,
    );
  }

  Widget _buildDisputeDetails(ViewDisputeViewModel viewModel) {
    if (viewModel.dispute == null) return const SizedBox.shrink();
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        _buildCompactSection(
          //title: 'Dispute Information',
          title: _buildDisputeDetailWithAuditLink(),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(viewModel.dispute!.disputeStatus).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _getStatusColor(viewModel.dispute!.disputeStatus), width: 1.5),
            ),
            child: Text(
              viewModel.dispute!.disputeStatus,
              style: TextStyle(
                color: _getStatusColor(viewModel.dispute!.disputeStatus),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          children: [
            Row(
              children: [
                Expanded(child: _buildDetailItem(title: 'Ticket ID', value: viewModel.dispute!.ticketId)),
                Expanded(child: _buildDetailItem(title: 'Plaza Name', value: viewModel.dispute!.plazaName)),
              ],
            ),
            Row(
              children: [
                Expanded(child: _buildDetailItem(title: 'Vehicle Number', value: viewModel.dispute!.vehicleNumber)),
                Expanded(child: _buildDetailItem(title: 'Vehicle Type', value: viewModel.dispute!.vehicleType)),
              ],
            ),
            Row(
              children: [
                Expanded(child: _buildDetailItem(title: 'Entry Time', value: viewModel.dispute!.vehicleEntryTime)),
                Expanded(child: _buildDetailItem(title: 'Exit Time', value: viewModel.dispute!.vehicleExitTime)),
              ],
            ),
            Row(
              children: [
                Expanded(child: _buildDetailItem(title: 'Parking Duration', value: viewModel.dispute!.parkingDuration)),
                Expanded(child: _buildDetailItem(title: 'Payment Amount', value: '₹${viewModel.dispute!.paymentAmount}')),
              ],
            ),
            Row(
              children: [
                Expanded(child: _buildDetailItem(title: 'Fare Type', value: viewModel.dispute!.fareType)),
                Expanded(child: _buildDetailItem(title: 'Fare Amount', value: '₹${viewModel.dispute!.fareAmount}')),
              ],
            ),
            Row(
              children: [
                Expanded(child: _buildDetailItem(title: 'Payment Date', value: viewModel.dispute!.paymentDate)),
                Expanded(child: _buildDetailItem(title: 'Expiry Date', value: viewModel.dispute!.disputeExpiryDate)),
              ],
            ),
            Row(
              children: [
                Expanded(child: _buildDetailItem(title: 'Dispute Reason', value: viewModel.dispute!.disputeReason)),
                Expanded(child: _buildDetailItem(title: 'Dispute Amount', value: '₹${viewModel.dispute!.disputeAmount}')),
              ],
            ),

            _buildDetailItem(
              title: 'Dispute Remark',
              value: viewModel.dispute!.disputeRemark.isEmpty ? 'N/A' : viewModel.dispute!.disputeRemark,
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
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
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
            child: viewModel.isLoading || viewModel.dispute == null
                ? _buildLoadingState()
                : _buildDisputeDetails(viewModel),
          ),
        );
      },
    );
  }
}