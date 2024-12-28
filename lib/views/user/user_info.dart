import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_strings.dart';
import 'package:merchant_app/services/secure_storage_service.dart';
import 'package:merchant_app/utils/components/button.dart';
import 'package:merchant_app/utils/components/card.dart';
import 'package:merchant_app/viewmodels/user_viewmodel.dart';
import 'package:merchant_app/views/user/set_reset_password.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../utils/components/appbar.dart';
import '../../utils/components/dropdown.dart';
import '../../utils/components/form_field.dart';
import '../onboarding/otp_verification.dart';

class UserInfoScreen extends StatefulWidget {
  final String operatorId;

  const UserInfoScreen({
    super.key,
    required this.operatorId,
  });

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();

  bool _isEditMode = false;
  String? selectedRole;
  String? currentUserRole;
  bool isMobileVerified = false;
  String? _originalMobileNumber;

  final Map<String, List<String>> roleHierarchy = {
    'System Admin': [
      'System Admin',
      'Plaza Owner',
      'IT Operator'
    ],
    'Plaza Owner': [
      'Plaza Admin',
      'Plaza Owner',
    ],
    'Plaza Admin': [
      'Plaza Operator'
    ]
  };

  List<String> getAvailableRoles() {
    if (currentUserRole == null) return [];
    return roleHierarchy[currentUserRole] ?? [];
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

  Map<String, String> _originalValues = {};

  void _storeOriginalValues() {
    _originalValues = {
      'username': _nameController.text,
      'email': _emailController.text,
      'mobileNumber': _mobileNumberController.text,
      'address': _addressController.text,
      'city': _cityController.text,
      'state': _stateController.text,
      'role': selectedRole!,
    };
    _originalMobileNumber = _mobileNumberController.text;
  }

  void _restoreOriginalValues() {
    setState(() {
      _nameController.text = _originalValues['username'] ?? '';
      _emailController.text = _originalValues['email'] ?? '';
      _mobileNumberController.text = _originalValues['mobileNumber'] ?? '';
      _addressController.text = _originalValues['address'] ?? '';
      _cityController.text = _originalValues['city'] ?? '';
      _stateController.text = _originalValues['state'] ?? '';
      selectedRole = _originalValues['role'] ?? '';
    });
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
      if (!_isEditMode) {
        _restoreOriginalValues();
      }
    });
  }

  Future<void> _loadOperatorData() async {
    try {
      final operatorViewModel = Provider.of<UserViewModel>(context, listen: false);
      await operatorViewModel.fetchUser(userId: widget.operatorId, isCurrentAppUser: false);
      if (mounted) {
        await _loadUser();
      }
    } catch (e) {
      print('Error in _loadOperatorData: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileNumberController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final operatorViewModel = Provider.of<UserViewModel>(context, listen: false);
    final currentOperator = operatorViewModel.currentOperator;

    if (currentOperator != null && mounted) {
      setState(() {
        _nameController.text = currentOperator.name;
        _emailController.text = currentOperator.email;
        _mobileNumberController.text = currentOperator.mobileNumber;
        _addressController.text = currentOperator.address ?? '';
        _cityController.text = currentOperator.city ?? '';
        _stateController.text = currentOperator.state ?? '';
        selectedRole = currentOperator.role;

        // Store original values
        _storeOriginalValues();
      });
    }
  }


  Future<void> verifyMobileNumber() async {
    if (_mobileNumberController.text.length != 10 ||
        !RegExp(r'^\d{10}$').hasMatch(_mobileNumberController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.errorMobileNumberInvalid),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => OtpVerificationScreen(
          mobileNumber: _mobileNumberController.text,
        ),
      ),
    );

    if (result == true) {
      setState(() {
        isMobileVerified = true;
      });
    } else {
      setState(() {
        _mobileNumberController.text = _originalMobileNumber ?? '';
        isMobileVerified = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.errorMobileVerificationFailed),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _confirmUpdate() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.errorUsernameEmpty)),
      );
      return;
    }

    if (_mobileNumberController.text != _originalMobileNumber && !isMobileVerified) {
      await verifyMobileNumber();
      if (!isMobileVerified) {
        return;
      }
    }

    final operatorViewModel = Provider.of<UserViewModel>(context, listen: false);
    final success = await operatorViewModel.updateUser(
        username: _nameController.text,
        email: _emailController.text,
        mobileNumber: _mobileNumberController.text,
        address: _addressController.text,
        city: _cityController.text,
        state: _stateController.text,
        role: selectedRole,
        isCurrentAppUser: false
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.successProfileUpdate)),
      );
      setState(() {
        _isEditMode = false;
        _storeOriginalValues();
        isMobileVerified = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.errorUpdateFailed)),
      );
    }
  }

  Widget _buildMobileNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomFormFields.primaryFormField(
          label: AppStrings.labelMobileNumber,
          controller: _mobileNumberController,
          keyboardType: TextInputType.phone,
          isPassword: false,
          enabled: _isEditMode,
          onChanged: (value) {
            if (value != _originalMobileNumber) {
              setState(() {
                isMobileVerified = false;
              });
            }
          },
        ),
        if (_isEditMode && _mobileNumberController.text != _originalMobileNumber && !isMobileVerified)
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text(
              AppStrings.warningMobileVerificationRequired,
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.appBarWithNavigation(
        screenTitle: AppStrings.titleUserInfo,
        onPressed: () => Navigator.pop(context),
        darkBackground: false,
      ),
      backgroundColor: AppColors.lightThemeBackground,
      floatingActionButton: _buildFloatingActionButtons(),
      body: Consumer<UserViewModel>(
        builder: (context, operatorVM, _) {
          if (operatorVM.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (operatorVM.currentOperator == null) {
            return const Center(child: Text(AppStrings.errorLoadOperator));
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
                              userId: operatorVM.currentOperator!.id
                          ),
                          const SizedBox(height: 20),
                          CustomFormFields.primaryFormField(
                            label: AppStrings.labelFullName,
                            controller: _nameController,
                            keyboardType: TextInputType.text,
                            isPassword: false,
                            enabled: _isEditMode,
                          ),
                          const SizedBox(height: 16),
                          CustomFormFields.primaryFormField(
                            label: AppStrings.labelEmail,
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            isPassword: false,
                            enabled: _isEditMode,
                          ),
                          const SizedBox(height: 16),
                          _buildMobileNumberField(),
                          const SizedBox(height: 16),
                          CustomDropDown.normalDropDown(
                            label: AppStrings.labelRole,
                            value: selectedRole,
                            enabled: _isEditMode,
                            items: getAvailableRoles(),
                            onChanged: (value) async {
                              setState(() {
                                selectedRole = value;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomFormFields.primaryFormField(
                            label: AppStrings.labelAddress,
                            controller: _addressController,
                            keyboardType: TextInputType.streetAddress,
                            isPassword: false,
                            enabled: _isEditMode,
                          ),
                          const SizedBox(height: 16),
                          CustomFormFields.primaryFormField(
                            label: AppStrings.labelCity,
                            controller: _cityController,
                            keyboardType: TextInputType.text,
                            isPassword: false,
                            enabled: _isEditMode,
                          ),
                          const SizedBox(height: 16),
                          CustomFormFields.primaryFormField(
                            label: AppStrings.labelState,
                            controller: _stateController,
                            keyboardType: TextInputType.text,
                            isPassword: false,
                            enabled: _isEditMode,
                          ),
                          const SizedBox(height: 30),
                          CustomButtons.primaryButton(
                              text: AppStrings.buttonSetResetPassword,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UserSetResetPasswordScreen(
                                        operatorId: widget.operatorId
                                    ),
                                  ),
                                );
                              }
                          )
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

  Widget _buildFloatingActionButtons() {
    if (!_isEditMode) {
      return FloatingActionButton(
        heroTag: 'editButton',  // Unique hero tag
        onPressed: _toggleEditMode,
        child: const Icon(Icons.edit),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'cancelButton',  // Unique hero tag
            onPressed: _toggleEditMode,
            backgroundColor: Colors.red,
            child: const Icon(Icons.close),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            heroTag: 'saveButton',  // Unique hero tag
            onPressed: _confirmUpdate,
            backgroundColor: Colors.green,
            child: const Icon(Icons.check),
          ),
        ],
      ),
    );
  }
}

