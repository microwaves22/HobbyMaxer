import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/network/auth_session.dart';
import '../../core/state/focus_areas.dart';
import '../../core/widgets/liquid_glass_card.dart';
import '../home/home_screen.dart';
import 'models/user_profile.dart';

/// Single-user profile setup: name, birthday, role, and Kids/Teen mode.
///
/// Other family members are added later from settings, not here.
class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key, this.focusAreas = const []});

  final List<String> focusAreas;

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _pinController = TextEditingController();
  FamilyRole _role = FamilyRole.parent;
  FamilyMode _mode = FamilyMode.kids;
  String? _nameError;
  String? _birthdayError;
  String? _pinError;

  @override
  void dispose() {
    _nameController.dispose();
    _birthdayController.dispose();
    _pinController.dispose();
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
    final name = _nameController.text.trim();
    final birthdayError = validateBirthday(_birthdayController.text);
    final pin = _pinController.text.trim();
    final pinError =
        _role == FamilyRole.parent && !RegExp(r'^\d{4}$').hasMatch(pin)
            ? 'Set a 4-digit Parent PIN.'
            : null;
    setState(() {
      _nameError = name.isEmpty ? 'Enter your name.' : null;
      _birthdayError = birthdayError;
      _pinError = pinError;
    });
    if (name.isEmpty || birthdayError != null || pinError != null) return;
    final session = AuthScope.maybeOf(context);
    String parentPin;
    if (_role == FamilyRole.parent) {
      parentPin = pin;
      await session?.setParentPin(pin);
    } else {
      parentPin = await session?.getParentPin() ?? '1234';
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
          child: HomeScreen(profile: profile, parentPin: parentPin),
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
                    Text('I am a…', style: text.labelSmall),
                    const SizedBox(height: 8),
                    SegmentedButton<FamilyRole>(
                      segments: const [
                        ButtonSegment(
                          value: FamilyRole.parent,
                          label: Text('Parent'),
                        ),
                        ButtonSegment(
                          value: FamilyRole.child,
                          label: Text('Child'),
                        ),
                      ],
                      selected: {_role},
                      onSelectionChanged: (selected) => setState(() {
                        _role = selected.first;
                        _pinError = null;
                      }),
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
                          label: Text('Teen'),
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
                    if (_role == FamilyRole.parent) ...[
                      const SizedBox(height: 16),
                      Text('Parent PIN', style: text.labelSmall),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _pinController,
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          hintText: '4-digit PIN',
                          errorText: _pinError,
                          counterText: '',
                        ),
                        onChanged: (_) =>
                            setState(() => _pinError = null),
                        onSubmitted: (_) => _continue(),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _continue,
                child: const Text('Continue'),
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
