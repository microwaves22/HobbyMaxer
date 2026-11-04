import 'package:flutter/material.dart';

import 'family_setup_screen.dart';
import 'models/interest_option.dart';

// Figma tokens (screen-only): hard-coded here because they differ from the
// shared theme (`AppColors` cream/sage/ink predate this design). Do not move
// them into the theme files: no other screen uses these values.
const _ink = Color(0xFF2B3A2B);
const _mute = Color(0xFF7C877A);
const _sage = Color(0xFF7A9A85);
const _sageLight = Color(0xFFE4EBDC);
const _sageMid = Color(0xFFA9BE9C);
const _line = Color(0xFFE8E4D8);
const _cream = Color(0xFFF9F8F6);
const _white = Color(0xFFFFFFFF);
const _unselectedRowFill = Color.fromRGBO(255, 255, 255, 0.66);
const _rowShadow = Color.fromRGBO(59, 77, 56, 0.07);
const _buttonShadow = Color(0x4D5E8054);

/// Figma "Onboarding interests" (node 62:5731): multi-select interest picker.
///
/// Rows are mapped from [kInterestOptions]. Selection state lives in
/// [_OnboardingInterestsScreenState._selectedIds]; the count line reads its
/// length on every build, so it always reflects the live selection.
class OnboardingInterestsScreen extends StatefulWidget {
  const OnboardingInterestsScreen({
    super.key,
    this.onToggleInterest,
    this.onContinue,
    this.onBack,
  });

  /// Called with the toggled interest id after each toggle.
  final ValueChanged<String>? onToggleInterest;

  /// Called when Continue is tapped. Defaults to pushing [FamilySetupScreen].
  final VoidCallback? onContinue;

  /// Called when the back button is tapped. Defaults to [Navigator.maybePop].
  final VoidCallback? onBack;

  @override
  State<OnboardingInterestsScreen> createState() =>
      _OnboardingInterestsScreenState();
}

class _OnboardingInterestsScreenState extends State<OnboardingInterestsScreen> {
  /// Live selection, seeded from the data array's default flags.
  late final Set<String> _selectedIds = {
    for (final option in kInterestOptions)
      if (option.selected) option.id,
  };

  void _toggleInterest(String id) {
    setState(() {
      if (!_selectedIds.remove(id)) {
        _selectedIds.add(id);
      }
    });
    widget.onToggleInterest?.call(id);
  }

  void _handleBack() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  void _handleContinue() {
    if (widget.onContinue != null) {
      widget.onContinue!();
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const FamilySetupScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
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
                    padding: const EdgeInsets.fromLTRB(24, 22, 24, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SetupProgress(onBack: _handleBack),
                        const SizedBox(height: 24),
                        const _Introduction(),
                        const SizedBox(height: 24),
                        _InterestChoices(
                          selectedIds: _selectedIds,
                          onToggle: _toggleInterest,
                        ),
                        const SizedBox(height: 24),
                        const Spacer(),
                        _NextStep(
                          selectedCount: _selectedIds.length,
                          onContinue: _handleContinue,
                        ),
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

/// Block 1: back button, step label, progress segments.
class _SetupProgress extends StatelessWidget {
  const _SetupProgress({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Semantics(
            label: 'Back',
            button: true,
            onTap: onBack,
            excludeSemantics: true,
            child: Material(
              color: _white,
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                onTap: onBack,
                borderRadius: BorderRadius.circular(18),
                child: const SizedBox(
                  width: 36,
                  height: 36,
                  child: Icon(
                    Icons.chevron_left_rounded,
                    size: 20,
                    color: _ink,
                  ),
                ),
              ),
            ),
          ),
          const Text(
            'STEP 1 OF 2',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w800,
              fontSize: 12,
              color: _sage,
            ),
          ),
          Row(
            children: [
              Container(
                width: 24,
                height: 5,
                decoration: BoxDecoration(
                  color: _sage,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 5),
              Container(
                width: 24,
                height: 5,
                decoration: BoxDecoration(
                  color: _sageLight,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Block 2: title + description.
class _Introduction extends StatelessWidget {
  const _Introduction();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What would you like to use HomeSync for?',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w800,
            fontSize: 29,
            height: 1.35,
            color: _ink,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'A little more harmony starts here. Choose everything that fits your family.',
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

/// Block 3: multi-select interest list, mapped from [kInterestOptions].
class _InterestChoices extends StatelessWidget {
  const _InterestChoices({
    required this.selectedIds,
    required this.onToggle,
  });

  final Set<String> selectedIds;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < kInterestOptions.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          _InterestRow(
            option: kInterestOptions[i],
            selected: selectedIds.contains(kInterestOptions[i].id),
            onToggle: onToggle,
          ),
        ],
      ],
    );
  }
}

/// One selectable interest row with checkbox semantics.
class _InterestRow extends StatelessWidget {
  const _InterestRow({
    required this.option,
    required this.selected,
    required this.onToggle,
  });

  final InterestOption option;
  final bool selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: option.title,
      checked: selected,
      onTap: () => onToggle(option.id),
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: () => onToggle(option.id),
          borderRadius: BorderRadius.circular(22),
          child: Container(
            constraints: const BoxConstraints(minHeight: 80),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: selected ? _sageLight : _unselectedRowFill,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: selected ? _sageMid : _white,
              ),
              boxShadow: const [
                BoxShadow(
                  color: _rowShadow,
                  offset: Offset(0, 5),
                  blurRadius: 16,
                  spreadRadius: -4,
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(option.icon, size: 20, color: _ink),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        option.title,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          height: 1.35,
                          color: _ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        option.description,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                          height: 1.35,
                          color: _mute,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: selected ? _sage : _white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected ? _sage : _line,
                    ),
                  ),
                  child: selected
                      ? const Icon(Icons.check, size: 15, color: _white)
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

/// Block 4: live count line, Continue button, next-step caption.
class _NextStep extends StatelessWidget {
  const _NextStep({
    required this.selectedCount,
    required this.onContinue,
  });

  final int selectedCount;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$selectedCount selected · You can change these later.',
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w500,
              fontSize: 12,
              height: 1.35,
              color: _sage,
            ),
          ),
          const SizedBox(height: 12),
          Container(
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
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: _sage,
                foregroundColor: _white,
                elevation: 0,
                shadowColor: Colors.transparent,
                minimumSize: const Size.fromHeight(54),
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                textStyle: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: _white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Next: Step 2 · Set up your family',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w500,
              fontSize: 12,
              height: 1.35,
              color: _mute,
            ),
          ),
        ],
      ),
    );
  }
}
