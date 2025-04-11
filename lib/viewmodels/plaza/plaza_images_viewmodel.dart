import 'dart:io';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:merchant_app/generated/l10n.dart';
import 'package:merchant_app/services/utils/image_service.dart';
import 'package:merchant_app/utils/components/snackbar.dart';
import 'package:merchant_app/utils/exceptions.dart';

class PlazaImagesViewModel extends ChangeNotifier {
  final ImagePicker _picker = ImagePicker();
  final ImageService _imageService = ImageService();

  static const int _maxImagesAllowed = 5;
  static const int _imageQuality = 80;

  List<XFile> plazaImages = [];
  Map<String, String?> errors = {};
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  int get maxImages => _maxImagesAllowed;

  PlazaImagesViewModel() {
    developer.log('[PlazaImagesViewModel] Initialized.', name: 'PlazaImagesViewModel');
  }

  Future<void> pickImages(BuildContext context, {ImageSource source = ImageSource.gallery}) async {
    errors.clear();
    notifyListeners();
    int currentImageCount = plazaImages.length;
    int availableSlots = _maxImagesAllowed - currentImageCount;
    if (availableSlots <= 0) {
      developer.log('[PlazaImagesViewModel] Max image limit ($_maxImagesAllowed) reached. Cannot pick more.', name: 'PlazaImagesViewModel.pickImages');
      errors['images'] = S.of(context).messageErrorMaxImagesReached;
      notifyListeners();
      if (context.mounted) {
        AppSnackbar.showSnackbar(context: context, message: errors['images']!, type: SnackbarType.warning);
      }
      return;
    }
    developer.log('[PlazaImagesViewModel] Attempting to pick images from $source. Available slots: $availableSlots', name: 'PlazaImagesViewModel.pickImages');
    try {
      List<XFile> newlyPickedFiles = [];
      if (source == ImageSource.gallery) {
        newlyPickedFiles = await _picker.pickMultiImage(imageQuality: _imageQuality);
        developer.log('[PlazaImagesViewModel] Picked ${newlyPickedFiles.length} files from gallery.', name: 'PlazaImagesViewModel.pickImages');
      } else {
        final XFile? pickedFile = await _picker.pickImage(source: source, imageQuality: _imageQuality);
        if (pickedFile != null) {
          newlyPickedFiles.add(pickedFile);
          developer.log('[PlazaImagesViewModel] Picked 1 file from camera: ${pickedFile.name}', name: 'PlazaImagesViewModel.pickImages');
        } else {
          developer.log('[PlazaImagesViewModel] No file picked from camera.', name: 'PlazaImagesViewModel.pickImages');
        }
      }
      if (newlyPickedFiles.isNotEmpty) {
        List<XFile> filesToAdd = newlyPickedFiles.take(availableSlots).toList();
        plazaImages.addAll(filesToAdd);
        developer.log('[PlazaImagesViewModel] Added ${filesToAdd.length} images. Total now: ${plazaImages.length}', name: 'PlazaImagesViewModel.pickImages');
        if (newlyPickedFiles.length > filesToAdd.length) {
          developer.log('[PlazaImagesViewModel] User picked more images than allowed slots. Limited to $availableSlots.', name: 'PlazaImagesViewModel.pickImages');
          if (context.mounted) {
            AppSnackbar.showSnackbar(context: context, message: S.of(context).messageWarningImagesLimited, type: SnackbarType.info);
          }
        }
        notifyListeners();
      }
    } on PlatformException catch (e) {
      developer.log('[PlazaImagesViewModel] PlatformException picking images: ${e.code} - ${e.message}', name: 'PlazaImagesViewModel.pickImages', error: e);
      errors['images'] = S.of(context).messageErrorPickingImagesPlatform;
      notifyListeners();
      if (context.mounted) {
        AppSnackbar.showSnackbar(context: context, message: errors['images']!, type: SnackbarType.error);
      }
    } catch (e, stackTrace) {
      developer.log('[PlazaImagesViewModel] Unexpected error picking images: $e', error: e, stackTrace: stackTrace, name: 'PlazaImagesViewModel.pickImages', level: 1000);
      errors['images'] = S.of(context).messageErrorPickingImages;
      notifyListeners();
      if (context.mounted) {
        AppSnackbar.showSnackbar(context: context, message: errors['images']!, type: SnackbarType.error);
      }
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < plazaImages.length) {
      final removedFileName = plazaImages[index].name;
      plazaImages.removeAt(index);
      developer.log('[PlazaImagesViewModel] Removed image at index $index: $removedFileName. Total now: ${plazaImages.length}', name: 'PlazaImagesViewModel.removeImage');
      if (errors.containsKey('images')) errors.remove('images');
      if (errors.isEmpty) errors.remove('general');
      notifyListeners();
    } else {
      developer.log('[PlazaImagesViewModel] Invalid index ($index) for image removal.', name: 'PlazaImagesViewModel.removeImage', level: 900);
    }
  }

  bool _validateForSave(BuildContext context) {
    errors.clear();
    developer.log('[PlazaImagesViewModel] Validating image selection for save...', name: 'PlazaImagesViewModel._validateForSave');
    if (plazaImages.isEmpty) {
      errors['images'] = S.of(context).validationAtLeastOneImage;
      developer.log('[PlazaImagesViewModel] Validation failed: No images selected.', name: 'PlazaImagesViewModel._validateForSave');
      notifyListeners();
      return false;
    }
    if (plazaImages.length > _maxImagesAllowed) {
      errors['images'] = S.of(context).messageErrorMaxImagesReached;
      developer.log('[PlazaImagesViewModel] Validation failed: Exceeds max image limit (${plazaImages.length} > $_maxImagesAllowed).', name: 'PlazaImagesViewModel._validateForSave');
      notifyListeners();
      return false;
    }
    developer.log('[PlazaImagesViewModel] Validation successful for save (${plazaImages.length} images).', name: 'PlazaImagesViewModel._validateForSave');
    return true;
  }

  Future<bool> savePlazaImages(BuildContext context, String plazaId) async {
    developer.log('[PlazaImagesViewModel] Attempting savePlazaImages (Upload) for plazaId: $plazaId with ${plazaImages.length} images.', name: 'PlazaImagesViewModel.savePlazaImages');
    if (!_validateForSave(context)) {
      _setLoading(false);
      return false;
    }
    _setLoading(true);
    final List<File> imageFiles = plazaImages.map((xFile) => File(xFile.path)).toList();
    try {
      developer.log('[PlazaImagesViewModel] Calling imageService.uploadMultipleImages...', name: 'PlazaImagesViewModel.savePlazaImages');
      await _imageService.uploadMultipleImages(plazaId, imageFiles);
      developer.log('[PlazaImagesViewModel] Successfully uploaded ${imageFiles.length} images for Plaza ID: $plazaId.', name: 'PlazaImagesViewModel.savePlazaImages');
      errors.clear();
      _setLoading(false);
      notifyListeners();
      return true;
    } on HttpException catch (e) {
      developer.log('[PlazaImagesViewModel] HttpException during upload: ${e.message}', name: 'PlazaImagesViewModel.savePlazaImages', error: e);
      _handleServiceError(context, e, S.of(context).messageErrorSavingImages);
      _setLoading(false);
      return false;
    } on PlazaException catch (e) {
      developer.log('[PlazaImagesViewModel] PlazaException during upload: ${e.message}', name: 'PlazaImagesViewModel.savePlazaImages', error: e);
      _handleServiceError(context, e, S.of(context).messageErrorSavingImages);
      _setLoading(false);
      return false;
    } on ServiceException catch (e) {
      developer.log('[PlazaImagesViewModel] ServiceException during upload: ${e.message}', name: 'PlazaImagesViewModel.savePlazaImages', error: e);
      _handleServiceError(context, e, S.of(context).messageErrorSavingImages);
      _setLoading(false);
      return false;
    } on RequestTimeoutException catch (e) {
      developer.log('[PlazaImagesViewModel] TimeoutException during upload', name: 'PlazaImagesViewModel.savePlazaImages', error: e);
      _handleServiceError(context, e, S.of(context).errorTimeout);
      _setLoading(false);
      return false;
    } on NoInternetException catch (e) {
      developer.log('[PlazaImagesViewModel] NoInternetException during upload', name: 'PlazaImagesViewModel.savePlazaImages', error: e);
      _handleServiceError(context, e, S.of(context).errorNoInternet);
      _setLoading(false);
      return false;
    } on ServerConnectionException catch (e) {
      developer.log('[PlazaImagesViewModel] ServerConnectionException during upload', name: 'PlazaImagesViewModel.savePlazaImages', error: e);
      _handleServiceError(context, e, S.of(context).errorServerConnection);
      _setLoading(false);
      return false;
    } catch (e, stackTrace) {
      developer.log('[PlazaImagesViewModel] UNEXPECTED Error uploading images', error: e, stackTrace: stackTrace, name: 'PlazaImagesViewModel.savePlazaImages', level: 1200);
      _handleGenericError(context, e);
      _setLoading(false);
      return false;
    }
  }

  void _handleServiceError(BuildContext context, Exception e, String defaultMessage) {
    String errorMessage = defaultMessage;
    int? statusCode;
    if (e is HttpException) {
      errorMessage = e.serverMessage ?? e.message;
      statusCode = e.statusCode;
    } else if (e is ServiceException) {
      errorMessage = e.serverMessage ?? e.message;
      statusCode = e.statusCode;
    } else if (e is PlazaException) {
      errorMessage = e.serverMessage ?? e.message;
      statusCode = e.statusCode;
    } else if (e is RequestTimeoutException) {
      errorMessage = S.of(context).errorTimeout;
    } else if (e is NoInternetException) {
      errorMessage = S.of(context).errorNoInternet;
    } else if (e is ServerConnectionException) {
      errorMessage = S.of(context).errorServerConnection;
    } else {
      errorMessage = S.of(context).errorUnexpected;
    }
    developer.log('[PlazaImagesViewModel] Handling Service Error: ${e.runtimeType} - "$errorMessage" ${statusCode != null ? '(Status: $statusCode)' : ''}', error: e, name: 'PlazaImagesViewModel._handleServiceError', level: 900);
    errors['general'] = errorMessage;
    if (context.mounted) {
      AppSnackbar.showSnackbar(context: context, message: errorMessage, type: SnackbarType.error);
    }
    notifyListeners();
  }

  void _handleGenericError(BuildContext context, dynamic e) {
    final message = S.of(context).errorUnexpected;
    errors['general'] = message;
    if (context.mounted) {
      AppSnackbar.showSnackbar(context: context, message: message, type: SnackbarType.error);
    }
    notifyListeners();
  }

  void _setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      developer.log('[PlazaImagesViewModel] isLoading set to: $_isLoading', name: 'PlazaImagesViewModel');
      if (_isLoading && errors.containsKey('general')) {
        errors.remove('general');
      }
      notifyListeners();
    }
  }

  void clearFieldsAndNotify() {
    developer.log('[PlazaImagesViewModel] Clearing state (images, errors)...', name: 'PlazaImagesViewModel.clearFieldsAndNotify');
    plazaImages.clear();
    errors.clear();
    _isLoading = false;
    developer.log('[PlazaImagesViewModel] State cleared.', name: 'PlazaImagesViewModel.clearFieldsAndNotify');
  }

  void resetToInitialState() {
    developer.log('[PlazaImagesViewModel] Resetting to initial empty state.', name: 'PlazaImagesViewModel.resetToInitialState');
    plazaImages.clear();
    errors.clear();
    _isLoading = false;
  }

  @override
  void dispose() {
    developer.log('[PlazaImagesViewModel] Disposing...', name: 'PlazaImagesViewModel');
    super.dispose();
    developer.log('[PlazaImagesViewModel] Dispose complete.', name: 'PlazaImagesViewModel');
  }
}