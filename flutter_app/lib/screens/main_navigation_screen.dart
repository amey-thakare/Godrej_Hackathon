import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/glass/glass_container.dart';
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
      {'label': 'Home', 'icon': Icons.eco_rounded, 'outlined': Icons.eco_outlined},
      {'label': 'Scan', 'icon': Icons.center_focus_strong_rounded, 'outlined': Icons.center_focus_weak_rounded},
      {'label': 'Explore', 'icon': Icons.auto_stories_rounded, 'outlined': Icons.auto_stories_outlined},
      {'label': 'My Flora', 'icon': Icons.collections_bookmark_rounded, 'outlined': Icons.collections_bookmark_outlined},
      {'label': 'AI Guide', 'icon': Icons.auto_awesome_rounded, 'outlined': Icons.auto_awesome_outlined},
    ];

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      extendBody: true,
      body: body,
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
          child: GlassContainer(
            borderRadius: AppTheme.radiusXL,
            opacityColor: Colors.white,
            opacity: 0.92,
            blur: AppTheme.blurMedium,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.6),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryForest.withValues(alpha: 0.10),
                blurRadius: 28,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
            ],
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(tabs.length, (index) {
                final isActive = _currentIndex == index;
                final tab = tabs[index];
                final isScanTab = index == 1;

                if (isScanTab) {
                  return GestureDetector(
                    onTap: () => _onNavigateTab(1),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primaryForest,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryForest.withValues(alpha: 0.35),
                            blurRadius: 14,
                            spreadRadius: 1,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  );
                }

                return Expanded(
                  child: InkWell(
                    onTap: () => _onNavigateTab(index),
                    borderRadius: BorderRadius.circular(18),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppTheme.softSage.withValues(alpha: 0.75)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isActive ? (tab['icon'] as IconData) : (tab['outlined'] as IconData),
                            color: isActive ? AppTheme.primaryForest : AppTheme.textSecondary,
                            size: 20,
                          ),
                          const SizedBox(height: 2),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              tab['label'] as String,
                              style: TextStyle(
                                color: isActive ? AppTheme.primaryForest : AppTheme.textSecondary,
                                fontSize: 10,
                                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                                letterSpacing: -0.1,
                              ),
                            ),
                          ),
                        ],
                      ),
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
