import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/config/app_routes.dart';
import 'package:merchant_app/config/app_strings.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:merchant_app/utils/components/button.dart';
import 'package:merchant_app/utils/components/form_field.dart';
import 'package:provider/provider.dart';
import 'package:merchant_app/services/storage/secure_storage_service.dart';
import 'package:shimmer/shimmer.dart';
import '../../utils/components/card.dart';
import '../../utils/components/pagination_controls.dart';
import '../../viewmodels/plaza/plaza_viewmodel.dart';
import '../../utils/exceptions.dart';

class PlazaListScreen extends StatefulWidget {
  final bool modifyPlazaInfo;

  const PlazaListScreen({super.key, required this.modifyPlazaInfo});

  @override
  State<PlazaListScreen> createState() => _PlazaListScreenState();
}

class _PlazaListScreenState extends State<PlazaListScreen> with RouteAware {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final SecureStorageService _secureStorage = SecureStorageService();
  late PlazaViewModel _viewModel;
  late RouteObserver<ModalRoute> _routeObserver;
  String _searchQuery = '';
  int _currentPage = 1;
  static const int _itemsPerPage = 10;
  bool useIndividualShimmer = false;
  bool _isLoading = false;
  final customCacheManager = CacheManager(
    Config(
      'plazaImageCache',
      stalePeriod: const Duration(hours: 24),
      maxNrOfCacheObjects: 100,
    ),
  );

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<PlazaViewModel>(context, listen: false);
    _loadInitialData();

    _searchController.addListener(() {
      setState(() => _currentPage = 1);
      _handleSearch();
    });
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    final userId = await _secureStorage.getUserId();
    if (userId != null) {
      await _viewModel.fetchUserPlazas(userId);
      await _fetchImagesForCurrentPage();
      await Future.delayed(const Duration(seconds: 3));
    }
    setState(() => _isLoading = false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _routeObserver = Provider.of<RouteObserver<ModalRoute>>(context);
    _routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    _routeObserver.unsubscribe(this);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didPopNext() => _refreshData();

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    await customCacheManager.emptyCache();
    _viewModel.clearPlazaImages();
    final userId = await _secureStorage.getUserId();
    if (userId != null) {
      await _viewModel.fetchUserPlazas(userId);
      await _fetchImagesForCurrentPage();
      await Future.delayed(const Duration(seconds: 3));
    }
    setState(() => _isLoading = false);
  }

  void _handleSearch() {
    _searchQuery = _searchController.text.toLowerCase();
    _fetchImagesForCurrentPage();
  }

  Future<void> _fetchImagesForCurrentPage() async {
    final filteredPlazas = _getFilteredPlazas(_viewModel.userPlazas);
    final paginatedPlazas = _getPaginatedPlazas(filteredPlazas);
    final plazaIds = paginatedPlazas.map((p) => p.plazaId.toString()).toList();
    await _viewModel.fetchPlazaImages(plazaIds);
  }

  List<dynamic> _getFilteredPlazas(List<dynamic> plazas) {
    if (_searchQuery.isEmpty) return plazas;
    return plazas.where((plaza) {
      return plaza.plazaId.toString().contains(_searchQuery) ||
          plaza.plazaName.toLowerCase().contains(_searchQuery) ||
          plaza.address.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  List<dynamic> _getPaginatedPlazas(List<dynamic> filteredPlazas) {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    return endIndex > filteredPlazas.length
        ? filteredPlazas.sublist(startIndex)
        : filteredPlazas.sublist(startIndex, endIndex);
  }

  void _updatePage(int newPage) {
    final filteredPlazas = _getFilteredPlazas(_viewModel.userPlazas);
    final totalPages = (filteredPlazas.length / _itemsPerPage).ceil();
    if (newPage < 1 || newPage > totalPages) return;
    setState(() => _currentPage = newPage);
    _fetchImagesForCurrentPage();
  }

  Widget _buildSearchField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomFormFields.searchFormField(
          controller: _searchController,
          hintText: 'Search by plaza name or location...',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Text(
            'Last updated: ${DateTime.now().toString().substring(0, 16)}. Swipe down to refresh.',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_city_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No plazas found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'There are no plazas available'
                : 'No plazas match your search criteria',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => _searchController.clear(),
              child: const Text('Clear Search'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildShimmerList() {
    return Scrollbar(
      controller: _scrollController,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: _itemsPerPage,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: SizedBox(
                height: 132,
                child: Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  direction: ShimmerDirection.ltr,
                  period: const Duration(milliseconds: 1200),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: 120,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: 180,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(PlazaViewModel viewModel) {
    String errorTitle = 'Unable to Load Plazas';
    String errorMessage = 'Something went wrong. Please try again.';
    String? errorDetails;

    final error = viewModel.error;
    if (error != null) {
      developer.log('Error occurred: $error');

      if (error is NoInternetException) {
        errorTitle = 'No Internet Connection';
        errorMessage = 'Please check your internet connection and try again.';
      } else if (error is RequestTimeoutException) {
        errorTitle = 'Request Timed Out';
        errorMessage = 'The server is taking too long to respond. Please try again later.';
      } else if (error is HttpException) {
        final statusCode = error.statusCode;
        final serverMessage = error.serverMessage ?? 'No additional details provided';

        errorTitle = statusCode != null ? 'Error $statusCode' : 'Server Error';
        errorMessage = error.toString().split(':').last.trim();

        switch (statusCode) {
          case 502:
            errorTitle = 'Server Unavailable (502)';
            errorMessage = 'We couldn’t connect to the plaza service.';
            errorDetails = serverMessage.isNotEmpty
                ? serverMessage
                : 'This might be a temporary server issue.';
            break;
          case 404:
            errorMessage = 'Plazas not found.';
            errorDetails = 'No plazas available or invalid request.';
            break;
          default:
            errorDetails = serverMessage;
        }
      } else if (error is PlazaException) {
        errorTitle = 'Plaza Error';
        errorMessage = error.toString().split(':').last.trim();
        errorDetails = error.serverMessage ?? 'No additional details provided';
      } else {
        errorMessage = error.toString();
        errorDetails = 'An unexpected error occurred. Please try again later.';
      }
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              errorTitle,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            if (errorDetails != null) ...[
              const SizedBox(height: 8),
              Text(
                errorDetails,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _refreshData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlazaViewModel>(
      builder: (context, viewModel, _) {
        final filteredPlazas = _getFilteredPlazas(viewModel.userPlazas);
        final totalPages = (filteredPlazas.length / _itemsPerPage).ceil();
        final paginatedPlazas = _getPaginatedPlazas(filteredPlazas);
        final showPagination = filteredPlazas.isNotEmpty;

        return Scaffold(
          backgroundColor: AppColors.lightThemeBackground,
          appBar: CustomAppBar.appBarWithNavigationAndActions(
            screenTitle: AppStrings.titlePlazas,
            onPressed: () => Navigator.pop(context),
            darkBackground: false,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: CustomButtons.downloadIconButton(
                  onPressed: () {
                    developer.log('Download button pressed');
                    /* Handle download */
                  },
                  darkBackground: false,
                ),
              )
            ],
          ),
          body: viewModel.error != null
              ? _buildErrorState(viewModel)
              : Column(
            children: [
              _buildSearchField(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshData,
                  child: _isLoading && !useIndividualShimmer
                      ? _buildShimmerList()
                      : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    controller: _scrollController,
                    itemCount: paginatedPlazas.isEmpty ? 1 : paginatedPlazas.length,
                    itemBuilder: (context, index) {
                      if (paginatedPlazas.isEmpty) {
                        return _buildEmptyState();
                      } else {
                        final plaza = paginatedPlazas[index];
                        final imageUrl = viewModel.plazaImages[plaza.plazaId.toString()];
                        return KeyedSubtree(
                          key: ValueKey(plaza.plazaId),
                          child: CustomCards.plazaCard(
                            imageUrl: imageUrl,
                            plazaName: plaza.plazaName,
                            plazaId: plaza.plazaId,
                            location: plaza.address,
                            onTap: () {
                              developer.log('Plaza card tapped: ${plaza.plazaId}');
                              if (widget.modifyPlazaInfo) {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.plazaInfo,
                                  arguments: plaza.plazaId,
                                );
                              } else {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.plazaFaresList,
                                  arguments: plaza,
                                );
                              }
                            },
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: showPagination
              ? Container(
            color: AppColors.lightThemeBackground,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: PaginationControls(
                  currentPage: _currentPage,
                  totalPages: totalPages,
                  onPageChange: _updatePage,
                ),
              ),
            ),
          )
              : null,
        );
      },
    );
  }
}