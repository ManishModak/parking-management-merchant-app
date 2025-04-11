import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:merchant_app/generated/l10n.dart';
import '../../../utils/components/appbar.dart';
import '../../../utils/components/form_field.dart';
import '../../../utils/exceptions.dart';
import '../../../viewmodels/plaza/plaza_modification_viewmodel.dart';
import 'dart:developer' as developer;
import 'package:merchant_app/config/app_theme.dart';
// Import loading screen if you want to use it while fetching basic details
import '../../../utils/screens/loading_screen.dart';

class BankDetailsModificationScreen extends StatefulWidget {
  const BankDetailsModificationScreen({super.key});

  @override
  State<BankDetailsModificationScreen> createState() => _BankDetailsModificationScreenState();
}

class _BankDetailsModificationScreenState extends State<BankDetailsModificationScreen> {
  late String _plazaId;
  bool _isInitialized = false;
  // Optional: Track if the initial load is happening
  bool _isInitialLoading = false;

  @override
  void initState() {
    super.initState();
    developer.log('[BankDetailsModScreen] Initializing State.', name: 'PlazaModify');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      developer.log('[BankDetailsModScreen] First didChangeDependencies.', name: 'PlazaModify');
      final args = ModalRoute.of(context)?.settings.arguments;
      final potentialPlazaId = args?.toString();
      developer.log('[BankDetailsModScreen] Received args: $args, potentialPlazaId: $potentialPlazaId', name: 'PlazaModify');

      final strings = S.of(context);

      if (potentialPlazaId == null || potentialPlazaId.isEmpty) {
        developer.log('[BankDetailsModScreen] Invalid Plaza ID received. Popping back.', name: 'PlazaModify', level: 1000);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(strings.invalidPlazaId)),
            );
            // Resetting state might be handled by the ViewModel itself if error occurs during fetch
            // context.read<PlazaModificationViewModel>().resetState();
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          }
        });
      } else {
        _plazaId = potentialPlazaId;
        developer.log('[BankDetailsModScreen] Plaza ID set: $_plazaId. Scheduling fetch...', name: 'PlazaModify');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            // *** START CHANGE ***
            _fetchRequiredDetails();
            // *** END CHANGE ***
          }
        });
      }
      _isInitialized = true;
    }
  }

  // *** NEW METHOD ***
  Future<void> _fetchRequiredDetails() async {
    if (!mounted) return;
    developer.log('[BankDetailsModScreen] Fetching required details (basic & bank)...', name: 'PlazaModify');
    setState(() { _isInitialLoading = true; }); // Show loading indicator

    final viewModel = context.read<PlazaModificationViewModel>();
    try {
      // Fetch basic details first for the header card
      await viewModel.fetchBasicPlazaDetails(_plazaId);
      // Then fetch bank details
      // Check mounted again in case the first fetch took time and user navigated back
      if (mounted) {
        await viewModel.fetchBankPlazaDetails(_plazaId);
      }
      developer.log('[BankDetailsModScreen] Successfully fetched required details.', name: 'PlazaModify');
    } catch (e) {
      developer.log('[BankDetailsModScreen] Error during initial fetch: $e', name: 'PlazaModify', error: e);
      // Error state is handled by the ViewModel, UI will show error banner via Consumer
    } finally {
      if (mounted) {
        setState(() { _isInitialLoading = false; }); // Hide loading indicator
      }
    }
  }
  // *** END NEW METHOD ***


  @override
  void dispose() {
    developer.log('[BankDetailsModScreen] Disposing State.', name: 'PlazaModify');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use Consumer instead of watch if you only need specific rebuilds
    final viewModel = context.watch<PlazaModificationViewModel>();
    final strings = S.of(context);

    developer.log('[BankDetailsModScreen] Building UI. isInitialLoading: $_isInitialLoading, VMisLoading: ${viewModel.isLoading}, error: ${viewModel.error != null}, isEditable: ${viewModel.isBankEditable}', name: 'PlazaModify');

    return Scaffold(
      appBar: CustomAppBar.appBarWithNavigation(
        screenTitle: strings.bankDetails,
        onPressed: () {
          developer.log('[BankDetailsModScreen] AppBar back pressed. isEditable: ${viewModel.isBankEditable}', name: 'PlazaModify');
          viewModel.formState.errors.clear();
          if (viewModel.isBankEditable) {
            viewModel.cancelBankDetailsEdit();
          }
          Navigator.pop(context);
        },
        darkBackground: Theme.of(context).brightness == Brightness.dark,
        context: context,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // Show loading screen during the initial combined fetch
      body: _isInitialLoading
          ? const LoadingScreen() // Use your loading screen
          : _buildContent(viewModel, strings),
      floatingActionButton: _isInitialized && !_isInitialLoading // Hide FAB during initial load
          ? _buildFloatingActionButtons(viewModel, strings)
          : null,
    );
  }

  Widget _buildContent(PlazaModificationViewModel viewModel, S strings) {
    developer.log('[BankDetailsModScreen] Building content.', name: 'PlazaModify');
    // Check if basic details are available before building the header
    final hasBasicDetails = viewModel.formState.basicDetails.isNotEmpty;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Conditionally display header card
            if (hasBasicDetails)
              Card(
                elevation: Theme.of(context).cardTheme.elevation ?? 2,
                color: Theme.of(context).cardColor,
                shape: Theme.of(context).cardTheme.shape,
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_city,
                        color: Theme.of(context).iconTheme.color?.withOpacity(0.7),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              viewModel.formState.basicDetails['plazaName'] ?? strings.loadingEllipsis, // Show loading if name not ready
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: context.textPrimaryColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "${strings.id}: ${viewModel.plazaId ?? strings.notApplicable}",
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: context.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (viewModel.isLoading && !viewModel.isBankEditable) // Show placeholder if loading basic details
              const SizedBox(height: 60, child: Center(child: Text("Loading Plaza Info..."))) // Placeholder
            else // If no basic details and not loading, maybe show minimal header or nothing
              const SizedBox.shrink(), // Or a minimal placeholder


            // Show error banner if there's an error from ViewModel
            if (viewModel.error != null) ...[
              const SizedBox(height: 16),
              _buildErrorBanner(viewModel.error!, strings),
            ],
            const SizedBox(height: 24),
            // --- Bank Detail Form Fields ---
            CustomFormFields.normalSizedTextFormField(
              context: context,
              label: strings.bankName,
              controller: viewModel.bankNameController,
              keyboardType: TextInputType.text,
              enabled: viewModel.isBankEditable,
              errorText: viewModel.formState.errors['bankName'],
            ),
            const SizedBox(height: 16),
            CustomFormFields.normalSizedTextFormField(
              context: context,
              label: strings.accountNumber,
              controller: viewModel.accountNumberController,
              keyboardType: TextInputType.number,
              enabled: viewModel.isBankEditable,
              errorText: viewModel.formState.errors['accountNumber'],
            ),
            const SizedBox(height: 16),
            CustomFormFields.normalSizedTextFormField(
              context: context,
              label: strings.accountHolderName,
              controller: viewModel.accountHolderController,
              keyboardType: TextInputType.name,
              enabled: viewModel.isBankEditable,
              errorText: viewModel.formState.errors['accountHolderName'],
            ),
            const SizedBox(height: 16),
            CustomFormFields.normalSizedTextFormField(
              context: context,
              label: strings.ifscCode,
              controller: viewModel.ifscCodeController,
              keyboardType: TextInputType.visiblePassword,
              textCapitalization: TextCapitalization.characters,
              maxLength: 11,
              height: 75,
              enabled: viewModel.isBankEditable,
              errorText: viewModel.formState.errors['IFSCcode'],
            ),
            const SizedBox(height: 80), // Space for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner(Exception error, S strings) {
    String errorMessage = strings.errorMessageDefault;
    String errorType = "Error"; // Default error type

    if (error is HttpException) {
      errorType = strings.errorTitleWithCode(error.statusCode ?? 0);
      errorMessage = error.message;
      if(error.serverMessage != null && error.serverMessage!.isNotEmpty){
        errorMessage += "\nServer: ${error.serverMessage}";
      }
    } else if (error is ServiceException) {
      errorType = strings.errorTitleService;
      errorMessage = error.message;
      if(error.serverMessage != null && error.serverMessage!.isNotEmpty){
        errorMessage += "\nDetails: ${error.serverMessage}";
      }
    } else {
      errorType = strings.errorLoadingData; // More specific title
      errorMessage = strings.errorMessagePleaseTryAgain;
    }

    developer.log('[BankDetailsModScreen] Building error banner: Type="$errorType", Msg="$errorMessage"', name: 'PlazaModify');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.8),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).colorScheme.error, width: 0.5)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Theme.of(context).colorScheme.error, size: 18),
              const SizedBox(width: 8),
              Text(errorType, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.onErrorContainer, fontWeight: FontWeight.bold)),
              const Spacer(),
              // *** START CHANGE ***
              TextButton(
                style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(50, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    alignment: Alignment.centerRight
                ),
                onPressed: () {
                  developer.log('[BankDetailsModScreen] Retry button in error banner tapped.', name: 'PlazaModify');
                  // Re-fetch both required details on retry
                  _fetchRequiredDetails();
                },
                child: Text(
                    strings.retry,
                    style: TextStyle(color: Theme.of(context).colorScheme.error)
                ),
              ),
              // *** END CHANGE ***
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 26.0), // Indent message under icon
            child: Text(
              errorMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onErrorContainer.withOpacity(0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildFloatingActionButtons(PlazaModificationViewModel viewModel, S strings) {
    // Check if bank details exist (indicating successful fetch or add)
    // Use a simple check like account number controller having text,
    // or check the formState map if populated reliably.
    bool bankDetailsExist = viewModel.accountNumberController.text.isNotEmpty ||
        (viewModel.formState.bankDetails['accountNumber'] != null &&
            viewModel.formState.bankDetails['accountNumber'].isNotEmpty);

    developer.log('[BankDetailsModScreen] Building FABs. isEditable: ${viewModel.isBankEditable}, bankDetailsExist: $bankDetailsExist', name: 'PlazaModify');


    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (viewModel.isBankEditable) ...[
          FloatingActionButton.extended(
            onPressed: () {
              developer.log('[BankDetailsModScreen] Cancel FAB pressed.', name: 'PlazaModify');
              viewModel.cancelBankDetailsEdit();
            },
            heroTag: "cancel_bank_details",
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
            foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
            icon: const Icon(Icons.cancel),
            label: Text(strings.cancel),
          ),
          const SizedBox(width: 16),
        ],
        FloatingActionButton.extended(
          onPressed: () async {
            if (viewModel.isBankEditable) {
              developer.log('[BankDetailsModScreen] Save FAB pressed. Validating...', name: 'PlazaModify');
              FocusScope.of(context).unfocus();
              if (!viewModel.formState.validateBankDetails(context)) {
                developer.log('[BankDetailsModScreen] Validation failed.', name: 'PlazaModify', level: 900);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(strings.correctBankDetailsErrors),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
                return;
              }
              developer.log('[BankDetailsModScreen] Validation passed. Attempting save (modify: $bankDetailsExist)...', name: 'PlazaModify');
              try {
                // Pass whether it's an update (modify=true) or add (modify=false)
                // Modify should be true if bankDetailsExist
                await viewModel.saveBankDetails(context, modify: bankDetailsExist);
                developer.log('[BankDetailsModScreen] Save successful (ViewModel likely showed dialog).', name: 'PlazaModify');
              } catch (e) {
                developer.log('[BankDetailsModScreen] Save failed: $e', name: 'PlazaModify', error: e, level: 1000);
                final String operation = bankDetailsExist ? strings.updateOperation : strings.addOperation;
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(strings.bankDetailsFailed(operation))),
                  );
                }
              }
            } else {
              developer.log('[BankDetailsModScreen] Edit/Add FAB pressed.', name: 'PlazaModify');
              viewModel.toggleBankEditable();
            }
          },
          heroTag: "save_or_edit_bank_details",
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          // Adjust icon and text based on whether details exist and are editable
          icon: Icon(viewModel.isBankEditable
              ? Icons.save
              : (bankDetailsExist ? Icons.edit : Icons.add) // Show Add icon if no details exist
          ),
          label: Text(viewModel.isBankEditable
              ? strings.save
              : (bankDetailsExist ? strings.edit : strings.addBankDetailsAction) // Show Add text if needed
          ),
        ),
      ],
    );
  }
}