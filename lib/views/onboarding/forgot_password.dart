import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/config/app_config.dart';
import 'package:merchant_app/config/app_strings.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:merchant_app/utils/components/form_field.dart';
import 'package:merchant_app/utils/components/button.dart';
import 'package:merchant_app/viewmodels/auth_viewmodel.dart';
import 'package:provider/provider.dart';

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

  Future<void> _handleSubmit(BuildContext context) async {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    authVM.clearAllErrors();
    // TODO: Implement forgot password logic
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.appBarWithNavigation(
        screenTitle: AppStrings.titleForgotPassword,
        onPressed: () => Navigator.pop(context),
        darkBackground: true,
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              width: AppConfig.deviceWidth,
              height: AppConfig.deviceHeight * 0.20,
              decoration: const BoxDecoration(
                color: AppColors.primary,
              ),
            ),
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
                    SizedBox(height: AppConfig.deviceHeight * 0.20),
                    CustomFormFields.primaryFormField(
                      label: AppStrings.labelUserId,
                      controller: _userIdController,
                      keyboardType: TextInputType.phone,
                      isPassword: false,
                      enabled: true
                    ),
                    Consumer<AuthViewModel>(
                      builder: (context, authVM, _) => authVM
                              .userIdError.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(top: 8, left: 12),
                              child: Text(
                                authVM.userIdError,
                                style: const TextStyle(
                                    color: Colors.red, fontSize: 12),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 35),
                    Consumer<AuthViewModel>(
                      builder: (_, authVM, __) => CustomButtons.primaryButton(
                        text: AppStrings.buttonContinue,
                        onPressed: authVM.isLoading
                            ? () {}
                            : () => _handleSubmit(context),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Consumer<AuthViewModel>(
                      builder: (_, authVM, __) => authVM.generalError.isNotEmpty
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
