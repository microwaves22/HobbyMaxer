import 'package:flutter/material.dart';

/// Teen real-world reward store (Figma node 62:6146) data layer.
///
/// All values below are the real design: Noah's store (Figma shows a
/// 120 balance; the product starts teens at 0 so costly perks lock),
/// Real-world category selected, the 4 real perks matching Sarah's
/// managed set. This screen makes no API calls, deducts no points, and
/// books/purchases nothing.
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

  /// Detail line ('+30 mins', 'Dinner / takeout', or '' when none).
  final String subtitle;

  /// Cost in points.
  final int points;

  /// Icon-tile background.
  final Color previewBackground;

  /// Project icon-library stand-in for the Figma tile artwork.
  /// moon-star → bedtime · utensils → restaurant ·
  /// clapperboard → movie · shopping-bag → shopping_bag.
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

/// Real teen name (Figma 62:6146).
const String kTeenStoreName = 'Noah';

/// Real screen title (Figma 62:6146).
const String kTeenStoreTitle = 'Teen Rewards';

/// Identity subtitle shape: "Noah · 14 · Teen Mode".
String get kTeenStoreSubtitle => '$kTeenStoreName · 14 · Teen Mode';

/// Starting balance: teens begin at 0 points, so every perk costing
/// more than 0 starts Locked (grayed out) until points are earned.
/// (Figma 62:6146 illustrates the same screen with a 120 balance.)
const int kTeenStoreAvailablePoints = 0;

/// Real balance-card eyebrow (Figma 62:6146, all caps, curly apostrophe).
const String kTeenStoreBalanceLabel = 'NOAH\u2019S AVAILABLE BALANCE';

/// Real section heading (Figma 62:6146).
const String kTeenStoreSectionTitle = 'Real-World Perks';

/// Real section subline (Figma 62:6146).
const String kTeenStoreSectionSubtitle =
    'Managed by Sarah · Redeem to request approval.';

/// Real footer (Figma 62:6146).
const String kTeenStoreFooter =
    'Sarah confirms timing and conditions before a perk is used. '
    'Your balance stays unchanged until approved.';

/// Category segments in order; 'Real-world' is selected in this view.
const List<String> kTeenStoreCategories = ['Digital', 'Real-world'];

/// The 4 real perks (Figma 62:6146), in design order. Locked state is
/// computed from cost vs the balance (at the 0 start, all are locked).
const List<TeenStoreReward> kTeenStoreRewards = [
  TeenStoreReward(
    id: 'extended-curfew',
    name: 'Extended weekend curfew',
    subtitle: '+30 mins',
    points: 80,
    previewBackground: Color(0xFFE4EBDC),
    previewIcon: Icons.bedtime_rounded,
  ),
  TeenStoreReward(
    id: 'friday-dinner',
    name: 'Choose Friday night dinner',
    subtitle: 'Dinner / takeout',
    points: 120,
    previewBackground: Color(0xFFF6D9C4),
    previewIcon: Icons.restaurant_rounded,
  ),
  TeenStoreReward(
    id: 'family-movie',
    name: 'Pick the family movie',
    subtitle: '',
    points: 150,
    previewBackground: Color(0xFFDDD5EE),
    previewIcon: Icons.movie_rounded,
  ),
  TeenStoreReward(
    id: 'purchase-contribution',
    name: 'Personal purchase contribution',
    subtitle: '',
    points: 200,
    previewBackground: Color(0xFFCFE0EE),
    previewIcon: Icons.shopping_bag_rounded,
  ),
];
