import 'package:flutter/material.dart';
import 'config/api_config.dart';
import 'screens/main_navigation_screen.dart';
import 'theme/app_theme.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiConfig.init();
  runApp(
    const ProviderScope(
      child: FieldIntelligenceApp(),
    ),
  );
}

class FieldIntelligenceApp extends StatelessWidget {
  const FieldIntelligenceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Field Intelligence - Native Plants',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainNavigationScreen(),
    );
  }
}
