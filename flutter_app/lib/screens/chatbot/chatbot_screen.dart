import 'package:flutter/material.dart';
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

  final List<String> _suggestedQuestions = [
    'Why is this plant important?',
    'Is this plant native to India?',
    'What makes this plant special?',
    'What threats does it face?',
    'How can I help conserve it?',
    'How can I identify it in the wild?',
  ];

  @override
  void initState() {
    super.initState();
    _messages.add(
      ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: widget.initialPlant != null
            ? 'Hello! I am your AI Botanical Guide. How can I help you learn more about **${widget.initialPlant!.commonName}** (*${widget.initialPlant!.scientificName}*)?'
            : 'Hello! I am your AI Botanical Guide specializing in India\'s native flora. Ask me any question about plant identification, ecological roles, or conservation efforts.',
        isUser: false,
        timestamp: DateTime.now(),
        plantName: widget.initialPlant?.commonName,
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

      setState(() {
        _messages.add(botMsg);
        _isSending = false;
      });
    } catch (e) {
      final errorMsg = ChatMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        text: 'Botanical Guide is temporarily operating offline or experiencing network delay.',
        isUser: false,
        timestamp: DateTime.now(),
      );
      setState(() {
        _messages.add(errorMsg);
        _isSending = false;
      });
    }

    _scrollToBottom();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('AI Botanical Guide'),
            Text(
              widget.initialPlant != null
                  ? 'Context: ${widget.initialPlant!.commonName}'
                  : 'India Native Biodiversity Assistant',
              style: const TextStyle(
                color: AppTheme.accentLime,
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(vertical: 6),
              color: AppTheme.surfaceCard,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _suggestedQuestions.length,
                itemBuilder: (context, index) {
                  final q = _suggestedQuestions[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ActionChip(
                      label: Text(
                        q,
                        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12),
                      ),
                      backgroundColor: AppTheme.primaryForest.withValues(alpha: 0.3),
                      side: const BorderSide(color: AppTheme.surfaceBorder),
                      onPressed: () => _handleSubmitted(q),
                    ),
                  );
                },
              ),
            ),

            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return _buildMessageBubble(msg);
                },
              ),
            ),

            if (_isSending)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.accentLime,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'AI Guide is searching botanical context...',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppTheme.surfaceCard,
                border: Border(top: BorderSide(color: AppTheme.surfaceBorder)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      style: const TextStyle(color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        hintText: widget.initialPlant != null
                            ? 'Ask about ${widget.initialPlant!.commonName}...'
                            : 'Ask any botanical question...',
                        hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
                        filled: true,
                        fillColor: AppTheme.darkBackground,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: _handleSubmitted,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send, color: AppTheme.accentLime),
                    onPressed: () => _handleSubmitted(_textController.text),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          color: msg.isUser ? AppTheme.primaryForest : AppTheme.surfaceCard,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(msg.isUser ? 16 : 4),
            bottomRight: Radius.circular(msg.isUser ? 4 : 16),
          ),
          border: Border.all(
            color: msg.isUser ? AppTheme.accentLime.withValues(alpha: 0.3) : AppTheme.surfaceBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!msg.isUser) ...[
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.psychology, size: 14, color: AppTheme.accentLime),
                  SizedBox(width: 4),
                  Text(
                    'Botanical Guide',
                    style: TextStyle(
                      color: AppTheme.accentLime,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
            ],
            Text(
              msg.text,
              style: TextStyle(
                color: msg.isUser ? Colors.white : AppTheme.textPrimary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
