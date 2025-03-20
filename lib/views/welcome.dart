import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:merchant_app/config/app_config.dart';
import 'package:merchant_app/config/app_routes.dart';
import 'package:merchant_app/config/app_theme.dart';
import 'package:merchant_app/utils/components/button.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:merchant_app/viewmodels/auth_viewmodel.dart';
import '../generated/l10n.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    developer.log('WelcomeScreen initialized', name: 'WelcomeScreen');
    _controller = AnimationController(
      duration: const Duration(milliseconds: 750),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    developer.log('WelcomeScreen disposed', name: 'WelcomeScreen');
    super.dispose();
  }

  void _navigateTo(BuildContext context, String route) {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    developer.log('Navigating to $route from WelcomeScreen', name: 'WelcomeScreen');
    HapticFeedback.lightImpact();
    try {
      authVM.resetErrors(); // Reset errors before navigation
      Navigator.pushReplacementNamed(context, route);
    } catch (e) {
      developer.log('Navigation failed to $route: $e', name: 'WelcomeScreen', level: 1000);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${S.of(context).errorNavigation}: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/citypark_doodle.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: AppConfig.deviceWidth * 0.05),
                  Text(
                    'CityPark',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: AppConfig.deviceWidth * 0.05),
                  Text(
                    'Welcome to the Merchant',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    'App!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CustomButtons.primaryButton(
                      height: 50,
                      width: double.infinity,
                      text: strings.buttonLogin,
                      onPressed: () => _navigateTo(context, AppRoutes.login),
                      context: context,
                    ),
                    const SizedBox(height: 15),
                    CustomButtons.secondaryButton(
                      height: 50,
                      width: double.infinity,
                      text: strings.buttonRegister,
                      onPressed: () => _navigateTo(context, AppRoutes.register),
                      context: context,
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}