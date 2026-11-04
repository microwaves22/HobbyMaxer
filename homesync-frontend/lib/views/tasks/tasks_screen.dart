import 'package:flutter/material.dart';

import '../../../core/widgets/home_title.dart';
import '../../../core/widgets/liquid_glass_card.dart';
import '../home/household_routes.dart';
import '../onboarding/models/user_profile.dart';
import 'models/chore_task.dart';
import 'tasks_controller.dart';
import 'widgets/submission_sheet.dart';

/// Task list. Children see their own tasks and tap one to open the
/// submission modal; parents see every task in the household.
class TasksScreen extends StatelessWidget {
  const TasksScreen({
    super.key,
    required this.controller,
    required this.profile,
    this.onNavigate,
  });

  final TasksController controller;
  final UserProfile profile;

  /// Called with the tapped bottom-nav tab id. When null, tabs switch
  /// with replacement (no-op for the tasks tab itself).
  final ValueChanged<String>? onNavigate;

  void _handleNavigate(BuildContext context, String tabId) {
    if (onNavigate != null) {
      onNavigate!(tabId);
      return;
    }
    if (tabId == 'tasks') return; // Already on Tasks.
    HouseholdRoutes.openTab(context, tabId);
  }

  Future<void> _openSubmission(BuildContext context, ChoreTask task) async {
    final submitted = await showSubmissionSheet(context, task, controller);
    if (submitted == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Submitted — pending review.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final text = Theme.of(context).textTheme;
        // Parent to-dos live in their own dashboard section, not here.
        final tasks = profile.isParent
            ? controller.tasks.where((t) => !t.isParentTodo).toList()
            : controller.tasksFor(profile.name);
        return Scaffold(
          appBar: AppBar(title: const HomeTitle(label: 'Tasks')),
          bottomNavigationBar: _BottomNav(
            activeTabId: 'tasks',
            onNavigate: (tabId) => _handleNavigate(context, tabId),
          ),
          body: tasks.isEmpty
              ? Center(
                  child: Text('No tasks yet.', style: text.bodyMedium),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(24),
                  itemCount: tasks.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    final submittable = task.state == TaskState.pending ||
                        task.state == TaskState.changesRequested;
                    return LiquidGlassCard(
                      onTap: submittable
                          ? () => _openSubmission(context, task)
                          : null,
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(task.title, style: text.titleLarge),
                                const SizedBox(height: 4),
                                Text(
                                  profile.isParent
                                      ? '${task.childName} · ${task.details}'
                                      : task.details,
                                  style: text.bodyMedium,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    _StateChip(state: task.state),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${task.points} pts',
                                      style: text.labelSmall,
                                    ),
                                    if (task.photoPath != null ||
                                        task.remotePhoto != null) ...[
                                      const SizedBox(width: 8),
                                      const Icon(
                                        Icons.photo_outlined,
                                        size: 16,
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (submittable)
                            const Icon(Icons.chevron_right_rounded),
                        ],
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}

const _navFill = Color.fromRGBO(255, 255, 255, 0.8);
const _navActive = Color(0xFF5F7F55);
const _navMuted = Color(0xFF7C877A);

class _NavTab {
  const _NavTab({required this.id, required this.label, required this.icon});

  final String id;
  final String label;
  final IconData icon;
}

const _navTabs = <_NavTab>[
  _NavTab(id: 'home', label: 'Home', icon: Icons.home_rounded),
  _NavTab(
      id: 'calendar', label: 'Calendar', icon: Icons.calendar_month_rounded),
  _NavTab(id: 'tasks', label: 'Tasks', icon: Icons.checklist_rounded),
  _NavTab(id: 'family', label: 'Family', icon: Icons.group_rounded),
];

/// Household bottom navigation (Home / Calendar / Tasks / Family),
/// matching the calendar, family-time, and hub bars.
class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.activeTabId, required this.onNavigate});

  final String activeTabId;
  final ValueChanged<String> onNavigate;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        color: _navFill,
        padding:
            const EdgeInsets.only(top: 12, left: 20, right: 20, bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final tab in _navTabs)
              _NavTabButton(
                tab: tab,
                active: tab.id == activeTabId,
                onTap: () => onNavigate(tab.id),
              ),
          ],
        ),
      ),
    );
  }
}

/// One bottom-navigation tab: 64px wide, icon over label.
class _NavTabButton extends StatelessWidget {
  const _NavTabButton({
    required this.tab,
    required this.active,
    required this.onTap,
  });

  final _NavTab tab;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? _navActive : _navMuted;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(tab.icon, size: 23, color: color),
            const SizedBox(height: 4),
            Text(
              tab.label,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                fontSize: 11,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StateChip extends StatelessWidget {
  const _StateChip({required this.state});

  final TaskState state;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(state.label),
      visualDensity: VisualDensity.compact,
    );
  }
}
