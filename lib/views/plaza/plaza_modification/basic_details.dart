import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for FilteringTextInputFormatter
import 'package:provider/provider.dart';
import 'package:merchant_app/generated/l10n.dart';
import '../../../models/plaza.dart';
import '../../../utils/components/appbar.dart';
import '../../../utils/components/button.dart';
import '../../../utils/components/dropdown.dart';
import '../../../utils/components/form_field.dart';
import '../../../utils/exceptions.dart';
import '../../../viewmodels/plaza/plaza_modification_viewmodel.dart';
import 'dart:developer' as developer;

class BasicDetailsModificationScreen extends StatefulWidget {
  const BasicDetailsModificationScreen({super.key});

  @override
  State<BasicDetailsModificationScreen> createState() =>
      _BasicDetailsModificationScreenState();
}

class _BasicDetailsModificationScreenState
    extends State<BasicDetailsModificationScreen> {
  static const String _logName = 'BasicDetailsModificationScreen';

  late String _plazaId;
  bool _isInitialized = false;
  bool _isInitialLoading = false;

  @override
  void initState() {
    super.initState();
    developer.log('initState called', name: _logName);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    developer.log(
        'didChangeDependencies called, _isInitialized: $_isInitialized',
        name: _logName);
    if (!_isInitialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      final potentialPlazaId = args?.toString();
      final strings = S.of(context);
      developer.log('Arguments received: $potentialPlazaId', name: _logName);

      if (potentialPlazaId == null || potentialPlazaId.isEmpty) {
        developer.log('Invalid or missing plazaId received.',
            name: _logName, level: 1000);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            developer.log(
                'Showing snackbar for invalid plazaId and popping screen.',
                name: _logName);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(strings.invalidPlazaId)),
            );
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          } else {
            developer.log('Screen not mounted, cannot show snackbar or pop.',
                name: _logName);
          }
        });
      } else {
        _plazaId = potentialPlazaId;
        developer.log('Valid plazaId received: $_plazaId', name: _logName);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _fetchDetails();
          } else {
            developer.log('Screen not mounted, cannot fetch plaza details.',
                name: _logName);
          }
        });
      }
      _isInitialized = true;
      developer.log('_isInitialized set to true', name: _logName);
    }
  }

  Future<void> _fetchDetails() async {
    if (!mounted) return;
    developer.log('[BasicDetailsModScreen] Fetching basic details...',
        name: _logName);
    setState(() {
      _isInitialLoading = true;
    });

    try {
      await context
          .read<PlazaModificationViewModel>()
          .fetchBasicPlazaDetails(_plazaId);
      developer.log('[BasicDetailsModScreen] Fetch successful.',
          name: _logName);
    } catch (e, stackTrace) {
      developer.log('[BasicDetailsModScreen] Error fetching initial details',
          name: _logName, error: e, stackTrace: stackTrace);
      // Error handled by VM, UI updates via Consumer/watch
    } finally {
      if (mounted) {
        setState(() {
          _isInitialLoading = false;
        });
      }
    }
  }

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
    final theme = Theme.of(context); // Get theme for colors

    developer.log(
        'Current State - isInitialLoading: $_isInitialLoading, VMisLoading: ${viewModel.isLoading}, error: ${viewModel.error}, isEditable: ${viewModel.isBasicDetailsEditable}',
        name: _logName);

    final showContent = _isInitialized && !_isInitialLoading;
    final bool isEnabled =
        viewModel.isBasicDetailsEditable; // Alias for readability
    final Color iconColor = isEnabled
        ? theme.iconTheme.color ?? theme.primaryColor
        : theme.disabledColor; // Dynamic icon color
    final Color disabledIconColor = theme.disabledColor;

    return Scaffold(
      appBar: CustomAppBar.appBarWithNavigation(
        screenTitle: strings.basicDetails, // Use appropriate title
        onPressed: () {
          developer.log(
              'AppBar back button pressed. isEditable: ${viewModel.isBasicDetailsEditable}',
              name: _logName);
          viewModel.formState.errors.clear();
          if (viewModel.isBasicDetailsEditable) {
            developer.log('Cancelling edit mode due to back navigation.',
                name: _logName);
            viewModel.cancelBasicDetailsEdit();
          }
          Navigator.pop(context);
        },
        darkBackground: Theme.of(context).brightness == Brightness.dark,
        context: context,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _isInitialLoading
          ? Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary))
          : viewModel.error != null && !_isInitialLoading
              ? _buildErrorState(viewModel, _plazaId, strings)
              : _buildContent(
                  viewModel, strings, isEnabled, iconColor, disabledIconColor),
      // Pass state down
      floatingActionButton: showContent && viewModel.error == null
          ? _buildFloatingActionButtons(viewModel, strings)
          : null,
    );
  }

  Widget _buildContent(PlazaModificationViewModel viewModel, S strings,
      bool isEnabled, Color iconColor, Color disabledIconColor) {
    developer.log('Building content form. isEditable: $isEnabled',
        name: _logName);
    final theme = Theme.of(context); // Get theme for text styles

    return AbsorbPointer(
      // Absorb clicks when not editable
      absorbing: !isEnabled,
      child: Opacity(
        // Dim content when not editable
        opacity: isEnabled ? 1.0 : 0.7,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            // Ensure fields stretch
            children: [
              const SizedBox(height: 16),
              // Plaza Name
              CustomFormFields.normalSizedTextFormField(
                context: context,
                label: "${strings.plazaName} *",
                // Assuming labelPlazaName
                controller: viewModel.plazaNameController,
                enabled: isEnabled,
                errorText:
                    isEnabled ? viewModel.formState.errors['plazaName'] : null,
                prefixIcon: Icon(Icons.business_outlined, color: iconColor),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),

              // --- ADDED COMPANY DETAILS ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CustomFormFields.normalSizedTextFormField(
                      context: context,
                      label: "${strings.labelCompanyName} *",
                      // Assumes label exists in S
                      controller: viewModel.companyNameController,
                      enabled: isEnabled,
                      errorText: isEnabled
                          ? viewModel.formState.errors['companyName']
                          : null,
                      prefixIcon:
                          Icon(Icons.corporate_fare_outlined, color: iconColor),
                      textCapitalization: TextCapitalization.words,
                      maxLength: 20,
                      height: 80, // Added height for counter
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomDropDown.normalDropDown(
                      context: context,
                      label: "${strings.labelCompanyType} *",
                      // Assumes label exists in S
                      value: viewModel.formState.basicDetails['companyType']
                          as String?,
                      items: Plaza.validCompanyTypes,
                      enabled: isEnabled,
                      onChanged: (value) {
                        developer.log('Company Type changed to: $value',
                            name: _logName);
                        if (value != null) {
                          viewModel.formState.basicDetails['companyType'] =
                              value;
                          viewModel.formState.errors
                              .remove('companyType'); // Clear error on change
                          viewModel.notifyListeners(); // Update UI
                        }
                      },
                      errorText: isEnabled
                          ? viewModel.formState.errors['companyType']
                          : null,
                      prefixIcon: Icon(Icons.business_center_outlined,
                          color: iconColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              CustomFormFields.normalSizedTextFormField(
                context: context,
                label: "${strings.labelPlazaOrgId} *",
                // Assumes label exists in S
                controller: viewModel.plazaOrgIdController,
                enabled: isEnabled,
                errorText:
                    isEnabled ? viewModel.formState.errors['plazaOrgId'] : null,
                prefixIcon: Icon(Icons.badge_outlined, color: iconColor),
                textCapitalization: TextCapitalization.characters,
                maxLength: 5,
                height: 80, // Added height for counter
              ),
              const SizedBox(height: 16),
              // --- END ADDED COMPANY DETAILS ---

              // REMOVED Operator Name Field
              // CustomFormFields.normalSizedTextFormField(
              //   context: context,
              //   label: strings.plazaOperatorName,
              //   controller: viewModel.operatorNameController, // REMOVED Controller
              //   enabled: isEnabled,
              //   errorText: isEnabled ? viewModel.formState.errors['plazaOperatorName'] : null,
              // ),
              // const SizedBox(height: 16),

              // Plaza Owner (Read-only usually, but schema requires it)
              // Keep it simple, maybe disable permanently if ID is the key driver
              CustomFormFields.normalSizedTextFormField(
                context: context,
                label: "${strings.plazaOwner} *",
                // Assuming labelPlazaOwner
                controller: viewModel.plazaOwnerController,
                enabled: isEnabled,
                // Keep editable as per schema? Or disable?
                errorText:
                    isEnabled ? viewModel.formState.errors['plazaOwner'] : null,
                prefixIcon: Icon(Icons.person_outline, color: iconColor),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),

              // Plaza Owner ID (Read-only usually)
              CustomFormFields.normalSizedTextFormField(
                context: context,
                label: "${strings.plazaOwnerId} *",
                // Assuming labelPlazaOwnerId
                controller: viewModel.plazaOwnerIdController,
                enabled: false,
                // Usually disabled as it comes from login/context
                errorText: isEnabled
                    ? viewModel.formState.errors['plazaOwnerId']
                    : null,
                prefixIcon: Icon(Icons.fingerprint, color: disabledIconColor),
              ),
              const SizedBox(height: 16),

              // Mobile Number
              CustomFormFields.normalSizedTextFormField(
                context: context,
                label: "${strings.mobileNumber} *",
                // Assuming labelMobileNumber
                maxLength: 15,
                // UPDATED
                height: 80,
                // Keep height for counter
                controller: viewModel.mobileController,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                enabled: isEnabled,
                errorText: isEnabled
                    ? viewModel.formState.errors['mobileNumber']
                    : null,
                prefixIcon:
                    Icon(Icons.phone_android_outlined, color: iconColor),
              ),
              const SizedBox(height: 16),

              // Email
              CustomFormFields.normalSizedTextFormField(
                context: context,
                label: "${strings.email} *",
                // Assuming labelEmail
                controller: viewModel.emailController,
                keyboardType: TextInputType.emailAddress,
                enabled: isEnabled,
                errorText:
                    isEnabled ? viewModel.formState.errors['email'] : null,
                prefixIcon: Icon(Icons.email_outlined, color: iconColor),
              ),
              const SizedBox(height: 16),

              // Address
              CustomFormFields.largeSizedTextFormField(
                // Use large field for address
                context: context,
                label: "${strings.address} *",
                // Assuming labelAddress
                controller: viewModel.addressController,
                keyboardType: TextInputType.streetAddress,
                textCapitalization: TextCapitalization.sentences,
                enabled: isEnabled,
                errorText:
                    isEnabled ? viewModel.formState.errors['address'] : null,
                prefixIcon: Icon(Icons.location_on_outlined, color: iconColor),
              ),
              const SizedBox(height: 16),

              // City / District Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CustomFormFields.normalSizedTextFormField(
                      context: context,
                      label: "${strings.city} *",
                      // Assuming labelCity
                      controller: viewModel.cityController,
                      textCapitalization: TextCapitalization.words,
                      enabled: isEnabled,
                      errorText:
                          isEnabled ? viewModel.formState.errors['city'] : null,
                      prefixIcon:
                          Icon(Icons.location_city_outlined, color: iconColor),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomFormFields.normalSizedTextFormField(
                      context: context,
                      label: "${strings.district} *",
                      // Assuming labelDistrict
                      controller: viewModel.districtController,
                      textCapitalization: TextCapitalization.words,
                      enabled: isEnabled,
                      errorText: isEnabled
                          ? viewModel.formState.errors['district']
                          : null,
                      prefixIcon: Icon(Icons.map_outlined, color: iconColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // State / Pincode Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CustomFormFields.normalSizedTextFormField(
                      context: context,
                      label: "${strings.state} *",
                      // Assuming labelState
                      controller: viewModel.stateController,
                      textCapitalization: TextCapitalization.words,
                      enabled: isEnabled,
                      errorText: isEnabled
                          ? viewModel.formState.errors['state']
                          : null,
                      prefixIcon: Icon(Icons.public_outlined, color: iconColor),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomFormFields.normalSizedTextFormField(
                      context: context,
                      label: "${strings.pincode} *",
                      // Assuming labelPincode
                      controller: viewModel.pincodeController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      maxLength: 6,
                      enabled: isEnabled,
                      errorText: isEnabled
                          ? viewModel.formState.errors['pincode']
                          : null,
                      height: 80,
                      // Height for counter
                      prefixIcon:
                          Icon(Icons.fiber_pin_outlined, color: iconColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Latitude / Longitude Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CustomFormFields.normalSizedTextFormField(
                      context: context,
                      label: "${strings.geoLatitude} *",
                      // Assuming labelLatitude
                      controller: viewModel.geoLatitudeController,
                      keyboardType: const TextInputType.numberWithOptions(
                          signed: true, decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^-?\d*\.?\d*'))
                      ],
                      enabled: isEnabled,
                      errorText: isEnabled
                          ? viewModel.formState.errors['geoLatitude']
                          : null,
                      prefixIcon:
                          Icon(Icons.gps_fixed_outlined, color: iconColor),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomFormFields.normalSizedTextFormField(
                      context: context,
                      label: "${strings.geoLongitude} *",
                      // Assuming labelLongitude
                      controller: viewModel.geoLongitudeController,
                      keyboardType: const TextInputType.numberWithOptions(
                          signed: true, decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^-?\d*\.?\d*'))
                      ],
                      enabled: isEnabled,
                      errorText: isEnabled
                          ? viewModel.formState.errors['geoLongitude']
                          : null,
                      prefixIcon:
                          Icon(Icons.gps_not_fixed_outlined, color: iconColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Category / SubCategory Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CustomDropDown.normalDropDown(
                      context: context,
                      label: "${strings.plazaCategory} *",
                      // Assuming labelPlazaCategory
                      value: viewModel.formState.basicDetails['plazaCategory']
                          ?.toString(),
                      items: Plaza.validPlazaCategories,
                      enabled: isEnabled,
                      onChanged: (value) {
                        developer.log('Plaza Category changed to: $value',
                            name: _logName);
                        if (value != null) {
                          viewModel.formState.basicDetails['plazaCategory'] =
                              value;
                          viewModel.formState.errors.remove('plazaCategory');
                          viewModel.notifyListeners();
                        }
                      },
                      errorText: isEnabled
                          ? viewModel.formState.errors['plazaCategory']
                          : null,
                      prefixIcon:
                          Icon(Icons.category_outlined, color: iconColor),
                    ),
                  ),
                  const SizedBox(width: 8), // Reduced spacing?
                  Expanded(
                    child: CustomDropDown.normalDropDown(
                      context: context,
                      label: "${strings.plazaSubCategory} *",
                      // Assuming labelPlazaSubCategory
                      value: viewModel
                          .formState.basicDetails['plazaSubCategory']
                          ?.toString(),
                      items: Plaza.validPlazaSubCategories,
                      enabled: isEnabled,
                      onChanged: (value) {
                        developer.log('Plaza SubCategory changed to: $value',
                            name: _logName);
                        if (value != null) {
                          viewModel.formState.basicDetails['plazaSubCategory'] =
                              value;
                          viewModel.formState.errors.remove('plazaSubCategory');
                          viewModel.notifyListeners();
                        }
                      },
                      errorText: isEnabled
                          ? viewModel.formState.errors['plazaSubCategory']
                          : null,
                      prefixIcon: Icon(Icons.subdirectory_arrow_right_outlined,
                          color: iconColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Status / Free Parking Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                // Center items vertically
                children: [
                  Expanded(
                    child: CustomDropDown.normalDropDown(
                      context: context,
                      label: "${strings.plazaStatus} *",
                      // Assuming labelPlazaStatus
                      value: viewModel.formState.basicDetails['plazaStatus']
                          ?.toString(),
                      items: Plaza.validPlazaStatuses,
                      enabled: isEnabled,
                      onChanged: (value) {
                        developer.log('Plaza Status changed to: $value',
                            name: _logName);
                        if (value != null) {
                          viewModel.formState.basicDetails['plazaStatus'] =
                              value;
                          viewModel.formState.errors.remove('plazaStatus');
                          viewModel.notifyListeners();
                        }
                      },
                      errorText: isEnabled
                          ? viewModel.formState.errors['plazaStatus']
                          : null,
                      prefixIcon:
                          Icon(Icons.toggle_on_outlined, color: iconColor),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    // Use Expanded to take available space
                    // UPDATED to SwitchListTile
                    child: SwitchListTile(
                      title: Text(
                        strings.freeParking, // Assuming labelFreeParking
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color: isEnabled
                                ? theme.colorScheme.onSurface
                                : theme.disabledColor),
                        overflow: TextOverflow.ellipsis,
                      ),
                      value: viewModel.formState.basicDetails['freeParking']
                              as bool? ??
                          false,
                      onChanged: isEnabled
                          ? (value) {
                              developer.log('Free Parking changed to: $value',
                                  name: _logName);
                              viewModel.formState.basicDetails['freeParking'] =
                                  value;
                              viewModel.formState.errors.remove('freeParking');
                              viewModel.notifyListeners(); // Update UI state
                            }
                          : null,
                      activeColor: theme.colorScheme.primary,
                      contentPadding:
                          const EdgeInsets.only(left: 4.0, right: 0),
                      // Adjust padding
                      dense: true,
                      // Make it more compact
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Structure Type / Price Category Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CustomDropDown.normalDropDown(
                      context: context,
                      label: "${strings.structureType} *",
                      // Assuming labelStructureType
                      value: viewModel.formState.basicDetails['structureType']
                          ?.toString(),
                      items: Plaza.validStructureTypes,
                      enabled: isEnabled,
                      onChanged: (value) {
                        developer.log('Structure Type changed to: $value',
                            name: _logName);
                        if (value != null) {
                          viewModel.formState.basicDetails['structureType'] =
                              value;
                          viewModel.formState.errors.remove('structureType');
                          viewModel.notifyListeners();
                        }
                      },
                      errorText: isEnabled
                          ? viewModel.formState.errors['structureType']
                          : null,
                      prefixIcon:
                          Icon(Icons.home_work_outlined, color: iconColor),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomDropDown.normalDropDown(
                      context: context,
                      label: "${strings.priceCategory} *",
                      // Assuming labelPriceCategory
                      value: viewModel.formState.basicDetails['priceCategory']
                          ?.toString(),
                      items: Plaza.validPriceCategories,
                      enabled: isEnabled,
                      onChanged: (value) {
                        developer.log('Price Category changed to: $value',
                            name: _logName);
                        if (value != null) {
                          viewModel.formState.basicDetails['priceCategory'] =
                              value;
                          viewModel.formState.errors.remove('priceCategory');
                          viewModel.notifyListeners();
                        }
                      },
                      errorText: isEnabled
                          ? viewModel.formState.errors['priceCategory']
                          : null,
                      prefixIcon:
                          Icon(Icons.price_change_outlined, color: iconColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Total Parking Slots
              CustomFormFields.normalSizedTextFormField(
                context: context,
                label: "${strings.totalParkingSlots} *",
                // Assuming labelTotalParkingSlots
                controller: viewModel.noOfParkingSlotsController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                enabled: isEnabled,
                errorText: isEnabled
                    ? viewModel.formState.errors['noOfParkingSlots']
                    : null,
                prefixIcon:
                    Icon(Icons.local_parking_outlined, color: iconColor),
              ),
              // Slot validation error message
              if (isEnabled &&
                  viewModel.formState.errors['noOfParkingSlots'] != null &&
                  (viewModel.formState.errors['noOfParkingSlots']!
                          .contains('must be equal') ||
                      viewModel.formState.errors['noOfParkingSlots']!
                          .contains('must equal')))
                Padding(
                  padding:
                      const EdgeInsets.only(top: 4.0, left: 12.0, right: 12.0),
                  child: Text(
                    viewModel.formState.errors['noOfParkingSlots']!,
                    style:
                        TextStyle(color: theme.colorScheme.error, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 20),
              // Space before capacities

              // --- Capacity Fields ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      child: _buildCapacityField(
                          viewModel,
                          strings.bikeCapacity,
                          'capacityBike',
                          iconColor,
                          Icons.two_wheeler_outlined,
                          isEnabled)),
                  // Assuming labelBikeCapacity
                  const SizedBox(width: 8),
                  Expanded(
                      child: _buildCapacityField(
                          viewModel,
                          strings.threeWheelerCapacity,
                          'capacity3Wheeler',
                          iconColor,
                          Icons.electric_rickshaw_outlined,
                          isEnabled)),
                  // Assuming label3WheelerCapacity
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      child: _buildCapacityField(
                          viewModel,
                          strings.fourWheelerCapacity,
                          'capacity4Wheeler',
                          iconColor,
                          Icons.directions_car_outlined,
                          isEnabled)),
                  // Assuming label4WheelerCapacity
                  const SizedBox(width: 8),
                  Expanded(
                      child: _buildCapacityField(
                          viewModel,
                          strings.busCapacity,
                          'capacityBus',
                          iconColor,
                          Icons.directions_bus_outlined,
                          isEnabled)),
                  // Assuming labelBusCapacity
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      child: _buildCapacityField(
                          viewModel,
                          strings.truckCapacity,
                          'capacityTruck',
                          iconColor,
                          Icons.local_shipping_outlined,
                          isEnabled)),
                  // Assuming labelTruckCapacity
                  const SizedBox(width: 8),
                  Expanded(
                      child: _buildCapacityField(
                          viewModel,
                          strings.heavyMachineryCapacity,
                          'capacityHeavyMachinaryVehicle',
                          iconColor,
                          Icons.agriculture_outlined,
                          isEnabled)),
                  // Assuming labelHeavyMachineryCapacity
                ],
              ),
              const SizedBox(height: 16),

              // Opening Time
              GestureDetector(
                onTap: () async {
                  if (!isEnabled) return;
                  developer.log('Opening time picker tapped.', name: _logName);
                  _showCustomTimePicker(
                      context,
                      viewModel.plazaOpenTimingsController,
                      'plazaOpenTimings',
                      viewModel);
                },
                child: AbsorbPointer(
                  child: CustomFormFields.normalSizedTextFormField(
                    context: context,
                    label: "${strings.openingTime} *",
                    // Assuming labelOpeningTime
                    controller: viewModel.plazaOpenTimingsController,
                    enabled: false,
                    // Visually disabled, gesture detector handles tap
                    errorText: isEnabled
                        ? viewModel.formState.errors['plazaOpenTimings']
                        : null,
                    prefixIcon: Icon(Icons.access_time_outlined,
                        color: isEnabled ? iconColor : disabledIconColor),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Closing Time
              GestureDetector(
                onTap: () async {
                  if (!isEnabled) return;
                  developer.log('Closing time picker tapped.', name: _logName);
                  _showCustomTimePicker(
                      context,
                      viewModel.plazaClosingTimeController,
                      'plazaClosingTime',
                      viewModel);
                },
                child: AbsorbPointer(
                  child: CustomFormFields.normalSizedTextFormField(
                    context: context,
                    label: "${strings.closingTime} *",
                    // Assuming labelClosingTime
                    controller: viewModel.plazaClosingTimeController,
                    enabled: false,
                    // Visually disabled
                    errorText: isEnabled
                        ? viewModel.formState.errors['plazaClosingTime']
                        : null,
                    prefixIcon: Icon(Icons.access_time_filled_outlined,
                        color: isEnabled ? iconColor : disabledIconColor),
                  ),
                ),
              ),

              // General Error Display
              if (viewModel.formState.errors['general'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                  child: Center(
                    child: Text(
                      viewModel.formState.errors['general']!,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: theme.colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

              const SizedBox(height: 80),
              // Space for FAB
            ],
          ),
        ),
      ),
    );
  }

  // Helper for capacity fields to reduce repetition
  Widget _buildCapacityField(PlazaModificationViewModel viewModel, String label,
      String mapKey, Color iconColor, IconData icon, bool isEnabled) {
    // Determine which controller to use based on the mapKey
    TextEditingController getControllerForKey() {
      switch (mapKey) {
        case 'capacityBike':
          return viewModel.capacityBikeController;
        case 'capacity3Wheeler':
          return viewModel.capacity3WheelerController;
        case 'capacity4Wheeler':
          return viewModel.capacity4WheelerController;
        case 'capacityBus':
          return viewModel.capacityBusController;
        case 'capacityTruck':
          return viewModel.capacityTruckController;
        case 'capacityHeavyMachinaryVehicle':
          return viewModel.capacityHeavyMachineryController;
        default:
          throw ArgumentError(
              'Invalid mapKey for capacity field: $mapKey'); // Should not happen
      }
    }

    return CustomFormFields.normalSizedTextFormField(
      context: context,
      label: label,
      controller: getControllerForKey(),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      enabled: isEnabled,
      errorText: isEnabled ? viewModel.formState.errors[mapKey] : null,
      prefixIcon: Icon(icon, color: iconColor),
    );
  }

  // Helper method for Time Picker (copied from BasicDetailsStep)
  Future<void> _showCustomTimePicker(
      BuildContext context,
      TextEditingController controller,
      String mapKey,
      PlazaModificationViewModel viewModel) async {
    developer.log(
        '[_showCustomTimePicker] Showing time picker for key: $mapKey',
        name: _logName);
    TimeOfDay initialTime = TimeOfDay.now();
    try {
      final parts = controller.text.split(':');
      if (parts.length == 2) {
        final hour = int.tryParse(parts[0]);
        final minute = int.tryParse(parts[1]);
        if (hour != null &&
            hour >= 0 &&
            hour < 24 &&
            minute != null &&
            minute >= 0 &&
            minute < 60) {
          initialTime = TimeOfDay(hour: hour, minute: minute);
          developer.log(
              '[_showCustomTimePicker] Parsed initial time: $initialTime',
              name: _logName);
        }
      }
    } catch (e) {
      developer.log(
          '[_showCustomTimePicker] Error parsing initial time "${controller.text}", using current time. Error: $e',
          name: _logName,
          level: 800);
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );

    if (picked != null && context.mounted) {
      final formattedTime =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      developer.log(
          '[_showCustomTimePicker] Time picked: $formattedTime. Updating ViewModel for key: $mapKey',
          name: _logName);
      // Update controller AND map state
      controller.text = formattedTime; // Update controller directly
      viewModel.formState.basicDetails[mapKey] =
          formattedTime; // Update map state
      viewModel.formState.errors.remove(mapKey); // Clear potential error
      viewModel
          .notifyListeners(); // Notify if needed, though controller update triggers rebuild via watch
    } else {
      developer.log(
          '[_showCustomTimePicker] Time picker cancelled or context unmounted.',
          name: _logName);
    }
  }

  // --- FABs and Error State Widgets (Remain Unchanged) ---
  Widget _buildFloatingActionButtons(
      PlazaModificationViewModel viewModel, S strings) {
    developer.log(
        'Building FABs. isEditable: ${viewModel.isBasicDetailsEditable}',
        name: _logName);
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
            developer.log(
                'Save/Edit FAB pressed. Current mode: ${viewModel.isBasicDetailsEditable ? "Save" : "Edit"}',
                name: _logName);
            if (viewModel.isBasicDetailsEditable) {
              FocusScope.of(context).unfocus(); // Hide keyboard
              developer.log('Attempting to save basic details.',
                  name: _logName);
              final isValid = viewModel.formState.validateBasicDetails(
                  context); // validation call will trigger error snackbar if needed
              developer.log(
                  'Validation result: $isValid. Errors: ${viewModel.formState.errors}',
                  name: _logName);
              if (isValid) {
                try {
                  developer.log(
                      'Validation passed. Calling updateBasicDetails.',
                      name: _logName);
                  await viewModel.updateBasicDetails(context);
                  developer.log('updateBasicDetails completed.',
                      name: _logName); // Success dialog shown by VM
                } catch (e, stackTrace) {
                  // Catching here might be redundant if VM handles errors and shows snackbars
                  developer.log('Error updating basic details (caught in UI)',
                      name: _logName, error: e, stackTrace: stackTrace);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              strings.updatePlazaFailed)), // Generic message
                    );
                  }
                }
              }
              // No need for else block showing snackbar, validateBasicDetails already does it
            } else {
              developer.log('Toggling basic details to editable mode.',
                  name: _logName);
              viewModel.toggleBasicDetailsEditable();
            }
          },
          heroTag: "save_or_edit_basic_details",
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          // Show loading indicator on FAB if saving
          label: viewModel.isLoading && viewModel.isBasicDetailsEditable
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.onPrimary,
                      strokeWidth: 2))
              : Text(viewModel.isBasicDetailsEditable
                  ? strings.save
                  : strings.edit),
          icon:
              Icon(viewModel.isBasicDetailsEditable ? Icons.save : Icons.edit),
        ),
      ],
    );
  }

  Widget _buildErrorState(
      PlazaModificationViewModel viewModel, String plazaId, S strings) {
    Exception? error = viewModel.error;
    developer.log('Building error state for plazaId: $plazaId',
        name: _logName, error: error);
    String errorTitle = strings.errorTitleDefault;
    String errorMessage = strings.errorMessageDefault;
    String? errorDetails;

    // Determine error message based on type (same logic as before)
    if (error is HttpException) {
      final statusCode = error.statusCode;
      errorTitle = statusCode != null
          ? strings.errorTitleWithCode(statusCode)
          : strings.errorTitleServer;
      errorMessage = error.message;
      errorDetails = error.serverMessage ?? strings.errorDetailsNoDetails;
    } else if (error is PlazaException || error is ServiceException) {
      errorTitle =
          strings.errorLoadingPlazaDetailsFailed; // More specific title?
      errorMessage = (error as dynamic)
          .message; // Assuming custom exceptions have a message property
      errorDetails =
          (error as dynamic).serverMessage ?? strings.errorDetailsNoDetails;
    } else if (error != null) {
      errorTitle = strings.errorLoadingPlazaDetailsFailed;
      errorMessage = strings.errorMessagePleaseTryAgain;
      errorDetails = error.toString(); // Log the raw error
    }

    developer.log(
        'Error details - Title: $errorTitle, Message: $errorMessage, Details: $errorDetails',
        name: _logName);

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
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
              textAlign: TextAlign.center,
            ),
            if (errorDetails != null &&
                errorDetails.isNotEmpty &&
                errorDetails != errorMessage) ...[
              // Avoid showing details if same as message
              const SizedBox(height: 8),
              Text(
                errorDetails,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.5),
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            CustomButtons.primaryButton(
              text: strings.retry,
              onPressed: () {
                developer.log('Retry button pressed for plazaId: $plazaId',
                    name: _logName);
                viewModel.clearError(); // Clear error before retrying
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
