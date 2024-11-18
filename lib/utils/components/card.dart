import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/config/app_config.dart';
import 'package:merchant_app/models/notification_model.dart';
import 'package:merchant_app/models/transaction_model.dart';
import 'package:merchant_app/utils/components/icon.dart';
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
        context
            .read<NotificationsViewModel>()
            .deleteNotification(notification.id);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
        child: Card(
          elevation: 5,
          color: Colors.teal[100],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(
              color: Colors.black, // Set the border color
              width: 2, // Set the border width
            ),
          ),
          child: ListTile(
            leading: CustomIcons.buildNotificationIcon(notification),
            title: Text(
              notification.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight:
                    notification.isRead ? FontWeight.normal : FontWeight.w500,
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

  static void _handleNotificationTap(
      BuildContext context, NotificationModel notification) {
    if (!notification.isRead) {
      context.read<NotificationsViewModel>().markAsRead(notification.id);
    }

    switch (notification.type) {
      case NotificationType.newBooking:
        if (notification.bookingId != null) {
          Navigator.pushNamed(context, '/booking-details',
              arguments: notification.bookingId);
        }
        break;
      case NotificationType.disputeRaised:
      case NotificationType.disputeResolved:
        Navigator.pushNamed(context, '/dispute-details',
            arguments: notification.bookingId);
        break;
      case NotificationType.plazaAlert:
        if (notification.plazaId != null) {
          Navigator.pushNamed(context, '/plaza-details',
              arguments: notification.plazaId);
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

  static Widget transactionCard(
      {required TransactionModel transaction, required BuildContext context}) {
    return Card(
      elevation: 5,
      color: Colors.teal[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(
          color: Colors.black, // Set the border color
          width: 2, // Set the border width
        ),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(transaction.title),
        subtitle: Text('${transaction.amount}'),
        trailing: Icon(
          transaction.type == TransactionType.payment
              ? Icons.arrow_downward
              : Icons.arrow_upward,
          color: transaction.type == TransactionType.payment
              ? Colors.green
              : Colors.red,
        ),
        onTap: () {
          // Handle onTap if needed (e.g., show details or edit transaction)
        },
      ),
    );
  }

  static Widget menuCard({
    required String title,
    required String value,
    VoidCallback? onTap,
    Color? backgroundColor,
    Color? valueColor,
    Widget? icon,
  }) {
    return Card(
      elevation: 5, // Shadow depth
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(
          color: Colors.black, // Set the border color
          width: 2, // Set the border width
        ),
      ),
      color: backgroundColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(16), // Match card's border radius
        onTap: onTap,
        splashColor: Colors.white.withOpacity(0.2), // Optional ripple color
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 20,
                      color: valueColor ?? Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  icon ??
                      const Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                        size: 24,
                      ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
