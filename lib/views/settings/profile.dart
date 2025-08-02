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
import 'package:merchant_app/generated/l10n.dart'; // Ensure this is correctly generated
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
  String?
      _verifiedMobileNumber; // Stores the mobile number that was last verified
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
    // Ensure S.of(context) is available or handle context appropriately
    // For initState, it's better to get strings once context is surely available,
    // like at the start of methods called after initState or in build method.
    // However, S.of(context) in methods called by user interaction (like this one if called later) is fine.
    final strings = S.of(context);
    final settingsViewModel =
        Provider.of<SettingsViewModel>(context, listen: false);
    settingsViewModel.clearErrors();
    final userId = await SecureStorageService().getUserId();
    if (userId == null) {
      if (!mounted) return;
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
      _populateControllersFromViewModel();
      if (settingsViewModel.currentUser == null &&
          settingsViewModel.errors.containsKey('general')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                settingsViewModel.errors['general'] ??
                    strings.errorLoadProfileFailed,
                style: TextStyle(color: context.textPrimaryColor)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _populateControllersFromViewModel() {
    final settingsViewModel =
        Provider.of<SettingsViewModel>(context, listen: false);
    final currentUser = settingsViewModel.currentUser;

    if (currentUser != null) {
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
        'Loaded user profile into controllers: id=${currentUser.id}, name=${currentUser.name}',
        name: 'UserProfileScreen',
      );
    } else {
      developer.log('No user profile data to load into controllers',
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
    final settingsViewModel =
        Provider.of<SettingsViewModel>(context, listen: false);
    settingsViewModel.clearErrors();
    setState(() {
      _nameController.text = _originalValues['username'] ?? '';
      _emailController.text = _originalValues['email'] ?? '';
      _mobileNumberController.text = _originalValues['mobileNumber'] ?? '';
      _addressController.text = _originalValues['address'] ?? '';
      _cityController.text = _originalValues['city'] ?? '';
      _stateController.text = _originalValues['state'] ?? '';
      if (_mobileNumberController.text == _originalMobileNumber) {
        isMobileVerified = true;
        _verifiedMobileNumber = _originalMobileNumber;
      } else {
        isMobileVerified = false;
        _verifiedMobileNumber = null;
      }
    });
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
      if (!_isEditMode) {
        _restoreOriginalValues();
      } else {
        _storeOriginalValues();
        _originalMobileNumber = _mobileNumberController.text;
        isMobileVerified = true;
        _verifiedMobileNumber = _mobileNumberController.text;
      }
    });
  }

  Future<void> verifyMobileNumber() async {
    final strings = S.of(context);
    final settingsViewModel =
        Provider.of<SettingsViewModel>(context, listen: false);
    final mobile = _mobileNumberController.text;

    if (mobile.isEmpty || !RegExp(r'^\d{10}$').hasMatch(mobile)) {
      settingsViewModel.setError('mobile', strings.errorInvalidMobile);
      developer.log('Invalid mobile number format: $mobile',
          name: 'UserProfileScreen');
      return;
    }
    if (mobile == _originalMobileNumber) {
      setState(() {
        isMobileVerified = true;
        _verifiedMobileNumber = mobile;
      });
      settingsViewModel.clearError('mobile');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(strings.successMobileRestored,
              style: TextStyle(color: context.textPrimaryColor)),
          backgroundColor: AppColors.success,
        ));
      }
      return;
    }

    settingsViewModel.clearError('mobile');

    try {
      final verificationService = VerificationService();
      await verificationService.sendOtp(mobile);
      developer.log('OTP sent successfully to $mobile',
          name: 'UserProfileScreen');

      if (!mounted) return;
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
        settingsViewModel.clearError('mobile');
        developer.log('Mobile number verified: $mobile',
            name: 'UserProfileScreen');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(strings.successMobileVerification,
              style: TextStyle(color: context.textPrimaryColor)),
          backgroundColor: AppColors.success,
        ));
      } else {
        settingsViewModel.setError('mobile', strings.errorVerificationFailed);
        setState(() {
          isMobileVerified = false;
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
      developer.log('Mobile number in use by another account: $mobile',
          name: 'UserProfileScreen', error: e);
    } catch (e) {
      if (!mounted) return;
      settingsViewModel.setError('mobile', strings.errorOtpSendFailed);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${strings.errorOtpSendFailed}: ${e.toString()}',
            style: TextStyle(color: context.textPrimaryColor),
          ),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 4),
        ),
      );
      developer.log('Error sending OTP or during verification process: $e',
          name: 'UserProfileScreen', error: e);
    }
  }

  Future<void> _confirmUpdate() async {
    final strings = S.of(context);
    final settingsViewModel =
        Provider.of<SettingsViewModel>(context, listen: false);
    final userId = await SecureStorageService().getUserId();

    if (userId == null) {
      if (!mounted) return;
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

    final currentMobile = _mobileNumberController.text;
    final bool mobileChanged = currentMobile != _originalMobileNumber;

    final validationErrors = settingsViewModel.validateUpdate(
      username: _nameController.text,
      email: _emailController.text.toLowerCase(),
      mobile: currentMobile,
      address: _addressController.text,
      city: _cityController.text,
      state: _stateController.text,
      role: null,
      subEntity: null,
      isMobileVerified: !mobileChanged ||
          (mobileChanged &&
              isMobileVerified &&
              currentMobile == _verifiedMobileNumber),
      originalMobile: _originalMobileNumber,
      isProfile: true,
    );

    if (validationErrors.isNotEmpty) {
      validationErrors
          .forEach((key, value) => settingsViewModel.setError(key, value));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: validationErrors.values
                  .map((e) => Text('• $e',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: context.textPrimaryColor)))
                  .toList(),
            ),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      return;
    }
    settingsViewModel.clearErrors();

    final success = await settingsViewModel.updateUser(
      userId: userId,
      username: _nameController.text,
      email: _emailController.text.toLowerCase(),
      mobileNumber: currentMobile,
      address: _addressController.text,
      city: _cityController.text,
      state: _stateController.text,
      isCurrentAppUser: true,
    );

    if (!mounted) return;

    if (success) {
      _populateControllersFromViewModel();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.successProfileUpdate,
              style: TextStyle(color: context.textPrimaryColor)),
          backgroundColor: AppColors.success,
        ),
      );
      setState(() {
        _isEditMode = false;
      });
    } else {
      final emailError = settingsViewModel.errors['email'];
      final generalError = settingsViewModel.errors['general'];
      final mobileError = settingsViewModel.errors['mobile'];

      String displayMessage;
      if (emailError != null && emailError.isNotEmpty) {
        displayMessage = "${strings.errorEmailInUse} ($emailError)";
      } else if (mobileError != null && mobileError.isNotEmpty) {
        displayMessage = mobileError;
        if (!mobileError.toLowerCase().contains("mobile")) {
          // Be more specific if error isn't self-descriptive
          displayMessage = "${strings.labelMobileNumber}: $mobileError";
        }
      } else if (generalError != null && generalError.isNotEmpty) {
        displayMessage = generalError;
      } else {
        displayMessage = strings.errorUpdateFailed;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(displayMessage,
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

  Widget _buildMobileNumberField(S strings, SettingsViewModel settingsVM) {
    final bool mobileChangedFromOriginal =
        _mobileNumberController.text != _originalMobileNumber;
    final bool effectiveIsMobileVerified = !mobileChangedFromOriginal ||
        (mobileChangedFromOriginal &&
            isMobileVerified &&
            _mobileNumberController.text == _verifiedMobileNumber);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: CustomFormFields.normalSizedTextFormField(
            context: context,
            label: strings.labelMobileNumber,
            controller: _mobileNumberController,
            keyboardType: TextInputType.phone,
            isPassword: false,
            enabled: _isEditMode,
            errorText: settingsVM.errors['mobile'],
            onChanged: (value) {
              if (_debounce?.isActive ?? false) _debounce!.cancel();
              _debounce = Timer(const Duration(milliseconds: 300), () {
                final newMobile = _mobileNumberController.text;
                final oldMobileAtEditStart = _originalMobileNumber;
                settingsVM.clearError('mobile');

                if (newMobile == oldMobileAtEditStart) {
                  if (isMobileVerified != true ||
                      _verifiedMobileNumber != newMobile) {
                    setState(() {
                      isMobileVerified = true;
                      _verifiedMobileNumber = newMobile;
                    });
                  }
                } else {
                  if (newMobile == _verifiedMobileNumber) {
                    // If they re-type an already verified (new) number
                    if (isMobileVerified != true) {
                      setState(() {
                        isMobileVerified = true;
                      });
                    }
                  } else {
                    // Number is new and not the same as the last OTP-verified one
                    if (isMobileVerified != false) {
                      setState(() {
                        isMobileVerified = false;
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
          if (mobileChangedFromOriginal && !effectiveIsMobileVerified)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: CustomButtons.secondaryButton(
                text: strings.buttonVerify,
                onPressed:
                    verifyMobileNumber, // Assuming verifyMobileNumber is VoidCallback
                height: 40,
                width: 90, // Ensure width is enough
                context: context,
              ),
            )
          else if (effectiveIsMobileVerified)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child:
                  Icon(Icons.check_circle, color: AppColors.success, size: 24),
            ),
        ]
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final settingsVM = Provider.of<SettingsViewModel>(context);

    return Scaffold(
      appBar: CustomAppBar.appBarWithNavigation(
        screenTitle: strings.titleProfile,
        onPressed: () => Navigator.pop(context),
        darkBackground: Theme.of(context).brightness == Brightness.dark,
        context: context,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Builder(
        builder: (BuildContext scaffoldContext) {
          if (settingsVM.isLoading && settingsVM.currentUser == null) {
            return Center(
                child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor));
          }

          if (settingsVM.currentUser == null) {
            return Center(
                child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                  settingsVM.errors['general'] ??
                      strings.errorLoadProfileFailed,
                  textAlign: TextAlign.center),
            ));
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomCards.userProfileCard(
                    name: _nameController.text,
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
                    onChanged: _isEditMode
                        ? (_) => settingsVM.clearError('username')
                        : null,
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
                    onChanged: _isEditMode
                        ? (_) => settingsVM.clearError('email')
                        : null,
                  ),
                  const SizedBox(height: 16),
                  _buildMobileNumberField(strings, settingsVM),
                  const SizedBox(height: 16),
                  CustomFormFields.normalSizedTextFormField(
                    context: context,
                    label: strings.labelAddress,
                    controller: _addressController,
                    keyboardType: TextInputType.streetAddress,
                    isPassword: false,
                    enabled: _isEditMode,
                    errorText: settingsVM.errors['address'],
                    onChanged: _isEditMode
                        ? (_) => settingsVM.clearError('address')
                        : null,
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
                    onChanged: _isEditMode
                        ? (_) => settingsVM.clearError('city')
                        : null,
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
                    onChanged: _isEditMode
                        ? (_) => settingsVM.clearError('state')
                        : null,
                  ),
                  const SizedBox(height: 30),
                  _buildActionButtons(strings, settingsVM.isLoading),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButtons(S strings, bool isLoading) {
    // WORKAROUND: If CustomButton.onPressed is strictly VoidCallback (non-nullable)
    // and CustomButton has no 'enabled' property, this passes an empty function
    // when isLoading is true. This makes the button do nothing but it might still
    // appear enabled.
    // THE PREFERRED FIX: Modify CustomButton to accept VoidCallback? onPressed
    // OR ensure CustomButton has an 'enabled: bool' property.
    final VoidCallback onPressedSave = isLoading ? () {} : _confirmUpdate;
    final VoidCallback onPressedEdit = isLoading ? () {} : _toggleEditMode;
    final VoidCallback onPressedCancel = isLoading ? () {} : _toggleEditMode;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _isEditMode
            ? [
                CustomButtons.secondaryButton(
                  text: strings.buttonCancel,
                  onPressed: onPressedCancel,
                  height: 50,
                  width: MediaQuery.of(context).size.width * 0.4,
                  context: context,
                ),
                CustomButtons.primaryButton(
                  text: strings.buttonSave,
                  onPressed: onPressedSave,
                  height: 50,
                  width: MediaQuery.of(context).size.width * 0.4,
                  context: context,
                ),
              ]
            : [
                CustomButtons.primaryButton(
                  text: strings.buttonEdit,
                  onPressed: onPressedEdit,
                  height: 50,
                  width: MediaQuery.of(context).size.width * 0.9,
                  context: context,
                ),
              ],
      ),
    );
  }
}
