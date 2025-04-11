import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:merchant_app/config/app_theme.dart';
import 'package:merchant_app/views/settings.dart';
import 'package:merchant_app/views/transaction.dart';
import 'package:provider/provider.dart';
import '../../generated/l10n.dart';
import '../services/storage/secure_storage_service.dart';
import '../utils/components/navigationbar.dart';
import '../viewmodels/user_viewmodel.dart';
import '../config/app_colors.dart';
import '../config/app_routes.dart';
import 'dashboard.dart';
import 'menu.dart';
import 'notification.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _secureStorage = SecureStorageService();
  int _selectedIndex = 0;
  bool _isLoadingProfile = false;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    developer.log('Initializing HomeScreen', name: 'HomeScreen');

    _screens = [
      const DashboardScreen(key: PageStorageKey('dashboard')),
      const MenuScreen(key: PageStorageKey('menu')),
      const NotificationsScreenWrapper(key: PageStorageKey('notifications')),
      const AccountSettingsScreen(key: PageStorageKey('settings')),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthentication();
      _loadProfileData();
    });
  }

  void _onItemTapped(int index) {
    developer.log('Navigation bar item tapped: $index, switching to ${_screens[index].runtimeType}', name: 'HomeScreen');
    HapticFeedback.selectionClick();
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _checkAuthentication() async {
    try {
      final strings = S.of(context);
      String? token = await _secureStorage.getAuthToken();
      developer.log("Authentication token ${token != null ? 'exists' : 'missing'}", name: 'HomeScreen');

      if (token == null) {
        developer.log('No auth token found, redirecting to welcome', name: 'HomeScreen', level: 900);
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.welcome,
                (route) => false,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(strings.errorUnauthorized),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      String? ownerId = await _secureStorage.getUserId();
      developer.log("Owner ID: ${ownerId ?? 'not found'}", name: 'HomeScreen');
    } catch (e) {
      developer.log("Error checking authentication: $e", name: 'HomeScreen', level: 1000);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${S.of(context).errorGeneric}: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _loadProfileData() async {
    final strings = S.of(context);
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    developer.log('Loading profile data', name: 'HomeScreen');

    try {
      final userId = await _secureStorage.getUserId();
      if (userId == null) {
        developer.log('User ID not found', name: 'HomeScreen', level: 900);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(strings.errorUserIdNotFound),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      // Use the new method to fetch and store the logged-in user's data
      await userViewModel.fetchAndStoreCurrentUser(
        userId: userId,
        forceApiCall: true, // Force API call to get the latest data
      );
      developer.log('User profile fetched and stored successfully for ID: $userId', name: 'HomeScreen');

      if (userViewModel.currentUser == null) {
        developer.log('No user data returned from fetchAndStoreCurrentUser', name: 'HomeScreen', level: 900);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(strings.errorLoadingUserProfile),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      developer.log("Error fetching user data: $e", name: 'HomeScreen', level: 1000);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings.errorLoadingUserProfile),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingProfile = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: Stack(
        children: [
          ..._screens.asMap().entries.map((entry) {
            final index = entry.key;
            final screen = entry.value;
            return Offstage(
              offstage: _selectedIndex != index,
              child: TickerMode(
                enabled: _selectedIndex == index,
                child: screen,
              ),
            );
          }),
          if (_isLoadingProfile)
            Container(
              color: context.shadowColor.withOpacity(0.5),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 16),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 500),
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: context.textPrimaryColor.withOpacity(_isLoadingProfile ? 1.0 : 0.7),
                      ),
                      child: Text(strings.labelLoading),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: CustomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}