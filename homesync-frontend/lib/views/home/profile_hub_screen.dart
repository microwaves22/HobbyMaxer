import 'dart:ui';

import 'package:flutter/material.dart';

// Figma tokens (screen-only): hard-coded here because they differ from the
// shared theme (`AppColors` cream/sage/ink predate this design). Do not move
// them into the theme files: no other screen uses these values.
const _ink = Color(0xFF2B3A2B);
const _mute = Color(0xFF7C877A);
const _sage = Color(0xFF5F7F55);
const _sageDark = Color(0xFF4A6A41);
const _sageLight = Color(0xFFE4EBDC);
const _yellowLight = Color(0xFFFDF0C8);
const _peach = Color(0xFFF6D9C4);
const _pink = Color(0xFFF4C9C9);
const _line = Color(0xFFE8E4D8);
const _white = Color(0xFFFFFFFF);
const _cream = Color(0xFFFBF7EF);
const _cardFill = Color.fromRGBO(255, 255, 255, 0.72);
const _cardBorder = Color.fromRGBO(255, 255, 255, 0.91);
const _cardShadow = Color.fromRGBO(59, 77, 56, 0.07);
const _dim = Color.fromRGBO(38, 57, 44, 0.07);
const _dropdownBg = Color.fromRGBO(255, 252, 245, 0.95);
const _dropdownBorder = Color.fromRGBO(255, 255, 255, 0.94);
const _dropdownShadow = Color.fromRGBO(38, 57, 44, 0.15);
const _navFill = Color.fromRGBO(255, 255, 255, 0.8);
const _darkPreview = Color(0xFF203B32);
const _systemPreview = Color(0xFFEDEFE8);
const _transparentFill = Color.fromRGBO(255, 255, 255, 0);

/// One family summary stat (value over label).
class _SummaryStat {
  const _SummaryStat({required this.value, required this.label});

  final String value;
  final String label;
}

const _summaryStats = <_SummaryStat>[
  _SummaryStat(value: '3', label: 'Events'),
  _SummaryStat(value: '4', label: 'Tasks due'),
  _SummaryStat(value: '2', label: 'To approve'),
];

/// One "Today's Overview" item.
class _OverviewItem {
  const _OverviewItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;
}

const _overviewItems = <_OverviewItem>[
  _OverviewItem(
    icon: Icons.checklist_rounded,
    title: 'Laundry · Put away clothes',
    subtitle: 'Due today by 7 PM',
  ),
  _OverviewItem(
    icon: Icons.checklist_rounded,
    title: 'Math Homework',
    subtitle: 'Due by 6 PM',
  ),
  _OverviewItem(
    icon: Icons.group_rounded,
    title: 'Family Dinner',
    subtitle: 'Today at 7 PM',
  ),
];

/// One bottom-navigation tab.
class _NavTab {
  const _NavTab({required this.id, required this.label, required this.icon});

  final String id;
  final String label;
  final IconData icon;
}

const _navTabs = <_NavTab>[
  _NavTab(id: 'home', label: 'Home', icon: Icons.home_rounded),
  _NavTab(id: 'calendar', label: 'Calendar', icon: Icons.calendar_month_rounded),
  _NavTab(id: 'tasks', label: 'Tasks', icon: Icons.checklist_rounded),
  _NavTab(id: 'family', label: 'Family', icon: Icons.group_rounded),
];

/// One appearance theme option. Selection styling is derived from state.
class _ThemeOption {
  const _ThemeOption({
    required this.id,
    required this.name,
    required this.icon,
    required this.previewBackground,
    required this.iconColor,
  });

  final String id;
  final String name;
  final IconData icon;
  final Color previewBackground;
  final Color iconColor;
}

const _themeOptions = <_ThemeOption>[
  _ThemeOption(
    id: 'light',
    name: 'Light',
    icon: Icons.wb_sunny_rounded,
    previewBackground: _cream,
    iconColor: _ink,
  ),
  _ThemeOption(
    id: 'dark',
    name: 'Dark',
    icon: Icons.nightlight_rounded,
    previewBackground: _darkPreview,
    iconColor: _white,
  ),
  _ThemeOption(
    id: 'system',
    name: 'System',
    icon: Icons.monitor_rounded,
    previewBackground: _systemPreview,
    iconColor: _ink,
  ),
];

/// One profile in the switcher. Selection styling is derived from state.
class _HubProfile {
  const _HubProfile({
    required this.id,
    required this.name,
    required this.detail,
    required this.avatarBackground,
    required this.avatarContent,
    required this.avatarContentSize,
  });

  final String id;
  final String name;
  final String detail;
  final Color avatarBackground;

  /// Verbatim avatar content: an emoji glyph or (for Noah) the letter "N".
  final String avatarContent;
  final double avatarContentSize;
}

const _hubProfiles = <_HubProfile>[
  _HubProfile(
    id: 'sarah',
    name: 'Sarah',
    detail: 'Parent · Active',
    avatarBackground: _peach,
    avatarContent: '👩',
    avatarContentSize: 23,
  ),
  _HubProfile(
    id: 'ava',
    name: 'Ava',
    detail: '8 years · Kids Mode',
    avatarBackground: _pink,
    avatarContent: '🐱',
    avatarContentSize: 23,
  ),
  _HubProfile(
    id: 'noah',
    name: 'Noah',
    detail: '14 years · Teen Mode',
    avatarBackground: _sageLight,
    avatarContent: 'N',
    avatarContentSize: 16,
  ),
];

/// Figma "Profile hub dropdown" (node 62:5787): the parent Home dashboard
/// with the profile dropdown menu OPEN over it.
///
/// Layered presentation: dashboard content with the bottom navigation pinned
/// at the bottom, a dimming overlay over the dashboard block (header and
/// bottom nav stay undimmed), an anchor caret, and the profile dropdown card.
class ProfileHubScreen extends StatefulWidget {
  const ProfileHubScreen({
    super.key,
    this.menuOpen = true,
    this.onToggleProfileMenu,
    this.onDismissProfileMenu,
    this.onSelectTheme,
    this.onSwitchProfile,
    this.onAccountSettings,
    this.onNavigate,
  });

  /// Whether the dropdown starts open. Defaults to true (the designed state).
  final bool menuOpen;

  /// Called after the header avatar toggles the menu.
  final VoidCallback? onToggleProfileMenu;

  /// Called after tapping the dimming overlay closes the menu.
  final VoidCallback? onDismissProfileMenu;

  /// Called with the selected theme id. Selection is UI state only.
  final ValueChanged<String>? onSelectTheme;

  /// Called with the selected profile id.
  final ValueChanged<String>? onSwitchProfile;

  /// Called from the Account settings row. Defaults to a no-op placeholder.
  final VoidCallback? onAccountSettings;

  /// Called with the tapped tab id. Defaults to a no-op for Home and a
  /// placeholder for tabs whose routes do not exist yet.
  final ValueChanged<String>? onNavigate;

  @override
  State<ProfileHubScreen> createState() => _ProfileHubScreenState();
}

class _ProfileHubScreenState extends State<ProfileHubScreen> {
  late bool _menuOpen = widget.menuOpen;
  String _selectedThemeId = 'light';
  String _selectedProfileId = 'sarah';

  void _toggleProfileMenu() {
    setState(() => _menuOpen = !_menuOpen);
    widget.onToggleProfileMenu?.call();
  }

  void _dismissProfileMenu() {
    setState(() => _menuOpen = false);
    widget.onDismissProfileMenu?.call();
  }

  void _selectTheme(String themeId) {
    setState(() => _selectedThemeId = themeId);
    widget.onSelectTheme?.call(themeId);
  }

  void _switchProfile(String profileId) {
    setState(() => _selectedProfileId = profileId);
    widget.onSwitchProfile?.call(profileId);
  }

  void _handleAccountSettings() {
    if (widget.onAccountSettings != null) {
      widget.onAccountSettings!();
    } else {
      // TODO: navigate to Account settings once that route exists.
    }
  }

  void _handleNavigate(String tabId) {
    if (widget.onNavigate != null) {
      widget.onNavigate!(tabId);
      return;
    }
    if (tabId == 'home') return; // Already on Home.
    // TODO: push the Calendar/Tasks/Family screen once its route exists.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _Dashboard(
                            menuOpen: _menuOpen,
                            onAvatarTap: _toggleProfileMenu,
                            onOverlayTap: _dismissProfileMenu,
                          ),
                          _BottomNav(
                            activeTabId: 'home',
                            onNavigate: _handleNavigate,
                          ),
                        ],
                      ),
                      if (_menuOpen) ...[
                        const Positioned(
                          top: 61,
                          right: 33,
                          child: _AnchorCaret(),
                        ),
                        Positioned(
                          top: 72,
                          right: 20,
                          width: 293,
                          child: _ProfileDropdown(
                            selectedThemeId: _selectedThemeId,
                            selectedProfileId: _selectedProfileId,
                            onSelectTheme: _selectTheme,
                            onSwitchProfile: _switchProfile,
                            onAccountSettings: _handleAccountSettings,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Layer 1A: greeting header plus summary, overview, approvals, and
/// encouragement blocks. When the menu is open, everything below the header
/// is covered by the dimming overlay.
class _Dashboard extends StatelessWidget {
  const _Dashboard({
    required this.menuOpen,
    required this.onAvatarTap,
    required this.onOverlayTap,
  });

  final bool menuOpen;
  final VoidCallback onAvatarTap;
  final VoidCallback onOverlayTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, left: 20, right: 20),
          child: _HeaderRow(onAvatarTap: onAvatarTap),
        ),
        const SizedBox(height: 14),
        Stack(
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SummaryRow(),
                  SizedBox(height: 14),
                  _OverviewCard(),
                  SizedBox(height: 14),
                  _ApprovalsCard(),
                  SizedBox(height: 14),
                  _EncouragementCard(),
                ],
              ),
            ),
            if (menuOpen)
              Positioned.fill(
                child: ModalBarrier(
                  color: _dim,
                  dismissible: true,
                  onDismiss: onOverlayTap,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Dashboard header: greeting plus the avatar menu trigger.
class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.onAvatarTap});

  final VoidCallback onAvatarTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(
          child: Text(
            'Good morning, Sarah!',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w800,
              fontSize: 24,
              height: 1.35,
              color: _ink,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Semantics(
          label: 'Profile menu',
          button: true,
          onTap: onAvatarTap,
          excludeSemantics: true,
          child: Material(
            color: _peach,
            borderRadius: BorderRadius.circular(999),
            child: InkWell(
              onTap: onAvatarTap,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: _white),
                ),
                child: const Text(
                  '👩',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w800,
                    fontSize: 23,
                    color: _sageDark,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Family summary row: three stat cards mapped from [_summaryStats].
class _SummaryRow extends StatelessWidget {
  const _SummaryRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < _summaryStats.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _cardFill,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _summaryStats[i].value,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w800,
                      fontSize: 25,
                      height: 1.35,
                      color: _ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _summaryStats[i].label,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                      height: 1.35,
                      color: _ink,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// "Today's Overview" card with items mapped from [_overviewItems].
class _OverviewCard extends StatelessWidget {
  const _OverviewCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardFill,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _cardBorder),
        boxShadow: const [
          BoxShadow(
            color: _cardShadow,
            offset: Offset(0, 5),
            blurRadius: 16,
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Today's Overview",
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w800,
              fontSize: 17,
              height: 1.35,
              color: _ink,
            ),
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < _overviewItems.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(_overviewItems[i].icon, size: 20, color: _ink),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _overviewItems[i].title,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            height: 1.35,
                            color: _ink,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _overviewItems[i].subtitle,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w500,
                            fontSize: 11,
                            height: 1.35,
                            color: _mute,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Pending-approvals card.
class _ApprovalsCard extends StatelessWidget {
  const _ApprovalsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _sageLight,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _cardBorder),
        boxShadow: const [
          BoxShadow(
            color: _cardShadow,
            offset: Offset(0, 5),
            blurRadius: 16,
            spreadRadius: -4,
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '2 pending approvals',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w800,
              fontSize: 14,
              height: 1.35,
              color: _ink,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Ava submitted Fold Laundry for review.',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w500,
              fontSize: 12,
              height: 1.35,
              color: _ink,
            ),
          ),
        ],
      ),
    );
  }
}

/// Encouragement card.
class _EncouragementCard extends StatelessWidget {
  const _EncouragementCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _yellowLight,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _cardBorder),
        boxShadow: const [
          BoxShadow(
            color: _cardShadow,
            offset: Offset(0, 5),
            blurRadius: 16,
            spreadRadius: -4,
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'A little teamwork goes a long way',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w800,
              fontSize: 13,
              height: 1.35,
              color: _ink,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Your family is making great progress today.',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w500,
              fontSize: 12,
              height: 1.35,
              color: _ink,
            ),
          ),
        ],
      ),
    );
  }
}

/// Layer 1B: bottom navigation pinned at the bottom of the home column.
/// (No home-indicator bar: the project does not draw its own; the
/// platform provides it.)
class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.activeTabId, required this.onNavigate});

  final String activeTabId;
  final ValueChanged<String> onNavigate;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _navFill,
      padding: const EdgeInsets.only(top: 12, left: 20, right: 20, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (final tab in _navTabs)
            _NavTabButton(
              tab: tab,
              active: tab.id == activeTabId,
              onTap: () => onNavigate(tab.id),
            ),
        ],
      ),
    );
  }
}

/// One bottom-navigation tab: 64px wide, icon over label.
class _NavTabButton extends StatelessWidget {
  const _NavTabButton({
    required this.tab,
    required this.active,
    required this.onTap,
  });

  final _NavTab tab;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? _sage : _mute;
    return Semantics(
      label: tab.label,
      button: true,
      selected: active,
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 64,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(tab.icon, size: 23, color: color),
                const SizedBox(height: 4),
                Text(
                  tab.label,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 11,
                    height: 1.35,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Layer 3: anchor caret pointing up at the avatar. The project has no
/// popover-caret pattern or exported anchor asset, so this draws the
/// specified 20 × 16 triangle in the dropdown background color.
class _AnchorCaret extends StatelessWidget {
  const _AnchorCaret();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 20,
      height: 16,
      child: CustomPaint(painter: _CaretPainter()),
    );
  }
}

class _CaretPainter extends CustomPainter {
  const _CaretPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = _dropdownBg);
  }

  @override
  bool shouldRepaint(_CaretPainter oldDelegate) => false;
}

/// Layer 4: the profile dropdown card. Frosted the same way as the shared
/// LiquidGlassCard pattern (clip + 12px backdrop blur), with this design's own
/// background, border, radius, and shadow. The shadow lives on the outer
/// container so the clip does not cut it off.
class _ProfileDropdown extends StatelessWidget {
  const _ProfileDropdown({
    required this.selectedThemeId,
    required this.selectedProfileId,
    required this.onSelectTheme,
    required this.onSwitchProfile,
    required this.onAccountSettings,
  });

  final String selectedThemeId;
  final String selectedProfileId;
  final ValueChanged<String> onSelectTheme;
  final ValueChanged<String> onSwitchProfile;
  final VoidCallback onAccountSettings;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: _dropdownShadow,
            offset: Offset(0, 8),
            blurRadius: 28,
            spreadRadius: -4,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _dropdownBg,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _dropdownBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _CurrentAccount(),
                const SizedBox(height: 15),
                _AccountSettingsRow(onTap: onAccountSettings),
                const SizedBox(height: 15),
                const _Divider(),
                const SizedBox(height: 15),
                _Appearance(
                  selectedThemeId: selectedThemeId,
                  onSelectTheme: onSelectTheme,
                ),
                const SizedBox(height: 15),
                const _Divider(),
                const SizedBox(height: 15),
                _SwitchProfile(
                  selectedProfileId: selectedProfileId,
                  onSwitchProfile: onSwitchProfile,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Dropdown block 1: current account.
class _CurrentAccount extends StatelessWidget {
  const _CurrentAccount();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _peach,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: _white),
          ),
          child: const Text(
            '👩',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w800,
              fontSize: 23,
              color: _sageDark,
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sarah',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  height: 1.35,
                  color: _ink,
                ),
              ),
              SizedBox(height: 1),
              Text(
                'Mom · Parent',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  height: 1.35,
                  color: _mute,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        const Icon(Icons.check, size: 18, color: _sage),
      ],
    );
  }
}

/// Dropdown block 2: account settings row.
class _AccountSettingsRow extends StatelessWidget {
  const _AccountSettingsRow({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 7),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.manage_accounts_rounded, size: 20, color: _ink),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Account settings',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    height: 1.35,
                    color: _ink,
                  ),
                ),
              ),
              SizedBox(width: 10),
              Icon(Icons.chevron_right_rounded, size: 16, color: _mute),
            ],
          ),
        ),
      ),
    );
  }
}

/// 1px divider between dropdown blocks.
class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: _line);
  }
}

/// Dropdown block 3: appearance theme picker.
class _Appearance extends StatelessWidget {
  const _Appearance({
    required this.selectedThemeId,
    required this.onSelectTheme,
  });

  final String selectedThemeId;
  final ValueChanged<String> onSelectTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'APPEARANCE',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w800,
            fontSize: 11,
            height: 1.35,
            color: _mute,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            for (var i = 0; i < _themeOptions.length; i++) ...[
              if (i > 0) const SizedBox(width: 6),
              Expanded(
                child: _ThemeOptionTile(
                  option: _themeOptions[i],
                  selected: _themeOptions[i].id == selectedThemeId,
                  onTap: () => onSelectTheme(_themeOptions[i].id),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        const Text(
          'Dark uses our Midnight Sage palette.',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w500,
            fontSize: 11,
            height: 1.35,
            color: _mute,
          ),
        ),
      ],
    );
  }
}

/// One theme option: preview tile plus label.
class _ThemeOptionTile extends StatelessWidget {
  const _ThemeOptionTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _ThemeOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: option.name,
      button: true,
      selected: selected,
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: option.previewBackground,
                  borderRadius: BorderRadius.circular(13),
                  border: selected
                      ? Border.all(color: _sage, width: 2)
                      : Border.all(color: _white),
                ),
                child: Icon(option.icon, size: 20, color: option.iconColor),
              ),
              const SizedBox(height: 6),
              Text(
                selected ? '${option.name} ✓' : option.name,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  fontSize: 11,
                  height: 1.35,
                  color: _ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dropdown block 4: profile switcher.
class _SwitchProfile extends StatelessWidget {
  const _SwitchProfile({
    required this.selectedProfileId,
    required this.onSwitchProfile,
  });

  final String selectedProfileId;
  final ValueChanged<String> onSwitchProfile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SWITCH PROFILE',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w800,
            fontSize: 11,
            height: 1.35,
            color: _mute,
          ),
        ),
        const SizedBox(height: 7),
        for (var i = 0; i < _hubProfiles.length; i++) ...[
          if (i > 0) const SizedBox(height: 7),
          _ProfileRow(
            profile: _hubProfiles[i],
            selected: _hubProfiles[i].id == selectedProfileId,
            onTap: () => onSwitchProfile(_hubProfiles[i].id),
          ),
        ],
      ],
    );
  }
}

/// One profile row in the switcher.
class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.profile,
    required this.selected,
    required this.onTap,
  });

  final _HubProfile profile;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: profile.name,
      button: true,
      selected: selected,
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: selected ? _sageLight : _transparentFill,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: profile.avatarBackground,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: _white),
                  ),
                  child: Text(
                    profile.avatarContent,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w800,
                      fontSize: profile.avatarContentSize,
                      color: _sageDark,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.name,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          height: 1.35,
                          color: _ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        profile.detail,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                          height: 1.35,
                          color: _mute,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  selected ? Icons.check : Icons.chevron_right_rounded,
                  size: 16,
                  color: selected ? _sage : _mute,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
