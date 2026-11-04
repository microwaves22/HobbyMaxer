import 'package:flutter/material.dart';

/// Figma "14 Teen Mode – Home" (node 7:320): final, from the Figma update
/// prompt. Background #F4F3EF (not cream); no progress ring or mini bars.
class TeenHomeScreen extends StatelessWidget {
  const TeenHomeScreen({
    super.key,
    this.onAvatarPress,
    this.onBalancePress,
    this.onTaskPress,
    this.onRewardsPress,
    this.onTabPress,
    this.onCompanionPress,
    this.onProofPress,
  });

  static const Color _bg = Color(0xFFF4F3EF);
  static const Color _ink = Color(0xFF2B3A2B);
  static const Color _mute = Color(0xFF7C877A);
  static const Color _sage = Color(0xFF5F7F55);
  static const Color _sageMid = Color(0xFFA9BE9C);
  static const Color _sageLight = Color(0xFFE4EBDC);
  static const Color _line = Color(0xFFE8E4D8);
  static const Color _white = Color(0xFFFFFFFF);

  static const String _font = 'Nunito';

  static const Gradient _teenGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color.fromRGBO(255, 255, 255, 0.2),
      Color.fromRGBO(95, 127, 85, 0.2),
    ],
  );

  final VoidCallback? onAvatarPress;
  final VoidCallback? onBalancePress;

  /// Called with the task id.
  final ValueChanged<String>? onTaskPress;
  final VoidCallback? onRewardsPress;

  /// Called with the tab id ('home' | 'rewards' | 'calendar').
  final ValueChanged<String>? onTabPress;

  /// Called when the companion drawer row is tapped.
  final VoidCallback? onCompanionPress;

  /// Called with the task id when a "Photo/video" proof button is tapped.
  final ValueChanged<String>? onProofPress;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
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
              const SizedBox(height: 12),
              _buildModeTag(),
              const SizedBox(height: 14),
              _buildCompanion(),
              const SizedBox(height: 14),
              _buildDueToday(),
              const SizedBox(height: 14),
              _buildUpcoming(),
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
                'Hey, Noah',
                style: TextStyle(
                  fontFamily: _font,
                  fontWeight: FontWeight.w800,
                  fontSize: 26,
                  color: _ink,
                ),
              ),
              Text(
                'Saturday, Oct 31',
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
          onTap: onBalancePress,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _white,
              border: Border.all(color: _line, width: 1.5),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '120',
                    style: TextStyle(
                      fontFamily: _font,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: _ink,
                    ),
                  ),
                  TextSpan(
                    text: ' pts',
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
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: onAvatarPress,
          child: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _sageLight,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: _teenGradient,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Text(
                'N',
                style: TextStyle(
                  fontFamily: _font,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: _ink,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModeTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _white,
        gradient: _teenGradient,
        border: Border.all(color: _line),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'Teen Mode',
              style: TextStyle(
                fontFamily: _font,
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: _ink,
              ),
            ),
            TextSpan(
              text: ' · simplified view',
              style: TextStyle(
                fontFamily: _font,
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: _ink,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanion() {
    return GestureDetector(
      onTap: onRewardsPress,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 335),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'COMPANION',
                    style: TextStyle(
                      fontFamily: _font,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      letterSpacing: 1,
                      color: _mute,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _sageLight,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Thriving',
                    style: TextStyle(
                      fontFamily: _font,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: _sage,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Ember',
              style: TextStyle(
                fontFamily: _font,
                fontWeight: FontWeight.w800,
                fontSize: 20,
                color: _ink,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  width: 96,
                  height: 96,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _sageLight,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Text('🐉', style: TextStyle(fontSize: 48)),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rested · 94% care',
                        style: TextStyle(
                          fontFamily: _font,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: _ink,
                        ),
                      ),
                      SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _RewardChip(
                            icon: Icons.shield_outlined,
                            label: 'Armor',
                          ),
                          _RewardChip(
                            icon: Icons.palette_outlined,
                            label: 'Skin',
                          ),
                          _RewardChip(
                            icon: Icons.home_outlined,
                            label: 'Den',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: onCompanionPress,
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Companion details',
                          style: TextStyle(
                            fontFamily: _font,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: _ink,
                          ),
                        ),
                        Text(
                          'Skins, armor, den themes',
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
                  Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: _sage,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: _white,
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

  Widget _buildDueToday() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DUE TODAY',
            style: TextStyle(
              fontFamily: _font,
              fontWeight: FontWeight.w700,
              fontSize: 11,
              letterSpacing: 1,
              color: _mute,
            ),
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < teenTasks.length; i++) ...[
            if (i > 0) const Divider(height: 16, thickness: 1, color: _line),
            _buildDueRow(teenTasks[i]),
          ],
        ],
      ),
    );
  }

  Widget _buildDueRow(TeenTask task) {
    return GestureDetector(
      onTap: onTaskPress == null ? null : () => onTaskPress!(task.id),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: const TextStyle(
                    fontFamily: _font,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: _ink,
                  ),
                ),
                if (task.time != null)
                  Text(
                    task.time!,
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
          if (task.state == TeenTaskState.done)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: _sage,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'Approved',
                style: TextStyle(
                  fontFamily: _font,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: _white,
                ),
              ),
            )
          else
            GestureDetector(
              onTap: onProofPress == null
                  ? null
                  : () => onProofPress!(task.id),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _white,
                  border: Border.all(color: _line),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.photo_camera_outlined,
                      size: 16,
                      color: _ink,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Photo/video',
                      style: TextStyle(
                        fontFamily: _font,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: _ink,
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

  Widget _buildUpcoming() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'UPCOMING',
            style: TextStyle(
              fontFamily: _font,
              fontWeight: FontWeight.w700,
              fontSize: 11,
              letterSpacing: 1,
              color: _mute,
            ),
          ),
          const SizedBox(height: 8),
          for (final event in teenUpcoming)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Container(
                    width: 3,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _sageMid,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: const TextStyle(
                            fontFamily: _font,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: _ink,
                          ),
                        ),
                        Text(
                          event.when,
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

class _RewardChip extends StatelessWidget {
  const _RewardChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F3EF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF2B3A2B)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: Color(0xFF2B3A2B),
            ),
          ),
        ],
      ),
    );
  }
}

enum TeenTaskState { open, done }

/// Teen Home "DUE TODAY" rows (Figma 7:320), in design order.
const List<TeenTask> teenTasks = [
  TeenTask(id: 'math-homework', title: 'Math homework', time: '6:00 PM'),
  TeenTask(
    id: 'vacuum-living',
    title: 'Vacuum living room',
    time: '7:00 PM',
  ),
  TeenTask(
    id: 'recycling',
    title: 'Take out recycling',
    state: TeenTaskState.done,
  ),
];

/// Teen Home "UPCOMING" rows (Figma 7:320), in design order.
const List<TeenUpcoming> teenUpcoming = [
  TeenUpcoming(title: 'Soccer practice', when: 'Thu · 4:30 PM'),
  TeenUpcoming(title: 'Family dinner', when: 'Fri · 6:00 PM'),
];

class TeenTask {
  const TeenTask({
    required this.id,
    required this.title,
    this.time,
    this.state = TeenTaskState.open,
  });

  final String id;
  final String title;
  final String? time;
  final TeenTaskState state;
}

class TeenUpcoming {
  const TeenUpcoming({required this.title, required this.when});

  final String title;
  final String when;
}
