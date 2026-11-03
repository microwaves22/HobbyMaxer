import 'package:flutter/material.dart';

import '../auth/login_screen.dart';
import 'choose_mode_screen.dart';

/// Figma "01 Splash" (node 3:2): brand, house illustration, actions.
///
/// Figma tokens are hard-coded here because they differ from the shared
/// theme (`AppColors` cream/sage/ink predate this design). Do not move
/// them into the theme files: no other screen uses these values.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  // Figma tokens (screen-only, see class doc).
  static const Color _cream = Color(0xFFFBF7EF);
  static const Color _ink = Color(0xFF2B3A2B);
  static const Color _mute = Color(0xFF7C877A);
  static const Color _sage = Color(0xFF5F7F55);
  static const Color _line = Color(0xFFE8E4D8);
  static const Color _white = Color(0xFFFFFFFF);

  /// Figma "House Illustration" export. The file lands here separately.
  static const String _houseAsset = 'assets/homePageImg.png';

  void _onGetStarted(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ChooseModeScreen()),
    );
  }

  void _onLogin(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 40,
            left: 24,
            right: 24,
            bottom: 34,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Brand.
              const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'HomeSync',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w800,
                      fontSize: 42,
                      color: _ink,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Plan. Share. Grow Together.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: _mute,
                    ),
                  ),
                ],
              ),
              // House illustration (260 x 205, aspect preserved).
              // Until homePageImg.png lands, the slot stays transparently
              // empty so layout and tests hold without a substitute image.
              SizedBox(
                width: 260,
                height: 205,
                child: Image.asset(
                  _houseAsset,
                  width: 260,
                  height: 205,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox(width: 260, height: 205),
                ),
              ),
              // Actions.
              SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 54,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x4D5E8054),
                            offset: Offset(0, 4),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () => _onGetStarted(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _sage,
                          foregroundColor: _white,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          minimumSize: const Size.fromHeight(54),
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          textStyle: const TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        child: const Text(
                          'Get Started',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: _white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () => _onLogin(context),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: _white,
                          foregroundColor: _mute,
                          minimumSize: const Size.fromHeight(50),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: _line, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          textStyle: const TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        child: const Text('Log In'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
