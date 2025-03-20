import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/config/app_routes.dart';
import 'package:merchant_app/config/app_theme.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:merchant_app/utils/components/button.dart';
import 'package:merchant_app/utils/components/form_field.dart';
import 'package:merchant_app/utils/screens/loading_screen.dart';
import 'package:merchant_app/viewmodels/auth_viewmodel.dart';
import 'package:provider/provider.dart';
import '../../generated/l10n.dart';
import 'success_screen.dart';
import '../../utils/screens/otp_verification.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  Future<void> _handleRegister(BuildContext context, AuthViewModel authVM) async {
    authVM.resetErrors(); // Reset errors before validation

    final isValid = authVM.validatePlazaOwnerData(context);
    if (!isValid || authVM.mobileController.text.isEmpty) {
      return; // Rely on field-level errorText
    }

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => OtpVerificationScreen(mobileNumber: authVM.mobileController.text),
      ),
    );

    if (result == true) {
      authVM.setMobileVerified(true);
      final success = await authVM.registerPlazaOwner(context);
      if (success && authVM.currentUser != null) {
        _clearControllers(authVM);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SuccessScreen(userId: authVM.currentUser!.id.toString()),
          ),
        );
      } else if (authVM.getError('api') != null) {
        _showErrorSnackBar(context, authVM.getError('api')!);
      }
    } else if (result == false && authVM.getError('api') != null) {
      _showErrorSnackBar(context, authVM.getError('api')!);
    }
  }

  void _clearControllers(AuthViewModel authVM) {
    authVM.usernameController.clear();
    authVM.nameController.clear();
    authVM.mobileController.clear();
    authVM.emailController.clear();
    authVM.cityController.clear();
    authVM.stateController.clear();
    authVM.addressController.clear();
    authVM.pincodeController.clear();
    authVM.passwordController.clear();
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
    } else if (errorMessage.contains('Username must be unique') || errorMessage.contains('username already taken')) {
      message = strings.errorUsernameTaken;
    } else if (errorMessage.contains('already exists')) {
      message = strings.errorUserExists;
    } else if (errorMessage.contains('verification')) {
      message = strings.errorMobileVerificationRequired;
    } else if (errorMessage.contains('Invalid registration data')) {
      message = strings.errorInvalidRegistrationData;
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

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String errorKey,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    bool isLarge = false,
  }) {
    return Consumer<AuthViewModel>(
      builder: (context, authVM, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isLarge
              ? CustomFormFields.largeSizedTextFormField(
            label: label,
            controller: controller,
            enabled: true,
            keyboardType: keyboardType,
            errorText: authVM.getError(errorKey),
            onChanged: (_) => authVM.clearError(errorKey),
            context: context,
          )
              : CustomFormFields.normalSizedTextFormField(
            label: label,
            controller: controller,
            keyboardType: keyboardType,
            isPassword: isPassword,
            enabled: true,
            errorText: authVM.getError(errorKey),
            onChanged: (_) => authVM.clearError(errorKey),
            context: context,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final authVM = Provider.of<AuthViewModel>(context, listen: false);

    return Scaffold(
      appBar: CustomAppBar.appBarWithNavigation(
        screenTitle: strings.titleRegister,
        onPressed: () {
          authVM.resetErrors(); // Reset errors when navigating away
          _clearControllers(authVM);
          Navigator.pushReplacementNamed(context, AppRoutes.welcome);
        },
        darkBackground: Theme.of(context).brightness == Brightness.dark,
        context: context,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: authVM.isLoading
          ? const LoadingScreen()
          : Column(
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
                        strings.registerMessage,
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      _buildFormField(
                        label: strings.labelUsername,
                        controller: authVM.usernameController,
                        errorKey: 'username',
                      ),
                      const SizedBox(height: 16),
                      _buildFormField(
                        label: strings.labelPlazaOwnerName,
                        controller: authVM.nameController,
                        errorKey: 'name',
                      ),
                      const SizedBox(height: 16),
                      _buildFormField(
                        label: strings.labelMobileNumber,
                        controller: authVM.mobileController,
                        errorKey: 'mobile',
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      _buildFormField(
                        label: strings.labelEmail,
                        controller: authVM.emailController,
                        errorKey: 'email',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildFormField(
                              label: strings.labelCity,
                              controller: authVM.cityController,
                              errorKey: 'city',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildFormField(
                              label: strings.labelState,
                              controller: authVM.stateController,
                              errorKey: 'state',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildFormField(
                        label: strings.labelAddress,
                        controller: authVM.addressController,
                        errorKey: 'address',
                        keyboardType: TextInputType.streetAddress,
                        isLarge: true,
                      ),
                      const SizedBox(height: 16),
                      _buildFormField(
                        label: strings.labelPincode,
                        controller: authVM.pincodeController,
                        errorKey: 'pincode',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      _buildFormField(
                        label: strings.labelPassword,
                        controller: authVM.passwordController,
                        errorKey: 'password',
                        keyboardType: TextInputType.visiblePassword,
                        isPassword: true,
                      ),
                      const SizedBox(height: 16),
                      _buildFormField(
                        label: strings.labelConfirmPassword,
                        controller: authVM.confirmPasswordController,
                        errorKey: 'confirmPassword',
                        keyboardType: TextInputType.visiblePassword,
                        isPassword: true,
                      ),
                      const SizedBox(height: 24),
                      Consumer<AuthViewModel>(
                        builder: (context, authVM, _) => CustomButtons.primaryButton(
                          height: 50,
                          text: strings.buttonRegister,
                          onPressed: authVM.isLoading ? () {} : () => _handleRegister(context, authVM),
                          context: context,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          authVM.resetErrors(); // Reset errors when switching to login screen
                          _clearControllers(authVM);
                          Navigator.pushReplacementNamed(context, AppRoutes.login);
                        },
                        style: TextButton.styleFrom(foregroundColor: Theme.of(context).primaryColor),
                        child: Text(strings.actionLoginAccount, style: Theme.of(context).textTheme.bodyMedium),
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