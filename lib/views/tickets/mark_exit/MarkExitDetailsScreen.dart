import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../config/app_colors.dart';
import '../../../../utils/components/appbar.dart';
import '../../../viewmodels/ticket/mark_exit_viewmodel.dart';

class MarkExitDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> ticket;

  const MarkExitDetailsScreen({super.key, required this.ticket});

  Future<void> _handleMarkExit(BuildContext context, MarkExitViewModel viewModel) async {
    bool? confirmExit = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark Exit'),
        content: Text('Are you sure you want to mark ticket ${ticket['ticketRefID']} as exited?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmExit == true) {
      final success = await viewModel.markTicketAsExited(ticket['ticketRefID']);
      if (success) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ticket marked as exited successfully')),
          );
          Navigator.pop(context); // Return to MarkExitScreen
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(viewModel.apiError ?? 'Failed to mark ticket as exited'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MarkExitViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: AppColors.lightThemeBackground,
          appBar: CustomAppBar.appBarWithNavigation(
            screenTitle: 'Mark Exit Details',
            onPressed: () => Navigator.pop(context),
            darkBackground: true,
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Ticket ID', ticket['ticketRefID']),
                    _buildDetailRow('Plaza Name', ticket['plazaName']),
                    _buildDetailRow('Vehicle Number', ticket['vehicleNumber']),
                    _buildDetailRow('Vehicle Type', ticket['vehicleType']),
                    _buildDetailRow('Entry Time', ticket['entryTime']),
                    _buildDetailRow('Status', ticket['status']),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: viewModel.isLoading ? null : () => _handleMarkExit(context, viewModel),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Mark as Exited'),
                    ),
                  ],
                ),
              ),
              if (viewModel.isLoading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value?.toString() ?? 'N/A',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}