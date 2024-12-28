import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/utils/components/icon.dart';

import '../../config/app_config.dart';

class CustomButtons {
  static Widget primaryButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    double width = AppConfig.deviceWidth;
    double height = 60;

    return SizedBox(
      width: width * 0.8,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(height / 2),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  static Widget secondaryButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    double width = AppConfig.deviceWidth;
    double height = 60;

    return SizedBox(
      width: width * 0.8,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(height / 2),
            side: const BorderSide(color: AppColors.primary, width: 2),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  static Widget backIconButton({
    required VoidCallback onPressed,
    required bool darkBackground,
  }) {
    return IconButton(
        onPressed: onPressed,
        icon: darkBackground
            ? CustomIcons.backIconWhite()
            : CustomIcons.backIconBlack());
  }

  static Widget downloadIconButton({
    required VoidCallback onPressed,
    required bool darkBackground,
  }) {
    return IconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(), // Removes any default constraints
      onPressed: onPressed,
      icon: darkBackground
          ? CustomIcons.backIconWhite()
          : CustomIcons.downloadIconBlack(),
    );
  }

  static Widget searchIconButton({
    required VoidCallback onPressed,
    required bool darkBackground,
  }) {
    return IconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(), // Removes any default constraints
      onPressed: onPressed,
      icon: darkBackground
          ? CustomIcons.backIconWhite()
          : CustomIcons.searchIconBlack(),
    );
  }

  static Widget changeInfoButton({
    required String text,
    required VoidCallback onPressed,
    Color? backgroundColor,
  }) {
    double width = AppConfig.deviceWidth;
    double height = 60;

    return SizedBox(
      width: width * 0.44,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 10,
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(height / 2),
            side: const BorderSide(
              color: Colors.black, // Set the border color
              width: 2, // Set the border width
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
