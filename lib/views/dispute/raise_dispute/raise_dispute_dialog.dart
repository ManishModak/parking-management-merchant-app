import 'dart:io';
import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_config.dart';
import 'package:merchant_app/utils/components/dropdown.dart';
import 'package:provider/provider.dart';

import '../../../config/app_colors.dart';
import '../../../utils/components/form_field.dart';
import '../../../viewmodels/dispute/raise_dispute_viewmodel.dart';

class RaiseDisputeDialog extends StatefulWidget {
  final String ticketId;

  const RaiseDisputeDialog({super.key, required this.ticketId});

  @override
  _RaiseDisputeDialogState createState() => _RaiseDisputeDialogState();
}

class _RaiseDisputeDialogState extends State<RaiseDisputeDialog> {
  late TextEditingController _amountController;
  late TextEditingController _remarkController;

  @override
  void initState() {
    super.initState();
    final viewModel = Provider.of<RaiseDisputeViewModel>(context, listen: false);
    _amountController = TextEditingController(text: viewModel.disputeAmount);
    _remarkController = TextEditingController(text: viewModel.remark);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RaiseDisputeViewModel>(
      builder: (context, viewModel, child) {
        return Dialog(
          // Set custom shape and inset padding
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          // Direct child is our custom content
          child: Container(
            width: AppConfig.deviceWidth * 0.95,
            constraints: BoxConstraints(
              maxHeight: AppConfig.deviceHeight * 0.75,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Default header style
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Text(
                    'Raise Dispute',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),

                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 24),
                        CustomDropDown.normalDropDown(
                          label: 'Dispute Reason',
                          value: viewModel.selectedReason,
                          items: viewModel.disputeReasons,
                          onChanged: viewModel.updateReason,
                          errorText: viewModel.reasonError, context: context,
                        ),
                        const SizedBox(height: 12),
                        CustomFormFields.normalSizedTextFormField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          onChanged: viewModel.updateAmount,
                          enabled: true,
                          errorText: viewModel.amountError,
                          label: 'Dispute Amount',
                          isPassword: false, context: context,
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

                // Actions
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          if (viewModel.validate()) {
                            await viewModel.submitDispute(widget.ticketId);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Dispute raised successfully!')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

  Widget _buildImageUploadSection(RaiseDisputeViewModel viewModel) {
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
          SizedBox(height: 8,),
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
                        width: AppConfig.deviceWidth*0.25,
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
                  Icon(Icons.camera_alt_outlined,size: 32,),
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