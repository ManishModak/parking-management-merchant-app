  import 'package:flutter/material.dart';
                import 'package:intl/intl.dart';
                import 'package:provider/provider.dart';
                import 'package:shimmer/shimmer.dart'; // Added shimmer import
                import '../../../../config/app_colors.dart';
                import '../../../../config/app_strings.dart';
                import '../../../../utils/components/appbar.dart';
                import '../../../../utils/components/form_field.dart';
                import '../../../../utils/components/pagination_controls.dart';
                import 'modify_view_open_ticket.dart';
                import '../../../viewmodels/ticket/open_ticket_viewmodel.dart';

                class OpenTicketsScreen extends StatefulWidget {
                  const OpenTicketsScreen({super.key});

                  @override
                  State<OpenTicketsScreen> createState() => _OpenTicketsScreenState();
                }

                class _OpenTicketsScreenState extends State<OpenTicketsScreen> {
                  final TextEditingController _searchController = TextEditingController();
                  String _searchQuery = "";
                  int _currentPage = 1;
                  static const int _itemsPerPage = 10;
                  late OpenTicketViewModel _viewModel;
                  final _refreshKey = GlobalKey<RefreshIndicatorState>();

                  @override
                  void initState() {
                    super.initState();
                    _viewModel = OpenTicketViewModel();

                    _searchController.addListener(() {
                      setState(() {
                        _searchQuery = _searchController.text.toLowerCase();
                        _currentPage = 1;
                      });
                    });

                    WidgetsBinding.instance.addPostFrameCallback((_) async {
                      await Future.delayed(const Duration(seconds: 3));
                      _viewModel.fetchOpenTickets();
                    });
                  }

                  @override
                  void dispose() {
                    _searchController.dispose();
                    _viewModel.dispose();
                    super.dispose();
                  }

                  Future<void> _refreshTickets() async {
                    await _viewModel.fetchOpenTickets();
                    setState(() {
                      _currentPage = 1;
                    });
                  }

                  List<Map<String, dynamic>> _filterTickets(List<Map<String, dynamic>> tickets) {
                    if (_searchQuery.isEmpty) return tickets;

                    return tickets.where((ticket) {
                      final searchLower = _searchQuery.toLowerCase();
                      return ticket['ticketID'].toString().toLowerCase().contains(searchLower) ||
                          ticket['plazaID'].toString().toLowerCase().contains(searchLower) ||
                          ticket['vehicleNumber'].toString().toLowerCase().contains(searchLower) ||
                          ticket['vehicleType'].toString().toLowerCase().contains(searchLower) ||
                          ticket['plazaName'].toString().toLowerCase().contains(searchLower);
                    }).toList();
                  }

                  void _updatePage(int newPage) {
                    final filteredTickets = _filterTickets(_viewModel.tickets);
                    final totalPages = (filteredTickets.length / _itemsPerPage).ceil();
                    if (newPage >= 1 && newPage <= totalPages) {
                      setState(() {
                        _currentPage = newPage;
                      });
                    }
                  }

                  Widget _buildTicketCard(Map<String, dynamic> ticket) {
                    DateTime entryTime = DateTime.parse(ticket['entryTime']);
                    String formattedEntryTime = DateFormat('dd MMM yyyy, hh:mm a').format(entryTime);

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(15),
                        onTap: () {
                          final detailViewModel = OpenTicketViewModel();
                          detailViewModel.initializeTicketData(ticket);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChangeNotifierProvider<OpenTicketViewModel>.value(
                                value: detailViewModel,
                                child: const ModifyViewOpenTicketScreen(),
                              ),
                            ),
                          ).then((_) => _refreshTickets());
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
                                    _buildTicketHeader(ticket),
                                    const SizedBox(height: 12),
                                    _buildVehicleInfo(ticket),
                                    const SizedBox(height: 12),
                                    _buildPlazaInfo(ticket, formattedEntryTime),
                                  ],
                                ),
                              ),
                              Container(
                                width: 30,
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.chevron_right,
                                  color: AppColors.primary,
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  Widget _buildTicketHeader(Map<String, dynamic> ticket) {
                    return Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(right: 65),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Ticket Id: ",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              Text(
                                ticket['ticketRefID'].toString(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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
                              ticket['status'].toString(),
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  Widget _buildVehicleInfo(Map<String, dynamic> ticket) {
                    return Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Vehicle Number',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                ticket['vehicleNumber'].toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Vehicle Type',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                ticket['vehicleType'].toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  Widget _buildPlazaInfo(Map<String, dynamic> ticket, String formattedEntryTime) {
                    return Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Plaza Name',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                ticket['plazaName'].toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Entry Time',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                formattedEntryTime,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  Widget _buildEmptyState() {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.confirmation_number_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No tickets found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _searchQuery.isEmpty
                                ? 'There are no open tickets at the moment'
                                : 'No tickets match your search criteria',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          if (_searchQuery.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () => _searchController.clear(),
                              child: const Text('Clear Search'),
                            ),
                          ],
                        ],
                      ),
                    );
                  }

                  Widget _buildShimmerList() {
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: _itemsPerPage,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey.shade300,
                            highlightColor: Colors.grey.shade100,
                            direction: ShimmerDirection.ltr,
                            period: const Duration(milliseconds: 1200),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Header Section (Ticket ID and Status)
                                        Stack(
                                          children: [
                                            Container(
                                              width: double.infinity,
                                              padding: const EdgeInsets.only(right: 65),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    width: 100,
                                                    height: 16,
                                                    color: Colors.white,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Container(
                                                    width: 150,
                                                    height: 16,
                                                    color: Colors.white,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Positioned(
                                              right: 0,
                                              child: Container(
                                                width: 60,
                                                height: 24,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        // Vehicle Info Section
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    width: 80,
                                                    height: 12,
                                                    color: Colors.white,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Container(
                                                    width: 100,
                                                    height: 14,
                                                    color: Colors.white,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    width: 80,
                                                    height: 12,
                                                    color: Colors.white,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Container(
                                                    width: 100,
                                                    height: 14,
                                                    color: Colors.white,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        // Plaza Info Section
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    width: 80,
                                                    height: 12,
                                                    color: Colors.white,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Container(
                                                    width: 120,
                                                    height: 14,
                                                    color: Colors.white,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    width: 80,
                                                    height: 12,
                                                    color: Colors.white,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Container(
                                                    width: 140,
                                                    height: 13,
                                                    color: Colors.white,
                                                  ),
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
                                    height: 24,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }

                  @override
                  Widget build(BuildContext context) {
                    return ChangeNotifierProvider.value(
                      value: _viewModel,
                      child: Consumer<OpenTicketViewModel>(
                        builder: (context, viewModel, child) {
                          if (viewModel.isLoading && viewModel.tickets.isEmpty) {
                            return Scaffold(
                              appBar: CustomAppBar.appBarWithNavigation(
                                screenTitle: AppStrings.titleOpenTickets,
                                onPressed: () => Navigator.pop(context),
                                darkBackground: true,
                              ),
                              body: _buildShimmerList(), // Replaced LoadingScreen with shimmer list
                            );
                          }

                          if (viewModel.error != null && viewModel.tickets.isEmpty) {
                            return Scaffold(
                              backgroundColor: AppColors.lightThemeBackground,
                              appBar: CustomAppBar.appBarWithNavigation(
                                screenTitle: AppStrings.titleOpenTickets,
                                onPressed: () => Navigator.pop(context),
                                darkBackground: true,
                              ),
                              body: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${viewModel.error}',
                                      style: const TextStyle(color: Colors.red),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: _refreshTickets,
                                      child: const Text('Retry'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          final filteredTickets = _filterTickets(viewModel.tickets);
                          final totalPages = (filteredTickets.length / _itemsPerPage).ceil();

                          int startIndex = (_currentPage - 1) * _itemsPerPage;
                          if (startIndex >= filteredTickets.length) {
                            startIndex = 0;
                            _currentPage = 1;
                          }

                          int endIndex = startIndex + _itemsPerPage;
                          if (endIndex > filteredTickets.length) {
                            endIndex = filteredTickets.length;
                          }

                          final paginatedTickets = filteredTickets.sublist(startIndex, endIndex);

                          return Scaffold(
                            backgroundColor: AppColors.lightThemeBackground,
                            appBar: CustomAppBar.appBarWithNavigation(
                              screenTitle: AppStrings.titleOpenTickets,
                              onPressed: () => Navigator.pop(context),
                              darkBackground: true,
                            ),
                            body: RefreshIndicator(
                              key: _refreshKey,
                              onRefresh: _refreshTickets,
                              child: Column(
                                children: [
                                  CustomFormFields.searchFormField(
                                    controller: _searchController,
                                    hintText: 'Search by Ticket ID, Plaza, Vehicle Number...',
                                  ),
                                  Expanded(
                                    child: paginatedTickets.isEmpty
                                        ? _buildEmptyState()
                                        : ListView.builder(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      itemCount: paginatedTickets.length,
                                      itemBuilder: (context, index) =>
                                          _buildTicketCard(paginatedTickets[index]),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            bottomNavigationBar: paginatedTickets.isNotEmpty
                                ? Container(
                              color: AppColors.lightThemeBackground,
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
                      ),
                    );
                  }
                }