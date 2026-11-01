import 'package:flutter/material.dart';

import '../../core/widgets/liquid_glass_card.dart';
import 'focus_areas_screen.dart';
import 'widgets/homesync_logo.dart';

/// Greeting view with the brand, tagline, and a [Get Started] button.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Center(child: HomeSyncLogo(size: 104)),
              const SizedBox(height: 24),
              Text(
                'Welcome to HomeSync',
                style: text.displayLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Plan. Share. Grow Together.',
                style: text.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              LiquidGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('One home, one plan', style: text.titleLarge),
                    const SizedBox(height: 8),
                    Text(
                      'Coordinate calendars, share chores, and celebrate '
                      'wins together — for kids, teens, and parents.',
                      style: text.bodyMedium,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const FocusAreasScreen(),
                  ),
                ),
                child: const Text('Get Started'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
