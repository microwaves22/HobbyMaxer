import 'package:flutter/material.dart';

import 'core/network/auth_session.dart';
import 'core/theme/app_theme.dart';
import 'views/onboarding/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final session = AuthSession();
  try {
    await session.restore();
  } catch (_) {
    // No saved session (or keychain unavailable): start logged out.
  }
  runApp(HomeSyncApp(session: session));
}

/// HomeSync root widget.
///
/// Light theme by default; Teen Mode picks up the dark theme via the
/// system brightness until a per-profile toggle is added. The [AuthScope]
/// above [MaterialApp] shares one authenticated client with every route.
class HomeSyncApp extends StatelessWidget {
  const HomeSyncApp({super.key, AuthSession? session}) : _session = session;

  final AuthSession? _session;

  @override
  Widget build(BuildContext context) {
    return AuthScope(
      session: _session ?? AuthSession(),
      child: MaterialApp(
        title: 'HomeSync',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        home: const SplashScreen(),
      ),
    );
  }
}
