import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:merchant_app/utils/components/appbar.dart';

String formatNumber(dynamic number) {
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

// Common tooltip constants for a unified look
const Color kTooltipBg = Colors.black;
const double kTooltipOpacity = 0.8;
const TextStyle kTooltipTextStyle = TextStyle(
  color: Colors.white,
  fontWeight: FontWeight.bold,
);

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Filter options and selected value.
  final List<String> _filterOptions = ['Daily', 'Weekly', 'Monthly', 'Quarterly'];
  String _selectedFilter = 'Monthly';

  final List<FlSpot> plazaRevenueSpots = [
    FlSpot(0, 85.5), // Central Mall
    FlSpot(1, 72.3), // City Center
    FlSpot(2, 93.7), // Metro Plaza
  ];

  final List<Map<String, dynamic>> plazaData = [
    {'name': 'Central Mall', 'total': 180, 'cancelled': 45},
    {'name': 'City Center', 'total': 150, 'cancelled': 30},
    {'name': 'Metro Plaza', 'total': 200, 'cancelled': 55},
  ];

  final List<PieChartSectionData> revenueDistributionSections = [
    PieChartSectionData(
      value: 45,
      color: const Color(0xFF6200EA),
      title: '45%',
      radius: 50,
      titleStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    PieChartSectionData(
      value: 35,
      color: const Color(0xFF3700B3),
      title: '35%',
      radius: 45,
      titleStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    PieChartSectionData(
      value: 20,
      color: const Color(0xFF9C27B0),
      title: '20%',
      radius: 40,
      titleStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: CustomAppBar.appBarWithTitle(
        screenTitle: 'Dashboard',
        darkBackground: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFilterDropdown(),
              const SizedBox(height: 16),
              _buildSummaryCards(),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4.0),
                child: _buildMonthlyEarningsCard(),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4.0),
                child: _buildPlazaBookingsCard(),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4.0),
                child: _buildRevenueDistributionCard(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // Improved filter dropdown design.
  Widget _buildFilterDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        children: [
          const Icon(Icons.filter_list, color: Colors.black54),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedFilter,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              items: _filterOptions.map((String filter) {
                return DropdownMenuItem<String>(
                  value: filter,
                  child: Text(
                    filter,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedFilter = newValue;
                    // TODO: Update your chart data based on the filter selection.
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // Reusable card widget.
  Widget _buildCard({
    required String title,
    required Widget child,
    required double height,
  }) {
    return Container(
      width: double.infinity,
      height: height,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
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
            style: const TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(child: child),
        ],
      ),
    );
  }

  // Summary cards widget.
  Widget _buildSummaryCards() {
    final PageController pageController = PageController();
    final List<List<Widget>> pairedCards = [
      [
        _buildSummaryCard(
          title: 'Total Plaza',
          values: {'Count': '110'},
          increase: '+12.5%',
          color: const Color(0xFF6200EA),
        ),
        _buildSummaryCard(
          title: 'Total Txns',
          values: {'Count': '100', 'Amount': '12,500'},
          increase: '+8.2%',
          color: const Color(0xFF6200EA),
        ),
      ],
      [
        _buildSummaryCard(
          title: 'Settled Txns',
          values: {'Count': '50', 'Amount': '5,500'},
          increase: '+15.3%',
          color: const Color(0xFF6200EA),
        ),
        _buildSummaryCard(
          title: 'Pending Txns',
          values: {'Count': '50', 'Amount': '7,000'},
          increase: '+5.8%',
          color: const Color(0xFF6200EA),
        ),
      ],
    ];

    return SizedBox(
      height: 150,
      child: PageView.builder(
        controller: pageController,
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
    );
  }

  // Helper method for individual summary card.
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
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
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 13,
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
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
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
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                entry.value,
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 16,
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

  // Line chart for monthly earnings with improved label insets and unified tooltips.
  Widget _buildMonthlyEarningsCard() {
    return _buildCard(
      title: 'Plaza-wise Revenue Summary',
      height: 280,
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: LineChart(
          LineChartData(
            lineTouchData: LineTouchData(
              enabled: true,
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (touchedSpot) =>
                    kTooltipBg.withOpacity(kTooltipOpacity),
                getTooltipItems: (List<LineBarSpot> touchedSpots) {
                  return touchedSpots.map((lineBarSpot) {
                    return LineTooltipItem(
                      'Revenue: ${lineBarSpot.y.toStringAsFixed(1)}K',
                      kTooltipTextStyle,
                    );
                  }).toList();
                },
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: plazaRevenueSpots,
                isCurved: true,
                barWidth: 2,
                gradient: const LinearGradient(
                  colors: [Color(0xFF6200EA), Color(0xFF3700B3)],
                ),
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 4,
                      color: Colors.white,
                      strokeWidth: 2,
                      strokeColor: const Color(0xFF6200EA),
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF6200EA).withOpacity(0.2),
                      const Color(0xFF3700B3).withOpacity(0.0),
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
                  color: Colors.grey.withOpacity(0.1),
                  strokeWidth: 0.5,
                );
              },
            ),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 60,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    const plazaNames = {
                      0: 'Central\nMall',
                      1: 'City\nCenter',
                      2: 'Metro\nPlaza'
                    };
                    final index = value.toInt();
                    if (!plazaNames.containsKey(index)) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: EdgeInsets.only(
                        top: 16.0,
                        left: index == 0 ? 16.0 : 0.0,
                        right: index == plazaNames.length - 1 ? 28.0 : 0.0,
                      ),
                      child: Transform.rotate(
                        angle: -0.6,
                        child: Align(
                          alignment: index == 0
                              ? Alignment.centerLeft
                              : index == plazaNames.length - 1
                              ? Alignment.centerRight
                              : Alignment.center,
                          child: Text(
                            plazaNames[index]!,
                            style: const TextStyle(
                              color: Color(0xFF1A1A1A),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
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
                        style: const TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  },
                ),
              ),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
          ),
        ),
      ),
    );
  }

  // Bar chart for plaza bookings with unified tooltips.
  Widget _buildPlazaBookingsCard() {
    // Function to split plaza name into two lines.
    String formatPlazaName(String name) {
      final words = name.split(' ');
      if (words.length > 1) {
        return '${words[0]}\n${words.sublist(1).join(' ')}';
      }
      return name;
    }

    return _buildCard(
      title: 'Plaza-wise Booking Summary',
      height: 350,
      child: Column(
        children: [
          const SizedBox(height: 8),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barGroups: List.generate(
                  plazaData.length,
                      (index) => BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: plazaData[index]['total']!.toDouble(),
                        width: 16,
                        color: const Color(0xFF6200EA),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                      ),
                      BarChartRodData(
                        toY: plazaData[index]['cancelled']!.toDouble(),
                        width: 16,
                        color: const Color(0xFF9C27B0),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                      ),
                    ],
                    barsSpace: 4,
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 50,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.1),
                      strokeWidth: 0.5,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 60,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= plazaData.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Transform.rotate(
                            angle: -0.6,
                            child: Text(
                              formatPlazaName(plazaData[index]['name']!.toString()),
                              style: const TextStyle(
                                color: Color(0xFF1A1A1A),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                height: 1.2,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              color: Color(0xFF1A1A1A),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) =>
                        kTooltipBg.withOpacity(kTooltipOpacity),
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rodIndex == 0 ? 'Total' : 'Cancelled'}: ${rod.toY.toInt()}',
                        kTooltipTextStyle,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Total Bookings', '', const Color(0xFF6200EA)),
                const SizedBox(width: 24),
                _buildLegendItem('Cancelled Bookings', '', const Color(0xFF9C27B0)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Pie chart for revenue distribution with touch enabled.
  Widget _buildRevenueDistributionCard() {
    return _buildCard(
      title: 'Revenue Distribution',
      height: 350,
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  enabled: true,
                ),
                sections: revenueDistributionSections,
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
                    child: _buildLegendItem('UPI/Debit\nCredit Card', '45%', const Color(0xFF6200EA)),
                  ),
                  Expanded(
                    child: _buildLegendItem('Cash', '35%', const Color(0xFF3700B3)),
                  ),
                  Expanded(
                    child: _buildLegendItem('QR', '20%', const Color(0xFF9C27B0)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Legend widget.
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
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
        ),
        if (percentage.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            percentage,
            style: const TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }
}
