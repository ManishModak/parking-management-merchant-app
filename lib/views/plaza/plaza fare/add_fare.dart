import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:merchant_app/models/plaza_fare.dart'; // Import FareTypes
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:merchant_app/utils/components/button.dart';
import 'package:merchant_app/utils/components/dropdown.dart';
import 'package:merchant_app/viewmodels/plaza_fare_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:merchant_app/config/app_config.dart';
import 'package:merchant_app/generated/l10n.dart';
import 'package:merchant_app/models/plaza.dart';
import 'package:merchant_app/utils/components/form_field.dart';
import 'add_fare_dialog.dart';
import 'dart:developer' as developer; // Import developer for logging

class AddFareScreen extends StatefulWidget {
  final Plaza? selectedPlaza; // Optional parameter

  const AddFareScreen({super.key, this.selectedPlaza});

  @override
  State<AddFareScreen> createState() => _AddFareScreenState();
}

class _AddFareScreenState extends State<AddFareScreen> {
  // *** Hold the ViewModel instance obtained in initState ***
  late PlazaFareViewModel _viewModelInstance;

  @override
  void initState() {
    super.initState();
    // *** Obtain and store the instance here ***
    _viewModelInstance =
        Provider.of<PlazaFareViewModel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Use the stored instance
        _viewModelInstance.initialize(preSelectedPlaza: widget.selectedPlaza);
      }
    });
  }

  // --- Dispose method to reset ViewModel state ---
  @override
  void dispose() {
    developer.log('Disposing AddFareScreen - Calling resetStateForDisposal.',
        name: 'AddFareScreen');
    // *** Use the stored instance variable, NOT context.read() ***
    _viewModelInstance.resetStateForDisposal();
    super.dispose();
  }

  // --- END OF DISPOSE METHOD ---

  // Updated Fare Card Builder
  Widget _buildFareCard(BuildContext context, PlazaFare fare, S strings) {
    // Access ViewModel using read or the stored instance (_viewModelInstance)
    // Using read is fine here as it's within build context scope implicitly
    final viewModel = context.read<PlazaFareViewModel>();
    String fareDetails = '';
    String timeDetails = '';

    // ... (rest of _buildFareCard logic remains the same) ...
    switch (fare.fareType) {
      case FareTypes.progressive:
        fareDetails =
            '${strings.labelFareAmount}: ₹${fare.fareRate.toStringAsFixed(2)}';
        timeDetails =
            '${strings.labelTimeRange}: ${fare.from ?? '?'} - ${fare.toCustom ?? '?'} ${strings.labelMinutesAbbr}';
        break;
      case FareTypes.freePass:
        fareDetails = strings.fareTypeFreePass; // "Free Pass"
        timeDetails = ''; // No extra details
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
        if (fare.discountRate != null && fare.discountRate! > 0) {
          timeDetails +=
              '\n${strings.labelDiscount}: ${fare.discountRate}%'; // Show discount if present
        }
        break;
      default:
        fareDetails =
            '${strings.labelRate}: ₹${fare.fareRate.toStringAsFixed(2)}';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      // Add space below card
      elevation: Theme.of(context).cardTheme.elevation ?? 2,
      shape: Theme.of(context).cardTheme.shape ??
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Consistent radius
            side: BorderSide(
              // Use theme colors or specific status colors
              color: fare.isDeleted
                  ? Colors.red.shade200
                  : Theme.of(context).dividerColor.withOpacity(0.5),
              width: 0.8,
            ),
          ),
      color: Theme.of(context).cardColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          print("Tapped temporary fare: ${fare.fareType}");
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: Plaza Name and Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          // Allow Plaza Name to wrap if long
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                strings.labelPlazaName, // "Plaza Name"
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.6),
                                    ),
                              ),
                              Text(
                                // Use viewModel.selectedPlaza read from context
                                viewModel.selectedPlaza?.plazaName ??
                                    '${strings.labelPlazaId}: ${fare.plazaId}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8), // Space before status
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            strings.statusPending, // "Pending" or "Staged"
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Row 2: Vehicle Type and Fare Type
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                strings.labelVehicleType, // "Vehicle Type"
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.6),
                                    ),
                              ),
                              Text(
                                fare.vehicleType,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
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
                                strings.labelFareType, // "Fare Type"
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.6),
                                    ),
                              ),
                              Text(
                                fare.fareType, // Display the actual fare type
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Row 3: Fare Details and Time Details (Conditional)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fare.fareType == FareTypes.progressive
                                    ? strings.labelDetails
                                    : strings.labelFareDetails,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.6),
                                    ),
                              ),
                              Text(
                                fareDetails,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              if (timeDetails.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  timeDetails,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.8),
                                      ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                strings.labelEffectivePeriod,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.6),
                                    ),
                              ),
                              Text(
                                '${DateFormat('dd MMM yyyy').format(fare.startEffectDate)} - ${fare.endEffectDate != null ? DateFormat('dd MMM yyyy').format(fare.endEffectDate!) : strings.labelOngoing}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
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
            ],
          ),
        ),
      ),
    );
  }

  // Function to show the Add Fare Dialog
  Future<void> _showAddFareDialog() async {
    // Use the stored instance here when passing to the dialog provider
    final strings = S.of(context);
    if (_viewModelInstance.selectedPlaza == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.warningSelectPlazaToAddFare),
          backgroundColor: Colors.orange.shade700,
        ),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (BuildContext context) => ChangeNotifierProvider.value(
        // Pass the stored instance
        value: _viewModelInstance,
        child: const AddFareDialog(),
      ),
    ).then((_) {
      // Use the stored instance
      _viewModelInstance.resetFieldsAfterAdd();
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    // Use Consumer here to react to changes in the ViewModel for the main build
    return Consumer<PlazaFareViewModel>(
      builder: (context, model, child) {
        // model is the instance of PlazaFareViewModel
        // You can also use _viewModelInstance here if preferred, but model is conventional
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: CustomAppBar.appBarWithNavigation(
            screenTitle: strings.titleAddFare, // Localized
            onPressed: () => Navigator.pop(context),
            darkBackground: Theme.of(context).brightness == Brightness.dark,
            context: context,
          ),
          body: model.isLoading
              ? Center(
                  child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary))
              : SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 80),
                  child: Center(
                    child: SizedBox(
                      width: AppConfig.deviceWidth * 0.9,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          Center(
                            child: SearchableDropdown(
                              label: strings.labelSelectPlaza,
                              value: model.selectedPlazaIdString,
                              items: model.plazaList,
                              onChanged: (dynamic selected) {
                                if (selected != null && model.canChangePlaza) {
                                  model.setSelectedPlaza(selected as Plaza);
                                }
                              },
                              itemText: (item) => (item as Plaza).plazaName!,
                              itemValue: (item) =>
                                  (item as Plaza).plazaId ?? '',
                              errorText: model.validationErrors['plaza'],
                              enabled: model.canChangePlaza,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            strings.labelFaresToBeAdded,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
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
                                            .withOpacity(0.6),
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: model.temporaryFares.length,
                            itemBuilder: (context, index) {
                              final fare = model.temporaryFares[index];
                              // Pass context to _buildFareCard
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
                  onPressed: _showAddFareDialog,
                  backgroundColor: Theme.of(context)
                          .floatingActionButtonTheme
                          .backgroundColor ??
                      Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context)
                          .floatingActionButtonTheme
                          .foregroundColor ??
                      Theme.of(context).colorScheme.onPrimary,
                  elevation:
                      Theme.of(context).floatingActionButtonTheme.elevation ??
                          6.0,
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
                    text: strings.buttonSubmitAllFares,
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
