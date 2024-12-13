import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/config/app_config.dart';
import 'package:merchant_app/config/app_routes.dart';
import 'package:merchant_app/config/app_strings.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:merchant_app/utils/components/button.dart';
import 'package:merchant_app/utils/components/form_field.dart';
import 'package:merchant_app/viewmodels/auth_viewmodel.dart';
import 'package:provider/provider.dart';

class SetUsernameScreen extends StatefulWidget {
  final String email;
  final String password;
  final String repeatPassword;
  final String mobileNo;

  const SetUsernameScreen({
    super.key,
    required this.email,
    required this.password,
    required this.repeatPassword,
    required this.mobileNo,
  });

  @override
  State<SetUsernameScreen> createState() => _SetUsernameScreenState();
}

class _SetUsernameScreenState extends State<SetUsernameScreen> {
  final TextEditingController _displayNameController = TextEditingController();

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister(BuildContext context) async {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    authVM.clearErrors();

    // Validate display name
    final displayName = _displayNameController.text.trim();
    if (displayName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.errorDisplayNameEmpty)),
      );
      return;
    }

    // Debugging: Print values
    debugPrint('Debugging Registration Data:');
    debugPrint('Username: $displayName');
    debugPrint('Email: ${widget.email}');
    debugPrint('MobileNo: ${widget.mobileNo}');
    debugPrint('Password: ${widget.password}');
    debugPrint('RepeatPassword: ${widget.repeatPassword}');

    final success = await authVM.register(
      username: displayName,
      email: widget.email,
      mobileNo: widget.mobileNo,
      password: widget.password,
      repeatPassword: widget.repeatPassword,
    );

    if (success) {
      // Navigate to home screen or dashboard
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.appBarWithNavigation(
        screenTitle: AppStrings.titleSetUsername,
        onPressed: () => Navigator.pop(context),
        darkBackground: true,
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // Primary color header
            Container(
              width: AppConfig.deviceWidth,
              height: AppConfig.deviceHeight * 0.20,
              decoration: const BoxDecoration(
                color: AppColors.primary,
              ),
            ),
            // Curved white container
            Padding(
              padding: EdgeInsets.only(top: AppConfig.deviceHeight * 0.07),
              child: Container(
                width: AppConfig.deviceWidth,
                height: AppConfig.deviceHeight * 0.80,
                decoration: const BoxDecoration(
                  color: AppColors.lightThemeBackground,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(75),
                    topRight: Radius.circular(75),
                  ),
                ),
                child: Column(
                  children: [
                    // Spacer to position content
                    SizedBox(height: AppConfig.deviceHeight * 0.15),

                    // Display Name Field
                    CustomFormFields.primaryFormField(
                      label: AppStrings.labelDisplayName,
                      controller: _displayNameController,
                      keyboardType: TextInputType.name,
                      isPassword: false,
                    ),

                    const SizedBox(height: 35),

                    // Complete Profile Button
                    Consumer<AuthViewModel>(
                      builder: (_, authVM, __) => CustomButtons.primaryButton(
                        text: AppStrings.buttonConfirm,
                        onPressed: authVM.isLoading
                            ? () {} // Disable button when loading
                            : () { _handleRegister(context);},
                      ),
                    ),

                    const SizedBox(height: 16),

                    // General Error Message
                    Consumer<AuthViewModel>(
                      builder: (_, authVM, __) =>
                      authVM.generalError.isNotEmpty
                          ? Text(
                        authVM.generalError,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
