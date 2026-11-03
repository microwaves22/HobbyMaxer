import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/figma_tokens.dart';
import '../onboarding/models/user_profile.dart';
import 'models/personal_task.dart';
import 'tasks_controller.dart';

const String _kFont = 'Nunito';

/// Figma "Teen My To-Do List" (node 100:4622): Noah's personal task list.
///
/// Sections, in order: identity header, plain intro line, "New personal
/// task" add card, "Created by me" list, "Assigned by Sarah" parent
/// block, bottom nav with Home active. No filter row, no encouragement
/// banner, no points pill, no submission flow — personal tasks are
/// explicitly "no points or parent review", and the parent rows are
/// display-only (no checkboxes).
///
/// Content is local mock data ([kTeenPersonalTasks], [kTeenAssignedChores],
/// [kTeenTaskCategories]): nothing here touches the backend. [controller]
/// and [profile] are retained for API compatibility with the home
/// dashboard; completion circles and category chips are local state only.
/// No status bar or phone frame is built here (device UI).
class TeenTodoListScreen extends StatefulWidget {
  const TeenTodoListScreen({
    super.key,
    required this.controller,
    required this.profile,
    this.onBack,
    this.onNavigateHome,
    this.onNavigateRewards,
    this.onNavigateCalendar,
  });

  final TasksController controller;
  final UserProfile profile;

  /// Back button placeholder. Falls back to [Navigator.maybePop].
  final VoidCallback? onBack;

  /// Bottom-nav placeholders (Home is the active tab in the design).
  final VoidCallback? onNavigateHome;
  final VoidCallback? onNavigateRewards;
  final VoidCallback? onNavigateCalendar;

  @override
  State<TeenTodoListScreen> createState() => _TeenTodoListScreenState();
}

class _TeenTodoListScreenState extends State<TeenTodoListScreen> {
  late List<bool> _done;
  int _selectedCategory = 0;
  late final TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _done = [for (final task in kTeenPersonalTasks) task.done];
    _titleController = TextEditingController(text: 'Outline science project');
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _handleBack() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FigmaColors.teenCanvas,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            // Fluid cap for tablets/desktop; phones use full width.
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                _HeaderRow(onBack: _handleBack),
                const SizedBox(height: 8),
                const Text(
                  'Your plans, your pace. Personal tasks are just for you — no points or parent review.',
                  style: TextStyle(
                    fontFamily: _kFont,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    height: 1.4,
                    color: FigmaColors.mute,
                  ),
                ),
                const SizedBox(height: 12),
                _AddCard(
                  titleController: _titleController,
                  selectedCategory: _selectedCategory,
                  onSelectCategory: (i) =>
                      setState(() => _selectedCategory = i),
                ),
                const SizedBox(height: 16),
                _PersonalSection(
                  done: _done,
                  onToggle: (i) => setState(() => _done[i] = !_done[i]),
                ),
                const SizedBox(height: 16),
                const _ParentBlock(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _BottomNav(
        onHome: widget.onNavigateHome,
        onRewards: widget.onNavigateRewards,
        onCalendar: widget.onNavigateCalendar,
      ),
    );
  }
}

/// Identity header: back button, title + "Noah · 14 · Teen Mode" subtitle,
/// and the "N" avatar on a 44px sageLight circle.
///
/// NOTE: the screen-title copy is not pinned by the spec, so the
/// scaffold's "My To-Do List" is kept. The subtitle is verbatim Figma.
class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left_rounded),
          color: FigmaColors.ink,
          tooltip: 'Back',
          onPressed: onBack,
        ),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My To-Do List',
                style: TextStyle(
                  fontFamily: _kFont,
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                  height: 1.25,
                  color: FigmaColors.ink,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Noah · 14 · Teen Mode',
                style: TextStyle(
                  fontFamily: _kFont,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: FigmaColors.mute,
                ),
              ),
            ],
          ),
        ),
        Container(
          key: const Key('teen-todo-avatar'),
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: FigmaColors.sageLight,
            shape: BoxShape.circle,
          ),
          child: const Text(
            'N',
            style: TextStyle(
              fontFamily: _kFont,
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: FigmaColors.sageDark,
            ),
          ),
        ),
      ],
    );
  }
}

/// Add card: "New personal task" heading, pre-filled title field, and
/// category chips with 9px vertical padding (selected chip in sage).
///
/// NOTE: the spec shows no add button on this card, so the title field
/// and chips are input + selection state only.
class _AddCard extends StatelessWidget {
  const _AddCard({
    required this.titleController,
    required this.selectedCategory,
    required this.onSelectCategory,
  });

  final TextEditingController titleController;
  final int selectedCategory;
  final ValueChanged<int> onSelectCategory;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('teen-todo-add-card'),
      decoration: FigmaCards.whiteCard(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'New personal task',
            style: TextStyle(
              fontFamily: _kFont,
              fontWeight: FontWeight.w700,
              fontSize: 16,
              height: 1.3,
              color: FigmaColors.ink,
            ),
          ),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 46),
            child: TextField(
              key: const Key('teen-todo-new-title'),
              controller: titleController,
              style: const TextStyle(
                fontFamily: _kFont,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: FigmaColors.ink,
              ),
              decoration: const InputDecoration(
                filled: true,
                fillColor: Color.fromRGBO(255, 255, 255, 0.91),
                contentPadding: EdgeInsets.all(12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                  borderSide: BorderSide(color: FigmaColors.line),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                  borderSide: BorderSide(color: FigmaColors.line),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                  borderSide: BorderSide(
                    color: FigmaColors.sage,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < kTeenTaskCategories.length; i++)
                ChoiceChip(
                  label: Text(kTeenTaskCategories[i]),
                  selected: selectedCategory == i,
                  onSelected: (_) => onSelectCategory(i),
                  selectedColor: FigmaColors.sage,
                  backgroundColor: FigmaColors.white,
                  labelStyle: TextStyle(
                    fontFamily: _kFont,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: selectedCategory == i
                        ? FigmaColors.white
                        : FigmaColors.ink,
                  ),
                  side: const BorderSide(color: FigmaColors.line),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// "Created by me" list: 17px heading, sageLight progress pill with the
/// count computed from the data, and one row per personal task.
class _PersonalSection extends StatelessWidget {
  const _PersonalSection({required this.done, required this.onToggle});

  final List<bool> done;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    final doneCount = done.where((d) => d).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Text(
              'Created by me',
              style: TextStyle(
                fontFamily: _kFont,
                fontWeight: FontWeight.w800,
                fontSize: 17,
                height: 1.3,
                color: FigmaColors.ink,
              ),
            ),
            const Spacer(),
            Container(
              key: const Key('teen-todo-progress-pill'),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: const BoxDecoration(
                color: FigmaColors.sageLight,
                borderRadius: BorderRadius.all(Radius.circular(999)),
              ),
              child: Text(
                teenProgressLabel(done: doneCount, total: done.length),
                style: const TextStyle(
                  fontFamily: _kFont,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  color: FigmaColors.sageDark,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        for (var i = 0; i < kTeenPersonalTasks.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          _PersonalRow(
            task: kTeenPersonalTasks[i],
            done: done[i],
            onToggle: () => onToggle(i),
          ),
        ],
      ],
    );
  }
}

/// One personal-task row: 26px completion circle plus title/meta.
/// Rows are at least 66px tall. Tapping the circle toggles local state.
class _PersonalRow extends StatelessWidget {
  const _PersonalRow({
    required this.task,
    required this.done,
    required this.onToggle,
  });

  final PersonalTask task;
  final bool done;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('personal-row-${task.id}'),
      constraints: const BoxConstraints(minHeight: 66),
      decoration: FigmaCards.whiteCard(),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            key: Key('personal-circle-${task.id}'),
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: done ? FigmaColors.sage : Colors.transparent,
                shape: BoxShape.circle,
                border: done
                    ? null
                    : Border.all(color: FigmaColors.sageMid, width: 2),
              ),
              child: done
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  task.title,
                  style: const TextStyle(
                    fontFamily: _kFont,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    height: 1.3,
                    color: FigmaColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  task.meta,
                  style: const TextStyle(
                    fontFamily: _kFont,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    height: 1.35,
                    color: FigmaColors.mute,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "Assigned by Sarah" block: heading with an 18px users icon, a frosted
/// card with exactly 2 display-only rows (no checkboxes), and the
/// verbatim footnote.
class _ParentBlock extends StatelessWidget {
  const _ParentBlock();

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(22));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Row(
          children: [
            Icon(
              Icons.group_rounded,
              size: 18,
              color: FigmaColors.sage,
            ),
            SizedBox(width: 8),
            Text(
              'Assigned by Sarah',
              style: TextStyle(
                fontFamily: _kFont,
                fontWeight: FontWeight.w800,
                fontSize: 17,
                height: 1.3,
                color: FigmaColors.ink,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: radius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 9, sigmaY: 9),
            child: Container(
              key: const Key('teen-todo-parent-card'),
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color.fromRGBO(255, 255, 255, 0.79),
                border: Border.fromBorderSide(
                  BorderSide(color: FigmaColors.white),
                ),
                borderRadius: radius,
                boxShadow: [FigmaShadows.card],
              ),
              child: Column(
                children: [
                  for (var i = 0; i < kTeenAssignedChores.length; i++) ...[
                    if (i > 0)
                      const Divider(
                        height: 20,
                        thickness: 1,
                        color: FigmaColors.line,
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            kTeenAssignedChores[i].title,
                            style: const TextStyle(
                              fontFamily: _kFont,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              height: 1.3,
                              color: FigmaColors.ink,
                            ),
                          ),
                        ),
                        Text(
                          kTeenAssignedChores[i].time,
                          style: const TextStyle(
                            fontFamily: _kFont,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: FigmaColors.mute,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: FigmaColors.mute,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Separate from your list · Photo/video and parent review required for chore points.',
          style: TextStyle(
            fontFamily: _kFont,
            fontWeight: FontWeight.w500,
            fontSize: 11,
            height: 1.4,
            color: FigmaColors.mute,
          ),
        ),
      ],
    );
  }
}

/// Bottom nav: the teen 3-tab bar (Home / Rewards / Calendar) shared
/// with the sibling Figma screens. Home is the active tab on this screen.
class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.onHome,
    required this.onRewards,
    required this.onCalendar,
  });

  final VoidCallback? onHome;
  final VoidCallback? onRewards;
  final VoidCallback? onCalendar;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        top: 12,
        left: 20,
        right: 20,
        bottom: 10,
      ),
      color: const Color.fromRGBO(255, 255, 255, 0.91),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _BottomTab(
                label: 'Home',
                icon: Icons.home_rounded,
                active: true,
                onTap: onHome,
              ),
              _BottomTab(
                label: 'Rewards',
                icon: Icons.card_giftcard_rounded,
                active: false,
                onTap: onRewards,
              ),
              _BottomTab(
                label: 'Calendar',
                icon: Icons.calendar_month_rounded,
                active: false,
                onTap: onCalendar,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: 116,
            height: 4,
            decoration: const BoxDecoration(
              color: FigmaColors.ink,
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomTab extends StatelessWidget {
  const _BottomTab({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
              style: TextStyle(
                fontFamily: _kFont,
                fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                fontSize: 11,
                color: active ? FigmaColors.sage : FigmaColors.mute,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
