// lib/models/notification_model.dart
enum NotificationType {
  newBooking,
  paymentReceived,
  disputeRaised,
  disputeResolved,
  plazaAlert,
  accountUpdate,
  system;

  String get icon {
    switch (this) {
      case NotificationType.newBooking:
        return 'assets/icons/booking.png';
      case NotificationType.paymentReceived:
        return 'assets/icons/payment.png';
      case NotificationType.disputeRaised:
      case NotificationType.disputeResolved:
        return 'assets/icons/dispute.png';
      case NotificationType.plazaAlert:
        return 'assets/icons/alert.png';
      case NotificationType.accountUpdate:
        return 'assets/icons/account.png';
      case NotificationType.system:
        return 'assets/icons/system.png';
    }
  }
}

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final NotificationType type;
  final bool isRead;
  final String? plazaId;
  final String? bookingId;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.isRead = false,
    this.plazaId,
    this.bookingId,
  });
}