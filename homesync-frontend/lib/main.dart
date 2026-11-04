import 'dart:async';

import 'package:flutter/material.dart';

import 'core/network/auth_session.dart';
import 'core/state/account_mode.dart';
import 'core/theme/app_theme.dart';
import 'views/customization/customization_controller.dart';
import 'views/onboarding/splash_screen.dart';

void main() {
  // The restores below touch platform channels, which
  // requires the binding before runApp.
  WidgetsFlutterBinding.ensureInitialized();
  final session = AuthSession();
  final accountMode = AccountModeController();
  final customization = CustomizationController();
  // Restore saved state in the background; failures fall back to
  // login (session), unselected mode, and theme defaults.
  unawaited(session.restore());
  unawaited(accountMode.restore());
  unawaited(customization.restore());
  runApp(
    HomeSyncApp(
      session: session,
      accountMode: accountMode,
      customization: customization,
    ),
  );
}

/// App entry. Home is the Figma 01 Splash screen, which routes to
/// account setup (Choose Mode) or login.
///
/// An [AuthScope] wraps the app so login, registration, and the
/// dashboard share one authenticated backend session. [AccountModeScope]
/// carries the chosen account role/mode centrally so setup screens never
/// ask twice, and [CustomizationScope] carries the applied avatar/
/// background selection.
class HomeSyncApp extends StatelessWidget {
  HomeSyncApp({
    super.key,
    AuthSession? session,
    AccountModeController? accountMode,
    CustomizationController? customization,
  })  : _session = session ?? AuthSession(),
        _accountMode = accountMode ?? AccountModeController(),
        _customization = customization ?? CustomizationController();

  final AuthSession _session;
  final AccountModeController _accountMode;
  final CustomizationController _customization;

  @override
  Widget build(BuildContext context) {
    return AuthScope(
      session: _session,
      child: AccountModeScope(
        controller: _accountMode,
        child: CustomizationScope(
          controller: _customization,
          child: MaterialApp(
            title: 'HomeSync',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            home: const SplashScreen(),
          ),
        ),
      ),
    );
  }
}
