import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/config/app_config.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:merchant_app/utils/components/button.dart';
import 'package:merchant_app/utils/components/dropdown.dart';
import 'package:merchant_app/utils/components/form_field.dart';
import 'package:merchant_app/utils/exceptions.dart';
import 'package:merchant_app/services/storage/secure_storage_service.dart';
import 'package:merchant_app/viewmodels/user_viewmodel.dart';
import 'package:provider/provider.dart';
import '../../generated/l10n.dart';

class UserSetResetPasswordScreen extends StatefulWidget {
  final String operatorId;

  const UserSetResetPasswordScreen({
    super.key,
    required this.operatorId,
  });

  @override
  State<UserSetResetPasswordScreen> createState() =>
      _UserSetResetPasswordScreenState();
}

class _UserSetResetPasswordScreenState
    extends State<UserSetResetPasswordScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? selectedRole;
  String? currentUserRole;
  bool _isLoading = false;

  final Map<String, List<String>> roleHierarchy = {
    'Plaza Owner': [
      'Plaza Owner',
      'Centralized Controller',
      'Plaza Admin',
      'Plaza Operator',
      'Cashier',
      'Backend Monitoring Operator',
      'Supervisor'
    ],
    'Plaza Admin': [
      'Plaza Operator',
      'Cashier',
      'Backend Monitoring Operator',
      'Supervisor'
    ],
  };

  @override
  void initState() {
    super.initState();
    developer.log(
        'UserSetResetPasswordScreen initialized with operatorId: ${widget.operatorId}',
        name: 'UserSetResetPasswordScreen');
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _fetchUserData();
      await _loadOperatorData();
    });
  }

  Future<void> _fetchUserData() async {
    final strings = S.of(context);
    try {
      final userViewModel = Provider.of<UserViewModel>(context, listen: false);
      final userId = await SecureStorageService().getUserId();
      if (userId != null) {
        await userViewModel.fetchUser(userId: userId, isCurrentAppUser: true);
        if (mounted) {
          setState(() {
            currentUserRole = userViewModel.currentUser?.role;
            developer.log('Fetched current user role: $currentUserRole',
                name: 'UserSetResetPasswordScreen');
          });
        }
      } else {
        developer.log('No user ID found in storage',
            name: 'UserSetResetPasswordScreen');
      }
    } catch (e) {
      developer.log('Error fetching user data: $e',
          name: 'UserSetResetPasswordScreen', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${strings.errorLoadCurrentUserInfo}: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _loadOperatorData() async {
    final strings = S.of(context);
    try {
      final userViewModel = Provider.of<UserViewModel>(context, listen: false);
      await userViewModel.fetchUser(
          userId: widget.operatorId, isCurrentAppUser: false);
      if (mounted) {
        await _loadUser();
      }
    } catch (e) {
      developer.log('Error loading operator data: $e',
          name: 'UserSetResetPasswordScreen', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${strings.errorLoadOperatorData}: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _loadUser() async {
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    final currentOperator = userViewModel.currentOperator;

    if (currentOperator != null && mounted) {
      setState(() {
        _nameController.text = currentOperator.name;
        _idController.text = currentOperator.id;
        _emailController.text = currentOperator.email;
        _mobileNumberController.text = currentOperator.mobileNumber;
        selectedRole = currentOperator.role;
        final availableRoles = getAvailableRoles();
        if (!availableRoles.contains(selectedRole)) {
          developer.log(
              'Role $selectedRole not in $availableRoles, setting to null',
              name: 'UserSetResetPasswordScreen');
          selectedRole = null;
        }
        developer.log(
            'Loaded operator data: id=${currentOperator.id}, role=$selectedRole',
            name: 'UserSetResetPasswordScreen');
      });
    } else {
      developer.log(
          'No operator data loaded for operatorId: ${widget.operatorId}',
          name: 'UserSetResetPasswordScreen');
    }
  }

  Future<void> _handleResetPassword() async {
    final strings = S.of(context);
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);

    developer.log(
        'Attempting to reset password for operatorId: ${widget.operatorId}',
        name: 'UserSetResetPasswordScreen');

// Clear previous errors
    userViewModel.clearErrors();

// Validate inputs
    final validationErrors = userViewModel.validateResetPassword(
      password: _newPasswordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    if (validationErrors.isNotEmpty) {
      validationErrors
          .forEach((key, value) => userViewModel.setError(key, value));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children:
                  validationErrors.values.map((e) => Text('• $e')).toList(),
            ),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);
    try {
      final success = await userViewModel.resetPassword(
        widget.operatorId,
        _newPasswordController.text,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings.successPasswordReset),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      } else {
        String errorMessage = strings.errorPasswordResetFailed;
        final error = userViewModel.getError('generic');
        if (error != null) {
          errorMessage =
              error.isNotEmpty ? error : strings.errorPasswordResetFailed;
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 6),
            ),
          );
        }
      }
    } on NoInternetException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings.errorNoInternet),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 6),
          ),
        );
      }
      developer.log('No internet connection: $e',
          name: 'UserSetResetPasswordScreen', error: e);
    } on RequestTimeoutException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings.errorRequestTimeout),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 6),
          ),
        );
      }
      developer.log('Request timed out: $e',
          name: 'UserSetResetPasswordScreen', error: e);
    } on HttpException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.serverMessage ?? strings.errorPasswordResetFailed),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 6),
          ),
        );
      }
      developer.log('HTTP error: $e',
          name: 'UserSetResetPasswordScreen', error: e);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${strings.errorPasswordResetFailed}: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 6),
          ),
        );
      }
      developer.log('Unexpected error: $e',
          name: 'UserSetResetPasswordScreen', error: e);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<String> getAvailableRoles() {
    final roles = roleHierarchy[currentUserRole] ?? [];
    final uniqueRoles = roles.toSet().toList();
    developer.log('Available roles: $uniqueRoles',
        name: 'UserSetResetPasswordScreen');
    return uniqueRoles;
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final userViewModel = Provider.of<UserViewModel>(context);

    return Scaffold(
      appBar: CustomAppBar.appBarWithNavigation(
        screenTitle: strings.titleSetResetPassword,
        onPressed: () => Navigator.pop(context),
        darkBackground: Theme.of(context).brightness == Brightness.dark,
        context: context,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  CustomFormFields.normalSizedTextFormField(
                    context: context,
                    label: strings.labelUsername,
                    controller: _nameController,
                    keyboardType: TextInputType.text,
                    isPassword: false,
                    enabled: false,
                  ),
                  const SizedBox(height: 16),
                  CustomFormFields.normalSizedTextFormField(
                    context: context,
                    label: strings.labelUserId,
                    controller: _idController,
                    keyboardType: TextInputType.text,
                    isPassword: false,
                    enabled: false,
                  ),
                  const SizedBox(height: 16),
                  CustomFormFields.normalSizedTextFormField(
                    context: context,
                    label: strings.labelEmail,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    isPassword: false,
                    enabled: false,
                  ),
                  const SizedBox(height: 16),
                  CustomFormFields.normalSizedTextFormField(
                    context: context,
                    label: strings.labelMobileNumber,
                    controller: _mobileNumberController,
                    keyboardType: TextInputType.phone,
                    isPassword: false,
                    enabled: false,
                  ),
                  const SizedBox(height: 16),
                  CustomDropDown.normalDropDown(
                    context: context,
                    label: strings.labelRole,
                    value: selectedRole,
                    items: getAvailableRoles(),
                    onChanged: null,
                    enabled: false,
                    errorText: null,
                  ),
                  const SizedBox(height: 16),
                  CustomFormFields.normalSizedTextFormField(
                    context: context,
                    label: strings.labelNewPassword,
                    controller: _newPasswordController,
                    keyboardType: TextInputType.visiblePassword,
                    isPassword: true,
                    enabled: true,
                    errorText: userViewModel.getError('password'),
                  ),
                  const SizedBox(height: 16),
                  CustomFormFields.normalSizedTextFormField(
                    context: context,
                    label: strings.labelConfirmPassword,
                    controller: _confirmPasswordController,
                    keyboardType: TextInputType.visiblePassword,
                    isPassword: true,
                    enabled: true,
                    errorText: userViewModel.getError('confirmPassword'),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CustomButtons.secondaryButton(
                          text: strings.buttonCancel,
                          onPressed: () => Navigator.pop(context),
                          height: 50,
                          width: AppConfig.deviceWidth * 0.4,
                          context: context,
                        ),
                        CustomButtons.primaryButton(
                          text: strings.buttonConfirm,
                          onPressed:
                              _isLoading ? () {} : () => _handleResetPassword(),
                          height: 50,
                          width: AppConfig.deviceWidth * 0.4,
                          context: context,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    _emailController.dispose();
    _mobileNumberController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
