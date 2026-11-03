import 'package:flutter/material.dart';

import 'models/teen_store_reward.dart';

/// Figma "Teen real-world reward store" (node 62:6146): SHELL — DO NOT
/// USE AS FINAL.
///
/// The Figma specs for node 62:6146 were never retrieved (Figma rate
/// limit), so this file renders only the verified HomeSync design system,
/// the verified teen patterns from Request Custom Reward (node 100:4945),
/// and the verified real-world card patterns from Kids Reward Store
/// (node 100:4854), plus explicit TODO placeholders from
/// [kTeenStoreRewards], [kTeenStoreAvailablePoints], and the other mock
/// values in `models/teen_store_reward.dart`. Re-pull node 62:6146 and
/// replace every TODO before calling this final.
///
/// [NOT RETRIEVED] items rendered as placeholders here: screen title,
/// subtitle, avatar identity (teen initial), background (cream #FBF7EF
/// is the store-pattern placeholder — the sibling teen form uses
/// #F4F3EF), balance label + value, section heading/subtitle, every
/// reward's name/subtitle/points/preview/artwork, nav confirmation
/// (3-item teen nav with Rewards active is the patterned default), and
/// the custom-reward entry (deliberately NOT built; no
/// [onRequestCustomReward]-style handler is wired because this project's
/// navigation does not expect one).
///
/// This is the REAL-WORLD store: no digital/unicorn-style rewards or
/// sections. Redeeming moves no points and books/purchases nothing.
class TeenRewardStoreScreen extends StatelessWidget {
  const TeenRewardStoreScreen({
    super.key,
    this.teenName = kTeenStoreName,
    this.title = kTeenStoreTitle,
    this.subtitle,
    this.availablePoints = kTeenStoreAvailablePoints,
    this.balanceLabel = kTeenStoreBalanceLabel,
    this.sectionTitle = kTeenStoreSectionTitle,
    this.sectionSubtitle = kTeenStoreSectionSubtitle,
    this.rewards = kTeenStoreRewards,
    this.onBack,
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

  /// Teen name driving the avatar initial + subtitle. TODO (see class doc).
  final String teenName;

  /// Screen title. TODO placeholder (see class doc).
  final String title;

  /// Screen subtitle. Defaults to the `"Name" · 14 · Teen Mode` shape.
  final String? subtitle;

  /// Single shared balance: drives the balance card and every
  /// reward-card action state.
  final int availablePoints;

  /// Balance-card label. TODO placeholder (see class doc).
  final String balanceLabel;

  /// Section heading + subtitle. TODO placeholders (see class doc).
  final String sectionTitle;
  final String sectionSubtitle;

  /// Placeholder rewards. Renders ALL rewards from this one array.
  final List<TeenStoreReward> rewards;

  final VoidCallback? onBack;

  /// Called with the reward id. Placeholders — no backend, no points.
  final ValueChanged<String>? onRedeemReward;

  /// Called with the reward id for the "Save X more" state.
  /// Must NOT deduct points; a no-op/info handler.
  final ValueChanged<String>? onSaveUpForReward;

  final VoidCallback? onNavigateHome;

  /// Patterned default — unconfirmed (see class doc).
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
    // TODO(figma 62:6146): background unconfirmed — cream is the
    // store-screen-pattern placeholder (the sibling teen form uses
    // #F4F3EF).
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
              const SizedBox(height: 16),
              _buildSectionHeading(),
              const SizedBox(height: 16),
              _buildRewardRows(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // Teen header pattern (sibling-verified layout; texts TODO).
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
            // Teen avatar pattern: sageLight circle + initial.
            // TODO(figma 62:6146): the initial/identity is unconfirmed.
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _sageLight,
                border: Border.all(color: _white),
                borderRadius: BorderRadius.circular(22),
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
          subtitle ?? '$teenName \u00B7 14 \u00B7 Teen Mode',
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
          // TODO(figma 62:6146): avatar-mark styling unknown — mirrors
          // the header avatar as a placeholder.
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
            child: Text(
              teenName.characters.first,
              style: const TextStyle(
                fontFamily: _font,
                fontWeight: FontWeight.w800,
                fontSize: 12,
                color: _sageDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Real-world section heading pattern (texts TODO).
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
            fontSize: 11,
            height: 1.35,
            color: _mute,
          ),
        ),
      ],
    );
  }

  // Rows of 2 equal real-world cards (sibling-verified card pattern).
  Widget _buildRewardRows() {
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

  Widget _buildRewardCard(TeenStoreReward reward) {
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

  // 3-item teen nav, Rewards active: strongly-patterned default from
  // both teen/kid siblings, but UNCONFIRMED for this screen (see class
  // doc). No custom-reward entry is built here.
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
