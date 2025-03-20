import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/config/app_theme.dart';
import 'dart:developer' as developer;
import '../../config/app_config.dart';
import '../../generated/l10n.dart';

class CustomFormFields {
  static Widget normalSizedTextFormField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    required bool isPassword,
    required bool enabled,
    String? errorText,
    String? hintText,
    FocusNode? focusNode,
    Function(String)? onChanged,
    int? maxLines,
    Widget? suffixIcon,
    required BuildContext context,
  }) {
    return _PasswordTextField(
      label: label,
      controller: controller,
      keyboardType: keyboardType,
      isPassword: isPassword,
      enabled: enabled,
      errorText: errorText,
      hintText: hintText,
      focusNode: focusNode,
      onChanged: onChanged,
      maxLines: maxLines,
      suffixIcon: suffixIcon,
      context: context,
    );
  }

  static Widget largeSizedTextFormField({
    required String label,
    required TextEditingController controller,
    required bool enabled,
    String? errorText,
    String? hintText,
    FocusNode? focusNode,
    Function(String)? onChanged,
    TextInputType keyboardType = TextInputType.text,
    required BuildContext context,
  }) {
    double baseHeight = 140;
    int errorLines = errorText != null && errorText.isNotEmpty
        ? (errorText.length / 40).ceil().clamp(0, 5)
        : 0;
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
              keyboardType: keyboardType,
              enabled: enabled,
              controller: controller,
              maxLines: 5,
              onChanged: (value) {
                developer.log(
                  'Large text field "$label" changed: $value',
                  name: 'CustomFormFields',
                );
                onChanged?.call(value);
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: context.formBackgroundColor,
                errorText: errorText?.isEmpty ?? true ? null : errorText,
                errorStyle: const TextStyle(height: 1.2),
                errorMaxLines: 5,
                labelText: label,
                hintText: hintText,
                hintStyle: TextStyle(color: context.textSecondaryColor),
                labelStyle: TextStyle(color: context.textPrimaryColor),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: context.inputBorderEnabledColor),
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
                  borderSide: const BorderSide(color: AppColors.error),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.error, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              ),
              style: TextStyle(
                fontSize: 16,
                color: enabled
                    ? context.textPrimaryColor
                    : context.textSecondaryColor.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget searchFormField({
    required TextEditingController controller,
    String hintText = '',
    Function(String)? onChanged,
    required BuildContext context,
  }) {
    final strings = S.of(context);
    return TextField(
      controller: controller,
      onChanged: (value) {
        developer.log(
          'Search field changed: $value',
          name: 'CustomFormFields',
        );
        onChanged?.call(value);
      },
      decoration: InputDecoration(
        hintText: hintText.isEmpty ? strings.hintSearchUsers : hintText,
        hintStyle: TextStyle(color: context.textPrimaryColor),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
          icon: Icon(Icons.clear, color: context.textPrimaryColor),
          tooltip: strings.searchClear,
          onPressed: () {
            controller.clear();
            developer.log(
              'Search field cleared',
              name: 'CustomFormFields',
            );
            onChanged?.call('');
          },
        )
            : Icon(Icons.search, color: context.textPrimaryColor),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.inputBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.inputBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.inputBorderFocused,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: context.cardColor,
      ),
      style: TextStyle(color: context.textPrimaryColor),
    );
  }
}

class _PasswordTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool isPassword;
  final bool enabled;
  final String? errorText;
  final String? hintText;
  final FocusNode? focusNode;
  final Function(String)? onChanged;
  final int? maxLines;
  final Widget? suffixIcon;
  final BuildContext context;

  const _PasswordTextField({
    required this.label,
    required this.controller,
    required this.keyboardType,
    required this.isPassword,
    required this.enabled,
    this.errorText,
    this.hintText,
    this.focusNode,
    this.onChanged,
    this.maxLines,
    this.suffixIcon,
    required this.context,
  });

  @override
  _PasswordTextFieldState createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<_PasswordTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    double fieldHeight = 60;
    if (widget.errorText != null && widget.errorText!.isNotEmpty) {
      int errorLines = (widget.errorText!.length / 40).ceil().clamp(0, 5);
      fieldHeight += errorLines * 20;
    }

    return SizedBox(
      width: AppConfig.deviceWidth * 0.9,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: fieldHeight,
            child: TextFormField(
              enabled: widget.enabled,
              controller: widget.controller,
              keyboardType: widget.keyboardType,
              obscureText: widget.isPassword ? _obscureText : false,
              focusNode: widget.focusNode,
              onChanged: (value) {
                developer.log(
                  'Text field "${widget.label}" changed: $value',
                  name: 'CustomFormFields',
                );
                widget.onChanged?.call(value);
              },
              maxLines: widget.maxLines ?? 1,
              decoration: InputDecoration(
                filled: true,
                fillColor: widget.context.formBackgroundColor,
                errorText: widget.errorText?.isEmpty ?? true ? null : widget.errorText,
                errorStyle: const TextStyle(height: 1.2),
                errorMaxLines: 5,
                labelText: widget.label,
                hintText: widget.hintText,
                hintStyle: TextStyle(color: widget.context.textSecondaryColor),
                labelStyle: TextStyle(color: widget.context.textPrimaryColor),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: widget.context.inputBorderEnabledColor),
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
                  borderSide: const BorderSide(color: AppColors.error),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.error, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                suffixIcon: widget.isPassword
                    ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: widget.context.textPrimaryColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                      developer.log(
                        'Password visibility toggled: ${_obscureText ? 'hidden' : 'visible'}',
                        name: 'CustomFormFields',
                      );
                    });
                  },
                )
                    : widget.suffixIcon,
              ),
              style: TextStyle(
                fontSize: 16,
                color: widget.enabled
                    ? widget.context.textPrimaryColor
                    : widget.context.textSecondaryColor.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
