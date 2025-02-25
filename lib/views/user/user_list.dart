import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/config/app_strings.dart';
import 'package:merchant_app/services/storage/secure_storage_service.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:merchant_app/utils/components/button.dart';
import 'package:merchant_app/utils/components/card.dart';
import 'package:merchant_app/utils/components/form_field.dart';
import 'package:merchant_app/viewmodels/user_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../services/utils/pdf_export_service.dart';
import 'user_info.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final _secureStorage = SecureStorageService();
  late final UserViewModel _viewModel;
  String _searchQuery = '';
  int _currentPage = 1;
  static const int _itemsPerPage = 10;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<UserViewModel>(context, listen: false);
    _loadInitialData();

    _searchController.addListener(() {
      setState(() => _currentPage = 1);
      _handleSearch();
    });
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    // Add artificial delay for testing (3 seconds)
    await Future.delayed(const Duration(seconds: 3));
    final userId = await _secureStorage.getUserId();
    if (userId != null) {
      await _viewModel.fetchUserList(userId);
    }
    setState(() => _isLoading = false);
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    // Add artificial delay for testing (3 seconds)
    await Future.delayed(const Duration(seconds: 3));
    _viewModel.clearUserImages(); // Clear cached user images
    final userId = await _secureStorage.getUserId();
    if (userId != null) {
      await _viewModel.fetchUserList(userId);
    }
    setState(() => _isLoading = false);
  }

  void _handleSearch() {
    setState(() => _searchQuery = _searchController.text.toLowerCase());
  }

  List<dynamic> _getFilteredUsers(List<dynamic> users) {
    if (_searchQuery.isEmpty) return users;
    return users.where((user) {
      return user.id.toString().contains(_searchQuery) ||
          user.name.toLowerCase().contains(_searchQuery) ||
          user.role.toLowerCase().contains(_searchQuery) ||
          user.mobileNumber.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  List<dynamic> _getPaginatedUsers(List<dynamic> filteredUsers) {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    return endIndex > filteredUsers.length
        ? filteredUsers.sublist(startIndex)
        : filteredUsers.sublist(startIndex, endIndex);
  }

  void _updatePage(int newPage) {
    final filteredUsers = _getFilteredUsers(_viewModel.operators);
    final totalPages = (filteredUsers.length / _itemsPerPage).ceil();
    if (newPage < 1 || newPage > totalPages) return;
    setState(() => _currentPage = newPage);
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
          ),
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: currentPage > 1 ? () => _updatePage(currentPage - 1) : null,
            color: AppColors.primary,
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('$currentPage / $totalPages',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.primary)),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: currentPage < totalPages ? () => _updatePage(currentPage + 1) : null,
            color: AppColors.primary,
          ),
          IconButton(
            icon: const Icon(Icons.last_page),
            onPressed: currentPage < totalPages ? () => _updatePage(totalPages) : null,
            color: AppColors.primary,
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
          hintText: 'Search by ID, name, role, or mobile number...',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 8),
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
            Icons.person_outline,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No users found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'There are no users available'
                : 'No users match your search criteria',
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
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                direction: ShimmerDirection.ltr,
                period: const Duration(milliseconds: 1200),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 150,
                              height: 18,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: 100,
                              height: 14,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: 120,
                              height: 14,
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
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightThemeBackground,
      appBar: CustomAppBar.appBarWithNavigationAndActions(
        screenTitle: AppStrings.titleUsers,
        onPressed: () => Navigator.pop(context),
        darkBackground: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: CustomButtons.downloadIconButton(
              onPressed: () async {
                try {
                  await PdfExportService.exportUserList(_viewModel.operators);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to export PDF: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              darkBackground: false,
            ),
          ),
        ],
      ),
      body: Consumer<UserViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(viewModel.error!),
                  ElevatedButton(onPressed: _refreshData, child: const Text('Retry')),
                ],
              ),
            );
          }
          final filteredUsers = _getFilteredUsers(viewModel.operators);
          final totalPages = (filteredUsers.length / _itemsPerPage).ceil();
          final paginatedUsers = _getPaginatedUsers(filteredUsers);
          final showPagination = filteredUsers.isNotEmpty;

          return Column(
            children: [
              _buildSearchField(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshData,
                  child: _isLoading
                      ? _buildShimmerList()
                      : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: paginatedUsers.isEmpty ? 1 : paginatedUsers.length,
                    itemBuilder: (context, index) {
                      if (paginatedUsers.isEmpty) {
                        return _buildEmptyState();
                      } else {
                        final user = paginatedUsers[index];
                        return CustomCards.operatorCard(
                          imageUrl: user.imageUrl,
                          operatorName: user.name,
                          role: user.role,
                          contactNumber: user.mobileNumber,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserInfoScreen(operatorId: user.id),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
              if (showPagination) _buildPaginationControls(_currentPage, totalPages),
            ],
          );
        },
      ),
    );
  }
}