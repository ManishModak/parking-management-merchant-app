import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;

// Adjust these paths to match your project structure
import 'package:merchant_app/models/plaza_fare.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:merchant_app/utils/components/button.dart';
import 'package:merchant_app/utils/components/dropdown.dart';
import 'package:merchant_app/viewmodels/plaza_fare_viewmodel.dart';
import 'package:merchant_app/config/app_config.dart'; // Assuming this holds deviceWidth
import 'package:merchant_app/generated/l10n.dart';
import 'package:merchant_app/models/plaza.dart';
import 'add_fare_dialog.dart'; // This dialog is for adding a single fare to the temporary list

class AddFareScreen extends StatefulWidget {
  final Plaza? selectedPlaza; // Optional parameter for pre-selection

  const AddFareScreen({super.key, this.selectedPlaza});

  @override
  State<AddFareScreen> createState() => _AddFareScreenState();
}

class _AddFareScreenState extends State<AddFareScreen> {
  // Store the ViewModel instance to avoid repeated lookups and for use in dispose
  late final PlazaFareViewModel _viewModelInstance;

  @override
  void initState() {
    super.initState();
    // Obtain the ViewModel instance provided by the parent navigator.
    // listen: false is crucial here as we don't want initState to rebuild.
    _viewModelInstance =
        Provider.of<PlazaFareViewModel>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Initialize the ViewModel, passing the pre-selected plaza if it exists.
        _viewModelInstance.initialize(preSelectedPlaza: widget.selectedPlaza);
      }
    });
  }

  @override
  void dispose() {
    developer.log('Disposing AddFareScreen', name: 'AddFareScreen');
    // Call the reset method on the ViewModel to clean up its state.
    _viewModelInstance.resetStateForDisposal();
    super.dispose();
  }

  /// Shows the dialog to add a single fare configuration to the temporary list.
  Future<void> _showAddFareDialog(PlazaFareViewModel model) async {
    final strings = S.of(context);
    if (model.selectedPlaza == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.warningSelectPlazaToAddFare),
          backgroundColor: Colors.orange.shade700,
        ),
      );
      return;
    }

    // The dialog gets the same ViewModel instance to work with.
    // Using .value is correct when providing an existing instance.
    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) => ChangeNotifierProvider.value(
        value: model,
        child: const AddFareDialog(),
      ),
    );
  }

  /// Builds a card to display a fare that has been staged for submission.
  Widget _buildFareCard(BuildContext context, PlazaFare fare, S strings) {
    final viewModel = context.read<PlazaFareViewModel>();
    String fareDetails = '';
    String timeDetails = '';

    switch (fare.fareType) {
      case FareTypes.progressive:
        fareDetails =
        '${strings.labelFareAmount}: ₹${fare.fareRate.toStringAsFixed(2)}';
        timeDetails =
        '${strings.labelTimeRange}: ${fare.from ?? '?'} - ${fare.toCustom ?? '?'} ${strings.labelMinutesAbbr}';
        break;
      case FareTypes.freePass:
        fareDetails = strings.fareTypeFreePass;
        break;
      case FareTypes.daily:
        fareDetails =
        '₹${fare.fareRate.toStringAsFixed(2)} / ${strings.labelDay}';
        break;
      case FareTypes.hourly:
        fareDetails =
        '₹${fare.fareRate.toStringAsFixed(2)} / ${strings.labelHour}';
        break;
      case FareTypes.monthlyPass:
        fareDetails =
        '₹${fare.fareRate.toStringAsFixed(2)} / ${strings.labelMonth}';
        break;
      case FareTypes.hourWiseCustom:
        fareDetails =
        '${strings.labelBaseRate}: ₹${fare.fareRate.toStringAsFixed(2)} / ${strings.labelHour}';
        timeDetails = '${strings.labelBaseHours}: ${fare.baseHours ?? '-'}';
        break;
      default:
        fareDetails =
        '${strings.labelRate}: ₹${fare.fareRate.toStringAsFixed(2)}';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Plaza Name and Status
            Text(
              viewModel.selectedPlaza?.plazaName ??
                  '${strings.labelPlazaId}: ${fare.plazaId}',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            // Row 2: Vehicle and Fare Type
            Row(
              children: [
                Expanded(
                    child: Text(
                        '${strings.labelVehicleType}: ${fare.vehicleType}',
                        style: Theme.of(context).textTheme.bodyMedium)),
                Expanded(
                    child: Text('${strings.labelFareType}: ${fare.fareType}',
                        style: Theme.of(context).textTheme.bodyMedium)),
              ],
            ),
            const SizedBox(height: 8),
            // Row 3: Fare Details
            Text(fareDetails, style: Theme.of(context).textTheme.bodyMedium),
            if (timeDetails.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(timeDetails, style: Theme.of(context).textTheme.bodySmall),
            ],
            const Divider(height: 20),
            // Row 4: Effective Dates
            Text(
              '${strings.labelEffectivePeriod}: ${DateFormat('dd MMM yyyy').format(fare.startEffectDate)} - ${fare.endEffectDate != null ? DateFormat('dd MMM yyyy').format(fare.endEffectDate!) : strings.labelOngoing}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    // Use a Consumer to listen for changes in the ViewModel and rebuild the UI.
    return Consumer<PlazaFareViewModel>(
      builder: (context, model, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: CustomAppBar.appBarWithNavigation(
            screenTitle: strings.titleAddFare,
            onPressed: () => Navigator.pop(context),
            darkBackground: Theme.of(context).brightness == Brightness.dark,
            context: context,
          ),
          body: model.isLoading && model.temporaryFares.isEmpty
              ? Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary))
              : SingleChildScrollView(
            padding:
            const EdgeInsets.only(bottom: 100), // Space for button
            child: Center(
              child: SizedBox(
                width: AppConfig.deviceWidth * 0.9,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    SearchableDropdown(
                      label: strings.labelSelectPlaza,
                      value: model.selectedPlazaIdString,
                      items: model.plazaList,
                      onChanged: (dynamic selected) {
                        if (selected != null && model.canChangePlaza) {
                          model.setSelectedPlaza(selected as Plaza);
                        }
                      },
                      itemText: (item) => (item as Plaza).plazaName!,
                      itemValue: (item) => (item as Plaza).plazaId ?? '',
                      errorText: model.validationErrors['plaza'],
                      enabled: model.canChangePlaza, // Controlled by VM
                    ),
                    const SizedBox(height: 24),
                    Text(
                      strings.labelFaresToBeAdded,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (model.temporaryFares.isEmpty)
                      Padding(
                        padding:
                        const EdgeInsets.symmetric(vertical: 30.0),
                        child: Center(
                          child: Text(
                            strings.messageNoFaresAddedYet,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.6)),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: model.temporaryFares.length,
                        itemBuilder: (context, index) {
                          final fare = model.temporaryFares[index];
                          return _buildFareCard(context, fare, strings);
                        },
                      ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
          floatingActionButton: model.selectedPlaza != null
              ? FloatingActionButton(
            onPressed: () => _showAddFareDialog(model),
            tooltip: strings.tooltipAddFare,
            child: const Icon(Icons.add),
          )
              : null,
          bottomNavigationBar: model.temporaryFares.isNotEmpty
              ? Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).padding.bottom + 16,
              top: 8,
            ),
            child: CustomButtons.primaryButton(
              height: 50,
              // Show different text while submitting
              text: model.isLoading
                  ? strings.buttonSubmitting
                  : strings.buttonSubmitAllFares,
              // The onPressed triggers the ViewModel's submit logic.
              // The ViewModel handles the API call AND navigation.
              // Disable the button when loading.
              onPressed: model.isLoading
                  ? null
                  : () => model.submitAllFares(context),
              context: context,
            ),
          )
              : null,
        );
      },
    );
  }
}