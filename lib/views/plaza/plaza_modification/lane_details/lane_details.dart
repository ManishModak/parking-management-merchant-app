import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for input formatters
import 'package:provider/provider.dart';
import 'package:merchant_app/config/app_theme.dart';
import 'package:merchant_app/generated/l10n.dart';
import 'package:merchant_app/models/lane.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:merchant_app/utils/components/button.dart';
import 'package:merchant_app/utils/components/dropdown.dart';
import 'package:merchant_app/utils/components/form_field.dart';
import 'package:merchant_app/utils/components/pagination_controls.dart';
import 'package:merchant_app/utils/exceptions.dart';
import 'package:merchant_app/utils/screens/loading_screen.dart';
import 'package:merchant_app/viewmodels/plaza/plaza_modification_viewmodel.dart';
import 'modify_view_lane_details.dart'; // The screen to navigate to for editing
import 'dart:developer' as developer;

class LaneDetailsModificationScreen extends StatefulWidget {
  final String plazaId; // Keep String here

  const LaneDetailsModificationScreen({super.key, required this.plazaId});

  @override
  State<LaneDetailsModificationScreen> createState() =>
      _LaneDetailsModificationScreenState();
}

class _LaneDetailsModificationScreenState
    extends State<LaneDetailsModificationScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _currentPage = 1;
  static const int _itemsPerPage = 10; // Or fetch from config

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fetchLanes();
      }
    });

    _searchController.addListener(() {
      final newQuery = _searchController.text.trim().toLowerCase();
      if (newQuery != _searchQuery) {
        setState(() {
          _searchQuery = newQuery;
          _currentPage = 1; // Reset page on new search
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchLanes({bool isRefresh = false}) async {
    if (!mounted) return;
    final viewModel = context.read<PlazaModificationViewModel>();
    developer.log('[LaneDetailsModScreen] Fetching lanes for plazaId: ${widget.plazaId}', name: 'LaneDetailsModScreen');
    try {
      // Assuming fetchLanes handles the String plazaId internally if needed
      await viewModel.fetchLanes(widget.plazaId);
      if (isRefresh && mounted) {
        setState(() {
          _currentPage = 1; // Reset page on refresh
        });
      }
    } catch (e, stackTrace) {
      developer.log('[LaneDetailsModScreen] Error fetching lanes: $e', name: 'LaneDetailsModScreen', error: e, stackTrace: stackTrace, level: 1000);
      // Error state is handled by the build method using viewModel.error
      if (mounted) setState(() {}); // Ensure UI rebuilds to show error
    }
  }

  void _updatePage(int newPage) {
    if (newPage != _currentPage) {
      developer.log('[LaneDetailsModScreen] Changing page to: $newPage', name: 'LaneDetailsModScreen');
      setState(() {
        _currentPage = newPage;
      });
    }
  }

  Widget _buildSearchField(S strings) {
    return SizedBox(
      // Consider constraining width more precisely if needed
      width: double.infinity, // Take available width in padding
      child: CustomFormFields.searchFormField(
        controller: _searchController,
        hintText: strings.searchLanesHint,
        context: context,
      ),
    );
  }

  Widget _buildEmptyState(S strings) {
    final bool isSearching = _searchQuery.isNotEmpty;
    return LayoutBuilder( // Ensures Center takes full available space
      builder: (context, constraints) {
        return RefreshIndicator( // Allow refresh even when empty
          onRefresh: () => _fetchLanes(isRefresh: true),
          child: SingleChildScrollView( // Makes it scrollable if content overflows vertically
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox( // Ensures minimum height for centering
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off , // Changed icon
                        size: 64,
                        color: context.textSecondaryColor.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isSearching ? strings.noLanesMatchSearch : strings.noLanesFound, // Adjusted text
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: context.textSecondaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isSearching
                            ? strings.tryDifferentSearch // Add specific string
                            : strings.noLanesForPlazaAddOne, // Add specific string
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.textSecondaryColor.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (isSearching) ...[
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => _searchController.clear(),
                          child: Text(strings.clearSearch),
                        ),
                      ],
                      // Optionally add Add Lane button here too?
                      // const SizedBox(height: 24),
                      // CustomButtons.primaryButton(
                      //   context: context,
                      //   text: strings.buttonAddLane,
                      //   onPressed: _showAddLaneDialog,
                      //   width: 180,
                      // )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // --- UPDATED _buildLaneCard ---
  Widget _buildLaneCard(Lane lane, S strings) {
    final bool isActive = lane.laneStatus.toLowerCase() == 'active';
    final String statusText = isActive ? strings.active : strings.inactive;

    final devices = [
      {'label': strings.labelRfidReaderId, 'value': lane.rfidReaderId ?? 'N/A'},
      {'label': strings.labelWimId, 'value': lane.wimId ?? 'N/A'},
      {'label': strings.labelCameraId, 'value': lane.cameraId ?? 'N/A'},
      {'label': strings.labelBoomerBarrierId, 'value': lane.boomerBarrierId ?? 'N/A'},
      {'label': strings.labelLedScreenId, 'value': lane.ledScreenId ?? 'N/A'},
      {'label': strings.labelMagneticLoopId, 'value': lane.magneticLoopId ?? 'N/A'},
    ];

    return Card(
      elevation: 1.5, // Slightly reduced elevation
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isActive
              ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
              : Theme.of(context).colorScheme.error.withOpacity(0.3),
          width: 0.6, // Slightly thicker border
        ),
      ),
      margin: const EdgeInsets.symmetric(vertical: 6.0), // Adjusted margin
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // --- ADDED Null Check ---
          final int? laneIdInt = lane.laneId;
          if (laneIdInt == null) {
            developer.log('[LaneDetailsModScreen] Card tapped for lane with NULL ID: ${lane.laneName}', name: 'LaneDetailsModScreen', level: 1000);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(strings.errorInvalidLaneIdNavigate)), // Specific error string
            );
            return;
          }
          // --- END Null Check ---
          developer.log('[LaneDetailsModScreen] Navigating to edit lane ID: $laneIdInt', name: 'LaneDetailsModScreen');
          Navigator.push(
            context,
            MaterialPageRoute(
              // Pass the ID as String, Modify screen expects String
              builder: (context) => ModifyViewLaneDetailsScreen(laneId: laneIdInt.toString()),
            ),
          ).then((_) {
            // Refresh list when returning from edit screen
            developer.log('[LaneDetailsModScreen] Returned from edit screen, refreshing lanes...', name: 'LaneDetailsModScreen');
            _fetchLanes(isRefresh: true);
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Lane Name, Status, Chevron
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start, // Align top
                children: [
                  Expanded( // Lane Name takes available space
                    child: Text(
                      '${strings.laneName}: ${lane.laneName}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith( // Slightly larger title
                        fontWeight: FontWeight.w600, // Bolder
                        color: context.textPrimaryColor,
                      ),
                      overflow: TextOverflow.ellipsis, // Handle long names
                      maxLines: 2,
                    ),
                  ),
                  const SizedBox(width: 8), // Space before status/icon
                  Row( // Group Status and Chevron
                    mainAxisSize: MainAxisSize.min, // Don't take extra space
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), // Adjusted padding
                        decoration: BoxDecoration(
                          color: isActive
                              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                              : Theme.of(context).colorScheme.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10), // More rounded
                        ),
                        child: Text(
                          statusText.toUpperCase(), // Uppercase status
                          style: Theme.of(context).textTheme.bodySmall?.copyWith( // Smaller status text
                            color: isActive
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.chevron_right,
                        color: context.textSecondaryColor.withOpacity(0.7), // Slightly muted chevron
                        size: 22,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10), // Increased space

              // Row 2: Lane Direction and Lane Type
              Row(
                // Removed CrossAxisAlignment.start as Text Rich handles baseline
                children: [
                  Expanded(
                    child: Text.rich(TextSpan(
                        children: [
                          TextSpan(text: '${strings.laneDirection}: ', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.textSecondaryColor)),
                          TextSpan(text: lane.laneDirection, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.textPrimaryColor, fontWeight: FontWeight.w500)),
                        ]
                    )),
                  ),
                  Expanded(
                    child: Text.rich(TextSpan(
                        children: [
                          TextSpan(text: '${strings.laneType}: ', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.textSecondaryColor)),
                          TextSpan(text: lane.laneType, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.textPrimaryColor, fontWeight: FontWeight.w500)),
                        ]
                    )),
                  ),
                ],
              ),
              const SizedBox(height: 10), // Increased space

              // Device Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 6, // Adjusted ratio for potentially longer text
                  crossAxisSpacing: 10, // Increased spacing
                  mainAxisSpacing: 5, // Increased spacing
                ),
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  final device = devices[index];
                  return Tooltip( // Add tooltip for full ID if needed
                    message: '${device['label']}: ${device['value']!}',
                    child: Text(
                      '${device['label']}: ${device['value']!}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith( // Smaller device text
                        color: context.textSecondaryColor,
                      ),
                      overflow: TextOverflow.ellipsis, // Handle long IDs
                      maxLines: 1,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
  // --- END UPDATED _buildLaneCard ---

  Widget _buildErrorState(Exception error, S strings) {
    // Error state builder remains largely the same, ensure strings are appropriate
    String errorTitle = strings.errorTitleDefault;
    String errorMessage = strings.errorMessageDefault;
    String? errorDetails;

    if (error is HttpException) {
      errorTitle = strings.errorTitleWithCode(error.statusCode ?? 0);
      errorMessage = error.message;
      errorDetails = error.serverMessage;
    } else if (error is ServiceException) {
      errorTitle = strings.errorTitleService;
      errorMessage = error.message;
      errorDetails = error.serverMessage;
    } else {
      errorTitle = strings.errorLoadingLanesFailed; // Specific title
      errorMessage = strings.errorMessagePleaseTryAgain;
      errorDetails = error.toString();
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_outlined, // Different icon for network/load errors
                size: 64, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text(errorTitle, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(errorMessage, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: context.textSecondaryColor), textAlign: TextAlign.center),
            if (errorDetails != null && errorDetails.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(errorDetails, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.textSecondaryColor.withOpacity(0.7)), textAlign: TextAlign.center),
            ],
            const SizedBox(height: 24),
            CustomButtons.primaryButton(
              height: 40,
              width: 150,
              text: strings.buttonRetry,
              onPressed: () => _fetchLanes(isRefresh: true),
              context: context,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddLaneDialog() {
    developer.log('[LaneDetailsModScreen] Showing Add Lane Dialog.', name: 'LaneDetailsModScreen');
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent accidental dismiss
      builder: (_) => AddLaneDialog( // Use the embedded dialog
        plazaId: widget.plazaId, // Pass plazaId (String)
        onSave: _handleAddLane, // Pass the correct callback
        // existingLanes: context.read<PlazaModificationViewModel>().lanes, // Pass current lanes for duplicate check in dialog
      ),
    );
  }

  // --- UPDATED _handleAddLane ---
  // Receives the fully formed Lane object from the AddLaneDialog
  Future<void> _handleAddLane(Lane newLaneFromDialog) async {
    developer.log('[LaneDetailsModScreen] Received new lane from dialog: ${newLaneFromDialog.laneName}', name: 'LaneDetailsModScreen._handleAddLane');
    // No need to reconstruct the Lane object here. The dialog should have done it.
    // No need to parse plazaId again here.

    final viewModel = context.read<PlazaModificationViewModel>();

    // Directly call the ViewModel's addLane method
    try {
      await viewModel.addLane(newLaneFromDialog); // Pass the object directly
      developer.log('[LaneDetailsModScreen] viewModel.addLane successful.', name: 'LaneDetailsModScreen._handleAddLane');
      // Fetch lanes AFTER successful addition
      await _fetchLanes(isRefresh: true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).laneAddedSuccess)),
        );
      }
    } catch (e, stackTrace) {
      developer.log('[LaneDetailsModScreen] Error calling viewModel.addLane: $e', name: 'LaneDetailsModScreen._handleAddLane', error: e, stackTrace: stackTrace, level: 1000);
      if (mounted) {
        // Show error from exception if possible
        String errorMsg = S.of(context).laneAddFailed;
        if (e is PlazaException) {
          errorMsg = e.serverMessage ?? e.message ?? errorMsg;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg)),
        );
      }
    }
  }
  // --- END UPDATED _handleAddLane ---

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PlazaModificationViewModel>();
    final strings = S.of(context);

    // Perform filtering based on search query
    List<Lane> filteredLanes = viewModel.lanes.where((lane) {
      final query = _searchQuery.toLowerCase();
      // Search by name, direction, type, status, or any device ID
      return lane.laneName.toLowerCase().contains(query) ||
          lane.laneDirection.toLowerCase().contains(query) ||
          lane.laneType.toLowerCase().contains(query) ||
          lane.laneStatus.toLowerCase().contains(query) ||
          (lane.rfidReaderId?.toLowerCase().contains(query) ?? false) ||
          (lane.cameraId?.toLowerCase().contains(query) ?? false) ||
          (lane.wimId?.toLowerCase().contains(query) ?? false) ||
          (lane.boomerBarrierId?.toLowerCase().contains(query) ?? false) ||
          (lane.ledScreenId?.toLowerCase().contains(query) ?? false) ||
          (lane.magneticLoopId?.toLowerCase().contains(query) ?? false);
      // Consider adding PlazaLaneId to search?
      // || lane.plazaLaneId.toString().contains(query)
    }).toList();

    // Apply pagination to the filtered list
    final int totalItems = filteredLanes.length;
    final int totalPages = (totalItems / _itemsPerPage).ceil();
    // Ensure _currentPage is valid
    if (_currentPage > totalPages && totalPages > 0) {
      _currentPage = totalPages;
    } else if (_currentPage < 1 && totalPages > 0) {
      _currentPage = 1;
    } else if (totalPages == 0) {
      _currentPage = 1; // Reset to 1 if no pages
    }
    final int startIndex = (_currentPage - 1) * _itemsPerPage;
    final int endIndex = (startIndex + _itemsPerPage).clamp(0, totalItems);
    final List<Lane> paginatedLanes = (startIndex < totalItems)
        ? filteredLanes.sublist(startIndex, endIndex)
        : [];

    return Scaffold(
      appBar: CustomAppBar.appBarWithNavigation(
        screenTitle: strings.laneDetails,
        onPressed: () => Navigator.pop(context),
        darkBackground: Theme.of(context).brightness == Brightness.dark,
        context: context,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // Use a Column structure for better layout control
      body: Column(
        children: [
          // Search bar always visible
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0), // Adjusted padding
            child: _buildSearchField(strings),
          ),
          // Content area (Loading, Error, Empty, List)
          Expanded(
            child: Builder( // Use Builder to get context within Column
                builder: (context) {
                  if (viewModel.isLoading && viewModel.lanes.isEmpty) {
                    return const LoadingScreen();
                  } else if (viewModel.error != null && viewModel.lanes.isEmpty) {
                    // Show error state only if loading finished and still no lanes
                    return _buildErrorState(viewModel.error!, strings);
                  } else if (filteredLanes.isEmpty) {
                    // Show empty state (could be no lanes initially or no search results)
                    return _buildEmptyState(strings);
                  } else {
                    // Show the list with refresh indicator
                    return RefreshIndicator(
                      onRefresh: () => _fetchLanes(isRefresh: true),
                      child: ListView.builder(
                        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16), // Add bottom padding
                        itemCount: paginatedLanes.length,
                        itemBuilder: (context, index) {
                          return _buildLaneCard(paginatedLanes[index], strings);
                        },
                      ),
                    );
                  }
                }
            ),
          ),
          // Pagination controls always visible if needed
          if (totalPages > 1)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12), // Adjusted padding
              child: PaginationControls(
                currentPage: _currentPage,
                totalPages: totalPages,
                onPageChange: _updatePage,
              ),
            ),
        ],
      ),
      // Add Lane FAB
      floatingActionButton: FloatingActionButton.extended( // Use extended for label
        onPressed: _showAddLaneDialog,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        icon: const Icon(Icons.add),
        label: Text(strings.buttonAddLane), // Add label
      ),
    );
  }
}


// --- AddLaneDialog (Embedded and Updated) ---

class AddLaneDialog extends StatefulWidget {
  final String plazaId; // Passed as String
  final Function(Lane newLaneValidated) onSave; // Callback returns validated Lane
  // Removed existingLanes, duplicate check should happen before calling onSave

  const AddLaneDialog({
    super.key,
    required this.plazaId,
    required this.onSave,
    // required this.existingLanes, // Removed
  });

  @override
  _AddLaneDialogState createState() => _AddLaneDialogState();
}

class _AddLaneDialogState extends State<AddLaneDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _laneNameController;
  // --- ADDED Controller ---
  late final TextEditingController _plazaLaneIdController;
  // --- END ADDED ---
  late final TextEditingController _rfidReaderController;
  late final TextEditingController _cameraController;
  late final TextEditingController _wimController;
  late final TextEditingController _boomerBarrierController;
  late final TextEditingController _ledScreenController;
  late final TextEditingController _magneticLoopController;
  String? _selectedDirection;
  String? _selectedType;
  String? _selectedStatus;
  final Map<String, String?> _errors = {}; // Store local validation errors
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    developer.log('[AddLaneDialog-Embedded] initState', name: 'AddLaneDialog');
    _laneNameController = TextEditingController();
    // --- ADDED Initialization ---
    _plazaLaneIdController = TextEditingController();
    // --- END ADDED ---
    _rfidReaderController = TextEditingController();
    _cameraController = TextEditingController();
    _wimController = TextEditingController();
    _boomerBarrierController = TextEditingController();
    _ledScreenController = TextEditingController();
    _magneticLoopController = TextEditingController();

    // Set default values for dropdowns
    _selectedDirection = null; // Start empty, force user selection
    _selectedType = null; // Start empty, force user selection
    _selectedStatus = Lane.validStatuses.firstWhere(
          (s) => s.toLowerCase() == 'active',
      orElse: () => Lane.validStatuses.first, // Default to active
    );
  }

  @override
  void dispose() {
    developer.log('[AddLaneDialog-Embedded] dispose', name: 'AddLaneDialog');
    _laneNameController.dispose();
    // --- ADDED Dispose ---
    _plazaLaneIdController.dispose();
    // --- END ADDED ---
    _rfidReaderController.dispose();
    _cameraController.dispose();
    _wimController.dispose();
    _boomerBarrierController.dispose();
    _ledScreenController.dispose();
    _magneticLoopController.dispose();
    super.dispose();
  }

  // --- UPDATED _handleSave for AddLaneDialog ---
  void _handleSave() async {
    if (_isSaving) return;
    setState(() { _isSaving = true; _errors.clear(); });
    developer.log('[AddLaneDialog-Embedded] Handle Save: Starting...', name: 'AddLaneDialog');

    // 1. Parse IDs
    int? parsedPlazaId;
    int? parsedPlazaLaneId;
    bool hasParsingError = false;

    try {
      parsedPlazaId = int.parse(widget.plazaId);
      if (parsedPlazaId < 0) throw FormatException("Plaza ID must be >= 0");
    } catch (e) {
      developer.log('[AddLaneDialog-Embedded] Invalid plazaId: ${widget.plazaId}', name: 'AddLaneDialog', level: 1000);
      _errors['general'] = S.of(context).errorInvalidPlazaId; // Use general error for this
      hasParsingError = true;
    }

    final plazaLaneIdString = _plazaLaneIdController.text.trim();
    if (plazaLaneIdString.isEmpty) {
      _errors['plazaLaneId'] = S.of(context).validationFieldRequired("Plaza Lane ID");
      hasParsingError = true;
    } else {
      try {
        parsedPlazaLaneId = int.parse(plazaLaneIdString);
        if (parsedPlazaLaneId <= 0) throw FormatException("Plaza Lane ID must be positive");
      } catch (e) {
        developer.log('[AddLaneDialog-Embedded] Invalid plazaLaneId: $plazaLaneIdString', name: 'AddLaneDialog', level: 900);
        _errors['plazaLaneId'] = S.of(context).validationNumberInvalid("Plaza Lane ID");
        hasParsingError = true;
      }
    }

    if (hasParsingError) {
      setState(() { _isSaving = false; });
      return;
    }

    // 2. Construct Lane Candidate
    final newLaneCandidate = Lane(
      plazaId: parsedPlazaId!, // Known non-null if no error
      plazaLaneId: parsedPlazaLaneId!, // Known non-null if no error
      laneName: _laneNameController.text.trim(),
      laneDirection: _selectedDirection ?? '', // Check if null is allowed by schema, else validate
      laneType: _selectedType ?? '', // Check if null is allowed by schema, else validate
      laneStatus: _selectedStatus ?? '', // Should have a default
      rfidReaderId: _rfidReaderController.text.trim().isEmpty ? null : _rfidReaderController.text.trim(),
      cameraId: _cameraController.text.trim().isEmpty ? null : _cameraController.text.trim(),
      wimId: _wimController.text.trim().isEmpty ? null : _wimController.text.trim(),
      boomerBarrierId: _boomerBarrierController.text.trim().isEmpty ? null : _boomerBarrierController.text.trim(),
      ledScreenId: _ledScreenController.text.trim().isEmpty ? null : _ledScreenController.text.trim(),
      magneticLoopId: _magneticLoopController.text.trim().isEmpty ? null : _magneticLoopController.text.trim(),
      laneId: null,
      recordStatus: null,
    );

    // 3. Validate using Model's Method
    final String? validationError = newLaneCandidate.validateForCreate();
    if (validationError != null) {
      developer.log('[AddLaneDialog-Embedded] Model Validation Failed: $validationError', name: 'AddLaneDialog', level: 900);
      setState(() {
        _errors['general'] = validationError;
        _isSaving = false;
      });
      return;
    }
    developer.log('[AddLaneDialog-Embedded] Model Validation Successful.', name: 'AddLaneDialog');

    // 4. Duplicate Check (using list from ViewModel accessed via context)
    // It's slightly better for the *caller* (main screen) to do the duplicate check
    // *before* calling the actual add service, but we can do it here too.
    final viewModel = context.read<PlazaModificationViewModel>();
    final List<Lane> allCurrentLanes = viewModel.lanes; // Get current lanes
    final Map<String, String> duplicateErrors = _checkForDuplicatesLocally(newLaneCandidate, allCurrentLanes);
    if (duplicateErrors.isNotEmpty) {
      developer.log('[AddLaneDialog-Embedded] Local Duplicate Check Failed: $duplicateErrors', name: 'AddLaneDialog', level: 900);
      setState(() {
        _errors.addAll(duplicateErrors);
        _errors['general'] = S.of(context).validationDuplicateGeneral;
        _isSaving = false;
      });
      return;
    }
    developer.log('[AddLaneDialog-Embedded] Local Duplicate Check Successful.', name: 'AddLaneDialog');

    // 5. If all checks pass, call the onSave callback with the validated Lane object
    try {
      developer.log('[AddLaneDialog-Embedded] Calling widget.onSave...', name: 'AddLaneDialog');
      // The callback expects the caller (_handleAddLane) to handle the async saving.
      // This dialog just provides the validated data.
      widget.onSave(newLaneCandidate);
      developer.log('[AddLaneDialog-Embedded] widget.onSave called.', name: 'AddLaneDialog');
      if (mounted) Navigator.pop(context); // Close dialog on successful validation & callback call
    } catch (e, stackTrace) {
      // Should not happen if onSave doesn't throw, but good practice
      developer.log('[AddLaneDialog-Embedded] Error during onSave callback execution: $e', name: 'AddLaneDialog', error: e, stackTrace: stackTrace, level: 1000);
      if (mounted) {
        setState(() {
          _errors['general'] = S.of(context).errorUnexpected; // Generic error
          _isSaving = false;
        });
      }
    }

    // Reset saving state if it hasn't been reset on error
    // if (mounted && _isSaving) {
    //   setState(() => _isSaving = false);
    // }
  }
  // --- END UPDATED _handleSave ---


  // Renamed duplicate check function to avoid conflict if copy-pasted
  Map<String, String> _checkForDuplicatesLocally(Lane newLane, List<Lane> existingLanes) {
    final duplicateErrors = <String, String>{};
    developer.log('[AddLaneDialog-Embedded] Checking duplicates locally for "${newLane.laneName}" against ${existingLanes.length} lanes.', name: '_checkForDuplicatesLocally');
    bool isDuplicateValue(String? newValue, String? existingValue) {
      if (newValue == null || newValue.trim().isEmpty) return false;
      if (existingValue == null || existingValue.trim().isEmpty) return false;
      return newValue.trim().toLowerCase() == existingValue.trim().toLowerCase();
    }
    for (var existingLane in existingLanes) {
      // No need to check ID here as newLane.laneId is null
      if (isDuplicateValue(newLane.laneName, existingLane.laneName)) duplicateErrors['LaneName'] = S.of(context).validationDuplicate('Lane name');
      if (isDuplicateValue(newLane.rfidReaderId, existingLane.rfidReaderId)) duplicateErrors['RFIDReaderID'] = S.of(context).validationDuplicate('RFID Reader ID');
      if (isDuplicateValue(newLane.cameraId, existingLane.cameraId)) duplicateErrors['CameraID'] = S.of(context).validationDuplicate('Camera ID');
      if (isDuplicateValue(newLane.wimId, existingLane.wimId)) duplicateErrors['WIMID'] = S.of(context).validationDuplicate('WIM ID');
      if (isDuplicateValue(newLane.boomerBarrierId, existingLane.boomerBarrierId)) duplicateErrors['BoomerBarrierID'] = S.of(context).validationDuplicate('Boomer Barrier ID');
      if (isDuplicateValue(newLane.ledScreenId, existingLane.ledScreenId)) duplicateErrors['LEDScreenID'] = S.of(context).validationDuplicate('LED Screen ID');
      if (isDuplicateValue(newLane.magneticLoopId, existingLane.magneticLoopId)) duplicateErrors['MagneticLoopID'] = S.of(context).validationDuplicate('Magnetic Loop ID');
      // Check plazaLaneId for uniqueness within the *same* plazaId
      if (newLane.plazaId == existingLane.plazaId && newLane.plazaLaneId == existingLane.plazaLaneId) {
        duplicateErrors['plazaLaneId'] = S.of(context).validationDuplicate('Plaza Lane ID');
      }
    }
    if (duplicateErrors.isNotEmpty) {
      developer.log('[AddLaneDialog-Embedded] Local duplicate check found issues: $duplicateErrors', name: '_checkForDuplicatesLocally');
    }
    return duplicateErrors;
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final theme = Theme.of(context);
    final Color iconColor = !_isSaving ? theme.iconTheme.color ?? theme.primaryColor : theme.disabledColor;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Text(
                  strings.titleAddLane,
                  style: theme.dialogTheme.titleTextStyle ?? theme.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 16),
                      CustomFormFields.normalSizedTextFormField(
                        context: context,
                        label: '${strings.labelLaneName} *',
                        controller: _laneNameController,
                        enabled: !_isSaving,
                        errorText: _errors['LaneName'],
                        prefixIcon: Icon(Icons.drive_file_rename_outline, color: iconColor),
                        onChanged: (_) => setState(() => _errors.remove('LaneName')),
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 16),
                      // --- ADDED Plaza Lane ID Field ---
                      CustomFormFields.normalSizedTextFormField(
                        context: context,
                        label: '${"Plaza Lane ID"} *', // Use S.of(context) if available
                        controller: _plazaLaneIdController,
                        enabled: !_isSaving,
                        errorText: _errors['plazaLaneId'],
                        prefixIcon: Icon(Icons.confirmation_number_outlined, color: iconColor),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        onChanged: (_) => setState(() => _errors.remove('plazaLaneId')),
                      ),
                      // --- END ADDED ---
                      const SizedBox(height: 16),
                      CustomDropDown.normalDropDown(
                        context: context,
                        label: '${strings.labelDirection} *',
                        value: _selectedDirection,
                        items: Lane.validDirections,
                        enabled: !_isSaving,
                        onChanged: (value) => setState(() { _selectedDirection = value; _errors.remove('LaneDirection'); }),
                        errorText: _errors['LaneDirection'],
                        prefixIcon: Icon(Icons.compare_arrows_outlined, color: iconColor),
                      ),
                      const SizedBox(height: 16),
                      CustomDropDown.normalDropDown(
                        context: context,
                        label: '${strings.labelType} *',
                        value: _selectedType,
                        items: Lane.validTypes,
                        enabled: !_isSaving,
                        onChanged: (value) => setState(() { _selectedType = value; _errors.remove('LaneType'); }),
                        errorText: _errors['LaneType'],
                        prefixIcon: Icon(Icons.merge_type_outlined, color: iconColor),
                      ),
                      const SizedBox(height: 16),
                      CustomDropDown.normalDropDown(
                        context: context,
                        label: '${strings.labelStatus} *',
                        value: _selectedStatus, // Has default
                        items: Lane.validStatuses,
                        enabled: !_isSaving,
                        onChanged: (value) => setState(() { _selectedStatus = value; _errors.remove('LaneStatus'); }),
                        errorText: _errors['LaneStatus'],
                        prefixIcon: Icon(Icons.toggle_on_outlined, color: iconColor),
                      ),
                      const SizedBox(height: 16),
                      // Optional Fields
                      CustomFormFields.normalSizedTextFormField(
                        context: context,
                        label: strings.labelRfidReaderId, // No asterisk
                        controller: _rfidReaderController,
                        enabled: !_isSaving,
                        errorText: _errors['RFIDReaderID'],
                        prefixIcon: Icon(Icons.wifi_tethering, color: iconColor),
                        onChanged: (_) => setState(() => _errors.remove('RFIDReaderID')),
                      ),
                      // ... other optional fields ...
                      const SizedBox(height: 16),
                      CustomFormFields.normalSizedTextFormField(
                        context: context,
                        label: strings.labelCameraId,
                        controller: _cameraController,
                        enabled: !_isSaving,
                        errorText: _errors['CameraID'],
                        prefixIcon: Icon(Icons.camera_alt_outlined, color: iconColor),
                        onChanged: (_) => setState(() => _errors.remove('CameraID')),
                      ),
                      const SizedBox(height: 16),
                      CustomFormFields.normalSizedTextFormField(
                        context: context,
                        label: strings.labelWimId,
                        controller: _wimController,
                        enabled: !_isSaving,
                        errorText: _errors['WIMID'],
                        prefixIcon: Icon(Icons.speed_outlined, color: iconColor),
                        onChanged: (_) => setState(() => _errors.remove('WIMID')),
                      ),
                      const SizedBox(height: 16),
                      CustomFormFields.normalSizedTextFormField(
                        context: context,
                        label: strings.labelBoomerBarrierId,
                        controller: _boomerBarrierController,
                        enabled: !_isSaving,
                        errorText: _errors['BoomerBarrierID'],
                        prefixIcon: Icon(Icons.traffic_outlined, color: iconColor),
                        onChanged: (_) => setState(() => _errors.remove('BoomerBarrierID')),
                      ),
                      const SizedBox(height: 16),
                      CustomFormFields.normalSizedTextFormField(
                        context: context,
                        label: strings.labelLedScreenId,
                        controller: _ledScreenController,
                        enabled: !_isSaving,
                        errorText: _errors['LEDScreenID'],
                        prefixIcon: Icon(Icons.screenshot_monitor_outlined, color: iconColor),
                        onChanged: (_) => setState(() => _errors.remove('LEDScreenID')),
                      ),
                      const SizedBox(height: 16),
                      CustomFormFields.normalSizedTextFormField(
                        context: context,
                        label: strings.labelMagneticLoopId,
                        controller: _magneticLoopController,
                        enabled: !_isSaving,
                        errorText: _errors['MagneticLoopID'],
                        prefixIcon: Icon(Icons.sensors_outlined, color: iconColor),
                        onChanged: (_) => setState(() => _errors.remove('MagneticLoopID')),
                      ),

                      // General Error Display
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return FadeTransition(opacity: animation, child: child);
                        },
                        child: _errors['general'] != null
                            ? Padding(
                          key: const ValueKey('general_error_add_embedded'),
                          padding: const EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0),
                          child: Text(
                            _errors['general']!,
                            style: TextStyle(color: theme.colorScheme.error, fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                        )
                            : const SizedBox.shrink(key: ValueKey('no_general_error_add_embedded')),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isSaving ? null : () => Navigator.pop(context),
                      child: Text(strings.buttonCancel),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _handleSave,
                      style: ElevatedButton.styleFrom(minimumSize: const Size(80, 36)),
                      child: _isSaving
                          ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                          : Text(strings.buttonAdd),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} // End of _AddLaneDialogState