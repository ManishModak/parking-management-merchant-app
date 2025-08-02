import 'dart:async';
import 'dart:developer' as developer;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/config/app_theme.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../generated/l10n.dart';
import '../models/dashboard.dart';
import '../services/core/plaza_service.dart';
import '../services/storage/secure_storage_service.dart';
import '../viewmodels/dashboard_viewmodel.dart';

String formatNumber(dynamic number,
    {String locale = 'en_IN',
    bool showCurrency = false,
    String currencySymbol = '₹'}) {
  if (number == null) return showCurrency ? '${currencySymbol}0.00' : '0';
  if (number is int || number is double) {
    String formattedNumber;
    if (number >= 10000000) {
      formattedNumber = '${(number / 10000000).toStringAsFixed(1)}Cr';
    } else if (number >= 100000) {
      formattedNumber = '${(number / 100000).toStringAsFixed(1)}L';
    } else if (number >= 1000) {
      formattedNumber = '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      if (number is double && number % 1 == 0) {
        formattedNumber = number.toInt().toString();
      } else if (number is double) {
        formattedNumber = number.toStringAsFixed(showCurrency ? 2 : 1);
      } else {
        formattedNumber = number.toString();
      }
    }
    if (showCurrency) {
      if (number < 1000 &&
          (number is int || (number is double && number % 1 == 0))) {
        return '$currencySymbol${number.toInt()}.00';
      }
      return '$currencySymbol$formattedNumber';
    }
    return formattedNumber;
  }
  return showCurrency ? '${currencySymbol}0.00' : '0';
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<String> _filterOptions = [];
  String _selectedFilter = '';
  final List<Map<String, dynamic>> _plazaOptions = [];
  String? _selectedPlazaId;
  // PageControllers are no longer needed for these sections if they become Columns
  // late PageController _ticketOverviewPageController;
  // late PageController _plazaSummaryPageController;
  Timer? _debounceTimer;
  final PlazaService _plazaService = PlazaService();
  final SecureStorageService _secureStorageService = SecureStorageService();

  bool _isInitialLoading = true;
  bool _hasAccessOrConfigError = false;
  String _accessOrConfigErrorMessage = '';
  bool _canViewDashboard = false;

  @override
  void initState() {
    super.initState();
    // _ticketOverviewPageController = PageController();
    // _plazaSummaryPageController = PageController();
    developer.log('Initializing DashboardScreen', name: 'DashboardScreen');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final strings = S.of(context);
      if (mounted) {
        setState(() {
          _filterOptions.clear();
          _filterOptions.addAll([
            strings.filterDaily,
            strings.filterWeekly,
            strings.filterMonthly,
            strings.filterQuarterly,
          ]);
          _selectedFilter = _filterOptions.isNotEmpty ? _filterOptions[2] : '';
        });
      }
      _initializeDashboard();
    });
  }

  Future<void> _initializeDashboard() async {
    if (!mounted) return;
    setState(() {
      _isInitialLoading = true;
      _hasAccessOrConfigError = false;
      _canViewDashboard = false;
      _accessOrConfigErrorMessage = '';
    });

    final success = await _loadPlazaOptionsAndValidateAccess();
    if (success) {
      if (mounted) {
        setState(() {
          _canViewDashboard = true;
        });
        await _refreshDashboardData(plazaId: _selectedPlazaId);
      }
    }

    if (mounted && _isInitialLoading) {
      setState(() {
        _isInitialLoading = false;
      });
    }
  }

  Future<bool> _loadPlazaOptionsAndValidateAccess() async {
    if (!mounted) {
      _isInitialLoading = false;
      return false;
    }
    final strings = S.of(context);

    try {
      final userRole = await _secureStorageService.getUserRole();
      developer.log('User role: $userRole', name: 'DashboardScreen');

      if (userRole != 'Plaza Owner' &&
          userRole != 'Plaza Admin' &&
          userRole != 'Plaza Operator') {
        developer.log('Unauthorized user role: $userRole',
            name: 'DashboardScreen');
        if (mounted) {
          setState(() {
            _hasAccessOrConfigError = true;
            _accessOrConfigErrorMessage = strings.errorNoAccessToDashboard;
            _isInitialLoading = false;
          });
        }
        return false;
      }

      _plazaOptions.clear();

      if (userRole == 'Plaza Owner') {
        final entityId = await _secureStorageService.getEntityId();
        if (entityId != null) {
          final plazas = await _plazaService.fetchUserPlazas(entityId);
          if (mounted) {
            setState(() {
              _plazaOptions.add({
                'id': null,
                'name': strings.labelAllPlazas,
              });
              _plazaOptions.addAll(plazas
                  .map((plaza) => {
                        'id': plaza.plazaId.toString(),
                        'name': plaza.plazaName ?? strings.labelUnknown,
                      })
                  .toList());
              _selectedPlazaId = _plazaOptions.first['id'];
            });
          }
        } else {
          developer.log('Entity ID not found for Plaza Owner',
              name: 'DashboardScreen');
          if (mounted) {
            setState(() {
              _hasAccessOrConfigError = true;
              _accessOrConfigErrorMessage =
                  strings.errorPlazaOwnerEntityIdMissing;
              _isInitialLoading = false;
            });
          }
          return false;
        }
      } else if (userRole == 'Plaza Admin' || userRole == 'Plaza Operator') {
        final userData = await _secureStorageService.getUserData();
        if (userData != null && userData['subEntity'] != null) {
          final subEntities = userData['subEntity'] as List<dynamic>;
          if (subEntities.isNotEmpty) {
            if (mounted) {
              setState(() {
                _plazaOptions.addAll(subEntities
                    .map((subEntity) => {
                          'id': subEntity['plazaId'].toString(),
                          'name':
                              subEntity['plazaName'] ?? strings.labelUnknown,
                        })
                    .toList());
                _selectedPlazaId =
                    _plazaOptions.isNotEmpty ? _plazaOptions.first['id'] : null;
              });
            }
            if (_plazaOptions.isEmpty) {
              developer.log(
                  'Plaza options became empty unexpectedly for $userRole',
                  name: 'DashboardScreen');
              if (mounted) {
                setState(() {
                  _hasAccessOrConfigError = true;
                  _accessOrConfigErrorMessage =
                      strings.errorAdminOperatorNoPlazasConfigured;
                  _isInitialLoading = false;
                });
              }
              return false;
            }
          } else {
            developer.log('No subEntity (empty list) found for $userRole',
                name: 'DashboardScreen');
            if (mounted) {
              setState(() {
                _hasAccessOrConfigError = true;
                _accessOrConfigErrorMessage =
                    strings.errorAdminOperatorNoPlazasAssigned;
                _isInitialLoading = false;
              });
            }
            return false;
          }
        } else {
          developer.log('No subEntity data (null) for $userRole',
              name: 'DashboardScreen');
          if (mounted) {
            setState(() {
              _hasAccessOrConfigError = true;
              _accessOrConfigErrorMessage =
                  strings.errorAdminOperatorNoPlazasConfigured;
              _isInitialLoading = false;
            });
          }
          return false;
        }
      }
      if (mounted) {
        setState(() {
          _isInitialLoading = false;
        });
      }
      return true;
    } catch (e, stackTrace) {
      developer.log('Error loading plaza options or validating access: $e',
          name: 'DashboardScreen', error: e, stackTrace: stackTrace);
      if (mounted) {
        setState(() {
          _hasAccessOrConfigError = true;
          _accessOrConfigErrorMessage =
              '${strings.errorLoadingDashboardConfig}: ${e.toString()}';
          _isInitialLoading = false;
        });
      }
      return false;
    }
  }

  @override
  void dispose() {
    // _ticketOverviewPageController.dispose();
    // _plazaSummaryPageController.dispose();
    _debounceTimer?.cancel();
    developer.log('Disposing DashboardScreen', name: 'DashboardScreen');
    super.dispose();
  }

  String _getFrequencyFromFilter(String filter) {
    final strings = S.of(context);
    if (filter == strings.filterDaily) return 'daily';
    if (filter == strings.filterWeekly) return 'weekly';
    if (filter == strings.filterMonthly) return 'monthly';
    if (filter == strings.filterQuarterly) return 'quarterly';
    return 'monthly';
  }

  Future<void> _refreshDashboardData({String? plazaId}) async {
    if (!mounted) return;
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      if (!mounted) return;
      final strings = S.of(context);
      final viewModel = Provider.of<DashboardViewModel>(context, listen: false);
      try {
        await viewModel.fetchDashboardData(
          frequency: _getFrequencyFromFilter(_selectedFilter),
          plazaId: plazaId ?? _selectedPlazaId,
        );
        if (mounted && viewModel.errorMessage == null) {
          if (ModalRoute.of(context)?.isCurrent == true) {
            // ScaffoldMessenger.of(context).showSnackBar( // Reduced verbosity
            //   SnackBar(
            //     content: Text(strings.dataRefreshSuccess),
            //     backgroundColor: AppColors.success,
            //   ),
            // );
          }
        } else if (mounted && viewModel.errorMessage != null) {
          if (ModalRoute.of(context)?.isCurrent == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    '${strings.dataRefreshFailed}: ${viewModel.errorMessage}'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      } catch (e) {
        developer.log('Data refresh failed: $e',
            name: 'DashboardScreen', level: 1000);
        if (mounted && ModalRoute.of(context)?.isCurrent == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${strings.dataRefreshFailed}: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    });
  }

  Widget _buildFullScreenErrorWidget(String message, S strings,
      {required bool showRetryButton}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: AppColors.error, size: 64),
            const SizedBox(height: 20),
            Text(
              message,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: context.textPrimaryColor,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (showRetryButton)
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: Text(
                  strings.retry,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                      ),
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _initializeDashboard();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    developer.log(
        'Building DashboardScreen, isInitialLoading: $_isInitialLoading, hasError: $_hasAccessOrConfigError, canView: $_canViewDashboard, errorMessage: $_accessOrConfigErrorMessage',
        name: 'DashboardScreen');

    Widget bodyContent;

    if (_isInitialLoading) {
      bodyContent = const Center(child: CircularProgressIndicator());
    } else if (_hasAccessOrConfigError) {
      final bool isRoleAccessError =
          _accessOrConfigErrorMessage == strings.errorNoAccessToDashboard;
      bodyContent = _buildFullScreenErrorWidget(
        _accessOrConfigErrorMessage,
        strings,
        showRetryButton: !isRoleAccessError,
      );
    } else if (!_canViewDashboard) {
      bodyContent = _buildFullScreenErrorWidget(
        strings.errorNoAccessToDashboard,
        strings,
        showRetryButton: false,
      );
    } else {
      bodyContent = RefreshIndicator(
        onRefresh: () => _refreshDashboardData(plazaId: _selectedPlazaId),
        color: Theme.of(context).primaryColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width > 600 ? 16 : 4,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              _buildFilterDropdown(),
              const SizedBox(height: 8),
              _buildPlazaSection(),
              const SizedBox(height: 16),
              _buildTicketCollectionsRow(strings),
              const SizedBox(height: 12),
              _buildTicketOverviewRow(strings), // This will now be a Column
              const SizedBox(height: 12), // Adjusted spacing
              _buildPlazaSummaryRow(strings), // This will now be a Column
              const SizedBox(height: 16),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4.0),
                child: _buildBookingAnalysisCard(strings),
              ),
              const SizedBox(height: 16),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4.0),
                child: _buildDisputeSummaryCard(strings),
              ),
              const SizedBox(height: 16),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4.0),
                child: _buildPaymentMethodAnalysisCard(strings),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: CustomAppBar.appBarWithTitle(
        screenTitle: strings.titleDashboard,
        darkBackground: isDarkMode,
        context: context,
      ),
      body: bodyContent,
    );
  }

  Widget _buildShimmerPlaceholder({
    double? width,
    required double height,
    double borderRadius = 8.0,
    EdgeInsetsGeometry margin = EdgeInsets.zero,
  }) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: Colors
            .white, // Base color for shimmer, will be overridden by Shimmer.fromColors
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }

  Widget _buildShimmerSummaryCardContainer({required Widget child}) {
    return Container(
      height: 80, // Adjusted height
      padding: const EdgeInsets.all(10), // Adjusted padding
      decoration: BoxDecoration(
        color: context.secondaryCardColor, // Base color for shimmer
        borderRadius: BorderRadius.circular(10), // Adjusted radius
        boxShadow: [
          BoxShadow(
            color: context.shadowColor.withOpacity(0.3),
            blurRadius: 3, // Adjusted blur
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildShimmerAnalysisCardContainer(
      {required Widget child, required double height}) {
    return Container(
      width: double.infinity,
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.secondaryCardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: context.shadowColor.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildShimmerDropdown() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDarkMode ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDarkMode ? Colors.grey[700]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        child: Row(
          children: [
            Expanded(
              child: _buildShimmerPlaceholder(
                  width: double.infinity, height: 48, borderRadius: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketCollectionsShimmer() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDarkMode ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDarkMode ? Colors.grey[700]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Expanded(
              child: _buildShimmerSummaryCardContainer(
                // Uses new height: 80
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildShimmerPlaceholder(
                            width: 80, // smaller
                            height: 10, // smaller
                            margin: const EdgeInsets.only(bottom: 5)),
                        _buildShimmerPlaceholder(
                            width: 30, height: 16), // smaller
                      ],
                    ),
                    Positioned(
                        top: 0,
                        right: 0,
                        child: _buildShimmerPlaceholder(
                            width: 24,
                            height: 24,
                            borderRadius: 12)), // smaller icon
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildShimmerSummaryCardContainer(
                // Uses new height: 80
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildShimmerPlaceholder(
                            width: 100, // smaller
                            height: 10, // smaller
                            margin: const EdgeInsets.only(bottom: 5)),
                        _buildShimmerPlaceholder(
                            width: 60, height: 16), // smaller
                      ],
                    ),
                    Positioned(
                        top: 0,
                        right: 0,
                        child: _buildShimmerPlaceholder(
                            width: 24,
                            height: 24,
                            borderRadius: 14)), // smaller icon
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Shimmer for sections that are now Columns of Rows
  Widget _buildStackedSummaryShimmer({int rowCount = 2}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDarkMode ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDarkMode ? Colors.grey[700]! : Colors.grey[100]!;

    return Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Column(
          children: List.generate(rowCount, (index) {
            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4.0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildShimmerSummaryCardContainer(
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildShimmerPlaceholder(
                                  width: 80,
                                  height: 10,
                                  margin: const EdgeInsets.only(bottom: 5)),
                              _buildShimmerPlaceholder(width: 30, height: 16),
                            ],
                          ),
                          Positioned(
                              top: 0,
                              right: 0,
                              child: _buildShimmerPlaceholder(
                                  width: 24, height: 24, borderRadius: 12)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildShimmerSummaryCardContainer(
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildShimmerPlaceholder(
                                  width: 80,
                                  height: 10,
                                  margin: const EdgeInsets.only(bottom: 5)),
                              _buildShimmerPlaceholder(width: 30, height: 16),
                            ],
                          ),
                          Positioned(
                              top: 0,
                              right: 0,
                              child: _buildShimmerPlaceholder(
                                  width: 24, height: 24, borderRadius: 12)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ));
  }

  Widget _buildFilterDropdown() {
    if (_filterOptions.isEmpty) {
      return _buildShimmerDropdown();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        children: [
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: DropdownButtonFormField<String>(
                key: ValueKey(_selectedFilter),
                value: _filterOptions.contains(_selectedFilter)
                    ? _selectedFilter
                    : (_filterOptions.isNotEmpty ? _filterOptions.first : null),
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.inputBorderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.inputBorderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: Theme.of(context).primaryColor, width: 2),
                  ),
                  filled: true,
                  fillColor: context.secondaryCardColor,
                ),
                items: _filterOptions.map((String filter) {
                  return DropdownMenuItem<String>(
                    value: filter,
                    child: Text(
                      filter,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null && newValue != _selectedFilter) {
                    developer.log('Filter changed to: $newValue',
                        name: 'DashboardScreen');
                    HapticFeedback.selectionClick();
                    setState(() {
                      _selectedFilter = newValue;
                    });
                    _refreshDashboardData(plazaId: _selectedPlazaId);
                  }
                },
                dropdownColor: context.cardColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlazaSection() {
    if (_plazaOptions.isEmpty) {
      developer.log(
          "Warning: _buildPlazaSection called with empty _plazaOptions when dashboard is visible.",
          name: "DashboardScreen");
      return const SizedBox.shrink();
    }
    return _buildPlazaDropdownWidget();
  }

  Widget _buildPlazaDropdownWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        children: [
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: DropdownButtonFormField<String?>(
                key: ValueKey(_selectedPlazaId),
                value: _selectedPlazaId,
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.inputBorderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.inputBorderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: Theme.of(context).primaryColor, width: 2),
                  ),
                  filled: true,
                  fillColor: context.secondaryCardColor,
                ),
                items: _plazaOptions.map((Map<String, dynamic> plaza) {
                  return DropdownMenuItem<String?>(
                    value: plaza['id'],
                    child: Text(
                      plaza['name'],
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != _selectedPlazaId) {
                    developer.log('Plaza changed to ID: $newValue',
                        name: 'DashboardScreen');
                    HapticFeedback.selectionClick();
                    setState(() {
                      _selectedPlazaId = newValue;
                    });
                    _refreshDashboardData(plazaId: newValue);
                  }
                },
                dropdownColor: context.cardColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required Widget child,
    required double height,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      height: height,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: context.secondaryCardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: context.shadowColor.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500),
              ),
            ),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String value, Color color) {
    return Text(
      value,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            // Reduced from headlineSmall
            color: color,
            fontWeight: FontWeight.bold,
          ),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required List<Widget> items,
    Widget? iconWidget,
  }) {
    return Container(
      height: 90, // Reduced from 100
      padding: const EdgeInsets.all(10), // Reduced padding
      decoration: BoxDecoration(
        color: context.secondaryCardColor,
        borderRadius: BorderRadius.circular(10), // Reduced radius
        boxShadow: [
          BoxShadow(
            color: context.shadowColor.withOpacity(0.3),
            blurRadius: 3, // Reduced blur
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall // Reduced from labelMedium
                        ?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w500),
                    softWrap: true,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4), // Reduced spacing
                ...items.map((item) => Flexible(child: item)),
              ],
            ),
          ),
          if (iconWidget != null) ...[
            const SizedBox(width: 8), // Reduced spacing
            iconWidget, // Ensure icon size is also reduced if needed
          ],
        ],
      ),
    );
  }

  Widget _buildSectionErrorWidget(S strings, DashboardViewModel viewModel) {
    String message = strings.errorDataNotFound;
    if (!viewModel.isLoading && viewModel.errorMessage != null) {
      message = "${strings.errorFailedToLoadSection}\n${strings.tryRefreshing}";
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: AppColors.error),
        ),
      ),
    );
  }

  Widget _buildTicketCollectionsRow(S strings) {
    return Consumer<DashboardViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading && viewModel.ticketStats == null) {
          return _buildTicketCollectionsShimmer();
        }

        if (viewModel.ticketStats == null) {
          return SizedBox(
              height: 80,
              child: _buildSectionErrorWidget(
                  strings, viewModel)); // Adjusted height
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: strings.labelNumberOfTickets,
                  items: [
                    _buildSummaryItem(
                      formatNumber(viewModel.ticketStats!.totalTickets),
                      context.textPrimaryColor,
                    ),
                  ],
                  iconWidget: Icon(Icons.receipt_long,
                      color: context.textPrimaryColor,
                      size: 24), // Reduced icon size
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSummaryCard(
                  title: strings.labelTicketCollections,
                  items: [
                    _buildSummaryItem(
                      formatNumber(viewModel.ticketStats!.totalCollection,
                          showCurrency: true),
                      context.textPrimaryColor,
                    ),
                  ],
                  iconWidget: Icon(Icons.account_balance_wallet,
                      color: context.textPrimaryColor,
                      size: 24), // Reduced icon size
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTicketOverviewRow(S strings) {
    return Consumer<DashboardViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading && viewModel.ticketOverview == null) {
          return _buildStackedSummaryShimmer(
              rowCount: 2); // Shimmer for 2 rows of cards
        }

        if (viewModel.ticketOverview == null) {
          return Padding(
            // Wrap error in padding consistent with content
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: SizedBox(
                height: 80,
                child: _buildSectionErrorWidget(strings, viewModel)),
          );
        }

        final List<Widget> cards = [
          _buildSummaryCard(
            title: strings.labelTotalTickets,
            items: [
              _buildSummaryItem(
                formatNumber(viewModel.ticketOverview!.totalTickets),
                context.textPrimaryColor,
              ),
            ],
            iconWidget: Icon(Icons.sticky_note_2_outlined,
                color: context.textPrimaryColor, size: 24), // Reduced icon size
          ),
          _buildSummaryCard(
            title: strings.labelOpenTickets,
            items: [
              _buildSummaryItem(
                formatNumber(viewModel.ticketOverview!.openTickets),
                AppColors.warning,
              ),
            ],
            iconWidget: Icon(Icons.folder_open_outlined,
                color: AppColors.warning, size: 24), // Reduced icon size
          ),
          _buildSummaryCard(
            title: strings.labelCompletedTickets,
            items: [
              _buildSummaryItem(
                formatNumber(viewModel.ticketOverview!.completedTickets),
                AppColors.success,
              ),
            ],
            iconWidget: Icon(Icons.check_circle_outline,
                color: AppColors.success, size: 24), // Reduced icon size
          ),
          _buildSummaryCard(
            title: strings.labelRejectedTickets,
            items: [
              _buildSummaryItem(
                formatNumber(viewModel.ticketOverview!.rejectedTickets),
                AppColors.error,
              ),
            ],
            iconWidget: Icon(Icons.cancel_outlined,
                color: AppColors.error, size: 24), // Reduced icon size
          ),
        ];

        final List<List<Widget>> cardPairs = [];
        for (int i = 0; i < cards.length; i += 2) {
          if (i + 1 < cards.length) {
            cardPairs.add([cards[i], cards[i + 1]]);
          } else {
            cardPairs.add([
              cards[i],
              Expanded(child: Container())
            ]); // Handle odd number of cards
          }
        }

        return Column(
          children: cardPairs.map((pair) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 4.0), // Add vertical padding between rows
              child: Row(
                children: [
                  Expanded(child: pair[0]),
                  const SizedBox(width: 8),
                  Expanded(child: pair[1]),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildPlazaSummaryRow(S strings) {
    return Consumer<DashboardViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading && viewModel.plazaSummary == null) {
          return _buildStackedSummaryShimmer(
              rowCount: 2); // Shimmer for 2 rows of cards
        }

        if (viewModel.plazaSummary == null) {
          return Padding(
            // Wrap error in padding consistent with content
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: SizedBox(
                height: 80,
                child: _buildSectionErrorWidget(strings, viewModel)),
          );
        }

        final availableSlots =
            (viewModel.plazaSummary!.totalParkingSlots ?? 0) -
                (viewModel.plazaSummary!.occupiedSlots ?? 0);

        final List<Widget> cards = [
          _buildSummaryCard(
            title: strings.labelNumberOfPlazas,
            items: [
              _buildSummaryItem(
                formatNumber(viewModel.plazaSummary!.totalPlazas ?? 0),
                context.textPrimaryColor,
              ),
            ],
            iconWidget: Icon(Icons.business_outlined,
                color: context.textPrimaryColor, size: 24), // Reduced icon size
          ),
          _buildSummaryCard(
            title: strings.labelTotalSlots,
            items: [
              _buildSummaryItem(
                formatNumber(viewModel.plazaSummary!.totalParkingSlots ?? 0),
                context.textPrimaryColor,
              ),
            ],
            iconWidget: Icon(Icons.local_parking_outlined,
                color: context.textPrimaryColor, size: 24), // Reduced icon size
          ),
          _buildSummaryCard(
            title: strings.labelAvailableSlots,
            items: [
              _buildSummaryItem(
                formatNumber(availableSlots > 0 ? availableSlots : 0),
                AppColors.success,
              ),
            ],
            iconWidget: Icon(Icons.event_available_outlined,
                color: AppColors.success, size: 24), // Reduced icon size
          ),
          _buildSummaryCard(
            title: strings.labelOccupiedSlots,
            items: [
              _buildSummaryItem(
                formatNumber(viewModel.plazaSummary!.occupiedSlots ?? 0),
                AppColors.warning,
              ),
            ],
            iconWidget: Icon(Icons.car_rental_outlined,
                color: AppColors.warning, size: 24), // Reduced icon size
          ),
        ];

        final List<List<Widget>> cardPairs = [];
        for (int i = 0; i < cards.length; i += 2) {
          if (i + 1 < cards.length) {
            cardPairs.add([cards[i], cards[i + 1]]);
          } else {
            cardPairs.add([
              cards[i],
              Expanded(child: Container())
            ]); // Handle odd number of cards
          }
        }

        return Column(
          children: cardPairs.map((pair) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 4.0), // Add vertical padding between rows
              child: Row(
                children: [
                  Expanded(child: pair[0]),
                  const SizedBox(width: 8),
                  Expanded(child: pair[1]),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildBookingAnalysisCard(S strings) {
    return Consumer<DashboardViewModel>(
      builder: (context, viewModel, child) {
        final cardHeight = 230.0;
        final bool isLoading =
            viewModel.isLoading && viewModel.bookingStats == null;

        if (isLoading) {
          final isDarkMode = Theme.of(context).brightness == Brightness.dark;
          final baseColor = isDarkMode ? Colors.grey[800]! : Colors.grey[300]!;
          final highlightColor =
              isDarkMode ? Colors.grey[700]! : Colors.grey[100]!;
          return Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: _buildShimmerAnalysisCardContainer(
              height: cardHeight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildShimmerPlaceholder(width: 150, height: 20),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildShimmerPlaceholder(width: 120, height: 12),
                  const SizedBox(height: 4),
                  _buildShimmerPlaceholder(width: 200, height: 24),
                  const SizedBox(height: 12),
                  _buildShimmerPlaceholder(
                      width: double.infinity, height: 10, borderRadius: 5),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: 3,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemBuilder: (ctx, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            ClipOval(
                                child: _buildShimmerPlaceholder(
                                    width: 10, height: 10)),
                            const SizedBox(width: 8),
                            _buildShimmerPlaceholder(width: 80, height: 12),
                            const Spacer(),
                            _buildShimmerPlaceholder(width: 100, height: 12),
                            const SizedBox(width: 8),
                            _buildShimmerPlaceholder(width: 50, height: 12),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (viewModel.bookingStats == null) {
          return _buildCard(
            title: "",
            height: cardHeight,
            child: Column(
              children: [
                _bookingAnalysisHeader(
                  title: strings.cardPlazaBookingSummary,
                ),
                Expanded(
                  child: _buildSectionErrorWidget(strings, viewModel),
                ),
              ],
            ),
          );
        }

        final bookingStats = viewModel.bookingStats!;
        final totalBookings = bookingStats.totalBookings;

        final categories = [
          {
            'label': strings.labelReservedBookings,
            'value': bookingStats.reserved.toDouble(),
            'color': context.chartPrimaryColor,
            'change': bookingStats.percentageChangeReserved ??
                bookingStats.percentageChange,
          },
          {
            'label': strings.labelCancelledBookings,
            'value': bookingStats.cancelled.toDouble(),
            'color': AppColors.error,
            'change': bookingStats.percentageChangeCancelled ??
                bookingStats.percentageChange,
          },
          {
            'label': strings.labelNoShowBookings,
            'value': bookingStats.noShow.toDouble(),
            'color': AppColors.warning,
            'change': bookingStats.percentageChangeNoShow ??
                bookingStats.percentageChange,
          },
        ];

        return _buildCard(
          title: "",
          height: cardHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _bookingAnalysisHeader(
                title: strings.cardPlazaBookingSummary,
              ),
              const SizedBox(height: 12),
              Text(
                strings.labelTotalBookings.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: context.textSecondaryColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    formatNumber(totalBookings),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: context.textPrimaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "${bookingStats.percentageChange >= 0 ? '+' : ''}${formatNumber(bookingStats.percentageChange)}% ${strings.labelVsPreviousPeriod}",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: bookingStats.percentageChange >= 0
                              ? AppColors.success
                              : AppColors.error,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (totalBookings > 0)
                _customStackedProgressBar(
                    categories: categories,
                    totalValue: totalBookings.toDouble()),
              if (totalBookings == 0)
                Container(
                  width: double.infinity,
                  height: 8,
                  decoration: BoxDecoration(
                    color: context.inputBorderColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: categories.length,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final value = category['value'] as double;
                    final percentageOfTotal =
                        totalBookings > 0 ? (value / totalBookings * 100) : 0.0;
                    final categoryChange = category['change'] as double?;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: category['color'] as Color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            category['label'] as String,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: category['color'] as Color,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          const Spacer(),
                          Text(
                            '${formatNumber(value)} (${percentageOfTotal.toStringAsFixed(percentageOfTotal == 0 || percentageOfTotal % 1 == 0 ? 0 : 1)}%)',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: context.textPrimaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          const SizedBox(width: 8),
                          if (categoryChange != null)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  categoryChange >= 0
                                      ? Icons.arrow_upward
                                      : Icons.arrow_downward,
                                  color: categoryChange >= 0
                                      ? AppColors.success
                                      : AppColors.error,
                                  size: 14,
                                ),
                                Text(
                                  '${formatNumber(categoryChange.abs())}%',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: categoryChange >= 0
                                            ? AppColors.success
                                            : AppColors.error,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _bookingAnalysisHeader({required String title}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _customStackedProgressBar({
    required List<Map<String, dynamic>> categories,
    required double totalValue,
    double height = 8.0,
  }) {
    if (totalValue <= 0) {
      return Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(height / 2),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        List<Widget> segments = [];

        final visibleCategories =
            categories.where((cat) => (cat['value'] as double) > 0).toList();

        if (visibleCategories.isEmpty) {
          return Container(
            width: double.infinity,
            height: height,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(height / 2),
            ),
          );
        }

        for (int i = 0; i < visibleCategories.length; i++) {
          final category = visibleCategories[i];
          final value = category['value'] as double;

          segments.add(
            Flexible(
              flex: (value * 1000)
                  .toInt(), // Use a large enough multiplier for flex
              child: Container(
                height: height,
                color: category['color'] as Color,
              ),
            ),
          );
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: Row(children: segments),
        );
      },
    );
  }

  Widget _buildDisputeSummaryCard(S strings) {
    return Consumer<DashboardViewModel>(
      builder: (context, viewModel, child) {
        final cardHeight = 450.0;
        if (viewModel.isLoading && viewModel.disputeSummary == null) {
          final isDarkMode = Theme.of(context).brightness == Brightness.dark;
          final baseColor = isDarkMode ? Colors.grey[800]! : Colors.grey[300]!;
          final highlightColor =
              isDarkMode ? Colors.grey[700]! : Colors.grey[100]!;
          return Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: _buildCard(
              title: strings.cardDisputeSummary,
              height: cardHeight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      child: Center(
                          child: ClipOval(
                              child: _buildShimmerPlaceholder(
                                  width: 120, height: 120)))),
                  const SizedBox(height: 12),
                  _buildShimmerPlaceholder(
                      width: double.infinity,
                      height: 30,
                      margin: const EdgeInsets.only(bottom: 8)),
                  _buildShimmerPlaceholder(
                      width: double.infinity,
                      height: 30,
                      margin: const EdgeInsets.only(bottom: 8)),
                  _buildShimmerPlaceholder(width: double.infinity, height: 30),
                ],
              ),
            ),
          );
        }

        if (viewModel.disputeSummary == null) {
          return _buildCard(
            title: strings.cardDisputeSummary,
            height: cardHeight,
            child: _buildSectionErrorWidget(strings, viewModel),
          );
        }

        final disputeSummary = viewModel.disputeSummary!;
        final totalDisputes = disputeSummary.totalDisputes ?? 0;
        final totalAmount = disputeSummary.totalAmount ?? 0.0;

        final categoriesData = [
          {
            'label': strings.labelOpenDisputes,
            'count': disputeSummary.openDisputes ?? 0,
            'amount': disputeSummary.openAmount ?? 0.0,
            'color': context.chartPrimaryColor,
          },
          {
            'label': strings.labelSettledDisputes,
            'count': disputeSummary.settledDisputes ?? 0,
            'amount': disputeSummary.settledAmount ?? 0.0,
            'color': AppColors.success,
          },
          {
            'label': strings.labelRejectedDisputes,
            'count': disputeSummary.rejectedDisputes ?? 0,
            'amount': disputeSummary.rejectedAmount ?? 0.0,
            'color': AppColors.error,
          },
        ];

        final activeCategories =
            categoriesData.where((cat) => cat['count'] as int > 0).toList();

        final pieChartSections = activeCategories.map((cat) {
          final value = (cat['count'] as int).toDouble();
          return PieChartSectionData(
            value: value,
            color: cat['color'] as Color,
            title: '',
            radius: 40,
            showTitle: false,
          );
        }).toList();

        return _buildCard(
          title: strings.cardDisputeSummary,
          height: cardHeight,
          child: Column(
            children: [
              SizedBox(
                height: 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (pieChartSections.isNotEmpty)
                      PieChart(
                        PieChartData(
                          sections: pieChartSections,
                          centerSpaceRadius: 60,
                          sectionsSpace: 2,
                          startDegreeOffset: -90,
                        ),
                      ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          formatNumber(totalDisputes),
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: context.textPrimaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          strings.labelTotalDisputes,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: context.textSecondaryColor),
                        ),
                        Text(
                          formatNumber(totalAmount, showCurrency: true),
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: context.textSecondaryColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: categoriesData.length,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: context.inputBorderColor.withOpacity(0.5)),
                  itemBuilder: (context, index) {
                    final category = categoriesData[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            category['label'] as String,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: category['color'] as Color,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          Text(
                            '${formatNumber(category['count'])} ${strings.labelDisputesLowerCase} (${formatNumber(category['amount'], showCurrency: true)})',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: context.textPrimaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentMethodAnalysisCard(S strings) {
    return Consumer<DashboardViewModel>(
      builder: (context, viewModel, child) {
        final cardHeight = 500.0;
        if (viewModel.isLoading && viewModel.paymentAnalysis == null) {
          final isDarkMode = Theme.of(context).brightness == Brightness.dark;
          final baseColor = isDarkMode ? Colors.grey[800]! : Colors.grey[300]!;
          final highlightColor =
              isDarkMode ? Colors.grey[700]! : Colors.grey[100]!;
          return Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: _buildCard(
              title: strings.cardPaymentMethodAnalysis,
              height: cardHeight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      child: Center(
                          child: ClipOval(
                              child: _buildShimmerPlaceholder(
                                  width: 120, height: 120)))),
                  const SizedBox(height: 12),
                  _buildShimmerPlaceholder(
                      width: double.infinity,
                      height: 10,
                      borderRadius: 5,
                      margin: const EdgeInsets.only(bottom: 8)),
                  _buildShimmerPlaceholder(
                      width: double.infinity,
                      height: 30,
                      margin: const EdgeInsets.only(bottom: 8)),
                  _buildShimmerPlaceholder(
                      width: double.infinity,
                      height: 30,
                      margin: const EdgeInsets.only(bottom: 8)),
                  _buildShimmerPlaceholder(width: double.infinity, height: 30),
                ],
              ),
            ),
          );
        }

        if (viewModel.paymentAnalysis == null) {
          return _buildCard(
            title: strings.cardPaymentMethodAnalysis,
            height: cardHeight,
            child: _buildSectionErrorWidget(strings, viewModel),
          );
        }

        final paymentAnalysis = viewModel.paymentAnalysis!;
        final totalTransactions = paymentAnalysis.totalTransactions ?? 0;
        final totalAmount = paymentAnalysis.totalAmount ?? 0.0;
        final chartData = paymentAnalysis.chartData ?? [];

        final activeCategories =
            chartData.where((method) => (method.count ?? 0) > 0).toList();

        final pieChartSections = activeCategories.map((method) {
          return PieChartSectionData(
            value: (method.count ?? 0).toDouble(),
            color: _getPaymentMethodColor(method.method),
            title: '',
            radius: 40,
            showTitle: false,
          );
        }).toList();

        final legendItemsForRow = chartData.map((method) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  width: 10,
                  height: 10,
                  color: _getPaymentMethodColor(method.method)),
              const SizedBox(width: 4),
              Text(method.method ?? strings.labelUnknown,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: context.textSecondaryColor)),
            ],
          );
        }).toList();

        return _buildCard(
          title: strings.cardPaymentMethodAnalysis,
          height: cardHeight,
          child: Column(
            children: [
              SizedBox(
                height: 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (pieChartSections.isNotEmpty)
                      PieChart(
                        PieChartData(
                          sections: pieChartSections,
                          centerSpaceRadius: 60,
                          sectionsSpace: 2,
                          startDegreeOffset: -90,
                        ),
                      ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          formatNumber(totalTransactions),
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: context.textPrimaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          strings.labelTotalTransactions,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: context.textSecondaryColor),
                        ),
                        Text(
                          formatNumber(totalAmount, showCurrency: true),
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: context.textSecondaryColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              if (legendItemsForRow.isNotEmpty)
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12.0,
                  runSpacing: 4.0,
                  children: legendItemsForRow,
                ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: chartData.length,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: context.inputBorderColor.withOpacity(0.5)),
                  itemBuilder: (context, index) {
                    final method = chartData[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            method.method ?? strings.labelUnknown,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: _getPaymentMethodColor(method.method),
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          Text(
                            '${formatNumber(method.count)} ${strings.labelTransactionsLowerCase} (${formatNumber(method.amount, showCurrency: true)})',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: context.textPrimaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getPaymentMethodColor(String? method) {
    switch (method?.toLowerCase()) {
      case 'card':
        return context.chartPrimaryColor;
      case 'upi':
        return AppColors.success;
      case 'cash':
        return AppColors.warning;
      case 'other':
        return context.chartTertiaryColor;
      default:
        return context.textSecondaryColor.withOpacity(0.5);
    }
  }
}

extension BookingStatsExtension on BookingStats {
  double? get percentageChangeReserved => null;
  double? get percentageChangeCancelled => null;
  double? get percentageChangeNoShow => null;
}
