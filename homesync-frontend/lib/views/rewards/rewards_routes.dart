import 'package:flutter/material.dart';

import 'parent_review_queue_screen.dart';
import 'request_custom_reward_screen.dart';
import 'reward_management_screen.dart';
import 'rewards_store_screen.dart';
import 'teen_reward_store_screen.dart';

/// Navigation helpers for the Rewards screens (Figma nodes 100:4945,
/// 100:5013, 5:139, 62:6146, 62:6235).
///
/// Follows the project's direct-push `MaterialPageRoute` pattern (see
/// `HomeScreen._openRewards`) — the project uses no named-route table.
/// Back/home/nav handlers pop back to the dashboard hub; submit-style
/// actions (`onSendRequest`, approve/decline, create, unlock/redeem) are
/// intentionally left null: the screen specs define them as placeholders
/// with no post-submit route, no backend, and no points movement.
abstract final class RewardsRoutes {
  /// Request Custom Reward (Noah, teen). Reached from the kids store's
  /// "+ Request Custom Reward" button.
  static void openRequestCustomReward(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RequestCustomRewardScreen(
          onBack: () => Navigator.of(context).pop(),
          onCancel: () => Navigator.of(context).pop(),
          onNavigateHome: () => Navigator.of(context).pop(),
          onNavigateRewards: () => Navigator.of(context).pop(),
          onNavigateCalendar: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  /// Parent Review Queue — Reward Requests (Sarah, parent).
  static void openReviewQueue(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ParentReviewQueueScreen(
          onBack: () => Navigator.of(context).pop(),
          // Task reviews live on the parent dashboard; popping returns
          // there. Reward-request approval stays a placeholder.
          onSelectTaskReviewsTab: () => Navigator.of(context).pop(),
          onNavigateHome: () => Navigator.of(context).pop(),
          onNavigateCalendar: () => Navigator.of(context).pop(),
          onNavigateTasks: () => Navigator.of(context).pop(),
          onNavigateFamily: () => Navigator.of(context).pop(),
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
          onNavigateHome: () => Navigator.of(context).pop(),
          onNavigateRewards: () => Navigator.of(context).pop(),
          onNavigateCalendar: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  /// Teen real-world reward store (node 62:6146). Reached from the
  /// teen dashboard's Rewards card.
  static void openTeenStore(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TeenRewardStoreScreen(
          onBack: () => Navigator.of(context).pop(),
          onNavigateHome: () => Navigator.of(context).pop(),
          onNavigateRewards: () => Navigator.of(context).pop(),
          onNavigateCalendar: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  /// Sarah reward management (node 62:6235).
  static void openManagement(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RewardManagementScreen(
          onNavigateHome: () => Navigator.of(context).pop(),
          onNavigateCalendar: () => Navigator.of(context).pop(),
          onNavigateTasks: () => Navigator.of(context).pop(),
          onNavigateFamily: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }
}
