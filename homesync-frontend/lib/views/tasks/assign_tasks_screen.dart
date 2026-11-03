import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/figma_tokens.dart';

// Figma node 4:30 — "05 Assign Tasks" (Parent To-Do & Chore Assignment).
// All copy, sizes, colors, and spacing come from the design brief.
// Local state only: every handler is a named placeholder with no
// backend, persistence, or navigation.

/// Option rendered as a selectable tile in the task grid.
class TaskOption {
  const TaskOption({
    required this.id,
    required this.label,
    required this.glyph,
    required this.tileColor,
    required this.selected,
  });

  final String id;
  final String label;
  final String glyph;
  final Color tileColor;
  final bool selected;

  TaskOption copyWith({bool? selected}) => TaskOption(
        id: id,
        label: label,
        glyph: glyph,
        tileColor: tileColor,
        selected: selected ?? this.selected,
      );
}

const taskOptions = <TaskOption>[
  TaskOption(
    id: 'laundry',
    label: 'Laundry',
    glyph: '🧺',
    tileColor: FigmaColors.pastelBlue,
    selected: true,
  ),
  TaskOption(
    id: 'wash-dishes',
    label: 'Wash Dishes',
    glyph: '🍽️',
    tileColor: FigmaColors.sageLight,
    selected: false,
  ),
  TaskOption(
    id: 'make-bed',
    label: 'Make Bed',
    glyph: '🛏️',
    tileColor: FigmaColors.pastelLavender,
    selected: true,
  ),
  TaskOption(
    id: 'clean-room',
    label: 'Clean Room',
    glyph: '🧹',
    tileColor: FigmaColors.pastelPeach,
    selected: false,
  ),
  TaskOption(
    id: 'take-out-trash',
    label: 'Take Out Trash',
    glyph: '🗑️',
    tileColor: FigmaColors.sageLight,
    selected: false,
  ),
  TaskOption(
    id: 'feed-pets',
    label: 'Feed Pets',
    glyph: '🐶',
    tileColor: FigmaColors.pastelYellow,
    selected: false,
  ),
  TaskOption(
    id: 'homework',
    label: 'Homework',
    glyph: '📚',
    tileColor: FigmaColors.pastelPink,
    selected: false,
  ),
  TaskOption(
    id: 'vacuum',
    label: 'Vacuum',
    glyph: '🪣',
    tileColor: FigmaColors.pastelBlue,
    selected: false,
  ),
];

/// Option rendered as a selectable kid avatar in the "Assign to" section.
class AssigneeOption {
  const AssigneeOption({
    required this.id,
    required this.label,
    required this.glyph,
    required this.avatarColor,
    required this.selected,
  });

  final String id;
  final String label;
  final String glyph;
  final Color avatarColor;
  final bool selected;
}

const assignees = <AssigneeOption>[
  AssigneeOption(
    id: 'ava',
    label: 'Ava',
    glyph: '👧',
    avatarColor: FigmaColors.pastelPink,
    selected: true,
  ),
  AssigneeOption(
    id: 'noah',
    label: 'Noah',
    glyph: '👦',
    avatarColor: FigmaColors.pastelBlue,
    selected: false,
  ),
  AssigneeOption(
    id: 'both',
    label: 'Both',
    glyph: '👨‍👩‍👧',
    avatarColor: FigmaColors.pastelLavender,
    selected: false,
  ),
];

TextStyle _nunito({
  required double size,
  required FontWeight weight,
  required Color color,
  double? height,
}) {
  return GoogleFonts.nunito(
    fontSize: size,
    fontWeight: weight,
    height: height,
    color: color,
  );
}

/// "05 Assign Tasks" screen. Presented open-menu, scrolled column; the
/// primary button sits after a spacer at the bottom of the content.
class AssignTasksScreen extends StatefulWidget {
  const AssignTasksScreen({super.key});

  @override
  State<AssignTasksScreen> createState() => _AssignTasksScreenState();
}

class _AssignTasksScreenState extends State<AssignTasksScreen> {
  bool _menuOpen = true;
  String _menuSelection = 'parent-assignment';
  List<TaskOption> _tasks = List.of(taskOptions);
  String _assigneeId = assignees.firstWhere((a) => a.selected).id;

  // Named placeholder handlers: local state only.

  // ignore: avoid_empty_blocks
  void onBack() {}

  // ignore: avoid_empty_blocks
  void onOpenSettings() {}

  void onToggleAssignMenu() => setState(() => _menuOpen = !_menuOpen);

  void onSelectParentAssignment() =>
      setState(() => _menuSelection = 'parent-assignment');

  void onSelectMyToDoList() => setState(() => _menuSelection = 'my-todo');

  void onToggleTask(String taskId) {
    setState(() {
      _tasks = [
        for (final task in _tasks)
          if (task.id == taskId)
            task.copyWith(selected: !task.selected)
          else
            task,
      ];
    });
  }

  // ignore: avoid_empty_blocks
  void onAddCustomTask() {}

  void onSelectAssignee(String assigneeId) =>
      setState(() => _assigneeId = assigneeId);

  // ignore: avoid_empty_blocks
  void onChangeDueTime() {}

  // ignore: avoid_empty_blocks
  void onAssignTasks() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FigmaColors.cream,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 375),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _TopBar(
                    onBack: onBack,
                    onToggleAssignMenu: onToggleAssignMenu,
                    onOpenSettings: onOpenSettings,
                  ),
                  const SizedBox(height: 8),
                  if (_menuOpen) ...[
                    _AssignMenu(
                      selection: _menuSelection,
                      onSelectParentAssignment: onSelectParentAssignment,
                      onSelectMyToDoList: onSelectMyToDoList,
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    'What tasks would you like to assign to your kids?',
                    textAlign: TextAlign.center,
                    style: _nunito(
                      size: 20,
                      weight: FontWeight.w800,
                      color: FigmaColors.ink,
                      height: 27 / 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const _ParentNote(),
                  const SizedBox(height: 8),
                  _TaskGrid(tasks: _tasks, onToggleTask: onToggleTask),
                  const SizedBox(height: 8),
                  _AddCustomTask(onTap: onAddCustomTask),
                  const SizedBox(height: 8),
                  _AssignTo(
                    assigneeId: _assigneeId,
                    onSelect: onSelectAssignee,
                  ),
                  const SizedBox(height: 8),
                  _DueRow(onTap: onChangeDueTime),
                  const SizedBox(height: 115),
                  _AssignButton(onTap: onAssignTasks),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.onBack,
    required this.onToggleAssignMenu,
    required this.onOpenSettings,
  });

  final VoidCallback onBack;
  final VoidCallback onToggleAssignMenu;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          key: const ValueKey('assign-back'),
          onTap: onBack,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: FigmaColors.white,
              borderRadius: BorderRadius.all(Radius.circular(19)),
              boxShadow: [FigmaShadows.small],
            ),
            child: const Icon(
              Icons.chevron_left_rounded,
              size: 20,
              color: FigmaColors.ink,
            ),
          ),
        ),
        GestureDetector(
          key: const ValueKey('assign-menu-trigger'),
          onTap: onToggleAssignMenu,
          behavior: HitTestBehavior.opaque,
          child: Container(
            decoration: FigmaCards.whiteCard(radius: 18),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Assign Tasks',
                  style: _nunito(
                    size: 16,
                    weight: FontWeight.w800,
                    color: FigmaColors.ink,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: FigmaColors.ink,
                ),
              ],
            ),
          ),
        ),
        GestureDetector(
          key: const ValueKey('assign-settings'),
          onTap: onOpenSettings,
          behavior: HitTestBehavior.opaque,
          child: const SizedBox(
            width: 38,
            height: 38,
            child: Icon(
              Icons.settings_outlined,
              size: 22,
              color: FigmaColors.ink,
            ),
          ),
        ),
      ],
    );
  }
}

class _AssignMenu extends StatelessWidget {
  const _AssignMenu({
    required this.selection,
    required this.onSelectParentAssignment,
    required this.onSelectMyToDoList,
  });

  final String selection;
  final VoidCallback onSelectParentAssignment;
  final VoidCallback onSelectMyToDoList;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('assign-menu'),
      decoration: FigmaCards.whiteCard(radius: 18),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _MenuOption(
            optionKey: 'assign-menu-option-parent',
            label: 'Parent To-Do & Chore Assignment',
            selected: selection == 'parent-assignment',
            onTap: onSelectParentAssignment,
          ),
          const SizedBox(height: 6),
          _MenuOption(
            optionKey: 'assign-menu-option-my-todo',
            label: 'My To-Do List',
            selected: selection == 'my-todo',
            onTap: onSelectMyToDoList,
          ),
        ],
      ),
    );
  }
}

class _MenuOption extends StatelessWidget {
  const _MenuOption({
    required this.optionKey,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String optionKey;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        key: ValueKey(optionKey),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? FigmaColors.sageLight : null,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: selected ? FigmaColors.sage : FigmaColors.white,
                borderRadius: BorderRadius.circular(10),
                border: selected
                    ? null
                    : Border.all(color: FigmaColors.line, width: 1),
              ),
              child: selected
                  ? const Icon(
                      Icons.check_rounded,
                      size: 12,
                      color: FigmaColors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: _nunito(
                  size: 13,
                  weight: selected ? FontWeight.w800 : FontWeight.w700,
                  color: FigmaColors.ink,
                  height: 18 / 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParentNote extends StatelessWidget {
  const _ParentNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: FigmaCards.whiteCard(radius: 18),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Parent account',
            style: _nunito(
              size: 12,
              weight: FontWeight.w700,
              color: FigmaColors.sage,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Kids submit a photo or video when done.\n'
            'You review before points are awarded.',
            style: _nunito(
              size: 13,
              weight: FontWeight.w700,
              color: FigmaColors.ink,
              height: 18 / 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskGrid extends StatelessWidget {
  const _TaskGrid({required this.tasks, required this.onToggleTask});

  final List<TaskOption> tasks;
  final ValueChanged<String> onToggleTask;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var row = 0; row < tasks.length; row += 2) ...[
          if (row > 0) const SizedBox(height: 10),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _TaskTile(
                    option: tasks[row],
                    onTap: () => onToggleTask(tasks[row].id),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _TaskTile(
                    option: tasks[row + 1],
                    onTap: () => onToggleTask(tasks[row + 1].id),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({required this.option, required this.onTap});

  final TaskOption option;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        key: ValueKey('task-${option.id}'),
        constraints: const BoxConstraints(minHeight: 58),
        decoration: FigmaCards.whiteCard(radius: 18),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              key: ValueKey('task-icon-${option.id}'),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: option.tileColor,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                option.glyph,
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                option.label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: _nunito(
                  size: 13,
                  weight: FontWeight.w700,
                  color: FigmaColors.ink,
                ),
              ),
            ),
            if (option.selected) ...[
              const SizedBox(width: 10),
              Container(
                key: ValueKey('task-badge-${option.id}'),
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: FigmaColors.sage,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 12,
                  color: FigmaColors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AddCustomTask extends StatelessWidget {
  const _AddCustomTask({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const ValueKey('add-custom-task'),
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: CustomPaint(
        painter: const _DashedBorder(
          color: FigmaColors.sageMid,
          strokeWidth: 2,
          radius: 18,
        ),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.add_rounded,
                size: 18,
                color: FigmaColors.sage,
              ),
              const SizedBox(width: 8),
              Text(
                'Add Custom Task',
                style: _nunito(
                  size: 14,
                  weight: FontWeight.w700,
                  color: FigmaColors.sage,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dashed rounded-rectangle stroke (Flutter has no dashed border).
class _DashedBorder extends CustomPainter {
  const _DashedBorder({
    required this.color,
    required this.strokeWidth,
    required this.radius,
  });

  final Color color;
  final double strokeWidth;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          rect,
          Radius.circular(radius - strokeWidth / 2),
        ),
      );
    const dashWidth = 6.0;
    const dashGap = 4.0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + dashWidth).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dashWidth + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorder oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.radius != radius;
}

class _AssignTo extends StatelessWidget {
  const _AssignTo({required this.assigneeId, required this.onSelect});

  final String assigneeId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Assign to:',
          style: _nunito(
            size: 14,
            weight: FontWeight.w700,
            color: FigmaColors.ink,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < assignees.length; i++) ...[
              if (i > 0) const SizedBox(width: 18),
              _Kid(
                option: assignees[i],
                selected: assignees[i].id == assigneeId,
                onTap: () => onSelect(assignees[i].id),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _Kid extends StatelessWidget {
  const _Kid({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final AssigneeOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: ValueKey('assignee-${option.id}'),
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            key: ValueKey('assignee-avatar-${option.id}'),
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: option.avatarColor,
              borderRadius: BorderRadius.circular(25),
              border: selected
                  ? Border.all(color: FigmaColors.sage, width: 3)
                  : null,
            ),
            alignment: Alignment.center,
            child: Text(
              option.glyph,
              style: const TextStyle(fontSize: 28),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            option.label,
            style: _nunito(
              size: 12,
              weight: selected ? FontWeight.w800 : FontWeight.w600,
              color: selected ? FigmaColors.sage : FigmaColors.mute,
            ),
          ),
        ],
      ),
    );
  }
}

class _DueRow extends StatelessWidget {
  const _DueRow({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const ValueKey('due-row'),
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: FigmaColors.white,
          border: Border.all(color: FigmaColors.line, width: 1),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    size: 18,
                    color: FigmaColors.ink,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Due: Today, 7:00 PM',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _nunito(
                        size: 14,
                        weight: FontWeight.w700,
                        color: FigmaColors.ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: FigmaColors.ink,
            ),
          ],
        ),
      ),
    );
  }
}

class _AssignButton extends StatelessWidget {
  const _AssignButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const ValueKey('assign-button'),
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 54,
        decoration: const BoxDecoration(
          color: FigmaColors.sage,
          borderRadius: BorderRadius.all(Radius.circular(18)),
          boxShadow: [FigmaShadows.primaryButton],
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        alignment: Alignment.center,
        child: Text(
          'Assign Tasks  →',
          style: _nunito(
            size: 16,
            weight: FontWeight.w800,
            color: FigmaColors.white,
          ),
        ),
      ),
    );
  }
}
