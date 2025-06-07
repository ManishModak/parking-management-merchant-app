import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:merchant_app/models/plaza.dart';
import 'package:merchant_app/utils/components/dropdown.dart';
import 'package:merchant_app/utils/components/form_field.dart';
import 'package:provider/provider.dart';
import '../../../generated/l10n.dart';
import '../../../viewmodels/plaza/basic_details_viewmodel.dart'; // Using this VM
import '../../../viewmodels/plaza/plaza_viewmodel.dart';

class BasicDetailsStep extends StatelessWidget {
  const BasicDetailsStep({super.key});

  @override
  Widget build(BuildContext context) {
    // Use the BasicDetailsViewModel from the main PlazaViewModel
    final basicDetailsVM = context.watch<PlazaViewModel>().basicDetails;
    final strings = S.of(context);
    final theme = Theme.of(context);
    final bool isEnabled = basicDetailsVM.isEditable;
    final bool isLoading = basicDetailsVM.isLoading;

    developer.log(
        '[BasicDetailsStep UI Build] isEditable=$isEnabled, isLoading=$isLoading, Errors: ${basicDetailsVM.errors.isNotEmpty}',
        name: 'BasicDetailsStep');

    // Plaza Owner Display Logic (unchanged)
    final ownerName = basicDetailsVM.basicDetails['plazaOwner'] as String?;
    final ownerId = basicDetailsVM.basicDetails['plazaOwnerId'] as String?;
    final plazaOwnerDisplay = (ownerName != null &&
            ownerName.isNotEmpty &&
            ownerId != null &&
            ownerId.isNotEmpty)
        ? '$ownerName (ID: $ownerId)'
        : (ownerName != null && ownerName.isNotEmpty
            ? ownerName
            : strings.labelUserDataNotAvailable);

    // Update controller text after build (unchanged)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted &&
          basicDetailsVM.plazaOwnerController.text != plazaOwnerDisplay) {
        basicDetailsVM.plazaOwnerController.text = plazaOwnerDisplay;
      }
    });

    final Color iconColor = isEnabled
        ? theme.iconTheme.color ?? theme.primaryColor
        : theme.disabledColor;
    final Color disabledIconColor = theme.disabledColor;

    return AbsorbPointer(
      absorbing: !isEnabled,
      // Still useful if modification becomes an option later
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.7, // Dim if disabled
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          // Added horizontal padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Plaza Owner (Read-only)
              CustomFormFields.normalSizedTextFormField(
                context: context,
                label: strings.labelPlazaOwner,
                controller: basicDetailsVM.plazaOwnerController,
                enabled: false,
                // Always disabled
                isPassword: false,
                prefixIcon:
                    Icon(Icons.person_pin_outlined, color: disabledIconColor),
              ),
              const SizedBox(height: 16),

              // *** ADDED Plaza ID Input Field ***
              CustomFormFields.normalSizedTextFormField(
                context: context,
                label: "${strings.labelPlazaId} *",
                // Add this label to S class
                controller: basicDetailsVM.plazaIdController,
                enabled: isEnabled,
                // Enable during creation
                isPassword: false,
                errorText: isEnabled ? basicDetailsVM.errors['plazaId'] : null,
                prefixIcon: Icon(Icons.vpn_key_outlined, color: iconColor),
                maxLength: 6,
                // Enforce max length
                height: 80,
                // Height for counter
                // Optional: Add input formatters if only specific chars allowed
                // inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]'))], // Example: Alphanumeric only
                textCapitalization:
                    TextCapitalization.characters, // Suggest uppercase
              ),
              const SizedBox(height: 16),
              // --- END Plaza ID Field ---

              // Plaza Name
              CustomFormFields.normalSizedTextFormField(
                context: context,
                label: "${strings.labelPlazaName} *",
                controller: basicDetailsVM.plazaNameController,
                enabled: isEnabled,
                isPassword: false,
                errorText:
                    isEnabled ? basicDetailsVM.errors['plazaName'] : null,
                prefixIcon: Icon(Icons.business_outlined, color: iconColor),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),

              // --- Company Details ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CustomFormFields.normalSizedTextFormField(
                      context: context,
                      label: "${strings.labelCompanyName} *",
                      controller: basicDetailsVM.companyNameController,
                      enabled: isEnabled,
                      isPassword: false,
                      errorText: isEnabled
                          ? basicDetailsVM.errors['companyName']
                          : null,
                      prefixIcon:
                          Icon(Icons.corporate_fare_outlined, color: iconColor),
                      textCapitalization: TextCapitalization.words,
                      maxLength: 20,
                      height: 80,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomDropDown.normalDropDown(
                      context: context,
                      label: "${strings.labelCompanyType} *",
                      value:
                          basicDetailsVM.basicDetails['companyType'] as String?,
                      items: Plaza.validCompanyTypes,
                      enabled: isEnabled,
                      onChanged: (value) => basicDetailsVM.updateDropdownValue(
                          'companyType', value),
                      errorText: isEnabled
                          ? basicDetailsVM.errors['companyType']
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
                controller: basicDetailsVM.plazaOrgIdController,
                enabled: isEnabled,
                isPassword: false,
                errorText:
                    isEnabled ? basicDetailsVM.errors['plazaOrgId'] : null,
                prefixIcon: Icon(Icons.badge_outlined, color: iconColor),
                textCapitalization: TextCapitalization.characters,
                maxLength: 5,
                height: 80,
              ),
              const SizedBox(height: 16),
              // --- END Company Details ---

              // Email
              CustomFormFields.normalSizedTextFormField(
                context: context,
                label: "${strings.labelEmail} *",
                controller: basicDetailsVM.emailController,
                enabled: isEnabled,
                isPassword: false,
                errorText: isEnabled ? basicDetailsVM.errors['email'] : null,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icon(Icons.email_outlined, color: iconColor),
              ),
              const SizedBox(height: 16),

              // Mobile Number
              CustomFormFields.normalSizedTextFormField(
                context: context,
                label: "${strings.labelMobileNumber} *",
                controller: basicDetailsVM.mobileNumberController,
                enabled: isEnabled,
                isPassword: false,
                errorText:
                    isEnabled ? basicDetailsVM.errors['mobileNumber'] : null,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 10,
                // Kept updated length
                height: 80,
                prefixIcon:
                    Icon(Icons.phone_android_outlined, color: iconColor),
              ),
              _buildSectionDivider(), // Divider
              const SizedBox(height: 16),

              // Plaza Category / SubCategory Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CustomDropDown.normalDropDown(
                      context: context,
                      label: "${strings.labelPlazaCategory} *",
                      value: basicDetailsVM.basicDetails['plazaCategory']
                          as String?,
                      items: Plaza.validPlazaCategories,
                      enabled: isEnabled,
                      onChanged: (value) => basicDetailsVM.updateDropdownValue(
                          'plazaCategory', value),
                      errorText: isEnabled
                          ? basicDetailsVM.errors['plazaCategory']
                          : null,
                      prefixIcon:
                          Icon(Icons.category_outlined, color: iconColor),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomDropDown.normalDropDown(
                      context: context,
                      label: "${strings.labelPlazaSubCategory} *",
                      value: basicDetailsVM.basicDetails['plazaSubCategory']
                          as String?,
                      items: Plaza.validPlazaSubCategories,
                      enabled: isEnabled,
                      onChanged: (value) => basicDetailsVM.updateDropdownValue(
                          'plazaSubCategory', value),
                      errorText: isEnabled
                          ? basicDetailsVM.errors['plazaSubCategory']
                          : null,
                      prefixIcon: Icon(Icons.subdirectory_arrow_right_outlined,
                          color: iconColor),
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
                      label: "${strings.labelStructureType} *",
                      value: basicDetailsVM.basicDetails['structureType']
                          as String?,
                      items: Plaza.validStructureTypes,
                      enabled: isEnabled,
                      onChanged: (value) => basicDetailsVM.updateDropdownValue(
                          'structureType', value),
                      errorText: isEnabled
                          ? basicDetailsVM.errors['structureType']
                          : null,
                      prefixIcon:
                          Icon(Icons.home_work_outlined, color: iconColor),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomDropDown.normalDropDown(
                      context: context,
                      label: "${strings.labelPriceCategory} *",
                      value: basicDetailsVM.basicDetails['priceCategory']
                          as String?,
                      items: Plaza.validPriceCategories,
                      enabled: isEnabled,
                      onChanged: (value) => basicDetailsVM.updateDropdownValue(
                          'priceCategory', value),
                      errorText: isEnabled
                          ? basicDetailsVM.errors['priceCategory']
                          : null,
                      prefixIcon:
                          Icon(Icons.price_change_outlined, color: iconColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Plaza Status / Free Parking Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: CustomDropDown.normalDropDown(
                      context: context,
                      label: "${strings.labelPlazaStatus} *",
                      value: basicDetailsVM.basicDetails['plazaStatus']
                              as String? ??
                          Plaza.validPlazaStatuses.first,
                      items: Plaza.validPlazaStatuses,
                      enabled: isEnabled,
                      onChanged: (value) => basicDetailsVM.updateDropdownValue(
                          'plazaStatus', value),
                      errorText: isEnabled
                          ? basicDetailsVM.errors['plazaStatus']
                          : null,
                      prefixIcon:
                          Icon(Icons.toggle_on_outlined, color: iconColor),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                      child: SwitchListTile(
                    title: Text(
                      strings.labelFreeParking,
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: isEnabled
                              ? theme.colorScheme.onSurface
                              : theme.disabledColor),
                      overflow: TextOverflow.ellipsis,
                    ),
                    value:
                        basicDetailsVM.basicDetails['freeParking'] as bool? ??
                            false,
                    onChanged: isEnabled
                        ? (value) => basicDetailsVM.updateBooleanValue(
                            'freeParking', value)
                        : null,
                    activeColor: theme.colorScheme.primary,
                    contentPadding: const EdgeInsets.only(left: 4.0, right: 0),
                    dense: true,
                    visualDensity: VisualDensity.compact,
                  )),
                ],
              ),

              // Get Location Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (isEnabled)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                      child: TextButton.icon(
                        icon: isLoading &&
                                basicDetailsVM
                                    .geoLatitudeController.text.isEmpty
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: theme.colorScheme.primary))
                            : Icon(Icons.my_location,
                                size: 18, color: theme.colorScheme.primary),
                        label: Text(strings.buttonGetLocation,
                            style: TextStyle(color: theme.colorScheme.primary)),
                        onPressed: isLoading || !isEnabled
                            ? null
                            : () {
                                if (context.mounted) {
                                  basicDetailsVM.getCurrentLocation(context);
                                }
                              },
                        style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8)),
                      ),
                    ),
                ],
              ),

              // Latitude / Longitude Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      child: CustomFormFields.normalSizedTextFormField(
                    context: context,
                    label: "${strings.labelLatitude} *",
                    controller: basicDetailsVM.geoLatitudeController,
                    enabled: isEnabled,
                    isPassword: false,
                    errorText:
                        isEnabled ? basicDetailsVM.errors['geoLatitude'] : null,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true, signed: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*'))
                    ],
                    prefixIcon:
                        Icon(Icons.gps_fixed_outlined, color: iconColor),
                  )),
                  const SizedBox(width: 16),
                  Expanded(
                      child: CustomFormFields.normalSizedTextFormField(
                    context: context,
                    label: "${strings.labelLongitude} *",
                    controller: basicDetailsVM.geoLongitudeController,
                    enabled: isEnabled,
                    isPassword: false,
                    errorText: isEnabled
                        ? basicDetailsVM.errors['geoLongitude']
                        : null,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true, signed: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*'))
                    ],
                    prefixIcon:
                        Icon(Icons.gps_not_fixed_outlined, color: iconColor),
                  )),
                ],
              ),
              const SizedBox(height: 16),

              // Address
              CustomFormFields.largeSizedTextFormField(
                context: context,
                label: "${strings.labelAddress} *",
                controller: basicDetailsVM.addressController,
                enabled: isEnabled,
                errorText: isEnabled ? basicDetailsVM.errors['address'] : null,
                prefixIcon: Icon(Icons.location_on_outlined, color: iconColor),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),

              // City / District Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      child: CustomFormFields.normalSizedTextFormField(
                    context: context,
                    label: "${strings.labelCity} *",
                    controller: basicDetailsVM.cityController,
                    enabled: isEnabled,
                    isPassword: false,
                    errorText: isEnabled ? basicDetailsVM.errors['city'] : null,
                    textCapitalization: TextCapitalization.words,
                    prefixIcon:
                        Icon(Icons.location_city_outlined, color: iconColor),
                  )),
                  const SizedBox(width: 16),
                  Expanded(
                      child: CustomFormFields.normalSizedTextFormField(
                    context: context,
                    label: "${strings.labelDistrict} *",
                    controller: basicDetailsVM.districtController,
                    enabled: isEnabled,
                    isPassword: false,
                    errorText:
                        isEnabled ? basicDetailsVM.errors['district'] : null,
                    textCapitalization: TextCapitalization.words,
                    prefixIcon: Icon(Icons.map_outlined, color: iconColor),
                  )),
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
                    label: "${strings.labelState} *",
                    controller: basicDetailsVM.stateController,
                    enabled: isEnabled,
                    isPassword: false,
                    errorText:
                        isEnabled ? basicDetailsVM.errors['state'] : null,
                    textCapitalization: TextCapitalization.words,
                    prefixIcon: Icon(Icons.public_outlined, color: iconColor),
                  )),
                  const SizedBox(width: 16),
                  Expanded(
                      child: CustomFormFields.normalSizedTextFormField(
                    context: context,
                    label: "${strings.labelPincode} *",
                    controller: basicDetailsVM.pincodeController,
                    enabled: isEnabled,
                    isPassword: false,
                    errorText:
                        isEnabled ? basicDetailsVM.errors['pincode'] : null,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    maxLength: 6,
                    height: 80,
                    prefixIcon:
                        Icon(Icons.fiber_pin_outlined, color: iconColor),
                  )),
                ],
              ),
              _buildSectionDivider(),
              const SizedBox(height: 16),

              // Opening / Closing Time Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: isEnabled
                          ? () => _showCustomTimePicker(
                              context,
                              basicDetailsVM.plazaOpenTimingsController,
                              'plazaOpenTimings',
                              basicDetailsVM)
                          : null,
                      child: AbsorbPointer(
                        absorbing: true,
                        child: CustomFormFields.normalSizedTextFormField(
                          context: context,
                          label: "${strings.labelOpeningTime} *",
                          controller: basicDetailsVM.plazaOpenTimingsController,
                          enabled: false,
                          // Keep visually disabled
                          isPassword: false,
                          errorText: isEnabled
                              ? basicDetailsVM.errors['plazaOpenTimings']
                              : null,
                          prefixIcon: Icon(Icons.access_time_outlined,
                              color: isEnabled ? iconColor : disabledIconColor),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: isEnabled
                          ? () => _showCustomTimePicker(
                              context,
                              basicDetailsVM.plazaClosingTimeController,
                              'plazaClosingTime',
                              basicDetailsVM)
                          : null,
                      child: AbsorbPointer(
                        absorbing: true,
                        child: CustomFormFields.normalSizedTextFormField(
                          context: context,
                          label: "${strings.labelClosingTime} *",
                          controller: basicDetailsVM.plazaClosingTimeController,
                          enabled: false,
                          // Keep visually disabled
                          isPassword: false,
                          errorText: isEnabled
                              ? basicDetailsVM.errors['plazaClosingTime']
                              : null,
                          prefixIcon: Icon(Icons.access_time_filled_outlined,
                              color: isEnabled ? iconColor : disabledIconColor),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Total Parking Slots
              CustomFormFields.normalSizedTextFormField(
                context: context,
                label: "${strings.labelTotalParkingSlots} *",
                controller: basicDetailsVM.noOfParkingSlotsController,
                enabled: isEnabled,
                isPassword: false,
                errorText: isEnabled
                    ? basicDetailsVM.errors['noOfParkingSlots']
                    : null,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                prefixIcon:
                    Icon(Icons.local_parking_outlined, color: iconColor),
              ),
              // Slot validation error message
              if (isEnabled &&
                  basicDetailsVM.errors['noOfParkingSlots'] != null &&
                  (basicDetailsVM.errors['noOfParkingSlots']!
                          .contains('must be equal') ||
                      basicDetailsVM.errors['noOfParkingSlots']!
                          .contains('must equal')))
                Padding(
                  padding:
                      const EdgeInsets.only(top: 4.0, left: 12.0, right: 12.0),
                  child: Text(
                    basicDetailsVM.errors['noOfParkingSlots']!,
                    style:
                        TextStyle(color: theme.colorScheme.error, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 20),

              // Capacity Fields (using helper)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      child: _buildCapacityField(
                          basicDetailsVM,
                          strings.labelCapacityBike,
                          'capacityBike',
                          iconColor,
                          Icons.two_wheeler_outlined,
                          isEnabled,context)),
                  const SizedBox(width: 8),
                  Expanded(
                      child: _buildCapacityField(
                          basicDetailsVM,
                          strings.labelCapacity3Wheeler,
                          'capacity3Wheeler',
                          iconColor,
                          Icons.electric_rickshaw_outlined,
                          isEnabled,context)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      child: _buildCapacityField(
                          basicDetailsVM,
                          strings.labelCapacity4Wheeler,
                          'capacity4Wheeler',
                          iconColor,
                          Icons.directions_car_outlined,
                          isEnabled,context)),
                  const SizedBox(width: 8),
                  Expanded(
                      child: _buildCapacityField(
                          basicDetailsVM,
                          strings.labelCapacityBus,
                          'capacityBus',
                          iconColor,
                          Icons.directions_bus_outlined,
                          isEnabled,context)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      child: _buildCapacityField(
                          basicDetailsVM,
                          strings.labelCapacityTruck,
                          'capacityTruck',
                          iconColor,
                          Icons.local_shipping_outlined,
                          isEnabled,context)),
                  const SizedBox(width: 8),
                  Expanded(
                      child: _buildCapacityField(
                          basicDetailsVM,
                          strings.labelCapacityHeavyMachinery,
                          'capacityHeavyMachinaryVehicle',
                          iconColor,
                          Icons.agriculture_outlined,
                          isEnabled,context)),
                ],
              ),
              const SizedBox(height: 24),

              // General Error Display
              if (basicDetailsVM.errors['general'] !=
                  null) // Show general error always if present
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                  child: Center(
                    child: Text(
                      basicDetailsVM.errors['general']!,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: theme.colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              const SizedBox(height: 16), // Padding at the bottom
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---
  Widget _buildSectionDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Divider(height: 1, thickness: 0.8),
    );
  }

  // Helper for capacity fields
  Widget _buildCapacityField(BasicDetailsViewModel viewModel, String label,
      String mapKey, Color iconColor, IconData icon, bool isEnabled, BuildContext context) {
    // Determine controller based on mapKey
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
          return viewModel.capacityHeavyMachinaryVehicleController;
        default:
          throw ArgumentError('Invalid mapKey for capacity field: $mapKey');
      }
    }

    return CustomFormFields.normalSizedTextFormField(
      context: context,
      // Needs context
      label: label,
      // Required field, add "*" if needed: "$label *"
      controller: getControllerForKey(),
      enabled: isEnabled,
      isPassword: false,
      errorText: isEnabled ? viewModel.errors[mapKey] : null,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      prefixIcon: Icon(icon, color: iconColor),
    );
  }

  // Time Picker function (Unchanged)
  Future<void> _showCustomTimePicker(
      BuildContext context,
      TextEditingController controller,
      String mapKey,
      BasicDetailsViewModel viewModel) async {
    developer.log('[BasicDetailsStep] Showing time picker for key: $mapKey',
        name: 'BasicDetailsStep');
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
          developer.log('[BasicDetailsStep] Parsed initial time: $initialTime',
              name: 'BasicDetailsStep');
        }
      }
    } catch (e) {
      developer.log(
          '[BasicDetailsStep] Error parsing initial time "${controller.text}", using current time. Error: $e',
          name: 'BasicDetailsStep',
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
          '[BasicDetailsStep] Time picked: $formattedTime. Updating ViewModel for key: $mapKey',
          name: 'BasicDetailsStep');
      viewModel.updateTimeValue(
          mapKey, formattedTime); // This updates controller and map
    } else {
      developer.log(
          '[BasicDetailsStep] Time picker cancelled or context unmounted.',
          name: 'BasicDetailsStep');
    }
  }
}
