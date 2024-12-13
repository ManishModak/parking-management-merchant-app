import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/config/app_routes.dart';
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
            title: 'Plazas',
            value: '54',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.plazaList);
            },
            backgroundColor: AppColors.primaryCard,
            valueColor: AppColors.primary,
          ),
          CustomCards.menuCard(
            title: 'Add Plaza',
            value: '',
            onTap: () {},
            backgroundColor: AppColors.secondaryCard,
            icon: const Icon(
              Icons.add,
              color: Colors.white,
              size: 24,
            ),
          ),
          CustomCards.menuCard(
            title: 'Disputes Remaining',
            value: '277',
            onTap: () {},
            backgroundColor: AppColors.secondaryCard,
            valueColor: AppColors.primary,
          ),
          CustomCards.menuCard(
            title: 'Add Operator',
            value: '',
            onTap: () {},
            backgroundColor: AppColors.primaryCard,
            icon: const Icon(
              Icons.add,
              color: Colors.white,
              size: 24,
            ),
          ),
          CustomCards.menuCard(
            title: 'Set Reset Password',
            value: '',
            onTap: () {},
            backgroundColor: AppColors.primaryCard,
            valueColor: Colors.red,
          ),
          CustomCards.menuCard(
            title: 'Manual Entry',
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
