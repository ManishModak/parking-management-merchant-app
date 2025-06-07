import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_config.dart';
import 'package:merchant_app/utils/components/dropdown.dart';
import 'package:merchant_app/utils/components/form_field.dart';
import 'package:provider/provider.dart';
import '../../../config/app_colors.dart';
import '../../../generated/l10n.dart';
import '../../../viewmodels/dispute/process_dispute_viewmodel.dart';

class ProcessDisputeDialog extends StatefulWidget {
  final String ticketId;

  const ProcessDisputeDialog({super.key, required this.ticketId});

  @override
  _ProcessDisputeDialogState createState() => _ProcessDisputeDialogState();
}

class _ProcessDisputeDialogState extends State<ProcessDisputeDialog> {
  late TextEditingController _remarkController;

  @override
  void initState() {
    super.initState();
    final viewModel = Provider.of<ProcessDisputeViewModel>(context, listen: false);
    _remarkController = TextEditingController(text: viewModel.remark);
    // Fetch details after the build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.fetchDisputeDetails(widget.ticketId);
    });
  }

  @override
  void dispose() {
    _remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    return Consumer<ProcessDisputeViewModel>(
      builder: (context, viewModel, child) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            width: AppConfig.deviceWidth * 0.95,
            constraints: BoxConstraints(maxHeight: AppConfig.deviceHeight * 0.75),
            child: viewModel.isLoading && viewModel.dispute == null
                ? Center(child: CircularProgressIndicator())
                : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Text(
                    strings.titleProcessDispute,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (viewModel.error != null)
                          Padding(
                            padding: EdgeInsets.only(bottom: 12),
                            child: Text(
                              viewModel.error!,
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                        SizedBox(height: 24),
                        CustomDropDown.normalDropDown(
                          label: strings.labelDisputeAction,
                          value: viewModel.selectedAction,
                          items: viewModel.disputeActions,
                          onChanged: viewModel.updateAction,
                          errorText: viewModel.actionError,
                          context: context,
                        ),
                        SizedBox(height: 12),
                        CustomFormFields.largeSizedTextFormField(
                          label: strings.labelEnterRemark,
                          controller: _remarkController,
                          enabled: true,
                          onChanged: viewModel.updateRemark,
                          errorText: viewModel.remarkError,
                          context: context,
                        ),
                        SizedBox(height: 12),
                        _buildFileUploadSection(viewModel, strings),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        child: Text(strings.buttonCancel),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: viewModel.isLoading
                            ? null
                            : () async {
                          developer.log('Submitting dispute action for ticketId: ${widget.ticketId}',
                              name: 'ProcessDisputeDialog.Submit');
                          if (viewModel.validateInputs()) {
                            const processedBy = 'admin@example.com';
                            final success = await viewModel.submitDisputeAction(processedBy);
                            if (success) {
                              developer.log('Dispute processed successfully for ticketId: ${widget.ticketId}',
                                  name: 'ProcessDisputeDialog.Success');
                              Navigator.pop(context, true);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(strings.messageDisputeProcessed)),
                              );
                            } else {
                              developer.log(
                                  'Failed to process dispute for ticketId: ${widget.ticketId}, error: ${viewModel.error}',
                                  name: 'ProcessDisputeDialog.Failure');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(viewModel.error ?? strings.errorProcessDispute)),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        child: viewModel.isLoading
                            ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : Text(strings.buttonSubmit, style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFileUploadSection(ProcessDisputeViewModel viewModel, S strings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (viewModel.filePaths.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(strings.labelUploadedFiles,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              TextButton(
                onPressed: viewModel.isLoading ? null : viewModel.pickFile,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(strings.buttonAddMore, style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          SizedBox(height: 8),
          SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: viewModel.filePaths.length,
              itemBuilder: (context, index) {
                final filePath = viewModel.filePaths[index];
                final isPdf = filePath.toLowerCase().endsWith('.pdf');
                return Padding(
                  padding: EdgeInsets.only(right: 6.0),
                  child: Stack(
                    children: [
                      Container(
                        width: AppConfig.deviceWidth * 0.25,
                        height: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: isPdf
                              ? _buildPdfPreview(filePath, strings)
                              : Image.file(
                            File(filePath),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Center(
                              child: Icon(Icons.broken_image,
                                  color: Colors.grey, size: 50),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: InkWell(
                          onTap: viewModel.isLoading ? null : () => viewModel.removeFile(index),
                          child: Container(
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.close, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ] else ...[
          InkWell(
            onTap: viewModel.isLoading ? null : viewModel.pickFile,
            child: Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                color: AppColors.formBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.upload_file, size: 32),
                  SizedBox(height: 4),
                  Text(strings.labelAddImagesOrPdfs,
                      style: TextStyle(color: Colors.black, fontSize: 14)),
                ],
              ),
            ),
          ),
        ],
        if (viewModel.fileError != null)
          Padding(
            padding: EdgeInsets.only(top: 4.0),
            child: Text(
              viewModel.fileError!,
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildPdfPreview(String filePath, S strings) {
    final fileName = filePath.split('/').last;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.picture_as_pdf, size: 50, color: Colors.red),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              fileName,
              style: TextStyle(fontSize: 12, color: Colors.black),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}