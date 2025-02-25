import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:merchant_app/views/home.dart';
import 'package:merchant_app/views/welcome.dart';
import 'package:provider/provider.dart';
import 'config/app_strings.dart';
import 'config/app_config.dart';
import 'config/app_routes.dart';
import 'services/core/auth_service.dart';
import 'services/core/user_service.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/notification_viewmodel.dart';
import 'viewmodels/plaza/plaza_viewmodel.dart';
import 'viewmodels/plaza_fare_viewmodel.dart';
import 'viewmodels/user_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final authService = AuthService();
  final userService = UserService();
  final routeObserver = RouteObserver<ModalRoute>();

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>.value(value: authService),
        Provider<UserService>.value(value: userService),
        Provider<RouteObserver<ModalRoute>>.value(value: routeObserver),

        // Global ViewModels
        ChangeNotifierProvider(create: (_) => AuthViewModel(authService)),
        ChangeNotifierProvider(create: (_) => UserViewModel(userService)),
        ChangeNotifierProvider(create: (_) => NotificationsViewModel()),
        ChangeNotifierProvider(create: (_) => PlazaViewModel()),
        ChangeNotifierProvider(create: (_) => PlazaFareViewModel()),
      ],
      child: MyApp(routeObserver: routeObserver),
    ),
  );
}

class MyApp extends StatefulWidget {
  final RouteObserver<ModalRoute> routeObserver;

  const MyApp({super.key, required this.routeObserver});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  late Future<bool> _authCheckFuture;

  @override
  void initState() {
    super.initState();
    final authService = Provider.of<AuthService>(context, listen: false);
    _authCheckFuture = authService.isAuthenticated();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      navigatorObservers: [widget.routeObserver],
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        // Handle initial route separately for security check
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

                // Set device dimensions
                final mediaQueryData = MediaQuery.of(context);
                AppConfig.deviceWidth = mediaQueryData.size.width;
                AppConfig.deviceHeight = mediaQueryData.size.height;

                // Determine initial screen based on security state
                if (snapshot.data == true) {
                  return const HomeScreen();
                } else {
                  return const WelcomeScreen();
                }
              },
            ),
          );
        }

        // Use the new route generator for all other routes
        return AppRoutes.generateRoute(settings);
      },
      builder: (context, child) {
        // Ensure we have a MediaQuery for AppConfig
        final mediaQuery = MediaQuery.of(context);
        AppConfig.deviceWidth = mediaQuery.size.width;
        AppConfig.deviceHeight = mediaQuery.size.height;

        return child!;
      },
    );
  }
}