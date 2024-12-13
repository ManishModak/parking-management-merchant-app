import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/config/app_config.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:merchant_app/utils/components/button.dart';
import 'package:merchant_app/utils/components/card.dart';

class PlazaInfoScreen extends StatefulWidget {
  const PlazaInfoScreen({super.key});

  @override
  State<PlazaInfoScreen> createState() => _PlazaInfoScreenState();
}

class _PlazaInfoScreenState extends State<PlazaInfoScreen> {
  TextEditingController _plazaNameController = TextEditingController(text: 'MG Plaza');
  TextEditingController _plazaMobileNoController = TextEditingController();
  bool _isEditing = false;

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _savePlazaData() {
    // Update the plaza data with the new values
    // and save the changes
    setState(() {
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightThemeBackground,
      appBar: CustomAppBar.appBarWithNavigationAndActions(
        screenTitle: _isEditing ? 'Edit Plaza' : _plazaNameController.text,
        onPressed: () {
          if (_isEditing) {
            _savePlazaData();
          } else {
            Navigator.pop(context);
          }
        },
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: _isEditing ? _savePlazaData : _toggleEditMode,
          ),
        ],
        darkBackground: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              child: Column(
                children: [
                  CustomCards.plazaImageCard(),
                  SizedBox(height: 2,),
                  Row(

                  ),
                  SizedBox(height: 2,),
                  Row(

                  ),
                ],
              ),
            ),
            Container(
              height: AppConfig.deviceHeight * 0.50,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    CustomCards.plazaInfoCard(controller: _plazaMobileNoController, labelText: 'Plaza Mobile No.', icon: Icons.edit)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}