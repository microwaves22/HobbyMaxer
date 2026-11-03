import 'package:flutter/material.dart';

/// Figma "08 Kids Mode – Home" (node 5:50): TODO SHELL — DO NOT USE AS FINAL.
///
/// Figma specs for node 5:50 were never retrieved (MCP tool-call limit on
/// 2026-11-02), so this file contains NO verified Kids Mode content. It
/// renders only the verified global tokens plus explicit TODO placeholders.
/// Re-run the Figma pass for node 5:50 and replace every TODO below with the
/// retrieved text, sizes, colors, and sample data before using this screen.
///
/// Verified global tokens only (Kids Mode is a Nunito screen):
/// ink #2B3A2B · mute #7C877A · sage #5F7F55 · line #E8E4D8 ·
/// white #FFFFFF · cream #FBF7EF.
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

  // Verified global tokens (screen-only copies, mirroring ParentHomeScreen).
  static const Color _cream = Color(0xFFFBF7EF);
  static const Color _ink = Color(0xFF2B3A2B);
  static const Color _mute = Color(0xFF7C877A);
  static const Color _sage = Color(0xFF5F7F55);
  static const Color _line = Color(0xFFE8E4D8);
  static const Color _white = Color(0xFFFFFFFF);

  static const String _font = 'Nunito';

  final VoidCallback? onAvatarPress;
  final VoidCallback? onPointsPress;

  /// Called with the task id.
  final ValueChanged<String>? onTaskPress;

  /// Called with the task id when the completed toggle is tapped.
  final ValueChanged<String>? onTaskCompleteToggle;
  final VoidCallback? onRewardsPress;

  /// Called with the tab id once tabs are retrieved from Figma.
  final ValueChanged<String>? onTabPress;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeaderPlaceholder(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTasksPlaceholder(),
                    const SizedBox(height: 10),
                    _buildRewardsPlaceholder(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildNavPlaceholder(),
    );
  }

  // TODO(Figma 5:50): replace with retrieved header — greeting text verbatim,
  // child name/age, avatar size/background, points/stars pill.
  Widget _buildHeaderPlaceholder() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: Text(
              'TODO(Figma 5:50): header greeting + child name',
              style: TextStyle(
                fontFamily: _font,
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: _mute,
              ),
            ),
          ),
          GestureDetector(
            onTap: onAvatarPress,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _white,
                border: Border.all(color: _line),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.person_rounded, size: 20, color: _ink),
            ),
          ),
        ],
      ),
    );
  }

  // TODO(Figma 5:50): replace with retrieved task cards. Tasks MUST render
  // from [kidsTasks]; completed and pending states per the design.
  Widget _buildTasksPlaceholder() {
    if (kidsTasks.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _white,
          border: Border.all(color: _line),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Text(
          'TODO(Figma 5:50): task list — names, points, times, icons',
          style: TextStyle(
            fontFamily: _font,
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: _sage,
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final task in kidsTasks) _buildTaskRow(task),
      ],
    );
  }

  Widget _buildTaskRow(KidsTask task) {
    return GestureDetector(
      onTap: onTaskPress == null ? null : () => onTaskPress!(task.id),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _white,
          border: Border.all(color: _line),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: onTaskCompleteToggle == null
                  ? null
                  : () => onTaskCompleteToggle!(task.id),
              child: Icon(
                task.completed
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 24,
                color: task.completed ? _sage : _mute,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                task.title,
                style: const TextStyle(
                  fontFamily: _font,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: _ink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // TODO(Figma 5:50): replace with retrieved stars/points balance, streak,
  // progress ring/bar values, reward card text and colors.
  Widget _buildRewardsPlaceholder() {
    return GestureDetector(
      onTap: onRewardsPress,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _white,
          border: Border.all(color: _line),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Text(
          'TODO(Figma 5:50): rewards / progress widgets',
          style: TextStyle(
            fontFamily: _font,
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: _sage,
          ),
        ),
      ),
    );
  }

  // TODO(Figma 5:50): replace with retrieved tabs — labels, icons, order,
  // active tab, active/inactive colors, bar styling.
  Widget _buildNavPlaceholder() {
    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 24, left: 14, right: 14),
      decoration: const BoxDecoration(
        color: _white,
        border: Border(top: BorderSide(color: _line)),
      ),
      child: const Text(
        'TODO(Figma 5:50): bottom navigation tabs',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: _font,
          fontWeight: FontWeight.w600,
          fontSize: 11,
          color: _mute,
        ),
      ),
    );
  }
}

/// ONE local data array for the Kids task list (see class doc).
///
/// Empty until Figma node 5:50 is retrieved — do NOT invent entries.
const List<KidsTask> kidsTasks = [];

class KidsTask {
  const KidsTask({
    required this.id,
    required this.title,
    required this.completed,
  });

  final String id;
  final String title;
  final bool completed;
}
