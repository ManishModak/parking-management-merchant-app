import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/config/app_strings.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:merchant_app/utils/components/button.dart';
import 'package:merchant_app/utils/components/card.dart';
import 'package:merchant_app/utils/screens/loading_screen.dart';
import 'package:merchant_app/viewmodels/plaza_viewmodel.dart';
import 'package:provider/provider.dart';

class PlazaListScreen extends StatefulWidget {
  const PlazaListScreen({super.key});

  @override
  State<PlazaListScreen> createState() => _PlazaListScreenState();
}

class _PlazaListScreenState extends State<PlazaListScreen> {
  final ScrollController _scrollController = ScrollController();
  late final PlazaViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<PlazaViewModel>(context, listen: false);
    Future.microtask(() => _viewModel.fetchUserPlazas('current_user_id'));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightThemeBackground,
      appBar: CustomAppBar.appBarWithNavigationAndActions(
        screenTitle: AppStrings.titlePlazas,
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
          )
        ],
      ),
      body: Consumer<PlazaViewModel>(
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
                      // Schedule the fetch after the current build
                      Future.microtask(() =>
                          viewModel.fetchUserPlazas('current_user_id')
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: Scrollbar(
                  controller: _scrollController,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16.0),
                    itemCount: viewModel.userPlazas.length,
                    cacheExtent: 100.0,
                    itemBuilder: (context, index) {
                      final plaza = viewModel.userPlazas[index];
                      return KeyedSubtree(
                        key: ValueKey(plaza.id),
                        child: CustomCards.plazaCard(
                          imageUrl: plaza.imageUrl,
                          plazaName: plaza.name,
                          location: plaza.location,
                          onTap: () {
                            // Handle plaza tap
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