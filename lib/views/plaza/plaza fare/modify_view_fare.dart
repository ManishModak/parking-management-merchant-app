import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../generated/l10n.dart';
import '../../../models/plaza_fare.dart';
import '../../../utils/components/appbar.dart';
import '../../../utils/components/dropdown.dart';
import '../../../utils/components/form_field.dart';
import '../../../viewmodels/plaza_fare_viewmodel.dart';

class EditFareScreen extends StatefulWidget {
  final int fareId;
  final int plazaId;

  const EditFareScreen({
    super.key,
    required this.fareId,
    required this.plazaId,
  });

  @override
  State<EditFareScreen> createState() => _EditFareScreenState();
}

class _EditFareScreenState extends State<EditFareScreen> {
  bool isEditing = false;
  late PlazaFareViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<PlazaFareViewModel>(); // Read VM is fine here

    // --- CHANGE HERE ---
    // Schedule the _loadFareData call to happen *after* the first frame is built.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // It's good practice to check if the widget is still mounted before
      // calling async functions in callbacks, although less critical here
      // since _loadFareData already has mounted checks inside.
      if (mounted) {
        developer.log("Post frame callback: Calling _loadFareData", name: "EditFareScreen");
        _loadFareData();
      } else {
        developer.log("Post frame callback: Widget unmounted, skipping _loadFareData", name: "EditFareScreen");
      }
    });
    // --- END CHANGE ---

    developer.log("initState complete for EditFareScreen", name: "EditFareScreen");
  }

  Future<void> _loadFareData() async {
    developer.log("_loadFareData called", name: "EditFareScreen");
    // Check mounted at the beginning, crucial if called from callback
    if (!mounted) {
      developer.log("_loadFareData: Widget unmounted at start.", name: "EditFareScreen");
      return;
    }

    try {
      // This call inside the async function (now running *after* build) is fine
      _viewModel.setLoadingFare(true);
      developer.log("_loadFareData: Fetching fare ID ${widget.fareId}", name: "EditFareScreen");
      final fare = await _viewModel.getFareById(widget.fareId);

      // Check mounted *again* after the await
      if (!mounted) {
        developer.log("_loadFareData: Widget unmounted after fetching fare.", name: "EditFareScreen");
        return;
      }

      if (fare != null) {
        developer.log("_loadFareData: Fare found, populating data.", name: "EditFareScreen");
        _viewModel.populateFareData(fare);
      } else {
        developer.log("_loadFareData: Fare not found (ID: ${widget.fareId}).", name: "EditFareScreen");
        // Optionally show an error message if fare is unexpectedly null
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).errorFareNotFound), backgroundColor: Colors.red), // Add errorFareNotFound string
        );
        // Maybe pop the screen if fare doesn't exist?
        // Navigator.pop(context);
      }
    } catch (e, s) {
      developer.log("_loadFareData: Error loading fare: $e", name: "EditFareScreen", error: e, stackTrace: s);
      // Check mounted before showing snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${S.of(context).errorLoadingFare}: $e')), // Add errorLoadingFare string
        );
      }
    } finally {
      // Check mounted before final state update
      if (mounted) {
        developer.log("_loadFareData: Setting loading fare to false.", name: "EditFareScreen");
        _viewModel.setLoadingFare(false);
      } else {
        developer.log("_loadFareData: Widget unmounted in finally block.", name: "EditFareScreen");
      }
    }
  }

  Future<void> _handleSave() async {
    if (!isEditing) return;

    try {
      final success = await _viewModel.updateFare(
        context,
        widget.fareId,
        widget.plazaId, // Pass the original plaza ID (as int)
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Fare updated successfully")),
          );
          setState(() => isEditing = false);
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to update fare")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error updating fare: $e")),
        );
      }
    }
  }


  Future<bool> _onWillPop() async {
    if (!isEditing) return true;

    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Changes?'),
        content: const Text('Are you sure you want to discard your changes?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    return shouldDiscard ?? false;
  }

  Widget _buildFareFields() {
    return Column(
      children: [
        if (_viewModel.selectedFareType == FareTypes.daily) ...[
          CustomFormFields.normalSizedTextFormField(
            context: context,
            label: "Daily Fare",
            controller: _viewModel.dailyFareController,
            keyboardType: TextInputType.number,
            enabled: isEditing,
            isPassword: false,
          ),
          const SizedBox(height: 16),
        ],
        if (_viewModel.selectedFareType == FareTypes.hourly) ...[
          CustomFormFields.normalSizedTextFormField(
            context: context,
            label: "Hourly Fare",
            controller: _viewModel.hourlyFareController,
            keyboardType: TextInputType.number,
            enabled: isEditing,
            isPassword: false,
          ),
          const SizedBox(height: 16),
        ],
        if (_viewModel.selectedFareType == FareTypes.monthlyPass) ...[
          CustomFormFields.normalSizedTextFormField(
            context: context,
            label: "Monthly Fare",
            controller: _viewModel.monthlyFareController,
            keyboardType: TextInputType.number,
            enabled: isEditing,
            isPassword: false,
          ),
          const SizedBox(height: 16),
        ],
        if (_viewModel.selectedFareType == FareTypes.hourWiseCustom) ...[
          CustomFormFields.normalSizedTextFormField(
            context: context,
            label: "Base Hours",
            controller: _viewModel.baseHoursController,
            keyboardType: TextInputType.number,
            enabled: isEditing,
            isPassword: false,
          ),
          const SizedBox(height: 16),
          CustomFormFields.normalSizedTextFormField(
            context: context,
            label: "Base Hourly Fare",
            controller: _viewModel.baseHourlyFareController,
            keyboardType: TextInputType.number,
            enabled: isEditing,
            isPassword: false,
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    return Consumer<PlazaFareViewModel>(
      builder: (context, viewModel, child) {
        return WillPopScope(
          onWillPop: _onWillPop,
          child: Scaffold(
            appBar: CustomAppBar.appBarWithNavigation(
              screenTitle: strings.menuModifyViewPlazaFare,
              onPressed: () => Navigator.pop(context),
              darkBackground: Theme.of(context).brightness == Brightness.dark,
              context: context,
              fontSize: 16,
            ),
            body: viewModel.isLoadingFare
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CustomDropDown.normalDropDown(
                    context: context,
                    label: "Vehicle Type",
                    items: VehicleTypes.values,
                    value: viewModel.selectedVehicleType,
                    onChanged: null,
                    enabled: false,
                  ),
                  const SizedBox(height: 16),
                  CustomDropDown.normalDropDown(
                    context: context,
                    label: "Fare Type",
                    items: FareTypes.values,
                    value: viewModel.selectedFareType,
                    onChanged: isEditing
                        ? (value) => viewModel.setFareType(value!)
                        : null,
                    enabled: isEditing,
                  ),
                  const SizedBox(height: 16),
                  _buildFareFields(),
                  if (viewModel.selectedFareType == FareTypes.hourWiseCustom) ...[
                    CustomFormFields.normalSizedTextFormField(
                      context: context,
                      label: "Discount Rate",
                      controller: viewModel.discountController,
                      keyboardType: TextInputType.number,
                      enabled: isEditing,
                      isPassword: false,
                    ),
                    const SizedBox(height: 16),
                  ],
                  GestureDetector(
                    onTap: isEditing ? () => viewModel.selectStartDate(context) : null,
                    child: AbsorbPointer(
                      child: CustomFormFields.normalSizedTextFormField(
                        context: context,
                        label: "Start Effect Date",
                        controller: viewModel.startDateController,
                        enabled: false,
                        isPassword: false,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: isEditing ? () => viewModel.selectEndDate(context) : null,
                    child: AbsorbPointer(
                      child: CustomFormFields.normalSizedTextFormField(
                        context: context,
                        label: "End Effect Date",
                        controller: viewModel.endDateController,
                        enabled: false,
                        isPassword: false,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButton: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isEditing) ...[
                  FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        isEditing = false;
                        _loadFareData();
                      });
                    },
                    heroTag: 'cancelFab',
                    backgroundColor: Colors.red,
                    child: const Icon(Icons.close),
                  ),
                  const SizedBox(width: 16),
                ],
                FloatingActionButton(
                  onPressed: viewModel.isUpdating
                      ? null
                      : () {
                    if (isEditing) {
                      _handleSave();
                    } else {
                      setState(() => isEditing = true);
                    }
                  },
                  heroTag: 'mainFab',
                  child: viewModel.isUpdating
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Icon(isEditing ? Icons.save : Icons.edit),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}