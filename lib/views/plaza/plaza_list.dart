import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/config/app_routes.dart';
import 'package:merchant_app/config/app_strings.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:merchant_app/utils/components/button.dart';
import 'package:merchant_app/utils/components/card.dart';
import 'package:merchant_app/utils/components/form_field.dart';
import 'package:merchant_app/utils/screens/loading_screen.dart';
import 'package:merchant_app/viewmodels/plaza_viewmodel/plaza_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:merchant_app/services/secure_storage_service.dart';

class PlazaListScreen extends StatefulWidget {
  const PlazaListScreen({super.key});

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
    final userId = await _secureStorage.getUserId();
    if (userId != null) {
      await _viewModel.fetchUserPlazas(userId);
      await _fetchImagesForCurrentPage();
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
    _routeObserver.unsubscribe(this);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didPopNext() => _refreshData();

  Future<void> _refreshData() async {
    final userId = await _secureStorage.getUserId();
    if (userId != null) {
      await _viewModel.fetchUserPlazas(userId);
      await _fetchImagesForCurrentPage();
    }
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

  Widget _buildPaginationControls(int currentPage, int totalPages) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.first_page),
            onPressed: currentPage > 1 ? () => _updatePage(1) : null,
            color: AppColors.primary,
            tooltip: 'First page',
          ),
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: currentPage > 1 ? () => _updatePage(currentPage - 1) : null,
            color: AppColors.primary,
            tooltip: 'Previous page',
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '$currentPage / $totalPages',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: currentPage < totalPages ? () => _updatePage(currentPage + 1) : null,
            color: AppColors.primary,
            tooltip: 'Next page',
          ),
          IconButton(
            icon: const Icon(Icons.last_page),
            onPressed: currentPage < totalPages ? () => _updatePage(totalPages) : null,
            color: AppColors.primary,
            tooltip: 'Last page',
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomFormFields.searchFormField(
          controller: _searchController,
          hintText: 'Search by plaza name or location...',
        ),
        if (_searchQuery.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 4.0),
            child: Text(
              'Searching for: "$_searchQuery"',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlazaViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.isLoading) return const LoadingScreen();
        if (viewModel.error != null) return _buildErrorState(viewModel);

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
                  onPressed: () {/* Handle download */},
                  darkBackground: false,
                ),
              )
            ],
          ),
          body: Column(
            children: [
              _buildSearchField(),
              Expanded(
                child: Scrollbar(
                  controller: _scrollController,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: paginatedPlazas.length,
                    cacheExtent: 100.0,
                    itemBuilder: (context, index) {
                      final plaza = paginatedPlazas[index];
                      final imageUrl = viewModel.plazaImages[plaza.plazaId.toString()] ?? '';
                      return KeyedSubtree(
                        key: ValueKey(plaza.plazaId),
                        child: CustomCards.plazaCard(
                          imageUrl: imageUrl,
                          plazaName: plaza.plazaName,
                          plazaId: plaza.plazaId,
                          location: plaza.address,
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.plazaInfo,
                            arguments: plaza.plazaId,
                          ),
                        ),
                      );
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
              child: _buildPaginationControls(_currentPage, totalPages),
            ),
          )
              : null,
        );
      },
    );
  }

  Widget _buildErrorState(PlazaViewModel viewModel) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(viewModel.error!),
            ElevatedButton(
              onPressed: _refreshData,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}