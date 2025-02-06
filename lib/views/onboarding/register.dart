
import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/config/app_routes.dart';
import 'package:merchant_app/config/app_strings.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:merchant_app/utils/components/button.dart';
import 'package:merchant_app/utils/components/form_field.dart';
import 'package:merchant_app/utils/screens/loading_screen.dart';
import 'package:merchant_app/viewmodels/auth_viewmodel.dart';
import 'package:provider/provider.dart';

import '../../utils/screens/success_screen.dart';
import 'otp_verification.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileNoController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repeatPasswordController = TextEditingController();

  bool isMobileVerified = false;
  bool isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _nameController.dispose();
    _mobileNoController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _addressController.dispose();
    _districtController.dispose();
    _pincodeController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handleRegister() async {
    print("1");
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    authVM.clearAllErrors();

    // Validate before proceeding with OTP
    final isValid = authVM.validateRegistrationData(
      fullName: _usernameController.text,
      entityName: _nameController.text,
      mobileNo: _mobileNoController.text,
      email: _emailController.text,
      city: _cityController.text,
      state: _stateController.text,
      address: _addressController.text,
      password: _passwordController.text,
      confirmPassword: _repeatPasswordController.text,
      isAppRegister: true,
      isMobileVerified: false,
    );

    print("2");

    if (!isValid) {
      print("4");
      setState(() {});
      return;
    }

    print("3");
    try {
      setState(() => isLoading = true);

      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => OtpVerificationScreen(
            mobileNumber: _mobileNoController.text,
          ),
        ),
      );

      if (result == true) {
        setState(() => isMobileVerified = true);

        final userData = await authVM.register(
          username: _usernameController.text,
          entityName: _nameController.text,
          mobileNo: _mobileNoController.text,
          email: _emailController.text,
          city: _cityController.text,
          state: _stateController.text,
          address: _addressController.text,
          password: _passwordController.text,
          confirmPassword: _repeatPasswordController.text,
          isAppRegister: true,
          isMobileVerified: true,
        );

        if (userData != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SuccessScreen(
                userId: userData['id'].toString(),
              ),
            ),
          );
        } else {
          _showErrorSnackBar('Registration failed. Please try again.');
        }
      } else if (result == false) {
        _showErrorSnackBar('OTP verification failed. Please try again.');
      }
    } catch (e) {
      _showErrorSnackBar('An error occurred: ${e.toString()}');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _clearErrors(BuildContext context) async {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    authVM.clearAllErrors();
  }

  @override
  Widget build(BuildContext context) {

    if (isLoading) {
      return const LoadingScreen();
    }

    return Scaffold(
      appBar: CustomAppBar.appBarWithNavigation(
        screenTitle: AppStrings.titleRegister,
        onPressed: () {
          _clearErrors(context);
          Navigator.pushReplacementNamed(context, AppRoutes.welcome);
        },
        darkBackground: false,
      ),
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
                        label: AppStrings.labelUsername,
                        controller: _usernameController,
                        keyboardType: TextInputType.text,
                        isPassword: false,
                        enabled: true,
                      ),
                      Consumer<AuthViewModel>(
                        builder: (context, authVM, _) =>
                        authVM.usernameError.isNotEmpty
                            ? Padding(
                          padding: const EdgeInsets.only(top: 8, left: 12),
                          child: Text(
                            authVM.usernameError,
                            style: const TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        )
                            : const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 16),

                      CustomFormFields.primaryFormField(
                        label: AppStrings.labelPlazaOwnerName,
                        controller: _nameController,
                        keyboardType: TextInputType.text,
                        isPassword: false,
                        enabled: true,
                      ),
                      Consumer<AuthViewModel>(
                        builder: (context, authVM, _) =>
                        authVM.entityError.isNotEmpty
                            ? Padding(
                          padding: const EdgeInsets.only(top: 8, left: 12),
                          child: Text(
                            authVM.entityError,
                            style: const TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        )
                            : const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 16),

                      CustomFormFields.primaryFormField(
                        label: AppStrings.labelMobileNumber,
                        controller: _mobileNoController,
                        keyboardType: TextInputType.phone,
                        isPassword: false,
                        enabled: true,
                      ),
                      Consumer<AuthViewModel>(
                        builder: (context, authVM, _) =>
                        authVM.mobileError.isNotEmpty
                            ? Padding(
                          padding: const EdgeInsets.only(top: 8, left: 12),
                          child: Text(
                            authVM.mobileError,
                            style: const TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        )
                            : const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 16),

                      CustomFormFields.primaryFormField(
                        label: AppStrings.labelEmail,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        isPassword: false,
                        enabled: true,
                      ),
                      Consumer<AuthViewModel>(
                        builder: (context, authVM, _) =>
                        authVM.emailError.isNotEmpty
                            ? Padding(
                          padding: const EdgeInsets.only(top: 8, left: 12),
                          child: Text(
                            authVM.emailError,
                            style: const TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        )
                            : const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomFormFields.primaryFormField(
                                  label: AppStrings.labelCity,
                                  controller: _cityController,
                                  keyboardType: TextInputType.text,
                                  isPassword: false,
                                  enabled: true,
                                ),
                                Consumer<AuthViewModel>(
                                  builder: (context, authVM, _) =>
                                  authVM.cityError.isNotEmpty
                                      ? Padding(
                                    padding: const EdgeInsets.only(top: 8, left: 12),
                                    child: Text(
                                      authVM.cityError,
                                      style: const TextStyle(color: Colors.red, fontSize: 12),
                                    ),
                                  )
                                      : const SizedBox.shrink(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomFormFields.primaryFormField(
                                  label: AppStrings.labelState,
                                  controller: _stateController,
                                  keyboardType: TextInputType.text,
                                  isPassword: false,
                                  enabled: true,
                                ),
                                Consumer<AuthViewModel>(
                                  builder: (context, authVM, _) =>
                                  authVM.stateError.isNotEmpty
                                      ? Padding(
                                    padding: const EdgeInsets.only(top: 8, left: 12),
                                    child: Text(
                                      authVM.stateError,
                                      style: const TextStyle(color: Colors.red, fontSize: 12),
                                    ),
                                  )
                                      : const SizedBox.shrink(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      CustomFormFields.primaryFormField(
                        label: AppStrings.labelAddress,
                        controller: _addressController,
                        keyboardType: TextInputType.streetAddress,
                        isPassword: false,
                        enabled: true,
                      ),
                      Consumer<AuthViewModel>(
                        builder: (context, authVM, _) =>
                        authVM.addressError.isNotEmpty
                            ? Padding(
                          padding: const EdgeInsets.only(top: 8, left: 12),
                          child: Text(
                            authVM.addressError,
                            style: const TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        )
                            : const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 16),

                      CustomFormFields.primaryFormField(
                        label: AppStrings.labelPassword,
                        controller: _passwordController,
                        keyboardType: TextInputType.visiblePassword,
                        isPassword: true,
                        enabled: true,
                      ),
                      Consumer<AuthViewModel>(
                        builder: (context, authVM, _) =>
                        authVM.passwordError.isNotEmpty
                            ? Padding(
                          padding: const EdgeInsets.only(top: 8, left: 12),
                          child: Text(
                            authVM.passwordError,
                            style: const TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        )
                            : const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 16),

                      CustomFormFields.primaryFormField(
                        label: AppStrings.labelConfirmPassword,
                        controller: _repeatPasswordController,
                        keyboardType: TextInputType.visiblePassword,
                        isPassword: true,
                        enabled: true,
                      ),
                      Consumer<AuthViewModel>(
                        builder: (context, authVM, _) =>
                        authVM.confirmPasswordError.isNotEmpty
                            ? Padding(
                          padding: const EdgeInsets.only(top: 8, left: 12),
                          child: Text(
                            authVM.confirmPasswordError,
                            style: const TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        )
                            : const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 24),
                      Consumer<AuthViewModel>(
                        builder: (_, authVM, __) => CustomButtons.primaryButton(
                          text: AppStrings.buttonRegister,
                          onPressed: authVM.isLoading ? () {} : _handleRegister,
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
