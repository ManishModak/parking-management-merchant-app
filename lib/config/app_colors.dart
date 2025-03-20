import 'package:flutter/material.dart';

class AppColors {
  // Core Colors - Updated with more vibrant and modern colors
  static const Color primary = Color(0xFF00007F); // Brighter blue
  static const Color primaryLight = Color(0xFF536DFE); // Lighter blue
  static const Color primaryDark = Color(0xFF283593); // Deeper blue
  static const Color secondary = Color(0xFF00E5FF); // Vibrant cyan
  static const Color secondaryLight = Color(0xFF18FFFF); // Brighter cyan
  static const Color secondaryDark = Color(0xFF00B8D4); // Deeper cyan

  // Backgrounds - Enhanced for better contrast
  static const Color backgroundLight = Colors.white;
  static const Color backgroundDark = Color(0xFF121212); // True Material dark
  static const Color surfaceLight = Color(0xFFF5F7FF); // Subtle blue tint
  static const Color surfaceDark = Color(0xFF1E1E1E); // Slightly lighter than background

  // Form Backgrounds - Subtle and unobtrusive
  static const Color formBackgroundLight = Color(0xFFF5F7FF);
  static const Color formBackgroundDark = Color(0xFF2C2C2C);

  // Text - Improved readability and contrast
  static const Color textPrimaryLight = Color(0xFF212121); // Almost black
  static const Color textPrimaryDark = Color(0xFFF5F5F5); // Off-white
  static const Color textSecondaryLight = Color(0xFF616161); // Medium gray
  static const Color textSecondaryDark = Color(0xFFBDBDBD); // Light gray
  static const Color textLight = Colors.white;
  static const Color textDark = Color(0xFF000000);

  // Status Colors - Standardized Material palette
  static const Color success = Color(0xFF00C853); // Vibrant green
  static const Color error = Color(0xFFFF1744); // Bright red
  static const Color warning = Color(0xFFFFAB00); // Amber
  static const Color info = Color(0xFF2979FF); // Blue

  // Borders - Subtle but visible
  static const Color inputBorderLight = Color(0xFFDFE1E5); // Subtle gray with blue tint
  static const Color inputBorderDark = Color(0xFF424242); // Lighter than background
  static const Color inputBorderFocused = Color(0xFF3D5AFE); // Primary color
  static const Color inputBorderDisabled = Color(0xFFB0B0B0);
  static const Color inputBorderEnabledLight = Color(0xFF000000); // Black for light theme
  static const Color inputBorderEnabledDark = Color(0xFFB0B0B0); // Greyish for dark theme (matches inputBorderDisabled)

  // Icons
  static const Color iconLight = Color(0xFF424242); // Dark gray for contrast
  static const Color iconDark = Color(0xFFE0E0E0); // Light gray for contrast

  // Cards - Better layering and elevation feedback
  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF272727); // Slightly lighter than background
  static const Color secondaryCardLight = Color(0x04000000); // Very light gray
  static const Color secondaryCardDark = Color(0xFF323232); // Lighter than card
  static const Color notificationCardLight = Color(0xFFE3F2FD); // Light blue
  static const Color notificationCardDark = Color(0xFF1A237E); // Deep blue

  // Buttons - More saturated and vibrant
  static const Color buttonTextLight = Color(0xFFFFFFFF);
  static const Color buttonTextDark = Color(0xFF000000);
  static const Color buttonLight = Colors.white;
  static const Color buttonDark = Color(0xFF2C2C2C);
  static const Color grey = Color(0xFF757575); // Medium gray for neutral elements

  // Shadows - More subtle and realistic
  static const Color shadowLight = Color.fromRGBO(0, 0, 0, 0.08);
  static const Color shadowDark = Color.fromRGBO(0, 0, 0, 0.3);

  // Charts - Better color differentiation
  static const Color chartPrimaryLight = Color(0xFF6200EA); // Deep purple
  static const Color chartPrimaryDark = Color(0xFF9C64FF); // Light purple
  static const Color chartSecondaryLight = Color(0xFF00B0FF); // Light blue
  static const Color chartSecondaryDark = Color(0xFF40C4FF); // Brighter blue
  static const Color chartTertiaryLight = Color(0xFF00BFA5); // Teal
  static const Color chartTertiaryDark = Color(0xFF1DE9B6); // Light teal

  // Shimmer - More subtle animations
  static const Color shimmerBaseLight = Color(0xFFEEEEEE);
  static const Color shimmerHighlightLight = Color(0xFFF9F9F9);
  static const Color shimmerBaseDark = Color(0xFF424242);
  static const Color shimmerHighlightDark = Color(0xFF5E5E5E);

  static const Color greyDark = Color(0xFF424242);
  static const Color successDark = Color(0xFF66BB6A);

  // Loading Indicators - More vibrant
  static const Color loadingIndicatorLight = Color(0xFF3D5AFE); // Match primary
  static const Color loadingIndicatorDark = Color(0xFF00E5FF); // Match secondary

  // Legacy colors - kept for backward compatibility
  static const Color background = Colors.white;
  static const Color surface = Color(0xFFF5F7FF); // Updated
  static const Color formBackground = Color(0xFFF5F7FF); // Updated
  static const Color textPrimary = Color(0xFF212121); // Updated
  static const Color textSecondary = Color(0xFF616161); // Updated
  static const Color inputBorderDefault = Color(0xFFDFE1E5); // Updated
  static const Color iconBlack = Color(0xFF212121); // Updated for less harshness
  static const Color iconWhite = Color(0xFFF5F5F5); // Slightly off-white
  static const Color lightThemeBackground = Colors.white;
  static const Color darkThemeBackground = Color(0xFF121212); // Updated
  static const Color darkThemeTitle = Color(0xFF00E5FF); // Updated to secondary
  static const Color lightThemeTitle = Color(0xFF212121); // Updated to text primary
  static Color? primaryCard = Colors.white;
  static Color? secondaryCard = Color(0xFF3D5AFE); // Updated to primary
  static Color? notificationCard = Color(0xFFE3F2FD); // Updated
}