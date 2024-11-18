import 'package:flutter/material.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:merchant_app/utils/components/card.dart';
import 'package:merchant_app/viewmodels/notification_viewmodel.dart';
import 'package:provider/provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.appBarWithTitle(
          screenTitle: 'Notifications', darkBackground: false),
      body: Consumer<NotificationsViewModel>(
        builder: (context, viewModel, child) {
          final notifications = viewModel.getNotifications();

          if (notifications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No notifications'),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return CustomCards.notificationCard(
                  notification: notification, context: context);
            },
          );
        },
      ),
    );
  }
}
