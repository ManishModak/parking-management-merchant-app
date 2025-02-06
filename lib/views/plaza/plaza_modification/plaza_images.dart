import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import '../../../viewmodels/plaza_viewmodel/plaza_viewmodel.dart';

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
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildContent(PlazaFormState formState, PlazaViewModel viewModel) {
    return Column(
      children: [
        Consumer<PlazaViewModel>(
          builder: (context, viewModel, _) {
            final plazaName =
                viewModel.formState.basicDetails['plazaName'] ??
                    'Unknown Plaza';
            final plazaId = viewModel.plazaId ?? "Unknown ID";
            return Card(
              margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
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
                            "$plazaName",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            "ID: $plazaId",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
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
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImage(String imagePath) {
    print('Building image: $imagePath');
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

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: imagePath.startsWith('http')
          ? Image.network(
        imagePath,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, progress) {
          return progress == null
              ? child
              : const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (_, __, ___) {
          print('Image failed: $imagePath');
          return errorWidget;
        },
      )
          : Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) {
          print('Image failed: $imagePath');
          return errorWidget;
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
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

    return Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.only(bottom: 16.0),
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
    );
  }

  Widget _buildImageGrid(List<String> images, PlazaViewModel viewModel) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = 2;
        final spacing = 8.0;
        final availableWidth = constraints.maxWidth - (spacing * (crossAxisCount - 1));
        final itemWidth = availableWidth / crossAxisCount;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: 1,
          ),
          itemCount: images.length,
          itemBuilder: (context, index) => SizedBox(
            width: itemWidth,
            height: itemWidth,
            child: _buildGridItem(images[index], viewModel),
          ),
        );
      },
    );
  }

  Widget _buildGridItem(String imageUrl, PlazaViewModel viewModel) {
    print('Attempting to load image: $imageUrl');
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildImage(imageUrl),
          if (isRemoveMode)
            Positioned(
              right: 4,
              top: 4,
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => viewModel.removeImage(imageUrl),
              ),
            )
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
            onPressed: () {
              setState(() {
                viewModel.saveImages(context, wantPop: false);
                isAddMode = false;
              });
            },
            backgroundColor: Colors.green,
            child: const Icon(Icons.check, color: Colors.white),
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
            child: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      );
    } else if (isRemoveMode) {
      return FloatingActionButton(
        onPressed: toggleRemoveMode,
        backgroundColor: Colors.green,
        child: const Icon(Icons.check, color: Colors.white),
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'add',
            onPressed: () => enterAddMode(viewModel),
            backgroundColor: Colors.green,
            child: const Icon(Icons.add_photo_alternate, color: Colors.white),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            heroTag: 'remove',
            onPressed: toggleRemoveMode,
            backgroundColor: Colors.red,
            child: const Icon(Icons.remove_circle_outline, color: Colors.white),
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
        );
      },
    );
  }
}