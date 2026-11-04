import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/network/api_client.dart';
import '../../core/network/auth_session.dart';
import '../../core/network/families_api.dart';

/// Sample invite code shown on [LinkKidsScreen] (UI build only, no backend).
///
/// Referenced by both the code display and [_LinkKidsScreenBody.onCopyCode].
const String familyInviteCode = 'H7K 2M9';

/// Figma "Link kids to family circle" (node 30:249): share the invite code.
///
/// Figma tokens are hard-coded here because they differ from the shared
/// theme (`AppColors` cream/sage/ink predate this design). Do not move
/// them into the theme files: no other screen uses these values.
class LinkKidsScreen extends StatefulWidget {
  const LinkKidsScreen({super.key});

  @override
  State<LinkKidsScreen> createState() => _LinkKidsScreenState();
}

class _LinkKidsScreenState extends State<LinkKidsScreen> {
  String? _inviteCode;
  List<_LinkedKid>? _kids;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    final session = AuthScope.maybeOf(context);
    if (session == null || !session.isAuthenticated) return;
    _loaded = true;
    _loadFamily(session.client);
  }

  /// Shows the real invite code and roster when signed in; the sample
  /// content stays as the signed-out fallback.
  Future<void> _loadFamily(ApiClient client) async {
    try {
      final family = await FamiliesApi(client).myFamily();
      if (!mounted) return;
      final code = family['invite_code'] as String?;
      final members = family['members'] as List? ?? const [];
      final kids = <_LinkedKid>[];
      for (final member in members) {
        final user = member as Map<String, dynamic>;
        if (user['role'] == 'parent') continue;
        final name = user['display_name'] as String? ?? 'Kid';
        final teen = user['mode'] == 'teen';
        kids.add(_LinkedKid(
          id: '${user['id']}',
          name: name,
          detail: teen ? 'Teen Mode' : 'Kids Mode',
          avatarColor:
              teen ? const Color(0xFFCFE0EE) : const Color(0xFFF4C9C9),
          glyph: name.isNotEmpty ? name.characters.first : '?',
          linked: true,
        ));
      }
      setState(() {
        if (code != null) _inviteCode = FamiliesApi.formatInviteCode(code);
        if (kids.isNotEmpty) _kids = kids;
      });
    } on ApiException {
      // Stay on the sample content.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _LinkKidsScreenBody.cream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            top: 6,
            left: 20,
            right: 20,
            bottom: 24,
          ),
          child: _LinkKidsScreenBody(
            inviteCode: _inviteCode,
            kids: _kids,
          ),
        ),
      ),
    );
  }
}

/// One joining-instruction row.
class _InstructionStep {
  const _InstructionStep({required this.number, required this.text});

  final String number;
  final String text;
}

/// One row in the linked-kids status card.
class _LinkedKid {
  const _LinkedKid({
    required this.id,
    required this.name,
    required this.detail,
    required this.avatarColor,
    required this.glyph,
    required this.linked,
  });

  final String id;
  final String name;
  final String detail;
  final Color avatarColor;
  final String glyph;
  final bool linked;
}

class _LinkKidsScreenBody extends StatelessWidget {
  const _LinkKidsScreenBody({this.inviteCode, this.kids});

  /// Displayed invite code; the sample when null (signed out).
  final String? inviteCode;

  /// Displayed kid rows; the sample roster when null (signed out).
  final List<_LinkedKid>? kids;

  String get _code => inviteCode ?? familyInviteCode;
  List<_LinkedKid> get _kidList => kids ?? _kids;

  String get _linkedSubtitle {
    final linked = _kidList.where((k) => k.linked).length;
    return '$linked of ${_kidList.length} linked';
  }

  // Figma tokens (screen-only, see class doc).
  static const Color cream = Color(0xFFFBF7EF);
  static const Color _ink = Color(0xFF2B3A2B);
  static const Color _mute = Color(0xFF7C877A);
  static const Color _sage = Color(0xFF5F7F55);
  static const Color _sageDark = Color(0xFF4A6A41);
  static const Color _sageLight = Color(0xFFE4EBDC);
  static const Color _pink = Color(0xFFF4C9C9);
  static const Color _blue = Color(0xFFCFE0EE);
  static const Color _line = Color(0xFFE8E4D8);
  static const Color _white = Color(0xFFFFFFFF);
  static const Color _inviteCard = Color(0xA8E4EBDC);
  static const Color _glassCard = Color(0x5CFFFFFF);

  static const List<BoxShadow> _cardShadow = [
    BoxShadow(
      color: Color(0x173B4D38),
      offset: Offset(0, 5),
      blurRadius: 16,
      spreadRadius: -4,
    ),
  ];

  static const BorderSide _cardBorderSide = BorderSide(
    color: Color(0xF2FFFFFF),
  );

  static const List<_InstructionStep> _steps = [
    _InstructionStep(
      number: '1',
      text: 'Open HomeSync and sign in to their account.',
    ),
    _InstructionStep(
      number: '2',
      text: 'Go to Settings → Join a family circle.',
    ),
    _InstructionStep(
      number: '3',
      text: 'Enter the code above and tap Join.',
    ),
  ];

  static const List<_LinkedKid> _kids = [
    _LinkedKid(
      id: 'ava',
      name: 'Ava',
      detail: 'Age 8 · Kids Mode',
      avatarColor: _pink,
      glyph: '👧',
      linked: true,
    ),
    _LinkedKid(
      id: 'noah',
      name: 'Noah',
      detail: 'Age 14 · Teen Mode',
      avatarColor: _blue,
      glyph: '👦',
      linked: false,
    ),
  ];

  void _onBackToFamily(BuildContext context) {
    Navigator.of(context).maybePop();
  }

  Future<void> _onCopyCode(BuildContext context) async {
    if (_code.isEmpty) return;
    try {
      await Clipboard.setData(ClipboardData(text: _code));
    } catch (_) {
      return;
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invite code copied')),
    );
  }

  Future<void> _onShareInviteCode() async {
    if (_code.isEmpty) return;
    try {
      // Native share sheet (Messages, Email, WhatsApp, …) with the
      // invite text pre-filled; subject populates the email subject.
      await Share.share(
        'Join our family on HomeSync! Use invite code: $_code',
        subject: 'Join our family on HomeSync',
      );
    } catch (_) {
      // Share sheet unavailable; nothing to show.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildBackRow(context),
        const SizedBox(height: 14),
        _buildIntroduction(),
        const SizedBox(height: 14),
        _buildInviteCard(context),
        const SizedBox(height: 14),
        _buildInstructionsCard(),
        const SizedBox(height: 14),
        _buildLinkedKids(),
        const SizedBox(height: 14),
        _buildPrivacyNote(),
      ],
    );
  }

  Widget _buildBackRow(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onBackToFamily(context),
      child: const SizedBox(
        height: 28,
        width: double.infinity,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.chevron_left_rounded,
              size: 18,
              color: _sage,
            ),
            SizedBox(width: 6),
            Text(
              'Manage Family',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: _sage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroduction() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Link your kids',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w800,
            fontSize: 28,
            height: 34 / 28,
            color: _ink,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Bring their accounts into your family circle with one simple code.',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w500,
            fontSize: 14,
            height: 19 / 14,
            color: _mute,
          ),
        ),
      ],
    );
  }

  Widget _buildInviteCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _inviteCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _cardBorderSide.color),
        boxShadow: _cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _CircleIconTile(),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your family circle',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: _ink,
                      ),
                    ),
                    Text(
                      'FAMILY INVITE CODE',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                        color: _mute,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 51,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  _code,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w800,
                    fontSize: 35,
                    letterSpacing: 4,
                    color: _sageDark,
                  ),
                ),
                Tooltip(
                  message: 'Copy invite code',
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _onCopyCode(context),
                    child: Container(
                      width: 44,
                      height: 49,
                      decoration: BoxDecoration(
                        color: _glassCard,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.content_copy_rounded,
                            size: 18,
                            color: _sageDark,
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Copy',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w800,
                              fontSize: 10,
                              color: _sageDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
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
              onPressed: _onShareInviteCode,
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
              child: const Text(
                'Share invite code',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: _white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Use this code for each child you want to link.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w600,
              fontSize: 11,
              height: 15 / 11,
              color: _sageDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _glassCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _cardBorderSide.color),
        boxShadow: _cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'On your child’s device',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: _ink,
            ),
          ),
          for (final step in _steps) ...[
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _sageLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    step.number,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      color: _sageDark,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    step.text,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      height: 18 / 13,
                      color: _ink,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLinkedKids() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Your kids',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: _ink,
              ),
            ),
            Text(
              _linkedSubtitle,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: _sage,
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          decoration: BoxDecoration(
            color: _glassCard,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: _cardBorderSide.color),
            boxShadow: _cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < _kidList.length; i++) ...[
                if (i > 0) ...[
                  const SizedBox(height: 10),
                  Container(
                    height: 1,
                    width: double.infinity,
                    color: _line,
                  ),
                  const SizedBox(height: 10),
                ],
                _KidRow(kid: _kidList[i]),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacyNote() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.verified_user_outlined,
          size: 14,
          color: _mute,
        ),
        SizedBox(width: 7),
        Text(
          'Only share this code with your family.',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w600,
            fontSize: 11,
            color: _mute,
          ),
        ),
      ],
    );
  }
}

/// 30px sage tile holding the family-circle icon.
class _CircleIconTile extends StatelessWidget {
  const _CircleIconTile();

  static const Color _sage = Color(0xFF5F7F55);
  static const Color _sageLight = Color(0xFFE4EBDC);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: _sageLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(
        Icons.group_rounded,
        size: 18,
        color: _sage,
      ),
    );
  }
}

/// One child row: avatar glyph, name/detail block, status pill.
class _KidRow extends StatelessWidget {
  const _KidRow({required this.kid});

  final _LinkedKid kid;

  static const Color _ink = Color(0xFF2B3A2B);
  static const Color _mute = Color(0xFF7C877A);
  static const Color _sageDark = Color(0xFF4A6A41);
  static const Color _sageLight = Color(0xFFE4EBDC);
  static const Color _yellowLight = Color(0xFFFDF0C8);

  Widget _statusPill() {
    if (kid.linked) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: _sageLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_rounded,
              size: 12,
              color: _sageDark,
            ),
            SizedBox(width: 4),
            Text(
              'Linked',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w700,
                fontSize: 11,
                color: _sageDark,
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: _yellowLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Text(
        'Not linked',
        style: TextStyle(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w700,
          fontSize: 11,
          color: _ink,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: kid.avatarColor,
            borderRadius: BorderRadius.circular(19),
          ),
          alignment: Alignment.center,
          child: Text(
            kid.glyph,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w400,
              fontSize: 24,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                kid.name,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                kid.detail,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                  color: _mute,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        _statusPill(),
      ],
    );
  }
}
