import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../tasks/tasks_controller.dart';
import 'models/reward_item.dart';
import 'rewards_api.dart';

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
  RewardsApi? _backend;

  List<RewardItem> get rewards => List.unmodifiable(_rewards);

  List<RewardItem> rewardsOf(RewardKind kind) =>
      _rewards.where((r) => r.kind == kind).toList();

  List<RedemptionRecord> get redemptions =>
      List.unmodifiable(_redemptions);

  List<PerkRequest> get perkRequests => List.unmodifiable(_perkRequests);

  int balanceFor(String childName) => tasks.balanceFor(childName);

  /// True once an authenticated backend is attached.
  bool get isSynced => _backend != null;

  /// Attaches the backend API. Later calls hit the network for
  /// rewards that carry a [RewardItem.serverId]; local-only entries
  /// keep working offline against the in-memory ledger.
  void attachBackend(RewardsApi backend) {
    _backend = backend;
  }

  static RewardKind _kindFor(String? kind) =>
      kind == 'perk' ? RewardKind.parentPerk : RewardKind.digital;

  static IconData _iconFor(String? kind) => switch (kind) {
    'avatar' => Icons.face,
    'pet' => Icons.pets,
    _ => Icons.card_giftcard,
  };

  static RewardItem _mapReward(Map<String, dynamic> json) {
    final kind = json['kind'] as String?;
    return RewardItem(
      id: 'srv-${json['id']}',
      serverId: json['id'] as int,
      title: json['name'] as String? ?? 'Untitled',
      description: json['description'] as String? ?? '',
      cost: json['cost_points'] as int? ?? 0,
      kind: _kindFor(kind),
      icon: _iconFor(kind),
    );
  }

  /// Replaces the catalog with the backend state.
  /// Throws [ApiException] on transport or server errors.
  Future<void> refresh() async {
    final backend = _backend;
    if (backend == null) return;
    final catalog = await backend.fetchCatalog();
    _rewards
      ..clear()
      ..addAll(catalog.map(_mapReward));
    notifyListeners();
  }

  /// Redeems [rewardId] for [childName]: deducts points, logs the
  /// redemption, and — for parent perks — raises a fulfillment request.
  RewardItem? _byId(String rewardId) {
    for (final candidate in _rewards) {
      if (candidate.id == rewardId) return candidate;
    }
    return null;
  }

  void _recordRedemption(String childName, RewardItem reward) {
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
  }

  RedeemResult redeem(String childName, String rewardId) {
    final reward = _byId(rewardId);
    if (reward == null) return RedeemResult.notFound;
    if (!tasks.deduct(childName, reward.cost)) {
      return RedeemResult.insufficient;
    }
    _recordRedemption(childName, reward);
    return RedeemResult.success;
  }

  /// Backend-aware redeem: synced rewards spend through the API
  /// (the local balance follows the server `balance_after`);
  /// local-only rewards use the in-memory ledger. Throws
  /// [ApiException] on transport or unexpected server errors.
  Future<RedeemResult> redeemAsync(String childName, String rewardId) async {
    final reward = _byId(rewardId);
    if (reward == null) return RedeemResult.notFound;
    final backend = _backend;
    if (backend != null && reward.serverId != null) {
      try {
        final txn = await backend.redeemReward(reward.serverId!);
        final balance = txn['balance_after'] as int?;
        if (balance != null) tasks.setBalance(childName, balance);
      } on ApiException catch (e) {
        if (e.statusCode == 400) return RedeemResult.insufficient;
        rethrow;
      }
      _recordRedemption(childName, reward);
      return RedeemResult.success;
    }
    return redeem(childName, rewardId);
  }

  /// Redeems a storefront-only reward (kids/teen mock catalogs carry
  /// no server id): deducts locally, logs the redemption, and raises
  /// a fulfillment request for parent perks.
  RedeemResult redeemExternal({
    required String childName,
    required String title,
    required int cost,
    required RewardKind kind,
  }) {
    if (!tasks.deduct(childName, cost)) return RedeemResult.insufficient;
    final now = DateTime.now();
    _redemptions.add(
      RedemptionRecord(
        childName: childName,
        rewardTitle: title,
        cost: cost,
        kind: kind,
        timestamp: now,
      ),
    );
    if (kind == RewardKind.parentPerk) {
      _perkRequests.add(
        PerkRequest(
          id: 'pr${_seq++}',
          childName: childName,
          perkTitle: title,
          cost: cost,
          requestedAt: now,
        ),
      );
    }
    notifyListeners();
    return RedeemResult.success;
  }

  /// Records a custom-reward request as a pending parent fulfillment
  /// request. Deducts nothing: points move when the perk is redeemed.
  void requestPerk({
    required String childName,
    required String perkTitle,
    required int cost,
  }) {
    _perkRequests.add(
      PerkRequest(
        id: 'pr${_seq++}',
        childName: childName,
        perkTitle: perkTitle,
        cost: cost,
        requestedAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  /// Marks a perk request fulfilled, clearing it from the parent queue.
  void fulfillRequest(String id) {
    _perkRequests.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  /// Backend-aware perk creation: synced catalogs persist through
  /// the API; otherwise the perk is added locally.
  Future<void> addPerkAsync({
    required String title,
    required String description,
    required int cost,
  }) async {
    final backend = _backend;
    if (backend == null) {
      addPerk(title: title, description: description, cost: cost);
      return;
    }
    final json = await backend.createReward(
      name: title,
      description: description,
      costPoints: cost,
      kind: 'perk',
    );
    _rewards.insert(0, _mapReward(json));
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
