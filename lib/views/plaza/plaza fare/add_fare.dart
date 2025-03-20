import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:merchant_app/utils/components/button.dart';
import 'package:merchant_app/utils/components/dropdown.dart';
import 'package:merchant_app/viewmodels/plaza_fare_viewmodel.dart';
import 'package:provider/provider.dart';

import '../../../config/app_config.dart';
import '../../../generated/l10n.dart';
import '../../../models/plaza.dart';
import '../../../models/plaza_fare.dart';
import '../../../utils/components/form_field.dart';

class AddFareScreen extends StatefulWidget {
  final Plaza? selectedPlaza; // Optional parameter

  const AddFareScreen({super.key, this.selectedPlaza});

  @override
  State<AddFareScreen> createState() => _AddFareScreenState();
}

class _AddFareScreenState extends State<AddFareScreen> {
  late PlazaFareViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = PlazaFareViewModel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.selectedPlaza != null) {
        // Pre-select the passed plaza.
        viewModel.setPreSelectedPlaza(widget.selectedPlaza!);
        viewModel.initialize();
      } else {
        viewModel.initialize();
      }
    });
  }

  /// Builds a fare card for each PlazaFare.
  Widget _buildFareCard(PlazaFare fare) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
            color: fare.isDeleted ? Colors.red.shade100 : Colors.green.shade100,
            width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: ()  { },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with Plaza Name and Status
                    Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(right: 65),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Plaza Name",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              Text(
                                viewModel.selectedPlaza?.plazaName ??
                                    'Plaza ID: ${fare.plazaId}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          right: 0,
                          child: Container(
                            width: 60,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: fare.isDeleted
                                  ? Colors.red.withOpacity(0.1)
                                  : Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              fare.isDeleted ? 'Inactive' : 'Active',
                              style: TextStyle(
                                color: fare.isDeleted ? Colors.red : Colors.green,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Structured Grid-like Layout
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Vehicle Type',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                fare.vehicleType,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Fare Type',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                fare.fareType,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Amount',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '₹${fare.fareRate}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Effective Period',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '${DateFormat('dd MMM yyyy').format(fare.startEffectDate)} - ${fare.endEffectDate != null ? DateFormat('dd MMM yyyy').format(fare.endEffectDate!) : 'Ongoing'}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 30,
                alignment: Alignment.center,
                child: Icon(
                  Icons.chevron_right,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAddFareDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) => ChangeNotifierProvider.value(
        value: viewModel,
        child: Consumer<PlazaFareViewModel>(
          builder: (context, model, _) => AddFareDialog(viewModel: model),
        ),
      ),
    ).then((_) {
      viewModel.resetFields(); // Reset fields when dialog closes
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Consumer<PlazaFareViewModel>(
        builder: (context, model, child) {
          return Scaffold(
            backgroundColor: AppColors.lightThemeBackground,
            appBar: CustomAppBar.appBarWithNavigation(
              screenTitle: strings.titleAddFare,
              onPressed: () => Navigator.pop(context),
              darkBackground: true, context: context,
            ),
            body: model.isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Center(
                    child: SearchableDropdown(
                      label: 'Select Plaza',
                      value: viewModel.selectedPlazaId,
                      items: viewModel.plazaList,
                      onChanged: (dynamic selected) {
                        if (selected != null) {
                          viewModel.setSelectedPlaza(selected as Plaza);
                        }
                      },
                      itemText: (item) => (item as Plaza).plazaName,
                      itemValue: (item) => (item as Plaza).plazaId!,
                      errorText: viewModel.validationErrors['plaza'],
                      enabled: model.canChangePlaza,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: const Text(
                      'Fares List:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (model.temporaryFares.isEmpty)
                    const Center(
                      child: Text(
                        'No fares added yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: model.temporaryFares.length,
                    itemBuilder: (context, index) =>
                        _buildFareCard(model.temporaryFares[index]),
                  ),
                ],
              ),
            ),
            floatingActionButton: model.canAddFare
                ? FloatingActionButton(
              onPressed: _showAddFareDialog,
              backgroundColor: Colors.green,
              child: const Icon(Icons.add),
            )
                : null,
            bottomNavigationBar: model.temporaryFares.isNotEmpty
                ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: CustomButtons.primaryButton(
                text: "Submit",
                onPressed: () => model.submitAllFares(context), context: context,
              ),
            )
                : null,
          );
        },
      ),
    );
  }
}

class AddFareDialog extends StatelessWidget {
  final PlazaFareViewModel viewModel;

  const AddFareDialog({
    super.key,
    required this.viewModel,
  });

  Future<void> _selectDate(
      BuildContext context,
      TextEditingController controller, {
        DateTime? firstDate,
      }) async {
    DateTime initialDate = DateTime.now();
    DateTime minDate = DateTime.now();

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
        child:   CustomFormFields.normalSizedTextFormField(context:context,

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

  Widget _buildFareInputField(
{
    required String label,
    required TextEditingController controller,
    required String? errorText,
    required BuildContext context,
  }) {
    return   CustomFormFields.normalSizedTextFormField(context:context,

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
              // Dialog header
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
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Plaza (disabled)
              SearchableDropdown(
                label: 'Select Plaza',
                value: viewModel.selectedPlazaId,
                items: viewModel.plazaList,
                onChanged: (dynamic selected) {
                  if (selected != null) {
                    viewModel.setSelectedPlaza(selected as Plaza);
                  }
                },
                itemText: (item) => (item as Plaza).plazaName,
                itemValue: (item) => (item as Plaza).plazaId!,
                errorText: viewModel.validationErrors['plaza'],
                enabled: false,
              ),
              const SizedBox(height: 16),
              // Fare Type dropdown
              CustomDropDown.normalDropDown(context:context,
                label: 'Select Fare Type',
                value: viewModel.selectedFareType,
                items: viewModel.fareTypes,
                onChanged: (value) => viewModel.setFareType(value!),
                icon: Icons.payments_outlined,
                errorText: viewModel.validationErrors['fareType'],
              ),
              const SizedBox(height: 16),
              // Vehicle Type dropdown
              CustomDropDown.normalDropDown(context:context,
                label: 'Select Vehicle Type',
                value: viewModel.selectedVehicleType,
                items: viewModel.vehicleTypes,
                onChanged: (value) => viewModel.setVehicleType(value!),
                icon: Icons.directions_car_outlined,
                errorText: viewModel.validationErrors['vehicleType'],
              ),
              const SizedBox(height: 16),
              // Fare input fields based on fare type.
              if (viewModel.isDailyFareVisible) ...[
                _buildFareInputField(context:context,

                  label: 'Daily Fare',
                  controller: viewModel.dailyFareController,
                  errorText: viewModel.validationErrors['dailyFare'],
                ),
                const SizedBox(height: 16),
              ],
              if (viewModel.isHourlyFareVisible) ...[
                _buildFareInputField(context:context,

                  label: 'Hourly Fare',
                  controller: viewModel.hourlyFareController,
                  errorText: viewModel.validationErrors['hourlyFare'],
                ),
                const SizedBox(height: 16),
              ],
              if (viewModel.isHourWiseCustomVisible) ...[
                _buildFareInputField(context:context,

                  label: 'Base Hours',
                  controller: viewModel.baseHoursController,
                  errorText: viewModel.validationErrors['baseHours'],
                ),
                const SizedBox(height: 16),
                _buildFareInputField(context:context,

                  label: 'Base Hourly Fare',
                  controller: viewModel.baseHourlyFareController,
                  errorText: viewModel.validationErrors['baseHourlyFare'],
                ),
                const SizedBox(height: 16),
                _buildFareInputField(context:context,

                  label: 'Discount for Extended Hours',
                  controller: viewModel.discountController,
                  errorText: viewModel.validationErrors['discount'],
                ),
                const SizedBox(height: 16),
              ],
              if (viewModel.isMonthlyFareVisible) ...[
                _buildFareInputField(context:context,

                  label: 'Monthly Fare',
                  controller: viewModel.monthlyFareController,
                  errorText: viewModel.validationErrors['monthlyFare'],
                ),
                const SizedBox(height: 16),
              ],
              // Date fields
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
              // Inline duplicate error display
              if (viewModel.validationErrors['duplicateFare'] != null) ...[
                Text(
                  viewModel.validationErrors['duplicateFare']!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              // Dialog action buttons
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
  }
}
