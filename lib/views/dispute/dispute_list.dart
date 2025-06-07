import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../config/app_colors.dart';
import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../generated/l10n.dart';
import '../../utils/components/appbar.dart';
import '../../utils/components/button.dart';
import '../../utils/components/form_field.dart';
import '../../utils/components/pagination_controls.dart';
import '../../utils/components/pagination_mixin.dart';
import '../../viewmodels/dispute/dispute_list_viewmodel.dart';

class DisputeList extends StatefulWidget {
  const DisputeList({super.key, required this.viewDisputeOptionSelect});

  final bool viewDisputeOptionSelect;

  @override
  State<DisputeList> createState() => _DisputeListState();
}

class _DisputeListState extends State<DisputeList> with RouteAware, PaginatedListMixin<Map<String, dynamic>> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  late DisputeListViewModel _viewModel;
  late RouteObserver<ModalRoute> _routeObserver;
  String _searchQuery = '';
  int _currentPage = 1;
  Timer? _debounce;
  bool _isInitialized = false;

  Set<String> _selectedStatuses = {};
  Set<String> _selectedVehicleTypes = {};
  Set<String> _selectedPlazaNames = {};
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<DisputeListViewModel>(context, listen: false);
    _setDefaultDateRange();
    _searchController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), () {
        setState(() {
          _searchQuery = _searchController.text.toLowerCase();
          _currentPage = 1;
        });
      });
    });
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
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
    await _viewModel.fetchOpenDisputes(reset: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _routeObserver = Provider.of<RouteObserver<ModalRoute>>(context, listen: false);
    _routeObserver.subscribe(this, ModalRoute.of(context)!);
    if (!_isInitialized) {
      _isInitialized = true;
    }
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
    developer.log('Refreshing dispute list data', name: 'DisputeList');
    await _viewModel.fetchOpenDisputes(reset: true);
  }

  List<Map<String, dynamic>> _getFilteredDisputes(List<Map<String, dynamic>> disputes) {
    return disputes.where((dispute) {
      final entryTime = DateTime.tryParse(dispute['entryTime']?.toString() ?? '');
      final entryTimeString = entryTime != null ? DateFormat('dd MMM yyyy, hh:mm a').format(entryTime) : '';

      final matchesSearch = _searchQuery.isEmpty ||
          (dispute['disputeId']?.toString().toLowerCase().contains(_searchQuery) ?? false) ||
          (dispute['plazaId']?.toString().toLowerCase().contains(_searchQuery) ?? false) ||
          (dispute['vehicleNumber']?.toString().toLowerCase().contains(_searchQuery) ?? false) ||
          (dispute['vehicleType']?.toString().toLowerCase().contains(_searchQuery) ?? false) ||
          (dispute['plazaName']?.toString().toLowerCase().contains(_searchQuery) ?? false) ||
          (dispute['status']?.toString().toLowerCase().contains(_searchQuery) ?? false) ||
          entryTimeString.toLowerCase().contains(_searchQuery);

      final disputeStatus = dispute['status']?.toString().toLowerCase() ?? '';
      final matchesStatus = _selectedStatuses.isEmpty || _selectedStatuses.contains(disputeStatus);

      final matchesVehicleType = _selectedVehicleTypes.isEmpty ||
          _selectedVehicleTypes.contains(dispute['vehicleType']?.toString().toLowerCase());

      final matchesPlazaName = _selectedPlazaNames.isEmpty ||
          _selectedPlazaNames.contains(dispute['plazaName']?.toString().toLowerCase());

      final matchesDate = _selectedDateRange == null ||
          (entryTime != null &&
              entryTime.isAfter(_selectedDateRange!.start.subtract(const Duration(days: 1))) &&
              entryTime.isBefore(_selectedDateRange!.end.add(const Duration(days: 1))));

      return matchesSearch && matchesStatus && matchesVehicleType && matchesPlazaName && matchesDate;
    }).toList();
  }

  void _updatePage(int newPage) {
    final filteredDisputes = _getFilteredDisputes(_viewModel.disputes);
    updatePage(newPage, filteredDisputes, (page) {
      setState(() => _currentPage = page);
      developer.log('Page updated to: $_currentPage', name: 'DisputeList');
    });
  }

  Widget _buildSearchField(S strings) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.95,
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
                hintText: strings.searchDisputeHint,
                context: context,
              ),
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

    return GestureDetector(
      onTap: _showDateFilterDialog,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: context.secondaryCardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today, color: textColor, size: 16),
            const SizedBox(width: 6),
            Text(
              displayText,
              style: TextStyle(
                color: textColor,
                fontWeight: _selectedDateRange != null ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreFiltersChip(S strings) {
    final hasActiveFilters =
        _selectedStatuses.isNotEmpty || _selectedVehicleTypes.isNotEmpty || _selectedPlazaNames.isNotEmpty;
    final textColor = context.textPrimaryColor;

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
            Icon(Icons.filter_list, color: textColor, size: 16),
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

  Widget _buildFilterChipsRow(S strings) {
    final selectedFilters = [
      ..._selectedStatuses.map((s) => '${strings.labelStatus}: ${s.capitalize()}'),
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
                  onTap: () {
                    setState(() {
                      _selectedStatuses.clear();
                      _selectedVehicleTypes.clear();
                      _selectedPlazaNames.clear();
                      _selectedDateRange = null;
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
                      style: TextStyle(color: textColor, fontWeight: FontWeight.normal),
                    ),
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
                    onDeleted: () {
                      setState(() {
                        if (filter.startsWith('${strings.labelStatus}:')) {
                          _selectedStatuses.remove(filter.split(': ')[1].toLowerCase());
                        } else if (filter.startsWith('${strings.vehicleLabel}:')) {
                          _selectedVehicleTypes.remove(filter.split(': ')[1].toLowerCase());
                        } else if (filter.startsWith('${strings.plazaLabel}:')) {
                          _selectedPlazaNames.remove(filter.split(': ')[1]);
                        }
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

  void _showAllFiltersDialog() {
    final strings = S.of(context);
    final plazaNames = _viewModel.disputes
        .map((d) => d['plazaName']?.toString().trim() ?? '')
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Container(
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
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
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      strings.advancedFiltersLabel,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: context.textPrimaryColor),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: [
                        _buildFilterSection(
                          title: strings.disputeStatusLabel,
                          options: [
                            {'key': 'open', 'label': strings.openDisputesLabel},
                            {'key': 'inprogress', 'label': strings.inProgressDisputesLabel},
                            {'key': 'accepted', 'label': strings.acceptedDisputesLabel},
                            {'key': 'rejected', 'label': strings.rejectedDisputesLabel},
                          ],
                          selectedItems: _selectedStatuses,
                          onChanged: (value, isSelected) {
                            setDialogState(() {
                              if (isSelected) {
                                _selectedStatuses.add(value);
                              } else {
                                _selectedStatuses.remove(value);
                              }
                            });
                          },
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
                          onChanged: (value, isSelected) {
                            setDialogState(() {
                              if (isSelected) {
                                _selectedVehicleTypes.add(value);
                              } else {
                                _selectedVehicleTypes.remove(value);
                              }
                            });
                          },
                        ),
                        _buildSearchableFilterSection(
                          title: strings.plazaNameLabel,
                          options: plazaNames,
                          selectedItems: _selectedPlazaNames,
                          onChanged: (value, isSelected) {
                            setDialogState(() {
                              if (isSelected) {
                                _selectedPlazaNames.add(value);
                              } else {
                                _selectedPlazaNames.remove(value);
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
                                _selectedStatuses.clear();
                                _selectedVehicleTypes.clear();
                                _selectedPlazaNames.clear();
                              });
                            },
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
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
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
                onSelected: (bool value) => onChanged(option['key']!, value),
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
        Divider(color: Theme.of(context).brightness == Brightness.light ? Colors.grey[300] : Colors.grey[600]),
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

    return StatefulBuilder(
      builder: (context, setLocalState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
              ),
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
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey[400]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey[400]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
                style: TextStyle(color: textColor),
                onChanged: (value) {
                  setLocalState(() {
                    filteredOptions =
                        options.where((option) => option.toLowerCase().contains(value.toLowerCase())).toList();
                  });
                },
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
                        onSelected: (bool value) => onChanged(option, value),
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
              ),
            ),
            const SizedBox(height: 16),
            Divider(color: Theme.of(context).brightness == Brightness.light ? Colors.grey[300] : Colors.grey[600]),
          ],
        );
      },
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme(
              brightness: Theme.of(context).brightness,
              primary: AppColors.primary,
              onPrimary: Colors.white,
              secondary: AppColors.primary.withOpacity(0.2),
              onSecondary: context.textPrimaryColor,
              surface: context.cardColor,
              onSurface: context.textPrimaryColor,
              background: context.cardColor,
              onBackground: context.textPrimaryColor,
              error: Colors.red,
              onError: Colors.white,
            ),
            dialogBackgroundColor: context.cardColor,
            textTheme: TextTheme(
              bodyMedium: TextStyle(color: context.textPrimaryColor),
              titleLarge: TextStyle(color: context.textPrimaryColor),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return null;

    final start = picked.start.isBefore(earliestDate) ? earliestDate : picked.start;
    final end = picked.end.isAfter(DateTime.now()) ? DateTime.now() : picked.end;

    final maxAllowedRange = const Duration(days: 365);
    if (end.difference(start) > maxAllowedRange) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.dateRangeTooLongWarning, style: TextStyle(color: context.textPrimaryColor)),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }

    return DateTimeRange(start: start, end: end);
  }

  void _showDateFilterDialog() {
    final strings = S.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        DateTimeRange? tempDateRange = _selectedDateRange;
        String? selectedOption = _getSelectedOption(tempDateRange);
        final textColor = context.textPrimaryColor;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Container(
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
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
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      strings.selectDateRangeLabel,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
                    ),
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
                                onTap: () {
                                  setDialogState(() {
                                    final now = DateTime.now();
                                    tempDateRange = DateTimeRange(
                                      start: DateTime(now.year, now.month, now.day),
                                      end: DateTime(now.year, now.month, now.day, 23, 59, 59),
                                    );
                                    selectedOption = 'Today';
                                  });
                                },
                              ),
                              const SizedBox(width: 8),
                              _buildQuickDateChip(
                                label: strings.yesterdayLabel,
                                isSelected: selectedOption == 'Yesterday',
                                onTap: () {
                                  setDialogState(() {
                                    final yesterday = DateTime.now().subtract(const Duration(days: 1));
                                    tempDateRange = DateTimeRange(
                                      start: DateTime(yesterday.year, yesterday.month, yesterday.day),
                                      end: DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59),
                                    );
                                    selectedOption = 'Yesterday';
                                  });
                                },
                              ),
                              const SizedBox(width: 8),
                              _buildQuickDateChip(
                                label: strings.last7DaysLabel,
                                isSelected: selectedOption == 'Last 7 Days',
                                onTap: () {
                                  setDialogState(() {
                                    final now = DateTime.now();
                                    tempDateRange = DateTimeRange(
                                      start: DateTime(now.year, now.month, now.day).subtract(const Duration(days: 7)),
                                      end: DateTime(now.year, now.month, now.day, 23, 59, 59),
                                    );
                                    selectedOption = 'Last 7 Days';
                                  });
                                },
                              ),
                              const SizedBox(width: 8),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildQuickDateChip(
                                label: strings.last30DaysLabel,
                                isSelected: selectedOption == 'Last 30 Days',
                                onTap: () {
                                  setDialogState(() {
                                    final now = DateTime.now();
                                    tempDateRange = DateTimeRange(
                                      start: DateTime(now.year, now.month, now.day).subtract(const Duration(days: 30)),
                                      end: DateTime(now.year, now.month, now.day, 23, 59, 59),
                                    );
                                    selectedOption = 'Last 30 Days';
                                  });
                                },
                              ),
                              const SizedBox(width: 8),
                              _buildQuickDateChip(
                                label: strings.customLabel,
                                isSelected: selectedOption == 'Custom',
                                onTap: () async {
                                  final picked = await _selectCustomDateRange(context, tempDateRange);
                                  if (picked != null) {
                                    setDialogState(() {
                                      tempDateRange = picked;
                                      selectedOption = 'Custom';
                                    });
                                  }
                                },
                              ),
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
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textColor),
                      ),
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
                            context: context,
                          ),
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
                            context: context,
                          ),
                        ),
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

  Widget _buildQuickDateChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final textColor = context.textPrimaryColor;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.2) : context.secondaryCardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent, width: 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primary : textColor,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
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

  Widget _buildDisputeCard(Map<String, dynamic> dispute, S strings) {
    final entryTime = DateTime.tryParse(dispute['entryTime']?.toString() ?? '');
    final entryTimeString = entryTime != null ? DateFormat('dd MMM, hh:mm a').format(entryTime) : strings.naLabel;
    final textColor = context.textPrimaryColor;
    final status = dispute['status']?.toString().toLowerCase() ?? 'open';
    final statusColor = _getStatusColor(status);

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
          if (widget.viewDisputeOptionSelect) { // Fixed syntax
            Navigator.pushNamed(
              context,
              AppRoutes.disputeDetails,
              arguments: {'ticketId': dispute['ticketId']},
            ).then((_) => _refreshData());
          } else {
            Navigator.pushNamed(
              context,
              AppRoutes.processDispute,
              arguments: {'ticketId': dispute['ticketId']},
            ).then((_) => _refreshData());
          }
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
                      '${dispute['plazaName']?.toString() ?? strings.naLabel} | ${dispute['disputeId']?.toString() ?? strings.naLabel}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textColor),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${dispute['vehicleNumber']?.toString() ?? strings.naLabel} | ${dispute['vehicleType']?.toString() ?? strings.naLabel} | $entryTimeString',
                      style: TextStyle(color: textColor, fontSize: 14),
                    ),
                    if (dispute['disputeReason']?.isNotEmpty ?? false)
                      Text(
                        dispute['disputeReason'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: textColor, fontSize: 14),
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
                        status.capitalize(),
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'open':
        return Colors.blue;
      case 'inprogress':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
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
    String errorTitle = strings.errorUnableToLoadDisputes;
    String errorMessage = strings.errorGeneric;

    final error = _viewModel.errorMessage;
    if (error != null) {
      developer.log('Error occurred: $error', name: 'DisputeList');
      switch (error) {
        case 'No internet connection. Please check your network.':
          errorTitle = strings.errorNoInternet;
          errorMessage = strings.errorNoInternetMessage;
          break;
        case 'Request timed out. Please try again.':
          errorTitle = strings.errorRequestTimeout;
          errorMessage = strings.errorRequestTimeoutMessage;
          break;
        default:
          if (error.contains('HTTP error')) {
            errorTitle = strings.errorServerError;
            errorMessage = strings.errorServerErrorMessage;
            if (error.contains('400')) {
              errorTitle = strings.errorInvalidRequest;
              errorMessage = strings.errorInvalidRequestMessage;
            } else if (error.contains('401')) {
              errorTitle = strings.errorUnauthorized;
              errorMessage = strings.errorUnauthorizedMessage;
            } else if (error.contains('403')) {
              errorTitle = strings.errorAccessDenied;
              errorMessage = strings.errorAccessDeniedMessage;
            } else if (error.contains('404')) {
              errorTitle = strings.errorNotFound;
              errorMessage = strings.errorNotFoundMessage;
            } else if (error.contains('500')) {
              errorTitle = strings.errorServerIssue;
              errorMessage = strings.errorServerIssueMessage;
            } else if (error.contains('502')) {
              errorTitle = strings.errorServiceUnavailable;
              errorMessage = strings.errorServiceUnavailableMessage;
            } else if (error.contains('503')) {
              errorTitle = strings.errorServiceOverloaded;
              errorMessage = strings.errorServiceOverloadedMessage;
            }
          } else {
            errorTitle = strings.errorUnexpected;
            errorMessage = error;
          }
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

  Widget _buildEmptyState(S strings) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_toggle_off,
            size: 50,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            strings.noDisputesFound,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.textPrimaryColor),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              strings.adjustFiltersMessage,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[400]),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    return Consumer<DisputeListViewModel>(
      builder: (context, viewModel, _) {
        final filteredDisputes = _getFilteredDisputes(viewModel.disputes);
        final totalPages = getTotalPages(filteredDisputes);
        final paginatedDisputes = getPaginatedItems(filteredDisputes, _currentPage);

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: CustomAppBar.appBarWithNavigationAndActions(
            screenTitle: strings.titleDisputeList, // Add appropriate title
            onPressed: () => Navigator.pop(context),
            darkBackground: Theme.of(context).brightness == Brightness.dark,
            actions: [],
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
                          if (viewModel.errorMessage != null && !viewModel.isLoading)
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.6,
                              child: _buildErrorState(strings),
                            )
                          else if (filteredDisputes.isEmpty && !viewModel.isLoading)
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.6,
                              child: _buildEmptyState(strings),
                            )
                          else if (!viewModel.isLoading)
                              ...paginatedDisputes.map((dispute) => _buildDisputeCard(dispute, strings)),
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
          bottomNavigationBar: filteredDisputes.isNotEmpty && !viewModel.isLoading
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
    return isEmpty ? this : this[0].toUpperCase() + substring(1).toLowerCase();
  }
}