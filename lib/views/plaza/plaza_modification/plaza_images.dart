import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../../viewmodels/plaza/plaza_viewmodel.dart';
import 'package:shimmer/shimmer.dart';

class PlazaImagesModificationScreen extends StatefulWidget {
  const PlazaImagesModificationScreen({super.key});

  @override
  State<PlazaImagesModificationScreen> createState() =>
      _PlazaImagesModificationScreenState();
}

class _PlazaImagesModificationScreenState
    extends State<PlazaImagesModificationScreen> {
  bool isRemoveMode = false;
  bool isAddMode = false;
  String _cacheKeySalt = DateTime.now().millisecondsSinceEpoch.toString();

  void toggleRemoveMode() {
    setState(() {
      isRemoveMode = !isRemoveMode;
    });
  }

  Future<void> enterAddMode(PlazaViewModel viewModel) async {
    setState(() {
      isAddMode = true;
    });

    try {
      await viewModel.pickImages();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick images: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        isAddMode = false;
      });
    }
  }

  Future<void> _refreshImages(PlazaViewModel viewModel) async {
    try {
      setState(() {
        _cacheKeySalt = DateTime.now().millisecondsSinceEpoch.toString();
      });

      if (viewModel.plazaId != null) {
        await viewModel.fetchPlazaImages([viewModel.plazaId!]);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh images: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildContent(PlazaFormState formState, PlazaViewModel viewModel) {
    return Column(
      children: [
        Card(
          margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  Icons.location_city,
                  color: Colors.grey.shade700,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        formState.basicDetails['plazaName'] ?? 'Unknown Plaza',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        "ID: ${viewModel.plazaId ?? 'Unknown ID'}",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildErrorMessage(formState.errors),
                if (formState.plazaImages.isEmpty)
                  _buildEmptyState()
                else
                  _buildImageGrid(formState.plazaImages, viewModel),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImage(String imagePath) {
    debugPrint('Attempting to load image: $imagePath');
    final errorWidget = Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Icon(
          Icons.broken_image,
          size: 48,
          color: Colors.grey,
        ),
      ),
    );

    return imagePath.startsWith('http')
        ? CachedNetworkImage(
      imageUrl: imagePath,
      cacheKey: '$imagePath-$_cacheKeySalt',
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        direction: ShimmerDirection.ltr, // Left-to-right wave
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      errorWidget: (context, url, error) {
        debugPrint('Failed to load image: $imagePath - $error');
        return errorWidget;
      },
      fadeInDuration: const Duration(milliseconds: 300),
    )
        : Image.file(
      File(imagePath),
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Failed to load local image: $imagePath - $error');
        return errorWidget;
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            'No images uploaded yet',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(Map<String, String?> errors) {
    final errorMessage = errors['plazaImages'];
    if (errorMessage == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade700),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                errorMessage,
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGrid(List<String> images, PlazaViewModel viewModel) {
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
      itemBuilder: (context, index) => _buildGridItem(images[index], viewModel),
    );
  }

  Widget _buildGridItem(String imageUrl, PlazaViewModel viewModel) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildImage(imageUrl),
          if (isRemoveMode)
            Positioned(
              right: 4,
              top: 4,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    bool success = await viewModel.removeImage(imageUrl);
                    await _refreshImages(viewModel);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success ? 'Image removed successfully!' : 'Failed to remove image.'),
                        backgroundColor: success ? Colors.green : Colors.red,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(PlazaViewModel viewModel) {
    if (isAddMode) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'save',
            onPressed: () async {
              try {
                await viewModel.saveImages(context, wantPop: false);
                await _refreshImages(viewModel);
                setState(() => isAddMode = false);
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to save images: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            backgroundColor: Colors.green,
            child: const Icon(Icons.check),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            heroTag: 'cancel',
            onPressed: () {
              setState(() {
                isAddMode = false;
                viewModel.formState.plazaImages.removeWhere(
                      (image) => !viewModel.formState.fetchedImages.contains(image),
                );
              });
            },
            backgroundColor: Colors.red,
            child: const Icon(Icons.close),
          ),
        ],
      );
    } else if (isRemoveMode) {
      return FloatingActionButton(
        onPressed: () {
          toggleRemoveMode();
          _refreshImages(viewModel);
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.check),
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'add',
            onPressed: () => enterAddMode(viewModel),
            backgroundColor: Colors.green,
            child: const Icon(Icons.add_photo_alternate),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            heroTag: 'remove',
            onPressed: toggleRemoveMode,
            backgroundColor: Colors.red,
            child: const Icon(Icons.remove_circle_outline),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlazaViewModel>(
      builder: (context, viewModel, child) {
        final formState = viewModel.formState;

        return Scaffold(
          appBar: CustomAppBar.appBarWithNavigation(
            screenTitle: 'Plaza Images',
            onPressed: () => Navigator.pop(context),
            darkBackground: true,
          ),
          backgroundColor: AppColors.lightThemeBackground,
          body: viewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildContent(formState, viewModel),
          floatingActionButton: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildFloatingActionButton(viewModel),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        );
      },
    );
  }
}