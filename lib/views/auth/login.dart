import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/config/app_config.dart';
import 'package:merchant_app/config/app_routes.dart';
import 'package:merchant_app/config/app_strings.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:merchant_app/utils/components/form_field.dart';
import 'package:merchant_app/utils/components/button.dart';
import 'package:merchant_app/viewmodels/auth_viewmodel.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _userIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _clearErrors(BuildContext context) async {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    authVM.clearErrors();
  }

  Future<void> _handleLogin(BuildContext context) async {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    authVM.clearErrors();
    if (authVM.validateCredentials(
        _userIdController.text, _passwordController.text, '', true)) {
      Navigator.pushNamed(context, AppRoutes.otpVerification);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.appBarWithNavigation(
          screenTitle: AppStrings.titleLogin,
          onPressed: () {
            final authVM = Provider.of<AuthViewModel>(context, listen: false);
            authVM.clearErrors();
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
                        AppStrings.loginMessage,
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      CustomFormFields.primaryFormField(
                          label: AppStrings.labelUserId,
                          controller: _userIdController,
                          keyboardType: TextInputType.visiblePassword,
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
                                        color: Colors.red,
                                        fontSize: 12,
                                      ),
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
                                        color: Colors.red,
                                        fontSize: 12,
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(
                              context, AppRoutes.forgotPassword);
                          _clearErrors(context);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                        ),
                        child: const Text(
                          AppStrings.actionForgotPassword,
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Consumer<AuthViewModel>(
                        builder: (_, authVM, __) => CustomButtons.primaryButton(
                          text: AppStrings.buttonLogin,
                          onPressed: authVM.isLoading
                              ? () {}
                              : () => _handleLogin(context),
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
                              context, AppRoutes.register);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                        ),
                        child: const Text(AppStrings.actionCreateAccount),
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
