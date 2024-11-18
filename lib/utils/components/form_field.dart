import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/config/app_config.dart';

class CustomFormFields {
  static Widget primaryFormField({
    required String label,
    required TextEditingController controller,
    required TextInputType keyboardType,
    required bool isPassword,
  }) {
    bool hidePassword = isPassword;

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Container(
          height: 60,
          width: AppConfig.deviceWidth * 0.8,
          decoration: const BoxDecoration(
            color: AppColors.formBackground,
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: hidePassword,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(color: AppColors.primary),
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
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              suffixIcon: isPassword
                  ? Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: IconButton(
                        icon: Icon(
                          hidePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
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
}
