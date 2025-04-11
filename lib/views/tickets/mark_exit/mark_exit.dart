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
import '../../../utils/exceptions.dart';
import '../../../viewmodels/ticket/mark_exit_viewmodel.dart';
import 'mark_exit_details.dart';

class MarkExitScreen extends StatefulWidget {
  const MarkExitScreen({super.key});

  @override
  State<MarkExitScreen> createState() => _MarkExitScreenState();
}

class _MarkExitScreenState extends State<MarkExitScreen> with RouteAware {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  late MarkExitViewModel _viewModel;
  late RouteObserver<ModalRoute> _routeObserver;
  String _searchQuery = '';
  int _currentPage = 1;
  static const int _itemsPerPage = 10;
  bool _isLoading = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _viewModel = MarkExitViewModel();
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

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    await _viewModel.fetchOpenTickets();
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
    await _viewModel.fetchOpenTickets();
    setState(() => _isLoading = false);
  }

  List<Map<String, dynamic>> _getFilteredTickets(List<Map<String, dynamic>> tickets) {
    if (_searchQuery.isEmpty) return tickets;
    return tickets.where((ticket) {
      return (ticket['ticketID']?.toString().toLowerCase().contains(_searchQuery) ?? false) ||
          (ticket['plazaID']?.toString().toLowerCase().contains(_searchQuery) ?? false) ||
          (ticket['vehicleNumber']?.toString().toLowerCase().contains(_searchQuery) ?? false) ||
          (ticket['vehicleType']?.toString().toLowerCase().contains(_searchQuery) ?? false) ||
          (ticket['plazaName']?.toString().toLowerCase().contains(_searchQuery) ?? false);
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

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomFormFields.searchFormField(
            controller: _searchController,
            hintText: 'Search by Ticket ID, Plaza, Vehicle Number...', context: context,
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
          Icon(Icons.confirmation_number_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No tickets to mark as exited',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty ? 'There are no open tickets to mark as exited' : 'No tickets match your search criteria',
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
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: _itemsPerPage,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              Container(width: 150, height: 16, color: Colors.white),
                              Positioned(right: 0, child: Container(width: 60, height: 24, color: Colors.white)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(width: 80, height: 12, color: Colors.white),
                                    const SizedBox(height: 4),
                                    Container(width: 100, height: 14, color: Colors.white),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(width: 80, height: 12, color: Colors.white),
                                    const SizedBox(height: 4),
                                    Container(width: 100, height: 14, color: Colors.white),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(width: 80, height: 12, color: Colors.white),
                                    const SizedBox(height: 4),
                                    Container(width: 120, height: 14, color: Colors.white),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(width: 80, height: 12, color: Colors.white),
                                    const SizedBox(height: 4),
                                    Container(width: 140, height: 13, color: Colors.white),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(width: 30, height: 24, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState() {
    String errorTitle = 'Unable to Load Tickets';
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
            errorMessage = 'The request was incorrect. Please try again or contact support.';
            break;
          case 401:
            errorTitle = 'Unauthorized';
            errorMessage = 'Please log in again to continue.';
            break;
          case 403:
            errorTitle = 'Access Denied';
            errorMessage = 'You don’t have permission to view this. Contact support if this is an error.';
            break;
          case 404:
            errorTitle = 'Not Found';
            errorMessage = 'No open tickets were found to mark as exited. Please try again.';
            break;
          case 500:
            errorTitle = 'Server Issue';
            errorMessage = 'There’s a problem on our end. Please try again later.';
            break;
          case 502:
            errorTitle = 'Service Unavailable';
            errorMessage = 'The service is temporarily down. Please try again.';
            break;
          case 503:
            errorTitle = 'Service Overloaded';
            errorMessage = 'The server is busy. Please try again in a moment.';
            break;
          default:
            errorTitle = 'Server Error';
            errorMessage = 'An unexpected server issue occurred. Please try again.';
            break;
        }
      } else if (error is ServiceException) {
        errorTitle = 'Service Error';
        errorMessage = 'Failed to fetch tickets. Please try again.';
      }
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(
            errorTitle,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              errorMessage,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _refreshData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketCard(Map<String, dynamic> ticket) {
    DateTime entryTime = DateTime.parse(ticket['entryTime']);
    String formattedEntryTime = DateFormat('dd MMM yyyy, hh:mm a').format(entryTime);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          developer.log('Ticket card tapped: ${ticket['ticketID']}');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChangeNotifierProvider.value(
                value: _viewModel,
                child: MarkExitDetailsScreen(ticketId: ticket['ticketID'],),
              ),
            ),
          ).then((_) => _refreshData());
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(right: 65),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Ticket ID', style: TextStyle(fontSize: 16, color: Colors.black)),
                              Text(ticket['ticketRefID'].toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        Positioned(
                          right: 0,
                          child: Container(
                            width: 60,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              ticket['ticketStatus'].toString(),
                              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600, fontSize: 13),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Vehicle Number', style: TextStyle(color: Colors.black, fontSize: 12)),
                              Text(ticket['vehicleNumber'].toString(), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Vehicle Type', style: TextStyle(color: Colors.black, fontSize: 12)),
                              Text(ticket['vehicleType'].toString(), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Plaza Name', style: TextStyle(color: Colors.black, fontSize: 12)),
                              Text(ticket['plazaName'].toString(), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Entry Time', style: TextStyle(color: Colors.black, fontSize: 12)),
                              Text(formattedEntryTime, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 30,
                alignment: Alignment.center,
                child: Icon(Icons.chevron_right, color: AppColors.primary, size: 24),
              ),
            ],
          ),
        ),
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
        screenTitle: 'Mark Exit',
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
  }
}