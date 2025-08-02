import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../../viewmodels/plaza/plaza_modification_viewmodel.dart';
import 'package:shimmer/shimmer.dart';
import 'package:merchant_app/generated/l10n.dart';
import 'dart:developer' as developer;
import 'package:merchant_app/config/app_theme.dart';
import 'package:merchant_app/utils/components/button.dart';
import 'package:merchant_app/utils/exceptions.dart';
// Import loading screen if needed
import '../../../utils/screens/loading_screen.dart';

class PlazaImagesModificationScreen extends StatefulWidget {
  const PlazaImagesModificationScreen({super.key});

  @override
  State<PlazaImagesModificationScreen> createState() => _PlazaImagesModificationScreenState();
}

class _PlazaImagesModificationScreenState extends State<PlazaImagesModificationScreen> {
  bool _isRemoveMode = false;
  bool _isAddMode = false;
  String _cacheKeySalt = DateTime.now().millisecondsSinceEpoch.toString();
  late String _plazaId;
  bool _isInitialized = false;
  // *** NEW ***
  bool _isInitialLoading = false;

  @override
  void initState() {
    super.initState();
    developer.log('[PlazaImagesModScreen] Initializing State.', name: 'PlazaModify');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      developer.log('[PlazaImagesModScreen] First didChangeDependencies.', name: 'PlazaModify');
      final args = ModalRoute.of(context)?.settings.arguments;
      final potentialPlazaId = args?.toString();
      developer.log('[PlazaImagesModScreen] Received args: $args, potentialPlazaId: $potentialPlazaId', name: 'PlazaModify');

      final strings = S.of(context);

      if (potentialPlazaId == null || potentialPlazaId.isEmpty) {
        developer.log('[PlazaImagesModScreen] Invalid Plaza ID received. Popping back.', name: 'PlazaModify', level: 1000);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(strings.invalidPlazaId)),
            );
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          }
        });
      } else {
        _plazaId = potentialPlazaId;
        developer.log('[PlazaImagesModScreen] Plaza ID set: $_plazaId. Scheduling fetch...', name: 'PlazaModify');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            // *** START CHANGE ***
            _fetchRequiredDetails();
            // *** END CHANGE ***
          }
        });
      }
      _isInitialized = true;
    }
  }

  // *** NEW METHOD ***
  Future<void> _fetchRequiredDetails() async {
    if (!mounted) return;
    developer.log('[PlazaImagesModScreen] Fetching required details (basic & images)...', name: 'PlazaModify');
    setState(() { _isInitialLoading = true; }); // Show loading indicator

    final viewModel = context.read<PlazaModificationViewModel>();
    try {
      // Fetch basic details first for the header card
      await viewModel.fetchBasicPlazaDetails(_plazaId);
      // Then fetch images
      if (mounted) { // Check mounted again
        await viewModel.fetchPlazaImages(_plazaId);
      }
      developer.log('[PlazaImagesModScreen] Successfully fetched required details.', name: 'PlazaModify');
    } catch (e) {
      developer.log('[PlazaImagesModScreen] Error during initial fetch: $e', name: 'PlazaModify', error: e);
      // Error state is handled by the ViewModel
    } finally {
      if (mounted) {
        setState(() { _isInitialLoading = false; }); // Hide loading indicator
      }
    }
  }
  // *** END NEW METHOD ***

  // --- Mode Toggles (No changes needed) ---
  void _toggleRemoveMode() {
    if(!mounted) return;
    setState(() {
      _isRemoveMode = !_isRemoveMode;
      if (_isRemoveMode) {
        _isAddMode = false; // Ensure only one mode is active
      }
      developer.log('[PlazaImagesModScreen] Toggled Remove Mode: $_isRemoveMode', name: 'PlazaModify');
    });
  }

  Future<void> _enterAddMode(PlazaModificationViewModel viewModel, S strings) async {
    if(!mounted) return;
    developer.log('[PlazaImagesModScreen] Entering Add Mode.', name: 'PlazaModify');
    setState(() {
      _isAddMode = true;
      _isRemoveMode = false;
    });

    try {
      developer.log('[PlazaImagesModScreen] Calling pickImages...', name: 'PlazaModify');
      await viewModel.pickImages();
      developer.log('[PlazaImagesModScreen] pickImages finished. New images potentially added to formState.', name: 'PlazaModify');
    } catch (e) {
      developer.log('[PlazaImagesModScreen] Error picking images: $e', name: 'PlazaModify', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings.failedToPickImages(e.toString())), // Use localized string
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        // Revert add mode if picking failed
        setState(() {
          _isAddMode = false;
        });
      }
    }
  }

  void _cancelAddMode(PlazaModificationViewModel viewModel) {
    developer.log('[PlazaImagesModScreen] Cancelling Add Mode.', name: 'PlazaModify');
    setState(() {
      _isAddMode = false;
      viewModel.resetImageState(); // Reset picked images
    });
  }
  // --- End Mode Toggles ---


  // --- Image Actions ---
  Future<void> _refreshImages(PlazaModificationViewModel viewModel, S strings) async {
    if(!mounted || _plazaId.isEmpty) return;
    developer.log('[PlazaImagesModScreen] Refreshing images for plazaId: $_plazaId', name: 'PlazaModify');
    try {
      // Update cache key salt *before* fetching to ensure fresh images
      setState(() {
        _cacheKeySalt = DateTime.now().millisecondsSinceEpoch.toString();
        developer.log('[PlazaImagesModScreen] Cache key salt updated: $_cacheKeySalt', name: 'PlazaModify');
      });

      // *** START CHANGE ***
      // Only fetch images here
      await viewModel.fetchPlazaImages(_plazaId);
      // *** END CHANGE ***

      developer.log('[PlazaImagesModScreen] Image list refreshed from service.', name: 'PlazaModify');
    } catch (e) {
      developer.log('[PlazaImagesModScreen] Error refreshing images: $e', name: 'PlazaModify', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings.failedToRefreshImages(e.toString())), // Use localized string
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _removeImage(PlazaModificationViewModel viewModel, String imageUrl, S strings) async {
    developer.log('[PlazaImagesModScreen] Attempting to remove image: $imageUrl', name: 'PlazaModify');
    bool success = await viewModel.removeImage(imageUrl);
    developer.log('[PlazaImagesModScreen] Removal result: $success', name: 'PlazaModify');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? strings.imageRemovedSuccess : strings.imageRemoveFailed), // Use localized strings
          backgroundColor: success ? Colors.green : Theme.of(context).colorScheme.error,
        ),
      );
      // No need to call _refreshImages here as removeImage updates the state
      // However, ensure removeImage calls notifyListeners()
    }
    // Optional: If removeImage doesn't update state reliably, refresh here
    // if (success) {
    //   await _refreshImages(viewModel, strings);
    // }
  }

  Future<void> _saveImages(PlazaModificationViewModel viewModel, S strings) async {
    developer.log('[PlazaImagesModScreen] Attempting to save images.', name: 'PlazaModify');
    try {
      // ViewModel's saveImages shows success/error messages internally
      await viewModel.saveImages(context, wantPop: true);
      developer.log('[PlazaImagesModScreen] Save operation completed by ViewModel.', name: 'PlazaModify');
      // ViewModel's saveImages should ideally refresh images on success
      // If not, uncomment the refresh call below
      // await _refreshImages(viewModel, strings);
      if(mounted && viewModel.error == null) { // Only exit add mode on success
        setState(() => _isAddMode = false);
      }
    } catch (e) {
      // Error is handled within viewModel.saveImages (shows snackbar)
      developer.log('[PlazaImagesModScreen] Error caught from saveImages: $e', name: 'PlazaModify', error: e);
      // No need for another snackbar here unless saveImages doesn't show one
    }
  }
  // --- End Image Actions ---


  // --- UI Building ---
  Widget _buildContent(PlazaModificationViewModel viewModel, S strings) {
    final formState = viewModel.formState;
    developer.log('[PlazaImagesModScreen] Building content. Image count: ${formState.plazaImages.length}', name: 'PlazaModify');
    final hasBasicDetails = formState.basicDetails.isNotEmpty;

    return Column(
      children: [
        // Show Header Card only if basic details are available
        if (hasBasicDetails)
          Card(
            margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
            elevation: Theme.of(context).cardTheme.elevation ?? 2,
            shape: Theme.of(context).cardTheme.shape,
            color: Theme.of(context).cardColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.location_city,
                    color: Theme.of(context).iconTheme.color?.withOpacity(0.7),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          formState.basicDetails['plazaName'] ?? strings.loadingEllipsis, // Show loading text if name not ready
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.textPrimaryColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "${strings.id}: ${viewModel.plazaId ?? strings.notApplicable}",
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        else if (viewModel.isLoading && !_isAddMode && !_isRemoveMode) // Show placeholder only during initial load
          const SizedBox(height: 60, child: Center(child: Text("Loading Plaza Info..."))),

        const SizedBox(height: 16),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _refreshImages(viewModel, strings),
            color: Theme.of(context).colorScheme.primary,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), // Adjust padding
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildErrorMessage(formState.errors, strings),
                  // Show loading indicator inside grid area if refreshing or saving
                  if (viewModel.isLoading && ! _isInitialLoading)
                    const Center(child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 32.0),
                      child: CircularProgressIndicator(),
                    ))
                  // Show empty state only if not loading and no images
                  else if (formState.plazaImages.isEmpty && !_isAddMode && !viewModel.isLoading)
                    _buildEmptyState(strings)
                  // Otherwise, show the grid
                  else
                    _buildImageGrid(formState.plazaImages, viewModel, strings),
                  const SizedBox(height: 80), // Space for FAB
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImage(String imagePath, S strings) {
    // Error widget remains the same
    final errorWidget = Container(
      // ... error widget definition ...
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image,
              size: 40,
              color: Colors.grey.shade500,
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                strings.errorImageLoadFailed,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
              ),
            )
          ],
        ),
      ),
    );

    bool isNetworkImage = imagePath.startsWith('http');
    developer.log('[PlazaImagesModScreen] Building image. Path: $imagePath, IsNetwork: $isNetworkImage', name: 'PlazaModify');

    // Placeholder for both network and file images while loading/processing
    final placeholderWidget = Shimmer.fromColors(
      baseColor: Theme.of(context).brightness == Brightness.light
          ? AppColors.shimmerBaseLight
          : AppColors.shimmerBaseDark,
      highlightColor: Theme.of(context).brightness == Brightness.light
          ? AppColors.shimmerHighlightLight
          : AppColors.shimmerHighlightDark,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, // Base color for shimmer
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );

    return ClipRRect( // Ensure image respects border radius
        borderRadius: BorderRadius.circular(8.0),
        child: isNetworkImage
            ? CachedNetworkImage(
          imageUrl: imagePath,
          cacheKey: '$imagePath-$_cacheKeySalt', // Use dynamic cache key for refresh
          fit: BoxFit.cover,
          placeholder: (context, url) => placeholderWidget,
          errorWidget: (context, url, error) {
            developer.log('[PlazaImagesModScreen] CachedNetworkImage error loading $url: $error', name: 'PlazaModify', error: error);
            return errorWidget;
          },
        )
            : Image.file(
          File(imagePath),
          fit: BoxFit.cover,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded || frame != null) {
              return child; // Image loaded
            }
            return placeholderWidget; // Show shimmer while file loads
          },
          errorBuilder: (context, error, stackTrace) {
            developer.log('[PlazaImagesModScreen] Image.file error loading $imagePath: $error', name: 'PlazaModify', error: error);
            return errorWidget;
          },
        )
    );
  }

  Widget _buildEmptyState(S strings) {
    // No changes needed
    developer.log('[PlazaImagesModScreen] Building empty state.', name: 'PlazaModify');
    // ... empty state definition ...
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 48,
              color: context.textSecondaryColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              strings.messageNoImagesUploaded,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: context.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorMessage(Map<String, String?> errors, S strings) {
    // No changes needed
    final errorMessage = errors['plazaImages'];
    // ... error message definition ...
    if (errorMessage == null || errorMessage.isEmpty) return const SizedBox.shrink();

    developer.log('[PlazaImagesModScreen] Building error message display: $errorMessage', name: 'PlazaModify');
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).colorScheme.error.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                errorMessage,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGrid(List<String> images, PlazaModificationViewModel viewModel, S strings) {
    // No changes needed
    developer.log('[PlazaImagesModScreen] Building image grid. Count: ${images.length}', name: 'PlazaModify');
    // ... image grid definition ...
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) => _buildGridItem(images[index], viewModel, strings),
    );
  }

  Widget _buildGridItem(String imageUrl, PlazaModificationViewModel viewModel, S strings) {
    // Use the modified _buildImage function
    return Stack(
      fit: StackFit.expand,
      children: [
        _buildImage(imageUrl, strings), // Use the updated image builder
        if (_isRemoveMode)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Align(
                alignment: Alignment.center,
                child: IconButton(
                  icon: const Icon(Icons.delete_forever, color: Colors.redAccent, size: 36),
                  tooltip: strings.buttonRemoveImage,
                  onPressed: () => _removeImage(viewModel, imageUrl, strings),
                  style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withOpacity(0.5),
                      padding: const EdgeInsets.all(12)
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFloatingActionButton(PlazaModificationViewModel viewModel, S strings) {
    // No changes needed
    developer.log('[PlazaImagesModScreen] Building FABs. AddMode: $_isAddMode, RemoveMode: $_isRemoveMode', name: 'PlazaModify');
    // ... FAB definition ...
    if (_isAddMode) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'cancel_add_image',
            tooltip: strings.tooltipCancelChanges,
            onPressed: () => _cancelAddMode(viewModel),
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
            foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
            icon: const Icon(Icons.close),
            label: Text(strings.cancel),
          ),
          const SizedBox(width: 16),
          FloatingActionButton.extended(
            heroTag: 'save_add_image',
            tooltip: strings.tooltipSaveChanges,
            onPressed: () => _saveImages(viewModel, strings),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            icon: const Icon(Icons.check),
            label: Text(strings.save),
          ),
        ],
      );
    } else if (_isRemoveMode) {
      return FloatingActionButton.extended(
        heroTag: 'done_remove_image',
        tooltip: strings.tooltipDone,
        onPressed: _toggleRemoveMode,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        icon: const Icon(Icons.check),
        label: Text(strings.tooltipDone),
      );
    } else {
      // Enable remove button only if there are images
      bool canRemove = viewModel.formState.plazaImages.isNotEmpty;

      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'add_image',
            tooltip: strings.tooltipAddImage,
            onPressed: () => _enterAddMode(viewModel, strings),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            foregroundColor: Theme.of(context).colorScheme.onSecondary,
            child: const Icon(Icons.add_photo_alternate),
          ),
          // Conditionally show remove button
          if (canRemove) ...[
            const SizedBox(width: 16),
            FloatingActionButton(
              heroTag: 'remove_image',
              tooltip: strings.tooltipRemoveImage,
              onPressed: _toggleRemoveMode,
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
              child: const Icon(Icons.remove_circle_outline),
            ),
          ]
        ],
      );
    }
  }

  Widget _buildErrorState(PlazaModificationViewModel viewModel, String plazaId, S strings) {
    Exception? error = viewModel.error;
    String errorTitle = strings.errorTitleDefault;
    String errorMessage = strings.errorMessageDefault;
    String? errorDetails;

    developer.log('[PlazaImagesModScreen] Building error state for plazaId: $plazaId, error: ${error?.runtimeType}', name: 'PlazaModify', error: error);

    if (error is HttpException) {
      final statusCode = error.statusCode;
      errorTitle = statusCode != null ? strings.errorTitleWithCode(statusCode) : strings.errorTitleServer;
      errorMessage = error.message;
      errorDetails = error.serverMessage ?? strings.errorDetailsNoDetails;
    } else if (error is ServiceException) {
      errorTitle = strings.errorTitleService;
      errorMessage = error.message;
      errorDetails = error.serverMessage ?? strings.errorDetailsService;
    } else if (error != null) {
      errorTitle = strings.errorLoadingPlazaDetailsFailed; // Changed title
      errorMessage = strings.errorMessagePleaseTryAgain;
      errorDetails = error.toString();
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.signal_wifi_connected_no_internet_4_outlined, // More relevant icon maybe
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              errorTitle,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (errorDetails != null && errorDetails.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                errorDetails,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            CustomButtons.primaryButton(
              text: strings.retry,
              onPressed: () {
                developer.log('[PlazaImagesModScreen] Retry button pressed for plazaId: $plazaId.', name: 'PlazaModify');
                // *** START CHANGE ***
                // Call the method to fetch both basic and images on retry
                _fetchRequiredDetails();
                // *** END CHANGE ***
              },
              context: context,
              width: 150,
              height: 40,
            ),
          ],
        ),
      ),
    );
  }
  // --- End UI Building ---


  // --- Main Build Method ---
  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);

    // Use Consumer for potentially better performance if only parts need to rebuild often
    return Consumer<PlazaModificationViewModel>(
      builder: (context, viewModel, child) {
        final formState = viewModel.formState;
        developer.log('[PlazaImagesModScreen] Building UI. isInitialLoading: $_isInitialLoading, VMisLoading: ${viewModel.isLoading}, error: ${viewModel.error != null}, AddMode: $_isAddMode, RemoveMode: $_isRemoveMode', name: 'PlazaModify');

        // Determine main body content based on state
        Widget bodyContent;
        if (_isInitialLoading) {
          bodyContent = const LoadingScreen(); // Show full loading screen initially
        } else if (viewModel.error != null && formState.plazaImages.isEmpty && !viewModel.isLoading) {
          // Show error state only if initial load failed AND there are no images to show
          bodyContent = _buildErrorState(viewModel, _plazaId, strings);
        } else {
          // Otherwise, build the main content (which handles internal loading/empty states)
          bodyContent = _buildContent(viewModel, strings);
        }


        return WillPopScope( // Handle back button press during add/remove modes
          onWillPop: () async {
            if (_isAddMode || _isRemoveMode) {
              developer.log('[PlazaImagesModScreen] Back pressed during edit mode. Resetting image state.', name: 'PlazaModify');
              if (_isAddMode) _cancelAddMode(viewModel);
              if (_isRemoveMode) _toggleRemoveMode();
              // Allow back navigation after resetting state
              return true;
            }
            // Allow back navigation if not in edit mode
            return true;
          },
          child: Scaffold(
            appBar: CustomAppBar.appBarWithNavigation(
              screenTitle: strings.titlePlazaImages, // Use localized title
              onPressed: () {
                developer.log('[PlazaImagesModScreen] AppBar back pressed. AddMode: $_isAddMode, RemoveMode: $_isRemoveMode', name: 'PlazaModify');
                if(_isAddMode || _isRemoveMode) {
                  if (_isAddMode) _cancelAddMode(viewModel);
                  if (_isRemoveMode) _toggleRemoveMode();
                }
                Navigator.pop(context);
              },
              darkBackground: Theme.of(context).brightness == Brightness.dark,
              context: context,
            ),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: bodyContent,
            floatingActionButton: _isInitialized && !_isInitialLoading && viewModel.error == null // Show FAB only when initialized, not loading, and no critical error
                ? Padding(
              padding: const EdgeInsets.only(bottom: 16.0, right: 0), // Adjust padding as needed
              child: _buildFloatingActionButton(viewModel, strings),
            )
                : null,
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          ),
        );
      },
    );
  }
// --- End Main Build Method ---

}