import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// Import FareTypes
import 'package:provider/provider.dart';
import '../../../config/app_config.dart';
import '../../../generated/l10n.dart'; // Import S for localization
import '../../../utils/components/form_field.dart';
import '../../../utils/components/dropdown.dart';
import '../../../viewmodels/plaza_fare_viewmodel.dart';

class AddFareDialog extends StatelessWidget {
  // Removed the viewModel parameter, as it's accessed via Consumer
  const AddFareDialog({super.key});

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller, {
    DateTime? firstDate,
  }) async {
    // Use the viewmodel from the provider
    final viewModel = Provider.of<PlazaFareViewModel>(context, listen: false);
    DateTime initialDate = DateTime.now();
    // Start date can be today
    DateTime minDate = DateTime.now();

    // For the end date field, if the start date is provided, update the minimum date.
    if (firstDate != null &&
        controller == viewModel.endDateController &&
        viewModel.startDateController.text.isNotEmpty) {
      try {
        final startDate = DateTime.parse(viewModel.startDateController.text);
        // End date must be strictly after start date
        minDate = startDate.add(const Duration(days: 1));
        initialDate = minDate;
      } catch (e) {
        // Handle parse error if start date is invalid, maybe default minDate
        print("Error parsing start date for end date picker: $e");
        minDate = DateTime.now().add(const Duration(days: 1)); // Fallback
        initialDate = minDate;
      }
    }

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: minDate, // Ensure firstDate is respected
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      // Check if the controller's text actually needs updating
      if (controller.text != formattedDate) {
        controller.text = formattedDate;
        // Trigger validation removal or re-evaluation in ViewModel if needed
        // Example: viewModel.validateSingleField('endDate');
        // No direct notifyListeners call here, ViewModel handles state changes
      }
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
        child: CustomFormFields.normalSizedTextFormField(
          context: context,
          label: label,
          controller: controller,
          errorText: errorText,
          keyboardType: TextInputType.datetime,
          isPassword: false,
          enabled:
              true, // Keep enabled visually, AbsorbPointer prevents interaction
          // Add suffix icon for calendar visual cue
          suffixIcon: Icon(Icons.calendar_today,
              size: 20,
              color: Theme.of(context).iconTheme.color?.withOpacity(0.6)),
        ),
      ),
    );
  }

  Widget _buildNumericInputField({
    required String label,
    required TextEditingController controller,
    required String? errorText,
    required BuildContext context,
    TextInputType keyboardType =
        TextInputType.number, // Allow specifying keyboard type
  }) {
    return CustomFormFields.normalSizedTextFormField(
      context: context,
      label: label,
      controller: controller,
      errorText: errorText,
      keyboardType: keyboardType,
      isPassword: false,
      enabled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context); // For localized labels if needed
    // Listen to the viewmodel so that the dialog rebuilds when data changes.
    return Consumer<PlazaFareViewModel>(
      builder: (context, viewModel, child) {
        return Dialog(
          shape: Theme.of(context).dialogTheme.shape ??
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          insetPadding:
              EdgeInsets.zero, // Consider some padding like EdgeInsets.all(20)
          backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
          child: SizedBox(
            width: AppConfig.deviceWidth * 0.9,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20), // Increased padding
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        strings.dialogTitleAddNewFare, // Use localized string
                        style: Theme.of(context).dialogTheme.titleTextStyle ??
                            Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        // Provide visual feedback on hover/press
                        splashRadius: 20,
                        icon: Icon(Icons.close,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7)),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20), // Increased spacing

                  // Plaza is already selected; show its name in a disabled field.
                  // Consider using SearchableDropdown with enabled: false if consistency is desired
                  CustomFormFields.normalSizedTextFormField(
                    context: context,
                    label: strings.labelPlaza, // Localized
                    controller: viewModel.plazaController,
                    enabled: false, isPassword: false, // Visually disabled
                    // prefixIcon: Icons.business_outlined, // Add icon
                  ),
                  const SizedBox(height: 16),

                  // Fare type dropdown
                  CustomDropDown.normalDropDown(
                    context: context,
                    label: strings.labelSelectFareType, // Localized
                    value: viewModel.selectedFareType,
                    items: viewModel.fareTypes,
                    onChanged: (value) => viewModel.setFareType(value!),
                    icon: Icons.payments_outlined,
                    errorText: viewModel.validationErrors['fareType'],
                  ),
                  const SizedBox(height: 16),

                  // Vehicle type dropdown
                  CustomDropDown.normalDropDown(
                    context: context,
                    label: strings.labelSelectVehicleType, // Localized
                    value: viewModel.selectedVehicleType,
                    items: viewModel.vehicleTypes,
                    onChanged: (value) => viewModel.setVehicleType(value!),
                    icon: Icons.directions_car_outlined,
                    errorText: viewModel.validationErrors['vehicleType'],
                  ),
                  const SizedBox(height: 16),

                  // --- CONDITIONAL FIELDS START ---

                  // Fields specific to PROGRESSIVE fare type
                  if (viewModel.isProgressiveFareVisible) ...[
                    _buildNumericInputField(
                      context: context,
                      label: strings.labelFromMinutes, // Localized
                      controller: viewModel.fromController,
                      errorText: viewModel.validationErrors['from'],
                      keyboardType: TextInputType.number, // Ensure number pad
                    ),
                    const SizedBox(height: 16),
                    _buildNumericInputField(
                      context: context,
                      label: strings.labelToMinutes, // Localized
                      controller: viewModel.toCustomController,
                      errorText: viewModel.validationErrors['toCustom'],
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    _buildNumericInputField(
                      context: context,
                      label: strings
                          .labelFareAmount, // Localized (Generic Fare Amount)
                      controller: viewModel.progressiveFareController,
                      errorText:
                          viewModel.validationErrors['progressiveFare'] ??
                              viewModel.validationErrors[
                                  'fareRate'], // Show specific or generic error
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Fields for standard fare types (NOT Progressive or FreePass)
                  if (!viewModel.isProgressiveFareVisible &&
                      !viewModel.isFreePassSelected) ...[
                    // Daily Fare
                    if (viewModel.isDailyFareVisible) ...[
                      _buildNumericInputField(
                        context: context,
                        label: strings.labelDailyFare, // Localized
                        controller: viewModel.dailyFareController,
                        errorText: viewModel.validationErrors['dailyFare'],
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Hourly Fare
                    if (viewModel.isHourlyFareVisible) ...[
                      _buildNumericInputField(
                        context: context,
                        label: strings.labelHourlyFare, // Localized
                        controller: viewModel.hourlyFareController,
                        errorText: viewModel.validationErrors['hourlyFare'],
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Hour-wise Custom Fields
                    if (viewModel.isHourWiseCustomVisible) ...[
                      _buildNumericInputField(
                        context: context,
                        label: strings.labelBaseHours, // Localized
                        controller: viewModel.baseHoursController,
                        errorText: viewModel.validationErrors['baseHours'],
                        keyboardType: TextInputType.number, // Integer only
                      ),
                      const SizedBox(height: 16),
                      _buildNumericInputField(
                        context: context,
                        label: strings.labelBaseHourlyFare, // Localized
                        controller: viewModel.baseHourlyFareController,
                        errorText: viewModel.validationErrors['baseHourlyFare'],
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                      ),
                      const SizedBox(height: 16),
                      _buildNumericInputField(
                        context: context,
                        label: strings.labelDiscountExtendedHours, // Localized
                        controller: viewModel.discountController,
                        errorText: viewModel.validationErrors['discount'],
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Monthly Fare
                    if (viewModel.isMonthlyFareVisible) ...[
                      _buildNumericInputField(
                        context: context,
                        label: strings.labelMonthlyFare, // Localized
                        controller: viewModel.monthlyFareController,
                        errorText: viewModel.validationErrors['monthlyFare'],
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ], // End standard fare types condition

                  // --- CONDITIONAL FIELDS END ---

                  // --- Common Fields (Dates) ---
                  _buildDateField(
                    label: strings.labelEffectiveStartDate, // Localized
                    controller: viewModel.startDateController,
                    context: context,
                    // firstDate: DateTime.now(), // Let ViewModel handle logic
                    errorText: viewModel.validationErrors['startDate'],
                  ),
                  const SizedBox(height: 16),
                  _buildDateField(
                    label: strings.labelEffectiveEndDate, // Localized
                    controller: viewModel.endDateController,
                    context: context,
                    // Let ViewModel handle logic based on start date
                    firstDate: viewModel.startDateController.text.isNotEmpty
                        ? DateTime.tryParse(viewModel.startDateController.text)
                        : null,
                    errorText: viewModel.validationErrors['endDate'],
                  ),
                  const SizedBox(height: 24),

                  // --- Validation Error Display ---
                  if (viewModel.validationErrors['duplicateFare'] != null ||
                      viewModel.validationErrors['dateOverlap'] != null) ...[
                    Text(
                      // Show whichever error is present, or combine them if needed
                      viewModel.validationErrors['duplicateFare'] ??
                          viewModel.validationErrors['dateOverlap']!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (viewModel.validationErrors['general'] != null) ...[
                    Text(
                      viewModel.validationErrors['general']!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                  ],

                  // --- Action Buttons ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(strings.buttonCancel), // Localized
                        // style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.secondary), // Optional styling
                      ),
                      const SizedBox(width: 8),
                      // Consider ElevatedButton for the primary action
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                        ),
                        onPressed: () async {
                          final success =
                              await viewModel.addFareToList(context);
                          if (success && context.mounted) {
                            Navigator.pop(
                                context); // Close dialog only on success
                          }
                        },
                        child: Text(strings.buttonSave), // Localized
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
