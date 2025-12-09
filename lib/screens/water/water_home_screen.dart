// 🏠 Water Tracking Home Screen - Main water intake tracking interface
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:health_care/models/water_model.dart';
import 'package:health_care/theme/water_theme.dart';
import 'package:health_care/widgets/water/water_blob.dart';
import 'package:health_care/widgets/water/drink_selector.dart';
import 'package:health_care/widgets/water/water_counter.dart';
import 'package:health_care/widgets/water/blur_card.dart';
import 'package:health_care/screens/water/water_success_screen.dart';
import 'package:intl/intl.dart';

class WaterHomeScreen extends StatefulWidget {
  const WaterHomeScreen({super.key});

  @override
  State<WaterHomeScreen> createState() => _WaterHomeScreenState();
}

class _WaterHomeScreenState extends State<WaterHomeScreen> {
  int _selectedDrinkIndex = 0;
  int _counterAmount = 0;
  DateTime _selectedDate = DateTime.now();

  // Week days for calendar
  List<DateTime> _getWeekDays() {
    final now = _selectedDate;
    final weekday = now.weekday;
    final monday = now.subtract(Duration(days: weekday - 1));
    return List.generate(7, (index) => monday.add(Duration(days: index)));
  }

  void _addWater() {
    if (_counterAmount > 0) {
      final waterModel = Provider.of<WaterModel>(context, listen: false);
      final drinkType = DrinkTypes.defaults[_selectedDrinkIndex];
      
      waterModel.addWaterIntake(drinkType, _counterAmount);
      
      setState(() {
        _counterAmount = 0;
      });

      // Check if goal achieved
      if (waterModel.isGoalAchieved(_selectedDate)) {
        _showGoalAchievedScreen();
      }
    }
  }

  void _showGoalAchievedScreen() {
    final waterModel = Provider.of<WaterModel>(context, listen: false);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WaterSuccessScreen(
          achievedAmount: waterModel.getCurrentIntake(_selectedDate),
          goalAmount: waterModel.dailyGoal,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WaterModel>(
      builder: (context, waterModel, child) {
        final currentIntake = waterModel.getCurrentIntake(_selectedDate);
        final dailyGoal = waterModel.dailyGoal;
        final progress = waterModel.getProgress(_selectedDate);

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: WaterColors.screenGradient,
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with profile and notification
                    _buildHeader(),
                    const SizedBox(height: 24),

                    // Week day selector
                    _buildWeekCalendar(waterModel),
                    const SizedBox(height: 32),

                    // Water blob with progress
                    Center(
                      child: Column(
                        children: [
                          WaterBlob(
                            progress: progress,
                            size: 220,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '$currentIntake ml / $dailyGoal ml',
                            style: WaterTextStyles.headlineMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Keep it going! Today you drank',
                            style: WaterTextStyles.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Choose drink section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Choose drink',
                          style: WaterTextStyles.headlineMedium,
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'Add new',
                            style: WaterTextStyles.labelLarge.copyWith(
                              color: WaterColors.waterPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Drink type selector
                    DrinkSelector(
                      drinks: DrinkTypes.defaults,
                      selectedIndex: _selectedDrinkIndex,
                      onDrinkSelected: (index) {
                        setState(() {
                          _selectedDrinkIndex = index;
                        });
                      },
                    ),
                    const SizedBox(height: 32),

                    // Amount counter
                    WaterCounter(
                      currentAmount: _counterAmount,
                      step: 50,
                      onAmountChanged: (amount) {
                        setState(() {
                          _counterAmount = amount;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Add button
                    if (_counterAmount > 0)
                      BluePrimaryButton(
                        text: 'Add $_counterAmount ml',
                        onPressed: _addWater,
                        width: double.infinity,
                        icon: Icons.add,
                      ),
                    const SizedBox(height: 32),

                    // Benefits card
                    _buildBenefitsCard(),
                  ],
                ),
              ),
            ),
          ),
          // Bottom navigation bar - removed since navigation is handled by PastelHomeNavigation
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: WaterColors.waterPrimary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: WaterColors.waterPrimary,
                size: 24,
              ),
            ),
          ],
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: WaterColors.cardBackground,
            shape: BoxShape.circle,
            boxShadow: WaterShadows.card,
          ),
          child: const Icon(
            Icons.notifications_outlined,
            color: WaterColors.textDark,
            size: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildWeekCalendar(WaterModel waterModel) {
    final days = _getWeekDays();

    return SizedBox(
      height: 70,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: days.map((day) {
          final isToday = DateFormat('yyyy-MM-dd').format(day) ==
              DateFormat('yyyy-MM-dd').format(_selectedDate);
          final dayNum = day.day;
          final dayName = DateFormat('E').format(day).substring(0, 3);
          final hasData = waterModel.getCurrentIntake(day) > 0;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = day;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 48,
              height: 70,
              decoration: BoxDecoration(
                color: isToday
                    ? WaterColors.waterPrimary
                    : WaterColors.cardBackground,
                borderRadius: BorderRadius.circular(24),
                border: isToday
                    ? Border.all(color: WaterColors.waterDark, width: 2)
                    : hasData
                        ? Border.all(color: WaterColors.waterLight, width: 2)
                        : null,
                boxShadow: isToday ? WaterShadows.button : WaterShadows.card,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$dayNum',
                    style: WaterTextStyles.labelLarge.copyWith(
                      color: isToday ? Colors.white : WaterColors.textDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dayName,
                    style: WaterTextStyles.labelSmall.copyWith(
                      color: isToday
                          ? Colors.white.withValues(alpha: 0.8)
                          : WaterColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBenefitsCard() {
    return PastelCard(
      backgroundColor: WaterColors.cardBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'The benefits of water for your health',
            style: WaterTextStyles.headlineMedium.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 12),
          Text(
            'Staying hydrated helps maintain energy levels, improves brain function, and supports overall wellness.',
            style: WaterTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }
}
