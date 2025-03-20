import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/config/app_config.dart';
import 'package:provider/provider.dart';
import '../../../../models/lane.dart';
import '../../../../utils/components/appbar.dart';
import '../../../../utils/components/form_field.dart';
import '../../../../utils/components/pagination_controls.dart';
import '../../../../utils/exceptions.dart';
import '../../../../utils/screens/loading_screen.dart';
import '../../../../viewmodels/plaza/plaza_viewmodel.dart';
import 'modify_view_lane_details.dart';

class LaneDetailsModificationScreen extends StatefulWidget {
  const LaneDetailsModificationScreen({super.key});

  @override
  State<LaneDetailsModificationScreen> createState() =>
      _LaneDetailsModificationScreenState();
}

class _LaneDetailsModificationScreenState
    extends State<LaneDetailsModificationScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _currentPage = 1;
  static const int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    final viewModel = context.read<PlazaViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.fetchLanes(viewModel.plazaId ?? '');
    });

    _searchController.addListener(() {
      setState(() {
        _currentPage = 1; // Reset to page 1 on search change
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updatePage(int newPage) {
    setState(() {
      _currentPage = newPage;
    });
  }

  Widget _buildSearchField() {
    return SizedBox(
      width: AppConfig.deviceWidth*0.95,
      child: CustomFormFields.searchFormField(
        controller: _searchController,
        hintText: 'Search lanes by name, ID or direction...', context: context,
      ),
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      width: AppConfig.deviceWidth*0.95,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            Icon(
              Icons.info_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No lanes found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isEmpty
                  ? 'There are no lanes for this plaza'
                  : 'No lanes match your search criteria',
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
      ),
    );
  }

  Widget _buildLaneCard(Lane lane) {
    final bool isActive = lane.laneStatus == 'active';
    final String statusText = isActive ? 'Active' : 'Inactive';

    return SizedBox(
      width: AppConfig.deviceWidth*0.95,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(
            color: isActive ? Colors.green.shade100 : Colors.red.shade100,
            width: 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ModifyViewLaneDetailsScreen(laneId: lane.laneId!),
              ),
            );
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
                                Text(
                                  "Lane Name",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  lane.laneName,
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? Colors.green.withValues(alpha: 0.1)
                                    : Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                statusText,
                                style: TextStyle(
                                  color: isActive ? Colors.green : Colors.red,
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
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Lane Direction',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  lane.laneDirection,
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
                                  'Lane Type',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  lane.laneType,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildDeviceInfo('RFID', lane.rfidReaderId),
                                const SizedBox(height: 4),
                                _buildDeviceInfo('Camera', lane.cameraId),
                                const SizedBox(height: 4),
                                _buildDeviceInfo('WIM', lane.wimId),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildDeviceInfo('Barrier', lane.boomerBarrierId),
                                const SizedBox(height: 4),
                                _buildDeviceInfo('LED', lane.ledScreenId),
                                const SizedBox(height: 4),
                                _buildDeviceInfo('Loop', lane.magneticLoopId),
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
      ),
    );
  }

  Widget _buildDeviceInfo(String label, String? value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            color: Colors.black,
          ),
        ),
        Expanded(
          child: Text(
            value?.isNotEmpty == true ? value! : 'N/A',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color:
              value?.isNotEmpty == true ? Colors.black87 : Colors.black,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(PlazaViewModel viewModel) {
    String errorTitle = 'Unable to Load Lanes';
    String errorMessage = 'Something went wrong. Please try again.';
    String? errorDetails;

    final error = viewModel.error;
    if (error != null) {
      if (error is HttpException) {
        final statusCode = error.statusCode;
        final serverMessage = error.serverMessage ?? 'No additional details provided';

        errorTitle = statusCode != null ? 'Error $statusCode' : 'Server Error';
        errorMessage = error.message;

        switch (statusCode) {
        case 502:
        errorTitle = 'Server Unavailable (502)';
        errorMessage = "We couldn't connect to the lane service.";
        errorDetails = serverMessage.isNotEmpty
        ? serverMessage
            : 'This might be a temporary server issue.';
        break;
        case 404:
        errorMessage = 'Lanes not found for this plaza.';
        errorDetails = 'No lanes available or invalid plaza ID.';
        break;
        default:
        errorDetails = serverMessage;
        }
      } else if (error is PlazaException) {
        errorTitle = 'Plaza Error';
        errorMessage = error.message;
        errorDetails = error.serverMessage ?? 'No additional details provided';
      } else if (error is ServiceException) {
        errorTitle = 'Service Error';
        errorMessage = error.message;
        errorDetails = error.serverMessage ?? 'Service-related issue occurred.';
      } else {
        errorMessage = error.toString();
        errorDetails = 'An unexpected error occurred. Please try again later.';
      }
    }

    return Center(
      child: SizedBox(
        width: AppConfig.deviceWidth*0.95,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                errorTitle,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              if (errorDetails != null) ...[
                const SizedBox(height: 8),
                Text(
                  errorDetails,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => viewModel.fetchLanes(viewModel.plazaId ?? ''),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(fontSize: 16, color: Colors.white),
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
    return Scaffold(
      backgroundColor: AppColors.lightThemeBackground,
      appBar: CustomAppBar.appBarWithNavigation(
        screenTitle: "Lane Details",
        onPressed: () => Navigator.pop(context),
        darkBackground: true, context: context,
      ),
      body: Consumer<PlazaViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) return const LoadingScreen();
          if (viewModel.error != null) return _buildErrorState(viewModel);

          // Filter lanes based on search query
          final filteredLanes = _searchQuery.isEmpty
              ? viewModel.lanes
              : viewModel.lanes.where((lane) {
            return lane.laneName.toLowerCase().contains(_searchQuery) ||
                lane.laneId.toString().contains(_searchQuery) ||
                lane.laneDirection.toLowerCase().contains(_searchQuery);
          }).toList();

          // Calculate total pages
          final totalPages = (filteredLanes.length / _itemsPerPage).ceil();

          // Calculate paginated lanes
          int startIndex = (_currentPage - 1) * _itemsPerPage;
          int endIndex = startIndex + _itemsPerPage;
          if (startIndex >= filteredLanes.length) {
            startIndex = 0;
            _currentPage = 1;
          }
          if (endIndex > filteredLanes.length) endIndex = filteredLanes.length;
          final paginatedLanes = filteredLanes.sublist(startIndex, endIndex);

          return Center(
            child: SizedBox(
              width: AppConfig.deviceWidth*0.95,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 12),
                  Card(
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_city,
                            color: Colors.grey.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  viewModel.formState.basicDetails['plazaName'] ??
                                      'Unknown Plaza',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  "ID: ${viewModel.plazaId ?? 'Unknown ID'}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSearchField(),
                  Flexible(
                    child: RefreshIndicator(
                      onRefresh: () => viewModel.fetchLanes(viewModel.plazaId ?? ''),
                      child: paginatedLanes.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                        itemCount: paginatedLanes.length,
                        padding: EdgeInsets.zero,
                        itemBuilder: (context, index) {
                          final lane = paginatedLanes[index];
                          return _buildLaneCard(lane);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'addLaneFAB',
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Disabled Needs to Discuss. Prev Implementation Same As in Plaza Registration"),
              backgroundColor: Colors.black,
            ),
          );
          // TODO: Implement navigation to add lane page
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: Consumer<PlazaViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading || viewModel.lanes.isEmpty) return const SizedBox.shrink();
          final filteredLanes = _searchQuery.isEmpty
              ? viewModel.lanes
              : viewModel.lanes.where((lane) {
            return lane.laneName.toLowerCase().contains(_searchQuery) ||
                lane.laneId.toString().contains(_searchQuery) ||
                lane.laneDirection.toLowerCase().contains(_searchQuery);
          }).toList();
          final totalPages = (filteredLanes.length / _itemsPerPage).ceil();

          return Container(
            color: AppColors.lightThemeBackground,
            child: SafeArea(
              child: PaginationControls(
                currentPage: _currentPage,
                totalPages: totalPages,
                onPageChange: _updatePage,
              ),
            ),
          );
        },
      ),
    );
  }
}