import 'package:flutter/material.dart';
import 'package:merchant_app/models/menu_item.dart';

import '../../config/app_colors.dart';

class CustomDropDown {
  static Widget normalDropDown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    IconData? icon,
    bool enabled = true,
    String? errorText,
  }) {
    // Calculate dynamic height based on error text
    final double containerHeight = errorText != null ? 80 : 60;

    return Container(
      height: containerHeight,
      width: 350,
      decoration: const BoxDecoration(
        color: AppColors.formBackground,
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        onChanged: enabled ? onChanged : null,
        items: items.map<DropdownMenuItem<String>>((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: enabled ? AppColors.textPrimary : AppColors.textDisabled,
                fontSize: 16,
              ),
            ),
          );
        }).toList(),
        decoration: InputDecoration(
          errorText: errorText,
          errorStyle: const TextStyle(
            height: 0.8, // Reduce space between error text and field
          ),
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.primary),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.inputBorderFocused,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        ),
        icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
        dropdownColor: AppColors.formBackground,
        style: const TextStyle(fontSize: 16),
        isExpanded: true,
      ),
    );
  }

  static Widget expansionDropDown({
    required String title,
    required IconData icon,
    required List<MenuCardItem> items,
    Color iconColor = Colors.black,
    Color textColor = AppColors.textPrimary,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: AppColors.primaryCard,
      child: ExpansionTile(
        leading: Icon(icon, color: iconColor),
        title: Text(
          title,
          style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold
          ),
        ),
        children: items.map((item) => ListTile(
          leading: Icon(item.icon, color: iconColor),
          title: Text(
            item.title,
            style: TextStyle(color: textColor),
          ),
          onTap: item.onTap,
        )).toList(),
      ),
    );
  }
}