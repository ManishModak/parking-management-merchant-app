import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:merchant_app/config/app_routes.dart';
import 'package:merchant_app/services/storage/secure_storage_service.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/config/app_config.dart';
import 'package:merchant_app/utils/components/button.dart';
import 'package:shimmer/shimmer.dart';
import '../../../generated/l10n.dart';
import '../../../models/ticket.dart';
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
  final _secureStorage = SecureStorageService();

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
        content: Text('$message: $error', style: Theme.of(context).snackBarTheme.contentTextStyle),
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
                      Expanded(child: _buildShimmerFieldPair(strings.labelVehicleNumber)),
                      const SizedBox(width: 20),
                      Expanded(child: _buildShimmerFieldPair(strings.labelVehicleType)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(child: _buildShimmerFieldPair(strings.labelPlazaName)),
                      const SizedBox(width: 20),
                      Expanded(child: _buildShimmerFieldPair(strings.labelEntryLane)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(child: _buildShimmerFieldPair(strings.labelEntryTime)),
                      const SizedBox(width: 20),
                      Expanded(child: _buildShimmerFieldPair(strings.labelExitTime)),
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

  Widget _buildImageSection(TicketHistoryViewModel viewModel, S strings) {
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
            if (viewModel.capturedImageUrls != null && viewModel.capturedImageUrls!.isNotEmpty)
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
                  if (_getTotalPages(viewModel) > 1) ...[
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
                            '${strings.labelPage} ${_currentImagePage + 1} ${strings.labelOf} ${_getTotalPages(viewModel)}',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios, size: 18),
                          color: _currentImagePage < _getTotalPages(viewModel) - 1
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
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

  List<String> _getCurrentImages(TicketHistoryViewModel viewModel) {
    if (viewModel.capturedImageUrls == null || viewModel.capturedImageUrls!.isEmpty) return [];
    final startIndex = _currentImagePage * 3;
    final endIndex = (startIndex + 3).clamp(0, viewModel.capturedImageUrls!.length);
    return viewModel.capturedImageUrls!.sublist(startIndex, endIndex);
  }

  int _getTotalPages(TicketHistoryViewModel viewModel) {
    if (viewModel.capturedImageUrls == null || viewModel.capturedImageUrls!.isEmpty) return 0;
    return (viewModel.capturedImageUrls!.length / 3).ceil();
  }

  Widget _buildActionButton(TicketHistoryViewModel viewModel, S strings) {
    if (viewModel.ticket == null || viewModel.ticket!.status != Status.Completed) {
      return const SizedBox.shrink();
    }

    final bool disputeRaised = viewModel.ticket!.disputeStatus == 'Raised';
    developer.log('Dispute Raised: $disputeRaised for ticket ${viewModel.ticket!.ticketId}',
        name: 'ViewTicketScreen.ActionButton');

    return Card(
      elevation: Theme.of(context).cardTheme.elevation,
      margin: Theme.of(context).cardTheme.margin,
      shape: Theme.of(context).cardTheme.shape,
      color: Theme.of(context).cardColor,
      child: InkWell(
        onTap: () async {
          if (disputeRaised) {
            developer.log('Navigating to view dispute screen for ticketId: ${widget.ticketId}',
                name: 'ViewTicketScreen.Navigation');
            Navigator.pushNamed(context, AppRoutes.disputeDetail,
                arguments: {'ticketId': widget.ticketId});
          } else {
            developer.log('Preparing to raise dispute for ticketId: ${widget.ticketId}',
                name: 'ViewTicketScreen.Navigation');
            // Await the userId from secure storage
            final userIdStr = await _secureStorage.getUserId();
            final userId = int.tryParse(userIdStr ?? '') ?? 1;
            // Format ticketCreationTime without milliseconds
            final dateFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
            final ticketCreationTime = viewModel.ticket!.createdTime != null
                ? dateFormat.format(viewModel.ticket!.createdTime!.toUtc())
                : dateFormat.format(DateTime.now().toUtc());
            final ticketData = {
              'userId': userId,
              'plazaId': viewModel.ticket!.plazaId ?? 0,
              'ticketCreationTime': ticketCreationTime,
              'vehicleNumber': viewModel.ticket!.vehicleNumber ?? 'UNKNOWN',
              'vehicleType': viewModel.ticket!.vehicleType ?? 'Unknown',
              'parkingDuration': viewModel.ticket!.parkingDuration?.toString() ?? 'Unknown',
              'fareAmount': viewModel.ticket!.fareAmount ?? 0.0,
              'totalCharges': viewModel.ticket!.totalCharges ?? 0.0,
              'exitTime': viewModel.ticket!.exitTime != null
                  ? dateFormat.format(viewModel.ticket!.exitTime!.toUtc())
                  : null,
              'paymentMode': viewModel.ticket!.paymentMode ?? 'Unknown',
            };
            developer.log('Ticket Data for RaiseDisputeDialog: $ticketData',
                name: 'ViewTicketScreen.TicketData');
            showDialog(
              context: context,
              builder: (context) => ChangeNotifierProvider(
                create: (_) => RaiseDisputeViewModel(),
                child: RaiseDisputeDialog(
                  ticketId: widget.ticketId,
                  ticketData: ticketData,
                ),
              ),
            );
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
                    color: Theme.of(context).colorScheme.primary,
                    size: Theme.of(context).iconTheme.size,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    disputeRaised ? strings.buttonViewDispute : strings.buttonRaiseDispute,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.primary,
                size: Theme.of(context).iconTheme.size,
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
              color: value.toLowerCase() == strings.statusSuccess.toLowerCase()
                  ? Colors.green.withOpacity(0.1)
                  : Theme.of(context).colorScheme.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: value.toLowerCase() == strings.statusSuccess.toLowerCase()
                    ? Colors.green
                    : Theme.of(context).colorScheme.error,
                width: 1,
              ),
            ),
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: value.toLowerCase() == strings.statusSuccess.toLowerCase()
                    ? Colors.green
                    : Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
              : Text(
            value.isEmpty ? strings.labelNA : value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
              color: highlight
                  ? (value.toLowerCase() == strings.statusSuccess.toLowerCase()
                  ? Colors.green
                  : Colors.red)
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.9),
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
    );
  }

  PreferredSizeWidget _buildCustomAppBar(TicketHistoryViewModel viewModel, S strings) {
    return CustomAppBar.appBarWithNavigation(
      screenTitle: viewModel.ticket == null
          ? "${strings.titleTicketDetails}\n${strings.labelLoading}"
          : "${strings.titleTicket} #${viewModel.ticket!.ticketRefId ?? strings.labelNA}\n${strings.labelCreated}: ${viewModel.getFormattedCreationTime()}",
      onPressed: () => Navigator.pop(context),
      darkBackground: Theme.of(context).brightness == Brightness.dark,
      fontSize: 14,
      centreTitle: false,
      context: context,
    );
  }

  Widget _buildErrorContent(TicketHistoryViewModel viewModel, S strings) {
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
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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

  Widget _buildPaymentDetails(TicketHistoryViewModel viewModel, S strings) {
    if (viewModel.ticket == null) return const SizedBox.shrink();
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
                Text(
                  strings.labelPaymentDetails,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
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
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: _getStatusColor(strings.statusPending.toLowerCase()),
                      fontWeight: FontWeight.w600,
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
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  viewModel.ticket!.totalCharges != null
                      ? '₹${viewModel.ticket!.totalCharges}'
                      : '₹0',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              viewModel.getFormattedCreationTime(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketDetails(TicketHistoryViewModel viewModel, S strings) {
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
                color: _getStatusColor(viewModel.ticket!.status.toString().split('.').last.toLowerCase())
                    .withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color:
                  _getStatusColor(viewModel.ticket!.status.toString().split('.').last.toLowerCase()),
                  width: 1.5,
                ),
              ),
              child: Text(
                viewModel.ticket!.status.toString().split('.').last,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color:
                  _getStatusColor(viewModel.ticket!.status.toString().split('.').last.toLowerCase()),
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
                      value: viewModel.ticket!.vehicleNumber ?? strings.labelNA,
                      strings: strings,
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      title: strings.labelVehicleType,
                      value: viewModel.ticket!.vehicleType ?? strings.labelNA,
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
                      value: '${strings.labelPlaza} ${viewModel.ticket!.plazaId ?? strings.labelNA}',
                      strings: strings,
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      title: strings.labelEntryLane,
                      value: viewModel.ticket!.entryLaneId ?? strings.labelNA,
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
                      value: viewModel.ticket!.floorId ?? strings.labelNA,
                      strings: strings,
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      title: strings.labelSlotId,
                      value: viewModel.ticket!.slotId ?? strings.labelNA,
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
                    value: viewModel.ticket!.parkingDuration?.toString() ?? strings.labelNA,
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
      ),
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
        return Theme.of(context).colorScheme.onSurface.withOpacity(0.6);
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
            child: viewModel.isLoading
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