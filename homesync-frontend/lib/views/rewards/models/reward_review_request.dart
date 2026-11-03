/// Parent Review Queue — Reward Requests (Figma node 100:5013) mock data.
///
/// MOCK DATA — the design's values only. This screen makes no API calls
/// and moves no points; approving is a named placeholder handler.
class PendingCounts {
  const PendingCounts({
    required this.taskReviews,
    required this.rewardRequests,
  });

  /// Badge count for the Task Reviews tab (and the footnote).
  final int taskReviews;

  /// Badge count for the Reward Requests tab.
  final int rewardRequests;

  /// Subtitle total. Derived so the three counts cannot disagree.
  int get totalPending => taskReviews + rewardRequests;
}

/// MOCK: the single source of truth for the subtitle total (3), the
/// Task Reviews badge (2), the Reward Requests badge (1), and the
/// review-actions footnote (2).
const PendingCounts kReviewPendingCounts = PendingCounts(
  taskReviews: 2,
  rewardRequests: 1,
);

/// MOCK: Noah's custom-reward request awaiting Sarah's review.
class RewardReviewRequest {
  const RewardReviewRequest({
    required this.id,
    required this.childName,
    required this.childAge,
    required this.childMode,
    required this.childInitial,
    required this.status,
    required this.perkName,
    required this.proposedCost,
    required this.currentBalance,
    required this.childNote,
    required this.storePointCost,
  });

  final String id;
  final String childName;
  final int childAge;
  final String childMode;
  final String childInitial;
  final String status;
  final String perkName;

  /// Cost in points, as proposed by the child.
  final int proposedCost;

  /// The child's current balance in points.
  final int currentBalance;
  final String childNote;

  /// Initial editable store cost in points (starts at [proposedCost]).
  final int storePointCost;
}

/// MOCK: the ONE reward request on this screen (design values).
const RewardReviewRequest kRewardReviewRequest = RewardReviewRequest(
  id: 'noah-trampoline-park',
  childName: 'Noah',
  childAge: 14,
  childMode: 'Teen Mode',
  childInitial: 'N',
  status: 'Pending',
  perkName: 'Go to trampoline park',
  proposedCost: 200,
  currentBalance: 120,
  childNote: 'Could we go this weekend? I am happy to save up.',
  storePointCost: 200,
);
