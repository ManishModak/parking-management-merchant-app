import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/config/app_theme.dart';
import 'package:merchant_app/services/storage/secure_storage_service.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:merchant_app/utils/components/button.dart';
import 'package:merchant_app/utils/components/dropdown.dart';
import 'package:merchant_app/utils/components/form_field.dart';
import 'package:merchant_app/viewmodels/user_viewmodel.dart';
import 'package:merchant_app/views/user/set_reset_password.dart';
import 'package:merchant_app/utils/screens/otp_verification.dart';
import 'package:provider/provider.dart';
import '../../config/app_config.dart';
import '../../generated/l10n.dart';
import '../../utils/exceptions.dart';

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
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();

  bool _isEditMode = false;
  String? selectedRole;
  String? entityId;
  String? selectedPlaza;
  String? currentUserRole;
  String? currentUserId;
  bool isMobileVerified = false;
  String? _originalMobileNumber;
  List<String> _plazas = [];
  String? _userSubEntity;

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
      await _loadCurrentUserInfo();
      await _loadOperatorData();
    });
  }

  Future<void> _loadCurrentUserInfo() async {
    final strings = S.of(context);
    try {
      final storage = SecureStorageService();
      final userData = await storage.getUserData();
      if (userData != null && mounted) {
        setState(() {
          currentUserRole = userData['role'];
          currentUserId = userData['id']?.toString();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${strings.errorLoadCurrentUserInfo}: $e', style: TextStyle(color: context.textPrimaryColor)),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _fetchPlazas(String id) async {
    final strings = S.of(context);
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);

    setState(() {
      _plazas = [];
    });

    try {
      await userViewModel.fetchUserPlazas(id);
      setState(() {
        _plazas = userViewModel.userPlazas.map((plaza) => plaza.plazaName).toList();
        if (_userSubEntity != null && _plazas.contains(_userSubEntity)) {
          selectedPlaza = _userSubEntity;
        } else if (_plazas.length == 1) {
          selectedPlaza = _plazas.first;
        } else {
          selectedPlaza = null;
        }
      });
    } catch (e) {
      String errorMessage = strings.errorLoadPlazas;
      final error = userViewModel.error;
      if (error != null) {
        if (error is HttpException) {
          errorMessage = error.message;
          if (error.statusCode == 404) {
            errorMessage = strings.errorNoPlazasFound;
          } else if (error.statusCode == 502) {
            errorMessage = strings.errorServiceUnavailableMessage;
          }
        } else if (error is PlazaException) {
          errorMessage = error.message;
        } else if (error is ServiceException) {
          errorMessage = error.message;
        } else {
          errorMessage = error.toString();
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage, style: TextStyle(color: context.textPrimaryColor)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _loadOperatorData() async {
    final strings = S.of(context);
    try {
      final userViewModel = context.read<UserViewModel>();
      await userViewModel.fetchUser(
        userId: widget.operatorId,
        isCurrentAppUser: false,
      );
      await _loadUser();
      final currentOperator = userViewModel.currentOperator;
      if (currentOperator?.entityId != null && mounted) {
        await _fetchPlazas(currentOperator!.entityId!);
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

  List<String> getAvailableRoles() => roleHierarchy[currentUserRole] ?? [];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileNumberController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _userIdController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final userViewModel = context.read<UserViewModel>();
    final currentOperator = userViewModel.currentOperator;

    if (currentOperator != null && mounted) {
      setState(() {
        _nameController.text = currentOperator.name;
        _userIdController.text = currentOperator.id;
        _emailController.text = currentOperator.email;
        _mobileNumberController.text = currentOperator.mobileNumber;
        _addressController.text = currentOperator.address ?? '';
        _cityController.text = currentOperator.city ?? '';
        _stateController.text = currentOperator.state ?? '';
        selectedRole = currentOperator.role;
        entityId = currentOperator.entityId;
        _originalMobileNumber = currentOperator.mobileNumber;
        _userSubEntity = (currentOperator.subEntity.isNotEmpty) ? currentOperator.subEntity.first : null;
      });
    }
  }

  Future<void> verifyMobileNumber() async {
    final strings = S.of(context);
    final operatorVM = Provider.of<UserViewModel>(context, listen: false);
    final mobile = _mobileNumberController.text;

    final mobileError = operatorVM.validateMobile(mobile, isMobileVerified, _originalMobileNumber);
    if (mobileError != null) {
      operatorVM.setError('mobile', mobileError);
      return;
    }

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => OtpVerificationScreen(
          mobileNumber: mobile,
        ),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      setState(() => isMobileVerified = true);
      operatorVM.clearError('mobile');
    } else {
      setState(() {
        _mobileNumberController.text = _originalMobileNumber ?? '';
        isMobileVerified = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.errorMobileVerificationFailed, style: TextStyle(color: context.textPrimaryColor)),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _confirmUpdate() async {
    final strings = S.of(context);
    final operatorVM = context.read<UserViewModel>();

    final validationErrors = operatorVM.validateUpdate(
      username: _nameController.text,
      email: _emailController.text,
      mobile: _mobileNumberController.text,
      address: _addressController.text,
      city: _cityController.text,
      state: _stateController.text,
      role: selectedRole,
      subEntity: selectedPlaza,
      isMobileVerified: isMobileVerified || _mobileNumberController.text == _originalMobileNumber,
      originalMobile: _originalMobileNumber,
    );

    if (validationErrors.isNotEmpty) {
      validationErrors.forEach((key, value) => operatorVM.setError(key, value));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: validationErrors.values
                .map((e) => Text('• $e', style: Theme.of(context).textTheme.bodyMedium))
                .toList(),
          ),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 5),
        ),
      );
      return;
    }

    if (_mobileNumberController.text != _originalMobileNumber && !isMobileVerified) {
      await verifyMobileNumber();
      if (!isMobileVerified) return;
    }

    final success = await operatorVM.updateUser(
      username: _nameController.text,
      email: _emailController.text,
      mobileNumber: _mobileNumberController.text,
      address: _addressController.text,
      city: _cityController.text,
      state: _stateController.text,
      role: selectedRole,
      subEntity: selectedPlaza,
      isCurrentAppUser: false,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.successProfileUpdate, style: TextStyle(color: context.textPrimaryColor)),
          backgroundColor: AppColors.success,
        ),
      );
      setState(() {
        _isEditMode = false;
        _originalMobileNumber = _mobileNumberController.text;
        isMobileVerified = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.errorUpdateFailed, style: TextStyle(color: context.textPrimaryColor)),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Widget _buildMobileNumberField(S strings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomFormFields.normalSizedTextFormField(
          context: context,
          label: strings.labelMobileNumber,
          controller: _mobileNumberController,
          keyboardType: TextInputType.phone,
          isPassword: false,
          enabled: _isEditMode,
          errorText: Provider.of<UserViewModel>(context).getError('mobile'),
          onChanged: (value) {
            if (value != _originalMobileNumber) {
              setState(() {
                isMobileVerified = false;
                Provider.of<UserViewModel>(context, listen: false).clearError('mobile');
              });
            }
          },
        ),
        if (_isEditMode && _mobileNumberController.text != _originalMobileNumber && !isMobileVerified)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              strings.warningMobileVerificationRequired,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    String? error,
  }) {
    return CustomDropDown.normalDropDown(
      label: label,
      value: value,
      items: items,
      onChanged: onChanged,
      enabled: _isEditMode,
      errorText: error,
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);

    return Scaffold(
      appBar: CustomAppBar.appBarWithNavigation(
        screenTitle: strings.titleUserInfo,
        onPressed: () => Navigator.pop(context),
        darkBackground: Theme.of(context).brightness == Brightness.dark,
        context: context,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Consumer<UserViewModel>(
        builder: (context, operatorVM, _) {
          if (operatorVM.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
              ),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 8),
                CustomFormFields.normalSizedTextFormField(
                  context: context,
                  label: strings.labelFullName,
                  controller: _nameController,
                  keyboardType: TextInputType.text,
                  isPassword: false,
                  enabled: _isEditMode,
                  errorText: operatorVM.getError('username'),
                ),
                const SizedBox(height: 16),
                CustomFormFields.normalSizedTextFormField(
                  context: context,
                  label: strings.labelUserId,
                  controller: _userIdController,
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
                  enabled: _isEditMode,
                  errorText: operatorVM.getError('email'),
                ),
                const SizedBox(height: 16),
                _buildMobileNumberField(strings),
                const SizedBox(height: 16),
                _buildDropdown(
                  label: strings.labelAssignRole,
                  value: selectedRole,
                  items: getAvailableRoles(),
                  onChanged: (value) => setState(() => selectedRole = value),
                  error: operatorVM.getError('role'),
                ),
                const SizedBox(height: 16),
                _buildDropdown(
                  label: strings.labelSubEntity,
                  value: selectedPlaza,
                  items: _plazas,
                  onChanged: (value) => setState(() => selectedPlaza = value),
                  error: operatorVM.getError('subEntity'),
                ),
                const SizedBox(height: 16),
                CustomFormFields.normalSizedTextFormField(
                  context: context,
                  label: strings.labelAddress,
                  controller: _addressController,
                  keyboardType: TextInputType.streetAddress,
                  isPassword: false,
                  enabled: _isEditMode,
                  errorText: operatorVM.getError('address'),
                ),
                const SizedBox(height: 16),
                CustomFormFields.normalSizedTextFormField(
                  context: context,
                  label: strings.labelCity,
                  controller: _cityController,
                  keyboardType: TextInputType.text,
                  isPassword: false,
                  enabled: _isEditMode,
                  errorText: operatorVM.getError('city'),
                ),
                const SizedBox(height: 16),
                CustomFormFields.normalSizedTextFormField(
                  context: context,
                  label: strings.labelState,
                  controller: _stateController,
                  keyboardType: TextInputType.text,
                  isPassword: false,
                  enabled: _isEditMode,
                  errorText: operatorVM.getError('state'),
                ),
                const SizedBox(height: 16),
                _buildActionButtons(strings),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButtons(S strings) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _isEditMode
            ? [
          CustomButtons.secondaryButton(
            text: strings.buttonCancel,
            onPressed: () => setState(() {
              _isEditMode = false;
              _loadUser();
            }),
            height: 50,
            width: AppConfig.deviceWidth * 0.4,
            context: context,
          ),
          CustomButtons.primaryButton(
            text: strings.buttonSave,
            onPressed: _confirmUpdate,
            height: 50,
            width: AppConfig.deviceWidth * 0.4,
            context: context,
          ),
        ]
            : [
          CustomButtons.secondaryButton(
            text: strings.buttonSetResetPassword,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserSetResetPasswordScreen(
                  operatorId: widget.operatorId,
                ),
              ),
            ),
            height: 50,
            width: AppConfig.deviceWidth * 0.4,
            context: context,
          ),
          CustomButtons.primaryButton(
            text: strings.buttonEdit,
            onPressed: () => setState(() => _isEditMode = true),
            height: 50,
            width: AppConfig.deviceWidth * 0.4,
            context: context,
          ),
        ],
      ),
    );
  }
}