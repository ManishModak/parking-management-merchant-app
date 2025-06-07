import 'package:flutter/material.dart';

class AppColors {
  // Core Colors - Vibrant and modern colors
  static const Color primary = Color(0xFF00007F); // Brighter blue
  static const Color primaryLight = Color(0xFF536DFE); // Lighter blue
  static const Color primaryDark = Color(0xFF283593); // Deeper blue
  static const Color secondary = Color(0xFF00E5FF); // Vibrant cyan (used for secondary actions)
  static const Color secondaryLight = Color(0xFF6EFFFF); // Brighter cyan
  static const Color secondaryDark = Color(0xFF00B8D4); // Deeper cyan

  // Backgrounds - High contrast for readability
  static const Color backgroundLight = Colors.white;
  static const Color backgroundDark = Color(0xFF121212); // Material dark background
  static const Color surfaceLight = Color(0xFFF5F7FF); // Subtle blue tint for surfaces
  static const Color surfaceDark = Color(0xFF1E1E1E); // Slightly lighter than background

  // Form Backgrounds - Subtle and clean
  static const Color formBackgroundLight = Color(0xFFF5F7FF);
  static const Color formBackgroundDark = Color(0xFF2C2C2C);

  // Text - High contrast for readability
  static const Color textPrimaryLight = Color(0xFF212121); // Near black
  static const Color textPrimaryDark = Color(0xFFF5F5F5); // Off-white
  static const Color textSecondaryLight = Color(0xFF616161); // Medium gray
  static const Color textSecondaryDark = Color(0xFFBDBDBD); // Light gray
  static const Color textLight = Colors.white;
  static const Color textDark = Color(0xFF000000);

  // Status Colors - Aligned with Material Design
  static const Color success = Color(0xFF00C853); // Vibrant green (matches Settled Disputes and UPI)
  static const Color successDark = Color(0xFF66BB6A); // Slightly muted green for dark theme
  static const Color error = Color(0xFFFF1744); // Bright red (matches Rejected Disputes)
  static const Color warning = Color(0xFFFFAB00); // Amber (matches Cash)
  static const Color info = Color(0xFF2979FF); // Blue for informational elements

  // Borders - Subtle but visible
  static const Color inputBorderLight = Color(0xFFDFE1E5); // Light gray with blue tint
  static const Color inputBorderDark = Color(0xFF424242); // Lighter than dark background
  static const Color inputBorderFocused = Color(0xFF3D5AFE); // Matches primary
  static const Color inputBorderDisabled = Color(0xFFB0B0B0);
  static const Color inputBorderEnabledLight = Color(0xFF000000); // Black for light theme
  static const Color inputBorderEnabledDark = Color(0xFFB0B0B0); // Greyish for dark theme

  // Icons - Good contrast
  static const Color iconLight = Color(0xFF424242); // Dark gray
  static const Color iconDark = Color(0xFFE0E0E0); // Light gray

  // Cards - Clear layering
  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF272727); // Slightly lighter than dark background
  static const Color secondaryCardLight = Color(0xFFF5F7FF); // Matches surfaceLight for consistency
  static const Color secondaryCardDark = Color(0xFF323232); // Lighter than cardDark
  static const Color notificationCardLight = Color(0xFFE3F2FD); // Light blue
  static const Color notificationCardDark = Color(0xFF1A237E); // Deep blue

  // Buttons - Vibrant and clear
  static const Color buttonTextLight = Color(0xFFFFFFFF);
  static const Color buttonTextDark = Color(0xFF000000);
  static const Color buttonLight = Colors.white;
  static const Color buttonDark = Color(0xFF2C2C2C);
  static const Color grey = Color(0xFF757575); // Neutral gray
  static const Color greyDark = Color(0xFF424242); // Darker gray for dark theme

  // Shadows - Subtle and realistic
  static const Color shadowLight = Color.fromRGBO(0, 0, 0, 0.08);
  static const Color shadowDark = Color.fromRGBO(0, 0, 0, 0.3);

  // Charts - Colors matching the image
  static const Color chartPrimaryLight = Color(0xFF3D5AFE); // Blue (matches Open Disputes and Card)
  static const Color chartPrimaryDark = Color(0xFF264AFE); // Slightly darker blue for dark theme
  static const Color chartSecondaryLight = Color(0xFFFF1744); // Red (not used in image, but for consistency)
  static const Color chartSecondaryDark = Color(0xFFFF4569); // Lighter red for dark theme
  static const Color chartTertiaryLight = Color(0xFF40C4FF); // Light blue (matches Other)
  static const Color chartTertiaryDark = Color(0xFF82DEFF); // Lighter blue for dark theme

  // Shimmer - Subtle animations
  static const Color shimmerBaseLight = Color(0xFFEEEEEE);
  static const Color shimmerHighlightLight = Color(0xFFF9F9F9);
  static const Color shimmerBaseDark = Color(0xFF424242);
  static const Color shimmerHighlightDark = Color(0xFF5E5E5E);

  static const Color successLight = Color(0xFFE8F5E9); // Light green background (NEW)
  static const Color warningLight = Color(0xFFFFF8E1);  // Light amber background (NEW)
  static const Color errorDark = Color(0xFFB71C1C);    // NEW: Dark red for text/border
  static const Color warningDark = Color(0xFFE65100);   // NEW: Dark orange for text/border


  // Loading Indicators - Vibrant
  static const Color loadingIndicatorLight = Color(0xFF3D5AFE); // Matches primary
  static const Color loadingIndicatorDark = Color(0xFF00E5FF); // Matches secondary

  // Legacy Colors - For backward compatibility
  static const Color background = Colors.white;
  static const Color surface = Color(0xFFF5F7FF);
  static const Color formBackground = Color(0xFFF5F7FF);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF616161);
  static const Color inputBorderDefault = Color(0xFFDFE1E5);
  static const Color iconBlack = Color(0xFF212121);
  static const Color iconWhite = Color(0xFFF5F5F5);
  static const Color lightThemeBackground = Colors.white;
  static const Color darkThemeBackground = Color(0xFF121212);
  static const Color darkThemeTitle = Color(0xFF00E5FF);
  static const Color lightThemeTitle = Color(0xFF212121);
  static Color? primaryCard = Colors.white;
  static Color? secondaryCard = Color(0xFF3D5AFE);
  static Color? notificationCard = Color(0xFFE3F2FD);
}