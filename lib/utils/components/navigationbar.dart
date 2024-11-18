import 'package:flutter/material.dart';

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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF014245), // Dark teal background color
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(50)), // Rounded edges for container
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment
            .spaceEvenly, // Evenly space icons without extra padding
        children: [
          _buildNavItem(Icons.swap_horiz, "Transactions", 0),
          _buildNavItem(Icons.layers_outlined, "Control Center", 1),
          _buildNavItem(Icons.dashboard_outlined, "Dashboard", 2),
          _buildNavItem(Icons.notifications_outlined, "Notifications", 3),
          _buildNavItem(Icons.person_outline, "Account", 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    return GestureDetector(
      onTap: () => onItemTapped(index),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color:
              selectedIndex == index ? Colors.tealAccent : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color:
              selectedIndex == index ? const Color(0xFF014245) : Colors.white70,
          size: 28, // Adjust icon size for better appearance
        ),
      ),
    );
  }
}
