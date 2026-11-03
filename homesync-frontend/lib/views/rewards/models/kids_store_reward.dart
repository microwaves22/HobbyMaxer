import 'package:flutter/material.dart';

/// Kids Reward Store (Figma node 100:4854) catalog data shape.
///
/// MOCK DATA — placeholder content only. This screen performs no backend
/// calls and deducts no points; KidsRewardStoreScreen renders from
/// [kKidsStoreRewards] and [kAvaAvailablePoints] by default.
enum KidsRewardCategory { digital, family }

class KidsStoreReward {
  const KidsStoreReward({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.points,
    required this.category,
    required this.previewBackground,
    required this.previewIcon,
  });

  final String id;
  final String name;
  final String subtitle;

  /// Cost in points.
  final int points;
  final KidsRewardCategory category;

  /// Preview-block background hex from the design.
  final Color previewBackground;

  /// Project icon-library stand-in for the Figma preview artwork
  /// (rainbow, crown, pizza, popcorn). No Figma image assets exist in
  /// this repo, so Material icons are used instead of emoji.
  final IconData previewIcon;

  /// A reward is affordable when its cost does not exceed the balance.
  /// Equal counts: 120 pts IS affordable with a 120 balance.
  bool affordable(int availablePoints) => points <= availablePoints;

  /// Action label computed from [points] vs the balance — never hard-coded:
  /// "Unlock" (affordable digital), "Redeem" (affordable family),
  /// or "Save {gap} more" (unaffordable).
  String actionLabel(int availablePoints) {
    if (points <= availablePoints) {
      return category == KidsRewardCategory.digital ? 'Unlock' : 'Redeem';
    }
    return 'Save ${points - availablePoints} more';
  }
}

/// MOCK: Ava's points balance. Single source of truth shared by the
/// balance card, the reward-card action states, and the footer note.
const int kAvaAvailablePoints = 120;

/// MOCK: the 4 store rewards. Both rows render by filtering this array
/// by [KidsStoreReward.category].
const List<KidsStoreReward> kKidsStoreRewards = [
  KidsStoreReward(
    id: 'rainbow-mane',
    name: 'Rainbow mane',
    subtitle: 'For your unicorn',
    points: 50,
    category: KidsRewardCategory.digital,
    previewBackground: Color(0xFFDDD5EE),
    previewIcon: Icons.palette_rounded,
  ),
  KidsStoreReward(
    id: 'starry-crown',
    name: 'Starry crown',
    subtitle: 'For your unicorn',
    points: 100,
    category: KidsRewardCategory.digital,
    previewBackground: Color(0xFFF4C9C9),
    previewIcon: Icons.auto_awesome_rounded,
  ),
  KidsStoreReward(
    id: 'friday-dinner',
    name: 'Choose Friday dinner',
    subtitle: 'Parent-approved perk',
    points: 120,
    category: KidsRewardCategory.family,
    previewBackground: Color(0xFFF6D9C4),
    previewIcon: Icons.local_pizza_rounded,
  ),
  KidsStoreReward(
    id: 'family-movie',
    name: 'Pick the family movie',
    subtitle: 'Parent-approved perk',
    points: 150,
    category: KidsRewardCategory.family,
    previewBackground: Color(0xFFCFE0EE),
    previewIcon: Icons.local_movies_rounded,
  ),
];
