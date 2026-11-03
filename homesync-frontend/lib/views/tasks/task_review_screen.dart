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

/// Local evidence asset: the child's submitted folded-laundry photo.
/// Illustrative placeholder generated locally; never a hotlink.
const _evidenceAsset = 'assets/folded-laundry-sample.png';

/// Nunito text in the exact size/weight/color. Most text on this screen
/// uses the 1.35 line height; button/tab/nav/pill labels pass
/// [height] null for the default line height.
TextStyle _nunito(double size, FontWeight weight, Color color,
        {double? height = 1.35}) =>
    GoogleFonts.nunito(
      fontSize: size,
      fontWeight: weight,
      height: height,
      color: color,
    );

/// Which review queue the parent is looking at. Only the Task Reviews
/// queue is built on this screen; switching is local state.
enum ReviewQueue { taskReviews, rewardRequests }

/// The single review data object this screen renders from.
///
/// Defaults are the Figma node 62:6347 values: Sarah reviewing Ava's
/// submitted Fold Laundry task. Field names follow the screen spec.
class TaskReviewData {
  const TaskReviewData({
    this.id = 'review-fold-laundry-ava',
    this.queueCounts = (taskReviews: 2, rewardRequests: 1),
    this.reviewerName = 'Sarah',
    this.positionLabel = 'Sarah · 1 of 2 pending approvals',
    this.child = (
      name: 'Ava',
      age: 8,
      identityLabel: 'Ava · 8',
      avatarGlyph: '🐱',
      avatarColor: FigmaColors.pink,
    ),
    this.submissionNote = 'Submitted for your review',
    this.status = 'Pending review',
    this.taskTitle = 'Fold Laundry',
    this.points = 15,
    this.pointsPillLabel = '★ +15 pts',
    this.dueLabel = 'Due today by 7 PM',
    this.evidenceCountLabel = '1 photo',
    this.evidenceCaption = 'Sample evidence · illustrative photo',
    this.instructions = const [
      'Fold all clean clothes',
      'Put them in your dresser',
      'Place socks in the top drawer',
    ],
    this.assignedByLabel = 'Assigned by Mom',
    this.currentBalance = 120,
    this.balanceAfterApproval = 135,
    this.safeguardTitle = 'Ava’s balance is still 120 points',
    this.safeguardBody = 'Pending review adds no points. '
        'Approval awards 15 points once, bringing the balance to 135.',
    this.approveLabel = 'Approve & Award 15 Points',
    this.requestChangesLabel = 'Request Changes',
    this.requestChangesExplainer = 'Request Changes returns this task to '
        'Ava with your feedback, without awarding points.',
  });

  final String id;
  final ({int taskReviews, int rewardRequests}) queueCounts;
  final String reviewerName;
  final String positionLabel;
  final ({
    String name,
    int age,
    String identityLabel,
    String avatarGlyph,
    Color avatarColor,
  }) child;
  final String submissionNote;
  final String status;
  final String taskTitle;
  final int points;
  final String pointsPillLabel;
  final String dueLabel;
  final String evidenceCountLabel;
  final String evidenceCaption;
  final List<String> instructions;
  final String assignedByLabel;
  final int currentBalance;
  final int balanceAfterApproval;
  final String safeguardTitle;
  final String safeguardBody;
  final String approveLabel;
  final String requestChangesLabel;
  final String requestChangesExplainer;
}

/// Sarah Task Review (Figma node 62:6347): parent Sarah reviewing Ava's
/// submitted Fold Laundry task.
///
/// Sections: (1) review queue tabs, (2) review header, (3) submission
/// card, (4) evidence & instructions (not a card), (5) points safeguard
/// banner, (6) review actions, (7) bottom navigation after the content.
///
/// Notes: no status bar is built (the project provides device UI); the
/// frosted surfaces use the same ClipRRect + BackdropFilter treatment as
/// the other Figma screens; the bottom nav here is Home / Calendar /
/// Tasks / Family with Tasks active and no Rewards tab, which differs
/// from the Kids To-Do nav (Home / Rewards / Calendar); no home
/// indicator is rendered because no other project bottom nav renders one.
/// Approve / request-changes are placeholder stubs: no backend, no
/// balance mutation, no navigation.
class TaskReviewScreen extends StatefulWidget {
  const TaskReviewScreen({
    super.key,
    this.review = const TaskReviewData(),
    this.onSwitchReviewQueue,
    this.onBackToNotifications,
    this.onOpenProfile,
    this.onApproveAndAward,
    this.onRequestChanges,
    this.onNavigateHome,
    this.onNavigateCalendar,
    this.onNavigateTasks,
    this.onNavigateFamily,
  });

  final TaskReviewData review;
  final ValueChanged<ReviewQueue>? onSwitchReviewQueue;
  final VoidCallback? onBackToNotifications;
  final VoidCallback? onOpenProfile;
  final VoidCallback? onApproveAndAward;
  final VoidCallback? onRequestChanges;
  final VoidCallback? onNavigateHome;
  final VoidCallback? onNavigateCalendar;
  final VoidCallback? onNavigateTasks;
  final VoidCallback? onNavigateFamily;

  @override
  State<TaskReviewScreen> createState() => _TaskReviewScreenState();
}

class _TaskReviewScreenState extends State<TaskReviewScreen> {
  ReviewQueue _queue = ReviewQueue.taskReviews;

  void _switchQueue(ReviewQueue queue) {
    setState(() => _queue = queue);
    widget.onSwitchReviewQueue?.call(queue);
  }

  @override
  Widget build(BuildContext context) {
    final review = widget.review;
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
                        _QueueTabs(
                          review: review,
                          active: _queue,
                          onSwitch: _switchQueue,
                        ),
                        const SizedBox(height: 18),
                        _ReviewHeader(
                          review: review,
                          onBack: widget.onBackToNotifications ??
                              () => Navigator.of(context).maybePop(),
                          onOpenProfile: widget.onOpenProfile ?? () {},
                        ),
                        const SizedBox(height: 18),
                        _SubmissionCard(review: review),
                        const SizedBox(height: 18),
                        _EvidenceSection(review: review),
                        const SizedBox(height: 18),
                        _SafeguardBanner(review: review),
                        const SizedBox(height: 18),
                        _ReviewActions(
                          review: review,
                          onApprove: widget.onApproveAndAward ?? () {},
                          onRequestChanges:
                              widget.onRequestChanges ?? () {},
                        ),
                      ],
                    ),
                  ),
                  _BottomNav(
                    onNavigateHome: widget.onNavigateHome ?? () {},
                    onNavigateCalendar:
                        widget.onNavigateCalendar ?? () {},
                    onNavigateTasks: widget.onNavigateTasks ?? () {},
                    onNavigateFamily: widget.onNavigateFamily ?? () {},
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

/// Frosted surface shared by the main card, the inactive queue tab, the
/// instructions panel, and the secondary button: translucent white fill,
/// 9px backdrop blur (the treatment used elsewhere in the app), a 1px
/// border, and the exact card shadow only where the spec gives one.
class _FrostedSurface extends StatelessWidget {
  const _FrostedSurface({
    required this.child,
    required this.fill,
    required this.border,
    required this.radius,
    this.padding = EdgeInsets.zero,
    this.constraints,
    this.alignment,
    this.shadow = false,
  });

  final Widget child;
  final Color fill;
  final Color border;
  final double radius;
  final EdgeInsetsGeometry padding;
  final BoxConstraints? constraints;
  final AlignmentGeometry? alignment;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    // Shadow lives on the outer box so the clip below (required for the
    // blur) cannot cut it off.
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: shadow ? const [_cardShadow] : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 9, sigmaY: 9),
          child: Container(
            padding: padding,
            constraints: constraints,
            alignment: alignment,
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: border, width: 1),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Small rounded pill label with the default line height.
class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.background,
    required this.textColor,
  });

  final String label;
  final Color background;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: _nunito(11, FontWeight.w800, textColor, height: null),
      ),
    );
  }
}

/// Section 1: two separate queue pills (not a segmented control).
/// Active styling follows local [_queue] state; counts never change.
class _QueueTabs extends StatelessWidget {
  const _QueueTabs({
    required this.review,
    required this.active,
    required this.onSwitch,
  });

  final TaskReviewData review;
  final ReviewQueue active;
  final ValueChanged<ReviewQueue> onSwitch;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _QueueTab(
          keyName: 'queue-task-reviews',
          label: 'Task Reviews',
          count: '${review.queueCounts.taskReviews}',
          isActive: active == ReviewQueue.taskReviews,
          onTap: () => onSwitch(ReviewQueue.taskReviews),
        ),
        const SizedBox(width: 8),
        _QueueTab(
          keyName: 'queue-reward-requests',
          label: 'Reward Requests',
          count: '${review.queueCounts.rewardRequests}',
          isActive: active == ReviewQueue.rewardRequests,
          onTap: () => onSwitch(ReviewQueue.rewardRequests),
        ),
      ],
    );
  }
}

class _QueueTab extends StatelessWidget {
  const _QueueTab({
    required this.keyName,
    required this.label,
    required this.count,
    required this.isActive,
    required this.onTap,
  });

  final String keyName;
  final String label;
  final String count;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const padding = EdgeInsets.symmetric(vertical: 10, horizontal: 14);
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: _nunito(
            13,
            FontWeight.w800,
            isActive ? FigmaColors.sage : FigmaColors.ink,
            height: null,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
          decoration: BoxDecoration(
            color: isActive
                ? FigmaColors.sageLight
                : FigmaColors.yellowLight,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            count,
            style: _nunito(
              11,
              FontWeight.w800,
              isActive ? FigmaColors.sage : FigmaColors.ink,
              height: null,
            ),
          ),
        ),
      ],
    );
    final pill = isActive
        ? Container(
            padding: padding,
            decoration: BoxDecoration(
              color: FigmaColors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: FigmaColors.sageMid, width: 1),
            ),
            child: content,
          )
        : _FrostedSurface(
            fill: FigmaColors.frostedReview,
            border: FigmaColors.frostedStrong,
            radius: 999,
            padding: padding,
            child: content,
          );
    return GestureDetector(
      key: ValueKey(keyName),
      onTap: onTap,
      child: pill,
    );
  }
}

/// Section 2: back button, title block, and parent avatar.
class _ReviewHeader extends StatelessWidget {
  const _ReviewHeader({
    required this.review,
    required this.onBack,
    required this.onOpenProfile,
  });

  final TaskReviewData review;
  final VoidCallback onBack;
  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          key: const ValueKey('review-back'),
          onTap: onBack,
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: FigmaColors.white,
              borderRadius: BorderRadius.circular(19),
            ),
            alignment: Alignment.center,
            // Figma 'chevron-left'.
            child: const Icon(
              Icons.chevron_left_rounded,
              size: 20,
              color: FigmaColors.ink,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Task Review',
                style: _nunito(23, FontWeight.w800, FigmaColors.ink),
              ),
              const SizedBox(height: 2),
              Text(
                review.positionLabel,
                style: _nunito(11, FontWeight.w500, FigmaColors.mute),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          key: const ValueKey('review-profile'),
          onTap: onOpenProfile,
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: FigmaColors.pastelPeach,
              shape: BoxShape.circle,
              border: Border.all(color: FigmaColors.white, width: 1),
            ),
            alignment: Alignment.center,
            child: Text(
              '👩',
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
    );
  }
}

/// Section 3: submission card (identity + task title + due).
class _SubmissionCard extends StatelessWidget {
  const _SubmissionCard({required this.review});

  final TaskReviewData review;

  @override
  Widget build(BuildContext context) {
    return _FrostedSurface(
      fill: FigmaColors.frostedReview,
      border: FigmaColors.frostedStrong,
      radius: 22,
      padding: const EdgeInsets.all(16),
      shadow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: review.child.avatarColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: FigmaColors.white, width: 1),
                ),
                alignment: Alignment.center,
                child: Text(
                  review.child.avatarGlyph,
                  style: _nunito(
                    23,
                    FontWeight.w400,
                    FigmaColors.sageDark,
                    height: 1,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.child.identityLabel,
                      style: _nunito(
                        16,
                        FontWeight.w800,
                        FigmaColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      review.submissionNote,
                      style: _nunito(
                        12,
                        FontWeight.w500,
                        FigmaColors.mute,
                      ),
                    ),
                  ],
                ),
              ),
              _Pill(
                label: review.status,
                background: FigmaColors.yellowLight,
                textColor: FigmaColors.ink,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  review.taskTitle,
                  style: _nunito(25, FontWeight.w800, FigmaColors.ink),
                ),
              ),
              const SizedBox(width: 10),
              _Pill(
                label: review.pointsPillLabel,
                background: FigmaColors.yellowLight,
                textColor: FigmaColors.ink,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Figma 'calendar-clock'.
              const Icon(
                Icons.schedule_rounded,
                size: 18,
                color: FigmaColors.ink,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  review.dueLabel,
                  style: _nunito(13, FontWeight.w800, FigmaColors.ink),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Section 4: evidence photo and instructions side by side. This group is
/// intentionally not wrapped in a card; only the instructions panel has
/// a fill.
class _EvidenceSection extends StatelessWidget {
  const _EvidenceSection({required this.review});

  final TaskReviewData review;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                'Submission details',
                style: _nunito(17, FontWeight.w800, FigmaColors.ink),
              ),
            ),
            _Pill(
              label: review.evidenceCountLabel,
              background: FigmaColors.white,
              textColor: FigmaColors.sage,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 154,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(19),
                    child: Image.asset(
                      _evidenceAsset,
                      width: 154,
                      height: 208,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    review.evidenceCaption,
                    style: _nunito(
                      10,
                      FontWeight.w500,
                      FigmaColors.mute,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FrostedSurface(
                fill: FigmaColors.frostedReview,
                border: FigmaColors.white,
                radius: 19,
                padding: const EdgeInsets.all(13),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Instructions',
                      style: _nunito(
                        14,
                        FontWeight.w800,
                        FigmaColors.ink,
                      ),
                    ),
                    for (final step in review.instructions) ...[
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Figma 'check'.
                          const Icon(
                            Icons.check_rounded,
                            size: 13,
                            color: FigmaColors.sage,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              step,
                              style: _nunito(
                                12,
                                FontWeight.w500,
                                FigmaColors.ink,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 10),
                    Text(
                      review.assignedByLabel,
                      style: _nunito(
                        10,
                        FontWeight.w500,
                        FigmaColors.mute,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Section 5: points safeguard banner.
class _SafeguardBanner extends StatelessWidget {
  const _SafeguardBanner({required this.review});

  final TaskReviewData review;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: FigmaColors.sageLight,
        borderRadius: BorderRadius.circular(19),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Figma 'shield-check'.
          const Icon(
            Icons.gpp_good_rounded,
            size: 24,
            color: FigmaColors.sageDark,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  review.safeguardTitle,
                  style: _nunito(13, FontWeight.w800, FigmaColors.ink),
                ),
                const SizedBox(height: 4),
                Text(
                  review.safeguardBody,
                  style: _nunito(11, FontWeight.w500, FigmaColors.ink),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Section 6: approve + request-changes buttons and the explainer.
/// Both handlers are placeholder stubs.
class _ReviewActions extends StatelessWidget {
  const _ReviewActions({
    required this.review,
    required this.onApprove,
    required this.onRequestChanges,
  });

  final TaskReviewData review;
  final VoidCallback onApprove;
  final VoidCallback onRequestChanges;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          key: const ValueKey('review-approve'),
          onTap: onApprove,
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
              review.approveLabel,
              style: _nunito(
                14,
                FontWeight.w800,
                FigmaColors.white,
                height: null,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          key: const ValueKey('review-request-changes'),
          onTap: onRequestChanges,
          child: _FrostedSurface(
            fill: FigmaColors.frostedReview,
            border: FigmaColors.sageMid,
            radius: 18,
            padding: const EdgeInsets.all(12),
            // Whole-box minimum: Container constraints include padding.
            constraints: const BoxConstraints(minHeight: 50),
            alignment: Alignment.center,
            child: Text(
              review.requestChangesLabel,
              textAlign: TextAlign.center,
              style: _nunito(
                14,
                FontWeight.w800,
                FigmaColors.sage,
                height: null,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          review.requestChangesExplainer,
          style: _nunito(11, FontWeight.w500, FigmaColors.mute),
        ),
      ],
    );
  }
}

/// Section 7: bottom nav with exactly Home / Calendar / Tasks / Family
/// and Tasks active. No Rewards tab on this screen, and no home
/// indicator: no other project bottom nav renders one.
class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.onNavigateHome,
    required this.onNavigateCalendar,
    required this.onNavigateTasks,
    required this.onNavigateFamily,
  });

  final VoidCallback onNavigateHome;
  final VoidCallback onNavigateCalendar;
  final VoidCallback onNavigateTasks;
  final VoidCallback onNavigateFamily;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FigmaColors.frostedNavReview,
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
                active: false,
                onTap: onNavigateHome,
              ),
              _tab(
                keyName: 'nav-calendar',
                label: 'Calendar',
                icon: Icons.calendar_month_rounded,
                active: false,
                onTap: onNavigateCalendar,
              ),
              _tab(
                keyName: 'nav-tasks',
                label: 'Tasks',
                icon: Icons.checklist_rounded,
                active: true,
                onTap: onNavigateTasks,
              ),
              _tab(
                keyName: 'nav-family',
                label: 'Family',
                icon: Icons.group_rounded,
                active: false,
                onTap: onNavigateFamily,
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
                height: null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
