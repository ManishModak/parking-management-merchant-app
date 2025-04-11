import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/config/app_theme.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:merchant_app/utils/components/button.dart';
import 'package:merchant_app/utils/components/dropdown.dart';
import 'package:merchant_app/utils/components/form_field.dart';
import 'package:provider/provider.dart';
import '../../generated/l10n.dart';
import '../../services/storage/secure_storage_service.dart';
import '../../viewmodels/user_viewmodel.dart';

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

  final Map<String, List<String>> roleHierarchy = {
    'System Admin': ['System Admin', 'Plaza Owner', 'IT Operator'],
    'Plaza Owner': [
      'Plaza Admin',
      'Centralized Controller',
      'Plaza Operator',
      'Cashier',
      'Backend Monitoring Operator',
      'Supervisor'
    ],
    'Plaza Admin': ['Plaza Owner', 'Plaza Operator']
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _fetchUserData();
      await _loadOperatorData();
    });
  }

  Future<void> _fetchUserData() async {
    try {
      final userViewModel = Provider.of<UserViewModel>(context, listen: false);
      final userId = await SecureStorageService().getUserId();
      await userViewModel.fetchUser(userId: userId!, isCurrentAppUser: true);

      if (mounted) {
        setState(() {
          currentUserRole = userViewModel.currentUser?.role;
        });
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }
  }

  Future<void> _loadOperatorData() async {
    final strings = S.of(context);
    try {
      final operatorViewModel = Provider.of<UserViewModel>(context, listen: false);
      await operatorViewModel.fetchUser(userId: widget.operatorId, isCurrentAppUser: false);
      if (mounted) {
        await _loadUser();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${strings.errorLoadOperatorData}: $e', style: TextStyle(color: context.textPrimaryColor)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleResetPassword() async {
    final strings = S.of(context);
    final operatorVM = Provider.of<UserViewModel>(context, listen: false);

    final validationErrors = operatorVM.validateResetPassword(
      newPassword: _newPasswordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    if (validationErrors.isNotEmpty) {
      validationErrors.forEach((key, value) => operatorVM.setError(key, value));
      return;
    }

    try {
      final success = await operatorVM.resetPassword(
        widget.operatorId,
        _newPasswordController.text,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(strings.successPasswordReset,
                  style: TextStyle(color: context.textPrimaryColor)),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(strings.errorPasswordResetFailed,
                  style: TextStyle(color: context.textPrimaryColor)),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${strings.errorGeneric}: ${e.toString()}',
                style: TextStyle(color: context.textPrimaryColor)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  List<String> getAvailableRoles() {
    final roles = roleHierarchy[currentUserRole] ?? [];
    final uniqueRoles = roles.toSet().toList(); // Remove duplicates
    developer.log('Unique available roles: $uniqueRoles', name: 'UserSetResetPasswordScreen');

    // Ensure selectedRole is valid; if not, set it to null or a default value
    if (selectedRole != null && !uniqueRoles.contains(selectedRole)) {
      developer.log('Selected role $selectedRole not in available roles, resetting to null', name: 'UserSetResetPasswordScreen');
      selectedRole = null; // Or set to a default role if appropriate
    }

    return uniqueRoles;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileNumberController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _idController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final operatorViewModel = Provider.of<UserViewModel>(context, listen: false);
    final currentOperator = operatorViewModel.currentOperator;

    if (currentOperator != null && mounted) {
      setState(() {
        _nameController.text = currentOperator.name;
        _emailController.text = currentOperator.email;
        _idController.text = currentOperator.id;
        _mobileNumberController.text = currentOperator.mobileNumber;
        selectedRole = currentOperator.role;
        final availableRoles = getAvailableRoles();
        if (!availableRoles.contains(selectedRole)) {
          developer.log('Role $selectedRole not in $availableRoles, setting to null', name: 'UserSetResetPasswordScreen');
          selectedRole = null; // Reset if invalid
        }
        developer.log('Loaded operator role: $selectedRole', name: 'UserSetResetPasswordScreen');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final operatorVM = Provider.of<UserViewModel>(context);

    // Log available roles and selected role before rendering the dropdown
    final availableRoles = getAvailableRoles();
    developer.log('Available roles: $availableRoles',
        name: 'UserSetResetPasswordScreen');
    developer.log('Selected role: $selectedRole',
        name: 'UserSetResetPasswordScreen');

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar.appBarWithNavigation(
        screenTitle: strings.titleSetResetPassword,
        onPressed: () => Navigator.pop(context),
        darkBackground: Theme.of(context).brightness == Brightness.dark,
        context: context,
      ),
      body: operatorVM.isLoading
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
                    label: strings.labelRole,
                    value: selectedRole,
                    enabled: false,
                    items: availableRoles,
                    onChanged: null,
                    context: context,
                  ),
                  const SizedBox(height: 16),
                  CustomFormFields.normalSizedTextFormField(
                    context: context,
                    label: strings.labelNewPassword,
                    controller: _newPasswordController,
                    keyboardType: TextInputType.visiblePassword,
                    isPassword: true,
                    enabled: true,
                    errorText: operatorVM.getError('newPassword'),
                  ),
                  const SizedBox(height: 16),
                  CustomFormFields.normalSizedTextFormField(
                    context: context,
                    label: strings.labelConfirmPassword,
                    controller: _confirmPasswordController,
                    keyboardType: TextInputType.visiblePassword,
                    isPassword: true,
                    enabled: true,
                    errorText: operatorVM.getError('confirmPassword'),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: operatorVM.isLoading
          ? null
          : Container(
              padding: const EdgeInsets.all(16.0),
              color: Theme.of(context).scaffoldBackgroundColor,
              child: CustomButtons.primaryButton(
                height: 50,
                text: strings.buttonConfirm,
                onPressed: operatorVM.isLoading ? null : _handleResetPassword,
                isEnabled: !operatorVM.isLoading,
                context: context,
              ),
            ),
    );
  }
}
