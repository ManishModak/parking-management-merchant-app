import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/config/app_config.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:developer' as developer;
import 'process_dispute_dialog.dart';
import '../../viewmodels/dispute/process_dispute_viewmodel.dart';

class ProcessDisputeDetailsScreen extends StatefulWidget {
  final String ticketId;

  const ProcessDisputeDetailsScreen({super.key, required this.ticketId});

  @override
  State<ProcessDisputeDetailsScreen> createState() => _ProcessDisputeDetailsScreenState();
}

class _ProcessDisputeDetailsScreenState extends State<ProcessDisputeDetailsScreen> {
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
    final viewModel = Provider.of<ProcessDisputeViewModel>(context, listen: false);
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _buildShimmerPlaceholder(width: 200, height: 24),
                        const SizedBox(width: 12),
                        _buildShimmerPlaceholder(width: 100, height: 20),
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
                    _buildShimmerPlaceholder(width: double.infinity, height: 18),
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
                          width: (AppConfig.deviceWidth - 64) / 3 + (index % 2 == 0 ? 15 : -15),
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

  Widget _buildImageSection(ProcessDisputeViewModel viewModel) {
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

  void _showAuditDetailsDialog(ProcessDisputeViewModel viewModel) {
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
                _buildDetailItem(
                  title: 'Dispute Raised By',
                  value: 'User1@mail.com', // Add this field to Dispute if needed
                ),
                _buildDetailItem(
                  title: 'Dispute Raised Date',
                  value: '30-01-2025  10:20:28',
                ),
                _buildDetailItem(
                  title: 'Dispute Processed By',
                  value: 'Admin1@mail.com', // Add this field to Dispute if needed
                ),
                _buildDetailItem(
                  title: 'Dispute Processed Date',
                  value: '31-01-2025  15:20:28', // Add this field to Dispute if needed
                ),
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

  Widget _buildDisputeDetailWithAuditLink(ProcessDisputeViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Dispute Information',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
        ),
        SizedBox(width: 36),
        GestureDetector(
          onTap: () => _showAuditDetailsDialog(viewModel),
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

  List<String> _getCurrentImages(ProcessDisputeViewModel viewModel) {
    if (viewModel.capturedImageUrls == null || viewModel.capturedImageUrls!.isEmpty) return [];
    final totalImages = viewModel.capturedImageUrls!.length;
    final startIndex = _currentImagePage * 3;
    final endIndex = (startIndex + 3) > totalImages ? totalImages : (startIndex + 3);
    return viewModel.capturedImageUrls!.sublist(startIndex, endIndex);
  }

  int _getTotalPages(ProcessDisputeViewModel viewModel) {
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
    required Widget title,
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
    if (viewModel.dispute == null) {
      return const SizedBox.shrink();
    }

    // Assuming disputeRaised can be inferred from disputeStatus or another field
    final bool disputeRaised = viewModel.dispute!.disputeStatus.toLowerCase() == 'open';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppColors.formBackground,
      child: InkWell(
        onTap: () => _handleActionButtonTap(disputeRaised),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    disputeRaised ? Icons.fact_check_outlined : Icons.report_problem_outlined,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    disputeRaised ? 'Process Dispute' : 'View Details',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.primary,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleActionButtonTap(bool disputeRaised) {
    developer.log('Showing dispute dialog', name: 'Navigation');
    showDialog(
      context: context,
      builder: (context) => ChangeNotifierProvider(
        create: (_) => ProcessDisputeViewModel()..fetchDisputeDetails(widget.ticketId),
        child: ProcessDisputeDialog(ticketId: widget.ticketId),
      ),
    );
  }

  PreferredSizeWidget _buildCustomAppBar(ProcessDisputeViewModel viewModel) {
    return CustomAppBar.appBarWithNavigation(
      screenTitle: viewModel.dispute == null
          ? "Processing Dispute\nLoading..."
          : "Ticket #${viewModel.dispute!.ticketId}\nStatus: ${viewModel.dispute!.disputeStatus}",
      onPressed: () => Navigator.pop(context),
      darkBackground: true,
      fontSize: 18,
      centreTitle: false, context: context,
    );
  }

  Widget _buildDisputeDetails(ProcessDisputeViewModel viewModel) {
    if (viewModel.dispute == null) return const SizedBox.shrink();
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        _buildActionButton(viewModel),
        _buildCompactSection(
          title: _buildDisputeDetailWithAuditLink(viewModel),
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
                Expanded(child: _buildDetailItem(title: 'Plaza Name', value: viewModel.dispute!.plazaName ?? 'N/A')),
              ],
            ),
            Row(
              children: [
                Expanded(child: _buildDetailItem(title: 'Vehicle Number', value: viewModel.dispute!.vehicleNumber ?? 'N/A')),
                Expanded(child: _buildDetailItem(title: 'Vehicle Type', value: viewModel.dispute!.vehicleType ?? 'N/A')),
              ],
            ),
            Row(
              children: [
                Expanded(child: _buildDetailItem(title: 'Entry Time', value: viewModel.dispute!.vehicleEntryTime ?? 'N/A')),
                Expanded(child: _buildDetailItem(title: 'Exit Time', value: viewModel.dispute!.vehicleExitTime ?? 'N/A')),
              ],
            ),
            Row(
              children: [
                Expanded(child: _buildDetailItem(title: 'Parking Duration', value: viewModel.dispute!.parkingDuration ?? 'N/A')),
                Expanded(child: _buildDetailItem(title: 'Payment Amount', value: '₹${viewModel.dispute!.paymentAmount ?? 0}')),
              ],
            ),
            Row(
              children: [
                Expanded(child: _buildDetailItem(title: 'Fare Type', value: viewModel.dispute!.fareType ?? 'N/A')),
                Expanded(child: _buildDetailItem(title: 'Fare Amount', value: '₹${viewModel.dispute!.fareAmount ?? 0}')),
              ],
            ),
            Row(
              children: [
                Expanded(child: _buildDetailItem(title: 'Payment Date', value: viewModel.dispute!.paymentDate ?? 'N/A')),
                Expanded(child: _buildDetailItem(title: 'Expiry Date', value: viewModel.dispute!.disputeExpiryDate ?? 'N/A')),
              ],
            ),
            Row(
              children: [
                Expanded(child: _buildDetailItem(title: 'Dispute Reason', value: viewModel.dispute!.disputeReason ?? 'N/A')),
                Expanded(child: _buildDetailItem(title: 'Dispute Amount', value: '₹${viewModel.dispute!.disputeAmount ?? 0}')),
              ],
            ),
            _buildDetailItem(
              title: 'Dispute Remark',
              value: viewModel.dispute!.disputeRemark?.isEmpty ?? true ? 'N/A' : viewModel.dispute!.disputeRemark!,
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
    return Consumer<ProcessDisputeViewModel>(
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