import 'package:flutter/material.dart';

/// Teen real-world reward store (Figma node 62:6146) data layer.
///
/// WARNING: the Figma specs for node 62:6146 were never retrieved
/// (Figma rate limit), so EVERY value below is a TODO placeholder shaped
/// by the sibling teen screen (Request Custom Reward, node 100:4945) and
/// the sibling real-world cards ("Family treats", node 100:4854) — NOT
/// design content. Re-pull node 62:6146 from Figma and replace each TODO
/// before calling this final. This screen makes no API calls, deducts no
/// points, and books/purchases nothing.
class TeenStoreReward {
  const TeenStoreReward({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.points,
    required this.previewBackground,
    required this.previewIcon,
  });

  final String id;
  final String name;
  final String subtitle;

  /// Cost in points.
  final int points;

  /// Preview-block background.
  final Color previewBackground;

  /// Project icon-library stand-in for the Figma preview artwork.
  /// No Figma image assets exist in this repo, so Material icons are
  /// used instead of emoji.
  final IconData previewIcon;

  /// A reward is affordable when its cost does not exceed the balance.
  /// Equal counts as affordable.
  bool affordable(int availablePoints) => points <= availablePoints;

  /// Action label computed from [points] vs the balance — never
  /// hard-coded: "Redeem" (affordable) or "Save {gap} more".
  String actionLabel(int availablePoints) {
    if (points <= availablePoints) return 'Redeem';
    return 'Save ${points - availablePoints} more';
  }
}

// TODO(figma 62:6146): replace with the retrieved teen name. Whether this
// store is Noah's was NOT retrieved.
const String kTeenStoreName = 'TODO(62:6146)';

// TODO(figma 62:6146): replace with the retrieved screen title.
const String kTeenStoreTitle = 'TODO(62:6146): store title';

// TODO(figma 62:6146): replace with the retrieved subtitle. Shape only:
// "<Name> · 14 · Teen Mode".
String get kTeenStoreSubtitle => '$kTeenStoreName \u00B7 14 \u00B7 Teen Mode';

// TODO(figma 62:6146): replace with the retrieved balance. 120 is a
// placeholder borrowed only to verify layout — it is NOT this screen's
// balance.
const int kTeenStoreAvailablePoints = 120;

// TODO(figma 62:6146): replace with the retrieved label (whose points).
const String kTeenStoreBalanceLabel =
    'TODO(62:6146): available points';

// TODO(figma 62:6146): replace with the retrieved section heading.
const String kTeenStoreSectionTitle =
    'TODO(62:6146): real-world rewards';

// TODO(figma 62:6146): replace with the retrieved section subtitle. Shape
// only (sibling pattern): "Approved by <parent> · She confirms when to
// enjoy them."
const String kTeenStoreSectionSubtitle =
    'Approved by TODO(62:6146) \u00B7 She confirms when to enjoy them.';

// TODO(figma 62:6146): replace with the retrieved rewards — every name,
// subtitle, points value, preview background, and artwork. These two
// placeholder rewards exist only to verify layout (one affordable, one
// not). The kid-screen items were deliberately NOT copied here.
const List<TeenStoreReward> kTeenStoreRewards = [
  TeenStoreReward(
    // TODO(figma 62:6146): reward id.
    id: 'placeholder-teen-reward-a',
    // TODO(figma 62:6146): reward name.
    name: 'Placeholder perk A',
    // TODO(figma 62:6146): reward subtitle (sibling wording reused as a
    // marked placeholder only).
    subtitle: 'Parent-approved perk',
    // TODO(figma 62:6146): point cost.
    points: 100,
    // TODO(figma 62:6146): preview background.
    previewBackground: Color(0xFFF6D9C4),
    // TODO(figma 62:6146): preview artwork.
    previewIcon: Icons.headphones_rounded,
  ),
  TeenStoreReward(
    // TODO(figma 62:6146): reward id.
    id: 'placeholder-teen-reward-b',
    // TODO(figma 62:6146): reward name.
    name: 'Placeholder perk B',
    // TODO(figma 62:6146): reward subtitle (sibling wording reused as a
    // marked placeholder only).
    subtitle: 'Parent-approved perk',
    // TODO(figma 62:6146): point cost.
    points: 180,
    // TODO(figma 62:6146): preview background.
    previewBackground: Color(0xFFCFE0EE),
    // TODO(figma 62:6146): preview artwork.
    previewIcon: Icons.sports_soccer_rounded,
  ),
];
