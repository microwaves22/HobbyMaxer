import 'package:flutter/material.dart';

import '../calendar/calendar_screen.dart';
import '../family_time/family_time_screen.dart';
import '../onboarding/models/user_profile.dart';
import '../settings/account_settings_screen.dart';
import '../tasks/tasks_controller.dart';
import '../tasks/tasks_screen.dart';
import 'profile_hub_screen.dart';

/// Bottom-tab destinations for the household tab family (Home, Calendar,
/// Tasks, Family). Follows the project's direct-push `MaterialPageRoute`
/// pattern (see `RewardsRoutes`) — the project uses no named-route table.
///
/// Tab switches REPLACE the current route so repeated taps never stack
/// duplicates; Account Settings pushes so back returns to the hub.
abstract final class HouseholdRoutes {
  /// Demo parent profile backing Tasks tab arrivals. The tab screens
  /// carry no session state, and the Tasks screen requires a profile
  /// plus controller, so arrivals reuse Sarah's local demo seeds.
  static final UserProfile _tasksProfile = UserProfile(
    name: 'Sarah',
    role: FamilyRole.parent,
    mode: FamilyMode.parent,
  );

  /// Demo profile backing Account Settings arrivals from the hub.
  static final UserProfile _settingsProfile = UserProfile(
    name: 'Sarah',
    role: FamilyRole.parent,
    mode: FamilyMode.parent,
  );

  static void openTab(BuildContext context, String tabId) {
    final Widget screen;
    switch (tabId) {
      case 'home':
        // Closed menu: the dropdown opens from the hub's avatar.
        screen = const ProfileHubScreen(menuOpen: false);
      case 'calendar':
        screen = const CalendarScreen();
      case 'tasks':
        screen = TasksScreen(
          controller: TasksController.forProfile(_tasksProfile),
          profile: _tasksProfile,
        );
      case 'family':
        screen = const FamilyTimeScreen();
      default:
        return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  static void openAccountSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AccountSettingsScreen(profile: _settingsProfile),
      ),
    );
  }
}
