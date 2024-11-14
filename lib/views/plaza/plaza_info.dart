import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:merchant_app/utils/components/navigationbar.dart';

class PlazaInfoScreen extends StatefulWidget {
  const PlazaInfoScreen({super.key});

  @override
  State<PlazaInfoScreen> createState() => _PlazaInfoScreenState();
}

class _PlazaInfoScreenState extends State<PlazaInfoScreen> {
  late String screenTitle;

  @override
  void initState() {
    screenTitle = 'Plaza Name';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightThemeBackground,
      appBar: CustomAppBar.appBarWithNavigation(screenTitle: screenTitle, onPressed: () {Navigator.pop(context);}, darkBackground: false),
    );
  }
}
