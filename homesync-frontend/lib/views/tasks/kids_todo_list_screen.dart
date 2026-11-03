import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/figma_tokens.dart';

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

/// A destination in the "Assign Tasks" dropdown menu (block 2).
///
/// The Figma icon name is kept in [iconName]; [icon] is the matching
/// project-library (Material) glyph.
class Destination {
  const Destination({
    required this.id,
    required this.label,
    this.sublabel,
    required this.iconName,
    required this.icon,
    required this.state,
    this.badge,
  });

  final String id;
  final String label;
  final String? sublabel;
  final String iconName;
  final IconData icon;
  final DestinationState state;
  final String? badge;
}

enum DestinationState { current, locked }

/// A category chip in the add-task form (block 4).
class Category {
  const Category({
    required this.id,
    required this.label,
    this.selected = false,
  });

  final String id;
  final String label;
  final bool selected;

  Category copyWith({bool? selected}) => Category(
        id: id,
        label: label,
        selected: selected ?? this.selected,
      );
}

/// A child-created practice task (block 5). No points, no parent review.
class PersonalTask {
  const PersonalTask({
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

  PersonalTask copyWith({bool? completed}) => PersonalTask(
        id: id,
        title: title,
        category: category,
        due: due,
        meta: meta,
        completed: completed ?? this.completed,
      );
}

/// A parent-assigned chore link (block 6).
class ParentChore {
  const ParentChore({
    required this.id,
    required this.title,
    required this.note,
  });

  final String id;
  final String title;
  final String note;
}

/// Kids Mode "My To-Do List" for Ava, built exactly from Figma node
/// 100:4739: a long scrolling 375px design on cream, frosted cards with
/// real backdrop blur, and the bottom nav after the content.
///
/// No status bar or home indicator is built here (device UI, and no other
/// project bottom nav renders one). No backend or persistence: adding a
/// task and toggling completion only touch local state.
class KidsTodoListScreen extends StatefulWidget {
  const KidsTodoListScreen({
    super.key,
    this.onBack,
    this.onToggleDestinationMenu,
    this.onOpenProfile,
    this.onSelectMyToDoList,
    this.onSelectParentAssignment,
    this.onSelectCategory,
    this.onPickDueDate,
    this.onAddTask,
    this.onEditTask,
    this.onToggleTaskComplete,
    this.onOpenParentChores,
    this.onNavigateHome,
    this.onNavigateRewards,
    this.onNavigateCalendar,
  });

  final VoidCallback? onBack;
  final VoidCallback? onToggleDestinationMenu;
  final VoidCallback? onOpenProfile;
  final VoidCallback? onSelectMyToDoList;
  final VoidCallback? onSelectParentAssignment;
  final ValueChanged<String>? onSelectCategory;
  final VoidCallback? onPickDueDate;
  final VoidCallback? onAddTask;
  final ValueChanged<String>? onEditTask;
  final ValueChanged<String>? onToggleTaskComplete;
  final VoidCallback? onOpenParentChores;
  final VoidCallback? onNavigateHome;
  final VoidCallback? onNavigateRewards;
  final VoidCallback? onNavigateCalendar;

  @override
  State<KidsTodoListScreen> createState() => _KidsTodoListScreenState();
}

class _KidsTodoListScreenState extends State<KidsTodoListScreen> {
  static const destinations = [
    Destination(
      id: 'my-to-do',
      label: 'My To-Do List',
      iconName: 'circle-check',
      icon: Icons.check_circle_outline_rounded,
      state: DestinationState.current,
      badge: 'Current',
    ),
    Destination(
      id: 'parent-assignment',
      label: 'Parent To-Do & Chore Assignment',
      sublabel: 'Parent account only',
      iconName: 'lock-keyhole',
      icon: Icons.lock_outline_rounded,
      state: DestinationState.locked,
    ),
  ];

  static const parentChores = [
    ParentChore(
      id: 'clean-desk',
      title: 'Clean your desk',
      note: 'Separate from my list · Parent review for points',
    ),
  ];

  List<Category> _categories = const [
    Category(id: 'homework', label: 'Homework', selected: true),
    Category(id: 'personal-goal', label: 'Personal goal'),
    Category(id: 'task', label: 'Task'),
  ];

  List<PersonalTask> _personalTasks = const [
    PersonalTask(
      id: 'read-book',
      title: 'Read my library book',
      category: 'Homework',
      due: 'Today, 5:00 PM',
      meta: 'Homework · Today, 5:00 PM',
    ),
    PersonalTask(
      id: 'draw-cat',
      title: 'Learn to draw a cat',
      category: 'Personal goal',
      due: 'Tomorrow',
      meta: 'Personal goal · Tomorrow',
    ),
    PersonalTask(
      id: 'pack-crayons',
      title: 'Pack my crayons',
      category: 'Task',
      due: 'Today',
      meta: 'Task · All done today!',
      completed: true,
    ),
  ];

  final _titleController = TextEditingController(
    text: 'Practice my spelling',
  );
  final String _dueText = 'Today, Oct 31 · 4:30 PM';

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
        PersonalTask(
          id: 'own-${_personalTasks.length}',
          title: _titleController.text,
          category: category.label,
          due: _dueText,
          meta: '${category.label} · $_dueText',
        ),
      ];
    });
    widget.onAddTask?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FigmaColors.cream,
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
                          onBack: widget.onBack ??
                              () => Navigator.of(context).maybePop(),
                          onToggleDestinationMenu:
                              widget.onToggleDestinationMenu ?? () {},
                          onOpenProfile: widget.onOpenProfile ?? () {},
                        ),
                        const SizedBox(height: 16),
                        _DestinationCard(
                          destinations: destinations,
                          onSelectMyToDoList:
                              widget.onSelectMyToDoList ?? () {},
                          onSelectParentAssignment:
                              widget.onSelectParentAssignment ?? () {},
                        ),
                        const SizedBox(height: 16),
                        const _EncouragementBanner(),
                        const SizedBox(height: 16),
                        _AddTaskCard(
                          titleController: _titleController,
                          categories: _categories,
                          dueText: _dueText,
                          onSelectCategory: _onSelectCategory,
                          onPickDueDate: widget.onPickDueDate ?? () {},
                          onAddTask: _onAddTask,
                        ),
                        const SizedBox(height: 16),
                        _MadeByMeCard(
                          tasks: _personalTasks,
                          onToggleTaskComplete: _onToggleTaskComplete,
                          onEditTask: widget.onEditTask ?? (_) {},
                        ),
                        const SizedBox(height: 16),
                        _ParentChoresCard(
                          chores: parentChores,
                          onOpenParentChores:
                              widget.onOpenParentChores ?? () {},
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

/// Frosted card shared by blocks 2, 4, and 5 (and block 6 with a
/// sageLight fill): translucent white, 9px backdrop blur, 1px white
/// border, 22px radius, and the exact card shadow.
class _FrostedCard extends StatelessWidget {
  const _FrostedCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.fill = FigmaColors.frostedFill,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
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
            padding: padding,
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

/// Block 1: nav header (back, "Assign Tasks" trigger, avatar) plus the
/// title block.
class _PageHeading extends StatelessWidget {
  const _PageHeading({
    required this.onBack,
    required this.onToggleDestinationMenu,
    required this.onOpenProfile,
  });

  final VoidCallback onBack;
  final VoidCallback onToggleDestinationMenu;
  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              key: const ValueKey('kids-back'),
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
            GestureDetector(
              key: const ValueKey('kids-destination-trigger'),
              onTap: onToggleDestinationMenu,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 14,
                ),
                decoration: BoxDecoration(
                  color: FigmaColors.frostedFill,
                  border: Border.all(color: FigmaColors.white, width: 1),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [_cardShadow],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Assign Tasks',
                      style: _nunito(15, FontWeight.w800, FigmaColors.ink),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.expand_more_rounded,
                      size: 16,
                      color: FigmaColors.ink,
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              key: const ValueKey('kids-profile'),
              onTap: onOpenProfile,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: FigmaColors.pink,
                  shape: BoxShape.circle,
                  border: Border.all(color: FigmaColors.white, width: 1),
                ),
                alignment: Alignment.center,
                child: Text(
                  '🐱',
                  style: _nunito(
                    23,
                    FontWeight.w400,
                    FigmaColors.sageDark,
                    height: 1,
                  ),
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
          'Ava · 8 · Kids Mode',
          style: _nunito(12, FontWeight.w500, FigmaColors.mute),
        ),
      ],
    );
  }
}

/// Block 2: the open "Assign Tasks" destination menu, rendered from
/// [destinations]. The locked parent row never navigates.
class _DestinationCard extends StatelessWidget {
  const _DestinationCard({
    required this.destinations,
    required this.onSelectMyToDoList,
    required this.onSelectParentAssignment,
  });

  final List<Destination> destinations;
  final VoidCallback onSelectMyToDoList;
  final VoidCallback onSelectParentAssignment;

  @override
  Widget build(BuildContext context) {
    return _FrostedCard(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < destinations.length; i++) ...[
            if (i > 0) const SizedBox(height: 4),
            _destinationRow(destinations[i]),
          ],
        ],
      ),
    );
  }

  Widget _destinationRow(Destination destination) {
    if (destination.state == DestinationState.current) {
      return GestureDetector(
        key: ValueKey('destination-${destination.id}'),
        onTap: onSelectMyToDoList,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: FigmaColors.sageLight,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                destination.icon,
                size: 18,
                color: FigmaColors.sageDark,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  destination.label,
                  style: _nunito(13, FontWeight.w800, FigmaColors.ink),
                ),
              ),
              const SizedBox(width: 10),
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
                  destination.badge ?? '',
                  style: _nunito(
                    11,
                    FontWeight.w800,
                    FigmaColors.sageDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    // Locked parent destination: disabled visual state only. The tap
    // calls the placeholder and must never open the parent screen.
    return GestureDetector(
      key: ValueKey('destination-${destination.id}'),
      onTap: onSelectParentAssignment,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              destination.icon,
              size: 16,
              color: FigmaColors.mute,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    destination.label,
                    style: _nunito(12, FontWeight.w700, FigmaColors.mute),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    destination.sublabel ?? '',
                    style: _nunito(10, FontWeight.w500, FigmaColors.mute),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Block 3: yellow encouragement banner.
class _EncouragementBanner extends StatelessWidget {
  const _EncouragementBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: FigmaColors.yellowLight,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: FigmaColors.pink,
              borderRadius: BorderRadius.circular(24),
            ),
            alignment: Alignment.center,
            child: Text(
              '🐱',
              style: _nunito(30, FontWeight.w400, Colors.black, height: 1),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Little plans, big smiles!',
                  style: _nunito(16, FontWeight.w800, FigmaColors.ink),
                ),
                const SizedBox(height: 3),
                Text(
                  'Your own tasks are for practice. '
                  'No points or parent review.',
                  style: _nunito(12, FontWeight.w500, FigmaColors.ink),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Block 4: "Add my own task" form. The title field is pre-filled with
/// entered text (not a placeholder); chips render from [categories].
class _AddTaskCard extends StatelessWidget {
  const _AddTaskCard({
    required this.titleController,
    required this.categories,
    required this.dueText,
    required this.onSelectCategory,
    required this.onPickDueDate,
    required this.onAddTask,
  });

  final TextEditingController titleController;
  final List<Category> categories;
  final String dueText;
  final ValueChanged<String> onSelectCategory;
  final VoidCallback onPickDueDate;
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
                  'Add my own task',
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
                  key: const ValueKey('kids-task-title'),
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
                      key: ValueKey('category-${categories[i].id}'),
                      onTap: () => onSelectCategory(categories[i].id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Due / schedule date',
                style: _nunito(12, FontWeight.w800, FigmaColors.ink),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                key: const ValueKey('kids-due-date'),
                onTap: onPickDueDate,
                child: Container(
                  constraints: const BoxConstraints(minHeight: 46),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: FigmaColors.frostedStrong,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: FigmaColors.line, width: 1),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          dueText,
                          style: _nunito(
                            14,
                            FontWeight.w600,
                            FigmaColors.ink,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.calendar_month_rounded,
                        size: 18,
                        color: FigmaColors.ink,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            key: const ValueKey('kids-add-task'),
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

/// Block 5: "Made by me" practice tasks, rendered from [tasks] with
/// dividers between rows only. The progress pill is derived from state.
class _MadeByMeCard extends StatelessWidget {
  const _MadeByMeCard({
    required this.tasks,
    required this.onToggleTaskComplete,
    required this.onEditTask,
  });

  final List<PersonalTask> tasks;
  final ValueChanged<String> onToggleTaskComplete;
  final ValueChanged<String> onEditTask;

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
                  'Made by me',
                  style: _nunito(18, FontWeight.w800, FigmaColors.ink),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  color: FigmaColors.yellowLight,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$doneCount of ${tasks.length} done!',
                  style: _nunito(
                    11,
                    FontWeight.w800,
                    FigmaColors.sageDark,
                  ),
                ),
              ),
            ],
          ),
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

  Widget _taskRow(PersonalTask task) {
    return Container(
      constraints: const BoxConstraints(minHeight: 74),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            key: ValueKey('complete-${task.id}'),
            onTap: () => onToggleTaskComplete(task.id),
            child: Container(
              width: 38,
              height: 38,
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
                      size: 17,
                      color: FigmaColors.white,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: _nunito(
                    14,
                    FontWeight.w700,
                    task.completed ? FigmaColors.mute : FigmaColors.ink,
                  ).copyWith(
                    decoration: task.completed
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  task.meta,
                  style: _nunito(11, FontWeight.w500, FigmaColors.mute),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            key: ValueKey('edit-${task.id}'),
            onTap: () => onEditTask(task.id),
            child: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              child: const Icon(
                Icons.edit_outlined,
                size: 17,
                color: FigmaColors.mute,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Block 6: "Chores from Mom" on a sageLight frosted card. No checkbox,
/// no points: parent chores are managed separately.
class _ParentChoresCard extends StatelessWidget {
  const _ParentChoresCard({
    required this.chores,
    required this.onOpenParentChores,
  });

  final List<ParentChore> chores;
  final VoidCallback onOpenParentChores;

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
                size: 20,
                color: FigmaColors.ink,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Chores from Mom',
                  style: _nunito(15, FontWeight.w800, FigmaColors.ink),
                ),
              ),
            ],
          ),
          for (final chore in chores) ...[
            const SizedBox(height: 12),
            GestureDetector(
              key: ValueKey('parent-chore-${chore.id}'),
              onTap: onOpenParentChores,
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
                              14,
                              FontWeight.w700,
                              FigmaColors.ink,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            chore.note,
                            style: _nunito(
                              11,
                              FontWeight.w500,
                              FigmaColors.sageDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: FigmaColors.ink,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Block 7: bottom nav with exactly Home (active), Rewards, Calendar.
/// No home indicator: no other project bottom nav renders one.
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
                keyName: 'nav-home',
                label: 'Home',
                icon: Icons.home_rounded,
                active: true,
                onTap: onNavigateHome,
              ),
              _tab(
                keyName: 'nav-rewards',
                label: 'Rewards',
                icon: Icons.stars_rounded,
                active: false,
                onTap: onNavigateRewards,
              ),
              _tab(
                keyName: 'nav-calendar',
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 23,
              height: 23,
              child: Icon(
                icon,
                size: 23,
                color: active ? FigmaColors.sage : FigmaColors.mute,
              ),
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
