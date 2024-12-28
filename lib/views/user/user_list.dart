import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/config/app_strings.dart';
import 'package:merchant_app/services/auth_service.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:merchant_app/utils/components/button.dart';
import 'package:merchant_app/utils/components/card.dart';
import 'package:merchant_app/utils/components/form_field.dart';
import 'package:merchant_app/utils/screens/loading_screen.dart';
import 'package:merchant_app/viewmodels/user_viewmodel.dart';
import 'package:provider/provider.dart';

import 'user_info.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  late final UserViewModel _viewModel;
  final AuthService _authService = AuthService();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<UserViewModel>(context, listen: false);
    Future.microtask(() => _viewModel.fetchUserList(_authService.getUserId()));

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<dynamic> _getFilteredOperators(List<dynamic> operators) {
    if (_searchQuery.isEmpty) {
      return operators;
    }
    return operators.where((operator) {
      return operator.name.toLowerCase().contains(_searchQuery) ||
          operator.role.toLowerCase().contains(_searchQuery) ||
          operator.mobileNumber.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightThemeBackground,
      appBar: CustomAppBar.appBarWithNavigationAndActions(
        screenTitle: AppStrings.titleUsers,
        onPressed: () {
          Navigator.pop(context);
        },
        darkBackground: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: CustomButtons.downloadIconButton(
              onPressed: () {
                // Handle download action
              },
              darkBackground: false,
            ),
          ),
        ],
      ),
      body: Consumer<UserViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: LoadingScreen());
          }

          if (viewModel.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(viewModel.error!),
                  ElevatedButton(
                    onPressed: () {
                      Future.microtask(
                              () => viewModel.fetchUserList(_authService.getUserId()));
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final filteredOperators = _getFilteredOperators(viewModel.operators);

          return Column(
            children: [
              CustomFormFields.searchFormField(controller: _searchController),
              Expanded(
                child: Scrollbar(
                  controller: _scrollController,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: filteredOperators.length,
                    cacheExtent: 100.0,
                    itemBuilder: (context, index) {
                      final operator = filteredOperators[index];
                      return KeyedSubtree(
                        key: ValueKey(operator.id),
                        child: CustomCards.operatorCard(
                          imageUrl: operator.imageUrl,
                          operatorName: operator.name,
                          role: operator.role,
                          contactNumber: operator.mobileNumber,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserInfoScreen(operatorId: operator.id),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}