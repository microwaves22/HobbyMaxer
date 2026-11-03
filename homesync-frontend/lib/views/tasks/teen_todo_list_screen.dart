import 'package:flutter/material.dart';

import '../../core/theme/figma_tokens.dart';
import '../onboarding/models/user_profile.dart';
import 'models/chore_task.dart';
import 'tasks_controller.dart';
import 'widgets/submission_sheet.dart';

// TODO(figma 100:4622): this screen is a best-effort skeleton. Node
// "Teen My To-Do List" returned HTTP 429 and was never re-pulled, so every
// layout choice below (header copy, progress card, filter labels, tile
// colors/glyphs, card radius, spacing, type sizes) is a placeholder. Once
// the node is re-pulled, replace each inline TODO with the exact spec and
// delete this comment. Do not ship pixel claims as Figma-exact until then.

/// Teen's personal to-do list, styled with the Figma 03 shared tokens.
///
/// Fluid layout for the 375px-wide design: content centers in a max-width
/// column on wide screens and never uses fixed-pixel page widths. No
/// status bar or home indicator is built here (device UI).
class TeenTodoListScreen extends StatefulWidget {
  const TeenTodoListScreen({
    super.key,
    required this.controller,
    required this.profile,
  });

  final TasksController controller;
  final UserProfile profile;

  @override
  State<TeenTodoListScreen> createState() => _TeenTodoListScreenState();
}

enum _TodoFilter { all, todo, inReview, done }

extension on _TodoFilter {
  // TODO(figma 100:4622): confirm filter labels (and whether a filter row
  // exists at all) from the re-pulled node.
  String get label => switch (this) {
        _TodoFilter.all => 'All',
        _TodoFilter.todo => 'To do',
        _TodoFilter.inReview => 'In review',
        _TodoFilter.done => 'Done',
      };

  bool matches(ChoreTask task) => switch (this) {
        _TodoFilter.all => true,
        _TodoFilter.todo => task.state == TaskState.pending ||
            task.state == TaskState.changesRequested,
        _TodoFilter.inReview => task.state == TaskState.pendingReview,
        _TodoFilter.done => task.state == TaskState.approved,
      };
}

class _TeenTodoListScreenState extends State<TeenTodoListScreen> {
  _TodoFilter _filter = _TodoFilter.all;

  Future<void> _openSubmission(BuildContext context, ChoreTask task) async {
    final submitted = await showSubmissionSheet(
      context,
      task,
      widget.controller,
    );
    if (submitted == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Submitted — pending review.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        // Parents see household chores here (parent to-dos live in their
        // own dashboard section); teens see their own tasks only.
        final all = widget.profile.isParent
            ? widget.controller.tasks.where((t) => !t.isParentTodo).toList()
            : widget.controller.tasksFor(widget.profile.name);
        final visible = all.where(_filter.matches).toList();
        final doneCount =
            all.where((t) => t.state == TaskState.approved).length;
        final balance = widget.controller.balanceFor(widget.profile.name);

        return Scaffold(
          backgroundColor: FigmaColors.cream,
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                // Fluid cap for tablets/desktop; phones use full width.
                constraints: const BoxConstraints(maxWidth: 560),
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: _Header(
                        doneCount: doneCount,
                        totalCount: all.length,
                        balance: balance,
                        profileName: widget.profile.name,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _FilterRow(
                        selected: _filter,
                        onSelect: (f) => setState(() => _filter = f),
                      ),
                    ),
                    if (visible.isEmpty)
                      const SliverToBoxAdapter(child: _EmptyState())
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                        sliver: SliverList.separated(
                          itemCount: visible.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final task = visible[index];
                            return _TodoCard(
                              task: task,
                              tileColor: FigmaColors.tileRotation[
                                  index % FigmaColors.tileRotation.length],
                              onTap: _isSubmittable(task)
                                  ? () => _openSubmission(context, task)
                                  : null,
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static bool _isSubmittable(ChoreTask task) =>
      task.state == TaskState.pending ||
      task.state == TaskState.changesRequested;
}

class _Header extends StatelessWidget {
  const _Header({
    required this.doneCount,
    required this.totalCount,
    required this.balance,
    required this.profileName,
  });

  final int doneCount;
  final int totalCount;
  final int balance;
  final String profileName;

  @override
  Widget build(BuildContext context) {
    // TODO(figma 100:4622): confirm header copy, alignment, back-button
    // placement, and whether the points pill lives here.
    final progress = totalCount == 0 ? 0.0 : doneCount / totalCount;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                // TODO(figma 100:4622): replace with the local
                // `chevron-left` SVG export. Never hotlink Figma URLs.
                icon: const Icon(Icons.chevron_left_rounded),
                color: FigmaColors.ink,
                tooltip: 'Back',
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: Text(
                  // TODO(figma 100:4622): confirm exact title case/copy.
                  'My To-Do List',
                  style: FigmaType.screenTitle(),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: FigmaColors.sageLight,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // TODO(figma 100:4622): replace with `icon/star` SVG.
                    const Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: FigmaColors.sageDark,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      // TODO(figma 100:4622): confirm points format.
                      '$balance pts',
                      style: FigmaType.points(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 0, 12),
            child: Container(
              decoration: FigmaCards.whiteCard(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    // TODO(figma 100:4622): confirm progress copy.
                    totalCount == 0
                        ? 'Nothing assigned yet.'
                        : '$doneCount of $totalCount done',
                    style: FigmaType.cardTitle(),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Hey $profileName — tap a chore to submit it.',
                    style: FigmaType.body(),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: FigmaColors.sageLight,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        FigmaColors.sage,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.selected, required this.onSelect});

  final _TodoFilter selected;
  final ValueChanged<_TodoFilter> onSelect;

  @override
  Widget build(BuildContext context) {
    // TODO(figma 100:4622): confirm chip labels, selected/unselected
    // fills, and horizontal padding from the re-pulled node.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Row(
        children: [
          for (final filter in _TodoFilter.values) ...[
            if (filter != _TodoFilter.values.first) const SizedBox(width: 8),
            ChoiceChip(
              label: Text(filter.label),
              selected: selected == filter,
              onSelected: (_) => onSelect(filter),
              selectedColor: FigmaColors.sage,
              backgroundColor: FigmaColors.white,
              labelStyle: FigmaType.label(
                color: selected == filter ? FigmaColors.white : FigmaColors.ink,
              ),
              side: const BorderSide(color: FigmaColors.line),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TodoCard extends StatelessWidget {
  const _TodoCard({
    required this.task,
    required this.tileColor,
    this.onTap,
  });

  final ChoreTask task;
  final Color tileColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final submittable = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: FigmaCards.whiteCard(),
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TileGlyph(task: task, background: tileColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.title, style: FigmaType.cardTitle()),
                  const SizedBox(height: 2),
                  Text(
                    task.details,
                    style: FigmaType.body(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // TODO(figma 100:4622): replace with `icon/star`.
                          const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: FigmaColors.sage,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${task.points} pts',
                            style: FigmaType.points(),
                          ),
                        ],
                      ),
                      _StatusPill(state: task.state),
                      if (task.requiresPhoto)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.photo_camera_outlined,
                              size: 14,
                              color: FigmaColors.mute,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Photo',
                              style: FigmaType.label(
                                color: FigmaColors.mute,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _TrailingAction(state: task.state, submittable: submittable),
          ],
        ),
      ),
    );
  }
}

/// Pastel tile with a glyph. Material icons are stand-ins only: the Figma
/// tile/avatar glyphs (laundry basket, plate, bed, cat, …) must come from
/// local SVG exports. No emoji anywhere.
class _TileGlyph extends StatelessWidget {
  const _TileGlyph({required this.task, required this.background});

  final ChoreTask task;
  final Color background;

  // TODO(figma 100:4622): replace this keyword guess with the exact
  // per-task glyph + tile color + glyph size from the re-pulled node.
  IconData _glyphFor(ChoreTask task) {
    final haystack = '${task.title} ${task.details}'.toLowerCase();
    if (haystack.contains('trash') || haystack.contains('laundry')) {
      return Icons.local_laundry_service_outlined;
    }
    if (haystack.contains('dish') || haystack.contains('plate')) {
      return Icons.dinner_dining_outlined;
    }
    if (haystack.contains('bed') || haystack.contains('tidy')) {
      return Icons.bed_outlined;
    }
    if (haystack.contains('cat') || haystack.contains('pet')) {
      return Icons.pets_outlined;
    }
    if (haystack.contains('plant') || haystack.contains('water')) {
      return Icons.spa_outlined;
    }
    if (haystack.contains('read') || haystack.contains('book')) {
      return Icons.menu_book_outlined;
    }
    if (haystack.contains('math') || haystack.contains('homework')) {
      return Icons.calculate_outlined;
    }
    return Icons.task_alt_outlined;
  }

  @override
  Widget build(BuildContext context) {
    // TODO(figma 100:4622): confirm tile size, radius, and glyph size.
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(_glyphFor(task), color: FigmaColors.ink, size: 24),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.state});

  final TaskState state;

  @override
  Widget build(BuildContext context) {
    // TODO(figma 100:4622): confirm status copy, colors, and whether a
    // pill exists per card.
    final (label, background, foreground) = switch (state) {
      TaskState.pending => (
          'To do',
          FigmaColors.pastelYellow,
          FigmaColors.ink,
        ),
      TaskState.pendingReview => (
          'In review',
          FigmaColors.pastelBlue,
          FigmaColors.ink,
        ),
      TaskState.approved => (
          'Done',
          FigmaColors.sageLight,
          FigmaColors.sageDark,
        ),
      TaskState.changesRequested => (
          'Try again',
          FigmaColors.pastelPink,
          FigmaColors.ink,
        ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: FigmaType.label(color: foreground),
      ),
    );
  }
}

class _TrailingAction extends StatelessWidget {
  const _TrailingAction({required this.state, required this.submittable});

  final TaskState state;
  final bool submittable;

  @override
  Widget build(BuildContext context) {
    // TODO(figma 100:4622): confirm the trailing affordance (checkbox vs
    // chevron vs button) and its size.
    if (state == TaskState.approved) {
      return const DecoratedBox(
        decoration: BoxDecoration(
          color: FigmaColors.sage,
          shape: BoxShape.circle,
        ),
        child: Padding(
          padding: EdgeInsets.all(6),
          child: Icon(
            // TODO(figma 100:4622): replace with `icon/check` SVG.
            Icons.check_rounded,
            size: 18,
            color: FigmaColors.white,
          ),
        ),
      );
    }
    if (state == TaskState.pendingReview) {
      return const DecoratedBox(
        decoration: BoxDecoration(
          color: FigmaColors.sageLight,
          shape: BoxShape.circle,
        ),
        child: Padding(
          padding: EdgeInsets.all(6),
          child: Icon(
            Icons.hourglass_top_rounded,
            size: 18,
            color: FigmaColors.sageDark,
          ),
        ),
      );
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: FigmaColors.sageMid, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(
          submittable ? Icons.chevron_right_rounded : Icons.lock_outline,
          size: 18,
          color: FigmaColors.sageDark,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    // TODO(figma 100:4622): confirm empty-state copy and illustration.
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Container(
        decoration: FigmaCards.whiteCard(),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(
              Icons.task_alt_outlined,
              size: 40,
              color: FigmaColors.sageMid,
            ),
            const SizedBox(height: 12),
            Text('All clear', style: FigmaType.cardTitle()),
            const SizedBox(height: 4),
            Text(
              'Nothing here under this filter.',
              style: FigmaType.body(),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
