import 'package:flutter/material.dart';

/// Noah Companion Drawer (Figma node 62:5907) data.
///
/// MOCK DATA — placeholder content only. This drawer performs no backend
/// calls and persists nothing; actions report through the drawer's
/// callbacks for the (unbuilt) parent to handle. Do NOT copy Ava's
/// drawer styling here — this panel deliberately differs.
class NoahCompanionPill {
  const NoahCompanionPill({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;
}

/// Wellbeing pills, verbatim with their Figma fills (all sage text).
const List<NoahCompanionPill> kNoahCompanionPills = [
  NoahCompanionPill(
    label: 'Thriving',
    background: Color(0xFFE4EBDC),
    foreground: Color(0xFF5F7F55),
  ),
  NoahCompanionPill(
    label: '☾ Rested',
    background: Color(0xFFFFFFFF),
    foreground: Color(0xFF5F7F55),
  ),
  NoahCompanionPill(
    label: '94% care',
    background: Color(0xFFFFFFFF),
    foreground: Color(0xFF5F7F55),
  ),
];

/// One care stat bar. The screen drives the sage fill width from
/// [percent].
class NoahCareStat {
  const NoahCareStat({
    required this.id,
    required this.label,
    required this.percent,
  });

  final String id;
  final String label;
  final int percent;
}

const List<NoahCareStat> kNoahCareStats = [
  NoahCareStat(id: 'nourishment', label: 'Nourishment', percent: 90),
  NoahCareStat(id: 'energy', label: 'Energy', percent: 98),
];

/// One "Make Ember yours" collection item. [icon] maps the Figma icon
/// name to the nearest Material glyph: palette → palette_rounded ·
/// swatch-book → color_lens_rounded (no swatch-book glyph exists) ·
/// house → home_rounded · lock-keyhole → lock_rounded.
class NoahCollectionItem {
  const NoahCollectionItem({
    required this.id,
    required this.name,
    required this.state,
    required this.icon,
    required this.locked,
  });

  final String id;
  final String name;
  final String state;
  final IconData icon;
  final bool locked;
}

/// Exactly 4 items in design order (2×2 grid).
const List<NoahCollectionItem> kNoahCollection = [
  NoahCollectionItem(
    id: 'forest-skin',
    name: 'Forest skin',
    state: 'Skin · Equipped',
    icon: Icons.palette_rounded,
    locked: false,
  ),
  NoahCollectionItem(
    id: 'moss-copper',
    name: 'Moss & copper',
    state: 'Palette · Owned',
    icon: Icons.color_lens_rounded,
    locked: false,
  ),
  NoahCollectionItem(
    id: 'woodland-den',
    name: 'Woodland den',
    state: 'Background · Equipped',
    icon: Icons.home_rounded,
    locked: false,
  ),
  NoahCollectionItem(
    id: 'moonstone-den',
    name: 'Moonstone den',
    state: 'Locked · 180 pts',
    icon: Icons.lock_rounded,
    locked: true,
  ),
];
