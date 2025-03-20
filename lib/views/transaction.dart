import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:merchant_app/config/app_theme.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:merchant_app/utils/components/button.dart';
import 'package:merchant_app/utils/components/card.dart';
import 'package:merchant_app/viewmodels/transaction_viewmodel.dart';
import 'package:provider/provider.dart';
import '../config/app_colors.dart';
import '../generated/l10n.dart';

class TransactionScreenWrapper extends StatelessWidget {
  const TransactionScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    developer.log('Building TransactionScreenWrapper', name: 'TransactionScreen');
    return ChangeNotifierProvider<TransactionViewModel>(
      create: (context) {
        final viewModel = TransactionViewModel();
        //viewModel.init(); // Ensure data is loaded on creation
        return viewModel;
      },
      child: const TransactionScreen(),
    );
  }
}

class TransactionScreen extends StatelessWidget {
  const TransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    developer.log('Building TransactionScreen', name: 'TransactionScreen');

    return Scaffold(
      appBar: CustomAppBar.appBarWithActions(
        screenTitle: strings.navTransactions,
        darkBackground: Theme.of(context).brightness == Brightness.dark,
        actions: [
          CustomButtons.downloadIconButton(
            onPressed: () {
              developer.log('Download button pressed', name: 'TransactionScreen');
              _handleDownload(context);
            },
            darkBackground: Theme.of(context).brightness == Brightness.dark,
            context: context,
          ),
          const SizedBox(width: 10),
        ],
        context: context,
      ),
      backgroundColor: context.backgroundColor,
      body: Consumer<TransactionViewModel>(
        builder: (context, viewModel, child) {
          return RefreshIndicator(
            onRefresh: () async {
              developer.log('Refreshing transactions', name: 'TransactionScreen');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(strings.refreshTransactions)),
              );
              //await viewModel.refreshTransactions();
            },
            child: _buildContent(context, viewModel),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, TransactionViewModel viewModel) {
    final strings = S.of(context);

    if (viewModel.isLoading) {
      developer.log('Showing loading state', name: 'TransactionScreen');
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

    final transactions = viewModel.getTransactions();

    if (transactions.isEmpty) {
      developer.log('No transactions available', name: 'TransactionScreen', level: 600); // Info level
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(), // Ensure RefreshIndicator works
        child: SizedBox(
          height: MediaQuery.of(context).size.height - kToolbarHeight - MediaQuery.of(context).padding.top,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.payment,
                  size: 48,
                  color: context.textSecondaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  strings.noTransactionsTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: context.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  strings.noTransactionsSubtitle,
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

    developer.log('Rendering ${transactions.length} transactions', name: 'TransactionScreen');
    return ListView.builder(
      itemCount: transactions.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return const SizedBox(height: 16);
        }
        final transaction = transactions[index - 1];
        return CustomCards.transactionCard(
          transaction: transaction,
          context: context,
        );
      },
    );
  }

  void _handleDownload(BuildContext context) async {
    final strings = S.of(context);
    HapticFeedback.lightImpact();
    try {
      developer.log('Starting transaction download', name: 'TransactionScreen');
      // Placeholder for actual download logic
      final viewModel = Provider.of<TransactionViewModel>(context, listen: false);
      final transactions = viewModel.getTransactions();
      if (transactions.isEmpty) {
        throw Exception('No transactions to download');
      }

      // Simulate download process (replace with actual implementation)
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.downloadStarted),
          backgroundColor: AppColors.success,
        ),
      );
      developer.log('Download completed successfully', name: 'TransactionScreen');
    } catch (e) {
      developer.log('Download failed: $e', name: 'TransactionScreen', level: 1000);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${strings.messagePdfFailed}: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}