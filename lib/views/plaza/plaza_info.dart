import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/config/app_config.dart';
import 'package:merchant_app/utils/screens/loading_screen.dart';
import 'package:provider/provider.dart';
import 'package:merchant_app/config/app_routes.dart';
import 'package:merchant_app/viewmodels/plaza_viewmodel/plaza_viewmodel.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:merchant_app/utils/components/card.dart';

class PlazaInfoScreen extends StatefulWidget {
  const PlazaInfoScreen({super.key});

  @override
  State<PlazaInfoScreen> createState() => _PlazaInfoScreenState();
}

class _PlazaInfoScreenState extends State<PlazaInfoScreen> {
  late String plazaId;
  late final PlazaViewModel _viewModel;
  bool _initialLoad = true;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<PlazaViewModel>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialLoad) {
      final routeArgs = ModalRoute.of(context)?.settings.arguments;
      plazaId = (routeArgs is String) ? routeArgs : '';

      // Schedule all side effects after the build phase
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (plazaId.isEmpty) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid plaza ID')),
          );
        } else {
          _loadPlazaDetails();
        }
      });

      _initialLoad = false;
    }
  }

  Future<void> _loadPlazaDetails() async {
    try {
      await _viewModel.fetchPlazaDetailsById(plazaId);
      if (!mounted) return;
      // Handle errors if needed
    } catch (e) {
      if (!mounted) return;
      // Handle exceptions
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.appBarWithNavigation(
        screenTitle: "Plaza Info",
        onPressed: () => Navigator.pop(context),
        darkBackground: true,
      ),
      // In the build method's Consumer widget:
      body: Consumer<PlazaViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return const LoadingScreen();
          }
          return Column(
            children: [
              // Plaza Header Card
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  margin: EdgeInsets.zero,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Container(
                    width: AppConfig.deviceWidth,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primaryLight.withOpacity(0.8)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.location_city_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    viewModel.formState
                                            .basicDetails['plazaName'] ??
                                        'Plaza Name',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.numbers_rounded,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "ID: ${viewModel.plazaId!}",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatusItem(
                                icon: Icons.schedule_rounded,
                                label: 'Status',
                                value: viewModel.formState
                                        .basicDetails['plazaStatus'] ??
                                    'Active',
                              ),
                              Container(
                                height: 30,
                                width: 1,
                                color: Colors.white.withOpacity(0.2),
                              ),
                              _buildStatusItem(
                                icon: Icons.category_rounded,
                                label: 'Category',
                                value: viewModel.formState
                                        .basicDetails['plazaCategory'] ??
                                    'Standard',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Menu List
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    CustomCards.menuCard(
                      menu: "Basic Details",
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.basicDetailsModification,
                      ),
                    ),
                    CustomCards.menuCard(
                      menu: "Lane Details",
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.laneDetailsModification,
                      ),
                    ),
                    CustomCards.menuCard(
                      menu: "Bank Details",
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.bankDetailsModification,
                      ),
                    ),
                    CustomCards.menuCard(
                      menu: "Plaza Images",
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.plazaImagesModification,
                        arguments: plazaId,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}


Widget _buildStatusItem({
  required IconData icon,
  required String label,
  required String value,
}) {
  return Row(
    children: [
      Icon(
        icon,
        color: Colors.white,
        size: 20,
      ),
      const SizedBox(width: 8),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ],
  );
}
