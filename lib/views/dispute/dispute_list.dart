import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../config/app_colors.dart';
import '../../config/app_routes.dart';
import '../../utils/components/appbar.dart';
import '../../utils/components/form_field.dart';
import '../../utils/components/pagination_controls.dart';
import '../../utils/exceptions.dart';
import '../../viewmodels/dispute/dispute_list_viewmodel.dart';

class DisputeList extends StatefulWidget {
  const DisputeList({super.key, required this.viewDisputeOptionSelect});

  final bool viewDisputeOptionSelect;

  @override
  State<DisputeList> createState() => _DisputeListState();
}

class _DisputeListState extends State<DisputeList> with RouteAware {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  late DisputeListViewModel _viewModel;
  late RouteObserver<ModalRoute> _routeObserver;
  String _searchQuery = '';
  int _currentPage = 1;
  static const int _itemsPerPage = 10;
  bool _isLoading = false;
  Timer? _debounce;

  // Filter-related state
  Set<String> _selectedStatuses = {};
  Set<String> _selectedVehicleTypes = {};
  Set<String> _selectedPlazaNames = {};
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _viewModel = DisputeListViewModel();
    _setDefaultDateRange(); // Set "Today" as default
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
    if (!mounted) return;
    setState(() => _isLoading = true);
    await _viewModel.fetchOpenTickets();
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _routeObserver = Provider.of<RouteObserver<ModalRoute>>(context, listen: false);
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
    if (!mounted) return;
    setState(() => _isLoading = true);
    await _viewModel.fetchOpenTickets();
    if (mounted) setState(() => _isLoading = false);
  }

  List<Map<String, dynamic>> _getFilteredTickets(List<Map<String, dynamic>> tickets) {
    return tickets.where((ticket) {
      final matchesSearch = _searchQuery.isEmpty ||
          (ticket['ticketID']?.toString().toLowerCase().contains(_searchQuery) ?? false) ||
          (ticket['plazaID']?.toString().toLowerCase().contains(_searchQuery) ?? false) ||
          (ticket['vehicleNumber']?.toString().toLowerCase().contains(_searchQuery) ?? false) ||
          (ticket['vehicleType']?.toString().toLowerCase().contains(_searchQuery) ?? false) ||
          (ticket['plazaName']?.toString().toLowerCase().contains(_searchQuery) ?? false) ||
          (ticket['status']?.toString().toLowerCase().contains(_searchQuery) ?? false);

      final matchesStatus = _selectedStatuses.isEmpty ||
          _selectedStatuses.contains(ticket['status']?.toString().toLowerCase());

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
    return endIndex > filteredTickets.length
        ? filteredTickets.sublist(startIndex)
        : filteredTickets.sublist(startIndex, endIndex);
  }

  void _updatePage(int newPage) {
    final filteredTickets = _getFilteredTickets(_viewModel.tickets);
    final totalPages = (filteredTickets.length / _itemsPerPage).ceil().clamp(1, double.infinity).toInt();
    if (newPage < 1 || newPage > totalPages) return;
    setState(() => _currentPage = newPage);
  }

  Widget _buildDateFilterChip() {
    String displayText;
    if (_selectedDateRange == null) {
      displayText = 'Date Range';
    } else if (_isTodayRange(_selectedDateRange!)) {
      displayText = 'Today';
    } else if (_isYesterdayRange(_selectedDateRange!)) {
      displayText = 'Yesterday';
    } else if (_isLast7DaysRange(_selectedDateRange!)) {
      displayText = 'Last 7 Days';
    } else if (_isLast30DaysRange(_selectedDateRange!)) {
      displayText = 'Last 30 Days';
    } else {
      displayText = '${DateFormat('dd MMM').format(_selectedDateRange!.start)} - '
          '${DateFormat('dd MMM').format(_selectedDateRange!.end)}';
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

  Widget _buildMoreFiltersChip() {
    final hasActiveFilters = _selectedStatuses.isNotEmpty ||
        _selectedVehicleTypes.isNotEmpty ||
        _selectedPlazaNames.isNotEmpty;

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
              'Filters',
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

  Widget _buildFilterChipsRow() {
    final selectedFilters = [
      ..._selectedStatuses.map((s) => 'Status: ${s.capitalize()}'),
      ..._selectedVehicleTypes.map((v) => 'Vehicle: ${v.capitalize()}'),
      ..._selectedPlazaNames.map((p) => 'Plaza: $p'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
        child: Row(
          children: [
            _buildDateFilterChip(),
            const SizedBox(width: 8),
            _buildMoreFiltersChip(),
            if (selectedFilters.isNotEmpty) ...[
              const SizedBox(width: 8),
              ...selectedFilters.map((filter) => Container(
                margin: const EdgeInsets.only(right: 8),
                child: Chip(
                  label: Text(filter),
                  onDeleted: () {
                    setState(() {
                      if (filter.startsWith('Status:')) {
                        _selectedStatuses.remove(filter.split(': ')[1].toLowerCase());
                      } else if (filter.startsWith('Vehicle:')) {
                        _selectedVehicleTypes.remove(filter.split(': ')[1].toLowerCase());
                      } else if (filter.startsWith('Plaza:')) {
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      'Advanced Filters',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: [
                        _buildFilterSection(
                          title: 'Dispute Status',
                          options: [
                            {'key': 'open', 'label': 'Open'},
                            {'key': 'pending', 'label': 'Pending'},
                            {'key': 'complete', 'label': 'Completed'},
                            {'key': 'rejected', 'label': 'Rejected'}
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
                          title: 'Vehicle Type',
                          options: [
                            {'key': 'bike', 'label': 'Bike'},
                            {'key': '3-wheeler', 'label': '3-Wheeler'},
                            {'key': '4-wheeler', 'label': '4-Wheeler'},
                            {'key': 'bus', 'label': 'Bus'},
                            {'key': 'truck', 'label': 'Truck'},
                            {'key': 'hmv', 'label': 'Heavy Machinery'}
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
                          title: 'Plaza Name',
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
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              setDialogState(() {
                                _selectedStatuses.clear();
                                _selectedVehicleTypes.clear();
                                _selectedPlazaNames.clear();
                              });
                            },
                            child: const Text('Clear All'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _currentPage = 1;
                              });
                              Navigator.pop(context);
                            },
                            child: const Text('Apply', style: TextStyle(color: Colors.white)),
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
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
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
                onSelected: (bool value) => onChanged(option['key']!, value),
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
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search $title',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onChanged: (value) {
                  setLocalState(() {
                    filteredOptions = options
                        .where((option) => option.toLowerCase().contains(value.toLowerCase()))
                        .toList();
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

  Widget _buildSearchField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildFilterChipsRow(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: CustomFormFields.searchFormField(
            controller: _searchController,
            hintText: 'Search by Ticket ID, Status, Plaza, Vehicle Number...', context: context,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Last updated: ${DateTime.now().toString().substring(0, 16)}. Swipe down to refresh.',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Future<DateTimeRange?> _selectCustomDateRange(BuildContext context, DateTimeRange? initialRange) async {
    final earliestDate = DateTime.now().subtract(const Duration(days: 365 * 5));
    final picked = await showDateRangePicker(
      context: context,
      firstDate: earliestDate,
      lastDate: DateTime.now(),
      initialDateRange: initialRange,
      builder: (context, child) => Theme(
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
      ),
    );

    if (picked == null) return null;

    final start = picked.start.isBefore(earliestDate) ? earliestDate : picked.start;
    final end = picked.end.isAfter(DateTime.now()) ? DateTime.now() : picked.end;

    final maxAllowedRange = const Duration(days: 365);
    if (end.difference(start) > maxAllowedRange) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a date range within one year.'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }

    return DateTimeRange(start: start, end: end);
  }

  void _showDateFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      'Select Date Range',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
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
                                label: 'Today',
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
                                label: 'Yesterday',
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
                                label: 'Last 7 Days',
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
                                label: 'Last 30 Days',
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
                                label: 'Custom',
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
                        'Selected Range: ${DateFormat('dd MMM yyyy').format(tempDateRange!.start)} - '
                            '${DateFormat('dd MMM yyyy').format(tempDateRange!.end)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
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
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              setDialogState(() {
                                tempDateRange = null;
                                selectedOption = null;
                              });
                            },
                            child: const Text('Clear'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _selectedDateRange = tempDateRange;
                                _currentPage = 1;
                              });
                              Navigator.pop(context);
                            },
                            child: const Text('Apply', style: TextStyle(color: Colors.white)),
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
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1,
          ),
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

  Widget _buildTicketCard(Map<String, dynamic> ticket) {
    DateTime entryTime = DateTime.parse(ticket['entryTime'] ?? DateTime.now().toString());
    String formattedEntryTime = DateFormat('dd MMM, hh:mm a').format(entryTime);
    Color statusColor;
    switch (ticket['status'].toString().toLowerCase()) {
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
          developer.log('Ticket card tapped: ${ticket['ticketID']}');
          if (widget.viewDisputeOptionSelect) {
            Navigator.pushNamed(
              context,
              AppRoutes.disputeDetail,
              arguments: {'ticketId': ticket['ticketID'].toString()},
            ).then((_) => _refreshData());
          } else {
            Navigator.pushNamed(
              context,
              AppRoutes.processDispute,
              arguments: {'ticketId': ticket['ticketID'].toString()},
            ).then((_) => _refreshData());
          }
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
                            '${ticket['plazaName']?.toString() ?? 'N/A'} | ${ticket['entryLaneId']?.toString() ?? 'N/A'}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.normal,
                              color: Colors.black,
                            ),
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
                            ticket['status'].toString(),
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ticket['ticketRefID']?.toString() ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          ticket['vehicleNumber']?.toString() ?? 'N/A',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6.0),
                          child: Text('|', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        ),
                        Text(
                          ticket['vehicleType']?.toString() ?? 'N/A',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6.0),
                          child: Text('|', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        ),
                        Text(
                          formattedEntryTime,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
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

  Widget _buildErrorState() {
    String errorTitle = 'Unable to Load Disputes';
    String errorMessage = 'Something went wrong. Please try again.';
    final error = _viewModel.error;
    if (error != null) {
      developer.log('Error occurred: $error');
      if (error is NoInternetException) {
        errorTitle = 'No Internet Connection';
        errorMessage = 'Please check your internet connection and try again.';
      } else if (error is RequestTimeoutException) {
        errorTitle = 'Request Timed Out';
        errorMessage = 'The server is taking too long to respond. Please try again later.';
      } else if (error is HttpException) {
        errorTitle = 'Server Error';
        errorMessage = 'We couldn’t reach the server. Please try again.';
        switch (error.statusCode) {
          case 400:
            errorTitle = 'Invalid Request';
            errorMessage = 'The request was incorrect.';
            break;
          case 401:
            errorTitle = 'Unauthorized';
            errorMessage = 'Please log in again.';
            break;
          case 403:
            errorTitle = 'Access Denied';
            errorMessage = 'You don’t have permission.';
            break;
          case 404:
            errorTitle = 'Not Found';
            errorMessage = 'No disputes were found.';
            break;
          case 500:
            errorTitle = 'Server Issue';
            errorMessage = 'Problem on our end.';
            break;
        }
      } else if (error is ServiceException) {
        errorTitle = 'Unexpected Error';
        errorMessage = 'An unexpected issue occurred.';
      }
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 50, color: Colors.red),
          SizedBox(height: 16),
          Text(errorTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text(errorMessage, style: const TextStyle(fontSize: 14), textAlign: TextAlign.center),
          SizedBox(height: 16),
          ElevatedButton(onPressed: _refreshData, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off, size: 50, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No disputes found.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Try adjusting your filters or swipe down to refresh.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredTickets = _getFilteredTickets(_viewModel.tickets);
    final totalPages = (filteredTickets.length / _itemsPerPage).ceil().clamp(1, double.infinity).toInt();
    final paginatedTickets = _getPaginatedTickets(filteredTickets);

    return Scaffold(
      backgroundColor: AppColors.lightThemeBackground,
      appBar: CustomAppBar.appBarWithNavigation(
        screenTitle: "Dispute Tickets",
        onPressed: () => Navigator.pop(context),
        darkBackground: true, context: context,
      ),
      body: Column(
        children: [
          _buildSearchField(),
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
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: _buildErrorState(),
                        )
                      else if (filteredTickets.isEmpty && !_isLoading)
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: _buildEmptyState(),
                        )
                      else if (!_isLoading)
                          ...paginatedTickets.map((ticket) => _buildTicketCard(ticket)),
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
  String capitalize() => "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
}