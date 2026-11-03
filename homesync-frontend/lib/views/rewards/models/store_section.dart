import 'package:flutter/material.dart';

/// 09 Rewards Store (Figma node 5:139) data layer.
///
/// WARNING: the Figma specs for node 5:139 were never retrieved
/// (Figma rate limit), so EVERY value below is a TODO placeholder shaped
/// by the sibling Rewards screens — NOT design content. Re-pull node
/// 5:139 from Figma and replace each TODO before calling this final.
/// This screen makes no API calls and moves no points.
class StoreReward {
  const StoreReward({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.points,
    required this.category,
    required this.affordableLabel,
    required this.previewBackground,
    required this.previewIcon,
  });

  final String id;
  final String name;
  final String subtitle;

  /// Cost in points.
  final int points;

  /// Grouping key (sibling shape: digital vs family).
  final String category;

  /// Button label when affordable (placeholder copy).
  final String affordableLabel;

  /// Preview-block background.
  final Color previewBackground;

  /// Project icon-library stand-in for the Figma preview artwork.
  /// No Figma image assets exist in this repo, so Material icons are
  /// used instead of emoji.
  final IconData previewIcon;

  /// A reward is affordable when its cost does not exceed the balance.
  /// Equal counts: 120 pts IS affordable with a 120 balance.
  bool affordable(int availablePoints) => points <= availablePoints;

  /// Action label computed from [points] vs the balance — never
  /// hard-coded: [affordableLabel], or "Save {gap} more".
  String actionLabel(int availablePoints) {
    if (points <= availablePoints) return affordableLabel;
    return 'Save ${points - availablePoints} more';
  }
}

class StoreSection {
  const StoreSection({
    required this.id,
    required this.title,
    this.pillLabel,
    this.subtitle,
    required this.rewards,
  });

  final String id;
  final String title;
  final String? pillLabel;
  final String? subtitle;
  final List<StoreReward> rewards;
}

// TODO(figma 5:139): replace with the retrieved balance. 120 is a
// placeholder borrowed only to verify layout — it is NOT this screen's
// balance.
const int kStoreAvailablePoints = 120;

// TODO(figma 5:139): replace with the retrieved label (whose points).
const String kStoreBalanceLabel = 'TODO(5:139): available points';

// TODO(figma 5:139): replace with the retrieved screen title.
const String kStoreTitle = '[NOT RETRIEVED \u2014 09 Rewards Store title]';

// TODO(figma 5:139): replace with the retrieved subtitle.
const String kStoreSubtitle = '[NOT RETRIEVED]';

// TODO(figma 5:139): replace with the retrieved sections, rewards, names,
// subtitles, points, preview colors, and artwork. This single placeholder
// section (two placeholder rewards) exists only to verify layout. The
// Kids Reward Store items were deliberately NOT copied here.
const List<StoreSection> kPlaceholderStoreSections = [
  StoreSection(
    // TODO(figma 5:139): section id.
    id: 'placeholder-section',
    // TODO(figma 5:139): section title.
    title: 'Placeholder section',
    // TODO(figma 5:139): pill label (or null if the design has none).
    pillLabel: 'Placeholder',
    // TODO(figma 5:139): section subtitle (or null if none).
    subtitle: 'Placeholder subtitle.',
    rewards: [
      StoreReward(
        // TODO(figma 5:139): reward id.
        id: 'placeholder-reward-a',
        // TODO(figma 5:139): reward name.
        name: 'Placeholder reward A',
        // TODO(figma 5:139): reward subtitle.
        subtitle: 'Placeholder subtitle',
        // TODO(figma 5:139): point cost.
        points: 100,
        // TODO(figma 5:139): category.
        category: 'placeholder',
        // TODO(figma 5:139): affordable action label.
        affordableLabel: 'Redeem',
        // TODO(figma 5:139): preview background.
        previewBackground: Color(0xFFF6D9C4),
        // TODO(figma 5:139): preview artwork.
        previewIcon: Icons.headphones_rounded,
      ),
      StoreReward(
        // TODO(figma 5:139): reward id.
        id: 'placeholder-reward-b',
        // TODO(figma 5:139): reward name.
        name: 'Placeholder reward B',
        // TODO(figma 5:139): reward subtitle.
        subtitle: 'Placeholder subtitle',
        // TODO(figma 5:139): point cost.
        points: 180,
        // TODO(figma 5:139): category.
        category: 'placeholder',
        // TODO(figma 5:139): affordable action label.
        affordableLabel: 'Redeem',
        // TODO(figma 5:139): preview background.
        previewBackground: Color(0xFFCFE0EE),
        // TODO(figma 5:139): preview artwork.
        previewIcon: Icons.sports_soccer_rounded,
      ),
    ],
  ),
];
