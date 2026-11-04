import 'package:flutter/material.dart';

/// Figma-style "Join a family circle": enter the invite code shown on a
/// parent's [LinkKidsScreen] to link this account into the circle.
///
/// Local-only for now (the backend has no invite-code endpoint yet):
/// any well-formed 6-character code is accepted.
class JoinCircleScreen extends StatefulWidget {
  const JoinCircleScreen({super.key});

  @override
  State<JoinCircleScreen> createState() => _JoinCircleScreenState();
}

class _JoinCircleScreenState extends State<JoinCircleScreen> {
  // Tokens matching the sibling LinkKidsScreen.
  static const Color _cream = Color(0xFFFBF7EF);
  static const Color _ink = Color(0xFF2B3A2B);
  static const Color _mute = Color(0xFF7C877A);
  static const Color _sage = Color(0xFF5F7F55);
  static const Color _sageDark = Color(0xFF4A6A41);
  static const Color _sageLight = Color(0xFFE4EBDC);
  static const Color _white = Color(0xFFFFFFFF);

  final _codeController = TextEditingController();
  String? _error;
  String? _joinedCode;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  /// Normalizes raw input to `XXX XXX`Invite code form, or null when
  /// it is not 6 letters/digits.
  static String? normalizeInviteCode(String input) {
    final compact = input.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase();
    if (compact.length != 6) return null;
    return '${compact.substring(0, 3)} ${compact.substring(3)}';
  }

  void _join() {
    final code = normalizeInviteCode(_codeController.text);
    if (code == null) {
      setState(() => _error = 'Enter the 6-character invite code.');
      return;
    }
    setState(() {
      _error = null;
      _joinedCode = code;
    });
  }

  @override
  Widget build(BuildContext context) {
    final joined = _joinedCode;
    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: _cream,
        elevation: 0,
        foregroundColor: _ink,
        title: const Text(
          'Join a family circle',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: _ink,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: joined == null ? _buildForm() : _buildSuccess(joined),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Enter the invite code from your family circle to link this account.',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w500,
            fontSize: 15,
            color: _mute,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                color: Color(0x173B4D38),
                offset: Offset(0, 5),
                blurRadius: 16,
                spreadRadius: -4,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'e.g. H7K 2M9',
                  errorText: _error,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                  letterSpacing: 4,
                  color: _sageDark,
                ),
                textAlign: TextAlign.center,
                onChanged: (_) => setState(() => _error = null),
                onSubmitted: (_) => _join(),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _join,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _sage,
                    foregroundColor: _white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    textStyle: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  child: const Text('Join'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Ask a parent for the code on their Link your kids screen.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: _mute,
          ),
        ),
      ],
    );
  }

  Widget _buildSuccess(String code) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _sageLight,
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Column(
            children: [
              Icon(Icons.check_circle_rounded, size: 56, color: _sage),
              SizedBox(height: 12),
              Text(
                'Circle joined!',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w800,
                  fontSize: 23,
                  color: _ink,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "You're now linked with code $code.",
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: _sageDark,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).maybePop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: _sage,
              foregroundColor: _white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              textStyle: const TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            child: const Text('Done'),
          ),
        ),
      ],
    );
  }
}
