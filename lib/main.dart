import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_strings.dart';
import 'package:merchant_app/viewmodels/notification_viewmodel.dart';
import 'package:merchant_app/viewmodels/plaza_viewmodel.dart';
import 'package:merchant_app/viewmodels/transaction_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import 'config/app_routes.dart';
import 'services/auth_service.dart';
//import 'services/user_service.dart';
import 'viewmodels/auth_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final authService = AuthService();
  //final userService = UserService();

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>.value(value: authService),
        //Provider<UserService>.value(value: userService),
        ChangeNotifierProvider(create: (_) => AuthViewModel(authService)),
        ChangeNotifierProvider(create: (_) => PlazaViewModel()),
        ChangeNotifierProvider(create: (_) => NotificationsViewModel()),
        ChangeNotifierProvider(create: (_) => TransactionViewModel()),
        //ChangeNotifierProvider(create: (_) => UserProfileViewModel(userService)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: AppRoutes.home,
      routes: AppRoutes.routes,
    );
  }
}
