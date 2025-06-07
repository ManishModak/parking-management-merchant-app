// lib/models/notification_model.dart
import 'dart:convert';
import 'dart:developer' as developer;

enum NotificationType {
  newBooking,
  paymentReceived,
  disputeRaised,
  plazaAlert,
  accountUpdate,
  disputeResolved,
  vehicleRegistration,
  plazaRegistration,
  bookingCancellation,
  ticketCreation,
  generic,
  unknown;

  static NotificationType fromString(String? eventString) {
    if (eventString == null) return NotificationType.unknown;
    final normalizedEvent = eventString.toLowerCase().replaceAll('_', '');

    switch (normalizedEvent) {
      case 'userregistration':
      case 'accountupdate':
        return NotificationType.accountUpdate;
      case 'bookingconfirmation':
        return NotificationType.newBooking;
      case 'bookingpaymentsuccessful':
      case 'paymentverificationsuccessful':
      case 'paymentverificationcomplete':
        return NotificationType.paymentReceived;
      case 'vehicleregistrationcomplete':
        return NotificationType.vehicleRegistration;
      case 'plazaregistration':
        return NotificationType.plazaRegistration;
      case 'bookingcancellation':
        return NotificationType.bookingCancellation;
      case 'ticketcreation':
        return NotificationType.ticketCreation;
      case 'disputeraised':
        return NotificationType.disputeRaised;
      case 'plazaalert':
        return NotificationType.plazaAlert;
      case 'disputeresolved':
        return NotificationType.disputeResolved;
      case 'inapp':
        return NotificationType.generic;
      default:
        developer.log('Unknown notification event string: $eventString',
            name: 'NotificationType');
        return NotificationType.unknown;
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
  final Map<String, dynamic>? metadata;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.isRead = false,
    this.plazaId,
    this.bookingId,
    this.metadata,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? metadataMap;
    final dynamic rawMetadata = json['metadata'];

    if (rawMetadata is Map<String, dynamic>) {
      metadataMap = rawMetadata;
    } else if (rawMetadata is String) {
      try {
        metadataMap = jsonDecode(rawMetadata) as Map<String, dynamic>?;
      } catch (e) {
        developer.log('Failed to parse metadata string: $rawMetadata',
            name: 'NotificationModel', error: e);
        metadataMap = null;
      }
    }

    final String? eventTypeString = metadataMap?['event'] as String?;
    final String? topLevelTypeString = json['type'] as String?;

    bool parsedIsRead = false;
    if (json.containsKey('isRead') && json['isRead'] is bool) {
      parsedIsRead = json['isRead'] as bool;
    } else if (json.containsKey('status')) {
      parsedIsRead =
          (json['status'] as String? ?? 'UNREAD').toUpperCase() == 'READ';
    }

    // Handle flexible ID types (String or int)
    final dynamic rawId = json['id'];
    final String id = rawId is String ? rawId : rawId.toString();

    // Handle flexible timestamp fields (timestamp, createdAt)
    final String? timestampString =
        json['timestamp'] as String? ?? json['createdAt'] as String?;
    final DateTime timestamp = timestampString != null
        ? DateTime.parse(timestampString)
        : DateTime.now();

    return NotificationModel(
      id: id,
      title: json['title'] as String,
      message: json['message'] as String,
      timestamp: timestamp,
      type: NotificationType.fromString(eventTypeString ?? topLevelTypeString),
      isRead: parsedIsRead,
      plazaId: metadataMap?['plazaId'] as String?,
      bookingId: metadataMap?['bookingId'] as String?,
      metadata: metadataMap,
    );
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    NotificationType? type,
    bool? isRead,
    String? plazaId,
    String? bookingId,
    Map<String, dynamic>? metadata,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      plazaId: plazaId ?? this.plazaId,
      bookingId: bookingId ?? this.bookingId,
      metadata: metadata ?? this.metadata,
    );
  }
}
