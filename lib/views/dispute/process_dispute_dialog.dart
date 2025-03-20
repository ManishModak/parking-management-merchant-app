import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_config.dart';
import 'package:merchant_app/utils/components/dropdown.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../../utils/components/form_field.dart';
import '../../../viewmodels/dispute/process_dispute_viewmodel.dart';
import '../../config/app_colors.dart';

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
  }

  @override
  void dispose() {
    _remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProcessDisputeViewModel>(
      builder: (context, viewModel, child) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            width: AppConfig.deviceWidth * 0.95,
            constraints: BoxConstraints(
              maxHeight: AppConfig.deviceHeight * 0.75,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Text(
                    'Process Dispute',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 24),
                        CustomDropDown.normalDropDown(
                          label: 'Dispute Action',
                          value: viewModel.selectedAction,
                          items: viewModel.disputeActions,
                          onChanged: viewModel.updateAction,
                          errorText: viewModel.actionError, context: context,
                        ),
                        const SizedBox(height: 12),
                        CustomFormFields.largeSizedTextFormField(
                          label: 'Enter Remark',
                          controller: _remarkController,
                          enabled: true,
                          onChanged: viewModel.updateRemark,
                          errorText: viewModel.remarkError, context: context,
                        ),
                        const SizedBox(height: 12),
                        _buildImageUploadSection(viewModel),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          if (viewModel.validate()) {
                            await viewModel.submitDisputeAction(widget.ticketId);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Dispute processed successfully!')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        child: const Text('Submit'),
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

  Widget _buildImageUploadSection(ProcessDisputeViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (viewModel.imagePaths.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Uploaded Images', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              TextButton(
                onPressed: viewModel.pickImage,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Add More', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          SizedBox(height: 8),
          SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: viewModel.imagePaths.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
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
                          child: Image.file(
                            File(viewModel.imagePaths[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: InkWell(
                          onTap: () => viewModel.removeImage(index),
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
            onTap: viewModel.pickImage,
            child: Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                color:  AppColors.formBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt_outlined, size: 32),
                  SizedBox(height: 4),
                  Text('Tap to Add Images',
                      style: TextStyle(color: Colors.black, fontSize: 14)),
                ],
              ),
            ),
          ),
        ],
        if (viewModel.imageError != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(viewModel.imageError!,
                style: const TextStyle(color: Colors.red, fontSize: 12)),
          ),
      ],
    );
  }
}