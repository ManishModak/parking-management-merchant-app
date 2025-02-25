import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/config/app_config.dart';
import 'package:merchant_app/utils/screens/loading_screen.dart';
import 'package:provider/provider.dart';
import 'package:merchant_app/config/app_routes.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:merchant_app/utils/components/card.dart';

import '../../viewmodels/plaza/plaza_viewmodel.dart';

class PlazaInfoScreen extends StatefulWidget {
  final dynamic plazaId;

  const PlazaInfoScreen({super.key, this.plazaId});

  @override
  State<PlazaInfoScreen> createState() => _PlazaInfoScreenState();
}

class _PlazaInfoScreenState extends State<PlazaInfoScreen> {
  late String plazaId;
  late final PlazaViewModel _viewModel;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<PlazaViewModel>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _initializePlaza();
      _isInitialized = true;
    }
  }

  void _initializePlaza() {
    final routeArgs = widget.plazaId ?? ModalRoute.of(context)?.settings.arguments;
    plazaId = routeArgs?.toString() ?? '';

    if (plazaId.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid plaza ID')),
        );
      });
    } else {
      // Schedule the data fetch for after the current build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadPlazaDetails();
      });
    }
  }

  Future<void> _loadPlazaDetails() async {
    try {
      await _viewModel.fetchPlazaDetailsById(plazaId);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading plaza details: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.appBarWithNavigation(
        screenTitle: "Plaza Info",
        onPressed: () => Navigator.pop(context),
        darkBackground: true,
      ),
      body: Consumer<PlazaViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return const LoadingScreen();
          }

          return PlazaInfoContent(
            viewModel: viewModel,
            plazaId: plazaId,
          );
        },
      ),
    );
  }
}

class PlazaInfoContent extends StatelessWidget {
  final PlazaViewModel viewModel;
  final String plazaId;

  const PlazaInfoContent({
    super.key,
    required this.viewModel,
    required this.plazaId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: PlazaHeaderCard(viewModel: viewModel),
        ),
        Expanded(
          child: PlazaMenuList(plazaId: plazaId),
        ),
      ],
    );
  }
}

class PlazaHeaderCard extends StatelessWidget {
  final PlazaViewModel viewModel;

  const PlazaHeaderCard({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
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
            PlazaHeaderInfo(viewModel: viewModel),
            const SizedBox(height: 16),
            PlazaStatusBar(viewModel: viewModel),
          ],
        ),
      ),
    );
  }
}

class PlazaHeaderInfo extends StatelessWidget {
  final PlazaViewModel viewModel;

  const PlazaHeaderInfo({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
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
                viewModel.formState.basicDetails['plazaName'] ?? 'Plaza Name',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              PlazaIdBadge(plazaId: viewModel.plazaId ?? ''),
            ],
          ),
        ),
      ],
    );
  }
}

class PlazaIdBadge extends StatelessWidget {
  final String plazaId;

  const PlazaIdBadge({
    super.key,
    required this.plazaId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
            "ID: $plazaId",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class PlazaStatusBar extends StatelessWidget {
  final PlazaViewModel viewModel;

  const PlazaStatusBar({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          StatusItem(
            icon: Icons.schedule_rounded,
            label: 'Status',
            value: viewModel.formState.basicDetails['plazaStatus'] ?? 'Active',
          ),
          Container(
            height: 30,
            width: 1,
            color: Colors.white.withOpacity(0.2),
          ),
          StatusItem(
            icon: Icons.category_rounded,
            label: 'Category',
            value: viewModel.formState.basicDetails['plazaCategory'] ?? 'Standard',
          ),
        ],
      ),
    );
  }
}

class StatusItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const StatusItem({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
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
}

class PlazaMenuList extends StatelessWidget {
  final String plazaId;

  const PlazaMenuList({
    super.key,
    required this.plazaId,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
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
    );
  }
}