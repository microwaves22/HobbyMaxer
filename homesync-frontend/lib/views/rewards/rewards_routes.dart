import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../home/household_routes.dart';
import 'models/reward_item.dart';
import 'models/reward_review_request.dart';
import 'models/teen_store_reward.dart';
import 'parent_review_queue_screen.dart';
import 'request_custom_reward_screen.dart';
import 'reward_management_screen.dart';
import 'rewards_controller.dart';
import 'rewards_store_screen.dart';
import 'teen_reward_store_screen.dart';

/// Navigation helpers for the Rewards screens (Figma nodes 100:4945,
/// 100:5013, 5:139, 62:6146, 62:6235).
///
/// Follows the project's direct-push `MaterialPageRoute` pattern (see
/// `HomeScreen._openRewards`) — the project uses no named-route table.
/// Back/home/nav handlers pop back to the dashboard hub.
///
/// When a [RewardsController] is provided, submit-style actions run for
/// real against the shared ledger (custom requests are recorded, review
/// approvals add store perks, management creates persist, teen redeems
/// spend points); without one the screens keep their mock success paths.
abstract final class RewardsRoutes {
  /// Request Custom Reward (Noah, teen). Reached from the kids store's
  /// "+ Request Custom Reward" button and the teen store's request bar.
  static void openRequestCustomReward(
    BuildContext context, {
    RewardsController? controller,
    String? childName,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RequestCustomRewardScreen(
          onBack: () => Navigator.of(context).pop(),
          submitRequest: controller == null || childName == null
              ? null
              : (form) async {
                  controller.requestPerk(
                    childName: childName,
                    perkTitle: form.requestedPerk,
                    cost: form.proposedCost,
                  );
                },
          onCancel: () => Navigator.of(context).pop(),
          onNavigateHome: () => HouseholdRoutes.goHome(context),
          onNavigateRewards: () => Navigator.of(context).pop(),
          onNavigateCalendar: () => HouseholdRoutes.goCalendar(context),
        ),
      ),
    );
  }

  /// Parent Review Queue — Reward Requests (Sarah, parent).
  static void openReviewQueue(
    BuildContext context, {
    RewardsController? controller,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (routeContext) => ParentReviewQueueScreen(
          onBack: () => Navigator.of(routeContext).pop(),
          // Task reviews live on the parent dashboard; popping returns
          // there.
          onSelectTaskReviewsTab: () => Navigator.of(routeContext).pop(),
          onApproveAndAddToStore: (requestId, cost) async {
            final messenger = ScaffoldMessenger.of(routeContext);
            if (cost < 1) {
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Enter a points cost of at least 1.'),
                ),
              );
              return;
            }
            if (controller != null) {
              final request = requestId == kRewardReviewRequest.id
                  ? kRewardReviewRequest
                  : null;
              try {
                await controller.addPerkAsync(
                  title: request?.perkName ?? 'Custom perk',
                  description: request?.childNote ?? '',
                  cost: cost,
                );
              } on ApiException catch (e) {
                messenger.showSnackBar(
                  SnackBar(content: Text(e.message)),
                );
                return;
              }
            }
            messenger.showSnackBar(
              const SnackBar(
                content: Text('Approved — added to the store.'),
              ),
            );
          },
          onDeclineOrEditPoints: (_) {
            ScaffoldMessenger.of(routeContext).showSnackBar(
              const SnackBar(content: Text('Request declined.')),
            );
          },
          onNavigateHome: () => HouseholdRoutes.goHome(routeContext),
          onNavigateCalendar: () => HouseholdRoutes.goCalendar(routeContext),
          onNavigateTasks: () => Navigator.of(routeContext).pop(),
          onNavigateFamily: () => Navigator.of(routeContext).pop(),
        ),
      ),
    );
  }

  /// 09 Rewards Store (node 5:139) — Teen Rewards, Digital view.
  static void openStoreShell(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RewardsStoreScreen(
          onBack: () => Navigator.of(context).pop(),
          onNavigateHome: () => HouseholdRoutes.goHome(context),
          onNavigateRewards: () => Navigator.of(context).pop(),
          onNavigateCalendar: () => HouseholdRoutes.goCalendar(context),
        ),
      ),
    );
  }

  /// Teen real-world reward store (node 62:6146). Reached from the
  /// teen dashboard's Rewards card.
  static void openTeenStore(
    BuildContext context, {
    RewardsController? controller,
    String? childName,
    int? availablePoints,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (routeContext) => TeenRewardStoreScreen(
          availablePoints: availablePoints ??
              (controller != null && childName != null
                  ? controller.balanceFor(childName)
                  : kTeenStoreAvailablePoints),
          onBack: () => Navigator.of(routeContext).pop(),
          onRedeemReward: controller == null || childName == null
              ? null
              : (id) {
                  TeenStoreReward? match;
                  for (final candidate in kTeenStoreRewards) {
                    if (candidate.id == id) match = candidate;
                  }
                  final reward = match;
                  if (reward == null) return;
                  final result = controller.redeemExternal(
                    childName: childName,
                    title: reward.name,
                    cost: reward.points,
                    kind: RewardKind.parentPerk,
                  );
                  final balance = controller.balanceFor(childName);
                  final message = switch (result) {
                    RedeemResult.success =>
                      'Redeemed ${reward.name}! Balance: $balance pts.',
                    RedeemResult.insufficient =>
                      'Not enough points for ${reward.name}.',
                    RedeemResult.notFound =>
                      'That reward is no longer available.',
                  };
                  ScaffoldMessenger.of(routeContext).showSnackBar(
                    SnackBar(content: Text(message)),
                  );
                },
          onRequestCustomReward: () => openRequestCustomReward(
            routeContext,
            controller: controller,
            childName: childName,
          ),
          onNavigateHome: () => HouseholdRoutes.goHome(routeContext),
          onNavigateRewards: () => Navigator.of(routeContext).pop(),
          onNavigateCalendar: () => HouseholdRoutes.goCalendar(routeContext),
        ),
      ),
    );
  }

  /// Sarah reward management (node 62:6235).
  static void openManagement(
    BuildContext context, {
    RewardsController? controller,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (routeContext) => RewardManagementScreen(
          onCreatePerk: controller == null
              ? null
              : (form) async {
                  final messenger = ScaffoldMessenger.of(routeContext);
                  final digits =
                      form.cost.replaceAll(RegExp(r'[^0-9]'), '');
                  final cost = int.tryParse(digits) ?? 0;
                  if (form.field1.trim().isEmpty || cost < 1) {
                    messenger.showSnackBar(
                      const SnackBar(
                        content:
                            Text('Enter a perk name and a points cost.'),
                      ),
                    );
                    return;
                  }
                  try {
                    await controller.addPerkAsync(
                      title: form.field1.trim(),
                      description: form.field3.trim().isNotEmpty
                          ? form.field3.trim()
                          : form.field2.trim(),
                      cost: cost,
                    );
                  } on ApiException catch (e) {
                    messenger.showSnackBar(
                      SnackBar(content: Text(e.message)),
                    );
                    return;
                  }
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Added perk: ${form.field1.trim()}.'),
                    ),
                  );
                },
          onNavigateHome: () => HouseholdRoutes.goHome(routeContext),
          onNavigateCalendar: () => HouseholdRoutes.goCalendar(routeContext),
          onNavigateTasks: () => Navigator.of(routeContext).pop(),
          onNavigateFamily: () => Navigator.of(routeContext).pop(),
        ),
      ),
    );
  }
}
