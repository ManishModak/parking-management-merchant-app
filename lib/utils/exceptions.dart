// exceptions.dart
class PlazaException implements Exception {
  final String message;
  PlazaException(this.message);
  @override
  String toString() => message;
}

class HttpException implements Exception {
  final String message;
  HttpException(this.message);
  @override
  String toString() => message;
}

class ServiceException implements Exception {
  final String message;

  ServiceException(this.message);

  @override
  String toString() => message;
}

// url_utils.dart
class UrlUtils {
  static String sanitizeUrl(String baseUrl, String path) {
    // If path is already a full URL, return it as is
    if (path.startsWith('http')) {
      return path;
    }

    // Replace port 3000 with 3004 in baseUrl
    final updatedBaseUrl = baseUrl.replaceFirst(':3000', ':3004');

    final cleanBase = updatedBaseUrl.endsWith('/') ? updatedBaseUrl.substring(0, updatedBaseUrl.length - 1) : updatedBaseUrl;
    final cleanPath = path.startsWith('/') ? path : '/$path';

    return '$cleanBase$cleanPath';
  }
}



class ImageUrlHelper {
  static String getWorkingImageUrl(String originalUrl) {
    // Extract just the path portion from the original URL
    Uri? uri = Uri.tryParse(originalUrl);
    String path = uri?.path ?? originalUrl;

    // If path starts with /uploads, that's what we want
    if (path.startsWith('/uploads')) {
      // Use a publicly accessible image placeholder service
      return 'https://placehold.co/400x300/png';

      // Alternatively, you could use your development server
      // return 'http://192.168.1.101:3000$path';
    }

    // If we can't parse it, return a placeholder
    return 'https://placehold.co/400x300/png';
  }
}