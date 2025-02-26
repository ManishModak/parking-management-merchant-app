import 'dart:developer' as developer;
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
import '../../utils/components/pagination_controls.dart';
import '../../utils/exceptions.dart';
import 'user_info.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> with RouteAware {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final SecureStorageService _secureStorage = SecureStorageService();
  late UserViewModel _viewModel;
  late RouteObserver<ModalRoute> _routeObserver;
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
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
        _currentPage = 1;
      });
    });
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    final userId = await _secureStorage.getUserId();
    if (userId != null) {
      await _viewModel.fetchUserList(userId);
      await Future.delayed(const Duration(seconds: 2));
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
    final userId = await _secureStorage.getUserId();
    if (userId != null) {
      await _viewModel.fetchUserList(userId);
      await Future.delayed(const Duration(seconds: 2));
    }
    setState(() => _isLoading = false);
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

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomFormFields.searchFormField(
            controller: _searchController,
            hintText: 'Search by ID, name, role, or mobile number...',
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
          Icon(Icons.person_outline, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No users found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty ? 'There are no users available' : 'No users match your search criteria',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(height: 16),
            TextButton(onPressed: () => _searchController.clear(), child: const Text('Clear Search')),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 150, height: 18, color: Colors.white),
                          const SizedBox(height: 4),
                          Container(width: 100, height: 14, color: Colors.white),
                          const SizedBox(height: 4),
                          Container(width: 120, height: 14, color: Colors.white),
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

  Widget _buildErrorState(UserViewModel viewModel) {
    String errorTitle = 'Unable to Load Users';
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
            Text(errorDetails, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          ],
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _refreshData, child: const Text('Retry')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserViewModel>(
      builder: (context, viewModel, _) {
        final filteredUsers = _getFilteredUsers(viewModel.operators);
        final totalPages = (filteredUsers.length / _itemsPerPage).ceil().clamp(1, double.infinity).toInt();
        final paginatedUsers = _getPaginatedUsers(filteredUsers);

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
                    developer.log('Download button pressed');
                    try {
                      await PdfExportService.exportUserList(viewModel.operators);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to export PDF: $e'), backgroundColor: Colors.red),
                      );
                    }
                  },
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
                  child: _isLoading
                      ? _buildShimmerList()
                      : viewModel.error != null
                      ? SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: _buildErrorState(viewModel),
                  )
                      : filteredUsers.isEmpty
                      ? SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: _buildEmptyState(),
                  )
                      : ListView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: paginatedUsers.map((user) {
                      return CustomCards.operatorCard(
                        operatorName: user.name,
                        role: user.role,
                        contactNumber: user.mobileNumber,
                        onTap: () {
                          developer.log('User card tapped: ${user.id}');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => UserInfoScreen(operatorId: user.id)),
                          );
                        }, imageUrl: '',
                      );
                    }).toList(),
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