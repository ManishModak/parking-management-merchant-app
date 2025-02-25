import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/config/app_strings.dart';
import 'package:merchant_app/config/app_routes.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:merchant_app/utils/components/dropdown.dart';

class MenuCardItem {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  const MenuCardItem({
    required this.title,
    required this.icon,
    this.onTap,
  });
}

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
        children: [
          const SizedBox(height: 16),
          CustomDropDown.expansionDropDown(
            title: AppStrings.menuPlazas,
            icon: Icons.business,
            items: [
              MenuCardItem(
                title: AppStrings.menuRegisterPlaza,
                icon: Icons.add_business,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.plazaRegistration);
                },
              ),
              MenuCardItem(
                title: AppStrings.menuModifyViewPlaza,
                icon: Icons.list,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.plazaList,
                    arguments: {'modifyPlazaInfo': true},
                  );
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
            title: AppStrings.menuTickets,
            icon: Icons.confirmation_number,
            items: [
              MenuCardItem(
                title: AppStrings.menuOpenTickets,
                icon: Icons.pending_actions,
                onTap: () => Navigator.pushNamed(context, AppRoutes.openTickets),
              ),
              MenuCardItem(
                title: AppStrings.menuNewTicket,
                icon: Icons.add_circle_outline,
                onTap: () => Navigator.pushNamed(context, AppRoutes.newTicket),
              ),
              MenuCardItem(
                title: AppStrings.menuRejectTicket,
                icon: Icons.cancel_outlined,
                onTap: () => Navigator.pushNamed(context, AppRoutes.rejectTicket),
              ),
              MenuCardItem(
                title: AppStrings.menuTicketHistory,
                icon: Icons.history,
                onTap: () => Navigator.pushNamed(context, AppRoutes.ticketHistory),
              ),
              MenuCardItem(
                title: AppStrings.menuMarkExit,
                icon: Icons.exit_to_app,
                onTap: () => Navigator.pushNamed(context, AppRoutes.markExit),
              ),
            ],
          ),
          const SizedBox(height: 8),
          CustomDropDown.expansionDropDown(
            title: AppStrings.menuDisputes,
            icon: Icons.gavel,
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
                icon: Icons.edit_document,
                onTap: () {
                  // Manage operators navigation logic
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          CustomDropDown.expansionDropDown(
            title: AppStrings.menuPlazaFare,
            icon: Icons.toll_outlined,
            items: [
              MenuCardItem(
                title: AppStrings.menuAddPlazaFare,
                icon: Icons.price_change,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.plazaAddFare);
                },
              ),
              MenuCardItem(
                title: AppStrings.menuModifyViewPlazaFare,
                icon: Icons.edit_note_outlined,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.plazaList,
                    arguments: {'modifyPlazaInfo': false},
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}