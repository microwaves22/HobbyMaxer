import 'package:flutter/material.dart';

/// Minimal member detail for the 03 Set Up Family flow.
///
/// Shows the tapped member's avatar glyph, name, and detail line from the
/// family setup list, plus a back button. No member features yet — this
/// only resolves the setup screen's member navigation gap.
class MemberDetailScreen extends StatelessWidget {
  const MemberDetailScreen({
    super.key,
    required this.memberId,
    required this.name,
    required this.detail,
    required this.avatarColor,
    required this.glyph,
    this.onBack,
  });

  /// Id of the member tapped on the family setup screen.
  final String memberId;

  final String name;
  final String detail;
  final Color avatarColor;
  final String glyph;

  /// Back button placeholder. Falls back to [Navigator.maybePop].
  final VoidCallback? onBack;

  // Screen-only tokens matching family_setup_screen.dart.
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
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  key: const Key('member-detail-back'),
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
              Container(
                key: const Key('member-detail-card'),
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
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: avatarColor,
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Text(
                        glyph,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w400,
                          fontSize: 31,
                          color: _ink,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: _ink,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      detail,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        color: _mute,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
