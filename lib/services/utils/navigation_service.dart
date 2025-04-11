import 'package:flutter/material.dart';

class NavigationService {
  // Private constructor
  NavigationService._();

  // Global key for accessing the Navigator state
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Optional: Add helper methods for navigation if desired
  // static Future<T?>? pushNamed<T extends Object?>(String routeName, {Object? arguments}) {
  //   return navigatorKey.currentState?.pushNamed<T>(routeName, arguments: arguments);
  // }
  //
  // static void pop<T extends Object?>([ T? result ]) {
  //    navigatorKey.currentState?.pop<T>(result);
  // }

  // Getter for a potentially safe context (primarily for ScaffoldMessenger/Dialogs)
  // Use with caution, passing context explicitly is often safer.
  static BuildContext? get navigatorContext => navigatorKey.currentContext;
}