import 'package:flutter/material.dart';

/// Settings (Figma node 7:207) data + screen.
///
/// All values below are the real design: title-only header, two group
/// cards (Parent + App) with 10 rows in order, exact tile colors, the
/// Family-calendars sublabel, and the Dark Mode toggle (default OFF,
/// local-state only).
///
/// This screen intentionally has NO bottom navigation bar: Settings is
/// the one page outside the tab flow, reached and left via the AppBar
/// back affordance. This screen makes no API calls and persists nothing.
class SettingsRowData {
  const SettingsRowData({
    required this.id,
    required this.label,
    this.sublabel,
    required this.icon,
    required this.tile,
    this.hasToggle = false,
  });

  final String id;
  final String label;
  final String? sublabel;
  final IconData icon;
  final Color tile;
  final bool hasToggle;
}

/// Parent group rows (Figma 7:207), in design order.
const List<SettingsRowData> kParentSettingsRows = [
  SettingsRowData(
    id: 'manage-family',
    label: 'Manage Family',
    icon: Icons.group_rounded,
    tile: Color(0xFFCFE0EE),
  ),
  SettingsRowData(
    id: 'task-preferences',
    label: 'Task Preferences',
    icon: Icons.checklist_rounded,
    tile: Color(0xFFFDF0C8),
  ),
  SettingsRowData(
    id: 'notifications',
    label: 'Notification Settings',
    icon: Icons.notifications_rounded,
    tile: Color(0xFFF6D9C4),
  ),
  SettingsRowData(
    id: 'points-rewards',
    label: 'Points & Rewards',
    icon: Icons.star_rounded,
    tile: Color(0xFFFDF0C8),
  ),
  SettingsRowData(
    id: 'customization',
    label: 'Customization',
    icon: Icons.auto_awesome_rounded,
    tile: Color(0xFFDDD5EE),
  ),
  SettingsRowData(
    id: 'kids-teen-mode',
    label: 'Kids / Teen Mode',
    icon: Icons.favorite_rounded,
    tile: Color(0xFFF4C9C9),
  ),
  SettingsRowData(
    id: 'family-calendars',
    label: 'Family calendars',
    sublabel: 'Import calendars · See free time',
    icon: Icons.calendar_month_rounded,
    tile: Color(0xFFCFE0EE),
  ),
];

/// App group rows (Figma 7:207), in design order.
const List<SettingsRowData> kAppSettingsRows = [
  SettingsRowData(
    id: 'dark-mode',
    label: 'Dark Mode',
    icon: Icons.dark_mode_rounded,
    tile: Color(0xFFDDD5EE),
    hasToggle: true,
  ),
  SettingsRowData(
    id: 'help-support',
    label: 'Help & Support',
    icon: Icons.help_outline_rounded,
    tile: Color(0xFFE4EBDC),
  ),
  SettingsRowData(
    id: 'about',
    label: 'About HomeSync',
    icon: Icons.info_outline_rounded,
    tile: Color(0xFFCFE0EE),
  ),
];

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    this.parentRows = kParentSettingsRows,
    this.appRows = kAppSettingsRows,
    this.initialDarkMode = false,
    this.onRowPress,
    this.onDarkModeChange,
  });

  static const Color _cream = Color(0xFFF9F8F6);
  static const Color _ink = Color(0xFF2B3A2B);
  static const Color _mute = Color(0xFF7C877A);
  static const Color _sageMid = Color(0xFFA9BE9C);
  static const Color _line = Color(0xFFE8E4D8);
  static const Color _white = Color(0xFFFFFFFF);

  static const String _font = 'Nunito';

  /// Parent group rows (default: the 7 real rows).
  final List<SettingsRowData> parentRows;

  /// App group rows (default: the 3 real rows).
  final List<SettingsRowData> appRows;

  /// Toggle default: OFF in the design.
  final bool initialDarkMode;

  /// Called with the row id for navigation rows. The Dark Mode row
  /// toggles in place instead (see [onDarkModeChange]) and is not
  /// reported here.
  final ValueChanged<String>? onRowPress;

  /// Called with the new toggle value. Local-state only — no dark
  /// theme is wired in this design.
  final ValueChanged<bool>? onDarkModeChange;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _darkMode;

  @override
  void initState() {
    super.initState();
    _darkMode = widget.initialDarkMode;
  }

  void _toggleDarkMode() {
    setState(() => _darkMode = !_darkMode);
    widget.onDarkModeChange?.call(_darkMode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SettingsScreen._cream,
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
              const Text(
                'Settings',
                style: TextStyle(
                  fontFamily: SettingsScreen._font,
                  fontWeight: FontWeight.w800,
                  fontSize: 26,
                  color: SettingsScreen._ink,
                ),
              ),
              const SizedBox(height: 16),
              _buildGroup(widget.parentRows),
              const SizedBox(height: 16),
              _buildGroup(widget.appRows),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroup(List<SettingsRowData> rows) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      decoration: BoxDecoration(
        color: SettingsScreen._white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0)
              const Divider(
                height: 1,
                thickness: 1,
                color: SettingsScreen._line,
              ),
            _buildRow(rows[i]),
          ],
        ],
      ),
    );
  }

  Widget _buildRow(SettingsRowData row) {
    final tall = row.sublabel != null;
    return GestureDetector(
      onTap: row.hasToggle
          ? _toggleDarkMode
          : widget.onRowPress == null
              ? null
              : () => widget.onRowPress!(row.id),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: tall ? 53 : 50,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: row.tile,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                row.icon,
                size: 18,
                color: SettingsScreen._ink,
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
                    row.label,
                    style: const TextStyle(
                      fontFamily: SettingsScreen._font,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: SettingsScreen._ink,
                    ),
                  ),
                  if (row.sublabel != null)
                    Text(
                      row.sublabel!,
                      style: const TextStyle(
                        fontFamily: SettingsScreen._font,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        height: 1.33,
                        color: SettingsScreen._mute,
                      ),
                    ),
                ],
              ),
            ),
            if (row.hasToggle)
              _buildToggle()
            else
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: SettingsScreen._mute,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggle() {
    return GestureDetector(
      onTap: _toggleDarkMode,
      child: Container(
        width: 48,
        height: 28,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: SettingsScreen._sageMid,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Align(
          alignment:
              _darkMode ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: SettingsScreen._white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
