// merchant_app/lib/views/ticket/new_ticket_screen.dart
import 'dart:developer'
    as developer; // aliased to avoid conflict if 'log' is used directly
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_theme.dart'; // For context.secondaryCardColor etc.
import 'package:provider/provider.dart';

// App specific imports
import '../../../config/app_colors.dart';
import '../../../utils/components/appbar.dart';
import '../../../utils/components/button.dart';
import '../../../utils/components/dropdown.dart'; // For SearchableDropdown
import '../../../utils/components/form_field.dart'; // For CustomFormFields
import '../../../viewmodels/ticket/new_ticket_viewmodel.dart';
import '../../../generated/l10n.dart'; // For S strings

// Imports for navigation to ViewOpenTicketScreen
import 'package:merchant_app/viewmodels/ticket/open_ticket_viewmodel.dart';

import '../open_ticket/view_open_ticket.dart';

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
    final strings = S.of(context);

    // Show error if no plaza is assigned for Plaza Admin or Plaza Operator
    // This is usually for initial load errors that prevent form usage.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (viewModel.apiError == strings.noPlazaAssigned ||
          viewModel.apiError?.startsWith('Invalid plaza count') == true) {
        _showFailureSnackbar(context, viewModel.apiError!);
        // Optionally, clear the error after showing it if it's a one-time info message
        // viewModel.clearApiError(); // You'd need to implement this in ViewModel
      }
    });

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
                  _buildTopSection(viewModel, context, strings),
                  const SizedBox(height: 8),
                  _buildEnhancedImageSection(viewModel, context, strings),
                  const SizedBox(height: 8),
                  _buildManualTicketSection(viewModel, context, strings),
                ],
              ),
            ),
          ),
          bottomNavigationBar:
              SafeArea(child: _buildSubmitButton(viewModel, context, strings)),
        ),
        if (viewModel.isLoading)
          Container(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withOpacity(0.5)
                : Colors.grey.withOpacity(0.5),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLocationErrorWidget(
      NewTicketViewmodel viewModel, BuildContext context, S strings) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_off,
                color: Theme.of(context).colorScheme.error,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  strings.locationRequired,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            viewModel.locationError!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (viewModel.canRetryLocation) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: viewModel.isLoading
                        ? null
                        : () async {
                            await viewModel.retryLocationFetch();
                          },
                    icon: viewModel.isLoading
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).primaryColor,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.refresh,
                            size: 16,
                            color: Theme.of(context).primaryColor,
                          ),
                    label: Text(
                      strings.buttonRetry,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      side: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
              ],
              if (viewModel.needsLocationSettings) ...[
                if (viewModel.canRetryLocation) const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await viewModel.openLocationSettings();
                      // After user potentially changes settings, auto-retry
                      Future.delayed(const Duration(seconds: 1), () {
                        if (!viewModel.isLocationAvailable) {
                          viewModel.retryLocationFetch();
                        }
                      });
                    },
                    icon: Icon(
                      Icons.settings,
                      size: 16,
                      color: Theme.of(context).primaryColor,
                    ),
                    label: Text(
                      strings.buttonSettings,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      side: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopSection(
      NewTicketViewmodel viewModel, BuildContext context, S strings) {
    final isNonOwner = viewModel.userRole == 'Plaza Admin' ||
        viewModel.userRole == 'Plaza Operator';

    return Card(
      margin: EdgeInsets.zero,
      shape: Theme.of(context).cardTheme.shape ??
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: context.secondaryCardColor, // Assumes AppTheme extension
      elevation: Theme.of(context).cardTheme.elevation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16),
        child: Column(
          children: [
            if (viewModel.locationError != null)
              _buildLocationErrorWidget(viewModel, context, strings),
            SearchableDropdown(
              // Ensure this component is correctly imported and defined
              label: strings.plazaNameLabel,
              value: viewModel.selectedPlazaId,
              items: viewModel.userPlazas,
              onChanged: (plaza) {
                if (!isNonOwner) {
                  viewModel.updatePlazaId(plaza?.plazaId);
                }
              },
              enabled: !isNonOwner,
              errorText: viewModel.plazaIdError,
              itemText: (item) => item.plazaName,
              itemValue: (item) => item.plazaId.toString(),
              height: 50, // Ensure SearchableDropdown supports this
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: SearchableDropdown(
                    label: strings.laneIdLabel,
                    value: viewModel.selectedEntryLaneId,
                    items: viewModel.lanes,
                    onChanged: (lane) => viewModel.updateEntryLaneId(
                        lane?.laneId, lane?.laneDirection),
                    enabled: viewModel.selectedPlazaId != null,
                    errorText: viewModel.entryLaneIdError,
                    itemText: (item) => item.laneName ?? item.laneId.toString(),
                    itemValue: (item) => item.laneId.toString(),
                    height: 50,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: CustomFormFields.normalSizedTextFormField(
                    // Ensure CustomFormFields is correctly imported
                    context: context,
                    height: 50,
                    label: strings.laneDirection,
                    controller: TextEditingController(
                        text: viewModel.selectedLaneDirection ?? ''),
                    enabled: false,
                    isPassword: false,
                    keyboardType: TextInputType.text,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedImageSection(
      NewTicketViewmodel viewModel, BuildContext context, S strings) {
    return Card(
      margin: EdgeInsets.zero,
      shape: Theme.of(context).cardTheme.shape ??
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: context.secondaryCardColor,
      elevation: Theme.of(context).cardTheme.elevation,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    onPressed: () => viewModel.pickImageFromCamera(),
                    child: Text(
                      strings.addMoreLabel,
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Adjust as needed
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.1, // Adjust aspect ratio
                ),
                itemCount: viewModel.selectedImagePaths.length,
                itemBuilder: (context, index) {
                  return _buildImageItem(viewModel, context, index);
                },
              ),
            ] else ...[
              InkWell(
                onTap: () => viewModel.pickImageFromCamera(),
                child: Container(
                  width: double.infinity,
                  height: 180, // Adjust height as needed
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
                        color: context
                            .textPrimaryColor, // Assumes AppTheme extension
                      ),
                      const SizedBox(height: 12),
                      Text(
                        strings.captureImageLabel,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: context.textPrimaryColor,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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

  Widget _buildImageItem(
      NewTicketViewmodel viewModel, BuildContext context, int index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[700]
            : Colors.grey[200],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(
                11), // Slightly less than container for border visibility
            child: Image.file(
              File(viewModel.selectedImagePaths[index]),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                developer.log(
                    'Error loading image file: ${viewModel.selectedImagePaths[index]}',
                    error: error,
                    stackTrace: stackTrace,
                    name: 'NewTicketScreen');
                return Center(
                    child: Icon(Icons.broken_image,
                        color: Theme.of(context).colorScheme.error, size: 32));
              },
            ),
          ),
          Positioned(
            top: 4, // Adjust position
            right: 4, // Adjust position
            child: GestureDetector(
              onTap: () => viewModel.removeImage(index),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  color: Colors.white, // Simpler color for close icon
                  size: 16, // Adjust size
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualTicketSection(
      NewTicketViewmodel viewModel, BuildContext context, S strings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () => viewModel.toggleManualTicketExpanded(),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: context.secondaryCardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.inputBorderDark // Ensure AppColors is imported
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
                        color: context.textPrimaryColor,
                      ),
                ),
                const SizedBox(width: 8),
                Icon(
                  viewModel.isManualTicketExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: context.textPrimaryColor,
                ),
              ],
            ),
          ),
        ),
        if (viewModel.isManualTicketExpanded) ...[
          const SizedBox(height: 16),
          Card(
            margin: EdgeInsets.zero,
            shape: Theme.of(context).cardTheme.shape ??
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: context.secondaryCardColor,
            elevation: Theme.of(context).cardTheme.elevation,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomFormFields.normalSizedTextFormField(
                    context: context,
                    label: strings.vehicleNumberLabel,
                    controller: viewModel.vehicleNumberController,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.characters,
                    isPassword: false,
                    enabled: true,
                    errorText: viewModel.vehicleNumberError,
                  ),
                  const SizedBox(height: 16),
                  CustomDropDown.normalDropDown(
                    // Ensure CustomDropDown is correctly imported
                    label: strings.vehicleTypeLabel,
                    value: viewModel.selectedVehicleType,
                    items: viewModel.vehicleTypes,
                    onChanged: (type) => viewModel.updateVehicleType(type),
                    icon: Icons.directions_car, // Example icon
                    enabled: true,
                    errorText: viewModel.vehicleTypeError,
                    context: context, // CustomDropDown might need context
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSubmitButton(
      NewTicketViewmodel viewModel, BuildContext context, S strings) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16), // Adjusted padding
      child: CustomButtons.primaryButton(
        // Ensure CustomButtons is correctly imported
        text: viewModel.isLoading
            ? strings.creatingLabel
            : strings.createTicketLabel,
        onPressed: viewModel.isLoading
            ? () {} // Disable button while loading
            : () async {
                final String? ticketRefId = await viewModel.createTicket();
                if (!context.mounted) return;

                if (ticketRefId != null &&
                    viewModel.createdTicketUuid != null) {
                  // Both IDs are available, proceed to success dialog
                  _showSuccessDialog(context, strings, ticketRefId);
                } else if (viewModel.apiError?.contains('ANPR Failed') ==
                    true) {
                  _showAnprManualDialog(context, strings, viewModel.apiError!);
                } else {
                  // Handle other errors (e.g., network, validation, general API error, or missing UUID)
                  _showFailureSnackbar(context,
                      viewModel.apiError ?? strings.failedToCreateTicket);
                }
              },
        height: 50,
        context: context, // CustomButtons might need context
      ),
    );
  }

  void _showAnprManualDialog(
      BuildContext parentContext, S strings, String apiError) {
    final serverMessage = apiError.replaceFirst(
        'ANPR Failed: AnprFailureException: ANPR processing failed: ', '');
    showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          backgroundColor: Theme.of(dialogContext).dialogBackgroundColor,
          content: Text(strings.anprFailedMessage),
          actions: [
            TextButton(
              child: Text(strings.okLabel,
                  style: TextStyle(
                      color: Theme.of(dialogContext).primaryColor,
                      fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // Access ViewModel via Provider to call method
                Provider.of<NewTicketViewmodel>(parentContext, listen: false)
                    .toggleManualTicketExpanded(forceExpand: true);
              },
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(
      BuildContext parentContext, S strings, String ticketRefId) {
    String ticketIdLabelText;
    try {
      ticketIdLabelText = strings.ticketIdLabel;
    } catch (e) {
      ticketIdLabelText = 'Ticket ID'; // Fallback
      developer.log(
          'Warning: strings.ticketIdLabel not found. Using fallback "Ticket ID".',
          name: 'NewTicketScreen');
    }

    showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          backgroundColor: Theme.of(dialogContext).dialogBackgroundColor,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.5, end: 1.0),
                duration: const Duration(milliseconds: 500),
                curve: Curves.elasticOut,
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: child,
                  );
                },
                child: const Icon(
                  // Made const
                  Icons.check_circle,
                  color: Colors.green,
                  size: 60,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                strings.ticketSuccessMessage,
                textAlign: TextAlign.center,
                style: Theme.of(dialogContext)
                    .textTheme
                    .titleLarge // Bolder and larger
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                "$ticketIdLabelText: $ticketRefId", // Displaying ticketRefId (human-readable)
                textAlign: TextAlign.center,
                style: Theme.of(dialogContext).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(dialogContext)
                          .textTheme
                          .bodySmall
                          ?.color, // Subtler color
                    ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text(
                strings.okLabel,
                style: TextStyle(
                  color: Theme.of(dialogContext).primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog

                if (parentContext.mounted) {
                  // Pop the NewTicketScreen
                  Navigator.of(parentContext).pop();

                  final viewModel = Provider.of<NewTicketViewmodel>(
                      parentContext,
                      listen: false);
                  final String? createdTicketUuid =
                      viewModel.createdTicketUuid; // The actual UUID

                  if (createdTicketUuid != null) {
                    Navigator.push(
                      parentContext,
                      MaterialPageRoute(
                        builder: (context) => ChangeNotifierProvider(
                          create: (_) =>
                              OpenTicketViewModel(), // ViewModel for ViewOpenTicketScreen
                          child: ViewOpenTicketScreen(
                            ticketId:
                                createdTicketUuid, // Use the actual UUID ticket ID
                            isEditable:
                                true, // Newly created ticket is likely editable by creator
                          ),
                        ),
                      ),
                    );
                  } else {
                    developer.log(
                        "Error: Actual Ticket ID (UUID) is null. Cannot navigate to ViewOpenTicketScreen.",
                        name: "NewTicketScreen");
                    // Show a fallback snackbar if navigation fails due to missing ID
                    ScaffoldMessenger.of(parentContext).showSnackBar(
                      SnackBar(
                        content: Text(strings.errorNavigatingToTicketDetails,
                            style: TextStyle(
                                color: Theme.of(parentContext)
                                    .colorScheme
                                    .onError)),
                        backgroundColor:
                            Theme.of(parentContext).colorScheme.error,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showFailureSnackbar(BuildContext context, String errorMessage) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage,
            style: TextStyle(color: Theme.of(context).colorScheme.onError)),
        duration: const Duration(seconds: 3),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
      ),
    );
  }
}
