import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/models/plaza.dart';
import 'package:merchant_app/services/storage/secure_storage_service.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:merchant_app/utils/components/button.dart';
import 'package:merchant_app/utils/components/dropdown.dart';
import 'package:merchant_app/utils/components/form_field.dart';
import 'package:merchant_app/utils/components/searchable_multi_select_dropdown.dart';
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
  final TextEditingController _pincodeController = TextEditingController();

  bool _isEditMode = false;
  String? _selectedRole;
  String? _selectedEntityId;
  String? _selectedEntityName;
  String? _selectedPlazaId;
  List<String> _selectedPlazaIds = [];
  String? _currentUserRole;
  String? _currentUserId;
  bool _isMobileVerified = false;
  String? _originalMobileNumber;
  String? _verifiedMobileNumber;
  bool _isLoadingIndicator = false; // Using this for general loading
  Timer? _debounce;

  // Your existing roleHierarchy
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
      // Clear any potential stale errors from the ViewModel when screen is initialized
      Provider.of<UserViewModel>(context, listen: false).clearErrors();
      await _initializeData();
    });
  }

  Future<void> _initializeData() async {
    final strings = S.of(context);
    setState(() => _isLoadingIndicator = true);
    try {
      await _loadCurrentUserInfo();
      // _loadOperatorData now populates fields and fetches plazas for dropdowns
      await _loadOperatorData();
      _autoAssignPlazaForPlazaAdmin();
    } catch (e) {
      developer.log(
          'Error initializing data: $e', name: 'UserInfoScreen', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${strings.errorLoadData}: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingIndicator = false);
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
      // Not throwing here, to allow UI to load; problems will manifest if this data is crucial later
    }
  }

  Future<void> _loadOperatorData() async {
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    try {
      // Fetch the operator being edited. This will set userViewModel.currentOperator
      // and userViewModel.userPlazas (if operator is Owner or CC with subEntities).
      await userViewModel.fetchUser(
        userId: widget.operatorId,
        isCurrentAppUser: false,
      );
      _populateFieldsFromViewModel(); // Populate screen fields from userViewModel.currentOperator

      // Then, ensure userViewModel.userPlazas contains the plazas the *logged-in user* can assign.
      // This might overwrite userPlazas if fetchUser above populated it with the operator's own plazas.
      await userViewModel.prepareForUserEdit();
      _validateSelectedPlazasAfterFetch(userViewModel.userPlazas);

    } catch (e) {
      developer.log(
          'Error loading operator data or assignable plazas: $e', name: 'UserInfoScreen', error: e);
      // Let _initializeData handle the SnackBar for general init errors
      rethrow;
    }
  }

  void _populateFieldsFromViewModel() { // Was _loadUser
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    final currentOperator = userViewModel.currentOperator;

    if (currentOperator != null) { // No mounted check, as this is called during build/init path
      _nameController.text = currentOperator.name;
      _userIdController.text = currentOperator.id;
      _emailController.text = currentOperator.email;
      _mobileNumberController.text = currentOperator.mobileNumber;
      _addressController.text = currentOperator.address ?? '';
      _cityController.text = currentOperator.city ?? '';
      _stateController.text = currentOperator.state ?? '';
      _pincodeController.text = currentOperator.pincode ?? '';
      _selectedRole = currentOperator.role;
      _selectedEntityId = currentOperator.entityId;
      _selectedEntityName = currentOperator.entityName;

      // Ensure subEntity items are strings
      final List<String> operatorSubEntities = currentOperator.subEntity
          .map((item) => item.toString())
          .toList();

      if (currentOperator.role == 'Centralized Controller') {
        _selectedPlazaIds = operatorSubEntities.isNotEmpty
            ? List<String>.from(operatorSubEntities)
            : [];
        _selectedPlazaId = null;
      } else { // For Plaza Admin, Operator, Cashier, Supervisor - they have one plaza in subEntity
        _selectedPlazaId = operatorSubEntities.isNotEmpty
            ? operatorSubEntities.first
            : null;
        _selectedPlazaIds = [];
      }

      _originalMobileNumber = currentOperator.mobileNumber;
      _verifiedMobileNumber = currentOperator.mobileNumber; // Assume loaded is verified
      _isMobileVerified = true;
      developer.log(
          'Populated fields for operator: id=${currentOperator.id}, name=${currentOperator.name}, role=${currentOperator.role}, subEntity=${currentOperator.subEntity}',
          name: 'UserInfoScreen');
    } else {
      developer.log(
          'No currentOperator in ViewModel to populate fields from.',
          name: 'UserInfoScreen');
    }
  }

  void _validateSelectedPlazasAfterFetch(List<Plaza> availablePlazas) {
    // No need for mounted check if this is called synchronously after fetches within _initializeData's try-catch
    // If it were async itself, mounted check would be good.
    // setState(() { // Removed setState, this is part of init data loading
    if (_selectedPlazaId != null) {
      final plazaExists = availablePlazas.any((plaza) => plaza.plazaId == _selectedPlazaId);
      if (!plazaExists) {
        developer.log("Previously selected single plaza ID '$_selectedPlazaId' not found in available plazas. Clearing.", name: "UserInfoScreen");
        _selectedPlazaId = null;
      }
    }
    if (_selectedPlazaIds.isNotEmpty) {
      final validPlazaIdsSet = availablePlazas.map((plaza) => plaza.plazaId).toSet();
      _selectedPlazaIds = _selectedPlazaIds.where((id) => validPlazaIdsSet.contains(id)).toList();
    }
    // });
  }


  void _autoAssignPlazaForPlazaAdmin() {
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    // If current logged-in user is Plaza Admin AND they are editing/creating a user
    // whose role is NOT CC or Plaza Owner, then assign the user to the Admin's own plaza.
    if (_currentUserRole == 'Plaza Admin' && userViewModel.userPlazas.isNotEmpty) {
      if (_selectedRole != 'Centralized Controller' && _selectedRole != 'Plaza Owner') {
        // Assuming the Plaza Admin's own plaza is the first one in their manageable list.
        // A more robust way would be to get the Plaza Admin's actual plazaId from their user object.
        final String? adminPlazaId = userViewModel.currentUser?.subEntity.isNotEmpty == true
            ? userViewModel.currentUser!.subEntity.first.toString()
            : userViewModel.userPlazas.first.plazaId; // Fallback

        if (adminPlazaId != null && _selectedPlazaId != adminPlazaId) {
          if (mounted) { // Check mounted before setState
            setState(() {
              _selectedPlazaId = adminPlazaId;
              _selectedPlazaIds = [];
              developer.log(
                  'Auto-assigned plaza by Plaza Admin: $_selectedPlazaId for role $_selectedRole',
                  name: 'UserInfoScreen');
            });
          }
        }
      }
    }
  }

  Future<void> _verifyMobileNumber() async {
    final strings = S.of(context);
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    final mobile = _mobileNumberController.text;

    // Debounce logic was in your original file for _verifyMobileNumber,
    // but it was inside the Timer. If this is called from a button, it's direct.
    // For this version, I'm keeping the direct call structure.

    final validationErrors = userViewModel.validateMobile(mobile);
    if (validationErrors.isNotEmpty) {
      validationErrors.forEach((key, value) => userViewModel.setError(key, value));
      return;
    }
    userViewModel.clearError('mobile');

    setState(() => _isLoadingIndicator = true);
    try {
      // VM's verifyMobileNumber sends OTP, returns true if successful,
      // false if MobileNumberInUseException (and sets error in VM).
      final bool otpSendAttempted = await userViewModel.verifyMobileNumber(
        mobile,
        errorMobileInUse: strings.errorMobileInUse,
      );

      if (otpSendAttempted && mounted) { // otpSendAttempted means no MobileInUse error
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
        } else if (result == false && mounted) { // OTP verification failed or backed out
          userViewModel.setError('mobile', strings.errorVerificationFailed);
          setState(() {
            _isMobileVerified = false;
          });
        }
      } else if (!otpSendAttempted && mounted) {
        // MobileInUse error occurred, error is already set in ViewModel.
        // SnackBar will be shown based on userViewModel.getError('mobile') if needed by UI.
        // Or, you can show a specific SnackBar here too.
        // For now, relying on the errorText of the field.
      }
    } catch (e) { // Catch other unexpected errors from OTP sending/navigation
      userViewModel.setError('mobile', strings.errorVerificationFailed);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${strings.errorVerificationFailed}: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      developer.log('Error in _verifyMobileNumber: $e', name: 'UserInfoScreen', error: e);
    } finally {
      if (mounted) setState(() => _isLoadingIndicator = false);
    }
  }

  Future<void> _confirmUpdate() async {
    final strings = S.of(context);
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);

    final List<String> subEntityForPayload = _selectedRole == 'Centralized Controller'
        ? _selectedPlazaIds
        : _selectedPlazaId != null
        ? [_selectedPlazaId!]
        : [];

    final String? subEntityForValidation = subEntityForPayload.isNotEmpty ? subEntityForPayload.join(',') : null;

    final validationErrors = userViewModel.validateUpdate(
      username: _nameController.text,
      email: _emailController.text.toLowerCase(),
      mobile: _mobileNumberController.text,
      address: _addressController.text,
      city: _cityController.text,
      state: _stateController.text,
      pincode: _pincodeController.text,
      role: _selectedRole,
      subEntity: subEntityForValidation,
      isMobileVerified: _isMobileVerified || (_mobileNumberController.text == _originalMobileNumber),
      originalMobile: _originalMobileNumber,
      isProfile: false,
    );

    if (validationErrors.isNotEmpty) {
      validationErrors.forEach((key, value) => userViewModel.setError(key, value));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: validationErrors.values.map((e) => Text('• $e', style: TextStyle(color: Theme.of(context).colorScheme.onError))).toList(),
            ),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      return;
    }
    userViewModel.clearErrors(); // Clear validation errors before API call

    setState(() => _isLoadingIndicator = true);
    try {
      final success = await userViewModel.updateUser(
        userId: widget.operatorId,
        username: _nameController.text,
        email: _emailController.text.toLowerCase(),
        mobileNumber: _mobileNumberController.text,
        address: _addressController.text,
        city: _cityController.text,
        state: _stateController.text,
        pincode: _pincodeController.text,
        role: _selectedRole,
        subEntity: subEntityForPayload, // Pass List<String>
        isCurrentAppUser: false,
      );

      if (mounted) {
        if (success) {
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
            // Consider re-calling _populateFieldsFromViewModel() or parts of _loadOperatorData()
            // if backend might return slightly different data after update.
          });
        } else {
          // Errors are set in UserViewModel. Show the most specific one.
          final emailError = userViewModel.getError('email');
          final genericError = userViewModel.getError('generic');
          final subEntityError = userViewModel.getError('subEntity');
          // Add other specific field errors if needed

          String errorMessage = strings.errorUpdateFailed; // Default

          if (emailError != null) {
            // This will show "email must be unique" or whatever message is in emailError
            errorMessage = emailError;
            // If you want to prepend a generic string like "Email issue:"
            // errorMessage = "${strings.errorEmailInUse} ($emailError)";
          } else if (subEntityError != null) {
            errorMessage = subEntityError;
          } else if (genericError != null) {
            errorMessage = genericError;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 6),
            ),
          );
        }
      }
    } catch (e) { // Fallback for truly unexpected errors
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${strings.errorUpdateFailed}: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      developer.log('Error in _confirmUpdate (outer catch): $e', name: 'UserInfoScreen', error: e);
    } finally {
      if (mounted) setState(() => _isLoadingIndicator = false);
    }
  }

  List<String> getAvailableRoles() {
    // Use a default list if _currentUserRole is null or not in roleHierarchy
    return roleHierarchy[_currentUserRole ?? ''] ?? []; // Provide a fallback if needed
  }

  List<String> getDropdownPlazaItems(List<Plaza> plazas) { // Was getAvailablePlazas
    return plazas
        .where((plaza) => plaza.plazaId != null)
        .map((plaza) => '${plaza.plazaId} - ${plaza.plazaName ?? "Unnamed Plaza"}') // Hardcoded fallback
        .toList();
  }

  String? getPlazaDisplayValue(String? plazaId, List<Plaza> plazas) {
    if (plazaId == null) return null;
    try {
      final plaza = plazas.firstWhere((p) => p.plazaId == plazaId);
      return '${plaza.plazaId} - ${plaza.plazaName ?? "Unnamed Plaza"}'; // Hardcoded fallback
    } catch (e) {
      developer.log('Plaza ID $plazaId not found for display', name: 'UserInfoScreen');
      return plazaId; // Fallback to showing ID
    }
  }


  Widget _buildMobileNumberField(S strings) {
    final userViewModel = Provider.of<UserViewModel>(context); // Use watch for errorText
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: CustomFormFields.normalSizedTextFormField(
            context: context,
            label: strings.labelMobileNumber,
            controller: _mobileNumberController,
            keyboardType: TextInputType.phone,
            enabled: _isEditMode,
            errorText: userViewModel.getError('mobile'),
            onChanged: (value) {
              if (_debounce?.isActive ?? false) _debounce!.cancel();
              _debounce = Timer(const Duration(milliseconds: 300), () {
                final vm = Provider.of<UserViewModel>(context, listen: false);
                vm.clearError('mobile'); // Clear error as user types
                if (mounted) { // Check mounted before setState
                  if (value != _originalMobileNumber) {
                    if (_isMobileVerified) {
                      setState(() {
                        _isMobileVerified = false;
                        _verifiedMobileNumber = null;
                      });
                    }
                  } else {
                    if (!_isMobileVerified) {
                      setState(() {
                        _isMobileVerified = true;
                        _verifiedMobileNumber = _originalMobileNumber;
                      });
                    }
                  }
                }
              });
            },
          ),
        ),
        if (_isEditMode) ...[
          const SizedBox(width: 8),
          if (_mobileNumberController.text != _originalMobileNumber && !_isMobileVerified)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: CustomButtons.secondaryButton(
                text: strings.buttonVerify,
                onPressed: _isLoadingIndicator ? (){} : _verifyMobileNumber,
                height: 40,
                width: 90, // Adjusted width
                context: context,
              ),
            )
          else if (_isMobileVerified || _mobileNumberController.text == _originalMobileNumber)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Icon(Icons.check_circle, color: AppColors.success, size: 24),
            ),
        ]
      ],
    );
  }

  Widget _buildSubEntityField(S strings, UserViewModel userViewModel) {
    final isMultiSelect = _selectedRole == 'Centralized Controller';

    bool isRoleBlockingSubEntityEdit = _currentUserRole == 'Plaza Admin' &&
        _selectedRole != 'Centralized Controller' &&
        _selectedRole != 'Plaza Owner';
    final bool enableDropdown = _isEditMode && !isRoleBlockingSubEntityEdit;

    if (isMultiSelect) {
      // Assuming SearchableMultiSelectDropdown has these parameters as per your original code
      return SearchableMultiSelectDropdown(
        label: strings.labelSubEntity,
        selectedValues: _selectedPlazaIds,
        items: userViewModel.userPlazas, // This should be List<Plaza>
        // You need to provide how to get display label and value from Plaza object
        // These were the parameters causing issues in the image.
        // Adjust these based on your SearchableMultiSelectDropdown's actual API.
        // Example placeholder implementations if your widget expects them:
        // itemLabelFormatter: (Plaza plaza) => '${plaza.plazaId} - ${plaza.plazaName ?? "Unnamed Plaza"}',
        // itemValueExtractor: (Plaza plaza) => plaza.plazaId!,
        onChanged: enableDropdown
            ? (values) { // Assuming 'values' is List<String> of selected IDs
          setState(() => _selectedPlazaIds = values.cast<String>());
          userViewModel.clearError('subEntity');
        }
            : (_){}, // Original used (_){}
        enabled: enableDropdown,
        errorText: userViewModel.getError('subEntity'),
        // context: context, // Add if your custom widget requires it
      );
    } else {
      final dropdownPlazaItems = getDropdownPlazaItems(userViewModel.userPlazas);
      final currentPlazaDisplayValue = getPlazaDisplayValue(_selectedPlazaId, userViewModel.userPlazas);
      return CustomDropDown.normalDropDown(
        context: context,
        label: strings.labelSubEntity,
        value: currentPlazaDisplayValue,
        items: dropdownPlazaItems,
        onChanged: enableDropdown
            ? (value) {
          setState(() => _selectedPlazaId = value?.split(' - ')[0]);
          userViewModel.clearError('subEntity');
        }
            : null,
        enabled: enableDropdown,
        errorText: userViewModel.getError('subEntity'),
      );
    }
  }

  Widget _buildActionButtons(S strings) {
    // Using MediaQuery directly as AppConfig.deviceWidth might not be available or might not take context
    final buttonWidth = MediaQuery.of(context).size.width * 0.4;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _isEditMode
          ? [
        CustomButtons.secondaryButton(
          text: strings.buttonCancel,
          onPressed: _isLoadingIndicator ? (){} : () {
            Provider.of<UserViewModel>(context, listen: false).clearErrors(); // Clear errors on cancel
            setState(() {
              _isEditMode = false;
              _populateFieldsFromViewModel(); // Restore to original loaded values
            });
          },
          height: 50,
          width: buttonWidth,
          context: context,
        ),
        CustomButtons.primaryButton(
          text: strings.buttonSave,
          onPressed: _isLoadingIndicator ? (){} : _confirmUpdate,
          height: 50,
          width: buttonWidth,
          context: context,
        ),
      ]
          : [
        CustomButtons.secondaryButton(
          text: strings.buttonSetResetPassword,
          onPressed: _isLoadingIndicator ? (){} : () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserSetResetPasswordScreen(
                  operatorId: widget.operatorId),
            ),
          ),
          height: 50,
          width: buttonWidth,
          context: context,
        ),
        CustomButtons.primaryButton(
          text: strings.buttonEdit,
          onPressed: _isLoadingIndicator ? (){} : () {
            setState(() {
              _isEditMode = true;
              _originalMobileNumber = _mobileNumberController.text;
              _isMobileVerified = true; // Assume current is verified
              _verifiedMobileNumber = _mobileNumberController.text;
              _autoAssignPlazaForPlazaAdmin();
            });
          },
          height: 50,
          width: buttonWidth,
          context: context,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final userViewModel = Provider.of<UserViewModel>(context);

    Widget bodyContent;

    if (_isLoadingIndicator || (userViewModel.isLoading && userViewModel.currentOperator == null)) {
      bodyContent = Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor));
    } else if (userViewModel.currentOperator == null && !userViewModel.isLoading) { // Ensure loading is false
      bodyContent = Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
                userViewModel.getError('generic') ?? "Failed to load operator data.", // Hardcoded fallback
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.error)
            ),
          )
      );
    }
    else {
      bodyContent = SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomFormFields.normalSizedTextFormField(
              context: context,
              label: strings.labelFullName,
              controller: _nameController,
              enabled: _isEditMode,
              errorText: userViewModel.getError('username'),
              onChanged: _isEditMode ? (_) => userViewModel.clearError('username') : null,
            ),
            const SizedBox(height: 16),
            CustomFormFields.normalSizedTextFormField(
              context: context,
              label: strings.labelUserId,
              controller: _userIdController,
              enabled: false,
            ),
            const SizedBox(height: 16),
            CustomFormFields.normalSizedTextFormField(
              context: context,
              label: strings.labelEmail,
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              enabled: _isEditMode,
              errorText: userViewModel.getError('email'),
              onChanged: _isEditMode ? (_) => userViewModel.clearError('email') : null,
            ),
            const SizedBox(height: 16),
            _buildMobileNumberField(strings),
            const SizedBox(height: 16),
            CustomFormFields.normalSizedTextFormField(
              context: context,
              label: strings.labelAddress,
              controller: _addressController,
              enabled: _isEditMode,
              errorText: userViewModel.getError('address'),
              onChanged: _isEditMode ? (_) => userViewModel.clearError('address') : null,
            ),
            const SizedBox(height: 16),
            CustomFormFields.normalSizedTextFormField(
              context: context,
              label: strings.labelCity,
              controller: _cityController,
              enabled: _isEditMode,
              errorText: userViewModel.getError('city'),
              onChanged: _isEditMode ? (_) => userViewModel.clearError('city') : null,
            ),
            const SizedBox(height: 16),
            CustomFormFields.normalSizedTextFormField(
              context: context,
              label: strings.labelState,
              controller: _stateController,
              enabled: _isEditMode,
              errorText: userViewModel.getError('state'),
              onChanged: _isEditMode ? (_) => userViewModel.clearError('state') : null,
            ),
            const SizedBox(height: 16),
            CustomFormFields.normalSizedTextFormField(
              context: context,
              label: strings.labelPincode,
              controller: _pincodeController,
              keyboardType: TextInputType.number,
              enabled: _isEditMode,
              errorText: userViewModel.getError('pincode'),
              onChanged: _isEditMode ? (_) => userViewModel.clearError('pincode') : null,
            ),
            const SizedBox(height: 16),
            CustomDropDown.normalDropDown(
              context: context,
              label: strings.labelAssignRole,
              value: _selectedRole,
              items: getAvailableRoles(),
              onChanged: _isEditMode
                  ? (value) {
                userViewModel.clearError('role'); // Clear errors when changing
                userViewModel.clearError('subEntity');
                setState(() {
                  _selectedRole = value;
                  _selectedPlazaId = null;
                  _selectedPlazaIds = [];
                  _autoAssignPlazaForPlazaAdmin();
                });
              }
                  : null,
              enabled: _isEditMode,
              errorText: userViewModel.getError('role'),
            ),
            const SizedBox(height: 16),
            CustomFormFields.normalSizedTextFormField(
              context: context,
              label: strings.labelEntity, // This was your original key
              controller: TextEditingController(text: _selectedEntityName ?? "N/A"), // Hardcoded fallback
              enabled: false,
              errorText: userViewModel.getError('entity'), // Your original key
            ),
            const SizedBox(height: 16),
            if (_selectedRole != null && _selectedRole != 'Plaza Owner')
              _buildSubEntityField(strings, userViewModel),
            const SizedBox(height: 24),
            _buildActionButtons(strings),
            const SizedBox(height: 16),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: CustomAppBar.appBarWithNavigation(
        screenTitle: strings.titleUserInfo,
        onPressed: () => Navigator.pop(context),
        darkBackground: Theme.of(context).brightness == Brightness.dark,
        context: context,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: bodyContent,
    );
  }

  @override
  void dispose() {
    developer.log('UserInfoScreen disposing.', name: 'UserInfoScreen');
    // Clear errors from the ViewModel when the screen is disposed.
    // Using addPostFrameCallback to ensure it runs after the current build cycle if needed,
    // though for dispose, direct call is often fine if VM instance is accessible.
    // The main challenge is getting a valid context if Provider.of is used.
    // A direct reference to the VM instance (if stored in initState) would be safer.
    // For now, this attempts to clear. If it fails due to context, it's logged.
    try {
      final userViewModel = Provider.of<UserViewModel>(context, listen: false);
      userViewModel.clearErrors();
      developer.log('Cleared UserViewModel errors on dispose.', name: 'UserInfoScreen');
    } catch (e) {
      developer.log('Could not clear UserViewModel errors on dispose: $e. Context might be invalid.', name: 'UserInfoScreen');
    }

    _debounce?.cancel();
    _nameController.dispose();
    _userIdController.dispose();
    _emailController.dispose();
    _mobileNumberController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }
}