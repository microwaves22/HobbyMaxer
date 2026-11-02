import 'package:flutter/material.dart';

import '../tasks/tasks_controller.dart';
import 'models/reward_item.dart';

/// Reward store state: catalog, redemption ledger, and pending parent-perk
/// requests. Points balances live in [TasksController]; this controller
/// spends from them so earn and spend stay in one place.
class RewardsController extends ChangeNotifier {
  RewardsController({required this.tasks, List<RewardItem>? rewards})
      : _rewards = List.of(rewards ?? _defaultRewards);

  final TasksController tasks;
  final List<RewardItem> _rewards;
  final List<RedemptionRecord> _redemptions = [];
  final List<PerkRequest> _perkRequests = [];
  int _seq = 0;

  List<RewardItem> get rewards => List.unmodifiable(_rewards);

  List<RewardItem> rewardsOf(RewardKind kind) =>
      _rewards.where((r) => r.kind == kind).toList();

  List<RedemptionRecord> get redemptions =>
      List.unmodifiable(_redemptions);

  List<PerkRequest> get perkRequests => List.unmodifiable(_perkRequests);

  int balanceFor(String childName) => tasks.balanceFor(childName);

  /// Redeems [rewardId] for [childName]: deducts points, logs the
  /// redemption, and — for parent perks — raises a fulfillment request.
  RedeemResult redeem(String childName, String rewardId) {
    RewardItem? reward;
    for (final candidate in _rewards) {
      if (candidate.id == rewardId) reward = candidate;
    }
    if (reward == null) return RedeemResult.notFound;
    if (!tasks.deduct(childName, reward.cost)) {
      return RedeemResult.insufficient;
    }
    final now = DateTime.now();
    _redemptions.add(
      RedemptionRecord(
        childName: childName,
        rewardTitle: reward.title,
        cost: reward.cost,
        kind: reward.kind,
        timestamp: now,
      ),
    );
    if (reward.kind == RewardKind.parentPerk) {
      _perkRequests.add(
        PerkRequest(
          id: 'pr${_seq++}',
          childName: childName,
          perkTitle: reward.title,
          cost: reward.cost,
          requestedAt: now,
        ),
      );
    }
    notifyListeners();
    return RedeemResult.success;
  }

  /// Marks a perk request fulfilled, clearing it from the parent queue.
  void fulfillRequest(String id) {
    _perkRequests.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  /// Adds a parent-managed perk to the top of the catalog, so it is
  /// visible immediately where the parent just tapped.
  void addPerk({
    required String title,
    required String description,
    required int cost,
  }) {
    _rewards.insert(
      0,
      RewardItem(
        id: 'perk-custom-${_seq++}',
        title: title,
        description: description,
        cost: cost,
        kind: RewardKind.parentPerk,
        icon: Icons.card_giftcard,
      ),
    );
    notifyListeners();
  }
}

const _defaultRewards = [
  RewardItem(
    id: 'dig-avatar',
    title: 'Pixel Avatar Pack',
    description: 'Six retro avatars for your profile.',
    cost: 50,
    kind: RewardKind.digital,
    icon: Icons.face,
  ),
  RewardItem(
    id: 'dig-hat',
    title: 'Companion Hat',
    description: 'A fancy hat for your companion.',
    cost: 30,
    kind: RewardKind.digital,
    icon: Icons.pets,
  ),
  RewardItem(
    id: 'dig-theme',
    title: 'Ocean Theme',
    description: 'A calming blue app theme.',
    cost: 40,
    kind: RewardKind.digital,
    icon: Icons.palette,
  ),
  RewardItem(
    id: 'dig-trail',
    title: 'Star Trail Effect',
    description: 'Sparkles that follow your avatar.',
    cost: 80,
    kind: RewardKind.digital,
    icon: Icons.auto_awesome,
  ),
  RewardItem(
    id: 'perk-screen',
    title: 'Extra 30 min screen time',
    description: 'Parent-approved bonus screen time, one evening.',
    cost: 25,
    kind: RewardKind.parentPerk,
    icon: Icons.timer_outlined,
  ),
  RewardItem(
    id: 'perk-takeout',
    title: 'Pick Friday takeout',
    description: 'You choose this week\u2019s Friday night takeout.',
    cost: 60,
    kind: RewardKind.parentPerk,
    icon: Icons.fastfood_outlined,
  ),
  RewardItem(
    id: 'perk-curfew',
    title: 'Extended curfew (1 hr)',
    description: 'Stay up one extra hour, one night.',
    cost: 100,
    kind: RewardKind.parentPerk,
    icon: Icons.nightlight_outlined,
  ),
];
