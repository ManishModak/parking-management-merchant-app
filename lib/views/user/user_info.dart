import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/config/app_strings.dart';
import 'package:merchant_app/services/secure_storage_service.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:merchant_app/utils/components/button.dart';
import 'package:merchant_app/utils/components/card.dart';
import 'package:merchant_app/utils/components/dropdown.dart';
import 'package:merchant_app/utils/components/form_field.dart';
import 'package:merchant_app/viewmodels/plaza_viewmodel/plaza_viewmodel.dart';
import 'package:merchant_app/viewmodels/user_viewmodel.dart';
import 'package:merchant_app/views/user/set_reset_password.dart';
import 'package:merchant_app/views/onboarding/otp_verification.dart';
import 'package:provider/provider.dart';

class UserInfoScreen extends StatefulWidget {
  final String operatorId;

  const UserInfoScreen({
    Key? key,
    required this.operatorId,
  }) : super(key: key);

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  // Controllers for text fields.
  final TextEditingController _nameController = TextEditingController();
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

  // This variable holds the operator’s subEntity value from user data.
  String? _userSubEntity;

  // Error states.
  String? _nameError;
  String? _emailError;
  String? _mobileError;
  String? _roleError;
  String? _plazaError;
  String? _addressError;
  String? _cityError;
  String? _stateError;

  // Role hierarchy for available roles.
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
    // First load current user info then operator data.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadCurrentUserInfo();
      await _loadOperatorData();
    });
  }

  Future<void> _loadCurrentUserInfo() async {
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
      // Show error if needed.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading current user info: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Fetches plazas from the API and then, if possible,
  /// assigns the operator’s subEntity value to the dropdown.
  Future<void> _fetchPlazas(String id) async {
    final plazaViewModel = Provider.of<PlazaViewModel>(context, listen: false);

    setState(() {
      _plazas = [];
    });

    try {
      await plazaViewModel.fetchUserPlazas(id);
      setState(() {
        _plazas = plazaViewModel.userPlazas
            .map((plaza) => plaza.plazaName)
            .toList();

        // If the user’s subEntity exists in the fetched plazas, select it.
        if (_userSubEntity != null && _plazas.contains(_userSubEntity)) {
          selectedPlaza = _userSubEntity;
        } else if (_plazas.length == 1) {
          // Otherwise, if there's only one plaza, select that.
          selectedPlaza = _plazas.first;
        } else {
          // If multiple plazas and no match, keep it null.
          selectedPlaza = null;
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(plazaViewModel.error ?? 'Failed to fetch plazas: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadOperatorData() async {
    try {
      final operatorViewModel = context.read<UserViewModel>();
      await operatorViewModel.fetchUser(
        userId: widget.operatorId,
        isCurrentAppUser: false,
      );
      await _loadUser();

      final currentOperator = operatorViewModel.currentOperator;
      if (currentOperator?.entityId != null && mounted) {
        await _fetchPlazas(currentOperator!.entityId!);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load operator data: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
    super.dispose();
  }

  /// Loads the operator data into the form fields.
  /// Also stores the operator’s subEntity value.
  Future<void> _loadUser() async {
    final operatorViewModel = context.read<UserViewModel>();
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
        entityId = currentOperator.entityId;
        _originalMobileNumber = currentOperator.mobileNumber;
        // If the subEntity is a list, pick the first element if available.
        _userSubEntity = (currentOperator.subEntity.isNotEmpty)
            ? currentOperator.subEntity.first
            : null;
      });
    }
  }


  Future<void> verifyMobileNumber() async {
    if (!RegExp(r'^\d{10}$').hasMatch(_mobileNumberController.text)) {
      setState(() => _mobileError = AppStrings.errorMobileInvalidFormat);
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

    if (!mounted) return;

    if (result == true) {
      setState(() => isMobileVerified = true);
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
    final validationErrors = <String, String>{};

    // Name validation.
    if (_nameController.text.isEmpty) {
      validationErrors['name'] = AppStrings.errorFullNameRequired;
    } else if (_nameController.text.length > 100) {
      validationErrors['name'] = AppStrings.errorFullNameLength;
    }

    // Email validation.
    if (_emailController.text.isEmpty) {
      validationErrors['email'] = AppStrings.errorEmailRequired;
    } else if (!RegExp(r'^[\w.%+-]+@[\w.-]+\.(com|in)$', caseSensitive: false)
        .hasMatch(_emailController.text)) {
      validationErrors['email'] = AppStrings.errorEmailInvalid;
    } else if (_emailController.text.length > 50) {
      validationErrors['email'] = AppStrings.errorEmailLength;
    }

    // Mobile validation.
    if (_mobileNumberController.text.isEmpty) {
      validationErrors['mobile'] = AppStrings.errorMobileRequired;
    } else if (!RegExp(r'^\d{10}$').hasMatch(_mobileNumberController.text)) {
      validationErrors['mobile'] = AppStrings.errorMobileInvalidFormat;
    }

    // Role validation.
    if (selectedRole == null || selectedRole!.isEmpty) {
      validationErrors['role'] = AppStrings.errorRoleRequired;
    }

    // Plaza (SubEntity) validation.
    if (selectedPlaza == null || selectedPlaza!.isEmpty) {
      validationErrors['plaza'] = AppStrings.errorSubEntityRequired;
    }

    // Address validation.
    if (_addressController.text.isEmpty) {
      validationErrors['address'] = AppStrings.errorAddressRequired;
    } else if (_addressController.text.length > 256) {
      validationErrors['address'] = AppStrings.errorAddressLength;
    }

    // City validation.
    if (_cityController.text.isEmpty) {
      validationErrors['city'] = AppStrings.errorCityRequired;
    } else if (_cityController.text.length > 50) {
      validationErrors['city'] = AppStrings.errorCityLength;
    }

    // State validation.
    if (_stateController.text.isEmpty) {
      validationErrors['state'] = AppStrings.errorStateRequired;
    } else if (_stateController.text.length > 50) {
      validationErrors['state'] = AppStrings.errorStateLength;
    }

    setState(() {
      _nameError = validationErrors['name'];
      _emailError = validationErrors['email'];
      _mobileError = validationErrors['mobile'];
      _roleError = validationErrors['role'];
      _plazaError = validationErrors['plaza'];
      _addressError = validationErrors['address'];
      _cityError = validationErrors['city'];
      _stateError = validationErrors['state'];
    });

    if (validationErrors.isNotEmpty) {
      // Show validation error SnackBar.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: validationErrors.values.map((e) => Text('• $e')).toList(),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
      return;
    }

    // If mobile number was changed, verify it.
    if (_mobileNumberController.text != _originalMobileNumber &&
        !isMobileVerified) {
      await verifyMobileNumber();
      if (!isMobileVerified) return;
    }

    final operatorViewModel = context.read<UserViewModel>();
    final success = await operatorViewModel.updateUser(
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
        const SnackBar(content: Text(AppStrings.successProfileUpdate)),
      );
      setState(() {
        _isEditMode = false;
        _originalMobileNumber = _mobileNumberController.text;
        isMobileVerified = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.errorUpdateFailed)),
      );
    }
  }

  /// Builds the mobile number field along with a verification warning.
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
          errorText: _mobileError,
          onChanged: (value) {
            if (value != _originalMobileNumber) {
              setState(() {
                isMobileVerified = false;
                _mobileError = null;
              });
            }
          },
        ),
        if (_isEditMode &&
            _mobileNumberController.text != _originalMobileNumber &&
            !isMobileVerified)
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text(
              AppStrings.warningMobileVerificationRequired,
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  /// Builds a dropdown field using the custom normal dropdown widget.
  /// The dropdown is enabled only in edit mode.
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
    );
  }
  void _clearErrors() {
    setState(() {
      _nameError = null;
      _emailError = null;
      _mobileError = null;
      _roleError = null;
      _plazaError = null;
      _addressError = null;
      _cityError = null;
      _stateError = null;
    });
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
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (operatorVM.currentOperator != null)
                  CustomCards.userProfileCard(
                    name: operatorVM.currentOperator!.name,
                    userId: operatorVM.currentOperator!.id,
                  ),
                const SizedBox(height: 20),
                CustomFormFields.primaryFormField(
                  label: AppStrings.labelFullName,
                  controller: _nameController,
                  keyboardType: TextInputType.text,
                  isPassword: false,
                  enabled: _isEditMode,
                  errorText: _nameError,
                ),
                const SizedBox(height: 16),
                CustomFormFields.primaryFormField(
                  label: AppStrings.labelEmail,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  isPassword: false,
                  enabled: _isEditMode,
                  errorText: _emailError,
                ),
                const SizedBox(height: 16),
                _buildMobileNumberField(),
                const SizedBox(height: 16),
                _buildDropdown(
                  label: AppStrings.labelAssignRole,
                  value: selectedRole,
                  items: getAvailableRoles(),
                  onChanged: (value) => setState(() => selectedRole = value),
                  error: _roleError,
                ),
                const SizedBox(height: 16),
                _buildDropdown(
                  label: AppStrings.labelSubEntity,
                  value: selectedPlaza,
                  items: _plazas,
                  onChanged: (value) => setState(() => selectedPlaza = value),
                  error: _plazaError,
                ),
                const SizedBox(height: 16),
                CustomFormFields.primaryFormField(
                  label: AppStrings.labelAddress,
                  controller: _addressController,
                  keyboardType: TextInputType.streetAddress,
                  isPassword: false,
                  enabled: _isEditMode,
                  errorText: _addressError,
                ),
                const SizedBox(height: 16),
                CustomFormFields.primaryFormField(
                  label: AppStrings.labelCity,
                  controller: _cityController,
                  keyboardType: TextInputType.text,
                  isPassword: false,
                  enabled: _isEditMode,
                  errorText: _cityError,
                ),
                const SizedBox(height: 16),
                CustomFormFields.primaryFormField(
                  label: AppStrings.labelState,
                  controller: _stateController,
                  keyboardType: TextInputType.text,
                  isPassword: false,
                  enabled: _isEditMode,
                  errorText: _stateError,
                ),
                const SizedBox(height: 30),
                CustomButtons.primaryButton(
                  text: AppStrings.buttonSetResetPassword,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserSetResetPasswordScreen(
                        operatorId: widget.operatorId,
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFloatingActionButtons() {
    if (!_isEditMode) {
      return FloatingActionButton(
        heroTag: 'editButton',
        onPressed: () => setState(() {
          _isEditMode = true;
        }),
        child: const Icon(Icons.edit),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'cancelButton',
            onPressed: () => setState(() {
              _isEditMode = false;
              _clearErrors();
              // Reload user data to reset any unsaved changes.
              _loadUser();
            }),
            backgroundColor: Colors.red,
            child: const Icon(Icons.close),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            heroTag: 'saveButton',
            onPressed: _confirmUpdate,
            backgroundColor: Colors.green,
            child: const Icon(Icons.check),
          ),
        ],
      ),
    );
  }
}
