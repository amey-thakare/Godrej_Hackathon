import 'package:flutter/material.dart';
import '../../models/chat_message.dart';
import '../../models/plant.dart';
import '../../services/chat_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass/glass_container.dart';
import '../../widgets/glass/glass_icon_button.dart';

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
        'How do I identify ${plant.commonName}?',
        'Is it native to my region?',
        'Why is it ecologically important?',
        'Can I grow it at home?',
      ];
    } else {
      _suggestedQuestions = [
        'What species are native to Western Ghats?',
        'How do I identify native Banyan trees?',
        'Why are keystone species vital in India?',
        'How can I restore native flora?',
      ];
    }

    _messages.add(
      ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: plant != null
            ? 'Welcome. I am your AI Botanical Assistant. I see you are inquiring about **${plant.commonName}** (*${plant.scientificName}*). How can I assist your field exploration?'
            : 'Welcome. I am your AI Botanical Assistant for India\'s native flora and biodiversity. What would you like to explore today?',
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
              text: 'Operating in offline mode. Please ensure backend service is connected.',
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
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
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
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        );
      } else if (part.startsWith('*') && part.endsWith('*')) {
        spans.add(
          TextSpan(
            text: part.substring(1, part.length - 1),
            style: const TextStyle(
              fontStyle: FontStyle.italic,
              color: AppTheme.accentForest,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      } else {
        spans.add(
          TextSpan(
            text: part,
            style: TextStyle(
              color: isUser ? AppTheme.textPrimary : AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        );
      }
    }

    return RichText(
      text: TextSpan(
        children: spans,
        style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w400),
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
            // Top Floating Liquid Glass Navigation Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: GlassContainer(
                borderRadius: AppTheme.radiusXL,
                opacityColor: Colors.white,
                opacity: 0.88,
                blur: AppTheme.blurMedium,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    GlassIconButton(
                      icon: Icons.arrow_back_rounded,
                      size: 38,
                      iconSize: 20,
                      onPressed: () => Navigator.maybePop(context),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'AI Botanical Assistant',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            widget.initialPlant != null
                                ? widget.initialPlant!.commonName
                                : 'India Biodiversity Intelligence',
                            style: const TextStyle(
                              color: AppTheme.accentForest,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.softSage,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.auto_awesome_rounded, size: 14, color: AppTheme.primaryForest),
                          SizedBox(width: 4),
                          Text(
                            'Gemini',
                            style: TextStyle(
                              color: AppTheme.primaryForest,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Clean Assistant Conversation Surface
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];

                  if (msg.isUser) {
                    return Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16, left: 40),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.softSage,
                          borderRadius: BorderRadius.circular(20).copyWith(
                            bottomRight: const Radius.circular(4),
                          ),
                          border: Border.all(color: AppTheme.surfaceBorder),
                        ),
                        child: _renderFormattedText(msg.text, true),
                      ),
                    );
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 20, right: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          margin: const EdgeInsets.only(right: 12, top: 2),
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryForest,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.auto_awesome_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: AppTheme.solidCardDecoration,
                            child: _renderFormattedText(msg.text, false),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Thinking State Indicator
            if (_isSending)
              Padding(
                padding: const EdgeInsets.only(left: 20, bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryForest,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 14),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Analyzing botanical data...',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

            // Suggested Prompts Horizontal Pills
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _suggestedQuestions.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final text = _suggestedQuestions[index];
                  return GlassContainer(
                    opacityColor: Colors.white,
                    opacity: 0.88,
                    blur: AppTheme.blurSmall,
                    borderRadius: AppTheme.radiusXL,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    onTap: () => _handleSubmitted(text),
                    child: Text(
                      text,
                      style: const TextStyle(
                        color: AppTheme.primaryForest,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.1,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            // Floating Liquid Glass Input Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: GlassContainer(
                height: 56,
                borderRadius: AppTheme.radiusXL,
                opacityColor: Colors.white,
                opacity: 0.90,
                blur: AppTheme.blurMedium,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Ask anything about native plants...',
                          hintStyle: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 14.5,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        onSubmitted: _handleSubmitted,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GlassIconButton(
                      icon: Icons.arrow_upward_rounded,
                      size: 40,
                      iconSize: 20,
                      opacityColor: AppTheme.primaryForest,
                      iconColor: Colors.white,
                      onPressed: () => _handleSubmitted(_textController.text),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
