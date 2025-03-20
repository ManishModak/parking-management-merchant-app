import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/config/app_theme.dart';
import '../../models/notification_model.dart';
import 'dart:developer' as developer;
import '../../generated/l10n.dart';

class CustomIcons {
  static Widget backIconWhite(BuildContext context) {
    final strings = S.of(context);
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppColors.textLight,
          width: 1.5,
        ),
      ),
      child: Tooltip(
        message: strings.tooltipBack,
        child: const Icon(
          Icons.arrow_back_ios_new,
          color: AppColors.textLight,
          size: 20,
        ),
      ),
    );
  }

  static Widget errorIcon(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: context.textPrimaryColor,
          width: 1.5,
        ),
      ),
      child: Icon(
        Icons.error_outline,
        color: context.textPrimaryColor,
        size: 64,
      ),
    );
  }

  static Widget editIcon(BuildContext context) {
    final strings = S.of(context);
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: context.borderColor,
          width: 1.5,
        ),
      ),
      child: Tooltip(
        message: strings.tooltipEdit,
        child: Icon(
          Icons.edit,
          color: context.textPrimaryColor,
          size: 20,
        ),
      ),
    );
  }

  static Widget cancelIcon(BuildContext context) {
    final strings = S.of(context);
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: context.borderColor,
          width: 1.5,
        ),
      ),
      child: Tooltip(
        message: strings.tooltipCancel,
        child: Icon(
          Icons.close,
          color: context.textPrimaryColor,
          size: 20,
        ),
      ),
    );
  }

  static Widget saveIcon(BuildContext context) {
    final strings = S.of(context);
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: context.borderColor,
          width: 1.5,
        ),
      ),
      child: Tooltip(
        message: strings.tooltipSave,
        child: Icon(
          Icons.check,
          color: context.textPrimaryColor,
          size: 20,
        ),
      ),
    );
  }

  static Widget backIconBlack(BuildContext context) {
    final strings = S.of(context);
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppColors.textDark,
          width: 1.5,
        ),
      ),
      child: Tooltip(
        message: strings.tooltipBack,
        child: const Icon(
          Icons.arrow_back_ios_new,
          color: AppColors.textDark,
          size: 20,
        ),
      ),
    );
  }

  static Widget downloadIconWhite(BuildContext context) {
    final strings = S.of(context);
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppColors.textLight,
          width: 1.5,
        ),
      ),
      child: Tooltip(
        message: strings.tooltipDownload,
        child: const Icon(
          Icons.download,
          color: AppColors.textLight,
          size: 20,
        ),
      ),
    );
  }

  static Widget downloadIconBlack(BuildContext context) {
    final strings = S.of(context);
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppColors.textDark,
          width: 1.5,
        ),
      ),
      child: Tooltip(
        message: strings.tooltipDownload,
        child: const Icon(
          Icons.download,
          color: AppColors.textDark,
          size: 20,
        ),
      ),
    );
  }

  static Widget searchIconBlack(BuildContext context) {
    final strings = S.of(context);
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppColors.textDark,
          width: 1.5,
        ),
      ),
      child: Tooltip(
        message: strings.tooltipSearch,
        child: const Icon(
          Icons.search,
          color: AppColors.textDark,
          size: 20,
        ),
      ),
    );
  }

  static Widget searchIconWhite(BuildContext context) {
    final strings = S.of(context);
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppColors.textLight,
          width: 1.5,
        ),
      ),
      child: Tooltip(
        message: strings.tooltipSearch,
        child: const Icon(
          Icons.search,
          color: AppColors.textLight,
          size: 20,
        ),
      ),
    );
  }

  static Widget doneIcon({double size = 20, BuildContext? context}) {
    final strings = context != null ? S.of(context) : null;
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.success,
          width: 1.5,
        ),
      ),
      child: Tooltip(
        message: strings?.tooltipDone ?? 'Done',
        child: Icon(
          Icons.check_circle_outline,
          color: AppColors.success,
          size: size,
        ),
      ),
    );
  }

  static Widget personIcon(BuildContext context) {
    final strings = S.of(context);
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: context.borderColor,
          width: 1.5,
        ),
      ),
      child: Tooltip(
        message: strings.tooltipPerson,
        child: Icon(
          Icons.person_outline,
          color: context.textPrimaryColor,
          size: 20,
        ),
      ),
    );
  }

  static Widget lockIcon(BuildContext context) {
    final strings = S.of(context);
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: context.borderColor,
          width: 1.5,
        ),
      ),
      child: Tooltip(
        message: strings.tooltipLock,
        child: Icon(
          Icons.lock_outline,
          color: context.textPrimaryColor,
          size: 20,
        ),
      ),
    );
  }

  static Widget logoutIcon(BuildContext context) {
    final strings = S.of(context);
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: context.borderColor,
          width: 1.5,
        ),
      ),
      child: Tooltip(
        message: strings.tooltipLogout,
        child: Icon(
          Icons.exit_to_app_outlined,
          color: context.textPrimaryColor,
          size: 20,
        ),
      ),
    );
  }

  static Widget languageIcon(BuildContext context) {
    final strings = S.of(context);
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: context.borderColor,
          width: 1.5,
        ),
      ),
      child: Tooltip(
        message: strings.tooltipLanguage,
        child: Icon(
          Icons.language_outlined,
          color: context.textPrimaryColor,
          size: 20,
        ),
      ),
    );
  }

  static Widget themeIcon(BuildContext context) {
    final strings = S.of(context);
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: context.borderColor,
          width: 1.5,
        ),
      ),
      child: Tooltip(
        message: strings.tooltipTheme,
        child: Icon(
          Icons.brightness_6_outlined,
          color: context.textPrimaryColor,
          size: 20,
        ),
      ),
    );
  }

  static Widget notificationsIcon(BuildContext context) {
    final strings = S.of(context);
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: context.borderColor,
          width: 1.5,
        ),
      ),
      child: Tooltip(
        message: strings.tooltipNotifications,
        child: Icon(
          Icons.notifications_outlined,
          color: context.textPrimaryColor,
          size: 20,
        ),
      ),
    );
  }

  static Widget helpIcon(BuildContext context) {
    final strings = S.of(context);
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: context.borderColor,
          width: 1.5,
        ),
      ),
      child: Tooltip(
        message: strings.tooltipHelp,
        child: Icon(
          Icons.help_outline,
          color: context.textPrimaryColor,
          size: 20,
        ),
      ),
    );
  }

  static Widget aboutIcon(BuildContext context) {
    final strings = S.of(context);
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: context.borderColor,
          width: 1.5,
        ),
      ),
      child: Tooltip(
        message: strings.tooltipAbout,
        child: Icon(
          Icons.info_outline,
          color: context.textPrimaryColor,
          size: 20,
        ),
      ),
    );
  }

  static Widget privacyIcon(BuildContext context) {
    final strings = S.of(context);
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: context.borderColor,
          width: 1.5,
        ),
      ),
      child: Tooltip(
        message: strings.tooltipPrivacy,
        child: Icon(
          Icons.policy_outlined,
          color: context.textPrimaryColor,
          size: 20,
        ),
      ),
    );
  }

  static Widget termsIcon(BuildContext context) {
    final strings = S.of(context);
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: context.borderColor,
          width: 1.5,
        ),
      ),
      child: Tooltip(
        message: strings.tooltipTerms,
        child: Icon(
          Icons.description_outlined,
          color: context.textPrimaryColor,
          size: 20,
        ),
      ),
    );
  }

  static Widget buildNotificationIcon(NotificationModel notification, BuildContext context) {
    IconData iconData;
    Color iconColor;

    switch (notification.type) {
      case NotificationType.newBooking:
        iconData = Icons.book_online;
        iconColor = AppColors.success;
        break;
      case NotificationType.disputeRaised:
        iconData = Icons.warning;
        iconColor = AppColors.error;
        break;
      case NotificationType.disputeResolved:
        iconData = Icons.check_circle;
        iconColor = AppColors.success;
        break;
      case NotificationType.plazaAlert:
        iconData = Icons.notifications_active;
        iconColor = AppColors.primary;
        break;
      default:
        iconData = Icons.info;
        iconColor = context.textSecondaryColor;
    }

    developer.log(
      'Building notification icon for type: ${notification.type}',
      name: 'CustomIcons',
    );

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: iconColor,
          width: 1.5,
        ),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 20,
      ),
    );
  }
}