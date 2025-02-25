import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_config.dart';
import '../../../models/plaza.dart';
import '../../../utils/components/dropdown.dart';
import '../../../utils/components/form_field.dart';
import '../../../viewmodels/plaza/plaza_viewmodel.dart';

class BasicDetailsStep extends StatefulWidget {
  const BasicDetailsStep({super.key});

  @override
  State<BasicDetailsStep> createState() => _BasicDetailsStepState();
}

class _BasicDetailsStepState extends State<BasicDetailsStep> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PlazaViewModel>();

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // Plaza Owner
          CustomFormFields.primaryFormField(
            label: 'Plaza Owner',
            controller: viewModel.plazaOwnerController,
            keyboardType: TextInputType.text,
            isPassword: false,
            enabled: false,
            errorText: viewModel.formState.errors['plazaOwner'],
          ),
          const SizedBox(height: 16),

          // Plaza Name
          CustomFormFields.primaryFormField(
            label: 'Plaza Name',
            controller: viewModel.plazaNameController,
            keyboardType: TextInputType.text,
            isPassword: false,
            enabled: viewModel.currentStep == 0 &&
                (viewModel.completeTillStep <= 0 ||
                    viewModel.isBasicDetailsEditable),
            errorText: viewModel.formState.errors['plazaName'],
          ),
          const SizedBox(height: 16),

          // Plaza Operator Name
          CustomFormFields.primaryFormField(
            label: 'Plaza Operator Name',
            controller: viewModel.operatorNameController,
            keyboardType: TextInputType.text,
            isPassword: false,
            enabled: viewModel.currentStep == 0 &&
                (viewModel.completeTillStep <= 0 ||
                    viewModel.isBasicDetailsEditable),
            errorText: viewModel.formState.errors['operatorName'],
          ),
          const SizedBox(height: 16),

          // Plaza Operator ID
          CustomFormFields.primaryFormField(
            label: 'Plaza Operator ID',
            controller: viewModel.operatorIdController,
            keyboardType: TextInputType.text,
            isPassword: false,
            enabled: viewModel.currentStep == 0 &&
                (viewModel.completeTillStep <= 0 ||
                    viewModel.isBasicDetailsEditable),
            errorText: viewModel.formState.errors['operatorId'],
          ),
          const SizedBox(height: 16),

          // Mobile Number
          CustomFormFields.primaryFormField(
            label: 'Mobile Number',
            controller: viewModel.mobileController,
            keyboardType: TextInputType.phone,
            isPassword: false,
            enabled: viewModel.currentStep == 0 &&
                (viewModel.completeTillStep <= 0 ||
                    viewModel.isBasicDetailsEditable),
            errorText: viewModel.formState.errors['mobileNumber'],
          ),
          const SizedBox(height: 16),

          // Email
          CustomFormFields.primaryFormField(
            label: 'Email',
            controller: viewModel.emailController,
            keyboardType: TextInputType.emailAddress,
            isPassword: false,
            enabled: viewModel.currentStep == 0 &&
                (viewModel.completeTillStep <= 0 ||
                    viewModel.isBasicDetailsEditable),
            errorText: viewModel.formState.errors['email'],
          ),
          const SizedBox(height: 16),

          // Address
          CustomFormFields.primaryFormField(
            label: 'Address',
            controller: viewModel.addressController,
            keyboardType: TextInputType.text,
            isPassword: false,
            enabled: viewModel.currentStep == 0 &&
                (viewModel.completeTillStep <= 0 ||
                    viewModel.isBasicDetailsEditable),
            errorText: viewModel.formState.errors['address'],
          ),
          const SizedBox(height: 16),

          // City
          CustomFormFields.primaryFormField(
            label: 'City',
            controller: viewModel.cityController,
            keyboardType: TextInputType.text,
            isPassword: false,
            enabled: viewModel.currentStep == 0 &&
                (viewModel.completeTillStep <= 0 ||
                    viewModel.isBasicDetailsEditable),
            errorText: viewModel.formState.errors['city'],
          ),
          const SizedBox(height: 16),

          // District
          CustomFormFields.primaryFormField(
            label: 'District',
            controller: viewModel.districtController,
            keyboardType: TextInputType.text,
            isPassword: false,
            enabled: viewModel.currentStep == 0 &&
                (viewModel.completeTillStep <= 0 ||
                    viewModel.isBasicDetailsEditable),
            errorText: viewModel.formState.errors['district'],
          ),
          const SizedBox(height: 16),

          // State
          CustomFormFields.primaryFormField(
            label: 'State',
            controller: viewModel.stateController,
            keyboardType: TextInputType.text,
            isPassword: false,
            enabled: viewModel.currentStep == 0 &&
                (viewModel.completeTillStep <= 0 ||
                    viewModel.isBasicDetailsEditable),
            errorText: viewModel.formState.errors['state'],
          ),
          const SizedBox(height: 16),

          // Pincode
          CustomFormFields.primaryFormField(
            label: 'Pincode',
            controller: viewModel.pincodeController,
            keyboardType: TextInputType.number,
            isPassword: false,
            enabled: viewModel.currentStep == 0 &&
                (viewModel.completeTillStep <= 0 ||
                    viewModel.isBasicDetailsEditable),
            errorText: viewModel.formState.errors['pincode'],
          ),
          const SizedBox(height: 16),

          // Geo Latitude
          CustomFormFields.primaryFormField(
            label: 'Geo Latitude',
            controller: viewModel.latitudeController,
            keyboardType: TextInputType.number,
            isPassword: false,
            enabled: viewModel.currentStep == 0 &&
                (viewModel.completeTillStep <= 0 ||
                    viewModel.isBasicDetailsEditable),
            errorText: viewModel.formState.errors['latitude'],
          ),
          const SizedBox(height: 16),

          // Geo Longitude
          CustomFormFields.primaryFormField(
            label: 'Geo Longitude',
            controller: viewModel.longitudeController,
            keyboardType: TextInputType.number,
            isPassword: false,
            enabled: viewModel.currentStep == 0 &&
                (viewModel.completeTillStep <= 0 ||
                    viewModel.isBasicDetailsEditable),
            errorText: viewModel.formState.errors['longitude'],
          ),
          const SizedBox(height: 16),

          // Plaza Category and Free Parking
          SizedBox(
            width: AppConfig.deviceWidth * 0.9,
            child: Row(
              children: [
                Expanded(
                  child: CustomDropDown.normalDropDown(
                    label: "Plaza Category",
                    value: viewModel.formState.basicDetails['plazaCategory'],
                    items: Plaza.validPlazaCategories,
                    enabled: viewModel.currentStep == 0 &&
                        (viewModel.completeTillStep <= 0 ||
                            viewModel.isBasicDetailsEditable),
                    onChanged: (value) {
                      viewModel.formState.basicDetails['plazaCategory'] = value;
                    },
                    // Disable dropdown if not editable
                    errorText: viewModel
                        .formState.errors['plazaCategory'], // Specific key
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomDropDown.normalDropDown(
                    label: "Plaza Sub-Category",
                    value: viewModel.formState.basicDetails['plazaSubCategory'],
                    items: Plaza.validPlazaSubCategories,
                    enabled: viewModel.currentStep == 0 &&
                        (viewModel.completeTillStep <= 0 ||
                            viewModel.isBasicDetailsEditable),
                    onChanged: (value) {
                      viewModel.formState.basicDetails['plazaSubCategory'] =
                          value;
                    },
                    // Disable dropdown if not editable
                    errorText: viewModel
                        .formState.errors['plazaSubCategory'], // Specific key
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: AppConfig.deviceWidth * 0.9,
            child: Row(
              children: [
                Expanded(
                  child: CustomDropDown.normalDropDown(
                    label: "Plaza Status",
                    value: viewModel.formState.basicDetails['plazaStatus'],
                    items: Plaza.validPlazaStatuses,
                    enabled: viewModel.currentStep == 0 &&
                        (viewModel.completeTillStep <= 0 ||
                            viewModel.isBasicDetailsEditable),
                    onChanged: (value) {
                      viewModel.formState.basicDetails['plazaStatus'] = value;
                    },
                    // Disable dropdown if not editable
                    errorText: viewModel
                        .formState.errors['plazaStatus'], // Specific key
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomDropDown.normalDropDown(
                    label: "Free Parking",
                    value: viewModel.formState.basicDetails['freeParking'] ?? false ? "Yes" : "No",
                    items: ['Yes', 'No'],
                    enabled: viewModel.currentStep == 0 &&
                        (viewModel.completeTillStep <= 0 || viewModel.isBasicDetailsEditable),
                    onChanged: (value) {
                      viewModel.formState.basicDetails['freeParking'] = value == "Yes";
                    },
                    errorText: viewModel.formState.errors['freeParking'],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Structure Type and Price Category
          SizedBox(
            width: AppConfig.deviceWidth * 0.9,
            child: Row(
              children: [
                Expanded(
                  child: CustomDropDown.normalDropDown(
                    label: "Structure Type",
                    value: viewModel.formState.basicDetails['structureType'],
                    items: Plaza.validStructureTypes,
                    enabled: viewModel.currentStep == 0 &&
                        (viewModel.completeTillStep <= 0 ||
                            viewModel.isBasicDetailsEditable),
                    onChanged: (value) {
                      viewModel.formState.basicDetails['structureType'] = value;
                    },
                    errorText: viewModel
                        .formState.errors['structureType'], // Specific key
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomDropDown.normalDropDown(
                    label: "Price Category",
                    value: viewModel.formState.basicDetails['priceCategory'],
                    items: Plaza.validPriceCategories, //ToDo Custom
                    enabled: viewModel.currentStep == 0 &&
                        (viewModel.completeTillStep <= 0 ||
                            viewModel.isBasicDetailsEditable),
                    onChanged: (value) {
                      viewModel.formState.basicDetails['priceCategory'] = value;
                    },
                    errorText: viewModel
                        .formState.errors['priceCategory'], // Specific key
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Total Parking Slots
          CustomFormFields.primaryFormField(
            label: 'Total Parking Slots',
            controller: viewModel.totalParkingSlotsController,
            keyboardType: TextInputType.number,
            isPassword: false,
            enabled: viewModel.currentStep == 0 &&
                (viewModel.completeTillStep <= 0 ||
                    viewModel.isBasicDetailsEditable),
            errorText: viewModel.formState.errors['totalParkingSlots'],
          ),
          const SizedBox(height: 16),

          // Two-Wheeler Capacity
          CustomFormFields.primaryFormField(
            label: 'Two-Wheeler Capacity',
            controller: viewModel.twoWheelerCapacityController,
            keyboardType: TextInputType.number,
            isPassword: false,
            enabled: viewModel.currentStep == 0 &&
                (viewModel.completeTillStep <= 0 ||
                    viewModel.isBasicDetailsEditable),
            errorText: viewModel.formState.errors['twoWheelerCapacity'],
          ),
          const SizedBox(height: 16),

          CustomFormFields.primaryFormField(
            label: 'LMV Capacity',
            controller: viewModel.lmvCapacityController,
            keyboardType: TextInputType.number,
            isPassword: false,
            enabled: viewModel.currentStep == 0 &&
                (viewModel.completeTillStep <= 0 ||
                    viewModel.isBasicDetailsEditable),
            errorText: viewModel.formState.errors['lmvCapacity'], // Correct key
          ),
          const SizedBox(height: 16),
          CustomFormFields.primaryFormField(
            label: 'LCV Capacity',
            controller: viewModel.lcvCapacityController,
            keyboardType: TextInputType.number,
            isPassword: false,
            enabled: viewModel.currentStep == 0 &&
                (viewModel.completeTillStep <= 0 ||
                    viewModel.isBasicDetailsEditable),
            errorText: viewModel.formState.errors['lcvCapacity'],
          ),
          const SizedBox(height: 16),
          CustomFormFields.primaryFormField(
            label: 'HMV Capacity',
            controller: viewModel.hmvCapacityController,
            keyboardType: TextInputType.number,
            isPassword: false,
            enabled: viewModel.currentStep == 0 &&
                (viewModel.completeTillStep <= 0 ||
                    viewModel.isBasicDetailsEditable),
            errorText: viewModel.formState.errors['hmvCapacity'],
          ),
          const SizedBox(height: 16),

          // Timing Fields
          GestureDetector(
            onTap: () async {
              final TimeOfDay? pickedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (pickedTime != null) {
                final formattedTime =
                    '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
                viewModel.openingTimeController.text = formattedTime;
                viewModel.formState.basicDetails['openingTime'] = formattedTime;
              }
            },
            child: AbsorbPointer(
              child: CustomFormFields.primaryFormField(
                label: 'Opening Time',
                controller: viewModel.openingTimeController,
                keyboardType: TextInputType.none,
                isPassword: false,
                enabled: viewModel.currentStep == 0 &&
                    (viewModel.completeTillStep <= 0 ||
                        viewModel.isBasicDetailsEditable),
                errorText: viewModel.formState.errors['openingTime'],
              ),
            ),
          ),
          const SizedBox(height: 16),

          GestureDetector(
            onTap: () async {
              final TimeOfDay? pickedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (pickedTime != null) {
                final formattedTime =
                    '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
                viewModel.closingTimeController.text = formattedTime;
                viewModel.formState.basicDetails['closingTime'] = formattedTime;
              }
            },
            child: AbsorbPointer(
              child: CustomFormFields.primaryFormField(
                label: 'Closing Time',
                controller: viewModel.closingTimeController,
                keyboardType: TextInputType.none,
                isPassword: false,
                enabled: viewModel.currentStep == 0 &&
                    (viewModel.completeTillStep <= 0 ||
                        viewModel.isBasicDetailsEditable),
                errorText: viewModel.formState.errors['closingTime'],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
