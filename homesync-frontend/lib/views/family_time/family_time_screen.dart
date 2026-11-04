import 'package:flutter/material.dart';

import '../home/household_routes.dart';
import 'family_time_data.dart';
import 'models/family_time_option.dart';

// Figma tokens (screen-only): hard-coded here because they differ from the
// shared theme (`AppColors` cream/sage/ink predate this design). Do not move
// them into the theme files: no other screen uses these values.
const _cream = Color(0xFFFBF7EF);
const _ink = Color(0xFF2B3A2B);
const _mute = Color(0xFF7C877A);
const _sage = Color(0xFF5F7F55);
const _sageDark = Color(0xFF4A6A41);
const _sageLight = Color(0xFFE4EBDC);
const _line = Color(0xFFE8E4D8);
const _white = Color(0xFFFFFFFF);
const _yellowLight = Color(0xFFFDF0C8);
const _peach = Color(0xFFF6D9C4);

// Borrowed from sibling Figma screens: the same design system already
// defines these shades (profile hub node 62:5787, 06 Calendar node 4:121).
const _navFill = Color.fromRGBO(255, 255, 255, 0.8);
const _buttonShadow = Color(0x4D5E8054);

// Card shadow reused from the sibling screens (family setup, link kids).
const _cardShadow = BoxShadow(
  color: Color(0x173B4D38),
  offset: Offset(0, 5),
  blurRadius: 16,
  spreadRadius: -4,
);

/// Figma "07 Family Time" (node 4:246): header, category strip, suggested
/// time card with activity chips, confirm button, other time options, and
/// the household bottom navigation with the family tab active.
///
/// Content (titles, labels, copy) is transcribed from the design.
/// Sizes, gaps, and untranscribable colors are read from the design
/// screenshot; see the delivery report for the flagged estimates.
///
/// All callbacks are placeholders: local UI state only, no backend, no
/// persistence. Both option radios are unselected in the design, so the
/// selected-radio fill is an assumed style (see [_OptionRow]).
class FamilyTimeScreen extends StatefulWidget {
  const FamilyTimeScreen({
    super.key,
    this.onActivityTypeChange,
    this.onConfirmFamilyTime,
    this.onSeeAllOptions,
    this.onOptionSelect,
    this.onNavigate,
  });

  /// Called with the newly selected activity-type id.
  final ValueChanged<String>? onActivityTypeChange;

  /// Called when "Confirm Family Time" is tapped. Defaults to a
  /// confirmation snackbar for the selected activity and time.
  final VoidCallback? onConfirmFamilyTime;

  /// Called when "See All" is tapped. Defaults to an options sheet.
  final VoidCallback? onSeeAllOptions;

  /// Called with the tapped option id. Updates the selected radio.
  final ValueChanged<String>? onOptionSelect;

  /// Called with the tapped bottom-nav tab id. When null, tabs switch
  /// with replacement (no-op for the family tab itself).
  final ValueChanged<String>? onNavigate;

  @override
  State<FamilyTimeScreen> createState() => _FamilyTimeScreenState();
}

class _FamilyTimeScreenState extends State<FamilyTimeScreen> {
  String _activityTypeId = FamilyTimeData.defaultActivityTypeId;
  String? _selectedOptionId;

  void _changeActivityType(String id) {
    setState(() => _activityTypeId = id);
    widget.onActivityTypeChange?.call(id);
  }

  void _selectOption(String id) {
    setState(() => _selectedOptionId = id);
    widget.onOptionSelect?.call(id);
  }

  void _defaultConfirm() {
    final activity = FamilyTimeData.activityTypeById(_activityTypeId).label;
    FamilyTimeOption? option;
    for (final candidate in FamilyTimeData.options) {
      if (candidate.id == _selectedOptionId) option = candidate;
    }
    final when = option == null
        ? '${FamilyTimeData.suggestedDay}, ${FamilyTimeData.suggestedTime}'
        : '${option.dayLabel}, ${option.timeLabel}';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Family time confirmed: $activity on $when')),
    );
  }

  void _defaultSeeAll() {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final option in FamilyTimeData.options)
              ListTile(
                title: Text(option.dayLabel),
                subtitle: Text(option.timeLabel),
                trailing: _selectedOptionId == option.id
                    ? const Icon(Icons.check_rounded)
                    : null,
                onTap: () {
                  _selectOption(option.id);
                  Navigator.of(sheetContext).pop();
                },
              ),
          ],
        ),
      ),
    );
  }

  void _handleNavigate(String tabId) {
    if (widget.onNavigate != null) {
      widget.onNavigate!(tabId);
      return;
    }
    if (tabId == 'family') return; // Already on Family Time.
    HouseholdRoutes.openTab(context, tabId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: 24,
            right: 24,
            top: 12,
            bottom: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _Header(),
              const SizedBox(height: 16),
              const _CategoryStrip(),
              const SizedBox(height: 12),
              _SuggestedCard(
                activityTypeId: _activityTypeId,
                onActivityTypeChange: _changeActivityType,
              ),
              const SizedBox(height: 12),
              _ConfirmButton(
                onConfirm: widget.onConfirmFamilyTime ?? _defaultConfirm,
              ),
              const SizedBox(height: 20),
              _OtherOptions(
                selectedOptionId: _selectedOptionId,
                onSeeAll: widget.onSeeAllOptions ?? _defaultSeeAll,
                onSelectOption: _selectOption,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: _BottomNav(onNavigate: _handleNavigate),
      ),
    );
  }
}

/// Header: "Family Time" title plus subtitle. No back arrow, avatar, or
/// action is shown in the design.
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          FamilyTimeData.title,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w800,
            fontSize: 28,
            height: 1.25,
            color: _ink,
          ),
        ),
        SizedBox(height: 4),
        Text(
          FamilyTimeData.subtitle,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w500,
            fontSize: 15,
            height: 1.35,
            color: _mute,
          ),
        ),
      ],
    );
  }
}

/// Hero: the four activity glyphs in separate 52px circles on an 82px
/// sageLight card. Static in the design (no selection state is shown
/// even though the Game Night chip below is selected), so the circles
/// are not tappable.
class _CategoryStrip extends StatelessWidget {
  const _CategoryStrip();

  static const _tileBackgrounds = [_white, _yellowLight, _white, _peach];

  @override
  Widget build(BuildContext context) {
    final ids = FamilyTimeData.stripTypeIds;
    return Container(
      height: 82,
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
      decoration: BoxDecoration(
        color: _sageLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (var i = 0; i < ids.length; i++)
            _StripIcon(
              type: FamilyTimeData.activityTypeById(ids[i]),
              background: _tileBackgrounds[i],
            ),
        ],
      ),
    );
  }
}

class _StripIcon extends StatelessWidget {
  const _StripIcon({required this.type, required this.background});

  final ActivityType type;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: background,
      ),
      child: Icon(type.icon, size: 28, color: _ink),
    );
  }
}

/// Suggested time card: label row, day, time, availability avatars, and
/// the activity-type chips, all mapped from [FamilyTimeData].
class _SuggestedCard extends StatelessWidget {
  const _SuggestedCard({
    required this.activityTypeId,
    required this.onActivityTypeChange,
  });

  final String activityTypeId;
  final ValueChanged<String> onActivityTypeChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _line),
        boxShadow: const [_cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                FamilyTimeData.suggestedLabel,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  height: 1.3,
                  color: _sageDark,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  color: _sageLight,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  FamilyTimeData.bestMatchLabel,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    height: 1.3,
                    color: _sage,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            FamilyTimeData.suggestedDay,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w800,
              fontSize: 20,
              height: 1.3,
              color: _ink,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            FamilyTimeData.suggestedTime,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w700,
              fontSize: 16,
              height: 1.3,
              color: _sage,
            ),
          ),
          const SizedBox(height: 10),
          const _AvailabilityRow(),
          const SizedBox(height: 12),
          _ActivityChips(
            activityTypeId: activityTypeId,
            onActivityTypeChange: onActivityTypeChange,
          ),
        ],
      ),
    );
  }
}

/// Availability row: member initial avatars plus the availability caption.
class _AvailabilityRow extends StatelessWidget {
  const _AvailabilityRow();

  @override
  Widget build(BuildContext context) {
    final members = FamilyTimeData.members;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < members.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: members[i].color,
              border: Border.all(color: _white, width: 2),
            ),
            child: Text(
              members[i].initials,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w800,
                fontSize: 11,
                height: 1.3,
                color: _sageDark,
              ),
            ),
          ),
        ],
        const SizedBox(width: 8),
        const Text(
          FamilyTimeData.availabilityLabel,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w600,
            fontSize: 13,
            height: 1.35,
            color: _mute,
          ),
        ),
      ],
    );
  }
}

/// Activity-type chips, mapped from [FamilyTimeData.activityTypes].
/// Game Night is selected in the design.
class _ActivityChips extends StatelessWidget {
  const _ActivityChips({
    required this.activityTypeId,
    required this.onActivityTypeChange,
  });

  final String activityTypeId;
  final ValueChanged<String> onActivityTypeChange;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final type in FamilyTimeData.activityTypes)
          _ActivityChip(
            type: type,
            selected: type.id == activityTypeId,
            onTap: () => onActivityTypeChange(type.id),
          ),
      ],
    );
  }
}

class _ActivityChip extends StatelessWidget {
  const _ActivityChip({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final ActivityType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: type.label,
      button: true,
      selected: selected,
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 12,
            ),
            decoration: BoxDecoration(
              color: selected ? _sage : _white,
              borderRadius: BorderRadius.circular(999),
              border: selected ? null : Border.all(color: _line),
            ),
            child: Text(
              type.label,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w700,
                fontSize: 13,
                height: 1.3,
                color: selected ? _white : _ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Primary action, following the Splash button pattern (54px tall,
/// radius 18, sage fill, white Nunito ExtraBold 16, sage shadow).
class _ConfirmButton extends StatelessWidget {
  const _ConfirmButton({required this.onConfirm});

  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: _buttonShadow,
            offset: Offset(0, 4),
            blurRadius: 5,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onConfirm,
        style: ElevatedButton.styleFrom(
          backgroundColor: _sage,
          foregroundColor: _white,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size.fromHeight(54),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        child: const Text(
          FamilyTimeData.confirmLabel,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w800,
            fontSize: 16,
            color: _white,
          ),
        ),
      ),
    );
  }
}

/// "Other Options" section: heading row plus the option cards, mapped
/// from [FamilyTimeData.options].
class _OtherOptions extends StatelessWidget {
  const _OtherOptions({
    required this.selectedOptionId,
    required this.onSeeAll,
    required this.onSelectOption,
  });

  final String? selectedOptionId;
  final VoidCallback? onSeeAll;
  final ValueChanged<String> onSelectOption;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              FamilyTimeData.otherOptionsLabel,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w800,
                fontSize: 17,
                height: 1.3,
                color: _ink,
              ),
            ),
            GestureDetector(
              onTap: onSeeAll,
              behavior: HitTestBehavior.opaque,
              child: const Text(
                FamilyTimeData.seeAllLabel,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  height: 1.3,
                  color: _sage,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < FamilyTimeData.options.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          _OptionRow(
            option: FamilyTimeData.options[i],
            selected:
                FamilyTimeData.options[i].id == selectedOptionId,
            onTap: () => onSelectOption(FamilyTimeData.options[i].id),
          ),
        ],
      ],
    );
  }
}

/// One option row: calendar tile, day/time labels, and a radio.
/// Both radios are unselected in the design; the selected fill (sage
/// with a white dot) is assumed so the local selection state is visible.
class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final FamilyTimeOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${option.dayLabel}, ${option.timeLabel}',
      button: true,
      selected: selected,
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _line),
              boxShadow: const [_cardShadow],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _sageLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.calendar_month_rounded,
                    size: 20,
                    color: _sage,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        option.dayLabel,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          height: 1.3,
                          color: _ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        option.timeLabel,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          height: 1.35,
                          color: _mute,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? _sage : _white,
                    border: Border.all(color: _sage, width: 2),
                  ),
                  child: selected
                      ? Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: _white,
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One bottom-navigation tab.
class _NavTab {
  const _NavTab({required this.id, required this.label, required this.icon});

  final String id;
  final String label;
  final IconData icon;
}

/// Bottom-nav tabs, copied from the existing household navigation
/// (profile hub): same items, order, icons, and labels.
const _navTabs = <_NavTab>[
  _NavTab(id: 'home', label: 'Home', icon: Icons.home_rounded),
  _NavTab(
    id: 'calendar',
    label: 'Calendar',
    icon: Icons.calendar_month_rounded,
  ),
  _NavTab(id: 'tasks', label: 'Tasks', icon: Icons.checklist_rounded),
  _NavTab(id: 'family', label: 'Family', icon: Icons.group_rounded),
];

/// Bottom navigation, replicating the existing household bar
/// (profile hub `_BottomNav`): same fill, padding, icon size, label
/// style, and active/inactive colors. Family is the active tab.
class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.onNavigate});

  final ValueChanged<String> onNavigate;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _navFill,
      padding: const EdgeInsets.only(top: 12, left: 20, right: 20, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (final tab in _navTabs)
            _NavTabButton(
              tab: tab,
              active: tab.id == 'family',
              onTap: () => onNavigate(tab.id),
            ),
        ],
      ),
    );
  }
}

/// One bottom-navigation tab: 64px wide, icon over label.
class _NavTabButton extends StatelessWidget {
  const _NavTabButton({
    required this.tab,
    required this.active,
    required this.onTap,
  });

  final _NavTab tab;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? _sage : _mute;
    return Semantics(
      label: tab.label,
      button: true,
      selected: active,
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 64,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(tab.icon, size: 23, color: color),
                const SizedBox(height: 4),
                Text(
                  tab.label,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 11,
                    height: 1.35,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
