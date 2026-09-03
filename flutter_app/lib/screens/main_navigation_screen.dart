import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'catalog/catalog_screen.dart';
import 'chatbot/chatbot_screen.dart';
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
    final List<Widget> screens = [
      HomeScreen(
        onNavigateTab: _onNavigateTab,
        onOpenScanner: () => _onNavigateTab(1),
      ),
      const ScannerScreen(),
      const CatalogScreen(),
      const ChatbotScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavigateTab,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home, color: AppTheme.accentLime),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            activeIcon: Icon(Icons.qr_code_scanner, color: AppTheme.accentLime),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book, color: AppTheme.accentLime),
            label: 'Catalog',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.psychology_outlined),
            activeIcon: Icon(Icons.psychology, color: AppTheme.accentLime),
            label: 'Guide',
          ),
        ],
      ),
    );
  }
}
