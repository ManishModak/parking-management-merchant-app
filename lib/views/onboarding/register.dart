import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/config/app_routes.dart';
import 'package:merchant_app/config/app_theme.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:merchant_app/utils/components/button.dart';
import 'package:merchant_app/utils/components/form_field.dart';
import 'package:merchant_app/utils/screens/loading_screen.dart';
import 'package:merchant_app/viewmodels/auth_viewmodel.dart';
import 'package:provider/provider.dart';
import '../../config/app_config.dart';
import '../../generated/l10n.dart';
import '../../utils/exceptions.dart';
import 'success_screen.dart';
import '../../utils/screens/otp_verification.dart';
import '../../utils/components/dropdown.dart';
import '../../services/security/otp_verification_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _verificationService = VerificationService();
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  Future<void> _handleRegister(
      BuildContext context, AuthViewModel authVM) async {
    final strings = S.of(context); // Cache localized strings at the start
    final mobile = authVM.mobileController.text;

    // Validate plaza owner data and mobile number
    final isValid = authVM.validatePlazaOwnerData(context);
    if (!isValid || mobile.isEmpty) {
      authVM.resetErrors(); // Reset only if validation fails
      return;
    }

    try {
      // Send OTP directly from RegisterScreen
      await _verificationService.sendOtp(mobile);
      developer.log('OTP sent successfully to $mobile', name: 'RegisterScreen');

      // Navigate to OTP verification screen
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => OtpVerificationScreen(mobileNumber: mobile),
        ),
      );

      if (!mounted) return;

      if (result == true) {
        authVM.setMobileVerified(true);
        final success = await authVM.registerPlazaOwner(context);
        developer.log(
            'Registration result: success=$success, emailError=${authVM.getError('email')}, apiError=${authVM.getError('api')}',
            name: 'RegisterScreen');
        if (success && authVM.currentUser != null) {
          _clearControllers(authVM);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  SuccessScreen(userId: authVM.currentUser!.id.toString()),
            ),
          );
        } else {
          // Log the error state right before displaying the SnackBar
          developer.log(
              'Showing SnackBar: emailError=${authVM.getError('email')}, mobileError=${authVM.getError('mobile')}, apiError=${authVM.getError('api')}',
              name: 'RegisterScreen');
          if (authVM.getError('email') != null) {
            _showErrorSnackBar(
                "${authVM.getError('email')!}. ${strings.suggestionTryAnotherEmail}",
                strings);
          } else if (authVM.getError('mobile') != null) {
            _showErrorSnackBar(
                "${authVM.getError('mobile')!}. ${strings.suggestionTryAnotherNumber}",
                strings);
          } else if (authVM.getError('api') != null) {
            _showErrorSnackBar(authVM.getError('api')!, strings);
          } else {
            developer.log('Falling back to generic error: ${strings.errorRegistrationFailed}',
                name: 'RegisterScreen');
            _showErrorSnackBar(strings.errorRegistrationFailed, strings);
          }
        }
      } else if (result == false) {
        if (authVM.getError('api') != null) {
          _showErrorSnackBar(authVM.getError('api')!, strings);
        } else {
          _showErrorSnackBar(strings.errorVerificationFailed, strings);
        }
      }
    } on MobileNumberInUseException catch (e) {
      if (!mounted) return;
      authVM.setError('mobile', strings.errorMobileInUse);
      _showErrorSnackBar(
          "${strings.errorMobileInUse}. ${strings.suggestionTryAnotherNumber}",
          strings);
      developer.log('Mobile number in use: $mobile',
          name: 'RegisterScreen', error: e);
    } on EmailInUseException catch (e) {
      if (!mounted) return;
      authVM.setError('email', strings.errorEmailInUse);
      _showErrorSnackBar(
          "${strings.errorEmailInUse}. ${strings.suggestionTryAnotherEmail}",
          strings);
      developer.log('Email in use: ${authVM.emailController.text}',
          name: 'RegisterScreen', error: e);
    } on Exception catch (e) {
      if (!mounted) return;
      _showErrorSnackBar(strings.errorRegistrationFailed, strings);
      developer.log('Unexpected error during registration: $e',
          name: 'RegisterScreen', error: e);
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
    authVM.companyNameController.clear();
    authVM.companyTypeController.clear();
    authVM.aadhaarNumberController.clear();
    authVM.panNumberController.clear();
    authVM.bankNameController.clear();
    authVM.accountNumberController.clear();
    authVM.ifscCodeController.clear();
  }

  void _showErrorSnackBar(String errorMessage, S strings) {
    if (errorMessage.isEmpty) return;

    Color backgroundColor = AppColors.error;
    String message = errorMessage;

    developer.log('Input to _showErrorSnackBar: $errorMessage', name: 'RegisterScreen');

    // Handle specific cases
    if (errorMessage.contains('No internet')) {
      message = strings.errorNoInternet;
      backgroundColor = AppColors.warning;
    } else if (errorMessage.contains('timed out')) {
      message = strings.errorTimeout;
      backgroundColor = AppColors.warning;
    } else if (errorMessage.contains('Connection refused') ||
        errorMessage.contains('ServerConnectionException')) {
      message = strings.errorServerUnavailable;
      backgroundColor = AppColors.error;
    } else if (errorMessage.contains('Server error')) {
      message = strings.errorServer;
      backgroundColor = AppColors.error;
    } else if (errorMessage.contains('reach user service')) {
      message = strings.errorServiceUnavailable;
      backgroundColor = AppColors.error;
    } else if (errorMessage.contains('Username must be unique') ||
        errorMessage.contains('username already taken')) {
      message = strings.errorUsernameTaken;
    } else if (errorMessage.contains('already exists') &&
        !errorMessage.contains('This email is already in use') &&
        !errorMessage.contains('This mobile number is already in use')) {
      message = strings.errorUserExists;
    } else if (errorMessage.contains('verification')) {
      message = strings.errorMobileVerificationRequired;
    } else if (errorMessage.contains('Invalid registration data')) {
      message = strings.errorInvalidRegistrationData;
    } else if (errorMessage.contains('This mobile number is already in use') ||
        errorMessage.contains('This email is already in use')) {
      message = errorMessage; // Preserve the full message with suggestion
      backgroundColor = AppColors.error;
    } else {
      message = strings.errorUnexpected;
    }

    developer.log('Displaying SnackBar with message: $message', name: 'RegisterScreen');

    try {
      _scaffoldMessengerKey.currentState?.removeCurrentSnackBar();
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: TextStyle(color: context.textPrimaryColor),
          ),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 6),
        ),
      );
    } catch (e) {
      developer.log('Failed to show SnackBar: $e', name: 'RegisterScreen', error: e);
    }
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String errorKey,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    bool isLarge = false,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
    double? height,
    TextCapitalization textCapitalization = TextCapitalization.none,
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
            inputFormatters: inputFormatters,
            maxLength: maxLength,
            textCapitalization: textCapitalization,
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
            inputFormatters: inputFormatters,
            maxLength: maxLength,
            textCapitalization: textCapitalization,
            height: height,
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyTypeDropdown({
    required String label,
    required TextEditingController controller,
    required String errorKey,
  }) {
    return Consumer<AuthViewModel>(
      builder: (context, authVM, _) => CustomDropDown.normalDropDown(
        label: label,
        value: controller.text.isEmpty ? null : controller.text,
        items: ['Individual', 'LLP', 'Private Limited', 'Public Limited'],
        onChanged: (String? newValue) {
          if (newValue != null) {
            controller.text = newValue;
            authVM.clearError(errorKey);
            setState(() {});
          }
        },
        errorText: authVM.getError(errorKey),
        enabled: true,
        context: context,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final authVM = Provider.of<AuthViewModel>(context, listen: false);

    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        appBar: CustomAppBar.appBarWithNavigation(
          screenTitle: strings.titleRegister,
          onPressed: () {
            authVM.resetErrors();
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
                child: Form(
                  child: Center(
                    child: SizedBox(
                      width: AppConfig.deviceWidth * 0.9,
                      child: Column(
                        children: <Widget>[
                          Text(
                            strings.registerMessage,
                            style: Theme.of(context).textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 30),
                          _buildFormField(
                            label: "${strings.labelUsername} *",
                            controller: authVM.usernameController,
                            errorKey: 'username',
                          ),
                          const SizedBox(height: 16),
                          _buildFormField(
                            label: "${strings.labelPlazaOwnerName} *",
                            controller: authVM.nameController,
                            errorKey: 'name',
                          ),
                          const SizedBox(height: 16),
                          _buildFormField(
                            label: "${strings.labelMobileNumber} *",
                            controller: authVM.mobileController,
                            errorKey: 'mobile',
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            maxLength: 10,
                            height: 70,
                          ),
                          const SizedBox(height: 16),
                          _buildFormField(
                            label: "${strings.labelEmail} *",
                            controller: authVM.emailController,
                            errorKey: 'email',
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildFormField(
                                  label: "${strings.labelCity} *",
                                  controller: authVM.cityController,
                                  errorKey: 'city',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildFormField(
                                  label: "${strings.labelState} *",
                                  controller: authVM.stateController,
                                  errorKey: 'state',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildFormField(
                            label: "${strings.labelAddress} *",
                            controller: authVM.addressController,
                            errorKey: 'address',
                            keyboardType: TextInputType.streetAddress,
                            isLarge: true,
                          ),
                          const SizedBox(height: 16),
                          _buildFormField(
                            label: "${strings.labelPincode} *",
                            controller: authVM.pincodeController,
                            errorKey: 'pincode',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            height: 70,
                            maxLength: 6,
                          ),
                          const SizedBox(height: 16),
                          _buildFormField(
                            label: "${strings.labelCompanyName} *",
                            controller: authVM.companyNameController,
                            errorKey: 'companyName',
                          ),
                          const SizedBox(height: 16),
                          _buildCompanyTypeDropdown(
                            label: "${strings.labelCompanyType} *",
                            controller: authVM.companyTypeController,
                            errorKey: 'companyType',
                          ),
                          const SizedBox(height: 16),
                          _buildFormField(
                            label: strings.labelAadhaarNumber,
                            controller: authVM.aadhaarNumberController,
                            errorKey: 'aadhaarNumber',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            maxLength: 12,
                            height: 70,
                          ),
                          const SizedBox(height: 16),
                          _buildFormField(
                            label: strings.labelPanNumber,
                            controller: authVM.panNumberController,
                            errorKey: 'panNumber',
                            keyboardType: TextInputType.text,
                            textCapitalization: TextCapitalization.characters,
                            maxLength: 10,
                            height: 70,
                          ),
                          const SizedBox(height: 16),
                          _buildFormField(
                            label: strings.labelBankName,
                            controller: authVM.bankNameController,
                            errorKey: 'bankName',
                            keyboardType: TextInputType.text,
                          ),
                          const SizedBox(height: 16),
                          _buildFormField(
                            label: strings.labelAccountNumber,
                            controller: authVM.accountNumberController,
                            errorKey: 'accountNumber',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildFormField(
                            label: strings.labelIfscCode,
                            controller: authVM.ifscCodeController,
                            errorKey: 'ifscCode',
                            keyboardType: TextInputType.text,
                            textCapitalization: TextCapitalization.characters,
                            maxLength: 11,
                            height: 70,
                          ),
                          const SizedBox(height: 16),
                          _buildFormField(
                            label: "${strings.labelPassword} *",
                            controller: authVM.passwordController,
                            errorKey: 'password',
                            keyboardType: TextInputType.visiblePassword,
                            isPassword: true,
                          ),
                          const SizedBox(height: 16),
                          _buildFormField(
                            label: "${strings.labelConfirmPassword} *",
                            controller: authVM.confirmPasswordController,
                            errorKey: 'confirmPassword',
                            keyboardType: TextInputType.visiblePassword,
                            isPassword: true,
                          ),
                          const SizedBox(height: 24),
                          Consumer<AuthViewModel>(
                            builder: (context, authVM, _) =>
                                CustomButtons.primaryButton(
                                  height: 50,
                                  text: strings.buttonRegister,
                                  onPressed: authVM.isLoading
                                      ? () {}
                                      : () => _handleRegister(context, authVM),
                                  context: context,
                                ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              authVM.resetErrors();
                              _clearControllers(authVM);
                              Navigator.pushReplacementNamed(
                                  context, AppRoutes.login);
                            },
                            style: TextButton.styleFrom(
                                foregroundColor:
                                Theme.of(context).primaryColor),
                            child: Text(strings.actionLoginAccount,
                                style:
                                Theme.of(context).textTheme.bodyMedium),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}