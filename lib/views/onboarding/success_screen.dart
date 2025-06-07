import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_config.dart';
import 'package:merchant_app/config/app_routes.dart';
import 'package:merchant_app/config/app_theme.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:merchant_app/utils/components/button.dart';
import 'package:merchant_app/utils/components/icon.dart';
import '../../generated/l10n.dart';

class SuccessScreen extends StatefulWidget {
  final String userId;

  const SuccessScreen({
    super.key,
    required this.userId,
  });

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize animation for the "done" icon
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToLogin() {
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);

    return Scaffold(
      appBar: CustomAppBar.appBarWithNavigation(
        screenTitle: "",
        onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.welcome),
        darkBackground: Theme.of(context).brightness == Brightness.dark,
        context: context,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SizedBox(
            width: AppConfig.deviceWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: AppConfig.deviceHeight*0.12),
                Semantics(
                  label: strings.successIconLabel, // Accessibility label
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: CustomIcons.doneIcon(
                      size: 80,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  strings.titleSuccess,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  strings.successRegistrationMessage, // Dynamic message with userId
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 16,
                    color: context.textSecondaryColor,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
                CustomButtons.primaryButton(
                  height: 50,
                  text: strings.buttonContinue,
                  onPressed: _navigateToLogin,
                  context: context,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}