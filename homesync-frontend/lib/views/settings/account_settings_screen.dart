import 'package:flutter/material.dart';

/// Minimal Account Settings placeholder, reached from the profile hub's
/// Account settings row.
///
/// Follows the Settings screen pattern (cream scaffold, Nunito 26
/// ExtraBold title, white group card). No settings features yet.
class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key, this.onBack});

  /// Back button placeholder. Falls back to [Navigator.maybePop].
  final VoidCallback? onBack;

  static const Color _cream = Color(0xFFFBF7EF);
  static const Color _ink = Color(0xFF2B3A2B);
  static const Color _mute = Color(0xFF7C877A);
  static const Color _white = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            top: 12,
            left: 20,
            right: 20,
            bottom: 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  key: const Key('account-settings-back'),
                  onTap: onBack ?? () => Navigator.of(context).maybePop(),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _white,
                      borderRadius: BorderRadius.circular(19),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x173B4D38),
                          offset: Offset(0, 5),
                          blurRadius: 16,
                          spreadRadius: -4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.chevron_left_rounded,
                      size: 20,
                      color: _ink,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Account Settings',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w800,
                  fontSize: 26,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xF2FFFFFF)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x173B4D38),
                      offset: Offset(0, 5),
                      blurRadius: 16,
                      spreadRadius: -4,
                    ),
                  ],
                ),
                child: const Text(
                  'Account settings are coming soon.',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    height: 1.35,
                    color: _mute,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
