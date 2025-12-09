// 📊 Water Statistics Screen - View water intake history and analytics
import 'package:flutter/material.dart';
import 'package:health_care/theme/water_theme.dart';
import 'package:health_care/widgets/water/donut_chart.dart';
import 'package:health_care/widgets/water/drink_selector.dart';
import 'package:intl/intl.dart';

class WaterStatsScreen extends StatefulWidget {
  const WaterStatsScreen({super.key});

  @override
  State<WaterStatsScreen> createState() => _WaterStatsScreenState();
}

class _WaterStatsScreenState extends State<WaterStatsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Sample data - in real app, this would come from a database
  final List<DrinkEntry> _todayEntries = [
    DrinkEntry(
      type: DrinkTypes.defaults[5],
      amount: 150,
      time: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    DrinkEntry(
      type: DrinkTypes.defaults[0],
      amount: 100,
      time: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    DrinkEntry(
      type: DrinkTypes.defaults[3],
      amount: 250,
      time: DateTime.now().subtract(const Duration(hours: 7)),
    ),
    DrinkEntry(
      type: DrinkTypes.defaults[1],
      amount: 250,
      time: DateTime.now().subtract(const Duration(hours: 9)),
    ),
    DrinkEntry(
      type: DrinkTypes.defaults[0],
      amount: 50,
      time: DateTime.now().subtract(const Duration(hours: 10)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<DonutChartData> _getChartData() {
    // Group entries by drink type
    final Map<String, double> drinkTotals = {};
    final Map<String, DrinkType> drinkTypes = {};

    for (var entry in _todayEntries) {
      drinkTotals[entry.type.name] =
          (drinkTotals[entry.type.name] ?? 0) + entry.amount;
      drinkTypes[entry.type.name] = entry.type;
    }

    return drinkTotals.entries
        .map((e) => DonutChartData(
              label: e.key,
              value: e.value,
              color: drinkTypes[e.key]!.color,
              icon: drinkTypes[e.key]!.icon,
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final chartData = _getChartData();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: WaterColors.screenGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),

              // Tabs
              _buildTabs(),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Donut chart and legend
                      _buildChartSection(chartData),
                      const SizedBox(height: 32),

                      // History section
                      _buildHistorySection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // Bottom navigation
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    final now = DateTime.now();
    final dateText = DateFormat('EEEE, d MMMM yyyy').format(now);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios),
                color: WaterColors.textDark,
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Today, $dateText',
            style: WaterTextStyles.headlineMedium.copyWith(fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: WaterColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: WaterShadows.card,
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: WaterColors.waterPrimary,
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: WaterColors.textLight,
        labelStyle: WaterTextStyles.labelLarge,
        tabs: const [
          Tab(text: 'Day'),
          Tab(text: 'Week'),
          Tab(text: 'Month'),
          Tab(text: 'All time'),
        ],
      ),
    );
  }

  Widget _buildChartSection(List<DonutChartData> chartData) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Donut chart
        DonutChart(
          data: chartData,
          size: 180,
          strokeWidth: 25,
        ),
        const SizedBox(width: 32),

        // Legend
        Expanded(
          child: DonutChartLegend(data: chartData),
        ),
      ],
    );
  }

  Widget _buildHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'History',
              style: WaterTextStyles.headlineMedium,
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'See all',
                style: WaterTextStyles.labelLarge.copyWith(
                  color: WaterColors.waterPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // History list
        ..._todayEntries.map((entry) => _buildHistoryItem(entry)),
      ],
    );
  }

  Widget _buildHistoryItem(DrinkEntry entry) {
    final timeText = DateFormat('hh:mm a').format(entry.time);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WaterColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: WaterShadows.card,
      ),
      child: Row(
        children: [
          // Drink icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: entry.type.color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              entry.type.icon,
              color: entry.type.color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // Drink info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.type.name,
                  style: WaterTextStyles.bodyLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  '${entry.amount} ml',
                  style: WaterTextStyles.bodyMedium,
                ),
              ],
            ),
          ),

          // Time
          Text(
            timeText,
            style: WaterTextStyles.labelSmall,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: WaterShadows.soft,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavIcon(Icons.water_drop, false, onTap: () {
                Navigator.pop(context);
              }),
              _buildNavIcon(Icons.bar_chart, true),
              _buildNavIcon(Icons.settings_outlined, false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, bool isActive, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive
              ? WaterColors.waterPrimary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isActive ? WaterColors.waterPrimary : WaterColors.textLight,
          size: 28,
        ),
      ),
    );
  }
}

// Drink entry model
class DrinkEntry {
  final DrinkType type;
  final int amount;
  final DateTime time;

  DrinkEntry({
    required this.type,
    required this.amount,
    required this.time,
  });
}
