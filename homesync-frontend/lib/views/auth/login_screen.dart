import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../../core/network/auth_session.dart';
import '../../core/state/focus_areas.dart';
import '../../core/widgets/liquid_glass_card.dart';
import '../home/home_screen.dart';
import '../onboarding/focus_areas_screen.dart';

/// Backend sign-in (`POST /auth/login` + `GET /auth/me`). On success the
/// JWT is stored securely, the dashboard syncs tasks, and balances come
/// from the server ledger.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _emailError;
  String? _passwordError;
  String? _formError;
  bool _busy = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final emailError =
        email.isEmpty || !email.contains('@') ? 'Enter a valid email.' : null;
    final passwordError = password.isEmpty ? 'Enter your password.' : null;
    setState(() {
      _emailError = emailError;
      _passwordError = passwordError;
      _formError = null;
    });
    if (emailError != null || passwordError != null) return;

    final session = AuthScope.of(context);
    setState(() => _busy = true);
    try {
      await session.login(email, password);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _formError = e.message;
      });
      return;
    }
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => FocusAreasScope(
          controller: FocusAreasController(FocusAreas.all),
          child: HomeScreen(profile: session.toProfile()),
        ),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Log in')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Welcome back', style: text.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'Log in to your family dashboard.',
                style: text.bodyMedium,
              ),
              const SizedBox(height: 20),
              LiquidGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        errorText: _emailError,
                      ),
                      onChanged: (_) => setState(() => _emailError = null),
                      onSubmitted: (_) => _login(),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        errorText: _passwordError,
                      ),
                      onChanged: (_) =>
                          setState(() => _passwordError = null),
                      onSubmitted: (_) => _login(),
                    ),
                    if (_formError != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _formError!,
                        style: text.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _busy ? null : _login,
                child: Text(_busy ? 'Logging in…' : 'Login'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const FocusAreasScreen(),
                  ),
                ),
                child: const Text('Create an account instead'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
