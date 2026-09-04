import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'catalog/catalog_screen.dart';
import 'chatbot/chatbot_screen.dart';
import 'flora_dex/flora_dex_screen.dart';
import 'home/home_screen.dart';
import 'scanner/scanner_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _onNavigateTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    switch (_currentIndex) {
      case 1:
        body = const ScannerScreen();
        break;
      case 2:
        body = const CatalogScreen();
        break;
      case 3:
        body = FloraDexScreen(
          onGoScan: () => _onNavigateTab(1),
          onOpenChatbot: () => _onNavigateTab(4),
        );
        break;
      case 4:
        body = const ChatbotScreen();
        break;
      case 0:
      default:
        body = HomeScreen(
          onNavigateTab: _onNavigateTab,
          onOpenScanner: () => _onNavigateTab(1),
        );
        break;
    }

    final tabs = [
      {'label': 'Home', 'icon': Icons.home_rounded, 'outlined': Icons.home_outlined},
      {'label': 'Scan', 'icon': Icons.center_focus_strong_rounded, 'outlined': Icons.center_focus_weak_rounded},
      {'label': 'Catalog', 'icon': Icons.auto_stories_rounded, 'outlined': Icons.auto_stories_outlined},
      {'label': 'Flora Dex', 'icon': Icons.catching_pokemon, 'outlined': Icons.catching_pokemon_outlined},
      {'label': 'Chat', 'icon': Icons.chat_bubble_rounded, 'outlined': Icons.chat_bubble_outline_rounded},
    ];

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: body,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(
            top: BorderSide(
              color: AppTheme.surfaceBorder,
              width: 1.2,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF15803D).withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(tabs.length, (index) {
                final isActive = _currentIndex == index;
                final tab = tabs[index];
                return InkWell(
                  onTap: () => _onNavigateTab(index),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isActive ? (tab['icon'] as IconData) : (tab['outlined'] as IconData),
                          color: isActive ? AppTheme.accentLime : const Color(0xFF64748B),
                          size: 24,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          tab['label'] as String,
                          style: TextStyle(
                            color: isActive ? AppTheme.accentLime : const Color(0xFF64748B),
                            fontSize: 10,
                            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isActive ? AppTheme.accentLime : Colors.transparent,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
