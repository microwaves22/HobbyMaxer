import 'package:flutter/material.dart';

/// Sarah reward management (Figma node 62:6235) data layer.
///
/// STRUCTURE below is exact from Figma (section order, sizes, positions,
/// icon names). STRINGS are the retrieved Figma copy — fill-ins are
/// marked INFERRED below.
///
/// Icon mapping (Figma icon name → project Material icon; the Figma
/// names are retrieved facts):
/// shield-check → verified_user · circle-plus → add_circle_outline ·
/// chevron-down → keyboard_arrow_down · moon-star → bedtime ·
/// utensils → restaurant · clapperboard → movie (nearest Material
/// equivalent — no clapperboard glyph exists) · shopping-bag →
/// shopping_bag · house → home · calendar-days → calendar_month ·
/// list-checks → checklist · users → group.
///
/// This screen makes no API calls and persists nothing.
class ManagedPerk {
  const ManagedPerk({
    required this.id,
    required this.icon,
    required this.name,
    required this.detail,
    required this.costLabel,
  });

  final String id;

  /// EXACT from Figma (see mapping above) — not a placeholder.
  final IconData icon;
  final String name;
  final String detail;

  /// Cost text as rendered ("★ 80" style) — the star-prefix format is
  /// INFERRED from the spec's "existing rows" note; confirm against the
  /// frame if the rows render differently.
  final String costLabel;

  ManagedPerk copyWith({
    String? name,
    String? detail,
    String? costLabel,
  }) {
    return ManagedPerk(
      id: id,
      icon: icon,
      name: name ?? this.name,
      detail: detail ?? this.detail,
      costLabel: costLabel ?? this.costLabel,
    );
  }
}

/// One child profile that a perk can be designated for.
///
/// Labels follow the sibling-screen identity format (`'Noah · 14'`,
/// `'Ava · 8'` — see the link-kids and task-review screens). Only
/// entries with [active] set appear in the eligibility dropdowns.
class EligibleChild {
  const EligibleChild({
    required this.id,
    required this.name,
    required this.label,
    this.active = true,
  });

  final String id;
  final String name;
  final String label;
  final bool active;
}

/// Active child profiles for the Sarah household (Ava · 8, Noah · 14).
const List<EligibleChild> kEligibleChildren = [
  EligibleChild(id: 'ava', name: 'Ava', label: 'Ava · 8'),
  EligibleChild(id: 'noah', name: 'Noah', label: 'Noah · 14'),
];

/// Form state for the creation card.
class PerkFormState {
  const PerkFormState({
    required this.field1,
    required this.cost,
    required this.eligibility,
    required this.field2,
    required this.field3,
    required this.category,
  });

  final String field1;
  final String cost;
  final String eligibility;
  final String field2;
  final String field3;
  final String category;
}

/// ONE data block for the whole screen. Strings are Figma copy unless
/// marked INFERRED.
class RewardManagementData {
  const RewardManagementData({
    required this.title,
    required this.avatarLabel,
    required this.description,
    required this.categoryA,
    required this.categoryB,
    required this.selectedCategoryId,
    required this.bannerTitle,
    required this.bannerBody,
    required this.creationHeading,
    required this.field1Label,
    required this.field1Value,
    required this.costLabel,
    required this.costValue,
    required this.eligibilityLabel,
    required this.eligibilityValue,
    required this.field2Label,
    required this.field2Value,
    required this.field2Placeholder,
    required this.helperText,
    required this.field3Label,
    required this.field3Value,
    required this.primaryActionLabel,
    required this.existingHeading,
    required this.statusPillLabel,
    required this.perks,
    required this.editLabel,
    this.eligibleChildren = kEligibleChildren,
    required this.navLabels,
    required this.activeNavId,
  });

  final String title;

  /// 42px avatar identity mark. INFERRED: the spec pins 42px peach but
  /// not the content, so Sarah's initial is kept.
  final String avatarLabel;
  final String description;

  /// INFERRED: the spec names only the selected segment ("Real-world").
  /// "Digital" mirrors the sibling stores' digital/real-world split.
  final String categoryA;
  final String categoryB;

  /// 'a' or 'b'. The SECOND segment ("Real-world") is selected in Figma.
  final String selectedCategoryId;
  final String bannerTitle;
  final String bannerBody;
  final String creationHeading;
  final String field1Label;
  final String field1Value;
  final String costLabel;
  final String costValue;
  final String eligibilityLabel;
  final String eligibilityValue;
  final String field2Label;

  /// EMPTY in the design — the field renders [field2Placeholder] instead.
  final String field2Value;
  final String field2Placeholder;
  final String helperText;
  final String field3Label;
  final String field3Value;
  final String primaryActionLabel;
  final String existingHeading;

  /// Expected pill text ('4 perks'). The screen derives the live count
  /// from [perks] so they stay in sync.
  final String statusPillLabel;

  /// The status pill ("4 perks") is computed from this array's length.
  final List<ManagedPerk> perks;

  /// Same on all rows. Text action, not a toggle.
  final String editLabel;

  /// Child profiles the eligibility dropdowns draw from. Only entries
  /// with [EligibleChild.active] set are offered.
  final List<EligibleChild> eligibleChildren;
  final List<String> navLabels;

  /// Active bottom-nav item id. FAMILY is active in the design.
  final String activeNavId;
}

/// Figma copy for node 62:6235. See INFERRED notes on the class for the
/// values the spec did not pin.
const RewardManagementData kRewardManagementData = RewardManagementData(
  title: 'Reward Management',
  avatarLabel: 'S',
  description: "Your family's rewards, on your terms.",
  categoryA: 'Digital',
  categoryB: 'Real-world',
  selectedCategoryId: 'b',
  bannerTitle: 'Managed by Sarah · Parent approval',
  bannerBody:
      'You set the cost, who can redeem, and any conditions. All requests come to you.',
  creationHeading: 'Create a custom perk',
  field1Label: 'Privilege / title',
  field1Value: 'Contribution toward a personal purchase',
  costLabel: 'Point cost',
  costValue: '200 points',
  eligibilityLabel: 'Eligible child',
  eligibilityValue: 'Noah · 14',
  field2Label: 'Contribution amount',
  field2Value: '',
  field2Placeholder: 'Enter an amount',
  helperText: 'Parent-defined amount. No payment or commitment is created here.',
  field3Label: 'Conditions · optional',
  field3Value: 'Agree on the item together before redeeming.',
  primaryActionLabel: 'Add Perk',
  existingHeading: 'Your real-world perks',
  statusPillLabel: '4 perks',
  perks: [
    ManagedPerk(
      id: 'managed-perk-1',
      // EXACT icon from Figma: moon-star.
      icon: Icons.bedtime_rounded,
      name: 'Extended weekend curfew',
      detail: '+30 mins · Noah',
      costLabel: '★ 80',
    ),
    ManagedPerk(
      id: 'managed-perk-2',
      // EXACT icon from Figma: utensils.
      icon: Icons.restaurant_rounded,
      name: 'Choose Friday night dinner / takeout',
      detail: 'Ava & Noah',
      costLabel: '★ 120',
    ),
    ManagedPerk(
      id: 'managed-perk-3',
      // EXACT icon from Figma: clapperboard.
      icon: Icons.movie_rounded,
      name: 'Pick the family movie',
      detail: 'Ava & Noah',
      costLabel: '★ 150',
    ),
    ManagedPerk(
      id: 'managed-perk-4',
      // EXACT icon from Figma: shopping-bag. This is the taller row:
      // the name below is long so it wraps to 2 lines like the design.
      icon: Icons.shopping_bag_rounded,
      name: 'Personal purchase contribution',
      detail: 'Amount defined by parent · Noah',
      costLabel: '★ 200',
    ),
  ],
  editLabel: 'Edit',
  navLabels: ['Home', 'Calendar', 'Tasks', 'Family'],
  activeNavId: 'family',
);
