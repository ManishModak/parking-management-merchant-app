import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/config/app_config.dart';
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
import 'package:merchant_app/views/user/set_reset_password.dart';
import 'package:provider/provider.dart';
import '../../generated/l10n.dart';

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
  String? _selectedRole;
  String? _selectedEntity;
  String? _selectedPlazaId;
  List<String> _selectedPlazaIds = [];
  String? _currentUserRole;
  String? _currentUserId;
  bool _isMobileVerified = false;
  String? _originalMobileNumber;
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
    developer.log(
        'UserInfoScreen initialized with operatorId: ${widget.operatorId}',
        name: 'UserInfoScreen');
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initializeData();
    });
  }

  Future<void> _initializeData() async {
    final strings = S.of(context);
    try {
      await _loadCurrentUserInfo();
      await _loadOperatorData();
      _autoAssignPlazaForPlazaAdmin();
    } catch (e) {
      developer.log(
          'Error initializing data: $e', name: 'UserInfoScreen', error: e);
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

  Future<void> _loadCurrentUserInfo() async {
    final storage = SecureStorageService();
    try {
      _currentUserRole = await storage.getUserRole();
      _currentUserId = await storage.getUserId();
      developer.log(
          'Loaded current user: role=$_currentUserRole, id=$_currentUserId',
          name: 'UserInfoScreen');
    } catch (e) {
      developer.log(
          'Error loading current user info: $e', name: 'UserInfoScreen',
          error: e);
      throw Exception('Failed to load current user info: $e');
    }
  }

  Future<void> _loadOperatorData() async {
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    try {
      await userViewModel.fetchUser(
        userId: widget.operatorId,
        isCurrentAppUser: false,
      );
      await _loadUser();
      final currentOperator = userViewModel.currentOperator;
      if (currentOperator?.entityId != null && mounted) {
        await _fetchPlazas();
      }
    } catch (e) {
      developer.log(
          'Error loading operator data: $e', name: 'UserInfoScreen', error: e);
      throw Exception('Failed to load operator data: $e');
    }
  }

  Future<void> _loadUser() async {
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
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
        _selectedRole = currentOperator.role;
        _selectedEntity = currentOperator.entityId;
        if (currentOperator.role == 'Centralized Controller') {
          _selectedPlazaIds = currentOperator.subEntity.isNotEmpty
              ? List.from(currentOperator.subEntity)
              : [];
          _selectedPlazaId = null;
        } else {
          _selectedPlazaId = currentOperator.subEntity.isNotEmpty
              ? currentOperator.subEntity.first
              : null;
          _selectedPlazaIds = [];
        }
        _originalMobileNumber = currentOperator.mobileNumber;
        _verifiedMobileNumber = currentOperator.mobileNumber;
        _isMobileVerified = true;
        developer.log(
            'Loaded operator: id=${currentOperator.id}, name=${currentOperator
                .name}, role=${currentOperator
                .role}, subEntity=${currentOperator.subEntity}',
            name: 'UserInfoScreen');
      });
    } else {
      developer.log(
          'No operator data found for operatorId: ${widget.operatorId}',
          name: 'UserInfoScreen');
    }
  }

  Future<void> _fetchPlazas() async {
    final strings = S.of(context);
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    try {
      await userViewModel.fetchPlazasForCurrentUser();
      if (mounted) {
        setState(() {
          if (_selectedPlazaId != null) {
            final plazaExists = userViewModel.userPlazas.any((plaza) =>
            plaza.plazaId == _selectedPlazaId);
            if (!plazaExists) _selectedPlazaId = null;
          }
          if (_selectedPlazaIds.isNotEmpty) {
            final validPlazaIds = userViewModel.userPlazas.map((plaza) =>
            plaza.plazaId).toSet();
            _selectedPlazaIds =
                _selectedPlazaIds
                    .where((id) => validPlazaIds.contains(id))
                    .toList();
          }
          developer.log('Fetched plazas: ${userViewModel.userPlazas.length}',
              name: 'UserInfoScreen');
        });
      }
    } catch (e) {
      developer.log(
          'Error fetching plazas: $e', name: 'UserInfoScreen', error: e);
      String errorMessage = strings.errorLoadPlazas;
      if (e is HttpException) errorMessage = e.message;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _autoAssignPlazaForPlazaAdmin() {
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    if (_currentUserRole == 'Plaza Admin' && _selectedRole == 'Plaza Admin' &&
        userViewModel.userPlazas.isNotEmpty) {
      setState(() {
        _selectedPlazaId = userViewModel.userPlazas.first.plazaId;
        _selectedPlazaIds = [];
        developer.log('Auto-assigned plaza: $_selectedPlazaId for Plaza Admin',
            name: 'UserInfoScreen');
      });
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
        validationErrors.forEach((key, value) =>
            userViewModel.setError(key, value));
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
        developer.log(
            'Error verifying mobile: $e', name: 'UserInfoScreen', error: e);
      } finally {
        if (mounted) setState(() => _isSendingOtp = false);
      }
    });
  }

  Future<void> _confirmUpdate() async {
    final strings = S.of(context);
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);

    final List<String> subEntity = _selectedRole == 'Centralized Controller'
        ? _selectedPlazaIds
        : _selectedPlazaId != null ? [_selectedPlazaId!] : [];

    final validationErrors = userViewModel.validateUpdate(
      username: _nameController.text,
      email: _emailController.text,
      mobile: _mobileNumberController.text,
      address: _addressController.text,
      city: _cityController.text,
      state: _stateController.text,
      role: _selectedRole,
      subEntity: subEntity.isNotEmpty ? subEntity.join(',') : null,
      isMobileVerified: _isMobileVerified,
      originalMobile: _originalMobileNumber,
      isProfile: false,
    );

    if (validationErrors.isNotEmpty) {
      validationErrors.forEach((key, value) =>
          userViewModel.setError(key, value));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: validationErrors.values
                  .map((e) => Text('• $e'))
                  .toList(),
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
      final success = await userViewModel.updateUser(
        userId: widget.operatorId,
        username: _nameController.text,
        email: _emailController.text,
        mobileNumber: _mobileNumberController.text,
        address: _addressController.text,
        city: _cityController.text,
        state: _stateController.text,
        role: _selectedRole,
        subEntity: _selectedRole == 'Plaza Owner' ? null : subEntity,
        isCurrentAppUser: false,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings.successUserUpdate),
            backgroundColor: AppColors.success,
          ),
        );
        setState(() {
          _isEditMode = false;
          _originalMobileNumber = _mobileNumberController.text;
          _isMobileVerified = true;
          _verifiedMobileNumber = _mobileNumberController.text;
        });
      } else {
        String errorMessage = strings.errorUpdateFailed;
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
      String errorMessage = strings.errorUpdateFailed;
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
      developer.log(
          'Error updating user: $e', name: 'UserInfoScreen', error: e);
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
        .map((plaza) => '${plaza.plazaId} - ${plaza.plazaName ??
        'Unnamed Plaza'}')
        .toList();
  }

  String? getPlazaDisplayValue(String? plazaId, List<Plaza> plazas) {
    if (plazaId == null) return null;
    try {
      final plaza = plazas.firstWhere((plaza) => plaza.plazaId == plazaId);
      return '${plaza.plazaId} - ${plaza.plazaName ?? 'Unnamed Plaza'}';
    } catch (e) {
      developer.log('Plaza not found for ID: $plazaId', name: 'UserInfoScreen');
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
            enabled: _isEditMode,
            errorText: Provider.of<UserViewModel>(context).getError('mobile'),
            onChanged: (value) {
              if (_debounce?.isActive ?? false) _debounce!.cancel();
              _debounce = Timer(const Duration(milliseconds: 300), () {
                final userViewModel = Provider.of<UserViewModel>(
                    context, listen: false);
                if (value != _originalMobileNumber) {
                  setState(() {
                    _isMobileVerified = false;
                    _verifiedMobileNumber = null;
                  });
                  userViewModel.clearError('mobile');
                } else {
                  setState(() {
                    _isMobileVerified = true;
                    _verifiedMobileNumber = _originalMobileNumber;
                  });
                  userViewModel.clearError('mobile');
                }
              });
            },
          ),
        ),
        const SizedBox(width: 8),
        if (_isEditMode &&
            _mobileNumberController.text != _originalMobileNumber &&
            !_isMobileVerified)
          CustomButtons.secondaryButton(
            text: strings.buttonVerify,
            onPressed: _isSendingOtp ? () {} : _verifyMobileNumber,
            height: 40,
            width: 100,
            context: context,
          )
        else
          if (_isEditMode && _isMobileVerified)
            Icon(Icons.check_circle, color: AppColors.success, size: 24),
      ],
    );
  }

  Widget _buildSubEntityField(S strings, UserViewModel userViewModel) {
    final isMultiSelect = _selectedRole == 'Centralized Controller';
    final availablePlazas = getAvailablePlazas(userViewModel.userPlazas);
    final plazaDisplayValue = getPlazaDisplayValue(
        _selectedPlazaId, userViewModel.userPlazas);
    final isPlazaAdminAutoAssigned = _currentUserRole == 'Plaza Admin' &&
        _selectedRole == 'Plaza Admin';

    return isMultiSelect
        ? SearchableMultiSelectDropdown(
      label: strings.labelSubEntity,
      selectedValues: _selectedPlazaIds,
      items: userViewModel.userPlazas,
      onChanged: _isEditMode
          ? (values) => setState(() {
        _selectedPlazaIds = values.cast<String>();
      })
          : (_) {},
      enabled: _isEditMode,
      errorText: userViewModel.getError('subEntity'),
    )
        : CustomDropDown.normalDropDown(
      context: context,
      label: strings.labelSubEntity,
      value: plazaDisplayValue,
      items: availablePlazas,
      onChanged: _isEditMode && !isPlazaAdminAutoAssigned
          ? (value) => setState(() => _selectedPlazaId = value?.split(' - ')[0])
          : null,
      enabled: _isEditMode && !isPlazaAdminAutoAssigned,
      errorText: userViewModel.getError('subEntity'),
    );
  }

  Widget _buildActionButtons(S strings) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _isEditMode
          ? [
        CustomButtons.secondaryButton(
          text: strings.buttonCancel,
          onPressed: () {
            setState(() {
              _isEditMode = false;
              _loadUser();
            });
          },
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
          onPressed: () =>
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      UserSetResetPasswordScreen(operatorId: widget.operatorId),
                ),
              ),
          height: 50,
          width: AppConfig.deviceWidth * 0.4,
          context: context,
        ),
        CustomButtons.primaryButton(
          text: strings.buttonEdit,
          onPressed: () =>
              setState(() {
                _isEditMode = true;
                _autoAssignPlazaForPlazaAdmin();
              }),
          height: 50,
          width: AppConfig.deviceWidth * 0.4,
          context: context,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final userViewModel = Provider.of<UserViewModel>(context);

    return Scaffold(
      appBar: CustomAppBar.appBarWithNavigation(
        screenTitle: strings.titleUserInfo,
        onPressed: () => Navigator.pop(context),
        darkBackground: Theme
            .of(context)
            .brightness == Brightness.dark,
        context: context,
      ),
      backgroundColor: Theme
          .of(context)
          .scaffoldBackgroundColor,
      body: userViewModel.isLoading || _isSendingOtp
          ? Center(child: CircularProgressIndicator(color: Theme
          .of(context)
          .primaryColor))
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
              enabled: _isEditMode,
              errorText: userViewModel.getError('username'),
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
              enabled: _isEditMode,
              errorText: userViewModel.getError('address'),
            ),
            const SizedBox(height: 16),
            CustomFormFields.normalSizedTextFormField(
              context: context,
              label: strings.labelCity,
              controller: _cityController,
              keyboardType: TextInputType.text,
              isPassword: false,
              enabled: _isEditMode,
              errorText: userViewModel.getError('city'),
            ),
            const SizedBox(height: 16),
            CustomFormFields.normalSizedTextFormField(
              context: context,
              label: strings.labelState,
              controller: _stateController,
              keyboardType: TextInputType.text,
              isPassword: false,
              enabled: _isEditMode,
              errorText: userViewModel.getError('state'),
            ),
            const SizedBox(height: 16),
            CustomDropDown.normalDropDown(
              context: context,
              label: strings.labelAssignRole,
              value: _selectedRole,
              items: getAvailableRoles(),
              onChanged: _isEditMode
                  ? (value) =>
                  setState(() {
                    _selectedRole = value;
                    _selectedPlazaId = null;
                    _selectedPlazaIds = [];
                    _autoAssignPlazaForPlazaAdmin();
                  })
                  : null,
              enabled: _isEditMode,
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
            _buildActionButtons(strings),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _nameController.dispose();
    _userIdController.dispose();
    _emailController.dispose();
    _mobileNumberController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }
}
