import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/config/app_config.dart';
import 'package:merchant_app/config/app_routes.dart';
import 'package:merchant_app/models/plaza.dart';
import 'package:merchant_app/services/storage/secure_storage_service.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:merchant_app/utils/components/button.dart';
import 'package:merchant_app/utils/components/dropdown.dart';
import 'package:merchant_app/utils/components/form_field.dart';
import 'package:merchant_app/utils/components/searchable_multi_select_dropdown.dart';
import 'package:merchant_app/utils/exceptions.dart';
import 'package:merchant_app/utils/screens/otp_verification.dart';
import 'package:merchant_app/viewmodels/user_viewmodel.dart';
import 'package:provider/provider.dart';
import '../../generated/l10n.dart';

class UserRegistrationScreen extends StatefulWidget {
  const UserRegistrationScreen({super.key});

  @override
  State<UserRegistrationScreen> createState() => _UserRegistrationScreenState();
}

class _UserRegistrationScreenState extends State<UserRegistrationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();

  String? _selectedRole;
  String? _selectedEntity;
  String? _selectedPlazaId;
  List<String> _selectedPlazaIds = [];
  String? _currentUserRole;
  bool _isMobileVerified = false;
  String? _verifiedMobileNumber;
  bool _isSendingOtp = false;
  Timer? _debounce;

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
    developer.log('UserRegistrationScreen initialized',
        name: 'UserRegistrationScreen');
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initializeData();
    });
  }

  Future<void> _initializeData() async {
    final strings = S.of(context);
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    try {
      final storage = SecureStorageService();
      _currentUserRole = await storage.getUserRole();
      _selectedEntity = await storage.getEntityId();
      developer.log(
          'Loaded current user role: $_currentUserRole, entity: $_selectedEntity',
          name: 'UserRegistrationScreen');
      await userViewModel.fetchPlazasForCurrentUser();
      if (_currentUserRole == 'Plaza Admin' &&
          userViewModel.userPlazas.isNotEmpty) {
        setState(() {
          _selectedPlazaId = userViewModel.userPlazas.first.plazaId;
          developer.log(
              'Auto-assigned plaza: $_selectedPlazaId for Plaza Admin',
              name: 'UserRegistrationScreen');
        });
      }
    } catch (e) {
      developer.log('Error initializing data: $e',
          name: 'UserRegistrationScreen', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${strings.errorLoadData}: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _verifyMobileNumber() async {
    final strings = S.of(context);
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    final mobile = _mobileNumberController.text;

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final validationErrors = userViewModel.validateMobile(mobile);
      if (validationErrors.isNotEmpty) {
        validationErrors
            .forEach((key, value) => userViewModel.setError(key, value));
        return;
      }

      setState(() => _isSendingOtp = true);
      try {
        final success = await userViewModel.verifyMobileNumber(
          mobile,
          errorMobileInUse: strings.errorMobileInUse,
        );
        if (success && mounted) {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => OtpVerificationScreen(mobileNumber: mobile),
            ),
          );
          if (result == true && mounted) {
            setState(() {
              _isMobileVerified = true;
              _verifiedMobileNumber = mobile;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(strings.otpVerifiedSuccess),
                backgroundColor: AppColors.success,
              ),
            );
          } else {
            userViewModel.setError('mobile', strings.errorVerificationFailed);
            setState(() {
              _isMobileVerified = false;
              _verifiedMobileNumber = null;
            });
          }
        }
      } catch (e) {
        userViewModel.setError('mobile', strings.errorVerificationFailed);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${strings.errorVerificationFailed}: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        developer.log('Error verifying mobile: $e',
            name: 'UserRegistrationScreen', error: e);
      } finally {
        if (mounted) setState(() => _isSendingOtp = false);
      }
    });
  }

  Future<void> _registerUser() async {
    final strings = S.of(context);
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);

    final List<String> subEntity = _selectedRole == 'Centralized Controller'
        ? _selectedPlazaIds
        : _selectedPlazaId != null
            ? [_selectedPlazaId!]
            : [];

    final validationErrors = userViewModel.validateRegistration(
      username: _nameController.text,
      email: _emailController.text,
      mobile: _mobileNumberController.text,
      city: _cityController.text,
      state: _stateController.text,
      address: _addressController.text,
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
      isMobileVerified: _isMobileVerified,
      role: _selectedRole,
      entity: _selectedEntity,
      subEntity: subEntity.isNotEmpty ? subEntity.join(',') : null,
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

    setState(() => _isSendingOtp = true);
    try {
      final success = await userViewModel.registerUser(
        username: _nameController.text,
        email: _emailController.text,
        mobileNumber: _mobileNumberController.text,
        password: _passwordController.text,
        city: _cityController.text,
        state: _stateController.text,
        address: _addressController.text,
        isAppUserRegister: false,
        role: _selectedRole,
        entity: _selectedEntity,
        subEntity: _selectedRole == 'Plaza Owner' ? null : subEntity,
        entityId: _selectedEntity,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings.successUserRegistered),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pushReplacementNamed(context, AppRoutes.userList);
      } else {
        String errorMessage = strings.errorRegistrationFailed;
        final error = userViewModel.getError('generic') ??
            userViewModel.getError('email') ??
            userViewModel.getError('subEntity');
        if (error != null) errorMessage = error;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      String errorMessage = strings.errorRegistrationFailed;
      if (e is HttpException) errorMessage = e.message;
      if (e is EmailInUseException) errorMessage = e.message;
      if (e is ServiceException) errorMessage = e.message;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error,
          ),
        );
      }
      developer.log('Error registering user: $e',
          name: 'UserRegistrationScreen', error: e);
    } finally {
      if (mounted) setState(() => _isSendingOtp = false);
    }
  }

  List<String> getAvailableRoles() {
    return roleHierarchy[_currentUserRole] ?? [];
  }

  List<String> getAvailablePlazas(List<Plaza> plazas) {
    return plazas
        .where((plaza) => plaza.plazaId != null)
        .map((plaza) =>
            '${plaza.plazaId} - ${plaza.plazaName ?? 'Unnamed Plaza'}')
        .toList();
  }

  String? getPlazaDisplayValue(String? plazaId, List<Plaza> plazas) {
    if (plazaId == null) return null;
    try {
      final plaza = plazas.firstWhere((plaza) => plaza.plazaId == plazaId);
      return '${plaza.plazaId} - ${plaza.plazaName ?? 'Unnamed Plaza'}';
    } catch (e) {
      developer.log('Plaza not found for ID: $plazaId',
          name: 'UserRegistrationScreen');
      return null;
    }
  }

  Widget _buildMobileNumberField(S strings) {
    return Row(
      children: [
        Expanded(
          child: CustomFormFields.normalSizedTextFormField(
            context: context,
            label: strings.labelMobileNumber,
            controller: _mobileNumberController,
            keyboardType: TextInputType.phone,
            isPassword: false,
            enabled: true,
            errorText: Provider.of<UserViewModel>(context).getError('mobile'),
            onChanged: (value) {
              if (_debounce?.isActive ?? false) _debounce!.cancel();
              _debounce = Timer(const Duration(milliseconds: 300), () {
                final userViewModel =
                    Provider.of<UserViewModel>(context, listen: false);
                if (value != _verifiedMobileNumber) {
                  setState(() {
                    _isMobileVerified = false;
                    _verifiedMobileNumber = null;
                  });
                  userViewModel.clearError('mobile');
                }
              });
            },
          ),
        ),
        const SizedBox(width: 8),
        if (!_isMobileVerified)
          CustomButtons.secondaryButton(
            text: strings.buttonVerify,
            onPressed: _isSendingOtp ? () {} : _verifyMobileNumber,
            height: 40,
            width: 100,
            context: context,
          )
        else
          Icon(Icons.check_circle, color: AppColors.success, size: 24),
      ],
    );
  }

  Widget _buildSubEntityField(S strings, UserViewModel userViewModel) {
    final isMultiSelect = _selectedRole == 'Centralized Controller';
    final availablePlazas = getAvailablePlazas(userViewModel.userPlazas);
    final plazaDisplayValue =
        getPlazaDisplayValue(_selectedPlazaId, userViewModel.userPlazas);
    final isPlazaAdminAutoAssigned =
        _currentUserRole == 'Plaza Admin' && _selectedRole == 'Plaza Admin';

    return isMultiSelect
        ? SearchableMultiSelectDropdown(
            label: strings.labelSubEntity,
            selectedValues: _selectedPlazaIds,
            items: userViewModel.userPlazas,
            itemText: (item) =>
                '${(item as Plaza).plazaId} - ${item.plazaName ?? 'Unnamed Plaza'}',
            itemValue: (item) => (item as Plaza).plazaId!,
            onChanged: (values) => setState(() {
              _selectedPlazaIds = values.cast<String>();
            }),
            enabled: true,
            errorText: userViewModel.getError('subEntity'),
          )
        : CustomDropDown.normalDropDown(
            context: context,
            label: strings.labelSubEntity,
            value: plazaDisplayValue,
            items: availablePlazas,
            onChanged: isPlazaAdminAutoAssigned
                ? null
                : (value) =>
                    setState(() => _selectedPlazaId = value?.split(' - ')[0]),
            enabled: !isPlazaAdminAutoAssigned,
            errorText: userViewModel.getError('subEntity'),
          );
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final userViewModel = Provider.of<UserViewModel>(context);

    return Scaffold(
      appBar: CustomAppBar.appBarWithNavigation(
        screenTitle: strings.titleUserRegistration,
        onPressed: () {
          userViewModel.clearErrors();
          Navigator.pop(context);
        },
        darkBackground: Theme.of(context).brightness == Brightness.dark,
        context: context,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: userViewModel.isLoading || _isSendingOtp
          ? Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomFormFields.normalSizedTextFormField(
                    context: context,
                    label: strings.labelFullName,
                    controller: _nameController,
                    keyboardType: TextInputType.text,
                    isPassword: false,
                    enabled: true,
                    errorText: userViewModel.getError('username'),
                  ),
                  const SizedBox(height: 16),
                  CustomFormFields.normalSizedTextFormField(
                    context: context,
                    label: strings.labelEmail,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    isPassword: false,
                    enabled: true,
                    errorText: userViewModel.getError('email'),
                  ),
                  const SizedBox(height: 16),
                  _buildMobileNumberField(strings),
                  const SizedBox(height: 16),
                  CustomFormFields.normalSizedTextFormField(
                    context: context,
                    label: strings.labelAddress,
                    controller: _addressController,
                    keyboardType: TextInputType.streetAddress,
                    isPassword: false,
                    enabled: true,
                    errorText: userViewModel.getError('address'),
                  ),
                  const SizedBox(height: 16),
                  CustomFormFields.normalSizedTextFormField(
                    context: context,
                    label: strings.labelCity,
                    controller: _cityController,
                    keyboardType: TextInputType.text,
                    isPassword: false,
                    enabled: true,
                    errorText: userViewModel.getError('city'),
                  ),
                  const SizedBox(height: 16),
                  CustomFormFields.normalSizedTextFormField(
                    context: context,
                    label: strings.labelState,
                    controller: _stateController,
                    keyboardType: TextInputType.text,
                    isPassword: false,
                    enabled: true,
                    errorText: userViewModel.getError('state'),
                  ),
                  const SizedBox(height: 16),
                  CustomFormFields.normalSizedTextFormField(
                    context: context,
                    label: strings.labelPassword,
                    controller: _passwordController,
                    keyboardType: TextInputType.text,
                    isPassword: true,
                    enabled: true,
                    errorText: userViewModel.getError('password'),
                  ),
                  const SizedBox(height: 16),
                  CustomFormFields.normalSizedTextFormField(
                    context: context,
                    label: strings.labelConfirmPassword,
                    controller: _confirmPasswordController,
                    keyboardType: TextInputType.text,
                    isPassword: true,
                    enabled: true,
                    errorText: userViewModel.getError('confirmPassword'),
                  ),
                  const SizedBox(height: 16),
                  CustomDropDown.normalDropDown(
                    context: context,
                    label: strings.labelAssignRole,
                    value: _selectedRole,
                    items: getAvailableRoles(),
                    onChanged: (value) => setState(() {
                      _selectedRole = value;
                      _selectedPlazaId = null;
                      _selectedPlazaIds = [];
                      if (_currentUserRole == 'Plaza Admin' &&
                          value == 'Plaza Admin' &&
                          userViewModel.userPlazas.isNotEmpty) {
                        _selectedPlazaId =
                            userViewModel.userPlazas.first.plazaId;
                      }
                    }),
                    enabled: true,
                    errorText: userViewModel.getError('role'),
                  ),
                  const SizedBox(height: 16),
                  CustomFormFields.normalSizedTextFormField(
                    context: context,
                    label: strings.labelEntity,
                    controller: TextEditingController(text: _selectedEntity),
                    keyboardType: TextInputType.text,
                    isPassword: false,
                    enabled: false,
                    errorText: userViewModel.getError('entity'),
                  ),
                  const SizedBox(height: 16),
                  if (_selectedRole != null && _selectedRole != 'Plaza Owner')
                    _buildSubEntityField(strings, userViewModel),
                  const SizedBox(height: 24),
                  CustomButtons.primaryButton(
                    text: strings.buttonRegister,
                    onPressed: _registerUser,
                    height: 50,
                    width: AppConfig.deviceWidth * 0.9,
                    context: context,
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _nameController.dispose();
    _emailController.dispose();
    _mobileNumberController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    Provider.of<UserViewModel>(context, listen: false).clearErrors();
    super.dispose();
  }
}
