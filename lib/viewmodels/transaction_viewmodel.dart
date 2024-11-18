import 'package:flutter/material.dart';
import 'package:merchant_app/models/transaction_model.dart';

class TransactionViewModel extends ChangeNotifier {
  List<TransactionModel> transactions = [
    TransactionModel(
      id: '1',
      title: 'Payment for Booking #BK001',
      amount: 150,
      date: DateTime.now().subtract(const Duration(hours: 1)),
      type: TransactionType.payment,
    ),
    TransactionModel(
      id: '2',
      title: 'Refund for Booking #BK002',
      amount: 50,
      date: DateTime.now().subtract(const Duration(days: 1)),
      type: TransactionType.refund,
    ),
    TransactionModel(
      id: '3',
      title: 'Payment for Booking #BK003',
      amount: 200,
      date: DateTime.now().subtract(const Duration(days: 2)),
      type: TransactionType.payment,
    ),
  ];

  bool isLoading = false;
  String? errorMessage;

  List<TransactionModel> getTransactions() {
    return transactions;
  }

  void addTransaction(TransactionModel transaction) {
    transactions.add(transaction);
    notifyListeners();
  }

  void deleteTransaction(String transactionId) {
    transactions.removeWhere((t) => t.id == transactionId);
    notifyListeners();
  }
}
