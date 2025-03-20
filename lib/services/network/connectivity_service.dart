import 'dart:developer' as developer;
import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

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
    developer.log('Connection results: $results', name: 'ConnectivityService');
    return results.isNotEmpty && results.first != ConnectivityResult.none;
  }

  /// Verify if the device can actually reach the internet by pinging a reliable host
  Future<bool> canReachInternet() async {
    if (!await isConnected()) {
      return false;
    }

    try {
      // Try to reach a reliable Google DNS server
      final result = await InternetAddress.lookup('8.8.8.8');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (e) {
      developer.log('Socket exception when checking internet: $e', name: 'ConnectivityService');
      return false;
    } catch (e) {
      developer.log('Error checking internet connection: $e', name: 'ConnectivityService');
      return false;
    }
  }

  /// Check if server is reachable by testing a connection to the specified host
  Future<bool> canReachServer(String host) async {
    if (!await isConnected()) {
      return false;
    }

    try {
      // Try to resolve the host
      final result = await InternetAddress.lookup(host);
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (e) {
      developer.log('Socket exception when checking server: $e', name: 'ConnectivityService');
      return false;
    } catch (e) {
      developer.log('Error checking server connection: $e', name: 'ConnectivityService');
      return false;
    }
  }

  /// Get the current connectivity status as a string
  Future<String> getConnectionType() async {
    final results = await _connectivity.checkConnectivity();
    developer.log('Connection results: $results', name: 'ConnectivityService');
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