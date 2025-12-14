// 📁 lib/services/notification_service.dart
// Local notification service for medication and water reminders

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: "https://health-tracking-system-700bf-default-rtdb.europe-west1.firebasedatabase.app"
  );

  String? get _userId => _auth.currentUser?.uid;

  // Notification IDs
  static const int _medicationBaseId = 1000;
  static const int _waterMorningId = 2000;
  static const int _waterAfternoonId = 2001;
  static const int _waterEveningId = 2002;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('🔔 [NotificationService] Already initialized');
      return;
    }

    try {
      // Initialize timezone
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));
      debugPrint('🔔 [NotificationService] Timezone initialized: Europe/Istanbul');

      // Android initialization settings
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      
      // iOS initialization settings
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Initialize plugin
      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      debugPrint('🔔 [NotificationService] Plugin initialized');

      // Request permissions
      await _requestPermissions();

      _isInitialized = true;
      debugPrint('✅ [NotificationService] Initialization complete');
    } catch (e) {
      debugPrint('❌ [NotificationService] Initialization failed: $e');
    }
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    try {
      // Request notification permission
      final status = await Permission.notification.request();
      debugPrint('🔔 [NotificationService] Permission status: $status');

      // iOS-specific: Request exact alarm permission
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await _notifications
            .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(alert: true, badge: true, sound: true);
        debugPrint('🔔 [NotificationService] iOS permissions requested');
      }

      // Android-specific: Request exact alarm permission (API 31+)
      if (defaultTargetPlatform == TargetPlatform.android) {
        await Permission.scheduleExactAlarm.request();
        debugPrint('🔔 [NotificationService] Android exact alarm permission requested');
      }
    } catch (e) {
      debugPrint('❌ [NotificationService] Permission request failed: $e');
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('🔔 [NotificationService] Notification tapped: ${response.payload}');
    // TODO: Navigate to appropriate screen based on payload
  }

  // ==================== MEDICATION NOTIFICATIONS ====================

  /// Schedule all medication notifications
  Future<void> scheduleAllMedicationNotifications() async {
    if (!_isInitialized) {
      debugPrint('⚠️ [NotificationService] Not initialized, initializing now...');
      await initialize();
    }

    if (_userId == null) {
      debugPrint('⚠️ [NotificationService] User not authenticated');
      return;
    }

    try {
      // Check user preference
      final prefSnapshot = await _database
          .ref('users/$_userId/notificationPreferences/medicationReminders')
          .get();
      
      final enabled = prefSnapshot.value as bool? ?? true;
      if (!enabled) {
        debugPrint('🔕 [NotificationService] Medication reminders disabled by user');
        return;
      }

      // Get all active medications
      final medsSnapshot = await _database.ref('medications/$_userId').get();
      if (!medsSnapshot.exists) {
        debugPrint('ℹ️ [NotificationService] No medications found');
        return;
      }

      final medsData = medsSnapshot.value as Map<dynamic, dynamic>;
      int scheduledCount = 0;

      for (var entry in medsData.entries) {
        final medId = entry.key as String;
        final medData = Map<String, dynamic>.from(entry.value as Map);
        
        final isActive = medData['active'] as bool? ?? false;
        if (!isActive) {
          debugPrint('⏭️ [NotificationService] Skipping inactive medication: $medId');
          continue;
        }

        final medName = medData['name'] as String? ?? 'Medication';
        final frequency = Map<String, dynamic>.from(medData['frequency'] as Map? ?? {});

        // Schedule for each time slot
        if (frequency['morning'] == true) {
          await _scheduleMedicationNotification(medId, 'morning', medName, 8, 0);
          scheduledCount++;
        }
        if (frequency['afternoon'] == true) {
          await _scheduleMedicationNotification(medId, 'afternoon', medName, 14, 0);
          scheduledCount++;
        }
        if (frequency['evening'] == true) {
          await _scheduleMedicationNotification(medId, 'evening', medName, 20, 0);
          scheduledCount++;
        }
      }

      debugPrint('✅ [NotificationService] Scheduled $scheduledCount medication notifications');
    } catch (e) {
      debugPrint('❌ [NotificationService] Failed to schedule medication notifications: $e');
    }
  }

  /// Schedule a single medication notification
  Future<void> _scheduleMedicationNotification(
    String medId,
    String period,
    String medName,
    int hour,
    int minute,
  ) async {
    try {
      final notificationId = _medicationBaseId + medId.hashCode.abs() % 900 + _getPeriodOffset(period);
      
      // Check if already taken today
      final today = DateTime.now();
      final dateKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      final intakeKey = '${dateKey}_$period';
      
      final intakeSnapshot = await _database
          .ref('medication_intakes/$_userId/$medId/$intakeKey')
          .get();
      
      if (intakeSnapshot.exists) {
        final intakeData = Map<String, dynamic>.from(intakeSnapshot.value as Map);
        final taken = intakeData['taken'] as bool? ?? false;
        
        if (taken) {
          debugPrint('✓ [NotificationService] Medication already taken today ($period): $medName');
          await _notifications.cancel(notificationId);
          return;
        }
      }

      // Schedule notification
      final scheduledTime = _getNextScheduledTime(hour, minute);
      
      await _notifications.zonedSchedule(
        notificationId,
        '💊 Time to take your medication',
        medName,
        scheduledTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'medication_reminders',
            'Medication Reminders',
            channelDescription: 'Reminders to take your medications',
            importance: Importance.high,
            priority: Priority.high,
            enableVibration: true,
            playSound: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'medication:$medId:$period',
      );

      debugPrint('✅ [NotificationService] Scheduled $period notification for $medName at ${scheduledTime.hour}:${scheduledTime.minute}');
    } catch (e) {
      debugPrint('❌ [NotificationService] Failed to schedule medication notification: $e');
    }
  }

  /// Cancel medication notification for a specific period
  Future<void> cancelMedicationNotification(String medId, String period) async {
    try {
      final notificationId = _medicationBaseId + medId.hashCode.abs() % 900 + _getPeriodOffset(period);
      await _notifications.cancel(notificationId);
      debugPrint('🔕 [NotificationService] Cancelled $period notification for medication: $medId');
    } catch (e) {
      debugPrint('❌ [NotificationService] Failed to cancel medication notification: $e');
    }
  }

  /// Cancel all notifications for a medication
  Future<void> cancelAllMedicationNotifications(String medId) async {
    await cancelMedicationNotification(medId, 'morning');
    await cancelMedicationNotification(medId, 'afternoon');
    await cancelMedicationNotification(medId, 'evening');
    debugPrint('🔕 [NotificationService] Cancelled all notifications for medication: $medId');
  }

  // ==================== WATER NOTIFICATIONS ====================

  /// Schedule water reminder notifications
  Future<void> scheduleWaterReminders() async {
    if (!_isInitialized) {
      debugPrint('⚠️ [NotificationService] Not initialized, initializing now...');
      await initialize();
    }

    if (_userId == null) {
      debugPrint('⚠️ [NotificationService] User not authenticated');
      return;
    }

    try {
      // Check user preference
      final prefSnapshot = await _database
          .ref('users/$_userId/notificationPreferences/waterReminders')
          .get();
      
      final enabled = prefSnapshot.value as bool? ?? true;
      if (!enabled) {
        debugPrint('🔕 [NotificationService] Water reminders disabled by user');
        return;
      }

      // Get user's water goal
      final goalSnapshot = await _database
          .ref('users/$_userId/waterGoalMl')
          .get();
      
      final goalMl = goalSnapshot.value as int? ?? 2000;

      // Schedule reminder for afternoon (check 50% progress)
      await _scheduleWaterReminder(
        _waterAfternoonId,
        14, 0,
        '💧 Hydration Check!',
        "You're halfway through the day. Have you reached 50% of your ${goalMl}ml goal?",
        0.5,
      );

      // Schedule reminder for evening (check 80% progress)
      await _scheduleWaterReminder(
        _waterEveningId,
        19, 0,
        '💧 Almost There!',
        "It's evening! Have you reached 80% of your ${goalMl}ml goal?",
        0.8,
      );

      debugPrint('✅ [NotificationService] Scheduled water reminders');
    } catch (e) {
      debugPrint('❌ [NotificationService] Failed to schedule water reminders: $e');
    }
  }

  /// Schedule a single water reminder
  Future<void> _scheduleWaterReminder(
    int notificationId,
    int hour,
    int minute,
    String title,
    String body,
    double targetPercentage,
  ) async {
    try {
      // Check if user has already met the target
      final goalSnapshot = await _database
          .ref('users/$_userId/waterGoalMl')
          .get();
      final goalMl = goalSnapshot.value as int? ?? 2000;

      final today = DateTime.now();
      final dateKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      
      final logsSnapshot = await _database
          .ref('water_logs/$_userId')
          .get();

      int totalMl = 0;
      if (logsSnapshot.exists) {
        final logsData = logsSnapshot.value as Map<dynamic, dynamic>;
        for (var entry in logsData.values) {
          final log = Map<String, dynamic>.from(entry as Map);
          if (log['date'] == dateKey) {
            totalMl += (log['amountML'] as int?) ?? 0;
          }
        }
      }

      final progress = totalMl / goalMl;
      if (progress >= targetPercentage) {
        debugPrint('✓ [NotificationService] Water goal already met (${(progress * 100).toStringAsFixed(0)}%)');
        await _notifications.cancel(notificationId);
        return;
      }

      // Schedule notification
      final scheduledTime = _getNextScheduledTime(hour, minute);
      
      await _notifications.zonedSchedule(
        notificationId,
        title,
        body,
        scheduledTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'water_reminders',
            'Water Reminders',
            channelDescription: 'Reminders to drink water',
            importance: Importance.high,
            priority: Priority.high,
            enableVibration: true,
            playSound: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'water:reminder',
      );

      debugPrint('✅ [NotificationService] Scheduled water reminder at ${scheduledTime.hour}:${scheduledTime.minute}');
    } catch (e) {
      debugPrint('❌ [NotificationService] Failed to schedule water reminder: $e');
    }
  }

  /// Cancel all water reminders
  Future<void> cancelAllWaterReminders() async {
    await _notifications.cancel(_waterAfternoonId);
    await _notifications.cancel(_waterEveningId);
    debugPrint('🔕 [NotificationService] Cancelled all water reminders');
  }

  // ==================== HELPER METHODS ====================

  /// Get next scheduled time for a given hour and minute
  tz.TZDateTime _getNextScheduledTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    
    // If the time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    return scheduledDate;
  }

  /// Get period offset for notification ID calculation
  int _getPeriodOffset(String period) {
    switch (period.toLowerCase()) {
      case 'morning':
        return 0;
      case 'afternoon':
        return 300;
      case 'evening':
        return 600;
      default:
        return 0;
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    debugPrint('🔕 [NotificationService] Cancelled ALL notifications');
  }

  /// Get all pending notifications (for debugging)
  Future<void> debugPrintPendingNotifications() async {
    final pending = await _notifications.pendingNotificationRequests();
    debugPrint('📋 [NotificationService] Pending notifications: ${pending.length}');
    for (var notification in pending) {
      debugPrint('   - ID ${notification.id}: ${notification.title} - ${notification.body}');
    }
  }

  /// Reschedule all notifications (call after app restart or login)
  Future<void> rescheduleAllNotifications() async {
    debugPrint('🔄 [NotificationService] Rescheduling all notifications...');
    await scheduleAllMedicationNotifications();
    await scheduleWaterReminders();
    debugPrint('✅ [NotificationService] Rescheduling complete');
  }
}
