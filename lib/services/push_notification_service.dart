import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/notification_model.dart';
import '../services/utils/navigation_service.dart';

class PushNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  /// Initialize the notification service
  static Future<void> initialize() async {
    if (_isInitialized) return;

    developer.log('Initializing PushNotificationService',
        name: 'PushNotificationService');

    // Android initialization
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions for iOS and newer Android versions
    await _requestPermissions();

    _isInitialized = true;
    developer.log('PushNotificationService initialized successfully',
        name: 'PushNotificationService');
  }

  /// Request notification permissions
  static Future<bool> _requestPermissions() async {
    bool? result;

    // Request permissions for iOS
    result = await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    // Request permissions for Android 13+
    final androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }

    developer.log('Notification permissions granted: $result',
        name: 'PushNotificationService');
    return result ?? false;
  }

  /// Handle notification tap
  static void _onNotificationTapped(NotificationResponse notificationResponse) {
    developer.log('Notification tapped: ${notificationResponse.payload}',
        name: 'PushNotificationService');

    // Navigate to notifications screen when notification is tapped
    final context = NavigationService.navigatorKey.currentContext;
    if (context != null) {
      Navigator.of(context).pushNamed('/notification');
    }
  }

  /// Show a native push notification
  static Future<void> showNotification(NotificationModel notification) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'citypark_notifications', // Channel ID
        'CityPark Notifications', // Channel name
        channelDescription: 'Notifications for CityPark Merchant App',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        enableVibration: true,
        enableLights: true,
        ledColor: Color(0xFF00FF00),
        ledOnMs: 1000,
        ledOffMs: 500,
        autoCancel: true,
        ongoing: false,
        showWhen: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Parse string ID to int, use hashCode as fallback for non-numeric strings
      int notificationId;
      try {
        notificationId = int.parse(notification.id);
      } catch (e) {
        // If ID is not a valid integer, use the hashCode of the string
        notificationId = notification.id.hashCode.abs();
      }

      await _notificationsPlugin.show(
        notificationId,
        notification.title,
        notification.message,
        notificationDetails,
        payload: notification.id.toString(),
      );

      developer.log('Native notification shown: ${notification.title}',
          name: 'PushNotificationService');
    } catch (e) {
      developer.log('Error showing notification: $e',
          name: 'PushNotificationService');
    }
  }

  /// Cancel all notifications
  static Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
    developer.log('All notifications cancelled',
        name: 'PushNotificationService');
  }

  /// Cancel specific notification
  static Future<void> cancel(int id) async {
    await _notificationsPlugin.cancel(id);
    developer.log('Notification cancelled: $id',
        name: 'PushNotificationService');
  }

  /// Check if notifications are enabled
  static Future<bool> areNotificationsEnabled() async {
    final androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      return await androidImplementation.areNotificationsEnabled() ?? false;
    }

    return true; // Assume enabled for iOS
  }
}
