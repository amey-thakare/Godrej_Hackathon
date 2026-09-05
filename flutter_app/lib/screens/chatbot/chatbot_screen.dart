import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        '🛡️ How can I conserve ${plant.commonName}?',
        '🌱 Soil, water & propagation guide',
        '⚠️ What threats does it face in India?',
        '🐝 Ecological role & wildlife supported',
        '🌿 Traditional & medicinal uses',
        '🔍 How to identify it in the wild?',
      ];
    } else {
      _suggestedQuestions = [
        '🌱 5 steps to conserve native plants',
        '🐝 How to attract native pollinators',
        '🪴 Balcony & urban native gardening',
        '🍂 Composting & living soil guide',
        '💧 Water-wise conservation techniques',
        '🚫 Managing invasive flora (Lantana, etc.)',
        '🏞️ Western Ghats & mangrove hotspots',
        '🌳 Keystone native trees of India',
      ];
    }

    _messages.add(
      ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: plant != null
            ? 'Hello! I am your AI Botanical & Conservation Guide. I see you are inquiring about **${plant.commonName}** (*${plant.scientificName}*).\n\nAsk me about its ecological importance, propagation steps, soil & water needs, or **how you can actively help conserve it**!'
            : 'Hello! I am your Field Intelligence Botanical Guide. 🌿\n\nAsk me about **any plant species**, gardening and propagation tips, biodiversity conservation, urban greening, or managing invasive flora across India!',
        isUser: false,
        timestamp: DateTime.now(),
        plantName: plant?.commonName,
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
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
        history: _messages,
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
              text: 'The Botanical Guide encountered a connection issue. Please check your network or try again.',
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

  void _clearChat() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF142018),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppTheme.surfaceBorder),
        ),
        title: Text(
          'Clear Conversation?',
          style: GoogleFonts.syne(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'This will reset your current chat session with the Botanical Guide.',
          style: GoogleFonts.dmSans(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.sageText)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.accentLime,
              foregroundColor: AppTheme.darkBackground,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _messages.clear();
                final plant = widget.initialPlant;
                _messages.add(
                  ChatMessage(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    text: plant != null
                        ? 'Session reset. Inquiring about **${plant.commonName}** (*${plant.scientificName}*). How can I help you conserve or understand this plant?'
                        : 'Session reset. What plant, gardening topic, or conservation practice would you like to explore?',
                    isUser: false,
                    timestamp: DateTime.now(),
                    plantName: plant?.commonName,
                  ),
                );
              });
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  Widget _renderFormattedText(String text, bool isUser) {
    final lines = text.split('\n');
    final widgets = <Widget>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trimRight();
      if (line.isEmpty) {
        widgets.add(const SizedBox(height: 6));
        continue;
      }

      // Headings
      if (line.startsWith('### ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Text(
              line.substring(4),
              style: GoogleFonts.syne(
                color: AppTheme.accentLime,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      } else if (line.startsWith('## ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 4),
            child: Text(
              line.substring(3),
              style: GoogleFonts.syne(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      } else if (line.startsWith('# ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 6),
            child: Text(
              line.substring(2),
              style: GoogleFonts.syne(
                color: AppTheme.accentLime,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      } else if (line.startsWith('• ') || line.startsWith('- ') || line.startsWith('* ')) {
        // Bullet point
        final content = line.substring(2);
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 6, right: 8),
                  child: Icon(Icons.circle, size: 5, color: AppTheme.accentLime),
                ),
                Expanded(
                  child: _parseInlineMarkdown(content, isUser),
                ),
              ],
            ),
          ),
        );
      } else if (RegExp(r'^\d+\.\s').hasMatch(line)) {
        // Numbered list
        final match = RegExp(r'^(\d+\.)\s(.*)').firstMatch(line);
        if (match != null) {
          final number = match.group(1)!;
          final content = match.group(2)!;
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 22,
                    child: Text(
                      number,
                      style: const TextStyle(
                        color: AppTheme.accentLime,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _parseInlineMarkdown(content, isUser),
                  ),
                ],
              ),
            ),
          );
        } else {
          widgets.add(_parseInlineMarkdown(line, isUser));
        }
      } else {
        // Normal paragraph line
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: _parseInlineMarkdown(line, isUser),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _parseInlineMarkdown(String text, bool isUser) {
    final parts = text.split(RegExp(r'(\*\*[^*]+\*\*|\*[^*]+\*)'));
    final spans = <TextSpan>[];

    for (final part in parts) {
      if (part.startsWith('**') && part.endsWith('**') && part.length > 4) {
        spans.add(
          TextSpan(
            text: part.substring(2, part.length - 2),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      } else if (part.startsWith('*') && part.endsWith('*') && part.length > 2) {
        spans.add(
          TextSpan(
            text: part.substring(1, part.length - 1),
            style: const TextStyle(
              fontStyle: FontStyle.italic,
              color: AppTheme.accentLime,
            ),
          ),
        );
      } else {
        spans.add(
          TextSpan(
            text: part,
            style: TextStyle(
              color: isUser ? AppTheme.textSecondary : const Color(0xFFD4E6D4),
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
            // Top Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                border: Border(
                  bottom: BorderSide(
                    color: AppTheme.accentLime.withValues(alpha: 0.1),
                  ),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.sageText),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.initialPlant != null
                              ? widget.initialPlant!.commonName
                              : 'AI Botanical & Conservation Guide',
                          style: GoogleFonts.syne(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppTheme.accentLime,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.initialPlant != null
                                  ? 'Curated Field Context • Active Conservation'
                                  : 'Universal Botanical Intelligence',
                              style: GoogleFonts.dmSans(
                                color: AppTheme.sageText,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, color: AppTheme.sageText, size: 20),
                    tooltip: 'Reset Conversation',
                    onPressed: _clearChat,
                  ),
                  if (widget.initialPlant != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        widget.initialPlant!.imageUrl ??
                            'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=100',
                        width: 34,
                        height: 34,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.eco, color: AppTheme.accentLime),
                      ),
                    ),
                ],
              ),
            ),

            // Plant Context Pill if plant is active
            if (widget.initialPlant != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                color: const Color(0x18A8E63D),
                child: Row(
                  children: [
                    const Icon(Icons.eco_rounded, size: 14, color: AppTheme.accentLime),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Focusing on ${widget.initialPlant!.commonName} (${widget.initialPlant!.scientificName}) • ${widget.initialPlant!.conservationStatus}',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: AppTheme.accentLime,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                    child: Column(
                      crossAxisAlignment:
                          msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment:
                              msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!msg.isUser) ...[
                              Container(
                                width: 30,
                                height: 30,
                                margin: const EdgeInsets.only(right: 8, top: 2),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF243B24),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.eco, color: AppTheme.accentLime, size: 15),
                              ),
                            ],
                            Flexible(
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                                decoration: BoxDecoration(
                                  color: msg.isUser
                                      ? const Color(0x28A8E63D)
                                      : const Color(0xFF142018),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: msg.isUser
                                        ? const Color(0x40A8E63D)
                                        : const Color(0x336B8F6B),
                                  ),
                                ),
                                child: _renderFormattedText(msg.text, msg.isUser),
                              ),
                            ),
                          ],
                        ),
                        if (!msg.isUser && index != 0)
                          Padding(
                            padding: const EdgeInsets.only(left: 38, top: 4),
                            child: InkWell(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: msg.text));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Botanical advice copied to clipboard'),
                                    duration: Duration(seconds: 2),
                                    backgroundColor: Color(0xFF243B24),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.copy_rounded, size: 12, color: AppTheme.sageText),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Copy advice',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 10,
                                        color: AppTheme.sageText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
                        color: Color(0xFF2D4A2D),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.eco, color: AppTheme.accentLime, size: 14),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF142018),
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
                            'Consulting Botanical & Conservation Guide...',
                            style: TextStyle(color: AppTheme.accentLime, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Suggestions Chips
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
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF142018),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0x596B8F6B)),
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
            const SizedBox(height: 8),

            // Input Bar
            Container(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF142018),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.surfaceBorder),
                      ),
                      child: TextField(
                        controller: _textController,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: widget.initialPlant != null
                              ? 'Ask about ${widget.initialPlant!.commonName} or conservation...'
                              : 'Ask about any plant, gardening, or conservation...',
                          hintStyle: const TextStyle(color: AppTheme.sageText, fontSize: 13),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.send_rounded, color: AppTheme.accentLime),
                            onPressed: () => _handleSubmitted(_textController.text),
                          ),
                        ),
                        onSubmitted: _handleSubmitted,
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
