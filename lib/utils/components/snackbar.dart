import 'package:flutter/material.dart';

// Enum to define different types of snackbars for styling
enum SnackbarType { success, error, warning, info }

class AppSnackbar {
  /// Shows a customized SnackBar.
  ///
  /// [context]: The BuildContext from where the SnackBar is triggered.
  /// [message]: The text content of the SnackBar.
  /// [type]: The type of SnackBar (success, error, warning, info), determines background color.
  /// [duration]: How long the SnackBar is displayed.
  static void showSnackbar({
    required BuildContext context,
    required String message,
    SnackbarType type = SnackbarType.info, // Default to info
    Duration duration = const Duration(seconds: 3),
  }) {
    // Ensure context is still valid before showing snackbar
    if (!context.mounted) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    // Remove any existing snackbars first
    scaffoldMessenger.hideCurrentSnackBar();

    // Determine background color based on type
    Color backgroundColor;
    IconData iconData;
    switch (type) {
      case SnackbarType.success:
        backgroundColor = Colors.green.shade600;
        iconData = Icons.check_circle_outline;
        break;
      case SnackbarType.error:
        backgroundColor = Colors.red.shade600;
        iconData = Icons.error_outline;
        break;
      case SnackbarType.warning:
        backgroundColor = Colors.orange.shade700;
        iconData = Icons.warning_amber_outlined;
        break;
      case SnackbarType.info:
      default:
        backgroundColor = Colors.blue.shade600;
        iconData = Icons.info_outline;
        break;
    }

    // Create the SnackBar widget
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(iconData, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              maxLines: 3, // Allow multiple lines
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      duration: duration,
      behavior: SnackBarBehavior.floating, // Makes it float above bottom nav bar
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0), // Add margin
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // Add padding
      action: SnackBarAction(
        label: 'Dismiss', // Optional dismiss action
        textColor: Colors.white,
        onPressed: () {
          scaffoldMessenger.hideCurrentSnackBar();
        },
      ),
    );

    // Show the SnackBar
    scaffoldMessenger.showSnackBar(snackBar);
  }
}