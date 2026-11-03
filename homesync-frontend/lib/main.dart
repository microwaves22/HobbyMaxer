import 'package:flutter/material.dart';

import 'views/calendar/calendar_screen.dart';

void main() {
  runApp(const HomeSyncApp());
}

/// Minimal app entry. Home previews the 06 Calendar screen; switch back
/// to OnboardingInterestsScreen once navigation is built out.
class HomeSyncApp extends StatelessWidget {
  const HomeSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'HomeSync',
      debugShowCheckedModeBanner: false,
      home: CalendarScreen(),
    );
  }
}
