import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_strings.dart';
import 'package:merchant_app/viewmodels/notification_viewmodel.dart';
import 'package:merchant_app/viewmodels/plaza_viewmodel.dart';
import 'package:merchant_app/viewmodels/transaction_viewmodel.dart';
import 'package:merchant_app/views/home.dart';
import 'package:merchant_app/views/welcome.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import 'config/app_config.dart';
import 'config/app_routes.dart';
import 'services/auth_service.dart';
import 'viewmodels/auth_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final authService = AuthService();

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>.value(value: authService),
        ChangeNotifierProvider(create: (_) => AuthViewModel(authService)),
        ChangeNotifierProvider(create: (_) => PlazaViewModel()),
        ChangeNotifierProvider(create: (_) => NotificationsViewModel()),
        ChangeNotifierProvider(create: (_) => TransactionViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<bool> _authCheckFuture;

  @override
  void initState() {
    super.initState();
    final authService = Provider.of<AuthService>(context, listen: false);
    _authCheckFuture = authService.isAuthenticated();
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    AppConfig.deviceWidth = MediaQuery.of(context).size.width;
    AppConfig.deviceHeight = MediaQuery.of(context).size.height;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routes: AppRoutes.routes, // Define routes here
      initialRoute: '/', // Set the initial route
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          return MaterialPageRoute(
            builder: (context) => FutureBuilder<bool>(
              future: _authCheckFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                return snapshot.data == true
                    ? const HomeScreen()
                    : const WelcomeScreen();
              },
            ),
          );
        }
        return null;
      },
    );
  }
}
