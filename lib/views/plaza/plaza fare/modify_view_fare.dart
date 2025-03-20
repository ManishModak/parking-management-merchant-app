import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/plaza_fare.dart';
import '../../../utils/components/appbar.dart';
import '../../../utils/components/dropdown.dart';
import '../../../utils/components/form_field.dart';
import '../../../viewmodels/plaza_fare_viewmodel.dart';

class EditFareScreen extends StatefulWidget {
  final int fareId;

  const EditFareScreen({
    super.key,
    required this.fareId,
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
    _viewModel = context.read<PlazaFareViewModel>();
    _loadFareData();
  }

  Future<void> _loadFareData() async {
    _viewModel.setLoadingFare(true);
    final fare = await _viewModel.getFareById(widget.fareId);
    if (mounted && fare != null) {
      _viewModel.populateFareData(fare);
    }
    if (mounted) {
      _viewModel.setLoadingFare(false);
    }
  }

  void _handleSave() async {
    if (!isEditing) return;

    final success = await _viewModel.updateFare(widget.fareId);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Fare updated successfully")),
        );
        setState(() => isEditing = false);
        Navigator.pop(context, true); // Return true to indicate successful update
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update fare")),
        );
      }
    }
  }

  Widget _buildFareFields() {
    return Column(
      children: [
        if (_viewModel.selectedFareType == FareTypes.daily) ... [
          CustomFormFields.normalSizedTextFormField(context:context,
            label: "Daily Fare",
            controller: _viewModel.dailyFareController,
            keyboardType: TextInputType.number,
            enabled: isEditing, isPassword: false,
          ),
          const SizedBox(height: 16),
        ],

        if (_viewModel.selectedFareType == FareTypes.hourly) ... [
          CustomFormFields.normalSizedTextFormField(context:context,
            label: "Hourly Fare",
            controller: _viewModel.hourlyFareController,
            keyboardType: TextInputType.number,
            enabled: isEditing, isPassword: false,
          ),
          const SizedBox(height: 16),
        ],


        if (_viewModel.selectedFareType == FareTypes.monthlyPass) ... [
          CustomFormFields.normalSizedTextFormField(context:context,
            label: "Monthly Fare",
            controller: _viewModel.monthlyFareController,
            keyboardType: TextInputType.number,
            enabled: isEditing, isPassword: false,
          ),
          const SizedBox(height: 16),
        ],

        if (_viewModel.selectedFareType == FareTypes.hourWiseCustom) ...[
          CustomFormFields.normalSizedTextFormField(context:context,
            label: "Base Hours",
            controller: _viewModel.baseHoursController,
            keyboardType: TextInputType.number,
            enabled: isEditing, isPassword: false,
          ),
          const SizedBox(height: 16),
          CustomFormFields.normalSizedTextFormField(context:context,
            label: "Base Hourly Fare",
            controller: _viewModel.baseHourlyFareController,
            keyboardType: TextInputType.number,
            enabled: isEditing, isPassword: false,
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlazaFareViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoadingFare) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: CustomAppBar.appBarWithNavigation(
            screenTitle: "Edit Fare Details",
            onPressed: () => Navigator.pop(context),
            darkBackground: true, context: context,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CustomDropDown.normalDropDown(context:context,
                  label: "Vehicle Type",
                  items: VehicleTypes.values,
                  value: viewModel.selectedVehicleType,
                  onChanged: (value) => viewModel.setVehicleType(value!),
                  enabled: false, // Vehicle type shouldn't be editable
                ),
                const SizedBox(height: 16),

                CustomDropDown.normalDropDown(context:context,
                  label: "Fare Type",
                  items: FareTypes.values,
                  value: viewModel.selectedFareType,
                  onChanged:(value) => viewModel.setFareType(value!),
                  enabled: isEditing,
                ),
                const SizedBox(height: 16),

                _buildFareFields(),

                if (viewModel.selectedFareType == FareTypes.hourWiseCustom)...[
                  CustomFormFields.normalSizedTextFormField(context:context,
                    label: "Discount Rate",
                    controller: viewModel.discountController,
                    keyboardType: TextInputType.number,
                    enabled: isEditing, isPassword: false,
                  ),
                  const SizedBox(height: 16),
                ],

                GestureDetector(
                  onTap: isEditing ? () => viewModel.selectStartDate(context) : null,
                  child: AbsorbPointer(
                    child: CustomFormFields.normalSizedTextFormField(context:context,
                      label: "Start Effect Date",
                      controller: viewModel.startDateController,
                      enabled: false, isPassword: false,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                GestureDetector(
                  onTap: isEditing ? () => viewModel.selectEndDate(context) : null,
                  child: AbsorbPointer(
                    child: CustomFormFields.normalSizedTextFormField(context:context,
                      label: "End Effect Date",
                      controller: viewModel.endDateController,
                      enabled: isEditing, isPassword: false,
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
                      _loadFareData(); // Reset to original data
                    });
                  },
                  heroTag: 'cancelFab',
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.close),
                ),
                const SizedBox(width: 16),
              ],
              if (viewModel.isUpdating)
                const CircularProgressIndicator()
              else
                FloatingActionButton(
                  onPressed: () {
                    if (isEditing) {
                      _handleSave();
                    } else {
                      setState(() => isEditing = true);
                    }
                  },
                  heroTag: 'mainFab',
                  child: Icon(isEditing ? Icons.save : Icons.edit),
                ),
            ],
          ),
        );
      },
    );
  }
}