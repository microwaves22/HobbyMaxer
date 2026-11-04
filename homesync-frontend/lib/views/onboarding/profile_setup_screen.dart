import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../../core/network/auth_session.dart';
import '../../core/state/focus_areas.dart';
import '../../core/widgets/liquid_glass_card.dart';
import '../home/home_screen.dart';
import 'models/user_profile.dart';

/// Create-an-account profile setup: email, password, name, birthday,
/// account type (Parent/Kid), and Kids/Teens/Parent mode.
///
/// When an [AuthScope] is available above this screen, Continue registers
/// the account with the backend (`POST /auth/register`); otherwise the
/// profile is created locally only. Other family members are added later
/// from settings, not here.
class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key, this.focusAreas = const []});

  final List<String> focusAreas;

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _birthdayController = TextEditingController();
  FamilyRole _role = FamilyRole.parent;
  FamilyMode _mode = FamilyMode.kids;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _nameError;
  String? _birthdayError;
  String? _formError;
  bool _busy = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _birthdayController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthday() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 10, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: today,
    );
    if (picked != null && mounted) {
      setState(() {
        _birthdayController.text = formatBirthday(picked);
        _birthdayError = null;
      });
    }
  }

  Future<void> _continue() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final name = _nameController.text.trim();
    final emailError =
        email.isEmpty || !email.contains('@') ? 'Enter a valid email.' : null;
    final passwordError = password.length < 6
        ? 'Enter a password (6+ characters).'
        : null;
    final confirmPasswordError = confirmPassword != password
        ? 'Passwords do not match.'
        : null;
    final birthdayError = validateBirthday(_birthdayController.text);
    setState(() {
      _emailError = emailError;
      _passwordError = passwordError;
      _confirmPasswordError = confirmPasswordError;
      _nameError = name.isEmpty ? 'Enter your name.' : null;
      _birthdayError = birthdayError;
      _formError = null;
    });
    if (emailError != null ||
        passwordError != null ||
        confirmPasswordError != null ||
        name.isEmpty ||
        birthdayError != null) {
      return;
    }
    final session = AuthScope.maybeOf(context);
    if (session != null) {
      setState(() => _busy = true);
      try {
        await session.register(
          email: email,
          password: password,
          displayName: name,
        );
      } on ApiException catch (e) {
        if (!mounted) return;
        setState(() {
          _busy = false;
          _formError = e.message;
        });
        return;
      }
    }
    if (!mounted) return;
    final profile = UserProfile(
      name: name,
      birthday: tryParseBirthday(_birthdayController.text)!,
      role: _role,
      mode: _mode,
    );
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => FocusAreasScope(
          controller: FocusAreasController(widget.focusAreas),
          child: HomeScreen(profile: profile),
        ),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Your profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Tell us about yourself', style: text.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'Just you for now — family members join later from settings.',
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
                        hintText: 'Email address',
                        errorText: _emailError,
                      ),
                      onChanged: (_) => setState(() => _emailError = null),
                      onSubmitted: (_) => _continue(),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        errorText: _passwordError,
                        suffixIcon: IconButton(
                          tooltip: _obscurePassword
                              ? 'Show password'
                              : 'Hide password',
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () => setState(() =>
                              _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      onChanged: (_) => setState(() => _passwordError = null),
                      onSubmitted: (_) => _continue(),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        hintText: 'Confirm Password',
                        errorText: _confirmPasswordError,
                        suffixIcon: IconButton(
                          tooltip: _obscureConfirmPassword
                              ? 'Show password'
                              : 'Hide password',
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () => setState(() =>
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword),
                        ),
                      ),
                      onChanged: (_) =>
                          setState(() => _confirmPasswordError = null),
                      onSubmitted: (_) => _continue(),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        hintText: 'Enter name',
                        errorText: _nameError,
                      ),
                      onChanged: (_) => setState(() => _nameError = null),
                      onSubmitted: (_) => _continue(),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _birthdayController,
                      keyboardType: TextInputType.datetime,
                      decoration: InputDecoration(
                        hintText: 'Birthday (YYYY-MM-DD)',
                        errorText: _birthdayError,
                        suffixIcon: IconButton(
                          tooltip: 'Pick a date',
                          icon: const Icon(Icons.calendar_month_outlined),
                          onPressed: _pickBirthday,
                        ),
                      ),
                      onChanged: (_) =>
                          setState(() => _birthdayError = null),
                      onSubmitted: (_) => _continue(),
                    ),
                    const SizedBox(height: 16),
                    Text('Account type', style: text.labelSmall),
                    const SizedBox(height: 8),
                    SegmentedButton<FamilyRole>(
                      segments: const [
                        ButtonSegment(
                          value: FamilyRole.parent,
                          label: Text('Parent'),
                        ),
                        ButtonSegment(
                          value: FamilyRole.child,
                          label: Text('Kid'),
                        ),
                      ],
                      selected: {_role},
                      onSelectionChanged: (selected) =>
                          setState(() => _role = selected.first),
                    ),
                    const SizedBox(height: 16),
                    Text('Mode', style: text.labelSmall),
                    const SizedBox(height: 8),
                    SegmentedButton<FamilyMode>(
                      segments: const [
                        ButtonSegment(
                          value: FamilyMode.kids,
                          label: Text('Kids'),
                        ),
                        ButtonSegment(
                          value: FamilyMode.teen,
                          label: Text('Teens'),
                        ),
                        ButtonSegment(
                          value: FamilyMode.parent,
                          label: Text('Parent'),
                        ),
                      ],
                      selected: {_mode},
                      onSelectionChanged: (selected) =>
                          setState(() => _mode = selected.first),
                    ),
                    if (_formError != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _formError!,
                        style: text.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _busy ? null : _continue,
                child: Text(_busy ? 'Creating account…' : 'Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Formats [date] as `YYYY-MM-DD`.
String formatBirthday(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}
