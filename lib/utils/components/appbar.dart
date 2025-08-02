import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/config/app_theme.dart';
import 'package:merchant_app/utils/components/button.dart';
// Import localization

class CustomAppBar {
  static AppBar appBarWithNavigation({
    required String screenTitle,
    required VoidCallback onPressed,
    required bool darkBackground,
    double? fontSize,
    bool? centreTitle,
    required BuildContext context,
  }) {
    return AppBar(
      leadingWidth: 80,
      leading: CustomButtons.backIconButton(
        onPressed: () {
          developer.log('Back button pressed on $screenTitle',
              name: 'CustomAppBar');
          onPressed();
        },
        darkBackground: darkBackground,
        context: context,
      ),
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: darkBackground
          ? AppColors.primary
          : context.backgroundColor, // Use theme-aware background
      toolbarHeight: 70,
      centerTitle: centreTitle ?? true,
      title: Text(
        screenTitle,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: fontSize ?? 20,
          color: context.textPrimaryColor, // Theme-aware text color
        ),
        textAlign: centreTitle == null
            ? TextAlign.center
            : centreTitle
                ? TextAlign.center
                : TextAlign.left,
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
    required BuildContext context,
  }) {
    return AppBar(
      leadingWidth: 80,
      leading: CustomButtons.backIconButton(
        onPressed: () {
          developer.log('Back button pressed on $screenTitle',
              name: 'CustomAppBar');
          onPressed();
        },
        darkBackground: darkBackground,
        context: context,
      ),
      elevation: 0,
      scrolledUnderElevation: 0,
      actions: actions,
      backgroundColor: darkBackground
          ? AppColors.primary
          : context.backgroundColor, // Use theme-aware background
      toolbarHeight: 70,
      centerTitle: true,
      title: Text(
        screenTitle,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 20,
          color: context.textPrimaryColor, // Theme-aware text color
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
    required BuildContext context, // Added context for theme awareness
  }) {
    return AppBar(
      automaticallyImplyLeading: false,
      actions: actions,
      backgroundColor: darkBackground
          ? AppColors.primary
          : context.backgroundColor, // Use theme-aware background
      toolbarHeight: 70,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          screenTitle,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: context.textPrimaryColor, // Use theme-aware text color
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  static AppBar appBarWithTitle({
    required String screenTitle,
    required bool darkBackground,
    required BuildContext context,
  }) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: darkBackground
          ? AppColors.primary
          : context.backgroundColor, // Use theme-aware background
      toolbarHeight: 70,
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: Text(
        screenTitle,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 20,
          color: context.textPrimaryColor, // Theme-aware text color
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
