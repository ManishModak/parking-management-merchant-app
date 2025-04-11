import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:merchant_app/generated/l10n.dart';
import '../../../models/plaza.dart';
import '../../../utils/components/appbar.dart';
import '../../../utils/components/button.dart';
import '../../../utils/components/dropdown.dart';
import '../../../utils/components/form_field.dart';
import '../../../utils/exceptions.dart';
import '../../../viewmodels/plaza/plaza_modification_viewmodel.dart';
import 'dart:developer' as developer; // Import the developer library
// Import loading screen if needed, or rely on ViewModel's isLoading
// import '../../../utils/screens/loading_screen.dart';

class BasicDetailsModificationScreen extends StatefulWidget {
  const BasicDetailsModificationScreen({super.key});

  @override
  State<BasicDetailsModificationScreen> createState() => _BasicDetailsModificationScreenState();
}

class _BasicDetailsModificationScreenState extends State<BasicDetailsModificationScreen> {
  // Define a logger name for this screen
  static const String _logName = 'BasicDetailsModificationScreen';

  late String _plazaId;
  bool _isInitialized = false;
  // Optional: Track initial load specifically for this screen
  bool _isInitialLoading = false;


  @override
  void initState() {
    super.initState();
    developer.log('initState called', name: _logName);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    developer.log('didChangeDependencies called, _isInitialized: $_isInitialized', name: _logName);
    if (!_isInitialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      final potentialPlazaId = args?.toString();
      final strings = S.of(context);
      developer.log('Arguments received: $potentialPlazaId', name: _logName);

      if (potentialPlazaId == null || potentialPlazaId.isEmpty) {
        developer.log('Invalid or missing plazaId received.', name: _logName, level: 1000);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            developer.log('Showing snackbar for invalid plazaId and popping screen.', name: _logName);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(strings.invalidPlazaId)),
            );
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          } else {
            developer.log('Screen not mounted, cannot show snackbar or pop.', name: _logName);
          }
        });
      } else {
        _plazaId = potentialPlazaId;
        developer.log('Valid plazaId received: $_plazaId', name: _logName);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            // *** START CHANGE ***
            _fetchDetails();
            // *** END CHANGE ***
          } else {
            developer.log('Screen not mounted, cannot fetch plaza details.', name: _logName);
          }
        });
      }
      _isInitialized = true;
      developer.log('_isInitialized set to true', name: _logName);
    }
  }

  // *** NEW METHOD ***
  Future<void> _fetchDetails() async {
    if (!mounted) return;
    developer.log('[BasicDetailsModScreen] Fetching basic details...', name: _logName);
    setState(() { _isInitialLoading = true; });

    try {
      await context.read<PlazaModificationViewModel>().fetchBasicPlazaDetails(_plazaId);
      developer.log('[BasicDetailsModScreen] Fetch successful.', name: _logName);
    } catch (e, stackTrace) {
      developer.log('[BasicDetailsModScreen] Error fetching initial details', name: _logName, error: e, stackTrace: stackTrace);
      // Error state handled by ViewModel, UI will update via Consumer/watch
    } finally {
      if (mounted) {
        setState(() { _isInitialLoading = false; });
      }
    }
  }
  // *** END NEW METHOD ***

  @override
  void dispose() {
    developer.log('dispose called', name: _logName);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    developer.log('build called', name: _logName);
    final viewModel = context.watch<PlazaModificationViewModel>();
    final strings = S.of(context);

    developer.log('Current State - isInitialLoading: $_isInitialLoading, VMisLoading: ${viewModel.isLoading}, error: ${viewModel.error}, isEditable: ${viewModel.isBasicDetailsEditable}', name: _logName);

    // Determine if content should be shown (fetch attempted, not initial loading OR has error)
    // Or simply rely on ViewModel's loading state if _isInitialLoading is too complex
    final showContent = _isInitialized && !_isInitialLoading;


    return Scaffold(
      appBar: CustomAppBar.appBarWithNavigation(
        screenTitle: strings.basicDetails,
        onPressed: () {
          developer.log('AppBar back button pressed. isEditable: ${viewModel.isBasicDetailsEditable}', name: _logName);
          viewModel.formState.errors.clear(); // Clear errors on navigate back
          if (viewModel.isBasicDetailsEditable) {
            developer.log('Cancelling edit mode due to back navigation.', name: _logName);
            viewModel.cancelBasicDetailsEdit();
          }
          Navigator.pop(context);
        },
        darkBackground: Theme.of(context).brightness == Brightness.dark,
        context: context,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // Use _isInitialLoading or viewModel.isLoading based on preference
      body: _isInitialLoading // || viewModel.isLoading && !_isInitialized) // More robust loading check if needed
          ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
          : viewModel.error != null && !_isInitialLoading // Show error only after initial load attempt
          ? _buildErrorState(viewModel, _plazaId, strings)
          : _buildContent(viewModel, strings),
      // Hide FAB during initial load
      floatingActionButton: showContent && viewModel.error == null ? _buildFloatingActionButtons(viewModel, strings) : null,
    );
  }

  Widget _buildContent(PlazaModificationViewModel viewModel, S strings) {
    developer.log('Building content form. isEditable: ${viewModel.isBasicDetailsEditable}', name: _logName);
    // Check if basic details actually exist in the viewmodel state
    final hasData = viewModel.formState.basicDetails.isNotEmpty;

    // If no data and no error, it might still be loading or failed silently
    if (!hasData && viewModel.error == null && viewModel.isLoading) {
      return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary));
    }
    // If no data and no error and not loading, show empty state or error hint?
    // Or rely on _buildErrorState to be shown if viewModel.error is set.


    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          CustomFormFields.normalSizedTextFormField(
            context: context,
            label: strings.plazaName,
            controller: viewModel.plazaNameController,
            keyboardType: TextInputType.text,
            enabled: viewModel.isBasicDetailsEditable,
            errorText: viewModel.formState.errors['plazaName'],
          ),
          const SizedBox(height: 16),
          CustomFormFields.normalSizedTextFormField(
            context: context,
            label: strings.plazaOperatorName,
            controller: viewModel.operatorNameController,
            keyboardType: TextInputType.text,
            enabled: viewModel.isBasicDetailsEditable,
            errorText: viewModel.formState.errors['plazaOperatorName'],
          ),
          const SizedBox(height: 16),
          CustomFormFields.normalSizedTextFormField(
            context: context,
            label: strings.plazaOwner,
            controller: viewModel.plazaOwnerController,
            keyboardType: TextInputType.text,
            enabled: viewModel.isBasicDetailsEditable,
            errorText: viewModel.formState.errors['plazaOwner'],
          ),
          const SizedBox(height: 16),
          CustomFormFields.normalSizedTextFormField(
            context: context,
            label: strings.plazaOwnerId,
            controller: viewModel.plazaOwnerIdController,
            keyboardType: TextInputType.text,
            enabled: viewModel.isBasicDetailsEditable,
            errorText: viewModel.formState.errors['plazaOwnerId'],
          ),
          const SizedBox(height: 16),
          CustomFormFields.normalSizedTextFormField(
            context: context,
            label: strings.mobileNumber,
            maxLength: 10,
            height: 75,
            controller: viewModel.mobileController,
            keyboardType: TextInputType.phone,
            enabled: viewModel.isBasicDetailsEditable,
            errorText: viewModel.formState.errors['mobileNumber'],
          ),
          const SizedBox(height: 16),
          CustomFormFields.normalSizedTextFormField(
            context: context,
            label: strings.email,
            controller: viewModel.emailController,
            keyboardType: TextInputType.emailAddress,
            enabled: viewModel.isBasicDetailsEditable,
            errorText: viewModel.formState.errors['email'],
          ),
          const SizedBox(height: 16),
          CustomFormFields.normalSizedTextFormField(
            context: context,
            label: strings.address,
            controller: viewModel.addressController,
            keyboardType: TextInputType.streetAddress,
            maxLines: 3,
            enabled: viewModel.isBasicDetailsEditable,
            errorText: viewModel.formState.errors['address'],
          ),
          const SizedBox(height: 16),
          CustomFormFields.normalSizedTextFormField(
            context: context,
            label: strings.city,
            controller: viewModel.cityController,
            keyboardType: TextInputType.text,
            enabled: viewModel.isBasicDetailsEditable,
            errorText: viewModel.formState.errors['city'],
          ),
          const SizedBox(height: 16),
          CustomFormFields.normalSizedTextFormField(
            context: context,
            label: strings.district,
            controller: viewModel.districtController,
            keyboardType: TextInputType.text,
            enabled: viewModel.isBasicDetailsEditable,
            errorText: viewModel.formState.errors['district'],
          ),
          const SizedBox(height: 16),
          CustomFormFields.normalSizedTextFormField(
            context: context,
            label: strings.state,
            controller: viewModel.stateController,
            keyboardType: TextInputType.text,
            enabled: viewModel.isBasicDetailsEditable,
            errorText: viewModel.formState.errors['state'],
          ),
          const SizedBox(height: 16),
          CustomFormFields.normalSizedTextFormField(
            context: context,
            label: strings.pincode,
            controller: viewModel.pincodeController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            enabled: viewModel.isBasicDetailsEditable,
            errorText: viewModel.formState.errors['pincode'],
            height: 75
          ),
          const SizedBox(height: 16),
          CustomFormFields.normalSizedTextFormField(
            context: context,
            label: strings.geoLatitude,
            controller: viewModel.geoLatitudeController,
            keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
            enabled: viewModel.isBasicDetailsEditable,
            errorText: viewModel.formState.errors['geoLatitude'],
          ),
          const SizedBox(height: 16),
          CustomFormFields.normalSizedTextFormField(
            context: context,
            label: strings.geoLongitude,
            controller: viewModel.geoLongitudeController,
            keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
            enabled: viewModel.isBasicDetailsEditable,
            errorText: viewModel.formState.errors['geoLongitude'],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CustomDropDown.normalDropDown(
                  context: context,
                  label: strings.plazaCategory,
                  value: viewModel.formState.basicDetails['plazaCategory']?.toString(),
                  items: Plaza.validPlazaCategories,
                  enabled: viewModel.isBasicDetailsEditable,
                  onChanged: (value) {
                    developer.log('Plaza Category changed to: $value', name: _logName);
                    if (value != null) {
                      viewModel.formState.basicDetails['plazaCategory'] = value;
                      viewModel.notifyListeners(); // Ensure UI updates if needed
                    }
                  },
                  errorText: viewModel.formState.errors['plazaCategory'],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CustomDropDown.normalDropDown(
                  context: context,
                  label: strings.plazaSubCategory,
                  value: viewModel.formState.basicDetails['plazaSubCategory']?.toString(),
                  items: Plaza.validPlazaSubCategories,
                  enabled: viewModel.isBasicDetailsEditable,
                  onChanged: (value) {
                    developer.log('Plaza SubCategory changed to: $value', name: _logName);
                    if (value != null) {
                      viewModel.formState.basicDetails['plazaSubCategory'] = value;
                      viewModel.notifyListeners();
                    }
                  },
                  errorText: viewModel.formState.errors['plazaSubCategory'],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CustomDropDown.normalDropDown(
                  context: context,
                  label: strings.plazaStatus,
                  value: viewModel.formState.basicDetails['plazaStatus']?.toString(),
                  items: Plaza.validPlazaStatuses,
                  enabled: viewModel.isBasicDetailsEditable,
                  onChanged: (value) {
                    developer.log('Plaza Status changed to: $value', name: _logName);
                    if (value != null) {
                      viewModel.formState.basicDetails['plazaStatus'] = value;
                      viewModel.notifyListeners();
                    }
                  },
                  errorText: viewModel.formState.errors['plazaStatus'],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CustomDropDown.normalDropDown(
                  context: context,
                  label: strings.freeParking,
                  value: (viewModel.formState.basicDetails['freeParking'] == true) ? strings.yes : strings.no,
                  items: [strings.yes, strings.no],
                  enabled: viewModel.isBasicDetailsEditable,
                  onChanged: (value) {
                    developer.log('Free Parking changed to: $value', name: _logName);
                    if (value != null) {
                      viewModel.formState.basicDetails['freeParking'] = (value == strings.yes);
                      viewModel.notifyListeners();
                    }
                  },
                  errorText: viewModel.formState.errors['freeParking'],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CustomDropDown.normalDropDown(
                  context: context,
                  label: strings.structureType,
                  value: viewModel.formState.basicDetails['structureType']?.toString(),
                  items: Plaza.validStructureTypes,
                  enabled: viewModel.isBasicDetailsEditable,
                  onChanged: (value) {
                    developer.log('Structure Type changed to: $value', name: _logName);
                    if (value != null) {
                      viewModel.formState.basicDetails['structureType'] = value;
                      viewModel.notifyListeners();
                    }
                  },
                  errorText: viewModel.formState.errors['structureType'],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CustomDropDown.normalDropDown(
                  context: context,
                  label: strings.priceCategory,
                  value: viewModel.formState.basicDetails['priceCategory']?.toString(),
                  items: Plaza.validPriceCategories,
                  enabled: viewModel.isBasicDetailsEditable,
                  onChanged: (value) {
                    developer.log('Price Category changed to: $value', name: _logName);
                    if (value != null) {
                      viewModel.formState.basicDetails['priceCategory'] = value;
                      viewModel.notifyListeners();
                    }
                  },
                  errorText: viewModel.formState.errors['priceCategory'],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CustomFormFields.normalSizedTextFormField(
            context: context,
            label: strings.totalParkingSlots,
            controller: viewModel.noOfParkingSlotsController,
            keyboardType: TextInputType.number,
            enabled: viewModel.isBasicDetailsEditable,
            errorText: viewModel.formState.errors['noOfParkingSlots'],
          ),
          const SizedBox(height: 16),
          CustomFormFields.normalSizedTextFormField(
            context: context,
            label: strings.bikeCapacity,
            controller: viewModel.capacityBikeController,
            keyboardType: TextInputType.number,
            enabled: viewModel.isBasicDetailsEditable,
            errorText: viewModel.formState.errors['capacityBike'],
          ),
          const SizedBox(height: 16),
          CustomFormFields.normalSizedTextFormField(
            context: context,
            label: strings.threeWheelerCapacity,
            controller: viewModel.capacity3WheelerController,
            keyboardType: TextInputType.number,
            enabled: viewModel.isBasicDetailsEditable,
            errorText: viewModel.formState.errors['capacity3Wheeler'],
          ),
          const SizedBox(height: 16),
          CustomFormFields.normalSizedTextFormField(
            context: context,
            label: strings.fourWheelerCapacity,
            controller: viewModel.capacity4WheelerController,
            keyboardType: TextInputType.number,
            enabled: viewModel.isBasicDetailsEditable,
            errorText: viewModel.formState.errors['capacity4Wheeler'],
          ),
          const SizedBox(height: 16),
          CustomFormFields.normalSizedTextFormField(
            context: context,
            label: strings.busCapacity,
            controller: viewModel.capacityBusController,
            keyboardType: TextInputType.number,
            enabled: viewModel.isBasicDetailsEditable,
            errorText: viewModel.formState.errors['capacityBus'],
          ),
          const SizedBox(height: 16),
          CustomFormFields.normalSizedTextFormField(
            context: context,
            label: strings.truckCapacity,
            controller: viewModel.capacityTruckController,
            keyboardType: TextInputType.number,
            enabled: viewModel.isBasicDetailsEditable,
            errorText: viewModel.formState.errors['capacityTruck'],
          ),
          const SizedBox(height: 16),
          CustomFormFields.normalSizedTextFormField(
            context: context,
            label: strings.heavyMachineryCapacity,
            controller: viewModel.capacityHeavyMachineryController,
            keyboardType: TextInputType.number,
            enabled: viewModel.isBasicDetailsEditable,
            errorText: viewModel.formState.errors['capacityHeavyMachinaryVehicle'],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () async {
              if (!viewModel.isBasicDetailsEditable) return;
              developer.log('Opening time picker tapped.', name: _logName);
              final TimeOfDay? pickedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(), // Consider initializing with current value if available
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: Theme.of(context).colorScheme,
                      timePickerTheme: TimePickerThemeData(),
                    ),
                    child: child!,
                  );
                },
              );
              if (pickedTime != null) {
                // Use HH:mm format for consistency
                final formattedTime =
                    '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
                developer.log('Opening time selected: $formattedTime', name: _logName);
                viewModel.plazaOpenTimingsController.text = formattedTime;
              } else {
                developer.log('Opening time picker cancelled.', name: _logName);
              }
            },
            child: AbsorbPointer(
              child: CustomFormFields.normalSizedTextFormField(
                context: context,
                label: strings.openingTime,
                controller: viewModel.plazaOpenTimingsController,
                keyboardType: TextInputType.none,
                enabled: viewModel.isBasicDetailsEditable, // Controller manages text, visually disabled
                errorText: viewModel.formState.errors['plazaOpenTimings'],
                suffixIcon: viewModel.isBasicDetailsEditable
                    ? Icon(Icons.access_time, color: Theme.of(context).colorScheme.primary)
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () async {
              if (!viewModel.isBasicDetailsEditable) return;
              developer.log('Closing time picker tapped.', name: _logName);
              final TimeOfDay? pickedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(), // Consider initializing with current value
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: Theme.of(context).colorScheme,
                    ),
                    child: child!,
                  );
                },
              );
              if (pickedTime != null) {
                // Use HH:mm format
                final formattedTime =
                    '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
                developer.log('Closing time selected: $formattedTime', name: _logName);
                viewModel.plazaClosingTimeController.text = formattedTime;
              } else {
                developer.log('Closing time picker cancelled.', name: _logName);
              }
            },
            child: AbsorbPointer(
              child: CustomFormFields.normalSizedTextFormField(
                context: context,
                label: strings.closingTime,
                controller: viewModel.plazaClosingTimeController,
                keyboardType: TextInputType.none,
                enabled: viewModel.isBasicDetailsEditable,
                errorText: viewModel.formState.errors['plazaClosingTime'],
                suffixIcon: viewModel.isBasicDetailsEditable
                    ? Icon(Icons.access_time, color: Theme.of(context).colorScheme.primary)
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildFloatingActionButtons(PlazaModificationViewModel viewModel, S strings) {
    developer.log('Building FABs. isEditable: ${viewModel.isBasicDetailsEditable}', name: _logName);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (viewModel.isBasicDetailsEditable) ...[
          FloatingActionButton.extended(
            onPressed: () {
              developer.log('Cancel FAB pressed.', name: _logName);
              viewModel.cancelBasicDetailsEdit();
            },
            heroTag: "cancel_basic_details",
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
            foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
            icon: const Icon(Icons.cancel),
            label: Text(strings.cancel),
          ),
          const SizedBox(width: 16),
        ],
        FloatingActionButton.extended(
          onPressed: () async {
            developer.log('Save/Edit FAB pressed. Current mode: ${viewModel.isBasicDetailsEditable ? "Save" : "Edit"}', name: _logName);
            if (viewModel.isBasicDetailsEditable) {
              FocusScope.of(context).unfocus(); // Hide keyboard
              developer.log('Attempting to save basic details.', name: _logName);
              final isValid = viewModel.formState.validateBasicDetails(context);
              developer.log('Validation result: $isValid. Errors: ${viewModel.formState.errors}', name: _logName);
              if (!isValid) {
                if (mounted) {
                  developer.log('Validation failed. Showing error snackbar.', name: _logName);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(strings.correctBasicDetailsErrors),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
                return;
              }
              try {
                developer.log('Validation passed. Calling updateBasicDetails.', name: _logName);
                await viewModel.updateBasicDetails(context);
                developer.log('updateBasicDetails completed successfully.', name: _logName);
                // Success message is usually shown by the ViewModel or after update completes
              } catch (e, stackTrace) {
                developer.log('Error updating basic details', name: _logName, error: e, stackTrace: stackTrace);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(strings.updatePlazaFailed)), // Generic message, specific error logged
                  );
                }
              }
            } else {
              developer.log('Toggling basic details to editable mode.', name: _logName);
              viewModel.toggleBasicDetailsEditable();
            }
          },
          heroTag: "save_or_edit_basic_details",
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          icon: Icon(viewModel.isBasicDetailsEditable ? Icons.save : Icons.edit),
          label: Text(viewModel.isBasicDetailsEditable ? strings.save : strings.edit),
        ),
      ],
    );
  }

  Widget _buildErrorState(PlazaModificationViewModel viewModel, String plazaId, S strings) {
    Exception? error = viewModel.error;
    developer.log('Building error state for plazaId: $plazaId', name: _logName, error: error);
    String errorTitle = strings.errorTitleDefault;
    String errorMessage = strings.errorMessageDefault;
    String? errorDetails;

    if (error is HttpException) {
      final statusCode = error.statusCode;
      errorTitle = statusCode != null ? strings.errorTitleWithCode(statusCode) : strings.errorTitleServer;
      errorMessage = error.message;
      errorDetails = error.serverMessage ?? strings.errorDetailsNoDetails;
    } else if (error is PlazaException) {
      errorTitle = strings.errorTitlePlaza;
      errorMessage = error.message;
      errorDetails = error.serverMessage ?? strings.errorDetailsNoDetails;
    } else if (error is ServiceException) {
      errorTitle = strings.errorTitleService;
      errorMessage = error.message;
      errorDetails = error.serverMessage ?? strings.errorDetailsService;
    } else if (error != null) {
      errorTitle = strings.errorLoadingPlazaDetailsFailed;
      errorMessage = strings.errorMessagePleaseTryAgain;
      errorDetails = error.toString(); // Log the raw error
    }

    developer.log('Error details - Title: $errorTitle, Message: $errorMessage, Details: $errorDetails', name: _logName);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              errorTitle,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (errorDetails != null && errorDetails.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                errorDetails,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            CustomButtons.primaryButton(
              text: strings.retry,
              onPressed: () {
                developer.log('Retry button pressed for plazaId: $plazaId', name: _logName);
                _fetchDetails();
              },
              context: context,
              width: 150,
              height: 40,
            ),
          ],
        ),
      ),
    );
  }
}