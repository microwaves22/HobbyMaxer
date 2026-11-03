import 'package:flutter/material.dart';

import 'models/store_section.dart';

/// Figma "09 Rewards Store" (node 5:139): SHELL — DO NOT USE AS FINAL.
///
/// The Figma specs for node 5:139 were never retrieved (Figma rate
/// limit), so this file renders only the verified HomeSync design system
/// plus explicit TODO placeholders from [kPlaceholderStoreSections],
/// [kStoreAvailablePoints], [kStoreBalanceLabel], [kStoreTitle], and
/// [kStoreSubtitle]. Re-pull node 5:139 and replace every TODO with the
/// retrieved text, sizes, colors, and data before using this screen.
///
/// Verified patterns reused from the sibling Rewards screens
/// (KidsRewardStoreScreen): screen-local tokens, Nunito fontFamily,
/// header row, balance card, reward-card grid, and bottom nav. No Figma
/// image assets exist in this repo, so Material icons stand in for
/// artwork — never emoji.
///
/// [NOT RETRIEVED] items rendered as placeholders here: screen title,
/// subtitle, avatar identity, back-button presence, balance label +
/// value, balance-card presence, every section title/pill/subtitle,
/// every reward's name/subtitle/points/preview/artwork/category,
/// affordable action labels, nav variant + active item, and any
/// custom-reward entry (deliberately NOT built).
class RewardsStoreScreen extends StatelessWidget {
  const RewardsStoreScreen({
    super.key,
    this.availablePoints = kStoreAvailablePoints,
    this.balanceLabel = kStoreBalanceLabel,
    this.title = kStoreTitle,
    this.subtitle = kStoreSubtitle,
    this.sections = kPlaceholderStoreSections,
    this.onBack,
    this.onUnlockReward,
    this.onRedeemReward,
    this.onSaveUpForReward,
    this.onNavigateHome,
    this.onNavigateRewards,
    this.onNavigateCalendar,
  });

  // Figma tokens (screen-only, sibling precedent).
  static const Color _cream = Color(0xFFFBF7EF);
  static const Color _ink = Color(0xFF2B3A2B);
  static const Color _mute = Color(0xFF7C877A);
  static const Color _sage = Color(0xFF5F7F55);
  static const Color _sageDark = Color(0xFF4A6A41);
  static const Color _sageLight = Color(0xFFE4EBDC);
  static const Color _white = Color(0xFFFFFFFF);
  static const Color _yellowLight = Color(0xFFFDF0C8);
  static const Color _gold = Color(0xFFF0B429);

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

  /// Single shared balance: drives the balance card and every
  /// reward-card action state.
  final int availablePoints;

  /// Balance-card label. TODO placeholder (see class doc).
  final String balanceLabel;

  /// Screen title + subtitle. TODO placeholders (see class doc).
  final String title;
  final String subtitle;

  /// Placeholder sections. Renders ALL rewards from this one array.
  final List<StoreSection> sections;

  // TODO(figma 5:139): confirm a back button is even present.
  final VoidCallback? onBack;

  /// Called with the reward id. Placeholders — no backend, no points.
  final ValueChanged<String>? onUnlockReward;
  final ValueChanged<String>? onRedeemReward;

  /// Called with the reward id for the "Save X more" state.
  /// Must NOT deduct points; a no-op/info handler.
  final ValueChanged<String>? onSaveUpForReward;

  final VoidCallback? onNavigateHome;

  /// Placeholder assumption: Rewards active (see class doc).
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
              _buildBalanceCard(),
              for (final section in sections) ...[
                const SizedBox(height: 16),
                _buildSectionHeading(section),
                const SizedBox(height: 16),
                _buildRewardRows(section),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // Header pattern + TODO title/subtitle/avatar (see class doc).
  Widget _buildHeading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: onBack,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: _white.withValues(alpha: 0.91),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Icon(
                  Icons.chevron_left_rounded,
                  size: 20,
                  color: _ink,
                ),
              ),
            ),
            const Expanded(
              child: Text(
                'HomeSync',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: _font,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: _sage,
                ),
              ),
            ),
            // TODO(figma 5:139): avatar identity unknown — placeholder
            // styling only.
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: _sageLight,
                border: Border.all(color: _white),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.person_rounded,
                size: 23,
                color: _sageDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          title,
          style: const TextStyle(
            fontFamily: _font,
            fontWeight: FontWeight.w800,
            fontSize: 26,
            color: _ink,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontFamily: _font,
            fontWeight: FontWeight.w500,
            fontSize: 12,
            color: _mute,
          ),
        ),
      ],
    );
  }

  // Balance-card pattern (sibling-verified layout; label + value TODO).
  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _yellowLight,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.star_rounded,
            size: 34,
            color: _gold,
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
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$availablePoints points',
                  style: const TextStyle(
                    fontFamily: _font,
                    fontWeight: FontWeight.w800,
                    fontSize: 28,
                    color: _ink,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          // TODO(figma 5:139): avatar-mark styling unknown.
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: _sageLight,
              border: Border.all(color: _white),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.person_rounded,
              size: 16,
              color: _sageDark,
            ),
          ),
        ],
      ),
    );
  }

  // Section-heading pattern: 18px title + optional pill/subtitle.
  Widget _buildSectionHeading(StoreSection section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                section.title,
                style: const TextStyle(
                  fontFamily: _font,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: _ink,
                ),
              ),
            ),
            if (section.pillLabel != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _sageLight,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  section.pillLabel!,
                  style: const TextStyle(
                    fontFamily: _font,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    color: _sageDark,
                  ),
                ),
              ),
          ],
        ),
        if (section.subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            section.subtitle!,
            style: const TextStyle(
              fontFamily: _font,
              fontWeight: FontWeight.w500,
              fontSize: 11,
              height: 1.35,
              color: _mute,
            ),
          ),
        ],
      ],
    );
  }

  // Rows of 2 equal cards (sibling-verified card pattern).
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
        color: _white.withValues(alpha: 0.79),
        border: Border.all(color: _white),
        borderRadius: BorderRadius.circular(22),
        boxShadow: _cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 72,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: reward.previewBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              reward.previewIcon,
              size: 38,
              color: _ink,
            ),
          ),
          const SizedBox(height: 7),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 55),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  reward.name,
                  style: const TextStyle(
                    fontFamily: _font,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  reward.subtitle,
                  style: const TextStyle(
                    fontFamily: _font,
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
                    color: _mute,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 7),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.star_rounded,
                size: 16,
                color: _sage,
              ),
              const SizedBox(width: 4),
              Text(
                '${reward.points} pts',
                style: const TextStyle(
                  fontFamily: _font,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: _sage,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
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
                  color: affordable ? _white : _sageDark,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // TODO(figma 5:139): nav variant + active item unknown. The kid/teen
  // 3-item nav with Rewards active is a placeholder (no custom-reward
  // entry is built on this screen).
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
