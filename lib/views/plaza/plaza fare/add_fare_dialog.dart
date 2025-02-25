import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../config/app_config.dart';
import '../../../utils/components/form_field.dart';
import '../../../utils/components/dropdown.dart';
import '../../../viewmodels/plaza_fare_viewmodel.dart';

class AddFareDialog extends StatelessWidget {
  const AddFareDialog({super.key});

  Future<void> _selectDate(
      BuildContext context,
      TextEditingController controller, {
        DateTime? firstDate,
      }) async {
    // Use the viewmodel from the provider
    final viewModel = Provider.of<PlazaFareViewModel>(context, listen: false);
    DateTime initialDate = DateTime.now();
    DateTime minDate = DateTime.now();

    // For the end date field, if the start date is provided, update the minimum date.
    if (firstDate != null &&
        controller == viewModel.endDateController &&
        viewModel.startDateController.text.isNotEmpty) {
      minDate = DateTime.parse(viewModel.startDateController.text)
          .add(const Duration(days: 1));
      initialDate = minDate;
    }

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: minDate,
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
    }
  }

  Widget _buildDateField({
    required String label,
    required TextEditingController controller,
    required BuildContext context,
    DateTime? firstDate,
    String? errorText,
  }) {
    return GestureDetector(
      onTap: () => _selectDate(context, controller, firstDate: firstDate),
      child: AbsorbPointer(
        child: CustomFormFields.primaryFormField(
          label: label,
          controller: controller,
          errorText: errorText,
          keyboardType: TextInputType.datetime,
          isPassword: false,
          enabled: true,
        ),
      ),
    );
  }

  Widget _buildFareInputField({
    required String label,
    required TextEditingController controller,
    required String? errorText,
  }) {
    return CustomFormFields.primaryFormField(
      label: label,
      controller: controller,
      errorText: errorText,
      keyboardType: TextInputType.number,
      isPassword: false,
      enabled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listen to the viewmodel so that the dialog rebuilds when data changes.
    return Consumer<PlazaFareViewModel>(
      builder: (context, viewModel, child) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          insetPadding: EdgeInsets.zero,
          child: SizedBox(
            width: AppConfig.deviceWidth * 0.9,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Add New Fare',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Plaza is already selected; show its name in a disabled field.
                  CustomFormFields.primaryFormField(
                    label: 'Plaza',
                    controller: viewModel.plazaController,
                    enabled: false, isPassword: false,
                  ),
                  const SizedBox(height: 16),
                  // Fare type dropdown
                  CustomDropDown.normalDropDown(
                    label: 'Select Fare Type',
                    value: viewModel.selectedFareType,
                    items: viewModel.fareTypes,
                    onChanged: (value) => viewModel.setFareType(value!),
                    icon: Icons.payments_outlined,
                    errorText: viewModel.validationErrors['fareType'],
                  ),
                  const SizedBox(height: 16),
                  // Vehicle type dropdown
                  CustomDropDown.normalDropDown(
                    label: 'Select Vehicle Type',
                    value: viewModel.selectedVehicleType,
                    items: viewModel.vehicleTypes,
                    onChanged: (value) => viewModel.setVehicleType(value!),
                    icon: Icons.directions_car_outlined,
                    errorText: viewModel.validationErrors['vehicleType'],
                  ),
                  const SizedBox(height: 16),
                  // Conditionally display fare amount input fields
                  if (viewModel.isDailyFareVisible) ...[
                    _buildFareInputField(
                      label: 'Daily Fare',
                      controller: viewModel.dailyFareController,
                      errorText: viewModel.validationErrors['dailyFare'],
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (viewModel.isHourlyFareVisible) ...[
                    _buildFareInputField(
                      label: 'Hourly Fare',
                      controller: viewModel.hourlyFareController,
                      errorText: viewModel.validationErrors['hourlyFare'],
                    ),
                    const SizedBox(height: 16),
                  ],


                  if (viewModel.isHourWiseCustomVisible) ...[
                    _buildFareInputField(
                      label: 'Base Hours',
                      controller: viewModel.baseHoursController,
                      errorText: viewModel.validationErrors['baseHours'],
                    ),
                    const SizedBox(height: 16),
                    _buildFareInputField(
                      label: 'Base Hourly Fare',
                      controller: viewModel.baseHourlyFareController,
                      errorText: viewModel.validationErrors['baseHourlyFare'],
                    ),
                    const SizedBox(height: 16),
                    _buildFareInputField(
                      label: 'Discount for Extended Hours',
                      controller: viewModel.discountController,
                      errorText: viewModel.validationErrors['discount'],
                    ),
                    const SizedBox(height: 16),
                  ],


                  if (viewModel.isMonthlyFareVisible) ...[
                    _buildFareInputField(
                      label: 'Monthly Fare',
                      controller: viewModel.monthlyFareController,
                      errorText: viewModel.validationErrors['monthlyFare'],
                    ),
                    const SizedBox(height: 16),
                  ],
                  // Date fields for effective period
                  _buildDateField(
                    label: 'Effective Start Date',
                    controller: viewModel.startDateController,
                    context: context,
                    firstDate: DateTime.now(),
                    errorText: viewModel.validationErrors['startDate'],
                  ),
                  const SizedBox(height: 16),
                  _buildDateField(
                    label: 'Effective End Date',
                    controller: viewModel.endDateController,
                    context: context,
                    firstDate: viewModel.startDateController.text.isNotEmpty
                        ? DateTime.parse(viewModel.startDateController.text)
                        .add(const Duration(days: 1))
                        : DateTime.now(),
                    errorText: viewModel.validationErrors['endDate'],
                  ),
                  const SizedBox(height: 24),
                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () async {
                          final success = await viewModel.addFareToList(context);
                          if (success && context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                        child: const Text("Save"),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
