import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../config/app_colors.dart';
import '../../../generated/l10n.dart';
import '../../../models/plaza.dart';
import '../../../utils/components/appbar.dart';
import '../../../utils/components/form_field.dart';
import '../../../utils/components/pagination_controls.dart';
import '../../../utils/components/card.dart';
import '../../../viewmodels/plaza_fare_viewmodel.dart';
import 'add_fare.dart';
import 'modify_view_fare.dart';

class PlazaFaresListScreen extends StatefulWidget {
  final Plaza plaza;

  const PlazaFaresListScreen({
    super.key,
    required this.plaza,
  });

  @override
  State<PlazaFaresListScreen> createState() => _PlazaFaresListScreenState();
}

class _PlazaFaresListScreenState extends State<PlazaFaresListScreen> {
  late final PlazaFareViewModel _viewModel;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  int _currentPage = 1;
  static const int _itemsPerPage = 10;
  bool _isLoadingFares = false;

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<PlazaFareViewModel>(context, listen: false);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
        _currentPage = 1;
      });
    });
    _loadPlazaFaresData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPlazaFaresData() async {
    setState(() => _isLoadingFares = true);
    await Future.delayed(const Duration(seconds: 3)); // Optional delay for testing
    await _viewModel.fetchExistingFares(widget.plaza.plazaId!);
    setState(() => _isLoadingFares = false);
    _viewModel.setPlazaName(widget.plaza.plazaName);
  }

  void _updatePage(int newPage) {
    setState(() => _currentPage = newPage);
  }

  Widget _buildSearchField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomFormFields.searchFormField(
          controller: _searchController,
          hintText: 'Search by Plaza ID, Vehicle, or Fare Type...', context: context,
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
            Icons.info_outline,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No fares found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'There are no fares for this plaza'
                : 'No fares match your search criteria',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: _itemsPerPage,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 12), // Increased vertical margin
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            direction: ShimmerDirection.ltr,
            period: const Duration(milliseconds: 1200),
            child: Padding(
              padding: const EdgeInsets.all(20), // Increased padding
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.only(right: 80), // Increased padding for status
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 120, // Increased width
                                    height: 20, // Increased height
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: 6), // Increased spacing
                                  Container(
                                    width: 150, // Increased width
                                    height: 22, // Increased height
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              right: 0,
                              child: Container(
                                width: 80, // Increased width
                                height: 30, // Increased height
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16), // Increased spacing
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 100, // Increased width
                                    height: 16, // Increased height
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: 6), // Increased spacing
                                  Container(
                                    width: 85, // Increased width
                                    height: 18, // Increased height
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 100, // Increased width
                                    height: 16, // Increased height
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: 6), // Increased spacing
                                  Container(
                                    width: 85, // Increased width
                                    height: 18, // Increased height
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16), // Increased spacing
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 100, // Increased width
                                    height: 16, // Increased height
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: 6), // Increased spacing
                                  Container(
                                    width: 85, // Increased width
                                    height: 20, // Increased height
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 100, // Increased width
                                    height: 16, // Increased height
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: 6), // Increased spacing
                                  Container(
                                    width: 85, // Increased width
                                    height: 18, // Increased height
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 40, // Increased width
                    height: 30, // Increased height
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    return Consumer<PlazaFareViewModel>(
      builder: (context, viewModel, child) {
        final filteredFares = _searchQuery.isEmpty
            ? viewModel.existingFares
            : viewModel.existingFares.where((fare) {
          return fare.plazaId.toString().contains(_searchQuery) ||
              fare.vehicleType.toLowerCase().contains(_searchQuery) ||
              fare.fareType.toLowerCase().contains(_searchQuery);
        }).toList();

        final totalPages = (filteredFares.length / _itemsPerPage).ceil();
        int startIndex = (_currentPage - 1) * _itemsPerPage;
        int endIndex = startIndex + _itemsPerPage;
        if (endIndex > filteredFares.length) endIndex = filteredFares.length;
        final paginatedFares = startIndex < filteredFares.length
            ? filteredFares.sublist(startIndex, endIndex)
            : [];

        return Scaffold(
          backgroundColor: AppColors.lightThemeBackground,
          appBar: CustomAppBar.appBarWithNavigation(
            screenTitle: strings.titleModifyViewFareDetails,
            onPressed: () => Navigator.pop(context),
            darkBackground: true, context: context,
          ),
          body: Column(
            children: [
              _buildSearchField(),
              Expanded(
                child: _isLoadingFares
                    ? _buildShimmerList()
                    : paginatedFares.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: paginatedFares.length,
                  itemBuilder: (context, index) {
                    final fare = paginatedFares[index];
                    return CustomCards.fareCard(
                      fare: fare,
                      plazaName: widget.plaza.plazaName,
                      onTap: () async {
                        final updated = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditFareScreen(fareId: fare.fareId!),
                          ),
                        );
                        if (updated == true) await _loadPlazaFaresData();
                      }, context: context,
                    );
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            heroTag: 'addFareFAB',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddFareScreen(selectedPlaza: widget.plaza),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
          bottomNavigationBar: !_isLoadingFares && paginatedFares.isNotEmpty
              ? Container(
            color: AppColors.lightThemeBackground,
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