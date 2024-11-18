import 'package:flutter/material.dart';
import 'package:merchant_app/utils/components/navigationbar.dart';
import 'package:merchant_app/views/transaction.dart';
import 'package:merchant_app/views/settings.dart';
import 'package:merchant_app/views/menu.dart';
import 'package:merchant_app/views/notification.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _screens[_selectedIndex],
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomNavigationBar(
              selectedIndex: _selectedIndex,
              onItemTapped: _onItemTapped,
            ),
          ),
        ],
      ),
    );
  }
}
