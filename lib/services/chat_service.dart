// 📁 lib/services/chat_service.dart
// Chat servisi - Firebase Realtime Database ile mesaj yönetimi

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../models/chat_models.dart';

class ChatService {
  final FirebaseDatabase _database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: "https://health-tracking-system-700bf-default-rtdb.europe-west1.firebasedatabase.app"
  );

  DatabaseReference get _dbRef => _database.ref();

  /// Yeni chat oturumu oluştur
  Future<String> createSession({
    required String userId,
    String? title,
  }) async {
    try {
      final sessionRef = _dbRef.child('users/$userId/chatSessions').push();
      final sessionId = sessionRef.key!;
      
      final session = ChatSession(
        id: sessionId,
        userId: userId,
        createdAt: DateTime.now(),
        title: title ?? 'Chat ${DateTime.now().toString().split(' ')[0]}',
        messageCount: 0,
      );

      await sessionRef.set(session.toJson());
      debugPrint('✅ Chat session created: $sessionId');
      
      return sessionId;
    } catch (e) {
      debugPrint('❌ Error creating chat session: $e');
      rethrow;
    }
  }

  /// Bugünün check-in oturumunu al veya oluştur
  Future<String> getTodayCheckInSession(String userId) async {
    try {
      final today = DateTime.now();
      final todayKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      
      // Bugünün check-in oturumunu kontrol et
      final checkInRef = _dbRef.child('users/$userId/dailyCheckIn/$todayKey/chatSessionId');
      final snapshot = await checkInRef.get();
      
      if (snapshot.exists) {
        final sessionId = snapshot.value as String;
        debugPrint('✅ Found existing check-in session: $sessionId');
        return sessionId;
      }
      
      // Yeni oturum oluştur
      final sessionId = await createSession(
        userId: userId,
        title: 'Daily Check-in $todayKey',
      );
      
      // Check-in referansını kaydet
      await checkInRef.set(sessionId);
      debugPrint('✅ Created new check-in session: $sessionId');
      
      return sessionId;
    } catch (e) {
      debugPrint('❌ Error getting today check-in session: $e');
      rethrow;
    }
  }

  /// Mesaj ekle
  Future<void> addMessage({
    required String userId,
    required String sessionId,
    required String sender,
    required String text,
    String sentiment = 'neutral',
  }) async {
    try {
      final messageRef = _dbRef.child('users/$userId/chatSessions/$sessionId/messages').push();
      final messageId = messageRef.key!;
      
      final message = ChatMessage(
        id: messageId,
        sender: sender,
        text: text,
        sentiment: sentiment,
        timestamp: DateTime.now(),
      );

      await messageRef.set(message.toJson());
      
      // Oturum bilgilerini güncelle
      await _updateSessionInfo(userId, sessionId);
      
      debugPrint('✅ Message added: $messageId');
    } catch (e) {
      debugPrint('❌ Error adding message: $e');
      rethrow;
    }
  }

  /// Oturum mesajlarını stream olarak al
  Stream<List<ChatMessage>> getSessionMessages({
    required String userId,
    required String sessionId,
  }) {
    try {
      final messagesRef = _dbRef.child('users/$userId/chatSessions/$sessionId/messages');
      
      return messagesRef.onValue.map((event) {
        final messages = <ChatMessage>[];
        
        if (event.snapshot.value != null) {
          final messagesMap = Map<String, dynamic>.from(event.snapshot.value as Map);
          
          messagesMap.forEach((key, value) {
            try {
              final messageData = Map<String, dynamic>.from(value as Map);
              messages.add(ChatMessage.fromFirestore(key, messageData));
            } catch (e) {
              debugPrint('❌ Error parsing message $key: $e');
            }
          });
          
          // Zamana göre sırala
          messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        }
        
        return messages;
      });
    } catch (e) {
      debugPrint('❌ Error getting session messages: $e');
      return Stream.value([]);
    }
  }

  /// Kullanıcının tüm oturumlarını al
  Future<List<ChatSession>> getUserSessions(String userId) async {
    try {
      final sessionsRef = _dbRef.child('users/$userId/chatSessions');
      final snapshot = await sessionsRef.get();
      
      final sessions = <ChatSession>[];
      
      if (snapshot.exists) {
        final sessionsMap = Map<String, dynamic>.from(snapshot.value as Map);
        
        sessionsMap.forEach((key, value) {
          try {
            final sessionData = Map<String, dynamic>.from(value as Map);
            // Messages'ı kaldırıyoruz çünkü session'a dahil etmiyoruz
            sessionData.remove('messages');
            
            sessions.add(ChatSession.fromFirestore(key, sessionData));
          } catch (e) {
            debugPrint('❌ Error parsing session $key: $e');
          }
        });
        
        // En yeni oturumlar önce
        sessions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
      
      return sessions;
    } catch (e) {
      debugPrint('❌ Error getting user sessions: $e');
      return [];
    }
  }

  /// Oturum sil
  Future<void> deleteSession({
    required String userId,
    required String sessionId,
  }) async {
    try {
      await _dbRef.child('users/$userId/chatSessions/$sessionId').remove();
      debugPrint('✅ Session deleted: $sessionId');
    } catch (e) {
      debugPrint('❌ Error deleting session: $e');
      rethrow;
    }
  }

  /// Oturum bilgilerini güncelle (son mesaj zamanı, mesaj sayısı)
  Future<void> _updateSessionInfo(String userId, String sessionId) async {
    try {
      final sessionRef = _dbRef.child('users/$userId/chatSessions/$sessionId');
      final messagesRef = sessionRef.child('messages');
      
      // Mesaj sayısını al
      final snapshot = await messagesRef.get();
      int messageCount = 0;
      
      if (snapshot.exists) {
        final messagesMap = Map<String, dynamic>.from(snapshot.value as Map);
        messageCount = messagesMap.length;
      }
      
      // Oturum bilgilerini güncelle
      await sessionRef.update({
        'lastMessageAt': DateTime.now().toIso8601String(),
        'messageCount': messageCount,
      });
      
      debugPrint('✅ Session info updated: $sessionId (messages: $messageCount)');
    } catch (e) {
      debugPrint('❌ Error updating session info: $e');
    }
  }

  /// Oturumdaki tüm mesajları sil
  Future<void> clearSessionMessages({
    required String userId,
    required String sessionId,
  }) async {
    try {
      await _dbRef.child('users/$userId/chatSessions/$sessionId/messages').remove();
      
      // Oturum bilgilerini sıfırla
      await _dbRef.child('users/$userId/chatSessions/$sessionId').update({
        'messageCount': 0,
        'lastMessageAt': null,
      });
      
      debugPrint('✅ Session messages cleared: $sessionId');
    } catch (e) {
      debugPrint('❌ Error clearing session messages: $e');
      rethrow;
    }
  }
}
