import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/figma_tokens.dart';

/// Figma node 7:69 — "11 Chores".
///
/// Pixel spec: 375 x 812 frame, cream background, header, segmented
/// control, 5 chore rows, banner, flexible spacer, and a full-bleed
/// 3-tab bottom nav OUTSIDE the padded body. No backend, no navigation;
/// all handlers are placeholders. No device frame or status bar is built
/// here (the project renders screens full-bleed under [SafeArea]).

// ---------------------------------------------------------------------------
// Data
// ---------------------------------------------------------------------------

/// One chore row. `status` is 'approved' (sage checkbox + mute text) or
/// 'pending' (sageLight chevron tile + ink title).
class Chore {
  const Chore({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.points,
    required this.status,
  });

  final String id;
  final String title;
  final String subtitle;
  final int points;
  final String status;

  bool get isApproved => status == 'approved';
}

/// Design sample data, in Figma order. Shown under BOTH segments: the
/// design shows the same 5 rows under "Assigned to me" and defines no
/// separate "All tasks" dataset, so none is invented here.
const chores = [
  Chore(
    id: 'make-bed',
    title: 'Make bed',
    subtitle: 'Approved by Mom',
    points: 5,
    status: 'approved',
  ),
  Chore(
    id: 'fold-laundry',
    title: 'Fold laundry',
    subtitle: 'Assigned by Mom • Due today',
    points: 15,
    status: 'pending',
  ),
  Chore(
    id: 'clean-room',
    title: 'Clean room',
    subtitle: 'Assigned by Mom • Due today',
    points: 15,
    status: 'pending',
  ),
  Chore(
    id: 'take-out-trash',
    title: 'Take out trash',
    subtitle: 'Assigned by Mom • Due today',
    points: 10,
    status: 'pending',
  ),
  Chore(
    id: 'feed-pets',
    title: 'Feed pets',
    subtitle: 'Assigned by Mom • Due today',
    points: 10,
    status: 'pending',
  ),
];

/// Segmented-control segments. "Assigned to me" is selected by default.
enum ChoresSegment { assignedToMe, allTasks }

extension ChoresSegmentLabel on ChoresSegment {
  String get label => switch (this) {
        ChoresSegment.assignedToMe => 'Assigned to me',
        ChoresSegment.allTasks => 'All tasks',
      };
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class ChoresScreen extends StatefulWidget {
  const ChoresScreen({
    super.key,
    this.chores,
    this.onSegmentChange,
    this.onOpenChore,
    this.onNavigateHome,
    this.onNavigateRewards,
    this.onNavigateCalendar,
  });

  /// Rows to render. Defaults to the Figma sample data ([chores]) when null.
  final List<Chore>? chores;

  /// Fires when the selected segment changes. Local state only: the
  /// screen does not navigate or fetch.
  final ValueChanged<ChoresSegment>? onSegmentChange;

  /// Row tap. Navigation placeholder to a task-detail screen.
  final ValueChanged<String>? onOpenChore;

  /// Bottom-nav placeholders. Home stays active on this screen.
  final VoidCallback? onNavigateHome;
  final VoidCallback? onNavigateRewards;
  final VoidCallback? onNavigateCalendar;

  @override
  State<ChoresScreen> createState() => _ChoresScreenState();
}

class _ChoresScreenState extends State<ChoresScreen> {
  ChoresSegment _segment = ChoresSegment.assignedToMe;

  void _onSegmentChange(ChoresSegment segment) {
    setState(() => _segment = segment);
    widget.onSegmentChange?.call(segment);
  }

  @override
  Widget build(BuildContext context) {
    // Both segments render the same sample data (see [chores] note).
    final visible = widget.chores ?? chores;
    return Scaffold(
      backgroundColor: FigmaColors.cream,
      body: SafeArea(
        // The bottom nav carries its own exact 24px bottom padding, so
        // the OS inset must not stretch it.
        bottom: false,
        child: Column(
          children: [
            Expanded(
              // Scroll-safe wrapper: at design size (and whenever the
              // content fits) this renders exactly like the plain padded
              // Column — the spacer absorbs the same free space. It only
              // scrolls on viewports shorter than the content instead of
              // overflowing (e.g. small phones, large text settings).
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 6, 20, 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // (1) Header: title only.
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  'Chores',
                                  style: _nunito(
                                    26,
                                    FontWeight.w800,
                                    FigmaColors.ink,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              // (2) Segmented control.
                              _SegmentedControl(
                                selected: _segment,
                                onSegmentChange: _onSegmentChange,
                              ),
                              const SizedBox(height: 12),
                              // (3) Chore list.
                              for (var i = 0; i < visible.length; i++) ...[
                                if (i > 0) const SizedBox(height: 12),
                                _ChoreRow(
                                  chore: visible[i],
                                  onTap: () =>
                                      widget.onOpenChore?.call(visible[i].id),
                                ),
                              ],
                              const SizedBox(height: 12),
                              // (4) Banner.
                              const _Banner(),
                              // (5) Flexible spacer.
                              const Spacer(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // (6) Bottom nav: full-bleed, outside the padded body.
            _BottomNav(
              onNavigateHome: widget.onNavigateHome,
              onNavigateRewards: widget.onNavigateRewards,
              onNavigateCalendar: widget.onNavigateCalendar,
            ),
          ],
        ),
      ),
    );
  }
}

TextStyle _nunito(double size, FontWeight weight, Color color) =>
    GoogleFonts.nunito(fontSize: size, fontWeight: weight, color: color);

/// Row card / banner decoration, exactly per spec: white bg, 1px border
/// rgba(255,255,255,0.95), radius 20, shadow
/// 0px 5px 16px -4px rgba(59,77,56,0.09).
BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: FigmaColors.white,
    borderRadius: BorderRadius.circular(20),
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
// (2) Segmented control — sageLight track, 2 equal segments.
// ---------------------------------------------------------------------------

class _SegmentedControl extends StatelessWidget {
  const _SegmentedControl({
    required this.selected,
    required this.onSegmentChange,
  });

  final ChoresSegment selected;
  final ValueChanged<ChoresSegment> onSegmentChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: FigmaColors.sageLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          for (final segment in ChoresSegment.values)
            Expanded(
              child: GestureDetector(
                onTap: () => onSegmentChange(segment),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: segment == selected ? FigmaColors.sage : null,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    segment.label,
                    textAlign: TextAlign.center,
                    style: _nunito(
                      13,
                      FontWeight.w700,
                      segment == selected
                          ? FigmaColors.white
                          : FigmaColors.sageDark,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// (3) Chore row — white card, left status tile, text block, points pill.
// ---------------------------------------------------------------------------

class _ChoreRow extends StatelessWidget {
  const _ChoreRow({required this.chore, required this.onTap});

  final Chore chore;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final approved = chore.isApproved;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: _cardDecoration(),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        child: Row(
          children: [
            // Left status tile: filled sage checkbox for completed rows,
            // sageLight chevron tile for pending rows (never an empty box).
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: approved ? FigmaColors.sage : FigmaColors.sageLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                approved ? Icons.check : Icons.chevron_right,
                size: approved ? 16 : 14,
                // Spec pins white for the check; the chevron color is
                // unspecified, so it follows this screen's sageLight-tile
                // foreground convention (sageDark, as in the segment).
                color: approved ? FigmaColors.white : FigmaColors.sageDark,
              ),
            ),
            const SizedBox(width: 14),
            // Text block: completed rows render fully in mute (no strike).
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chore.title,
                    style: _nunito(
                      15,
                      FontWeight.w700,
                      approved ? FigmaColors.mute : FigmaColors.ink,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    chore.subtitle,
                    style: _nunito(12, FontWeight.w500, FigmaColors.mute),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            _PointsPill(points: chore.points),
          ],
        ),
      ),
    );
  }
}

class _PointsPill extends StatelessWidget {
  const _PointsPill({required this.points});

  final int points;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: FigmaColors.pastelYellow,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Star color is unspecified; it matches the pill's ink text.
          const Icon(Icons.star, size: 12, color: FigmaColors.ink),
          const SizedBox(width: 4),
          Text(
            '+$points pts',
            style: _nunito(12, FontWeight.w800, FigmaColors.ink),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// (4) Banner — yellowLight card with the trophy glyph.
// ---------------------------------------------------------------------------

class _Banner extends StatelessWidget {
  const _Banner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: FigmaColors.pastelYellow,
        borderRadius: BorderRadius.circular(20),
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
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          // The design's banner glyph, reproduced as specified.
          const Text('🏆', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Take a photo or video when done. Mom reviews it before you earn points.',
              style: _nunito(13, FontWeight.w700, FigmaColors.ink),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// (6) Bottom nav — EXACTLY Home / Rewards / Calendar, Home active.
// ---------------------------------------------------------------------------

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.onNavigateHome,
    required this.onNavigateRewards,
    required this.onNavigateCalendar,
  });

  final VoidCallback? onNavigateHome;
  final VoidCallback? onNavigateRewards;
  final VoidCallback? onNavigateCalendar;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: FigmaColors.white,
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            offset: Offset(0, -3),
            blurRadius: 12,
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavTab(
            label: 'Home',
            icon: Icons.home,
            active: true,
            onTap: onNavigateHome,
          ),
          _NavTab(
            label: 'Rewards',
            icon: Icons.card_giftcard,
            active: false,
            onTap: onNavigateRewards,
          ),
          _NavTab(
            label: 'Calendar',
            icon: Icons.calendar_today,
            active: false,
            onTap: onNavigateCalendar,
          ),
        ],
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
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
    // Icon colors are unspecified; they follow their label colors.
    final color = active ? FigmaColors.sage : FigmaColors.mute;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 62,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 3),
            Text(
              label,
              style: _nunito(
                11,
                active ? FontWeight.w800 : FontWeight.w600,
                color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
