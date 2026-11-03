import 'package:flutter/material.dart';

/// 09 Rewards Store (Figma node 5:139) data layer.
///
/// Teen Rewards, Digital category view. All values below are the real
/// design: 6 rewards in order, balance 120, categories Digital (selected)
/// and Real-world. This screen makes no API calls and moves no points.
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

  /// Kept for data-shape compatibility; the design shows NO subtitle
  /// line on cards, so this is always empty here.
  final String subtitle;

  /// Cost in points.
  final int points;

  /// Grouping key: 'digital' (this view) or 'real-world' (sibling view).
  final String category;

  /// Button label when affordable ('Equipped' for the equipped reward,
  /// 'Redeem' otherwise).
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

/// Real balance for this view (Figma 5:139).
const int kStoreAvailablePoints = 120;

/// Real screen title (Figma 5:139).
const String kStoreTitle = 'Teen Rewards';

/// Category chips in order; 'Digital' is selected in this view.
const List<String> kStoreCategories = ['Digital', 'Real-world'];

/// The 6 real Digital rewards (Figma 5:139), in design order.
const List<StoreSection> kStoreSections = [
  StoreSection(
    id: 'digital',
    title: 'Digital',
    rewards: [
      StoreReward(
        id: 'neon-avatar',
        name: 'Neon Avatar',
        subtitle: '',
        points: 0,
        category: 'digital',
        affordableLabel: 'Equipped',
        previewBackground: Color(0xFFE4EBDC),
        previewIcon: Icons.tag_faces_rounded,
      ),
      StoreReward(
        id: 'midnight-sage',
        name: 'Midnight Sage',
        subtitle: '',
        points: 50,
        category: 'digital',
        affordableLabel: 'Redeem',
        previewBackground: Color(0xFFCFE0EE),
        previewIcon: Icons.dark_mode_rounded,
      ),
      StoreReward(
        id: 'rare-dragon-armor',
        name: 'Rare Dragon Armor',
        subtitle: '',
        points: 100,
        category: 'digital',
        affordableLabel: 'Redeem',
        previewBackground: Color(0xFFDDD5EE),
        previewIcon: Icons.shield_rounded,
      ),
      StoreReward(
        id: 'profile-wallpaper',
        name: 'Profile Wallpaper',
        subtitle: '',
        points: 150,
        category: 'digital',
        affordableLabel: 'Redeem',
        previewBackground: Color(0xFFFDF0C8),
        previewIcon: Icons.wallpaper_rounded,
      ),
      StoreReward(
        id: 'app-icon-theme',
        name: 'App Icon Theme',
        subtitle: '',
        points: 80,
        category: 'digital',
        affordableLabel: 'Redeem',
        previewBackground: Color(0xFFE4EBDC),
        previewIcon: Icons.apps_rounded,
      ),
      StoreReward(
        id: 'creature-palette',
        name: 'Creature Palette',
        subtitle: '',
        points: 120,
        category: 'digital',
        affordableLabel: 'Redeem',
        previewBackground: Color(0xFFCFE0EE),
        previewIcon: Icons.palette_rounded,
      ),
    ],
  ),
];
