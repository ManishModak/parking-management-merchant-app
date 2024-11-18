import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:merchant_app/utils/components/card.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightThemeBackground,
      appBar: CustomAppBar.appBarWithTitle(
          screenTitle: 'Menu', darkBackground: false),
      body:GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        padding: const EdgeInsets.all(8),
        children: [
          CustomCards.menuCard(
            title: 'Registered Plazas',
            value: '\$5046.57',
            onTap: () {
              // Navigate or perform an action
            },
            backgroundColor: AppColors.primaryCard,
            valueColor: AppColors.primary,
          ),
          CustomCards.menuCard(
            title: 'Add Plaza',
            value: '',
            onTap: () {},
            backgroundColor: AppColors.secondaryCard,
          ),
          CustomCards.menuCard(
            title: 'Disputes Remaining',
            value: '277',
            onTap: () {},
            backgroundColor: AppColors.secondaryCard,
            valueColor: Colors.red,
          ),
          CustomCards.menuCard(
            title: 'Payments Success Rate',
            value: '98%',
            onTap: () {},
            backgroundColor: AppColors.primaryCard,
          ),
          CustomCards.menuCard(
            title: 'Total Plazas',
            value: '24',
            onTap: () {},
            backgroundColor: AppColors.primaryCard,
            valueColor: Colors.red,
          ),
          CustomCards.menuCard(
            title: 'ANPR',
            value: '',
            onTap: () {},
            backgroundColor: AppColors.secondaryCard,
            icon: const Icon(
              Icons.camera_alt,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}
