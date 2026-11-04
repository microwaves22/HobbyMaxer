import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../../core/network/auth_session.dart';
import '../../core/state/focus_areas.dart';
import '../home/home_screen.dart';

/// Independent kid login (`POST /auth/child-login` with the child's
/// own PIN, which is optional). No parent credential involved.
class ChildLoginScreen extends StatefulWidget {
  const ChildLoginScreen({super.key});

  @override
  State<ChildLoginScreen> createState() => _ChildLoginScreenState();
}

class _ChildLoginScreenState extends State<ChildLoginScreen> {
  final _idController = TextEditingController();
  final _pinController = TextEditingController();
  String? _idError;
  String? _pinError;
  String? _formError;
  bool _busy = false;

  @override
  void dispose() {
    _idController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final idText = _idController.text.trim();
    final pin = _pinController.text;
    final userId = int.tryParse(idText);
    final idError = userId == null ? 'Enter your child ID.' : null;
    final pinError =
        pin.isNotEmpty && pin.length < 4 ? 'PINs have 4+ characters.' : null;
    setState(() {
      _idError = idError;
      _pinError = pinError;
      _formError = null;
    });
    if (idError != null || pinError != null || userId == null) return;

    final session = AuthScope.of(context);
    setState(() => _busy = true);
    try {
      await session.childLogin(
        userId: userId,
        pin: pin.isEmpty ? null : pin,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _formError = e.message;
      });
      return;
    } catch (_) {
      debugPrint('Kid login failed with an unexpected error.');
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
      backgroundColor: const Color(0xFFF5EBE0),
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
                Center(
                  child: Container(
                    height: 64,
                    width: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3DAC9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.face_rounded,
                      size: 32,
                      color: Color(0xFF2C5E3B),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Kid login',
                  style: text.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2C3E35),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your child ID and PIN to open your dashboard.',
                  style: text.bodyMedium?.copyWith(
                    color: const Color(0xFF5A6B60),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF6F0),
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
                        controller: _idController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Color(0xFF2C3E35)),
                        decoration: InputDecoration(
                          hintText: 'Child ID',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          errorText: _idError,
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.badge_outlined,
                              color: Color(0xFF2C5E3B)),
                        ),
                        onChanged: (_) => setState(() => _idError = null),
                        onSubmitted: (_) => _login(),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _pinController,
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Color(0xFF2C3E35)),
                        decoration: InputDecoration(
                          hintText: 'PIN (if you have one)',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          errorText: _pinError,
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.lock_outline,
                              color: Color(0xFF2C5E3B)),
                        ),
                        onChanged: (_) => setState(() => _pinError = null),
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
                ElevatedButton(
                  onPressed: _busy ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C5E3B),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
