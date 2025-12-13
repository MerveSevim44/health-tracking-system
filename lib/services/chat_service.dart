// 📁 lib/services/chat_service.dart
// Firebase Chat operations service

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/chat_models.dart';

class ChatService {
  final FirebaseDatabase _database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: "https://health-tracking-system-700bf-default-rtdb.europe-west1.firebasedatabase.app"
  );

  DatabaseReference get _dbRef => _database.ref();

  /// Create a new chat session
  /// Returns sessionId
  Future<String> createChatSession({
    required String userId,
    required String topic,
  }) async {
    try {
      final sessionRef = _dbRef.child('chat_sessions').child(userId).push();
      final sessionId = sessionRef.key!;
      final now = DateTime.now().toIso8601String();

      final session = ChatSession(
        id: sessionId,
        startTime: now,
        lastMessageTime: now,
        topic: topic,
      );

      await sessionRef.set(session.toJson());
      print('✅ Chat session created: $sessionId');
      return sessionId;
    } catch (e) {
      print('❌ Error creating chat session: $e');
      rethrow;
    }
  }

  /// Add message to session
  Future<String> addMessage({
    required String userId,
    required String sessionId,
    required String sender,
    required String text,
    String sentiment = 'neutral',
  }) async {
    try {
      final messageRef = _dbRef
          .child('chat_messages')
          .child(userId)
          .child(sessionId)
          .push();
      final messageId = messageRef.key!;
      final now = DateTime.now().toIso8601String();

      final message = ChatMessage(
        id: messageId,
        sender: sender,
        text: text,
        sentiment: sentiment,
        timestamp: now,
      );

      // Save message
      await messageRef.set(message.toJson());

      // Update session lastMessageTime
      await _dbRef
          .child('chat_sessions')
          .child(userId)
          .child(sessionId)
          .update({'lastMessageTime': now});

      print('✅ Message added to session: $sessionId');
      return messageId;
    } catch (e) {
      print('❌ Error adding message: $e');
      rethrow;
    }
  }

  /// Get all sessions for user (ordered by lastMessageTime)
  Stream<List<ChatSession>> getUserSessions(String userId) {
    return _dbRef
        .child('chat_sessions')
        .child(userId)
        .orderByChild('lastMessageTime')
        .onValue
        .map((event) {
      final data = event.snapshot.value;
      if (data == null) return <ChatSession>[];

      final sessions = <ChatSession>[];
      final map = data as Map<dynamic, dynamic>;

      map.forEach((key, value) {
        if (value is Map) {
          final sessionMap = Map<String, dynamic>.from(value as Map);
          sessions.add(ChatSession.fromJson(key.toString(), sessionMap));
        }
      });

      // Sort by lastMessageTime descending (newest first)
      sessions.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
      return sessions;
    });
  }

  /// Get messages for a specific session (ordered by timestamp)
  Stream<List<ChatMessage>> getSessionMessages({
    required String userId,
    required String sessionId,
  }) {
    return _dbRef
        .child('chat_messages')
        .child(userId)
        .child(sessionId)
        .orderByChild('timestamp')
        .onValue
        .map((event) {
      final data = event.snapshot.value;
      if (data == null) return <ChatMessage>[];

      final messages = <ChatMessage>[];
      final map = data as Map<dynamic, dynamic>;

      map.forEach((key, value) {
        if (value is Map) {
          final messageMap = Map<String, dynamic>.from(value as Map);
          messages.add(ChatMessage.fromJson(key.toString(), messageMap));
        }
      });

      // Sort by timestamp ascending (oldest first)
      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return messages;
    });
  }

  /// Get or create today's daily check-in session
  /// Note: Fetches all sessions to avoid Firebase index requirement
  Future<String> getTodayCheckInSession(String userId) async {
    try {
      // Get all sessions (no index needed)
      final sessionsSnapshot = await _dbRef
          .child('chat_sessions')
          .child(userId)
          .get();

      if (sessionsSnapshot.exists) {
        final data = sessionsSnapshot.value as Map<dynamic, dynamic>;
        final today = DateTime.now();

        // Filter for daily check-in sessions from today
        for (var entry in data.entries) {
          final sessionData = entry.value as Map;
          final topic = sessionData['topic'] as String?;
          final startTime = sessionData['startTime'] as String?;
          
          if (topic == 'daily check-in' && startTime != null) {
            final sessionDate = DateTime.parse(startTime);
            if (sessionDate.year == today.year &&
                sessionDate.month == today.month &&
                sessionDate.day == today.day) {
              print('✅ Found today\'s check-in session: ${entry.key}');
              return entry.key.toString();
            }
          }
        }
      }

      // No today's session found, create new one
      print('📝 Creating new daily check-in session');
      return await createChatSession(
        userId: userId,
        topic: 'daily check-in',
      );
    } catch (e) {
      print('❌ Error getting today\'s check-in session: $e');
      rethrow;
    }
  }

  /// Delete a session and all its messages
  Future<void> deleteSession({
    required String userId,
    required String sessionId,
  }) async {
    try {
      // Delete messages
      await _dbRef
          .child('chat_messages')
          .child(userId)
          .child(sessionId)
          .remove();

      // Delete session
      await _dbRef
          .child('chat_sessions')
          .child(userId)
          .child(sessionId)
          .remove();

      print('✅ Session deleted: $sessionId');
    } catch (e) {
      print('❌ Error deleting session: $e');
      rethrow;
    }
  }
}
