import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:merchant_app/utils/components/card.dart';
import 'package:merchant_app/viewmodels/notification_viewmodel.dart';
import 'package:provider/provider.dart';
import '../../generated/l10n.dart'; // Your localization

class NotificationsScreenWrapper extends StatelessWidget {
  const NotificationsScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    developer.log('Building NotificationsScreenWrapper',
        name: 'NotificationsScreen');
    return ChangeNotifierProvider<NotificationsViewModel>(
      create: (context) {
        final viewModel = NotificationsViewModel();
        // Simple initialization with force refresh to ensure fresh data
        WidgetsBinding.instance.addPostFrameCallback((_) {
          viewModel.init(forceRefresh: true);
        });
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
    final viewModel = Provider.of<NotificationsViewModel>(context,
        listen: false); // For actions
    developer.log('Building NotificationsScreen', name: 'NotificationsScreen');

    return Scaffold(
      appBar: CustomAppBar.appBarWithActions(
        screenTitle: strings.titleNotifications,
        darkBackground: Theme.of(context).brightness == Brightness.dark,
        context: context,
        actions: [
          // Example: Add a "Mark all as read" button
          Consumer<NotificationsViewModel>(
              // To update button based on unread count
              builder: (context, vm, _) {
            if (vm.unreadCount > 0) {
              return IconButton(
                icon: const Icon(Icons.done_all),
                tooltip: strings.markAllAsRead, // Add to S.of(context)
                onPressed: () {
                  vm.markAllAsReadForCurrentUser();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            strings.markedAllAsRead)), // Add to S.of(context)
                  );
                },
              );
            }
            return const SizedBox.shrink();
          })
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.background, // Use theme
      body: Consumer<NotificationsViewModel>(
        builder: (context, viewModelConsumer, child) {
          // Renamed to avoid conflict
          return RefreshIndicator(
            onRefresh: () async {
              developer.log('Refreshing notifications via UI',
                  name: 'NotificationsScreen');
              HapticFeedback.lightImpact();
              // ScaffoldMessenger.of(context).showSnackBar(
              //   SnackBar(content: Text(strings.refreshNotifications)),
              // );
              await viewModelConsumer.refreshNotifications();
            },
            child: _buildContent(context, viewModelConsumer, strings),
          );
        },
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, NotificationsViewModel viewModel, S strings) {
    if (viewModel.isLoading && viewModel.getNotifications().isEmpty) {
      developer.log('Showing loading state', name: 'NotificationsScreen');
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Theme.of(context).primaryColor),
            const SizedBox(height: 16),
            Text(strings.labelLoading),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                developer.log('Manual retry from loading screen',
                    name: 'NotificationsScreen');
                viewModel.forceReset();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (viewModel.errorMessage != null &&
        viewModel.getNotifications().isEmpty) {
      developer.log('Showing error state: ${viewModel.errorMessage}',
          name: 'NotificationsScreen');
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          // Use Container for height matching
          height: MediaQuery.of(context).size.height -
              (Scaffold.of(context).appBarMaxHeight ?? kToolbarHeight) -
              MediaQuery.of(context).padding.top,
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  strings.errorLoadingNotifications, // Add to S.of(context)
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  viewModel.errorMessage!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => viewModel.refreshNotifications(),
                  child: Text(strings.labelRetry),
                )
              ],
            ),
          ),
        ),
      );
    }

    final notifications = viewModel.getNotifications();
    if (notifications.isEmpty) {
      developer.log('No notifications available',
          name: 'NotificationsScreen', level: 600);
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          // Use Container for height matching
          height: MediaQuery.of(context).size.height -
              (Scaffold.of(context).appBarMaxHeight ?? kToolbarHeight) -
              MediaQuery.of(context).padding.top,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.notifications_off_outlined,
                  size: 60, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                strings.noNotificationsTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                strings.noNotificationsSubtitle,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    developer.log('Rendering ${notifications.length} notifications',
        name: 'NotificationsScreen');
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        // Assuming CustomCards.notificationCard can now take these callbacks
        return CustomCards.notificationCard(
          notification: notification,
          context: context,
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, NotificationsViewModel viewModel,
      String notificationId, S strings) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(strings.confirmDeleteTitle), // Add to S.of(context)
          content: Text(strings.confirmDeleteMessage), // Add to S.of(context)
          actions: <Widget>[
            TextButton(
              child: Text(strings.labelCancel), // Add to S.of(context)
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(strings.labelDelete), // Add to S.of(context)
              onPressed: () {
                Navigator.of(dialogContext).pop();
                viewModel.deleteNotification(notificationId);
              },
            ),
          ],
        );
      },
    );
  }
}
