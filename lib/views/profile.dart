import 'package:flutter/material.dart';
import 'package:merchant_app/utils/components/form_field.dart';
import 'package:merchant_app/viewmodels/auth_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:merchant_app/utils/components/button.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  // Controllers for text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load existing user data when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthViewModel>(context, listen: false).fetchUserProfile();
      _loadUserProfile();
    });
  }

  void _loadUserProfile() {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final currentUser = authViewModel.currentUser;

    if (currentUser != null) {
      setState(() {
        _nameController.text = currentUser.username ?? '';
        _emailController.text = currentUser.email ?? '';
        _mobileNumberController.text = currentUser.mobileNumber ?? '';
        _addressController.text = currentUser.address ?? '';
        _cityController.text = currentUser.city ?? '';
        _stateController.text = currentUser.state ?? '';
      });
    }
  }

  void _updateProfile() {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    // Validate fields
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username cannot be empty')), // Changed from Name to Username
      );
      return;
    }

    // Call update profile method
    authViewModel.updateProfile(
      username: _nameController.text, // Note: This might need adjustment in ViewModel
      email: _emailController.text,
      mobileNumber: _mobileNumberController.text,
      address: _addressController.text,
      city: _cityController.text,
      state: _stateController.text,
    ).then((success) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile')),
        );
      }
    });
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
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
          onPressed: () {
            // Add navigation logic if needed
            Navigator.pop(context);
          },
          darkBackground: false
      ),
      backgroundColor: AppColors.lightThemeBackground,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Center(
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.blue[100],
                          child: const Icon(Icons.person, size: 50, color: Colors.blue),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // User Name and Email
                      Consumer<AuthViewModel>(
                        builder: (context, authVM, _) => Column(
                          children: [
                            Text(
                              authVM.currentUser?.username ?? 'Username', // Changed from name to username
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                            Text(
                              authVM.currentUser?.role ?? 'No Role', // Added role display
                              style: const TextStyle(color: Colors.black,fontWeight: FontWeight.w900),
                            ),
                            Text(
                              authVM.currentUser?.id ?? 'UserId',
                              style: const TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Username Field (changed from Name)
                      CustomFormFields.primaryFormField(
                        label: 'Username',
                        controller: _nameController,
                        keyboardType: TextInputType.text,
                        isPassword: false,
                      ),
                      const SizedBox(height: 16),
                      // Email Field
                      CustomFormFields.primaryFormField(
                        label: 'Email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        isPassword: false,
                      ),
                      const SizedBox(height: 16),
                      // Phone Number Field
                      CustomFormFields.primaryFormField(
                        label: 'Mobile Number',
                        controller: _mobileNumberController,
                        keyboardType: TextInputType.phone,
                        isPassword: false,
                      ),
                      const SizedBox(height: 16),
                      // Address Field
                      CustomFormFields.primaryFormField(
                        label: 'Address',
                        controller: _addressController,
                        keyboardType: TextInputType.streetAddress,
                        isPassword: false,
                      ),
                      const SizedBox(height: 16),
                      // City Field
                      CustomFormFields.primaryFormField(
                        label: 'City',
                        controller: _cityController,
                        keyboardType: TextInputType.text,
                        isPassword: false,
                      ),
                      const SizedBox(height: 16),
                      // State Field
                      CustomFormFields.primaryFormField(
                        label: 'State',
                        controller: _stateController,
                        keyboardType: TextInputType.text,
                        isPassword: false,
                      ),
                      const SizedBox(height: 30),
                      // Update Button
                      Consumer<AuthViewModel>(
                        builder: (_, authVM, __) => CustomButtons.primaryButton(
                          text: 'Update',
                          onPressed: authVM.isLoading
                              ? () {}
                              : () => _updateProfile(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}