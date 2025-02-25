import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/components/form_field.dart';
import '../../../viewmodels/plaza/plaza_viewmodel.dart';

class BankDetailsStep extends StatelessWidget {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  BankDetailsStep({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PlazaViewModel>();

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bank Name
          CustomFormFields.primaryFormField(
            label: 'Bank Name',
            controller: viewModel.bankNameController,
            keyboardType: TextInputType.text,
            isPassword: false,
            enabled: viewModel.currentStep == 2 &&
                (viewModel.completeTillStep <= 2 || viewModel.isBankEditable),
            errorText: viewModel.formState.errors['bankName'],
          ),
          const SizedBox(height: 16),

          // Account Number
          CustomFormFields.primaryFormField(
            label: 'Account Number',
            controller: viewModel.accountNumberController,
            keyboardType: TextInputType.number,
            isPassword: false,
            enabled: viewModel.currentStep == 2 &&
                (viewModel.completeTillStep <= 2 || viewModel.isBankEditable),
            errorText: viewModel.formState.errors['accountNumber'],
          ),
          const SizedBox(height: 16),

          // Account Holder Name
          CustomFormFields.primaryFormField(
            label: 'Account Holder Name',
            controller: viewModel.accountHolderController,
            keyboardType: TextInputType.text,
            isPassword: false,
            enabled: viewModel.currentStep == 2 &&
                (viewModel.completeTillStep <= 2 || viewModel.isBankEditable),
            errorText: viewModel.formState.errors['accountHolderName'],
          ),
          const SizedBox(height: 16),

          // IFSC Code
          CustomFormFields.primaryFormField(
            label: 'IFSC Code',
            controller: viewModel.ifscCodeController,
            keyboardType: TextInputType.text,
            isPassword: false,
            enabled: viewModel.currentStep == 2 &&
                (viewModel.completeTillStep <= 2 || viewModel.isBankEditable),
            errorText: viewModel.formState.errors['ifscCode'],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
