import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/config/app_routes.dart';
import 'package:merchant_app/config/app_theme.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:merchant_app/utils/components/dropdown.dart';
import '../generated/l10n.dart';
import '../services/storage/secure_storage_service.dart';

class MenuCardItem {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  final List<String> allowedRoles;

  const MenuCardItem({
    required this.title,
    required this.icon,
    this.onTap,
    required this.allowedRoles,
  });
}

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final ScrollController _scrollController = ScrollController();
  final Future<String?> _userRoleFuture = SecureStorageService().getUserRole();

  // Updated access rules for ticket-related actions based on provided permissions
  static const Map<String, List<String>> _accessRules = {
    'registerPlaza': ['Plaza Owner'],
    'modifyViewPlaza': ['Plaza Owner'],
    'registerUser': ['Plaza Owner', 'Plaza Admin'],
    'modifyViewUser': ['Plaza Owner', 'Plaza Admin'],
    'openTickets': [
      'Plaza Owner',
      'Centralized Controller',
      'Plaza Admin',
      'Plaza Operator'
    ],
    'newTicket': ['Plaza Owner', 'Plaza Admin', 'Plaza Operator'],
    //'rejectTicket': ['Plaza Owner', 'Plaza Admin', 'Plaza Operator'],
    'ticketHistory': [
      'Plaza Owner',
      'Centralized Controller',
      'Plaza Admin',
      'Plaza Operator'
    ],
    'raiseDispute': ['Plaza Owner', 'Plaza Admin'],
    'viewDispute': [
      'Plaza Owner',
      'Centralized Controller',
      'Plaza Admin',
      'Plaza Operator'
    ],
    'processDispute': ['Plaza Owner', 'Centralized Controller', 'Plaza Admin'],
    'addPlazaFare': ['Plaza Owner'],
    'modifyViewPlazaFare': ['Plaza Owner'],
  };

  @override
  void initState() {
    super.initState();
    developer.log('initState called for MenuScreen', name: 'Lifecycle');
    _scrollController.addListener(() {
      developer.log('Scroll position: ${_scrollController.offset}',
          name: 'MenuScreen');
    });
  }

  @override
  void dispose() {
    developer.log('dispose called for MenuScreen', name: 'Lifecycle');
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    developer.log('Building MenuScreen', name: 'MenuScreen');

    return FutureBuilder<String?>(
      future: _userRoleFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          developer.log('Error in FutureBuilder: ${snapshot.error}',
              name: 'MenuScreen', error: snapshot.error);
          return Scaffold(
            body: Center(child: Text(strings.errorLoadingRole)),
          );
        }

        final userRole = snapshot.data ?? '';
        developer.log('User role: $userRole', name: 'MenuScreen');

        return Scaffold(
          backgroundColor: context.backgroundColor,
          appBar: CustomAppBar.appBarWithTitle(
            screenTitle: strings.menuTitle,
            darkBackground: Theme.of(context).brightness == Brightness.dark,
            context: context,
          ),
          body: Builder(
            builder: (BuildContext context) {
              try {
                return ListView(
                  key: const ValueKey('menu_listview'),
                  controller: _scrollController,
                  primary: false,
                  children: [
                    const SizedBox(height: 12),
                    _buildDropDown(
                      context: context,
                      title: strings.menuUsers,
                      icon: Icons.people,
                      items: [
                        MenuCardItem(
                          title: strings.menuRegisterUser,
                          icon: Icons.person_add,
                          allowedRoles: _accessRules['registerUser']!,
                          onTap: () => _handleNavigation(
                            context,
                            AppRoutes.userRegistration,
                            userRole,
                            'registerUser',
                          ),
                        ),
                        MenuCardItem(
                          title: strings.menuModifyViewUser,
                          icon: Icons.manage_accounts,
                          allowedRoles: _accessRules['modifyViewUser']!,
                          onTap: () => _handleNavigation(
                            context,
                            AppRoutes.userList,
                            userRole,
                            'modifyViewUser',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildDropDown(
                      context: context,
                      title: strings.menuPlazas,
                      icon: Icons.business,
                      items: [
                        MenuCardItem(
                          title: strings.menuRegisterPlaza,
                          icon: Icons.add_business,
                          allowedRoles: _accessRules['registerPlaza']!,
                          onTap: () => _handleNavigation(
                            context,
                            AppRoutes.plazaRegistration,
                            userRole,
                            'registerPlaza',
                          ),
                        ),
                        MenuCardItem(
                          title: strings.menuModifyViewPlaza,
                          icon: Icons.list,
                          allowedRoles: _accessRules['modifyViewPlaza']!,
                          onTap: () => _handleNavigation(
                            context,
                            AppRoutes.plazaList,
                            userRole,
                            'modifyViewPlaza',
                            arguments: {'modifyPlazaInfo': true},
                          ),
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
                          allowedRoles: _accessRules['openTickets']!,
                          onTap: () => _handleNavigation(
                            context,
                            AppRoutes.openTickets,
                            userRole,
                            'openTickets',
                          ),
                        ),
                        MenuCardItem(
                          title: strings.menuNewTicket,
                          icon: Icons.add_circle_outline,
                          allowedRoles: _accessRules['newTicket']!,
                          onTap: () => _handleNavigation(
                            context,
                            AppRoutes.newTicket,
                            userRole,
                            'newTicket',
                          ),
                        ),
                        // MenuCardItem(
                        //   title: strings.menuRejectTicket,
                        //   icon: Icons.cancel_outlined,
                        //   allowedRoles: _accessRules['rejectTicket']!,
                        //   onTap: () => _handleNavigation(
                        //     context,
                        //     AppRoutes.rejectTicket,
                        //     userRole,
                        //     'rejectTicket',
                        //   ),
                        // ),
                        MenuCardItem(
                          title: strings.menuTicketHistory,
                          icon: Icons.history,
                          allowedRoles: _accessRules['ticketHistory']!,
                          onTap: () => _handleNavigation(
                            context,
                            AppRoutes.ticketHistory,
                            userRole,
                            'ticketHistory',
                          ),
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
                          allowedRoles: _accessRules['raiseDispute']!,
                          onTap: () {
                            developer.log(
                                'Raise Dispute tapped, navigating to ticketHistory with filters',
                                name: 'MenuScreen');
                            _handleNavigation(
                              context,
                              AppRoutes.ticketHistory,
                              userRole,
                              'raiseDispute',
                              arguments: {
                                'statusFilter': 'complete',
                                'disputeStatusFilter': 'not raised',
                              },
                            );
                          },
                        ),
                        MenuCardItem(
                          title: strings.menuViewDispute,
                          icon: Icons.visibility,
                          allowedRoles: _accessRules['viewDispute']!,
                          onTap: () => _handleNavigation(
                            context,
                            AppRoutes.disputeList,
                            userRole,
                            'viewDispute',
                            arguments: {'viewDisputeOptionSelect': true},
                          ),
                        ),
                        MenuCardItem(
                          title: strings.menuProcessDispute,
                          icon: Icons.build,
                          allowedRoles: _accessRules['processDispute']!,
                          onTap: () => _handleNavigation(
                            context,
                            AppRoutes.disputeList,
                            userRole,
                            'processDispute',
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
                          allowedRoles: _accessRules['addPlazaFare']!,
                          onTap: () => _handleNavigation(
                            context,
                            AppRoutes.plazaAddFare,
                            userRole,
                            'addPlazaFare',
                          ),
                        ),
                        MenuCardItem(
                          title: strings.menuModifyViewPlazaFare,
                          icon: Icons.edit_note_outlined,
                          allowedRoles: _accessRules['modifyViewPlazaFare']!,
                          onTap: () => _handleNavigation(
                            context,
                            AppRoutes.plazaList,
                            userRole,
                            'modifyViewPlazaFare',
                            arguments: {'modifyPlazaInfo': false},
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              } catch (e, stackTrace) {
                developer.log('Error building ListView: $e',
                    name: 'MenuScreen', error: e, stackTrace: stackTrace);
                return Center(child: Text(strings.errorRenderingMenu));
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildDropDown({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<MenuCardItem> items,
  }) {
    try {
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
    } catch (e, stackTrace) {
      developer.log('Error building dropdown: $e',
          name: 'MenuScreen', error: e, stackTrace: stackTrace);
      return const SizedBox.shrink();
    }
  }

  void _handleNavigation(
    BuildContext context,
    String routeName,
    String userRole,
    String action, {
    Object? arguments,
  }) {
    final strings = S.of(context);
    if (!_accessRules[action]!.contains(userRole)) {
      developer.log('Access denied for $action by role: $userRole',
          name: 'MenuScreen');
      HapticFeedback.vibrate();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.accessDenied),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    developer.log('Navigating to $routeName with arguments: $arguments',
        name: 'MenuScreen');
    HapticFeedback.selectionClick();
    Navigator.pushNamed(context, routeName, arguments: arguments)
        .catchError((e) {
      developer.log('Navigation error to $routeName: $e',
          name: 'MenuScreen', level: 1000);
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
}
