// 📁 lib/models/chat_models.dart
// Chat mesajları ve oturum modelleri

/// Chat mesaj modeli
class ChatMessage {
  final String id;
  final String sender; // 'user' veya 'ai'
  final String text;
  final String sentiment; // 'positive', 'negative', 'neutral'
  final DateTime timestamp;

  const ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.sentiment,
    required this.timestamp,
  });

  // Firebase'e kayıt için JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender': sender,
      'text': text,
      'sentiment': sentiment,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Firebase'den okuma için
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      sender: json['sender'] as String,
      text: json['text'] as String,
      sentiment: json['sentiment'] as String? ?? 'neutral',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  // Firestore document'den okuma için
  factory ChatMessage.fromFirestore(String id, Map<String, dynamic> data) {
    return ChatMessage(
      id: id,
      sender: data['sender'] as String,
      text: data['text'] as String,
      sentiment: data['sentiment'] as String? ?? 'neutral',
      timestamp: data['timestamp'] != null
          ? DateTime.parse(data['timestamp'] as String)
          : DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'ChatMessage(id: $id, sender: $sender, text: $text, sentiment: $sentiment, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatMessage &&
        other.id == id &&
        other.sender == sender &&
        other.text == text &&
        other.sentiment == sentiment &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        sender.hashCode ^
        text.hashCode ^
        sentiment.hashCode ^
        timestamp.hashCode;
  }
}

/// Chat oturum modeli
class ChatSession {
  final String id;
  final String userId;
  final DateTime createdAt;
  final DateTime? lastMessageAt;
  final String? title;
  final int messageCount;

  const ChatSession({
    required this.id,
    required this.userId,
    required this.createdAt,
    this.lastMessageAt,
    this.title,
    this.messageCount = 0,
  });

  // Firebase'e kayıt için JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'lastMessageAt': lastMessageAt?.toIso8601String(),
      'title': title,
      'messageCount': messageCount,
    };
  }

  // Firebase'den okuma için
  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'] as String,
      userId: json['userId'] as String,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      lastMessageAt: json['lastMessageAt'] != null
          ? DateTime.parse(json['lastMessageAt'] as String)
          : null,
      title: json['title'] as String?,
      messageCount: json['messageCount'] as int? ?? 0,
    );
  }

  // Firestore document'den okuma için
  factory ChatSession.fromFirestore(String id, Map<String, dynamic> data) {
    return ChatSession(
      id: id,
      userId: data['userId'] as String,
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'] as String)
          : DateTime.now(),
      lastMessageAt: data['lastMessageAt'] != null
          ? DateTime.parse(data['lastMessageAt'] as String)
          : null,
      title: data['title'] as String?,
      messageCount: data['messageCount'] as int? ?? 0,
    );
  }

  @override
  String toString() {
    return 'ChatSession(id: $id, userId: $userId, title: $title, messageCount: $messageCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatSession &&
        other.id == id &&
        other.userId == userId &&
        other.title == title &&
        other.messageCount == messageCount;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        (title?.hashCode ?? 0) ^
        messageCount.hashCode;
  }
}

/// AI Coach ayarları modeli
class AiCoachSettings {
  final bool enabled;
  final String tone; // 'gentle', 'energetic', 'professional'
  final bool dailyTips;
  final bool moodResponses;
  final bool medicationReminders;

  const AiCoachSettings({
    this.enabled = true,
    this.tone = 'gentle',
    this.dailyTips = true,
    this.moodResponses = true,
    this.medicationReminders = true,
  });

  // Firebase'e kayıt için JSON
  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'tone': tone,
      'dailyTips': dailyTips,
      'moodResponses': moodResponses,
      'medicationReminders': medicationReminders,
    };
  }

  // Firebase'den okuma için
  factory AiCoachSettings.fromJson(Map<String, dynamic> json) {
    return AiCoachSettings(
      enabled: json['enabled'] as bool? ?? true,
      tone: json['tone'] as String? ?? 'gentle',
      dailyTips: json['dailyTips'] as bool? ?? true,
      moodResponses: json['moodResponses'] as bool? ?? true,
      medicationReminders: json['medicationReminders'] as bool? ?? true,
    );
  }

  AiCoachSettings copyWith({
    bool? enabled,
    String? tone,
    bool? dailyTips,
    bool? moodResponses,
    bool? medicationReminders,
  }) {
    return AiCoachSettings(
      enabled: enabled ?? this.enabled,
      tone: tone ?? this.tone,
      dailyTips: dailyTips ?? this.dailyTips,
      moodResponses: moodResponses ?? this.moodResponses,
      medicationReminders: medicationReminders ?? this.medicationReminders,
    );
  }

  @override
  String toString() {
    return 'AiCoachSettings(enabled: $enabled, tone: $tone, dailyTips: $dailyTips, moodResponses: $moodResponses, medicationReminders: $medicationReminders)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AiCoachSettings &&
        other.enabled == enabled &&
        other.tone == tone &&
        other.dailyTips == dailyTips &&
        other.moodResponses == moodResponses &&
        other.medicationReminders == medicationReminders;
  }

  @override
  int get hashCode {
    return enabled.hashCode ^
        tone.hashCode ^
        dailyTips.hashCode ^
        moodResponses.hashCode ^
        medicationReminders.hashCode;
  }
}
