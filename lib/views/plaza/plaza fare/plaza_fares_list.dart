import 'dart:async';
import 'dart:developer' as developer; // Import developer for logging
import 'package:flutter/material.dart';
import 'package:merchant_app/models/plaza_fare.dart'; // Import FareTypes
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../config/app_colors.dart'; // Assuming AppColors exists
import '../../../config/app_theme.dart'; // For theme extensions like context.secondaryCardColor
import '../../../generated/l10n.dart';
import '../../../models/plaza.dart';
import '../../../utils/components/appbar.dart';
import '../../../utils/components/form_field.dart';
import '../../../utils/components/pagination_controls.dart';
import '../../../utils/components/card.dart'; // Assuming CustomCards.fareCard is here
import '../../../utils/components/pagination_mixin.dart';
import '../../../viewmodels/plaza_fare_viewmodel.dart';
import 'add_fare.dart';
import 'modify_view_fare.dart'; // Import ViewModel

class PlazaFaresListScreen extends StatefulWidget {
  final Plaza plaza;

  const PlazaFaresListScreen({
    super.key,
    required this.plaza,
  });

  @override
  State<PlazaFaresListScreen> createState() => _PlazaFaresListScreenState();
}

class _PlazaFaresListScreenState extends State<PlazaFaresListScreen>
    with PaginatedListMixin<PlazaFare> { // Specify PlazaFare type for mixin
  // Use context.read for one-time reads in initState/callbacks
  // Use Consumer or context.watch in build method for listening
  // late final PlazaFareViewModel _viewModel; // No longer needed here

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';
  int _currentPage = 1;
  Timer? _debounce;

  @override
  int get itemsPerPage => 10; // You can adjust this value

  @override
  void initState() {
    super.initState();
    // Access ViewModel for initial setup if needed, but loading is deferred
    // _viewModel = Provider.of<PlazaFareViewModel>(context, listen: false); // Can use context.read instead
    developer.log('PlazaFaresListScreen initState for Plaza: ${widget.plaza.plazaName} (ID: ${widget.plaza.plazaId})', name: 'PlazaFaresList');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        developer.log("Post frame callback: Calling _loadPlazaFaresData", name: "PlazaFaresList");
        // Pass context for potential error messages during load
        _loadPlazaFaresData(context);
      } else {
        developer.log("Post frame callback: Widget unmounted, skipping _loadPlazaFaresData", name: "PlazaFaresList");
      }
    });

    _searchController.addListener(_onSearchChanged);
    developer.log("PlazaFaresListScreen initState complete", name: "PlazaFaresList");
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      // Use context.read to access ViewModel for filtering if needed, or filter directly
      // final viewModel = context.read<PlazaFareViewModel>();
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
        _currentPage = 1; // Reset to first page on search
        developer.log('Search query changed: $_searchQuery', name: 'PlazaFaresList');
        // No need to explicitly call a filter method if filtering happens in _getFilteredFares
      });
    });
  }

  @override
  void dispose() {
    developer.log('Disposing PlazaFaresListScreen', name: 'PlazaFaresList');
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Pass BuildContext for error handling
  Future<void> _loadPlazaFaresData(BuildContext context) async {
    developer.log("_loadPlazaFaresData called", name: "PlazaFaresList");
    final viewModel = context.read<PlazaFareViewModel>(); // Use context.read
    final strings = S.of(context); // Get localization

    if (!mounted) {
      developer.log("_loadPlazaFaresData: Widget unmounted at start.", name: "PlazaFaresList");
      return;
    }
    final plazaIdString = widget.plaza.plazaId;

    if (plazaIdString != null) {
      developer.log('Loading fares for Plaza ID (String): $plazaIdString', name: 'PlazaFaresList');
      // Fetch fares and set the plaza name in the ViewModel
      await viewModel.fetchExistingFares(plazaIdString);
      if (mounted) {
        // Set plaza name for display in edit screen if needed (e.g., in the disabled plaza field)
        viewModel.setPlazaName(widget.plaza.plazaName!);
      }
    } else {
      developer.log('CRITICAL ERROR: Plaza ID is null for ${widget.plaza.plazaName}. Cannot load fares.', name: 'PlazaFaresList');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings.errorMissingPlazaId), // Localized
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
    if (mounted) {
      developer.log("_loadPlazaFaresData complete. Resetting page.", name: "PlazaFaresList");
      setState(() {
        _currentPage = 1; // Reset page after data load
      });
    }
  }

  // Refresh data - uses _loadPlazaFaresData
  Future<void> _refreshData() async {
    developer.log('Refreshing plaza fares data...', name: 'PlazaFaresList');
    if (!mounted) return;
    await _loadPlazaFaresData(context); // Pass context
  }

  // Filters the fares based on the search query (Uses ViewModel's data)
  List<PlazaFare> _getFilteredFares(PlazaFareViewModel viewModel) {
    if (viewModel.existingFares.isEmpty) {
      return [];
    }
    if (_searchQuery.isEmpty) {
      return viewModel.existingFares; // Return all if no query
    }
    // Filter based on search query (case-insensitive)
    return viewModel.existingFares.where((fare) {
      final vehicleMatch = fare.vehicleType.toLowerCase().contains(_searchQuery);
      final fareTypeMatch = fare.fareType.toLowerCase().contains(_searchQuery);
      // Fare Rate search (convert to string)
      final rateMatch = fare.fareRate.toStringAsFixed(2).contains(_searchQuery);
      // Progressive 'from'/'to' search (optional)
      final fromMatch = fare.from?.toString().contains(_searchQuery) ?? false;
      final toMatch = fare.toCustom?.toString().contains(_searchQuery) ?? false;

      return vehicleMatch || fareTypeMatch || rateMatch || fromMatch || toMatch;
    }).toList();
  }

  // Handles page changes for pagination
  void _updatePage(int newPage, List<PlazaFare> filteredFares) {
    // Use the mixin's updatePage method
    updatePage(newPage, filteredFares, (page) {
      if (!mounted) return;
      setState(() => _currentPage = page);
      developer.log('Pagination: Page changed to $_currentPage', name: 'PlazaFaresList');
      // Scroll to top smoothly when page changes
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  // Builds the search input field area
  Widget _buildSearchField(S strings) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.95,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        elevation: Theme.of(context).cardTheme.elevation ?? 1.0,
        // Use theme extension method for color if available
        color: context.secondaryCardColor, // Assumes AppTheme extension method
        shape: Theme.of(context).cardTheme.shape,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomFormFields.searchFormField(
                controller: _searchController,
                hintText: strings.searchPlazaFareHint, // Use specific hint
                context: context,
              ),
              // Optional: Add last updated time or refresh hint
              // const SizedBox(height: 8),
              // Text(
              //   '${strings.labelLastUpdated}: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}. ${strings.labelSwipeToRefresh}',
              //   style: Theme.of(context).textTheme.bodySmall?.copyWith(
              //     color: context.textSecondaryColor, // Assumes AppTheme extension
              //   ),
              //   textAlign: TextAlign.center,
              // ),
            ],
          ),
        ),
      ),
    );
  }

  // Builds the UI shown when no fares are found or match the search
  Widget _buildEmptyState(S strings, PlazaFareViewModel viewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchQuery.isEmpty ? Icons.receipt_long_outlined : Icons.search_off_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              strings.noFaresFoundLabel, // Generic "not found" label
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: context.textPrimaryColor, // Assumes AppTheme extension
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isEmpty
                  ? strings.noFaresForPlazaMessage
                  : strings.noFaresMatchSearchMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.textSecondaryColor, // Assumes AppTheme extension
              ),
              textAlign: TextAlign.center,
            ),
            // Clear search button
            if (_searchQuery.isNotEmpty) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  _searchController.clear(); // This triggers the listener -> _onSearchChanged
                },
                child: Text(
                  strings.clearSearchLabel,
                  style: TextStyle(color: AppColors.primary), // Use AppColors if defined
                ),
              ),
            ],
            // Button to Add Fare directly from empty state
            if (_searchQuery.isEmpty) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: Text(strings.buttonAddFare), // Add this string
                onPressed: () => _navigateToAddFare(viewModel), // Pass viewModel
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary, // Use AppColors
                  foregroundColor: Colors.white,
                ),
              )
            ]
          ],
        ),
      ),
    );
  }

  // Builds the shimmer loading placeholder list
  Widget _buildShimmerList() {
    // (Implementation remains the same)
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemsPerPage,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Theme.of(context).brightness == Brightness.light
              ? AppColors.shimmerBaseLight // Use defined AppColors
              : AppColors.shimmerBaseDark,
          highlightColor: Theme.of(context).brightness == Brightness.light
              ? AppColors.shimmerHighlightLight
              : AppColors.shimmerHighlightDark,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Card(
              elevation: 0,
              shape: Theme.of(context).cardTheme.shape,
              child: Container(
                height: 120, // Adjust height to match actual card approx
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(width: double.infinity, height: 20, color: context.backgroundColor), // Type/Rate Line 1
                          const SizedBox(height: 8),
                          Container(width: 150, height: 16, color: context.backgroundColor), // Type/Rate Line 2
                          const SizedBox(height: 8),
                          Container(width: 200, height: 16, color: context.backgroundColor), // Dates
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // --- Navigation Helpers ---

  // Navigate to Add Fare screen
  void _navigateToAddFare(PlazaFareViewModel viewModel) async {
    final strings = S.of(context);
    developer.log('Navigating to AddFareScreen', name: 'PlazaFaresList');
    // AddFareScreen uses Provider to get the viewModel instance.
    // We just need to pass the pre-selected Plaza.
    final added = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider.value( // Provide existing VM instance
          value: viewModel,
          child: AddFareScreen(selectedPlaza: widget.plaza), // Pass Plaza data
        ),
      ),
    );
    // If AddFareScreen pops with 'true', refresh data
    if (added == true && mounted) {
      developer.log('Returned from AddFareScreen with success, refreshing data.', name: 'PlazaFaresList');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.successFareSubmission), backgroundColor: Colors.green),
      );
      await _refreshData();
    }
  }

  // Navigate to Edit Fare screen
  void _navigateToEditFare(PlazaFare fare, PlazaFareViewModel viewModel) async {
    final strings = S.of(context);
    developer.log('Attempting to navigate to EditFareScreen for Fare ID: ${fare.fareId}', name: 'PlazaFaresList');
    final String? plazaIdString = widget.plaza.plazaId;

    if (plazaIdString == null) {
      developer.log('Navigation failed: Plaza ID is null.', name: 'PlazaFaresList');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(strings.errorMissingPlazaId), backgroundColor: Colors.red));
      }
      return;
    }

    final int? plazaIdInt = int.tryParse(plazaIdString);
    if (plazaIdInt == null) {
      developer.log('Navigation failed: Could not parse Plaza ID "$plazaIdString" to int.', name: 'PlazaFaresList');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(strings.errorInvalidPlazaIdFormat), backgroundColor: Colors.red));
      }
      return;
    }

    if (fare.fareId == null) {
      developer.log('Navigation failed: Fare ID is null.', name: 'PlazaFaresList');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(strings.errorMissingFareId), backgroundColor: Colors.red));
      }
      return;
    }

    developer.log('Navigating to EditFareScreen with Fare ID: ${fare.fareId}, Plaza ID (int): $plazaIdInt', name: 'PlazaFaresList');
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        // Provide the existing viewModel instance to the EditFareScreen
        builder: (context) => ChangeNotifierProvider.value(
          value: viewModel,
          child: EditFareScreen(fareId: fare.fareId!, plazaId: plazaIdInt), // Pass IDs
        ),
      ),
    );

    // If EditFareScreen pops with 'true', refresh data
    if (updated == true && mounted) {
      developer.log('Returned from EditFareScreen with success, refreshing data.', name: 'PlazaFaresList');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.successFareUpdated), backgroundColor: Colors.green),
      );
      await _refreshData();
    }
  }


  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    final strings = S.of(context); // Localizations instance

    // Use Consumer to get the ViewModel and rebuild when it notifies listeners
    return Consumer<PlazaFareViewModel>(
      builder: (context, viewModel, _) {
        // Get filtered list based on current search query using VM data
        final filteredFares = _getFilteredFares(viewModel);
        // Calculate total pages based on filtered list
        final totalPages = getTotalPages(filteredFares); // Use mixin method
        // Get the items for the current page
        final paginatedFares = getPaginatedItems(filteredFares, _currentPage); // Use mixin method

        // Determine UI state based on ViewModel's loading status and data
        final bool showLoading = viewModel.isLoading || viewModel.isLoadingFare; // Combine loading states?
        final bool showEmpty = !showLoading && filteredFares.isEmpty; // Check filtered list
        final bool showList = !showLoading && paginatedFares.isNotEmpty;
        final bool showPagination = showList && totalPages > 1;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: CustomAppBar.appBarWithNavigation(
            // Use a specific title including the plaza name
            screenTitle: strings.titleFaresForPlaza(widget.plaza.plazaName!), // Localized title with plaza name
            onPressed: () => Navigator.pop(context),
            darkBackground: Theme.of(context).brightness == Brightness.dark,
            context: context,
          ),
          body: Column(
            children: [
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: _buildSearchField(strings),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshData,
                  color: Theme.of(context).colorScheme.primary,
                  child: Stack( // Use Stack to potentially overlay shimmer/empty state
                    children: [
                      // Build the list or empty state
                      ListView.builder(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(top: 8, bottom: 80, left: 8, right: 8), // Padding for FAB
                        // Item count is 1 for empty/loading state, or actual count
                        itemCount: showList ? paginatedFares.length : 1,
                        itemBuilder: (context, index) {
                          if (showLoading) {
                            // Show shimmer directly as the only item
                            return _buildShimmerList();
                          } else if (showEmpty) {
                            // Show empty state directly as the only item
                            return SizedBox(
                              height: MediaQuery.of(context).size.height * 0.6,
                              child: _buildEmptyState(strings, viewModel),
                            );
                          } else { // showList
                            final fare = paginatedFares[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              // *** DELEGATE FARE DISPLAY TO CustomCards.fareCard ***
                              // You MUST update CustomCards.fareCard to handle
                              // Progressive, FreePass, and other types correctly.
                              child: CustomCards.fareCard(
                                fare: fare,
                                plazaName: widget.plaza.plazaName!, // Pass plaza name
                                onTap: () => _navigateToEditFare(fare, viewModel), // Pass fare and viewModel
                                context: context,
                                strings: strings, // Pass localization strings
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            heroTag: 'addFareFAB_ListScreen', // Ensure unique HeroTag
            backgroundColor: AppColors.primary, // Use AppColors
            onPressed: () => _navigateToAddFare(viewModel), // Pass viewModel
            tooltip: strings.buttonAddFare, // Localized tooltip
            child: const Icon(Icons.add, color: Colors.white),
          ),
          // Show pagination only if needed
          bottomNavigationBar: showPagination
              ? Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            child: SafeArea(
              child: PaginationControls(
                currentPage: _currentPage,
                totalPages: totalPages,
                // Pass the filtered list count to onPageChange
                onPageChange: (newPage) => _updatePage(newPage, filteredFares),
              ),
            ),
          )
              : null, // Hide if not paginated
        );
      },
    );
  }
}


// TODO: Ensure AppTheme extension methods like context.secondaryCardColor,
// context.textPrimaryColor, context.textSecondaryColor, context.backgroundColor exist.

// TODO: Update the implementation of `CustomCards.fareCard` to display fare details
// correctly based on `fare.fareType`, including handling for 'Progressive' and 'FREEPASS'.
// It should accept the `S strings` object for localization.