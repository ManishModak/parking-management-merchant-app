import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_colors.dart';

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
}
