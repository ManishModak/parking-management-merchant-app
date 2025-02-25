import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;

import '../../config/api_config.dart';

class ImageService {
  final String baseUrl = ApiConfig.apiGateway; // http://192.168.1.105:5000/
  final Map<String, String> headers = {
    'Content-Type': 'application/json',
  };

  // In ImageService.dart
  // In ImageService.dart
  String _normalizeUrl(String base, String path) {
    log('[NORMALIZE_URL] Base: $base');
    log('[NORMALIZE_URL] Path: $path');

    String cleanBase = base.trim();
    if (!cleanBase.startsWith('http://') && !cleanBase.startsWith('https://')) {
      cleanBase = 'http://$cleanBase';
    }
    cleanBase = cleanBase.replaceAll(RegExp(r'/+$'), '');

    String cleanPath = path.trim().replaceAll(RegExp(r'^/+'), '');

    if (path.startsWith('http://') || path.startsWith('https://')) {
      String result = path.replaceAll(RegExp(r'/+'), '/');
      log('[NORMALIZE_URL] Result (full URL): $result');
      return result;
    }

    String result = '$cleanBase/$cleanPath';
    log('[NORMALIZE_URL] Result: $result');
    return result;
  }

  Future<String> uploadSingleImage(String plazaId, File image) async {
    try {
      final fullUrl = ApiConfig.getFullUrl(ApiConfig.uploadSingleImageEndpoint);
      log('[UPLOAD IMAGE] Configuration:');
      log('  Base URL: $baseUrl');
      log('  Endpoint: ${ApiConfig.uploadSingleImageEndpoint}');
      log('  Full URL: $fullUrl');
      log('  Plaza ID: $plazaId');

      final request = http.MultipartRequest('POST', Uri.parse(fullUrl));
      request.fields['plazaId'] = plazaId;

      final extension =
          path.extension(image.path).toLowerCase().replaceAll('.', '');
      log('[UPLOAD IMAGE] File details:');
      log('  Original path: ${image.path}');
      log('  Extension: $extension');

      final mimeType = switch (extension) {
        'jpg' || 'jpeg' => MediaType('image', 'jpeg'),
        'png' => MediaType('image', 'png'),
        'gif' => MediaType('image', 'gif'),
        _ => throw Exception(
            'Unsupported image type: $extension. Only jpg, jpeg, png, and gif are allowed.')
      };

      log('  Determined MIME type: ${mimeType.mimeType}');

      final file = await http.MultipartFile.fromPath(
        'image',
        image.path,
        contentType: mimeType,
        filename: path.basename(image.path),
      );

      request.files.add(file);

      log('[UPLOAD IMAGE] Sending request...');
      final streamedResponse = await request.send().timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw TimeoutException(
                'Upload connection timed out after 15 seconds'),
          );

      final response = await http.Response.fromStream(streamedResponse);
      log('[UPLOAD IMAGE] Response received:');
      log('  Status code: ${response.statusCode}');
      log('  Body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final imageUrl = responseData['data']['imageUrl'] ?? '';
        final normalizedUrl = _normalizeUrl(baseUrl, imageUrl);
        log('[UPLOAD IMAGE] Success - Original URL: $imageUrl');
        log('[UPLOAD IMAGE] Success - Normalized URL: $normalizedUrl');
        return normalizedUrl;
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      log('[UPLOAD IMAGE] Error occurred: $e');
      throw _handleError(e);
    }
  }

  Future<List<String>> uploadMultipleImages(
      String plazaId, List<File> images) async {
    try {
      final fullUrl =
          ApiConfig.getFullUrl(ApiConfig.uploadMultipleImagesEndpoint);
      log('[UPLOAD MULTIPLE] Configuration:');
      log('  Full URL: $fullUrl');
      log('  Plaza ID: $plazaId');
      log('  Number of images: ${images.length}');

      final request = http.MultipartRequest('POST', Uri.parse(fullUrl));
      request.fields['plazaId'] = plazaId;

      for (var (index, image) in images.indexed) {
        final extension =
            path.extension(image.path).toLowerCase().replaceAll('.', '');
        final mimeType = switch (extension) {
          'jpg' || 'jpeg' => MediaType('image', 'jpeg'),
          'png' => MediaType('image', 'png'),
          'gif' => MediaType('image', 'gif'),
          _ => throw Exception('Unsupported image type: $extension')
        };

        final file = await http.MultipartFile.fromPath(
          'images',
          image.path,
          contentType: mimeType,
          filename: path.basename(image.path),
        );

        request.files.add(file);
      }

      final streamedResponse = await request.send().timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw TimeoutException(
                'Upload connection timed out after 15 seconds'),
          );

      final response = await http.Response.fromStream(streamedResponse);
      log('[UPLOAD MULTIPLE] Response received:');
      log('  Status code: ${response.statusCode}');
      log('  Body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final List<dynamic> urls = responseData['data'] ?? [];
        final imageUrls = urls.map((item) {
          final originalUrl = item['imageUrl'].toString();
          final normalizedUrl = _normalizeUrl(baseUrl, originalUrl);
          log('  Original URL: $originalUrl');
          log('  Normalized URL: $normalizedUrl');
          return normalizedUrl;
        }).toList();
        return imageUrls;
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      log('[UPLOAD MULTIPLE] Error occurred: $e');
      throw _handleError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getImagesByPlazaId(String plazaId) async {
    try {
      final uri =
          Uri.parse(ApiConfig.getFullUrl(ApiConfig.getImagesByPlazaIdEndpoint))
              .replace(queryParameters: {'plazaId': plazaId});

      log('[GET IMAGES] Full URL: $uri');

      final response = await http.get(uri, headers: headers);
      log('[GET IMAGES] Response received:');
      log('  Status code: ${response.statusCode}');
      log('  Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        if (responseBody['success'] == true && responseBody['data'] is List) {
          final List<dynamic> data = responseBody['data'];
          final results = data.map((image) {
            final originalUrl = image['imageUrl'].toString();
            final normalizedUrl = _normalizeUrl(baseUrl, originalUrl);
            log('[GET IMAGES] Original URL: $originalUrl');
            log('[GET IMAGES] Normalized URL: $normalizedUrl');
            return {
              'imageId': image['imageId'].toString(),
              'imageUrl': normalizedUrl,
            };
          }).toList();

          log('[GET IMAGES] Successfully processed ${results.length} images');
          return results;
        } else {
          throw Exception("Unexpected response structure");
        }
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      log('[GET IMAGES] Error occurred: $e');
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<bool> deleteImage(String imageId) async {
    try {
      final fullUrl =
      ApiConfig.getFullUrl('${ApiConfig.deleteImageEndpoint}$imageId');
      log('[DELETE IMAGE] Full URL: $fullUrl');

      final response = await http.delete(Uri.parse(fullUrl), headers: headers);

      log('[DELETE IMAGE] Response received:');
      log('  Status code: ${response.statusCode}');
      log('  Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          log('[DELETE IMAGE] Successfully deleted image: ${responseData['data']}');
          return true;
        } else {
          log('[DELETE IMAGE] API returned success = false');
          return false;
        }
      } else {
        throw _handleError(response);
      }
    } catch (e, stackTrace) {
      log('[DELETE IMAGE] Error occurred: $e');
      log('[DELETE IMAGE] Stack Trace: $stackTrace');
      return false;
    }
  }


  bool _validateImage(File image) {
    final extension = image.path.split('.').last.toLowerCase();
    const allowedExtensions = ['jpg', 'jpeg', 'png', 'gif'];
    if (!allowedExtensions.contains(extension)) {
      throw Exception(
          'Invalid image format. Allowed formats: ${allowedExtensions.join(", ")}');
    }

    const maxSize = 5 * 1024 * 1024; // 5MB
    final fileSize = image.lengthSync();
    if (fileSize > maxSize) {
      throw Exception('Image size exceeds 5MB limit');
    }
    return true;
  }

  void _validateImages(List<File> images) {
    if (images.isEmpty) throw Exception('No images provided');
    const maxImages = 10;
    if (images.length > maxImages) {
      throw Exception('Maximum $maxImages images allowed per request');
    }
    for (var image in images) {
      _validateImage(image);
    }
  }

  Exception _handleError(dynamic error) {
    if (error is http.Response) {
      try {
        final errorBody = jsonDecode(error.body);
        final message =
            errorBody['message'] ?? 'Server error: ${error.statusCode}';
        return Exception(message);
      } catch (_) {
        return Exception('Server error: ${error.statusCode}');
      }
    }
    return Exception('An unexpected error occurred: $error');
  }
}
