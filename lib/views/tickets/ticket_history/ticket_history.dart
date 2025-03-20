import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../config/app_colors.dart';
import '../../../../utils/components/appbar.dart';
import '../../../../utils/components/form_field.dart';
import '../../../../utils/components/pagination_controls.dart';
import '../../../generated/l10n.dart';
import '../../../utils/exceptions.dart';
import 'view_ticket.dart';
import '../../../viewmodels/ticket/ticket_history_viewmodel.dart';

class TicketHistoryScreen extends StatefulWidget {
  const TicketHistoryScreen({super.key});

  @override
  State<TicketHistoryScreen> createState() => _TicketHistoryScreenState();
}

class _TicketHistoryScreenState extends State<TicketHistoryScreen> with RouteAware {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  late TicketHistoryViewModel _viewModel;
  late RouteObserver<ModalRoute> _routeObserver;
  String _searchQuery = '';
  int _currentPage = 1;
  static const int _itemsPerPage = 10;
  bool _isLoading = false;
  Timer? _debounce;

  Set<String> _selectedStatuses = {};
  Set<String> _selectedVehicleTypes = {};
  Set<String> _selectedPlazaNames = {};
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _viewModel = TicketHistoryViewModel();
    _setDefaultDateRange();
    _loadInitialData();
    _searchController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), () {
        setState(() {
          _searchQuery = _searchController.text.toLowerCase();
          _currentPage = 1;
        });
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
    setState(() => _isLoading = true);
    await _viewModel.fetchTicketHistory();
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
    _debounce?.cancel();
    _routeObserver.unsubscribe(this);
    _scrollController.dispose();
    _searchController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  void didPopNext() => _refreshData();

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    await _viewModel.fetchTicketHistory();
    setState(() => _isLoading = false);
  }

  List<Map<String, dynamic>> _getFilteredTickets(List<Map<String, dynamic>> tickets) {
    return tickets.where((ticket) {
      final matchesSearch = _searchQuery.isEmpty ||
          (ticket['ticketId']?.toString().toLowerCase().contains(_searchQuery) ?? false) ||
          (ticket['plazaId']?.toString().toLowerCase().contains(_searchQuery) ?? false) ||
          (ticket['vehicleNumber']?.toString().toLowerCase().contains(_searchQuery) ?? false) ||
          (ticket['vehicleType']?.toString().toLowerCase().contains(_searchQuery) ?? false) ||
          (ticket['plazaName']?.toString().toLowerCase().contains(_searchQuery) ?? false) ||
          (ticket['ticketStatus']?.toString().toLowerCase().contains(_searchQuery) ?? false);

      final matchesStatus = _selectedStatuses.isEmpty ||
          _selectedStatuses.contains(ticket['ticketStatus']?.toString().toLowerCase());

      final matchesVehicleType = _selectedVehicleTypes.isEmpty ||
          _selectedVehicleTypes.contains(ticket['vehicleType']?.toString().toLowerCase());

      final matchesPlazaName = _selectedPlazaNames.isEmpty ||
          _selectedPlazaNames.contains(ticket['plazaName']?.toString().toLowerCase());

      final entryTime = DateTime.tryParse(ticket['entryTime'] ?? '');
      final matchesDate = _selectedDateRange == null ||
          (entryTime != null &&
              entryTime.isAfter(_selectedDateRange!.start.subtract(const Duration(days: 1))) &&
              entryTime.isBefore(_selectedDateRange!.end.add(const Duration(days: 1))));

      return matchesSearch && matchesStatus && matchesVehicleType && matchesPlazaName && matchesDate;
    }).toList();
  }

  List<Map<String, dynamic>> _getPaginatedTickets(List<Map<String, dynamic>> filteredTickets) {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    return endIndex > filteredTickets.length ? filteredTickets.sublist(startIndex) : filteredTickets.sublist(startIndex, endIndex);
  }

  void _updatePage(int newPage) {
    final filteredTickets = _getFilteredTickets(_viewModel.tickets);
    final totalPages = (filteredTickets.length / _itemsPerPage).ceil().clamp(1, double.infinity).toInt();
    if (newPage < 1 || newPage > totalPages) return;
    setState(() => _currentPage = newPage);
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
      displayText = '${DateFormat('dd MMM').format(_selectedDateRange!.start)} - ${DateFormat('dd MMM').format(_selectedDateRange!.end)}';
    }

    return GestureDetector(
      onTap: _showDateFilterDialog,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _selectedDateRange != null ? AppColors.primary.withOpacity(0.1) : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today,
              color: _selectedDateRange != null ? AppColors.primary : Colors.grey,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              displayText,
              style: TextStyle(
                color: _selectedDateRange != null ? AppColors.primary : Colors.black87,
                fontWeight: _selectedDateRange != null ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreFiltersChip(S strings) {
    final hasActiveFilters = _selectedStatuses.isNotEmpty || _selectedVehicleTypes.isNotEmpty || _selectedPlazaNames.isNotEmpty;

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

  Widget _buildFilterChipsRow(S strings) {
    final selectedFilters = [
      ..._selectedStatuses.map((s) => '${strings.statusLabel}: ${s.capitalize()}'),
      ..._selectedVehicleTypes.map((v) => '${strings.vehicleLabel}: ${v.capitalize()}'),
      ..._selectedPlazaNames.map((p) => '${strings.plazaLabel}: $p'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
        child: Row(
          children: [
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
                      if (filter.startsWith('${strings.statusLabel}:')) {
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

  void _showAllFiltersDialog() {
    final strings = S.of(context);
    final plazaNames = _viewModel.tickets
        .map((t) => t['plazaName']?.toString().trim() ?? '')
        .where((name) => name.isNotEmpty)
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
              height: MediaQuery.of(context).size.height * 0.8,
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
                          title: strings.ticketStatusLabel,
                          options: [
                            {'key': 'open', 'label': strings.openTicketsLabel},
                            {'key': 'pending', 'label': strings.pendingTicketsLabel},
                            {'key': 'complete', 'label': strings.completedTicketsLabel},
                            {'key': 'rejected', 'label': strings.rejectedTicketsLabel}
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
                            {'key': 'hmv', 'label': strings.heavyMachineryLabel}
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
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () {
                              setDialogState(() {
                                _selectedStatuses.clear();
                                _selectedVehicleTypes.clear();
                                _selectedPlazaNames.clear();
                              });
                            },
                            child: Text(strings.clearAllLabel),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () {
                              setState(() {
                                _currentPage = 1;
                              });
                              Navigator.pop(context);
                            },
                            child: Text(strings.applyLabel, style: const TextStyle(color: Colors.white)),
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

  Widget _buildSearchableFilterSection({
    required String title,
    required List<String> options,
    required Set<String> selectedItems,
    required Function(String, bool) onChanged,
  }) {
    final strings = S.of(context);
    final TextEditingController searchController = TextEditingController();
    List<String> filteredOptions = options;

    return StatefulBuilder(
      builder: (context, setLocalState) {
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
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: strings.searchPlazaHint,
                  prefixIcon: const Icon(Icons.search),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onChanged: (value) {
                  setLocalState(() {
                    filteredOptions = options.where((option) => option.toLowerCase().contains(value.toLowerCase())).toList();
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
                        onSelected: (bool value) {
                          onChanged(option, value);
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
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
          ],
        );
      },
    );
  }

  Widget _buildSearchField(S strings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildFilterChipsRow(strings),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: CustomFormFields.searchFormField(
            controller: _searchController,
            hintText: strings.searchTicketHistoryHint, context: context,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            '${strings.lastUpdated}: ${DateTime.now().toString().substring(0, 16)}. ${strings.swipeToRefresh}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      ],
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
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
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
          content: Text(strings.dateRangeTooLongWarning),
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
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        DateTimeRange? tempDateRange = _selectedDateRange;
        String? selectedOption = _getSelectedOption(tempDateRange);

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              height: MediaQuery.of(context).size.height * 0.4,
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
                      strings.selectDateRangeLabel,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
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
                          SizedBox(height: 8),
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
                  if (selectedOption == 'Custom' && tempDateRange != null) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Text(
                        '${strings.selectedRangeLabel}: ${DateFormat('dd MMM yyyy').format(tempDateRange!.start)} - ${DateFormat('dd MMM yyyy').format(tempDateRange!.end)}',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.primary),
                      ),
                    ),
                  ],
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () {
                              setDialogState(() {
                                tempDateRange = null;
                                selectedOption = null;
                              });
                            },
                            child: Text(strings.clearLabel),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () {
                              setState(() {
                                _selectedDateRange = tempDateRange;
                                _currentPage = 1;
                              });
                              Navigator.pop(context);
                            },
                            child: Text(strings.applyLabel, style: const TextStyle(color: Colors.white)),
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

  String? _getSelectedOption(DateTimeRange? range) {
    if (range == null) return null;
    if (_isTodayRange(range)) return 'Today';
    if (_isYesterdayRange(range)) return 'Yesterday';
    if (_isLast7DaysRange(range)) return 'Last 7 Days';
    if (_isLast30DaysRange(range)) return 'Last 30 Days';
    return 'Custom';
  }

  Widget _buildQuickDateChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.2) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent, width: 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primary : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
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

  Widget _buildTicketCard(Map<String, dynamic> ticket, S strings) {
    DateTime createdTime = DateTime.parse(ticket['ticketCreationTime'] ?? "N/A");
    String formattedCreatedTime = DateFormat('dd MMM, hh:mm a').format(createdTime);
    Color statusColor;
    switch (ticket['ticketStatus'].toString().toLowerCase()) {
      case 'open':
        statusColor = Colors.green;
        break;
      case 'rejected':
        statusColor = Colors.red;
        break;
      case 'complete':
        statusColor = Colors.blue;
        break;
      case 'pending':
      default:
        statusColor = Colors.orange;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: statusColor.withOpacity(0.2), width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          developer.log('Ticket card tapped: ${ticket['ticketId']}');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChangeNotifierProvider<TicketHistoryViewModel>(
                create: (_) => TicketHistoryViewModel(),
                child: ViewTicketScreen(ticketId: ticket['ticketId'].toString()),
              ),
            ),
          ).then((_) => _refreshData());
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${ticket['plazaName']?.toString() ?? strings.naLabel} | ${ticket['entryLaneId']?.toString() ?? strings.naLabel}',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.normal, color: Colors.black),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            ticket['ticketStatus'].toString(),
                            style: TextStyle(color: statusColor, fontWeight: FontWeight.w600, fontSize: 11),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ticket['ticketRefId']?.toString() ?? strings.naLabel,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.normal, color: Colors.black),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          ticket['vehicleNumber']?.toString() ?? strings.naLabel,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.normal, color: Colors.black),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6.0),
                          child: Text('|', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        ),
                        Text(
                          ticket['vehicleType']?.toString() ?? strings.naLabel,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.normal, color: Colors.black),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6.0),
                          child: Text('|', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        ),
                        Text(
                          formattedCreatedTime,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.normal, color: Colors.black),
                        ),
                      ],
                    ),
                    if (ticket['remarks']?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 4),
                      Text(
                        ticket['remarks'],
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.normal, color: Colors.black),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.primary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Container(width: 100, height: 16, color: Colors.white),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 150, height: 12, color: Colors.white),
                Container(width: 120, height: 12, color: Colors.white),
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
      developer.log('Error occurred: $error');
      if (error is NoInternetException) {
        errorTitle = strings.errorNoInternet;
        errorMessage = strings.errorNoInternetMessage;
      } else if (error is RequestTimeoutException) {
        errorTitle = strings.errorRequestTimeout;
        errorMessage = strings.errorRequestTimeoutMessage;
      } else if (error is HttpException) {
        errorTitle = strings.errorServerError;
        errorMessage = strings.errorServerErrorMessage;
        switch (error.statusCode) {
          case 400:
            errorTitle = strings.errorInvalidRequest;
            errorMessage = strings.errorInvalidRequestMessage;
            break;
          case 401:
            errorTitle = strings.errorUnauthorized;
            errorMessage = strings.errorUnauthorizedMessage;
            break;
          case 403:
            errorTitle = strings.errorAccessDenied;
            errorMessage = strings.errorAccessDeniedMessage;
            break;
          case 404:
            errorTitle = strings.errorNotFound;
            errorMessage = strings.errorNotFoundMessage;
            break;
          case 500:
            errorTitle = strings.errorServerIssue;
            errorMessage = strings.errorServerIssueMessage;
            break;
          case 502:
            errorTitle = strings.errorServiceUnavailable;
            errorMessage = strings.errorServiceUnavailableMessage;
            break;
          case 503:
            errorTitle = strings.errorServiceOverloaded;
            errorMessage = strings.errorServiceOverloadedMessage;
            break;
          default:
            errorTitle = strings.errorServerError;
            errorMessage = strings.errorServerErrorMessage;
            break;
        }
      } else if (error is ServiceException) {
        errorTitle = strings.errorUnexpected;
        errorMessage = strings.errorUnexpectedMessage;
      }
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 50, color: Colors.red),
          SizedBox(height: 16),
          Text(
            errorTitle,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            errorMessage,
            style: TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refreshData,
            child: Text(strings.buttonRetry),
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
          Icon(Icons.history_toggle_off, size: 50, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            strings.noTicketsFoundLabel,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            strings.adjustFiltersMessage,
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final filteredTickets = _getFilteredTickets(_viewModel.tickets);
    final totalPages = (filteredTickets.length / _itemsPerPage).ceil().clamp(1, double.infinity).toInt();
    final paginatedTickets = _getPaginatedTickets(filteredTickets);

    return Scaffold(
      backgroundColor: AppColors.lightThemeBackground,
      appBar: CustomAppBar.appBarWithNavigation(
        screenTitle: strings.titleTicketHistory,
        onPressed: () => Navigator.pop(context),
        darkBackground: true, context: context,
      ),
      body: Column(
        children: [
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
                      if (_viewModel.error != null)
                        SizedBox(height: MediaQuery.of(context).size.height * 0.6, child: _buildErrorState(strings))
                      else if (filteredTickets.isEmpty && !_isLoading)
                        SizedBox(height: MediaQuery.of(context).size.height * 0.6, child: _buildEmptyState(strings))
                      else if (!_isLoading)
                          ...paginatedTickets.map((ticket) => _buildTicketCard(ticket, strings)),
                    ],
                  ),
                  if (_isLoading) _buildShimmerList(),
                ],
              ),
            ),
          ),
          if (!_isLoading && filteredTickets.isNotEmpty)
            PaginationControls(
              currentPage: _currentPage,
              totalPages: totalPages,
              onPageChange: _updatePage,
            ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase}${substring(1).toLowerCase()}";
  }
}