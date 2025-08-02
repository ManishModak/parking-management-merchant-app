import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

// Adjust these paths to match your project structure
import 'package:merchant_app/models/plaza_fare.dart';
import 'package:merchant_app/config/app_colors.dart'; // For custom colors
import 'package:merchant_app/config/app_theme.dart'; // For theme extensions like context.secondaryCardColor
import 'package:merchant_app/generated/l10n.dart';
import 'package:merchant_app/models/plaza.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:merchant_app/utils/components/card.dart'; // Assuming CustomCards.fareCard is here
import 'package:merchant_app/utils/components/form_field.dart';
import 'package:merchant_app/utils/components/pagination_controls.dart';
import 'package:merchant_app/utils/components/pagination_mixin.dart';
import 'package:merchant_app/viewmodels/plaza_fare_viewmodel.dart';
import 'add_fare.dart';
import 'modify_view_fare.dart'; // Assuming this is your edit screen

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
    with PaginatedListMixin<PlazaFare> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';
  int _currentPage = 1;
  Timer? _debounce;

  @override
  int get itemsPerPage => 10;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadPlazaFaresData(context);
      }
    });

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Called when the search text changes to filter the list.
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
        _currentPage = 1; // Reset to first page on search
      });
    });
  }

  /// Fetches the initial fare data for the given plaza.
  Future<void> _loadPlazaFaresData(BuildContext context) async {
    final viewModel = context.read<PlazaFareViewModel>();
    final plazaIdString = widget.plaza.plazaId;

    if (plazaIdString != null) {
      await viewModel.fetchExistingFares(plazaIdString);
      if (mounted) {
        // This is a good place to set the plaza name if the ViewModel
        // needs it for display purposes elsewhere.
        viewModel.setPlazaName(widget.plaza.plazaName!);
      }
    } else {
      developer.log(
          'CRITICAL ERROR: Plaza ID is null for ${widget.plaza.plazaName}. Cannot load fares.',
          name: 'PlazaFaresList');
    }
    if (mounted) {
      setState(() => _currentPage = 1);
    }
  }

  /// Handles the pull-to-refresh action.
  Future<void> _refreshData() async {
    if (!mounted) return;
    // Clearing search on refresh is optional but often a good UX.
    _searchController.clear();
    await _loadPlazaFaresData(context);
  }

  // --- NAVIGATION HELPERS (CRITICAL ARCHITECTURAL UPDATE) ---

  /// Navigates to the AddFareScreen.
  /// This method creates a NEW, ISOLATED ViewModel for the AddFareScreen
  /// to prevent state conflicts between the list and add screens.
  void _navigateToAddFare() async {
    developer.log('Navigating to AddFareScreen', name: 'PlazaFaresList');

    final addedSuccessfully = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          // IMPORTANT: Create a new instance of the ViewModel here.
          create: (_) => PlazaFareViewModel(),
          child: AddFareScreen(selectedPlaza: widget.plaza), // Pass plaza data
        ),
      ),
    );

    // If the AddFareScreen pops with a 'true' result, it means the submission
    // was successful. This list should be refreshed to show the new data.
    if (addedSuccessfully == true && mounted) {
      developer.log(
          'Returned from AddFareScreen with success, refreshing data.',
          name: 'PlazaFaresList');
      await _refreshData();
    }
  }

  /// Navigates to the screen for editing an existing fare.
  void _navigateToEditFare(PlazaFare fare) async {
    // A similar pattern of creating an isolated ViewModel should be used here.
    final updatedSuccessfully = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (_) => PlazaFareViewModel(),
          child: EditFareScreen(
            // Pass the necessary IDs to the edit screen
            fareId: fare.fareId!,
            plazaId: int.parse(widget.plaza.plazaId!),
          ),
        ),
      ),
    );

    if (updatedSuccessfully == true && mounted) {
      await _refreshData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    return Consumer<PlazaFareViewModel>(
      builder: (context, viewModel, _) {
        // Apply search filter to the list from the ViewModel
        final filteredFares = viewModel.existingFares.where((fare) {
          if (_searchQuery.isEmpty) return true;
          return fare.vehicleType.toLowerCase().contains(_searchQuery) ||
              fare.fareType.toLowerCase().contains(_searchQuery) ||
              fare.fareRate.toString().contains(_searchQuery);
        }).toList();

        final totalPages = getTotalPages(filteredFares);
        final paginatedFares = getPaginatedItems(filteredFares, _currentPage);

        final bool showLoading = viewModel.isLoadingFare;
        final bool showEmpty = !showLoading && filteredFares.isEmpty;
        final bool showList = !showLoading && paginatedFares.isNotEmpty;
        final bool showPagination = showList && totalPages > 1;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: CustomAppBar.appBarWithNavigation(
            screenTitle: strings.titleFaresForPlaza(widget.plaza.plazaName!),
            onPressed: () => Navigator.pop(context),
            darkBackground: Theme.of(context).brightness == Brightness.dark,
            context: context,
          ),
          body: RefreshIndicator(
            onRefresh: _refreshData,
            color: Theme.of(context).colorScheme.primary,
            child: Column(
              children: [
                _buildSearchField(strings),
                Expanded(
                  child: showLoading
                      ? _buildShimmerList()
                      : showEmpty
                      ? _buildEmptyState(strings)
                      : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(
                        top: 8, bottom: 80, left: 8, right: 8),
                    itemCount: paginatedFares.length,
                    itemBuilder: (context, index) {
                      final fare = paginatedFares[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: CustomCards.fareCard(
                          fare: fare,
                          plazaName: widget.plaza.plazaName!,
                          onTap: () => _navigateToEditFare(fare),
                          context: context,
                          strings: strings,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            heroTag: 'addFareFAB_ListScreen',
            backgroundColor: AppColors.primary,
            onPressed: _navigateToAddFare, // Call the updated navigation method
            tooltip: strings.buttonAddFare,
            child: const Icon(Icons.add, color: Colors.white),
          ),
          bottomNavigationBar: showPagination
              ? Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            padding: const EdgeInsets.symmetric(
                vertical: 4.0, horizontal: 8.0),
            child: SafeArea(
              child: PaginationControls(
                currentPage: _currentPage,
                totalPages: totalPages,
                onPageChange: (newPage) => setState(() {
                  _currentPage = newPage;
                }),
              ),
            ),
          )
              : null,
        );
      },
    );
  }

  Widget _buildSearchField(S strings) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Card(
        color: context.secondaryCardColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: CustomFormFields.searchFormField(
            controller: _searchController,
            hintText: strings.searchPlazaFareHint,
            context: context,
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerList() {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).brightness == Brightness.light
          ? AppColors.shimmerBaseLight
          : AppColors.shimmerBaseDark,
      highlightColor: Theme.of(context).brightness == Brightness.light
          ? AppColors.shimmerHighlightLight
          : AppColors.shimmerHighlightDark,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemsPerPage,
        itemBuilder: (context, index) => Card(
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Container(height: 120, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildEmptyState(S strings) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _searchQuery.isEmpty
                    ? Icons.receipt_long_outlined
                    : Icons.search_off_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                _searchQuery.isEmpty
                    ? strings.noFaresForPlazaMessage
                    : strings.noFaresMatchSearchMessage,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (_searchQuery.isEmpty)
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: Text(strings.buttonAddFare),
                  onPressed: _navigateToAddFare,
                )
              else
                TextButton(
                  onPressed: () => _searchController.clear(),
                  child: Text(strings.clearSearchLabel),
                ),
            ],
          ),
        ),
      ),
    );
  }
}