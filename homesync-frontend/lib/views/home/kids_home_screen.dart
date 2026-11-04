import 'package:flutter/material.dart';

/// Figma "08 Kids Mode – Home" (node 5:50): final, from the Figma update
/// prompt. All strings, sizes, colors, and data below are the real design.
class KidsHomeScreen extends StatelessWidget {
  const KidsHomeScreen({
    super.key,
    this.onAvatarPress,
    this.onPointsPress,
    this.onTaskPress,
    this.onTaskCompleteToggle,
    this.onRewardsPress,
    this.onTabPress,
  });

  static const Color _cream = Color(0xFFFBF7EF);
  static const Color _ink = Color(0xFF2B3A2B);
  static const Color _mute = Color(0xFF7C877A);
  static const Color _sage = Color(0xFF5F7F55);
  static const Color _sageDark = Color(0xFF4A6A41);
  static const Color _sageMid = Color(0xFFA9BE9C);
  static const Color _sageLight = Color(0xFFE4EBDC);
  static const Color _yellowLight = Color(0xFFFDF0C8);
  static const Color _pink = Color(0xFFF4C9C9);
  static const Color _line = Color(0xFFE8E4D8);
  static const Color _white = Color(0xFFFFFFFF);

  static const String _font = 'Nunito';

  static const List<BoxShadow> _cardShadow = [
    BoxShadow(
      color: Color.fromRGBO(59, 77, 56, 0.09),
      offset: Offset(0, 5),
      blurRadius: 16,
      spreadRadius: -4,
    ),
  ];

  static BoxDecoration _cardDecoration({double radius = 22}) {
    return BoxDecoration(
      color: _white,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: const Color.fromRGBO(255, 255, 255, 0.95),
      ),
      boxShadow: _cardShadow,
    );
  }

  final VoidCallback? onAvatarPress;
  final VoidCallback? onPointsPress;

  /// Called with the task id.
  final ValueChanged<String>? onTaskPress;

  /// Called with the task id when the completed toggle is tapped.
  final ValueChanged<String>? onTaskCompleteToggle;
  final VoidCallback? onRewardsPress;

  /// Called with the tab id ('home' | 'rewards' | 'calendar').
  final ValueChanged<String>? onTabPress;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 14,
            bottom: 18,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 14),
              _buildHero(),
              const SizedBox(height: 14),
              _buildTasksCard(),
              const SizedBox(height: 14),
              _buildCompanionCard(),
              const SizedBox(height: 14),
              _buildProgressCard(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildNav(),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi Ava! 👋',
                style: TextStyle(
                  fontFamily: _font,
                  fontWeight: FontWeight.w800,
                  fontSize: 26,
                  color: _ink,
                ),
              ),
              Text(
                'Keep up the great work!',
                style: TextStyle(
                  fontFamily: _font,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: _mute,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onPointsPress,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _yellowLight,
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star_rounded, size: 16, color: _sageDark),
                SizedBox(width: 4),
                Text(
                  '120 pts',
                  style: TextStyle(
                    fontFamily: _font,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: _ink,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: onAvatarPress,
          child: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: _white,
              shape: BoxShape.circle,
            ),
            child: const Text('🐱', style: TextStyle(fontSize: 23)),
          ),
        ),
      ],
    );
  }

  Widget _buildHero() {
    final done =
        kidsTasks.where((t) => t.state == KidsTaskState.approved).length;
    final total = kidsTasks.length;
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 335, minHeight: 140),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: const Color.fromRGBO(255, 255, 255, 0.95),
          ),
          boxShadow: _cardShadow,
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('👑', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 2),
                Container(
                  width: 78,
                  height: 78,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: _pink,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '🐱',
                    style: TextStyle(fontSize: 36),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '2 tasks to go!',
                    style: TextStyle(
                      fontFamily: _font,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: _ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Finish today's chores to earn 25 more points.",
                    style: TextStyle(
                      fontFamily: _font,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      height: 1.35,
                      color: _ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Track fills the right column (210px at the 335 design
                  // width); the sage fill is fraction-driven so it lands
                  // at exactly 70px there (1 of 3 done).
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final fraction =
                          total == 0 ? 0.0 : done / total;
                      return Container(
                        height: 12,
                        decoration: BoxDecoration(
                          color: _sageLight,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: constraints.maxWidth * fraction,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _sage,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < kidsTasks.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            _buildTaskRow(kidsTasks[i]),
          ],
        ],
      ),
    );
  }

  Widget _buildTaskRow(KidsTask task) {
    final approved = task.state == KidsTaskState.approved;
    return GestureDetector(
      onTap: onTaskPress == null ? null : () => onTaskPress!(task.id),
      child: Row(
        children: [
          GestureDetector(
            onTap: onTaskCompleteToggle == null
                ? null
                : () => onTaskCompleteToggle!(task.id),
            child: Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: approved ? _sage : _sageLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: approved
                  ? const Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: _white,
                    )
                  : const Text(
                      '›',
                      style: TextStyle(
                        fontFamily: _font,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        height: 1,
                        color: _sage,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontFamily: _font,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: approved ? _mute : _ink,
                  ),
                ),
                const SizedBox(height: 4),
                if (approved)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _sageLight,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      task.note,
                      style: const TextStyle(
                        fontFamily: _font,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: _sageDark,
                      ),
                    ),
                  )
                else
                  Text(
                    task.note,
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
        ],
      ),
    );
  }

  Widget _buildCompanionCard() {
    return GestureDetector(
      onTap: onRewardsPress,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _yellowLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text('🦄', style: TextStyle(fontSize: 28)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Care for your companion',
                    style: TextStyle(
                      fontFamily: _font,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: _ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _sageLight,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Care $kidsCompanionCare%',
                          style: const TextStyle(
                            fontFamily: _font,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: _sageDark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _yellowLight,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          kidsCompanionMood,
                          style: const TextStyle(
                            fontFamily: _font,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: _ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 64,
                  height: 64,
                  child: CircularProgressIndicator(
                    value: kidsProgressValue,
                    strokeWidth: 8,
                    backgroundColor: _sageLight,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(_sage),
                  ),
                ),
                Text(
                  '${(kidsProgressValue * 100).round()}%',
                  style: const TextStyle(
                    fontFamily: _font,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: _ink,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SizedBox(
              height: 44,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var i = 0; i < kidsMiniBars.length; i++) ...[
                    if (i > 0) const SizedBox(width: 6),
                    Expanded(
                      child: Container(
                        height: kidsMiniBars[i].toDouble(),
                        decoration: BoxDecoration(
                          color: i == kidsMiniBars.length - 1
                              ? _sage
                              : _sageMid,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNav() {
    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 24, left: 14, right: 14),
      decoration: const BoxDecoration(
        color: _white,
        border: Border(top: BorderSide(color: _line)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTab(
            id: 'home',
            label: 'Home',
            icon: Icons.home_rounded,
            active: true,
          ),
          _buildTab(
            id: 'rewards',
            label: 'Rewards',
            icon: Icons.card_giftcard_rounded,
            active: false,
          ),
          _buildTab(
            id: 'calendar',
            label: 'Calendar',
            icon: Icons.calendar_month_rounded,
            active: false,
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required String id,
    required String label,
    required IconData icon,
    required bool active,
  }) {
    final color = active ? _sage : _mute;
    return GestureDetector(
      onTap: onTabPress == null ? null : () => onTabPress!(id),
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 23, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: _font,
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

enum KidsTaskState { approved, open }

/// Kids Home task list (Figma 5:50), in design order.
const List<KidsTask> kidsTasks = [
  KidsTask(
    id: 'make-bed',
    title: 'Make bed',
    state: KidsTaskState.approved,
    note: '+5 pts · Approved',
  ),
  KidsTask(
    id: 'homework-math',
    title: 'Homework: Math',
    state: KidsTaskState.open,
    note: 'Due by 6 PM',
  ),
  KidsTask(
    id: 'clean-desk',
    title: 'Clean your desk',
    state: KidsTaskState.open,
    note: '+10 pts',
  ),
];

/// Companion status (Figma 5:50), driving the status pills.
const int kidsCompanionCare = 80;
const String kidsCompanionMood = 'Happy';

/// Progress ring value (Figma 5:50): exactly 75%.
const double kidsProgressValue = 0.75;

/// Mini bar heights (Figma 5:50), in order.
const List<int> kidsMiniBars = [18, 26, 22, 34, 40, 30, 44];

class KidsTask {
  const KidsTask({
    required this.id,
    required this.title,
    required this.state,
    required this.note,
  });

  final String id;
  final String title;
  final KidsTaskState state;
  final String note;

  bool get completed => state == KidsTaskState.approved;
}
