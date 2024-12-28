import 'dart:async';

import 'package:flutter/material.dart';
import 'package:merchant_app/services/secure_storage_service.dart';
import 'package:merchant_app/utils/components/navigationbar.dart';
import 'package:merchant_app/viewmodels/user_viewmodel.dart';
import 'package:merchant_app/views/transaction.dart';
import 'package:merchant_app/views/settings.dart';
import 'package:merchant_app/views/menu.dart';
import 'package:merchant_app/views/notification.dart';
import 'package:provider/provider.dart';
import 'dashboard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 2;

  final List<Widget> _screens = [
    const TransactionScreen(),
    const MenuScreen(),
    const DashboardScreen(),
    const NotificationsScreen(),
    const AccountSettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

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
    unawaited(userViewModel.fetchUser(userId: userId!, isCurrentAppUser: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
      body: _screens[_selectedIndex],
    );
  }
}