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
import '../../utils/components/card.dart';
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
  Timer? _debounce;
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
    developer.log('PlazaListScreen initialized', name: 'PlazaList');
    _loadInitialData();
    _searchController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), () {
        setState(() {
          _searchQuery = _searchController.text.toLowerCase();
          _currentPage = 1;
        });
        _fetchImagesForCurrentPage();
      });
    });
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final userId = await _secureStorage.getUserId();
    if (userId != null) {
      developer.log('Loading initial plaza list for userId: $userId', name: 'PlazaList');
      await _viewModel.fetchUserPlazas(userId);
      await _fetchImagesForCurrentPage();
    }
    if (mounted) {
      setState(() => _isLoading = false);
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
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didPopNext() => _refreshData();

  Future<void> _refreshData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    await customCacheManager.emptyCache();
    _viewModel.clearPlazaImages();
    final userId = await _secureStorage.getUserId();
    if (userId != null) {
      developer.log('Refreshing plaza list for userId: $userId', name: 'PlazaList');
      await _viewModel.fetchUserPlazas(userId);
      await _fetchImagesForCurrentPage();
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
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
    final totalPages = (filteredPlazas.length / _itemsPerPage).ceil().clamp(1, double.infinity).toInt();
    if (newPage < 1 || newPage > totalPages) return;
    setState(() => _currentPage = newPage);
    developer.log('Page updated to: $_currentPage', name: 'PlazaList');
    _fetchImagesForCurrentPage();
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
                hintText: strings.hintSearchPlazas, // Assuming this exists in l10n
                context: context,
              ),
              const SizedBox(height: 8),
              Text(
                '${strings.labelLastUpdated}: ${DateTime.now().toString().substring(0, 16)}. ${strings.labelSwipeToRefresh}',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChipsRow(S strings) {
    // Placeholder for filters (not implemented in original PlazaListScreen)
    return const SizedBox.shrink(); // Add filter logic if needed later
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _itemsPerPage,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: AppColors.shimmerBaseLight,
          highlightColor: AppColors.shimmerHighlightLight,
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
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(PlazaViewModel viewModel, S strings) {
    String errorTitle = strings.errorTitleDefault;
    String errorMessage = strings.errorMessageDefault;
    String? errorDetails;

    final error = viewModel.error;
    if (error != null) {
      developer.log('Error occurred: $error', name: 'PlazaList');
      if (error is NoInternetException) {
        errorTitle = strings.errorTitleNoInternet;
        errorMessage = strings.errorMessageNoInternet;
      } else if (error is RequestTimeoutException) {
        errorTitle = strings.errorTitleTimeout;
        errorMessage = strings.errorMessageTimeout;
      } else if (error is HttpException) {
        errorTitle = strings.errorTitleServer;
        errorMessage = error.serverMessage ?? strings.errorMessageServer;
        errorDetails = strings.errorDetailsUnexpected;
      } else if (error.toString().contains('ServerConnectionException') || error.toString().contains('Connection refused')) {
        errorTitle = strings.errorTitleServer;
        errorMessage = strings.errorMessageServer;
      } else {
        errorMessage = error.toString().split(':').last.trim();
        errorDetails = strings.errorDetailsUnexpected;
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(errorMessage, style: const TextStyle(fontSize: 16), textAlign: TextAlign.center),
          ),
          if (errorDetails != null) ...[
            const SizedBox(height: 8),
            Text(errorDetails, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          ],
          const SizedBox(height: 24),
          CustomButtons.primaryButton(height: 40, width: 150,text: strings.buttonRetry, onPressed: _refreshData, context: context)
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    return Consumer<PlazaViewModel>(
      builder: (context, viewModel, _) {
        final filteredPlazas = _getFilteredPlazas(viewModel.userPlazas);
        final totalPages = (filteredPlazas.length / _itemsPerPage).ceil().clamp(1, double.infinity).toInt();
        final paginatedPlazas = _getPaginatedPlazas(filteredPlazas);

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
                  child: Stack(
                    children: [
                      ListView(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: 8,),
                          if (viewModel.error != null && !_isLoading)
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: _buildErrorState(viewModel, strings),
                            )
                          else if (filteredPlazas.isEmpty && !_isLoading)
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.6,
                              child: Center(child: Text(strings.messageNoPlazasFound)), // Assuming this exists
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
                                    developer.log('Plaza card tapped: ${plaza.plazaId}', name: 'PlazaList');
                                    Navigator.pushNamed(
                                      context,
                                      widget.modifyPlazaInfo ? AppRoutes.plazaInfo : AppRoutes.plazaFaresList,
                                      arguments: widget.modifyPlazaInfo ? plaza.plazaId : plaza,
                                    );
                                  },
                                  context: context,
                                );
                              }),
                        ],
                      ),
                      if (_isLoading) Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: _buildShimmerList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
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