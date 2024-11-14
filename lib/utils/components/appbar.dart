import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/utils/components/button.dart';

class CustomAppBar {
  static AppBar appBarWithNavigation({
    required String screenTitle,
    required VoidCallback onPressed,
    required bool darkBackground,
  }) {
    return AppBar(
      leadingWidth: 80,
      leading: CustomButtons.backIconButton(
        onPressed: onPressed,
        darkBackground: darkBackground,
      ),
      backgroundColor: darkBackground ? AppColors.primary : AppColors.lightThemeBackground,
      toolbarHeight: 125,
      centerTitle: true,
      title: Text(
        screenTitle,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 26,
          color: darkBackground
              ? AppColors.darkThemeTitle
              : AppColors.lightThemeTitle,
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  static AppBar appBarWithNavigationAndActions({
    required String screenTitle,
    required VoidCallback onPressed,
    required bool darkBackground,
    required List<Widget> actions,
  }) {
    return AppBar(
      leadingWidth: 80,
      leading: CustomButtons.backIconButton(
        onPressed: onPressed,
        darkBackground: darkBackground,
      ),
      actions: actions,
      backgroundColor: darkBackground ? AppColors.primary : AppColors.lightThemeBackground,
      toolbarHeight: 100,
      centerTitle: true,
      title: Text(
        screenTitle,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 26,
          color: darkBackground
              ? AppColors.darkThemeTitle
              : AppColors.lightThemeTitle,
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  static AppBar appBarWithActions({
    required String screenTitle,
    required bool darkBackground,
    required List<Widget> actions,
  }) {
    return AppBar(
      actions: actions,
      backgroundColor: darkBackground ? AppColors.primary : AppColors.lightThemeBackground,
      toolbarHeight: 100,
      centerTitle: true,
      title: Text(
        screenTitle,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 26,
          color: darkBackground
              ? AppColors.darkThemeTitle
              : AppColors.lightThemeTitle,
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  static AppBar appBarWithTitle({
    required String screenTitle,
    required bool darkBackground,
  }) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: darkBackground ? AppColors.primary : AppColors.lightThemeBackground,
      toolbarHeight: 75,
      centerTitle: true,
      title: Text(
        screenTitle,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 26,
          color: darkBackground
              ? AppColors.darkThemeTitle
              : AppColors.lightThemeTitle,
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}