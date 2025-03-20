import 'dart:developer' as developer;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/app_config.dart';
import '../../../../utils/components/appbar.dart';
import '../../../../utils/exceptions.dart';
import '../../../viewmodels/ticket/mark_exit_viewmodel.dart';

class MarkExitDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> ticket;

  const MarkExitDetailsScreen({super.key, required this.ticket});

  @override
  State<MarkExitDetailsScreen> createState() => _MarkExitDetailsScreenState();
}

class _MarkExitDetailsScreenState extends State<MarkExitDetailsScreen> {
  int _currentImagePage = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<MarkExitViewModel>(context, listen: false);
      viewModel.markTicketAsExited(widget.ticket['ticketID']);
    });
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
            children: [
              InteractiveViewer(
                boundaryMargin: const EdgeInsets.all(20.0),
                minScale: 0.5,
                maxScale: 4.0,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(color: Colors.grey.shade300),
                  ),
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

  Widget _buildImageSection(MarkExitViewModel viewModel) {
    developer.log('[MarkExitDetailsScreen] Building image section with capturedImageUrls: ${viewModel.ticketDetails?['captured_images']}', name: 'MarkExitDetailsScreen');
    if (viewModel.isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(height: 150, color: Colors.grey.shade300),
        ),
      );
    }

    final capturedImageUrls = viewModel.ticketDetails?['captured_images'] as List<String>? ?? [];
    if (capturedImageUrls.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        child: SizedBox(
          height: 150,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_not_supported, size: 48, color: AppColors.primary),
                const SizedBox(height: 8),
                const Text('No Images Available', style: TextStyle(color: Colors.red, fontSize: 16)),
              ],
            ),
          ),
        ),
      );
    }

    final totalImages = capturedImageUrls.length;
    final totalPages = (totalImages / 3).ceil();
    final startIndex = _currentImagePage * 3;
    final endIndex = (startIndex + 3) > totalImages ? totalImages : (startIndex + 3);
    final currentImages = capturedImageUrls.sublist(startIndex, endIndex);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Captured Images', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: currentImages.length,
              itemBuilder: (context, index) {
                final imageUrl = currentImages[index];
                developer.log('[MarkExitDetailsScreen] Rendering image at index $index: $imageUrl', name: 'MarkExitDetailsScreen');
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Container(
                    width: AppConfig.deviceWidth / 3 - 16,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: GestureDetector(
                        onTap: () => _showZoomableImageDialog(imageUrl),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Colors.grey.shade300,
                            highlightColor: Colors.grey.shade100,
                            child: Container(color: Colors.grey.shade300),
                          ),
                          errorWidget: (context, url, error) => Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.broken_image_outlined, size: 48, color: AppColors.primary),
                                const SizedBox(height: 8),
                                Text('Failed to load', style: TextStyle(color: Colors.red, fontSize: 12)),
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
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_left),
                onPressed: _currentImagePage > 0 ? () => setState(() => _currentImagePage--) : null,
              ),
              Text('Page ${_currentImagePage + 1} of $totalPages', style: const TextStyle(fontSize: 14)),
              IconButton(
                icon: const Icon(Icons.arrow_right),
                onPressed: _currentImagePage < totalPages - 1 ? () => setState(() => _currentImagePage++) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(MarkExitViewModel viewModel) {
    String errorTitle = 'Unable to Load Ticket Details';
    String errorMessage = 'Something went wrong. Please try again.';

    final error = viewModel.error;
    if (error != null) {
      developer.log('[MarkExitDetailsScreen] Error occurred: $error');
      if (error is NoInternetException) {
        errorTitle = 'No Internet Connection';
        errorMessage = 'Please check your internet connection and try again.';
      } else if (error is RequestTimeoutException) {
        errorTitle = 'Request Timed Out';
        errorMessage = 'The server is taking too long to respond. Please try again later.';
      } else if (error is HttpException) {
        errorTitle = 'Server Error';
        errorMessage = 'We couldn’t process the request. Please try again.';
        switch (error.statusCode) {
          case 404:
            errorTitle = 'Fare Details Not Found';
            errorMessage = error.serverMessage ?? 'No applicable fare details found for this vehicle type.';
            break;
          case 400:
            errorTitle = 'Invalid Request';
            errorMessage = 'The request was incorrect. Please try again or contact support.';
            break;
          case 401:
            errorTitle = 'Unauthorized';
            errorMessage = 'Please log in again to continue.';
            break;
          case 403:
            errorTitle = 'Access Denied';
            errorMessage = 'You don’t have permission to view this.';
            break;
          case 500:
            errorTitle = 'Server Issue';
            errorMessage = 'There’s a problem on our end. Please try again later.';
            break;
          default:
            errorTitle = 'Unexpected Error';
            errorMessage = error.serverMessage ?? 'An unexpected server issue occurred.';
        }
      } else if (error is ServiceException) {
        errorTitle = 'Service Error';
        errorMessage = 'Failed to process the ticket exit. Please try again.';
      }
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(
            errorTitle,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              errorMessage,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              viewModel.markTicketAsExited(widget.ticket['ticketID']);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MarkExitViewModel>(
      builder: (context, viewModel, child) {
        final ticketData = viewModel.ticketDetails ?? widget.ticket;
        return Scaffold(
          backgroundColor: AppColors.lightThemeBackground,
          appBar: CustomAppBar.appBarWithNavigation(
            screenTitle: 'Mark Exit Details',
            onPressed: () => Navigator.pop(context),
            darkBackground: true, context: context,
          ),
          body: Stack(
            children: [
              viewModel.error != null
                  ? _buildErrorState(viewModel)
                  : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImageSection(viewModel),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Ticket ID', style: TextStyle(fontSize: 16, color: Colors.black)),
                              Text(ticketData['ticket_ref_id'] ?? 'N/A', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 16),
                              Text('Status', style: TextStyle(fontSize: 16, color: Colors.black)),
                              Text(ticketData['status'] ?? 'N/A', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 16),
                              Text('Entry Lane', style: TextStyle(fontSize: 16, color: Colors.black)),
                              Text(ticketData['entry_lane_id'] ?? 'N/A', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 16),
                              Text('Exit Lane', style: TextStyle(fontSize: 16, color: Colors.black)),
                              Text(ticketData['exit_lane_id'] ?? 'Not filled', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 16),
                              Text('Floor ID', style: TextStyle(fontSize: 16, color: Colors.black)),
                              Text(ticketData['floor_id'] ?? 'N/A', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 16),
                              Text('Slot ID', style: TextStyle(fontSize: 16, color: Colors.black)),
                              Text(ticketData['slot_id'] ?? 'N/A', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 16),
                              Text('Vehicle Number', style: TextStyle(fontSize: 16, color: Colors.black)),
                              Text(ticketData['vehicle_number'] ?? 'N/A', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Vehicle Type', style: TextStyle(fontSize: 16, color: Colors.black)),
                              Text(ticketData['vehicle_type'] ?? 'N/A', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 16),
                              Text('Entry Time', style: TextStyle(fontSize: 16, color: Colors.black)),
                              Text(_formatDateTime(ticketData['entry_time']), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 16),
                              Text('Exit Time', style: TextStyle(fontSize: 16, color: Colors.black)),
                              Text(_formatDateTime(ticketData['exit_time']), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 16),
                              Text('Parking Duration', style: TextStyle(fontSize: 16, color: Colors.black)),
                              Text(ticketData['parking_duration']?.toString() ?? 'Calculating...', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 16),
                              Text('Fare Type', style: TextStyle(fontSize: 16, color: Colors.black)),
                              Text(ticketData['fare_type'] ?? 'Pending', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 16),
                              Text('Fare Amount', style: TextStyle(fontSize: 16, color: Colors.black)),
                              Text(ticketData['fare_amount'] ?? 'Pending', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 16),
                              Text('Total Charges', style: TextStyle(fontSize: 16, color: Colors.black)),
                              Text(ticketData['total_charges'] ?? 'Pending', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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

  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return DateFormat('dd/MM/yyyy, hh:mm:ss a').format(dateTime);
    } catch (e) {
      return dateTimeStr;
    }
  }
}