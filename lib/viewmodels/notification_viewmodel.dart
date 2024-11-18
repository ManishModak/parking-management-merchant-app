// lib/viewmodels/notifications_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:merchant_app/models/notification_model.dart';

class NotificationsViewModel extends ChangeNotifier {
  List<NotificationModel> notifications = [
    NotificationModel(
      id: '1',
      title: 'New Booking Received',
      message: 'New parking booking at Central Plaza - Slot A12',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      type: NotificationType.newBooking,
      plazaId: 'PZ001',
      bookingId: 'BK001',
    ),
    NotificationModel(
      id: '2',
      title: 'Payment Successful',
      message: 'Payment of ₹150 received for booking #BK001',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      type: NotificationType.paymentReceived,
      plazaId: 'PZ001',
      bookingId: 'BK001',
    ),
    NotificationModel(
      id: '3',
      title: 'Dispute Raised',
      message: 'Customer raised dispute for incorrect charges',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      type: NotificationType.disputeRaised,
      plazaId: 'PZ001',
      bookingId: 'BK002',
    ),
    NotificationModel(
      id: '4',
      title: 'Plaza Alert',
      message: 'Central Plaza is reaching capacity (85% full)',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      type: NotificationType.plazaAlert,
      plazaId: 'PZ001',
    ),
    NotificationModel(
      id: '5',
      title: 'Account Update',
      message: 'Your profile information has been updated successfully',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      type: NotificationType.accountUpdate,
    ),
    NotificationModel(
      id: '6',
      title: 'Dispute Resolved',
      message: 'Dispute #DS001 has been resolved',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      type: NotificationType.disputeResolved,
      plazaId: 'PZ001',
      bookingId: 'BK002',
    ),
    NotificationModel(
      id: '6',
      title: 'Dispute Resolved',
      message: 'Dispute #DS001 has been resolved',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      type: NotificationType.disputeResolved,
      plazaId: 'PZ001',
      bookingId: 'BK002',
    ),
    NotificationModel(
      id: '6',
      title: 'Dispute Resolved',
      message: 'Dispute #DS001 has been resolved',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      type: NotificationType.disputeResolved,
      plazaId: 'PZ001',
      bookingId: 'BK002',
    ),
  ];

  bool isLoading = false;
  String? errorMessage;

  List<NotificationModel> getNotifications() {
    return notifications;
  }

  void markAsRead(String notificationId) {
    final index = notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      final updatedNotification = NotificationModel(
        id: notifications[index].id,
        title: notifications[index].title,
        message: notifications[index].message,
        timestamp: notifications[index].timestamp,
        type: notifications[index].type,
        isRead: true,
        plazaId: notifications[index].plazaId,
        bookingId: notifications[index].bookingId,
      );
      notifications[index] = updatedNotification;
      notifyListeners();
    }
  }

  void deleteNotification(String notificationId) {
    notifications.removeWhere((n) => n.id == notificationId);
    notifyListeners();
  }

  int get unreadCount => notifications.where((n) => !n.isRead).length;
}
