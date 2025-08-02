import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:merchant_app/config/app_theme.dart';
import 'package:merchant_app/views/settings.dart';
import 'package:provider/provider.dart';
import '../../generated/l10n.dart';
import '../services/storage/secure_storage_service.dart';
import '../utils/components/navigationbar.dart';
import '../viewmodels/settings_viewmodel.dart';
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
  bool _isInitialized = false;

  List<Widget>? _screens;

  @override
  void initState() {
    super.initState();
    developer.log('Initializing HomeScreen', name: 'HomeScreen');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _initializeData();
      _isInitialized = true;
    }
  }

  void _onItemTapped(int index) {
    developer.log(
        'Navigation bar item tapped: $index, switching to ${_screens?[index].runtimeType}',
        name: 'HomeScreen');
    HapticFeedback.selectionClick();
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _initializeData() async {
    await _checkAuthentication();
    if (mounted) {
      await _loadProfileData();
      setState(() {
        _screens = [
          const DashboardScreen(key: PageStorageKey('dashboard')),
          const MenuScreen(key: PageStorageKey('menu')),
          const NotificationsScreenWrapper(
              key: PageStorageKey('notifications')),
          const AccountSettingsScreen(key: PageStorageKey('settings')),
        ];
      });
    }
  }

  Future<void> _checkAuthentication() async {
    try {
      final strings = S.of(context);
      String? token = await _secureStorage.getAuthToken();
      developer.log(
          "Authentication token ${token != null ? 'exists' : 'missing'}",
          name: 'HomeScreen');

      if (token == null) {
        developer.log('No auth token found, redirecting to welcome',
            name: 'HomeScreen', level: 900);
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
      developer.log("Error checking authentication: $e",
          name: 'HomeScreen', level: 1000);
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
    final settingsViewModel =
        Provider.of<SettingsViewModel>(context, listen: false);
    developer.log('Loading profile data', name: 'HomeScreen');

    try {
      setState(() => _isLoadingProfile = true);
      final userId = await _secureStorage.getUserId();
      if (userId == null) {
        developer.log('User ID not found', name: 'HomeScreen', level: 900);
        return;
      }

      final success = await settingsViewModel.fetchAndStoreUserData(
        userId: userId,
        isCurrentAppUser: true,
      );
      developer.log(
          'User profile ${success ? 'fetched and stored' : 'failed to fetch/store'} for ID: $userId',
          name: 'HomeScreen');

      if (!success || settingsViewModel.currentUser == null) {
        developer.log('No user data returned or failed to store',
            name: 'HomeScreen', level: 900);
      }
    } catch (e) {
      developer.log("Error fetching/storing user data: $e",
          name: 'HomeScreen', level: 1000);
    } finally {
      if (mounted) {
        setState(() => _isLoadingProfile = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: Stack(
        children: [
          if (_isLoadingProfile || _screens == null)
            const Center(child: CircularProgressIndicator()),
          if (_screens != null)
            ..._screens!.asMap().entries.map((entry) {
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
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: CustomNavigationBar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
        ),
      ),
    );
  }
}
