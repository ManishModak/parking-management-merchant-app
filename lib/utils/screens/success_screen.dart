import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_config.dart';
import 'package:merchant_app/config/app_strings.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/utils/components/button.dart';
import 'package:merchant_app/utils/components/icon.dart';

class SuccessScreen extends StatefulWidget {
  const SuccessScreen({super.key});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: SizedBox(
              width: AppConfig.deviceWidth,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIcons.doneIcon(),
                  const SizedBox(height: 24),
                  const Text(
                    AppStrings.titleSuccess,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    AppStrings.successMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'User ID:',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 32),
                  CustomButtons.primaryButton(text: AppStrings.buttonContinue, onPressed: () {})
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
