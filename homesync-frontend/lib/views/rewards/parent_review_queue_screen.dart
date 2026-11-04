import 'dart:ui';

import 'package:flutter/material.dart';

import 'models/reward_review_request.dart';

/// Figma "Parent Review Queue — Reward Requests" (node 100:5013): Sarah's
/// review of Noah's custom-reward request. Reward Requests tab selected.
///
/// Figma tokens are hard-coded here because they differ from the shared
/// theme (`AppColors` cream/sage/ink predate this design) — same
/// screen-local-tokens precedent as KidsRewardStoreScreen. `LiquidGlassCard`
/// is not reused because its fixed values differ from this design's exact
/// card spec. Font, header, pill, and bottom-nav patterns mirror
/// KidsRewardStoreScreen.
///
/// This screen builds ONLY the Reward Requests tab content. The Task
/// Reviews tab is a placeholder callback ([onSelectTaskReviewsTab]) — its
/// content is not built here.
///
/// Mock data ([kRewardReviewRequest], [kReviewPendingCounts]) is local.
/// Every handler is an optional placeholder callback — this screen makes
/// no API calls, deducts or awards no points, and modifies no store.
class ParentReviewQueueScreen extends StatefulWidget {
  const ParentReviewQueueScreen({
    super.key,
    this.request = kRewardReviewRequest,
    this.counts = kReviewPendingCounts,
    this.onBack,
    this.onSelectTaskReviewsTab,
    this.onSelectRewardRequestsTab,
    this.onApproveAndAddToStore,
    this.onDeclineOrEditPoints,
    this.onNavigateHome,
    this.onNavigateCalendar,
    this.onNavigateTasks,
    this.onNavigateFamily,
  });

  // Figma tokens (screen-only, see class doc).
  static const Color _cream = Color(0xFFFBF7EF);
  static const Color _ink = Color(0xFF2B3A2B);
  static const Color _mute = Color(0xFF7C877A);
  static const Color _sage = Color(0xFF5F7F55);
  static const Color _sageDark = Color(0xFF4A6A41);
  static const Color _sageMid = Color(0xFFA9BE9C);
  static const Color _sageLight = Color(0xFFE4EBDC);
  static const Color _line = Color(0xFFE8E4D8);
  static const Color _white = Color(0xFFFFFFFF);
  static const Color _yellowLight = Color(0xFFFDF0C8);
  static const Color _peach = Color(0xFFF6D9C4);

  static const String _font = 'Nunito';

  /// Card shadow: 0px 5px 16px -4px rgba(59,77,56,0.07).
  static const List<BoxShadow> _cardShadow = [
    BoxShadow(
      color: Color.fromRGBO(59, 77, 56, 0.07),
      offset: Offset(0, 5),
      blurRadius: 16,
      spreadRadius: -4,
    ),
  ];

  /// Primary-button shadow: 0px 4px 5px rgba(94,128,84,0.3).
  static const List<BoxShadow> _primaryShadow = [
    BoxShadow(
      color: Color.fromRGBO(94, 128, 84, 0.3),
      offset: Offset(0, 4),
      blurRadius: 5,
    ),
  ];

  /// The ONE reward request on this screen.
  final RewardReviewRequest request;

  /// Single source of truth for the subtitle total and both tab badges.
  final PendingCounts counts;

  final VoidCallback? onBack;

  /// Placeholder — the Task Reviews content is not built in this task,
  /// so tapping it fires the callback without switching content.
  final VoidCallback? onSelectTaskReviewsTab;
  final VoidCallback? onSelectRewardRequestsTab;

  /// Called with (requestId, storePointCost). Placeholder only — no
  /// backend, no points movement, no store change.
  final void Function(String requestId, int storePointCost)?
      onApproveAndAddToStore;

  /// ONE combined secondary action. Called with the request id.
  final ValueChanged<String>? onDeclineOrEditPoints;

  final VoidCallback? onNavigateHome;
  final VoidCallback? onNavigateCalendar;

  /// Current section — already selected.
  final VoidCallback? onNavigateTasks;
  final VoidCallback? onNavigateFamily;

  @override
  State<ParentReviewQueueScreen> createState() =>
      _ParentReviewQueueScreenState();
}

class _ParentReviewQueueScreenState extends State<ParentReviewQueueScreen> {
  late final TextEditingController _costController;

  /// Editable store cost in points, backing the cost input.
  late int _storePointCost;

  @override
  void initState() {
    super.initState();
    _storePointCost = widget.request.storePointCost;
    _costController =
        TextEditingController(text: '$_storePointCost points');
    _costController.addListener(_onCostChanged);
  }

  @override
  void dispose() {
    _costController.removeListener(_onCostChanged);
    _costController.dispose();
    super.dispose();
  }

  /// Keeps [_storePointCost] numeric while the input shows the " points"
  /// suffix. Unparseable text keeps the previous value so derived copy
  /// never shows garbage mid-edit.
  void _onCostChanged() {
    final digits = _costController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final parsed = int.tryParse(digits);
    if (parsed != null && parsed != _storePointCost) {
      setState(() => _storePointCost = parsed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ParentReviewQueueScreen._cream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            top: 12,
            left: 20,
            right: 20,
            bottom: 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeading(),
              const SizedBox(height: 16),
              _buildTabs(),
              const SizedBox(height: 16),
              _buildRequestCard(),
              const SizedBox(height: 16),
              _buildBanner(),
              const SizedBox(height: 16),
              _buildActions(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // SECTION 1 — Page heading: header row + title block.
  Widget _buildHeading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: widget.onBack,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(255, 255, 255, 0.91),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Icon(
                  Icons.chevron_left_rounded,
                  size: 20,
                  color: ParentReviewQueueScreen._ink,
                ),
              ),
            ),
            const Expanded(
              child: Text(
                'HomeSync',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: ParentReviewQueueScreen._font,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: ParentReviewQueueScreen._sage,
                ),
              ),
            ),
            // Sarah's avatar: no avatar image/asset exists in this
            // project, so the peach circle carries a person glyph
            // (23px, sageDark) per the Figma placeholder — never emoji.
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: ParentReviewQueueScreen._peach,
                border: Border.all(
                  color: ParentReviewQueueScreen._white,
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.person_rounded,
                size: 23,
                color: ParentReviewQueueScreen._sageDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const Text(
          'Parent Review Queue',
          style: TextStyle(
            fontFamily: ParentReviewQueueScreen._font,
            fontWeight: FontWeight.w800,
            fontSize: 26,
            color: ParentReviewQueueScreen._ink,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Sarah \u00B7 Parent Mode \u00B7 '
          '${widget.counts.totalPending} pending items',
          style: const TextStyle(
            fontFamily: ParentReviewQueueScreen._font,
            fontWeight: FontWeight.w500,
            fontSize: 12,
            color: ParentReviewQueueScreen._mute,
          ),
        ),
      ],
    );
  }

  // SECTION 2 — Review queue tabs. Reward Requests is selected.
  Widget _buildTabs() {
    return Row(
      children: [
        Expanded(
          child: _buildQueueTab(
            label: 'Task Reviews',
            count: widget.counts.taskReviews,
            selected: false,
            onTap: widget.onSelectTaskReviewsTab,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _buildQueueTab(
            label: 'Reward Requests',
            count: widget.counts.rewardRequests,
            selected: true,
            onTap: widget.onSelectRewardRequestsTab,
          ),
        ),
      ],
    );
  }

  Widget _buildQueueTab({
    required String label,
    required int count,
    required bool selected,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 9),
        decoration: BoxDecoration(
          color: selected
              ? ParentReviewQueueScreen._sage
              : ParentReviewQueueScreen._white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: ParentReviewQueueScreen._font,
                fontWeight: FontWeight.w800,
                fontSize: 12,
                color: selected
                    ? ParentReviewQueueScreen._white
                    : ParentReviewQueueScreen._sage,
              ),
            ),
            const SizedBox(width: 5),
            Container(
              width: 21,
              height: 21,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? ParentReviewQueueScreen._white
                    : ParentReviewQueueScreen._sageLight,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  fontFamily: ParentReviewQueueScreen._font,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  color: ParentReviewQueueScreen._sageDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // SECTION 3 — Request card (Noah's custom-reward request).
  Widget _buildRequestCard() {
    const radius = BorderRadius.all(Radius.circular(22));
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 9, sigmaY: 9),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Color.fromRGBO(255, 255, 255, 0.79),
            border: Border.fromBorderSide(
              BorderSide(color: ParentReviewQueueScreen._white),
            ),
            borderRadius: radius,
            boxShadow: ParentReviewQueueScreen._cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildIdentityRow(),
              const SizedBox(height: 16),
              _buildPerkBlock(),
              const SizedBox(height: 16),
              _buildPointsSummary(),
              const SizedBox(height: 16),
              _buildChildNote(),
              const SizedBox(height: 16),
              Container(
                height: 1,
                color: ParentReviewQueueScreen._line,
              ),
              const SizedBox(height: 16),
              _buildCostField(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIdentityRow() {
    final request = widget.request;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: ParentReviewQueueScreen._sageLight,
            border: Border.all(
              color: ParentReviewQueueScreen._white,
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Text(
            request.childInitial,
            style: const TextStyle(
              fontFamily: ParentReviewQueueScreen._font,
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: ParentReviewQueueScreen._sageDark,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${request.childName} \u00B7 ${request.childAge}',
                style: const TextStyle(
                  fontFamily: ParentReviewQueueScreen._font,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: ParentReviewQueueScreen._ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                request.childMode,
                style: const TextStyle(
                  fontFamily: ParentReviewQueueScreen._font,
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                  color: ParentReviewQueueScreen._mute,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: ParentReviewQueueScreen._yellowLight,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            request.status,
            style: const TextStyle(
              fontFamily: ParentReviewQueueScreen._font,
              fontWeight: FontWeight.w800,
              fontSize: 11,
              color: ParentReviewQueueScreen._sageDark,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPerkBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'CUSTOM REWARD REQUEST',
          style: TextStyle(
            fontFamily: ParentReviewQueueScreen._font,
            fontWeight: FontWeight.w800,
            fontSize: 11,
            color: ParentReviewQueueScreen._sage,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          widget.request.perkName,
          style: const TextStyle(
            fontFamily: ParentReviewQueueScreen._font,
            fontWeight: FontWeight.w800,
            fontSize: 24,
            color: ParentReviewQueueScreen._ink,
          ),
        ),
      ],
    );
  }

  Widget _buildPointsSummary() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ParentReviewQueueScreen._sageLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Proposed cost',
                  style: TextStyle(
                    fontFamily: ParentReviewQueueScreen._font,
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                    color: ParentReviewQueueScreen._sageDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${widget.request.proposedCost} points',
                  style: const TextStyle(
                    fontFamily: ParentReviewQueueScreen._font,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    color: ParentReviewQueueScreen._ink,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 1,
            height: 48,
            color: ParentReviewQueueScreen._sageMid,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Current balance',
                  style: TextStyle(
                    fontFamily: ParentReviewQueueScreen._font,
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                    color: ParentReviewQueueScreen._sageDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${widget.request.currentBalance} points',
                  style: const TextStyle(
                    fontFamily: ParentReviewQueueScreen._font,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    color: ParentReviewQueueScreen._ink,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildNote() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${widget.request.childName}\u2019s note',
          style: const TextStyle(
            fontFamily: ParentReviewQueueScreen._font,
            fontWeight: FontWeight.w800,
            fontSize: 12,
            color: ParentReviewQueueScreen._ink,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          widget.request.childNote,
          style: const TextStyle(
            fontFamily: ParentReviewQueueScreen._font,
            fontWeight: FontWeight.w500,
            fontSize: 15,
            height: 1.35,
            color: ParentReviewQueueScreen._ink,
          ),
        ),
      ],
    );
  }

  Widget _buildCostField() {
    final gap = _storePointCost - widget.request.currentBalance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Store point cost \u00B7 editable by you',
          style: TextStyle(
            fontFamily: ParentReviewQueueScreen._font,
            fontWeight: FontWeight.w800,
            fontSize: 12,
            color: ParentReviewQueueScreen._ink,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          constraints: const BoxConstraints(minHeight: 46),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(255, 255, 255, 0.91),
            border: Border.all(color: ParentReviewQueueScreen._line),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _costController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    fontFamily: ParentReviewQueueScreen._font,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: ParentReviewQueueScreen._ink,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    filled: true,
                    fillColor:
                        Color.fromRGBO(255, 255, 255, 0.91),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Pencil icon: no color in the spec; mute matches the
              // input-affordance pattern.
              const Icon(
                Icons.edit_rounded,
                size: 18,
                color: ParentReviewQueueScreen._mute,
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '$gap more needed at the proposed price. You can change the '
          'cost before adding it to ${widget.request.childName}\u2019s store.',
          style: const TextStyle(
            fontFamily: ParentReviewQueueScreen._font,
            fontWeight: FontWeight.w500,
            fontSize: 11,
            height: 1.35,
            color: ParentReviewQueueScreen._mute,
          ),
        ),
      ],
    );
  }

  // SECTION 4 — Approval explanation banner.
  Widget _buildBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ParentReviewQueueScreen._sageLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Store icon: no color in the spec; sageDark matches the
          // glyph-on-tint pattern used elsewhere in the app.
          const Icon(
            Icons.storefront_rounded,
            size: 22,
            color: ParentReviewQueueScreen._sageDark,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Approval adds a reward, not a redemption',
                  style: TextStyle(
                    fontFamily: ParentReviewQueueScreen._font,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: ParentReviewQueueScreen._ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Adds this perk to ${widget.request.childName}\u2019s '
                  'eligible store. No points are deducted or awarded. '
                  'He can redeem only when approved and affordable.',
                  style: const TextStyle(
                    fontFamily: ParentReviewQueueScreen._font,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    height: 1.35,
                    color: ParentReviewQueueScreen._ink,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // SECTION 5 — Review actions.
  Widget _buildActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: () => widget.onApproveAndAddToStore?.call(
            widget.request.id,
            _storePointCost,
          ),
          child: Container(
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: ParentReviewQueueScreen._sage,
              borderRadius: BorderRadius.circular(18),
              boxShadow: ParentReviewQueueScreen._primaryShadow,
            ),
            child: const Text(
              'Approve & Add to Store',
              style: TextStyle(
                fontFamily: ParentReviewQueueScreen._font,
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: ParentReviewQueueScreen._white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () =>
              widget.onDeclineOrEditPoints?.call(widget.request.id),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.all(12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color.fromRGBO(255, 255, 255, 0.91),
              border: Border.all(
                color: ParentReviewQueueScreen._sageMid,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Text(
              'Decline / Edit Points',
              style: TextStyle(
                fontFamily: ParentReviewQueueScreen._font,
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: ParentReviewQueueScreen._sage,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Reward requests are separate from task evidence reviews. '
          'Your ${widget.counts.taskReviews} task reviews remain pending.',
          style: const TextStyle(
            fontFamily: ParentReviewQueueScreen._font,
            fontWeight: FontWeight.w500,
            fontSize: 11,
            height: 1.35,
            color: ParentReviewQueueScreen._mute,
          ),
        ),
      ],
    );
  }

  // Bottom navigation (parent nav): Home / Calendar / Tasks (active) /
  // Family. There is NO Rewards item here.
  Widget _buildBottomNav() {
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
              _buildTab(
                label: 'Home',
                icon: Icons.home_rounded,
                active: false,
                onTap: widget.onNavigateHome,
              ),
              _buildTab(
                label: 'Calendar',
                icon: Icons.calendar_month_rounded,
                active: false,
                onTap: widget.onNavigateCalendar,
              ),
              _buildTab(
                label: 'Tasks',
                icon: Icons.checklist_rounded,
                active: true,
                onTap: widget.onNavigateTasks,
              ),
              _buildTab(
                label: 'Family',
                icon: Icons.group_rounded,
                active: false,
                onTap: widget.onNavigateFamily,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: 116,
            height: 4,
            decoration: BoxDecoration(
              color: ParentReviewQueueScreen._ink,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required String label,
    required IconData icon,
    required bool active,
    required VoidCallback? onTap,
  }) {
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
              color: active
                  ? ParentReviewQueueScreen._sage
                  : ParentReviewQueueScreen._mute,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: ParentReviewQueueScreen._font,
                fontWeight:
                    active ? FontWeight.w800 : FontWeight.w600,
                fontSize: 11,
                color: active
                    ? ParentReviewQueueScreen._sage
                    : ParentReviewQueueScreen._mute,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
