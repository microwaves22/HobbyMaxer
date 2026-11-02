import 'dart:async';

import 'package:flutter/material.dart';

import 'welcome_screen.dart';
import 'widgets/homesync_logo.dart';

/// Launch screen. Shows the brand briefly, then moves to [WelcomeScreen].
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const HomeSyncLogo(),
              const SizedBox(height: 24),
              Text('HomeSync', style: text.displayLarge),
              const SizedBox(height: 8),
              Text(
                'Plan. Share. Grow Together.',
                style: text.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
