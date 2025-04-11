import 'dart:async';
import 'dart:developer' as developer; // Import developer for logging
import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_theme.dart';
import 'package:merchant_app/viewmodels/plaza_fare_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../config/app_colors.dart';
import '../../../generated/l10n.dart';
import '../../../models/plaza.dart';
import '../../../models/plaza_fare.dart'; // Ensure PlazaFare model is imported
import '../../../utils/components/appbar.dart';
import '../../../utils/components/form_field.dart';
import '../../../utils/components/pagination_controls.dart';
import '../../../utils/components/card.dart';
import '../../../utils/components/pagination_mixin.dart';
import 'add_fare.dart';
import 'modify_view_fare.dart'; // Renamed from edit_fare.dart based on previous context? Verify filename.

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
  late final PlazaFareViewModel _viewModel;
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
    _viewModel = Provider.of<PlazaFareViewModel>(context, listen: false);
    developer.log('PlazaFaresListScreen initState for Plaza: ${widget.plaza.plazaName} (ID: ${widget.plaza.plazaId})', name: 'PlazaFaresList');

    // --- CHANGE HERE ---
    // Defer the initial data load until after the first frame build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        developer.log("Post frame callback: Calling _loadPlazaFaresData", name: "PlazaFaresList");
        _loadPlazaFaresData();
      } else {
        developer.log("Post frame callback: Widget unmounted, skipping _loadPlazaFaresData", name: "PlazaFaresList");
      }
    });
    // --- END CHANGE ---

    _searchController.addListener(_onSearchChanged);
    developer.log("PlazaFaresListScreen initState complete", name: "PlazaFaresList");
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
        _currentPage = 1;
        developer.log('Search query changed: $_searchQuery', name: 'PlazaFaresList');
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

  Future<void> _loadPlazaFaresData() async {
    developer.log("_loadPlazaFaresData called", name: "PlazaFaresList");
    if (!mounted) {
      developer.log("_loadPlazaFaresData: Widget unmounted at start.", name: "PlazaFaresList");
      return;
    }
    final plazaIdString = widget.plaza.plazaId;

    if (plazaIdString != null) {
      developer.log('Loading fares for Plaza ID (String): $plazaIdString', name: 'PlazaFaresList');
      // This fetchExistingFares call will now happen *after* the initial build
      // Its internal setLoadingFare(true) will be safe.
      await _viewModel.fetchExistingFares(plazaIdString);
      if (mounted) {
        _viewModel.setPlazaName(widget.plaza.plazaName);
      }
    } else {
      developer.log('CRITICAL ERROR: Plaza ID is null for ${widget.plaza.plazaName}. Cannot load fares.', name: 'PlazaFaresList');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).errorMissingPlazaId),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
    if (mounted) {
      developer.log("_loadPlazaFaresData complete. Resetting page.", name: "PlazaFaresList");
      // Reset page *after* data loading is complete (inside the async function)
      // No need for setState here if _currentPage is only used for calculations
      // If you need UI to react to page 1 *immediately* after load, use setState:
      setState(() {
        _currentPage = 1;
      });
    }
  }

  Future<void> _refreshData() async {
    developer.log('Refreshing plaza fares data...', name: 'PlazaFaresList');
    if (!mounted) return;
    await _loadPlazaFaresData();
  }

  // Filters the fares based on the search query
  List<PlazaFare> _getFilteredFares() {
    if (_viewModel.existingFares.isEmpty) {
      return [];
    }
    if (_searchQuery.isEmpty) {
      return _viewModel.existingFares;
    }
    return _viewModel.existingFares.where((fare) {
      // Ensure fields are not null before calling toLowerCase() or contains()
      final vehicleMatch = fare.vehicleType.toLowerCase().contains(_searchQuery);
      final fareTypeMatch = fare.fareType.toLowerCase().contains(_searchQuery);
      // Plaza ID is an int in the model, convert to string for search
      final idMatch = fare.plazaId.toString().contains(_searchQuery);
      // Fare Rate (optional search field)
      // final rateMatch = fare.fareRate.toStringAsFixed(2).contains(_searchQuery);

      return idMatch || vehicleMatch || fareTypeMatch /* || rateMatch */;
    }).toList();
  }

  // Handles page changes for pagination
  void _updatePage(int newPage) {
    final filteredFares = _getFilteredFares();
    // Use the mixin's updatePage method
    updatePage(newPage, filteredFares, (page) { // Pass total item count
      if (!mounted) return;
      setState(() => _currentPage = page);
      developer.log('Pagination: Page changed to $_currentPage', name: 'PlazaFaresList');
      // Scroll to top smoothly when page changes
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  // Builds the search input field area
  Widget _buildSearchField(S strings) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.95,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4), // Add some vertical margin
        elevation: Theme.of(context).cardTheme.elevation ?? 1.0, // Use theme elevation
        color: context.secondaryCardColor,
        shape: Theme.of(context).cardTheme.shape, // Use theme shape
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0), // Adjust padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomFormFields.searchFormField(
                controller: _searchController,
                hintText: strings.searchPlazaFareHint, // Use specific hint
                context: context,
              ),
              const SizedBox(height: 8),
              // Consider removing or simplifying the 'Last Updated' text if refresh is obvious
              Text(
                '${strings.labelLastUpdated}: ${DateTime.now().toString().substring(0, 16)}. ${strings.labelSwipeToRefresh}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.textSecondaryColor, // Use secondary text color
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Builds the UI shown when no fares are found or match the search
  Widget _buildEmptyState(S strings) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Add padding
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              // Use a more relevant icon like list or search off
              _searchQuery.isEmpty ? Icons.list_alt_outlined : Icons.search_off_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              strings.noFaresFoundLabel, // Generic "not found" label
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: context.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isEmpty
                  ? strings.noFaresForPlazaMessage // Pass plaza name
                  : strings.noFaresMatchSearchMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith( // Use bodyMedium for better readability
                color: context.textSecondaryColor, // Use secondary color
              ),
              textAlign: TextAlign.center,
            ),
            if (_searchQuery.isNotEmpty) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  _searchController.clear(); // This triggers the listener -> _onSearchChanged
                },
                child: Text(
                  strings.clearSearchLabel,
                  style: const TextStyle(color: AppColors.primary), // Use AppColors
                ),
              ),
            ],
            // Optionally add a button to navigate to "Add Fare" directly from empty state
            if (_searchQuery.isEmpty) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: Text(strings.buttonAddFare), // Add this string
                onPressed: _navigateToAddFare,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
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
    return ListView.builder(
      // No controller needed here, it's just a placeholder
      physics: const NeverScrollableScrollPhysics(), // Disable scrolling for shimmer
      itemCount: itemsPerPage, // Show a fixed number of shimmer items
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Theme.of(context).brightness == Brightness.light
              ? AppColors.shimmerBaseLight
              : AppColors.shimmerBaseDark,
          highlightColor: Theme.of(context).brightness == Brightness.light
              ? AppColors.shimmerHighlightLight
              : AppColors.shimmerHighlightDark,
          child: Padding( // Add padding around shimmer card
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Card(
              elevation: 0, // Shimmer card might not need elevation
              shape: Theme.of(context).cardTheme.shape,
              child: Container( // Use container for defined height
                height: 120, // Adjust height to match actual card
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Shimmer for Icon/Image placeholder (optional)
                    /*
                    Container(
                      width: 50, // Adjust size
                      height: 50,
                      decoration: BoxDecoration(
                         color: context.backgroundColor, // Use background color for placeholder
                         borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(width: 16),
                    */
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceAround, // Space out shimmer elements
                        children: [
                          Container(width: double.infinity, height: 20, color: context.backgroundColor), // Fare Type/Vehicle
                          const SizedBox(height: 8),
                          Container(width: 150, height: 16, color: context.backgroundColor), // Rate
                          const SizedBox(height: 8),
                          Container(width: 200, height: 16, color: context.backgroundColor), // Dates
                        ],
                      ),
                    ),
                    // Shimmer for chevron/arrow placeholder (optional)
                    /*
                    Container(
                       width: 24,
                       height: 24,
                       color: context.backgroundColor,
                    )
                    */
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

  // Inside _PlazaFaresListScreenState

  void _navigateToAddFare() async {
    developer.log('Navigating to AddFareScreen', name: 'PlazaFaresList');
    // NOTE: We are NOT passing the view model instance here.
    // AddFareScreen will read it from the Provider context.
    final added = await Navigator.push(
      context,
      MaterialPageRoute(
        // Pass the selected plaza data
        builder: (context) => AddFareScreen(selectedPlaza: widget.plaza),
      ),
    );
    if (added == true && mounted) {
      developer.log('Returned from AddFareScreen with success, refreshing data.', name: 'PlazaFaresList');
      await _refreshData();
    }
  }

  void _navigateToEditFare(PlazaFare fare) async {
    developer.log('Attempting to navigate to EditFareScreen for Fare ID: ${fare.fareId}', name: 'PlazaFaresList');
    final String? plazaIdString = widget.plaza.plazaId;

    if (plazaIdString == null) {
      developer.log('Navigation failed: Plaza ID is null.', name: 'PlazaFaresList');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.of(context).errorMissingPlazaId), backgroundColor: Colors.red));
      }
      return;
    }

    final int? plazaIdInt = int.tryParse(plazaIdString);

    if (plazaIdInt == null) {
      developer.log('Navigation failed: Could not parse Plaza ID "$plazaIdString" to int.', name: 'PlazaFaresList');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.of(context).errorInvalidPlazaIdFormat), backgroundColor: Colors.red)); // Add string
      }
      return;
    }

    if (fare.fareId == null) {
      developer.log('Navigation failed: Fare ID is null.', name: 'PlazaFaresList');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.of(context).errorMissingFareId), backgroundColor: Colors.red)); // Add string
      }
      return;
    }

    developer.log('Navigating to EditFareScreen with Fare ID: ${fare.fareId}, Plaza ID (int): $plazaIdInt', name: 'PlazaFaresList');
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        // Ensure ModifyViewFareScreen (or EditFareScreen) expects fareId (int) and plazaId (int)
        builder: (context) => EditFareScreen(fareId: fare.fareId!, plazaId: plazaIdInt),
      ),
    );

    if (updated == true && mounted) { // Check mounted status after async gap
      developer.log('Returned from EditFareScreen with success, refreshing data.', name: 'PlazaFaresList');
      await _refreshData();
    }
  }


  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    final strings = S.of(context); // Localizations instance

    return Consumer<PlazaFareViewModel>(
      builder: (context, viewModel, _) {
        // Get filtered list based on current search query
        final filteredFares = _getFilteredFares();
        // Calculate total pages based on filtered list
        final totalPages = getTotalPages(filteredFares); // Use mixin method
        // Get the items for the current page
        final paginatedFares = getPaginatedItems(filteredFares, _currentPage); // Use mixin method

        // Determine if the view should show loading, empty, or list state
        final bool showLoading = viewModel.isLoading;
        final bool showEmpty = !showLoading && paginatedFares.isEmpty;
        final bool showList = !showLoading && paginatedFares.isNotEmpty;
        final bool showPagination = showList && totalPages > 1;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: CustomAppBar.appBarWithNavigation(
            // Use a more specific title including the plaza name
            screenTitle: strings.titleFaresForPlaza, // Add this string
            onPressed: () => Navigator.pop(context),
            darkBackground: Theme.of(context).brightness == Brightness.dark,
            context: context,
          ),
          body: Column(
            children: [
              const SizedBox(height: 4), // Reduced top spacing
              Padding( // Add padding around search field
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: _buildSearchField(strings),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshData,
                  color: Theme.of(context).colorScheme.primary,
                  child: Stack( // Use Stack to overlay shimmer if needed
                    children: [
                      // Use ListView.builder for potentially long lists
                      ListView.builder(
                        controller: _scrollController, // Attach scroll controller
                        physics: const AlwaysScrollableScrollPhysics(), // Ensure refresh indicator works even if list fits screen
                        // Add padding to the list itself
                        padding: const EdgeInsets.only(top: 8, bottom: 8, left: 8, right: 8),
                        // Item count depends on the state
                        itemCount: showLoading ? itemsPerPage : (showEmpty ? 1 : paginatedFares.length),
                        itemBuilder: (context, index) {
                          if (showLoading) {
                            // Wrap shimmer in Padding if not done inside _buildShimmerList
                            return _buildShimmerList(); // This already returns a list view builder content
                          } else if (showEmpty) {
                            // Display empty state centered within the list area
                            return SizedBox(
                              height: MediaQuery.of(context).size.height * 0.6, // Ensure it takes enough space
                              child: _buildEmptyState(strings),
                            );
                          } else { // showList
                            final fare = paginatedFares[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: CustomCards.fareCard(
                                fare: fare,
                                plazaName: widget.plaza.plazaName,
                                onTap: () => _navigateToEditFare(fare),
                                context: context,
                              ),
                            );
                          }
                        },
                      ),
                      // Alternative Shimmer display (if not using ListView builder count for shimmer)
                      // if (showLoading)
                      //    Positioned.fill(child: _buildShimmerList()),
                    ],
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            heroTag: 'addFareFAB', // Ensure unique HeroTag
            backgroundColor: AppColors.primary,
            onPressed: _navigateToAddFare,
            tooltip: strings.buttonAddFare, // Add tooltip
            child: const Icon(Icons.add, color: Colors.white),
          ),
          bottomNavigationBar: Container(
            color: Theme.of(context).scaffoldBackgroundColor, // Match background
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0), // Adjust padding
            child: SafeArea( // Ensure controls are within safe area
              child: PaginationControls(
                currentPage: _currentPage,
                totalPages: totalPages,
                onPageChange: _updatePage,
              ),
            ),
          )
        );
      },
    );
  }
}