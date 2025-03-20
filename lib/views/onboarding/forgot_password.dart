import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:merchant_app/utils/components/form_field.dart';
import 'package:merchant_app/viewmodels/auth_viewmodel.dart';
import 'package:provider/provider.dart';

import '../../generated/l10n.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _userIdController = TextEditingController();

  @override
  void dispose() {
    _userIdController.dispose();
    super.dispose();
  }

  // Future<void> _handleSubmit(BuildContext context) async {
  //   final authVM = Provider.of<AuthViewModel>(context, listen: false);
  //   //final success = await authVM.forgotPassword(_userIdController.text.trim());
  //
  //   if (success) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Password reset instructions sent successfully!'),
  //         backgroundColor: Colors.green,
  //       ),
  //     );
  //     Navigator.pop(context);
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(authVM.getError('general')),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    return Scaffold(
      appBar: CustomAppBar.appBarWithNavigation(
        screenTitle: strings.titleForgotPassword,
        onPressed: () => Navigator.pop(context),
        darkBackground: false, context: context,
      ),
      backgroundColor: AppColors.lightThemeBackground,
      body: Consumer<AuthViewModel>(
        builder: (context, authVM, _) => SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Reset Your Password',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Enter your email or mobile number to receive password reset instructions.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                CustomFormFields.normalSizedTextFormField(
                  label: strings.labelEmailAndMobileNo,
                  controller: _userIdController,
                  keyboardType: TextInputType.emailAddress,
                  isPassword: false,
                  enabled: !authVM.isLoading,
                  errorText: authVM.getError('username'),
                  onChanged: (_) => authVM.clearError('username'), context: context,
                ),
                const SizedBox(height: 16),
                // if (authVM.getError('general').isNotEmpty)
                //   Text(
                //     authVM.getError('general'),
                //     style: const TextStyle(color: Colors.red),
                //     textAlign: TextAlign.center,
                //   ),
                const SizedBox(height: 24),
                // CustomButtons.primaryButton(
                //   text: 'Submit',
                //   //onPressed: authVM.isLoading ? () {} : () => _handleSubmit(context),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}