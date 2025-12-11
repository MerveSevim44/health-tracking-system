// 📁 lib/models/drink_type_info.dart
// Comprehensive drink type information with health benefits and hydration factors

import 'package:flutter/material.dart';

/// DrinkTypeInfo - Complete information about each drink type
class DrinkTypeInfo {
  final String id;
  final String name;
  final String description;
  final String iconEmoji;
  final Color color;
  final double hydrationFactor; // 0.0 to 1.0 (water = 1.0)
  final List<String> benefits;
  final List<String> risks;
  final String recommendedDaily;
  final DrinkCategory category;

  const DrinkTypeInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.iconEmoji,
    required this.color,
    required this.hydrationFactor,
    required this.benefits,
    this.risks = const [],
    required this.recommendedDaily,
    required this.category,
  });
}

enum DrinkCategory {
  basic,           // Water, Soda, Juice
  classic,         // Classic herbal teas
  relaxing,        // Calming teas
  digestive,       // Digestive support
  detox,           // Detox & metabolism
  immunity,        // Immunity boosting
  coldFlu,         // Cold & flu relief
  womensHealth,    // Women's health
  special,         // Special & rare teas
}

/// Complete drink database with all herbal teas and beverages
class DrinkDatabase {
  static final List<DrinkTypeInfo> allDrinks = [
    // ========== BASIC DRINKS ==========
    DrinkTypeInfo(
      id: 'water',
      name: 'Water',
      description: 'Pure water - the best choice for hydration. Keeps you energized and supports all body functions.',
      iconEmoji: '💧',
      color: const Color(0xFF4FC3F7),
      hydrationFactor: 1.0,
      benefits: [
        'Perfect hydration',
        'No calories',
        'Supports all body functions',
        'Regulates body temperature',
      ],
      recommendedDaily: '2000-3000 ml',
      category: DrinkCategory.basic,
    ),
    
    DrinkTypeInfo(
      id: 'coffee',
      name: 'Coffee',
      description: 'Boosts alertness and energy. Contains caffeine - consume in moderation.',
      iconEmoji: '☕',
      color: const Color(0xFF8D6E63),
      hydrationFactor: 0.7,
      benefits: [
        'Increases alertness',
        'Rich in antioxidants',
        'May improve focus',
      ],
      risks: [
        'May cause dehydration if consumed in excess',
        'Can increase heart rate',
        'May disrupt sleep if consumed late',
      ],
      recommendedDaily: '300-400 ml (2-3 cups)',
      category: DrinkCategory.basic,
    ),

    DrinkTypeInfo(
      id: 'soda',
      name: 'Soda',
      description: 'Carbonated drink - refreshing but high in sugar. Limit consumption.',
      iconEmoji: '🥤',
      color: const Color(0xFFFF6B6B),
      hydrationFactor: 0.5,
      benefits: ['Refreshing taste'],
      risks: [
        'High sugar content',
        'May cause tooth decay',
        'Low nutritional value',
      ],
      recommendedDaily: '0-250 ml (occasional)',
      category: DrinkCategory.basic,
    ),

    DrinkTypeInfo(
      id: 'wine',
      name: 'Wine',
      description: 'Moderate consumption may have health benefits. Always drink responsibly.',
      iconEmoji: '🍷',
      color: const Color(0xFF9C27B0),
      hydrationFactor: 0.3,
      benefits: [
        'Contains antioxidants (red wine)',
        'May support heart health in moderation',
      ],
      risks: [
        'Alcohol can cause dehydration',
        'Excessive consumption is harmful',
        'Not recommended daily',
      ],
      recommendedDaily: '0-150 ml (occasional)',
      category: DrinkCategory.basic,
    ),

    // ========== CLASSIC HERBAL TEAS ==========
    DrinkTypeInfo(
      id: 'linden tea',
      name: 'Linden Tea',
      description: 'Traditional remedy for cold and flu. Soothes throat and reduces fever.',
      iconEmoji: '🌿',
      color: const Color(0xFFF5E6D3),
      hydrationFactor: 0.95,
      benefits: [
        'Relieves cold and flu symptoms',
        'Soothes sore throat',
        'Reduces fever naturally',
        'Calming effect',
      ],
      recommendedDaily: '2-3 cups',
      category: DrinkCategory.classic,
    ),

    DrinkTypeInfo(
      id: 'chamomile tea',
      name: 'Chamomile Tea',
      description: 'Calming tea that helps with sleep and relaxation.',
      iconEmoji: '🌼',
      color: const Color(0xFFFFF9C4),
      hydrationFactor: 0.95,
      benefits: [
        'Promotes better sleep',
        'Reduces anxiety',
        'Soothes digestive issues',
        'Anti-inflammatory properties',
      ],
      recommendedDaily: '2-3 cups',
      category: DrinkCategory.classic,
    ),

    DrinkTypeInfo(
      id: 'sage tea',
      name: 'Sage Tea',
      description: 'Antiseptic properties. Great for oral and throat health.',
      iconEmoji: '🍃',
      color: const Color(0xFF9CCC65),
      hydrationFactor: 0.9,
      benefits: [
        'Antiseptic properties',
        'Good for sore throat',
        'Supports oral health',
        'May improve memory',
      ],
      risks: [
        'Not recommended during pregnancy',
      ],
      recommendedDaily: '2 cups',
      category: DrinkCategory.classic,
    ),

    DrinkTypeInfo(
      id: 'mint-lemon tea',
      name: 'Mint-Lemon Tea',
      description: 'Refreshing blend that soothes stomach and relieves nausea.',
      iconEmoji: '🍋',
      color: const Color(0xFFB2DFDB),
      hydrationFactor: 0.95,
      benefits: [
        'Soothes upset stomach',
        'Relieves nausea',
        'Refreshing and energizing',
        'Rich in vitamin C',
      ],
      recommendedDaily: '3-4 cups',
      category: DrinkCategory.classic,
    ),

    DrinkTypeInfo(
      id: 'rosehip tea',
      name: 'Rosehip Tea',
      description: 'Vitamin C powerhouse. Boosts immunity naturally.',
      iconEmoji: '🌹',
      color: const Color(0xFFFF8A80),
      hydrationFactor: 0.95,
      benefits: [
        'Very high in vitamin C',
        'Boosts immune system',
        'Supports skin health',
        'Antioxidant rich',
      ],
      recommendedDaily: '2-3 cups',
      category: DrinkCategory.classic,
    ),

    // ========== RELAXING / STRESS RELIEF ==========
    DrinkTypeInfo(
      id: 'lemon balm tea',
      name: 'Lemon Balm Tea',
      description: 'Reduces stress and promotes better sleep naturally.',
      iconEmoji: '🌿',
      color: const Color(0xFFE1F5DC),
      hydrationFactor: 0.95,
      benefits: [
        'Reduces stress and anxiety',
        'Improves sleep quality',
        'Calms nervous system',
        'Pleasant citrus flavor',
      ],
      recommendedDaily: '2-3 cups',
      category: DrinkCategory.relaxing,
    ),

    DrinkTypeInfo(
      id: 'lavender tea',
      name: 'Lavender Tea',
      description: 'Calming floral tea for peace and tranquility.',
      iconEmoji: '💜',
      color: const Color(0xFFD1C4E9),
      hydrationFactor: 0.95,
      benefits: [
        'Promotes relaxation',
        'Reduces anxiety',
        'Helps with headaches',
        'Improves mood',
      ],
      recommendedDaily: '1-2 cups',
      category: DrinkCategory.relaxing,
    ),

    DrinkTypeInfo(
      id: 'valerian tea',
      name: 'Valerian Tea',
      description: 'Powerful natural sleep aid. Use before bedtime.',
      iconEmoji: '🌙',
      color: const Color(0xFFB39DDB),
      hydrationFactor: 0.9,
      benefits: [
        'Strong sleep aid',
        'Reduces insomnia',
        'Calms nervous system',
      ],
      risks: [
        'May cause drowsiness',
        'Not for daytime use',
      ],
      recommendedDaily: '1 cup before bed',
      category: DrinkCategory.relaxing,
    ),

    DrinkTypeInfo(
      id: 'fennel tea',
      name: 'Fennel Tea',
      description: 'Relieves bloating and gas. Great after meals.',
      iconEmoji: '🌱',
      color: const Color(0xFFC5E1A5),
      hydrationFactor: 0.95,
      benefits: [
        'Relieves gas and bloating',
        'Aids digestion',
        'Relaxing effect',
        'Sweet natural flavor',
      ],
      recommendedDaily: '2-3 cups',
      category: DrinkCategory.relaxing,
    ),

    // ========== DIGESTIVE SUPPORT ==========
    DrinkTypeInfo(
      id: 'ginger tea',
      name: 'Ginger Tea',
      description: 'Powerful digestive aid. Relieves nausea and stomach pain.',
      iconEmoji: '🫚',
      color: const Color(0xFFFFCC80),
      hydrationFactor: 0.9,
      benefits: [
        'Relieves nausea',
        'Soothes stomach pain',
        'Anti-inflammatory',
        'Boosts immunity',
      ],
      recommendedDaily: '2-3 cups',
      category: DrinkCategory.digestive,
    ),

    DrinkTypeInfo(
      id: 'turmeric tea',
      name: 'Turmeric Tea',
      description: 'Anti-inflammatory golden tea. Supports digestion and overall health.',
      iconEmoji: '🟡',
      color: const Color(0xFFFFB74D),
      hydrationFactor: 0.9,
      benefits: [
        'Powerful anti-inflammatory',
        'Supports digestion',
        'Boosts immunity',
        'Antioxidant rich',
      ],
      recommendedDaily: '1-2 cups',
      category: DrinkCategory.digestive,
    ),

    DrinkTypeInfo(
      id: 'anise tea',
      name: 'Anise Tea',
      description: 'Soothes stomach discomfort and aids digestion.',
      iconEmoji: '⭐',
      color: const Color(0xFFDCEDC8),
      hydrationFactor: 0.95,
      benefits: [
        'Relieves indigestion',
        'Reduces bloating',
        'Soothes stomach',
        'Sweet licorice flavor',
      ],
      recommendedDaily: '2 cups',
      category: DrinkCategory.digestive,
    ),

    DrinkTypeInfo(
      id: 'mate tea',
      name: 'Mate Tea',
      description: 'Energy-boosting South American tea. Speeds up metabolism.',
      iconEmoji: '🧉',
      color: const Color(0xFF8BC34A),
      hydrationFactor: 0.85,
      benefits: [
        'Boosts energy',
        'Speeds up metabolism',
        'Supports weight loss',
        'Rich in antioxidants',
      ],
      risks: [
        'Contains caffeine',
        'May affect sleep',
      ],
      recommendedDaily: '2-3 cups',
      category: DrinkCategory.digestive,
    ),

    // ========== DETOX & METABOLISM ==========
    DrinkTypeInfo(
      id: 'green tea',
      name: 'Green Tea',
      description: 'Antioxidant-rich tea. Supports fat burning and metabolism.',
      iconEmoji: '🍵',
      color: const Color(0xFF81C784),
      hydrationFactor: 0.9,
      benefits: [
        'Supports fat burning',
        'Boosts metabolism',
        'Rich in antioxidants',
        'May improve brain function',
      ],
      risks: [
        'Contains caffeine (less than coffee)',
      ],
      recommendedDaily: '2-3 cups',
      category: DrinkCategory.detox,
    ),

    DrinkTypeInfo(
      id: 'white tea',
      name: 'White Tea',
      description: 'Delicate tea with powerful antioxidants. Supports weight management.',
      iconEmoji: '☁️',
      color: const Color(0xFFF5F5DC),
      hydrationFactor: 0.95,
      benefits: [
        'Highest antioxidant content',
        'Supports weight loss',
        'Gentle on stomach',
        'Anti-aging properties',
      ],
      recommendedDaily: '2-3 cups',
      category: DrinkCategory.detox,
    ),

    DrinkTypeInfo(
      id: 'oolong tea',
      name: 'Oolong Tea',
      description: 'Traditional Chinese tea. Speeds up metabolism.',
      iconEmoji: '🫖',
      color: const Color(0xFFD4A574),
      hydrationFactor: 0.9,
      benefits: [
        'Boosts metabolism',
        'Supports weight management',
        'Improves mental alertness',
        'Rich flavor profile',
      ],
      recommendedDaily: '2-3 cups',
      category: DrinkCategory.detox,
    ),

    DrinkTypeInfo(
      id: 'hibiscus tea',
      name: 'Hibiscus Tea',
      description: 'Beautiful red tea. Helps reduce water retention.',
      iconEmoji: '🌺',
      color: const Color(0xFFE91E63),
      hydrationFactor: 0.95,
      benefits: [
        'Reduces water retention',
        'Supports heart health',
        'Rich in vitamin C',
        'Tangy refreshing taste',
      ],
      recommendedDaily: '2-3 cups',
      category: DrinkCategory.detox,
    ),

    // ========== IMMUNITY BOOSTING ==========
    DrinkTypeInfo(
      id: 'echinacea tea',
      name: 'Echinacea Tea',
      description: 'Powerful immune system booster. Great for prevention.',
      iconEmoji: '🌸',
      color: const Color(0xFFCE93D8),
      hydrationFactor: 0.95,
      benefits: [
        'Boosts immune system',
        'Fights infections',
        'Reduces cold duration',
        'Anti-inflammatory',
      ],
      recommendedDaily: '2 cups (during illness)',
      category: DrinkCategory.immunity,
    ),

    DrinkTypeInfo(
      id: 'ginger-honey-lemon tea',
      name: 'Ginger-Honey-Lemon Tea',
      description: 'Ultimate cold and flu fighter. Warming and soothing.',
      iconEmoji: '🍯',
      color: const Color(0xFFFFF176),
      hydrationFactor: 0.9,
      benefits: [
        'Fights cold and flu',
        'Soothes sore throat',
        'Boosts immunity',
        'Natural antibacterial',
      ],
      recommendedDaily: '3-4 cups when sick',
      category: DrinkCategory.immunity,
    ),

    // ========== COLD & FLU RELIEF ==========
    DrinkTypeInfo(
      id: 'clove tea',
      name: 'Clove Tea',
      description: 'Antiseptic tea. Relieves cough and cold symptoms.',
      iconEmoji: '🌰',
      color: const Color(0xFF8D6E63),
      hydrationFactor: 0.9,
      benefits: [
        'Antiseptic properties',
        'Relieves cough',
        'Soothes sore throat',
        'Warming effect',
      ],
      recommendedDaily: '2 cups',
      category: DrinkCategory.coldFlu,
    ),

    DrinkTypeInfo(
      id: 'cinnamon tea',
      name: 'Cinnamon Tea',
      description: 'Warming spice tea. Helps reduce fever and fight infections.',
      iconEmoji: '🟤',
      color: const Color(0xFFD7B39A),
      hydrationFactor: 0.95,
      benefits: [
        'Reduces fever',
        'Fights infections',
        'Warming effect',
        'Sweet spicy flavor',
      ],
      recommendedDaily: '2-3 cups',
      category: DrinkCategory.coldFlu,
    ),

    // ========== WOMEN'S HEALTH ==========
    DrinkTypeInfo(
      id: 'vitex tea',
      name: 'Vitex Tea',
      description: 'Supports menstrual cycle regulation and hormonal balance.',
      iconEmoji: '🌺',
      color: const Color(0xFFF48FB1),
      hydrationFactor: 0.95,
      benefits: [
        'Regulates menstrual cycle',
        'Supports hormonal balance',
        'Reduces PMS symptoms',
      ],
      recommendedDaily: '1-2 cups',
      category: DrinkCategory.womensHealth,
    ),

    DrinkTypeInfo(
      id: 'raspberry leaf tea',
      name: 'Raspberry Leaf Tea',
      description: 'Traditional women\'s health tea. Eases menstrual discomfort.',
      iconEmoji: '🍓',
      color: const Color(0xFFFF6F91),
      hydrationFactor: 0.95,
      benefits: [
        'Eases menstrual cramps',
        'Tones uterine muscles',
        'Rich in vitamins',
        'Supports women\'s health',
      ],
      recommendedDaily: '2-3 cups',
      category: DrinkCategory.womensHealth,
    ),

    // ========== SPECIAL & RARE ==========
    DrinkTypeInfo(
      id: 'matcha',
      name: 'Matcha',
      description: 'Concentrated green tea powder. Boosts energy and focus.',
      iconEmoji: '🍵',
      color: const Color(0xFF7CB342),
      hydrationFactor: 0.85,
      benefits: [
        'High caffeine content',
        'Boosts concentration',
        'Rich in antioxidants',
        'Sustained energy release',
      ],
      risks: [
        'High caffeine - limit to 1-2 per day',
      ],
      recommendedDaily: '1-2 cups',
      category: DrinkCategory.special,
    ),

    DrinkTypeInfo(
      id: 'moringa tea',
      name: 'Moringa Tea',
      description: 'Superfood tea packed with minerals and vitamins.',
      iconEmoji: '🌿',
      color: const Color(0xFF7CB342),
      hydrationFactor: 0.95,
      benefits: [
        'Rich in minerals',
        'High vitamin content',
        'Boosts energy',
        'Anti-inflammatory',
      ],
      recommendedDaily: '1-2 cups',
      category: DrinkCategory.special,
    ),

    DrinkTypeInfo(
      id: 'ginseng tea',
      name: 'Ginseng Tea',
      description: 'Adaptogenic tea. Boosts energy and immune function.',
      iconEmoji: '⚡',
      color: const Color(0xFFFFE082),
      hydrationFactor: 0.9,
      benefits: [
        'Boosts energy',
        'Strengthens immunity',
        'Improves mental clarity',
        'Adaptogenic properties',
      ],
      recommendedDaily: '1-2 cups',
      category: DrinkCategory.special,
    ),

    DrinkTypeInfo(
      id: 'rooibos tea',
      name: 'Rooibos Tea',
      description: 'Caffeine-free red tea from South Africa. Rich in antioxidants.',
      iconEmoji: '🔴',
      color: const Color(0xFFD32F2F),
      hydrationFactor: 0.95,
      benefits: [
        'Caffeine-free',
        'Rich in antioxidants',
        'Supports heart health',
        'Sweet natural flavor',
      ],
      recommendedDaily: '3-4 cups',
      category: DrinkCategory.special,
    ),

    DrinkTypeInfo(
      id: 'rosemary tea',
      name: 'Rosemary Tea',
      description: 'Enhances memory and focus. Aromatic herbal tea.',
      iconEmoji: '🌿',
      color: const Color(0xFF66BB6A),
      hydrationFactor: 0.95,
      benefits: [
        'Improves memory',
        'Enhances concentration',
        'Antioxidant properties',
        'Aromatic flavor',
      ],
      recommendedDaily: '1-2 cups',
      category: DrinkCategory.special,
    ),

    // Add the previously defined tea from drink_selector
    DrinkTypeInfo(
      id: 'tea',
      name: 'Tea',
      description: 'Traditional tea. Rich in antioxidants and calming properties.',
      iconEmoji: '🍵',
      color: const Color(0xFF81C784),
      hydrationFactor: 0.9,
      benefits: [
        'Rich in antioxidants',
        'Calming effect',
        'May improve heart health',
      ],
      recommendedDaily: '3-4 cups',
      category: DrinkCategory.basic,
    ),
  ];

  /// Get drink by ID
  static DrinkTypeInfo? getDrinkById(String id) {
    try {
      return allDrinks.firstWhere(
        (drink) => drink.id.toLowerCase() == id.toLowerCase(),
        orElse: () => allDrinks[0], // Default to water
      );
    } catch (e) {
      return allDrinks[0]; // Return water as fallback
    }
  }

  /// Get drinks by category
  static List<DrinkTypeInfo> getDrinksByCategory(DrinkCategory category) {
    return allDrinks.where((drink) => drink.category == category).toList();
  }

  /// Get popular drinks (for quick selection)
  static List<DrinkTypeInfo> getPopularDrinks() {
    return [
      getDrinkById('water')!,
      getDrinkById('coffee')!,
      getDrinkById('green tea')!,
      getDrinkById('chamomile tea')!,
      getDrinkById('linden tea')!,
      getDrinkById('ginger tea')!,
    ];
  }
}
