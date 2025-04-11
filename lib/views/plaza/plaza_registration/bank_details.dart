import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:merchant_app/utils/components/form_field.dart'; // Your custom form field
import 'package:provider/provider.dart';
import '../../../generated/l10n.dart'; // Localization
import '../../../viewmodels/plaza/plaza_viewmodel.dart'; // Main ViewModel
import 'dart:developer' as developer; // For logging

class BankDetailsStep extends StatelessWidget {
  const BankDetailsStep({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch the sub-view model via the main view model for reactive UI updates
    final bankDetailsVM = context.watch<PlazaViewModel>().bankDetails;
    final strings = S.of(context);
    final theme = Theme.of(context);

    // Determine overall enabled state for the step's fields from the ViewModel
    final bool isEnabled = bankDetailsVM.isEditable;

    developer.log(
        '[BankDetailsStep UI Build] isEditable=$isEnabled, isLoading=${bankDetailsVM.isLoading}, Errors: ${bankDetailsVM.errors.isNotEmpty}',
        name: 'BankDetailsStep');

    // Define icon color based on enabled state for visual feedback
    final Color iconColor = isEnabled ? theme.iconTheme.color ?? theme.primaryColor : theme.disabledColor;

    // Use AbsorbPointer and Opacity to control interactivity and appearance
    return AbsorbPointer(
      absorbing: !isEnabled, // Prevent interaction when not editable
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.7, // Dim UI visually when disabled
        child: SingleChildScrollView( // Ensure content scrolls if needed
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch fields horizontally
            children: [
              // --- Bank Name ---
              CustomFormFields.normalSizedTextFormField(
                context: context,
                label: "${strings.labelBankName} *", // Indicate required
                controller: bankDetailsVM.bankNameController,
                enabled: isEnabled, // Control enabled state
                // Read error using the key consistent with VM map ('bankName')
                errorText: isEnabled ? bankDetailsVM.errors['bankName'] : null,
                isPassword: false,
                prefixIcon: Icon(Icons.account_balance_outlined, color: iconColor),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),

              // --- Account Number ---
              CustomFormFields.normalSizedTextFormField(
                context: context,
                label: "${strings.labelAccountNumber} *", // Indicate required
                controller: bankDetailsVM.accountNumberController,
                enabled: isEnabled,
                // Read error using the key consistent with VM map ('accountNumber')
                errorText: isEnabled ? bankDetailsVM.errors['accountNumber'] : null,
                isPassword: false,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                prefixIcon: Icon(Icons.pin_outlined, color: iconColor),
              ),
              const SizedBox(height: 16),

              // --- Account Holder Name ---
              CustomFormFields.normalSizedTextFormField(
                context: context,
                label: "${strings.labelAccountHolderName} *", // Indicate required
                controller: bankDetailsVM.accountHolderController,
                enabled: isEnabled,
                // Read error using the key consistent with VM map ('accountHolderName')
                errorText: isEnabled ? bankDetailsVM.errors['accountHolderName'] : null,
                isPassword: false,
                prefixIcon: Icon(Icons.person_outline, color: iconColor),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),

              // --- IFSC Code ---
              CustomFormFields.normalSizedTextFormField(
                context: context,
                label: "${strings.labelIfscCode} *", // Indicate required
                controller: bankDetailsVM.ifscCodeController,
                enabled: isEnabled,
                // *** FIXED: Read error using the key consistent with VM map ('IFSCcode') ***
                errorText: isEnabled ? bankDetailsVM.errors['IFSCcode'] : null,
                isPassword: false,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                  LengthLimitingTextInputFormatter(11),
                ],
                prefixIcon: Icon(Icons.code_outlined, color: iconColor),
              ),
              const SizedBox(height: 24), // Space before general error display

              // --- General Error Display ---
              // Show general error if it exists AND the step is editable
              if (isEnabled && bankDetailsVM.errors['general'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                  child: Center(
                    child: Text(
                      bankDetailsVM.errors['general']!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error // Use theme's standard error color
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              // Add final bottom padding if needed
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}