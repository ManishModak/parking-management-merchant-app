import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_colors.dart';

class CustomFormFields {
  static Widget primaryFormField({
    required String label,
    required TextEditingController controller,
    required TextInputType keyboardType,
    required bool isPassword,
    required bool enabled,
    String? errorText, FocusNode? focusNode, Null Function(dynamic value)? onChanged,
  }) {
    bool hidePassword = isPassword;

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        // Calculate dynamic height based on error text
        final double containerHeight = errorText != null ? 80 : 60;

        return Container(
          height: containerHeight,
          width: 350,
          decoration: const BoxDecoration(
            color: AppColors.formBackground,
          ),
          child: TextFormField(
            enabled: enabled,
            controller: controller,
            keyboardType: keyboardType,
            obscureText: hidePassword,
            onChanged: onChanged,
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
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              suffixIcon: isPassword
                  ? Padding(
                padding: const EdgeInsets.only(right: 10),
                child: IconButton(
                  icon: Icon(
                    hidePassword ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.primary,
                  ),
                  onPressed: () {
                    setState(() {
                      hidePassword = !hidePassword;
                    });
                  },
                ),
              )
                  : null,
            ),
            style: const TextStyle(fontSize: 16),
          ),
        );
      },
    );
  }

  static Widget searchFormField({
    required TextEditingController controller,
    String hintText = 'Search users...',
  }) {
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    controller.clear();
                  },
                )
              : const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: AppColors.lightThemeBackground),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}
