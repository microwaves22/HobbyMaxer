import 'package:flutter/material.dart';

import '../household_routes.dart';

/// The universal household bottom navigation bar (Home / Calendar /
/// Tasks / Family), shared by every section-level screen so the tab bar
/// looks and behaves the same across the entire app.
///
/// Tapping a tab switches sections with replacement navigation (repeat
/// taps never stack duplicates); tapping the active tab is a no-op.
/// Pass an explicit [onNavigate] to override (tests, previews).
class HouseholdBottomNav extends StatelessWidget {
  const HouseholdBottomNav({
    super.key,
    required this.activeTabId,
    this.onNavigate,
  });

  /// Id of the highlighted tab (`home`, `calendar`, `tasks`, `family`),
  /// or null when the current screen is outside the tab family.
  final String? activeTabId;

  /// Called with the tapped tab id. When null, tabs switch with
  /// replacement navigation (no-op for the active tab itself).
  final ValueChanged<String>? onNavigate;

  void _handleNavigate(BuildContext context, String tabId) {
    if (onNavigate != null) {
      onNavigate!(tabId);
      return;
    }
    if (tabId == activeTabId) return;
    HouseholdRoutes.openTab(context, tabId);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        color: const Color.fromRGBO(255, 255, 255, 0.8),
        padding:
            const EdgeInsets.only(top: 12, left: 20, right: 20, bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final tab in _householdTabs)
              _HouseholdNavTabButton(
                tab: tab,
                active: tab.id == activeTabId,
                onTap: () => _handleNavigate(context, tab.id),
              ),
          ],
        ),
      ),
    );
  }
}

class _HouseholdNavTab {
  const _HouseholdNavTab({
    required this.id,
    required this.label,
    required this.icon,
  });

  final String id;
  final String label;
  final IconData icon;
}

const _householdTabs = <_HouseholdNavTab>[
  _HouseholdNavTab(id: 'home', label: 'Home', icon: Icons.home_rounded),
  _HouseholdNavTab(
      id: 'calendar', label: 'Calendar', icon: Icons.calendar_month_rounded),
  _HouseholdNavTab(id: 'tasks', label: 'Tasks', icon: Icons.checklist_rounded),
  _HouseholdNavTab(id: 'family', label: 'Family', icon: Icons.group_rounded),
];

/// One bottom-navigation tab: 64px wide, icon over label.
class _HouseholdNavTabButton extends StatelessWidget {
  const _HouseholdNavTabButton({
    required this.tab,
    required this.active,
    required this.onTap,
  });

  final _HouseholdNavTab tab;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF7A9A85);
    const mutedColor = Color(0xFF7C877A);
    final color = active ? activeColor : mutedColor;
    return GestureDetector(
      onTap: onTap,
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
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
