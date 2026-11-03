import 'package:flutter/material.dart';

import '../../core/state/focus_areas.dart';

import 'profile_setup_screen.dart';



/// Figma "03 Set Up Family" (node 3:63): member list plus add-member form.
///
/// Figma tokens are hard-coded here because they differ from the shared
/// theme (`AppColors` cream/sage/ink predate this design). Do not move
/// them into the theme files: no other screen uses these values.
class FamilySetupScreen extends StatefulWidget {
  const FamilySetupScreen({super.key});

  @override
  State<FamilySetupScreen> createState() => _FamilySetupScreenState();
}

/// Which trailing widget a member card shows.
enum _MemberTrailing { chevron, kidsMode, teenMode }

/// One row in the existing-members list.
class _FamilyMember {
  const _FamilyMember({
    required this.id,
    required this.name,
    required this.detail,
    required this.avatarColor,
    required this.glyph,
    required this.trailing,
  });

  final String id;
  final String name;
  final String detail;
  final Color avatarColor;
  final String glyph;
  final _MemberTrailing trailing;
}

class _FamilySetupScreenState extends State<FamilySetupScreen> {
  // Figma tokens (screen-only, see class doc).
  static const Color _cream = Color(0xFFFBF7EF);
  static const Color _ink = Color(0xFF2B3A2B);
  static const Color _mute = Color(0xFF7C877A);
  static const Color _sage = Color(0xFF5F7F55);
  static const Color _sageMid = Color(0xFFA9BE9C);
  static const Color _peach = Color(0xFFF6D9C4);
  static const Color _pink = Color(0xFFF4C9C9);
  static const Color _blue = Color(0xFFCFE0EE);
  static const Color _white = Color(0xFFFFFFFF);

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

  static const TextStyle _inputTextStyle = TextStyle(
    fontFamily: 'Nunito',
    fontWeight: FontWeight.w600,
    fontSize: 16,
    color: _ink,
  );

  /// Role picker options. The shared [FamilyRole] enum has only
  /// Parent/Child (tied to onboarding semantics, no Teen), so this screen
  /// keeps the spec's fallback set locally instead of widening it.
  static const List<String> _roleOptions = ['Parent', 'Child', 'Teen'];

  static const List<_FamilyMember> _initialMembers = [
    _FamilyMember(
      id: 'sarah',
      name: 'Sarah',
      detail: 'Mom · Parent',
      avatarColor: _peach,
      glyph: '👩',
      trailing: _MemberTrailing.chevron,
    ),
    _FamilyMember(
      id: 'ava',
      name: 'Ava',
      detail: 'Child · Age 8',
      avatarColor: _pink,
      glyph: '👧',
      trailing: _MemberTrailing.kidsMode,
    ),
    _FamilyMember(
      id: 'noah',
      name: 'Noah',
      detail: 'Child · Age 14',
      avatarColor: _blue,
      glyph: '👦',
      trailing: _MemberTrailing.teenMode,
    ),
  ];

  final List<_FamilyMember> _members = List.of(_initialMembers);
  final _nameController = TextEditingController();
  final _ageController = TextEditingController(text: '12');
  String _role = 'Child';

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _onPressMember(String memberId) {
    // TODO: navigate to the member detail route once it exists.
  }

  /// Appends the entered member to the local list only. No API call.
  void _onAddMember() {
    final name = _nameController.text.trim();
    final age = _ageController.text.trim();
    _nameController.clear();
    setState(() {
      _members.add(
        _FamilyMember(
          id: 'custom-${_members.length}',
          name: name.isEmpty ? 'New member' : name,
          detail: _role == 'Parent'
              ? 'Parent'
              : '$_role · Age ${age.isEmpty ? '–' : age}',
          avatarColor: _peach,
          glyph: '👤',
          trailing: _MemberTrailing.chevron,
        ),
      );
    });
  }

  void _onDoneLater() {
    // Focus picker shelved: straight to profile setup, all areas on.


    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProfileSetupScreen(focusAreas: FocusAreas.all),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hintText}) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: _cardBorderSide,
    );
    return InputDecoration(
      hintText: hintText,
      hintStyle: _inputTextStyle,
      filled: true,
      fillColor: _white,
      contentPadding: const EdgeInsets.symmetric(
        vertical: 14,
        horizontal: 16,
      ),
      border: border,
      enabledBorder: border,
      focusedBorder: border,
      disabledBorder: border,
    );
  }

  Widget _shadowedInput(Widget child) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: _cardShadow,
      ),
      child: child,
    );
  }

  Widget _labeledField({required String label, required Widget input}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w700,
            fontSize: 12,
            color: _mute,
          ),
        ),
        const SizedBox(height: 8),
        input,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: 34,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              _buildExistingMembers(),
              const SizedBox(height: 12),
              _buildAddMemberForm(),
              const SizedBox(height: 12),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Set Up Your Family',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w800,
            fontSize: 28,
            color: _ink,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Add your family members to get started.',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w500,
            fontSize: 15,
            color: _mute,
          ),
        ),
      ],
    );
  }

  Widget _buildExistingMembers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Existing members',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: _mute,
          ),
        ),
        for (final member in _members) ...[
          const SizedBox(height: 6),
          _MemberCard(
            member: member,
            onTap: () => _onPressMember(member.id),
          ),
        ],
      ],
    );
  }

  Widget _buildAddMemberForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Add member',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: _mute,
          ),
        ),
        const SizedBox(height: 12),
        _labeledField(
          label: 'Name',
          input: _shadowedInput(
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              style: _inputTextStyle,
              decoration: _inputDecoration(hintText: 'Enter name'),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _labeledField(
          label: 'Age',
          input: _shadowedInput(
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              style: _inputTextStyle,
              decoration: _inputDecoration(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _labeledField(
          label: 'Role',
          input: _shadowedInput(
            DropdownButtonFormField<String>(
              initialValue: _role,
              isExpanded: true,
              items: [
                for (final option in _roleOptions)
                  DropdownMenuItem(value: option, child: Text(option)),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _role = value);
              },
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 20,
                color: _mute,
              ),
              style: _inputTextStyle,
              dropdownColor: _white,
              decoration: _inputDecoration(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
            onPressed: _onAddMember,
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
              'Add Member',
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
        SizedBox(
          height: 54,
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _onDoneLater,
            style: OutlinedButton.styleFrom(
              backgroundColor: _white,
              foregroundColor: _sage,
              side: const BorderSide(color: _sageMid),
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
              'Done / Later',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: _sage,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// One existing-member row: avatar glyph, name/detail block, trailing.
class _MemberCard extends StatelessWidget {
  const _MemberCard({required this.member, required this.onTap});

  final _FamilyMember member;
  final VoidCallback onTap;

  static const Color _ink = Color(0xFF2B3A2B);
  static const Color _mute = Color(0xFF7C877A);
  static const Color _yellowLight = Color(0xFFFDF0C8);
  static const Color _lavender = Color(0xFFDDD5EE);
  static const Color _white = Color(0xFFFFFFFF);

  Widget _trailing() {
    switch (member.trailing) {
      case _MemberTrailing.chevron:
        return const Icon(
          Icons.chevron_right_rounded,
          size: 20,
          color: _mute,
        );
      case _MemberTrailing.kidsMode:
        return _modePill('Kids Mode', _yellowLight);
      case _MemberTrailing.teenMode:
        return _modePill('Teen Mode', _lavender);
    }
  }

  Widget _modePill(String label, Color background) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
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
    return Semantics(
      button: true,
      label: member.name,
      child: Material(
        color: _white,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
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
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: member.avatarColor,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    member.glyph,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w400,
                      fontSize: 31,
                      color: _ink,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.name,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: _ink,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        member.detail,
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
                const SizedBox(width: 14),
                _trailing(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
