import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/config/app_theme.dart';
import 'dart:developer' as developer;
import '../../config/app_config.dart';
import '../../generated/l10n.dart';
import 'package:flutter/services.dart'; // Import needed

class CustomFormFields {
  static Widget normalSizedTextFormField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false, // Default to false
    required bool enabled,
    String? errorText,
    String? hintText,
    FocusNode? focusNode,
    Function(String)? onChanged,
    int? maxLines = 1, // Default to 1
    Widget? suffixIcon,
    required BuildContext context,
    double? height,
    // --- Added optional parameters ---
    Widget? prefixIcon,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
    TextCapitalization textCapitalization = TextCapitalization.none,
    // --- End Added Parameters ---
  }) {
    // Pass all parameters, including new optional ones, to _PasswordTextField
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
      maxLines: isPassword ? 1 : maxLines,
      // Ensure password is single line
      suffixIcon: suffixIcon,
      context: context,
      // Pass context
      height: height,
      // --- Pass new optional parameters ---
      prefixIcon: prefixIcon,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      textCapitalization: textCapitalization,
      // --- End Pass New Parameters ---
    );
  }

  // largeSizedTextFormField method remains the same as in the previous response
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
    double? height,
    // Added optional parameters
    Widget? prefixIcon,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    // ... (implementation from previous response using TextFormField directly)
    double baseHeight = height ?? 140;
    int errorLines = errorText != null && errorText.isNotEmpty
        ? (errorText.length / 40).ceil().clamp(1, 5)
        : 0;
    double fieldHeight = baseHeight + (errorLines * 18.0);

    return SizedBox(
      width: AppConfig.deviceWidth * 0.9,
      height: fieldHeight,
      child: TextFormField(
        keyboardType: keyboardType,
        enabled: enabled,
        controller: controller,
        maxLines: 5,
        focusNode: focusNode,
        inputFormatters: inputFormatters,
        maxLength: maxLength,
        textCapitalization: textCapitalization,
        onChanged: onChanged,
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
          prefixIcon: prefixIcon,
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
          contentPadding:
              EdgeInsets.fromLTRB(prefixIcon != null ? 12 : 20, 20, 20, 20),
        ),
        style: TextStyle(
          fontSize: 16,
          color: enabled
              ? context.textPrimaryColor
              : context.textSecondaryColor.withOpacity(0.5),
        ),
      ),
    );
  }

  static Widget searchFormField({
    required TextEditingController controller,
    String hintText = '',
    Function(String)? onChanged,
    required BuildContext context,
    double? height,
  }) {
    final strings = S.of(context);
    // Default height if not specified
    final double fieldHeight = height ?? 60;

    return SizedBox(
      height: fieldHeight,
      child: TextField(
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
            borderSide: BorderSide(color: context.inputBorderEnabledColor),
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
      ),
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
  final BuildContext context; // Context passed down for theme access
  final double? height;

  // --- New Optional Parameters ---
  final Widget? prefixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final TextCapitalization textCapitalization;

  // --- End New Parameters ---

  const _PasswordTextField({
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.text, // Default keyboardType
    required this.isPassword,
    required this.enabled,
    this.errorText,
    this.hintText,
    this.focusNode,
    this.onChanged,
    this.maxLines,
    this.suffixIcon,
    required this.context,
    this.height,
    // --- New Optional Parameters ---
    this.prefixIcon,
    this.inputFormatters,
    this.maxLength,
    this.textCapitalization = TextCapitalization.none, // Default capitalization
    // --- End New Parameters ---
    super.key, // Add Key
  });

  @override
  _PasswordTextFieldState createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<_PasswordTextField> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    // Initialize _obscureText only if it's a password field
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    // Use the context passed down from the static method
    final effectiveContext = widget.context;
    final bool hasError =
        widget.errorText != null && widget.errorText!.isNotEmpty;

    // Calculate field height (keep your existing logic)
    double baseHeight = widget.height ?? 60; // Base height
    int errorLines =
        hasError ? (widget.errorText!.length / 40).ceil().clamp(1, 3) : 0;
    double fieldHeight =
        baseHeight + (errorLines * 18.0); // Adjust multiplier as needed

    return SizedBox(
      width: AppConfig.deviceWidth * 0.9, // Keep consistent width
      // Use IntrinsicHeight or calculated height carefully
      height: fieldHeight,
      child: TextFormField(
        enabled: widget.enabled,
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        obscureText: widget.isPassword ? _obscureText : false,
        // Use state variable
        focusNode: widget.focusNode,
        onChanged: widget.onChanged,
        // Pass onChanged directly
        maxLines: widget.isPassword ? 1 : (widget.maxLines ?? 1),
        // Ensure password is single line
        // --- Use New Parameters ---
        inputFormatters: widget.inputFormatters,
        maxLength: widget.maxLength,
        textCapitalization: widget.textCapitalization,
        // --- End Use New Parameters ---
        decoration: InputDecoration(
          filled: true,
          fillColor: effectiveContext.formBackgroundColor,
          labelText: widget.label,
          hintText: widget.hintText,
          errorText: hasError ? widget.errorText : null,
          // Let TextFormField handle error display
          errorStyle: const TextStyle(height: 1.2),
          errorMaxLines: 3,
          // Allow multiple lines for errors
          hintStyle: TextStyle(color: effectiveContext.textSecondaryColor),
          labelStyle: TextStyle(color: effectiveContext.textPrimaryColor),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          // --- Use New Parameter ---
          prefixIcon: widget.prefixIcon,
          // --- End Use New Parameter ---
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: effectiveContext
                        .textPrimaryColor, // Or textSecondaryColor
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
          // Use original suffixIcon if not password
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: effectiveContext.inputBorderEnabledColor),
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
          // Adjust padding if prefix icon exists
          contentPadding: EdgeInsets.fromLTRB(
              widget.prefixIcon != null ? 12 : 20, 15, 12, 15),
        ),
        style: TextStyle(
          fontSize: 16,
          color: widget.enabled
              ? effectiveContext.textPrimaryColor
              : effectiveContext.textSecondaryColor.withOpacity(0.5),
        ),
      ),
    );
  }
}
