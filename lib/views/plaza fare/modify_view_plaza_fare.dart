import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../config/app_strings.dart';
import '../../utils/components/appbar.dart';

class ModifyViewPlazaFareScreen extends StatefulWidget {
  const ModifyViewPlazaFareScreen({super.key});

  @override
  State<ModifyViewPlazaFareScreen> createState() => _ModifyViewPlazaFareScreenState();
}

class _ModifyViewPlazaFareScreenState extends State<ModifyViewPlazaFareScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightThemeBackground,
      appBar: CustomAppBar.appBarWithNavigation(
        screenTitle: AppStrings.titleModifyViewFareDetails,
        onPressed: () => Navigator.pop(context),
        darkBackground: true,
      ),
    );
  }
}
