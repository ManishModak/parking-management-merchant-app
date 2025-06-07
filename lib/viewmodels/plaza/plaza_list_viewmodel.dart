import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:merchant_app/models/plaza.dart';
import 'package:merchant_app/services/core/plaza_service.dart';
import 'package:merchant_app/services/utils/image_service.dart';

class PlazaListViewModel extends ChangeNotifier {
  final PlazaService _plazaService = PlazaService();
  final ImageService _imageService = ImageService();

  List<Plaza> _userPlazas = [];
  final Map<String, String?> _plazaImages = {};
  bool _isLoading = false;
  Exception? _error;

  List<Plaza> get userPlazas => List.unmodifiable(_userPlazas);
  Map<String, String?> get plazaImages => Map.unmodifiable(_plazaImages);
  bool get isLoading => _isLoading;
  Exception? get error => _error;

  void _setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      developer.log('Loading state set to: $value', name: 'PlazaListViewModel.State');
      notifyListeners();
    }
  }

  void setError(Exception? error) {
    if (_error?.toString() != error?.toString()) {
      _error = error;
      developer.log('Error state set externally: ${error?.runtimeType} - ${error?.toString()}', name: 'PlazaListViewModel.State', level: error == null ? 0 : 900);
      notifyListeners();
    }
  }

  void _clearError() {
    if (_error != null) {
      _error = null;
      developer.log('Error state cleared.', name: 'PlazaListViewModel.State');
      notifyListeners();
    }
  }

  Future<void> fetchUserPlazas(String entityId) async {
    _setLoading(true);
    _clearError();
    developer.log('Fetching plazas for EntityId: $entityId', name: 'PlazaListViewModel');
    try {
      _userPlazas = await _plazaService.fetchUserPlazas(entityId);
      developer.log('Fetched ${_userPlazas.length} plazas successfully', name: 'PlazaListViewModel');
    } catch (e) {
      developer.log('Error in fetchUserPlazas: $e', name: 'PlazaListViewModel', error: e, level: 1000);
      _error = e is Exception ? e : Exception('Error fetching plazas: $e');
      _userPlazas = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchPlazaImages(List<String> plazaIds) async {
    // 1. REMOVED: _clearError(); - Do not clear errors set by other operations.

    final validIds = plazaIds.where((id) => id.isNotEmpty).toList();
    if (validIds.isEmpty) {
      developer.log('No valid plaza IDs provided to fetchPlazaImages', name: 'PlazaListViewModel');
      return; // Nothing to do, no state change expected.
    }

    developer.log('Fetching images for ${validIds.length} plazaIds: $validIds', name: 'PlazaListViewModel');

    bool imagesWereUpdated = false; // Track if any changes were made to _plazaImages
    Exception? imageFetchError; // Store errors specific to *this* function call

    try {
      for (var plazaId in validIds) {
        // Optimization: Skip if image already fetched (and not null)
        // Remove this 'if' if you always want to try fetching again.
        if (_plazaImages.containsKey(plazaId) && _plazaImages[plazaId] != null) {
          developer.log('Skipping image fetch for $plazaId, already cached.', name: 'PlazaListViewModel');
          continue;
        }

        developer.log('Fetching image for plazaId $plazaId...', name: 'PlazaListViewModel');
        try {
          // Fetch image data
          final imageDataList = await _imageService.getImagesByPlazaId(plazaId);
          developer.log('Received ${imageDataList.length} images for plazaId $plazaId', name: 'PlazaListViewModel');

          // Extract URL (handle potential nulls or missing keys safely)
          String? newImageUrl;
          if (imageDataList.isNotEmpty && imageDataList.first.containsKey('imageUrl')) {
            newImageUrl = imageDataList.first['imageUrl'] as String?;
          } else {
            newImageUrl = null; // Explicitly null if no valid image found
          }


          // Update the map directly *if* the URL is different
          if (!_plazaImages.containsKey(plazaId) || _plazaImages[plazaId] != newImageUrl) {
            _plazaImages[plazaId] = newImageUrl;
            imagesWereUpdated = true; // Mark that a change occurred
            developer.log('Updated image cache for $plazaId: ${newImageUrl ?? 'null'}', name: 'PlazaListViewModel');
          }
        } on Exception catch (e) {
          // Handle error for *this specific* image fetch
          developer.log('Error fetching image for plazaId $plazaId: $e', name: 'PlazaListViewModel', error: e, level: 900);

          // Store the first error encountered during this batch
          imageFetchError ??= e;

          // Update map to null to indicate failure for this ID, only if it wasn't already null
          if (!_plazaImages.containsKey(plazaId) || _plazaImages[plazaId] != null) {
            _plazaImages[plazaId] = null;
            imagesWereUpdated = true; // Mark that state changed (to null)
          }
          // Continue to the next plazaId even if one fails
        }
      }
    } catch (e) { // Catch unexpected errors in the loop structure itself
      developer.log('General error during fetchPlazaImages loop: $e', name: 'PlazaListViewModel', error: e, level: 1000);
      // Assign if no specific image error was already caught
      imageFetchError ??= e is Exception ? e : Exception('Image fetch process failed unexpectedly: $e');
      // Don't set imagesWereUpdated here, the error is the primary state change.
    } finally {
      // 2. Update error state ONLY if an error occurred during *this* function
      bool errorStateChanged = false;
      if (imageFetchError != null) {
        // Check if the error is actually different from the current one before setting
        if (_error?.toString() != imageFetchError.toString()) {
          setError(imageFetchError); // Use setError to handle notification
          errorStateChanged = true;
        }
      }

      // 3. Notify listeners *only if needed*
      // Notify if images were updated AND the error state didn't change (setError already notified)
      if (imagesWereUpdated && !errorStateChanged) {
        notifyListeners();
      }
      // If error state changed, setError handled the notification.
      // If neither changed, no notification needed.
    }
  }


void clearPlazaImages() {
    if (_plazaImages.isNotEmpty) {
      _plazaImages.clear();
      developer.log('Plaza images cleared', name: 'PlazaListViewModel');
      notifyListeners();
    }
  }
}