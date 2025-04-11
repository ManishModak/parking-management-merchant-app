import 'package:flutter/material.dart';
import 'package:merchant_app/generated/l10n.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:merchant_app/utils/components/button.dart';
import 'package:merchant_app/views/plaza/plaza_registration/add_lane_dialog.dart';
import 'package:merchant_app/views/plaza/plaza_registration/bank_details.dart';
import 'package:merchant_app/views/plaza/plaza_registration/basic_details.dart';
import 'package:merchant_app/views/plaza/plaza_registration/lane_details.dart';
import 'package:merchant_app/views/plaza/plaza_registration/plaza_images.dart';
import 'package:merchant_app/viewmodels/plaza/plaza_viewmodel.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;

class PlazaRegistrationScreen extends StatelessWidget {
  final String? plazaIdForModification;

  const PlazaRegistrationScreen({super.key, this.plazaIdForModification});

  @override
  Widget build(BuildContext context) {
    developer.log('[PlazaRegistrationScreen] Building with plazaIdForModification: $plazaIdForModification', name: 'PlazaRegistrationScreen');
    return ChangeNotifierProvider(
      create: (_) => PlazaViewModel(plazaIdForModification: plazaIdForModification),
      child: const _PlazaRegistrationView(),
    );
  }
}

class _PlazaRegistrationView extends StatefulWidget {
  const _PlazaRegistrationView();

  @override
  _PlazaRegistrationViewState createState() => _PlazaRegistrationViewState();
}

class _PlazaRegistrationViewState extends State<_PlazaRegistrationView>
    with SingleTickerProviderStateMixin {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final viewModel = context.read<PlazaViewModel>();
        developer.log('[PlazaRegistrationView] initState: Initializing TabController and Data', name: 'PlazaRegistrationView');
        viewModel.initializeTabController(this);
        viewModel.initializeData(context);
      }
    });
  }

  Widget _buildStepIndicator(BuildContext context, int stepIndex, String title,
      bool isCompleted, bool isActive) {
    final theme = Theme.of(context);
    final viewModel = context.read<PlazaViewModel>();

    final int maxAllowedStep = viewModel.isModificationMode
        ? 3
        : (viewModel.completeTillStep + 1).clamp(0, 3);
    final bool isAccessible = stepIndex <= maxAllowedStep;

    developer.log('[PlazaRegistrationView] Step $stepIndex: isCompleted=$isCompleted, isActive=$isActive, isAccessible=$isAccessible', name: '_buildStepIndicator');

    final Color activeColor = theme.colorScheme.primary;
    final Color inactiveColor = theme.colorScheme.onSurface.withOpacity(0.38);
    final Color completedColor = theme.colorScheme.primary;
    final Color iconColor = theme.colorScheme.onPrimary;
    final Color numberColor = isActive ? iconColor : (isCompleted ? iconColor : theme.colorScheme.onSurface.withOpacity(0.87));
    final Color disabledTextColor = theme.colorScheme.onSurface.withOpacity(0.6);

    return GestureDetector(
      onTap: isAccessible ? () => viewModel.goToStep(stepIndex) : null,
      child: Opacity(
        opacity: isAccessible ? 1.0 : 0.5,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 36, height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? activeColor : (isCompleted ? completedColor : inactiveColor),
                boxShadow: [
                  if (isActive)
                    BoxShadow(
                      color: activeColor.withOpacity(0.4),
                      blurRadius: 6, offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Center(
                child: isCompleted && !isActive
                    ? Icon(Icons.check, color: iconColor, size: 18)
                    : Text(
                  '${stepIndex + 1}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: numberColor,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isAccessible
                    ? (isActive ? activeColor : theme.textTheme.bodySmall?.color)
                    : disabledTextColor,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent(BuildContext context) {
    final viewModel = context.watch<PlazaViewModel>();

    developer.log('[PlazaRegistrationView] Building Step Content for step: ${viewModel.currentStep}', name: '_buildStepContent');

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) => FadeTransition(opacity: animation, child: child),
      child: Container(
        key: ValueKey<int>(viewModel.currentStep),
        child: _getCurrentStepWidget(viewModel.currentStep),
      ),
    );
  }

  Widget _getCurrentStepWidget(int step) {
    switch (step) {
      case 0: return const BasicDetailsStep();
      case 1: return const LaneDetailsStep();
      case 2: return const BankDetailsStep();
      case 3: return const PlazaImagesStep();
      default:
        developer.log('[PlazaRegistrationView] Error: Invalid step index $step requested.', name: '_getCurrentStepWidget', level: 1000);
        return const SizedBox.shrink();
    }
  }

  Widget? _buildFab(BuildContext context, PlazaViewModel viewModel, S strings) {
    final laneDetailsVM = viewModel.laneDetails;
    final bool showFab = viewModel.currentStep == 1 && laneDetailsVM.isEditable;

    developer.log('[PlazaRegistrationView] FAB Check: showFab=$showFab', name: '_buildFab');

    if (!showFab) return null;

    return FloatingActionButton(
      onPressed: () {
        if (viewModel.plazaId == null) {
          developer.log('[PlazaRegistrationView] FAB Pressed: Blocked, plazaId is null.', name: '_buildFab');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(strings.messageErrorPlazaIdNotSetForLane),
            backgroundColor: Colors.redAccent,
          ));
          return;
        }

        developer.log('[PlazaRegistrationView] FAB Pressed: Opening AddLaneDialog.', name: '_buildFab');
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AddLaneDialog(
            onSave: (newLane) {
              developer.log('[PlazaRegistrationView] AddLaneDialog onSave called.', name: '_buildFab');
              viewModel.addNewLane(context, newLane);
            },
            plazaId: viewModel.plazaId!,
            plazaViewModel: viewModel,
          ),
        );
      },
      tooltip: strings.buttonAddLane,
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      child: const Icon(Icons.add),
    );
  }

  String _getButtonText(PlazaViewModel viewModel, S strings) {
    if (viewModel.currentStep == 3) {
      return strings.buttonFinish;
    }
    bool isCurrentStepEditable = false;
    try {
      switch (viewModel.currentStep) {
        case 0: isCurrentStepEditable = viewModel.basicDetails.isEditable; break;
        case 1: isCurrentStepEditable = viewModel.laneDetails.isEditable; break;
        case 2: isCurrentStepEditable = viewModel.bankDetails.isEditable; break;
      }
    } catch (e) {
      developer.log('[PlazaRegistrationView] Error accessing isEditable for button text: $e', name: '_getButtonText', level: 900);
    }

    developer.log('[PlazaRegistrationView] Button Text Check: currentStep=${viewModel.currentStep}, isEditable=$isCurrentStepEditable', name: '_getButtonText');
    return isCurrentStepEditable ? strings.buttonSaveAndNext : strings.buttonEdit;
  }

  bool _shouldTriggerSave(PlazaViewModel viewModel) {
    if (viewModel.currentStep == 3) {
      return true;
    }
    try {
      switch (viewModel.currentStep) {
        case 0: return viewModel.basicDetails.isEditable;
        case 1: return viewModel.laneDetails.isEditable;
        case 2: return viewModel.bankDetails.isEditable;
        default: return false;
      }
    } catch (e) {
      developer.log('[PlazaRegistrationView] Error accessing isEditable for save check: $e', name: '_shouldTriggerSave', level: 900);
      return false;
    }
  }

  void _toggleCurrentStepEditable(PlazaViewModel viewModel) {
    developer.log('[PlazaRegistrationView] Toggling editable for step: ${viewModel.currentStep}', name: '_toggleCurrentStepEditable');
    viewModel.toggleEditForCurrentStep();
  }

  Future<void> _handleBottomButtonPress(PlazaViewModel viewModel, BuildContext context) async {
    final strings = S.of(context);
    if (_shouldTriggerSave(viewModel)) {
      developer.log('[PlazaRegistrationView] Bottom Button: Triggering SAVE for step ${viewModel.currentStep}', name: '_handleBottomButtonPress');
      bool success = await _saveCurrentStep(viewModel, context);
      developer.log('[PlazaRegistrationView] Save result for step ${viewModel.currentStep}: $success', name: '_handleBottomButtonPress');
    } else {
      developer.log('[PlazaRegistrationView] Bottom Button: Triggering TOGGLE EDIT for step ${viewModel.currentStep}', name: '_handleBottomButtonPress');
      _toggleCurrentStepEditable(viewModel);
    }
  }

  Future<bool> _saveCurrentStep(PlazaViewModel viewModel, BuildContext context) async {
    switch (viewModel.currentStep) {
      case 0: return await viewModel.saveBasicDetails(context);
      case 1: return await viewModel.saveLaneDetails(context);
      case 2: return await viewModel.saveBankDetails(context);
      case 3: return await viewModel.savePlazaImages(context);
      default:
        developer.log('[PlazaRegistrationView] Error: Invalid step index ${viewModel.currentStep} for saving.', name: '_saveCurrentStep', level: 1000);
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PlazaViewModel>();
    final strings = S.of(context);
    final theme = Theme.of(context);
    final bool isStepLoading = viewModel.isLoading;

    developer.log('[PlazaRegistrationView] Main Build: currentStep=${viewModel.currentStep}, isLoading=$isStepLoading, completeTill=${viewModel.completeTillStep}', name: 'PlazaRegistrationView');

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar.appBarWithNavigation(
        screenTitle: strings.titlePlazaRegistration,
        onPressed: () {
          developer.log('[PlazaRegistrationView] AppBar Back Pressed.', name: 'PlazaRegistrationView');
          Navigator.pop(context);
        },
        darkBackground: theme.brightness == Brightness.dark,
        context: context,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
            color: theme.cardColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(4, (index) {
                String title;
                bool isCompleted;
                bool isActive = viewModel.currentStep == index;
                switch (index) {
                  case 0:
                    title = strings.labelBasicDetails;
                    isCompleted = viewModel.completeTillStep >= 0;
                    break;
                  case 1:
                    title = strings.labelLaneDetails;
                    isCompleted = viewModel.completeTillStep >= 1;
                    break;
                  case 2:
                    title = strings.labelBankDetails;
                    isCompleted = viewModel.completeTillStep >= 2;
                    break;
                  case 3:
                    title = strings.labelPlazaImages;
                    isCompleted = viewModel.completeTillStep >= 3;
                    break;
                  default:
                    title = '';
                    isCompleted = false;
                }
                return _buildStepIndicator(context, index, title, isCompleted, isActive);
              }),
            ),
          ),
          if (viewModel.currentStep == 1 && viewModel.isLaneTabControllerInitialized)
            Material(
              color: theme.cardColor,
              elevation: 1.0,
              child: TabBar(
                controller: viewModel.laneTabController!,
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.7),
                indicatorColor: theme.colorScheme.primary,
                indicatorWeight: 2.5,
                tabs: [
                  Tab(text: strings.labelNewLanes),
                  Tab(text: strings.labelExistingLanes),
                ],
              ),
            ),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildStepContent(context),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFab(context, viewModel, strings),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0 + MediaQuery.of(context).padding.bottom),
        color: theme.navigationBarTheme.backgroundColor ?? theme.cardColor,
        child: CustomButtons.primaryButton(
          height: 50,
          text: _getButtonText(viewModel, strings),
          onPressed: isStepLoading ? null : () => _handleBottomButtonPress(viewModel, context),
          isEnabled: !isStepLoading,
          context: context,
        ),
      ),
    );
  }
}
