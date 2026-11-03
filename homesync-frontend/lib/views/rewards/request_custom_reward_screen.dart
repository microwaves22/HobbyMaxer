import 'dart:ui';

import 'package:flutter/material.dart';

import 'models/custom_reward_request.dart';

/// Figma "Request Custom Reward" (node 100:4945): Noah's custom-reward
/// request form.
///
/// Figma tokens are hard-coded here because they differ from the shared
/// theme (`AppColors` cream/sage/ink predate this design) — same
/// screen-local-tokens precedent as KidsRewardStoreScreen. `LiquidGlassCard`
/// is not reused because its fixed values differ from this design's exact
/// card spec. Font, header, pill, and bottom-nav patterns mirror
/// KidsRewardStoreScreen.
///
/// NOTE: this screen's background is #F4F3EF (flat light grey-cream),
/// NOT the usual cream #FBF7EF. Screen-only value.
///
/// Form state ([CustomRewardFormState]) is local to this screen, pre-filled
/// with the design's values. Every handler is an optional placeholder
/// callback — this screen makes no API calls, deducts no points, and
/// navigates nowhere on send.
class RequestCustomRewardScreen extends StatefulWidget {
  const RequestCustomRewardScreen({
    super.key,
    this.availablePoints = kNoahAvailablePoints,
    this.recipient = kCustomRewardRecipient,
    this.initialForm = kInitialCustomRewardForm,
    this.onBack,
    this.onSendRequest,
    this.onCancel,
    this.onNavigateHome,
    this.onNavigateRewards,
    this.onNavigateCalendar,
  });

  // Figma tokens (screen-only, see class doc).
  static const Color _background = Color(0xFFF4F3EF);
  static const Color _ink = Color(0xFF2B3A2B);
  static const Color _mute = Color(0xFF7C877A);
  static const Color _sage = Color(0xFF5F7F55);
  static const Color _sageDark = Color(0xFF4A6A41);
  static const Color _sageMid = Color(0xFFA9BE9C);
  static const Color _sageLight = Color(0xFFE4EBDC);
  static const Color _line = Color(0xFFE8E4D8);
  static const Color _white = Color(0xFFFFFFFF);

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

  /// Single shared balance: drives the context pill, the safeguard card,
  /// and the status note.
  final int availablePoints;

  /// Who the request is sent to. Defaults to the design value.
  final String recipient;

  /// Design's pre-filled form values.
  final CustomRewardFormState initialForm;

  final VoidCallback? onBack;

  /// Called with the current form state. Placeholder only — no network
  /// call, no points deducted, no navigation.
  final ValueChanged<CustomRewardFormState>? onSendRequest;
  final VoidCallback? onCancel;

  final VoidCallback? onNavigateHome;

  /// Current section — already selected.
  final VoidCallback? onNavigateRewards;
  final VoidCallback? onNavigateCalendar;

  @override
  State<RequestCustomRewardScreen> createState() =>
      _RequestCustomRewardScreenState();
}

class _RequestCustomRewardScreenState extends State<RequestCustomRewardScreen> {
  late final TextEditingController _perkController;
  late final TextEditingController _costController;
  late final TextEditingController _noteController;

  /// Numeric points value backing the Proposed cost input.
  late int _proposedCost;

  @override
  void initState() {
    super.initState();
    _perkController =
        TextEditingController(text: widget.initialForm.requestedPerk);
    _proposedCost = widget.initialForm.proposedCost;
    _costController =
        TextEditingController(text: '$_proposedCost points');
    _costController.addListener(_onCostChanged);
    _noteController =
        TextEditingController(text: widget.initialForm.note);
  }

  @override
  void dispose() {
    _costController.removeListener(_onCostChanged);
    _perkController.dispose();
    _costController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  /// Keeps [_proposedCost] numeric while the input shows the " points"
  /// suffix. Unparseable text keeps the previous value so derived copy
  /// never shows garbage mid-edit.
  void _onCostChanged() {
    final digits = _costController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final parsed = int.tryParse(digits);
    if (parsed != null && parsed != _proposedCost) {
      setState(() => _proposedCost = parsed);
    }
  }

  CustomRewardFormState get _currentForm => CustomRewardFormState(
        requestedPerk: _perkController.text,
        proposedCost: _proposedCost,
        note: _noteController.text,
      );

  void _handleSend() {
    // TODO: no post-submit route is defined in the project yet — navigate
    // only once one exists. Sending deducts no points and calls no API.
    widget.onSendRequest?.call(_currentForm);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RequestCustomRewardScreen._background,
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
              _buildContextPills(),
              const SizedBox(height: 16),
              _buildIntro(),
              const SizedBox(height: 16),
              _buildFormCard(),
              const SizedBox(height: 16),
              _buildSafeguardCard(),
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
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _HeaderRow(),
        SizedBox(height: 14),
        Text(
          'Request Custom Reward',
          style: TextStyle(
            fontFamily: RequestCustomRewardScreen._font,
            fontWeight: FontWeight.w800,
            fontSize: 26,
            color: RequestCustomRewardScreen._ink,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Noah \u00B7 14 \u00B7 Teen Mode',
          style: TextStyle(
            fontFamily: RequestCustomRewardScreen._font,
            fontWeight: FontWeight.w500,
            fontSize: 12,
            color: RequestCustomRewardScreen._mute,
          ),
        ),
      ],
    );
  }

  // SECTION 2 — Request context pills.
  Widget _buildContextPills() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildPill('To ${widget.recipient} \u00B7 Parent'),
        _buildPill('${widget.availablePoints} points available'),
      ],
    );
  }

  Widget _buildPill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: RequestCustomRewardScreen._sageLight,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: RequestCustomRewardScreen._font,
          fontWeight: FontWeight.w800,
          fontSize: 11,
          color: RequestCustomRewardScreen._sageDark,
        ),
      ),
    );
  }

  // SECTION 3 — Intro line.
  Widget _buildIntro() {
    return Text(
      'Have a perk in mind? Suggest it to ${widget.recipient}, '
      'even if you\u2019re still saving up.',
      style: const TextStyle(
        fontFamily: RequestCustomRewardScreen._font,
        fontWeight: FontWeight.w500,
        fontSize: 14,
        height: 1.35,
        color: RequestCustomRewardScreen._mute,
      ),
    );
  }

  // SECTION 4 — Form card (3 fields with helpers).
  Widget _buildFormCard() {
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
              BorderSide(color: RequestCustomRewardScreen._white),
            ),
            borderRadius: radius,
            boxShadow: RequestCustomRewardScreen._cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildField(
                label: 'Requested perk',
                input: _buildTextInput(
                  controller: _perkController,
                  minHeight: 46,
                ),
                helper: 'Another idea: Stay up 30 mins late',
              ),
              const SizedBox(height: 16),
              _buildField(
                label: 'Proposed cost',
                input: _buildCostInput(),
                helper: 'Your suggestion only. '
                    '${widget.recipient} can approve it or edit the price.',
              ),
              const SizedBox(height: 16),
              _buildField(
                label: 'Your note to ${widget.recipient}',
                input: _buildTextInput(
                  controller: _noteController,
                  minHeight: 88,
                  maxLines: null,
                ),
                helper: null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required Widget input,
    required String? helper,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: RequestCustomRewardScreen._font,
            fontWeight: FontWeight.w800,
            fontSize: 12,
            color: RequestCustomRewardScreen._ink,
          ),
        ),
        const SizedBox(height: 6),
        input,
        if (helper != null) ...[
          const SizedBox(height: 6),
          Text(
            helper,
            style: const TextStyle(
              fontFamily: RequestCustomRewardScreen._font,
              fontWeight: FontWeight.w500,
              fontSize: 11,
              height: 1.35,
              color: RequestCustomRewardScreen._mute,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTextInput({
    required TextEditingController controller,
    required double minHeight,
    int? maxLines = 1,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        textAlignVertical: TextAlignVertical.top,
        style: const TextStyle(
          fontFamily: RequestCustomRewardScreen._font,
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: RequestCustomRewardScreen._ink,
        ),
        decoration: const InputDecoration(
          filled: true,
          fillColor: Color.fromRGBO(255, 255, 255, 0.91),
          contentPadding: EdgeInsets.all(12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
            borderSide: BorderSide(
              color: RequestCustomRewardScreen._line,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
            borderSide: BorderSide(
              color: RequestCustomRewardScreen._line,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
            borderSide: BorderSide(
              color: RequestCustomRewardScreen._sage,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCostInput() {
    return Container(
      constraints: const BoxConstraints(minHeight: 46),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 255, 255, 0.91),
        border: Border.all(color: RequestCustomRewardScreen._line),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _costController,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontFamily: RequestCustomRewardScreen._font,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: RequestCustomRewardScreen._ink,
              ),
              decoration: const InputDecoration(
                isDense: true,
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
            color: RequestCustomRewardScreen._mute,
          ),
        ],
      ),
    );
  }

  // SECTION 5 — Safeguard card. Numbers are derived from state.
  Widget _buildSafeguardCard() {
    final gap = _proposedCost - widget.availablePoints;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: RequestCustomRewardScreen._sageLight,
        border: Border.fromBorderSide(
          BorderSide(color: RequestCustomRewardScreen._white),
        ),
        borderRadius: BorderRadius.all(Radius.circular(22)),
        boxShadow: RequestCustomRewardScreen._cardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shield-check icon: no color in the spec; sageDark matches
          // the glyph-on-tint pattern used elsewhere in the app.
          const Icon(
            Icons.verified_user_rounded,
            size: 23,
            color: RequestCustomRewardScreen._sageDark,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Asking costs no points',
                  style: TextStyle(
                    fontFamily: RequestCustomRewardScreen._font,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: RequestCustomRewardScreen._ink,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'You can request $_proposedCost with '
                  '${widget.availablePoints} available. At this price, '
                  'save $gap more. The reward is only redeemable after '
                  '${widget.recipient} approves and you have enough points.',
                  style: const TextStyle(
                    fontFamily: RequestCustomRewardScreen._font,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    height: 1.35,
                    color: RequestCustomRewardScreen._ink,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // SECTION 6 — Form actions.
  Widget _buildActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: _handleSend,
          child: Container(
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: RequestCustomRewardScreen._sage,
              borderRadius: BorderRadius.circular(18),
              boxShadow: RequestCustomRewardScreen._primaryShadow,
            ),
            child: const Text(
              'Send Request',
              style: TextStyle(
                fontFamily: RequestCustomRewardScreen._font,
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: RequestCustomRewardScreen._white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: widget.onCancel,
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.all(12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color.fromRGBO(255, 255, 255, 0.91),
              border: Border.all(
                color: RequestCustomRewardScreen._sageMid,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: RequestCustomRewardScreen._font,
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: RequestCustomRewardScreen._sage,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Not sent yet \u00B7 Your balance stays at '
          '${widget.availablePoints} points.',
          style: const TextStyle(
            fontFamily: RequestCustomRewardScreen._font,
            fontWeight: FontWeight.w500,
            fontSize: 11,
            height: 1.35,
            color: RequestCustomRewardScreen._mute,
          ),
        ),
      ],
    );
  }

  // Bottom navigation: exactly Home / Rewards (active) / Calendar.
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
                label: 'Rewards',
                icon: Icons.card_giftcard_rounded,
                active: true,
                onTap: widget.onNavigateRewards,
              ),
              _buildTab(
                label: 'Calendar',
                icon: Icons.calendar_month_rounded,
                active: false,
                onTap: widget.onNavigateCalendar,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: 116,
            height: 4,
            decoration: BoxDecoration(
              color: RequestCustomRewardScreen._ink,
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
                  ? RequestCustomRewardScreen._sage
                  : RequestCustomRewardScreen._mute,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: RequestCustomRewardScreen._font,
                fontWeight:
                    active ? FontWeight.w800 : FontWeight.w600,
                fontSize: 11,
                color: active
                    ? RequestCustomRewardScreen._sage
                    : RequestCustomRewardScreen._mute,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Header row: back button, centered brand, teen avatar.
class _HeaderRow extends StatelessWidget {
  const _HeaderRow();

  @override
  Widget build(BuildContext context) {
    // onBack lives on the screen state; look it up via context.
    final screen = context
        .findAncestorWidgetOfExactType<RequestCustomRewardScreen>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: screen?.onBack,
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
              color: RequestCustomRewardScreen._ink,
            ),
          ),
        ),
        const Expanded(
          child: Text(
            'HomeSync',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: RequestCustomRewardScreen._font,
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: RequestCustomRewardScreen._sage,
            ),
          ),
        ),
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: RequestCustomRewardScreen._sageLight,
            border: Border.all(
              color: RequestCustomRewardScreen._white,
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Text(
            'N',
            style: TextStyle(
              fontFamily: RequestCustomRewardScreen._font,
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: RequestCustomRewardScreen._sageDark,
            ),
          ),
        ),
      ],
    );
  }
}
