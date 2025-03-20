import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:merchant_app/config/app_theme.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:merchant_app/utils/components/card.dart';
import 'package:merchant_app/viewmodels/notification_viewmodel.dart';
import 'package:provider/provider.dart';
import '../../generated/l10n.dart';

class NotificationsScreenWrapper extends StatelessWidget {
  const NotificationsScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    developer.log('Building NotificationsScreenWrapper', name: 'NotificationsScreen');
    return ChangeNotifierProvider<NotificationsViewModel>(
      create: (context) {
        final viewModel = NotificationsViewModel();
        //viewModel.init(); // Ensure data is loaded on creation
        return viewModel;
      },
      child: const NotificationsScreen(),
    );
  }
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    developer.log('Building NotificationsScreen', name: 'NotificationsScreen');

    return Scaffold(
      appBar: CustomAppBar.appBarWithTitle(
        screenTitle: strings.titleNotifications,
        darkBackground: Theme.of(context).brightness == Brightness.dark,
        context: context,
      ),
      backgroundColor: context.backgroundColor,
      body: Consumer<NotificationsViewModel>(
        builder: (context, viewModel, child) {
          return RefreshIndicator(
            onRefresh: () async {
              developer.log('Refreshing notifications', name: 'NotificationsScreen');
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(strings.refreshNotifications)),
              );
              //await viewModel.refreshNotifications();
            },
            child: _buildContent(context, viewModel),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, NotificationsViewModel viewModel) {
    final strings = S.of(context);

    if (viewModel.isLoading) {
      developer.log('Showing loading state', name: 'NotificationsScreen');
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 16),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 500),
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: context.textPrimaryColor.withOpacity(viewModel.isLoading ? 1.0 : 0.7),
              ),
              child: Text(strings.labelLoading),
            ),
          ],
        ),
      );
    }

    final notifications = viewModel.getNotifications();

    if (notifications.isEmpty) {
      developer.log('No notifications available', name: 'NotificationsScreen', level: 600); // Info level
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(), // Ensure RefreshIndicator works
        child: SizedBox(
          height: MediaQuery.of(context).size.height - kToolbarHeight - MediaQuery.of(context).padding.top,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    Icons.notifications_off,
                    key: ValueKey('no-notifications-icon'),
                    size: 48,
                    color: context.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  strings.noNotificationsTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: context.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  strings.noNotificationsSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    developer.log('Rendering ${notifications.length} notifications', name: 'NotificationsScreen');
    return ListView.builder(
      itemCount: notifications.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return const SizedBox(height: 16);
        }
        final notification = notifications[index - 1];
        return CustomCards.notificationCard(
          notification: notification,
          context: context,
        );
      },
    );
  }
}