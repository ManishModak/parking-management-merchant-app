import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/config/app_config.dart';

class CustomFormFields {
  static Widget primaryFormField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.visiblePassword,
    required bool isPassword,
    required bool enabled,
    String? errorText,
    FocusNode? focusNode,
    Null Function(dynamic value)? onChanged,
    int? maxLines,
  }) {
    bool hidePassword = isPassword;

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        // Calculate dynamic height based on error text
        double fieldHeight = 60;
        if (errorText != null) {
          // Estimate lines in error text (rough calculation)
          int errorLines = (errorText.length / 40).ceil();
          fieldHeight += errorLines * 20; // Adjust height per line
        }

        return SizedBox(
          width: AppConfig.deviceWidth*0.9,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: fieldHeight,
                child: TextFormField(
                  enabled: enabled,
                  controller: controller,
                  keyboardType: keyboardType,
                  obscureText: hidePassword,
                  onChanged: onChanged,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.formBackground,
                    errorText: errorText,
                    errorStyle: const TextStyle(
                      height: 1.2, // Increased height for better line spacing
                    ),
                    errorMaxLines: 5, // Allow multiple lines for error text
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
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget remarksFormField({
    required String label,
    required TextEditingController controller,
    required bool enabled,
    String? errorText,
    FocusNode? focusNode,
    Function(String)? onChanged,
  }) {
    // Calculate dynamic height based on error text
    double baseHeight = 140;
    int errorLines = errorText != null ? (errorText.length / 40).ceil() : 0;
    double fieldHeight = baseHeight + (errorLines * 20);

    return SizedBox(
      width: AppConfig.deviceWidth * 0.9,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: fieldHeight,
            child: TextFormField(
              enabled: enabled,
              controller: controller,
              maxLines: 5,
              onChanged: onChanged,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.formBackground,
                errorText: errorText,
                errorStyle: const TextStyle(
                  height: 1.2, // Increased height for better line spacing
                ),
                errorMaxLines: 5, // Allow multiple lines for error text
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
              ),
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  static Widget searchFormField({
    required TextEditingController controller,
    String hintText = 'Search users...',
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0,right: 12,top: 12),
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