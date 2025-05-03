import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/config/app_routes.dart';
import 'package:merchant_app/config/app_theme.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:merchant_app/utils/components/button.dart';
import 'package:merchant_app/utils/components/form_field.dart';
import 'package:merchant_app/utils/components/pagination_controls.dart';
import 'package:provider/provider.dart';
import 'package:merchant_app/services/storage/secure_storage_service.dart';
import 'package:shimmer/shimmer.dart';
import '../../config/app_config.dart';
import '../../generated/l10n.dart';
import '../../models/plaza.dart';
import '../../utils/components/card.dart';
import '../../utils/components/pagination_mixin.dart';
import '../../utils/exceptions.dart';
import '../../viewmodels/plaza/plaza_list_viewmodel.dart';

class PlazaListScreen extends StatefulWidget {
  final bool modifyPlazaInfo;

  const PlazaListScreen({super.key, required this.modifyPlazaInfo});

  @override
  State<PlazaListScreen> createState() => _PlazaListScreenState();
}

class _PlazaListScreenState extends State<PlazaListScreen>
    with RouteAware, PaginatedListMixin<Plaza> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final SecureStorageService _secureStorage = SecureStorageService();
  late PlazaListViewModel _viewModel;
  late RouteObserver<ModalRoute> _routeObserver;
  String _searchQuery = '';
  int _currentPage = 1;
  Timer? _debounce;
  final customCacheManager = CacheManager(
    Config(
      'plazaImageCache',
      stalePeriod: const Duration(hours: 24),
      maxNrOfCacheObjects: 100,
    ),
  );

  // Filter-related state
  final Set<String> _selectedStatuses = {};

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<PlazaListViewModel>(context, listen: false);
    developer.log('PlazaListScreen initialized', name: 'PlazaList');
    _loadInitialData();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
        _currentPage = 1;
      });
      _fetchImagesForCurrentPage();
    });
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;
    final userData = await _secureStorage.getUserData();
    if (userData != null && userData['entityId'] != null) {
      final entityId = userData['entityId'].toString();
      developer.log('Loading initial plaza list for entityId: $entityId', name: 'PlazaList');
      // Fetch plazas
      await _viewModel.fetchUserPlazas(entityId);

      // Check if the fetch was successful before fetching images
      if (!mounted) return; // Check mount status again after async gap
      if (_viewModel.error == null) { // <--- Check for error
        await _fetchImagesForCurrentPage();
      } else {
        // Optionally log that images won't be fetched due to error
        developer.log('Skipping image fetch due to error in fetching plazas.', name: 'PlazaList');
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _routeObserver = Provider.of<RouteObserver<ModalRoute>>(context);
    _routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _routeObserver.unsubscribe(this);
    _scrollController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didPopNext() => _refreshData();

  Future<void> _refreshData() async {
    if (!mounted) return;
    await customCacheManager.emptyCache();
    _viewModel.clearPlazaImages();
    final userId = await _secureStorage.getUserId();
    if (userId != null) {
      developer.log('Refreshing plaza list for userId: $userId', name: 'PlazaList');
      // Fetch plazas
      await _viewModel.fetchUserPlazas(userId);

      // Check if the fetch was successful before fetching images
      if (!mounted) return; // Check mount status again after async gap
      if (_viewModel.error == null) { // <--- Check for error
        await _fetchImagesForCurrentPage();
      } else {
        developer.log('Skipping image fetch during refresh due to error in fetching plazas.', name: 'PlazaList');
      }
    }
  }

  Future<void> _fetchImagesForCurrentPage() async {
    // Add an early exit if there's already an error or plazas are empty
    if (_viewModel.error != null || _viewModel.userPlazas.isEmpty) {
      developer.log('Skipping _fetchImagesForCurrentPage: Error exists or no plazas.', name: 'PlazaList');
      return;
    }

    final filteredPlazas = _getFilteredPlazas(_viewModel.userPlazas);
    final paginatedPlazas = getPaginatedItems(filteredPlazas, _currentPage);
    final plazaIds = paginatedPlazas
        .map((p) => p.plazaId)
        .where((id) => id != null)
        .cast<String>()
        .toList();

    // Check again if there are actually IDs to fetch for the current page
    if (plazaIds.isNotEmpty) {
      await _viewModel.fetchPlazaImages(plazaIds);
    } else {
      developer.log('No plaza IDs found on current page to fetch images for.', name: 'PlazaList');
    }
  }

  List<Plaza> _getFilteredPlazas(List<Plaza> plazas) {
    return plazas.where((plaza) {
      final matchesSearch = _searchQuery.isEmpty ||
          (plaza.plazaId?.contains(_searchQuery) ?? false) ||
          plaza.plazaName!.toLowerCase().contains(_searchQuery) ||
          plaza.address!.toLowerCase().contains(_searchQuery);

      final matchesStatus = _selectedStatuses.isEmpty ||
          (plaza.plazaStatus != null && _selectedStatuses.contains(plaza.plazaStatus!.toLowerCase()));

      return matchesSearch && matchesStatus;
    }).toList();
  }

  void _updatePage(int newPage) {
    final filteredPlazas = _getFilteredPlazas(_viewModel.userPlazas);
    updatePage(newPage, filteredPlazas, (page) {
      setState(() => _currentPage = page);
      developer.log('Page updated to: $_currentPage', name: 'PlazaList');
      _fetchImagesForCurrentPage();
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  Widget _buildSearchField(S strings) {
    return SizedBox(
      width: AppConfig.deviceWidth * 0.95,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: Theme.of(context).cardTheme.elevation,
        color: context.secondaryCardColor,
        shape: Theme.of(context).cardTheme.shape,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomFormFields.searchFormField(
                controller: _searchController,
                hintText: strings.hintSearchPlazas,
                context: context,
              ),
              const SizedBox(height: 8),
              Text(
                '${strings.labelLastUpdated}: ${DateTime.now().toString().substring(0, 16)}. ${strings.labelSwipeToRefresh}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.textPrimaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChipsRow(S strings) {
    final selectedFilters = _selectedStatuses
        .map((s) => '${strings.labelStatus}: ${s.capitalize()}')
        .toList();
    final textColor = context.textPrimaryColor;

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Row(
            children: [
              if (selectedFilters.isNotEmpty) ...[
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedStatuses.clear();
                      _currentPage = 1;
                    });
                    _fetchImagesForCurrentPage();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: context.secondaryCardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      strings.resetAllLabel,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              _buildMoreFiltersChip(strings),
              if (selectedFilters.isNotEmpty) ...[
                const SizedBox(width: 8),
                ...selectedFilters.map((filter) => Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: Chip(
                    label: Text(filter),
                    onDeleted: () {
                      setState(() {
                        _selectedStatuses.remove(filter.split(': ')[1].toLowerCase());
                      });
                      _fetchImagesForCurrentPage();
                    },
                    deleteIcon: const Icon(Icons.close, size: 16),
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    labelStyle: TextStyle(color: textColor),
                    deleteIconColor: textColor,
                  ),
                )),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoreFiltersChip(S strings) {
    final hasActiveFilters = _selectedStatuses.isNotEmpty;
    final textColor = context.textPrimaryColor;

    return GestureDetector(
      onTap: _showAllFiltersDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: context.secondaryCardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.filter_list,
              color: textColor,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              strings.filtersLabel,
              style: TextStyle(
                color: textColor,
                fontWeight: hasActiveFilters ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAllFiltersDialog() {
    final strings = S.of(context);
    final statuses = _viewModel.userPlazas
        .map((p) => p.plazaStatus!.toLowerCase() ?? '')
        .where((plazaStatus) => plazaStatus.isNotEmpty)
        .toSet()
        .toList()
      ..sort((a, b) => a.compareTo(b));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.cardColor,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Container(
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              height: MediaQuery.of(context).size.height * 0.6,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.grey[300]
                            : Colors.grey[600],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      strings.advancedFiltersLabel,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimaryColor,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: [
                        _buildFilterSection(
                          title: strings.labelStatus,
                          options: statuses
                              .map((status) => {
                            'key': status,
                            'label': status.capitalize(),
                          })
                              .toList(),
                          selectedItems: _selectedStatuses,
                          onChanged: (value, isSelected) {
                            setDialogState(() {
                              if (isSelected) {
                                _selectedStatuses.add(value);
                              } else {
                                _selectedStatuses.remove(value);
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomButtons.secondaryButton(
                            height: 40,
                            text: strings.clearAllLabel,
                            onPressed: () {
                              setDialogState(() {
                                _selectedStatuses.clear();
                              });
                            },
                            context: context,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomButtons.primaryButton(
                            height: 40,
                            text: strings.applyLabel,
                            onPressed: () {
                              setState(() {
                                _currentPage = 1;
                              });
                              _fetchImagesForCurrentPage();
                              Navigator.pop(context);
                            },
                            context: context,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterSection({
    required String title,
    required List<Map<String, String>> options,
    required Set<String> selectedItems,
    required Function(String, bool) onChanged,
  }) {
    final textColor = context.textPrimaryColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((option) {
              final isSelected = selectedItems.contains(option['key']);
              return FilterChip(
                label: Text(option['label'] ?? ''),
                selected: isSelected,
                onSelected: (bool value) {
                  onChanged(option['key']!, value);
                },
                selectedColor: AppColors.primary.withOpacity(0.2),
                checkmarkColor: textColor,
                backgroundColor: context.secondaryCardColor,
                labelStyle: TextStyle(
                  color: isSelected ? textColor : Colors.grey[400],
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        Divider(
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.grey[300]
              : Colors.grey[600],
        ),
      ],
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: itemsPerPage,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Theme.of(context).brightness == Brightness.light
              ? AppColors.shimmerBaseLight
              : AppColors.shimmerBaseDark,
          highlightColor: Theme.of(context).brightness == Brightness.light
              ? AppColors.shimmerHighlightLight
              : AppColors.shimmerHighlightDark,
          child: Card(
            elevation: Theme.of(context).cardTheme.elevation,
            shape: Theme.of(context).cardTheme.shape,
            child: SizedBox(
              height: 132,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      color: context.backgroundColor,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 20,
                            color: context.backgroundColor,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 120,
                            height: 16,
                            color: context.backgroundColor,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 180,
                            height: 32,
                            color: context.backgroundColor,
                          ),
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

  Widget _buildErrorState(PlazaListViewModel viewModel, S strings) {
    String errorTitle = strings.errorTitleDefault;
    String errorMessage = strings.errorMessageDefault;

    final error = viewModel.error;
    if (error != null) {
      developer.log('Error occurred: $error', name: 'PlazaList');
      switch (error.runtimeType) {
        case NoInternetException _:
          errorTitle = strings.errorTitleNoInternet;
          errorMessage = strings.errorMessageNoInternet;
          break;
        case RequestTimeoutException _:
          errorTitle = strings.errorTitleTimeout;
          errorMessage = strings.errorMessageTimeout;
          break;
        case HttpException _:
          final httpError = error as HttpException;
          errorTitle = strings.errorTitleWithCode(httpError.statusCode ?? 0);
          errorMessage = httpError.message;
          break;
        case ServerConnectionException _:
          errorTitle = strings.errorTitleServer;
          errorMessage = strings.errorMessageServer;
          break;
        default:
          errorTitle = strings.errorUnexpected;
          errorMessage = error.toString().split(':').last.trim();
      }
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(errorTitle, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: context.textPrimaryColor)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(errorMessage, style: TextStyle(fontSize: 16, color: context.textPrimaryColor), textAlign: TextAlign.center),
          ),
          const SizedBox(height: 24),
          CustomButtons.primaryButton(
            height: 40,
            width: 150,
            text: strings.buttonRetry,
            onPressed: _refreshData,
            context: context,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    return Consumer<PlazaListViewModel>(
      builder: (context, viewModel, _) {
        final filteredPlazas = _getFilteredPlazas(viewModel.userPlazas);
        final totalPages = getTotalPages(filteredPlazas);
        final paginatedPlazas = getPaginatedItems(filteredPlazas, _currentPage);

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: CustomAppBar.appBarWithNavigationAndActions(
            screenTitle: strings.titlePlazas,
            onPressed: () => Navigator.pop(context),
            darkBackground: Theme.of(context).brightness == Brightness.dark,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: CustomButtons.downloadIconButton(
                  onPressed: () {
                    developer.log('Download button pressed', name: 'PlazaList');
                  },
                  darkBackground: Theme.of(context).brightness == Brightness.dark,
                  context: context,
                ),
              ),
            ],
            context: context,
          ),
          body: Column(
            children: [
              const SizedBox(height: 4),
              _buildFilterChipsRow(strings),
              _buildSearchField(strings),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshData,
                  color: Theme.of(context).colorScheme.primary,
                  child: Stack(
                    children: [
                      ListView(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          const SizedBox(height: 8),
                          if (viewModel.error != null && !viewModel.isLoading)
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: _buildErrorState(viewModel, strings),
                            )
                          else if (filteredPlazas.isEmpty && !viewModel.isLoading)
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.6,
                              child: Center(
                                child: Text(
                                  strings.messageNoPlazasFound,
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: context.textPrimaryColor,
                                  ),
                                ),
                              ),
                            )
                          else if (!viewModel.isLoading)
                              ...paginatedPlazas.map((plaza) {
                                final imageUrl = viewModel.plazaImages[plaza.plazaId];
                                return CustomCards.plazaCard(
                                  imageUrl: imageUrl,
                                  plazaName: plaza.plazaName!,
                                  plazaId: plaza.plazaId ?? '',
                                  location: plaza.address!,
                                  onTap: () {
                                    developer.log('Plaza card tapped: ${plaza.plazaId}', name: 'PlazaList');
                                    Navigator.pushNamed(
                                      context,
                                      widget.modifyPlazaInfo ? AppRoutes.plazaInfo : AppRoutes.plazaFaresList,
                                      arguments: widget.modifyPlazaInfo ? plaza.plazaId ?? '' : plaza,
                                    );
                                  },
                                  context: context,
                                );
                              }),
                        ],
                      ),
                      if (viewModel.isLoading)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: _buildShimmerList(),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: filteredPlazas.isNotEmpty && totalPages > 1 && !viewModel.isLoading
              ? Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            padding: const EdgeInsets.all(4.0),
            child: SafeArea(
              child: PaginationControls(
                currentPage: _currentPage,
                totalPages: totalPages,
                onPageChange: _updatePage,
              ),
            ),
          )
              : null,
        );
      },
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}