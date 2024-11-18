import 'package:flutter/material.dart';
import 'package:merchant_app/utils/screens/loading_screen.dart';
import 'package:merchant_app/utils/screens/success_screen.dart';
import 'package:merchant_app/views/auth/otp_verification.dart';
import 'package:merchant_app/views/home.dart';
import 'package:merchant_app/views/notification.dart';
import 'package:merchant_app/views/Menu/plaza_info.dart';

import '../views/auth/login.dart';
import '../views/auth/register.dart';
import '../views/auth/forgot_password.dart';
import '../views/dashboard.dart';
import '../views/welcome.dart';
import '../views/Menu/plaza_list.dart';

class AppRoutes {
  static const String initial = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String dashboard = '/account';
  static const String plazaList = '/plaza-list';
  static const String operatorList = '/operator-list';
  static const String otpVerification = "/otp-verification";
  static const String success = "/success";
  static const String loading = "/loading";
  static const String plazaInfo = "/plaza-info";
  static const String home = "/home";
  static const String notification = '/notification';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const WelcomeScreen(),
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    forgotPassword: (context) => const ForgotPasswordScreen(),
    dashboard: (context) => const DashboardScreen(),
    otpVerification: (context) => const OtpVerificationScreen(),
    success: (context) => const SuccessScreen(),
    loading: (context) => const LoadingScreen(),
    plazaList: (context) => const PlazaListScreen(),
    plazaInfo: (context) => const PlazaInfoScreen(),
    home: (context) => const HomeScreen(),
    notification: (context) => const NotificationsScreen()
    //plazaList: (context) => PlazaListScreen(),
    //operatorList: (context) => OperatorListScreen(),
  };
}
