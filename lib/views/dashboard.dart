import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:merchant_app/config/app_theme.dart';
import 'package:merchant_app/utils/components/appbar.dart';
import 'package:merchant_app/config/app_colors.dart';
import 'dart:math';
import '../../generated/l10n.dart';

String formatNumber(dynamic number, {String locale = 'en_US'}) {
  if (number is int || number is double) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
  return '0';
}

class PlazaData {
  final String name;
  final double revenue;
  final int total;
  final int cancelled;

  PlazaData({
    required this.name,
    required this.revenue,
    required this.total,
    required this.cancelled,
  });
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<String> _filterOptions = [];
  String _selectedFilter = '';
  late PageController _summaryPageController;
  bool _isRefreshing = false;
  Timer? _debounceTimer;

  final List<PlazaData> plazaData = [
    PlazaData(name: 'Central Mall', revenue: 85.5, total: 180, cancelled: 45),
    PlazaData(name: 'City Center', revenue: 72.3, total: 150, cancelled: 30),
    PlazaData(name: 'Metro Plaza', revenue: 93.7, total: 200, cancelled: 55),
  ];

  final List<Map<String, dynamic>> paymentData = [
    {'method': 'UPI/Card', 'percentage': 45.0, 'color': null},
    {'method': 'Cash', 'percentage': 35.0, 'color': null},
    {'method': 'QR', 'percentage': 20.0, 'color': null},
  ];

  @override
  void initState() {
    super.initState();
    _summaryPageController = PageController();
    developer.log('Initializing DashboardScreen', name: 'DashboardScreen');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final strings = S.of(context);
      setState(() {
        _filterOptions.clear();
        _filterOptions.addAll([
          strings.filterDaily,
          strings.filterWeekly,
          strings.filterMonthly,
          strings.filterQuarterly,
        ]);
        _selectedFilter = _filterOptions.isNotEmpty ? _filterOptions[2] : ''; // Default to Monthly
      });
    });
  }

  @override
  void dispose() {
    _summaryPageController.dispose();
    _debounceTimer?.cancel();
    developer.log('Disposing DashboardScreen', name: 'DashboardScreen');
    super.dispose();
  }

  Future<void> _refreshDashboardData() async {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      final strings = S.of(context);
      setState(() => _isRefreshing = true);
      developer.log('Refreshing dashboard data for filter: $_selectedFilter', name: 'DashboardScreen');
      try {
        // Simulate data refresh (replace with actual API call)
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(strings.dataRefreshSuccess),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        developer.log('Data refresh failed: $e', name: 'DashboardScreen', level: 1000);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${strings.dataRefreshFailed}: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isRefreshing = false);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    developer.log('Building DashboardScreen, isDarkMode: $isDarkMode', name: 'DashboardScreen');

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: CustomAppBar.appBarWithTitle(
        screenTitle: strings.titleDashboard,
        darkBackground: isDarkMode,
        context: context,
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _refreshDashboardData,
            color: Theme.of(context).primaryColor,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(), // Ensure scrollable for RefreshIndicator
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width > 600 ? 16 : 4,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 12,),
                  _buildFilterDropdown(),
                  const SizedBox(height: 16),
                  _buildSummaryCards(strings),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4.0),
                    child: _buildMonthlyEarningsCard(strings),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4.0),
                    child: _buildPlazaBookingsCard(strings),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4.0),
                    child: _buildRevenueDistributionCard(strings),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          if (_isRefreshing)
            Container(
              color: context.shadowColor.withOpacity(0.5),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Theme.of(context).primaryColor),
                    const SizedBox(height: 16),
                    Text(
                      strings.labelLoading,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: context.textPrimaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown() {
    if (_filterOptions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        children: [
          Icon(Icons.filter_list, color: context.textSecondaryColor),
          const SizedBox(width: 8),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: DropdownButtonFormField<String>(
                key: ValueKey(_selectedFilter),
                value: _filterOptions.contains(_selectedFilter) ? _selectedFilter : _filterOptions[0],
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.inputBorderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.inputBorderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                  ),
                  filled: true,
                  fillColor: context.secondaryCardColor,
                ),
                items: _filterOptions.map((String filter) {
                  return DropdownMenuItem<String>(
                    value: filter,
                    child: Text(
                      filter,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: context.textPrimaryColor,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    developer.log('Filter changed to: $newValue', name: 'DashboardScreen');
                    HapticFeedback.selectionClick();
                    setState(() {
                      _selectedFilter = newValue;
                      _refreshDashboardData(); // Trigger refresh on filter change
                    });
                  }
                },
                dropdownColor: context.cardColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required Widget child,
    required double height,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.secondaryCardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: context.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: context.textPrimaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(S strings) {
    final List<List<Widget>> pairedCards = [
      [
        _buildSummaryCard(
          title: strings.summaryTotalPlaza,
          values: {'Count': '110'},
          increase: '+12.5%',
          color: context.chartPrimaryColor,
        ),
        _buildSummaryCard(
          title: strings.summaryTotalTxns,
          values: {'Count': '100', 'Amount': '12,500'},
          increase: '+8.2%',
          color: context.chartPrimaryColor,
        ),
      ],
      [
        _buildSummaryCard(
          title: strings.summarySettledTxns,
          values: {'Count': '50', 'Amount': '5,500'},
          increase: '+15.3%',
          color: context.chartPrimaryColor,
        ),
        _buildSummaryCard(
          title: strings.summaryPendingTxns,
          values: {'Count': '50', 'Amount': '7,000'},
          increase: '+5.8%',
          color: context.chartPrimaryColor,
        ),
      ],
    ];

    return SizedBox(
      height: 150,
      child: Stack(
        children: [
          PageView.builder(
            controller: _summaryPageController,
            itemCount: pairedCards.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Expanded(child: pairedCards[index][0]),
                    const SizedBox(width: 8),
                    Expanded(child: pairedCards[index][1]),
                  ],
                ),
              );
            },
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: () {
                if (_summaryPageController.hasClients && _summaryPageController.page! > 0) {
                  HapticFeedback.lightImpact();
                  _summaryPageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
              child: Container(
                width: 40,
                color: Colors.transparent,
                child: Icon(
                  Icons.chevron_left,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: () {
                if (_summaryPageController.hasClients && _summaryPageController.page! < pairedCards.length - 1) {
                  HapticFeedback.lightImpact();
                  _summaryPageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
              child: Container(
                width: 40,
                color: Colors.transparent,
                child: Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required Map<String, String> values,
    required String increase,
    required Color color,
  }) {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.secondaryCardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: context.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.textSecondaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  increase,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...values.entries.map((entry) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.key,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.textSecondaryColor,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                entry.value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: context.textPrimaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildMonthlyEarningsCard(S strings) {
    if (plazaData.isEmpty) {
      return _buildCard(
        title: strings.cardPlazaRevenueSummary,
        height: 280,
        child: Center(
          child: Text(
            strings.errorNotFound,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.error),
          ),
        ),
      );
    }

    final List<FlSpot> revenueSpots = List.generate(
      plazaData.length,
          (index) => FlSpot(index.toDouble(), plazaData[index].revenue),
    );

    return _buildCard(
      title: strings.cardPlazaRevenueSummary,
      height: MediaQuery.of(context).size.height * 0.35, // Dynamic height
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: LineChart(
          LineChartData(
            lineTouchData: LineTouchData(
              enabled: true,
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) => context.textPrimaryColor.withOpacity(0.8),
                getTooltipItems: (List<LineBarSpot> touchedSpots) {
                  return touchedSpots.map((lineBarSpot) {
                    final index = lineBarSpot.x.toInt();
                    final plazaName = index >= 0 && index < plazaData.length ? plazaData[index].name : '';
                    return LineTooltipItem(
                      '$plazaName: ${lineBarSpot.y.toStringAsFixed(1)}K',
                      Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: context.secondaryCardColor,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }).toList();
                },
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: revenueSpots,
                isCurved: true,
                barWidth: 2,
                gradient: LinearGradient(
                  colors: [
                    context.chartPrimaryColor,
                    context.chartSecondaryColor,
                  ],
                ),
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 4,
                      color: context.secondaryCardColor,
                      strokeWidth: 2,
                      strokeColor: context.chartPrimaryColor,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      context.chartPrimaryColor.withOpacity(0.2),
                      context.chartSecondaryColor.withOpacity(0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 20,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: context.textSecondaryColor.withOpacity(0.1),
                  strokeWidth: 0.5,
                );
              },
            ),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 70,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= plazaData.length) return const SizedBox.shrink();
                    return Padding(
                      padding: EdgeInsets.only(
                        top: 16.0,
                        left: index == 0 ? 16.0 : 0.0,
                        right: index == plazaData.length - 1 ? 28.0 : 0.0,
                      ),
                      child: Transform.rotate(
                        angle: -0.6,
                        child: Align(
                          alignment: index == 0
                              ? Alignment.centerLeft
                              : index == plazaData.length - 1
                              ? Alignment.centerRight
                              : Alignment.center,
                          child: Text(
                            _formatLongName(plazaData[index].name),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: context.textPrimaryColor,
                              fontWeight: FontWeight.w500,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  interval: 20,
                  getTitlesWidget: (value, meta) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        '${value.toInt()}K',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.textSecondaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  },
                ),
              ),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
          ),
        ),
      ),
    );
  }

  Widget _buildPlazaBookingsCard(S strings) {
    if (plazaData.isEmpty) {
      developer.log('No booking data available for chart', name: 'DashboardScreen', level: 900);
      return _buildCard(
        title: strings.cardPlazaBookingSummary,
        height: 350,
        child: Center(
          child: Text(
            strings.errorNotFound,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.error),
          ),
        ),
      );
    }

    final maxTotal = plazaData.map((e) => e.total).reduce(max);

    return _buildCard(
      title: strings.cardPlazaBookingSummary,
      height: MediaQuery.of(context).size.height * 0.45, // Dynamic height
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxTotal * 1.2,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => context.textPrimaryColor.withOpacity(0.8),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final plaza = plazaData[groupIndex];
                      return BarTooltipItem(
                        '${plaza.name}\n${strings.totalBookings}: ${plaza.total}\n${strings.cancelledBookings}: ${plaza.cancelled}',
                        Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: context.secondaryCardColor,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  checkToShowHorizontalLine: (value) => value % 50 == 0,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: context.textSecondaryColor.withOpacity(0.1),
                    strokeWidth: 0.5,
                  ),
                  drawVerticalLine: false,
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 60,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= plazaData.length) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _formatLongName(plazaData[index].name, maxCharsPerLine: 8),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: context.textPrimaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 50,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.textSecondaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(plazaData.length, (index) {
                  final plaza = plazaData[index];
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: plaza.total.toDouble(),
                        width: 16,
                        gradient: LinearGradient(
                          colors: [
                            context.chartPrimaryColor,
                            context.chartSecondaryColor,
                          ],
                        ),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxTotal * 1.2,
                          color: context.chartPrimaryColor.withOpacity(0.05),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(
                strings.legendTotalBookings,
                '',
                context.chartPrimaryColor,
              ),
              const SizedBox(width: 24),
              _buildLegendItem(
                strings.legendCancelledBookings,
                '',
                context.chartSecondaryColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _getRevenueDistributionSections(BuildContext context) {
    paymentData[0]['color'] = context.chartPrimaryColor;
    paymentData[1]['color'] = context.chartSecondaryColor;
    paymentData[2]['color'] = context.chartTertiaryColor;

    return List.generate(paymentData.length, (index) {
      final data = paymentData[index];
      return PieChartSectionData(
        value: data['percentage'],
        title: '${data['percentage'].toStringAsFixed(0)}%',
        color: data['color'] as Color,
        radius: 60,
        titleStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: context.secondaryCardColor,
        ),
      );
    });
  }

  Widget _buildRevenueDistributionCard(S strings) {
    if (paymentData.isEmpty) {
      return _buildCard(
        title: strings.cardRevenueDistribution,
        height: 350,
        child: Center(
          child: Text(
            strings.errorNotFound,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.error),
          ),
        ),
      );
    }

    return _buildCard(
      title: strings.cardRevenueDistribution,
      height: MediaQuery.of(context).size.height * 0.45, // Dynamic height
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  enabled: true,
                  touchCallback: (event, pieTouchResponse) {
                    if (pieTouchResponse != null && pieTouchResponse.touchedSection != null) {
                      HapticFeedback.lightImpact();
                    }
                  },
                ),
                sections: _getRevenueDistributionSections(context),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                startDegreeOffset: -90,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: _buildLegendItem(
                      strings.legendUpiCard,
                      '${paymentData[0]['percentage'].toStringAsFixed(0)}%',
                      paymentData[0]['color'] as Color,
                    ),
                  ),
                  Expanded(
                    child: _buildLegendItem(
                      strings.legendCash,
                      '${paymentData[1]['percentage'].toStringAsFixed(0)}%',
                      paymentData[1]['color'] as Color,
                    ),
                  ),
                  Expanded(
                    child: _buildLegendItem(
                      strings.legendQr,
                      '${paymentData[2]['percentage'].toStringAsFixed(0)}%',
                      paymentData[2]['color'] as Color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, String percentage, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Flexible(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.textPrimaryColor,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (percentage.isNotEmpty) ...[
          const SizedBox(height: 2),
          Flexible(
            child: Text(
              percentage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.textPrimaryColor,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }

  String _formatLongName(String name, {int maxCharsPerLine = 10}) {
    if (name.isEmpty) return '';
    if (name.length <= maxCharsPerLine) return name;

    final words = name.trim().split(' ');
    if (words.length > 1) {
      String firstLine = '';
      String secondLine = '';

      for (var word in words) {
        if ((firstLine + word).length <= maxCharsPerLine) {
          firstLine = firstLine.isEmpty ? word : '$firstLine $word';
        } else if (secondLine.isEmpty || (secondLine + word).length <= maxCharsPerLine) {
          secondLine = secondLine.isEmpty ? word : '$secondLine $word';
        } else {
          secondLine = '$secondLine...';
          break;
        }
      }

      return '$firstLine\n$secondLine';
    } else {
      return '${name.substring(0, maxCharsPerLine - 1)}-\n${name.substring(maxCharsPerLine - 1, min(name.length, maxCharsPerLine * 2 - 1))}${name.length > maxCharsPerLine * 2 - 1 ? '...' : ''}';
    }
  }
}