import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/config/app_strings.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:merchant_app/utils/components/form_field.dart';
import '../../../viewmodels/ticket/ticket_history_viewmodel.dart';

class ViewTicketScreen extends StatelessWidget {
  const ViewTicketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TicketHistoryViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: CustomAppBar.appBarWithNavigation(
            screenTitle: AppStrings.titleViewTicketDetails,
            onPressed: () => Navigator.pop(context),
            darkBackground: true,
          ),
          backgroundColor: AppColors.lightThemeBackground,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Ticket Details Section
                CustomFormFields.primaryFormField(
                  label: 'Ticket ID',
                  controller: viewModel.ticketIdController,
                  enabled: false,
                  errorText: null,
                  isPassword: false,
                ),
                const SizedBox(height: 16),
                CustomFormFields.primaryFormField(
                  label: 'Plaza ID',
                  controller: viewModel.plazaIdController,
                  enabled: false,
                  errorText: null,
                  isPassword: false,
                ),
                const SizedBox(height: 16),
                CustomFormFields.primaryFormField(
                  label: 'Plaza Name',
                  controller: viewModel.plazaNameController,
                  enabled: false,
                  errorText: null,
                  isPassword: false,
                ),
                const SizedBox(height: 16),
                CustomFormFields.primaryFormField(
                  label: 'Entry Lane ID',
                  controller: viewModel.entryLaneIdController,
                  enabled: false,
                  errorText: null,
                  isPassword: false,
                ),
                const SizedBox(height: 16),
                CustomFormFields.primaryFormField(
                  label: 'Entry Lane Direction',
                  controller: viewModel.entryLaneDirectionController,
                  enabled: false,
                  errorText: null,
                  isPassword: false,
                ),
                const SizedBox(height: 16),
                CustomFormFields.primaryFormField(
                  label: 'Floor ID',
                  controller: viewModel.floorIdController,
                  enabled: false,
                  errorText: null,
                  isPassword: false,
                ),
                const SizedBox(height: 16),
                CustomFormFields.primaryFormField(
                  label: 'Slot ID',
                  controller: viewModel.slotIdController,
                  enabled: false,
                  errorText: null,
                  isPassword: false,
                ),
                const SizedBox(height: 16),
                // Vehicle Details Section
                CustomFormFields.primaryFormField(
                  label: 'Vehicle Number',
                  controller: viewModel.vehicleNumberController,
                  enabled: false,
                  errorText: null,
                  isPassword: false,
                ),
                const SizedBox(height: 16),
                CustomFormFields.primaryFormField(
                  label: 'Vehicle Type',
                  controller: viewModel.vehicleTypeController,
                  enabled: false,
                  errorText: null,
                  isPassword: false,
                ),
                const SizedBox(height: 16),
                // Timestamp Section
                CustomFormFields.primaryFormField(
                  label: 'Entry Time',
                  controller: viewModel.entryTimeController,
                  enabled: false,
                  errorText: null,
                  isPassword: false,
                ),
                const SizedBox(height: 16),
                CustomFormFields.primaryFormField(
                  label: 'Ticket Creation Time',
                  controller: viewModel.ticketCreationTimeController,
                  enabled: false,
                  errorText: null,
                  isPassword: false,
                ),
                const SizedBox(height: 16),
                // Status Section
                CustomFormFields.primaryFormField(
                  label: 'Ticket Status',
                  controller: viewModel.ticketStatusController,
                  enabled: false,
                  errorText: null,
                  isPassword: false,
                ),
                if (viewModel.remarksController.text.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  CustomFormFields.primaryFormField(
                    label: 'Remarks',
                    controller: viewModel.remarksController,
                    enabled: false,
                    errorText: null,
                    isPassword: false,
                    maxLines: 3,
                  ),
                ],
                // Add padding at the bottom for better scrolling
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }
}