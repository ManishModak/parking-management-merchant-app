import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_strings.dart';
import 'package:merchant_app/services/user_service.dart';
import 'package:merchant_app/viewmodels/notification_viewmodel.dart';
import 'package:merchant_app/viewmodels/user_viewmodel.dart';
import 'package:merchant_app/viewmodels/plaza_viewmodel/plaza_viewmodel.dart';
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
  final userService = UserService();
  final routeObserver = RouteObserver<ModalRoute>();

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>.value(value: authService),
        Provider<UserService>.value(value: userService),
        Provider<RouteObserver<ModalRoute>>.value(value: routeObserver),
        ChangeNotifierProvider(create: (_) => AuthViewModel(authService)),
        ChangeNotifierProvider(create: (_) => PlazaViewModel()),
        ChangeNotifierProvider(create: (_) => UserViewModel(userService)),
        ChangeNotifierProvider(create: (_) => NotificationsViewModel()),
        ChangeNotifierProvider(create: (_) => TransactionViewModel()),
      ],
      child: MyApp(routeObserver: routeObserver),
    ),
  );
}

class MyApp extends StatefulWidget {
  final RouteObserver<ModalRoute> routeObserver;

  const MyApp({super.key, required this.routeObserver});

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
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      navigatorObservers: [widget.routeObserver],
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routes: AppRoutes.routes,
      initialRoute: '/',
      // Update the onGenerateRoute section in the MyApp build method
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
                // Set device dimensions once the future is complete
                final mediaQueryData = MediaQuery.of(context);
                AppConfig.deviceWidth = mediaQueryData.size.width; // Uses setter
                AppConfig.deviceHeight = mediaQueryData.size.height; // Uses setter

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