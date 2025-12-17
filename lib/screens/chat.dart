import 'package:flutter/material.dart';
import 'package:health_care/theme/theme.dart';
import 'package:health_care/models/mood_model.dart';
import 'package:health_care/services/firebase_gemini_service.dart';
import 'package:provider/provider.dart';

// --- Veri Modeli ---
enum ChatMessageType { user, bot }

class ChatMessage {
  final String text;
  final ChatMessageType type;

  ChatMessage({required this.text, required this.type});
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;

  // 🔥 Firebase Gemini Service (NEW)
  final FirebaseGeminiService _geminiService = FirebaseGeminiService();

  @override
  void initState() {
    super.initState();
    _initializeGemini();
    // Sayfa açıldığında ilk karşılama mesajını gönderelim
    WidgetsBinding.instance.addPostFrameCallback((_) => _sendInitialMessage());
  }

  void _initializeGemini() {
    try {
      // Get user's mood for system instruction
      final moodModel = Provider.of<MoodModel>(context, listen: false);
      final selectedMoodIndex = moodModel.selectedMoodIndex;
      
      // 🔥 Initialize Firebase Gemini Service with mood-based system instruction
      _geminiService.initialize(selectedMoodIndex: selectedMoodIndex);
    } catch (e) {
      debugPrint('❌ Error initializing Gemini: $e');
      // Continue anyway - fallback will be used if AI fails
    }
  }

  // --- Metotlar ---

  void _sendInitialMessage() {
    // MoodModel'i sadece okuma modunda (listen: false) kullanmak initState'te güvenlidir.
    final moodModel = Provider.of<MoodModel>(context, listen: false);
    final selectedMoodIndex = moodModel.selectedMoodIndex;
    final moodLabel = moodModel.getMoodLabel(selectedMoodIndex);

    // 🔥 Generate initial message using Firebase Gemini Service
    final initialPrompt = _geminiService.generateInitialMessage(
      selectedMoodIndex: selectedMoodIndex,
      moodLabel: moodLabel,
    );

    setState(() {
      _messages.insert(
        0,
        ChatMessage(text: initialPrompt, type: ChatMessageType.bot),
      );
    });
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;

    _textController.clear();
    setState(() {
      _messages.insert(0, ChatMessage(text: text, type: ChatMessageType.user));
    });

    _sendMessage(text);
  }

  Future<void> _sendMessage(String userMessage) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 🔥 Send message to Gemini via Firebase Gemini Service
      final botResponseText = await _geminiService.sendMessage(userMessage);

      if (mounted) {
        setState(() {
          _messages.insert(
            0,
            ChatMessage(text: botResponseText, type: ChatMessageType.bot),
          );
        });
      }
    } catch (e) {
      // 🛡️ This should never happen due to internal error handling
      // But as extra safety, use fallback message
      debugPrint('❌ Unexpected error in chat: $e');
      
      if (mounted) {
        setState(() {
          _messages.insert(
            0,
            ChatMessage(
              text: "Bugün kendine küçük bir iyilik yapmayı unutma 🌿",
              type: ChatMessageType.bot,
            ),
          );
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // --- Arayüz Yapıcılar ---

  Widget _buildTextComposer() {
    // Renkleri theme.dart'tan çekiyoruz
    final Color greyText = const Color(0xFF757575);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Flexible(
            child: TextField(
              controller: _textController,
              onSubmitted: _handleSubmitted,
              decoration: InputDecoration.collapsed(
                hintText: 'Mesajınızı yazın...',
                hintStyle: TextStyle(color: greyText.withValues(alpha: 0.7)),
              ),
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            child: IconButton(
              icon: Icon(Icons.send, color: Theme.of(context).primaryColor),
              onPressed: _isLoading
                  ? null
                  : () => _handleSubmitted(_textController.text),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // MoodModel'den ruh hali etiketini çekmek için (Appbar'da kullanmak için)
    // listen: false kullanıldığı için bu, performans sorununa neden olmaz.
    final moodModel = Provider.of<MoodModel>(context, listen: false);
    final selectedMoodIndex = moodModel.selectedMoodIndex;
    final moodLabel = moodModel.getMoodLabel(selectedMoodIndex);

    // BÜYÜK GÜNCELLEME: Scaffold eklendi ve performans için ayar yapıldı.
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Color(0xFF009000),
        foregroundColor: Colors.white,
        title: Text(
          'AI Asistanı - $moodLabel Modu',
          style: TextStyle(fontSize: 22, color: Colors.white),
        ),
      ),
      // Klavye açılıp kapanırken takılmaları azaltmak için önerilen ayar.
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          Flexible(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              reverse: true,
              itemBuilder: (_, int index) =>
                  _MessageBubble(message: _messages[index]),
              itemCount: _messages.length,
            ),
          ),

          if (_isLoading)
            LinearProgressIndicator(color: Theme.of(context).primaryColor),

          const Divider(height: 1.0),

          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }
}

// --- Mesaj Balonu Widget'ı ---
class _MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.type == ChatMessageType.user;
    final alignment = isUser
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;
    final color = isUser ? Theme.of(context).primaryColor : lightCardColor;
    final textColor = isUser
        ? Colors.white
        : Theme.of(context).textTheme.bodyMedium?.color;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(15.0),
                topRight: const Radius.circular(15.0),
                bottomLeft: Radius.circular(isUser ? 15.0 : 0.0),
                bottomRight: Radius.circular(isUser ? 0.0 : 15.0),
              ),
              boxShadow: isUser
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        blurRadius: 4,
                      ),
                    ],
            ),
            child: Text(
              message.text,
              style: TextStyle(color: textColor, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
