import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/widgets/profile_avatar_dropdown.dart';
import 'models/reward_management_data.dart';

/// Figma "Sarah reward management" (node 62:6235): the parent screen for
/// creating and managing store perks.
///
/// Section order, sizes, positions, and icon names are EXACT from Figma;
/// strings and the corrected styles are the retrieved Figma values.
/// Every string lives in [kRewardManagementData] (one data block).
/// Styles the spec did not pin keep the verified HomeSync pattern
/// (sibling screens), flagged [STYLE NOT RETRIEVED] where it mattered.
///
/// Spacing is reproduced from the design y-offsets (header y12 / desc
/// y70 / categories y104 / banner y164 / card y255 / heading y725 / list
/// y766), which resolve to uniform 16px section gaps; the creation
/// card's inner gaps resolve to 10px. Nothing is compressed.
///
/// No back button and no centered brand text — the structure has neither.
/// Creating or editing a perk calls no API and persists nothing: edits
/// update the on-screen list only.

///
/// The header avatar opens the shared profile dropdown (account
/// settings, family management, profile switching). The creation
/// heading carries no plus affordance: the inline fields below already
/// add consecutive perks.
class RewardManagementScreen extends StatefulWidget {
  const RewardManagementScreen({
    super.key,
    this.data = kRewardManagementData,
    this.onSelectCategory,
    this.onOpenEligibilitySelect,
    this.onCreatePerk,
    this.onEditPerk,
    this.onSavePerk,
    this.onNavigateHome,
    this.onNavigateCalendar,
    this.onNavigateTasks,
    this.onNavigateFamily,
    this.activeProfile = const ProfileOption(
      name: 'Sarah',
      roleLabel: 'Parent',
      isParent: true,
    ),
    this.profiles = const [],
    this.parentPin = '1234',
    this.onSwitchProfile,
    this.onAccountSettings,
    this.onManageFamily,
  });

  // App-wide pattern tokens (screen-only copies, sibling precedent).
  // [STYLE NOT RETRIEVED] for this screen — flag any deviation found
  // when node 62:6235 is re-pulled.
  static const Color _cream = Color(0xFFFBF7EF);
  static const Color _ink = Color(0xFF2B3A2B);
  static const Color _mute = Color(0xFF7C877A);
  static const Color _sage = Color(0xFF5F7F55);
  static const Color _sageDark = Color(0xFF4A6A41);
  static const Color _sageLight = Color(0xFFE4EBDC);
  static const Color _line = Color(0xFFE8E4D8);
  static const Color _white = Color(0xFFFFFFFF);
  static const Color _peach = Color(0xFFF6D9C4);

  /// Segmented-control track (same control as the teen store).
  static const Color _segmentTrack = Color(0xFFE9EAE3);

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

  /// The ONE data block for this screen.
  final RewardManagementData data;

  /// Called with the category id ('a' or 'b'). Placeholder.
  final ValueChanged<String>? onSelectCategory;

  /// Called when the eligibility dropdown is opened. The dropdown
  /// itself lists the active child profiles from
  /// [RewardManagementData.eligibleChildren].
  final VoidCallback? onOpenEligibilitySelect;

  /// Called with the current form state. Placeholder only — no API,
  /// no persistence (real behavior would add the perk to the list).
  final ValueChanged<PerkFormState>? onCreatePerk;

  /// Called with the perk id when its Edit action is tapped. The
  /// screen also opens the perk edit modal itself.
  final ValueChanged<String>? onEditPerk;

  /// Called with the updated perk when the edit modal is saved.
  /// Local state only — no API, no persistence.
  final ValueChanged<ManagedPerk>? onSavePerk;

  final VoidCallback? onNavigateHome;
  final VoidCallback? onNavigateCalendar;
  final VoidCallback? onNavigateTasks;
  final VoidCallback? onNavigateFamily;

  /// Profile shown in the header avatar dropdown (Sarah, the parent).
  final ProfileOption activeProfile;

  /// Other household profiles offered in the dropdown switcher.
  final List<ProfileOption> profiles;

  /// Demo Parent PIN guarding switches to parent profiles.
  final String parentPin;

  final ValueChanged<ProfileOption>? onSwitchProfile;
  final VoidCallback? onAccountSettings;
  final VoidCallback? onManageFamily;

  @override
  State<RewardManagementScreen> createState() =>
      _RewardManagementScreenState();
}

class _RewardManagementScreenState extends State<RewardManagementScreen> {
  late final TextEditingController _field1Controller;
  late final TextEditingController _costController;
  late final TextEditingController _eligibilityController;
  late final TextEditingController _field2Controller;
  late final TextEditingController _field3Controller;

  late String _selectedCategoryId;

  /// Currently selected eligibility dropdown value. Mirrored into
  /// [_eligibilityController] so [_handleCreate] keeps working unchanged.
  late String _eligibility;

  /// Locally editable copy of [RewardManagementData.perks]: the edit
  /// modal writes back here.
  late List<ManagedPerk> _perks;

  @override
  void initState() {
    super.initState();
    final data = widget.data;
    _field1Controller = TextEditingController(text: data.field1Value);
    _costController = TextEditingController(text: data.costValue);
    _eligibilityController =
        TextEditingController(text: data.eligibilityValue);
    _field2Controller = TextEditingController(text: data.field2Value);
    _field3Controller = TextEditingController(text: data.field3Value);
    _selectedCategoryId = data.selectedCategoryId;
    _eligibility = data.eligibilityValue;
    _perks = List.of(data.perks);
  }

  @override
  void didUpdateWidget(RewardManagementScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _perks = List.of(widget.data.perks);
      _eligibility = widget.data.eligibilityValue;
      _eligibilityController.text = _eligibility;
    }
  }

  @override
  void dispose() {
    _field1Controller.dispose();
    _costController.dispose();
    _eligibilityController.dispose();
    _field2Controller.dispose();
    _field3Controller.dispose();
    super.dispose();
  }

  void _handleSelectCategory(String id) {
    setState(() => _selectedCategoryId = id);
    widget.onSelectCategory?.call(id);
  }

  void _handleCreate() {
    widget.onCreatePerk?.call(
      PerkFormState(
        field1: _field1Controller.text,
        cost: _costController.text,
        eligibility: _eligibilityController.text,
        field2: _field2Controller.text,
        field3: _field3Controller.text,
        category: _selectedCategoryId,
      ),
    );
  }

  /// Labels of the active child profiles for the eligibility dropdown.
  /// The current value is always kept so the dropdown never strands it
  /// outside its item list (which Flutter forbids).
  List<String> _activeChildLabels() {
    final labels = <String>[
      for (final child in widget.data.eligibleChildren)
        if (child.active) child.label,
    ];
    if (!labels.contains(_eligibility)) {
      labels.insert(0, _eligibility);
    }
    return labels;
  }

  void _handleSelectEligibility(String? selected) {
    if (selected == null) return;
    setState(() {
      _eligibility = selected;
      _eligibilityController.text = selected;
    });
  }

  void _handleEditPerk(ManagedPerk perk) {
    widget.onEditPerk?.call(perk.id);
    _showEditPerkDialog(perk);
  }

  Future<void> _showEditPerkDialog(ManagedPerk perk) async {
    final updated = await showDialog<ManagedPerk>(
      context: context,
      builder: (_) => _EditPerkDialog(
        perk: perk,
        children: widget.data.eligibleChildren,
      ),
    );
    if (updated == null || !mounted) return;
    setState(() {
      final index = _perks.indexWhere((p) => p.id == updated.id);
      if (index != -1) _perks[index] = updated;
    });
    widget.onSavePerk?.call(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RewardManagementScreen._cream,
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
              _buildHeader(),
              const SizedBox(height: 16),
              _buildDescription(),
              const SizedBox(height: 16),
              _buildCategories(),
              const SizedBox(height: 16),
              _buildBanner(),
              const SizedBox(height: 16),
              _buildCreationCard(),
              const SizedBox(height: 16),
              _buildExistingHeading(),
              const SizedBox(height: 16),
              _buildPerksList(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // 1) HEADER ROW (height 42): title + 42px avatar ONLY. The avatar is
  // the shared profile dropdown trigger: tapping it opens the account
  // menu (switch profile, manage family, account settings).
  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            widget.data.title,
            style: const TextStyle(
              fontFamily: RewardManagementScreen._font,
              fontWeight: FontWeight.w800,
              fontSize: 26,
              color: RewardManagementScreen._ink,
            ),
          ),
        ),
        const SizedBox(width: 10),
        ProfileAvatarDropdown(
          active: widget.activeProfile,
          profiles: widget.profiles,
          parentPin: widget.parentPin,
          onSwitchProfile: widget.onSwitchProfile,
          onAccountSettings: widget.onAccountSettings,
          onManageFamily: widget.onManageFamily,
          avatar: Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              // Peach fill is Figma; the white border is sibling pattern.
              color: RewardManagementScreen._peach,
              border: Border.all(
                color: RewardManagementScreen._white,
              ),
              borderRadius: BorderRadius.circular(21),
            ),
            child: Text(
              widget.data.avatarLabel,
              style: const TextStyle(
                fontFamily: RewardManagementScreen._font,
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: RewardManagementScreen._sageDark,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 2) DESCRIPTION LINE (full width, one line).
  Widget _buildDescription() {
    return Text(
      widget.data.description,
      style: const TextStyle(
        fontFamily: RewardManagementScreen._font,
        fontWeight: FontWeight.w500,
        fontSize: 13,
        color: RewardManagementScreen._mute,
      ),
    );
  }

  // 3) REWARD CATEGORIES CONTROL (full width, height 44, padding 4):
  // exactly TWO equal segments (161.5 × 36 at design width), the
  // SECOND one ("Real-world") selected.
  Widget _buildCategories() {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: RewardManagementScreen._segmentTrack,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSegment(
              id: 'a',
              label: widget.data.categoryA,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildSegment(
              id: 'b',
              label: widget.data.categoryB,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegment({required String id, required String label}) {
    final selected = id == _selectedCategoryId;
    return GestureDetector(
      onTap: () => _handleSelectCategory(id),
      child: Container(
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? RewardManagementScreen._white
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: RewardManagementScreen._font,
            fontWeight: FontWeight.w800,
            fontSize: 12,
            color: selected
                ? RewardManagementScreen._sage
                // INFERRED: unselected label color (the spec pins only
                // the selected state).
                : RewardManagementScreen._mute,
          ),
        ),
      ),
    );
  }

  // 4) PARENT CONTROL CONTEXT BANNER (full width, min-height 75):
  // shield-check 24 + two text lines. Icon name EXACT.
  Widget _buildBanner() {
    return Container(
      constraints: const BoxConstraints(minHeight: 75),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: RewardManagementScreen._sageLight,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // [STYLE NOT RETRIEVED] — icon color is a pattern guess.
          const Icon(
            Icons.verified_user_rounded,
            size: 24,
            color: RewardManagementScreen._sageDark,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.data.bannerTitle,
                  style: const TextStyle(
                    fontFamily: RewardManagementScreen._font,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: RewardManagementScreen._ink,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  widget.data.bannerBody,
                  style: const TextStyle(
                    fontFamily: RewardManagementScreen._font,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    height: 1.35,
                    color: RewardManagementScreen._ink,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 5) CREATION CARD (full width, card pattern, padding 16, inner
  // content width 303 at design size, inner gaps 10).
  Widget _buildCreationCard() {
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
              BorderSide(color: RewardManagementScreen._white),
            ),
            borderRadius: radius,
            boxShadow: RewardManagementScreen._cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCreationHeading(),
              const SizedBox(height: 10),
              _buildField(
                label: widget.data.field1Label,
                controller: _field1Controller,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      label: widget.data.costLabel,
                      controller: _costController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildEligibilityField(),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildField(
                label: widget.data.field2Label,
                controller: _field2Controller,
                placeholder: widget.data.field2Placeholder,
              ),
              const SizedBox(height: 10),
              Text(
                widget.data.helperText,
                style: const TextStyle(
                  fontFamily: RewardManagementScreen._font,
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                  height: 1.35,
                  color: RewardManagementScreen._mute,
                ),
              ),
              const SizedBox(height: 10),
              _buildField(
                label: widget.data.field3Label,
                controller: _field3Controller,
              ),
              const SizedBox(height: 10),
              _buildPrimaryAction(),
            ],
          ),
        ),
      ),
    );
  }

  // 5a) CREATION HEADING: heading text only. The standalone plus
  // affordance was removed: the inline fields below already handle
  // adding consecutive perks.
  Widget _buildCreationHeading() {
    return Text(
      widget.data.creationHeading,
      style: const TextStyle(
        fontFamily: RewardManagementScreen._font,
        fontWeight: FontWeight.w800,
        fontSize: 16,
        color: RewardManagementScreen._ink,
      ),
    );
  }

  // Field block: label + 6 + 44px input.
  Widget _buildField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    String? placeholder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: RewardManagementScreen._font,
            fontWeight: FontWeight.w800,
            fontSize: 11,
            color: RewardManagementScreen._mute,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 44,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontFamily: RewardManagementScreen._font,
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: RewardManagementScreen._ink,
            ),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: const TextStyle(
                fontFamily: RewardManagementScreen._font,
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: RewardManagementScreen._mute,
              ),
              filled: true,
              fillColor: const Color.fromRGBO(255, 255, 255, 0.91),
              contentPadding: const EdgeInsets.all(12),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(14)),
                borderSide: BorderSide(
                  color: RewardManagementScreen._line,
                ),
              ),
              enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(14)),
                borderSide: BorderSide(
                  color: RewardManagementScreen._line,
                ),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(14)),
                borderSide: BorderSide(
                  color: RewardManagementScreen._sage,
                  width: 2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 5c-right) ELIGIBILITY: 44px dropdown of the active child
  // profiles + chevron-down 15 (EXACT icon = select/dropdown
  // affordance). Opening it still notifies
  // [onOpenEligibilitySelect].
  Widget _buildEligibilityField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.data.eligibilityLabel,
          style: const TextStyle(
            fontFamily: RewardManagementScreen._font,
            fontWeight: FontWeight.w800,
            fontSize: 11,
            color: RewardManagementScreen._mute,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 44,
          child: Listener(
            onPointerDown: (_) =>
                widget.onOpenEligibilitySelect?.call(),
            child: DropdownButtonFormField<String>(
              initialValue: _eligibility,
              isExpanded: true,
              items: [
                for (final label in _activeChildLabels())
                  DropdownMenuItem<String>(
                    value: label,
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: RewardManagementScreen._font,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: RewardManagementScreen._ink,
                      ),
                    ),
                  ),
              ],
              onChanged: _handleSelectEligibility,
              // [STYLE NOT RETRIEVED] — icon color is a pattern guess.
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 15,
                color: RewardManagementScreen._mute,
              ),
              style: const TextStyle(
                fontFamily: RewardManagementScreen._font,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: RewardManagementScreen._ink,
              ),
              decoration: const InputDecoration(
                filled: true,
                fillColor: Color.fromRGBO(255, 255, 255, 0.91),
                contentPadding: EdgeInsets.all(12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                  borderSide: BorderSide(
                    color: RewardManagementScreen._line,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                  borderSide: BorderSide(
                    color: RewardManagementScreen._line,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                  borderSide: BorderSide(
                    color: RewardManagementScreen._sage,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 5g) PRIMARY ACTION (303 × 54 at design size).
  Widget _buildPrimaryAction() {
    return GestureDetector(
      onTap: _handleCreate,
      child: Container(
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: RewardManagementScreen._sage,
          borderRadius: BorderRadius.circular(18),
          boxShadow: RewardManagementScreen._primaryShadow,
        ),
        child: Text(
          widget.data.primaryActionLabel,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: RewardManagementScreen._font,
            fontWeight: FontWeight.w800,
            fontSize: 14,
            color: RewardManagementScreen._white,
          ),
        ),
      ),
    );
  }

  // 6) EXISTING PERKS HEADING + 59×25 count pill (computed from the
  // perks array, not stored).
  Widget _buildExistingHeading() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            widget.data.existingHeading,
            style: const TextStyle(
              fontFamily: RewardManagementScreen._font,
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: RewardManagementScreen._ink,
            ),
          ),
        ),
        Container(
          width: 59,
          height: 25,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            // [STYLE NOT RETRIEVED] — pill colors are pattern.
            color: RewardManagementScreen._sageLight,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '${_perks.length} perks',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: RewardManagementScreen._font,
              fontWeight: FontWeight.w800,
              fontSize: 11,
              color: RewardManagementScreen._sageDark,
            ),
          ),
        ),
      ],
    );
  }

  // 7) MANAGED PERKS LIST: rendered from the editable [_perks]
  // copy (NOT hard-coded rows), 9px gaps, content-driven height
  // (min 62).
  Widget _buildPerksList() {
    final perks = _perks;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < perks.length; i++) ...[
          if (i > 0) const SizedBox(height: 9),
          _buildPerkRow(perks[i]),
        ],
      ],
    );
  }

  // Row layout (EXACT): symbol block 34×38 at x12, info at x56 (two
  // lines, gap 3), cost + edit controls right-aligned. Only the edit
  // action is interactive: it notifies [onEditPerk] and opens the
  // perk edit modal.
  Widget _buildPerkRow(ManagedPerk perk) {
    return Container(
      constraints: const BoxConstraints(minHeight: 62),
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Color.fromRGBO(255, 255, 255, 0.79),
        border: Border.fromBorderSide(
          BorderSide(color: RewardManagementScreen._white),
        ),
        borderRadius: BorderRadius.all(Radius.circular(22)),
        boxShadow: RewardManagementScreen._cardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 34,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: RewardManagementScreen._sageLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              perk.icon,
              size: 18,
              color: RewardManagementScreen._ink,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  perk.name,
                  style: const TextStyle(
                    fontFamily: RewardManagementScreen._font,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: RewardManagementScreen._ink,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  perk.detail,
                  style: const TextStyle(
                    fontFamily: RewardManagementScreen._font,
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                    height: 1.35,
                    color: RewardManagementScreen._mute,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                perk.costLabel,
                style: const TextStyle(
                  fontFamily: RewardManagementScreen._font,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  color: RewardManagementScreen._sage,
                ),
              ),
              const SizedBox(height: 2),
              GestureDetector(
                onTap: () => _handleEditPerk(perk),
                child: Text(
                  widget.data.editLabel,
                  style: const TextStyle(
                    fontFamily: RewardManagementScreen._font,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                    color: RewardManagementScreen._mute,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 8) BOTTOM NAVIGATION (pinned): 4 parent items. Icons EXACT, in
  // order: house / calendar-days / list-checks / users. Labels and the
  // FAMILY active item are confirmed; tab styling is sibling pattern.
  Widget _buildBottomNav() {
    const ids = ['home', 'calendar', 'tasks', 'family'];
    const icons = [
      Icons.home_rounded,
      Icons.calendar_month_rounded,
      Icons.checklist_rounded,
      Icons.group_rounded,
    ];
    const handlers = [
      _NavHandler.home,
      _NavHandler.calendar,
      _NavHandler.tasks,
      _NavHandler.family,
    ];
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
              for (var i = 0; i < 4; i++)
                _buildTab(
                  label: widget.data.navLabels[i],
                  icon: icons[i],
                  active: widget.data.activeNavId == ids[i],
                  onTap: _navHandler(handlers[i]),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: 116,
            height: 4,
            decoration: BoxDecoration(
              color: RewardManagementScreen._ink,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  VoidCallback? _navHandler(_NavHandler handler) {
    return switch (handler) {
      _NavHandler.home => widget.onNavigateHome,
      _NavHandler.calendar => widget.onNavigateCalendar,
      _NavHandler.tasks => widget.onNavigateTasks,
      _NavHandler.family => widget.onNavigateFamily,
    };
  }

  Widget _buildTab({
    required String label,
    required IconData icon,
    required bool active,
    required VoidCallback? onTap,
  }) {
    // [STYLE NOT RETRIEVED] — active/inactive tab styling is pattern
    // (mirrors the verified review-queue parent nav).
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
                  ? RewardManagementScreen._sage
                  : RewardManagementScreen._mute,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: RewardManagementScreen._font,
                fontWeight:
                    active ? FontWeight.w800 : FontWeight.w600,
                fontSize: 11,
                color: active
                    ? RewardManagementScreen._sage
                    : RewardManagementScreen._mute,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _NavHandler { home, calendar, tasks, family }

/// Edit modal for one real-world perk.
///
/// Parents can modify the perk type (name), the extra-time/detail line,
/// the assigned child (dropdown of the active child profiles), and the
/// point cost. Saving pops the updated [ManagedPerk]; cancelling pops
/// null and changes nothing.
class _EditPerkDialog extends StatefulWidget {
  const _EditPerkDialog({required this.perk, required this.children});

  final ManagedPerk perk;
  final List<EligibleChild> children;

  @override
  State<_EditPerkDialog> createState() => _EditPerkDialogState();
}

class _EditPerkDialogState extends State<_EditPerkDialog> {
  /// Separates the extra-time/detail head from the assigned-child tail
  /// in row detail lines (`'+30 mins · Noah'`).
  static const String _separator = ' · ';

  late final TextEditingController _typeController;
  late final TextEditingController _extraController;
  late final TextEditingController _costController;
  late String _assignedChild;

  @override
  void initState() {
    super.initState();
    final parts = _splitDetail(widget.perk.detail);
    _typeController = TextEditingController(text: widget.perk.name);
    _extraController = TextEditingController(text: parts.extra);
    _costController = TextEditingController(
      text: _costDigits(widget.perk.costLabel),
    );
    _assignedChild = parts.child;
  }

  @override
  void dispose() {
    _typeController.dispose();
    _extraController.dispose();
    _costController.dispose();
    super.dispose();
  }

  /// Splits a row detail line into its extra-time head and assigned-child
  /// tail. Lines without the separator (e.g. `'Ava & Noah'`) are treated
  /// as a child-only line.
  static ({String extra, String child}) _splitDetail(String detail) {
    final at = detail.lastIndexOf(_separator);
    if (at == -1) return (extra: '', child: detail);
    return (
      extra: detail.substring(0, at),
      child: detail.substring(at + _separator.length),
    );
  }

  /// Digits of a cost label (`'★ 80'` → `'80'`).
  static String _costDigits(String costLabel) {
    return RegExp(r'\d+')
        .allMatches(costLabel)
        .map((m) => m.group(0))
        .join();
  }

  /// Assigned-child menu: one entry per active profile (shown by label,
  /// valued by name) plus the perk's current token when it matches no
  /// profile (e.g. `'Ava & Noah'`), so saving without changes is a
  /// no-op and the dropdown value is always one of its items.
  List<DropdownMenuItem<String>> _childItems() {
    final items = <DropdownMenuItem<String>>[];
    final seen = <String>{};
    for (final child in widget.children) {
      if (!child.active || !seen.add(child.name)) continue;
      items.add(
        DropdownMenuItem<String>(
          value: child.name,
          child: Text(child.label),
        ),
      );
    }
    if (!seen.contains(_assignedChild)) {
      items.add(
        DropdownMenuItem<String>(
          value: _assignedChild,
          child: Text(
            _assignedChild.isEmpty ? 'Select a child' : _assignedChild,
          ),
        ),
      );
    }
    return items;
  }

  void _handleSave() {
    final type = _typeController.text.trim();
    final extra = _extraController.text.trim();
    final cost = int.tryParse(_costController.text.trim());
    Navigator.of(context).pop(
      widget.perk.copyWith(
        name: type.isEmpty ? widget.perk.name : type,
        detail: extra.isEmpty
            ? _assignedChild
            : '$extra$_separator$_assignedChild',
        costLabel: cost == null || cost < 1
            ? widget.perk.costLabel
            : '★ $cost',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Edit perk',
        style: TextStyle(
          fontFamily: RewardManagementScreen._font,
          fontWeight: FontWeight.w800,
          fontSize: 16,
          color: RewardManagementScreen._ink,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _modalField(
              label: 'Perk type',
              controller: _typeController,
            ),
            const SizedBox(height: 10),
            _modalField(
              label: 'Extra time',
              controller: _extraController,
            ),
            const SizedBox(height: 10),
            const Text(
              'Assigned child',
              style: TextStyle(
                fontFamily: RewardManagementScreen._font,
                fontWeight: FontWeight.w800,
                fontSize: 11,
                color: RewardManagementScreen._mute,
              ),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _assignedChild,
              isExpanded: true,
              items: _childItems(),
              onChanged: (selected) {
                if (selected == null) return;
                setState(() => _assignedChild = selected);
              },
              style: const TextStyle(
                fontFamily: RewardManagementScreen._font,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: RewardManagementScreen._ink,
              ),
              decoration: const InputDecoration(
                filled: true,
                fillColor: Color.fromRGBO(255, 255, 255, 0.91),
                contentPadding: EdgeInsets.all(12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                  borderSide: BorderSide(
                    color: RewardManagementScreen._line,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                  borderSide: BorderSide(
                    color: RewardManagementScreen._line,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                  borderSide: BorderSide(
                    color: RewardManagementScreen._sage,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            _modalField(
              label: 'Point cost',
              controller: _costController,
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _handleSave,
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _modalField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: RewardManagementScreen._font,
            fontWeight: FontWeight.w800,
            fontSize: 11,
            color: RewardManagementScreen._mute,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(
            fontFamily: RewardManagementScreen._font,
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: RewardManagementScreen._ink,
          ),
          decoration: const InputDecoration(
            filled: true,
            fillColor: Color.fromRGBO(255, 255, 255, 0.91),
            contentPadding: EdgeInsets.all(12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(14)),
              borderSide: BorderSide(
                color: RewardManagementScreen._line,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(14)),
              borderSide: BorderSide(
                color: RewardManagementScreen._line,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(14)),
              borderSide: BorderSide(
                color: RewardManagementScreen._sage,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
