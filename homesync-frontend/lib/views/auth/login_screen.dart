import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../../core/network/auth_session.dart';
import '../../core/state/focus_areas.dart';
import '../home/home_screen.dart';
import '../onboarding/profile_setup_screen.dart';
import 'child_login_screen.dart';





/// Backend sign-in (`POST /auth/login` + `GET /auth/me`). On success the
/// JWT is stored securely, the dashboard syncs tasks, and balances come
/// from the server ledger matching the HomeSync Figma design.
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
    } catch (_) {
      // Non-API failures must not wedge the form in its busy state.
      debugPrint('Login failed with an unexpected error.');
      if (!mounted) return;
      setState(() {
        _busy = false;
        _formError = 'Something went wrong. Please try again.';
      });
      return;
    }
    String parentPin = '1234';
    try {
      parentPin = await session.getParentPin() ?? '1234';
    } catch (_) {
      // Keychain unavailable: fall back to the demo PIN gate.
    }
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => FocusAreasScope(
          controller: FocusAreasController(FocusAreas.all),
          child: HomeScreen(profile: session.toProfile(), parentPin: parentPin),
        ),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;

    return Scaffold(
      backgroundColor:
          const Color(0xFFF5EBE0), // Warm beige background matching Figma theme
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2C3E35)),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Branded Icon Container with contrast
                Center(
                  child: Container(
                    height: 64,
                    width: 64,
                    decoration: BoxDecoration(
                      color:
                          const Color(0xFFE3DAC9), // Deeper contrast sage/beige
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.home_rounded,
                      size: 32,
                      color: Color(0xFF2C5E3B), // Primary HomeSync green
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Welcome back',
                  style: text.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2C3E35), // High contrast dark text
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Log in to your family dashboard.',
                  style: text.bodyMedium?.copyWith(
                    color: const Color(0xFF5A6B60), // Readable muted dark tone
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Form Card Container with solid warm beige background for visibility
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color:
                        const Color(0xFFFAF6F0), // Clean opaque warm card base
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Color(0xFF2C3E35)),
                        decoration: InputDecoration(
                          hintText: 'Email address',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          errorText: _emailError,
                          filled: true,
                          fillColor:
                              Colors.white, // Crisp white fields for clarity
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.email_outlined,
                              color: Color(0xFF2C5E3B)),
                        ),
                        onChanged: (_) => setState(() => _emailError = null),
                        onSubmitted: (_) => _login(),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        style: const TextStyle(color: Color(0xFF2C3E35)),
                        decoration: InputDecoration(
                          hintText: 'Password',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          errorText: _passwordError,
                          filled: true,
                          fillColor:
                              Colors.white, // Crisp white fields for clarity
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.lock_outline,
                              color: Color(0xFF2C5E3B)),
                        ),
                        onChanged: (_) => setState(() => _passwordError = null),
                        onSubmitted: (_) => _login(),
                      ),
                      if (_formError != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _formError!,
                          style: text.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Primary Pill Action Button
                ElevatedButton(
                  onPressed: _busy ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                        0xFF2C5E3B), // Primary deep green for strong contrast
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _busy ? 'Logging in…' : 'Login',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Switch to registration link
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      // Skip the focus picker: enable all areas by default.
                      builder: (_) => ProfileSetupScreen(
                        focusAreas: FocusAreas.all,
                      ),
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF2C5E3B),
                  ),
                  child: const Text(
                    'Create an account instead',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ChildLoginScreen(),
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF2C5E3B),
                  ),
                  child: const Text(
                    'Log in as a kid instead',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
