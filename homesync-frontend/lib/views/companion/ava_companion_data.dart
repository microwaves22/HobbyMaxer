import 'package:flutter/material.dart';

/// Ava Companion Drawer (Figma node 62:6040) data.
///
/// MOCK DATA — placeholder content only. This drawer performs no backend
/// calls and persists nothing; care actions report through
/// [AvaCompanionDrawer.onCareAction] for the (unbuilt) parent to handle.
class AvaCompanionPill {
  const AvaCompanionPill({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;
}

/// Mood/status pills, verbatim with their Figma fills.
const List<AvaCompanionPill> kAvaCompanionPills = [
  AvaCompanionPill(
    label: 'Care 80%',
    background: Color(0xFFE4EBDC),
    foreground: Color(0xFF5F7F55),
  ),
  AvaCompanionPill(
    label: '😊 Happy',
    background: Color(0xFFFDF0C8),
    foreground: Color(0xFF2B3A2B),
  ),
  AvaCompanionPill(
    label: '★ 120 pts',
    background: Color(0xFFFDF0C8),
    foreground: Color(0xFF2B3A2B),
  ),
];

/// One care stat bar. The screen drives the coral fill width from
/// [percent].
class AvaCareStat {
  const AvaCareStat({
    required this.id,
    required this.label,
    required this.percent,
  });

  final String id;
  final String label;
  final int percent;
}

const List<AvaCareStat> kAvaCareStats = [
  AvaCareStat(id: 'care', label: 'Care', percent: 80),
  AvaCareStat(id: 'energy', label: 'Energy', percent: 90),
];

/// One stacked care button. [id] is reported to `onCareAction`.
class AvaCareAction {
  const AvaCareAction({
    required this.id,
    required this.title,
    required this.subline,
  });

  final String id;
  final String title;
  final String subline;
}

const List<AvaCareAction> kAvaCareActions = [
  AvaCareAction(id: 'feed', title: 'Feed', subline: '🍎 3 apples'),
  AvaCareAction(id: 'play', title: 'Play', subline: "Let's have fun!"),
];

/// Chore-care card inventory pills, verbatim.
const List<String> kAvaInventoryPills = ['🍎 Apples ×3', '🧸 Toys ×2'];
