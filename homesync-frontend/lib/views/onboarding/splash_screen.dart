import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/network/auth_session.dart';
import '../../core/state/focus_areas.dart';
import '../auth/login_screen.dart';
import '../home/home_screen.dart';
import 'choose_mode_screen.dart';
import 'models/user_profile.dart';

/// Figma "01 Splash" (node 3:2): brand, house illustration, actions.
///
/// Figma tokens are hard-coded here because they differ from the shared
/// theme (`AppColors` cream/sage/ink predate this design). Do not move
/// them into the theme files: no other screen uses these values.
///
/// When an [AuthScope] session is present, the splash also owns startup
/// re-hydration: it kicks off [AuthSession.restore] if needed, shows a
/// loader while the saved JWT revalidates, and auto-routes an
/// authenticated user to the dashboard so a restart never flashes
/// login. Without a session (previews, isolated tests) it renders the
/// static Figma entry with [Get Started] / [Log In].
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Figma tokens (screen-only, see class doc).
  static const Color _cream = Color(0xFFFBF7EF);
  static const Color _ink = Color(0xFF2B3A2B);
  static const Color _mute = Color(0xFF7C877A);
  static const Color _sage = Color(0xFF5F7F55);
  static const Color _line = Color(0xFFE8E4D8);
  static const Color _white = Color(0xFFFFFFFF);

  /// Figma "House Illustration" export. The file lands here separately.
  static const String _houseAsset = 'assets/homePageImg.png';

  bool _navigated = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final session = AuthScope.maybeOf(context);
    if (session == null) return;
    // Belt-and-braces: main() already starts the restore, but a session
    // created elsewhere (e.g. HomeSyncApp's default) still re-hydrates.
    if (!session.hasRestored && !session.isRestoring) {
      unawaited(session.restore());
    }
    if (_navigated || !session.hasRestored || !session.isAuthenticated) {
      return;
    }
    _navigated = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _goHome(session));
  }

  /// Routes a restored login to the dashboard, mirroring [LoginScreen]'s
  /// post-login navigation (all focus areas, stored Parent PIN).
  Future<void> _goHome(AuthSession session) async {
    String parentPin = '1234';
    try {
      parentPin = await session.getParentPin() ?? '1234';
    } catch (_) {
      // Keychain unavailable: fall back to the demo PIN gate.
    }
    if (!mounted) return;
    late final UserProfile profile;
    try {
      profile = session.toProfile();
    } catch (_) {
      // Logged out between frames: stay on the splash actions.
      _navigated = false;
      return;
    }
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => FocusAreasScope(
          controller: FocusAreasController(FocusAreas.all),
          child: HomeScreen(profile: profile, parentPin: parentPin),
        ),
      ),
      (_) => false,
    );
  }

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
    final session = AuthScope.maybeOf(context);
    final restoring = session != null && !session.hasRestored;
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
              // Actions: a loader while the saved session revalidates so
              // a restart never flashes login for a signed-in user.
              if (restoring)
                const SizedBox(
                  height: 116,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              else
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
