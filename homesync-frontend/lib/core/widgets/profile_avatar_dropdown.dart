import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'member_avatar.dart';

/// A family profile entry shown in the avatar dropdown.
class ProfileOption {
  const ProfileOption({
    required this.name,
    required this.roleLabel,
    this.avatarColor = AppColors.sage,
    this.isParent = false,
    this.avatarUrl,
    this.avatarBytes,
  });

  final String name;
  final String roleLabel;
  final Color avatarColor;

  /// Persisted avatar URL (backend `/avatars/...` resolved to full URL).
  final String? avatarUrl;

  /// Freshly picked avatar bytes (transient preview).
  final Uint8List? avatarBytes;

  /// Whether this profile has parent privileges. Switching *to* a parent
  /// profile from a child/teen profile requires the Parent PIN.
  final bool isParent;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.characters.take(2).toString().toUpperCase();
    }
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }
}

/// Top-right avatar that opens a dropdown menu for account settings
/// or switching profiles on a shared household device.
///
/// Switching from a child/teen profile to a parent profile prompts for
/// the Parent PIN before the switch is allowed.
class ProfileAvatarDropdown extends StatelessWidget {
  const ProfileAvatarDropdown({
    super.key,
    required this.active,
    this.profiles = const [],
    this.parentPin = '1234',
    this.avatar,
    this.onSwitchProfile,
    this.onAccountSettings,
    this.onManageFamily,
  });

  final ProfileOption active;
  final List<ProfileOption> profiles;

  /// Optional custom trigger widget (e.g. a screen's own avatar artwork).
  /// When null, the default initial-based avatar is used.
  final Widget? avatar;

  /// Demo Parent PIN. Wire to the backend (`POST /auth/switch-profile`)
  /// once API integration lands.
  final String parentPin;

  final ValueChanged<ProfileOption>? onSwitchProfile;
  final VoidCallback? onAccountSettings;
  final VoidCallback? onManageFamily;

  void _requestSwitch(BuildContext context, ProfileOption target) {
    if (active.isParent || !target.isParent) {
      onSwitchProfile?.call(target);
      return;
    }
    showDialog<bool>(
      context: context,
      builder: (_) => _ParentPinDialog(parentPin: parentPin),
    ).then((unlocked) {
      if (unlocked == true) onSwitchProfile?.call(target);
    });
  }

  @override
  Widget build(BuildContext context) {
    final pageContext = context;
    final others = profiles.where((p) => p.name != active.name).toList();
    return PopupMenuButton<_MenuAction>(
      tooltip: 'Profile',
      offset: const Offset(0, 48),
      padding: avatar != null ? EdgeInsets.zero : const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      onSelected: (action) {
        // Profile taps are handled per-item via onTap; only the
        // footer actions need handling here.
        if (action == _MenuAction.settings) onAccountSettings?.call();
        if (action == _MenuAction.family) onManageFamily?.call();
      },
      itemBuilder: (_) => [
        PopupMenuItem<_MenuAction>(
          enabled: false,
          child: Row(
            children: [
              _Avatar(option: active, radius: 18),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      active.name,
                      style: Theme.of(pageContext).textTheme.titleLarge,
                    ),
                    Text(
                      active.roleLabel,
                      style: Theme.of(pageContext).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        for (final profile in others)
          PopupMenuItem<_MenuAction>(
            value: _MenuAction.profile,
            onTap: () => _requestSwitch(pageContext, profile),
            child: Row(
              children: [
                _Avatar(option: profile, radius: 14),
                const SizedBox(width: 12),
                Expanded(child: Text(profile.name)),
                if (!active.isParent && profile.isParent)
                  const Icon(Icons.lock_outline, size: 18)
                else
                  const Icon(Icons.swap_horiz, size: 18),
              ],
            ),
          ),
        if (others.isNotEmpty) const PopupMenuDivider(),
        const PopupMenuItem<_MenuAction>(
          value: _MenuAction.family,
          child: Row(
            children: [
              Icon(Icons.group_outlined, size: 18),
              SizedBox(width: 12),
              Text('Manage family'),
            ],
          ),
        ),
        const PopupMenuItem<_MenuAction>(
          value: _MenuAction.settings,
          child: Row(
            children: [
              Icon(Icons.settings_outlined, size: 18),
              SizedBox(width: 12),
              Text('Account settings'),
            ],
          ),
        ),
      ],
      child: avatar ??
          Padding(
        padding: const EdgeInsets.only(right: 12),
        child: _Avatar(option: active, radius: 18),
      ),
    );
  }
}

enum _MenuAction { profile, family, settings }

/// PIN challenge shown when switching to a parent profile. Pops `true`
/// on a correct PIN, `false` when cancelled.
class _ParentPinDialog extends StatefulWidget {
  const _ParentPinDialog({required this.parentPin});

  final String parentPin;

  @override
  State<_ParentPinDialog> createState() => _ParentPinDialogState();
}

class _ParentPinDialogState extends State<_ParentPinDialog> {
  final _pinController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _unlock() {
    if (_pinController.text == widget.parentPin) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _error = 'Incorrect PIN. Try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Parent PIN required'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Enter the family parent PIN to switch to a parent profile.',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _pinController,
            obscureText: true,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'PIN',
              errorText: _error,
            ),
            onSubmitted: (_) => _unlock(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _unlock,
          child: const Text('Unlock'),
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.option, required this.radius});

  final ProfileOption option;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return MemberAvatar(
      bytes: option.avatarBytes,
      imageUrl: option.avatarUrl,
      name: option.name,
      background: option.avatarColor,
      size: radius * 2,
    );
  }
}
