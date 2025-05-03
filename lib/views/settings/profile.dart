import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/config/app_theme.dart';
import 'package:merchant_app/services/storage/secure_storage_service.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:merchant_app/utils/components/button.dart';
import 'package:merchant_app/utils/components/card.dart';
import 'package:merchant_app/utils/components/form_field.dart';
import 'package:merchant_app/viewmodels/settings_viewmodel.dart';
import 'package:merchant_app/generated/l10n.dart';
import 'dart:developer' as developer;
import 'dart:async';

import '../../services/security/otp_verification_service.dart';
import '../../utils/exceptions.dart';
import '../../utils/screens/otp_verification.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  bool _isEditMode = false;
  bool isMobileVerified = false;
  String? _originalMobileNumber;
  String? _verifiedMobileNumber;
  Map<String, String> _originalValues = {};
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    developer.log('UserProfileScreen initialized', name: 'UserProfileScreen');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfileData();
    });
  }

  Future<void> _loadProfileData() async {
    final strings = S.of(context);
    final settingsViewModel = Provider.of<SettingsViewModel>(context, listen: false);
    final userId = await SecureStorageService().getUserId();
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.errorUserIdNotFound,
              style: TextStyle(color: context.textPrimaryColor)),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    developer.log('Loading profile data for userId: $userId',
        name: 'UserProfileScreen');
    await settingsViewModel.fetchUser(userId: userId, isCurrentAppUser: true);
    if (mounted) {
      await _loadUserProfile();
    }
  }

  Future<void> _loadUserProfile() async {
    final settingsViewModel = Provider.of<SettingsViewModel>(context, listen: false);
    final currentUser = settingsViewModel.currentUser;

    if (currentUser != null && mounted) {
      setState(() {
        _nameController.text = currentUser.name;
        _emailController.text = currentUser.email;
        _mobileNumberController.text = currentUser.mobileNumber;
        _addressController.text = currentUser.address ?? '';
        _cityController.text = currentUser.city ?? '';
        _stateController.text = currentUser.state ?? '';
        _originalMobileNumber = currentUser.mobileNumber;
        _verifiedMobileNumber = currentUser.mobileNumber;
        isMobileVerified = true;
        _storeOriginalValues();
        developer.log(
          'Loaded user profile: id=${currentUser.id}, name=${currentUser.name}',
          name: 'UserProfileScreen',
        );
      });
    } else {
      developer.log('No user profile data loaded',
          name: 'UserProfileScreen', level: 900);
    }
  }

  void _storeOriginalValues() {
    _originalValues = {
      'username': _nameController.text,
      'email': _emailController.text,
      'mobileNumber': _mobileNumberController.text,
      'address': _addressController.text,
      'city': _cityController.text,
      'state': _stateController.text,
    };
  }

  void _restoreOriginalValues() {
    setState(() {
      _nameController.text = _originalValues['username'] ?? '';
      _emailController.text = _originalValues['email'] ?? '';
      _mobileNumberController.text = _originalValues['mobileNumber'] ?? '';
      _addressController.text = _originalValues['address'] ?? '';
      _cityController.text = _originalValues['city'] ?? '';
      _stateController.text = _originalValues['state'] ?? '';
      isMobileVerified = (_mobileNumberController.text == _originalMobileNumber);
      _verifiedMobileNumber = isMobileVerified ? _mobileNumberController.text : null;
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

  Future<void> verifyMobileNumber() async {
    final strings = S.of(context);
    final settingsViewModel = Provider.of<SettingsViewModel>(context, listen: false);
    final mobile = _mobileNumberController.text;

    if (mobile.isEmpty || !RegExp(r'^\d{10}$').hasMatch(mobile)) {
      settingsViewModel.setError('mobile', strings.errorInvalidMobile);
      developer.log('Invalid mobile number format: $mobile', name: 'UserProfileScreen');
      return;
    }

    settingsViewModel.clearError('mobile');

    try {
      final verificationService = VerificationService();
      await verificationService.sendOtp(mobile);
      developer.log('OTP sent successfully to $mobile', name: 'UserProfileScreen');

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
        developer.log('Mobile number verified: $mobile', name: 'UserProfileScreen');
      } else {
        settingsViewModel.setError('mobile', strings.errorVerificationFailed);
        setState(() {
          isMobileVerified = false;
          _verifiedMobileNumber = null;
        });
      }
    } on MobileNumberInUseException catch (e) {
      if (!mounted) return;
      settingsViewModel.setError('mobile', strings.errorMobileInUse);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "${strings.errorMobileInUse}. ${strings.suggestionTryAnotherNumber}",
            style: TextStyle(color: context.textPrimaryColor),
          ),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 6),
        ),
      );
      developer.log('Mobile number in use: $mobile', name: 'UserProfileScreen', error: e);
    } catch (e) {
      if (!mounted) return;
      settingsViewModel.setError('mobile', strings.errorVerificationFailed);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${strings.errorVerificationFailed}: $e',
            style: TextStyle(color: context.textPrimaryColor),
          ),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 4),
        ),
      );
      developer.log('Error verifying mobile number: $e', name: 'UserProfileScreen', error: e);
    }
  }

  Future<void> _confirmUpdate() async {
    final strings = S.of(context);
    final settingsViewModel = Provider.of<SettingsViewModel>(context, listen: false);
    final userId = await SecureStorageService().getUserId();

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.errorUserIdNotFound,
              style: TextStyle(color: context.textPrimaryColor)),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    developer.log('Confirming update for userId: $userId',
        name: 'UserProfileScreen');

    final validationErrors = settingsViewModel.validateUpdate(
      username: _nameController.text,
      email: _emailController.text,
      mobile: _mobileNumberController.text,
      address: _addressController.text,
      city: _cityController.text,
      state: _stateController.text,
      role: null,
      subEntity: null,
      isMobileVerified: isMobileVerified,
      originalMobile: _originalMobileNumber,
      isProfile: true,
    );

    if (validationErrors.isNotEmpty) {
      validationErrors.forEach((key, value) => settingsViewModel.setError(key, value));
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

    final success = await settingsViewModel.updateUser(
      userId: userId,
      username: _nameController.text,
      email: _emailController.text,
      mobileNumber: _mobileNumberController.text,
      address: _addressController.text,
      city: _cityController.text,
      state: _stateController.text,
      isCurrentAppUser: true,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.successProfileUpdate,
              style: TextStyle(color: context.textPrimaryColor)),
          backgroundColor: AppColors.success,
        ),
      );
      setState(() {
        _isEditMode = false;
        _originalMobileNumber = _mobileNumberController.text;
        isMobileVerified = true;
        _verifiedMobileNumber = _mobileNumberController.text;
        _storeOriginalValues();
      });
    } else {
      final emailError = settingsViewModel.errors['email'] ?? '';
      final generalError = settingsViewModel.errors['general'] ?? '';
      String errorMessage = emailError.isNotEmpty
          ? "$emailError. ${strings.errorEmailInUse}"
          : (generalError.isNotEmpty
          ? generalError
          : strings.errorUpdateFailed);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage,
              style: TextStyle(color: context.textPrimaryColor)),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 6),
        ),
      );
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _nameController.dispose();
    _emailController.dispose();
    _mobileNumberController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
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
            errorText: Provider.of<SettingsViewModel>(context).errors['mobile'],
            onChanged: (value) {
              if (_debounce?.isActive ?? false) _debounce!.cancel();
              _debounce = Timer(const Duration(milliseconds: 300), () {
                final settingsViewModel = Provider.of<SettingsViewModel>(context, listen: false);
                if (value != _originalMobileNumber) {
                  setState(() {
                    isMobileVerified = false;
                    _verifiedMobileNumber = null;
                  });
                  settingsViewModel.clearError('mobile');
                } else {
                  setState(() {
                    isMobileVerified = true;
                    _verifiedMobileNumber = _originalMobileNumber;
                  });
                  settingsViewModel.clearError('mobile');
                }
              });
            },
          ),
        ),
        const SizedBox(width: 8),
        if (_isEditMode &&
            _mobileNumberController.text != _originalMobileNumber &&
            !isMobileVerified)
          CustomButtons.secondaryButton(
            text: strings.buttonVerify,
            onPressed: verifyMobileNumber,
            height: 40,
            width: 100,
            context: context,
          )
        else if (_isEditMode && isMobileVerified)
          Icon(Icons.check_circle,
              color: Theme.of(context).iconTheme.color, size: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    return Scaffold(
      appBar: CustomAppBar.appBarWithNavigation(
        screenTitle: strings.titleProfile,
        onPressed: () => Navigator.pop(context),
        darkBackground: Theme.of(context).brightness == Brightness.dark,
        context: context,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Consumer<SettingsViewModel>(
        builder: (context, settingsVM, _) {
          if (settingsVM.isLoading) {
            return Center(
                child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor));
          }

          if (settingsVM.currentUser == null) {
            return Center(child: Text(strings.errorLoadProfileFailed));
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomCards.userProfileCard(
                    name: settingsVM.currentUser!.name,
                    userId: settingsVM.currentUser!.id,
                    context: context,
                  ),
                  const SizedBox(height: 20),
                  CustomFormFields.normalSizedTextFormField(
                    context: context,
                    label: strings.labelUsername,
                    controller: _nameController,
                    keyboardType: TextInputType.text,
                    isPassword: false,
                    enabled: _isEditMode,
                    errorText: settingsVM.errors['username'],
                  ),
                  const SizedBox(height: 16),
                  CustomFormFields.normalSizedTextFormField(
                    context: context,
                    label: strings.labelEmail,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    isPassword: false,
                    enabled: _isEditMode,
                    errorText: settingsVM.errors['email'],
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
                    errorText: settingsVM.errors['address'],
                  ),
                  const SizedBox(height: 16),
                  CustomFormFields.normalSizedTextFormField(
                    context: context,
                    label: strings.labelCity,
                    controller: _cityController,
                    keyboardType: TextInputType.text,
                    isPassword: false,
                    enabled: _isEditMode,
                    errorText: settingsVM.errors['city'],
                  ),
                  const SizedBox(height: 16),
                  CustomFormFields.normalSizedTextFormField(
                    context: context,
                    label: strings.labelState,
                    controller: _stateController,
                    keyboardType: TextInputType.text,
                    isPassword: false,
                    enabled: _isEditMode,
                    errorText: settingsVM.errors['state'],
                  ),
                  const SizedBox(height: 30),
                  _buildActionButtons(strings),
                ],
              ),
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
            onPressed: _toggleEditMode,
            height: 50,
            width: MediaQuery.of(context).size.width * 0.4,
            context: context,
          ),
          CustomButtons.primaryButton(
            text: strings.buttonSave,
            onPressed: _confirmUpdate,
            height: 50,
            width: MediaQuery.of(context).size.width * 0.4,
            context: context,
          ),
        ]
            : [
          CustomButtons.primaryButton(
            text: strings.buttonEdit,
            onPressed: _toggleEditMode,
            height: 50,
            width: MediaQuery.of(context).size.width * 0.9,
            context: context,
          ),
        ],
      ),
    );
  }
}