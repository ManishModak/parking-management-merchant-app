import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/config/app_theme.dart';
import 'package:merchant_app/services/storage/secure_storage_service.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:merchant_app/utils/components/button.dart';
import 'package:merchant_app/utils/components/form_field.dart';
import 'package:merchant_app/utils/components/pagination_controls.dart';
import 'package:merchant_app/viewmodels/user_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../config/app_config.dart';
import '../../generated/l10n.dart';
import '../../models/user_model.dart';
import '../../services/utils/pdf_export_service.dart';
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
  final Set<String> _selectedRoles = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<UserViewModel>(context, listen: false);
    developer.log('UserListScreen initialized', name: 'UserList');
    _loadInitialData();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
        _currentPage = 1;
        developer.log('Search query updated: $_searchQuery', name: 'UserList');
      });
    });
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final userId = await _secureStorage.getUserId();
    if (userId != null) {
      developer.log('Loading initial user list for userId: $userId', name: 'UserList');
      await _viewModel.fetchUserList(userId);
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
    final userId = await _secureStorage.getUserId();
    if (userId != null) {
      developer.log('Refreshing user list for userId: $userId', name: 'UserList');
      await _viewModel.fetchUserList(userId);
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  List<User> _getFilteredUsers(List<User> users) {
    return users.where((user) {
      final matchesSearch = _searchQuery.isEmpty ||
          user.id.toString().contains(_searchQuery) ||
          user.name.toLowerCase().contains(_searchQuery) ||
          user.role.toLowerCase().contains(_searchQuery) ||
          user.mobileNumber.toLowerCase().contains(_searchQuery);

      final matchesRole = _selectedRoles.isEmpty || _selectedRoles.contains(user.role.toLowerCase());

      return matchesSearch && matchesRole;
    }).toList();
  }

  List<User> _getPaginatedUsers(List<User> filteredUsers) {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    return endIndex > filteredUsers.length
        ? filteredUsers.sublist(startIndex)
        : filteredUsers.sublist(startIndex, endIndex);
  }

  void _updatePage(int newPage) {
    final filteredUsers = _getFilteredUsers(_viewModel.operators);
    final totalPages = (filteredUsers.length / _itemsPerPage).ceil().clamp(1, double.infinity).toInt();
    if (newPage < 1 || newPage > totalPages) return;
    setState(() => _currentPage = newPage);
    developer.log('Page updated to: $_currentPage', name: 'UserList');
  }

  Widget _buildSearchField(S strings) {
    return SizedBox(
      width: AppConfig.deviceWidth * 0.95,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: Theme.of(context).cardTheme.elevation,
        color: context.cardColor,
        shape: Theme.of(context).cardTheme.shape,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomFormFields.searchFormField(
                controller: _searchController,
                hintText: strings.hintSearchUsers,
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
    final selectedFilters = _selectedRoles.map((r) => '${strings.labelRole}: ${r.capitalize()}').toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
        child: Row(
          children: [
            _buildMoreFiltersChip(strings),
            if (selectedFilters.isNotEmpty) ...[
              const SizedBox(width: 8),
              ...selectedFilters.map((filter) => Container(
                margin: const EdgeInsets.only(right: 8),
                child: Chip(
                  label: Text(filter),
                  onDeleted: () {
                    setState(() {
                      _selectedRoles.remove(filter.split(': ')[1].toLowerCase());
                    });
                  },
                  deleteIcon: const Icon(Icons.close, size: 16),
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  labelStyle: TextStyle(color: AppColors.primary),
                  deleteIconColor: AppColors.primary,
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMoreFiltersChip(S strings) {
    final hasActiveFilters = _selectedRoles.isNotEmpty;

    return GestureDetector(
      onTap: _showAllFiltersDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: hasActiveFilters ? AppColors.primary.withOpacity(0.1) : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.filter_list,
              color: hasActiveFilters ? AppColors.primary : Colors.grey,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              strings.filtersLabel,
              style: TextStyle(
                color: hasActiveFilters ? AppColors.primary : Colors.black87,
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
    final roles = _viewModel.operators
        .map((u) => u.role.toLowerCase())
        .where((role) => role.isNotEmpty)
        .toSet()
        .toList()
      ..sort((a, b) => a.compareTo(b));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              height: MediaQuery.of(context).size.height * 0.6,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      strings.advancedFiltersLabel,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: [
                        _buildFilterSection(
                          title: strings.labelRole,
                          options: roles.map((role) => {'key': role, 'label': role.capitalize()}).toList(),
                          selectedItems: _selectedRoles,
                          onChanged: (value, isSelected) {
                            setDialogState(() {
                              if (isSelected) {
                                _selectedRoles.add(value);
                              } else {
                                _selectedRoles.remove(value);
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
                                    _selectedRoles.clear();
                                  });
                                },
                                context: context)),
                        const SizedBox(width: 16),
                        Expanded(
                            child: CustomButtons.primaryButton(
                                height: 40,
                                text: strings.applyLabel,
                                context: context,
                                onPressed: () {
                                  setState(() {
                                    _currentPage = 1;
                                  });
                                  Navigator.pop(context);
                                })),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
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
                checkmarkColor: AppColors.primary,
                backgroundColor: Colors.grey[200],
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.primary : Colors.black87,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        const Divider(),
      ],
    );
  }

  Widget _buildUserCard(User user) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      elevation: 2,
      color: context.secondaryCardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(user.name),
        subtitle: Text('${user.email}\n${user.mobileNumber}'),
        trailing: Icon(Icons.chevron_right, color: Theme.of(context).iconTheme.color),
        onTap: () {
          developer.log('User card tapped: ${user.id}', name: 'UserList');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserInfoScreen(operatorId: user.id),
            ),
          );
        },
      ),
    );
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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 150, height: 18, color: context.backgroundColor),
                        const SizedBox(height: 4),
                        Container(width: 100, height: 14, color: context.backgroundColor),
                        const SizedBox(height: 4),
                        Container(width: 120, height: 14, color: context.backgroundColor),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(UserViewModel viewModel, S strings) {
    String errorTitle = strings.errorTitleDefault;
    String errorMessage = strings.errorMessageDefault;
    String? errorDetails;

    final error = viewModel.getError('general');
    if (error.isNotEmpty) {
      developer.log('Error occurred: $error', name: 'UserList');
      if (error.contains('No internet')) {
        errorTitle = strings.errorTitleNoInternet;
        errorMessage = strings.errorMessageNoInternet;
      } else if (error.contains('timed out')) {
        errorTitle = strings.errorTitleTimeout;
        errorMessage = strings.errorMessageTimeout;
      } else if (error.contains('ServerConnectionException') || error.contains('Connection refused')) {
        errorTitle = strings.errorTitleServer;
        errorMessage = strings.errorMessageServer;
      } else if (error.contains('HttpException')) {
        errorTitle = strings.errorTitleServer;
        errorMessage = error.split(':').last.trim();
        errorDetails = strings.errorDetailsUnexpected;
      } else {
        errorMessage = error.split(':').last.trim();
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
          CustomButtons.primaryButton(height: 40, width: 150, text: strings.buttonRetry, onPressed: _refreshData, context: context)
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    return Consumer<UserViewModel>(
      builder: (context, viewModel, _) {
        final filteredUsers = _getFilteredUsers(viewModel.operators);
        final totalPages = (filteredUsers.length / _itemsPerPage).ceil().clamp(1, double.infinity).toInt();
        final paginatedUsers = _getPaginatedUsers(filteredUsers);

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: CustomAppBar.appBarWithNavigationAndActions(
            screenTitle: strings.titleUsers,
            onPressed: () => Navigator.pop(context),
            darkBackground: Theme.of(context).brightness == Brightness.dark,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: CustomButtons.downloadIconButton(
                  onPressed: () async {
                    developer.log('Download button pressed', name: 'UserList');
                    try {
                      await PdfExportService.exportUserList(viewModel.operators);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(strings.messagePdfSuccess, style: TextStyle(color: context.textPrimaryColor)),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    } catch (e) {
                      developer.log('PDF export failed: $e', name: 'UserList', error: e);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${strings.messagePdfFailed}: $e', style: TextStyle(color: context.textPrimaryColor)),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
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
                          if (viewModel.getError('general').isNotEmpty && !_isLoading)
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.6,
                              child: _buildErrorState(viewModel, strings),
                            )
                          else if (filteredUsers.isEmpty && !_isLoading)
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.6,
                              child: Center(child: Text(strings.messageNoUsersFound)),
                            )
                          else if (!_isLoading)
                              ...paginatedUsers.map((user) => _buildUserCard(user)),
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

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}