import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/widgets/member_avatar.dart';

import 'family_member.dart';
import 'members_api.dart';

/// Member editor for the 03 Set Up Family flow (parent side).
///
/// Every field of [member] is editable here: name, age, gender, profile
/// picture, and account role (Kids / Teen / Parent). Saving pops a
/// [MemberUpdated]; the Delete button confirms, then pops a [MemberDeleted].
/// The back button pops nothing (no change).
class MemberDetailScreen extends StatefulWidget {
  const MemberDetailScreen({
    super.key,
    required this.member,
    this.onBack,
    this.membersApi,
  });

  /// The member being edited (a copy is edited; the original is untouched
  /// until Save).
  final FamilySetupMember member;

  /// Back button placeholder. Falls back to [Navigator.maybePop].
  final VoidCallback? onBack;

  /// Avatar upload client. Null keeps photos as in-memory previews.
  final MembersApi? membersApi;

  @override
  State<MemberDetailScreen> createState() => _MemberDetailScreenState();
}

class _MemberDetailScreenState extends State<MemberDetailScreen> {
  // Screen-only tokens matching family_setup_screen.dart.
  static const Color _cream = Color(0xFFFBF7EF);
  static const Color _ink = Color(0xFF2B3A2B);
  static const Color _mute = Color(0xFF7C877A);
  static const Color _sage = Color(0xFF5F7F55);
  static const Color _white = Color(0xFFFFFFFF);
  static const Color _danger = Color(0xFFB3261E);

  static const TextStyle _inputTextStyle = TextStyle(
    fontFamily: 'Nunito',
    fontWeight: FontWeight.w600,
    fontSize: 16,
    color: _ink,
  );

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _ageController;
  String? _gender;
  String? _role;
  Uint8List? _photoBytes;
  String? _avatarUrl;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.member.name);
    _ageController = TextEditingController(text: widget.member.age);
    _gender = FamilySetupOptions.genders.contains(widget.member.gender)
        ? widget.member.gender
        : null;
    _role = FamilySetupOptions.roles.contains(widget.member.role)
        ? widget.member.role
        : null;
    _photoBytes = widget.member.photoBytes;
    _avatarUrl = widget.member.avatarUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop<MemberEditResult>(
      MemberUpdated(
        widget.member.copyWith(
          name: _nameController.text.trim(),
          age: _ageController.text.trim(),
          gender: _gender!,
          role: _role!,
          photoBytes: _photoBytes,
          avatarUrl: _avatarUrl,
          clearPhoto: _photoBytes == null && _avatarUrl == null,
        ),
      ),
    );
  }

  Future<void> _onDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete member?'),
        content: Text(
          '${widget.member.name} will be removed from your family.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: _danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      Navigator.of(context).pop<MemberEditResult>(
        MemberDeleted(widget.member.id),
      );
    }
  }

  Future<void> _pickPhoto(ImageSource source) async {
    Uint8List? bytes;
    try {
      // Web-safe: bytes via XFile.readAsBytes; null means the user
      // cancelled, which is silently ignored.
      bytes = await pickAvatarBytes(_picker, source);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open camera/gallery.')),
      );
      return;
    }
    if (bytes == null || !mounted) return;
    setState(() => _photoBytes = bytes);
    await _uploadAvatar(bytes);
  }

  /// Persists freshly picked bytes via `POST /members/{id}/avatar` when
  /// the member is backend-synced. Failures keep the bytes preview and
  /// tell the user the picture is not saved yet.
  Future<void> _uploadAvatar(Uint8List bytes) async {
    final api = widget.membersApi;
    final serverId = widget.member.serverId;
    if (api == null || serverId == null) return;
    try {
      final url = await api.uploadAvatarUrl(serverId, bytes);
      if (url != null && mounted) setState(() => _avatarUrl = url);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Photo picked, but upload failed.')),
      );
    }
  }

  void _choosePhotoSource() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Profile picture'),
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
          if (_photoBytes != null || _avatarUrl != null)
            SimpleDialogOption(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                setState(() {
                  _photoBytes = null;
                  _avatarUrl = null;
                });
              },
              child: const Row(
                children: [
                  Icon(Icons.delete_outline_rounded),
                  SizedBox(width: 12),
                  Text('Remove photo'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({String? hintText}) {
    const border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(18)),
      borderSide: BorderSide(color: Color(0xF2FFFFFF)),
    );
    const errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(18)),
      borderSide: BorderSide(color: _danger),
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
        color: _danger,
      ),
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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x173B4D38),
            offset: Offset(0, 5),
            blurRadius: 16,
            spreadRadius: -4,
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
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
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  key: const Key('member-detail-back'),
                  onTap: widget.onBack ??
                      () => Navigator.of(context).maybePop(),
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
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(child: _buildAvatar()),
                      const SizedBox(height: 16),
                      _labeledField(
                        label: 'Name',
                        input: TextFormField(
                          controller: _nameController,
                          textCapitalization: TextCapitalization.words,
                          style: _inputTextStyle,
                          decoration:
                              _inputDecoration(hintText: 'Enter name'),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                                  ? 'Name is required'
                                  : null,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _labeledField(
                        label: 'Age',
                        input: TextFormField(
                          controller: _ageController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          style: _inputTextStyle,
                          decoration: _inputDecoration(),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                                  ? 'Enter an age'
                                  : null,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _labeledField(
                        label: 'Gender',
                        input: _dropdownField(
                          value: _gender,
                          options: FamilySetupOptions.genders,
                          onChanged: (value) =>
                              setState(() => _gender = value),
                          hintText: 'Select gender',
                          validator: (value) =>
                              value == null || value.isEmpty
                                  ? 'Select a gender'
                                  : null,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _labeledField(
                        label: 'Account Role',
                        input: _dropdownField(
                          value: _role,
                          options: FamilySetupOptions.roles,
                          onChanged: (value) =>
                              setState(() => _role = value),
                          hintText: 'Select role',
                          validator: (value) => value == null || value.isEmpty
                              ? 'Choose a role'
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 54,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onSave,
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
                    'Save Changes',
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
                  onPressed: _onDelete,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: _white,
                    foregroundColor: _danger,
                    side: const BorderSide(color: _danger),
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
                    'Delete Member',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: _danger,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final name = _nameController.text.trim();
    return GestureDetector(
      key: const Key('member-detail-photo'),
      onTap: _choosePhotoSource,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MemberAvatar(
            bytes: _photoBytes,
            imageUrl: _avatarUrl,
            name: name.isEmpty ? widget.member.name : name,
            background: widget.member.avatarColor,
            size: 64,
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add_a_photo_outlined,
                size: 14,
                color: _mute,
              ),
              SizedBox(width: 6),
              Text(
                'Change photo',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: _mute,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
