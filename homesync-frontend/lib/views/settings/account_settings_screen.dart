import 'package:flutter/material.dart';

import '../../core/network/auth_session.dart';
import '../customization/customization_screen.dart';
import 'child_pin_screen.dart';
import 'notification_settings_screen.dart';
import '../onboarding/join_circle_screen.dart';
import '../onboarding/link_kids_screen.dart';
import '../onboarding/models/user_profile.dart';
import '../onboarding/splash_screen.dart';

/// Account Settings: account info plus customization, family linking,
/// and sign-out options. Reached from the profile dropdown on every
/// home screen, for every role.
///
/// Follows the Settings screen pattern (cream scaffold, Nunito 26
/// ExtraBold title, white group cards).
class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({
    super.key,
    this.onBack,
    required this.profile,
  });

  /// Back button placeholder. Falls back to [Navigator.maybePop].
  final VoidCallback? onBack;

  /// The signed-in account these settings belong to.
  final UserProfile profile;

  static const Color _cream = Color(0xFFFBF7EF);
  static const Color _ink = Color(0xFF2B3A2B);
  static const Color _mute = Color(0xFF7C877A);
  static const Color _line = Color(0xFFE8E4D8);
  static const Color _white = Color(0xFFFFFFFF);
  static const Color _lavender = Color(0xFFDDD5EE);
  static const Color _blue = Color(0xFFCFE0EE);
  static const Color _sageLight = Color(0xFFE4EBDC);
  static const Color _pink = Color(0xFFF4C9C9);
  static const Color _peach = Color(0xFFF6D9C4);
  static const Color _mint = Color(0xFFD5E8D5);

  static const List<BoxShadow> _cardShadow = [
    BoxShadow(
      color: Color(0x173B4D38),
      offset: Offset(0, 5),
      blurRadius: 16,
      spreadRadius: -4,
    ),
  ];

  /// "Parent · Age 36"-style summary, without repeating the label when
  /// role and mode match.
  static String _summary(UserProfile profile) {
    final role = profile.role.label;
    final mode = profile.mode.label;
    final head = role == mode ? role : '$role · $mode';
    final age = profile.age();
    return '$head · ${age == null ? 'Age –' : 'Age $age'}';
  }

  Future<void> _signOut(BuildContext context) async {
    final session = AuthScope.maybeOf(context);
    if (session == null) return;
    await session.logout();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SplashScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final signedIn = AuthScope.maybeOf(context)?.isAuthenticated == true;
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
                      boxShadow: _cardShadow,
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
              _AccountCard(profile: profile),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                decoration: BoxDecoration(
                  color: _white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: _cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SettingsRow(
                      icon: Icons.auto_awesome_rounded,
                      tile: _lavender,
                      label: 'Customization',
                      sublabel: 'Avatar, background, and theme',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CustomizationScreen(),
                        ),
                      ),
                    ),
                    const Divider(height: 1, thickness: 1, color: _line),
                    _SettingsRow(
                      icon: Icons.group_rounded,
                      tile: _blue,
                      label: 'Link your kids',
                      sublabel: 'Share your family invite code',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const LinkKidsScreen(),
                        ),
                      ),
                    ),
                    const Divider(height: 1, thickness: 1, color: _line),
                    _SettingsRow(
                      icon: Icons.group_add_rounded,
                      tile: _sageLight,
                      label: 'Join a family circle',
                      sublabel: 'Link with an invite code',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const JoinCircleScreen(),
                        ),
                      ),
                    ),
                    if (signedIn && profile.isParent) ...[
                      const Divider(height: 1, thickness: 1, color: _line),
                      _SettingsRow(
                        icon: Icons.pin_rounded,
                        tile: _mint,
                        label: 'Child PINs',
                        sublabel: 'Kids log in with their own PIN',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ChildPinScreen(),
                          ),
                        ),
                      ),
                    ],
                    if (signedIn && profile.isParent) ...[
                      const Divider(height: 1, thickness: 1, color: _line),
                      _SettingsRow(
                        icon: Icons.notifications_rounded,
                        tile: _peach,
                        label: 'Notifications',
                        sublabel: 'Inbox and family preferences',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                const NotificationSettingsScreen(),
                          ),
                        ),
                      ),
                    ],
                    if (signedIn) ...[
                      const Divider(height: 1, thickness: 1, color: _line),
                      _SettingsRow(
                        icon: Icons.logout_rounded,
                        tile: _pink,
                        label: 'Sign out',
                        destructive: true,
                        onTap: () => _signOut(context),
                      ),
                    ],
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

/// Signed-in account card: avatar initial, name, and role summary.
class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final initial = profile.name.trim().isEmpty
        ? '?'
        : profile.name.trim().characters.first.toUpperCase();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AccountSettingsScreen._white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xF2FFFFFF)),
        boxShadow: AccountSettingsScreen._cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AccountSettingsScreen._sageLight,
              borderRadius: BorderRadius.circular(26),
            ),
            child: Text(
              initial,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w800,
                fontSize: 23,
                color: AccountSettingsScreen._ink,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: AccountSettingsScreen._ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AccountSettingsScreen._summary(profile),
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AccountSettingsScreen._mute,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One tappable options row: tinted tile icon, label, and chevron.
class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.tile,
    required this.label,
    this.sublabel,
    this.destructive = false,
    required this.onTap,
  });

  final IconData icon;
  final Color tile;
  final String label;
  final String? sublabel;
  final bool destructive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final labelColor =
        destructive ? Theme.of(context).colorScheme.error : AccountSettingsScreen._ink;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: sublabel == null ? 50 : 58,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: tile,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                icon,
                size: 18,
                color: AccountSettingsScreen._ink,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: labelColor,
                    ),
                  ),
                  if (sublabel != null)
                    Text(
                      sublabel!,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        height: 1.33,
                        color: AccountSettingsScreen._mute,
                      ),
                    ),
                ],
              ),
            ),
            if (!destructive)
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AccountSettingsScreen._mute,
              ),
          ],
        ),
      ),
    );
  }
}
