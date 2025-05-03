class PlazaException implements Exception {
  final String message;
  final int? statusCode;
  final String? serverMessage;

  PlazaException(this.message, {this.statusCode, this.serverMessage});

  @override
  String toString() {
    if (statusCode != null && serverMessage != null) {
      return 'PlazaException: $message (Status: $statusCode, Server: $serverMessage)';
    } else if (statusCode != null) {
      return 'PlazaException: $message (Status: $statusCode)';
    } else if (serverMessage != null) {
      return 'PlazaException: $message (Server: $serverMessage)';
    }
    return 'PlazaException: $message';
  }
}

class StorageException implements Exception {
  final String message;
  StorageException(this.message);

  @override
  String toString() => message;
}

class HttpException implements Exception {
  final String message;
  final int? statusCode;
  final String? serverMessage;

  HttpException(this.message, {this.statusCode, this.serverMessage});

  @override
  String toString() {
    if (statusCode != null && serverMessage != null) {
      return 'HttpException: $message (Status: $statusCode, Server: $serverMessage)';
    } else if (statusCode != null) {
      return 'HttpException: $message (Status: $statusCode)';
    } else if (serverMessage != null) {
      return 'HttpException: $message (Server: $serverMessage)';
    }
    return 'HttpException: $message';
  }
}

class ServiceException implements Exception {
  final String message;
  final int? statusCode;
  final String? serverMessage;

  ServiceException(this.message, {this.statusCode, this.serverMessage});

  @override
  String toString() {
    if (statusCode != null && serverMessage != null) {
      return 'ServiceException: $message (Status: $statusCode, Server: $serverMessage)';
    } else if (statusCode != null) {
      return 'ServiceException: $message (Status: $statusCode)';
    } else if (serverMessage != null) {
      return 'ServiceException: $message (Server: $serverMessage)';
    }
    return 'ServiceException: $message';
  }
}

class PaymentException implements Exception {
  final String message;
  final int? statusCode;
  final String? serverMessage;

  PaymentException(this.message, {this.statusCode, this.serverMessage});

  @override
  String toString() {
    return 'PaymentException: $message${statusCode != null ? ' (Status Code: $statusCode)' : ''}${serverMessage != null ? ' - $serverMessage' : ''}';
  }
}

class NoInternetException implements Exception {
  final String message;

  NoInternetException(this.message);

  @override
  String toString() => message;
}

class ServerConnectionException implements Exception {
  final String message;
  final String? host;

  ServerConnectionException(this.message, {this.host});

  @override
  String toString() {
    if (host != null) {
      return 'ServerConnectionException: $message (Host: $host)';
    }
    return 'ServerConnectionException: $message';
  }
}

class RequestTimeoutException implements Exception {
  final String message;

  RequestTimeoutException(this.message);

  @override
  String toString() => message;
}

class AnprFailureException implements Exception {
  final String message;
  AnprFailureException(this.message);

  @override
  String toString() => 'AnprFailureException: $message';
}

class MobileNumberInUseException implements Exception {
  final String message;

  MobileNumberInUseException([this.message = 'Mobile number is already in use']);

  @override
  String toString() => 'MobileNumberInUseException: $message';
}

class EmailInUseException implements Exception {
  final String message;

  EmailInUseException([this.message = 'Email is already in use']);

  @override
  String toString() => 'EmailInUseException: $message';
}