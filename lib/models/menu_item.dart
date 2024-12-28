import 'package:flutter/material.dart';

// Create a class to hold plaza item data
class MenuCardItem {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  const MenuCardItem({
    required this.title,
    required this.icon,
    this.onTap,
  });
}
