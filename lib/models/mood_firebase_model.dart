// 📁 lib/models/mood_firebase_model.dart
// Firebase-compatible mood tracking models

/// Mood entry matching Firebase schema
/// Firebase path: moods/{userId}/{moodId}
class MoodFirebase {
  final String id;
  final String date; // ISO string
  final int moodLevel; // 1-5 or similar scale
  final List<String> emotions; // array of emotion strings
  final String notes;
  final double sentimentScore;
  final double sentimentMagnitude;

  const MoodFirebase({
    required this.id,
    required this.date,
    required this.moodLevel,
    required this.emotions,
    this.notes = '',
    this.sentimentScore = 0.0,
    this.sentimentMagnitude = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'moodLevel': moodLevel,
      'emotions': emotions,
      'notes': notes,
      'sentimentScore': sentimentScore,
      'sentimentMagnitude': sentimentMagnitude,
    };
  }

  factory MoodFirebase.fromJson(String id, Map<String, dynamic> json) {
    return MoodFirebase(
      id: id,
      date: json['date'] as String? ?? DateTime.now().toIso8601String(),
      moodLevel: json['moodLevel'] as int? ?? 3,
      emotions: (json['emotions'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      notes: json['notes'] as String? ?? '',
      sentimentScore: (json['sentimentScore'] as num?)?.toDouble() ?? 0.0,
      sentimentMagnitude: (json['sentimentMagnitude'] as num?)?.toDouble() ?? 0.0,
    );
  }

  MoodFirebase copyWith({
    String? date,
    int? moodLevel,
    List<String>? emotions,
    String? notes,
    double? sentimentScore,
    double? sentimentMagnitude,
  }) {
    return MoodFirebase(
      id: id,
      date: date ?? this.date,
      moodLevel: moodLevel ?? this.moodLevel,
      emotions: emotions ?? this.emotions,
      notes: notes ?? this.notes,
      sentimentScore: sentimentScore ?? this.sentimentScore,
      sentimentMagnitude: sentimentMagnitude ?? this.sentimentMagnitude,
    );
  }

  /// Helper to get mood label from level
  String get moodLabel {
    switch (moodLevel) {
      case 5:
        return 'Great';
      case 4:
        return 'Good';
      case 3:
        return 'Neutral';
      case 2:
        return 'Bad';
      case 1:
        return 'Awful';
      default:
        return 'Unknown';
    }
  }

  /// Helper to check if mood has specific emotion
  bool hasEmotion(String emotion) {
    return emotions.contains(emotion.toLowerCase());
  }
}

/// Predefined emotions list
class EmotionsList {
  static const List<String> common = [
    'happy',
    'sad',
    'anxious',
    'calm',
    'angry',
    'excited',
    'tired',
    'energetic',
    'stressed',
    'relaxed',
    'grateful',
    'frustrated',
    'confident',
    'overwhelmed',
    'peaceful',
  ];

  static const Map<String, String> emotionEmojis = {
    'happy': '😊',
    'sad': '😢',
    'anxious': '😰',
    'calm': '😌',
    'angry': '😠',
    'excited': '🤩',
    'tired': '😴',
    'energetic': '⚡',
    'stressed': '😫',
    'relaxed': '😎',
    'grateful': '🙏',
    'frustrated': '😤',
    'confident': '💪',
    'overwhelmed': '🤯',
    'peaceful': '☮️',
  };

  static String getEmoji(String emotion) {
    return emotionEmojis[emotion.toLowerCase()] ?? '😐';
  }
}
