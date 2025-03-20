import 'dart:async';
import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/config/app_config.dart';
import 'package:merchant_app/config/app_theme.dart';
import 'package:merchant_app/services/storage/secure_storage_service.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:merchant_app/utils/components/button.dart';
import 'package:merchant_app/utils/components/dropdown.dart';
import 'package:merchant_app/utils/components/form_field.dart';
import 'package:provider/provider.dart';
import '../../generated/l10n.dart';
import '../../utils/screens/otp_verification.dart';
import '../../viewmodels/plaza/plaza_viewmodel.dart';
import '../../viewmodels/user_viewmodel.dart';
import 'dart:developer' as developer;

class UserRegistrationScreen extends StatefulWidget {
  const UserRegistrationScreen({super.key});

  @override
  State<UserRegistrationScreen> createState() => _UserRegistrationScreenState();
}

class _UserRegistrationScreenState extends State<UserRegistrationScreen> with RouteAware {
  String? selectedRole;
  String? selectedEntity;
  String? selectedPlaza;
  bool isMobileVerified = false;
  String? currentUserName;
  String? currentUserRole;
  String? currentUserId;
  String? currentUserEntityId;
  String? _verifiedMobileNumber;
  List<String> _plazas = [];
  List<String> _entities = [];
  late RouteObserver<ModalRoute> _routeObserver;

  // Local TextEditingControllers
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final Map<String, List<String>> roleHierarchy = {
    'System Admin': [
      'System Admin',
      'Plaza Owner',
      'Centralized Controller',
      'Plaza Operator',
      'Backend Monitoring Operator',
      'Cashier',
      'Supervisor',
      'IT Operator'
    ],
    'Plaza Owner': [
      'Plaza Admin',
      'Centralized Controller',
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
    'Centralized Controller': [
      'Plaza Admin',
      'Plaza Operator',
      'Cashier',
      'Backend Monitoring Operator',
      'Supervisor'
    ]
  };

  @override
  void initState() {
    super.initState();
    developer.log('UserRegistrationScreen initialized', name: 'UserRegistration');
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _fetchUserData();
      await fetchEntities();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _routeObserver = Provider.of<RouteObserver<ModalRoute>>(context);
    _routeObserver.subscribe(this, ModalRoute.of(context)!);
  }


  @override
  void dispose() {
    _routeObserver.unsubscribe(this);
    _usernameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  List<String> getAvailableRoles() => roleHierarchy[currentUserRole] ?? [];

  Future<void> verifyMobileNumber(UserViewModel userVM) async {
    final strings = S.of(context);
    final mobile = _mobileController.text;

    // Check only the mobile number format
    if (mobile.isEmpty || !RegExp(r'^\d{10}$').hasMatch(mobile)) {
      userVM.setError('mobile', strings.errorInvalidMobile);
      developer.log('Invalid mobile number format: $mobile', name: 'UserRegistration');
      return;
    }

    // Clear any previous error
    userVM.clearError('mobile');

    developer.log('Verifying mobile number: $mobile', name: 'UserRegistration');
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => OtpVerificationScreen(mobileNumber: mobile),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      setState(() {
        isMobileVerified = true;
        _verifiedMobileNumber = mobile;
      });
      developer.log('Mobile number verified: $_verifiedMobileNumber', name: 'UserRegistration');
    } else {
      // Optionally, set an error if verification failed
      userVM.setError('mobile', strings.errorVerificationFailed);
    }
  }

  Future<void> fetchEntities() async {
    final strings = S.of(context);
    final userVM = Provider.of<UserViewModel>(context, listen: false);

    try {
      developer.log('Fetching entities for role: $currentUserRole', name: 'UserRegistration');
      if (currentUserRole == 'Plaza Owner') {
        _entities = [currentUserName ?? ''].where((item) => item.isNotEmpty).toList();
      } else {
        final entityName = userVM.currentUser?.entityName;
        _entities = [entityName ?? ''].where((item) => item.isNotEmpty).toList();
      }

      if (_entities.isNotEmpty) {
        setState(() => selectedEntity = _entities.first);
        String idToUse = currentUserRole == 'Plaza Owner' ? (currentUserId ?? '') : (currentUserEntityId ?? '');
        await _fetchPlazas(idToUse);
      }
    } catch (e) {
      developer.log('Error fetching entities: $e', name: 'UserRegistration', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${strings.errorFetchEntities}: $e', style: TextStyle(color: context.textPrimaryColor)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _fetchPlazas(String entityId) async {
    final strings = S.of(context);
    final plazaVM = Provider.of<PlazaViewModel>(context, listen: false);

    setState(() {
      _plazas = [];
      selectedPlaza = null;
    });

    try {
      String idToUse = currentUserRole == 'Plaza Owner' ? (currentUserId ?? '') : (currentUserEntityId ?? entityId);
      developer.log('Fetching plazas for entityId: $idToUse', name: 'UserRegistration');
      await plazaVM.fetchUserPlazas(idToUse);
      if (mounted) {
        setState(() {
          _plazas = plazaVM.userPlazas.map((plaza) => plaza.plazaName).toList();
          if (_plazas.length == 1) selectedPlaza = _plazas.first;
        });
      }
    } catch (e) {
      developer.log('Error fetching plazas: $e', name: 'UserRegistration', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${strings.errorFetchPlazas}: $e', style: TextStyle(color: context.textPrimaryColor)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _fetchUserData() async {
    final userVM = Provider.of<UserViewModel>(context, listen: false);
    try {
      final userId = await SecureStorageService().getUserId();
      developer.log('Fetching user data for userId: $userId', name: 'UserRegistration');
      await userVM.fetchUser(userId: userId!, isCurrentAppUser: true);
      if (mounted) {
        setState(() {
          currentUserRole = userVM.currentUser?.role;
          currentUserName = userVM.currentUser?.name;
          currentUserId = userVM.currentUser?.id;
          currentUserEntityId = userVM.currentUser?.entityId;
        });
      }
    } catch (e) {
      developer.log('Error fetching user data: $e', name: 'UserRegistration', error: e);
    }
  }

  void _refreshForm() {
    setState(() {
      selectedRole = null;
      selectedPlaza = null;
      isMobileVerified = false;
      _verifiedMobileNumber = null;
      _usernameController.clear();
      _emailController.clear();
      _mobileController.clear();
      _cityController.clear();
      _stateController.clear();
      _addressController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
    });
    final userVM = Provider.of<UserViewModel>(context, listen: false);
    userVM.resetErrors();
    developer.log('Form refreshed on revisit', name: 'UserRegistration');
  }

  Future<void> _handleRegister(BuildContext context) async {
    final strings = S.of(context);
    final userVM = Provider.of<UserViewModel>(context, listen: false);

    // Validate using UserViewModel
    final validationErrors = userVM.validateRegistration(
      username: _usernameController.text,
      email: _emailController.text,
      mobile: _mobileController.text,
      city: _cityController.text,
      state: _stateController.text,
      address: _addressController.text,
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
      role: selectedRole,
      entity: selectedEntity,
      subEntity: selectedPlaza,
      isMobileVerified: isMobileVerified,
      verifiedMobileNumber: _verifiedMobileNumber,
    );

    if (validationErrors.isNotEmpty) {
      validationErrors.forEach((key, value) => userVM.setError(key, value));
      developer.log('Registration failed: Validation errors', name: 'UserRegistration');
      return;
    }

    String entityId = currentUserRole == 'Plaza Owner' ? (currentUserId ?? '') : (currentUserEntityId ?? '');
    developer.log('Registering user with role: $selectedRole, entity: $selectedEntity, subEntity: $selectedPlaza', name: 'UserRegistration');
    final success = await userVM.registerUser(
      username: _usernameController.text,
      email: _emailController.text,
      mobileNumber: _mobileController.text,
      password: _passwordController.text,
      city: _cityController.text,
      state: _stateController.text,
      address: _addressController.text,
      isAppUserRegister: false,
      role: selectedRole,
      entity: selectedEntity,
      subEntity: selectedPlaza,
      entityId: entityId,
    );

    if (!mounted) return;

    if (success) {
      final currentEntityValue = selectedEntity;
      _refreshForm();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
          shape: Theme.of(context).dialogTheme.shape,
          content: const Text('User Registered Successfully.', style: TextStyle(color: Colors.black)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pop(context);
              },
              child: Text(strings.buttonOk, style: Theme.of(context).textButtonTheme.style?.textStyle?.resolve({})),
            ),
          ],
        ),
      );
      setState(() => selectedEntity = currentEntityValue);
      developer.log('User registered successfully', name: 'UserRegistration');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.errorRegistrationFailed, style: TextStyle(color: context.textPrimaryColor)),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final userVM = Provider.of<UserViewModel>(context);

    return Scaffold(
      appBar: CustomAppBar.appBarWithNavigation(
        screenTitle: strings.titleUserRegistration,
        onPressed: () => Navigator.pop(context),
        darkBackground: Theme.of(context).brightness == Brightness.dark,
        context: context,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomFormFields.normalSizedTextFormField(
              context: context,
              label: strings.labelFullName,
              controller: _usernameController,
              keyboardType: TextInputType.text,
              isPassword: false,
              enabled: true,
              errorText: userVM.getError('username'),
              onChanged: (_) => userVM.clearError('username'),
            ),
            const SizedBox(height: 16),
            CustomFormFields.normalSizedTextFormField(
              context: context,
              label: strings.labelEmail,
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              isPassword: false,
              enabled: true,
              errorText: userVM.getError('email'),
              onChanged: (_) => userVM.clearError('email'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomFormFields.normalSizedTextFormField(
                    context: context,
                    label: strings.labelMobileNumber,
                    controller: _mobileController,
                    keyboardType: TextInputType.phone,
                    isPassword: false,
                    enabled: true,
                    errorText: userVM.getError('mobile'),
                    onChanged: (_) {
                      userVM.clearError('mobile');
                      if (isMobileVerified && _verifiedMobileNumber != _mobileController.text) {
                        setState(() => isMobileVerified = false);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                if (!isMobileVerified)
                  CustomButtons.secondaryButton(
                    text: strings.buttonVerify,
                    onPressed: () => verifyMobileNumber(userVM),
                    height: 40,
                    width: 100,
                    context: context,
                  )
                else
                  Icon(Icons.check_circle, color: Theme.of(context).iconTheme.color, size: 24),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomFormFields.normalSizedTextFormField(
                    context: context,
                    label: strings.labelCity,
                    controller: _cityController,
                    keyboardType: TextInputType.text,
                    isPassword: false,
                    enabled: true,
                    errorText: userVM.getError('city'),
                    onChanged: (_) => userVM.clearError('city'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomFormFields.normalSizedTextFormField(
                    context: context,
                    label: strings.labelState,
                    controller: _stateController,
                    keyboardType: TextInputType.text,
                    isPassword: false,
                    enabled: true,
                    errorText: userVM.getError('state'),
                    onChanged: (_) => userVM.clearError('state'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomFormFields.normalSizedTextFormField(
              context: context,
              label: strings.labelAddress,
              controller: _addressController,
              keyboardType: TextInputType.multiline,
              isPassword: false,
              enabled: true,
              errorText: userVM.getError('address'),
              onChanged: (_) => userVM.clearError('address'),
            ),
            const SizedBox(height: 16),
            CustomDropDown.normalDropDown(
              context: context,
              label: strings.labelAssignRole,
              value: selectedRole,
              items: getAvailableRoles(),
              onChanged: (value) {
                setState(() => selectedRole = value);
                userVM.clearError('role');
              },
              errorText: userVM.getError('role'),
            ),
            const SizedBox(height: 16),
            CustomDropDown.normalDropDown(
              context: context,
              label: strings.labelEntity,
              value: selectedEntity,
              items: _entities,
              enabled: false,
              onChanged: null,
              errorText: userVM.getError('entity'),
            ),
            if (selectedEntity != null) ...[
              const SizedBox(height: 16),
              CustomDropDown.normalDropDown(
                context: context,
                label: strings.labelSubEntity,
                value: selectedPlaza,
                items: _plazas,
                onChanged: (value) => setState(() => selectedPlaza = value),
                errorText: userVM.getError('subEntity'),
              ),
            ],
            const SizedBox(height: 16),
            CustomFormFields.normalSizedTextFormField(
              context: context,
              label: strings.labelPassword,
              controller: _passwordController,
              keyboardType: TextInputType.visiblePassword,
              isPassword: true,
              enabled: true,
              errorText: userVM.getError('password'),
              onChanged: (_) => userVM.clearError('password'),
            ),
            const SizedBox(height: 16),
            CustomFormFields.normalSizedTextFormField(
              context: context,
              label: strings.labelConfirmPassword,
              controller: _confirmPasswordController,
              keyboardType: TextInputType.visiblePassword,
              isPassword: true,
              enabled: true,
              errorText: userVM.getError('confirmPassword'),
              onChanged: (_) => userVM.clearError('confirmPassword'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        color: Theme.of(context).scaffoldBackgroundColor,
        child: CustomButtons.primaryButton(
          height: 50,
          text: strings.buttonRegister,
          onPressed: userVM.isLoading ? null : () => _handleRegister(context),
          isEnabled: !userVM.isLoading,
          context: context,
        ),
      ),
    );
  }
}