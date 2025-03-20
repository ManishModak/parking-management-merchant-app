import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:merchant_app/services/storage/secure_storage_service.dart';
import '../../config/api_config.dart';
import '../../utils/exceptions.dart';

class ImageService {
  final http.Client _client;
  final String baseUrl = ApiConfig.baseUrl;
  final SecureStorageService _secureStorage = SecureStorageService();

  ImageService({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _secureStorage.getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  String _normalizeUrl(String base, String path) {
    developer.log('[IMAGE] Normalizing URL - Base: $base', name: 'ImageService');
    developer.log('[IMAGE] Normalizing URL - Path: $path', name: 'ImageService');

    String cleanBase = base.trim();
    if (!cleanBase.startsWith('http://') && !cleanBase.startsWith('https://')) {
      cleanBase = 'http://$cleanBase';
    }
    cleanBase = cleanBase.replaceAll(RegExp(r'/+$'), '');

    String cleanPath = path.trim().replaceAll(RegExp(r'^/+'), '');

    if (path.startsWith('http://') || path.startsWith('https://')) {
      String result = path.replaceAll(RegExp(r'/+'), '/');
      developer.log('[IMAGE] Normalized URL (full): $result', name: 'ImageService');
      return result;
    }

    String result = '$cleanBase/$cleanPath';
    developer.log('[IMAGE] Normalized URL: $result', name: 'ImageService');
    return result;
  }

  Future<String> uploadSingleImage(String plazaId, File image) async {
    final fullUrl = ApiConfig.getFullUrl(PlazaApi.uploadSingleImage);
    developer.log('[IMAGE] Uploading single image at URL: $fullUrl', name: 'ImageService');
    developer.log('[IMAGE] Plaza ID: $plazaId', name: 'ImageService');

    try {
      _validateImage(image);
      final headers = await _getHeaders();
      final request = http.MultipartRequest('POST', Uri.parse(fullUrl));
      request.fields['plazaId'] = plazaId;
      request.headers.addAll(headers);

      final extension = path.extension(image.path).toLowerCase().replaceAll('.', '');
      developer.log('[IMAGE] File details - Path: ${image.path}, Extension: $extension', name: 'ImageService');

      final mimeType = switch (extension) {
        'jpg' || 'jpeg' => MediaType('image', 'jpeg'),
        'png' => MediaType('image', 'png'),
        'gif' => MediaType('image', 'gif'),
        _ => throw PlazaException('Unsupported image type: $extension')
      };

      developer.log('[IMAGE] MIME type: ${mimeType.mimeType}', name: 'ImageService');

      final file = await http.MultipartFile.fromPath(
        'image',
        image.path,
        contentType: mimeType,
        filename: path.basename(image.path),
      );
      request.files.add(file);

      developer.log('[IMAGE] Sending request...', name: 'ImageService');
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          developer.log('[IMAGE] Upload timed out after 15 seconds', name: 'ImageService');
          throw RequestTimeoutException('Upload timed out after 15 seconds');
        },
      );

      final response = await http.Response.fromStream(streamedResponse);
      developer.log('[IMAGE] Response Status Code: ${response.statusCode}', name: 'ImageService');
      developer.log('[IMAGE] Response Body: ${response.body}', name: 'ImageService');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final imageUrl = responseData['data']?['imageUrl'] ?? '';
        final normalizedUrl = _normalizeUrl(baseUrl, imageUrl);
        developer.log('[IMAGE] Success - Normalized URL: $normalizedUrl', name: 'ImageService');
        return normalizedUrl;
      } else {
        throw _handleError(response);
      }
    } on TimeoutException catch (e) {
      developer.log('[IMAGE] Timeout while uploading single image: $e', name: 'ImageService');
      throw RequestTimeoutException('Upload timed out: $e');
    } catch (e, stackTrace) {
      developer.log('[IMAGE] Error uploading single image: $e',
          name: 'ImageService', error: e, stackTrace: stackTrace);
      throw _handleError(e);
    }
  }

  Future<List<String>> uploadMultipleImages(String plazaId, List<File> images) async {
    final fullUrl = ApiConfig.getFullUrl(PlazaApi.uploadMultipleImages);
    developer.log('[IMAGE] Uploading multiple images at URL: $fullUrl', name: 'ImageService');
    developer.log('[IMAGE] Plaza ID: $plazaId', name: 'ImageService');
    developer.log('[IMAGE] Number of images: ${images.length}', name: 'ImageService');

    try {
      _validateImages(images);
      final headers = await _getHeaders();
      final request = http.MultipartRequest('POST', Uri.parse(fullUrl));
      request.fields['plazaId'] = plazaId;
      request.headers.addAll(headers);

      for (var (index, image) in images.indexed) {
        final extension = path.extension(image.path).toLowerCase().replaceAll('.', '');
        final mimeType = switch (extension) {
          'jpg' || 'jpeg' => MediaType('image', 'jpeg'),
          'png' => MediaType('image', 'png'),
          'gif' => MediaType('image', 'gif'),
          _ => throw PlazaException('Unsupported image type: $extension')
        };

        final file = await http.MultipartFile.fromPath(
          'images',
          image.path,
          contentType: mimeType,
          filename: path.basename(image.path),
        );
        request.files.add(file);
        developer.log('[IMAGE] Added file $index: ${image.path}', name: 'ImageService');
      }

      developer.log('[IMAGE] Sending request...', name: 'ImageService');
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          developer.log('[IMAGE] Upload timed out after 15 seconds', name: 'ImageService');
          throw RequestTimeoutException('Upload timed out after 15 seconds');
        },
      );

      final response = await http.Response.fromStream(streamedResponse);
      developer.log('[IMAGE] Response Status Code: ${response.statusCode}', name: 'ImageService');
      developer.log('[IMAGE] Response Body: ${response.body}', name: 'ImageService');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final List<dynamic> urls = responseData['data'] ?? [];
        final imageUrls = urls.map((item) {
          final originalUrl = item['imageUrl'].toString();
          final normalizedUrl = _normalizeUrl(baseUrl, originalUrl);
          developer.log('[IMAGE] Normalized URL: $normalizedUrl', name: 'ImageService');
          return normalizedUrl;
        }).toList();
        developer.log('[IMAGE] Successfully uploaded ${imageUrls.length} images', name: 'ImageService');
        return imageUrls;
      } else {
        throw _handleError(response);
      }
    } on TimeoutException catch (e) {
      developer.log('[IMAGE] Timeout while uploading multiple images: $e', name: 'ImageService');
      throw RequestTimeoutException('Upload timed out: $e');
    } catch (e, stackTrace) {
      developer.log('[IMAGE] Error uploading multiple images: $e',
          name: 'ImageService', error: e, stackTrace: stackTrace);
      throw _handleError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getImagesByPlazaId(String plazaId) async {
    final uri = Uri.parse(ApiConfig.getFullUrl(PlazaApi.getImagesByPlaza))
        .replace(queryParameters: {'plazaId': plazaId});
    developer.log('[IMAGE] Fetching images by Plaza ID at URL: $uri', name: 'ImageService');
    developer.log('[IMAGE] Plaza ID: $plazaId', name: 'ImageService');

    try {
      final headers = await _getHeaders();
      developer.log('[IMAGE] Request Headers: $headers', name: 'ImageService');

      final response = await _client
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 30));

      developer.log('[IMAGE] Response Status Code: ${response.statusCode}', name: 'ImageService');
      developer.log('[IMAGE] Response Body: ${response.body}', name: 'ImageService');

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        if (responseBody['success'] == true && responseBody['data'] is List) {
          final List<dynamic> data = responseBody['data'];
          final results = data.map((image) {
            final originalUrl = image['imageUrl'].toString();
            final normalizedUrl = _normalizeUrl(baseUrl, originalUrl);
            return {
              'imageId': image['imageId'].toString(),
              'imageUrl': normalizedUrl,
            };
          }).toList();
          developer.log('[IMAGE] Successfully retrieved ${results.length} images', name: 'ImageService');
          return results;
        } else {
          developer.log('[IMAGE] Unexpected response structure', name: 'ImageService');
          throw PlazaException('Unexpected response structure');
        }
      } else {
        throw _handleError(response);
      }
    } on TimeoutException catch (e) {
      developer.log('[IMAGE] Timeout while fetching images: $e', name: 'ImageService');
      throw RequestTimeoutException('Request timed out while fetching images');
    } catch (e, stackTrace) {
      developer.log('[IMAGE] Error fetching images by plaza ID: $e',
          name: 'ImageService', error: e, stackTrace: stackTrace);
      throw ServiceException('Error fetching images: $e');
    }
  }

  Future<bool> deleteImage(String imageId) async {
    final fullUrl = ApiConfig.getFullUrl('${PlazaApi.deleteImage}$imageId');
    developer.log('[IMAGE] Deleting image at URL: $fullUrl', name: 'ImageService');
    developer.log('[IMAGE] Image ID: $imageId', name: 'ImageService');

    try {
      final headers = await _getHeaders();
      developer.log('[IMAGE] Request Headers: $headers', name: 'ImageService');

      final response = await _client
          .delete(Uri.parse(fullUrl), headers: headers)
          .timeout(const Duration(seconds: 30));

      developer.log('[IMAGE] Response Status Code: ${response.statusCode}', name: 'ImageService');
      developer.log('[IMAGE] Response Body: ${response.body}', name: 'ImageService');

      if (response.statusCode == 200 || response.statusCode == 204) {
        final Map<String, dynamic> responseData = jsonDecode(response.body.isEmpty ? '{}' : response.body);
        final success = responseData['success'] == true || response.statusCode == 204;
        developer.log('[IMAGE] Delete operation ${success ? 'successful' : 'failed'}', name: 'ImageService');
        return success;
      } else {
        throw _handleError(response);
      }
    } on TimeoutException catch (e) {
      developer.log('[IMAGE] Timeout while deleting image: $e', name: 'ImageService');
      throw RequestTimeoutException('Request timed out while deleting image');
    } catch (e, stackTrace) {
      developer.log('[IMAGE] Error deleting image: $e',
          name: 'ImageService', error: e, stackTrace: stackTrace);
      throw ServiceException('Error deleting image: $e');
    }
  }

  bool _validateImage(File image) {
    final extension = image.path.split('.').last.toLowerCase();
    const allowedExtensions = ['jpg', 'jpeg', 'png', 'gif'];
    if (!allowedExtensions.contains(extension)) {
      developer.log('[IMAGE] Invalid image format: $extension', name: 'ImageService');
      throw PlazaException('Invalid image format. Allowed: ${allowedExtensions.join(", ")}');
    }

    const maxSize = 5 * 1024 * 1024; // 5MB
    final fileSize = image.lengthSync();
    if (fileSize > maxSize) {
      developer.log('[IMAGE] Image size exceeds 5MB limit: $fileSize bytes', name: 'ImageService');
      throw PlazaException('Image size exceeds 5MB limit');
    }
    developer.log('[IMAGE] Image validated - Size: $fileSize bytes', name: 'ImageService');
    return true;
  }

  void _validateImages(List<File> images) {
    if (images.isEmpty) {
      developer.log('[IMAGE] No images provided', name: 'ImageService');
      throw PlazaException('No images provided');
    }
    const maxImages = 10;
    if (images.length > maxImages) {
      developer.log('[IMAGE] Too many images: ${images.length} (max: $maxImages)', name: 'ImageService');
      throw PlazaException('Maximum $maxImages images allowed per request');
    }
    for (var image in images) {
      _validateImage(image);
    }
  }

  Exception _handleError(dynamic error) {
    if (error is http.Response) {
      try {
        final errorBody = jsonDecode(error.body);
        final message = errorBody['message'] ?? 'Server error: ${error.statusCode}';
        developer.log('[IMAGE] Server error - Status: ${error.statusCode}, Message: $message',
            name: 'ImageService');
        return HttpException('Server error', statusCode: error.statusCode, serverMessage: message);
      } catch (_) {
        developer.log('[IMAGE] Server error - Status: ${error.statusCode}', name: 'ImageService');
        return HttpException('Server error: ${error.statusCode}', statusCode: error.statusCode);
      }
    }
    developer.log('[IMAGE] Unexpected error: $error', name: 'ImageService');
    return ServiceException('Unexpected error: $error');
  }
}