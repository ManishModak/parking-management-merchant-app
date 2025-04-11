import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_colors.dart';
import '../../generated/l10n.dart';

class CustomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final S strings = S.of(context);
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final List<({IconData icon, String label})> navItems = [
      (icon: Icons.dashboard_outlined, label: strings.navDashboard),
      (icon: Icons.apps_outlined, label: strings.navMenu),
      (icon: Icons.notifications_outlined, label: strings.navNotifications),
      (icon: Icons.person_outline, label: strings.navAccount),
    ];

    final Color barBackgroundColor = isDarkMode ? AppColors.primary : AppColors.primary;
    final Color selectedIconBgColor = isDarkMode ? AppColors.secondary : Colors.white;
    final Color selectedIconColor = isDarkMode ? AppColors.primary : AppColors.primary;
    final Color unselectedIconColor = isDarkMode ? AppColors.secondary.withOpacity(0.7) : Colors.white70;
    final Color selectedTextColor = isDarkMode ? AppColors.secondary : Colors.white;
    final Color unselectedTextColor = isDarkMode ? AppColors.secondary.withOpacity(0.7) : Colors.white70;

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: barBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(50)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          navItems.length,
              (index) => _buildNavItem(
            icon: navItems[index].icon,
            label: navItems[index].label,
            index: index,
            context: context,
            selectedIconBgColor: selectedIconBgColor,
            selectedIconColor: selectedIconColor,
            unselectedIconColor: unselectedIconColor,
            selectedTextColor: selectedTextColor,
            unselectedTextColor: unselectedTextColor,
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required BuildContext context,
    required Color selectedIconBgColor,
    required Color selectedIconColor,
    required Color unselectedIconColor,
    required Color selectedTextColor,
    required Color unselectedTextColor,
  }) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        developer.log('Nav item tapped: $label (index: $index)', name: 'CustomNavigationBar');
        onItemTapped(index);
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isSelected ? selectedIconBgColor : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isSelected ? selectedIconColor : unselectedIconColor,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isSelected ? selectedTextColor : unselectedTextColor,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}