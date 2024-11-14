import 'package:flutter/material.dart';
import 'package:merchant_app/utils/components/navigationbar.dart';
import 'package:merchant_app/views/Transaction.dart';
import 'package:merchant_app/views/account/settings.dart';
import 'package:merchant_app/views/control_center.dart';
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
    const ControlCenterScreen(),
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
      body: _screens[_selectedIndex],
      bottomNavigationBar: CustomNavigationBar(selectedIndex: _selectedIndex, onItemTapped: _onItemTapped),
      //bottomNavigationBar: CustomNavigation.navbar(selectedIndex: _selectedIndex,onItemTapped: _onItemTapped),
    );
  }
}
