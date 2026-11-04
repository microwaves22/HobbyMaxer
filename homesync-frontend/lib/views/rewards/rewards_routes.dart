import 'package:flutter/material.dart';

import '../home/household_routes.dart';
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
/// intentionally left null: the specs define them as placeholders
/// with no backend and no points movement; the request screen pops back
/// to the store with confirmation on send.
///
/// Category switches between the Digital and Real-world teen views use
/// replacement navigation so repeated switches never stack duplicates
/// (same precedent as `HouseholdRoutes.openTab`).
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
          onNavigateCalendar: () =>
              HouseholdRoutes.openTab(context, 'calendar'),
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
          onNavigateHome: () => HouseholdRoutes.openTab(context, 'home'),
          onNavigateCalendar: () =>
              HouseholdRoutes.openTab(context, 'calendar'),
          onNavigateTasks: () => HouseholdRoutes.openTab(context, 'tasks'),
          onNavigateFamily: () =>
              HouseholdRoutes.openTab(context, 'family'),
        ),
      ),
    );
  }

  /// 09 Rewards Store (node 5:139) — Teen Rewards, Digital view: the
  /// digital side of the teen store (avatar/pet items, themes, and
  /// portal customization). Reached from the dashboard or the
  /// Real-world view's Digital tab.
  static void openDigitalStore(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => _digitalStore(context)),
    );
  }

  /// Teen real-world reward store (node 62:6146): the real-world perks
  /// created by parents and children. Reached from the teen
  /// dashboard's Rewards card or the Digital view's Real-world tab.
  static void openTeenStore(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => _teenStore(context)),
    );
  }

  /// Sarah reward management (node 62:6235).
  static void openManagement(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RewardManagementScreen(
          onNavigateHome: () => HouseholdRoutes.openTab(context, 'home'),
          onNavigateCalendar: () =>
              HouseholdRoutes.openTab(context, 'calendar'),
          onNavigateTasks: () => HouseholdRoutes.openTab(context, 'tasks'),
          onNavigateFamily: () =>
              HouseholdRoutes.openTab(context, 'family'),
        ),
      ),
    );
  }

  /// Digital teen view with its tabs wired: Real-world replaces with
  /// the Real-world view; Digital is already selected.
  static Widget _digitalStore(BuildContext context) {
    return RewardsStoreScreen(
      onBack: () => Navigator.of(context).pop(),
      onSelectCategory: (category) {
        if (category == 'Real-world') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => _teenStore(context)),
          );
        }
      },
      onNavigateHome: () => Navigator.of(context).pop(),
      // Rewards is the active section: tapping it stays put.
      onNavigateRewards: () {},
      onNavigateCalendar: () =>
          HouseholdRoutes.openTab(context, 'calendar'),
    );
  }

  /// Real-world teen view with its tabs wired: Digital replaces with
  /// the Digital view; Real-world is already selected.
  static Widget _teenStore(BuildContext context) {
    return TeenRewardStoreScreen(
      onBack: () => Navigator.of(context).pop(),
      onSelectCategory: (category) {
        if (category == 'Digital') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => _digitalStore(context)),
          );
        }
      },
      onNavigateHome: () => Navigator.of(context).pop(),
      // Rewards is the active section: tapping it stays put.
      onNavigateRewards: () {},
      onNavigateCalendar: () =>
          HouseholdRoutes.openTab(context, 'calendar'),
    );
  }
}
