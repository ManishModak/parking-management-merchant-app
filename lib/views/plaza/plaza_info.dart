import 'dart:developer' as developer;
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'package:merchant_app/config/app_config.dart';
import 'package:merchant_app/generated/l10n.dart';
import 'package:merchant_app/utils/components/button.dart';
import 'package:merchant_app/utils/exceptions.dart';
import 'package:provider/provider.dart';
import 'package:merchant_app/config/app_routes.dart';
import 'package:merchant_app/config/app_theme.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:shimmer/shimmer.dart';
import '../../viewmodels/plaza/plaza_modification_viewmodel.dart';

class PlazaInfoScreen extends StatefulWidget {
  final dynamic plazaId;

  const PlazaInfoScreen({super.key, this.plazaId});

  @override
  State<PlazaInfoScreen> createState() => _PlazaInfoScreenState();
}

class _PlazaInfoScreenState extends State<PlazaInfoScreen> with RouteAware {
  static const String _logName = 'PlazaInfoScreen';
  late String _plazaId = '';
  late final PlazaModificationViewModel _viewModel;
  bool _isInitialized = false;
  bool _hasFetchError = false;
  int _currentImagePage = 0;
  bool _isImagesExpanded = true;
  int _fetchAttemptId = 0;
  bool _isFetching = false;
  late RouteObserver<ModalRoute> _routeObserver;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<PlazaModificationViewModel>();
    developer.log('initState', name: _logName);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      developer.log('didChangeDependencies - First time initialization', name: _logName);
      _initializePlaza();
      _isInitialized = true;
    }
    final route = ModalRoute.of(context);
    if (route != null) {
      _routeObserver = Provider.of<RouteObserver<ModalRoute>>(context, listen: false);
      _routeObserver.subscribe(this, route);
      developer.log('Subscribed to RouteObserver', name: _logName);
    } else {
      developer.log('Failed to subscribe to RouteObserver: ModalRoute is null.',
          name: _logName, level: 900);
    }
  }

  @override
  void dispose() {
    developer.log('dispose - Unsubscribing from RouteObserver', name: _logName);
    _routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    developer.log('didPopNext - Screen became visible again. Refreshing details.',
        name: _logName);
    if (_isInitialized && mounted && _plazaId.isNotEmpty) {
      _loadPlazaDetails();
    }
  }

  void _initializePlaza() {
    final routeArgs = widget.plazaId ?? ModalRoute.of(context)?.settings.arguments;
    final potentialPlazaId = routeArgs?.toString();
    final strings = S.of(context);

    developer.log('Initializing Plaza with args: $routeArgs, potentialPlazaId: $potentialPlazaId',
        name: _logName);

    if (potentialPlazaId == null || potentialPlazaId.isEmpty) {
      _hasFetchError = true;
      developer.log('Invalid or missing Plaza ID during init.', name: _logName, level: 1000);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(strings.invalidPlazaId), backgroundColor: Colors.red),
          );
          _viewModel.resetState();
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        }
      });
      if (mounted) setState(() {});
    } else {
      _plazaId = potentialPlazaId;
      developer.log('Plaza ID set to: $_plazaId. Scheduling initial load.', name: _logName);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _loadPlazaDetails();
        }
      });
    }
  }

  Future<void> _loadPlazaDetails() async {
    if (!mounted || _plazaId.isEmpty || _isFetching) {
      developer.log('Skipping _loadPlazaDetails (not mounted, no plazaId, or fetch in progress).',
          name: _logName);
      return;
    }
    _isFetching = true;
    _hasFetchError = false;
    _fetchAttemptId++;
    developer.log('Starting _loadPlazaDetails for ID: $_plazaId, Attempt: $_fetchAttemptId',
        name: _logName);

    if (mounted && !_viewModel.isLoading) {
      setState(() {});
    }

    try {
      await _viewModel.fetchAllPlazaDetails(_plazaId);
      developer.log('fetchAllPlazaDetails completed successfully.', name: _logName);
    } catch (e, stackTrace) {
      _hasFetchError = true;
      developer.log('Error loading plaza details: $e', name: _logName,
          error: e, stackTrace: stackTrace, level: 1000);
    } finally {
      if (mounted) {
        setState(() {});
      }
      _isFetching = false;
      developer.log('Finished _loadPlazaDetails attempt.', name: _logName);
      developer.log('Finished _loadPlazaDetails attempt.', name: _logName);
    }
  }

  PreferredSizeWidget _buildCustomAppBar(PlazaModificationViewModel viewModel, S strings) {
    final bool isDataActuallyLoaded = viewModel.plazaId == _plazaId &&
        !viewModel.isLoading &&
        viewModel.error == null &&
        viewModel.formState.basicDetails.isNotEmpty;

    final plazaName = viewModel.formState.basicDetails['plazaName'] as String?;
    final displayPlazaName = (isDataActuallyLoaded && plazaName?.isNotEmpty == true)
        ? plazaName
        : strings.labelLoading;

    final status = viewModel.formState.basicDetails['plazaStatus'] as String?;
    final displayStatus = (isDataActuallyLoaded && status?.isNotEmpty == true)
        ? status!.capitalize()
        : '';

    final String titleText = (isDataActuallyLoaded)
        ? "${strings.labelPlaza}: $displayPlazaName${displayStatus.isNotEmpty ? "\n${strings.labelStatus}: $displayStatus" : ""}"
        : "${strings.plazaInfoTitle}\n(${strings.labelLoading.toLowerCase()})";

    return CustomAppBar.appBarWithNavigation(
      screenTitle: titleText,
      onPressed: () => Navigator.pop(context),
      context: context,
      fontSize: 14,
      centreTitle: true,
      darkBackground: Theme.of(context).brightness == Brightness.dark,
    );
  }

  Widget _buildLoadingState(S strings) {
    developer.log('Building loading shimmer state.', name: _logName);
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Shimmer.fromColors(
        baseColor: Theme.of(context).brightness == Brightness.light
            ? AppColors.shimmerBaseLight
            : AppColors.shimmerBaseDark,
        highlightColor: Theme.of(context).brightness == Brightness.light
            ? AppColors.shimmerHighlightLight
            : AppColors.shimmerHighlightDark,
        child: Column(
          children: [
            _buildShimmerSectionCard(fieldCount: 5),
            _buildShimmerSectionCard(fieldCount: 2),
            _buildShimmerSectionCard(isImageSection: true),
            _buildShimmerSectionCard(isActionCard: true),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerSectionCard({
    int fieldCount = 3,
    bool isImageSection = false,
    bool isActionCard = false,
  }) {
    final cardColor = Theme.of(context).cardTheme.color ?? Theme.of(context).cardColor;
    final shimmerPlaceholderColor = Colors.white.withOpacity(0.5);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      shape: Theme.of(context).cardTheme.shape ??
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isActionCard)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(width: 150, height: 20, color: shimmerPlaceholderColor),
                  Container(width: 30, height: 20, color: shimmerPlaceholderColor),
                ],
              ),
            if (!isActionCard) const SizedBox(height: 16),
            if (isImageSection)
              SizedBox(
                height: 140,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  children: List.generate(
                    3,
                        (index) => Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Container(
                        width: (AppConfig.deviceWidth * 0.9 - 48 - 16) / 3,
                        height: 140,
                        decoration: BoxDecoration(
                          color: shimmerPlaceholderColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            else if (isActionCard)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(width: 24, height: 24, color: shimmerPlaceholderColor),
                      const SizedBox(width: 12),
                      Container(width: 120, height: 20, color: shimmerPlaceholderColor),
                    ],
                  ),
                  Container(width: 24, height: 24, color: shimmerPlaceholderColor),
                ],
              )
            else
              ...List.generate(
                fieldCount,
                    (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildShimmerFieldPair(shimmerPlaceholderColor)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildShimmerFieldPair(shimmerPlaceholderColor)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerFieldPair(Color placeholderColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(width: 100, height: 14, color: placeholderColor),
        const SizedBox(height: 6),
        Container(width: 130, height: 18, color: placeholderColor),
      ],
    );
  }

  Widget _buildErrorState(Exception error, S strings) {
    developer.log('Building error state: ${error.runtimeType} - $error', name: _logName);
    String errorTitle = strings.errorTitleDefault;
    String errorMessage = strings.errorMessageDefault;
    String? errorDetails;

    if (error is HttpException) {
      errorTitle = strings.errorTitleWithCode(error.statusCode ?? 0);
      errorMessage = error.message;
      errorDetails = error.serverMessage;
    } else if (error is ServiceException) {
      errorTitle = strings.errorTitleService;
      errorMessage = error.message;
      errorDetails = error.serverMessage;
    } else {
      errorTitle = strings.errorLoadingPlazaDetailsFailed;
      errorMessage = strings.errorMessagePleaseTryAgain;
      errorDetails = error.toString();
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 64, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text(
              errorTitle,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: context.textPrimaryColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: context.textSecondaryColor),
              textAlign: TextAlign.center,
            ),
            if (errorDetails != null && errorDetails.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                "Details: $errorDetails",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.textSecondaryColor),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            CustomButtons.primaryButton(
              height: 40,
              width: 150,
              text: strings.buttonRetry,
              onPressed: _loadPlazaDetails,
              context: context,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem({required String title, required String value, required S strings}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            value.isEmpty ? strings.labelNA : value,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.9)),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicDetailsSection(PlazaModificationViewModel viewModel, S strings) {
    final details = viewModel.formState.basicDetails;
    final plazaCategory = details['plazaCategory'] as String?;
    final plazaSubCategory = details['plazaSubCategory'] as String?;
    final bool areDetailsLoaded = details.isNotEmpty && details['plazaName'] != null;

    return Card(
      elevation: Theme.of(context).cardTheme.elevation,
      margin: Theme.of(context).cardTheme.margin,
      shape: Theme.of(context).cardTheme.shape,
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  strings.menuBasicDetails,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.edit_outlined, color: Theme.of(context).colorScheme.primary, size: 20),
                  onPressed: areDetailsLoaded && viewModel.error == null
                      ? () {
                    developer.log('Navigating to Basic Details Mod', name: _logName);
                    Navigator.pushNamed(context, AppRoutes.basicDetailsModification, arguments: _plazaId).then(
                          (_) => developer.log('Returned from Basic Details Mod', name: _logName),
                    );
                  }
                      : null,
                  tooltip: strings.tooltipEditBasicDetails,
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            if (areDetailsLoaded) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      title: strings.labelOwner,
                      value: details['plazaOwner']?.toString() ?? '',
                      strings: strings,
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      title: strings.labelOperator,
                      value: details['plazaOperatorName']?.toString() ?? '',
                      strings: strings,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      title: strings.labelMobileNumber,
                      value: details['mobileNumber']?.toString() ?? '',
                      strings: strings,
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      title: strings.labelPincode,
                      value: details['pincode']?.toString() ?? '',
                      strings: strings,
                    ),
                  ),
                ],
              ),
              _buildDetailItem(
                title: strings.labelEmail,
                value: details['email']?.toString() ?? '',
                strings: strings,
              ),
              _buildDetailItem(
                title: strings.labelAddress,
                value: details['address']?.toString() ?? '',
                strings: strings,
              ),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildDetailItem(
                      title: strings.labelCategory,
                      value: plazaCategory?.capitalize() ?? strings.labelNA,
                      strings: strings,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: _buildDetailItem(
                      title: strings.labelSubCategory,
                      value: plazaSubCategory?.capitalize() ?? strings.labelNA,
                      strings: strings,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: _buildDetailItem(
                      title: strings.labelCity,
                      value: details['city']?.toString() ?? '',
                      strings: strings,
                    ),
                  ),
                ],
              ),
            ] else if (!viewModel.isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: Text(strings.loadingEllipsis, style: TextStyle(color: context.textSecondaryColor)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankDetailsSection(PlazaModificationViewModel viewModel, S strings) {
    final details = viewModel.formState.bankDetails;
    final bool hasBankDetails = details.isNotEmpty && (details['bankName']?.toString().isNotEmpty ?? false);
    final bool areBasicDetailsLoaded = viewModel.formState.basicDetails.isNotEmpty;

    return Card(
      elevation: Theme.of(context).cardTheme.elevation,
      margin: Theme.of(context).cardTheme.margin,
      shape: Theme.of(context).cardTheme.shape,
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  strings.menuBankDetails,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.edit_outlined, color: Theme.of(context).colorScheme.primary, size: 20),
                  onPressed: areBasicDetailsLoaded && viewModel.error == null
                      ? () {
                    developer.log('Navigating to Bank Details Mod', name: _logName);
                    Navigator.pushNamed(context, AppRoutes.bankDetailsModification, arguments: _plazaId).then(
                          (_) => developer.log('Returned from Bank Details Mod', name: _logName),
                    );
                  }
                      : null,
                  tooltip: strings.tooltipEditBankDetails,
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (areBasicDetailsLoaded) ...[
              if (hasBankDetails) ...[
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem(
                        title: strings.labelBankName,
                        value: details['bankName']?.toString() ?? '',
                        strings: strings,
                      ),
                    ),
                    Expanded(
                      child: _buildDetailItem(
                        title: strings.labelAccountHolder,
                        value: details['accountHolderName']?.toString() ?? '',
                        strings: strings,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem(
                        title: strings.labelAccountNumber,
                        value: details['accountNumber']?.toString() ?? '',
                        strings: strings,
                      ),
                    ),
                    Expanded(
                      child: _buildDetailItem(
                        title: strings.labelIFSC,
                        value: details['IFSCcode']?.toString() ?? '',
                        strings: strings,
                      ),
                    ),
                  ],
                ),
              ] else
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                    child: Text(
                      strings.messageNoBankDetails,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                    ),
                  ),
                ),
            ] else if (!viewModel.isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: Text(strings.loadingEllipsis, style: TextStyle(color: context.textSecondaryColor)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(PlazaModificationViewModel viewModel, S strings) {
    final images = viewModel.formState.plazaImages;
    final bool areBasicDetailsLoaded = viewModel.formState.basicDetails.isNotEmpty;

    return Card(
      elevation: Theme.of(context).cardTheme.elevation,
      margin: Theme.of(context).cardTheme.margin,
      shape: Theme.of(context).cardTheme.shape,
      color: Theme.of(context).cardColor,
      child: ExpansionTile(
        key: const ValueKey('plazaImagesExpansionTile'),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              strings.menuPlazaImages,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (images.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${images.length}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                if (images.isNotEmpty) const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.edit_outlined, color: Theme.of(context).colorScheme.primary, size: 20),
                  onPressed: areBasicDetailsLoaded && viewModel.error == null
                      ? () {
                    developer.log('Navigating to Images Mod', name: _logName);
                    Navigator.pushNamed(context, AppRoutes.plazaImagesModification, arguments: _plazaId).then(
                          (_) => developer.log('Returned from Images Mod', name: _logName),
                    );
                  }
                      : null,
                  tooltip: strings.tooltipEditImages,
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ],
        ),
        initiallyExpanded: _isImagesExpanded,
        onExpansionChanged: (expanded) => setState(() => _isImagesExpanded = expanded),
        shape: const Border(),
        collapsedShape: const Border(),
        tilePadding: const EdgeInsets.only(left: 16, right: 8, top: 4, bottom: 4),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (images.isEmpty && !viewModel.isLoading && areBasicDetailsLoaded)
                  SizedBox(
                    height: 150,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported_outlined,
                            size: 48,
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            strings.messageNoImagesAvailable,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (images.isNotEmpty) ...[
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _getCurrentImages(images).length,
                      itemBuilder: (context, index) {
                        final imageUrl = _getCurrentImages(images)[index];
                        final imageWidth = (AppConfig.deviceWidth * 0.9 - 48 - 16) / 3;
                        final isNetworkImage = imageUrl.startsWith('http');
                        final isFileImage = !isNetworkImage && File(imageUrl).existsSync();
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Container(
                            width: imageWidth,
                            decoration: BoxDecoration(
                              border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(11),
                              child: GestureDetector(
                                onTap: () => _showZoomableImageDialog(imageUrl, isNetworkImage, isFileImage, strings),
                                child: isNetworkImage
                                    ? CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      _buildShimmerPlaceholder(width: imageWidth, height: 150),
                                  errorWidget: (context, url, error) =>
                                      _buildImageErrorWidget(strings, isNetwork: true),
                                )
                                    : isFileImage
                                    ? Image.file(
                                  File(imageUrl),
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, st) =>
                                      _buildImageErrorWidget(strings, isNetwork: false),
                                )
                                    : _buildImageErrorWidget(
                                  strings,
                                  isNetwork: false,
                                  message: strings.errorImageNotFound,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (_getTotalPages(images) > 1) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios, size: 18),
                          color: _currentImagePage > 0
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).disabledColor,
                          onPressed: _currentImagePage > 0 ? () => setState(() => _currentImagePage--) : null,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${strings.labelPage} ${_currentImagePage + 1} ${strings.labelOf} ${_getTotalPages(images)}',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios, size: 18),
                          color: _currentImagePage < _getTotalPages(images) - 1
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).disabledColor,
                          onPressed: _currentImagePage < _getTotalPages(images) - 1
                              ? () => setState(() => _currentImagePage++)
                              : null,
                        ),
                      ],
                    ),
                  ],
                ] else if (!areBasicDetailsLoaded && !viewModel.isLoading)
                  SizedBox(
                    height: 150,
                    child: Center(child: Text(strings.loadingEllipsis)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageErrorWidget(S strings, {required bool isNetwork, String? message}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image_outlined,
              size: 32,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(height: 4),
            Text(
              message ?? (isNetwork ? strings.errorImageLoadFailed : strings.errorImageNotFound),
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerPlaceholder({double width = double.infinity, double height = 20}) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).brightness == Brightness.light ? Colors.grey[300]! : Colors.grey[700]!,
      highlightColor: Theme.of(context).brightness == Brightness.light ? Colors.grey[100]! : Colors.grey[600]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showZoomableImageDialog(String imagePath, bool isNetworkImage, bool isFileImage, S strings) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(10),
          child: Stack(
            alignment: Alignment.center,
            children: [
              InteractiveViewer(
                boundaryMargin: const EdgeInsets.all(20.0),
                minScale: 0.5,
                maxScale: 4.0,
                child: isNetworkImage
                    ? CachedNetworkImage(
                  imageUrl: imagePath,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => Center(child: _buildShimmerPlaceholder(height: 300, width: 300)),
                  errorWidget: (context, url, error) => _buildImageErrorWidget(strings, isNetwork: true),
                )
                    : isFileImage
                    ? Image.file(
                  File(imagePath),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildImageErrorWidget(strings, isNetwork: false),
                )
                    : _buildImageErrorWidget(strings, isNetwork: false, message: strings.errorImageNotFound),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Material(
                  color: Colors.black54,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => Navigator.of(context).pop(),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.close, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<String> _getCurrentImages(List<String> allImages) {
    if (allImages.isEmpty) return [];
    const int imagesPerPage = 3;
    final startIndex = _currentImagePage * imagesPerPage;
    final endIndex = (startIndex + imagesPerPage).clamp(0, allImages.length);
    return allImages.sublist(startIndex, endIndex);
  }

  int _getTotalPages(List<String> allImages) {
    if (allImages.isEmpty) return 0;
    const int imagesPerPage = 3;
    return (allImages.length / imagesPerPage).ceil();
  }

  Widget _buildLaneDetailsAction(PlazaModificationViewModel viewModel, S strings) {
    final bool canNavigate = viewModel.formState.basicDetails.isNotEmpty && viewModel.error == null;
    final int laneCount = viewModel.lanes.length;

    return Card(
      elevation: Theme.of(context).cardTheme.elevation,
      margin: Theme.of(context).cardTheme.margin,
      shape: Theme.of(context).cardTheme.shape,
      color: Theme.of(context).cardColor,
      child: InkWell(
        onTap: canNavigate
            ? () {
          developer.log('Navigating to Lane Details Mod', name: _logName);
          Navigator.pushNamed(context, AppRoutes.laneDetailsModification, arguments: _plazaId).then(
                (_) => developer.log('Returned from Lane Details Mod', name: _logName),
          );
        }
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.edit_road_outlined,
                    color: canNavigate ? Theme.of(context).colorScheme.primary : Theme.of(context).disabledColor,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    strings.menuLaneDetails,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: canNavigate ? Theme.of(context).colorScheme.primary : Theme.of(context).disabledColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  if (canNavigate && laneCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        laneCount.toString(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  if (canNavigate && laneCount > 0) const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right,
                    color: canNavigate ? Theme.of(context).colorScheme.primary : Theme.of(context).disabledColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentLoaded(PlazaModificationViewModel viewModel, S strings) {
    developer.log(
      'Building content loaded state. Basic details loaded: ${viewModel.formState.basicDetails.isNotEmpty}',
      name: _logName,
    );
    final bool hasAnyData = viewModel.formState.basicDetails.isNotEmpty ||
        viewModel.formState.bankDetails.isNotEmpty ||
        viewModel.formState.plazaImages.isNotEmpty ||
        viewModel.lanes.isNotEmpty;

    if (!hasAnyData && !viewModel.isLoading) {
      developer.log('Content loaded state, but no data found.', name: _logName);
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(strings.noDetailsAvailable, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              CustomButtons.primaryButton(
                height: 35,
                width: 100,
                text: strings.buttonRetry,
                onPressed: _loadPlazaDetails,
                context: context,
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          _buildBasicDetailsSection(viewModel, strings),
          _buildBankDetailsSection(viewModel, strings),
          _buildImageSection(viewModel, strings),
          _buildLaneDetailsAction(viewModel, strings),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    return Consumer<PlazaModificationViewModel>(
      builder: (context, viewModel, _) {
        final effectiveError = _hasFetchError && viewModel.error == null
            ? Exception(strings.errorLoadingPlazaDetailsGeneric)
            : viewModel.error;
        final bool showLoading = viewModel.isLoading && effectiveError == null;
        final bool showError = effectiveError != null && !viewModel.isLoading;

        developer.log(
          '[PlazaInfoScreen] Build: isLoading=${viewModel.isLoading}, '
              'showLoading=$showLoading, effectiveError=${effectiveError?.runtimeType}, '
              'isInitialized=$_isInitialized, fetchAttemptId=$_fetchAttemptId',
          name: _logName,
        );

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: _buildCustomAppBar(viewModel, strings),
          body: RefreshIndicator(
            onRefresh: _loadPlazaDetails,
            color: Theme.of(context).colorScheme.primary,
            child: Builder(
              builder: (innerContext) {
                if (showError) {
                  return _buildErrorState(effectiveError, strings);
                }
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: showLoading
                      ? KeyedSubtree(
                    key: ValueKey('loading_$_fetchAttemptId'),
                    child: _buildLoadingState(strings),
                  )
                      : KeyedSubtree(
                    key: ValueKey('content_$_plazaId$_fetchAttemptId${DateTime.now().millisecondsSinceEpoch}'),
                    child: _buildContentLoaded(viewModel, strings),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    if (length == 1) return toUpperCase();
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}