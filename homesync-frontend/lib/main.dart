import 'dart:async';

import 'package:flutter/material.dart';

import 'core/network/auth_session.dart';
import 'core/theme/app_theme.dart';
import 'views/onboarding/splash_screen.dart';

void main() {
  // The restore below touches the secure-storage platform channel, which
  // requires the binding before runApp.
  WidgetsFlutterBinding.ensureInitialized();
  final session = AuthSession();
  // Restore a saved JWT in the background; failures fall back to login.
  unawaited(session.restore());
  runApp(HomeSyncApp(session: session));
}

/// App entry. Home is the Figma 01 Splash screen, which routes to
/// account setup (Choose Mode) or login.
///
/// An [AuthScope] wraps the app so login, registration, and the
/// dashboard share one authenticated backend session.
class HomeSyncApp extends StatelessWidget {
  HomeSyncApp({super.key, AuthSession? session})
      : _session = session ?? AuthSession();

  final AuthSession _session;

  @override
  Widget build(BuildContext context) {
    return AuthScope(
      session: _session,
      child: MaterialApp(
        title: 'HomeSync',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        home: const SplashScreen(),
      ),
    );
  }
}
