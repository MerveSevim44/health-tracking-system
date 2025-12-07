import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:health_care/widgets/theme.dart';
import 'package:health_care/models/mood_model.dart';
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

  // Gerçek API URL'si buraya gelmelidir. (Örn: Gemini API)
  static const String _geminiApiUrl = 'YOUR_API_ENDPOINT_HERE';
  static const String _apiKey = 'YOUR_API_KEY_HERE';

  // Ruha Göre Prompt Haritası
  final Map<int, String> _moodPrompts = {
    0: "Kullanıcı kendini **Mutlu** hissettiğini belirtti. Cevapların kutlayıcı, neşeli ve pozitif enerjiyi sürdüren bir tonda olmalıdır. Başarısını veya pozitifliğini tebrik et.",
    1: "Kullanıcı kendini **Sakin** hissettiğini belirtti. Cevapların huzurlu, dinlendirici ve meditasyonu veya şimdiki anı destekleyen bir tonda olmalıdır. Derin düşüncelere yönlendir.",
    2: "Kullanıcı kendini **Üzgün** hissettiğini belirtti. Cevapların son derece empatik, destekleyici ve yargılayıcı olmayan bir tonda olmalıdır. Onaylayıcı dil kullan (örneğin, 'Hislerinin tamamen doğal olduğunu anlıyorum.'). Çözüm sunmak yerine dinlemeye odaklan.",
    3: "Kullanıcı kendini **Kaygılı** hissettiğini belirtti. Cevapların güven verici, sakinleştirici ve somut başa çıkma stratejilerine (nefes egzersizi, topraklanma teknikleri) odaklanan bir tonda olmalıdır. Kısa ve net cümleler kur, uzun cevaplardan kaçın.",
    4: "Kullanıcı kendini **Kızgın** hissettiğini belirtti. Cevapların sabırlı, nötr ve duyguyu kabul eden bir tonda olmalıdır. Sakinleşmesine yardımcı olacak adımlar önerebilir veya sadece duygusunu boşaltmasına izin verebilirsin. Asla savunmacı veya itirazcı olma.",
  };


  @override
  void initState() {
    super.initState();
    // Sayfa açıldığında ilk karşılama mesajını gönderelim
    WidgetsBinding.instance.addPostFrameCallback((_) => _sendInitialMessage());
  }

  // --- Metotlar ---

  void _sendInitialMessage() {
    // MoodModel'i sadece okuma modunda (listen: false) kullanmak initState'te güvenlidir.
    final moodModel = Provider.of<MoodModel>(context, listen: false);
    final selectedMoodIndex = moodModel.selectedMoodIndex; // MoodModel'den gelen int

    String initialPrompt = "";

    // Ruha göre karşılama metni
    switch (selectedMoodIndex) {
      case 0: // Mutlu
        initialPrompt = "Harika! Enerjin bana da geçti! ${moodModel.getMoodLabel(selectedMoodIndex)} hissetmene sevindim. Bugün ne hakkında konuşmak istersin?";
        break;
      case 2: // Üzgün
        initialPrompt = "Merhaba. Bugün kendini ${moodModel.getMoodLabel(selectedMoodIndex)} hissediyormuşsun. Unutma, burası yargılanmadan her şeyi paylaşabileceğin güvenli bir alan. Seni dinlemek için buradayım, nasılsın?";
        break;
      case 3: // Kaygılı
        initialPrompt = "Merhaba, ${moodModel.getMoodLabel(selectedMoodIndex)} hissettiğini görüyorum. Bir nefes al. Şu an ne seni en çok meşgul ediyor? Eğer konuşmak zorsa, sadece 'Buradayım' yazabilirsin.";
        break;
      default:
        initialPrompt = "Merhaba! ${moodModel.getMoodLabel(selectedMoodIndex)} hissettiğini görüyorum. Seni dinliyorum. Bugün konuşmak istediğin konu ne?";
    }

    setState(() {
      _messages.insert(0, ChatMessage(text: initialPrompt, type: ChatMessageType.bot));
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

    // --- 1. Kullanıcının Ruh Halini ve Prompt'u Al ---
    final moodModel = Provider.of<MoodModel>(context, listen: false);
    final selectedMoodIndex = moodModel.selectedMoodIndex;

    // Ruha özel sistem talimatını al
    final systemPrompt = _moodPrompts[selectedMoodIndex] ??
        "Sen bir destekleyici yapay zeka asistansın. Daima nazik, empatik ve yargılayıcı olmayan bir tonda cevap ver.";

    // --- 2. API İstek Gövdesinin Hazırlanması (Örnek: Gemini API) ---
    try {
      final response = await http.post(
        Uri.parse(_geminiApiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'contents': [
            {'role': 'system', 'parts': [{'text': systemPrompt}]},
            {'role': 'user', 'parts': [{'text': userMessage}]}
          ],
          'config': {'temperature': 0.7}
        }),
      ).timeout(const Duration(seconds: 30));

      String botResponseText;

      if (response.statusCode == 200) {
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        botResponseText = responseData['candidates'][0]['content']['parts'][0]['text'];
      } else {
        print('API Hata Kodu: ${response.statusCode}');
        botResponseText = "Üzgünüm, Yapay Zeka servisine bağlanırken bir sorun oluştu. (Hata Kodu: ${response.statusCode})";
      }

      setState(() {
        _messages.insert(0, ChatMessage(text: botResponseText, type: ChatMessageType.bot));
      });
    } catch (e) {
      setState(() {
        _messages.insert(0, ChatMessage(text: "Bir bağlantı hatası oluştu: $e", type: ChatMessageType.bot));
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
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
                hintStyle: TextStyle(color: greyText.withOpacity(0.7)),
              ),
              style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            child: IconButton(
              icon: Icon(Icons.send, color: Theme.of(context).primaryColor),
              onPressed: _isLoading ? null : () => _handleSubmitted(_textController.text),
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
        title: Text('AI Asistanı - $moodLabel Modu',
          style: TextStyle(
            fontSize: 22,
            color: Colors.white,
          ),
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
              itemBuilder: (_, int index) => _MessageBubble(message: _messages[index]),
              itemCount: _messages.length,
            ),
          ),

          if (_isLoading) LinearProgressIndicator(color: Theme.of(context).primaryColor),

          const Divider(height: 1.0),

          Container(
            decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
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
    final alignment = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final color = isUser ? Theme.of(context).primaryColor : lightCardColor;
    final textColor = isUser ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(15.0),
                topRight: const Radius.circular(15.0),
                bottomLeft: Radius.circular(isUser ? 15.0 : 0.0),
                bottomRight: Radius.circular(isUser ? 0.0 : 15.0),
              ),
              boxShadow: isUser ? null : [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4)],
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