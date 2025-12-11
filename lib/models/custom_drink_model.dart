// 📁 lib/models/custom_drink_model.dart
// Genişletilmiş içecek modeli - custom ve predefined drinks için

import 'package:flutter/material.dart';

/// Genişletilmiş içecek modeli
class CustomDrink {
  final String id;
  final String name;
  final String? benefits;
  final String? harms;
  final String? recommendedIntake;
  final String iconUrl; // Firebase Storage URL veya emoji
  final Color color;
  final String category; // "tea", "herbal", "coffee", "juice", "custom"
  final bool isPredefined; // Sistem içeceği mi, kullanıcı ekledi mi?
  final DateTime? createdAt;

  const CustomDrink({
    required this.id,
    required this.name,
    this.benefits,
    this.harms,
    this.recommendedIntake,
    required this.iconUrl,
    required this.color,
    this.category = 'custom',
    this.isPredefined = false,
    this.createdAt,
  });

  // Firebase'e kayıt için JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'benefits': benefits,
      'harms': harms,
      'recommendedIntake': recommendedIntake,
      'iconUrl': iconUrl,
      'color': color.value,
      'category': category,
      'isPredefined': isPredefined,
      'createdAt': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  // Firebase'den okuma için
  factory CustomDrink.fromJson(Map<String, dynamic> json) {
    return CustomDrink(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      benefits: json['benefits'] as String?,
      harms: json['harms'] as String?,
      recommendedIntake: json['recommendedIntake'] as String?,
      iconUrl: json['iconUrl'] as String? ?? '🍵',
      color: Color(json['color'] as int? ?? 0xFF81C784),
      category: json['category'] as String? ?? 'custom',
      isPredefined: json['isPredefined'] as bool? ?? false,
      createdAt: json['createdAt'] != null 
        ? DateTime.parse(json['createdAt'] as String)
        : null,
    );
  }

  CustomDrink copyWith({
    String? id,
    String? name,
    String? benefits,
    String? harms,
    String? recommendedIntake,
    String? iconUrl,
    Color? color,
    String? category,
    bool? isPredefined,
    DateTime? createdAt,
  }) {
    return CustomDrink(
      id: id ?? this.id,
      name: name ?? this.name,
      benefits: benefits ?? this.benefits,
      harms: harms ?? this.harms,
      recommendedIntake: recommendedIntake ?? this.recommendedIntake,
      iconUrl: iconUrl ?? this.iconUrl,
      color: color ?? this.color,
      category: category ?? this.category,
      isPredefined: isPredefined ?? this.isPredefined,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Otomatik ikon seçici - kategori bazlı
class DrinkIconGenerator {
  static const Map<String, List<String>> categoryIcons = {
    'tea': ['🍵', '☕', '🫖'],
    'herbal': ['🌿', '🍃', '🌱', '🪴'],
    'coffee': ['☕', '🫘'],
    'juice': ['🧃', '🥤', '🍹'],
    'water': ['💧', '💦'],
    'milk': ['🥛', '🍼'],
    'custom': ['🍵', '☕', '🥤', '🧃', '💧'],
  };

  static const Map<String, List<Color>> categoryColors = {
    'tea': [Color(0xFF81C784), Color(0xFF66BB6A), Color(0xFF4CAF50)],
    'herbal': [Color(0xFFA5D6A7), Color(0xFF8BC34A), Color(0xFF9CCC65)],
    'coffee': [Color(0xFF8D6E63), Color(0xFFA1887F), Color(0xFF795548)],
    'juice': [Color(0xFFFF9800), Color(0xFFFFA726), Color(0xFFFFB74D)],
    'water': [Color(0xFF4FC3F7), Color(0xFF29B6F6), Color(0xFF03A9F4)],
    'milk': [Color(0xFFECEFF1), Color(0xFFCFD8DC), Color(0xFFB0BEC5)],
    'custom': [Color(0xFF81C784), Color(0xFF4FC3F7), Color(0xFFFFB74D)],
  };

  /// Kategori bazlı rastgele ikon seç
  static String generateIcon(String category) {
    final icons = categoryIcons[category.toLowerCase()] ?? categoryIcons['custom']!;
    return icons[(DateTime.now().millisecond % icons.length)];
  }

  /// Kategori bazlı rastgele renk seç
  static Color generateColor(String category) {
    final colors = categoryColors[category.toLowerCase()] ?? categoryColors['custom']!;
    return colors[(DateTime.now().millisecond % colors.length)];
  }
}

/// Günlük içecek logu
class DrinkLog {
  final String id;
  final String drinkId;
  final String drinkName;
  final int amount; // ml
  final String unit; // "ml" or "cup"
  final int cups; // Kaç bardak
  final DateTime timestamp;
  final String? iconUrl;
  final Color? color;

  const DrinkLog({
    required this.id,
    required this.drinkId,
    required this.drinkName,
    required this.amount,
    this.unit = 'ml',
    this.cups = 1,
    required this.timestamp,
    this.iconUrl,
    this.color,
  });

  Map<String, dynamic> toJson() {
    return {
      'drinkId': drinkId,
      'drinkName': drinkName,
      'amount': amount,
      'unit': unit,
      'cups': cups,
      'timestamp': timestamp.toIso8601String(),
      'iconUrl': iconUrl,
      'color': color?.value,
    };
  }

  factory DrinkLog.fromJson(String id, Map<String, dynamic> json) {
    return DrinkLog(
      id: id,
      drinkId: json['drinkId'] as String? ?? '',
      drinkName: json['drinkName'] as String? ?? 'Unknown',
      amount: json['amount'] as int? ?? 200,
      unit: json['unit'] as String? ?? 'ml',
      cups: json['cups'] as int? ?? 1,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      iconUrl: json['iconUrl'] as String?,
      color: json['color'] != null ? Color(json['color'] as int) : null,
    );
  }

  // Formatlanmış zaman gösterimi
  String get formattedTime {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // Display text
  String get displayText {
    if (drinkName.toLowerCase() == 'water') {
      return '$amount ml';
    } else {
      return '$cups cup${cups > 1 ? 's' : ''}';
    }
  }
}
