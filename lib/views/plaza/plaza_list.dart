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
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
        _currentPage = 1;
      });
      _fetchImagesForCurrentPage();
    });
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    final userId = await _secureStorage.getUserId();
    if (userId != null) {
      await _viewModel.fetchUserPlazas(userId);
      await _fetchImagesForCurrentPage();
      await Future.delayed(const Duration(seconds: 2)); // 2-second delay for shimmer testing
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
      await Future.delayed(const Duration(seconds: 2));
    }
    setState(() => _isLoading = false);
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomFormFields.searchFormField(
            controller: _searchController,
            hintText: 'Search by plaza name or location...',
          ),
          const SizedBox(height: 8),
          Text(
            'Last updated: ${DateTime.now().toString().substring(0, 16)}. Swipe down to refresh.',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
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
    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: _itemsPerPage,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
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
                        color: Colors.white,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(width: double.infinity, height: 20, color: Colors.white),
                            const SizedBox(height: 8),
                            Container(width: 120, height: 16, color: Colors.white),
                            const SizedBox(height: 8),
                            Container(width: 180, height: 32, color: Colors.white),
                          ],
                        ),
                      ),
                      Container(width: 24, height: 24, color: Colors.white),
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
        errorMessage = 'The server is taking too long to respond.';
      } else if (error is HttpException) {
        errorTitle = 'Error ${error.statusCode ?? 'Unknown'}';
        errorMessage = error.serverMessage ?? 'An error occurred.';
        errorDetails = error.toString();
      } else {
        errorMessage = error.toString();
        errorDetails = 'An unexpected error occurred.';
      }
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(errorTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(errorMessage, style: const TextStyle(fontSize: 16), textAlign: TextAlign.center),
          if (errorDetails != null) ...[
            const SizedBox(height: 8),
            Text(errorDetails!, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _refreshData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlazaViewModel>(
      builder: (context, viewModel, _) {
        final filteredPlazas = _getFilteredPlazas(viewModel.userPlazas);
        final totalPages = (filteredPlazas.length / _itemsPerPage).ceil().clamp(1, double.infinity).toInt();
        final paginatedPlazas = _getPaginatedPlazas(filteredPlazas);

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
                  onPressed: () => developer.log('Download button pressed'),
                  darkBackground: false,
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              _buildSearchField(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshData,
                  child: Stack(
                    children: [
                      ListView(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          if (viewModel.error != null)
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.6,
                              child: _buildErrorState(viewModel),
                            )
                          else if (filteredPlazas.isEmpty && !_isLoading)
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.6,
                              child: _buildEmptyState(),
                            )
                          else if (!_isLoading)
                              ...paginatedPlazas.map((plaza) {
                                final imageUrl = viewModel.plazaImages[plaza.plazaId.toString()];
                                return CustomCards.plazaCard(
                                  imageUrl: imageUrl,
                                  plazaName: plaza.plazaName,
                                  plazaId: plaza.plazaId,
                                  location: plaza.address,
                                  onTap: () {
                                    developer.log('Plaza card tapped: ${plaza.plazaId}');
                                    Navigator.pushNamed(
                                      context,
                                      widget.modifyPlazaInfo ? AppRoutes.plazaInfo : AppRoutes.plazaFaresList,
                                      arguments: widget.modifyPlazaInfo ? plaza.plazaId : plaza,
                                    );
                                  },
                                );
                              }).toList(),
                        ],
                      ),
                      if (_isLoading) _buildShimmerList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: Container(
            color: AppColors.lightThemeBackground,
            padding: const EdgeInsets.all(4.0),
            child: SafeArea(
              child: PaginationControls(
                currentPage: _currentPage,
                totalPages: totalPages,
                onPageChange: _updatePage,
              ),
            ),
          ),
        );
      },
    );
  }
}