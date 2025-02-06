import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;

import '../config/api_config.dart';
import '../utils/exceptions.dart';

class ImageService {
  final String baseUrl = ApiConfig.apiGateway;
  final Map<String, String> headers = {
    'Content-Type': 'application/json',
  };

  Future<String> uploadSingleImage(String plazaId, File image) async {
    try {
      final fullUrl = ApiConfig.getFullUrl(ApiConfig.uploadSingleImageEndpoint);
      print('[UPLOAD IMAGE] Configuration:');
      print('  Base URL: $baseUrl');
      print('  Endpoint: ${ApiConfig.uploadSingleImageEndpoint}');
      print('  Full URL: $fullUrl');
      print('  Plaza ID: $plazaId');

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(fullUrl),
      );

      request.fields['plazaId'] = plazaId;

      final extension = path.extension(image.path).toLowerCase().replaceAll('.', '');
      print('[UPLOAD IMAGE] File details:');
      print('  Original path: ${image.path}');
      print('  Extension: $extension');

      final mimeType = switch (extension) {
        'jpg' || 'jpeg' => MediaType('image', 'jpeg'),
        'png' => MediaType('image', 'png'),
        'gif' => MediaType('image', 'gif'),
        _ => throw Exception('Unsupported image type: $extension. Only jpg, jpeg, png, and gif are allowed.')
      };

      print('  Determined MIME type: ${mimeType.mimeType}');

      final file = await http.MultipartFile.fromPath(
        'image',
        image.path,
        contentType: mimeType,
        filename: path.basename(image.path),
      );

      print('[UPLOAD IMAGE] MultipartFile details:');
      print('  Field name: ${file.field}');
      print('  Filename: ${file.filename}');
      print('  Content-Type: ${file.contentType}');
      print('  Length: ${file.length} bytes');

      request.files.add(file);

      print('[UPLOAD IMAGE] Sending request...');
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          print('[UPLOAD IMAGE] Request timed out after 15 seconds');
          throw TimeoutException('Upload connection timed out after 15 seconds');
        },
      );

      final response = await http.Response.fromStream(streamedResponse);
      print('[UPLOAD IMAGE] Response received:');
      print('  Status code: ${response.statusCode}');
      print('  Headers: ${response.headers}');
      print('  Body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final imageUrl = responseData['data']['imageUrl'] ?? '';
        print('[UPLOAD IMAGE] Success - Image URL: $imageUrl');
        return imageUrl;
      } else {
        print('[UPLOAD IMAGE] Failed with status ${response.statusCode}');
        throw _handleError(response);
      }
    } catch (e) {
      print('[UPLOAD IMAGE] Error occurred:');
      print('  Type: ${e.runtimeType}');
      print('  Details: $e');
      print('  Stack trace: ${StackTrace.current}');
      throw _handleError(e);
    }
  }

  Future<List<String>> uploadMultipleImages(String plazaId, List<File> images) async {
    try {
      final fullUrl = ApiConfig.getFullUrl(ApiConfig.uploadMultipleImagesEndpoint);
      print('[UPLOAD MULTIPLE] Configuration:');
      print('  Base URL: $baseUrl');
      print('  Endpoint: ${ApiConfig.uploadMultipleImagesEndpoint}');
      print('  Full URL: $fullUrl');
      print('  Plaza ID: $plazaId');
      print('  Number of images: ${images.length}');

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(fullUrl),
      );

      request.fields['plazaId'] = plazaId;

      for (var (index, image) in images.indexed) {
        final extension = path.extension(image.path).toLowerCase().replaceAll('.', '');
        print('[UPLOAD MULTIPLE] Processing image $index:');
        print('  Path: ${image.path}');
        print('  Extension: $extension');

        final mimeType = switch (extension) {
          'jpg' || 'jpeg' => MediaType('image', 'jpeg'),
          'png' => MediaType('image', 'png'),
          'gif' => MediaType('image', 'gif'),
          _ => throw Exception('Unsupported image type: $extension. Only jpg, jpeg, png, and gif are allowed.')
        };

        print('  MIME type: ${mimeType.mimeType}');

        final file = await http.MultipartFile.fromPath(
          'images',
          image.path,
          contentType: mimeType,
          filename: path.basename(image.path),
        );

        print('  MultipartFile details:');
        print('    Field name: ${file.field}');
        print('    Filename: ${file.filename}');
        print('    Content-Type: ${file.contentType}');
        print('    Length: ${file.length} bytes');

        request.files.add(file);
      }

      print('[UPLOAD MULTIPLE] Sending request...');
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          print('[UPLOAD MULTIPLE] Request timed out after 15 seconds');
          throw TimeoutException('Upload connection timed out after 15 seconds');
        },
      );

      final response = await http.Response.fromStream(streamedResponse);
      print('[UPLOAD MULTIPLE] Response received:');
      print('  Status code: ${response.statusCode}');
      print('  Headers: ${response.headers}');
      print('  Body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final List<dynamic> urls = responseData['data'] ?? [];
        final imageUrls = urls.map((item) => item['imageUrl'].toString()).toList();
        print('[UPLOAD MULTIPLE] Success - Image URLs:');
        imageUrls.forEach((url) => print('  $url'));
        return imageUrls;
      } else {
        print('[UPLOAD MULTIPLE] Failed with status ${response.statusCode}');
        throw _handleError(response);
      }
    } catch (e) {
      print('[UPLOAD MULTIPLE] Error occurred:');
      print('  Type: ${e.runtimeType}');
      print('  Details: $e');
      print('  Stack trace: ${StackTrace.current}');
      throw _handleError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getImagesByPlazaId(String plazaId) async {
    try {
      print('[GET IMAGES] Configuration:');
      print('  Base URL: $baseUrl');
      print('  Endpoint: ${ApiConfig.getImagesByPlazaIdEndpoint}');
      print('  Plaza ID: $plazaId');

      final uri = Uri.parse(ApiConfig.getFullUrl(ApiConfig.getImagesByPlazaIdEndpoint))
          .replace(queryParameters: {'plazaId': plazaId});

      print('[GET IMAGES] Full URL: $uri');

      final response = await http.get(
        uri,
        headers: headers,
      );

      print('[GET IMAGES] Response received:');
      print('  Status code: ${response.statusCode}');
      print('  Headers: ${response.headers}');
      print('  Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        if (responseBody['success'] == true && responseBody['data'] is List) {
          final List<dynamic> data = responseBody['data'];
          final results = data.map((image) {
            return {
              'imageId': image['imageId'].toString(),
              'imageUrl': image['imageUrl'].toString(),
          };}).toList();

          print('[GET IMAGES] Successfully processed ${results.length} images');
          return results;
        } else {
          print('[GET IMAGES] Unexpected response structure');
          throw Exception("Unexpected response structure");
        }
      } else {
        print('[GET IMAGES] Failed with status ${response.statusCode}');
        throw _handleError(response);
      }
    } catch (e) {
      print('[GET IMAGES] Error occurred:');
      print('  Type: ${e.runtimeType}');
      print('  Details: $e');
      print('  Stack trace: ${StackTrace.current}');
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<void> deleteImage(String imageId) async {
    try {
      print('[DELETE IMAGE] Configuration:');
      print('  Base URL: $baseUrl');
      print('  Endpoint: ${ApiConfig.deleteImageEndpoint}');
      print('  Image ID: $imageId');

      final fullUrl = ApiConfig.getFullUrl('${ApiConfig.deleteImageEndpoint}$imageId');
      print('[DELETE IMAGE] Full URL: $fullUrl');

      final response = await http.delete(
        Uri.parse(fullUrl),
        headers: headers,
      );

      print('[DELETE IMAGE] Response received:');
      print('  Status code: ${response.statusCode}');
      print('  Headers: ${response.headers}');
      print('  Body: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 204) {
        print('[DELETE IMAGE] Failed with status ${response.statusCode}');
        throw _handleError(response);
      } else {
        print('[DELETE IMAGE] Successfully deleted image');
      }
    } catch (e) {
      print('[DELETE IMAGE] Error occurred:');
      print('  Type: ${e.runtimeType}');
      print('  Details: $e');
      print('  Stack trace: ${StackTrace.current}');
      throw _handleError(e);
    }
  }

  bool _validateImage(File image) {
    print('[VALIDATE IMAGE] Starting validation:');
    print('  File path: ${image.path}');

    final extension = image.path.split('.').last.toLowerCase();
    print('  File extension: $extension');

    const allowedExtensions = ['jpg', 'jpeg', 'png', 'gif'];
    if (!allowedExtensions.contains(extension)) {
      print('[VALIDATE IMAGE] Invalid extension');
      throw Exception('Invalid image format. Allowed formats: ${allowedExtensions.join(", ")}');
    }

    const maxSize = 5 * 1024 * 1024; // 5MB in bytes
    final fileSize = image.lengthSync();
    print('  File size: $fileSize bytes (Max: $maxSize bytes)');

    if (fileSize > maxSize) {
      print('[VALIDATE IMAGE] File too large');
      throw Exception('Image size exceeds 5MB limit');
    }

    print('[VALIDATE IMAGE] Validation successful');
    return true;
  }

  void _validateImages(List<File> images) {
    print('[VALIDATE IMAGES] Starting validation for ${images.length} images');

    if (images.isEmpty) {
      print('[VALIDATE IMAGES] No images provided');
      throw Exception('No images provided');
    }

    const maxImages = 10;
    if (images.length > maxImages) {
      print('[VALIDATE IMAGES] Too many images: ${images.length}');
      throw Exception('Maximum $maxImages images allowed per request');
    }

    for (var (index, image) in images.indexed) {
      print('[VALIDATE IMAGES] Validating image $index:');
      _validateImage(image);
    }

    print('[VALIDATE IMAGES] All images validated successfully');
  }

  Exception _handleError(dynamic error) {
    print('[ERROR HANDLER] Processing error:');
    print('  Error type: ${error.runtimeType}');
    print('  Error details: $error');

    if (error is http.Response) {
      try {
        final errorBody = jsonDecode(error.body);
        final message = errorBody['message'] ?? 'Server error: ${error.statusCode}';
        print('  Parsed error message: $message');
        return Exception(message);
      } catch (e) {
        print('  Failed to parse error body: $e');
        return Exception('Server error: ${error.statusCode}');
      }
    }
    return Exception('An unexpected error occurred: $error');
  }
}