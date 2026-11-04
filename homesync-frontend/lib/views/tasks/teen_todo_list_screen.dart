import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/figma_tokens.dart';
import '../onboarding/models/user_profile.dart';
import 'tasks_controller.dart';

/// Teen background (Figma 100:4622): #F4F3EF, NOT cream.
const _teenBg = Color(0xFFF4F3EF);

/// Frosted-card shadow, copied exactly from the screen spec:
/// `0px 5px 16px -4px rgba(59,77,56,0.07)`.
const _cardShadow = BoxShadow(
  color: Color.fromRGBO(59, 77, 56, 0.07),
  offset: Offset(0, 5),
  blurRadius: 16,
  spreadRadius: -4,
);

/// Nunito text in the exact size/weight/color, defaulting to the screen's
/// 1.35 line height.
TextStyle _nunito(double size, FontWeight weight, Color color,
        {double height = 1.35}) =>
    GoogleFonts.nunito(
      fontSize: size,
      fontWeight: weight,
      height: height,
      color: color,
    );

/// A category chip in the add-task form.
class TeenCategory {
  const TeenCategory({
    required this.id,
    required this.label,
    this.selected = false,
  });

  final String id;
  final String label;
  final bool selected;

  TeenCategory copyWith({bool? selected}) => TeenCategory(
        id: id,
        label: label,
        selected: selected ?? this.selected,
      );
}

/// A teen-created personal task. No points, no parent review.
class TeenPersonalTask {
  const TeenPersonalTask({
    required this.id,
    required this.title,
    required this.category,
    required this.due,
    required this.meta,
    this.completed = false,
  });

  final String id;
  final String title;
  final String category;
  final String due;
  final String meta;
  final bool completed;

  TeenPersonalTask copyWith({bool? completed}) => TeenPersonalTask(
        id: id,
        title: title,
        category: category,
        due: due,
        meta: meta,
        completed: completed ?? this.completed,
      );
}

/// A parent-assigned chore link.
class TeenParentChore {
  const TeenParentChore({
    required this.id,
    required this.title,
    required this.time,
  });

  final String id;
  final String title;
  final String time;
}

/// Teen Mode "My To-Do List" for Noah, built exactly from Figma node
/// 100:4622: a long scrolling 375px design on #F4F3EF, frosted cards with
/// real backdrop blur, and the bottom nav after the content.
///
/// No status bar or home indicator is built here (device UI). No backend
/// or persistence: adding a task and toggling completion only touch
/// local state. [controller] is retained for API compatibility with the
/// dashboard entry point; personal tasks are local-only by design.
class TeenTodoListScreen extends StatefulWidget {
  const TeenTodoListScreen({
    super.key,
    required this.controller,
    required this.profile,
    this.onBack,
    this.onSelectCategory,
    this.onAddTask,
    this.onToggleTaskComplete,
    this.onParentChorePress,
    this.onNavigateHome,
    this.onNavigateRewards,
    this.onNavigateCalendar,
  });

  final TasksController controller;
  final UserProfile profile;

  /// Back button placeholder. Falls back to [Navigator.maybePop].
  final VoidCallback? onBack;
  final ValueChanged<String>? onSelectCategory;
  final VoidCallback? onAddTask;
  final ValueChanged<String>? onToggleTaskComplete;
  final ValueChanged<String>? onParentChorePress;

  /// Bottom-nav placeholders (Home is the active tab in the design).
  final VoidCallback? onNavigateHome;
  final VoidCallback? onNavigateRewards;
  final VoidCallback? onNavigateCalendar;

  @override
  State<TeenTodoListScreen> createState() => _TeenTodoListScreenState();
}

class _TeenTodoListScreenState extends State<TeenTodoListScreen> {
  static const parentChores = [
    TeenParentChore(
      id: 'math-homework',
      title: 'Math homework',
      time: '6:00 PM',
    ),
    TeenParentChore(
      id: 'vacuum-living',
      title: 'Vacuum living room',
      time: '7:00 PM',
    ),
  ];

  List<TeenCategory> _categories = const [
    TeenCategory(id: 'homework', label: 'Homework', selected: true),
    TeenCategory(id: 'personal-goal', label: 'Personal goal'),
    TeenCategory(id: 'task', label: 'Task'),
  ];

  List<TeenPersonalTask> _personalTasks = const [
    TeenPersonalTask(
      id: 'history-chapter',
      title: 'Read history chapter 4',
      category: 'Homework',
      due: 'Today, 5:00 PM',
      meta: 'Homework · Today, 5:00 PM',
    ),
    TeenPersonalTask(
      id: 'run-mile',
      title: 'Run a mile',
      category: 'Personal goal',
      due: 'Sun, Nov 1',
      meta: 'Personal goal · Sun, Nov 1',
    ),
    TeenPersonalTask(
      id: 'pack-soccer-bag',
      title: 'Pack soccer bag',
      category: 'Task',
      due: 'Today',
      meta: 'Task · Completed today',
      completed: true,
    ),
  ];

  final _titleController = TextEditingController(
    text: 'Outline science project',
  );

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _onSelectCategory(String id) {
    setState(() {
      _categories = [
        for (final category in _categories)
          category.copyWith(selected: category.id == id),
      ];
    });
    widget.onSelectCategory?.call(id);
  }

  void _onToggleTaskComplete(String taskId) {
    setState(() {
      _personalTasks = [
        for (final task in _personalTasks)
          if (task.id == taskId)
            task.copyWith(completed: !task.completed)
          else
            task,
      ];
    });
    widget.onToggleTaskComplete?.call(taskId);
  }

  void _onAddTask() {
    final category = _categories.firstWhere(
      (category) => category.selected,
      orElse: () => _categories.first,
    );
    setState(() {
      _personalTasks = [
        ..._personalTasks,
        TeenPersonalTask(
          id: 'own-${_personalTasks.length}',
          title: _titleController.text,
          category: category.label,
          due: 'Today, 5:00 PM',
          meta: '${category.label} · Today, 5:00 PM',
        ),
      ];
    });
    widget.onAddTask?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _teenBg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            // Fluid cap for tablets/desktop; phones use full width.
            constraints: const BoxConstraints(maxWidth: 560),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _PageHeading(
                          profile: widget.profile,
                          onBack: widget.onBack ??
                              () => Navigator.of(context).maybePop(),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Your plans, your pace. Personal tasks are just '
                          'for you — no points or parent review.',
                          style: _nunito(
                            13,
                            FontWeight.w500,
                            FigmaColors.mute,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _AddTaskCard(
                          titleController: _titleController,
                          categories: _categories,
                          onSelectCategory: _onSelectCategory,
                          onAddTask: _onAddTask,
                        ),
                        const SizedBox(height: 16),
                        _CreatedByMeCard(
                          tasks: _personalTasks,
                          onToggleTaskComplete: _onToggleTaskComplete,
                        ),
                        const SizedBox(height: 16),
                        _ParentChoresCard(
                          chores: parentChores,
                          onParentChorePress:
                              widget.onParentChorePress ?? (_) {},
                        ),
                      ],
                    ),
                  ),
                  _BottomNav(
                    onNavigateHome: widget.onNavigateHome ?? () {},
                    onNavigateRewards: widget.onNavigateRewards ?? () {},
                    onNavigateCalendar: widget.onNavigateCalendar ?? () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Frosted card: translucent white, 9px backdrop blur, 1px white border,
/// 22px radius, and the exact card shadow.
class _FrostedCard extends StatelessWidget {
  const _FrostedCard({
    required this.child,
    this.fill = FigmaColors.frostedFill,
  });

  final Widget child;
  final Color fill;

  @override
  Widget build(BuildContext context) {
    // Shadow lives on the outer box so the clip below (required for the
    // blur) cannot cut it off.
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [_cardShadow],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 9, sigmaY: 9),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: FigmaColors.white, width: 1),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Header: back button + avatar row, then the title block.
class _PageHeading extends StatelessWidget {
  const _PageHeading({required this.profile, required this.onBack});

  final UserProfile profile;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final initial =
        profile.name.isEmpty ? '?' : profile.name.characters.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              key: const ValueKey('teen-back'),
              onTap: onBack,
              child: Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: FigmaColors.frostedStrong,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chevron_left_rounded,
                  size: 20,
                  color: FigmaColors.ink,
                ),
              ),
            ),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: FigmaColors.sageLight,
                shape: BoxShape.circle,
                border: Border.all(color: FigmaColors.white, width: 1),
              ),
              alignment: Alignment.center,
              child: Text(
                initial,
                style: _nunito(
                  16,
                  FontWeight.w800,
                  FigmaColors.sageDark,
                  height: 1,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          'My To-Do List',
          style: _nunito(26, FontWeight.w800, FigmaColors.ink),
        ),
        const SizedBox(height: 4),
        Text(
          '${profile.name} · 14 · Teen Mode',
          style: _nunito(12, FontWeight.w500, FigmaColors.mute),
        ),
      ],
    );
  }
}

/// "New personal task" form. The title field is pre-filled with entered
/// text (not a placeholder); chips render from [categories].
class _AddTaskCard extends StatelessWidget {
  const _AddTaskCard({
    required this.titleController,
    required this.categories,
    required this.onSelectCategory,
    required this.onAddTask,
  });

  final TextEditingController titleController;
  final List<TeenCategory> categories;
  final ValueChanged<String> onSelectCategory;
  final VoidCallback onAddTask;

  static const _inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(14)),
    borderSide: BorderSide(color: FigmaColors.line, width: 1),
  );

  @override
  Widget build(BuildContext context) {
    return _FrostedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.add_rounded,
                size: 20,
                color: FigmaColors.ink,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'New personal task',
                  style: _nunito(17, FontWeight.w800, FigmaColors.ink),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Task title',
                style: _nunito(12, FontWeight.w800, FigmaColors.ink),
              ),
              const SizedBox(height: 6),
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 46),
                child: TextField(
                  key: const ValueKey('teen-task-title'),
                  controller: titleController,
                  style: _nunito(14, FontWeight.w600, FigmaColors.ink),
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: FigmaColors.frostedStrong,
                    contentPadding: EdgeInsets.all(12),
                    border: _inputBorder,
                    enabledBorder: _inputBorder,
                    focusedBorder: _inputBorder,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Category',
                style: _nunito(12, FontWeight.w800, FigmaColors.ink),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  for (var i = 0; i < categories.length; i++) ...[
                    if (i > 0) const SizedBox(width: 6),
                    GestureDetector(
                      key: ValueKey('teen-category-${categories[i].id}'),
                      onTap: () => onSelectCategory(categories[i].id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 9,
                          horizontal: 10,
                        ),
                        decoration: BoxDecoration(
                          color: categories[i].selected
                              ? FigmaColors.sage
                              : FigmaColors.frostedStrong,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          categories[i].label,
                          style: _nunito(
                            11,
                            FontWeight.w800,
                            categories[i].selected
                                ? FigmaColors.white
                                : FigmaColors.sage,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            key: const ValueKey('teen-add-task'),
            onTap: onAddTask,
            child: Container(
              height: 54,
              padding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 20,
              ),
              decoration: BoxDecoration(
                color: FigmaColors.sage,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [FigmaShadows.primaryButton],
              ),
              alignment: Alignment.center,
              child: Text(
                'Add Task',
                style: _nunito(15, FontWeight.w800, FigmaColors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Created by me" personal tasks, rendered from [tasks] with dividers
/// between rows only. The progress pill is derived from state.
class _CreatedByMeCard extends StatelessWidget {
  const _CreatedByMeCard({
    required this.tasks,
    required this.onToggleTaskComplete,
  });

  final List<TeenPersonalTask> tasks;
  final ValueChanged<String> onToggleTaskComplete;

  @override
  Widget build(BuildContext context) {
    final doneCount = tasks.where((task) => task.completed).length;
    return _FrostedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  'Created by me',
                  style: _nunito(17, FontWeight.w800, FigmaColors.ink),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  color: FigmaColors.sageLight,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$doneCount of ${tasks.length} done',
                  style: _nunito(
                    11,
                    FontWeight.w800,
                    FigmaColors.sageDark,
                  ),
                ),
              ),
            ],
          ),
          // NOTE (merge reconstruction): the per-row loop below was
          // mangled in the main merge; restored per this class's doc —
          // dividers between rows only.
          for (var i = 0; i < tasks.length; i++) ...[
            if (i > 0)
              const Divider(
                height: 1,
                thickness: 1,
                color: FigmaColors.line,
              ),
            _taskRow(tasks[i]),
          ],
        ],
      ),
    );
  }

  Widget _taskRow(TeenPersonalTask task) {
    return Container(
      constraints: const BoxConstraints(minHeight: 66),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            key: ValueKey('teen-complete-${task.id}'),
            onTap: () => onToggleTaskComplete(task.id),
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: task.completed
                    ? FigmaColors.sage
                    : FigmaColors.frostedStrong,
                shape: BoxShape.circle,
                border: Border.all(
                  color: task.completed
                      ? FigmaColors.sage
                      : FigmaColors.sageMid,
                  width: 1,
                ),
              ),
              alignment: Alignment.center,
              child: task.completed
                  ? const Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: FigmaColors.white,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: _nunito(14, FontWeight.w700, FigmaColors.ink),
                ),
                const SizedBox(height: 3),
                Text(
                  task.meta,
                  style: _nunito(11, FontWeight.w500, FigmaColors.mute),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "Assigned by Sarah" on a sageLight frosted card: exactly two rows,
/// no checkboxes, plus the verbatim footnote.
class _ParentChoresCard extends StatelessWidget {
  const _ParentChoresCard({
    required this.chores,
    required this.onParentChorePress,
  });

  final List<TeenParentChore> chores;
  final ValueChanged<String> onParentChorePress;

  @override
  Widget build(BuildContext context) {
    return _FrostedCard(
      fill: FigmaColors.sageLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.group_outlined,
                size: 18,
                color: FigmaColors.ink,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Assigned by Sarah',
                  style: _nunito(15, FontWeight.w800, FigmaColors.ink),
                ),
              ),
            ],
          ),
          for (final chore in chores) ...[
            const SizedBox(height: 12),
            GestureDetector(
              key: ValueKey('teen-parent-chore-${chore.id}'),
              onTap: () => onParentChorePress(chore.id),
              child: Container(
                constraints: const BoxConstraints(minHeight: 44),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            chore.title,
                            style: _nunito(
                              13,
                              FontWeight.w700,
                              FigmaColors.ink,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            chore.time,
                            style: _nunito(
                              12,
                              FontWeight.w500,
                              FigmaColors.mute,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: FigmaColors.ink,
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            'Separate from your list · Photo/video and parent review '
            'required for chore points.',
            style: _nunito(11, FontWeight.w500, FigmaColors.mute),
          ),
        ],
      ),
    );
  }
}

/// Bottom nav with exactly Home (active), Rewards, Calendar.
class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.onNavigateHome,
    required this.onNavigateRewards,
    required this.onNavigateCalendar,
  });

  final VoidCallback onNavigateHome;
  final VoidCallback onNavigateRewards;
  final VoidCallback onNavigateCalendar;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FigmaColors.frostedStrong,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _tab(
                keyName: 'teen-nav-home',
                label: 'Home',
                icon: Icons.home_rounded,
                active: true,
                onTap: onNavigateHome,
              ),
              _tab(
                keyName: 'teen-nav-rewards',
                label: 'Rewards',
                icon: Icons.stars_rounded,
                active: false,
                onTap: onNavigateRewards,
              ),
              _tab(
                keyName: 'teen-nav-calendar',
                label: 'Calendar',
                icon: Icons.calendar_month_rounded,
                active: false,
                onTap: onNavigateCalendar,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tab({
    required String keyName,
    required String label,
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      key: ValueKey(keyName),
      onTap: onTap,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 23,
              color: active ? FigmaColors.sage : FigmaColors.mute,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: _nunito(
                11,
                active ? FontWeight.w800 : FontWeight.w600,
                active ? FigmaColors.sage : FigmaColors.mute,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
