import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/config/app_routes.dart';
import 'package:merchant_app/config/app_strings.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:merchant_app/utils/components/button.dart';
import 'package:merchant_app/utils/components/form_field.dart';
import 'package:merchant_app/viewmodels/auth_viewmodel.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repeatPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _userIdController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose(); // Added missing disposal
    super.dispose();
  }

  Future<void> _clearErrors(BuildContext context) async {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    authVM.clearErrors();
  }

  Future<void> _handleRegister(BuildContext context) async {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    authVM.clearErrors();

    if (authVM.validateCredentials(_userIdController.text,
        _passwordController.text, _repeatPasswordController.text, false)) {
      Navigator.pushNamed(context, AppRoutes.otpVerification);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.appBarWithNavigation(
          screenTitle: AppStrings.titleRegister,
          onPressed: () {
            Navigator.pushReplacementNamed(context, AppRoutes.initial);
          },
          darkBackground: false),
      backgroundColor: AppColors.lightThemeBackground,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const Text(
                        AppStrings.registerMessage,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      CustomFormFields.primaryFormField(
                          label: AppStrings.labelMobileNumber,
                          controller: _userIdController,
                          keyboardType: TextInputType.phone,
                          // Changed to phone type
                          isPassword: false),
                      Consumer<AuthViewModel>(
                        builder: (context, authVM, _) =>
                            authVM.userIdError.isNotEmpty
                                ? Padding(
                                    padding:
                                        const EdgeInsets.only(top: 8, left: 12),
                                    child: Text(
                                      authVM.userIdError,
                                      style: const TextStyle(
                                          color: Colors.red, fontSize: 12),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 16),
                      CustomFormFields.primaryFormField(
                          label: AppStrings.labelPassword,
                          controller: _passwordController,
                          keyboardType: TextInputType.visiblePassword,
                          isPassword: true),
                      Consumer<AuthViewModel>(
                        builder: (context, authVM, _) =>
                            authVM.passwordError.isNotEmpty
                                ? Padding(
                                    padding:
                                        const EdgeInsets.only(top: 8, left: 12),
                                    child: Text(
                                      authVM.passwordError,
                                      style: const TextStyle(
                                          color: Colors.red, fontSize: 12),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 16),
                      CustomFormFields.primaryFormField(
                          label: AppStrings.labelRepeatPassword,
                          controller: _repeatPasswordController,
                          keyboardType: TextInputType.visiblePassword,
                          isPassword: true),
                      Consumer<AuthViewModel>(
                        builder: (context, authVM, _) =>
                            authVM.passwordError.isNotEmpty
                                ? Padding(
                                    padding:
                                        const EdgeInsets.only(top: 8, left: 12),
                                    child: Text(
                                      authVM.passwordError,
                                      style: const TextStyle(
                                          color: Colors.red, fontSize: 12),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 24),
                      Consumer<AuthViewModel>(
                        builder: (_, authVM, __) => CustomButtons.primaryButton(
                          text: AppStrings.buttonRegister,
                          onPressed: authVM.isLoading
                              ? () {}
                              : () => _handleRegister(context),
                        ),
                      ),
                      const SizedBox(height: 16),
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
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          _clearErrors(context);
                          Navigator.pushReplacementNamed(
                              context, AppRoutes.login);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                        ),
                        child: const Text(AppStrings.actionLoginAccount),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
