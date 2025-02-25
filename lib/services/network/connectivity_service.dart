import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final _connectivityStreamController = StreamController<bool>.broadcast();

  Stream<bool> get connectivityStream => _connectivityStreamController.stream;

  ConnectivityService() {
    // Initialize connectivity monitoring
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.isNotEmpty) {
        final result = results.first;
        _connectivityStreamController.add(result != ConnectivityResult.none);
      } else {
        _connectivityStreamController.add(false);
      }
    });
  }

  /// Check if the device is connected to the internet.
  Future<bool> isConnected() async {
    final results = await _connectivity.checkConnectivity();
    return results.isNotEmpty && results.first != ConnectivityResult.none;
  }

  /// Get the current connectivity status as a string
  Future<String> getConnectionType() async {
    final results = await _connectivity.checkConnectivity();
    if (results.isEmpty) return 'No Connection';

    final result = results.first;
    switch (result) {
      case ConnectivityResult.mobile:
        return 'Mobile';
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      case ConnectivityResult.none:
        return 'No Connection';
      default:
        return 'Unknown';
    }
  }

  /// Get all active connections
  Future<List<String>> getAllConnections() async {
    final results = await _connectivity.checkConnectivity();
    return results.map((result) {
      switch (result) {
        case ConnectivityResult.mobile:
          return 'Mobile';
        case ConnectivityResult.wifi:
          return 'WiFi';
        case ConnectivityResult.ethernet:
          return 'Ethernet';
        case ConnectivityResult.bluetooth:
          return 'Bluetooth';
        case ConnectivityResult.none:
          return 'No Connection';
        default:
          return 'Unknown';
      }
    }).toList();
  }

  void dispose() {
    _connectivityStreamController.close();
  }
}