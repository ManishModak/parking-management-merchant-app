import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:merchant_app/generated/l10n.dart';
import 'package:merchant_app/models/lane.dart';
import 'package:merchant_app/views/plaza/plaza_registration/edit_new_lane_dialog.dart';
import 'package:merchant_app/views/plaza/plaza_registration/edit_saved_lane_dialog.dart';
import 'package:merchant_app/viewmodels/plaza/lane_details_viewmodel.dart';
import 'package:merchant_app/viewmodels/plaza/plaza_viewmodel.dart';
import 'package:provider/provider.dart';

class LaneDetailsStep extends StatelessWidget {
  const LaneDetailsStep({super.key});

  @override
  Widget build(BuildContext context) {
    final plazaVM = context.read<PlazaViewModel>();
    final strings = S.of(context);
    final theme = Theme.of(context);

    return Consumer<PlazaViewModel>(
      builder: (context, plazaViewModel, child) {
        final laneDetailsVM = plazaViewModel.laneDetails;
        final bool isEditable = laneDetailsVM.isEditable;
        final bool isLoading = laneDetailsVM.isLoading;
        final String? generalError = laneDetailsVM.errors['general'];

        developer.log(
            '[LaneDetailsStep UI Build] Consuming laneDetailsVM. HashCode: ${laneDetailsVM.hashCode}. isEditable=$isEditable, newLanes=${laneDetailsVM.newlyAddedLanes.length}, savedLanes=${laneDetailsVM.savedLanes.length}',
            name: 'LaneDetailsStep');

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (generalError != null && !isLoading)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                margin: const EdgeInsets.only(bottom: 16.0, left: 4, right: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: Icon(Icons.error_outline,
                          color: theme.colorScheme.onErrorContainer, size: 20),
                    ),
                    Expanded(
                      child: Text(
                        generalError,
                        style: TextStyle(
                            color: theme.colorScheme.onErrorContainer,
                            fontSize: 13),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close,
                          size: 16, color: theme.colorScheme.onErrorContainer),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: strings.buttonDismiss,
                      onPressed: () => laneDetailsVM.clearError('general'),
                    ),
                  ],
                ),
              ),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 60.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            Visibility(
              visible: !isLoading,
              maintainState: true,
              child: Builder(builder: (innerContext) {
                if (plazaVM.isLaneTabControllerInitialized &&
                    plazaVM.laneTabController != null) {
                  return SizedBox(
                    height: MediaQuery.of(innerContext).size.height * 0.55,
                    child: TabBarView(
                      controller: plazaVM.laneTabController!,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _buildLaneList(
                          context: innerContext,
                          isEditable: isEditable,
                          isNewlyAddedList: true,
                          listKey: 'newlyAddedLanesList',
                          emptyListMessage: isEditable
                              ? strings.messageNoNewLanesAddOne
                              : strings.messageNoNewLanesToAdd,
                          plazaVM: plazaVM,
                          laneDetailsVM: laneDetailsVM,
                        ),
                        _buildLaneList(
                          context: innerContext,
                          isEditable: isEditable,
                          isNewlyAddedList: false,
                          listKey: 'savedLanesList',
                          emptyListMessage: strings.messageNoExistingLanesSaved,
                          plazaVM: plazaVM,
                          laneDetailsVM: laneDetailsVM,
                        ),
                      ],
                    ),
                  );
                } else {
                  developer.log(
                      '[LaneDetailsStep] TabController not ready, showing placeholder.',
                      name: 'LaneDetailsStep');
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.0),
                    child: Center(child: Text("Initializing lane details...")),
                  );
                }
              }),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildLaneList({
    required BuildContext context,
    required bool isEditable,
    required bool isNewlyAddedList,
    required String listKey,
    required String emptyListMessage,
    required PlazaViewModel plazaVM,
    required LaneDetailsViewModel laneDetailsVM,
  }) {
    final theme = Theme.of(context);
    final strings = S.of(context);
    final List<Lane> lanes = isNewlyAddedList
        ? laneDetailsVM.newlyAddedLanes
        : laneDetailsVM.savedLanes;

    developer.log(
        'Building _buildLaneList (key: $listKey): Count=${lanes.length}, isNewlyAdded=$isNewlyAddedList, isEditable=$isEditable',
        name: 'LaneDetailsStep._buildLaneList');

    if (lanes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isNewlyAddedList
                    ? Icons.playlist_add_outlined
                    : Icons.list_alt_outlined,
                size: 48,
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
              ),
              const SizedBox(height: 16),
              Text(
                emptyListMessage,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      key: PageStorageKey(listKey),
      padding: const EdgeInsets.only(top: 8.0, bottom: 16.0, left: 4, right: 4),
      itemCount: lanes.length,
      itemBuilder: (context, index) {
        final lane = lanes[index];
        final cardWidget = _buildLaneCard(
            context: context,
            lane: lane,
            indexInList: index,
            isEditable: isEditable,
            isNewlyAdded: isNewlyAddedList,
            plazaVM: plazaVM,
            laneDetailsVM: laneDetailsVM);

        if (isNewlyAddedList && isEditable) {
          return Dismissible(
            key: ValueKey(lane.hashCode ^ index),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              final removedLaneName = lane.laneName;
              developer.log(
                  '[LaneDetailsStep] Dismissed new lane: $removedLaneName at index $index',
                  name: 'LaneDetailsStep');
              laneDetailsVM.removeNewLaneFromList(index);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(strings.messageLaneRemoved(removedLaneName)),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ));
              }
            },
            background: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.redAccent.withOpacity(0.85),
              ),
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(strings.buttonDelete.toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5)),
                  const SizedBox(width: 8),
                  const Icon(Icons.delete_sweep_outlined, color: Colors.white),
                ],
              ),
            ),
            child: cardWidget,
          );
        } else {
          return cardWidget;
        }
      },
      separatorBuilder: (context, index) => const SizedBox(height: 8),
    );
  }

  Widget _buildLaneCard({
    required BuildContext context,
    required Lane lane,
    required int indexInList,
    required bool isEditable,
    required bool isNewlyAdded,
    required PlazaViewModel plazaVM,
    required LaneDetailsViewModel laneDetailsVM,
  }) {
    final theme = Theme.of(context);
    final strings = S.of(context);
    final bool isActive = lane.laneStatus.toLowerCase() == 'active';
    final String statusText = isActive ? strings.active : strings.inactive;
    final Color statusColor =
        isActive ? theme.colorScheme.primary : theme.colorScheme.error;
    final Color statusBgColor =
        isActive ? statusColor.withOpacity(0.1) : statusColor.withOpacity(0.1);
    final Color cardColor = isNewlyAdded
        ? theme.cardColor
        : theme.colorScheme.surfaceContainerHighest.withOpacity(0.65);

    // Define all possible devices, showing "N/A" if the value is null
    final devices = [
      {'label': strings.labelRfidReaderId, 'value': lane.rfidReaderId ?? 'N/A'},
      {'label': strings.labelWimId, 'value': lane.wimId ?? 'N/A'},
      {'label': strings.labelCameraId, 'value': lane.cameraId ?? 'N/A'},
      {
        'label': strings.labelBoomerBarrierId,
        'value': lane.boomerBarrierId ?? 'N/A'
      },
      {'label': strings.labelLedScreenId, 'value': lane.ledScreenId ?? 'N/A'},
      {
        'label': strings.labelMagneticLoopId,
        'value': lane.magneticLoopId ?? 'N/A'
      },
    ];

    developer.log(
      'Building _buildLaneCard: Name="${lane.laneName}", ID=${lane.laneId}, isNewlyAdded=$isNewlyAdded, isEditable=$isEditable',
      name: 'LaneDetailsStep._buildLaneCard',
    );

    return Card(
        margin: EdgeInsets.zero,
        elevation: isEditable ? 2.0 : 0.8,
        shadowColor: isEditable
            ? theme.shadowColor.withOpacity(0.25)
            : Colors.transparent,
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isActive
                ? theme.colorScheme.primary.withOpacity(0.3)
                : theme.colorScheme.error.withOpacity(0.3),
            width: 0.5,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: isEditable
              ? () {
                  developer.log(
                      '[LaneDetailsStep] Card Tapped: isNewlyAdded=$isNewlyAdded, index=$indexInList',
                      name: 'LaneDetailsStep._buildLaneCard');
                  _handleCardTap(context, lane, indexInList, isNewlyAdded,
                      plazaVM, laneDetailsVM);
                }
              : null,
          splashColor: isEditable
              ? theme.splashColor.withOpacity(0.1)
              : Colors.transparent,
          highlightColor: isEditable
              ? theme.highlightColor.withOpacity(0.1)
              : Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row 1: Lane Name, Status, Edit Icon (if editable)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              '${strings.laneName}: ${lane.laneName}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isNewlyAdded
                                    ? theme.colorScheme.onSurface
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                              softWrap: true,
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusBgColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            statusText,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isEditable) ...[
                          const SizedBox(width: 8),
                          Icon(
                            isNewlyAdded
                                ? Icons.edit_note_outlined
                                : Icons.edit_outlined,
                            color: theme.colorScheme.primary,
                            size: 22,
                            semanticLabel: isNewlyAdded
                                ? strings.tooltipEditNewLane
                                : strings.tooltipEditSavedLane,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Row 2: Lane Direction and Lane Type
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${strings.laneDirection}: ',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  lane.laneDirection,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: isNewlyAdded
                                        ? theme.colorScheme.onSurface
                                        : theme.colorScheme.onSurfaceVariant,
                                  ),
                                  softWrap: true,
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${strings.laneType}: ',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  lane.laneType,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: isNewlyAdded
                                        ? theme.colorScheme.onSurface
                                        : theme.colorScheme.onSurfaceVariant,
                                  ),
                                  softWrap: true,
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Device Grid: Always show all devices
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 5, // Adjust as needed for layout
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: devices.length,
                  // Always 6 items (all devices)
                  itemBuilder: (context, index) {
                    final device = devices[index];
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(
                            '${device['label']}: ${device['value']}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isNewlyAdded
                                  ? theme.colorScheme.onSurface
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                            softWrap: true,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ));
  }

  void _handleCardTap(
      BuildContext context,
      Lane lane,
      int indexInList,
      bool isNewlyAdded,
      PlazaViewModel plazaVM,
      LaneDetailsViewModel laneDetailsVM) {
    final currentContext = context;
    developer.log(
        '[LaneDetailsStep] Handling card tap: isNewlyAdded=$isNewlyAdded, index=$indexInList, Lane Name="${lane.laneName}"',
        name: 'LaneDetailsStep._handleCardTap');

    if (isNewlyAdded) {
      showDialog(
        context: currentContext,
        barrierDismissible: false,
        builder: (_) => EditNewLaneDialog(
          lane: lane,
          index: indexInList,
          plazaViewModel: plazaVM,
          onSave: (index, updatedLane) {
            developer.log('[LaneDetailsStep] EditNewLaneDialog onSave called.',
                name: 'LaneDetailsStep._handleCardTap');
            try {
              laneDetailsVM.modifyNewLaneInList(index, updatedLane);
              developer.log(
                  '[LaneDetailsStep] laneDetailsVM.modifyNewLaneInList completed.',
                  name: 'LaneDetailsStep._handleCardTap');
            } catch (e) {
              developer.log(
                  "[LaneDetailsStep] Error from modifyNewLaneInList caught: $e",
                  name: "LaneDetailsStep._handleCardTap");
              rethrow;
            }
          },
        ),
      );
    } else {
      // NEW Check (for int? laneId)
      if (lane.laneId == null || lane.laneId! <= 0) {
        // Direct check for null or non-positive int
        developer.log(
            '[LaneDetailsStep] Error: Attempted to edit saved lane without valid ID (null or <= 0). Lane ID: ${lane.laneId}', // Log the actual int? value
            name: 'LaneDetailsStep._handleCardTap',
            level: 1000);
        if (currentContext.mounted) {
          ScaffoldMessenger.of(currentContext).showSnackBar(const SnackBar(
            content: Text(
                "Error: Cannot edit lane. Invalid or missing lane ID."), // Slightly adjusted message
            backgroundColor: Colors.redAccent,
          ));
        }
        return;
      }

      showDialog(
        context: currentContext,
        barrierDismissible: false,
        builder: (_) => EditSavedLaneDialog(
          lane: lane,
          index: indexInList,
          plazaViewModel: plazaVM,
          onSave: (index, updatedLane) async {
            developer.log(
                '[LaneDetailsStep] EditSavedLaneDialog onSave called. Awaiting VM update...',
                name: 'LaneDetailsStep._handleCardTap');
            await laneDetailsVM.updateSavedLane(
                index, updatedLane, currentContext);
            developer.log(
                '[LaneDetailsStep] EditSavedLaneDialog onSave completed (VM update finished).',
                name: 'LaneDetailsStep._handleCardTap');
          },
        ),
      );
    }
  }

  bool _hasDeviceInfo(Lane lane) {
    return (lane.rfidReaderId?.isNotEmpty ?? false) ||
        (lane.cameraId?.isNotEmpty ?? false) ||
        (lane.wimId?.isNotEmpty ?? false) ||
        (lane.boomerBarrierId?.isNotEmpty ?? false) ||
        (lane.ledScreenId?.isNotEmpty ?? false) ||
        (lane.magneticLoopId?.isNotEmpty ?? false);
  }

  Widget _buildLaneInfoChip(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    return Chip(
      avatar: Icon(icon, size: 14, color: theme.colorScheme.secondary),
      label: Text(text,
          style: theme.textTheme.labelMedium
              ?.copyWith(color: theme.colorScheme.onSecondaryContainer)),
      backgroundColor: theme.colorScheme.secondaryContainer.withOpacity(0.7),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      visualDensity: VisualDensity.compact,
      side: BorderSide.none,
    );
  }

  Widget _buildDeviceInfo(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Text.rich(
      TextSpan(children: [
        TextSpan(
            text: '$label: ',
            style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                fontWeight: FontWeight.w500)),
        TextSpan(
            text: value,
            style: TextStyle(
                fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
      ]),
      overflow: TextOverflow.ellipsis,
    );
  }
}
