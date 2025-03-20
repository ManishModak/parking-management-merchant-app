import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../config/app_theme.dart';
import '../../services/storage/secure_storage_service.dart';
import '../../utils/components/appbar.dart';
import '../../utils/components/button.dart';
import '../../utils/components/card.dart';
import '../../utils/components/form_field.dart';
import '../../viewmodels/user_viewmodel.dart';
import '../../generated/l10n.dart';

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

  Map<String, String> _originalValues = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfileData();
    });
  }

  Future<void> _loadProfileData() async {
    final strings = S.of(context);
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    final userId = await SecureStorageService().getUserId();
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.errorUserIdNotFound, style: TextStyle(color: context.textPrimaryColor)),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    await userViewModel.fetchUser(userId: userId, isCurrentAppUser: true);
    if (mounted) {
      await _loadUserProfile();
    }
  }

  Future<void> _loadUserProfile() async {
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    final currentUser = userViewModel.currentUser;

    if (currentUser != null && mounted) {
      setState(() {
        _nameController.text = currentUser.name;
        _emailController.text = currentUser.email;
        _mobileNumberController.text = currentUser.mobileNumber;
        _addressController.text = currentUser.address ?? '';
        _cityController.text = currentUser.city ?? '';
        _stateController.text = currentUser.state ?? '';
        _storeOriginalValues();
      });
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

  Future<void> _confirmUpdate() async {
    final strings = S.of(context);
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.errorUsernameRequired, style: TextStyle(color: context.textPrimaryColor)),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    final success = await userViewModel.updateUser(
      username: _nameController.text,
      email: _emailController.text,
      mobileNumber: _mobileNumberController.text,
      address: _addressController.text,
      city: _cityController.text,
      state: _stateController.text,
      isCurrentAppUser: true,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.successProfileUpdate, style: TextStyle(color: context.textPrimaryColor)),
          backgroundColor: AppColors.success,
        ),
      );
      setState(() {
        _isEditMode = false;
        _storeOriginalValues();
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
      body: Consumer<UserViewModel>(
        builder: (context, userVM, _) {
          if (userVM.isLoading) {
            return Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor));
          }

          if (userVM.currentUser == null) {
            return Center(child: Text(strings.errorLoadProfileFailed));
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomCards.userProfileCard(
                    name: userVM.currentUser!.name,
                    userId: userVM.currentUser!.id,
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
                  ),
                  const SizedBox(height: 16),
                  CustomFormFields.normalSizedTextFormField(
                    context: context,
                    label: strings.labelEmail,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    isPassword: false,
                    enabled: _isEditMode,
                  ),
                  const SizedBox(height: 16),
                  CustomFormFields.normalSizedTextFormField(
                    context: context,
                    label: strings.labelMobileNumber,
                    controller: _mobileNumberController,
                    keyboardType: TextInputType.phone,
                    isPassword: false,
                    enabled: _isEditMode,
                  ),
                  const SizedBox(height: 16),
                  CustomFormFields.normalSizedTextFormField(
                    context: context,
                    label: strings.labelAddress,
                    controller: _addressController,
                    keyboardType: TextInputType.streetAddress,
                    isPassword: false,
                    enabled: _isEditMode,
                  ),
                  const SizedBox(height: 16),
                  CustomFormFields.normalSizedTextFormField(
                    context: context,
                    label: strings.labelCity,
                    controller: _cityController,
                    keyboardType: TextInputType.text,
                    isPassword: false,
                    enabled: _isEditMode,
                  ),
                  const SizedBox(height: 16),
                  CustomFormFields.normalSizedTextFormField(
                    context: context,
                    label: strings.labelState,
                    controller: _stateController,
                    keyboardType: TextInputType.text,
                    isPassword: false,
                    enabled: _isEditMode,
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