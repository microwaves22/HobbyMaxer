import 'package:flutter/material.dart';

import 'models/store_section.dart';

/// Figma "09 Rewards Store" (node 5:139): Teen Rewards, Digital view.
///
/// All values are the real design: title-only header with the points
/// pill, Digital/Real-world chips (Digital selected), the 6 real Digital
/// rewards, the Custom Reward Request card, and the 3-item nav with
/// Rewards active. Real-world items live in the sibling Real-World view
/// ([TeenRewardStoreScreen]) and are never shown here.
///
/// Locked state is computed per card: rewards costing more than the
/// balance render grayed out with a lock glyph, mirroring the
/// Real-world view. At the 0 starting balance only the 0-point reward
/// is green and redeemable.
///
/// No Figma image assets exist in this repo, so Material icons stand in
/// for artwork — never emoji. This screen makes no API calls and moves
/// no points.
class RewardsStoreScreen extends StatelessWidget {
  const RewardsStoreScreen({
    super.key,
    this.availablePoints = kStoreAvailablePoints,
    this.title = kStoreTitle,
    this.sections = kStoreSections,
    this.selectedCategory = 'Digital',
    this.onSelectCategory,
    this.onBack,
    this.onUnlockReward,
    this.onRedeemReward,
    this.onSaveUpForReward,
    this.onRequestCustomReward,
    this.onNavigateHome,
    this.onNavigateRewards,
    this.onNavigateCalendar,
  });

  // Figma tokens (screen-only, sibling precedent).
  static const Color _cream = Color(0xFFFBF7EF);
  static const Color _ink = Color(0xFF2B3A2B);
  static const Color _mute = Color(0xFF7C877A);
  static const Color _sage = Color(0xFF5F7F55);
  static const Color _sageLight = Color(0xFFE4EBDC);
  static const Color _line = Color(0xFFE8E4D8);
  static const Color _white = Color(0xFFFFFFFF);
  static const Color _lockedFill = Color(0xFFE4E8DF);

  static const String _font = 'Nunito';

  /// Card shadow: 0px 6px 18px -8px rgba(59,77,56,0.09).
  static const List<BoxShadow> _cardShadow = [
    BoxShadow(
      color: Color.fromRGBO(59, 77, 56, 0.09),
      offset: Offset(0, 6),
      blurRadius: 18,
      spreadRadius: -8,
    ),
  ];

  /// Bottom-nav top shadow.
  static const List<BoxShadow> _navShadow = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.05),
      offset: Offset(0, -3),
      blurRadius: 12,
    ),
  ];

  /// Single shared balance: drives every reward-card action state and
  /// the header points pill.
  final int availablePoints;

  /// Screen title.
  final String title;

  /// Reward sections; this view shows the Digital section's rewards.
  final List<StoreSection> sections;

  /// Selected category chip ('Digital' or 'Real-world').
  final String selectedCategory;

  /// Called with the tapped category name. The parent navigates to the
  /// Real-World view for 'Real-world'.
  final ValueChanged<String>? onSelectCategory;

  /// Kept for API compatibility; the design has no back button.
  final VoidCallback? onBack;

  /// Called with the reward id. Placeholders — no backend, no points.
  final ValueChanged<String>? onUnlockReward;
  final ValueChanged<String>? onRedeemReward;

  /// Called with the reward id for the "Save X more" state.
  /// Must NOT deduct points; a no-op/info handler.
  final ValueChanged<String>? onSaveUpForReward;

  /// Called from the "+ Request Custom Reward" button.
  final VoidCallback? onRequestCustomReward;

  final VoidCallback? onNavigateHome;

  /// Rewards is the active tab in this view.
  final VoidCallback? onNavigateRewards;
  final VoidCallback? onNavigateCalendar;

  void _onAction(StoreReward reward) {
    if (!reward.affordable(availablePoints)) {
      onSaveUpForReward?.call(reward.id);
      return;
    }
    if (reward.category == 'digital') {
      onUnlockReward?.call(reward.id);
    } else {
      onRedeemReward?.call(reward.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final section = sections.firstWhere(
      (s) => s.title == selectedCategory,
      orElse: () => sections.first,
    );
    return Scaffold(
      backgroundColor: _cream,
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
              _buildCategoryChips(),
              const SizedBox(height: 16),
              if (selectedCategory == 'Digital') ...[
                _buildRewardRows(section),
                const SizedBox(height: 16),
                _buildCustomRequestCard(),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // Title-only header: title + points pill (no back button, no avatar).
  Widget _buildHeading() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: _font,
              fontWeight: FontWeight.w800,
              fontSize: 26,
              color: _ink,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _white,
            border: Border.all(color: _line, width: 1.5),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.star_rounded,
                size: 16,
                color: _sage,
              ),
              const SizedBox(width: 4),
              Text(
                '$availablePoints pts',
                style: const TextStyle(
                  fontFamily: _font,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: _ink,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChips() {
    return Row(
      children: [
        for (final category in kStoreCategories) ...[
          if (category != kStoreCategories.first)
            const SizedBox(width: 8),
          _buildChip(
            label: category,
            selected: category == selectedCategory,
          ),
        ],
      ],
    );
  }

  Widget _buildChip({required String label, required bool selected}) {
    return GestureDetector(
      onTap: onSelectCategory == null
          ? null
          : () => onSelectCategory!(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? _sage : _white,
          borderRadius: BorderRadius.circular(999),
          border: selected ? null : Border.all(color: _line),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: _font,
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: selected ? _white : _ink,
          ),
        ),
      ),
    );
  }

  // Rows of 2 equal cards.
  Widget _buildRewardRows(StoreSection section) {
    final rewards = section.rewards;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < rewards.length; i += 2) ...[
          if (i > 0) const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildRewardCard(rewards[i])),
              const SizedBox(width: 12),
              Expanded(
                child: i + 1 < rewards.length
                    ? _buildRewardCard(rewards[i + 1])
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildRewardCard(StoreReward reward) {
    final affordable = reward.affordable(availablePoints);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: affordable ? _white : _lockedFill,
        border: Border.all(color: _line),
        borderRadius: BorderRadius.circular(20),
        boxShadow: _cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 76,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: affordable ? reward.previewBackground : _white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              affordable ? reward.previewIcon : Icons.lock_outline_rounded,
              size: 38,
              color: affordable ? _ink : _mute,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            reward.name,
            style: TextStyle(
              fontFamily: _font,
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: affordable ? _ink : _mute,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.star_rounded,
                size: 13,
                color: affordable ? _sage : _mute,
              ),
              const SizedBox(width: 4),
              Text(
                '${reward.points} pts',
                style: TextStyle(
                  fontFamily: _font,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: affordable ? _sage : _mute,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _onAction(reward),
            child: Container(
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: affordable ? _sage : _sageLight,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Text(
                reward.actionLabel(availablePoints),
                style: TextStyle(
                  fontFamily: _font,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  color: affordable ? _white : _ink,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomRequestCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _white,
        border: Border.all(color: _line),
        borderRadius: BorderRadius.circular(20),
        boxShadow: _cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Have a perk in mind?',
            style: TextStyle(
              fontFamily: _font,
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: _ink,
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: onRequestCustomReward,
            child: Container(
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _sage,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                '+ Request Custom Reward',
                style: TextStyle(
                  fontFamily: _font,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: _white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Examples: Stay up 30 mins late, Go to trampoline park, '
            'Extra screen time.',
            style: TextStyle(
              fontFamily: _font,
              fontWeight: FontWeight.w500,
              fontSize: 11,
              height: 1.35,
              color: _mute,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.only(
        top: 12,
        left: 20,
        right: 20,
        bottom: 10,
      ),
      decoration: const BoxDecoration(
        color: _white,
        boxShadow: _navShadow,
      ),
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
                onTap: onNavigateHome,
              ),
              _buildTab(
                label: 'Rewards',
                icon: Icons.card_giftcard_rounded,
                active: true,
                onTap: onNavigateRewards,
              ),
              _buildTab(
                label: 'Calendar',
                icon: Icons.calendar_month_rounded,
                active: false,
                onTap: onNavigateCalendar,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: 116,
            height: 4,
            decoration: BoxDecoration(
              color: _ink,
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
              color: active ? _sage : _mute,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: _font,
                fontWeight:
                    active ? FontWeight.w800 : FontWeight.w600,
                fontSize: 11,
                color: active ? _sage : _mute,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
