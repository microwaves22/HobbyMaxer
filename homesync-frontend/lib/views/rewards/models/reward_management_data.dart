import 'package:flutter/material.dart';

/// Sarah reward management (Figma node 62:6235) data layer.
///
/// STRUCTURE below is exact from Figma (section order, sizes, positions,
/// icon names). TEXT, COLORS, and FONTS were NOT retrievable
/// (Figma rate limit), so EVERY string here is a TODO placeholder —
/// clearly labelled, in this ONE data block only, never hard-coded in
/// the screen. Fill every TODO from Figma node 62:6235 before calling
/// a build from this prompt final.
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
  final String costLabel;
}

/// Form state for the creation card. ALL display strings are TODO
/// placeholders from [kRewardManagementData].
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

/// ONE data block for the whole screen. Every string is
/// [TEXT NOT RETRIEVED] unless noted otherwise.
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
    required this.helperText,
    required this.field3Label,
    required this.field3Value,
    required this.primaryActionLabel,
    required this.existingHeading,
    required this.statusPillLabel,
    required this.perks,
    required this.editLabel,
    required this.navLabels,
    required this.activeNavId,
  });

  final String title;

  /// 42px avatar identity mark (initial or asset name).
  final String avatarLabel;
  final String description;
  final String categoryA;
  final String categoryB;

  /// 'a' or 'b'. The SECOND segment is selected in Figma (structural
  /// fact); the category it represents is NOT retrieved.
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
  final String field2Value;
  final String helperText;
  final String field3Label;
  final String field3Value;
  final String primaryActionLabel;
  final String existingHeading;
  final String statusPillLabel;
  final List<ManagedPerk> perks;

  /// Same on all rows. Design zone is 19px wide (pattern: "Edit").
  final String editLabel;
  final List<String> navLabels;

  /// No color data was retrieved, so the active item is a TODO guess.
  final String activeNavId;
}

// TODO(figma 62:6235): fill EVERY string below from the Figma frame.
// Nothing here is design copy.
const RewardManagementData kRewardManagementData = RewardManagementData(
  // TODO(figma 62:6235): screen title.
  title: 'TODO(62:6235): screen title',
  // TODO(figma 62:6235): 42px avatar identity mark (Sarah's initial or
  // avatar asset). 'S' is a placeholder.
  avatarLabel: 'S',
  // TODO(figma 62:6235): one-line description under the title.
  description: 'TODO(62:6235): description line',
  // TODO(figma 62:6235): both category names AND which grouping they
  // represent. Do NOT assume.
  categoryA: 'TODO(62:6235): category A',
  categoryB: 'TODO(62:6235): category B',
  // Structural fact: the SECOND segment is selected.
  selectedCategoryId: 'b',
  // TODO(figma 62:6235): banner title (bold title-line shape).
  bannerTitle: 'TODO(62:6235): banner title',
  // TODO(figma 62:6235): banner body (~2-line explanation shape). Do NOT
  // copy a sibling banner's wording here.
  bannerBody: 'TODO(62:6235): banner body explaining the parent-control rule.',
  // TODO(figma 62:6235): creation heading ("create a perk" shape).
  creationHeading: 'TODO(62:6235): creation heading',
  // TODO(figma 62:6235): field 1 label + value (pattern: perk NAME).
  field1Label: 'TODO(62:6235): field 1 label',
  field1Value: 'TODO(62:6235): field 1 value',
  // TODO(figma 62:6235): cost label + value (pattern: COST points value).
  costLabel: 'TODO(62:6235): cost label',
  costValue: 'TODO(62:6235): cost value',
  // TODO(figma 62:6235): eligibility label + value (pattern:
  // ELIGIBILITY — which child/mode; chevron-down = select).
  eligibilityLabel: 'TODO(62:6235): eligibility label',
  eligibilityValue: 'TODO(62:6235): eligibility value',
  // TODO(figma 62:6235): field 2 label + value (do NOT assume which
  // field this is).
  field2Label: 'TODO(62:6235): field 2 label',
  field2Value: 'TODO(62:6235): field 2 value',
  // TODO(figma 62:6235): standalone helper text (11px mute shape).
  helperText: 'TODO(62:6235): standalone helper text.',
  // TODO(figma 62:6235): field 3 label + value.
  field3Label: 'TODO(62:6235): field 3 label',
  field3Value: 'TODO(62:6235): field 3 value',
  // TODO(figma 62:6235): primary action label (create/add verb shape).
  primaryActionLabel: 'TODO(62:6235): primary action',
  // TODO(figma 62:6235): existing-perks heading.
  existingHeading: 'TODO(62:6235): existing perks',
  // TODO(figma 62:6235): 59×25 status pill label (count/state shape).
  // Bg/text colors are pattern-only (sageLight/sageDark).
  statusPillLabel: 'TODO',
  perks: [
    ManagedPerk(
      id: 'managed-perk-1',
      // EXACT icon from Figma: moon-star.
      icon: Icons.bedtime_rounded,
      // TODO(figma 62:6235): perk name.
      name: 'TODO(62:6235): perk 1 name',
      // TODO(figma 62:6235): perk detail line.
      detail: 'TODO(62:6235): perk 1 detail',
      // TODO(figma 62:6235): cost ("<n> pts" shape only).
      costLabel: 'TODO pts',
    ),
    ManagedPerk(
      id: 'managed-perk-2',
      // EXACT icon from Figma: utensils.
      icon: Icons.restaurant_rounded,
      // TODO(figma 62:6235): perk name.
      name: 'TODO(62:6235): perk 2 name',
      // TODO(figma 62:6235): perk detail line.
      detail: 'TODO(62:6235): perk 2 detail',
      // TODO(figma 62:6235): cost ("<n> pts" shape only).
      costLabel: 'TODO pts',
    ),
    ManagedPerk(
      id: 'managed-perk-3',
      // EXACT icon from Figma: clapperboard.
      icon: Icons.movie_rounded,
      // TODO(figma 62:6235): perk name.
      name: 'TODO(62:6235): perk 3 name',
      // TODO(figma 62:6235): perk detail line.
      detail: 'TODO(62:6235): perk 3 detail',
      // TODO(figma 62:6235): cost ("<n> pts" shape only).
      costLabel: 'TODO pts',
    ),
    ManagedPerk(
      id: 'managed-perk-4',
      // EXACT icon from Figma: shopping-bag. This is the taller row:
      // the name below is long so it wraps to 2 lines like the design.
      icon: Icons.shopping_bag_rounded,
      // TODO(figma 62:6235): perk name (long — wraps to 2 lines).
      name: 'TODO(62:6235): long perk 4 name that wraps to two lines',
      // TODO(figma 62:6235): perk detail line.
      detail: 'TODO(62:6235): perk 4 detail',
      // TODO(figma 62:6235): cost ("<n> pts" shape only).
      costLabel: 'TODO pts',
    ),
  ],
  // TODO(figma 62:6235): per-row edit action label. The design zone is
  // 19px wide (pattern: the word "Edit" at ~11px).
  editLabel: 'Edit',
  // TODO(figma 62:6235): nav labels (pattern: Home/Calendar/Tasks/Family
  // to match the icons, which ARE exact).
  navLabels: ['Home', 'Calendar', 'Tasks', 'Family'],
  // TODO(figma 62:6235): NO color data was retrieved — do NOT treat this
  // as the design's active item. 'tasks' is a placeholder guess mirroring
  // the sibling parent screen (Parent Review Queue highlights Tasks).
  activeNavId: 'tasks',
);
