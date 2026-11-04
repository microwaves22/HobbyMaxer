/// Request Custom Reward (Figma node 100:4945) form + mock data.
///
/// MOCK DATA — the design's values only. This screen makes no API calls,
/// deducts no points; submit pops back to the store with confirmation.
class CustomRewardFormState {
  const CustomRewardFormState({
    required this.requestedPerk,
    required this.proposedCost,
    required this.note,
  });

  final String requestedPerk;

  /// Proposed cost in points, stored as a number.
  /// Display appends the " points" suffix.
  final int proposedCost;
  final String note;
}

/// MOCK: who the request is sent to (design value).
const String kCustomRewardRecipient = 'Sarah';

/// MOCK: Noah's available balance. Single source of truth shared by the
/// recipient pill, the safeguard card, and the status note.
const int kNoahAvailablePoints = 120;

/// MOCK: the design's pre-filled form values (not placeholders).
const CustomRewardFormState kInitialCustomRewardForm = CustomRewardFormState(
  requestedPerk: 'Go to trampoline park',
  proposedCost: 200,
  note: 'Could we go this weekend? I am happy to save up.',
);
