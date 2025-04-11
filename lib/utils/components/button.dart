import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/config/app_theme.dart';
import 'package:merchant_app/utils/components/icon.dart';
import 'dart:developer' as developer;
import '../../config/app_config.dart';
import '../../generated/l10n.dart'; // Import localization

class CustomButtons {
  static Widget primaryButton({
    required String text,
    required VoidCallback? onPressed,
    double height = 0,
    double width = 0,
    bool isEnabled = true,
    required BuildContext context,
  }) {
    final strings = S.of(context); // Access localized strings
    double effectiveWidth = width != 0 ? width : AppConfig.deviceWidth * 0.8;
    double effectiveHeight = height != 0 ? height : 64;
    double fontSize = effectiveHeight < 50 ? 14 : 16;

    final primaryColor = Theme.of(context).brightness == Brightness.light
        ? AppColors.primary
        : AppColors.primary;

    return SizedBox(
      width: effectiveWidth,
      height: effectiveHeight,
      child: ElevatedButton(
        onPressed: isEnabled
            ? () {
          developer.log('Primary button pressed: $text', name: 'CustomButtons');
          onPressed?.call();
        }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? primaryColor : AppColors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              text,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
                color: context.primaryButtonTextColor, // Theme-aware text color
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  static Widget secondaryButton({
    required String text,
    required VoidCallback onPressed,
    double height = 0,
    double width = 0,
    required BuildContext context,
  }) {
    final strings = S.of(context); // Access localized strings
    double effectiveWidth = width != 0 ? width : AppConfig.deviceWidth * 0.8;
    double effectiveHeight = height != 0 ? height : 64;
    double fontSize = effectiveHeight < 50 ? 14 : 16;

    final buttonColor = Theme.of(context).brightness == Brightness.light
        ? AppColors.buttonLight
        : AppColors.buttonDark;
    final borderColor = Theme.of(context).brightness == Brightness.light
        ? AppColors.primary
        : AppColors.primary;

    return SizedBox(
      width: effectiveWidth,
      height: effectiveHeight,
      child: ElevatedButton(
        onPressed: () {
          developer.log('Secondary button pressed: $text', name: 'CustomButtons');
          onPressed();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: borderColor, width: 2),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              text,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
                color: context.secondaryButtonTextColor, // Theme-aware text color
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  static Widget backIconButton({
    required VoidCallback onPressed,
    required bool darkBackground,
    required BuildContext context,
  }) {
    final strings = S.of(context); // Access localized strings
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return IconButton(
      onPressed: () {
        developer.log('Back icon button pressed', name: 'CustomButtons');
        onPressed();
      },
      tooltip: strings.actionBack, // Add localization for accessibility
      icon: isDarkTheme ? CustomIcons.backIconWhite(context) : CustomIcons.backIconBlack(context),
      color: context.textPrimaryColor, // Theme-aware color
    );
  }

  static Widget downloadIconButton({
    required VoidCallback onPressed,
    required bool darkBackground,
    required BuildContext context,
  }) {
    final strings = S.of(context); // Access localized strings
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return IconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      onPressed: () {
        developer.log('Download icon button pressed', name: 'CustomButtons');
        onPressed();
      },
      tooltip: strings.actionDownload, // Add localization for accessibility
      icon: isDarkTheme ? CustomIcons.downloadIconWhite(context) : CustomIcons.downloadIconBlack(context),
      color: context.textPrimaryColor, // Theme-aware color
    );
  }

  static Widget searchIconButton({
    required VoidCallback onPressed,
    required bool darkBackground,
    required BuildContext context,
  }) {
    final strings = S.of(context); // Access localized strings
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return IconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      onPressed: () {
        developer.log('Search icon button pressed', name: 'CustomButtons');
        onPressed();
      },
      tooltip: strings.labelSearch, // Add localization for accessibility
      icon: isDarkTheme ? CustomIcons.searchIconWhite(context) : CustomIcons.searchIconBlack(context),
      color: context.textPrimaryColor, // Theme-aware color
    );
  }
}