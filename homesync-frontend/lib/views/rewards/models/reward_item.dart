import 'package:flutter/widgets.dart';

/// A redeemable reward: either a digital good or a parent-managed perk.
class RewardItem {
  const RewardItem({
    required this.id,
    required this.title,
    required this.description,
    required this.cost,
    required this.kind,
    required this.icon,
    this.serverId,
  });

  final String id;
  final String title;
  final String description;

  /// Cost in points.
  final int cost;
  final RewardKind kind;
  final IconData icon;

  /// Backend reward id once synced; null for local-only entries.
  final int? serverId;
}

enum RewardKind { digital, parentPerk }

/// Audit record of a points redemption.
class RedemptionRecord {
  const RedemptionRecord({
    required this.childName,
    required this.rewardTitle,
    required this.cost,
    required this.kind,
    required this.timestamp,
  });

  final String childName;
  final String rewardTitle;
  final int cost;
  final RewardKind kind;
  final DateTime timestamp;
}

/// A redeemed parent perk awaiting parental fulfillment.
class PerkRequest {
  const PerkRequest({
    required this.id,
    required this.childName,
    required this.perkTitle,
    required this.cost,
    required this.requestedAt,
  });

  final String id;
  final String childName;
  final String perkTitle;
  final int cost;
  final DateTime requestedAt;
}

enum RedeemResult { success, insufficient, notFound }
