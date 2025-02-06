import 'package:flutter/material.dart';
import 'package:merchant_app/utils/screens/loading_screen.dart';
import 'package:merchant_app/utils/screens/success_screen.dart';
import 'package:merchant_app/views/home.dart';
import 'package:merchant_app/views/notification.dart';
import 'package:merchant_app/views/onboarding/set_username.dart';
import 'package:merchant_app/views/plaza%20fare/add_fare.dart';
import 'package:merchant_app/views/plaza%20fare/modify_view_plaza_fare.dart';
import 'package:merchant_app/views/plaza/plaza_registration.dart';
import 'package:merchant_app/views/user/user_info.dart';
import 'package:merchant_app/views/user/user_list.dart';
import 'package:merchant_app/views/user/user_registration.dart';
import '../views/onboarding/forgot_password.dart';
import '../views/dashboard.dart';
import '../views/onboarding/login.dart';
import '../views/onboarding/register.dart';
import '../views/plaza/plaza_info.dart';
import '../views/plaza/plaza_list.dart';
import '../views/plaza/plaza_modification/bank_details.dart';
import '../views/plaza/plaza_modification/basic_details.dart';
import '../views/plaza/plaza_modification/lane_details.dart';
import '../views/plaza/plaza_modification/plaza_images.dart';
import '../views/settings/profile.dart';
import '../views/welcome.dart';

class AppRoutes {
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String dashboard = '/account';
  static const String plazaList = '/plaza-list';
  static const String userList = '/user-list';
  static const String otpVerification = "/otp-verification";
  static const String success = "/success";
  static const String loading = "/loading";
  static const String plazaInfo = "/plaza-info";
  static const String home = "/home";
  static const String notification = '/notification';
  static const String userProfile = '/user-profile';
  static const String setUsername = '/set-username';
  static const String userInfo = '/user-info';
  static const String userRegistration = '/user-registration';
  static const String plazaRegistration = '/plaza-registration';
  static const String basicDetailsModification = '/plaza-basicDetailsModification';
  static const String bankDetailsModification = '/plaza-bankDetailsModification';
  static const String laneDetailsModification = '/plaza-laneDetailsModification';
  static const String plazaImagesModification = '/plaza-plazaImagesModification';
  static const String plazaAddFare = '/add-plazaFare';
  static const String modifyViewPlazaFare = '/modifyView-plazaFare';

  static Map<String, WidgetBuilder> routes = {
    welcome: (context) => const WelcomeScreen(),
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    forgotPassword: (context) => const ForgotPasswordScreen(),
    dashboard: (context) => const DashboardScreen(),
    success: (context) => const SuccessScreen(userId: '',),
    loading: (context) => const LoadingScreen(),
    plazaList: (context) => const PlazaListScreen(),
    plazaInfo: (context) => const PlazaInfoScreen(),
    home: (context) => const HomeScreen(),
    notification: (context) => const NotificationsScreen(),
    userProfile: (context) => const UserProfileScreen(),
    userInfo: (context) => const UserInfoScreen(operatorId: '',),
    userList: (context) => const UserListScreen(),
    userRegistration: (context) => const UserRegistrationScreen(),
    plazaRegistration: (context) => const PlazaRegistrationScreen(),
    basicDetailsModification: (context) => const BasicDetailsModificationScreen(),
    bankDetailsModification: (context) => const BankDetailsModificationScreen(),
    laneDetailsModification: (context) => const LaneDetailsModificationScreen(),
    plazaImagesModification: (context) => const PlazaImagesModificationScreen(),
    plazaAddFare: (context) => const AddFareScreen(),
    modifyViewPlazaFare: (context) => const ModifyViewPlazaFareScreen(),
    setUsername: (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, String>;
      return SetUsernameScreen(
        email: args['email']!,
        password: args['password']!,
        mobileNo: args['mobileNo']!,
        confirmPassword: args['repeatPassword']!,
      );
    },
  };
}

