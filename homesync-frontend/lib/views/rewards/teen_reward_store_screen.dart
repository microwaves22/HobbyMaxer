import 'package:flutter/material.dart';

import 'models/teen_store_reward.dart';

/// Figma "Teen real-world reward store" (node 62:6146).
///
/// All values are the real design: #F4F3EF background, sageLight balance
/// card, Digital/Real-world segmented control (Real-world selected),
/// the 4 real perks, the custom-request bar, the verbatim footer, and
/// the 3-item nav with Rewards active.
///
/// This is the REAL-WORLD store: no digital rewards or sections.
/// Redeeming moves no points and books/purchases nothing.
class TeenRewardStoreScreen extends StatelessWidget {
  const TeenRewardStoreScreen({
    super.key,
    this.teenName = kTeenStoreName,
    this.title = kTeenStoreTitle,
    this.availablePoints = kTeenStoreAvailablePoints,
    this.balanceLabel = kTeenStoreBalanceLabel,
    this.sectionTitle = kTeenStoreSectionTitle,
    this.sectionSubtitle = kTeenStoreSectionSubtitle,
    this.rewards = kTeenStoreRewards,
    this.selectedCategory = 'Real-world',
    this.onSelectCategory,
    this.onBack,
    this.onRedeemReward,
    this.onSaveUpForReward,
    this.onRequestCustomReward,
    this.onNavigateHome,
    this.onNavigateRewards,
    this.onNavigateCalendar,
  });

  // Figma tokens (screen-only, sibling precedent).
  static const Color _bg = Color(0xFFF4F3EF);
  static const Color _ink = Color(0xFF2B3A2B);
  static const Color _mute = Color(0xFF7C877A);
  static const Color _sage = Color(0xFF5F7F55);
  static const Color _sageDark = Color(0xFF4A6A41);
  static const Color _sageLight = Color(0xFFE4EBDC);
  static const Color _segmentTrack = Color(0xFFE9EAE3);
  static const Color _lockedFill = Color(0xFFE4E8DF);
  static const Color _cardFill = Color.fromRGBO(255, 255, 255, 0.72);
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

  /// Teen name driving the avatar initial.
  final String teenName;

  /// Screen title.
  final String title;

  /// Single shared balance: drives the balance card and every
  /// reward-card action state.
  final int availablePoints;

  /// Balance-card eyebrow.
  final String balanceLabel;

  /// Section heading + subline.
  final String sectionTitle;
  final String sectionSubtitle;

  /// The 4 real perks. Renders ALL rewards from this one array.
  final List<TeenStoreReward> rewards;

  /// Selected category segment ('Digital' or 'Real-world').
  final String selectedCategory;

  /// Called with the tapped category name. The parent navigates to the
  /// Digital view for 'Digital'.
  final ValueChanged<String>? onSelectCategory;

  /// Kept for API compatibility; the design has no back button.
  final VoidCallback? onBack;

  /// Called with the reward id. Placeholders — no backend, no points.
  final ValueChanged<String>? onRedeemReward;

  /// Called with the reward id for the "Save X more" state.
  /// Must NOT deduct points; a no-op/info handler.
  final ValueChanged<String>? onSaveUpForReward;

  /// Called from the "+ Request Custom Reward" bar.
  final VoidCallback? onRequestCustomReward;

  final VoidCallback? onNavigateHome;

  /// Rewards is the active tab in this view.
  final VoidCallback? onNavigateRewards;
  final VoidCallback? onNavigateCalendar;

  void _onAction(TeenStoreReward reward) {
    if (!reward.affordable(availablePoints)) {
      onSaveUpForReward?.call(reward.id);
      return;
    }
    onRedeemReward?.call(reward.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
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
              _buildBalanceCard(),
              const SizedBox(height: 16),
              _buildCategories(),
              if (selectedCategory == 'Real-world') ...[
                const SizedBox(height: 16),
                _buildSectionHeading(),
                const SizedBox(height: 12),
                _buildCustomRequestBar(),
                const SizedBox(height: 12),
                _buildPerkList(),
                const SizedBox(height: 12),
                const Text(
                  kTeenStoreFooter,
                  style: TextStyle(
                    fontFamily: _font,
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                    height: 1.35,
                    color: _mute,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

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
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _sageLight,
            border: Border.all(color: _white),
            borderRadius: BorderRadius.circular(21),
          ),
          child: Text(
            teenName.characters.first,
            style: const TextStyle(
              fontFamily: _font,
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: _sageDark,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _sageLight,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.auto_awesome,
            size: 28,
            color: _sage,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  balanceLabel,
                  style: const TextStyle(
                    fontFamily: _font,
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                    color: _sage,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$availablePoints points',
                  style: const TextStyle(
                    fontFamily: _font,
                    fontWeight: FontWeight.w800,
                    fontSize: 25,
                    color: _ink,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: _white,
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'Earned, not bought',
              style: TextStyle(
                fontFamily: _font,
                fontWeight: FontWeight.w800,
                fontSize: 11,
                color: _sage,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _segmentTrack,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          for (final category in kTeenStoreCategories)
            Expanded(
              child: _buildSegment(
                label: category,
                selected: category == selectedCategory,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSegment({required String label, required bool selected}) {
    return GestureDetector(
      onTap: onSelectCategory == null
          ? null
          : () => onSelectCategory!(label),
      child: Container(
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? _white : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: _font,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
            fontSize: 13,
            color: selected ? _sage : _mute,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          sectionTitle,
          style: const TextStyle(
            fontFamily: _font,
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: _ink,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          sectionSubtitle,
          style: const TextStyle(
            fontFamily: _font,
            fontWeight: FontWeight.w500,
            fontSize: 12,
            height: 1.35,
            color: _mute,
          ),
        ),
      ],
    );
  }

  Widget _buildCustomRequestBar() {
    return GestureDetector(
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
    );
  }

  Widget _buildPerkList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < rewards.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          _buildPerkCard(rewards[i]),
        ],
      ],
    );
  }

  Widget _buildPerkCard(TeenStoreReward reward) {
    final affordable = reward.affordable(availablePoints);
    final titleColor = affordable ? _ink : _mute;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: affordable ? _cardFill : _lockedFill,
        borderRadius: BorderRadius.circular(22),
        boxShadow: _cardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: affordable
                  ? reward.previewBackground
                  : _white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              affordable ? reward.previewIcon : Icons.lock_outline_rounded,
              size: 24,
              color: affordable ? _ink : _mute,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  reward.name,
                  style: TextStyle(
                    fontFamily: _font,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: titleColor,
                  ),
                ),
                if (reward.subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    reward.subtitle,
                    style: const TextStyle(
                      fontFamily: _font,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: _mute,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  '★ ${reward.points} pts',
                  style: TextStyle(
                    fontFamily: _font,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: affordable ? _sage : _mute,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _onAction(reward),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
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

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.only(
        top: 12,
        left: 20,
        right: 20,
        bottom: 10,
      ),
      color: _white.withValues(alpha: 0.91),
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
