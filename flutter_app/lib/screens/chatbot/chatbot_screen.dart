import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/chat_message.dart';
import '../../models/plant.dart';
import '../../services/chat_service.dart';
import '../../theme/app_theme.dart';

class ChatbotScreen extends StatefulWidget {
  final Plant? initialPlant;

  const ChatbotScreen({super.key, this.initialPlant});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;

  late final List<String> _suggestedQuestions;

  @override
  void initState() {
    super.initState();

    final plant = widget.initialPlant;
    if (plant != null) {
      _suggestedQuestions = [
        'Why is ${plant.commonName} important?',
        'What threats does it face?',
        'How can I help conserve it?',
        'How to identify in the wild?',
      ];
    } else {
      _suggestedQuestions = [
        'What plants are endangered?',
        'Tell me about Western Ghats flora',
        'Best time to spot orchids in India?',
        'What are keystone species in India?',
      ];
    }

    _messages.add(
      ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: plant != null
            ? 'Hello! I am your Botanical Guide, powered by **Gemini AI**. I see you are inquiring about **${plant.commonName}** (*${plant.scientificName}*). What ecological role, habitat detail, or conservation action would you like to explore?'
            : 'Hello! I am your Field Intelligence Botanical Guide. Ask me anything about India\'s native plant species, Western Ghats flora, ecological restoration, or species identification. 🌿',
        isUser: false,
        timestamp: DateTime.now(),
        plantName: plant?.commonName,
      ),
    );
  }

  Future<void> _handleSubmitted(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _isSending) return;

    _textController.clear();

    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: trimmed,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMsg);
      _isSending = true;
    });

    _scrollToBottom();

    try {
      final replyText = await ChatService.sendMessage(
        message: trimmed,
        plantId: widget.initialPlant?.id,
      );

      final botMsg = ChatMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        text: replyText,
        isUser: false,
        timestamp: DateTime.now(),
        plantName: widget.initialPlant?.commonName,
      );

      if (mounted) {
        setState(() {
          _messages.add(botMsg);
          _isSending = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(
            ChatMessage(
              id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
              text: 'The Botanical Guide is operating in offline mode. Please ensure the backend server is running.',
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
          _isSending = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _renderFormattedText(String text, bool isUser) {
    final parts = text.split(RegExp(r'(\*\*[^*]+\*\*|\*[^*]+\*)'));
    final spans = <TextSpan>[];

    for (final part in parts) {
      if (part.startsWith('**') && part.endsWith('**')) {
        spans.add(
          TextSpan(
            text: part.substring(2, part.length - 2),
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        );
      } else if (part.startsWith('*') && part.endsWith('*')) {
        spans.add(
          TextSpan(
            text: part.substring(1, part.length - 1),
            style: const TextStyle(fontStyle: FontStyle.italic, color: AppTheme.accentLime),
          ),
        );
      } else {
        spans.add(
          TextSpan(
            text: part,
            style: TextStyle(
              color: isUser ? AppTheme.textSecondary : const Color(0xFFE2E8F0),
              height: 1.45,
            ),
          ),
        );
      }
    }

    return RichText(
      text: TextSpan(
        children: spans,
        style: GoogleFonts.dmSans(fontSize: 13.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Ergonomic Header Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xF2070E09),
                border: Border(
                  bottom: BorderSide(
                    color: AppTheme.accentLime.withValues(alpha: 0.15),
                  ),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Botanical Guide',
                          style: GoogleFonts.syne(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              'Powered by Gemini AI',
                              style: GoogleFonts.dmSans(
                                color: AppTheme.sageText,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppTheme.accentLime,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (widget.initialPlant != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        widget.initialPlant!.imageUrl ?? 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=100',
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.eco, color: AppTheme.accentLime),
                      ),
                    ),
                ],
              ),
            ),

            // Messages Stream
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      mainAxisAlignment:
                          msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!msg.isUser) ...[
                          Container(
                            width: 34,
                            height: 34,
                            margin: const EdgeInsets.only(right: 8, top: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF132A1C),
                              shape: BoxShape.circle,
                              border: Border.all(color: AppTheme.accentLime.withValues(alpha: 0.3)),
                            ),
                            child: const Icon(Icons.eco_rounded, color: AppTheme.accentLime, size: 18),
                          ),
                        ],
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: msg.isUser
                                  ? AppTheme.accentLime.withValues(alpha: 0.15)
                                  : const Color(0xD9070E09),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: msg.isUser
                                    ? AppTheme.accentLime.withValues(alpha: 0.4)
                                    : AppTheme.surfaceBorder,
                              ),
                            ),
                            child: _renderFormattedText(msg.text, msg.isUser),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Thinking Indicator
            if (_isSending)
              Padding(
                padding: const EdgeInsets.only(left: 20, bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: Color(0xFF132A1C),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.eco, color: AppTheme.accentLime, size: 14),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.surfaceBorder),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.accentLime,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Consulting Gemini AI Guide...',
                            style: TextStyle(color: AppTheme.accentLime, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Suggestions Chips (Scrollable, Thumb-accessible)
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _suggestedQuestions.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final text = _suggestedQuestions[index];
                  return InkWell(
                    onTap: () => _handleSubmitted(text),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xD9070E09),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.accentLime.withValues(alpha: 0.25)),
                      ),
                      child: Text(
                        text,
                        style: GoogleFonts.dmSans(
                          color: AppTheme.sageText,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),

            // ERGONOMIC THUMB INPUT BAR
            Container(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xF5070E09),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: AppTheme.accentLime.withValues(alpha: 0.3),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: _textController,
                              style: const TextStyle(color: Colors.white, fontSize: 14.5),
                              decoration: const InputDecoration(
                                hintText: 'Ask about any native plant...',
                                hintStyle: TextStyle(color: AppTheme.sageText, fontSize: 13.5),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              onSubmitted: _handleSubmitted,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Material(
                              color: AppTheme.accentLime,
                              shape: const CircleBorder(),
                              child: InkWell(
                                onTap: () => _handleSubmitted(_textController.text),
                                customBorder: const CircleBorder(),
                                child: const Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: Icon(
                                    Icons.send_rounded,
                                    color: Color(0xFF070E09),
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
