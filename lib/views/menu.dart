import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/config/app_routes.dart';
import 'package:merchant_app/config/app_theme.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:merchant_app/utils/components/dropdown.dart';
import '../generated/l10n.dart';

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
    final strings = S.of(context);
    developer.log('Building MenuScreen', name: 'MenuScreen');

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: CustomAppBar.appBarWithTitle(
        screenTitle: strings.menuTitle,
        darkBackground: Theme.of(context).brightness == Brightness.dark,
        context: context,
      ),
      body: ListView(
        children: [
          SizedBox(height: 12,),
          _buildDropDown(
            context: context,
            title: strings.menuPlazas,
            icon: Icons.business,
            items: [
              MenuCardItem(
                title: strings.menuRegisterPlaza,
                icon: Icons.add_business,
                onTap: () => _navigate(context, AppRoutes.plazaRegistration),
              ),
              MenuCardItem(
                title: strings.menuModifyViewPlaza,
                icon: Icons.list,
                onTap: () => _navigate(
                  context,
                  AppRoutes.plazaList,
                  arguments: {'modifyPlazaInfo': true},
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildDropDown(
            context: context,
            title: strings.menuUsers,
            icon: Icons.people,
            items: [
              MenuCardItem(
                title: strings.menuRegisterUser,
                icon: Icons.person_add,
                onTap: () => _navigate(context, AppRoutes.userRegistration),
              ),
              MenuCardItem(
                title: strings.menuModifyViewUser,
                icon: Icons.manage_accounts,
                onTap: () => _navigate(context, AppRoutes.userList),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildDropDown(
            context: context,
            title: strings.menuTickets,
            icon: Icons.confirmation_number,
            items: [
              MenuCardItem(
                title: strings.menuOpenTickets,
                icon: Icons.pending_actions,
                onTap: () => _navigate(context, AppRoutes.openTickets),
              ),
              MenuCardItem(
                title: strings.menuNewTicket,
                icon: Icons.add_circle_outline,
                onTap: () => _navigate(context, AppRoutes.newTicket),
              ),
              MenuCardItem(
                title: strings.menuRejectTicket,
                icon: Icons.cancel_outlined,
                onTap: () => _navigate(context, AppRoutes.rejectTicket),
              ),
              MenuCardItem(
                title: strings.menuTicketHistory,
                icon: Icons.history,
                onTap: () => _navigate(context, AppRoutes.ticketHistory),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildDropDown(
            context: context,
            title: strings.menuDisputes,
            icon: Icons.gavel,
            items: [
              MenuCardItem(
                title: strings.menuRaiseDispute,
                icon: Icons.report,
                onTap: () => _showNotImplemented(context, strings.menuRaiseDispute),
              ),
              MenuCardItem(
                title: strings.menuViewDispute,
                icon: Icons.visibility,
                onTap: () => _navigate(
                  context,
                  AppRoutes.disputeList,
                  arguments: {'viewDisputeOptionSelect': true},
                ),
              ),
              MenuCardItem(
                title: strings.menuProcessDispute,
                icon: Icons.build,
                onTap: () => _navigate(
                  context,
                  AppRoutes.disputeList,
                  arguments: {'viewDisputeOptionSelect': false},
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildDropDown(
            context: context,
            title: strings.menuPlazaFare,
            icon: Icons.toll_outlined,
            items: [
              MenuCardItem(
                title: strings.menuAddPlazaFare,
                icon: Icons.price_change,
                onTap: () => _navigate(context, AppRoutes.plazaAddFare),
              ),
              MenuCardItem(
                title: strings.menuModifyViewPlazaFare,
                icon: Icons.edit_note_outlined,
                onTap: () => _navigate(
                  context,
                  AppRoutes.plazaList,
                  arguments: {'modifyPlazaInfo': false},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropDown({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<MenuCardItem> items,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: CustomDropDown.expansionDropDown(
        context: context,
        title: title,
        icon: icon,
        backgroundColor: context.secondaryCardColor,
        items: items,
      ),
    );
  }

  void _navigate(BuildContext context, String routeName, {Object? arguments}) {
    final strings = S.of(context);
    developer.log('Navigating to $routeName with arguments: $arguments', name: 'MenuScreen');
    HapticFeedback.selectionClick();
    Navigator.pushNamed(context, routeName, arguments: arguments).catchError((e) {
      developer.log('Navigation error to $routeName: $e', name: 'MenuScreen', level: 1000);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${strings.errorNavigation}: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });
  }

  void _showNotImplemented(BuildContext context, String feature) {
    developer.log('$feature tapped - not implemented', name: 'MenuScreen');
    HapticFeedback.vibrate();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).messageNotImplemented)),
      );
    }
  }
}