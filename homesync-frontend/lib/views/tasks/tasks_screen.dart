import 'package:flutter/material.dart';

import '../../../core/widgets/home_title.dart';
import '../../../core/widgets/liquid_glass_card.dart';
import '../onboarding/models/user_profile.dart';
import 'models/chore_task.dart';
import 'tasks_controller.dart';
import 'widgets/chore_edit_dialog.dart';
import 'widgets/submission_sheet.dart';

/// Task list. Children see their own tasks and tap one to open the
/// submission modal; parents see every task in the household.
/// Chores sent back for revision show the parent's feedback with a
/// Retry action; parents can edit any chore inline.
class TasksScreen extends StatelessWidget {
  const TasksScreen({
    super.key,
    required this.controller,
    required this.profile,
  });

  final TasksController controller;
  final UserProfile profile;

  Future<void> _openSubmission(BuildContext context, ChoreTask task) async {
    final submitted = await showSubmissionSheet(context, task, controller);
    if (submitted == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Submitted — pending review.')),
      );
    }
  }

  Future<void> _editChore(BuildContext context, ChoreTask task) async {
    final result = await showChoreEditDialog(context, task);
    if (result == null || !context.mounted) return;
    final updated = controller.updateChore(
      task.id,
      points: result.points,
      details: result.details,
      requiresPhoto: result.requiresPhoto,
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(updated ? 'Chore updated.' : 'No changes to save.'),
      ),
    );
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
                    final feedback = task.feedback;
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
                                if (feedback != null &&
                                    feedback.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondaryContainer,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Feedback: $feedback',
                                      style: text.bodySmall,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (profile.isParent)
                            IconButton(
                              tooltip: 'Edit chore',
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () => _editChore(context, task),
                            ),
                          if (submittable)
                            task.state == TaskState.changesRequested
                                ? TextButton(
                                    onPressed: () =>
                                        _openSubmission(context, task),
                                    child: const Text('Retry'),
                                  )
                                : const Icon(Icons.chevron_right_rounded),
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
