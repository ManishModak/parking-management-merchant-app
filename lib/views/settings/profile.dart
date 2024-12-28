import 'package:flutter/material.dart';
import 'package:merchant_app/utils/components/card.dart';
import 'package:merchant_app/utils/components/form_field.dart';
import 'package:provider/provider.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/utils/components/appbar.dart';

import '../../services/secure_storage_service.dart';
import '../../viewmodels/user_viewmodel.dart';

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

  // Store original values for cancellation
  Map<String, String> _originalValues = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfileData();
    });
  }

  Future<void> _loadProfileData() async {
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    final userId = await SecureStorageService().getUserId();
    await userViewModel.fetchUser(userId: userId!, isCurrentAppUser: true);
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

        // Store original values
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
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username cannot be empty')),
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
      isCurrentAppUser: true
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      setState(() {
        _isEditMode = false;
        _storeOriginalValues();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile')),
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
    return Scaffold(
      appBar: CustomAppBar.appBarWithNavigation(
        screenTitle: 'Profile',
        onPressed: () => Navigator.pop(context),
        darkBackground: false,
      ),
      backgroundColor: AppColors.lightThemeBackground,
      floatingActionButton: _buildFloatingActionButtons(),
      body: Consumer<UserViewModel>(
        builder: (context, userVM, _) {
          if (userVM.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (userVM.currentUser == null) {
            return const Center(child: Text('Failed to load profile data'));
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          CustomCards.userProfileCard(name: userVM.currentOperator!.name, userId: userVM.currentOperator!.id),
                          const SizedBox(height: 20),
                          CustomFormFields.primaryFormField(
                            label: 'Username',
                            controller: _nameController,
                            keyboardType: TextInputType.text,
                            isPassword: false,
                            enabled: _isEditMode,
                          ),
                          const SizedBox(height: 16),
                          CustomFormFields.primaryFormField(
                            label: 'Email',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            isPassword: false,
                            enabled: _isEditMode,
                          ),
                          const SizedBox(height: 16),
                          CustomFormFields.primaryFormField(
                            label: 'Mobile Number',
                            controller: _mobileNumberController,
                            keyboardType: TextInputType.phone,
                            isPassword: false,
                            enabled: _isEditMode,
                          ),
                          const SizedBox(height: 16),
                          CustomFormFields.primaryFormField(
                            label: 'Address',
                            controller: _addressController,
                            keyboardType: TextInputType.streetAddress,
                            isPassword: false,
                            enabled: _isEditMode,
                          ),
                          const SizedBox(height: 16),
                          CustomFormFields.primaryFormField(
                            label: 'City',
                            controller: _cityController,
                            keyboardType: TextInputType.text,
                            isPassword: false,
                            enabled: _isEditMode,
                          ),
                          const SizedBox(height: 16),
                          CustomFormFields.primaryFormField(
                            label: 'State',
                            controller: _stateController,
                            keyboardType: TextInputType.text,
                            isPassword: false,
                            enabled: _isEditMode,
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFloatingActionButtons() {
    if (!_isEditMode) {
      return FloatingActionButton(
        onPressed: _toggleEditMode,
        child: const Icon(Icons.edit),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          onPressed: _toggleEditMode,
          backgroundColor: Colors.red,
          child: const Icon(Icons.close),
        ),
        const SizedBox(width: 16),
        FloatingActionButton(
          onPressed: _confirmUpdate,
          backgroundColor: Colors.green,
          child: const Icon(Icons.check),
        ),
      ],
    );
  }
}