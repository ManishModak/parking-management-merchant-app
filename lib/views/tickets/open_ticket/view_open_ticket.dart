import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_config.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:merchant_app/utils/components/button.dart';
import 'package:merchant_app/utils/components/form_field.dart'; // Added for remarks dialog
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../generated/l10n.dart';
import '../../../services/storage/secure_storage_service.dart';
import '../../../viewmodels/ticket/mark_exit_viewmodel.dart';
import '../../../viewmodels/ticket/open_ticket_viewmodel.dart';
import '../../../viewmodels/ticket/ticket_history_viewmodel.dart';
import '../mark_exit/mark_exit_details.dart';
import '../ticket_history/view_ticket.dart';
import 'modify_open_ticket.dart';
import 'dart:developer' as developer;

class ViewOpenTicketScreen extends StatefulWidget {
  final String ticketId;
  final bool isEditable;

  const ViewOpenTicketScreen({
    super.key,
    required this.ticketId,
    this.isEditable = true,
  });

  @override
  _ViewOpenTicketScreenState createState() => _ViewOpenTicketScreenState();
}

class _ViewOpenTicketScreenState extends State<ViewOpenTicketScreen> {
  int _currentImagePage = 0;
  bool _isImagesExpanded = false;
  String? _userRole;

  static const Map<String, List<String>> _accessRules = {
    'modifyTicket': ['Plaza Owner', 'Plaza Admin', 'Plaza Operator'],
    'markExit': ['Plaza Owner', 'Plaza Admin', 'Plaza Operator'],
    'rejectTicket': [
      'Plaza Owner',
      'Plaza Admin',
      'Plaza Operator'
    ], // New rule
  };

  @override
  void initState() {
    super.initState();
    developer.log(
        'Initializing ViewOpenTicketScreen for ticketId: ${widget.ticketId}',
        name: 'ViewOpenTicketScreen');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      developer.log('Scheduling ticket details fetch and role retrieval',
          name: 'ViewOpenTicketScreen');
      _fetchTicketDetails();
      _fetchUserRole();
    });
  }

  Future<void> _fetchUserRole() async {
    final secureStorage = SecureStorageService();
    try {
      _userRole = await secureStorage.getUserRole();
      developer.log('Fetched user role: $_userRole',
          name: 'ViewOpenTicketScreen');
      if (mounted) setState(() {}); // To rebuild if role affects UI initially
    } catch (e) {
      developer.log('Error fetching user role: $e',
          name: 'ViewOpenTicketScreen', error: e);
      if (mounted) {
        _showErrorSnackBar(S.of(context).errorGeneric, e.toString());
      }
    }
  }

  Future<void> _fetchTicketDetails() async {
    final viewModel = Provider.of<OpenTicketViewModel>(context, listen: false);
    final strings = S.of(context);
    developer.log('Fetching ticket details for ticketId: ${widget.ticketId}',
        name: 'ViewOpenTicketScreen');
    try {
      await viewModel.fetchTicketDetails(widget.ticketId);
      developer.log(
          'Successfully fetched ticket details for ticketId: ${widget.ticketId}',
          name: 'ViewOpenTicketScreen');
    } catch (e) {
      developer.log('Error fetching ticket details: $e',
          name: 'ViewOpenTicketScreen', error: e);
      if (mounted) {
        _showErrorSnackBar(strings.errorLoadTicketDetails, e.toString());
      }
    }
  }

  void _showErrorSnackBar(String message, String error) {
    developer.log('Showing error snackbar: $message - $error',
        name: 'ViewOpenTicketScreen');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$message: $error',
            style: Theme.of(context).snackBarTheme.contentTextStyle),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).snackBarTheme.backgroundColor,
        action: SnackBarAction(
          label: S.of(context).buttonRetry,
          textColor: Theme.of(context).colorScheme.onSurface,
          onPressed: () {
            developer.log('Retry button pressed in error snackbar',
                name: 'ViewOpenTicketScreen');
            _fetchTicketDetails();
          },
        ),
      ),
    );
  }

  void _showAccessDeniedSnackBar(String action) {
    final strings = S.of(context);
    developer.log('Access denied for $action by role: $_userRole',
        name: 'ViewOpenTicketScreen');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(strings.accessDenied),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _showZoomableImageDialog(String imageUrl) {
    developer.log('Showing zoomable image dialog for URL: $imageUrl',
        name: 'ViewOpenTicketScreen');
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
                  errorWidget: (context, url, error) {
                    developer.log(
                        'Image loading failed for URL: $imageUrl, error: $error',
                        name: 'ViewOpenTicketScreen');
                    return Center(
                      child: Icon(Icons.broken_image_outlined,
                          size: 48, color: Theme.of(context).colorScheme.error),
                    );
                  },
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: Icon(Icons.close,
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimaryContainer), // Adjusted color
                  onPressed: () {
                    developer.log('Closing zoomable image dialog',
                        name: 'ViewOpenTicketScreen');
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // New Dialog for Reject Ticket Remarks
  void _showRejectTicketDialog(OpenTicketViewModel viewModel) {
    final strings = S.of(context);
    developer.log('Showing reject ticket dialog', name: 'ViewOpenTicketScreen');

    // Reset remarks and errors in ViewModel before showing dialog
    viewModel.resetRemarks();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        // Use a different context name
        return StatefulBuilder(// To update error text within the dialog
            builder: (stfContext, stfSetState) {
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              width: AppConfig.deviceWidth * 0.9,
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      strings.buttonRejectTicket ??
                          "Reject Ticket", // Assuming l10n string
                      style: Theme.of(dialogContext).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  CustomFormFields.largeSizedTextFormField(
                    label: strings.labelRemarks,
                    controller: viewModel.remarksController,
                    enabled: true,
                    context: dialogContext, // Pass dialogContext here
                    errorText: viewModel.remarksError,
                    onChanged: (_) {
                      // Clear error as user types or re-validate if desired
                      if (viewModel.remarksError != null) {
                        viewModel
                            .validateRejectForm(); // Re-validate to clear error if condition met
                        stfSetState(() {}); // Update dialog UI
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          developer.log('Reject ticket dialog cancelled',
                              name: 'ViewOpenTicketScreen');
                          Navigator.pop(dialogContext);
                        },
                        child: Text(strings.buttonCancel),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: viewModel.isLoading
                            ? null
                            : () async {
                                developer.log('Submit reject ticket tapped',
                                    name: 'ViewOpenTicketScreen');
                                if (viewModel.validateRejectForm()) {
                                  Navigator.pop(
                                      dialogContext); // Close dialog first
                                  final success =
                                      await viewModel.rejectTicket();
                                  if (mounted) {
                                    // Check if widget is still in tree
                                    if (success) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(strings
                                              .messageTicketRejectedSuccess),
                                          backgroundColor: Colors.green,
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                      Navigator.pop(
                                          context); // Pop ViewOpenTicketScreen
                                    } else {
                                      _showErrorSnackBar(
                                        strings.errorFailedToRejectTicket,
                                        viewModel.apiError ??
                                            strings.errorUnknown,
                                      );
                                    }
                                  }
                                } else {
                                  stfSetState(
                                      () {}); // Update dialog UI to show validation error
                                }
                              },
                        child: viewModel.isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(dialogContext)
                                        .colorScheme
                                        .onPrimary,
                                  ),
                                ),
                              )
                            : Text(strings.buttonSubmit),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildShimmerPlaceholder(
      {double width = double.infinity, double height = 20}) {
    developer.log('Building shimmer placeholder: width=$width, height=$height',
        name: 'ViewOpenTicketScreen');
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
    developer.log('Building loading state UI', name: 'ViewOpenTicketScreen');
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
                              _buildShimmerFieldPair(strings.labelEntryLane)),
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
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                          child: _buildShimmerFieldPair(strings.labelSlotId)),
                      const SizedBox(width: 20),
                      Expanded(
                          child: _buildShimmerFieldPair(
                              strings.labelEntryLaneDirection)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                          child: _buildShimmerFieldPair(
                              strings.labelTicketCreationTime)),
                      const SizedBox(width: 20),
                      Expanded(
                          child: _buildShimmerFieldPair(
                              strings.labelModificationTime)),
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
                    height: 150,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: List.generate(
                        3,
                        (index) => Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: _buildShimmerPlaceholder(
                            width: (AppConfig.deviceWidth - 70) / 3,
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
            // Shimmer for Mark Exit Button
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
                      _buildShimmerPlaceholder(width: 32, height: 32),
                      const SizedBox(width: 12),
                      _buildShimmerPlaceholder(width: 120, height: 24),
                    ],
                  ),
                  _buildShimmerPlaceholder(width: 24, height: 24),
                ],
              ),
            ),
          ),
          Card(
            // Shimmer for Reject Ticket Button
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
                      _buildShimmerPlaceholder(width: 32, height: 32),
                      const SizedBox(width: 12),
                      _buildShimmerPlaceholder(width: 120, height: 24),
                    ],
                  ),
                  _buildShimmerPlaceholder(width: 24, height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerFieldPair(String label) {
    developer.log('Building shimmer field pair for label: $label',
        name: 'ViewOpenTicketScreen');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildShimmerPlaceholder(width: 110, height: 16),
        const SizedBox(height: 10),
        _buildShimmerPlaceholder(height: 22),
      ],
    );
  }

  Widget _buildImageSection(OpenTicketViewModel viewModel, S strings) {
    final imageCount = viewModel.capturedImageUrls?.length ?? 0;
    developer.log('Building image section, image count: $imageCount',
        name: 'ViewOpenTicketScreen');
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
            if (imageCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$imageCount',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
          ],
        ),
        initiallyExpanded: false, // Default to collapsed
        onExpansionChanged: (expanded) {
          developer.log('Image section expansion changed: $expanded',
              name: 'ViewOpenTicketScreen');
          setState(() => _isImagesExpanded = expanded);
        },
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
                if (imageCount == 0)
                  SizedBox(
                    height: 150,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                              Icons
                                  .image_not_supported_outlined, // Changed icon
                              size: 48,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant
                                  .withOpacity(0.6)), // Adjusted color
                          const SizedBox(height: 8),
                          Text(
                            strings.messageNoImagesAvailable,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant // Adjusted color
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
                        developer.log(
                            'Building image item $index with URL: $imageUrl',
                            name: 'ViewOpenTicketScreen');
                        final imageWidth = (AppConfig.deviceWidth - 64) /
                            3; // Adjusted for padding
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Container(
                            width: imageWidth,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outline
                                      .withOpacity(0.5)), // Adjusted border
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(11),
                              child: GestureDetector(
                                onTap: () {
                                  developer.log(
                                      'Image tapped at index $index: $imageUrl',
                                      name: 'ViewOpenTicketScreen');
                                  _showZoomableImageDialog(imageUrl);
                                },
                                child: CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  fit: BoxFit.cover,
                                  memCacheWidth:
                                      300, // Optional: for performance
                                  placeholder: (context, url) =>
                                      _buildShimmerPlaceholder(
                                          width: imageWidth, height: 150),
                                  errorWidget: (context, url, error) {
                                    developer.log(
                                        'Image loading failed: $url, error: $error',
                                        name: 'ViewOpenTicketScreen');
                                    return Center(
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
                                              strings.errorImageLoadFailed ??
                                                  "Load Error", // Use a shorter error message
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
                                          // Removed retry button from individual image to simplify
                                        ],
                                      ),
                                    );
                                  },
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
                              ? () {
                                  developer.log(
                                      'Previous image page tapped, current: $_currentImagePage',
                                      name: 'ViewOpenTicketScreen');
                                  setState(() => _currentImagePage--);
                                }
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
                                  ? () {
                                      developer.log(
                                          'Next image page tapped, current: $_currentImagePage',
                                          name: 'ViewOpenTicketScreen');
                                      setState(() => _currentImagePage++);
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

  List<String> _getCurrentImages(OpenTicketViewModel viewModel) {
    if (viewModel.capturedImageUrls == null ||
        viewModel.capturedImageUrls!.isEmpty) {
      developer.log('No images available in viewModel',
          name: 'ViewOpenTicketScreen');
      return [];
    }
    final startIndex = _currentImagePage * 3;
    final endIndex =
        (startIndex + 3).clamp(0, viewModel.capturedImageUrls!.length);
    developer.log(
        'Getting images for page $_currentImagePage: start=$startIndex, end=$endIndex',
        name: 'ViewOpenTicketScreen');
    return viewModel.capturedImageUrls!.sublist(startIndex, endIndex);
  }

  int _getTotalPages(OpenTicketViewModel viewModel) {
    if (viewModel.capturedImageUrls == null ||
        viewModel.capturedImageUrls!.isEmpty) {
      developer.log('Calculating total pages: 0 (no images)',
          name: 'ViewOpenTicketScreen');
      return 0;
    }
    final pages = (viewModel.capturedImageUrls!.length / 3).ceil();
    developer.log('Calculated total pages: $pages',
        name: 'ViewOpenTicketScreen');
    return pages;
  }

  Widget _buildMarkExitActionButton(OpenTicketViewModel viewModel, S strings) {
    if (viewModel.ticket == null) {
      developer.log('No ticket available for mark exit action button',
          name: 'ViewOpenTicketScreen');
      return const SizedBox.shrink();
    }

    developer.log(
        'Building mark exit action button for ticket: ${widget.ticketId}',
        name: 'ViewOpenTicketScreen');
    return Card(
      elevation: Theme.of(context).cardTheme.elevation,
      margin: Theme.of(context).cardTheme.margin,
      shape: Theme.of(context).cardTheme.shape,
      color: Theme.of(context).cardColor,
      child: InkWell(
        onTap: viewModel.isLoading
            ? null
            : () {
                if (_userRole == null ||
                    !_accessRules['markExit']!.contains(_userRole!)) {
                  _showAccessDeniedSnackBar('markExit');
                  return;
                }
                developer.log(
                    'Mark Exit button tapped for ticket: ${widget.ticketId}',
                    name: 'ViewOpenTicketScreen');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangeNotifierProvider(
                      create: (_) => MarkExitViewModel(),
                      child: MarkExitDetailsScreen(ticketId: widget.ticketId),
                    ),
                  ),
                ).then((value) {
                  // value will be true if payment was successful
                  if (value == true) {
                    developer.log(
                        'Returned from MarkExitDetailsScreen with success, replacing screen.',
                        name: 'ViewOpenTicketScreen');
                    // Payment was successful, ticket is no longer "open".
                    // Replace this screen with the historical view of the ticket.
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChangeNotifierProvider(
                          create: (_) => TicketHistoryViewModel(),
                          child: ViewTicketScreen(ticketId: widget.ticketId),
                        ),
                      ),
                    );
                  } else {
                    // No success, just refresh the open ticket details
                    developer.log(
                        'Returned from MarkExitDetailsScreen without success, refreshing details. Returned value: $value',
                        name: 'ViewOpenTicketScreen');
                    _fetchTicketDetails();
                  }
                });
              },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.exit_to_app,
                      color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 12),
                  Text(
                    strings.markExitLabel ?? 'Mark Exit',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              Icon(Icons.chevron_right,
                  color: Theme.of(context).colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }

  // New action button for Reject Ticket
  Widget _buildRejectTicketActionButton(
      OpenTicketViewModel viewModel, S strings) {
    if (viewModel.ticket == null) {
      developer.log('No ticket available for reject action button',
          name: 'ViewOpenTicketScreen');
      return const SizedBox.shrink();
    }

    developer.log(
        'Building reject ticket action button for ticket: ${widget.ticketId}',
        name: 'ViewOpenTicketScreen');
    return Card(
      elevation: Theme.of(context).cardTheme.elevation,
      margin: Theme.of(context).cardTheme.margin,
      shape: Theme.of(context).cardTheme.shape,
      color: Theme.of(context).cardColor,
      child: InkWell(
        onTap: viewModel.isLoading
            ? null
            : () {
                if (_userRole == null ||
                    !_accessRules['rejectTicket']!.contains(_userRole!)) {
                  _showAccessDeniedSnackBar('rejectTicket');
                  return;
                }
                developer.log(
                    'Reject Ticket button tapped for ticket: ${widget.ticketId}',
                    name: 'ViewOpenTicketScreen');
                _showRejectTicketDialog(viewModel);
              },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.block, // Using 'block' icon for reject
                      color: Theme.of(context).colorScheme.error),
                  const SizedBox(width: 12),
                  Text(
                    strings.buttonRejectTicket, // Assuming l10n string exists
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
    developer.log('Building detail item: $title = $value',
        name: 'ViewOpenTicketScreen');
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
                      .withOpacity(0.8), // Adjusted color
                  fontWeight: FontWeight.w500, // Adjusted weight
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
    developer.log('Building compact section: $title',
        name: 'ViewOpenTicketScreen');
    return Card(
      elevation: Theme.of(context).cardTheme.elevation,
      margin: Theme.of(context).cardTheme.margin,
      shape: Theme.of(context).cardTheme.shape,
      color: Theme.of(context).cardColor,
      child: InkWell(
        onTap: widget.isEditable &&
                onTap !=
                    null // Only enable onTap if editable and onTap provided
            ? () {
                if (_userRole == null ||
                    !_accessRules['modifyTicket']!.contains(_userRole!)) {
                  _showAccessDeniedSnackBar('modifyTicket');
                  return;
                }
                onTap.call();
              }
            : null,
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
      OpenTicketViewModel viewModel, S strings) {
    developer.log(
        'Building custom app bar, ticket: ${viewModel.ticket?.ticketRefId ?? "loading"}',
        name: 'ViewOpenTicketScreen');
    return CustomAppBar.appBarWithNavigation(
      screenTitle: viewModel.ticket == null
          ? "${strings.titleTicketDetails}\n${strings.labelLoading}"
          : "${strings.titleTicket} #${viewModel.ticket!.ticketRefId ?? strings.labelNA}\n${strings.labelCreated}: ${viewModel.getFormattedCreationTime()}",
      onPressed: () {
        developer.log('App bar back button pressed',
            name: 'ViewOpenTicketScreen');
        Navigator.pop(context);
      },
      darkBackground: Theme.of(context).brightness == Brightness.dark,
      fontSize: 14,
      centreTitle: false,
      context: context,
    );
  }

  Widget _buildErrorContent(OpenTicketViewModel viewModel, S strings) {
    developer.log(
        'Building error content: ${viewModel.error ?? viewModel.apiError}',
        name: 'ViewOpenTicketScreen');
    return Center(
        child: SingleChildScrollView(
      padding: const EdgeInsets.all(16.0), // Added padding
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline,
              size: 48, color: Theme.of(context).colorScheme.error),
          const SizedBox(height: 16),
          Text(
            strings.errorLoadTicketDetails, // More specific error title
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            viewModel.apiError ??
                viewModel.error?.toString() ??
                strings.errorUnknown,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24), // Increased spacing
          CustomButtons.primaryButton(
            height: 40,
            width: 175,
            text: strings.buttonRetry,
            onPressed: () {
              developer.log('Retry button pressed in error content',
                  name: 'ViewOpenTicketScreen');
              _fetchTicketDetails();
            },
            context: context,
          ),
        ],
      ),
    ));
  }

  Widget _buildTicketDetails(OpenTicketViewModel viewModel, S strings) {
    if (viewModel.ticket == null) {
      developer.log('Ticket is null in buildTicketDetails',
          name: 'ViewOpenTicketScreen');
      // This case should ideally be handled by the loading/error states in the main builder
      // If it reaches here, it's an unexpected state after loading/error.
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            strings.errorNoTicketData,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    developer.log(
        'Building ticket details for ticket: ${viewModel.ticket!.ticketRefId}, imageCount: ${viewModel.capturedImageUrls?.length ?? 0}',
        name: 'ViewOpenTicketScreen');
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          _buildCompactSection(
            title: strings.labelTicketDetails,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        Colors.green.withOpacity(0.15), // Slightly more opaque
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.green.shade600,
                        width: 1.5), // Darker green border
                  ),
                  child: Text(
                    strings.ticketStatusOpen, // Assuming l10n string
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.green.shade700, // Darker green text
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                if (widget.isEditable) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.edit_outlined, // Changed to outlined
                      color: Theme.of(context).colorScheme.primary,
                      size: 20),
                ],
              ],
            ),
            onTap: widget.isEditable // This onTap is for modification
                ? () {
                    developer.log(
                        'Ticket details section tapped for modification',
                        name: 'ViewOpenTicketScreen');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ChangeNotifierProvider<OpenTicketViewModel>.value(
                          value: viewModel, // Pass the existing viewModel
                          child: ModifyViewOpenTicketScreen(
                              ticketId: widget.ticketId),
                        ),
                      ),
                    ).then((modified) {
                      // Check if modification happened
                      developer.log(
                          'Returned from ModifyViewOpenTicketScreen, modified: $modified, refreshing',
                          name: 'ViewOpenTicketScreen');
                      if (modified == true) {
                        // Only refresh if confirmed modification
                        _fetchTicketDetails();
                      }
                    });
                  }
                : null,
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
                      value: viewModel
                              .ticket!.plazaName ?? // Use plazaName from ticket
                          viewModel.ticket!.plazaId?.toString() ??
                          strings.labelNA,
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
                      title: strings.labelEntryTime,
                      value: viewModel.getFormattedEntryTime(),
                      strings: strings,
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      title: strings.labelFloorId,
                      value: viewModel.ticket!.floorId ?? strings.labelNA,
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
                      value: viewModel.ticket!.slotId ?? strings.labelNA,
                      strings: strings,
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      title: strings.labelEntryLaneDirection,
                      value: viewModel.ticket!.entryLaneDirection ??
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
                      title: strings.labelTicketCreationTime,
                      value: viewModel.getFormattedCreationTime(), // Correct
                      strings: strings,
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      // Simplified this part
                      title: strings.labelModificationTime,
                      // CORRECTED LINE: Use the ViewModel's formatted string
                      value: viewModel.getFormattedModificationTime(),
                      strings: strings,
                    ),
                  ),
                ],
              ),
            ],
          ),
          _buildImageSection(viewModel, strings),
          _buildMarkExitActionButton(viewModel, strings),
          _buildRejectTicketActionButton(
              viewModel, strings), // Added Reject Ticket button
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    developer.log('Building ViewOpenTicketScreen widget',
        name: 'ViewOpenTicketScreen');
    // final viewModel = Provider.of<OpenTicketViewModel>(context); // No need to listen here, use Consumer/Selector

    return Scaffold(
      appBar: PreferredSize(
        // Wrap AppBar with PreferredSize to use Consumer
        preferredSize: const Size.fromHeight(
            kToolbarHeight + 20), // Adjust height as needed for multiline title
        child: Consumer<OpenTicketViewModel>(
          builder: (context, vm, child) => _buildCustomAppBar(vm, strings),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () {
          developer.log('Refresh indicator triggered',
              name: 'ViewOpenTicketScreen');
          return _fetchTicketDetails();
        },
        // Use Selector for more granular control if OpenTicketViewModel has many changing parts
        // For this screen, Consumer is fine as most of it depends on ticket data.
        child: Consumer<OpenTicketViewModel>(
          builder: (context, viewModel, child) {
            developer.log(
              'Consumer rebuilding, isLoading: ${viewModel.isLoading}, hasError: ${viewModel.error != null || viewModel.apiError != null}, ticket: ${viewModel.ticket?.ticketId}',
              name: 'ViewOpenTicketScreen',
            );
            if (viewModel.isLoading && viewModel.ticket == null) {
              // Show loading only if ticket is not yet loaded
              return _buildLoadingState(strings);
            }
            if (viewModel.error != null ||
                viewModel.apiError != null && viewModel.ticket == null) {
              // Show error if ticket failed to load
              return _buildErrorContent(viewModel, strings);
            }
            if (viewModel.ticket == null) {
              // Fallback if somehow ticket is null after loading & no error
              return _buildLoadingState(strings); // Or an "empty state"
            }
            return _buildTicketDetails(viewModel, strings);
          },
        ),
      ),
    );
  }
}
