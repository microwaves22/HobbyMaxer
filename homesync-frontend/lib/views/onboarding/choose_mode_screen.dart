import 'package:flutter/material.dart';

import 'family_setup_screen.dart';

/// Figma "02 Account Setup — Choose Mode" (node 3:32): account mode picker.
///
/// Figma tokens are hard-coded here because they differ from the shared
/// theme (`AppColors` cream/sage/ink predate this design). Do not move
/// them into the theme files: no other screen uses these values.
class ChooseModeScreen extends StatefulWidget {
  const ChooseModeScreen({super.key});

  @override
  State<ChooseModeScreen> createState() => _ChooseModeScreenState();
}

/// One account-mode option rendered as a selectable card.
class _AccountMode {
  const _AccountMode({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.tileColor,
    required this.selected,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color tileColor;
  final bool selected;
}

class _ChooseModeScreenState extends State<ChooseModeScreen> {
  // Figma tokens (screen-only, see class doc).
  static const Color _cream = Color(0xFFFBF7EF);
  static const Color _ink = Color(0xFF2B3A2B);
  static const Color _mute = Color(0xFF7C877A);
  static const Color _sage = Color(0xFF5F7F55);
  static const Color _sageLight = Color(0xFFE4EBDC);
  static const Color _sageMid = Color(0xFFA9BE9C);
  static const Color _yellowLight = Color(0xFFFDF0C8);
  static const Color _white = Color(0xFFFFFFFF);

  // Single-select state, defaulting to Parent Mode exactly as shown.
  String _selectedId = 'parent';

  void _onSelectMode(String modeId) {
    setState(() => _selectedId = modeId);
  }

  void _onContinue(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const FamilySetupScreen()),
    );
  }

  List<_AccountMode> get _modes => [
        _AccountMode(
          id: 'parent',
          title: 'Parent Mode',
          description:
              'Administrative controls, task management, and family data at a glance.',
          icon: Icons.group_rounded,
          tileColor: _sageLight,
          selected: _selectedId == 'parent',
        ),
        _AccountMode(
          id: 'teen',
          title: 'Teen Mode',
          description:
              'A mature, simplified view for independence and responsibility.',
          icon: Icons.checklist_rounded,
          tileColor: _sageLight,
          selected: _selectedId == 'teen',
        ),
        _AccountMode(
          id: 'kids',
          title: 'Kids Mode',
          description:
              'Playful rewards, animal friends, and gentle chore encouragement.',
          icon: Icons.star_rounded,
          tileColor: _yellowLight,
          selected: _selectedId == 'kids',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final modes = _modes;
    return Scaffold(
      backgroundColor: _cream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: 34,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Intro.
              const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Welcome to HomeSync!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w800,
                      fontSize: 28,
                      color: _ink,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Choose the account type that fits your family role.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      height: 22 / 15,
                      color: _mute,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Account mode cards.
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < modes.length; i++) ...[
                    if (i > 0) const SizedBox(height: 12),
                    _ModeCard(
                      mode: modes[i],
                      onTap: () => _onSelectMode(modes[i].id),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 20),
              // Actions.
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Progress dots.
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 24,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _sage,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _sageMid,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _sageMid,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Primary button.
                  Container(
                    height: 54,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x4D5E8054),
                          offset: Offset(0, 4),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () => _onContinue(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _sage,
                        foregroundColor: _white,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        minimumSize: const Size.fromHeight(54),
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        textStyle: const TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      child: const Text('Continue'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Selectable account-mode card: icon tile, text block, optional pill.
class _ModeCard extends StatelessWidget {
  const _ModeCard({required this.mode, required this.onTap});

  final _AccountMode mode;
  final VoidCallback onTap;

  static const Color _ink = Color(0xFF2B3A2B);
  static const Color _mute = Color(0xFF7C877A);
  static const Color _sage = Color(0xFF5F7F55);
  static const Color _line = Color(0xFFE8E4D8);
  static const Color _white = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: mode.title,
      selected: mode.selected,
      child: Material(
        color: _white,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _white,
              borderRadius: BorderRadius.circular(22),
              border: mode.selected
                  ? Border.all(color: _sage, width: 2)
                  : Border.all(color: _line, width: 1),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x173B4D38),
                  offset: Offset(0, 5),
                  blurRadius: 16,
                  spreadRadius: -4,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: mode.tileColor,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(mode.icon, size: 20, color: _sage),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mode.title,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                          color: _ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mode.description,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          height: 18 / 13,
                          color: _mute,
                        ),
                      ),
                    ],
                  ),
                ),
                if (mode.selected) ...[
                  const SizedBox(width: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      color: _sage,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Selected',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                        color: _white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
