import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/figma_tokens.dart';

/// Figma node 7:157 — "12 Task Detail" (the "Fold Laundry" task).
///
/// Pixel spec: 375 x 812 frame, cream background, top bar, task hero,
/// instructions card, due-date row, proof-submission card, flexible
/// spacer, primary button. NO bottom navigation. No backend, no media
/// capture, no navigation; all handlers are placeholders. No device
/// frame or status bar is built here (the project renders screens
/// full-bleed under [SafeArea]).

// ---------------------------------------------------------------------------
// Data — ONE object; the screen renders from it.
// ---------------------------------------------------------------------------

class TaskDetailData {
  const TaskDetailData({
    required this.id,
    required this.title,
    required this.glyph,
    required this.iconTileColor,
    required this.points,
    required this.instructions,
    required this.dueLabel,
    required this.dueValue,
    required this.proofTitle,
    required this.proofSubtitle,
    required this.proofBadge,
    required this.proofHeading,
    required this.proofBody,
  });

  final String id;
  final String title;
  final String glyph;
  final Color iconTileColor;
  final int points;
  final List<String> instructions;
  final String dueLabel;
  final String dueValue;
  final String proofTitle;
  final String proofSubtitle;
  final String proofBadge;
  final String proofHeading;
  final String proofBody;
}

const foldLaundryTask = TaskDetailData(
  id: 'fold-laundry',
  title: 'Fold Laundry',
  glyph: '🧺',
  iconTileColor: Color(0xFFCFE0EE),
  points: 15,
  instructions: [
    'Fold all clean clothes',
    'Put them in your dresser',
    'Place socks in the top drawer',
  ],
  dueLabel: 'Due Date',
  dueValue: 'Today by 7:00 PM',
  proofTitle: 'Proof for Mom',
  proofSubtitle: 'Assigned by Mom',
  proofBadge: 'Parent review',
  proofHeading: 'Add a photo · optional',
  proofBody:
      'Share your folded clothes if you like. Mom reviews the task before awarding 15 points.',
);

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class TaskDetailScreen extends StatelessWidget {
  const TaskDetailScreen({
    super.key,
    this.task = foldLaundryTask,
    this.onBack,
    this.onAddPhoto,
    this.onSkipPhoto,
    this.onSubmitForReview,
  });

  /// Content to render. Defaults to the Figma "Fold Laundry" task.
  final TaskDetailData task;

  /// Back-button placeholder.
  final VoidCallback? onBack;

  /// "Add photo" placeholder: must not open a camera/gallery or upload.
  final VoidCallback? onAddPhoto;

  /// "Skip photo" placeholder.
  final VoidCallback? onSkipPhoto;

  /// "Submit for Review" placeholder: no backend, upload, or navigation.
  final VoidCallback? onSubmitForReview;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FigmaColors.cream,
      // Scroll-safe wrapper: at design size (and whenever the content
      // fits) this renders exactly like the plain padded Column — the
      // spacer absorbs the same free space. It only scrolls on viewports
      // shorter than the content instead of overflowing.
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 6, 20, 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // (1) Top bar: Back button + empty spacer, no title.
                        _TopBar(onBack: onBack),
                        const SizedBox(height: 10),
                        // (2) Task hero.
                        _Hero(task: task),
                        const SizedBox(height: 10),
                        // (3) Instructions card.
                        _InstructionsCard(task: task),
                        const SizedBox(height: 10),
                        // (4) Due Date row.
                        _DueDateRow(task: task),
                        const SizedBox(height: 10),
                        // (5) Proof Submission card.
                        _ProofCard(
                          task: task,
                          onAddPhoto: onAddPhoto,
                          onSkipPhoto: onSkipPhoto,
                        ),
                        // (6) Flexible spacer.
                        const Spacer(),
                        // (7) Primary button.
                        _PrimaryButton(onSubmitForReview: onSubmitForReview),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

TextStyle _nunito(double size, FontWeight weight, Color color) =>
    GoogleFonts.nunito(fontSize: size, fontWeight: weight, color: color);

/// Section card (3–5), exactly per spec: white bg, 1px border
/// rgba(255,255,255,0.95), radius 22, shadow
/// 0px 5px 16px -4px rgba(59,77,56,0.09).
BoxDecoration _sectionCard() {
  return BoxDecoration(
    color: FigmaColors.white,
    borderRadius: BorderRadius.circular(22),
    border: Border.all(
      color: const Color.fromRGBO(255, 255, 255, 0.95),
      width: 1,
    ),
    boxShadow: const [
      BoxShadow(
        color: Color.fromRGBO(59, 77, 56, 0.09),
        offset: Offset(0, 5),
        blurRadius: 16,
        spreadRadius: -4,
      ),
    ],
  );
}

// ---------------------------------------------------------------------------
// (1) Top bar — white round Back button + an EMPTY 38px spacer.
// ---------------------------------------------------------------------------

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: FigmaColors.white,
                borderRadius: BorderRadius.circular(19),
                boxShadow: const [FigmaShadows.small],
              ),
              // Chevron color is unspecified; it follows the ink text.
              child: const Icon(
                Icons.chevron_left,
                size: 20,
                color: FigmaColors.ink,
              ),
            ),
          ),
          // Empty spacer: keeps the layout balanced, holds nothing.
          const SizedBox(width: 38, height: 38),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// (2) Task hero — glyph tile, title, points pill.
// ---------------------------------------------------------------------------

class _Hero extends StatelessWidget {
  const _Hero({required this.task});

  final TaskDetailData task;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: task.iconTileColor,
            borderRadius: BorderRadius.circular(32),
          ),
          alignment: Alignment.center,
          // The design's laundry glyph at the specified size.
          child: Text(task.glyph, style: const TextStyle(fontSize: 52)),
        ),
        const SizedBox(height: 6),
        Text(
          task.title,
          textAlign: TextAlign.center,
          style: _nunito(26, FontWeight.w800, FigmaColors.ink),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: FigmaColors.pastelYellow,
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Star color is unspecified; it matches the pill's ink text.
              const Icon(Icons.star, size: 16, color: FigmaColors.ink),
              const SizedBox(width: 6),
              Text(
                '+${task.points} pts',
                style: _nunito(15, FontWeight.w800, FigmaColors.ink),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// (3) Instructions card — heading + dotted steps from the data object.
// ---------------------------------------------------------------------------

class _InstructionsCard extends StatelessWidget {
  const _InstructionsCard({required this.task});

  final TaskDetailData task;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: _sectionCard(),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Instructions',
            style: _nunito(16, FontWeight.w700, FigmaColors.ink),
          ),
          const SizedBox(height: 6),
          for (final step in task.instructions) ...[
            Row(
              children: [
                // The design's bullet ellipse asset; no bullet SVG exists
                // in the project, so a plain 8px ink circle is used.
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: FigmaColors.ink,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    step,
                    style: _nunito(14, FontWeight.w500, FigmaColors.ink),
                  ),
                ),
              ],
            ),
            if (step != task.instructions.last) const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// (4) Due Date row — icon + label/value, nothing on the right.
// ---------------------------------------------------------------------------

class _DueDateRow extends StatelessWidget {
  const _DueDateRow({required this.task});

  final TaskDetailData task;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: _sectionCard(),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        children: [
          // Icon color is unspecified; it follows the ink value text.
          const Icon(
            Icons.calendar_today,
            size: 22,
            color: FigmaColors.ink,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.dueLabel,
                style: _nunito(12, FontWeight.w500, FigmaColors.mute),
              ),
              Text(
                task.dueValue,
                style: _nunito(15, FontWeight.w700, FigmaColors.ink),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// (5) Proof Submission card — header row + inner cream panel.
// ---------------------------------------------------------------------------

class _ProofCard extends StatelessWidget {
  const _ProofCard({
    required this.task,
    required this.onAddPhoto,
    required this.onSkipPhoto,
  });

  final TaskDetailData task;
  final VoidCallback? onAddPhoto;
  final VoidCallback? onSkipPhoto;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: _sectionCard(),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Flexible lets the text wrap instead of overflowing when a
              // larger font is in use; at design size it lays out the same.
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.proofTitle,
                      style: _nunito(15, FontWeight.w700, FigmaColors.ink),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      task.proofSubtitle,
                      style: _nunito(13, FontWeight.w500, FigmaColors.mute),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: FigmaColors.pastelYellow,
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 10,
                ),
                child: Text(
                  task.proofBadge,
                  style: _nunito(12, FontWeight.w800, FigmaColors.ink),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: FigmaColors.cream,
              border: Border.all(color: FigmaColors.line, width: 1),
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Text(
                  task.proofHeading,
                  textAlign: TextAlign.center,
                  style: _nunito(15, FontWeight.w700, FigmaColors.ink),
                ),
                const SizedBox(height: 4),
                Text(
                  task.proofBody,
                  textAlign: TextAlign.center,
                  style: _nunito(13, FontWeight.w500, FigmaColors.mute),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _ProofOption(
                        icon: Icons.camera_alt,
                        label: 'Add photo',
                        onTap: onAddPhoto,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Built exactly as designed: the second option uses
                    // the VIDEO icon and is labeled "Skip photo". This
                    // looks like a design error but is reproduced as-is.
                    Expanded(
                      child: _ProofOption(
                        icon: Icons.videocam,
                        label: 'Skip photo',
                        onTap: onSkipPhoto,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProofOption extends StatelessWidget {
  const _ProofOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        decoration: BoxDecoration(
          color: FigmaColors.white,
          border: Border.all(color: FigmaColors.line, width: 1),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon color is unspecified; it matches the ink label.
            Icon(icon, size: 16, color: FigmaColors.ink),
            const SizedBox(width: 8),
            // Flexible lets the label wrap instead of overflowing when a
            // larger font is in use; at design size it stays on one line.
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: _nunito(13, FontWeight.w700, FigmaColors.ink),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// (7) Primary button.
// ---------------------------------------------------------------------------

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.onSubmitForReview});

  final VoidCallback? onSubmitForReview;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSubmitForReview,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          color: FigmaColors.sage,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [FigmaShadows.primaryButton],
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        alignment: Alignment.center,
        child: Text(
          'Submit for Review',
          style: _nunito(16, FontWeight.w800, FigmaColors.white),
        ),
      ),
    );
  }
}
