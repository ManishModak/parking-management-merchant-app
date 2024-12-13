import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_routes.dart';
import 'package:merchant_app/config/app_strings.dart';
import 'package:merchant_app/utils/components/button.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/config/app_config.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              width: AppConfig.deviceWidth,
              height: AppConfig.deviceHeight * 0.55,
              // Adjust this value as needed
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(75),
                  bottomRight: Radius.circular(75),
                ),
              ),
              child: const Center(
                child: Text(
                  'P',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 300,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: AppConfig.deviceHeight * 0.06),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    AppStrings.appName,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    AppStrings.welcomeMessage,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 25),
                  CustomButtons.primaryButton(
                      text: AppStrings.buttonLogin,
                      onPressed: () => Navigator.pushReplacementNamed(
                          context, AppRoutes.login)),
                  const SizedBox(height: 15),
                  CustomButtons.secondaryButton(
                      text: AppStrings.buttonRegister,
                      onPressed: () => Navigator.pushReplacementNamed(
                          context, AppRoutes.register)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
