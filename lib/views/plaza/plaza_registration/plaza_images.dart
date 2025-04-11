import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../generated/l10n.dart';
import '../../../viewmodels/plaza/plaza_images_viewmodel.dart';
import '../../../viewmodels/plaza/plaza_viewmodel.dart';
import 'dart:developer' as developer;

class PlazaImagesStep extends StatelessWidget {
  const PlazaImagesStep({super.key});

  @override
  Widget build(BuildContext context) {
    final imagesVM = context.watch<PlazaViewModel>().plazaImages;
    final strings = S.of(context);
    final theme = Theme.of(context);
    final bool isLoading = imagesVM.isLoading;

    developer.log(
      '[PlazaImagesStep UI Build] isLoading=$isLoading, Image count=${imagesVM.plazaImages.length}, Errors: ${imagesVM.errors.isNotEmpty}',
      name: 'PlazaImagesStep',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              flex: 3,
              child: OutlinedButton.icon(
                icon: Icon(
                  Icons.photo_library_outlined,
                  size: 18,
                  color: isLoading ? theme.disabledColor : theme.colorScheme.primary,
                ),
                label: Text(
                  strings.buttonPickGallery,
                  style: TextStyle(color: isLoading ? theme.disabledColor : theme.colorScheme.primary),
                ),
                onPressed: isLoading
                    ? null
                    : () {
                  developer.log('[PlazaImagesStep] Pick from Gallery button pressed.', name: 'PlazaImagesStep');
                  if (context.mounted) {
                    imagesVM.pickImages(context, source: ImageSource.gallery);
                  }
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: isLoading ? theme.disabledColor : theme.colorScheme.primary),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              flex: 2,
              child: OutlinedButton.icon(
                icon: Icon(
                  Icons.camera_alt_outlined,
                  size: 18,
                  color: isLoading ? theme.disabledColor : theme.colorScheme.primary,
                ),
                label: Text(
                  strings.buttonTakePhoto,
                  style: TextStyle(color: isLoading ? theme.disabledColor : theme.colorScheme.primary),
                ),
                onPressed: isLoading
                    ? null
                    : () {
                  developer.log('[PlazaImagesStep] Take Photo button pressed.', name: 'PlazaImagesStep');
                  if (context.mounted) {
                    imagesVM.pickImages(context, source: ImageSource.camera);
                  }
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: isLoading ? theme.disabledColor : theme.colorScheme.primary),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              strings.messageMaxImagesHint(imagesVM.maxImages),
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
        ),
        if (imagesVM.plazaImages.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              childAspectRatio: 1.0,
            ),
            itemCount: imagesVM.plazaImages.length,
            itemBuilder: (context, index) {
              final image = imagesVM.plazaImages[index];
              return Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.file(
                        File(image.path),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          developer.log(
                            '[PlazaImagesStep] Error loading image preview for ${image.path}: $error',
                            name: 'PlazaImagesStep',
                            level: 900,
                          );
                          return Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Icon(
                              Icons.broken_image_outlined,
                              color: theme.colorScheme.onSurfaceVariant,
                              size: 32,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Material(
                      color: Colors.black.withOpacity(0.65),
                      type: MaterialType.circle,
                      elevation: 1.0,
                      child: InkWell(
                        onTap: isLoading
                            ? null
                            : () {
                          developer.log(
                            '[PlazaImagesStep] Remove image button pressed for index $index.',
                            name: 'PlazaImagesStep',
                          );
                          imagesVM.removeImage(index);
                        },
                        customBorder: const CircleBorder(),
                        child: Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 16,
                            semanticLabel: strings.buttonRemoveImage,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40.0),
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.image_search_outlined,
                  size: 48,
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                ),
                const SizedBox(height: 16),
                Text(
                  strings.messageNoImagesSelected,
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        if (isLoading)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30.0),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 12),
                  Text(
                    strings.messageUploadingImages,
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary),
                  ),
                ],
              ),
            ),
          ),
        if (imagesVM.errors.isNotEmpty && !isLoading)
          Padding(
            padding: const EdgeInsets.only(top: 20.0, bottom: 8.0),
            child: Center(
              child: Text(
                imagesVM.errors['images'] ?? imagesVM.errors['general'] ?? strings.errorUnknown,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }
}