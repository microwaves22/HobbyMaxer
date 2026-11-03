import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../../core/network/auth_session.dart';
import '../../core/state/focus_areas.dart';
import '../../core/widgets/home_title.dart';
import '../../core/widgets/liquid_glass_card.dart';
import '../../core/widgets/profile_avatar_dropdown.dart';
import '../calendar/calendar_screen.dart';
import '../onboarding/link_kids_screen.dart';
import '../onboarding/models/user_profile.dart';
import '../rewards/rewards_controller.dart';
import '../rewards/rewards_screen.dart';
import '../rewards/widgets/perk_requests_section.dart';
import '../tasks/tasks_api.dart';
import '../tasks/tasks_controller.dart';
import '../tasks/widgets/parent_todo_section.dart';
import '../tasks/tasks_screen.dart';
import '../tasks/teen_todo_list_screen.dart';
import '../tasks/widgets/review_queue_section.dart';

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
  });

  final UserProfile profile;

  /// Other household profiles, for the profile switcher. Empty until
  /// family management lands in settings.
  final List<UserProfile> otherProfiles;

  /// Demo Parent PIN. Wire to the backend (`POST /auth/switch-profile`)
  /// once API integration lands.
  final String parentPin;

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
    _tasks.attachBackend(TasksApi(session.client));
    _tasks.setBalance(user.displayName, user.pointsBalance);
    unawaited(_syncBackend());
  }

  Future<void> _syncBackend() async {
    try {
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
    return ProfileOption(
      name: profile.name,
      roleLabel:
          '${profile.role.label} · ${profile.mode.label} · ${age == null ? 'Age –' : 'Age $age'}',
      isParent: profile.isParent,
    );
  }

  List<ProfileOption> _options() => [
        _toOption(widget.profile),
        for (final other in widget.otherProfiles) _toOption(other),
      ];

  void _openTasks() {
    // Teen profiles get the Figma 03 Teen My To-Do List skeleton; parents
    // and kids keep the generic task list.
    final isTeen =
        !widget.profile.isParent && widget.profile.mode == FamilyMode.teen;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => isTeen
            ? TeenTodoListScreen(
                controller: _tasks,
                profile: widget.profile,
              )
            : TasksScreen(
                controller: _tasks,
                profile: widget.profile,
              ),
      ),
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
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RewardsScreen(
          controller: _rewards,
          profile: widget.profile,
        ),
      ),
    );
  }

  VoidCallback? _cardAction(String area) => switch (area) {
        FocusAreas.calendar => _openCalendar,
        FocusAreas.chores => _openTasks,
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
          ProfileAvatarDropdown(
            onManageFamily: _openManageFamily,
            active: _active,
            profiles: _options(),
            parentPin: widget.parentPin,
            onSwitchProfile: (profile) => setState(() => _active = profile),
            onAccountSettings: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account settings coming soon.'),
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
