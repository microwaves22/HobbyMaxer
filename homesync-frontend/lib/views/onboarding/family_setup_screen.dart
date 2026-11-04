import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/state/focus_areas.dart';
import '../../core/widgets/member_avatar.dart';

import 'family_member.dart';
import 'member_detail_screen.dart';
import 'members_api.dart';
import 'profile_setup_screen.dart';

/// Figma "03 Set Up Family" (node 3:63): member list plus add-member form.
///
/// New users start with a clean slate: the member list is empty until the
/// parent adds members below. Tapping a member opens the edit screen where
/// every field can be changed or the member deleted.
///
/// Figma tokens are hard-coded here because they differ from the shared
/// theme (`AppColors` cream/sage/ink predate this design). Do not move
/// them into the theme files: no other screen uses these values.
class FamilySetupScreen extends StatefulWidget {
<<<<<<< HEAD
  const FamilySetupScreen({super.key, this.initialRole});

  /// Default role for the add-member form, carried from the
  /// Choose Mode screen. Defaults to the first option when null.
  final String? initialRole;
=======
  const FamilySetupScreen({super.key, this.membersApi});

  /// Avatar upload client, forwarded to the member editor. Null in
  /// offline onboarding: photos stay as in-memory previews.
  final MembersApi? membersApi;
>>>>>>> 48e512845754349ab492b180d4e531d2082a5fd4

  @override
  State<FamilySetupScreen> createState() => _FamilySetupScreenState();
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
  static const Color _error = Color(0xFFB3261E);

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

  /// Clean slate: no pre-populated members for new Parent Mode users.
  final List<FamilySetupMember> _members = [];
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
<<<<<<< HEAD
  final _ageController = TextEditingController(text: '12');
  late String _role;

  @override
  void initState() {
    super.initState();
    _role = widget.initialRole ?? FamilySetupOptions.roles.first;
  }
  String _gender = FamilySetupOptions.genders.first;
  String? _photoPath;
=======
  final _ageController = TextEditingController();
  String? _role;
  String? _gender;
  Uint8List? _photoBytes;
>>>>>>> 48e512845754349ab492b180d4e531d2082a5fd4
  final _picker = ImagePicker();

  /// Bumped after each successful add so the dropdown fields are rebuilt
  /// fresh (unselected) instead of keeping the previous member's values.
  int _fieldResetId = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _onPressMember(String memberId) async {
    final index = _members.indexWhere((m) => m.id == memberId);
    if (index == -1) return;
    final result = await Navigator.of(context).push<MemberEditResult>(
      MaterialPageRoute(
        builder: (_) => MemberDetailScreen(
          member: _members[index],
          membersApi: widget.membersApi,
        ),
      ),
    );
    if (!mounted || result == null) return;
    switch (result) {
      case MemberUpdated(:final member):
        setState(() {
          final at = _members.indexWhere((m) => m.id == member.id);
          if (at != -1) _members[at] = member;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Member updated')),
        );
      case MemberDeleted(:final memberId):
        setState(() {
          _members.removeWhere((m) => m.id == memberId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Member deleted')),
        );
    }
  }

  String _glyphFor({required String gender, required bool isParent}) {
    switch (gender) {
      case 'Female':
        return isParent ? '👩' : '👧';
      case 'Male':
        return isParent ? '👨' : '👦';
      default:
        return '👤';
    }
  }

  /// Appends the entered member to the local list only. No API call.
  ///
  /// Name, age, gender, and role are required: invalid input blocks the
  /// add and shows an error under each missing field.
  void _onAddMember() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final name = _nameController.text.trim();
    final age = _ageController.text.trim();
    final gender = _gender!;
    final role = _role!;
    final isParent = role == 'Parent';
    const avatarColors = [_peach, _pink, _blue];
    _nameController.clear();
    _ageController.clear();
    setState(() {
      _members.add(
        FamilySetupMember(
          id: 'custom-${DateTime.now().microsecondsSinceEpoch}',
          name: name,
          age: age,
          gender: gender,
          role: role,
          avatarColor: avatarColors[_members.length % avatarColors.length],
          glyph: _glyphFor(gender: gender, isParent: isParent),
          photoBytes: _photoBytes,
        ),
      );
<<<<<<< HEAD
      _photoPath = null;
      _role = widget.initialRole ?? FamilySetupOptions.roles.first;
      _gender = FamilySetupOptions.genders.first;
=======
      _photoBytes = null;
      _gender = null;
      _role = null;
      _fieldResetId++;
>>>>>>> 48e512845754349ab492b180d4e531d2082a5fd4
    });
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      // Web-safe: bytes via XFile.readAsBytes; null means the user
      // cancelled, which is silently ignored.
      final bytes = await pickAvatarBytes(_picker, source);
      if (bytes != null && mounted) {
        setState(() => _photoBytes = bytes);
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open camera/gallery.')),
      );
    }
  }

  void _choosePhotoSource() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Add a profile picture'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _pickPhoto(ImageSource.camera);
            },
            child: const Row(
              children: [
                Icon(Icons.photo_camera_outlined),
                SizedBox(width: 12),
                Text('Take a photo'),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _pickPhoto(ImageSource.gallery);
            },
            child: const Row(
              children: [
                Icon(Icons.photo_library_outlined),
                SizedBox(width: 12),
                Text('Choose from gallery'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onDoneLater() {
    // Focus picker shelved: straight to profile setup, all areas on.
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProfileSetupScreen(
          focusAreas: FocusAreas.all,
          familyMembers: _members,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hintText}) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: _cardBorderSide,
    );
    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: _error),
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
      errorBorder: errorBorder,
      focusedErrorBorder: errorBorder,
      errorStyle: const TextStyle(
        fontFamily: 'Nunito',
        fontWeight: FontWeight.w600,
        fontSize: 12,
        color: _error,
      ),
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

  Widget _dropdownField({
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
    required String hintText,
    required FormFieldValidator<String> validator,
  }) {
    return _shadowedInput(
      DropdownButtonFormField<String>(
        key: ValueKey('$hintText-$_fieldResetId'),
        initialValue: value,
        isExpanded: true,
        items: [
          for (final option in options)
            DropdownMenuItem(value: option, child: Text(option)),
        ],
        onChanged: onChanged,
        validator: validator,
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          size: 20,
          color: _mute,
        ),
        style: _inputTextStyle,
        dropdownColor: _white,
        decoration: _inputDecoration(hintText: hintText),
      ),
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
        if (_members.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Text(
              'No members yet. Add your first member below.',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: _mute,
              ),
            ),
          )
        else
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
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
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
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                style: _inputTextStyle,
                decoration: _inputDecoration(hintText: 'Enter name'),
                validator: (value) =>
                    value == null || value.trim().isEmpty
                        ? 'Name is required'
                        : null,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _labeledField(
            label: 'Age',
            input: _shadowedInput(
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: _inputTextStyle,
                decoration: _inputDecoration(),
                validator: (value) =>
                    value == null || value.trim().isEmpty
                        ? 'Enter an age'
                        : null,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _labeledField(
            label: 'Gender',
            input: _dropdownField(
              value: _gender,
              options: FamilySetupOptions.genders,
              onChanged: (value) => setState(() => _gender = value),
              hintText: 'Select gender',
              validator: (value) => value == null || value.isEmpty
                  ? 'Select a gender'
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          _labeledField(
            label: 'Role',
            input: _dropdownField(
              value: _role,
              options: FamilySetupOptions.roles,
              onChanged: (value) => setState(() => _role = value),
              hintText: 'Select role',
              validator: (value) =>
                  value == null || value.isEmpty ? 'Choose a role' : null,
            ),
          ),
        const SizedBox(height: 12),
        _labeledField(
          label: 'Profile picture',
          input: _shadowedInput(
            Material(
              color: _white,
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                key: const Key('add-member-photo'),
                onTap: _choosePhotoSource,
                borderRadius: BorderRadius.circular(18),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  child: Row(
                    children: [
                      MemberAvatar(
                        bytes: _photoBytes,
                        name: _nameController.text.trim(),
                        background: _peach,
                        size: 40,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _photoBytes == null
                              ? 'Choose a photo (optional)'
                              : 'Photo selected — tap to change',
                          style: _inputTextStyle,
                        ),
                      ),
                      const Icon(
                        Icons.add_a_photo_outlined,
                        size: 20,
                        color: _mute,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        ],
      ),
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

/// One existing-member row: avatar, name/detail block, trailing.
class _MemberCard extends StatelessWidget {
  const _MemberCard({required this.member, required this.onTap});

  final FamilySetupMember member;
  final VoidCallback onTap;

  static const Color _ink = Color(0xFF2B3A2B);
  static const Color _mute = Color(0xFF7C877A);
  static const Color _yellowLight = Color(0xFFFDF0C8);
  static const Color _lavender = Color(0xFFDDD5EE);
  static const Color _white = Color(0xFFFFFFFF);

  Widget _trailing() {
    if (member.isKids) return _modePill('Kids Mode', _yellowLight);
    if (member.isTeen) return _modePill('Teen Mode', _lavender);
    return const Icon(
      Icons.chevron_right_rounded,
      size: 20,
      color: _mute,
    );
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
                MemberAvatar(
                  bytes: member.photoBytes,
                  imageUrl: member.avatarUrl,
                  name: member.name,
                  background: member.avatarColor,
                  size: 40,
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
