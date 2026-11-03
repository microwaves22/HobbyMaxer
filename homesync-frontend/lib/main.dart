import 'package:flutter/material.dart';

import 'views/onboarding/onboarding_interests_screen.dart';

void main() {
  runApp(const HomeSyncApp());
}

/// Minimal app entry. Home is the onboarding interests screen (Step 1 of 2)
/// until onboarding navigation is built out.
class HomeSyncApp extends StatelessWidget {
  const HomeSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'HomeSync',
      debugShowCheckedModeBanner: false,
      home: OnboardingInterestsScreen(),
    );
  }
}
