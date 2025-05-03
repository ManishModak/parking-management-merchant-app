import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:merchant_app/models/plaza_fare.dart'; // Import FareTypes
import 'package:provider/provider.dart';
import '../../../generated/l10n.dart';
// import '../../../models/plaza_fare.dart'; // Already imported above
import '../../../utils/components/appbar.dart';
import '../../../utils/components/dropdown.dart';
import '../../../utils/components/form_field.dart';
import '../../../viewmodels/plaza_fare_viewmodel.dart';

class EditFareScreen extends StatefulWidget {
  final int fareId;
  final int plazaId; // Passed as int

  const EditFareScreen({
    super.key,
    required this.fareId,
    required this.plazaId, // Expecting int
  });

  @override
  State<EditFareScreen> createState() => _EditFareScreenState();
}

class _EditFareScreenState extends State<EditFareScreen> {
  bool isEditing = false;
  // ViewModel accessed via Consumer/Provider.of, no need for late final here
  // late PlazaFareViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    // Use read here as it's outside the build method and only needed for initial load trigger.
    final viewModel = context.read<PlazaFareViewModel>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        developer.log("Post frame callback: Calling _loadFareData", name: "EditFareScreen");
        // Pass context for potential snackbars during loading
        _loadFareData(context);
      } else {
        developer.log("Post frame callback: Widget unmounted, skipping _loadFareData", name: "EditFareScreen");
      }
    });

    developer.log("initState complete for EditFareScreen", name: "EditFareScreen");
  }

  // Pass BuildContext for showing errors during load
  Future<void> _loadFareData(BuildContext context) async {
    developer.log("_loadFareData called", name: "EditFareScreen");
    final viewModel = context.read<PlazaFareViewModel>(); // Read VM instance
    final strings = S.of(context); // Get localization instance

    if (!mounted) {
      developer.log("_loadFareData: Widget unmounted at start.", name: "EditFareScreen");
      return;
    }

    try {
      // ViewModel handles setting its own loading state now
      // viewModel.setLoadingFare(true); // Let getFareById handle this
      developer.log("_loadFareData: Fetching fare ID ${widget.fareId}", name: "EditFareScreen");
      final fare = await viewModel.getFareById(widget.fareId);

      // Check mounted *again* after the await
      if (!mounted) {
        developer.log("_loadFareData: Widget unmounted after fetching fare.", name: "EditFareScreen");
        return;
      }

      if (fare != null) {
        developer.log("_loadFareData: Fare found, populating data.", name: "EditFareScreen");
        // Also pass the plaza name to potentially update the disabled plaza field
        // Fetch plaza details if needed or assume VM can get it? For now, just populate fare.
        viewModel.populateFareData(fare);
        // If the screen has a plaza name display, update it here or in populateFareData
        // viewModel.setPlazaName(plazaNameFromSomewhere);
      } else {
        developer.log("_loadFareData: Fare not found (ID: ${widget.fareId}).", name: "EditFareScreen");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.errorFareNotFound), backgroundColor: Colors.red),
        );
        // Pop the screen if fare doesn't exist
        Navigator.pop(context);
      }
    } catch (e, s) {
      developer.log("_loadFareData: Error loading fare: $e", name: "EditFareScreen", error: e, stackTrace: s);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${strings.errorLoadingFare}: $e'), backgroundColor: Colors.red),
        );
        // Maybe pop on error too?
        // Navigator.pop(context);
      }
    } finally {
      // Loading state is handled internally by getFareById now
      // if (mounted) {
      //   developer.log("_loadFareData: Setting loading fare to false.", name: "EditFareScreen");
      //   viewModel.setLoadingFare(false);
      // } else {
      //   developer.log("_loadFareData: Widget unmounted in finally block.", name: "EditFareScreen");
      // }
    }
  }

  // Handles saving the changes
  Future<void> _handleSave() async {
    final viewModel = context.read<PlazaFareViewModel>(); // Read VM instance
    final strings = S.of(context); // Get localization instance
    if (!isEditing || viewModel.isUpdating) return; // Prevent double taps

    developer.log("Handling Save...", name: "EditFareScreen");

    try {
      // ViewModel's updateFare now handles validation internally
      final success = await viewModel.updateFare(
        context, // Pass context for potential dialogs/snackbars inside updateFare
        widget.fareId,
        widget.plazaId, // Pass the original plaza ID (as int)
      );

      // Check mounted after async gap
      if (!mounted) return;

      if (success) {
        developer.log("Save successful, exiting edit mode.", name: "EditFareScreen");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.successFareUpdated), backgroundColor: Colors.green),
        );
        setState(() => isEditing = false);
        Navigator.pop(context, true); // Pop screen and indicate success
      } else {
        developer.log("Save failed (updateFare returned false).", name: "EditFareScreen");
        // ViewModel's updateFare should have shown an error dialog/snackbar
        // Optionally show a generic one here if VM doesn't always.
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text(strings.errorUpdateFailed), backgroundColor: Colors.red),
        // );
      }
    } catch (e) {
      developer.log("Error during save operation: $e", name: "EditFareScreen");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${strings.errorUpdateFailed}: $e"), backgroundColor: Colors.red),
        );
      }
    }
    // No need for finally block to set isUpdating=false, VM handles it
  }

  // Handles back button press confirmation when editing
  Future<bool> _onWillPop() async {
    if (!isEditing) return true; // Allow pop if not editing

    final strings = S.of(context); // Get localization instance
    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.dialogTitleDiscardChanges),
        content: Text(strings.dialogMessageDiscardChanges),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Don't discard
            child: Text(strings.buttonNo),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), // Discard
            child: Text(strings.buttonYes),
          ),
        ],
      ),
    );

    return shouldDiscard ?? false; // Return true only if 'Yes' was pressed
  }

  // Builds the main fare input fields based on selected fare type
  Widget _buildFareFields(PlazaFareViewModel viewModel, S strings) {
    return Column(
      children: [
        // --- PROGRESSIVE FIELDS ---
        if (viewModel.isProgressiveFareVisible) ...[
          CustomFormFields.normalSizedTextFormField(
            context: context,
            label: strings.labelFromMinutes,
            controller: viewModel.fromController,
            keyboardType: TextInputType.number,
            enabled: isEditing,
            isPassword: false,
            errorText: viewModel.validationErrors['from'],
          ),
          const SizedBox(height: 16),
          CustomFormFields.normalSizedTextFormField(
            context: context,
            label: strings.labelToMinutes,
            controller: viewModel.toCustomController,
            keyboardType: TextInputType.number,
            enabled: isEditing,
            isPassword: false,
            errorText: viewModel.validationErrors['toCustom'],
          ),
          const SizedBox(height: 16),
          CustomFormFields.normalSizedTextFormField(
            context: context,
            label: strings.labelFareAmount, // Generic Fare Amount
            controller: viewModel.progressiveFareController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            enabled: isEditing,
            isPassword: false,
            errorText: viewModel.validationErrors['progressiveFare'] ?? viewModel.validationErrors['fareRate'],
          ),
          const SizedBox(height: 16),
        ],

        // --- STANDARD FIELDS (Not Progressive or FreePass) ---
        if (!viewModel.isProgressiveFareVisible && !viewModel.isFreePassSelected) ...[
          // Daily
          if (viewModel.isDailyFareVisible) ...[
            CustomFormFields.normalSizedTextFormField(
              context: context,
              label: strings.labelDailyFare,
              controller: viewModel.dailyFareController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              enabled: isEditing,
              isPassword: false,
              errorText: viewModel.validationErrors['dailyFare'],
            ),
            const SizedBox(height: 16),
          ],
          // Hourly
          if (viewModel.isHourlyFareVisible) ...[
            CustomFormFields.normalSizedTextFormField(
              context: context,
              label: strings.labelHourlyFare,
              controller: viewModel.hourlyFareController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              enabled: isEditing,
              isPassword: false,
              errorText: viewModel.validationErrors['hourlyFare'],
            ),
            const SizedBox(height: 16),
          ],
          // Monthly
          if (viewModel.isMonthlyFareVisible) ...[
            CustomFormFields.normalSizedTextFormField(
              context: context,
              label: strings.labelMonthlyFare,
              controller: viewModel.monthlyFareController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              enabled: isEditing,
              isPassword: false,
              errorText: viewModel.validationErrors['monthlyFare'],
            ),
            const SizedBox(height: 16),
          ],
          // Hour-wise Custom
          if (viewModel.isHourWiseCustomVisible) ...[
            CustomFormFields.normalSizedTextFormField(
              context: context,
              label: strings.labelBaseHours,
              controller: viewModel.baseHoursController,
              keyboardType: TextInputType.number,
              enabled: isEditing,
              isPassword: false,
              errorText: viewModel.validationErrors['baseHours'],
            ),
            const SizedBox(height: 16),
            CustomFormFields.normalSizedTextFormField(
              context: context,
              label: strings.labelBaseHourlyFare,
              controller: viewModel.baseHourlyFareController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              enabled: isEditing,
              isPassword: false,
              errorText: viewModel.validationErrors['baseHourlyFare'],
            ),
            const SizedBox(height: 16),
            // Discount (Only show for Hour-wise Custom based on original logic)
            // If Discount applies to others (Daily, Hourly, Monthly), move this outside the HourWiseCustom check
            CustomFormFields.normalSizedTextFormField(
              context: context,
              label: strings.labelDiscountExtendedHours, // Or just "Discount Rate"
              controller: viewModel.discountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              enabled: isEditing,
              isPassword: false,
              errorText: viewModel.validationErrors['discount'],
            ),
            const SizedBox(height: 16),
          ],
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    // Use Consumer to listen to ViewModel changes
    return Consumer<PlazaFareViewModel>(
      builder: (context, viewModel, child) {
        // Use WillPopScope to intercept back navigation when editing
        return WillPopScope(
          onWillPop: _onWillPop,
          child: Scaffold(
            appBar: CustomAppBar.appBarWithNavigation(
              screenTitle: isEditing ? strings.titleEditFare : strings.titleViewFare, // Dynamic title
              onPressed: () async {
                // Handle back press: ask for confirmation if editing, otherwise just pop
                if (await _onWillPop()) {
                  Navigator.pop(context);
                }
              },
              darkBackground: Theme.of(context).brightness == Brightness.dark,
              context: context,
              fontSize: 16, // Keep font size if needed
            ),
            // Show loading indicator while fetching fare data initially
            body: viewModel.isLoadingFare // Use specific loader for initial fetch
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Plaza Name (Display Only - cannot change Plaza when editing a fare)
                  CustomFormFields.normalSizedTextFormField(
                    context: context,
                    label: strings.labelPlaza,
                    controller: viewModel.plazaController, // Controller displays the name
                    enabled: false, // Always disabled
                    isPassword: false,
                  ),
                  const SizedBox(height: 16),

                  // Vehicle Type (Display Only - cannot change Vehicle Type)
                  CustomDropDown.normalDropDown(
                    context: context,
                    label: strings.labelVehicleType,
                    items: VehicleTypes.values, // Use constant from model
                    value: viewModel.selectedVehicleType,
                    onChanged: null, // Not changeable
                    enabled: false, // Visually disabled
                    errorText: viewModel.validationErrors['vehicleType'], // Show error if somehow invalid
                  ),
                  const SizedBox(height: 16),

                  // Fare Type (Can be changed when editing)
                  CustomDropDown.normalDropDown(
                    context: context,
                    label: strings.labelFareType,
                    items: FareTypes.values, // Use constant from model
                    value: viewModel.selectedFareType,
                    // Allow changing only when in editing mode
                    onChanged: isEditing
                        ? (value) {
                      if (value != null) {
                        viewModel.setFareType(value);
                      }
                    }
                        : null, // Disable changing if not editing
                    enabled: isEditing, // Enable dropdown only when editing
                    errorText: viewModel.validationErrors['fareType'],
                  ),
                  const SizedBox(height: 16),

                  // Dynamically build fare amount/time fields
                  _buildFareFields(viewModel, strings),

                  // --- Date Fields (Common) ---
                  GestureDetector(
                    onTap: isEditing ? () => viewModel.selectStartDate(context) : null,
                    child: AbsorbPointer(
                      child: CustomFormFields.normalSizedTextFormField(
                        context: context,
                        label: strings.labelEffectiveStartDate,
                        controller: viewModel.startDateController,
                        enabled: false, // Visually disabled, tap handled by GestureDetector
                        isPassword: false,
                        errorText: viewModel.validationErrors['startDate'],
                        suffixIcon: isEditing ? Icon(Icons.calendar_today, size: 20) : null, // Show icon only when editable
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: isEditing ? () => viewModel.selectEndDate(context) : null,
                    child: AbsorbPointer(
                      child: CustomFormFields.normalSizedTextFormField(
                        context: context,
                        label: strings.labelEffectiveEndDate,
                        controller: viewModel.endDateController,
                        enabled: false, // Visually disabled, tap handled by GestureDetector
                        isPassword: false,
                        errorText: viewModel.validationErrors['endDate'],
                        suffixIcon: isEditing ? Icon(Icons.calendar_today, size: 20) : null, // Show icon only when editable
                      ),
                    ),
                  ),
                  const SizedBox(height: 80), // Space for FABs
                ],
              ),
            ),
            // Floating Action Buttons for Edit/Save/Cancel
            floatingActionButton: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Show Cancel button only when editing
                if (isEditing) ...[
                  FloatingActionButton.extended(
                    onPressed: () {
                      // Ask for confirmation before discarding changes
                      _onWillPop().then((discard) {
                        if (discard) {
                          setState(() {
                            isEditing = false;
                            // Reload original data to discard changes
                            _loadFareData(context);
                          });
                        }
                      });
                    },
                    heroTag: 'cancelFab', // Unique tag
                    backgroundColor: Colors.grey[600],
                    icon: const Icon(Icons.close),
                    label: Text(strings.buttonCancel),
                  ),
                  const SizedBox(width: 16),
                ],
                // Main FAB: Edit or Save
                FloatingActionButton.extended(
                  // Disable button while saving
                  onPressed: viewModel.isUpdating ? null : () {
                    if (isEditing) {
                      // Trigger save action
                      _handleSave();
                    } else {
                      // Enter editing mode
                      setState(() => isEditing = true);
                    }
                  },
                  heroTag: 'mainEditSaveFab', // Unique tag
                  backgroundColor: isEditing ? Colors.green : Theme.of(context).colorScheme.primary,
                  // Show progress indicator while saving
                  icon: viewModel.isUpdating
                      ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                      : Icon(isEditing ? Icons.save_outlined : Icons.edit_outlined),
                  label: Text(isEditing ? strings.buttonSave : strings.buttonEdit),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}