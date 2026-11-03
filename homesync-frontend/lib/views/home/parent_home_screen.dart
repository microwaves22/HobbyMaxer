import 'package:flutter/material.dart';

/// Figma "04 Parent Home" (node 3:106): the parent's home/dashboard screen.
///
/// Figma tokens are hard-coded here because they differ from the shared
/// theme (`AppColors` cream/sage/ink predate this design). Do not move
/// them into the theme files: no other screen uses these exact values.
///
/// All content is local sample data rendered from the typed constants
/// below. Every handler is an optional placeholder callback — this screen
/// makes no API calls and builds no other screens.
class ParentHomeScreen extends StatelessWidget {
  const ParentHomeScreen({
    super.key,
    this.onAssignTasksPress,
    this.onNotificationsPress,
    this.onAvatarPress,
    this.onStatCardPress,
    this.onQuickOverviewPress,
    this.onReviewRewardRequest,
    this.onViewAllOverviewPress,
    this.onOverviewItemPress,
    this.onTipCardPress,
    this.onTabPress,
  });

  // Figma tokens (screen-only, see class doc).
  static const Color _cream = Color(0xFFFBF7EF);
  static const Color _ink = Color(0xFF2B3A2B);
  static const Color _mute = Color(0xFF7C877A);
  static const Color _sage = Color(0xFF5F7F55);
  static const Color _sageDark = Color(0xFF4A6A41);
  static const Color _sageLight = Color(0xFFE4EBDC);
  static const Color _line = Color(0xFFE8E4D8);
  static const Color _white = Color(0xFFFFFFFF);
  static const Color _blue = Color(0xFFCFE0EE);
  static const Color _yellowLight = Color(0xFFFDF0C8);
  static const Color _pink = Color(0xFFF4C9C9);
  static const Color _peach = Color(0xFFF6D9C4);

  static const String _font = 'Inter';

  /// Card shadow: 0px 3px 12px rgba(51,64,38,0.08).
  static const List<BoxShadow> _cardShadow = [
    BoxShadow(
      color: Color(0x14334026),
      offset: Offset(0, 3),
      blurRadius: 12,
    ),
  ];

  final VoidCallback? onAssignTasksPress;
  final VoidCallback? onNotificationsPress;
  final VoidCallback? onAvatarPress;

  /// Called with the stat id (`events`, `tasksDue`, `approvals`).
  final ValueChanged<String>? onStatCardPress;
  final VoidCallback? onQuickOverviewPress;

  /// Called with the reward request id. No approval/deny logic here.
  final ValueChanged<String>? onReviewRewardRequest;
  final VoidCallback? onViewAllOverviewPress;

  /// Called with the overview item id.
  final ValueChanged<String>? onOverviewItemPress;
  final VoidCallback? onTipCardPress;

  /// Called with the tab route (`Home`, `Calendar`, `Tasks`, `Family`).
  final ValueChanged<String>? onTabPress;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 6,
                  bottom: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildStatsRow(),
                    const SizedBox(height: 10),
                    _buildQuickOverview(),
                    const SizedBox(height: 10),
                    _buildReviewQueueCard(),
                    const SizedBox(height: 10),
                    _buildTodayHeader(),
                    const SizedBox(height: 10),
                    for (var i = 0; i < _overviewItems.length; i++) ...[
                      if (i > 0) const SizedBox(height: 10),
                      _buildOverviewRow(_overviewItems[i]),
                    ],
                    const SizedBox(height: 10),
                    _buildTipCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // SECTION 1 — Header.
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _greeting,
                style: TextStyle(
                  fontFamily: _font,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: _mute,
                ),
              ),
              SizedBox(height: 2),
              Text(
                '$_parentName!',
                style: TextStyle(
                  fontFamily: _font,
                  fontWeight: FontWeight.w800,
                  fontSize: 26,
                  color: _ink,
                ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: onAssignTasksPress,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 10,
                  ),
                  decoration: BoxDecoration(
                    color: _white,
                    border: Border.all(color: _line),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x14334026),
                        offset: Offset(0, 3),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Assign Tasks',
                        style: TextStyle(
                          fontFamily: _font,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: _sage,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: _sage,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: onNotificationsPress,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _white,
                    border: Border.all(color: _line),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: _cardShadow,
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    size: 20,
                    color: _ink,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: onAvatarPress,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _white,
                    border: Border.all(color: _line),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: _cardShadow,
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '👩',
                    style: TextStyle(fontSize: 22),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // SECTION 2 — Stats row.
  Widget _buildStatsRow() {
    return Row(
      children: [
        for (var i = 0; i < _stats.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(child: _buildStatCard(_stats[i])),
        ],
      ],
    );
  }

  Widget _buildStatCard(_StatItem stat) {
    return GestureDetector(
      onTap: onStatCardPress == null ? null : () => onStatCardPress!(stat.id),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: _white,
          border: Border.all(color: _line),
          borderRadius: BorderRadius.circular(20),
          boxShadow: _cardShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: stat.tileColor,
                borderRadius: BorderRadius.circular(17),
              ),
              child: Icon(stat.icon, size: 18, color: _ink),
            ),
            const SizedBox(height: 6),
            Text(
              stat.value,
              style: const TextStyle(
                fontFamily: _font,
                fontWeight: FontWeight.w800,
                fontSize: 24,
                color: _ink,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              stat.label,
              style: const TextStyle(
                fontFamily: _font,
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: _mute,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // SECTION 3 — Quick overview button (text only, no progress bar/ring).
  Widget _buildQuickOverview() {
    return GestureDetector(
      onTap: onQuickOverviewPress,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: _white,
          border: Border.all(color: _line),
          borderRadius: BorderRadius.circular(18),
          boxShadow: _cardShadow,
        ),
        alignment: Alignment.center,
        child: Text(
          '${_quickOverview.childName} ${_quickOverview.age} · '
          '${_quickOverview.tasksDone}/${_quickOverview.tasksTotal} '
          'tasks done',
          style: const TextStyle(
            fontFamily: _font,
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: _sage,
          ),
        ),
      ),
    );
  }

  // SECTION 4 — Parent review queue card.
  Widget _buildReviewQueueCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _white,
        border: Border.all(color: _line),
        borderRadius: BorderRadius.circular(22),
        boxShadow: _cardShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Parent Review Queue',
                style: TextStyle(
                  fontFamily: _font,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: _sage,
                ),
              ),
              Text(
                '3 items',
                style: TextStyle(
                  fontFamily: _font,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  color: _mute,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (var i = 0; i < _reviewChips.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 10,
                  ),
                  decoration: BoxDecoration(
                    color: _reviewChips[i].background,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    _reviewChips[i].label,
                    style: const TextStyle(
                      fontFamily: _font,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: _sageDark,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: onReviewRewardRequest == null
                ? null
                : () => onReviewRewardRequest!(_rewardRequest.id),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _sageLight,
                border: Border.all(color: _line),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _pink,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      '👦',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${_rewardRequest.type} · ${_rewardRequest.childName}',
                          style: const TextStyle(
                            fontFamily: _font,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                            color: _sageDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _rewardRequest.title,
                          style: const TextStyle(
                            fontFamily: _font,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: _ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_rewardRequest.pointsRequested} points requested '
                          '· ${_rewardRequest.pointsAvailable} available',
                          style: const TextStyle(
                            fontFamily: _font,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                            color: _sageDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: onReviewRewardRequest == null
                        ? null
                        : () => onReviewRewardRequest!(_rewardRequest.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 14,
                      ),
                      decoration: BoxDecoration(
                        color: _sage,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'Review',
                        style: TextStyle(
                          fontFamily: _font,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: _white,
                        ),
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

  // SECTION 5 — "Today's Overview" section header.
  Widget _buildTodayHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Today's Overview",
          style: TextStyle(
            fontFamily: _font,
            fontWeight: FontWeight.w700,
            fontSize: 17,
            color: _ink,
          ),
        ),
        GestureDetector(
          onTap: onViewAllOverviewPress,
          child: const Text(
            'View All',
            style: TextStyle(
              fontFamily: _font,
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: _sage,
            ),
          ),
        ),
      ],
    );
  }

  // SECTION 6 — Overview list (exactly three rows).
  Widget _buildOverviewRow(_OverviewItem item) {
    return GestureDetector(
      onTap:
          onOverviewItemPress == null ? null : () => onOverviewItemPress!(item.id),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _white,
          border: Border.all(color: _line),
          borderRadius: BorderRadius.circular(18),
          boxShadow: _cardShadow,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: item.tileColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.icon, size: 20, color: _ink),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontFamily: _font,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: _ink,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    item.subtitle,
                    style: const TextStyle(
                      fontFamily: _font,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: _mute,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: item.avatarColor,
                borderRadius: BorderRadius.circular(15),
              ),
              alignment: Alignment.center,
              child: Text(
                item.avatarGlyph,
                style: const TextStyle(fontSize: 17),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // SECTION 7 — Tip card.
  Widget _buildTipCard() {
    return GestureDetector(
      onTap: onTipCardPress,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _yellowLight,
          border: Border.all(color: _line),
          borderRadius: BorderRadius.circular(20),
          boxShadow: _cardShadow,
        ),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.lightbulb_rounded, size: 26, color: _ink),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Family Load Tip',
                    style: TextStyle(
                      fontFamily: _font,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: _ink,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Thursday looks busy. Move one chore to Friday?',
                    style: TextStyle(
                      fontFamily: _font,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: _mute,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.only(
        top: 10,
        bottom: 24,
        left: 14,
        right: 14,
      ),
      decoration: const BoxDecoration(
        color: _white,
        border: Border(top: BorderSide(color: _line)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0D000000),
            offset: Offset(0, -3),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (final tab in _tabs) _buildTab(tab),
        ],
      ),
    );
  }

  Widget _buildTab(_NavTab tab) {
    final active = tab.route == _activeRoute;
    return GestureDetector(
      onTap: onTabPress == null ? null : () => onTabPress!(tab.route),
      child: SizedBox(
        width: 62,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              tab.icon,
              size: 24,
              color: active ? _sage : _mute,
            ),
            const SizedBox(height: 3),
            Text(
              tab.label,
              style: TextStyle(
                fontFamily: _font,
                fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                fontSize: 11,
                color: active ? _sage : _mute,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Local sample data (see class doc). Rendered, never copy-pasted.

const String _greeting = 'Good morning,';
const String _parentName = 'Sarah';
const String _activeRoute = 'Home';

class _StatItem {
  const _StatItem({
    required this.id,
    required this.icon,
    required this.tileColor,
    required this.value,
    required this.label,
  });

  final String id;
  final IconData icon;
  final Color tileColor;
  final String value;
  final String label;
}

const List<_StatItem> _stats = [
  _StatItem(
    id: 'events',
    icon: Icons.calendar_month_rounded,
    tileColor: ParentHomeScreen._blue,
    value: '3',
    label: 'Events',
  ),
  _StatItem(
    id: 'tasksDue',
    icon: Icons.checklist_rounded,
    tileColor: ParentHomeScreen._yellowLight,
    value: '4',
    label: 'Tasks Due',
  ),
  _StatItem(
    id: 'approvals',
    icon: Icons.check_rounded,
    tileColor: ParentHomeScreen._sageLight,
    value: '2',
    label: 'Approvals',
  ),
];

class _QuickOverview {
  const _QuickOverview({
    required this.childName,
    required this.age,
    required this.tasksDone,
    required this.tasksTotal,
  });

  final String childName;
  final int age;
  final int tasksDone;
  final int tasksTotal;
}

const _quickOverview = _QuickOverview(
  childName: 'Ava',
  age: 8,
  tasksDone: 3,
  tasksTotal: 4,
);

class _ReviewChip {
  const _ReviewChip({required this.label, required this.background});

  final String label;
  final Color background;
}

const List<_ReviewChip> _reviewChips = [
  _ReviewChip(
    label: '2 approvals',
    background: ParentHomeScreen._sageLight,
  ),
  _ReviewChip(
    label: '1 reward request',
    background: ParentHomeScreen._yellowLight,
  ),
];

class _RewardRequest {
  const _RewardRequest({
    required this.id,
    required this.type,
    required this.childName,
    required this.title,
    required this.pointsRequested,
    required this.pointsAvailable,
  });

  final String id;
  final String type;
  final String childName;
  final String title;
  final int pointsRequested;
  final int pointsAvailable;
}

const _rewardRequest = _RewardRequest(
  id: 'reward-noah-trampoline',
  type: 'Reward request',
  childName: 'Noah',
  title: 'Go to trampoline park',
  pointsRequested: 200,
  pointsAvailable: 120,
);

class _OverviewItem {
  const _OverviewItem({
    required this.id,
    required this.icon,
    required this.tileColor,
    required this.title,
    required this.subtitle,
    required this.avatarColor,
    required this.avatarGlyph,
  });

  final String id;
  final IconData icon;
  final Color tileColor;
  final String title;
  final String subtitle;
  final Color avatarColor;
  final String avatarGlyph;
}

const List<_OverviewItem> _overviewItems = [
  _OverviewItem(
    id: 'laundry',
    icon: Icons.checklist_rounded,
    tileColor: ParentHomeScreen._sageLight,
    title: 'Laundry · Put away clothes',
    subtitle: 'Due by 5:00 PM',
    avatarColor: ParentHomeScreen._pink,
    avatarGlyph: '👧',
  ),
  _OverviewItem(
    id: 'math-homework',
    icon: Icons.checklist_rounded,
    tileColor: ParentHomeScreen._yellowLight,
    title: 'Math Homework',
    subtitle: 'Due by 6:00 PM',
    avatarColor: ParentHomeScreen._blue,
    avatarGlyph: '👦',
  ),
  _OverviewItem(
    id: 'family-dinner',
    icon: Icons.group_rounded,
    tileColor: ParentHomeScreen._peach,
    title: 'Family Dinner',
    subtitle: 'Today at 7:00 PM',
    avatarColor: ParentHomeScreen._peach,
    avatarGlyph: '👩',
  ),
];

class _NavTab {
  const _NavTab({
    required this.route,
    required this.label,
    required this.icon,
  });

  final String route;
  final String label;
  final IconData icon;
}

const List<_NavTab> _tabs = [
  _NavTab(route: 'Home', label: 'Home', icon: Icons.home_rounded),
  _NavTab(route: 'Calendar', label: 'Calendar', icon: Icons.calendar_month_rounded),
  _NavTab(route: 'Tasks', label: 'Tasks', icon: Icons.checklist_rounded),
  _NavTab(route: 'Family', label: 'Family', icon: Icons.group_rounded),
];
