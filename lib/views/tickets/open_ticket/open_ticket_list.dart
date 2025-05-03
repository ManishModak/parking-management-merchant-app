import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:merchant_app/config/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../config/app_colors.dart';
import '../../../../utils/components/appbar.dart';
import '../../../../utils/components/button.dart';
import '../../../../utils/components/form_field.dart';
import '../../../../utils/components/pagination_controls.dart';
import '../../../generated/l10n.dart';
import '../../../models/ticket.dart';
import '../../../utils/exceptions.dart';
import '../../../viewmodels/ticket/open_ticket_viewmodel.dart';
import 'view_open_ticket.dart';

class OpenTicketsScreen extends StatefulWidget {
  const OpenTicketsScreen({super.key});

  @override
  State<OpenTicketsScreen> createState() => _OpenTicketsScreenState();
}

class _OpenTicketsScreenState extends State<OpenTicketsScreen> with RouteAware {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  late OpenTicketViewModel _viewModel;
  late RouteObserver<ModalRoute> _routeObserver;
  String _searchQuery = '';
  DateTimeRange? _selectedDateRange;
  int _currentPage = 1;
  static const int _itemsPerPage = 10;
  Timer? _debounce;

  Set<String> _selectedStatuses = {};
  Set<String> _selectedVehicleTypes = {};
  Set<String> _selectedPlazaNames = {};

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<OpenTicketViewModel>(context, listen: false);
    _setDefaultDateRange();
    _loadInitialData();
    _searchController.addListener(_debounceSearch);
  }

  void _debounceSearch() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
        _currentPage = 1;
        developer.log('Search query updated: $_searchQuery', name: 'OpenTicketsScreen');
      });
    });
  }

  void _setDefaultDateRange() {
    final now = DateTime.now();
    _selectedDateRange = DateTimeRange(
      start: DateTime(now.year, now.month, now.day),
      end: DateTime(now.year, now.month, now.day, 23, 59, 59),
    );
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _viewModel.fetchOpenTickets();
    });
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
    await _viewModel.fetchOpenTickets();
  }

  List<Map<String, dynamic>> _getFilteredTickets(List<Map<String, dynamic>> tickets) {
    var filtered = tickets;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((ticket) {
        return (ticket['ticketId']?.toString().toLowerCase().contains(_searchQuery) ?? false) ||
            (ticket['plazaId']?.toString().toLowerCase().contains(_searchQuery) ?? false) ||
            (ticket['vehicleNumber']?.toString().toLowerCase().contains(_searchQuery) ?? false) ||
            (ticket['vehicleType']?.toString().toLowerCase().contains(_searchQuery) ?? false) ||
            (ticket['plazaName']?.toString().toLowerCase().contains(_searchQuery) ?? false);
      }).toList();
    }

    if (_selectedDateRange != null) {
      filtered = filtered.where((ticket) {
        final entryTime = ticket['entryTime'];
        if (entryTime == null) return false;
        final inRange = entryTime.isAfter(_selectedDateRange!.start.subtract(const Duration(milliseconds: 1))) &&
            entryTime.isBefore(_selectedDateRange!.end.add(const Duration(milliseconds: 1)));
        return inRange;
      }).toList();
    }

    if (_selectedStatuses.isNotEmpty) {
      filtered = filtered.where((ticket) => _selectedStatuses.contains(ticket['ticketStatus']?.toString().toLowerCase())).toList();
    }
    if (_selectedVehicleTypes.isNotEmpty) {
      filtered = filtered.where((ticket) => _selectedVehicleTypes.contains(ticket['vehicleType']?.toString().toLowerCase())).toList();
    }
    if (_selectedPlazaNames.isNotEmpty) {
      filtered = filtered.where((ticket) => _selectedPlazaNames.contains(ticket['plazaName']?.toString().toLowerCase())).toList();
    }

    developer.log('Filtered tickets count: ${filtered.length}', name: 'OpenTicketsScreen');
    return filtered;
  }

  List<Map<String, dynamic>> _getPaginatedTickets(List<Map<String, dynamic>> filteredTickets) {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    return endIndex > filteredTickets.length ? filteredTickets.sublist(startIndex) : filteredTickets.sublist(startIndex, endIndex);
  }

  void _updatePage(int newPage) {
    final filteredTickets = _getFilteredTickets(_viewModel.tickets);
    final totalPages = (filteredTickets.length / _itemsPerPage).ceil();
    if (newPage < 1 || newPage > totalPages) return;
    setState(() {
      _currentPage = newPage;
      _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    });
  }

  Widget _buildDateFilterChip(S strings) {
    String displayText = _selectedDateRange == null
        ? strings.dateRangeLabel
        : _isTodayRange(_selectedDateRange!)
        ? strings.todayLabel
        : _isYesterdayRange(_selectedDateRange!)
        ? strings.yesterdayLabel
        : _isLast7DaysRange(_selectedDateRange!)
        ? strings.last7DaysLabel
        : _isLast30DaysRange(_selectedDateRange!)
        ? strings.last30DaysLabel
        : '${DateFormat('dd MMM').format(_selectedDateRange!.start)} - ${DateFormat('dd MMM').format(_selectedDateRange!.end)}';

    final textColor = context.textPrimaryColor;

    return GestureDetector(
      onTap: _showDateFilterDialog,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _selectedDateRange != null ? AppColors.primary.withOpacity(0.1) : context.secondaryCardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today, color: _selectedDateRange != null ? AppColors.primary : textColor, size: 16),
            const SizedBox(width: 6),
            Text(displayText,
                style: TextStyle(
                    color: _selectedDateRange != null ? AppColors.primary : textColor,
                    fontWeight: _selectedDateRange != null ? FontWeight.w600 : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreFiltersChip(S strings) {
    final hasActiveFilters = _selectedStatuses.isNotEmpty || _selectedVehicleTypes.isNotEmpty || _selectedPlazaNames.isNotEmpty;
    final textColor = context.textPrimaryColor;

    return GestureDetector(
      onTap: _showAllFiltersDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: hasActiveFilters ? AppColors.primary.withOpacity(0.1) : context.secondaryCardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.filter_list, color: hasActiveFilters ? AppColors.primary : textColor, size: 16),
            const SizedBox(width: 6),
            Text(strings.filtersLabel,
                style: TextStyle(
                    color: hasActiveFilters ? AppColors.primary : textColor,
                    fontWeight: hasActiveFilters ? FontWeight.w600 : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChipsRow(S strings) {
    final selectedFilters = [
      ..._selectedStatuses.map((s) => '${strings.statusLabel}: ${s.capitalize()}'),
      ..._selectedVehicleTypes.map((v) => '${strings.vehicleLabel}: ${v.capitalize()}'),
      ..._selectedPlazaNames.map((p) => '${strings.plazaLabel}: $p'),
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
              if (selectedFilters.isNotEmpty || _selectedDateRange != null) ...[
                GestureDetector(
                  onTap: () => setState(() {
                    _selectedStatuses.clear();
                    _selectedVehicleTypes.clear();
                    _selectedPlazaNames.clear();
                    _selectedDateRange = null;
                    _currentPage = 1;
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: context.secondaryCardColor, borderRadius: BorderRadius.circular(12)),
                    child: Text(strings.resetAllLabel, style: TextStyle(color: textColor, fontWeight: FontWeight.normal)),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              _buildDateFilterChip(strings),
              const SizedBox(width: 8),
              _buildMoreFiltersChip(strings),
              if (selectedFilters.isNotEmpty) ...[
                const SizedBox(width: 8),
                ...selectedFilters.map((filter) => Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: Chip(
                    label: Text(filter),
                    onDeleted: () => setState(() {
                      if (filter.startsWith('${strings.statusLabel}:')) {
                        _selectedStatuses.remove(filter.split(': ')[1].toLowerCase());
                      } else if (filter.startsWith('${strings.vehicleLabel}:')) {
                        _selectedVehicleTypes.remove(filter.split(': ')[1].toLowerCase());
                      } else if (filter.startsWith('${strings.plazaLabel}:')) {
                        _selectedPlazaNames.remove(filter.split(': ')[1]);
                      }
                      _currentPage = 1;
                    }),
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
    final plazaNames = _viewModel.tickets
        .map((t) => t['plazaName']?.toString().trim() ?? '')
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(builder: (context, setDialogState) {
        return Container(
          decoration: BoxDecoration(color: context.cardColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.light ? Colors.grey[300] : Colors.grey[600],
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(strings.advancedFiltersLabel,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: context.textPrimaryColor)),
              ),
              Expanded(
                child: ListView(
                  children: [
                    _buildFilterSection(
                      title: strings.ticketStatusLabel,
                      options: [
                        {'key': 'open', 'label': strings.openTicketsLabel},
                      ],
                      selectedItems: _selectedStatuses,
                      onChanged: (value, isSelected) => setDialogState(() {
                        if (isSelected) _selectedStatuses.add(value);
                        else _selectedStatuses.remove(value);
                      }),
                    ),
                    _buildFilterSection(
                      title: strings.vehicleTypeLabel,
                      options: [
                        {'key': 'bike', 'label': strings.bikeLabel},
                        {'key': '3-wheeler', 'label': strings.threeWheelerLabel},
                        {'key': '4-wheeler', 'label': strings.fourWheelerLabel},
                        {'key': 'bus', 'label': strings.busLabel},
                        {'key': 'truck', 'label': strings.truckLabel},
                        {'key': 'hmv', 'label': strings.heavyMachineryLabel},
                      ],
                      selectedItems: _selectedVehicleTypes,
                      onChanged: (value, isSelected) => setDialogState(() {
                        if (isSelected) _selectedVehicleTypes.add(value);
                        else _selectedVehicleTypes.remove(value);
                      }),
                    ),
                    _buildSearchableFilterSection(
                      title: strings.plazaNameLabel,
                      options: plazaNames,
                      selectedItems: _selectedPlazaNames,
                      onChanged: (value, isSelected) => setDialogState(() {
                        if (isSelected) _selectedPlazaNames.add(value);
                        else _selectedPlazaNames.remove(value);
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
                        }),
                        context: context,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomButtons.primaryButton(
                        height: 40,
                        text: strings.applyLabel,
                        onPressed: () {
                          setState(() => _currentPage = 1);
                          Navigator.pop(context);
                        },
                        context: context,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
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
              color: textColor,
            ),
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
                onSelected: (value) => onChanged(option['key']!, value),
                selectedColor: AppColors.primary.withOpacity(0.2),
                checkmarkColor: textColor,
                backgroundColor: context.secondaryCardColor,
                labelStyle: TextStyle(
                  color: isSelected ? textColor : Colors.grey[400],
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

  Widget _buildSearchableFilterSection({
    required String title,
    required List<String> options,
    required Set<String> selectedItems,
    required Function(String, bool) onChanged,
  }) {
    final strings = S.of(context);
    final TextEditingController searchController = TextEditingController();
    List<String> filteredOptions = options;
    final textColor = context.textPrimaryColor;

    return StatefulBuilder(builder: (context, setLocalState) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: strings.searchPlazaHint,
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(Icons.search, color: textColor),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
                enabledBorder:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary)),
              ),
              style: TextStyle(color: textColor),
              onChanged: (value) => setLocalState(() {
                filteredOptions = options.where((option) => option.toLowerCase().contains(value.toLowerCase())).toList();
              }),
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 300),
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
                      onSelected: (value) => onChanged(option, value),
                      selectedColor: AppColors.primary.withOpacity(0.2),
                      checkmarkColor: textColor,
                      backgroundColor: context.secondaryCardColor,
                      labelStyle: TextStyle(
                          color: isSelected ? textColor : Colors.grey[400],
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Divider(color: Theme.of(context).brightness == Brightness.light ? Colors.grey[300] : Colors.grey[600]),
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
                  controller: _searchController, hintText: strings.searchHint ?? 'Search open tickets...', context: context),
              const SizedBox(height: 8),
              Text(
                '${strings.lastUpdated}: ${DateTime.now().toString().substring(0, 16)}. ${strings.swipeToRefresh}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[400]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<DateTimeRange?> _selectCustomDateRange(BuildContext context, DateTimeRange? initialRange) async {
    final strings = S.of(context);
    final earliestDate = DateTime.now().subtract(const Duration(days: 365 * 5));

    final picked = await showDateRangePicker(
      context: context,
      firstDate: earliestDate,
      lastDate: DateTime.now(),
      initialDateRange: initialRange,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
              primary: AppColors.primary, onPrimary: context.textPrimaryColor, surface: context.cardColor, onSurface: context.textPrimaryColor),
          dialogBackgroundColor: context.cardColor,
          textTheme: Theme.of(context).textTheme.copyWith(bodyLarge: TextStyle(color: context.textPrimaryColor), bodyMedium: TextStyle(color: context.textPrimaryColor)),
        ),
        child: child!,
      ),
    );

    if (picked == null) return null;

    final start = picked.start.isBefore(earliestDate) ? earliestDate : picked.start;
    final end = picked.end.isAfter(DateTime.now()) ? DateTime.now() : picked.end;

    const maxAllowedRange = Duration(days: 365);
    if (end.difference(start) > maxAllowedRange) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(strings.dateRangeTooLongWarning), backgroundColor: Colors.red));
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        DateTimeRange? tempDateRange = _selectedDateRange;
        String? selectedOption = _getSelectedOption(tempDateRange);
        final textColor = context.textPrimaryColor;

        return StatefulBuilder(builder: (context, setDialogState) {
          return Container(
            decoration: BoxDecoration(color: context.cardColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
            height: MediaQuery.of(context).size.height * 0.4,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.light ? Colors.grey[300] : Colors.grey[600],
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(strings.selectDateRangeLabel,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            _buildQuickDateChip(
                                label: strings.todayLabel,
                                isSelected: selectedOption == 'Today',
                                onTap: () => setDialogState(() {
                                  final now = DateTime.now();
                                  tempDateRange = DateTimeRange(
                                      start: DateTime(now.year, now.month, now.day),
                                      end: DateTime(now.year, now.month, now.day, 23, 59, 59));
                                  selectedOption = 'Today';
                                })),
                            const SizedBox(width: 8),
                            _buildQuickDateChip(
                                label: strings.yesterdayLabel,
                                isSelected: selectedOption == 'Yesterday',
                                onTap: () => setDialogState(() {
                                  final yesterday = DateTime.now().subtract(const Duration(days: 1));
                                  tempDateRange = DateTimeRange(
                                      start: DateTime(yesterday.year, yesterday.month, yesterday.day),
                                      end: DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59));
                                  selectedOption = 'Yesterday';
                                })),
                            const SizedBox(width: 8),
                            _buildQuickDateChip(
                                label: strings.last7DaysLabel,
                                isSelected: selectedOption == 'Last 7 Days',
                                onTap: () => setDialogState(() {
                                  final now = DateTime.now();
                                  tempDateRange = DateTimeRange(
                                      start: DateTime(now.year, now.month, now.day).subtract(const Duration(days: 7)),
                                      end: DateTime(now.year, now.month, now.day, 23, 59, 59));
                                  selectedOption = 'Last 7 Days';
                                })),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildQuickDateChip(
                                label: strings.last30DaysLabel,
                                isSelected: selectedOption == 'Last 30 Days',
                                onTap: () => setDialogState(() {
                                  final now = DateTime.now();
                                  tempDateRange = DateTimeRange(
                                      start: DateTime(now.year, now.month, now.day).subtract(const Duration(days: 30)),
                                      end: DateTime(now.year, now.month, now.day, 23, 59, 59));
                                  selectedOption = 'Last 30 Days';
                                })),
                            const SizedBox(width: 8),
                            _buildQuickDateChip(
                                label: strings.customLabel,
                                isSelected: selectedOption == 'Custom',
                                onTap: () async {
                                  final picked = await _selectCustomDateRange(context, tempDateRange);
                                  if (picked != null) setDialogState(() {
                                    tempDateRange = picked;
                                    selectedOption = 'Custom';
                                  });
                                }),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (selectedOption == 'Custom' && tempDateRange != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                        '${strings.selectedRangeLabel}: ${DateFormat('dd MMM yyyy').format(tempDateRange!.start)} - ${DateFormat('dd MMM yyyy').format(tempDateRange!.end)}',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textColor)),
                  ),
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
                            context: context),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomButtons.primaryButton(
                            height: 40,
                            text: strings.applyLabel,
                            onPressed: () {
                              setState(() {
                                _selectedDateRange = tempDateRange;
                                _currentPage = 1;
                              });
                              Navigator.pop(context);
                            },
                            context: context),
                      ),
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

  Widget _buildQuickDateChip({required String label, required bool isSelected, required VoidCallback onTap}) {
    final textColor = context.textPrimaryColor;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withOpacity(0.2) : context.secondaryCardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent, width: 1)),
        child: Text(label,
            style: TextStyle(color: isSelected ? AppColors.primary : textColor, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
      ),
    );
  }

  bool _isTodayRange(DateTimeRange range) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return range.start == todayStart && range.end.isAtSameMomentAs(todayEnd);
  }

  bool _isYesterdayRange(DateTimeRange range) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdayStart = DateTime(yesterday.year, yesterday.month, yesterday.day);
    final yesterdayEnd = DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59);
    return range.start == yesterdayStart && range.end.isAtSameMomentAs(yesterdayEnd);
  }

  bool _isLast7DaysRange(DateTimeRange range) {
    final now = DateTime.now();
    final sevenDaysAgo = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 7));
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return range.start == sevenDaysAgo && range.end.isAtSameMomentAs(todayEnd);
  }

  bool _isLast30DaysRange(DateTimeRange range) {
    final now = DateTime.now();
    final thirtyDaysAgo = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 30));
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return range.start == thirtyDaysAgo && range.end.isAtSameMomentAs(todayEnd);
  }

  Widget _buildEmptyState(S strings) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.confirmation_number_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(strings.noOpenTicketsLabel, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: context.textPrimaryColor)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
                _searchQuery.isEmpty &&
                    _selectedDateRange == null &&
                    _selectedStatuses.isEmpty &&
                    _selectedVehicleTypes.isEmpty &&
                    _selectedPlazaNames.isEmpty
                    ? strings.noTicketsToRejectMessage
                    : strings.noTicketsMatchSearchMessage,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[400]),
                textAlign: TextAlign.center),
          ),
          if (_searchQuery.isNotEmpty || _selectedDateRange != null || _selectedStatuses.isNotEmpty || _selectedVehicleTypes.isNotEmpty || _selectedPlazaNames.isNotEmpty) ...[
            const SizedBox(height: 16),
            TextButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _selectedDateRange = null;
                    _selectedStatuses.clear();
                    _selectedVehicleTypes.clear();
                    _selectedPlazaNames.clear();
                    _currentPage = 1;
                  });
                },
                child: Text(strings.clearSearchLabel, style: const TextStyle(color: AppColors.primary)))
          ],
        ],
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: 10,
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

  Widget _buildErrorState(S strings) {
    String errorTitle = strings.errorUnableToLoadTickets;
    String errorMessage = strings.errorGeneric;
    final error = _viewModel.error;

    if (error != null) {
      developer.log('Error occurred: $error', name: 'OpenTicketsScreen');
      switch (error.runtimeType) {
        case NoInternetException:
          errorTitle = strings.errorNoInternet;
          errorMessage = strings.errorNoInternetMessage;
          break;
        case RequestTimeoutException:
          errorTitle = strings.errorRequestTimeout;
          errorMessage = strings.errorRequestTimeoutMessage;
          break;
        case HttpException:
          final httpError = error as HttpException;
          errorTitle = strings.errorServerError;
          errorMessage = httpError.message.isNotEmpty ? httpError.message : strings.errorServerErrorMessage;
          break;
        case ServiceException:
          errorTitle = strings.errorUnexpected;
          errorMessage = error.toString().split(':').last.trim();
          break;
        default:
          errorTitle = strings.errorUnexpected;
          errorMessage = error.toString().split(':').last.trim();
      }
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(errorTitle, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: context.textPrimaryColor), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(errorMessage, style: TextStyle(fontSize: 16, color: context.textPrimaryColor), textAlign: TextAlign.center),
          ),
          const SizedBox(height: 24),
          CustomButtons.primaryButton(height: 40, width: 150, text: strings.buttonRetry, onPressed: _refreshData, context: context),
        ],
      ),
    );
  }

  Widget _buildTicketCard(Map<String, dynamic> ticket, S strings) {
    DateTime createdTime = DateTime.parse(ticket['ticketCreationTime'] ?? DateTime.now().toIso8601String());
    String formattedCreatedTime = DateFormat('dd MMM, hh:mm a').format(createdTime);
    Color statusColor;
    final ticketStatus = ticket['ticketStatus'] is Status
        ? ticket['ticketStatus'].toString().split('.').last.toLowerCase()
        : ticket['ticketStatus']?.toString().toLowerCase() ?? '';
    switch (ticketStatus) {
      case 'open':
        statusColor = Colors.green;
        break;
      case 'rejected':
        statusColor = Colors.red;
        break;
      case 'completed':
        statusColor = Colors.blue;
        break;
      default:
        statusColor = Colors.orange;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: Theme.of(context).cardTheme.elevation,
      color: context.secondaryCardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: statusColor.withOpacity(0.2), width: 1),
      ),
      child: InkWell(
        onTap: () {
          developer.log('Ticket card tapped: ${ticket['ticketId']}', name: 'TicketHistory');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChangeNotifierProvider<OpenTicketViewModel>.value(
                  value: Provider.of<OpenTicketViewModel>(context, listen: false),
                  child: ViewOpenTicketScreen(ticketId: ticket['ticketId'].toString()),
                ),
              ),
            ).then((_) => _refreshData());
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 4, top: 8, bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${ticket['plazaName']?.toString() ?? strings.naLabel} | ${ticket['entryLaneId']?.toString() ?? strings.naLabel} | ${ticket['ticketRefId']?.toString() ?? strings.naLabel}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.textPrimaryColor),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${ticket['vehicleNumber']?.toString() ?? strings.naLabel} | ${ticket['vehicleType']?.toString() ?? strings.naLabel} | $formattedCreatedTime',
                      style: TextStyle(color: context.textPrimaryColor, fontSize: 14),
                    ),
                    if (ticket['remarks']?.isNotEmpty ?? false)
                      Text(
                        ticket['remarks'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: context.textPrimaryColor, fontSize: 14),
                      ),
                  ],
                ),
              ),

              SizedBox(
                width: 75,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        ticketStatus.capitalize(),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Icon(Icons.chevron_right, color: Theme.of(context).iconTheme.color, size: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    return Consumer<OpenTicketViewModel>(
      builder: (context, viewModel, _) {
        final filteredTickets = _getFilteredTickets(viewModel.tickets);
        final totalPages = (filteredTickets.length / _itemsPerPage).ceil();
        final paginatedTickets = _getPaginatedTickets(filteredTickets);

        developer.log('Filtered tickets: ${filteredTickets.length}, Paginated tickets: ${paginatedTickets.length}', name: 'OpenTicketsScreen');

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: CustomAppBar.appBarWithNavigation(
              screenTitle: strings.titleOpenTickets, onPressed: () => Navigator.pop(context), darkBackground: Theme.of(context).brightness == Brightness.dark, context: context),
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
                      ListView(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          const SizedBox(height: 8),
                          if (viewModel.error != null && !viewModel.isLoading)
                            SizedBox(height: MediaQuery.of(context).size.height * 0.6, child: _buildErrorState(strings))
                          else if (filteredTickets.isEmpty && !viewModel.isLoading)
                            SizedBox(height: MediaQuery.of(context).size.height * 0.6, child: _buildEmptyState(strings))
                          else if (!viewModel.isLoading)
                              ...paginatedTickets.map((ticket) => _buildTicketCard(ticket, strings)),
                        ],
                      ),
                      if (viewModel.isLoading) Padding(padding: const EdgeInsets.only(top: 8.0), child: _buildShimmerList()),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: filteredTickets.isNotEmpty && !viewModel.isLoading
              ? Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              padding: const EdgeInsets.all(4.0),
              child: SafeArea(child: PaginationControls(currentPage: _currentPage, totalPages: totalPages, onPageChange: _updatePage)))
              : null,
        );
      },
    );
  }
}

extension StringExtension on String {
  String capitalize() => "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
}