// 📁 lib/models/sleep_model.dart
// Sleep tracking data model matching Firebase structure

class SleepLog {
  final String date; // YYYY-MM-DD format (also used as key)
  final String bedTime; // HH:mm format
  final String wakeTime; // HH:mm format
  final double durationHours; // Hours (e.g., 7.75)
  final int quality; // 1-5 rating
  final int createdAt; // Unix timestamp

  SleepLog({
    required this.date,
    required this.bedTime,
    required this.wakeTime,
    required this.durationHours,
    required this.quality,
    required this.createdAt,
  });

  // Create from DateTime objects (for UI input)
  factory SleepLog.fromDateTimes({
    required String date,
    required DateTime bedTimeDate,
    required DateTime wakeTimeDate,
    required int quality,
  }) {
    final bedTime = '${bedTimeDate.hour.toString().padLeft(2, '0')}:${bedTimeDate.minute.toString().padLeft(2, '0')}';
    final wakeTime = '${wakeTimeDate.hour.toString().padLeft(2, '0')}:${wakeTimeDate.minute.toString().padLeft(2, '0')}';
    
    // Calculate duration in hours
    final duration = wakeTimeDate.difference(bedTimeDate).inMinutes / 60.0;
    
    return SleepLog(
      date: date,
      bedTime: bedTime,
      wakeTime: wakeTime,
      durationHours: duration,
      quality: quality,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  // Convert to Firebase format
  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'bedTime': bedTime,
      'wakeTime': wakeTime,
      'durationHours': durationHours,
      'quality': quality,
      'createdAt': createdAt,
    };
  }

  // Parse from Firebase with null safety
  factory SleepLog.fromJson(String dateKey, Map<String, dynamic> json) {
    return SleepLog(
      date: json['date'] as String? ?? dateKey,
      bedTime: json['bedTime'] as String? ?? '00:00',
      wakeTime: json['wakeTime'] as String? ?? '00:00',
      durationHours: (json['durationHours'] as num?)?.toDouble() ?? 0.0,
      quality: json['quality'] as int? ?? 3,
      createdAt: json['createdAt'] as int? ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  // Get formatted duration string (e.g., "7h 45m")
  String get formattedDuration {
    final hours = durationHours.floor();
    final minutes = ((durationHours - hours) * 60).round();
    return '${hours}h ${minutes}m';
  }

  // Get short duration (e.g., "7.8h")
  String get shortDuration {
    return '${durationHours.toStringAsFixed(1)}h';
  }

  // Get quality label
  String get qualityLabel {
    switch (quality) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Fair';
      case 4:
        return 'Good';
      case 5:
        return 'Excellent';
      default:
        return 'Fair';
    }
  }

  // Parse time string to DateTime (for calculations)
  DateTime parseTimeToday(String timeStr) {
    final parts = timeStr.split(':');
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
  }
}
