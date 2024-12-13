import 'package:flutter/material.dart';
import 'package:merchant_app/utils/screens/loading_screen.dart';
import 'package:merchant_app/utils/screens/success_screen.dart';
import 'package:merchant_app/views/auth/otp_verification.dart';
import 'package:merchant_app/views/home.dart';
import 'package:merchant_app/views/notification.dart';
import 'package:merchant_app/views/Menu/plaza_info.dart';
import 'package:merchant_app/views/set_username.dart';

import '../views/auth/login.dart';
import '../views/auth/register.dart';
import '../views/auth/forgot_password.dart';
import '../views/dashboard.dart';
import '../views/profile.dart';
import '../views/welcome.dart';
import '../views/Menu/plaza_list.dart';

class AppRoutes {
  static const String welcome = '/welcome';
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
  static const String userProfile = '/user-profile';
  static const String setUsername = '/set-username';

  static Map<String, WidgetBuilder> routes = {
    welcome: (context) => const WelcomeScreen(),
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
    notification: (context) => const NotificationsScreen(),
    userProfile: (context) => const UserProfileScreen(),
    setUsername: (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, String>;
      return SetUsernameScreen(
        email: args['email']!,
        password: args['password']!,
        mobileNo: args['mobileNo']!,
        repeatPassword: args['repeatPassword']!,
      );
    },
  };
}

