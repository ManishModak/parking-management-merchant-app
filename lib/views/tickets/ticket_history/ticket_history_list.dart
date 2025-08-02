import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/app_theme.dart';
import '../../../../utils/components/appbar.dart';
import '../../../../utils/components/button.dart';
import '../../../../utils/components/form_field.dart';
import '../../../../utils/components/pagination_controls.dart';
import '../../../generated/l10n.dart';
import '../../../models/plaza_fare.dart';
import '../../../utils/components/pagination_mixin.dart';
import '../../../utils/exceptions.dart';
import '../../../viewmodels/ticket/open_ticket_viewmodel.dart';
import '../open_ticket/view_open_ticket.dart';
import 'view_ticket.dart';
import '../../../viewmodels/ticket/ticket_history_viewmodel.dart';
import '../../../services/storage/secure_storage_service.dart';
import '../../../services/core/plaza_service.dart';

class TicketHistoryScreen extends StatefulWidget {
  const TicketHistoryScreen({super.key});

  @override
  State<TicketHistoryScreen> createState() => _TicketHistoryScreenState();
}

class _TicketHistoryScreenState extends State<TicketHistoryScreen>
    with RouteAware, PaginatedListMixin<Map<String, dynamic>> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  late TicketHistoryViewModel _viewModel;
  late RouteObserver<ModalRoute> _routeObserver;
  String _searchQuery = '';
  int _currentPage = 1;
  Timer? _debounce;
  bool _isInitialized = false;

  final Set<String> _selectedStatuses = {};
  final Set<String> _selectedVehicleTypes = {};
  final Set<String> _selectedPlazaNames = {};
  final Set<String> _selectedDisputeStatuses = {};
  DateTimeRange? _selectedDateRange;

  // Add services for role-based plaza filtering
  final SecureStorageService _secureStorageService = SecureStorageService();
  final PlazaService _plazaService = PlazaService();
  List<String> _availablePlazaNames = [];

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<TicketHistoryViewModel>(context, listen: false);
    _setDefaultDateRange();
    _loadAvailablePlazaNames(); // Load role-based plaza names

    _searchController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _searchQuery = _searchController.text.toLowerCase();
            _currentPage = 1;
          });
        }
      });
    });

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!_isInitialized) {
        _loadInitialData();
      }
    });
  }

  // Add method to load available plaza names based on user role
  Future<void> _loadAvailablePlazaNames() async {
    try {
      final userRole = await _secureStorageService.getUserRole();
      developer.log('Loading plaza names for role: $userRole',
          name: 'TicketHistoryScreen');

      if (userRole == 'Plaza Owner') {
        // For Plaza Owner, use PlazaService to fetch user plazas
        final entityId = await _secureStorageService.getEntityId();
        if (entityId != null) {
          final plazas = await _plazaService.fetchUserPlazas(entityId);
          _availablePlazaNames = plazas
              .map((plaza) => plaza.plazaName ?? 'Unnamed Plaza')
              .where((name) => name.isNotEmpty)
              .toSet()
              .toList()
            ..sort();
          developer.log(
              'Loaded ${_availablePlazaNames.length} plaza names for Plaza Owner',
              name: 'TicketHistoryScreen');
        }
      } else {
        // For other roles, get plaza names from user's subEntity data
        final userData = await _secureStorageService.getUserData();
        if (userData != null && userData['subEntity'] != null) {
          final subEntity = userData['subEntity'] as List<dynamic>;
          _availablePlazaNames = subEntity
              .map((entity) => entity['plazaName']?.toString() ?? '')
              .where((name) => name.isNotEmpty)
              .toSet()
              .toList()
            ..sort();
          developer.log(
              'Loaded ${_availablePlazaNames.length} plaza names from subEntity for role: $userRole',
              name: 'TicketHistoryScreen');
        }
      }
    } catch (e) {
      developer.log('Error loading available plaza names: $e',
          name: 'TicketHistoryScreen');
      // Fallback to existing ticket-based plaza names if role-based loading fails
      _availablePlazaNames = _viewModel.tickets
          .map((t) => t['plazaName']?.toString().trim() ?? '')
          .where((name) => name.isNotEmpty)
          .toSet()
          .toList()
        ..sort();
    }
  }

  String _formatDateTimeForDisplayInScreen(DateTime? utcTime) {
    if (utcTime == null) return 'N/A';
    final DateTime ensuredUtcTime = utcTime.isUtc ? utcTime : utcTime.toUtc();
    final DateTime istEquivalentTime =
        ensuredUtcTime.add(const Duration(hours: 5, minutes: 30));
    final DateTime localRepresentationOfIst = DateTime(
      istEquivalentTime.year,
      istEquivalentTime.month,
      istEquivalentTime.day,
      istEquivalentTime.hour,
      istEquivalentTime.minute,
      istEquivalentTime.second,
      istEquivalentTime.millisecond,
      istEquivalentTime.microsecond,
    );
    return DateFormat('dd MMM, hh:mm a').format(localRepresentationOfIst);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _routeObserver = Provider.of<RouteObserver<ModalRoute>>(context);
    final route = ModalRoute.of(context);
    if (route != null) {
      _routeObserver.subscribe(this, route);
    }

    if (!_isInitialized && ModalRoute.of(context)?.isCurrent == true) {
      final args = ModalRoute.of(context)?.settings.arguments;
      bool filtersAppliedFromArgs = false;
      if (args is Map<String, dynamic>?) {
        if (args?['statusFilter'] == 'complete') {
          _selectedStatuses.add('completed');
          filtersAppliedFromArgs = true;
        }
        if (args?['disputeStatusFilter'] == 'not raised') {
          _selectedDisputeStatuses.add('not raised');
          filtersAppliedFromArgs = true;
        }
      } else {
        developer.log('Unexpected arguments type: ${args.runtimeType}',
            name: 'TicketHistoryScreen.didChange');
      }

      _isInitialized = true;
      if (filtersAppliedFromArgs) {
        _currentPage = 1;
        SchedulerBinding.instance.addPostFrameCallback((_) => _refreshData());
      } else {
        if (_viewModel.tickets.isEmpty && !_viewModel.isLoading) {
          SchedulerBinding.instance.addPostFrameCallback((_) => _loadInitialData());
        }
      }
    }
  }

  void _setDefaultDateRange() {
    final now = DateTime.now();
    _selectedDateRange = DateTimeRange(
      start: DateTime(now.year, now.month, now.day, 0, 0, 0),
      end: DateTime(now.year, now.month, now.day, 23, 59, 59, 999, 999),
    );
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;
    await _viewModel.fetchTicketHistory();
    await _loadAvailablePlazaNames(); // Ensure plaza names are loaded after tickets
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
    await _viewModel.fetchTicketHistory();
    await _loadAvailablePlazaNames(); // Refresh plaza names when data is refreshed
  }

  List<Map<String, dynamic>> _getFilteredTickets(
      List<Map<String, dynamic>> tickets) {
    return tickets.where((ticket) {
      final entryTimeUtc = ticket['entryTime'];
      final entryTimeStringForSearch = entryTimeUtc != null
          ? _formatDateTimeForDisplayInScreen(entryTimeUtc)
          : '';

      final matchesSearch = _searchQuery.isEmpty ||
          (ticket['ticketId']
                  ?.toString()
                  .toLowerCase()
                  .contains(_searchQuery) ??
              false) ||
          (ticket['plazaId']?.toString().toLowerCase().contains(_searchQuery) ??
              false) ||
          (ticket['vehicleNumber']
                  ?.toString()
                  .toLowerCase()
                  .contains(_searchQuery) ??
              false) ||
          (ticket['vehicleType']
                  ?.toString()
                  .toLowerCase()
                  .contains(_searchQuery) ??
              false) ||
          (ticket['plazaName']
                  ?.toString()
                  .toLowerCase()
                  .contains(_searchQuery) ??
              false) ||
          (ticket['ticketStatus']
                  ?.toString()
                  .toLowerCase()
                  .contains(_searchQuery) ??
              false) ||
          (ticket['disputeStatus']
                  ?.toString()
                  .toLowerCase()
                  .contains(_searchQuery) ??
              false) ||
          entryTimeStringForSearch.toLowerCase().contains(_searchQuery);

      final ticketStatus =
          ticket['ticketStatus']?.toString().toLowerCase() ?? '';
      final matchesStatus =
          _selectedStatuses.isEmpty || _selectedStatuses.contains(ticketStatus);

      final disputeStatus =
          ticket['disputeStatus']?.toString().toLowerCase() ?? '';
      final matchesDisputeStatus = _selectedDisputeStatuses.isEmpty ||
          _selectedDisputeStatuses.contains(disputeStatus);

      final matchesVehicleType = _selectedVehicleTypes.isEmpty ||
          _selectedVehicleTypes
              .contains(ticket['vehicleType']?.toString().toLowerCase());

      final matchesPlazaName = _selectedPlazaNames.isEmpty ||
          _selectedPlazaNames
              .contains(ticket['plazaName']?.toString().toLowerCase());

      final matchesDate = _selectedDateRange == null ||
          (entryTimeUtc != null &&
              !entryTimeUtc.isBefore(_selectedDateRange!.start) &&
              !entryTimeUtc.isAfter(_selectedDateRange!.end));

      return matchesSearch &&
          matchesStatus &&
          matchesVehicleType &&
          matchesPlazaName &&
          matchesDisputeStatus &&
          matchesDate;
    }).toList();
  }

  void _updatePage(int newPage) {
    final filteredTickets = _getFilteredTickets(_viewModel.tickets);
    updatePage(newPage, filteredTickets, (page) {
      if (mounted) setState(() => _currentPage = page);
    });
  }

  Widget _buildDateFilterChip(S strings) {
    String displayText;
    if (_selectedDateRange == null) {
      displayText = strings.dateRangeLabel;
    } else if (_isTodayRange(_selectedDateRange!)) {
      displayText = strings.todayLabel;
    } else if (_isYesterdayRange(_selectedDateRange!)) {
      displayText = strings.yesterdayLabel;
    } else if (_isLast7DaysRange(_selectedDateRange!)) {
      displayText = strings.last7DaysLabel;
    } else if (_isLast30DaysRange(_selectedDateRange!)) {
      displayText = strings.last30DaysLabel;
    } else {
      displayText =
          '${DateFormat('dd MMM').format(_selectedDateRange!.start)} - ${DateFormat('dd MMM').format(_selectedDateRange!.end)}';
    }
    final textColor = context.textPrimaryColor;
    final isActive = _selectedDateRange != null;

    return GestureDetector(
      onTap: _showDateFilterDialog,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withOpacity(0.1)
              : context.secondaryCardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today,
                color: isActive ? AppColors.primary : textColor, size: 16),
            const SizedBox(width: 6),
            Text(displayText,
                style: TextStyle(
                    color: isActive ? AppColors.primary : textColor,
                    fontWeight:
                        isActive ? FontWeight.w600 : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreFiltersChip(S strings) {
    final hasActiveFilters = _selectedStatuses.isNotEmpty ||
        _selectedVehicleTypes.isNotEmpty ||
        _selectedPlazaNames.isNotEmpty ||
        _selectedDisputeStatuses.isNotEmpty;
    final textColor = context.textPrimaryColor;
    return GestureDetector(
      onTap: _showAllFiltersDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: hasActiveFilters
              ? AppColors.primary.withOpacity(0.1)
              : context.secondaryCardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.filter_list,
                color: hasActiveFilters ? AppColors.primary : textColor,
                size: 16),
            const SizedBox(width: 6),
            Text(strings.filtersLabel,
                style: TextStyle(
                    color: hasActiveFilters ? AppColors.primary : textColor,
                    fontWeight: hasActiveFilters
                        ? FontWeight.w600
                        : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  bool _hasAnyActiveFilter() {
    return _selectedDateRange != null ||
        _selectedStatuses.isNotEmpty ||
        _selectedVehicleTypes.isNotEmpty ||
        _selectedPlazaNames.isNotEmpty ||
        _selectedDisputeStatuses.isNotEmpty;
  }

  Widget _buildFilterChipsRow(S strings) {
    final selectedFilters = [
      ..._selectedStatuses
          .map((s) => '${strings.statusLabel}: ${s.capitalize()}'),
      ..._selectedVehicleTypes
          .map((v) => '${strings.vehicleLabel}: ${v.capitalize()}'),
      ..._selectedPlazaNames.map((p) => '${strings.plazaLabel}: $p'),
      ..._selectedDisputeStatuses
          .map((d) => '${strings.disputeStatusLabel}: ${d.capitalize()}'),
    ];
    final textColor = context.textPrimaryColor;

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Row(
            children: [
              if (_hasAnyActiveFilter()) ...[
                GestureDetector(
                  onTap: () {
                    if (mounted) {
                      setState(() {
                        _selectedStatuses.clear();
                        _selectedVehicleTypes.clear();
                        _selectedPlazaNames.clear();
                        _selectedDisputeStatuses.clear();
                        _selectedDateRange = null;
                        _currentPage = 1;
                      });
                    }
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                        color: context.secondaryCardColor,
                        borderRadius: BorderRadius.circular(12)),
                    child: Text(strings.resetAllLabel,
                        style: TextStyle(
                            color: textColor, fontWeight: FontWeight.normal)),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              _buildDateFilterChip(strings),
              _buildMoreFiltersChip(strings),
              if (selectedFilters.isNotEmpty) ...[
                const SizedBox(width: 8),
                ...selectedFilters.map((filter) => Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text(filter),
                        onDeleted: () {
                          if (mounted) {
                            setState(() {
                              if (filter
                                  .startsWith('${strings.statusLabel}:')) {
                                _selectedStatuses.remove(
                                    filter.split(': ')[1].toLowerCase());
                              } else if (filter
                                  .startsWith('${strings.vehicleLabel}:')) {
                                _selectedVehicleTypes.remove(
                                    filter.split(': ')[1].toLowerCase());
                              } else if (filter
                                  .startsWith('${strings.plazaLabel}:')) {
                                _selectedPlazaNames
                                    .remove(filter.split(': ')[1]);
                              } else if (filter.startsWith(
                                  '${strings.disputeStatusLabel}:')) {
                                _selectedDisputeStatuses.remove(
                                    filter.split(': ')[1].toLowerCase());
                              }
                              _currentPage = 1;
                            });
                          }
                        },
                        deleteIcon: const Icon(Icons.close, size: 16),
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        labelStyle: const TextStyle(color: AppColors.primary),
                        deleteIconColor: AppColors.primary,
                      ),
                    )),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showAllFiltersDialog() {
    final strings = S.of(context);
    // Use role-based plaza names instead of ticket-based plaza names
    final plazaNames = _availablePlazaNames.isNotEmpty
        ? _availablePlazaNames
        : _viewModel.tickets
            .map((t) => t['plazaName']?.toString().trim() ?? '')
            .where((name) => name.isNotEmpty)
            .toSet()
            .toList()
      ..sort((a, b) => a.compareTo(b));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(builder: (context, setDialogState) {
        return Container(
          decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20))),
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.grey[300]
                            : Colors.grey[600],
                        borderRadius: BorderRadius.circular(10))),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(strings.advancedFiltersLabel,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimaryColor)),
              ),
              Expanded(
                child: ListView(
                  children: [
                    _buildFilterSection(
                      title: strings.ticketStatusLabel,
                      options: [
                        {'key': 'open', 'label': strings.openTicketsLabel},
                        {
                          'key': 'rejected',
                          'label': strings.rejectedTicketsLabel
                        },
                        {
                          'key': 'completed',
                          'label': strings.completedTicketsLabel
                        },
                      ],
                      selectedItems: _selectedStatuses,
                      onChanged: (value, isSelected) => setDialogState(() {
                        if (isSelected) {
                          _selectedStatuses.add(value);
                        } else {
                          _selectedStatuses.remove(value);
                        }
                      }),
                    ),
                    _buildFilterSection(
                      title: strings.vehicleTypeLabel,
                      options: VehicleTypes.values
                          .map((e) =>
                              {'key': e.toLowerCase(), 'label': e.capitalize()})
                          .toList(),
                      selectedItems: _selectedVehicleTypes,
                      onChanged: (value, isSelected) => setDialogState(() {
                        if (isSelected) {
                          _selectedVehicleTypes.add(value);
                        } else {
                          _selectedVehicleTypes.remove(value);
                        }
                      }),
                    ),
                    _buildFilterSection(
                      title: strings.disputeStatusLabel,
                      options: [
                        {'key': 'not raised', 'label': strings.notRaisedLabel},
                        {'key': 'raised', 'label': strings.raisedLabel},
                      ],
                      selectedItems: _selectedDisputeStatuses,
                      onChanged: (value, isSelected) => setDialogState(() {
                        if (isSelected) {
                          _selectedDisputeStatuses.add(value);
                        } else {
                          _selectedDisputeStatuses.remove(value);
                        }
                      }),
                    ),
                    _buildSearchableFilterSection(
                      title: strings.plazaNameLabel,
                      options: plazaNames,
                      selectedItems: _selectedPlazaNames,
                      onChanged: (value, isSelected) => setDialogState(() {
                        if (isSelected) {
                          _selectedPlazaNames.add(value);
                        } else {
                          _selectedPlazaNames.remove(value);
                        }
                      }),
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
                            onPressed: () => setDialogState(() {
                                  _selectedStatuses.clear();
                                  _selectedVehicleTypes.clear();
                                  _selectedPlazaNames.clear();
                                  _selectedDisputeStatuses.clear();
                                }),
                            context: context)),
                    const SizedBox(width: 16),
                    Expanded(
                        child: CustomButtons.primaryButton(
                            height: 40,
                            text: strings.applyLabel,
                            onPressed: () {
                              if (mounted) setState(() => _currentPage = 1);
                              Navigator.pop(context);
                            },
                            context: context)),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildFilterSection(
      {required String title,
      required List<Map<String, String>> options,
      required Set<String> selectedItems,
      required Function(String, bool) onChanged}) {
    final textColor = context.textPrimaryColor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Text(title,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor))),
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
                onSelected: (bool value) => onChanged(option['key']!, value),
                selectedColor: AppColors.primary.withOpacity(0.2),
                checkmarkColor: isSelected ? AppColors.primary : textColor,
                backgroundColor: context.secondaryCardColor,
                labelStyle: TextStyle(
                    color: isSelected
                        ? AppColors.primary
                        : (Theme.of(context).brightness == Brightness.light
                            ? Colors.grey[700]
                            : Colors.grey[400]),
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal),
                shape: StadiumBorder(
                    side: BorderSide(
                        color: isSelected
                            ? AppColors.primary
                            : (Theme.of(context).brightness == Brightness.light
                                ? Colors.grey[400]!
                                : Colors.grey[700]!))),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        Divider(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.grey[300]
                : Colors.grey[600]),
      ],
    );
  }

  Widget _buildSearchableFilterSection(
      {required String title,
      required List<String> options,
      required Set<String> selectedItems,
      required Function(String, bool) onChanged}) {
    final strings = S.of(context);
    final TextEditingController searchController = TextEditingController();
    List<String> filteredOptions = List.from(options);
    final textColor = context.textPrimaryColor;

    return StatefulBuilder(builder: (context, setLocalState) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Text(title,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor))),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                  hintText: strings.searchPlazaHint,
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.search, color: textColor),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[300]!)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[300]!)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.primary))),
              style: TextStyle(color: textColor),
              onChanged: (value) => setLocalState(() {
                filteredOptions = options
                    .where((option) =>
                        option.toLowerCase().contains(value.toLowerCase()))
                    .toList();
              }),
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: filteredOptions.map((option) {
                    final isSelected = selectedItems.contains(option);
                    return FilterChip(
                      label: Text(option),
                      selected: isSelected,
                      onSelected: (bool value) => onChanged(option, value),
                      selectedColor: AppColors.primary.withOpacity(0.2),
                      checkmarkColor:
                          isSelected ? AppColors.primary : textColor,
                      backgroundColor: context.secondaryCardColor,
                      labelStyle: TextStyle(
                          color: isSelected
                              ? AppColors.primary
                              : (Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Colors.grey[700]
                                  : Colors.grey[400]),
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal),
                      shape: StadiumBorder(
                          side: BorderSide(
                              color: isSelected
                                  ? AppColors.primary
                                  : (Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.grey[400]!
                                      : Colors.grey[700]!))),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Divider(
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.grey[300]
                  : Colors.grey[600]),
        ],
      );
    });
  }

  Widget _buildSearchField(S strings) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.95,
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
                  hintText: strings.searchTicketHistoryHint,
                  context: context),
              const SizedBox(height: 8),
              Text(
                  '${strings.lastUpdated}: ${DateFormat('dd MMM, hh:mm a').format(DateTime.now())}. ${strings.swipeToRefresh}',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey[400]),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Future<DateTimeRange?> _selectCustomDateRange(
      BuildContext context, DateTimeRange? initialRange) async {
    final strings = S.of(context);
    final earliestDate = DateTime.now().subtract(const Duration(days: 365 * 5));
    final latestDate = DateTime.now();

    final picked = await showDateRangePicker(
      context: context,
      firstDate: earliestDate,
      lastDate: latestDate,
      initialDateRange: initialRange,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: AppColors.primary,
                onPrimary: Colors.white,
                surface: context.cardColor,
                onSurface: context.textPrimaryColor),
            textTheme: Theme.of(context).textTheme.apply(
                bodyColor: context.textPrimaryColor,
                displayColor: context.textPrimaryColor),
            textButtonTheme: TextButtonThemeData(
                style:
                    TextButton.styleFrom(foregroundColor: AppColors.primary)),
            dialogTheme: DialogThemeData(backgroundColor: context.cardColor)),
        child: child!,
      ),
    );
    if (picked == null) return null;
    final start =
        picked.start.isBefore(earliestDate) ? earliestDate : picked.start;
    var end = picked.end.isAfter(latestDate) ? latestDate : picked.end;
    end = DateTime(end.year, end.month, end.day, 23, 59, 59, 999, 999);
    const maxAllowedRange = Duration(days: 365);
    if (end.difference(start) > maxAllowedRange) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(strings.dateRangeTooLongWarning),
            backgroundColor: Colors.red));
      }
      return null;
    }
    return DateTimeRange(start: start, end: end);
  }

  void _showDateFilterDialog() {
    final strings = S.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        DateTimeRange? tempDateRange = _selectedDateRange;
        String? selectedOption = _getSelectedOption(tempDateRange);
        final textColor = context.textPrimaryColor;
        return StatefulBuilder(builder: (context, setDialogState) {
          return Container(
            decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20))),
            height: MediaQuery.of(context).size.height * 0.45,
            child: Column(
              children: [
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Colors.grey[300]
                                    : Colors.grey[600],
                            borderRadius: BorderRadius.circular(10)))),
                Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Text(strings.selectDateRangeLabel,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textColor))),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildQuickDateChip(
                                label: strings.todayLabel,
                                isSelected: selectedOption == 'Today',
                                onTap: () => setDialogState(() {
                                      final now = DateTime.now();
                                      tempDateRange = DateTimeRange(
                                          start: DateTime(
                                              now.year, now.month, now.day),
                                          end: DateTime(now.year, now.month,
                                              now.day, 23, 59, 59, 999, 999));
                                      selectedOption = 'Today';
                                    })),
                            const SizedBox(width: 8),
                            _buildQuickDateChip(
                                label: strings.yesterdayLabel,
                                isSelected: selectedOption == 'Yesterday',
                                onTap: () => setDialogState(() {
                                      final yesterday = DateTime.now()
                                          .subtract(const Duration(days: 1));
                                      tempDateRange = DateTimeRange(
                                          start: DateTime(yesterday.year,
                                              yesterday.month, yesterday.day),
                                          end: DateTime(
                                              yesterday.year,
                                              yesterday.month,
                                              yesterday.day,
                                              23,
                                              59,
                                              59,
                                              999,
                                              999));
                                      selectedOption = 'Yesterday';
                                    })),
                            const SizedBox(width: 8),
                            _buildQuickDateChip(
                                label: strings.last7DaysLabel,
                                isSelected: selectedOption == 'Last 7 Days',
                                onTap: () => setDialogState(() {
                                      final now = DateTime.now();
                                      tempDateRange = DateTimeRange(
                                          start: DateTime(
                                                  now.year, now.month, now.day)
                                              .subtract(
                                                  const Duration(days: 6)),
                                          end: DateTime(now.year, now.month,
                                              now.day, 23, 59, 59, 999, 999));
                                      selectedOption = 'Last 7 Days';
                                    })),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildQuickDateChip(
                                label: strings.last30DaysLabel,
                                isSelected: selectedOption == 'Last 30 Days',
                                onTap: () => setDialogState(() {
                                      final now = DateTime.now();
                                      tempDateRange = DateTimeRange(
                                          start: DateTime(
                                                  now.year, now.month, now.day)
                                              .subtract(
                                                  const Duration(days: 29)),
                                          end: DateTime(now.year, now.month,
                                              now.day, 23, 59, 59, 999, 999));
                                      selectedOption = 'Last 30 Days';
                                    })),
                            const SizedBox(width: 8),
                            _buildQuickDateChip(
                                label: strings.customLabel,
                                isSelected: selectedOption == 'Custom',
                                onTap: () async {
                                  final picked = await _selectCustomDateRange(
                                      context, tempDateRange);
                                  if (picked != null) {
                                    setDialogState(() {
                                      tempDateRange = picked;
                                      selectedOption = 'Custom';
                                    });
                                  }
                                }),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (selectedOption == 'Custom' && tempDateRange != null)
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Text(
                          '${strings.selectedRangeLabel}: ${DateFormat('dd MMM yyyy').format(tempDateRange!.start)} - ${DateFormat('dd MMM yyyy').format(tempDateRange!.end)}',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: textColor))),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                          child: CustomButtons.secondaryButton(
                              height: 40,
                              text: strings.clearLabel,
                              onPressed: () => setDialogState(() {
                                    tempDateRange = null;
                                    selectedOption = null;
                                  }),
                              context: context)),
                      const SizedBox(width: 16),
                      Expanded(
                          child: CustomButtons.primaryButton(
                              height: 40,
                              text: strings.applyLabel,
                              onPressed: () {
                                if (mounted) {
                                  setState(() {
                                    _selectedDateRange = tempDateRange;
                                    _currentPage = 1;
                                  });
                                }
                                Navigator.pop(context);
                              },
                              context: context)),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  String? _getSelectedOption(DateTimeRange? range) {
    if (range == null) return null;
    if (_isTodayRange(range)) return 'Today';
    if (_isYesterdayRange(range)) return 'Yesterday';
    if (_isLast7DaysRange(range)) return 'Last 7 Days';
    if (_isLast30DaysRange(range)) return 'Last 30 Days';
    return 'Custom';
  }

  Widget _buildQuickDateChip(
      {required String label,
      required bool isSelected,
      required VoidCallback onTap}) {
    final textColor = context.textPrimaryColor;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.2)
                : context.secondaryCardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : (Theme.of(context).brightness == Brightness.light
                        ? Colors.grey[400]!
                        : Colors.grey[700]!),
                width: 1)),
        child: Text(label,
            style: TextStyle(
                color: isSelected ? AppColors.primary : textColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isTodayRange(DateTimeRange range) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd =
        DateTime(now.year, now.month, now.day, 23, 59, 59, 999, 999);
    return _isSameDay(range.start, todayStart) &&
        _isSameDay(range.end, todayEnd);
  }

  bool _isYesterdayRange(DateTimeRange range) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdayStart =
        DateTime(yesterday.year, yesterday.month, yesterday.day);
    final yesterdayEnd = DateTime(
        yesterday.year, yesterday.month, yesterday.day, 23, 59, 59, 999, 999);
    return _isSameDay(range.start, yesterdayStart) &&
        _isSameDay(range.end, yesterdayEnd);
  }

  bool _isLast7DaysRange(DateTimeRange range) {
    final now = DateTime.now();
    final sevenDaysAgoStart = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 6));
    final todayEnd =
        DateTime(now.year, now.month, now.day, 23, 59, 59, 999, 999);
    return _isSameDay(range.start, sevenDaysAgoStart) &&
        _isSameDay(range.end, todayEnd);
  }

  bool _isLast30DaysRange(DateTimeRange range) {
    final now = DateTime.now();
    final thirtyDaysAgoStart = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 29));
    final todayEnd =
        DateTime(now.year, now.month, now.day, 23, 59, 59, 999, 999);
    return _isSameDay(range.start, thirtyDaysAgoStart) &&
        _isSameDay(range.end, todayEnd);
  }

  Widget _buildTicketCard(Map<String, dynamic> ticket, S strings) {
    final rawCreatedTimeUtc = ticket['ticketCreationTime'] as DateTime?;
    String formattedCreatedTime =
        _formatDateTimeForDisplayInScreen(rawCreatedTimeUtc);
    Color statusColor;
    final ticketStatus = ticket['ticketStatus']?.toString().toLowerCase() ?? '';
    switch (ticketStatus) {
      case 'open':
        statusColor = AppColors.success;
        break;
      case 'rejected':
        statusColor = AppColors.error;
        break;
      case 'completed':
        statusColor = AppColors.info;
        break;
      default:
        statusColor = AppColors.warning;
    }

    return Column(
      children: [
        SizedBox(
          height: 8,
        ),
        Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          elevation: Theme.of(context).cardTheme.elevation,
          color: context.secondaryCardColor,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: statusColor.withOpacity(0.2), width: 1)),
          child: InkWell(
            onTap: () {
              if (ticketStatus == 'open') {
                Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChangeNotifierProvider(
                                create: (_) => OpenTicketViewModel(),
                                child: ViewOpenTicketScreen(
                                    ticketId: ticket['ticketId'].toString(),
                                    isEditable: false))))
                    .then((_) => _refreshData());
              } else {
                Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChangeNotifierProvider<
                                    TicketHistoryViewModel>.value(
                                value: _viewModel,
                                child: ViewTicketScreen(
                                    ticketId: ticket['ticketId'].toString()))))
                    .then((_) => _refreshData());
              }
            },
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 8.0, right: 4, top: 8, bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            '${ticket['plazaName']?.toString() ?? strings.naLabel} | ${ticket['entryLaneId']?.toString() ?? strings.naLabel} | ${ticket['ticketRefId']?.toString() ?? strings.naLabel}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: context.textPrimaryColor),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 6),
                        Text(
                            '${ticket['vehicleNumber']?.toString() ?? strings.naLabel} | ${ticket['vehicleType']?.toString() ?? strings.naLabel} | $formattedCreatedTime',
                            style: TextStyle(
                                color: context.textPrimaryColor, fontSize: 14),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                        if (ticket['remarks']?.isNotEmpty ?? false)
                          Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text('Remarks: ${ticket['remarks']}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic))),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 75,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10)),
                            child: Text(ticketStatus.capitalize(),
                                style: TextStyle(
                                    color: statusColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600))),
                        const SizedBox(height: 8),
                        Icon(Icons.chevron_right,
                            color: Theme.of(context)
                                .iconTheme
                                .color
                                ?.withOpacity(0.7),
                            size: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: 10,
      itemBuilder: (context, index) => Shimmer.fromColors(
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
                      Container(
                          width: 150, height: 18, color: context.cardColor),
                      const SizedBox(height: 4),
                      Container(
                          width: 100, height: 14, color: context.cardColor),
                      const SizedBox(height: 4),
                      Container(
                          width: 120, height: 14, color: context.cardColor)
                    ])),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(S strings) {
    String errorTitle = strings.errorUnableToLoadTicketsHistory;
    String errorMessage = strings.errorGeneric;
    final error = _viewModel.error;
    if (error != null) {
      if (error is NoInternetException) {
        errorTitle = strings.errorNoInternet;
        errorMessage = strings.errorNoInternetMessage;
      } else if (error is RequestTimeoutException) {
        errorTitle = strings.errorRequestTimeout;
        errorMessage = strings.errorRequestTimeoutMessage;
      } else if (error is HttpException) {
        errorTitle = strings.errorServerError;
        errorMessage = strings
            .errorServerErrorMessage; /* Could add switch for status codes */
      } else if (error is ServiceException) {
        errorTitle = strings.errorUnexpected;
        errorMessage = strings.errorUnexpectedMessage;
      } else {
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
          Text(errorTitle,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimaryColor)),
          const SizedBox(height: 8),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(errorMessage,
                  style:
                      TextStyle(fontSize: 16, color: context.textPrimaryColor),
                  textAlign: TextAlign.center)),
          const SizedBox(height: 24),
          CustomButtons.primaryButton(
              height: 40,
              width: 150,
              text: strings.buttonRetry,
              onPressed: _refreshData,
              context: context),
        ],
      ),
    );
  }

  Widget _buildEmptyState(S strings) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off, size: 50, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(strings.noTicketsFoundLabel,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: context.textPrimaryColor)),
          const SizedBox(height: 8),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(strings.adjustFiltersMessage,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey[400]),
                  textAlign: TextAlign.center)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    return Consumer<TicketHistoryViewModel>(
      builder: (context, viewModel, _) {
        final filteredTickets = _getFilteredTickets(viewModel.tickets);
        final totalPages = getTotalPages(filteredTickets);
        final paginatedTickets =
            getPaginatedItems(filteredTickets, _currentPage);

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: CustomAppBar.appBarWithNavigationAndActions(
              screenTitle: strings.titleTicketHistory,
              onPressed: () => Navigator.pop(context),
              darkBackground: Theme.of(context).brightness == Brightness.dark,
              actions: [],
              context: context),
          body: Column(
            children: [
              const SizedBox(height: 4),
              _buildFilterChipsRow(strings),
              _buildSearchField(strings),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshData,
                  color: Theme.of(context).colorScheme.primary,
                  child: Stack(
                    children: [
                      if (viewModel.isLoading)
                        Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: _buildShimmerList())
                      else if (viewModel.error != null &&
                          !viewModel.isLoading &&
                          viewModel.tickets.isEmpty)
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: _buildErrorState(strings))
                      else if (filteredTickets.isEmpty && !viewModel.isLoading)
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: _buildEmptyState(strings))
                      else
                        ListView.builder(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: paginatedTickets.length,
                          padding: const EdgeInsets.all(8.0),
                          itemBuilder: (context, index) => _buildTicketCard(
                              paginatedTickets[index], strings),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: filteredTickets.isNotEmpty &&
                  !viewModel.isLoading &&
                  totalPages > 1
              ? Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  padding: const EdgeInsets.all(4.0),
                  child: SafeArea(
                      child: PaginationControls(
                          currentPage: _currentPage,
                          totalPages: totalPages,
                          onPageChange: _updatePage)))
              : null,
        );
      },
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
