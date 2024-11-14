import 'package:flutter/material.dart';
import 'package:merchant_app/utils/components/appbar.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.appBarWithTitle(
          screenTitle: 'Transactions', darkBackground: false),
    );
  }
}
