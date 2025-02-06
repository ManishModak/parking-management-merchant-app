import 'dart:async';
import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/config/app_config.dart';
import 'package:merchant_app/config/app_strings.dart';
import 'package:merchant_app/services/secure_storage_service.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:merchant_app/utils/components/button.dart';
import 'package:merchant_app/utils/components/dropdown.dart';
import 'package:provider/provider.dart';
import '../../utils/components/form_field.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/plaza_viewmodel/plaza_viewmodel.dart';
import '../../viewmodels/user_viewmodel.dart';
import '../onboarding/otp_verification.dart';

class UserRegistrationScreen extends StatefulWidget {
  const UserRegistrationScreen({super.key});

  @override
  State<UserRegistrationScreen> createState() => _UserRegistrationScreenState();
}

class _UserRegistrationScreenState extends State<UserRegistrationScreen> {
  // Text Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Focus Nodes
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _mobileFocus = FocusNode();
  final FocusNode _addressFocus = FocusNode();
  final FocusNode _cityFocus = FocusNode();
  final FocusNode _stateFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  // State variables
  String? selectedRole;
  String? selectedEntity;
  String? selectedPlaza;
  bool isMobileVerified = false;
  String? currentUserName;
  String? currentUserRole;
  String? currentUserId;
  String? currentUserEntityId;
  List<String> _plazas = [];
  List<String> _entities = [];

  // Role-based accessible roles mapping
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
    _setupFocusListeners();
    _setupTextListeners();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _fetchUserData();
      await fetchEntities();
    });
  }

  void _setupFocusListeners() {
    _nameFocus.addListener(() {
      if (_nameFocus.hasFocus) {
        Provider.of<AuthViewModel>(context, listen: false).clearError('userId');
      }
    });

    _emailFocus.addListener(() {
      if (_emailFocus.hasFocus) {
        Provider.of<AuthViewModel>(context, listen: false).clearError('email');
      }
    });

    _mobileFocus.addListener(() {
      if (_mobileFocus.hasFocus) {
        Provider.of<AuthViewModel>(context, listen: false).clearError('mobile');
      }
    });

    _addressFocus.addListener(() {
      if (_addressFocus.hasFocus) {
        Provider.of<AuthViewModel>(context, listen: false)
            .clearError('address');
      }
    });

    _cityFocus.addListener(() {
      if (_cityFocus.hasFocus) {
        Provider.of<AuthViewModel>(context, listen: false)
            .clearError('address');
      }
    });

    _stateFocus.addListener(() {
      if (_stateFocus.hasFocus) {
        Provider.of<AuthViewModel>(context, listen: false)
            .clearError('address');
      }
    });

    _passwordFocus.addListener(() {
      if (_passwordFocus.hasFocus) {
        Provider.of<AuthViewModel>(context, listen: false)
            .clearError('password');
      }
    });

    _confirmPasswordFocus.addListener(() {
      if (_confirmPasswordFocus.hasFocus) {
        Provider.of<AuthViewModel>(context, listen: false)
            .clearError('password');
      }
    });
  }

  void _setupTextListeners() {
    _nameController.addListener(() {
      Provider.of<AuthViewModel>(context, listen: false).clearError('userId');
    });

    _emailController.addListener(() {
      Provider.of<AuthViewModel>(context, listen: false).clearError('email');
    });

    _mobileNumberController.addListener(() {
      Provider.of<AuthViewModel>(context, listen: false).clearError('mobile');
    });

    _addressController.addListener(() {
      Provider.of<AuthViewModel>(context, listen: false).clearError('address');
    });

    _cityController.addListener(() {
      Provider.of<AuthViewModel>(context, listen: false).clearError('address');
    });

    _stateController.addListener(() {
      Provider.of<AuthViewModel>(context, listen: false).clearError('address');
    });

    _newPasswordController.addListener(() {
      Provider.of<AuthViewModel>(context, listen: false).clearError('password');
    });

    _confirmPasswordController.addListener(() {
      Provider.of<AuthViewModel>(context, listen: false).clearError('password');
    });
  }

  @override
  void dispose() {
    // Dispose focus nodes
    _nameFocus.dispose();
    _emailFocus.dispose();
    _mobileFocus.dispose();
    _addressFocus.dispose();
    _cityFocus.dispose();
    _stateFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();

    // Dispose controllers
    _nameController.dispose();
    _emailController.dispose();
    _mobileNumberController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  List<String> getAvailableRoles() {
    if (currentUserRole == null) return [];

    final assignableRoles = roleHierarchy[currentUserRole] ?? [];

    if (assignableRoles.isEmpty) {
      return [];
    }

    return assignableRoles;
  }

  void _clearAllErrors() {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    authVM.clearAllErrors();
  }

  Future<void> verifyMobileNumber() async {
    if (_mobileNumberController.text.length != 10 ||
        !RegExp(r'^\d{10}$').hasMatch(_mobileNumberController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 10-digit mobile number'),
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
    }
  }

  Future<void> fetchEntities() async {
    if (currentUserRole == 'Plaza Owner') {
      // For Plaza Owner, use their name as entity
      _entities = [currentUserName ?? ''].where((item) => item.isNotEmpty).toList();
    } else {
      // For other roles, use their entityName from currentUser
      final userViewModel = Provider.of<UserViewModel>(context, listen: false);
      final entityName = userViewModel.currentUser?.entityName;
      _entities = [entityName ?? ''].where((item) => item.isNotEmpty).toList();
    }

    if (_entities.isNotEmpty) {
      selectedEntity = _entities.first;
      // For Plaza Owner, use their ID, otherwise use their entityId
      String idToUse = currentUserRole == 'Plaza Owner'
          ? (currentUserId ?? '')
          : (currentUserEntityId ?? '');
      await _fetchPlazas(idToUse);
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _handleRegister(BuildContext context) async {
    _clearAllErrors();
    final authVM = Provider.of<AuthViewModel>(context, listen: false);

    try {
      String entityId = currentUserRole == 'Plaza Owner'
          ? (currentUserId ?? '')
          : (currentUserEntityId ?? '');

      final userData = await authVM.register(
        username: _nameController.text,
        email: _emailController.text,
        mobileNo: _mobileNumberController.text,
        city: _cityController.text,
        state: _stateController.text,
        address: _addressController.text,
        password: _newPasswordController.text,
        confirmPassword: _confirmPasswordController.text,
        selectedRole: selectedRole,
        entityName: selectedEntity,
        selectedSubEntity: selectedPlaza,
        entityId: entityId,
        isMobileVerified: isMobileVerified,
        isAppRegister: false,
      );

      if (userData != null) {
        final currentEntityValue = selectedEntity;

        _nameController.clear();
        _emailController.clear();
        _mobileNumberController.clear();
        _cityController.clear();
        _stateController.clear();
        _addressController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();

        setState(() {
          selectedRole = null;
          selectedPlaza = null;
          isMobileVerified = false;
          selectedEntity = currentEntityValue;
        });

        if (context.mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Registration Successful'),
                content: const Text('User has been registered successfully.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      Navigator.pop(context); // Pop registration screen
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authVM.generalError.isNotEmpty
                ? authVM.generalError
                : 'Please check all fields and try again.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _fetchPlazas(String entityId) async {
    final plazaViewModel = Provider.of<PlazaViewModel>(context, listen: false);

    if (mounted) {
      setState(() {
        _plazas = [];
        selectedPlaza = null;
      });
    }

    try {
      // Determine which ID to use based on user role
      String idToUse;
      if (currentUserRole == 'Plaza Owner') {
        // For Plaza Owner, use their own ID
        idToUse = currentUserId!;
      } else {
        // For other roles, use the current user's entityId
        idToUse = currentUserEntityId ?? entityId;
      }

      await plazaViewModel.fetchUserPlazas(idToUse);

      if (mounted) {
        setState(() {
          _plazas = plazaViewModel.userPlazas
              .map((plaza) => plaza.plazaName)
              .toList();

          // Auto-select if only one plaza
          if (_plazas.length == 1) {
            selectedPlaza = _plazas.first;
          }
        });
      }
    } catch (e) {
      debugPrint('Error fetching plazas: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(plazaViewModel.error ?? 'Failed to fetch plazas'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _fetchUserData() async {
    try {
      final userViewModel = Provider.of<UserViewModel>(context, listen: false);
      final userId = await SecureStorageService().getUserId();
      await userViewModel.fetchUser(userId: userId!, isCurrentAppUser: true);

      if (mounted) {
        setState(() {
          currentUserRole = userViewModel.currentUser?.role;
          currentUserName = userViewModel.currentUser?.name;
          currentUserId = userViewModel.currentUser?.id;
          currentUserEntityId = userViewModel.currentUser?.entityId; // Add this line to get entityId
        });
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.appBarWithNavigation(
        screenTitle: 'User\nRegistration',
        onPressed: () => Navigator.pop(context),
        darkBackground: true,
      ),
      backgroundColor: AppColors.lightThemeBackground,
      body: Consumer<AuthViewModel>(
        builder: (context, authVM, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: AppConfig.deviceWidth*0.9,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomFormFields.primaryFormField(
                    label: AppStrings.labelFullName,
                    controller: _nameController,
                    focusNode: _nameFocus,
                    keyboardType: TextInputType.text,
                    isPassword: false,
                    enabled: true,
                    errorText: authVM.usernameError.isNotEmpty ? authVM.usernameError : null,
                  ),
                  const SizedBox(height: 16),
                  CustomFormFields.primaryFormField(
                    label: AppStrings.labelEmail,
                    controller: _emailController,
                    focusNode: _emailFocus,
                    keyboardType: TextInputType.emailAddress,
                    isPassword: false,
                    enabled: true,
                    errorText: authVM.emailError.isNotEmpty ? authVM.emailError : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: CustomFormFields.primaryFormField(
                          label: AppStrings.labelMobileNumber,
                          controller: _mobileNumberController,
                          focusNode: _mobileFocus,
                          keyboardType: TextInputType.phone,
                          isPassword: false,
                          enabled: true,
                          errorText: authVM.mobileError.isNotEmpty ? authVM.mobileError : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (!isMobileVerified)
                        ElevatedButton(
                          onPressed: verifyMobileNumber,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Verify',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      else
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 24,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: CustomFormFields.primaryFormField(
                          label: AppStrings.labelCity,
                          controller: _cityController,
                          focusNode: _cityFocus,
                          keyboardType: TextInputType.text,
                          isPassword: false,
                          enabled: true,
                          errorText: authVM.cityError.isNotEmpty ? authVM.cityError : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomFormFields.primaryFormField(
                          label: AppStrings.labelState,
                          controller: _stateController,
                          focusNode: _stateFocus,
                          keyboardType: TextInputType.text,
                          isPassword: false,
                          enabled: true,
                          errorText: authVM.stateError.isNotEmpty ? authVM.stateError : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CustomFormFields.primaryFormField(
                    label: AppStrings.labelAddress,
                    controller: _addressController,
                    focusNode: _addressFocus,
                    keyboardType: TextInputType.multiline,
                    isPassword: false,
                    enabled: true,
                    errorText: authVM.addressError.isNotEmpty ? authVM.addressError : null,
                  ),
                  const SizedBox(height: 16),
                  CustomDropDown.normalDropDown(
                    label: AppStrings.labelAssignRole,
                    value: selectedRole,
                    items: getAvailableRoles(),
                    onChanged: (value) {
                      setState(() {
                        selectedRole = value;
                      });
                      Provider.of<AuthViewModel>(context, listen: false)
                          .clearError('role');
                    },
                    errorText: authVM.roleError.isNotEmpty ? authVM.roleError : null,
                  ),
                  const SizedBox(height: 16),
                  CustomDropDown.normalDropDown(
                    label: AppStrings.labelEntity,
                    value: selectedEntity,
                    items: _entities,
                    onChanged: (value) {
                      setState(() {
                        selectedEntity = value;
                      });
                      Provider.of<AuthViewModel>(context, listen: false)
                          .clearError('entity');
                      if (value != null) {
                        _fetchPlazas(value);
                      }
                    },
                    errorText: authVM.entityError.isNotEmpty ? authVM.entityError : null,
                  ),
                  if (selectedEntity != null) ...[
                    const SizedBox(height: 16),
                    CustomDropDown.normalDropDown(
                      label: AppStrings.labelSubEntity,
                      value: selectedPlaza,
                      items: _plazas,
                      onChanged: (value) {
                        setState(() {
                          selectedPlaza = value;
                        });
                      },
                    ),
                  ],
                  const SizedBox(height: 16),
                  CustomFormFields.primaryFormField(
                    label: AppStrings.labelPassword,
                    controller: _newPasswordController,
                    focusNode: _passwordFocus,
                    keyboardType: TextInputType.visiblePassword,
                    isPassword: true,
                    enabled: true,
                    errorText: authVM.passwordError.isNotEmpty ? authVM.passwordError : null,
                  ),
                  const SizedBox(height: 16),
                  CustomFormFields.primaryFormField(
                    label: AppStrings.labelConfirmPassword,
                    controller: _confirmPasswordController,
                    focusNode: _confirmPasswordFocus,
                    keyboardType: TextInputType.visiblePassword,
                    isPassword: true,
                    enabled: true,
                    errorText: authVM.confirmPasswordError.isNotEmpty ? authVM.confirmPasswordError : null,
                  ),
                  const SizedBox(height: 16),
                  CustomButtons.primaryButton(
                    text: AppStrings.buttonRegister,
                    onPressed: () => _handleRegister(context),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}