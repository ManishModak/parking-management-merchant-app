import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/components/appbar.dart';
import '../../../utils/components/form_field.dart';
import '../../../viewmodels/plaza/plaza_viewmodel.dart';

class BankDetailsModificationScreen extends StatefulWidget {
  const BankDetailsModificationScreen({super.key});

  @override
  State<BankDetailsModificationScreen> createState() =>
      _BankDetailsModificationScreenState();
}

class _BankDetailsModificationScreenState
    extends State<BankDetailsModificationScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PlazaViewModel>();
    return Scaffold(
      appBar: CustomAppBar.appBarWithNavigation(
          screenTitle: "Bank Details",
          onPressed: () {
            Navigator.pop(context);
            viewModel.formState.errors.clear();
            viewModel.setBankDetailsEditable(false);
          },
          darkBackground: true
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.all(16), // Consistent padding for the whole form
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Consumer<PlazaViewModel>(
                    builder: (context, viewModel, _) {
                      final plazaName = viewModel.formState.basicDetails['plazaName'] ?? 'Unknown Plaza';
                      final plazaId = viewModel.plazaId ?? "Unknown ID";
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_city,
                                color: Colors.grey.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "$plazaName",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      "ID: $plazaId",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24), // Slightly more space after the card

                  // Bank Name
                  CustomFormFields.primaryFormField(
                    label: 'Bank Name',
                    controller: viewModel.bankNameController,
                    keyboardType: TextInputType.text,
                    isPassword: false,
                    enabled: viewModel.isBankEditable,
                    errorText: viewModel.formState.errors['bankName'],
                  ),
                  const SizedBox(height: 16),

                  // Account Number
                  CustomFormFields.primaryFormField(
                    label: 'Account Number',
                    controller: viewModel.accountNumberController,
                    keyboardType: TextInputType.number,
                    isPassword: false,
                    enabled: viewModel.isBankEditable,
                    errorText: viewModel.formState.errors['accountNumber'],
                  ),
                  const SizedBox(height: 16),

                  // Account Holder Name
                  CustomFormFields.primaryFormField(
                    label: 'Account Holder Name',
                    controller: viewModel.accountHolderController,
                    keyboardType: TextInputType.text,
                    isPassword: false,
                    enabled: viewModel.isBankEditable,
                    errorText: viewModel.formState.errors['accountHolderName'],
                  ),
                  const SizedBox(height: 16),

                  // IFSC Code
                  CustomFormFields.primaryFormField(
                    label: 'IFSC Code',
                    controller: viewModel.ifscCodeController,
                    keyboardType: TextInputType.text,
                    isPassword: false,
                    enabled: viewModel.isBankEditable,
                    errorText: viewModel.formState.errors['ifscCode'],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (viewModel.isBankEditable) ...[
            FloatingActionButton(
              onPressed: () {
                viewModel.cancelBankDetailsEdit();
              },
              heroTag: "cancel_bank",
              backgroundColor: Colors.red,
              child: const Icon(Icons.cancel),
            ),
            const SizedBox(width: 8),
          ],
          FloatingActionButton(
            onPressed: () async {
              if (viewModel.isBankEditable) {
                if (formKey.currentState?.validate() ?? false) {
                  await viewModel.saveBankDetails(context, modify: true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please correct the errors before saving.")),
                  );
                }
              } else {
                viewModel.toggleBankEditable();
              }
            },
            heroTag: "save_bank",
            child: Icon(viewModel.isBankEditable ? Icons.save : Icons.edit),
          ),
        ],
      ),
    );
  }
}
