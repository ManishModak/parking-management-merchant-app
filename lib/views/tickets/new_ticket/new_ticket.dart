import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/components/appbar.dart';
import '../../../utils/components/button.dart';
import '../../../utils/components/dropdown.dart';
import '../../../utils/components/form_field.dart';
import '../../../viewmodels/ticket/new_ticket_viewmodel.dart';

class NewTicketScreen extends StatelessWidget {
  const NewTicketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NewTicketViewmodel(),
      child: const NewTicketView(),
    );
  }
}

class NewTicketView extends StatelessWidget {
  const NewTicketView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<NewTicketViewmodel>();

    if (viewModel.apiError != null) {
      log('Error in NewTicketView: ${viewModel.apiError}');
    }

    return Scaffold(
      appBar: CustomAppBar.appBarWithNavigation(
        screenTitle: 'New Ticket',
        onPressed: () => Navigator.pop(context),
        darkBackground: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildImageSection(viewModel, context),
              const SizedBox(height: 24),
              _buildVehicleDetailsCard(viewModel),
              const SizedBox(height: 16),
              _buildParkingDetailsCard(context, viewModel),
              const SizedBox(height: 24),
              _buildApiError(viewModel),
              _buildSubmitButton(viewModel, context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(NewTicketViewmodel viewModel, BuildContext context) {
    if (viewModel.selectedImagePaths.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Vehicle Images',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              TextButton(
                onPressed: () => viewModel.showImageSourceDialog(context),
                child: const Text('Add More'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: viewModel.selectedImagePaths.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width / 3 - 16,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!, width: 1),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(viewModel.selectedImagePaths[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => viewModel.removeImage(index),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (viewModel.imageCaptureError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                viewModel.imageCaptureError!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () => viewModel.showImageSourceDialog(context),
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!, width: 1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.camera_alt,
                  size: 36,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 8),
                Text(
                  'Capture Vehicle Image',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (viewModel.imageCaptureError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              viewModel.imageCaptureError!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildVehicleDetailsCard(NewTicketViewmodel viewModel) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vehicle Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            CustomFormFields.primaryFormField(
              label: 'Vehicle Number',
              controller: viewModel.vehicleNumberController,
              keyboardType: TextInputType.visiblePassword,
              isPassword: false,
              enabled: true,
              errorText: viewModel.vehicleNumberError,
            ),
            const SizedBox(height: 16),
            CustomDropDown.normalDropDown(
              label: 'Vehicle Type',
              value: viewModel.selectedVehicleType,
              items: viewModel.vehicleTypes,
              onChanged: viewModel.updateVehicleType,
              icon: Icons.directions_car,
              enabled: true,
              errorText: viewModel.vehicleTypeError,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParkingDetailsCard(BuildContext context, NewTicketViewmodel viewModel) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Parking Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            CustomFormFields.primaryFormField(
              label: 'Floor ID',
              controller: viewModel.floorIdController,
              keyboardType: TextInputType.visiblePassword,
              isPassword: false,
              enabled: true,
              errorText: viewModel.floorIdError,
            ),
            const SizedBox(height: 16),
            CustomFormFields.primaryFormField(
              label: 'Slot ID',
              controller: viewModel.slotIdController,
              keyboardType: TextInputType.visiblePassword,
              isPassword: false,
              enabled: true,
              errorText: viewModel.slotIdError,
            ),
            const SizedBox(height: 16),
            CustomFormFields.primaryFormField(
              label: 'Plaza ID',
              keyboardType: TextInputType.visiblePassword,
              controller: viewModel.plazaIdController,
              isPassword: false,
              enabled: true,
              errorText: viewModel.plazaIdError,
            ),
            const SizedBox(height: 16),
            CustomFormFields.primaryFormField(
              label: 'Entry Lane ID',
              controller: viewModel.entryLaneIdController,
              keyboardType: TextInputType.visiblePassword,
              isPassword: false,
              enabled: true,
              errorText: viewModel.entryLaneIdError,
            ),
            const SizedBox(height: 16),
            CustomDropDown.normalDropDown(
              label: 'Lane Direction',
              value: viewModel.selectedDirection,
              items: viewModel.laneDirections,
              onChanged: viewModel.updateDirection,
              enabled: true,
              errorText: viewModel.laneDirectionError, // Fixed to use correct error field
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApiError(NewTicketViewmodel viewModel) {
    if (viewModel.apiError == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0), // Fixed typo from 'custom' to 'bottom'
      child: Text(
        viewModel.apiError!,
        style: const TextStyle(color: Colors.red, fontSize: 14),
      ),
    );
  }

  Widget _buildSubmitButton(NewTicketViewmodel viewModel, BuildContext context) {
    return CustomButtons.primaryButton(
      text: viewModel.isLoading ? 'Creating...' : 'Create Ticket',
      onPressed: viewModel.isLoading
          ? () {}
          : () async {
        if (await viewModel.createTicket()) {
          _showSuccessDialog(context);
        } else {
          _showFailureSnackbar(context, viewModel.apiError ?? 'Failed to create ticket');
        }
      },
      height: 50,
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('Ticket created successfully!'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showFailureSnackbar(BuildContext context, String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
      ),
    );
  }
}