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
          bottomNavigationBar: _buildSubmitButton(viewModel, context, strings),
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

  Widget _buildTopSection(
      NewTicketViewmodel viewModel, BuildContext context, S strings) {
    return Card(
      margin: EdgeInsets.zero,
      shape: Theme.of(context).cardTheme.shape ??
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: context.secondaryCardColor,
      elevation: Theme.of(context).cardTheme.elevation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16),
        child: Column(
          children: [
            if (viewModel.locationError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  viewModel.locationError!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            SearchableDropdown(
              label: strings.plazaNameLabel,
              value: viewModel.selectedPlazaId,
              items: viewModel.userPlazas,
              onChanged: (plaza) => viewModel.updatePlazaId(plaza?.plazaId),
              enabled: true,
              errorText: viewModel.plazaIdError,
              itemText: (item) => item.plazaName,
              itemValue: (item) => item.plazaId.toString(),
              height: 50,
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
                    onChanged: (lane) => viewModel.updateEntryLaneId(lane?.laneId, lane?.laneDirection),
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
                    context: context,
                    height: 50,
                    label: strings.laneDirection,
                    controller: TextEditingController(text: viewModel.selectedLaneDirection),
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
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.1,
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
                  height: 180,
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
                        color: context.textPrimaryColor,
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
      height: 120,
      width: 120,
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
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(viewModel.selectedImagePaths[index]),
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 5,
            right: 5,
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
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.grey[200],
                  size: 16,
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
                    ? AppColors.inputBorderDark
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
                    keyboardType: TextInputType.visiblePassword,
                    isPassword: false,
                    enabled: true,
                    errorText: viewModel.vehicleNumberError,
                  ),
                  const SizedBox(height: 16),
                  CustomDropDown.normalDropDown(
                    label: strings.vehicleTypeLabel,
                    value: viewModel.selectedVehicleType,
                    items: viewModel.vehicleTypes,
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

  Widget _buildSubmitButton(
      NewTicketViewmodel viewModel, BuildContext context, S strings) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CustomButtons.primaryButton(
        text: viewModel.isLoading
            ? strings.creatingLabel
            : strings.createTicketLabel,
        onPressed: viewModel.isLoading
            ? () {}
            : () async {
          final result = await viewModel.createTicket();
          if (!context.mounted) return;

          if (result) {
            _showSuccessDialog(context, strings);
          } else if (viewModel.apiError?.contains('ANPR Failed') ==
              true) {
            _showAnprManualDialog(context, strings, viewModel.apiError!);
          } else {
            _showFailureSnackbar(context,
                viewModel.apiError ?? strings.failedToCreateTicket);
          }
        },
        height: 50,
        context: context,
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
          backgroundColor: Theme.of(dialogContext).dialogBackgroundColor,
          content: Text(serverMessage.isNotEmpty
              ? serverMessage
              : strings.anprFailedMessage),
          actions: [
            TextButton(
              child: Text(strings.okLabel,
                  style:
                  TextStyle(color: Theme.of(dialogContext).primaryColor)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Provider.of<NewTicketViewmodel>(parentContext, listen: false)
                    .toggleManualTicketExpanded(forceExpand: true);
              },
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(BuildContext parentContext, S strings) {
    showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Theme.of(dialogContext).dialogBackgroundColor,
          content: Text(
            strings.ticketSuccessMessage,
            style: Theme.of(dialogContext)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          actions: [
            TextButton(
              child: Text(strings.okLabel,
                  style:
                  TextStyle(color: Theme.of(dialogContext).primaryColor)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                if (parentContext.mounted) {
                  Navigator.of(parentContext).pop();
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
      ),
    );
  }
}