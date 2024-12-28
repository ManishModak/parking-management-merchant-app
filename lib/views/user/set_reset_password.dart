import 'package:flutter/material.dart';
import 'package:merchant_app/utils/components/card.dart';
import 'package:merchant_app/utils/components/form_field.dart';
import 'package:provider/provider.dart';

import '../../config/app_strings.dart';
import '../../services/secure_storage_service.dart';
import '../../utils/components/appbar.dart';
import '../../utils/components/button.dart';
import '../../utils/components/dropdown.dart';
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
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? selectedRole;
  String? currentUserRole;

  final Map<String, List<String>> roleHierarchy = {
    'System Admin': [
      'System Admin',
      'Plaza Owner',
      'Plaza Admin',
      'Centralized Controller',
      'Plaza Operator',
      'Backend Monitoring Operator',
      'Cashier',
      'Supervisor',
      'IT Operator'
    ],
    'Plaza Owner': ['Plaza Admin', 'Plaza Owner', 'Cashier', 'Supervisor'],
  };

  List<String> getAvailableRoles() {
    if (currentUserRole == null) return [];
    return roleHierarchy[currentUserRole] ?? [];
  }

  bool _validatePasswords() {
    if (_newPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all password fields')),
      );
      return false;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return false;
    }

    // Add any additional password validation rules here
    if (_newPasswordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return false;
    }

    return true;
  }

  Future<void> _handleResetPassword() async {
    if (!_validatePasswords()) return;

    final operatorVM = Provider.of<UserViewModel>(context, listen: false);

    try {
      final success = await operatorVM.resetPassword(
        widget.operatorId,
        _newPasswordController.text,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password reset successful')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(operatorVM.error ?? 'Failed to reset password')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

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
    try {
      final operatorViewModel =
          Provider.of<UserViewModel>(context, listen: false);
      await operatorViewModel.fetchUser(
          userId: widget.operatorId, isCurrentAppUser: false);
      if (mounted) {
        await _loadUser();
      }
    } catch (e) {
      print('Error in _loadOperatorData: $e');
    }
  }

  Future<void> _loadUser() async {
    final operatorViewModel =
        Provider.of<UserViewModel>(context, listen: false);
    final currentOperator = operatorViewModel.currentOperator;

    if (currentOperator != null && mounted) {
      setState(() {
        _nameController.text = currentOperator.name;
        _emailController.text = currentOperator.email;
        _mobileNumberController.text = currentOperator.mobileNumber;
         selectedRole = currentOperator.role;
      });

      print(selectedRole);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileNumberController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.appBarWithNavigation(
        screenTitle: AppStrings.titleSetResetPassword,
        onPressed: () => Navigator.pop(context),
        darkBackground: false,
      ),
      body: Consumer<UserViewModel>(
        builder: (context, operatorVM, _) {
          if (operatorVM.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (operatorVM.currentOperator == null) {
            return const Center(child: Text('Failed to load Operator data'));
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          CustomCards.userProfileCard(
                              name: operatorVM.currentOperator!.name,
                              userId: operatorVM.currentOperator!.id),
                          const SizedBox(height: 20),
                          CustomFormFields.primaryFormField(
                            label: 'Username',
                            controller: _nameController,
                            keyboardType: TextInputType.text,
                            isPassword: false,
                            enabled: false,
                          ),
                          const SizedBox(height: 16),
                          CustomFormFields.primaryFormField(
                            label: 'Email',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            isPassword: false,
                            enabled: false,
                          ),
                          const SizedBox(height: 16),
                          CustomFormFields.primaryFormField(
                            label: 'Mobile Number',
                            controller: _mobileNumberController,
                            keyboardType: TextInputType.phone,
                            isPassword: false,
                            enabled: false,
                          ),
                          const SizedBox(height: 16),
                          CustomDropDown.normalDropDown(
                            label: AppStrings.labelRole,
                            value: selectedRole,
                            enabled: false,
                            items: getAvailableRoles(),
                            onChanged: (value) async {
                              setState(() {
                                selectedRole = value;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomFormFields.primaryFormField(
                            label: 'New Password',
                            controller: _newPasswordController,
                            keyboardType: TextInputType.visiblePassword,
                            isPassword: true,
                            enabled: true,
                          ),
                          const SizedBox(height: 16),
                          CustomFormFields.primaryFormField(
                            label: 'Confirm Password',
                            controller: _confirmPasswordController,
                            keyboardType: TextInputType.visiblePassword,
                            isPassword: true,
                            enabled: true,
                          ),
                          const SizedBox(height: 30),
                          CustomButtons.primaryButton(
                            text: AppStrings.buttonConfirm,
                            onPressed: operatorVM.isLoading ? () {} : _handleResetPassword,
                          ),
                          if (operatorVM.isLoading)
                            const Center(child: CircularProgressIndicator()),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
