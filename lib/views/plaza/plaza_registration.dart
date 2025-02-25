import 'package:flutter/material.dart';
import 'package:merchant_app/views/plaza/plaza_registration/bank_details.dart';
import 'package:merchant_app/views/plaza/plaza_registration/basic_details.dart';
import 'package:merchant_app/views/plaza/plaza_registration/lane_details.dart';
import 'package:merchant_app/views/plaza/plaza_registration/plaza_images.dart';
import 'package:provider/provider.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import '../../utils/components/button.dart';
import '../../viewmodels/plaza/plaza_viewmodel.dart';

class PlazaRegistrationScreen extends StatelessWidget {
  const PlazaRegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PlazaViewModel()..initControllers(),
      child: const _PlazaRegistrationView(),
    );
  }
}

class _PlazaRegistrationView extends StatelessWidget {
  const _PlazaRegistrationView();

  Widget _buildStepIndicator(
      BuildContext context, int step, String title, bool isCompleted) {
    final viewModel = context.watch<PlazaViewModel>();

    return GestureDetector(
      onTap: () {
        print('completeTillStep: ${viewModel.completeTillStep}');
        print('current step: $step');
        print('isInEdit(): ${viewModel.isInEdit()}');
        print('Should allow tap: ${viewModel.completeTillStep >= step && !viewModel.isInEdit()}');

        if (viewModel.completeTillStep >= step && !viewModel.isInEdit()) {
          viewModel.goToStep(step);
        }
      },
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: viewModel.currentStep == step
                  ? AppColors.primary
                  : AppColors.primary.withOpacity(0.3),
            ),
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white)
                : Center(
              child: Text(
                '${step + 1}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: viewModel.currentStep >= step ? Colors.black : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(BuildContext context) {
    final viewModel = context.watch<PlazaViewModel>();

    switch (viewModel.currentStep) {
      case 0:
        return const BasicDetailsStep();
      case 1:
        return const LaneDetailsStep();
      case 2:
        return BankDetailsStep();
      case 3:
        return const PlazaImagesStep();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PlazaViewModel>();

    return Scaffold(
      appBar: CustomAppBar.appBarWithNavigation(
        screenTitle: "Plaza\nRegistration",
        onPressed: () {
          viewModel.clearErrors();
          Navigator.pop(context);
        },
        darkBackground: true,
      ),
      backgroundColor: AppColors.lightThemeBackground,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStepIndicator(context, 0, 'Basic\nDetails',
                    viewModel.completeTillStep > 0),
                _buildStepIndicator(context, 1, 'Lane\nDetails',
                    viewModel.completeTillStep > 1),
                _buildStepIndicator(context, 2, 'Bank\nDetails',
                    viewModel.completeTillStep > 2),
                _buildStepIndicator(context, 3, 'Plaza\nImages',
                    viewModel.completeTillStep > 3),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              child: _buildStepContent(context),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: CustomButtons.primaryButton(
          onPressed: () async {
            if (viewModel.currentStep == 0) {
              await viewModel.saveBasicDetails(context);
            } else if (viewModel.currentStep == 1) {
              await viewModel.saveLanes(viewModel.plazaId!);
            } else if (viewModel.currentStep == 2) {
              await viewModel.saveBankDetails(context);
            } else if (viewModel.currentStep == 3) {
              await viewModel.saveImages(context);
            } else {
              viewModel.nextStep();
            }
          },
          text: viewModel.currentStep == 0
              ? (viewModel.isBasicDetailsFirstTime
              ? "Save"
              : (viewModel.isBasicDetailsEditable ? "Save" : "Edit"))
              : viewModel.currentStep == 1
              ? (viewModel.isLaneDetailsFirstTime
              ? "Save"
              : (viewModel.isLaneEditable ? "Save" : "Edit"))
              : viewModel.currentStep == 2
              ? (viewModel.isBankDetailsFirstTime
              ? "Save"
              : (viewModel.isBankEditable ? "Save" : "Edit"))
              : viewModel.currentStep == 3 ? "Save" : "Next",
        ),
      ),
    );
  }
}