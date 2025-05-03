import 'package:flutter/material.dart';
import 'package:merchant_app/views/dispute/dispute_list.dart';
import '../models/plaza.dart';
import '../views/dispute/process_dispute_details.dart';
import '../views/dispute/view_dispute_details.dart';
import '../views/home.dart';
import '../views/notification.dart';
import '../views/plaza/plaza fare/add_fare.dart';
import '../views/plaza/plaza fare/plaza_fares_list.dart';
import '../views/plaza/plaza_registration.dart';
import '../views/user/user_info.dart';
import '../views/user/user_list.dart';
import '../views/user/user_registration.dart';
import '../views/onboarding/forgot_password.dart';
import '../views/dashboard.dart';
import '../views/onboarding/login.dart';
import '../views/onboarding/register.dart';
import '../views/plaza/plaza_info.dart';
import '../views/plaza/plaza_list.dart';
import '../views/plaza/plaza_modification/bank_details.dart';
import '../views/plaza/plaza_modification/basic_details.dart';
import '../views/plaza/plaza_modification/lane_details/lane_details.dart';
import '../views/plaza/plaza_modification/plaza_images.dart';
import '../views/settings/profile.dart';
import '../views/tickets/mark_exit/mark_exit.dart';
import '../views/tickets/new_ticket/new_ticket.dart';
import '../views/tickets/open_ticket/open_ticket_list.dart';
import '../views/tickets/reject_ticket/reject_ticket_list.dart';
import '../views/tickets/ticket_history/ticket_history_list.dart';
import '../views/welcome.dart';
import '../utils/screens/loading_screen.dart';
import '../views/onboarding/success_screen.dart';

class AppRoutes {
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String dashboard = '/dashboard';
  static const String plazaList = '/plaza-list';
  static const String userList = '/user-list';
  static const String success = '/success';
  static const String loading = '/loading';
  static const String plazaInfo = '/plaza-info';
  static const String home = '/home';
  static const String notification = '/notification';
  static const String userProfile = '/user-profile';
  static const String setUsername = '/set-username';
  static const String userInfo = '/user-info';
  static const String userRegistration = '/user-registration';
  static const String plazaRegistration = '/plaza-registration';
  static const String basicDetailsModification = '/plaza-basic-details';
  static const String bankDetailsModification = '/plaza-bank-details';
  static const String laneDetailsModification = '/plaza-lane-details';
  static const String plazaImagesModification = '/plaza-images';
  static const String plazaAddFare = '/plaza-add-fare';
  static const String plazaFaresList = '/plaza-fares';
  static const String newTicket = '/new-ticket';
  static const String openTickets = '/open-tickets';
  static const String rejectTicket = '/reject-ticket';
  static const String ticketHistory = '/ticket-history';
  static const String markExit = '/mark-exit';
  static const String disputeList = '/dispute-list';
  static const String disputeDetail = '/dispute-detail';
  static const String processDispute = '/process-dispute';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case welcome:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case plazaList:
        final args = settings.arguments as Map<String, dynamic>?;
        final modifyPlazaInfo = args?['modifyPlazaInfo'] ?? true;
        return MaterialPageRoute(
            builder: (_) => PlazaListScreen(modifyPlazaInfo: modifyPlazaInfo));
      case userList:
        return MaterialPageRoute(builder: (_) => const UserListScreen());
      case success:
        final args = settings.arguments as Map<String, dynamic>?;
        final userId = args?['userId'] as String? ?? '';
        return MaterialPageRoute(builder: (_) => SuccessScreen(userId: userId));
      case loading:
        return MaterialPageRoute(builder: (_) => const LoadingScreen());
      case plazaInfo:
        final plazaId = settings.arguments;
        return MaterialPageRoute(builder: (_) => PlazaInfoScreen(plazaId: plazaId));
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case notification:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());
      case userProfile:
        return MaterialPageRoute(builder: (_) => const UserProfileScreen());
      case userInfo:
        final args = settings.arguments as Map<String, dynamic>?;
        final operatorId = args?['operatorId'] as String? ?? '';
        return MaterialPageRoute(builder: (_) => UserInfoScreen(operatorId: operatorId));
      case userRegistration:
        return MaterialPageRoute(builder: (_) => const UserRegistrationScreen());
      case plazaRegistration:
        return MaterialPageRoute(builder: (_) => const PlazaRegistrationScreen());
      case basicDetailsModification:
      // Pass the settings object along so ModalRoute works inside the screen
        return MaterialPageRoute(
          builder: (_) => const BasicDetailsModificationScreen(),
          settings: settings, // <--- ADD THIS LINE
        );
      case bankDetailsModification:
        return MaterialPageRoute(builder: (_) => const BankDetailsModificationScreen(),settings: settings);
      case laneDetailsModification:
        final plazaId = settings.arguments as String?; // Extract plazaId from arguments
        return MaterialPageRoute(
          builder: (_) => LaneDetailsModificationScreen(
            plazaId: plazaId ?? '', // Use empty string as fallback
          ),
        );
      case plazaImagesModification:
        return MaterialPageRoute(builder: (_) => const PlazaImagesModificationScreen(),settings: settings);
      case plazaAddFare:
        final args = settings.arguments as Map<String, dynamic>?;
        final selectedPlaza = args?['plaza'] as Plaza?;
        return MaterialPageRoute(builder: (_) => AddFareScreen(selectedPlaza: selectedPlaza));
      case plazaFaresList:
        final plaza = settings.arguments as Plaza;
        return MaterialPageRoute(builder: (_) => PlazaFaresListScreen(plaza: plaza));
      case newTicket:
        return MaterialPageRoute(builder: (_) => const NewTicketScreen());
      case openTickets:
        return MaterialPageRoute(builder: (_) => const OpenTicketsScreen());
      case rejectTicket:
        return MaterialPageRoute(builder: (_) => const RejectTicketScreen());
      case ticketHistory:
        return MaterialPageRoute(
          builder: (_) => const TicketHistoryScreen(),
          settings: settings,
        );
      case markExit:
        return MaterialPageRoute(builder: (_) => const MarkExitScreen());
      case disputeList:
        final args = settings.arguments as Map<String, dynamic>?;
        final viewDisputeOptionSelect = args?['viewDisputeOptionSelect'] as bool? ?? true;
        return MaterialPageRoute(
            builder: (_) => DisputeList(viewDisputeOptionSelect: viewDisputeOptionSelect));
      case disputeDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        final ticketId = args?['ticketId'] as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => ViewDisputeDetailsScreen(ticketId: ticketId),
        );
      case processDispute:
        final args = settings.arguments as Map<String, dynamic>?;
        final ticketId = args?['ticketId'] as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => ProcessDisputeDetailsScreen(ticketId: ticketId),
        );
      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
              body: Center(child: Text('No route defined for ${settings.name}')),
            ));
    }
  }
}