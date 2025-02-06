import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:merchant_app/config/app_strings.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:merchant_app/utils/components/button.dart';
import 'package:merchant_app/utils/components/dropdown.dart';
import 'package:merchant_app/viewmodels/plaza_fare_viewmodel.dart';
import 'package:provider/provider.dart';
import '../../config/app_config.dart';
import '../../models/plaza.dart';
import '../../models/plaza_fare.dart';
import '../../utils/components/form_field.dart';

class AddFareScreen extends StatefulWidget {
  const AddFareScreen({super.key});

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
      viewModel.initialize();
    });
  }

  /// Builds a card to display fare information.
  Widget _buildFareCard(PlazaFare fare, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plaza ID
            Text(
              'Plaza ID: ${fare.plazaId}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            // Vehicle and fare type (display enum values as strings)
            Text(
              '${fare.vehicleType.toString().split('.').last} - ${fare.fareType.toString().split('.').last}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            // Fare details based on fare type
            if (fare.fareType == FareType.Fixed24Hour)
              _buildFareDetail('Daily Fare:', '₹${fare.fareRate}'),
            if (fare.fareType == FareType.Hourly)
              _buildFareDetail('Hourly Fare:', '₹${fare.fareRate}'),
            if (fare.fareType == FareType.HourWiseCustom) ...[
              _buildFareDetail('Base Hourly Fare:', '₹${fare.fareRate}'),
              if (fare.baseHours != null)
                _buildFareDetail('Base Hours:', '${fare.baseHours}'),
            ],
            if (fare.fareType == FareType.MonthlyPass)
              _buildFareDetail('Monthly Fare:', '₹${fare.fareRate}'),
            const SizedBox(height: 8),
            // Validity period (using startEffectDate and endEffectDate)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.date_range, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Valid: ${DateFormat('dd MMM yyyy').format(fare.startEffectDate)} to ${fare.endEffectDate != null ? DateFormat('dd MMM yyyy').format(fare.endEffectDate!) : 'N/A'}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper to build a row for a fare detail.
  Widget _buildFareDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Consumer<PlazaFareViewModel>(
        builder: (context, model, child) {
          return Scaffold(
            backgroundColor: AppColors.lightThemeBackground,
            appBar: CustomAppBar.appBarWithNavigation(
              screenTitle: AppStrings.titleAddFare,
              onPressed: () => Navigator.pop(context),
              darkBackground: true,
            ),
            body: model.isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Fares List:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
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
                    itemBuilder: (context, index) => _buildFareCard(
                      model.temporaryFares[index],
                      index,
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: _showAddFareDialog,
              backgroundColor: Colors.green,
              child: const Icon(Icons.add),
            ),
            bottomNavigationBar: model.temporaryFares.isNotEmpty
                ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: CustomButtons.primaryButton(
                text: "Submit",
                onPressed: () => model.submitAllFares(context),
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
      BuildContext context, TextEditingController controller,
      {DateTime? firstDate}) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: firstDate ?? DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      controller.text = formattedDate;
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
              // Plaza selection
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
              if (viewModel.isDailyFareVisible)
                _buildFareInputField(
                  label: 'Daily Fare',
                  controller: viewModel.dailyFareController,
                  errorText: viewModel.validationErrors['dailyFare'],
                ),
              if (viewModel.isHourlyFareVisible)
                _buildFareInputField(
                  label: 'Hourly Fare',
                  controller: viewModel.hourlyFareController,
                  errorText: viewModel.validationErrors['hourlyFare'],
                ),
              if (viewModel.isBaseHourVisible)
                _buildFareInputField(
                  label: 'Base Hourly Fare',
                  controller: viewModel.baseHourlyFareController,
                  errorText: viewModel.validationErrors['baseHourlyFare'],
                ),
              if (viewModel.isMonthlyFareVisible)
                _buildFareInputField(
                  label: 'Monthly Fare',
                  controller: viewModel.monthlyFareController,
                  errorText: viewModel.validationErrors['monthlyFare'],
                ),
              if (viewModel.isBaseHourVisible ||
                  viewModel.isDailyFareVisible ||
                  viewModel.isHourlyFareVisible)
                const SizedBox(height: 16),
              _buildFareInputField(
                label: 'Discount for Extended Hours',
                controller: viewModel.discountController,
                errorText: viewModel.validationErrors['discount'],
              ),
              const SizedBox(height: 16),
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
                    ? DateTime.parse(viewModel.startDateController.text).add(const Duration(days: 1))
                    : DateTime.now(),
                errorText: viewModel.validationErrors['endDate'],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final success = await viewModel.addFareToList(context);
                    if (success && context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Add Fare',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
