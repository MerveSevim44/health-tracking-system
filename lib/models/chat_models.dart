// 📁 lib/models/chat_models.dart
// Chat session and message models

/// Chat session model
/// Firebase path: chat_sessions/{uid}/{sessionId}
class ChatSession {
  final String id;
  final String startTime;
  final String lastMessageTime;
  final String topic;

  const ChatSession({
    required this.id,
    required this.startTime,
    required this.lastMessageTime,
    required this.topic,
  });

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime,
      'lastMessageTime': lastMessageTime,
      'topic': topic,
    };
  }

  factory ChatSession.fromJson(String id, Map<String, dynamic> json) {
    return ChatSession(
      id: id,
      startTime: json['startTime'] as String? ?? DateTime.now().toIso8601String(),
      lastMessageTime: json['lastMessageTime'] as String? ?? DateTime.now().toIso8601String(),
      topic: json['topic'] as String? ?? 'general',
    );
  }

  ChatSession copyWith({
    String? startTime,
    String? lastMessageTime,
    String? topic,
  }) {
    return ChatSession(
      id: id,
      startTime: startTime ?? this.startTime,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      topic: topic ?? this.topic,
    );
  }
}

/// Chat message model
/// Firebase path: chat_messages/{uid}/{sessionId}/{messageId}
class ChatMessage {
  final String id;
  final String sender; // "user" | "ai"
  final String text;
  final String sentiment; // "positive" | "neutral" | "negative"
  final String timestamp;

  const ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.sentiment,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'sender': sender,
      'text': text,
      'sentiment': sentiment,
      'timestamp': timestamp,
    };
  }

  factory ChatMessage.fromJson(String id, Map<String, dynamic> json) {
    return ChatMessage(
      id: id,
      sender: json['sender'] as String? ?? 'user',
      text: json['text'] as String? ?? '',
      sentiment: json['sentiment'] as String? ?? 'neutral',
      timestamp: json['timestamp'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  bool get isUser => sender == 'user';
  bool get isAI => sender == 'ai';

  DateTime get dateTime => DateTime.parse(timestamp);
}

/// AI Coach settings model
/// Firebase path: users/{uid}/aiCoach
class AiCoachSettings {
  final bool enabled;
  final String preferredTime; // "HH:mm" format
  final String tone; // "gentle" | "energetic" | "professional"
  final bool dailyTips;

  const AiCoachSettings({
    this.enabled = true,
    this.preferredTime = '09:00',
    this.tone = 'gentle',
    this.dailyTips = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'preferredTime': preferredTime,
      'tone': tone,
      'dailyTips': dailyTips,
    };
  }

  factory AiCoachSettings.fromJson(Map<String, dynamic> json) {
    return AiCoachSettings(
      enabled: json['enabled'] as bool? ?? true,
      preferredTime: json['preferredTime'] as String? ?? '09:00',
      tone: json['tone'] as String? ?? 'gentle',
      dailyTips: json['dailyTips'] as bool? ?? true,
    );
  }

  AiCoachSettings copyWith({
    bool? enabled,
    String? preferredTime,
    String? tone,
    bool? dailyTips,
  }) {
    return AiCoachSettings(
      enabled: enabled ?? this.enabled,
      preferredTime: preferredTime ?? this.preferredTime,
      tone: tone ?? this.tone,
      dailyTips: dailyTips ?? this.dailyTips,
    );
  }
}
