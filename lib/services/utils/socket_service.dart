import 'dart:developer' as developer;
import 'package:socket_io_client/socket_io_client.dart' as socket_io;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  socket_io.Socket? _socket;
  bool _isInitialized = false;

  factory SocketService() => _instance;

  SocketService._internal();

// Initialize Socket.IO connection
  void initialize(String userId, String socketUrl) {
    if (_isInitialized) {
      developer.log('[SocketService] Socket already initialized', name: 'SocketService');
      return;
    }

    try {
      _socket = socket_io.io(
        socketUrl,
        socket_io.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .build(),
      );

      _socket?.connect();

      // Handle connection events
      _socket?.onConnect((data) {  // Added dynamic parameter
        developer.log('[SocketService] Connected to Socket.IO server', name: 'SocketService');
        _isInitialized = true;
        // Register user with the server
        _socket?.emit('register', userId);
      });

      _socket?.onConnectError((error) {
        developer.log('[SocketService] Connection error: $error', name: 'SocketService', error: error);
        _isInitialized = false;
      });

      _socket?.onDisconnect((reason) {
        developer.log('[SocketService] Disconnected from Socket.IO server: $reason', name: 'SocketService');
        _isInitialized = false;
      });
    } catch (e) {
      developer.log('[SocketService] Initialization error: $e', name: 'SocketService', error: e);
      _isInitialized = false;
    }
  }

// Listen for payment result notifications
  void onPaymentResult(String event, Function(dynamic) callback) {
    _socket?.on(event, (data) {
      developer.log('[SocketService] Received payment result: $data', name: 'SocketService');
      callback(data);
    });
  }

// Disconnect from Socket.IO server
  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _isInitialized = false;
    developer.log('[SocketService] Socket disconnected and disposed', name: 'SocketService');
  }

// Check if socket is connected
  bool get isConnected => _socket?.connected ?? false;

// Get socket instance
  socket_io.Socket? get socket => _socket;
}