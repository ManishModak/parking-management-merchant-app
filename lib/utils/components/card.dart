import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/config/app_config.dart';
import 'package:merchant_app/models/notification_model.dart';
import 'package:merchant_app/viewmodels/notification_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class CustomCards {
  static Widget plazaCard({
    required String imageUrl,
    required String plazaName,
    required String location,
    VoidCallback? onTap,
  }) {
    return Container(
      width: AppConfig.deviceWidth * 0.9,
      height: 160,
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 16),
      child: Card(
        elevation: 0,
        color: Colors.grey[200],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(25),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 115,
                  height: 135,
                  decoration: BoxDecoration(
                    color: AppColors.lightThemeBackground,
                    borderRadius: BorderRadius.circular(25),
                    image: imageUrl.isNotEmpty
                        ? DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        plazaName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        location,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget addPlazaCard({
    VoidCallback? onTap,
    double? width,
    double? height,
  }) {
    return Container(
      width: width,
      height: height ?? 80,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        elevation: 0,
        color: Colors.grey[200],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Icon(
              Icons.add,
              size: 24,
              color: Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  static Widget notificationCard({
    required NotificationModel notification,
    required BuildContext context,
  }) {
    return Dismissible(
      key: Key(notification.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        context.read<NotificationsViewModel>().deleteNotification(notification.id);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Card(
          elevation: 0,
          color: Colors.teal[100],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: _buildNotificationIcon(notification),
            title: Text(
              notification.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w500,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getTimeAgo(notification.timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            onTap: () => _handleNotificationTap(context, notification),
          ),
        ),
      ),
    );
  }

  static Widget _buildNotificationIcon(NotificationModel notification) {
    IconData iconData;
    Color iconColor;

    switch (notification.type) {
      case NotificationType.newBooking:
        iconData = Icons.local_parking;
        iconColor = Colors.blue;
        break;
      case NotificationType.paymentReceived:
        iconData = Icons.payment;
        iconColor = Colors.green;
        break;
      case NotificationType.disputeRaised:
        iconData = Icons.warning;
        iconColor = Colors.orange;
        break;
      case NotificationType.disputeResolved:
        iconData = Icons.check_circle;
        iconColor = Colors.green;
        break;
      case NotificationType.plazaAlert:
        iconData = Icons.notifications_active;
        iconColor = Colors.red;
        break;
      case NotificationType.accountUpdate:
        iconData = Icons.person;
        iconColor = Colors.purple;
        break;
      case NotificationType.system:
        iconData = Icons.info;
        iconColor = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: iconColor),
    );
  }

  static void _handleNotificationTap(BuildContext context, NotificationModel notification) {
    if (!notification.isRead) {
      context.read<NotificationsViewModel>().markAsRead(notification.id);
    }

    switch (notification.type) {
      case NotificationType.newBooking:
        if (notification.bookingId != null) {
          Navigator.pushNamed(context, '/booking-details', arguments: notification.bookingId);
        }
        break;
      case NotificationType.disputeRaised:
      case NotificationType.disputeResolved:
        Navigator.pushNamed(context, '/dispute-details', arguments: notification.bookingId);
        break;
      case NotificationType.plazaAlert:
        if (notification.plazaId != null) {
          Navigator.pushNamed(context, '/plaza-details', arguments: notification.plazaId);
        }
        break;
      default:
        break;
    }
  }

  static String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 7) {
      final formatter = DateFormat('MMM d, y');
      return formatter.format(timestamp);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}