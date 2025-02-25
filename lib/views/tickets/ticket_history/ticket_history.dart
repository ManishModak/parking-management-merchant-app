import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:merchant_app/views/tickets/ticket_history/view_ticket.dart';
import 'package:provider/provider.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/app_strings.dart';
import '../../../../utils/components/appbar.dart';
import '../../../../utils/components/form_field.dart';
import '../../../../utils/components/pagination_controls.dart';
import '../../../viewmodels/ticket/ticket_history_viewmodel.dart';

class TicketHistoryScreen extends StatefulWidget {
  const TicketHistoryScreen({super.key});

  @override
  State<TicketHistoryScreen> createState() => _TicketHistoryScreenState();
}

class _TicketHistoryScreenState extends State<TicketHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  int _currentPage = 1;
  static const int _itemsPerPage = 10;
  bool _isLoadingTickets = false;

  // Updated dummy data including both open and rejected tickets
  final List<Map<String, dynamic>> tickets = [
    {
      'ticketId': 'TICKET-1739170533986',
      'plazaId': '01',
      'plazaName': 'Central Plaza',
      'entryLaneId': 'LANE-01',
      'entryLaneDirection': 'ENTRY',
      'floorId': 'F1',
      'slotId': 'S101',
      'vehicleNumber': 'MH14JK9827',
      'vehicleType': 'Car',
      'entryTime': '2025-02-10T06:55:53.984Z',
      'ticketCreationTime': '2025-02-10T06:55:53.984Z',
      'ticketStatus': 'Open',
      'capturedImageUrl': 'https://example.com/image1.jpg',
      'remarks': ''
    },
    {
      'ticketId': 'TICKET-1739170533987',
      'plazaId': '02',
      'plazaName': 'Highway Plaza',
      'entryLaneId': 'LANE-02',
      'entryLaneDirection': 'ENTRY',
      'floorId': 'F2',
      'slotId': 'S202',
      'vehicleNumber': 'KA03LM1234',
      'vehicleType': 'Bike',
      'entryTime': '2025-02-11T08:20:13.123Z',
      'ticketCreationTime': '2025-02-11T08:20:13.123Z',
      'ticketStatus': 'Rejected',
      'capturedImageUrl': 'https://example.com/image2.jpg',
      'remarks': 'Invalid vehicle details'
    }
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
        _currentPage = 1;
      });
    });
    _loadTicketsData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTicketsData() async {
    setState(() {
      _isLoadingTickets = true;
    });
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isLoadingTickets = false;
    });
  }

  List<Map<String, dynamic>> get filteredTickets {
    if (_searchQuery.isEmpty) return tickets;
    return tickets.where((ticket) {
      return ticket['ticketId']
          .toString()
          .toLowerCase()
          .contains(_searchQuery) ||
          ticket['plazaId'].toString().toLowerCase().contains(_searchQuery) ||
          ticket['vehicleNumber']
              .toString()
              .toLowerCase()
              .contains(_searchQuery) ||
          ticket['vehicleType']
              .toString()
              .toLowerCase()
              .contains(_searchQuery) ||
          ticket['plazaName'].toString().toLowerCase().contains(_searchQuery) ||
          ticket['ticketStatus']
              .toString()
              .toLowerCase()
              .contains(_searchQuery);
    }).toList();
  }

  List<Map<String, dynamic>> get paginatedTickets {
    final ticketsList = filteredTickets;
    int startIndex = (_currentPage - 1) * _itemsPerPage;
    int endIndex = startIndex + _itemsPerPage;
    if (startIndex >= ticketsList.length) return [];
    if (endIndex > ticketsList.length) endIndex = ticketsList.length;
    return ticketsList.sublist(startIndex, endIndex);
  }

  int get totalPages => (filteredTickets.length / _itemsPerPage).ceil();

  void _updatePage(int newPage) {
    if (newPage >= 1 && newPage <= totalPages) {
      setState(() {
        _currentPage = newPage;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _navigateToViewTicket(BuildContext context, Map<String, dynamic> ticket) {
    final ticketHistoryVM =
    Provider.of<TicketHistoryViewModel>(context, listen: false);
    ticketHistoryVM.initializeTicketData(ticket);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider.value(
          value: ticketHistoryVM,
          child: const ViewTicketScreen(),
        ),
      ),
    );
  }

  Widget _buildTicketCard(BuildContext context, Map<String, dynamic> ticket) {
    DateTime entryTime = DateTime.parse(ticket['entryTime']);
    String formattedEntryTime =
    DateFormat('dd MMM yyyy, hh:mm a').format(entryTime);
    Color statusColor = _getStatusColor(ticket['ticketStatus']);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () => _navigateToViewTicket(context, ticket),
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
                          padding: const EdgeInsets.only(right: 85),
                          child: Text(
                            ticket['ticketId'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              ticket['ticketStatus'],
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      'Vehicle Number',
                      ticket['vehicleNumber'],
                      'Vehicle Type',
                      ticket['vehicleType'],
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      'Plaza Name',
                      ticket['plazaName'],
                      'Entry Time',
                      formattedEntryTime,
                    ),
                    if (ticket['remarks']?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Remarks',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        ticket['remarks'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
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

  Widget _buildInfoRow(String label1, String value1, String label2, String value2) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label1,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
              Text(
                value1,
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
                label2,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
              Text(
                value2,
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
                ? 'There are no tickets in history'
                : 'No tickets match your search criteria',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                _searchController.clear();
              },
              child: const Text('Clear Search'),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TicketHistoryViewModel(),
      child: Builder(
        builder: (context) => Scaffold(
          backgroundColor: AppColors.lightThemeBackground,
          appBar: CustomAppBar.appBarWithNavigation(
            screenTitle: AppStrings.titleTicketHistory,
            onPressed: () => Navigator.pop(context),
            darkBackground: true,
          ),
          body: Consumer<TicketHistoryViewModel>(
            builder: (context, viewModel, child) {
              return _isLoadingTickets
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                children: [
                  CustomFormFields.searchFormField(
                    controller: _searchController,
                    hintText:
                    'Search by Ticket ID, Status, Plaza, Vehicle Number...',
                  ),
                  Expanded(
                    child: paginatedTickets.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: paginatedTickets.length,
                      itemBuilder: (context, index) {
                        final ticket = paginatedTickets[index];
                        return _buildTicketCard(context, ticket);
                      },
                    ),
                  ),
                ],
              );
            },
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
        ),
      ),
    );
  }
}