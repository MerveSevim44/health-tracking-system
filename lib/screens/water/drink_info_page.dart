// 📁 lib/screens/water/drink_info_page.dart
// Detailed information page for each drink type

import 'package:flutter/material.dart';
import 'package:health_care/models/drink_type_info.dart';
import 'package:health_care/theme/modern_colors.dart';

class DrinkInfoPage extends StatelessWidget {
  final DrinkTypeInfo drinkInfo;

  const DrinkInfoPage({
    super.key,
    required this.drinkInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ModernAppColors.darkBg,
              ModernAppColors.cardBg,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDrinkIcon(),
                        const SizedBox(height: 24),
                        _buildTitle(),
                        const SizedBox(height: 16),
                        _buildDescription(),
                        const SizedBox(height: 32),
                        _buildHydrationFactor(),
                        const SizedBox(height: 24),
                        _buildBenefitsSection(),
                        if (drinkInfo.risks.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          _buildRisksSection(),
                        ],
                        const SizedBox(height: 24),
                        _buildRecommendedDaily(),
                        const SizedBox(height: 32),
                        _buildUseThisDrinkButton(context),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: ModernAppColors.lightText),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          const Text(
            'Drink Information',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: ModernAppColors.lightText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrinkIcon() {
    return Center(
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: drinkInfo.color.withValues(alpha: 0.2),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: drinkInfo.color.withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Center(
          child: Text(
            drinkInfo.iconEmoji,
            style: const TextStyle(fontSize: 64),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Center(
      child: Text(
        drinkInfo.name,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: ModernAppColors.lightText,
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ModernAppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ModernAppColors.mutedText.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Text(
        drinkInfo.description,
        style: const TextStyle(
          fontSize: 16,
          height: 1.6,
          color: ModernAppColors.mutedText,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildHydrationFactor() {
    final percentage = (drinkInfo.hydrationFactor * 100).toInt();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ModernAppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: drinkInfo.color.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.water_drop, color: ModernAppColors.vibrantCyan, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Hydration Factor',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ModernAppColors.lightText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              Container(
                height: 12,
                decoration: BoxDecoration(
                  color: ModernAppColors.darkBg,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              FractionallySizedBox(
                widthFactor: drinkInfo.hydrationFactor,
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        drinkInfo.color,
                        drinkInfo.color.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$percentage% as hydrating as water',
            style: const TextStyle(
              fontSize: 14,
              color: ModernAppColors.mutedText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsSection() {
    return _buildInfoCard(
      title: '✨ Benefits',
      items: drinkInfo.benefits,
      color: Colors.green,
    );
  }

  Widget _buildRisksSection() {
    return _buildInfoCard(
      title: '⚠️ Considerations',
      items: drinkInfo.risks,
      color: Colors.orange,
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<String> items,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ModernAppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 16),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 15,
                          color: ModernAppColors.lightText,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildRecommendedDaily() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ModernAppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: drinkInfo.color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: drinkInfo.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.calendar_today,
              color: drinkInfo.color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recommended Daily',
                  style: TextStyle(
                    fontSize: 14,
                    color: ModernAppColors.mutedText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  drinkInfo.recommendedDaily,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ModernAppColors.lightText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUseThisDrinkButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context, drinkInfo.id);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: drinkInfo.color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          shadowColor: drinkInfo.color.withValues(alpha: 0.4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              drinkInfo.iconEmoji,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              'Use This Drink',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
