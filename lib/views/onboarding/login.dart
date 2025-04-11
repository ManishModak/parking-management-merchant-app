import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/config/app_routes.dart';
import 'package:merchant_app/config/app_theme.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:merchant_app/utils/components/form_field.dart';
import 'package:merchant_app/utils/components/button.dart';
import 'package:merchant_app/viewmodels/auth_viewmodel.dart';
import 'package:provider/provider.dart';
import '../../generated/l10n.dart';

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

  Future<void> _handleLogin(BuildContext context) async {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    authVM.resetErrors(); // Reset errors before validation
    final success = await authVM.login(context, _userIdController.text.trim(), _passwordController.text);

    if (success) {
      _clearControllers(authVM);
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else if (authVM.getError('api') != null) {
      _showErrorSnackBar(context, authVM.getError('api')!);
    }
  }

  void _clearControllers(AuthViewModel authVM) {
    _userIdController.clear();
    _passwordController.clear();
    authVM.usernameController.clear();
    authVM.passwordController.clear();
    authVM.nameController.clear();
    authVM.mobileController.clear();
    authVM.emailController.clear();
    authVM.cityController.clear();
    authVM.stateController.clear();
    authVM.addressController.clear();
    authVM.pincodeController.clear();
    authVM.confirmPasswordController.clear();
  }

  void _showErrorSnackBar(BuildContext context, String errorMessage) {
    if (errorMessage.isEmpty) return;

    final strings = S.of(context);
    Color backgroundColor = AppColors.error;
    String message = errorMessage;

    if (errorMessage.contains('No internet')) {
      message = strings.errorNoInternet;
      backgroundColor = AppColors.warning;
    } else if (errorMessage.contains('timed out')) {
      message = strings.errorTimeout;
      backgroundColor = AppColors.warning;
    } else if (errorMessage.contains('Connection refused') || errorMessage.contains('ServerConnectionException')) {
      message = strings.errorServerUnavailable;
      backgroundColor = AppColors.error;
    } else if (errorMessage.contains('Server error')) {
      message = strings.errorServer;
      backgroundColor = AppColors.error;
    } else if (errorMessage.contains('reach user service')) {
      message = strings.errorServiceUnavailable;
      backgroundColor = AppColors.error;
    } else if (errorMessage.contains('Invalid credentials')) {
      message = strings.errorInvalidCredentials;
    } else if (errorMessage.contains('User not found')) {
      message = strings.errorUserNotFound;
    } else {
      message = strings.errorUnexpected;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: context.textPrimaryColor)),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final authVM = Provider.of<AuthViewModel>(context, listen: false);

    return Scaffold(
      appBar: CustomAppBar.appBarWithNavigation(
        screenTitle: strings.titleLogin,
        onPressed: () {
          authVM.resetErrors(); // Reset errors when navigating away
          _clearControllers(authVM);
          Navigator.pushReplacementNamed(context, AppRoutes.welcome);
        },
        darkBackground: Theme.of(context).brightness == Brightness.dark,
        context: context,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                      Text(
                        strings.loginMessage,
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      Consumer<AuthViewModel>(
                        builder: (context, authVM, _) => CustomFormFields.normalSizedTextFormField(
                          label: strings.labelEmailAndMobileNo,
                          controller: _userIdController,
                          keyboardType: TextInputType.emailAddress,
                          isPassword: false,
                          enabled: true,
                          errorText: authVM.getError('username'),
                          onChanged: (_) => authVM.clearError('username'),
                          context: context,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Consumer<AuthViewModel>(
                        builder: (context, authVM, _) => CustomFormFields.normalSizedTextFormField(
                          label: strings.labelPassword,
                          controller: _passwordController,
                          keyboardType: TextInputType.visiblePassword,
                          isPassword: true,
                          enabled: true,
                          errorText: authVM.getError('password'),
                          onChanged: (_) => authVM.clearError('password'),
                          context: context,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          authVM.resetErrors(); // Reset errors when navigating to forgot password
                          Navigator.pushNamed(context, AppRoutes.forgotPassword);
                        },
                        style: TextButton.styleFrom(foregroundColor: Theme.of(context).primaryColor),
                        child: Text(strings.actionForgotPassword, style: Theme.of(context).textTheme.bodySmall),
                      ),
                      const SizedBox(height: 8),
                      Consumer<AuthViewModel>(
                        builder: (context, authVM, _) => CustomButtons.primaryButton(
                          height: 50,
                          text: strings.buttonLogin,
                          onPressed: authVM.isLoading ? () {} : () => _handleLogin(context),
                          context: context,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          authVM.resetErrors(); // Reset errors when switching to register screen
                          _clearControllers(authVM);
                          Navigator.pushReplacementNamed(context, AppRoutes.register);
                        },
                        style: TextButton.styleFrom(foregroundColor: Theme.of(context).primaryColor),
                        child: Text(strings.actionCreateAccount, style: Theme.of(context).textTheme.bodyMedium),
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