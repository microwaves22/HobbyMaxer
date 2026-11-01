import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'views/onboarding/splash_screen.dart';

void main() {
  runApp(const HomeSyncApp());
}

/// HomeSync root widget.
///
/// Light theme by default; Teen Mode picks up the dark theme via the
/// system brightness until a per-profile toggle is added.
class HomeSyncApp extends StatelessWidget {
  const HomeSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HomeSync',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}
