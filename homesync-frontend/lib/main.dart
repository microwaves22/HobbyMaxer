import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'views/onboarding/splash_screen.dart';

// NOTE (2026-11-02): this entry file was reconstructed during the Family
// calendars delivery after the previous main.dart was accidentally
// overwritten. It wires the canonical pieces only: the shared AppTheme and
// the 01 Splash screen as the launch route. If the original entry did more
// (e.g. session bootstrap), restore that here.
void main() => runApp(const HomeSyncApp());

class HomeSyncApp extends StatelessWidget {
  const HomeSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HomeSync',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: const SplashScreen(),
    );
  }
}
