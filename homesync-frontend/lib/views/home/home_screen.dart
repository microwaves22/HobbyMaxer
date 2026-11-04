import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../../core/network/auth_session.dart';
import '../../core/network/families_api.dart';
import '../../core/state/focus_areas.dart';
import '../../core/widgets/home_title.dart';
import '../../core/widgets/liquid_glass_card.dart';
import '../../core/widgets/member_avatar.dart';
import '../../core/widgets/profile_avatar_dropdown.dart';
import '../ai/quick_add_screen.dart';
import '../calendar/calendar_screen.dart';
import '../onboarding/link_kids_screen.dart';
import '../onboarding/family_member.dart';
import '../onboarding/models/user_profile.dart';
import '../rewards/kids_reward_store_screen.dart';
import '../rewards/models/kids_store_reward.dart';
import '../rewards/models/reward_item.dart';
import '../rewards/rewards_api.dart';
import '../rewards/rewards_controller.dart';
import '../rewards/rewards_routes.dart';
import '../rewards/rewards_screen.dart';
import '../rewards/widgets/perk_requests_section.dart';
import '../settings/account_settings_screen.dart';
import '../tasks/tasks_api.dart';
import '../tasks/tasks_controller.dart';
import '../tasks/widgets/parent_todo_section.dart';
import '../tasks/tasks_screen.dart';
import '../tasks/teen_todo_list_screen.dart';
import '../tasks/widgets/review_queue_section.dart';
<<<<<<< HEAD
import 'widgets/load_balance_section.dart';
import 'household_routes.dart';
import 'widgets/notification_bell.dart';
=======
import 'household_routes.dart';
>>>>>>> 48e512845754349ab492b180d4e531d2082a5fd4

/// Dashboard landing after onboarding or login.
///
/// Feature cards render only for the focus areas selected during
/// onboarding (see [FocusAreasScope]); unselected features stay hidden.
/// Parent profiles additionally get the task review queue and perk
/// fulfillment requests.
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.profile,
    this.otherProfiles = const [],
    this.parentPin = '1234',
    this.pendingMembers = const [],
  });

  final UserProfile profile;

  /// Other household profiles, for the profile switcher. Empty until
  /// family management lands in settings.
  final List<UserProfile> otherProfiles;

  /// Demo Parent PIN. Wire to the backend (`POST /auth/switch-profile`)
  /// once API integration lands.
  final String parentPin;

  /// Members collected during onboarding, added as backend child
  /// profiles on the first authenticated sync (parents only).
  final List<FamilySetupMember> pendingMembers;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ProfileOption _active;
  late final TasksController _tasks;
  late final RewardsController _rewards;

  @override
  void initState() {
    super.initState();
    _active = _toOption(widget.profile);
    _tasks = TasksController.forProfile(widget.profile);
    _rewards = RewardsController(tasks: _tasks);
  }

  @override
  void dispose() {
    _rewards.dispose();
    _tasks.dispose();
    super.dispose();
  }

  bool _backendAttached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_backendAttached) return;
    final session = AuthScope.maybeOf(context);
    if (session == null || !session.isAuthenticated) return;
    _backendAttached = true;
    final user = session.user!;
    final headerAvatar =
        resolveAvatarUrl(user.avatarUrl, session.client.baseUrl);
    if (headerAvatar != null) {
      _active = ProfileOption(
        name: _active.name,
        roleLabel: _active.roleLabel,
        avatarColor: _active.avatarColor,
        isParent: _active.isParent,
        avatarUrl: headerAvatar,
      );
    }
    _tasks.attachBackend(TasksApi(session.client));
    _rewards.attachBackend(RewardsApi(session.client));
    _tasks.setBalance(user.displayName, user.pointsBalance);
    unawaited(_syncBackend());
  }

  /// Creates the backend family on first sync (parents only), adds the
  /// kids collected during onboarding as child profiles, and surfaces
  /// the invite code for any additional parents so they can join.
  /// No-ops for children.
  Future<void> _ensureFamily() async {
    final session = AuthScope.maybeOf(context);
    final user = session?.user;
    if (session == null || user == null || !user.isParent) return;
    final families = FamiliesApi(session.client);
    late final Map<String, dynamic> family;
    try {
      family = await families.myFamily();
    } on ApiException catch (e) {
      if (e.statusCode != 404) rethrow;
      var pin = '1234';
      try {
        pin = await session.getParentPin() ?? '1234';
        await session.setParentPin(pin);
      } catch (_) {
        // Keychain unavailable: the default still works locally.
      }
      final firstName = user.displayName.split(' ').first;
      family = await families.createFamily(
        name: 'The $firstName Family',
        parentPin: pin,
      );
    }
    final familyId = family['id'] as int;
    // Parent-role entries are login-bearing accounts, not child
    // profiles: the creator's own entry is skipped, and any additional
    // parents join later with the invite code below.
    final creatorName = user.displayName.trim().toLowerCase();
    final awaitingParents = <String>[];
    for (final member in widget.pendingMembers) {
      if (member.isParent) {
        if (member.name.trim().toLowerCase() != creatorName) {
          awaitingParents.add(member.name);
        }
        continue;
      }
      try {
        await families.addChild(
          familyId: familyId,
          displayName: member.name,
          mode: member.isTeen ? 'teen' : 'kids',
        );
      } on ApiException {
        // Keep syncing the rest; unsent members retry next launch.
      }
    }

    if (awaitingParents.isNotEmpty && mounted) {
      final names = awaitingParents.join(' & ');
      final code = family['invite_code'] as String?;
      final detail = code == null
          ? 'Share your invite code so $names can join.'
          : 'Family code ${FamiliesApi.formatInviteCode(code)} — share it so $names can join.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(detail),
          action: SnackBarAction(
            label: 'Share',
            onPressed: _openManageFamily,
          ),
        ),
      );
    }
  }

  Future<void> _syncBackend() async {
    try {
      await _ensureFamily();
      await _tasks.refresh();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
  }

  static ProfileOption _toOption(UserProfile profile) {
    final age = profile.age();
    final role = profile.role.label;
    final mode = profile.mode.label;
    // Role and mode can share a label (Parent/Parent): show it once.
    final head = role == mode ? role : '$role · $mode';
    return ProfileOption(
      name: profile.name,
      roleLabel:
          '$head · ${age == null ? 'Age –' : 'Age $age'}',
      isParent: profile.isParent,
    );
  }

  List<ProfileOption> _options() => [
        _toOption(widget.profile),
        for (final other in widget.otherProfiles) _toOption(other),
      ];

  void _openTasks([TasksSegment initial = TasksSegment.chores]) {
    // Teen profiles keep the Figma 03 Teen My To-Do List; parents
    // and kids get the combined chores/homework hub.
    final isTeen =
        !widget.profile.isParent && widget.profile.mode == FamilyMode.teen;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => isTeen
            ? TeenTodoListScreen(
                controller: _tasks,
                profile: widget.profile,
<<<<<<< HEAD
                onNavigateHome: () => HouseholdRoutes.goHome(context),
                onNavigateCalendar: () => HouseholdRoutes.goCalendar(context),
=======
                onNavigateHome: () => Navigator.of(context).pop(),
                onNavigateRewards: () =>
                    RewardsRoutes.openTeenStore(context),
                onNavigateCalendar: () =>
                    HouseholdRoutes.openTab(context, 'calendar'),
>>>>>>> 48e512845754349ab492b180d4e531d2082a5fd4
              )
            : TasksScreen(
                controller: _tasks,
                profile: widget.profile,
                initialSegment: initial,
              ),
      ),
    );
  }

  void _openQuickAdd() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const QuickAddScreen()),
    );
  }

  void _openCalendar() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CalendarScreen()),
    );
  }

  void _openManageFamily() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LinkKidsScreen()),
    );
  }

  void _openRewards() {
    if (widget.profile.mode == FamilyMode.kids) {
      Navigator.of(context).push(
        MaterialPageRoute(
<<<<<<< HEAD
          builder: (_) => Builder(
            builder: (storeContext) => KidsRewardStoreScreen(
              availablePoints: _rewards.balanceFor(widget.profile.name),
              onBack: () => Navigator.of(context).pop(),
              onRequestCustomReward: () =>
                  RewardsRoutes.openRequestCustomReward(
                context,
                controller: _rewards,
                childName: widget.profile.name,
              ),
              onUnlockReward: (id) =>
                  _redeemExternal(storeContext, id, RewardKind.digital),
              onRedeemReward: (id) =>
                  _redeemExternal(storeContext, id, RewardKind.parentPerk),
              onNavigateHome: () => HouseholdRoutes.goHome(context),
              onNavigateCalendar: () =>
                  HouseholdRoutes.goCalendar(context),
            ),
=======
          // Mock-only storefront (node 100:4854): placeholder handlers,
          // fixed mock balance. Back/Home return to the dashboard.
          builder: (_) => KidsRewardStoreScreen(
            onBack: () => Navigator.of(context).pop(),
            onRequestCustomReward: () =>
                RewardsRoutes.openRequestCustomReward(context),
            onNavigateHome: () => Navigator.of(context).pop(),
            onNavigateCalendar: () =>
                HouseholdRoutes.openTab(context, 'calendar'),
>>>>>>> 48e512845754349ab492b180d4e531d2082a5fd4
          ),
        ),
      );
      return;
    }
    if (!widget.profile.isParent &&
        widget.profile.mode == FamilyMode.teen) {
      RewardsRoutes.openTeenStore(
        context,
        controller: _rewards,
        childName: widget.profile.name,
        availablePoints: _rewards.balanceFor(widget.profile.name),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RewardsScreen(
          controller: _rewards,
          profile: widget.profile,
        ),
      ),
    );
  }

  /// Redeems a kids-store item through the shared ledger and confirms.
  void _redeemExternal(
    BuildContext context,
    String rewardId,
    RewardKind kind,
  ) {
    KidsStoreReward? match;
    for (final candidate in kKidsStoreRewards) {
      if (candidate.id == rewardId) match = candidate;
    }
    final reward = match;
    if (reward == null) return;
    final result = _rewards.redeemExternal(
      childName: widget.profile.name,
      title: reward.name,
      cost: reward.points,
      kind: kind,
    );
    final balance = _rewards.balanceFor(widget.profile.name);
    final message = switch (result) {
      RedeemResult.success => 'Redeemed ${reward.name}! Balance: $balance pts.',
      RedeemResult.insufficient => 'Not enough points for ${reward.name}.',
      RedeemResult.notFound => 'That reward is no longer available.',
    };
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  VoidCallback? _cardAction(String area) => switch (area) {
        FocusAreas.calendar => _openCalendar,
        FocusAreas.chores => () => _openTasks(TasksSegment.chores),
        FocusAreas.homework => () => _openTasks(TasksSegment.homework),
        FocusAreas.rewards => _openRewards,
        _ => null,
      };

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final areas = FocusAreasScope.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const HomeTitle(label: 'HomeSync'),
        actions: [
          if (widget.profile.isParent) const NotificationBell(),
          if (widget.profile.isParent)
            IconButton(
              key: const Key('quick-add-button'),
              tooltip: 'Quick add',
              icon: const Icon(Icons.auto_awesome_rounded),
              onPressed: _openQuickAdd,
            ),
          ProfileAvatarDropdown(
            onManageFamily: _openManageFamily,
            active: _active,
            profiles: _options(),
            parentPin: widget.parentPin,
            onSwitchProfile: (profile) => setState(() => _active = profile),
            onAccountSettings: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      AccountSettingsScreen(profile: widget.profile),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Hello, ${_active.name.split(' ').first}!',
                style: text.headlineMedium,
              ),
              const SizedBox(height: 4),
              Text(_active.roleLabel, style: text.bodyMedium),
              const SizedBox(height: 20),
              if (widget.profile.isParent) ...[
                ReviewQueueSection(controller: _tasks),
                const SizedBox(height: 20),
                PerkRequestsSection(controller: _rewards),
                const SizedBox(height: 20),
                ParentTodoSection(controller: _tasks),
                const SizedBox(height: 20),
<<<<<<< HEAD
                LoadBalanceSection(refreshTrigger: _tasks),
                const SizedBox(height: 20),
=======
                // Parents manage rewards; the child-facing storefront
                // preview stays out of the parent view entirely.
>>>>>>> 48e512845754349ab492b180d4e531d2082a5fd4
                LiquidGlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Rewards (new screens)',
                        style: text.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () =>
                            RewardsRoutes.openReviewQueue(
                              context,
                              controller: _rewards,
                            ),
                        icon: const Icon(Icons.mark_email_read_rounded),
                        label: const Text('Review reward requests'),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () =>
                            RewardsRoutes.openManagement(
                              context,
                              controller: _rewards,
                            ),
                        icon: const Icon(Icons.storefront_rounded),
                        label: const Text('Manage store perks'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
              for (final feature in _features)
                if (areas.has(feature.area)) ...[
                  _FeatureCard(
                    feature: feature,
                    onTap: _cardAction(feature.area),
                  ),
                  const SizedBox(height: 12),
                ],
              if (areas.selected.isEmpty)
                LiquidGlassCard(
                  child: Text(
                    'No focus areas selected — pick some in settings '
                    'to light up your dashboard.',
                    style: text.bodyMedium,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Feature {
  const _Feature(this.area, this.icon, this.blurb);

  final String area;
  final IconData icon;
  final String blurb;
}

const _features = [
  _Feature(
    FocusAreas.calendar,
    Icons.calendar_month_rounded,
    'Upcoming events and the shared family plan.',
  ),
  _Feature(
    FocusAreas.chores,
    Icons.cleaning_services_rounded,
    'Chores, who owns them, and what is due.',
  ),
  _Feature(
    FocusAreas.rewards,
    Icons.stars_rounded,
    'Points balance and the reward store.',
  ),
  _Feature(
    FocusAreas.homework,
    Icons.school_rounded,
    'Homework tracker and due dates.',
  ),
];

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.feature, this.onTap});

  final _Feature feature;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return LiquidGlassCard(
      onTap: onTap,
      child: Row(
        children: [
          Icon(feature.icon, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(feature.area, style: text.titleLarge),
                const SizedBox(height: 4),
                Text(feature.blurb, style: text.bodyMedium),
              ],
            ),
          ),
          if (onTap != null) const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}
