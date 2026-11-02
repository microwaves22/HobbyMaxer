import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A family profile entry shown in the avatar dropdown.
class ProfileOption {
  const ProfileOption({
    required this.name,
    required this.roleLabel,
    this.avatarColor = AppColors.sage,
  });

  final String name;
  final String roleLabel;
  final Color avatarColor;

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
class ProfileAvatarDropdown extends StatelessWidget {
  const ProfileAvatarDropdown({
    super.key,
    required this.active,
    this.profiles = const [],
    this.onSwitchProfile,
    this.onAccountSettings,
  });

  final ProfileOption active;
  final List<ProfileOption> profiles;
  final ValueChanged<ProfileOption>? onSwitchProfile;
  final VoidCallback? onAccountSettings;

  @override
  Widget build(BuildContext context) {
    final others = profiles.where((p) => p.name != active.name).toList();
    return PopupMenuButton<_MenuAction>(
      tooltip: 'Profile',
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      onSelected: (action) {
        // Profile taps are handled per-item via onTap; only settings
        // needs handling here.
        if (action == _MenuAction.settings) onAccountSettings?.call();
      },
      itemBuilder: (context) => [
        PopupMenuItem<_MenuAction>(
          enabled: false,
          child: Row(
            children: [
              _Avatar(option: active, radius: 18),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    active.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    active.roleLabel,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        for (final profile in others)
          PopupMenuItem<_MenuAction>(
            value: _MenuAction.profile,
            onTap: () => onSwitchProfile?.call(profile),
            child: Row(
              children: [
                _Avatar(option: profile, radius: 14),
                const SizedBox(width: 12),
                Expanded(child: Text(profile.name)),
                const Icon(Icons.swap_horiz, size: 18),
              ],
            ),
          ),
        if (others.isNotEmpty) const PopupMenuDivider(),
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
      child: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: _Avatar(option: active, radius: 18),
      ),
    );
  }
}

enum _MenuAction { profile, settings }

class _Avatar extends StatelessWidget {
  const _Avatar({required this.option, required this.radius});

  final ProfileOption option;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: option.avatarColor,
      child: Text(
        option.initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.8,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
