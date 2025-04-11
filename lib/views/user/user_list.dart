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
import '../../utils/components/pagination_mixin.dart';
import '../../utils/exceptions.dart';
import 'user_info.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen>
    with RouteAware, PaginatedListMixin<User> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final SecureStorageService _secureStorage = SecureStorageService();
  late UserViewModel _viewModel;
  late RouteObserver<ModalRoute> _routeObserver;
  String _searchQuery = '';
  int _currentPage = 1;
  final Set<String> _selectedRoles = {};
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<UserViewModel>(context, listen: false);
    developer.log('UserListScreen initialized', name: 'UserList');
    _loadInitialData();
    _searchController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), () {
        setState(() {
          _searchQuery = _searchController.text.toLowerCase();
          _currentPage = 1;
          developer.log('Search query updated: $_searchQuery', name: 'UserList');
        });
      });
    });
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;
    final userData = await _secureStorage.getUserData();
    if (userData != null && userData['entityId'] != null) {
      final entityId = userData['entityId'].toString();
      developer.log('Loading initial user list for entityId: $entityId', name: 'UserList');
      await _viewModel.fetchUserList(entityId);
    } else {
      developer.log('No entityId found in userData', name: 'UserList');
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
    final userId = await _secureStorage.getUserId();
    if (userId != null) {
      developer.log('Refreshing user list for userId: $userId', name: 'UserList');
      await _viewModel.fetchUserList(userId);
    }
  }

  List<User> _getFilteredUsers(List<User> users) {
    return users.where((user) {
      final matchesSearch = _searchQuery.isEmpty ||
          user.id.toString().contains(_searchQuery) ||
          user.name.toLowerCase().contains(_searchQuery) ||
          user.role.toLowerCase().contains(_searchQuery) ||
          user.mobileNumber.toLowerCase().contains(_searchQuery);

      final matchesRole = _selectedRoles.isEmpty ||
          _selectedRoles.contains(user.role.toLowerCase());

      return matchesSearch && matchesRole;
    }).toList();
  }

  void _updatePage(int newPage) {
    final filteredUsers = _getFilteredUsers(_viewModel.operators);
    updatePage(newPage, filteredUsers, (page) {
      setState(() => _currentPage = page);
      developer.log('Page updated to: $_currentPage', name: 'UserList');
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
    final selectedFilters = _selectedRoles
        .map((r) => '${strings.labelRole}: ${r.capitalize()}')
        .toList();
    final textColor = Theme.of(context).brightness == Brightness.light
        ? AppColors.textPrimaryLight
        : AppColors.textPrimaryDark;

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
                      _selectedRoles.clear();
                      _currentPage = 1;
                    });
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
                        _selectedRoles.remove(filter.split(': ')[1].toLowerCase());
                      });
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
    final hasActiveFilters = _selectedRoles.isNotEmpty;
    final textColor = Theme.of(context).brightness == Brightness.light
        ? AppColors.textPrimaryLight
        : AppColors.textPrimaryDark;

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
    final roles = _viewModel.operators
        .map((u) => u.role.toLowerCase())
        .where((role) => role.isNotEmpty)
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
                      decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      strings.advancedFiltersLabel,
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimaryColor),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: [
                        _buildFilterSection(
                          title: strings.labelRole,
                          options: roles
                              .map((role) => {'key': role, 'label': role.capitalize()})
                              .toList(),
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
                color: context.textPrimaryColor),
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
                selectedColor: Theme.of(context).brightness == Brightness.light
                    ? Colors.grey
                    : Colors.black,
                checkmarkColor: textColor,
                backgroundColor: context.secondaryCardColor,
                labelStyle: TextStyle(
                  color: textColor,
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

    final error = viewModel.error;
    if (error != null) {
      developer.log('Error occurred: $error', name: 'UserList');
      switch (error.runtimeType) {
        case NoInternetException:
          errorTitle = strings.errorTitleNoInternet;
          errorMessage = strings.errorMessageNoInternet;
          break;
        case RequestTimeoutException:
          errorTitle = strings.errorTitleTimeout;
          errorMessage = strings.errorMessageTimeout;
          break;
        case HttpException:
          final httpError = error as HttpException;
          errorTitle = strings.errorTitleServer;
          errorMessage = httpError.toString(); // Adjust based on HttpException properties
          break;
        case ServiceException:
          errorTitle = strings.errorUnexpected;
          errorMessage = error.toString();
          break;
        default:
          errorTitle = strings.errorUnexpected;
          errorMessage = error.toString();
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
    return Consumer<UserViewModel>(
      builder: (context, viewModel, _) {
        final filteredUsers = _getFilteredUsers(viewModel.operators);
        final totalPages = getTotalPages(filteredUsers);
        final paginatedUsers = getPaginatedItems(filteredUsers, _currentPage);

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
                          content: Text(strings.messagePdfSuccess,
                              style: TextStyle(color: context.textPrimaryColor)),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    } catch (e) {
                      developer.log('PDF export failed: $e', name: 'UserList', error: e);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${strings.messagePdfFailed}: $e',
                              style: TextStyle(color: context.textPrimaryColor)),
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
                          const SizedBox(height: 8),
                          if (viewModel.error != null && !viewModel.isLoading)
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.6,
                              child: _buildErrorState(viewModel, strings),
                            )
                          else if (filteredUsers.isEmpty && !viewModel.isLoading)
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.6,
                              child: Center(
                                child: Text(
                                  strings.messageNoUsersFound,
                                  style: TextStyle(color: context.textPrimaryColor),
                                ),
                              ),
                            )
                          else if (!viewModel.isLoading)
                              ...paginatedUsers.map((user) => _buildUserCard(user)),
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
          bottomNavigationBar: filteredUsers.isNotEmpty && !viewModel.isLoading
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