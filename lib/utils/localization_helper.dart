import 'package:flutter/material.dart';
import 'package:merchant_app/generated/l10n.dart';

/// A helper class that provides localized strings throughout the app.
/// This replaces the static AppStrings class with localized versions.
class LocalizationHelper {
  /// Get the localized strings from the current context
  static S of(BuildContext context) {
    return S.of(context);
  }

  /// Static helper to get a localized string from a BuildContext
  static String getString(
      BuildContext context, String Function(S) stringGetter) {
    return stringGetter(of(context));
  }
}
