import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_routes.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/config/app_config.dart';
import 'package:merchant_app/utils/components/button.dart';
import 'package:shimmer/shimmer.dart';
import '../../../generated/l10n.dart';
import '../../../viewmodels/dispute/raise_dispute_viewmodel.dart';
import '../../../viewmodels/ticket/ticket_history_viewmodel.dart';
import '../../dispute/raise_dispute/raise_dispute_dialog.dart';

class ViewTicketScreen extends StatefulWidget {
  final String ticketId;

  const ViewTicketScreen({super.key, required this.ticketId});

  @override
  _ViewTicketScreenState createState() => _ViewTicketScreenState();
}

class _ViewTicketScreenState extends State<ViewTicketScreen> {
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
    final viewModel = Provider.of<TicketHistoryViewModel>(context, listen: false);
    final strings = S.of(context);
    try {
      await Future.delayed(const Duration(seconds: 2));
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
        content: Text('$message: $error'),
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
                    _buildShimmerPlaceholder(width: 180, height: 24),
                    _buildShimmerPlaceholder(width: 100, height: 30),
                  ],
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildShimmerPlaceholder(width: 110, height: 16),
                          const SizedBox(height: 10),
                          _buildShimmerPlaceholder(height: 22),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildShimmerPlaceholder(width: 110, height: 16),
                          const SizedBox(height: 10),
                          _buildShimmerPlaceholder(height: 22),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildShimmerPlaceholder(width: 110, height: 16),
                          const SizedBox(height: 10),
                          _buildShimmerPlaceholder(height: 22),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildShimmerPlaceholder(width: 110, height: 16),
                          const SizedBox(height: 10),
                          _buildShimmerPlaceholder(height: 22),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildShimmerPlaceholder(width: 110, height: 16),
                          const SizedBox(height: 10),
                          _buildShimmerPlaceholder(height: 22),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildShimmerPlaceholder(width: 110, height: 16),
                          const SizedBox(height: 10),
                          _buildShimmerPlaceholder(height: 22),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildShimmerPlaceholder(width: 80, height: 16),
                          const SizedBox(height: 10),
                          _buildShimmerPlaceholder(width: 60, height: 22),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildShimmerPlaceholder(width: 80, height: 16),
                          const SizedBox(height: 10),
                          _buildShimmerPlaceholder(width: 70, height: 22),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildShimmerPlaceholder(width: 80, height: 16),
                          const SizedBox(height: 10),
                          _buildShimmerPlaceholder(width: 90, height: 22),
                        ],
                      ),
                    ),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildShimmerPlaceholder(width: 180, height: 24),
                    _buildShimmerPlaceholder(width: 100, height: 30),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildShimmerPlaceholder(width: 80, height: 20),
                    _buildShimmerPlaceholder(width: 100, height: 20),
                  ],
                ),
                const SizedBox(height: 10),
                _buildShimmerPlaceholder(width: 140, height: 16),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildShimmerPlaceholder(width: 140, height: 24),
                    _buildShimmerPlaceholder(width: 30, height: 24),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    3,
                        (index) => ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _buildShimmerPlaceholder(
                        width: (AppConfig.deviceWidth - 70) / 3,
                        height: 140,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildShimmerPlaceholder(width: 28, height: 28),
                    const SizedBox(width: 8),
                    _buildShimmerPlaceholder(width: 90, height: 20),
                    const SizedBox(width: 8),
                    _buildShimmerPlaceholder(width: 28, height: 28),
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
            padding: const EdgeInsets.all(18.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildShimmerPlaceholder(width: 28, height: 28),
                    const SizedBox(width: 14),
                    _buildShimmerPlaceholder(width: 140, height: 24),
                  ],
                ),
                _buildShimmerPlaceholder(width: 28, height: 28),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection(TicketHistoryViewModel viewModel, S strings) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: AppColors.formBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              strings.labelUploadedDocuments,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
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
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
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
                if (viewModel.capturedImageUrls == null || viewModel.capturedImageUrls!.isEmpty)
                  SizedBox(
                    height: 150,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_not_supported, size: 48, color: AppColors.primary),
                          const SizedBox(height: 8),
                          Text(
                            strings.messageNoImagesAvailable,
                            style: const TextStyle(color: Colors.grey, fontSize: 16),
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
                                  errorWidget: (context, url, error) => Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.broken_image_outlined, size: 32, color: Colors.grey),
                                        const SizedBox(height: 8),
                                        Text(strings.errorImageLoadFailed, style: const TextStyle(color: Colors.grey, fontSize: 12)),
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
                          color: _currentImagePage > 0 ? AppColors.primary : Colors.grey,
                          onPressed: _currentImagePage > 0
                              ? () {
                            setState(() {
                              _currentImagePage--;
                            });
                          }
                              : null,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${strings.labelPage} ${_currentImagePage + 1} ${strings.labelOf} ${_getTotalPages(viewModel)}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios, size: 18),
                          color: _currentImagePage < _getTotalPages(viewModel) - 1 ? AppColors.primary : Colors.grey,
                          onPressed: _currentImagePage < _getTotalPages(viewModel) - 1
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
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getCurrentImages(TicketHistoryViewModel viewModel) {
    if (viewModel.capturedImageUrls == null || viewModel.capturedImageUrls!.isEmpty) {
      return [];
    }
    final totalImages = viewModel.capturedImageUrls!.length;
    final startIndex = _currentImagePage * 3;
    final endIndex = (startIndex + 3) > totalImages ? totalImages : (startIndex + 3);
    return viewModel.capturedImageUrls!.sublist(startIndex, endIndex);
  }

  int _getTotalPages(TicketHistoryViewModel viewModel) {
    if (viewModel.capturedImageUrls == null || viewModel.capturedImageUrls!.isEmpty) {
      return 0;
    }
    return (viewModel.capturedImageUrls!.length / 3).ceil();
  }

  Widget _buildActionButton(TicketHistoryViewModel viewModel, S strings) {
    if (viewModel.ticket == null) return const SizedBox.shrink();

    final bool disputeRaised = true; // Hardcoded for now as per original
    developer.log('Dispute Raised: ${viewModel.ticket!.disputeRaised.toString()}', name: 'ActionButton');
    developer.log('Dispute Raised: ${disputeRaised.toString()}', name: 'ActionButton');

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(left: 8, right: 8, top: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppColors.formBackground,
      child: InkWell(
        onTap: () {
          if (disputeRaised) {
            developer.log('Navigating to view dispute screen', name: 'Navigation');
            Navigator.pushNamed(context, AppRoutes.disputeDetail, arguments: {'ticketId': widget.ticketId});
          } else {
            developer.log('Navigating to raise dispute screen', name: 'Navigation');
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showDialog(
                context: context,
                builder: (context) => ChangeNotifierProvider(
                  create: (_) => RaiseDisputeViewModel(),
                  child: RaiseDisputeDialog(ticketId: widget.ticketId),
                ),
              );
            });
          }
        },
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
                    disputeRaised ? strings.buttonViewDispute : strings.buttonRaiseDispute,
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
              color: value.toLowerCase() == strings.statusSuccess.toLowerCase() ? Colors.green.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: value.toLowerCase() == strings.statusSuccess.toLowerCase() ? Colors.green : AppColors.error,
                width: 1,
              ),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: value.toLowerCase() == strings.statusSuccess.toLowerCase() ? Colors.green : AppColors.error,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          )
              : Text(
            value.isEmpty ? strings.labelNA : value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
              color: highlight
                  ? (value.toLowerCase() == strings.statusSuccess.toLowerCase() ? Colors.green : Colors.red)
                  : AppColors.textPrimary.withOpacity(0.9),
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
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
            ...children,
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildCustomAppBar(TicketHistoryViewModel viewModel, S strings) {
    return CustomAppBar.appBarWithNavigation(
      screenTitle: viewModel.ticket == null
          ? "${strings.titleTicketDetails}\n${strings.labelLoading}"
          : "${strings.titleTicket} #${viewModel.ticket!.ticketRefId ?? strings.labelNA}\n${strings.labelCreated}: ${viewModel.getFormattedCreationTime()}",
      onPressed: () => Navigator.pop(context),
      darkBackground: true,
      fontSize: 18,
      centreTitle: false, context: context,
    );
  }

  Widget _buildErrorContent(TicketHistoryViewModel viewModel, S strings) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              '${strings.errorGeneric}: ${viewModel.error}',
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            CustomButtons.primaryButton(
              text: strings.buttonRetry,
              onPressed: _fetchTicketDetails, context: context,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentDetails(TicketHistoryViewModel viewModel, S strings) {
    if (viewModel.ticket == null) return const SizedBox.shrink();
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
                Text(
                  strings.labelPaymentDetails,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(strings.statusPending.toLowerCase()).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    strings.statusPending,
                    style: TextStyle(
                      color: _getStatusColor(strings.statusPending.toLowerCase()),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  strings.labelUPI,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  viewModel.ticket!.totalCharges != null ? '₹${viewModel.ticket!.totalCharges}' : '₹0',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              viewModel.getFormattedCreationTime(),
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketDetails(TicketHistoryViewModel viewModel, S strings) {
    if (viewModel.ticket == null) return const SizedBox.shrink();
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        _buildCompactSection(
          title: strings.labelTicketDetails,
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(viewModel.ticket!.status.toString().split('.').last.toLowerCase()).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _getStatusColor(viewModel.ticket!.status.toString().split('.').last.toLowerCase()),
                width: 1.5,
              ),
            ),
            child: Text(
              viewModel.ticket!.status.toString().split('.').last,
              style: TextStyle(
                color: _getStatusColor(viewModel.ticket!.status.toString().split('.').last.toLowerCase()),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    title: strings.labelVehicleNumber,
                    value: viewModel.ticket!.vehicleNumber,
                    strings: strings,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    title: strings.labelVehicleType,
                    value: viewModel.ticket!.vehicleType,
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
                    value: '${strings.labelPlaza} ${viewModel.ticket!.plazaId}',
                    strings: strings,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    title: strings.labelEntryLane,
                    value: viewModel.ticket!.entryLaneId,
                    strings: strings,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    title: strings.labelFloorId,
                    value: viewModel.ticket!.floorId.isEmpty ? strings.labelNA : viewModel.ticket!.floorId,
                    strings: strings,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    title: strings.labelSlotId,
                    value: viewModel.ticket!.slotId.isEmpty ? strings.labelNA : viewModel.ticket!.slotId,
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
                    value: viewModel.getFormattedEntryTime(),
                    strings: strings,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    title: strings.labelExitTime,
                    value: viewModel.getFormattedExitTime(),
                    strings: strings,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDetailItem(
                  title: strings.labelDuration,
                  value: viewModel.ticket!.parkingDuration?.toString() ?? '0',
                  strings: strings,
                ),
                _buildDetailItem(
                  title: strings.labelFareRate,
                  value: viewModel.ticket!.fareAmount != null ? '₹${viewModel.ticket!.fareAmount}' : '₹0',
                  strings: strings,
                ),
                _buildDetailItem(
                  title: strings.labelFareType,
                  value: viewModel.ticket!.fareType ?? strings.labelStandard,
                  strings: strings,
                ),
              ],
            ),
          ],
        ),
        _buildPaymentDetails(viewModel, strings),
        _buildImageSection(viewModel, strings),
        _buildActionButton(viewModel, strings),
      ],
    );
  }

  Color _getStatusColor(String status) {
    final strings = S.of(context);
    switch (status.toLowerCase()) {
      case 'success':
      case 'open':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
      case 'rejected':
        return Colors.red;
      case 'complete':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    return Consumer<TicketHistoryViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: _buildCustomAppBar(viewModel, strings),
          body: RefreshIndicator(
            onRefresh: _fetchTicketDetails,
            child: viewModel.isLoading || viewModel.ticket == null
                ? _buildLoadingState()
                : viewModel.error != null
                ? _buildErrorContent(viewModel, strings)
                : _buildTicketDetails(viewModel, strings),
          ),
        );
      },
    );
  }
}