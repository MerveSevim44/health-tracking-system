// 🏠 Water Tracking Home Screen - Main water intake tracking interface
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:health_care/models/water_model.dart';
import 'package:health_care/models/drink_type_info.dart';
import 'package:health_care/models/custom_drink_model.dart';
import 'package:health_care/providers/drink_provider.dart';
import 'package:health_care/theme/water_theme.dart';
import 'package:health_care/widgets/water/dynamic_drink_blob.dart';
import 'package:health_care/widgets/water/drink_selector.dart';
import 'package:health_care/widgets/water/selected_drink_display.dart';
import 'package:health_care/widgets/water/water_counter.dart';
import 'package:health_care/widgets/water/blur_card.dart';
import 'package:health_care/widgets/water/add_custom_drink_modal.dart';
import 'package:health_care/widgets/water/today_drink_logs.dart';
import 'package:health_care/screens/water/water_success_screen.dart';
import 'package:health_care/screens/water/drink_info_page.dart';
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

  @override
  void initState() {
    super.initState();
    // DrinkProvider'a başlangıç tarihini set et
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DrinkProvider>(context, listen: false)
          .setSelectedDate(_selectedDate);
    });
  }

  // Week days for calendar
  List<DateTime> _getWeekDays() {
    final now = _selectedDate;
    final weekday = now.weekday;
    final monday = now.subtract(Duration(days: weekday - 1));
    return List.generate(7, (index) => monday.add(Duration(days: index)));
  }

  void _addWater() async {
    final waterModel = Provider.of<WaterModel>(context, listen: false);
    final drinkProvider = Provider.of<DrinkProvider>(context, listen: false);
    final drinkType = DrinkTypes.defaults[_selectedDrinkIndex];
    final isWater = waterModel.isWaterDrink(drinkType);
    
    if (isWater) {
      // Su için: kullanıcının girdiği ml değeri
      if (_counterAmount > 0) {
        await waterModel.addWaterIntake(drinkType, _counterAmount);
        
        // Su için de log kaydet
        await drinkProvider.addDrinkLog(DrinkLog(
          id: '',
          drinkId: 'water',
          drinkName: drinkType.name,
          amount: _counterAmount,
          cups: 0,
          timestamp: DateTime.now(),
          iconUrl: '💧',
          color: drinkType.color,
        ));
        
        setState(() {
          _counterAmount = 0;
        });

        // Check if goal achieved (sadece su için)
        final achieved = await waterModel.isGoalAchieved(_selectedDate);
        if (achieved) {
          _showGoalAchievedScreen();
        }
      }
    } else {
      // Diğer içecekler için: 1 bardak = 200ml varsayılan
      await waterModel.addWaterIntake(drinkType, 200);
      
      // Drink log kaydet
      await drinkProvider.addDrinkLog(DrinkLog(
        id: '',
        drinkId: drinkType.name.toLowerCase(),
        drinkName: drinkType.name,
        amount: 200,
        cups: 1,
        timestamp: DateTime.now(),
        iconUrl: _getDrinkIcon(drinkType),
        color: drinkType.color,
      ));
      
      // Basit bildirim göster
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('1 cup of ${drinkType.name} added!'),
            duration: const Duration(seconds: 2),
            backgroundColor: drinkType.color,
          ),
        );
      }
    }
  }

  // İçecek için ikon seç (emoji veya MaterialIcon'dan)
  String _getDrinkIcon(DrinkType drinkType) {
    final name = drinkType.name.toLowerCase();
    if (name.contains('tea')) return '🍵';
    if (name.contains('coffee')) return '☕';
    if (name.contains('juice')) return '🧃';
    if (name.contains('milk')) return '🥛';
    if (name.contains('water')) return '💧';
    return '🥤'; // Default
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

  // Seçili içeceğin su olup olmadığını kontrol et
  bool _isWaterSelected() {
    final drinkType = DrinkTypes.defaults[_selectedDrinkIndex];
    return drinkType.name.toLowerCase() == 'water';
  }

  // İçecek bilgi ekranını aç
  void _showDrinkInfo(int drinkIndex) {
    final drinkType = DrinkTypes.defaults[drinkIndex];
    
    // DrinkTypeInfo'yu bul
    final drinkInfo = DrinkDatabase.allDrinks.firstWhere(
      (info) => info.name.toLowerCase() == drinkType.name.toLowerCase(),
      orElse: () => DrinkDatabase.allDrinks[0], // Default to water
    );
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DrinkInfoPage(
          drinkInfo: drinkInfo,
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
                    const SizedBox(height: 24),

                    // Seçili içecek adı gösterimi
                    Center(
                      child: SelectedDrinkDisplay(
                        drinkType: DrinkTypes.defaults[_selectedDrinkIndex],
                        onTap: () => _showDrinkInfo(_selectedDrinkIndex),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Dinamik içecek blob with progress
                    Center(
                      child: Column(
                        children: [
                          DynamicDrinkBlob(
                            progress: progress,
                            drinkType: DrinkTypes.defaults[_selectedDrinkIndex],
                            size: 220,
                          ),
                          const SizedBox(height: 16),
                          // Sadece SU için ml/hedef göster
                          if (_isWaterSelected()) ...[
                            Text(
                              '$currentIntake ml / $dailyGoal ml',
                              style: WaterTextStyles.headlineMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Daily water goal progress',
                              style: WaterTextStyles.bodyMedium,
                            ),
                          ] else ...[
                            // Diğer içecekler için farklı mesaj
                            FutureBuilder<int>(
                              future: waterModel.getTodayDrinkCount(_selectedDate),
                              builder: (context, snapshot) {
                                final count = snapshot.data ?? 0;
                                return Text(
                                  '$count cup${count != 1 ? 's' : ''} today',
                                  style: WaterTextStyles.headlineMedium,
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap Add to log 1 cup',
                              style: WaterTextStyles.bodyMedium,
                            ),
                          ],
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
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AddCustomDrinkModal(
                                onDrinkAdded: (drink) async {
                                  final drinkProvider = Provider.of<DrinkProvider>(
                                    context,
                                    listen: false,
                                  );
                                  await drinkProvider.addCustomDrink(drink);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${drink.name} added!'),
                                        backgroundColor: drink.color,
                                      ),
                                    );
                                  }
                                },
                              ),
                            );
                          },
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
                      onDrinkLongPressed: (index) {
                        _showDrinkInfo(index);
                      },
                    ),
                    const SizedBox(height: 32),

                    // Sadece SU için ml slider göster
                    if (_isWaterSelected()) ...[
                      // Amount counter (sadece su için)
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

                      // Add button (su için ml ile)
                      if (_counterAmount > 0)
                        BluePrimaryButton(
                          text: 'Add $_counterAmount ml',
                          onPressed: _addWater,
                          width: double.infinity,
                          icon: Icons.add,
                          color: DrinkTypes.defaults[_selectedDrinkIndex].color,
                        ),
                    ] else ...[
                      // Diğer içecekler için tek buton (1 bardak = 200ml)
                      BluePrimaryButton(
                        text: 'Add 1 cup of ${DrinkTypes.defaults[_selectedDrinkIndex].name}',
                        onPressed: _addWater,
                        width: double.infinity,
                        icon: Icons.add,
                        color: DrinkTypes.defaults[_selectedDrinkIndex].color,
                      ),
                    ],
                    const SizedBox(height: 32),

                    // Benefits card
                    _buildBenefitsCard(),
                    
                    const SizedBox(height: 32),

                    // Today's Drink Logs
                    Consumer<DrinkProvider>(
                      builder: (context, drinkProvider, child) {
                        // Seçili tarih bugün mü kontrol et
                        final now = DateTime.now();
                        final today = DateTime(now.year, now.month, now.day);
                        final selected = DateTime(
                          _selectedDate.year,
                          _selectedDate.month,
                          _selectedDate.day,
                        );
                        final isToday = selected == today;
                        
                        return TodayDrinkLogs(
                          logs: isToday ? drinkProvider.todayLogs : drinkProvider.selectedDateLogs,
                          selectedDate: _selectedDate,
                          onDeleteLog: (logId) async {
                            await drinkProvider.deleteDrinkLog(logId);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Log deleted'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 20),
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
              // DrinkProvider'daki tarihi de güncelle
              Provider.of<DrinkProvider>(context, listen: false)
                  .setSelectedDate(day);
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
