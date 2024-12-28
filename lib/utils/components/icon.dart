import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/models/notification_model.dart';

class CustomIcons {
  static Widget backIconBlack() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.iconBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.iconBlack, width: 1),
      ),
      child: const Center(
        child: Icon(
          Icons.chevron_left,
          size: 40 * 0.7,
          color: AppColors.iconBlack,
        ),
      ),
    );
  }

  static Widget backIconWhite() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.iconBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.iconWhite, width: 1),
      ),
      child: const Center(
        child: Icon(
          Icons.chevron_left,
          size: 40 * 0.7,
          color: AppColors.iconWhite,
        ),
      ),
    );
  }

  static Widget doneIcon() {
    return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        child: const Center(
          child: Icon(
            Icons.check,
            size: 40,
            color: AppColors.primary,
          ),
        ));
  }

  static Widget downloadIconBlack() {
    return Container(
      width: 40,
      height: 40,
      margin: EdgeInsets.zero, // Remove any margin
      decoration: BoxDecoration(
        color: AppColors.iconBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.iconBlack, width: 1),
      ),
      child: const Center(
        child: Icon(
          Icons.file_download_outlined,
          size: 40 * 0.7,
          color: AppColors.iconBlack,
        ),
      ),
    );
  }

  static Widget searchIconBlack() {
    return Container(
      width: 40,
      height: 40,
      margin: EdgeInsets.zero, // Remove any margin
      decoration: BoxDecoration(
        color: AppColors.iconBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.iconBlack, width: 1),
      ),
      child: const Center(
        child: Icon(
          Icons.search_rounded,
          size: 40 * 0.7,
          color: AppColors.iconBlack,
        ),
      ),
    );
  }

  static Widget buildNotificationIcon(NotificationModel notification) {
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
}
