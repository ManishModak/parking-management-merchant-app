import 'package:flutter/material.dart';
import 'package:merchant_app/utils/components/appbar.dart';

class ControlCenterScreen extends StatelessWidget {
  const ControlCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.appBarWithTitle(
          screenTitle: 'Control Center',
          darkBackground: false
      ),
    );
  }
}
