import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat_models.dart';
import '../services/chat_service.dart';
import '../services/ai_coach_service.dart';
import '../theme/modern_colors.dart';
import 'dart:ui';

class ChatScreen extends StatefulWidget {
  final String? sessionId;

  const ChatScreen({super.key, this.sessionId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin {
  final ChatService _chatService = ChatService();
  final AiCoachService _aiCoachService = AiCoachService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String? _currentSessionId;
  bool _isLoading = false;
  bool _isSending = false;
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _initSession();
    
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  Future<void> _initSession() async {
    setState(() => _isLoading = true);
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      _currentSessionId = widget.sessionId ?? 
          await _chatService.getTodayCheckInSession(userId);
      
      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      print('❌ Error initializing session: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _currentSessionId == null || _isSending) return;

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    setState(() => _isSending = true);

    try {
      _messageController.clear();

      await _chatService.addMessage(
        userId: userId,
        sessionId: _currentSessionId!,
        sender: 'user',
        text: text,
        sentiment: 'neutral',
      );

      _scrollToBottom();

      // Generate AI response with Gemini (with fallback)
      // Service handles all errors and returns fallback message - never throws
      await Future.delayed(const Duration(milliseconds: 800));
      final aiResponse = await _aiCoachService.generateChatResponse(text);
      
      await _chatService.addMessage(
        userId: userId,
        sessionId: _currentSessionId!,
        sender: 'ai',
        text: aiResponse,
        sentiment: 'positive',
      );

      _scrollToBottom();
    } catch (e) {
      // 🛡️ Silent error logging - this should rarely happen (only Firebase errors)
      // AI errors are handled by service and return fallback message
      debugPrint('❌ [Chat Screen] Firebase error (silent): ${e.runtimeType}');
      
      // If Firebase fails, still try to add fallback message so user sees something
      try {
        final userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId != null && _currentSessionId != null) {
          await _chatService.addMessage(
            userId: userId,
            sessionId: _currentSessionId!,
            sender: 'ai',
            text: 'Bugün kendine küçük bir iyilik yapmayı unutma 🌿',
            sentiment: 'positive',
          );
        }
      } catch (e2) {
        // Even fallback failed - log silently, don't show error to user
        debugPrint('❌ [Chat Screen] Error adding fallback message: ${e2.runtimeType}');
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: ModernAppColors.darkBg,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Animated background
          _buildAnimatedBackground(),
          
          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(),
                
                // Messages
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: ModernAppColors.vibrantCyan,
                          ),
                        )
                      : _currentSessionId == null || userId == null
                          ? _buildEmptyState()
                          : _buildMessagesList(userId),
                ),
                
                // Input area
                _buildInputArea(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: ModernAppColors.backgroundGradient,
          ),
        ),
        AnimatedBuilder(
          animation: _floatController,
          builder: (context, child) {
            return Positioned(
              top: 200 + (_floatController.value * 50),
              left: -80,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      ModernAppColors.accentGreen.withOpacity(0.2),
                      ModernAppColors.accentGreen.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: ModernAppColors.secondaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: ModernAppColors.accentGreen.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.psychology_rounded,
              color: ModernAppColors.lightText,
              size: 26,
            ),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Health Coach',
                  style: TextStyle(
                    color: ModernAppColors.lightText,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Online',
                  style: TextStyle(
                    color: ModernAppColors.accentGreen,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(String userId) {
    return StreamBuilder<List<ChatMessage>>(
      stream: _chatService.getSessionMessages(
        userId: userId,
        sessionId: _currentSessionId!,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading messages',
              style: TextStyle(color: ModernAppColors.error),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(
              color: ModernAppColors.vibrantCyan,
            ),
          );
        }

        final messages = snapshot.data!;
        
        if (messages.isEmpty) {
          return _buildEmptyState();
        }

        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            final isUser = message.sender == 'user';
            return _buildMessageBubble(message, isUser);
          },
        );
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isUser) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                gradient: ModernAppColors.secondaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.psychology_rounded,
                color: ModernAppColors.lightText,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: isUser
                    ? ModernAppColors.primaryGradient
                    : null,
                color: isUser ? null : ModernAppColors.cardBg,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 5),
                  bottomRight: Radius.circular(isUser ? 5 : 20),
                ),
                boxShadow: [
                  ModernAppColors.cardShadow(opacity: 0.1),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: ModernAppColors.lightText,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 10),
            Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: ModernAppColors.cardBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_rounded,
                color: ModernAppColors.deepPurple,
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: ModernAppColors.secondaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.psychology_rounded,
              color: ModernAppColors.lightText,
              size: 50,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Start a conversation',
            style: TextStyle(
              color: ModernAppColors.lightText,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ask me anything about your health',
            style: TextStyle(
              color: ModernAppColors.mutedText,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            color: ModernAppColors.cardBg.withOpacity(0.95),
            border: Border(
              top: BorderSide(
                color: ModernAppColors.vibrantCyan.withOpacity(0.2),
                width: 1.5,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C2038),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: ModernAppColors.vibrantCyan.withOpacity(0.25),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: ModernAppColors.vibrantCyan.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _messageController,
                      onChanged: (value) => setState(() {}),
                      style: const TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                      ),
                      cursorColor: ModernAppColors.vibrantCyan,
                      cursorWidth: 2,
                      decoration: InputDecoration(
                        hintText: 'Mesajınızı yazın...',
                        hintStyle: TextStyle(
                          color: Color(0xFF9AA0B5),
                          fontSize: 16,
                        ),
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 0,
                          vertical: 14,
                        ),
                      ),
                      maxLines: 5,
                      minLines: 1,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty && !_isSending) {
                          _sendMessage();
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: _messageController.text.trim().isNotEmpty && !_isSending
                        ? ModernAppColors.primaryGradient
                        : null,
                    color: _messageController.text.trim().isEmpty || _isSending
                        ? const Color(0xFF2A2E40)
                        : null,
                    shape: BoxShape.circle,
                    boxShadow: _messageController.text.trim().isNotEmpty && !_isSending
                        ? [
                            BoxShadow(
                              color: ModernAppColors.vibrantCyan.withOpacity(0.5),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: _isSending
                      ? const Padding(
                          padding: EdgeInsets.all(14.0),
                          child: CircularProgressIndicator(
                            color: ModernAppColors.lightText,
                            strokeWidth: 2.5,
                          ),
                        )
                      : IconButton(
                          icon: Icon(
                            Icons.send_rounded,
                            color: _messageController.text.trim().isNotEmpty
                                ? ModernAppColors.lightText
                                : const Color(0xFF5A5E70),
                            size: 24,
                          ),
                          onPressed: _messageController.text.trim().isNotEmpty && !_isSending
                              ? _sendMessage
                              : null,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
