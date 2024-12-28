import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/config/app_config.dart';
import 'package:merchant_app/models/notification_model.dart';
import 'package:merchant_app/models/transaction_model.dart';
import 'package:merchant_app/utils/components/icon.dart';
import 'package:merchant_app/viewmodels/notification_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../models/menu_item.dart';

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

  static Widget addCard({
    VoidCallback? onTap,
    double? width,
    double? height,
  }) {
    return SizedBox(
      width: width,
      height: height ?? 80,
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

  static Widget userProfileCard({
    required String name,
    required String userId,
    String? imageUrl,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.all(0),
      elevation: 5,
      color: const Color(0xFF014245), // Dark teal background like in the image
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(
          color: Colors.black,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blue[100],
              child: const Icon(
                Icons.person,
                size: 50,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Hello! $name",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "ID: $userId",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[300],
                    ),
                  ),
                ],
              ),
            ),
          ],
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
          color: AppColors.primaryCard,
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
      color: AppColors.primaryCard,
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


  static Widget plazaImageCard({
    final List<String>? imageUrls,
    final VoidCallback? onTap,
  }) {
    return Container(
      width: AppConfig.deviceWidth,
      height: AppConfig.deviceHeight * 0.2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        elevation: 5,
        color: Colors.teal[100],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(
            color: Colors.black,
            width: 2,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                if (imageUrls != null && imageUrls.isNotEmpty)
                  Expanded(
                    child: SizedBox(
                      height: 100,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: imageUrls.length,
                        itemBuilder: (context, index) => Container(
                          width: 60,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: NetworkImage(imageUrls[index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 8),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: Container(
                      width: 60,
                      height: AppConfig.deviceHeight * 0.15,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[300],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(width: 16),
                addCard(
                  height: AppConfig.deviceHeight * 0.15,
                  width: AppConfig.deviceWidth * 0.2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget plazaInfoCard({
    required TextEditingController controller,
    required String labelText,
    TextInputType? keyboardType,
    VoidCallback? onTap,
    VoidCallback? onConfirm,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        enabled: true,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        style: TextStyle(
          color: true ? Colors.black : Colors.grey.shade700,
        ),
      ),
    );
  }

  static Widget operatorCard({
    required String imageUrl,
    required String operatorName,
    required String role,
    required String contactNumber,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 5,
        color: AppColors.primaryCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(
            color: Colors.black,
            width: 2,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(40),
                    image: imageUrl.isNotEmpty
                        ? DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                  child: imageUrl.isEmpty
                      ? CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.blue[100],
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.blue,
                    ),
                  )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        operatorName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        role,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        contactNumber,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
