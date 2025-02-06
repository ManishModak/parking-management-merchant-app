import 'package:flutter/material.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:merchant_app/utils/components/button.dart';
import 'package:merchant_app/utils/components/card.dart';
import 'package:merchant_app/viewmodels/transaction_viewmodel.dart';
import 'package:provider/provider.dart';

class TransactionScreen extends StatelessWidget {
  const TransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.appBarWithActions(
          screenTitle: 'Transactions',
          darkBackground: false,
          actions: [
            CustomButtons.downloadIconButton(
                onPressed: () {}, darkBackground: false),
            const SizedBox(
              width: 10,
            )
          ]),
      body: Consumer<TransactionViewModel>(
        builder: (context, viewModel, child) {
          final transactions = viewModel.getTransactions();

          if (transactions.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.payment, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No transactions'),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: transactions.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return const SizedBox(height: 16); // Adding space before the first card
              }
              final transaction = transactions[index - 1];
              return CustomCards.transactionCard(
                  transaction: transaction, context: context);
            },
          );
        },
      ),
    );
  }
}