import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/config/app_strings.dart';
import 'package:merchant_app/config/app_routes.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:merchant_app/utils/components/dropdown.dart';
import '../models/menu_item.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightThemeBackground,
      appBar: CustomAppBar.appBarWithTitle(
        screenTitle: AppStrings.menuTitle,
        darkBackground: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          CustomDropDown.expansionDropDown(
            title: AppStrings.menuPlazas,
            icon: Icons.store,
            items: [
              MenuCardItem(
                title: AppStrings.menuViewAllPlazas,
                icon: Icons.list,
                onTap: () => Navigator.pushNamed(context, AppRoutes.plazaList),
              ),
              MenuCardItem(
                title: AppStrings.menuAddNewPlaza,
                icon: Icons.add_circle,
                onTap: () {
                  // Add plaza navigation logic
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          CustomDropDown.expansionDropDown(
            title: AppStrings.menuUsers,
            icon: Icons.people,
            items: [
              MenuCardItem(
                title: AppStrings.menuRegisterUser,
                icon: Icons.person_add,
                onTap: () => Navigator.pushNamed(context, AppRoutes.userRegistration),
              ),
              MenuCardItem(
                title: AppStrings.menuModifyViewUser,
                icon: Icons.manage_accounts,
                onTap: () => Navigator.pushNamed(context, AppRoutes.userList),
              ),
            ],
          ),
          const SizedBox(height: 8),
          CustomDropDown.expansionDropDown(
            title: AppStrings.menuDisputes,
            icon: Icons.warning_rounded,
            items: [
              MenuCardItem(
                title: AppStrings.menuViewAllDisputes,
                icon: Icons.list_alt,
                onTap: () {
                  // Add operator navigation logic
                },
              ),
              MenuCardItem(
                title: AppStrings.menuManualEntry,
                icon: Icons.camera_alt,
                onTap: () {
                  // Manage operators navigation logic
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          CustomDropDown.expansionDropDown(
            title: AppStrings.menuSettings,
            icon: Icons.settings,
            items: [
              MenuCardItem(
                title: AppStrings.menuResetPassword,
                icon: Icons.password,
                onTap: () {
                  // Add operator navigation logic
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}