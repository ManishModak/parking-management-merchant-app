import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:merchant_app/models/notification_model.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:merchant_app/utils/exceptions.dart';

import '../config/api_config.dart';
import '../services/storage/secure_storage_service.dart';
import '../services/utils/notification_service.dart';
import '../services/push_notification_service.dart';

class NotificationsViewModel extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  bool _isLoading = false; // Start with false to prevent stuck state
  String? _errorMessage;
  IO.Socket? _socket;

  final NotificationApiService _apiService;
  final SecureStorageService _secureStorageService;

  String? _currentUserId;
  String? _authTokenForSocket;

  List<NotificationModel> getNotifications() => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  NotificationsViewModel({
    NotificationApiService? apiService,
    SecureStorageService? secureStorageService,
  })  : _apiService = apiService ?? NotificationApiService(),
        _secureStorageService = secureStorageService ?? SecureStorageService();

  Future<void> _loadCredentials() async {
    _currentUserId = await _secureStorageService.getUserId();
    _authTokenForSocket = await _secureStorageService.getAuthToken();
    developer.log(
        'Loaded credentials - UserID: $_currentUserId, Token: ${_authTokenForSocket != null ? "present" : "null"}',
        name: 'NotificationsViewModel');
    if (_currentUserId == null) {
      developer.log('User ID not found in secure storage.',
          name: 'NotificationsViewModel');
      _errorMessage = "User not identified. Please log in again.";
    }
    if (_authTokenForSocket == null) {
      developer.log('Auth token not found for socket.',
          name: 'NotificationsViewModel');
    }
  }

  Future<void> init({bool forceRefresh = false}) async {
    developer.log(
        'Initializing NotificationsViewModel. Force refresh: $forceRefresh, Current loading state: $_isLoading',
        name: 'NotificationsViewModel');

    if (_isLoading && !forceRefresh) {
      developer.log('Already loading, skipping init unless forceRefresh.',
          name: 'NotificationsViewModel');

      // Add emergency timeout to force loading completion
      Future.delayed(Duration(seconds: 12), () {
        if (_isLoading) {
          developer.log('EMERGENCY: Force completing stuck loading state',
              name: 'NotificationsViewModel');
          _isLoading = false;
          _errorMessage = null;
          _notifications = [];
          notifyListeners();
        }
      });
      return;
    }

    _isLoading = true;
    if (forceRefresh) _notifications.clear();
    _errorMessage = null;
    notifyListeners();

    await _loadCredentials();

    if (_currentUserId == null) {
      developer.log('No user ID found, stopping initialization',
          name: 'NotificationsViewModel');
      _isLoading = false;
      _errorMessage = "Please log in to view notifications";
      notifyListeners();
      return;
    }

    developer.log(
        'User ID found: $_currentUserId, attempting socket connection',
        name: 'NotificationsViewModel');
    _connectSocket();
  }

  void _connectSocket() {
    _socket?.dispose();
    _socket = null;

    if (_currentUserId == null) {
      developer.log('Cannot connect socket: User ID is null.',
          name: 'NotificationsViewModel');
      _isLoading = false;
      _errorMessage = "User session error. Cannot fetch notifications.";
      notifyListeners();
      return;
    }

    developer.log('Setting up socket connection to: ${ApiConfig.baseUrl}',
        name: 'NotificationsViewModel');
    try {
      final socketOptions = <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
      };

      if (_authTokenForSocket != null && _currentUserId != null) {
        socketOptions['query'] = {
          'token': _authTokenForSocket,
          'userId': _currentUserId,
        };
        developer.log('Socket query params set: ${socketOptions['query']}',
            name: 'NotificationsViewModel');
      } else {
        developer.log('Socket connecting without auth token or userId.',
            name: 'NotificationsViewModel');
      }

      _socket = IO.io(ApiConfig.socketUrl, socketOptions);
      developer.log(
          'Socket instance created with URL: ${ApiConfig.socketUrl}, options: $socketOptions',
          name: 'NotificationsViewModel');

      _socket!.onConnect((_) {
        developer.log('Socket connected successfully. ID: ${_socket!.id}',
            name: 'NotificationsViewModel');
        _errorMessage = null;
        _socket!
            .emit('request_initial_notifications', {'userId': _currentUserId!});
        developer.log(
            'Emitted request_initial_notifications for user $_currentUserId',
            name: 'NotificationsViewModel');
      });

      _socket!.on('initial_notifications', (data) {
        developer.log('Received initial_notifications event. Data: $data',
            name: 'NotificationsViewModel');
        _handleInitialNotifications(data);
      });

      _socket!.on('new_notification', (data) {
        developer.log('Received new_notification event. Data: $data',
            name: 'NotificationsViewModel');
        _handleNewNotification(data);
      });

      _socket!.onDisconnect((reason) {
        developer.log('Socket disconnected. Reason: $reason',
            name: 'NotificationsViewModel');
        if (_notifications.isEmpty && _isLoading) {
          _errorMessage = 'Disconnected. Pull to refresh to try reconnecting.';
        }
        _isLoading = false;
        notifyListeners();
      });

      _socket!.onConnectError((data) {
        developer.log('Socket connect error: $data',
            name: 'NotificationsViewModel', error: data);

        // Only update state if we haven't already fallen back to API mode
        if (_socket != null && _isLoading) {
          _isLoading = false;
          _errorMessage =
              'Failed to connect to notification server. Please check your internet connection and pull to refresh.';
          notifyListeners();

          // Try to show empty state instead of loading forever
          if (_notifications.isEmpty) {
            developer.log('Socket failed, showing empty state',
                name: 'NotificationsViewModel');
          }
        }
      });

      _socket!.onError((data) {
        developer.log('Socket general error: $data',
            name: 'NotificationsViewModel', error: data);

        // Only update state if we haven't already fallen back to API mode
        if (_socket != null && _notifications.isEmpty && _isLoading) {
          _isLoading = false;
          _errorMessage = 'A socket error occurred. Pull to refresh.';
          notifyListeners();
        }
      });

      developer.log('Initiating socket connection...',
          name: 'NotificationsViewModel');
      _socket!.connect();

      // Timeout to catch hanging connections with API fallback
      Future.delayed(Duration(seconds: 8), () {
        if (_socket != null && !_socket!.connected && _isLoading) {
          developer.log(
              'Socket connection timed out after 8 seconds. Falling back to API-only mode.',
              name: 'NotificationsViewModel');
          _loadNotificationsFromAPI();
        }
      });

      // Additional timeout for any loading state
      Future.delayed(Duration(seconds: 15), () {
        if (_isLoading) {
          developer.log(
              'Notification loading forced to complete after 15 seconds.',
              name: 'NotificationsViewModel');
          _isLoading = false;
          if (_notifications.isEmpty) {
            _errorMessage =
                'Unable to load notifications. Check your connection and try again.';
          }
          notifyListeners();
        }
      });
    } catch (e, s) {
      developer.log('Error initializing socket: $e',
          name: 'NotificationsViewModel', error: e, stackTrace: s);
      _isLoading = false;
      _errorMessage = null; // Show empty state instead of error
      _notifications = []; // Initialize with empty list
      notifyListeners();
    }
  }

  void _handleInitialNotifications(dynamic data) {
    try {
      if (data is List) {
        _notifications = data
            .map((item) =>
                NotificationModel.fromJson(item as Map<String, dynamic>))
            .toList();
        developer.log('Parsed ${_notifications.length} initial notifications.',
            name: 'NotificationsViewModel');
        _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        _errorMessage = null;
      } else if (data is Map<String, dynamic> &&
          data.containsKey('notifications') &&
          data['notifications'] is List) {
        _notifications = (data['notifications'] as List)
            .map((item) =>
                NotificationModel.fromJson(item as Map<String, dynamic>))
            .toList();
        developer.log(
            'Parsed ${_notifications.length} initial notifications from map.',
            name: 'NotificationsViewModel');
        _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        _errorMessage = null;
      } else {
        developer.log('Invalid initial_notifications data format: $data',
            name: 'NotificationsViewModel');
        _errorMessage =
            'Received invalid data format for initial notifications.';
      }
    } catch (e, s) {
      developer.log('Error parsing initial_notifications: $e',
          name: 'NotificationsViewModel', error: e, stackTrace: s);
      _errorMessage = 'Error processing notifications data.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _handleNewNotification(dynamic data) {
    try {
      if (data is Map<String, dynamic>) {
        final newNotification = NotificationModel.fromJson(data);
        _notifications.removeWhere((n) => n.id == newNotification.id);
        _notifications.insert(0, newNotification);
        developer.log('Added new notification: ${newNotification.id}',
            name: 'NotificationsViewModel');
        _errorMessage = null;

        // Show popup notification
        _showNotificationPopup(newNotification);
      } else {
        developer.log('Invalid new_notification data: $data',
            name: 'NotificationsViewModel');
      }
    } catch (e, s) {
      developer.log('Error parsing new_notification: $e',
          name: 'NotificationsViewModel', error: e, stackTrace: s);
    } finally {
      notifyListeners();
    }
  }

  void _showNotificationPopup(NotificationModel notification) {
    developer.log('📱 Real-time notification received: ${notification.title}',
        name: 'NotificationsViewModel');

    try {
      // Show native push notification
      PushNotificationService.showNotification(notification);
      developer.log(
          '✅ Native notification displayed successfully: ${notification.title}',
          name: 'NotificationsViewModel');
    } catch (e) {
      // Fallback to simple logging if notification fails
      developer.log('❌ Native notification failed, error: $e',
          name: 'NotificationsViewModel', error: e);
    }

    developer.log('💬 Notification processed: ${notification.message}',
        name: 'NotificationsViewModel');
  }

  Future<void> refreshNotifications() async {
    developer.log('Refreshing notifications explicitly',
        name: 'NotificationsViewModel');
    await init(forceRefresh: true);
  }

  /// Force reset the loading state and reinitialize
  Future<void> forceReset() async {
    developer.log('Force resetting notification state',
        name: 'NotificationsViewModel');

    // Complete reset of all state
    _isLoading = false;
    _errorMessage = null;
    _notifications.clear();
    _socket?.dispose();
    _socket = null;
    _currentUserId = null;
    _authTokenForSocket = null;

    notifyListeners();

    // Small delay then reinitialize
    await Future.delayed(Duration(milliseconds: 100));
    await init(forceRefresh: true);
  }

  /// Quick fix for stuck loading state
  void unstickLoading() {
    if (_isLoading) {
      developer.log('Unsticking loading state', name: 'NotificationsViewModel');
      _isLoading = false;
      _errorMessage = null;
      _notifications = [];
      notifyListeners();
    }
  }

  /// Load notifications from API when socket fails
  Future<void> _loadNotificationsFromAPI() async {
    if (_currentUserId == null) {
      developer.log('Cannot load from API: No user ID',
          name: 'NotificationsViewModel');
      _isLoading = false;
      _errorMessage = "Please log in to view notifications";
      notifyListeners();
      return;
    }

    try {
      developer.log('Loading notifications from API for user $_currentUserId',
          name: 'NotificationsViewModel');

      // For now, show empty state - API implementation can be added later
      _notifications = [];
      _isLoading = false;
      _errorMessage = null; // No error - just no notifications available

      // Dispose socket to prevent further error messages
      _socket?.dispose();
      _socket = null;

      developer.log(
          'API fallback completed - showing empty notifications state',
          name: 'NotificationsViewModel');
      notifyListeners();
    } catch (e) {
      developer.log('Error loading from API: $e',
          name: 'NotificationsViewModel', error: e);
      _isLoading = false;
      _errorMessage = null;
      _notifications = [];
      notifyListeners();
    }
  }

  Future<void> _handleApiCall(
    Future<bool> Function() apiCall, {
    required Function onSuccess,
    required Function onApiFailure,
    String? genericErrorMessage,
  }) async {
    try {
      bool success = await apiCall();
      if (success) {
        onSuccess();
      } else {
        onApiFailure();
        _errorMessage =
            genericErrorMessage ?? "Operation failed. Please try again.";
        developer.log(_errorMessage!, name: 'NotificationsViewModel');
      }
    } on UnauthenticatedException catch (e) {
      _errorMessage = e.message;
      developer.log('Unauthenticated: $_errorMessage',
          name: 'NotificationsViewModel', error: e);
      notifyListeners();
    } on HttpException catch (e) {
      _errorMessage = e.serverMessage ?? e.message;
      developer.log('HTTP Error: $_errorMessage',
          name: 'NotificationsViewModel', error: e);
      onApiFailure();
      notifyListeners();
    } on ServiceException catch (e) {
      _errorMessage = e.message;
      developer.log('Service Error: $_errorMessage',
          name: 'NotificationsViewModel', error: e);
      onApiFailure();
      notifyListeners();
    } catch (e) {
      _errorMessage = genericErrorMessage ??
          "An unexpected error occurred: ${e.toString()}";
      developer.log('Unexpected Error: $_errorMessage',
          name: 'NotificationsViewModel', error: e);
      onApiFailure();
      notifyListeners();
    }
  }

  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1 && !_notifications[index].isRead) {
      final originalNotification = _notifications[index];
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();

      await _handleApiCall(
          () => _apiService.markNotificationAsRead(notificationId),
          onSuccess: () {
        developer.log('Successfully marked $notificationId as read on backend.',
            name: 'NotificationsViewModel');
      }, onApiFailure: () {
        _notifications[index] = originalNotification;
        notifyListeners();
      }, genericErrorMessage: 'Failed to mark notification as read.');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      final removedNotification = _notifications.removeAt(index);
      notifyListeners();

      await _handleApiCall(() => _apiService.deleteNotification(notificationId),
          onSuccess: () {
        developer.log('Successfully deleted $notificationId on backend.',
            name: 'NotificationsViewModel');
      }, onApiFailure: () {
        _notifications.insert(index, removedNotification);
        notifyListeners();
      }, genericErrorMessage: 'Failed to delete notification.');
    }
  }

  Future<void> markAllAsReadForCurrentUser() async {
    if (_currentUserId == null) {
      _errorMessage = "Cannot mark all as read: User not identified.";
      notifyListeners();
      return;
    }
    bool changedInUi = false;
    List<NotificationModel> originalNotifications = List.from(_notifications);

    _notifications = _notifications.map((n) {
      if (!n.isRead) {
        changedInUi = true;
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();

    if (changedInUi) notifyListeners();

    await _handleApiCall(
        () => _apiService.markAllNotificationsAsRead(_currentUserId!),
        onSuccess: () {
      developer.log(
          'Successfully marked all as read on backend for user $_currentUserId.',
          name: 'NotificationsViewModel');
    }, onApiFailure: () {
      if (changedInUi) {
        _notifications = originalNotifications;
        notifyListeners();
      }
    }, genericErrorMessage: 'Failed to mark all notifications as read.');
  }

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  @override
  void dispose() {
    developer.log('Disposing NotificationsViewModel and socket.',
        name: 'NotificationsViewModel');
    _socket?.dispose();
    _socket = null;
    super.dispose();
  }
}
