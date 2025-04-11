import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_theme.dart';
import 'package:provider/provider.dart';
import '../../../config/app_colors.dart';
import '../../../utils/components/appbar.dart';
import '../../../utils/components/button.dart';
import '../../../utils/components/dropdown.dart';
import '../../../utils/components/form_field.dart';
import '../../../viewmodels/ticket/new_ticket_viewmodel.dart';
import '../../../generated/l10n.dart';

class NewTicketScreen extends StatelessWidget {
  const NewTicketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Provides the ViewModel to the widget tree below it
    return ChangeNotifierProvider(
      create: (_) => NewTicketViewmodel(), // Creates the ViewModel instance
      child: const NewTicketView(), // The actual view that uses the ViewModel
    );
  }
}

class NewTicketView extends StatelessWidget {
  const NewTicketView({super.key});

  @override
  Widget build(BuildContext context) {
    // Listens for changes in the ViewModel
    final viewModel = context.watch<NewTicketViewmodel>();
    // Accesses localized strings
    final strings = S.of(context);

    // Log errors if any occur in the ViewModel
    if (viewModel.apiError != null && viewModel.apiError != 'ANPR Failed') {
      log('Error in NewTicketView: ${viewModel.apiError}');
    }

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: CustomAppBar.appBarWithNavigation(
            screenTitle: strings.newTicketTitle,
            onPressed: () => Navigator.pop(context),
            darkBackground: Theme.of(context).brightness == Brightness.dark,
            context: context,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Section for selecting Plaza and Lane
                  _buildTopSection(viewModel, context, strings),
                  const SizedBox(height: 8),
                  // Section for capturing/displaying images
                  _buildEnhancedImageSection(viewModel, context, strings),
                  const SizedBox(height: 8),
                  // Section for manual ticket entry (expandable)
                  _buildManualTicketSection(viewModel, context, strings),
                ],
              ),
            ),
          ),
          // Submit button at the bottom
          bottomNavigationBar: _buildSubmitButton(viewModel, context, strings),
        ),
        // Loading indicator overlay
        if (viewModel.isLoading)
          Container(
            // Semi-transparent background based on theme
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withOpacity(0.5)
                : Colors.grey.withOpacity(0.5),
            child: Center(
              child: CircularProgressIndicator(
                // Indicator color matches primary theme color
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Builds the Plaza and Lane selection dropdowns
  Widget _buildTopSection(NewTicketViewmodel viewModel, BuildContext context, S strings) {
    return Card(
      margin: EdgeInsets.zero,
      shape: Theme.of(context).cardTheme.shape ?? RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: context.secondaryCardColor,
      elevation: Theme.of(context).cardTheme.elevation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16),
        child: Column(
          children: [
            SearchableDropdown(
              label: strings.plazaNameLabel,
              value: viewModel.selectedPlazaId, // Already String?
              items: viewModel.userPlazas,
              onChanged: (plaza) => viewModel.updatePlazaId(plaza?.plazaId), // Pass raw plazaId
              enabled: true,
              errorText: viewModel.plazaIdError,
              itemText: (item) => item.plazaName,
              itemValue: (item) => item.plazaId.toString(), // Convert to String
              height: 50,
            ),
            const SizedBox(height: 16),
            SearchableDropdown(
              label: strings.laneIdLabel,
              value: viewModel.selectedEntryLaneId, // Already String?
              items: viewModel.lanes,
              onChanged: (lane) => viewModel.updateEntryLaneId(lane?.laneId), // Pass raw laneId
              enabled: viewModel.selectedPlazaId != null,
              errorText: viewModel.entryLaneIdError,
              itemText: (item) => item.laneName ?? item.laneId.toString(), // Convert to String for display
              itemValue: (item) => item.laneId.toString(), // Convert to String
              height: 50,
            ),
          ],
        ),
      ),
    );
  }

  // Builds the image capture/display section
  Widget _buildEnhancedImageSection(NewTicketViewmodel viewModel, BuildContext context, S strings) {
    return Card(
      margin: EdgeInsets.zero,
      shape: Theme.of(context).cardTheme.shape ?? RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: context.secondaryCardColor, // Adapts to theme
      elevation: Theme.of(context).cardTheme.elevation,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // If images are selected, show the grid and "Add More" button
            if (viewModel.selectedImagePaths.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    strings.capturedImagesLabel,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextButton(
                    onPressed: () => viewModel.pickImageFromCamera(), // Directly open camera
                    child: Text(
                      strings.addMoreLabel,
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Grid view to display captured images
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(), // Disable grid scrolling
                shrinkWrap: true, // Fit content height
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Two images per row
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.1, // Adjust aspect ratio as needed
                ),
                itemCount: viewModel.selectedImagePaths.length,
                itemBuilder: (context, index) {
                  // Build individual image item with remove button
                  return _buildImageItem(viewModel, context, index);
                },
              ),
            ]
            // If no images are selected, show the "Capture Image" placeholder
            else ...[
              InkWell(
                onTap: () => viewModel.pickImageFromCamera(), // Directly open camera
                child: Container(
                  width: double.infinity,
                  height: 180, // Placeholder height
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[800]
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt_outlined,
                        size: 48,
                        color: context.textPrimaryColor, // Adapts to theme
                      ),
                      const SizedBox(height: 12),
                      Text(
                        strings.captureImageLabel,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: context.textPrimaryColor, // Adapts to theme
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            // Show error message if image capture failed
            if (viewModel.imageCaptureError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  viewModel.imageCaptureError!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Builds a single image item with a remove button overlay
  Widget _buildImageItem(NewTicketViewmodel viewModel, BuildContext context, int index) {
    return Container(
      height: 120,
      width: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[700] : Colors.grey[200],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Display the image file
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(viewModel.selectedImagePaths[index]), // Load image from file path
              fit: BoxFit.cover, // Cover the container space
            ),
          ),
          // Close button overlay
          Positioned(
            top: 5,
            right: 5,
            child: GestureDetector(
              onTap: () => viewModel.removeImage(index), // Call remove function on tap
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6), // Semi-transparent background
                  shape: BoxShape.circle, // Circular shape
                ),
                child: Icon(
                  Icons.close,
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.grey[200],
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Builds the expandable manual ticket entry section
  Widget _buildManualTicketSection(NewTicketViewmodel viewModel, BuildContext context, S strings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Clickable header to toggle expansion
        InkWell(
          onTap: () => viewModel.toggleManualTicketExpanded(), // Toggle expansion state
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: context.secondaryCardColor, // Adapts to theme
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.inputBorderDark // Use theme-specific border color
                    : AppColors.inputBorderLight,
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  strings.manualTicketLabel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.textPrimaryColor, // Adapts to theme
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  // Show up/down arrow based on expansion state
                  viewModel.isManualTicketExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: context.textPrimaryColor, // Adapts to theme
                ),
              ],
            ),
          ),
        ),
        // Show the form fields only if the section is expanded
        if (viewModel.isManualTicketExpanded) ...[
          const SizedBox(height: 16), // Spacing when expanded
          Card(
            margin: EdgeInsets.zero,
            shape: Theme.of(context).cardTheme.shape ?? RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: context.secondaryCardColor, // Adapts to theme
            elevation: Theme.of(context).cardTheme.elevation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vehicle Number input field
                  CustomFormFields.normalSizedTextFormField(
                    context: context,
                    label: strings.vehicleNumberLabel,
                    controller: viewModel.vehicleNumberController,
                    keyboardType: TextInputType.visiblePassword, // Consider changing if not password-like
                    isPassword: false, // Set to false
                    enabled: true,
                    errorText: viewModel.vehicleNumberError,
                  ),
                  const SizedBox(height: 16),
                  // Vehicle Type dropdown
                  CustomDropDown.normalDropDown(
                    label: strings.vehicleTypeLabel,
                    value: viewModel.selectedVehicleType,
                    items: viewModel.vehicleTypes, // List of available types
                    onChanged: (type) => viewModel.updateVehicleType(type),
                    icon: Icons.directions_car,
                    enabled: true,
                    errorText: viewModel.vehicleTypeError,
                    context: context,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  // Builds the bottom navigation bar containing the submit button
  Widget _buildSubmitButton(NewTicketViewmodel viewModel, BuildContext context, S strings) {
    return Padding(
      padding: const EdgeInsets.all(8.0), // Padding around the button
      child: CustomButtons.primaryButton(
        text: viewModel.isLoading ? strings.creatingLabel : strings.createTicketLabel, // Change text during loading
        onPressed: viewModel.isLoading
            ? () {} // Disable button while loading
            : () async {
          // Attempt to create the ticket when pressed
          final result = await viewModel.createTicket();
          // Check if the widget is still mounted before interacting with context
          if (!context.mounted) return;

          if (result) {
            // Show success dialog if ticket creation is successful
            _showSuccessDialog(context, strings);
          } else if (viewModel.apiError == 'ANPR Failed') {
            // Show specific dialog if ANPR failed, prompting manual entry
            _showAnprManualDialog(context, strings);
          } else {
            // Show generic failure snackbar for other errors
            _showFailureSnackbar(context, viewModel.apiError ?? strings.failedToCreateTicket);
          }
        },
        height: 50,
        context: context,
      ),
    );
  }

  // Shows a dialog indicating ANPR failure and suggests manual entry
  void _showAnprManualDialog(BuildContext parentContext, S strings) {
    showDialog(
      context: parentContext, // Use the context from the parent widget (NewTicketView)
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext dialogContext) { // Context specific to the dialog
        return AlertDialog(
          backgroundColor: Theme.of(dialogContext).dialogBackgroundColor,
          content: Text(strings.anprFailedMessage), // e.g., "Failed to recognise vehicle details. Please enter them manually."
          actions: [
            TextButton(
              child: Text(strings.okLabel, style: TextStyle(color: Theme.of(dialogContext).primaryColor)),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
                // Access the ViewModel using the parentContext and ensure manual section is expanded
                Provider.of<NewTicketViewmodel>(parentContext, listen: false)
                    .toggleManualTicketExpanded(forceExpand: true); // Assumes method accepts forceExpand
              },
            ),
          ],
        );
      },
    );
  }

  // Shows a success dialog after the ticket is created successfully
  void _showSuccessDialog(BuildContext parentContext, S strings) {
    showDialog(
      context: parentContext, // Use the context from the parent widget (NewTicketView)
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext dialogContext) { // Context specific to the dialog
        return AlertDialog(
          backgroundColor: Theme.of(dialogContext).dialogBackgroundColor,
          content: Text(
            strings.ticketSuccessMessage, // e.g., "Ticket created successfully!"
            style: Theme.of(dialogContext).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          actions: [
            TextButton(
              child: Text(strings.okLabel, style: TextStyle(color: Theme.of(dialogContext).primaryColor)),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog first
                // Check if parent context is still mounted before popping the screen
                if (parentContext.mounted) {
                  Navigator.of(parentContext).pop(); // Go back from NewTicketScreen
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Shows a floating SnackBar for displaying failure messages
  void _showFailureSnackbar(BuildContext context, String errorMessage) {
    // Ensure the context is still valid before showing the SnackBar
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage, style: TextStyle(color: Theme.of(context).colorScheme.onError)),
        duration: const Duration(seconds: 3),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating, // Make it float above the bottom nav bar
      ),
    );
  }
}
