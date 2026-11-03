import 'package:flutter/material.dart';

/// Figma "14 Teen Mode – Home" (node 7:320): TODO SHELL — DO NOT USE AS FINAL.
///
/// Figma specs for node 7:320 were never retrieved (MCP tool-call limit on
/// 2026-11-02), so this file contains NO verified Teen Mode content. It
/// renders only the verified global tokens plus explicit TODO placeholders.
/// Re-run the Figma pass for node 7:320 and replace every TODO below with the
/// retrieved text, sizes, colors, and sample data before using this screen.
///
/// Verified global tokens only:
/// ink #2B3A2B · mute #7C877A · sage #5F7F55 · line #E8E4D8 ·
/// white #FFFFFF · cream #FBF7EF.
/// TODO(Figma 7:320): confirm which font Teen Mode uses per text node
/// (brand font is Nunito 500/700/800; Parent Home uses Inter).
class TeenHomeScreen extends StatelessWidget {
  const TeenHomeScreen({
    super.key,
    this.onAvatarPress,
    this.onBalancePress,
    this.onTaskPress,
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

  // TODO(Figma 7:320): confirm font per text node; Nunito is the brand font.
  static const String _font = 'Nunito';

  final VoidCallback? onAvatarPress;
  final VoidCallback? onBalancePress;

  /// Called with the task id.
  final ValueChanged<String>? onTaskPress;
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
                    _buildWidgetsPlaceholder(),
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

  // TODO(Figma 7:320): replace with retrieved header — greeting/name
  // verbatim, avatar size/background, points/balance/level pill.
  Widget _buildHeaderPlaceholder() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: Text(
              'TODO(Figma 7:320): header greeting + name',
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

  // TODO(Figma 7:320): replace with retrieved cards/list items. Lists MUST
  // render from [teenTasks]; progress bars/rings use retrieved values only.
  Widget _buildTasksPlaceholder() {
    if (teenTasks.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _white,
          border: Border.all(color: _line),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Text(
          'TODO(Figma 7:320): task/chore list — names, points, due times',
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
        for (final task in teenTasks) _buildTaskRow(task),
      ],
    );
  }

  Widget _buildTaskRow(TeenTask task) {
    return GestureDetector(
      onTap: onTaskPress == null ? null : () => onTaskPress!(task.id),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _white,
          border: Border.all(color: _line),
          borderRadius: BorderRadius.circular(18),
        ),
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
    );
  }

  // TODO(Figma 7:320): replace with retrieved progress values (bars/rings
  // with exact fractions or %), streaks, rewards/earnings widgets.
  Widget _buildWidgetsPlaceholder() {
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
          'TODO(Figma 7:320): progress / streak / rewards widgets',
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

  // TODO(Figma 7:320): replace with retrieved tabs — labels, icons, order,
  // active tab, active/inactive colors, bar styling.
  Widget _buildNavPlaceholder() {
    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 24, left: 14, right: 14),
      decoration: const BoxDecoration(
        color: _white,
        border: Border(top: BorderSide(color: _line)),
      ),
      child: const Text(
        'TODO(Figma 7:320): bottom navigation tabs',
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

/// ONE local data array for the Teen task list (see class doc).
///
/// Empty until Figma node 7:320 is retrieved — do NOT invent entries.
const List<TeenTask> teenTasks = [];

class TeenTask {
  const TeenTask({required this.id, required this.title});

  final String id;
  final String title;
}
