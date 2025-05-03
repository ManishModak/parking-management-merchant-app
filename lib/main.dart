import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:merchant_app/providers/locale_provider.dart';
import 'package:merchant_app/providers/theme_provider.dart';
import 'package:merchant_app/services/utils/navigation_service.dart';
import 'package:merchant_app/viewmodels/dispute/process_dispute_viewmodel.dart';
import 'package:merchant_app/viewmodels/dispute/view_dispute_viewmodel.dart';
import 'package:merchant_app/viewmodels/plaza/lane_details_viewmodel.dart';
import 'package:merchant_app/viewmodels/plaza/plaza_list_viewmodel.dart';
import 'package:merchant_app/viewmodels/plaza/plaza_modification_viewmodel.dart';
import 'package:merchant_app/viewmodels/settings_viewmodel.dart';
import 'package:merchant_app/viewmodels/ticket/open_ticket_viewmodel.dart';
import 'package:merchant_app/viewmodels/ticket/reject_ticket_viewmodel.dart';
import 'package:merchant_app/viewmodels/ticket/ticket_history_viewmodel.dart';
import 'package:merchant_app/views/home.dart';
import 'package:merchant_app/views/tickets/ticket_history/ticket_history_list.dart';
import 'package:merchant_app/views/welcome.dart';
import 'package:provider/provider.dart';
import 'config/app_config.dart';
import 'config/app_routes.dart';
import 'config/app_theme.dart';
import 'generated/l10n.dart';
import 'services/core/auth_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/notification_viewmodel.dart';
import 'viewmodels/plaza/plaza_viewmodel.dart';
import 'viewmodels/plaza_fare_viewmodel.dart';
import 'viewmodels/user_viewmodel.dart';

void main() async {
  developer.log('App starting initialization', name: 'Main');
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await AppConfig.initializeSettings();

  final authService = AuthService();
  final routeObserver = RouteObserver<ModalRoute>();

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>.value(value: authService),
        Provider<RouteObserver<ModalRoute>>.value(value: routeObserver),
        ChangeNotifierProvider(create: (_) => AuthViewModel(authService)),
        ChangeNotifierProvider(create: (_) => UserViewModel()),
        ChangeNotifierProvider(create: (_) => NotificationsViewModel()),
        ChangeNotifierProvider(create: (_) => PlazaViewModel()),
        ChangeNotifierProvider(create: (_) => PlazaListViewModel()),
        ChangeNotifierProvider(create: (_) => PlazaModificationViewModel()),
        ChangeNotifierProvider(create: (_) => PlazaFareViewModel()),
        ChangeNotifierProvider(create: (_) => ViewDisputeViewModel()),
        ChangeNotifierProvider(create: (_) => ProcessDisputeViewModel()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => TicketHistoryViewModel()),
        ChangeNotifierProvider(create: (_) => OpenTicketViewModel()),
        ChangeNotifierProvider(create: (_) => RejectTicketViewModel ()),
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
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
    developer.log('Checking authentication status', name: 'MyApp');

    AppConfig.listenToChanges(
      onLanguageChanged: () {
        setState(() {});
        developer.log('Language changed', name: 'MyApp');
      },
      onThemeChanged: () {
        setState(() {});
        developer.log('Theme changed', name: 'MyApp');
      },
    );
  }

  @override
  void dispose() {
    AppConfig.removeListeners(
      onLanguageChanged: () => setState(() {}),
      onThemeChanged: () => setState(() {}),
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LocaleProvider>(
      builder: (context, themeProvider, localeProvider, child) {
        return MaterialApp(
          title: 'CityPark',
          navigatorObservers: [widget.routeObserver],
          locale: localeProvider.locale,
          supportedLocales: const [Locale('en'), Locale('hi'), Locale('mr')],
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          navigatorKey: NavigationService.navigatorKey,
          theme: AppTheme.lightTheme,
          themeAnimationDuration: const Duration(milliseconds: 300),
          themeAnimationCurve: Curves.easeInOut,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          initialRoute: '/',
          onGenerateRoute: (settings) {
            if (settings.name == '/') {
              return MaterialPageRoute(
                builder: (context) => AuthCheckScreen(future: _authCheckFuture),
              );
            }
            return AppRoutes.generateRoute(settings);
          },
          builder: (context, child) {
            final mediaQuery = MediaQuery.of(context);
            AppConfig.deviceWidth = mediaQuery.size.width;
            AppConfig.deviceHeight = mediaQuery.size.height;
            return child!;
          },
        );
      },
    );
  }
}

class AuthCheckScreen extends StatelessWidget {
  final Future<bool> future;

  const AuthCheckScreen({super.key, required this.future});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return FutureBuilder<bool>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          developer.log('Auth check failed: ${snapshot.error}', name: 'AuthCheck', error: snapshot.error);
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => authService.isAuthenticated(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        developer.log('Auth check completed: ${snapshot.data}', name: 'AuthCheck');
        return snapshot.data == true ? const HomeScreen() : const WelcomeScreen();
      },
    );
  }
}