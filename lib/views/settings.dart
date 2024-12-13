import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/config/app_routes.dart';
import 'package:merchant_app/utils/components/appbar.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  _AccountSettingsScreenState createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  bool isFaceIDEnabled = false; // State variable to control the switch

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightThemeBackground,
      appBar: CustomAppBar.appBarWithTitle(
        screenTitle: "Account Settings",
        darkBackground: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildSettingsItem(
                      icon: Icons.person_outline,
                      title: 'My Account',
                      subtitle: 'Make changes to your account',
                      onTap: () { Navigator.pushNamed(context, AppRoutes.userProfile); },
                  ),
                  _buildSettingsItem(
                    icon: Icons.lock_outline,
                    title: 'Face ID / Touch ID',
                    subtitle: 'Manage your device security',
                    trailingIcon: Switch(
                      activeColor: AppColors.primary,
                      value: isFaceIDEnabled,
                      onChanged: (value) {
                        setState(() {
                          isFaceIDEnabled = value;
                        });
                      },
                    ),
                  ),
                  _buildSettingsItem(
                    icon: Icons.exit_to_app_outlined,
                    title: 'Log out',
                    subtitle: 'Further secure your account for safety',
                    onTap: _showLogoutConfirmationDialog,
                  ),
                  const SizedBox(height: 24),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'More',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSettingsItem(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                  ),
                  _buildSettingsItem(
                    icon: Icons.info_outline,
                    title: 'About App',
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          // You can add a custom navigation bar or footer here if needed.
        ],
      ),
    );
  }

  // Helper method to build each setting item
  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailingIcon,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: CircleAvatar(
        backgroundColor: AppColors.primary.withOpacity(0.1),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            )
          : null,
      trailing: trailingIcon ??
          const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
      onTap: onTap,
    );
  }

  // Method to show a logout confirmation dialog
  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Log out"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Close dialog
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              // Add your logout logic here
            },
            child: const Text("Log out"),
          ),
        ],
      ),
    );
  }
}
