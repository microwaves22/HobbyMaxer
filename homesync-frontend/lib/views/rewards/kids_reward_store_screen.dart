import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/widgets/profile_avatar_dropdown.dart';
import 'models/kids_store_reward.dart';

/// Figma "Kids Reward Store" (node 100:4854): Ava's reward store.
///
/// Figma tokens are hard-coded here because they differ from the shared
/// theme (`AppColors` cream/sage/ink predate this design) — same
/// screen-local-tokens precedent as ParentHomeScreen. `LiquidGlassCard`
/// is not reused because its fixed values (0.65 alpha, different shadow)
/// differ from this design's exact card spec (white 0.79, card shadow).
///
/// All content is local mock data ([kAvaAvailablePoints],
/// [kKidsStoreRewards]). Every handler is an optional placeholder
/// callback — this screen makes no API calls, deducts no points, and
/// builds no other screens.
class KidsRewardStoreScreen extends StatelessWidget {
  const KidsRewardStoreScreen({
    super.key,
    this.availablePoints = kAvaAvailablePoints,
    this.rewards = kKidsStoreRewards,
    this.onBack,
    this.onRequestCustomReward,
    this.onUnlockReward,
    this.onRedeemReward,
    this.onSaveUpForReward,
    this.onNavigateHome,
    this.onNavigateRewards,
    this.onNavigateCalendar,
    this.activeProfile = const ProfileOption(
      name: 'Ava',
      roleLabel: 'Kids Mode',
    ),
    this.profiles = const [],
    this.parentPin = '1234',
    this.onSwitchProfile,
    this.onAccountSettings,
    this.onManageFamily,
  });

  // Figma tokens (screen-only, see class doc).
  static const Color _cream = Color(0xFFF9F8F6);
  static const Color _ink = Color(0xFF2B3A2B);
  static const Color _mute = Color(0xFF7C877A);
  static const Color _sage = Color(0xFF7A9A85);
  static const Color _sageDark = Color(0xFF4A6A41);
  static const Color _sageLight = Color(0xFFE4EBDC);
  static const Color _white = Color(0xFFFFFFFF);
  static const Color _yellowLight = Color(0xFFFDF0C8);
  static const Color _pink = Color(0xFFF4C9C9);
  static const Color _gold = Color(0xFFF0B429);

  static const String _font = 'Nunito';

  /// Card shadow: 0px 3px 12px rgba(51,64,38,0.08).
  static const List<BoxShadow> _cardShadow = [
    BoxShadow(
      color: Color(0x14334026),
      offset: Offset(0, 3),
      blurRadius: 12,
    ),
  ];

  /// Single shared balance: drives the balance card, every reward-card
  /// action state, and the footer note.
  final int availablePoints;

  /// Mock catalog; both rows render by filtering on category.
  final List<KidsStoreReward> rewards;

  final VoidCallback? onBack;
  final VoidCallback? onRequestCustomReward;

  /// Called with the reward id. Digital unlock — spends nothing here.
  final ValueChanged<String>? onUnlockReward;

  /// Called with the reward id. Family redeem — spends nothing here.
  final ValueChanged<String>? onRedeemReward;

  /// Called with the reward id for the "Save X more" state.
  /// Must NOT deduct points; a no-op/info handler.
  final ValueChanged<String>? onSaveUpForReward;

  final VoidCallback? onNavigateHome;

  /// Current screen — already selected.
  final VoidCallback? onNavigateRewards;
  final VoidCallback? onNavigateCalendar;

  /// Active household profile for the header menu. Defaults to the mock
  /// kids profile; hosts pass the real roster to enable switching.
  final ProfileOption activeProfile;

  /// Other household profiles offered in the header menu.
  final List<ProfileOption> profiles;

  /// Parent PIN guarding switches to parent profiles from this menu.
  final String parentPin;

  final ValueChanged<ProfileOption>? onSwitchProfile;
  final VoidCallback? onAccountSettings;
  final VoidCallback? onManageFamily;

  List<KidsStoreReward> _of(KidsRewardCategory category) =>
      rewards.where((r) => r.category == category).toList();

  void _onAction(KidsStoreReward reward) {
    if (!reward.affordable(availablePoints)) {
      onSaveUpForReward?.call(reward.id);
      return;
    }
    if (reward.category == KidsRewardCategory.digital) {
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
              const SizedBox(height: 16),
              _buildCustomRewardCard(),
              const SizedBox(height: 16),
              _buildDigitalHeading(),
              const SizedBox(height: 16),
              _buildRewardRow(_of(KidsRewardCategory.digital)),
              const SizedBox(height: 16),
              _buildFamilyHeading(),
              const SizedBox(height: 16),
              _buildRewardRow(_of(KidsRewardCategory.family)),
              const SizedBox(height: 16),
              _buildFooterNote(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // SECTION 1 — Page heading: header row + title block.
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
            ProfileAvatarDropdown(
              active: activeProfile,
              profiles: profiles,
              parentPin: parentPin,
              onSwitchProfile: onSwitchProfile,
              onAccountSettings: onAccountSettings,
              onManageFamily: onManageFamily,
              buttonChild: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _pink,
                  border: Border.all(color: _white),
                  borderRadius: BorderRadius.circular(22),
                ),
                alignment: Alignment.center,
                clipBehavior: Clip.antiAlias,
                child: const Icon(
                  Icons.pets_rounded,
                  size: 23,
                  color: _sageDark,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Reward Store',
              style: TextStyle(
                fontFamily: _font,
                fontWeight: FontWeight.w800,
                fontSize: 26,
                color: _ink,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Ava\u2019s little world of rewards',
              style: TextStyle(
                fontFamily: _font,
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: _mute,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // SECTION 2 — Points balance card.
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
                const Text(
                  'Ava\u2019s available points',
                  style: TextStyle(
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
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _pink,
              border: Border.all(color: _white),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            clipBehavior: Clip.antiAlias,
            child: const Icon(
              Icons.pets_rounded,
              size: 16,
              color: _sageDark,
            ),
          ),
        ],
      ),
    );
  }

  // SECTION 3 — Custom-reward card.
  Widget _buildCustomRewardCard() {
    const radius = BorderRadius.all(Radius.circular(22));
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _white.withValues(alpha: 0.79),
            border: Border.all(color: _white),
            borderRadius: radius,
            boxShadow: _cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Dreaming of something else?',
                style: TextStyle(
                  fontFamily: _font,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Ask Sarah for a perk not in the store. '
                'Asking doesn\u2019t spend any points.',
                style: TextStyle(
                  fontFamily: _font,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: _mute,
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: onRequestCustomReward,
                child: Container(
                  height: 54,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _sage,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    '+ Request Custom Reward',
                    style: TextStyle(
                      fontFamily: _font,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: _white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // SECTION 4 — Digital section heading + pill.
  Widget _buildDigitalHeading() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(
          child: Text(
            'Unicorn treasures',
            style: TextStyle(
              fontFamily: _font,
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: _ink,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: _sageLight,
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Text(
            'Digital',
            style: TextStyle(
              fontFamily: _font,
              fontWeight: FontWeight.w800,
              fontSize: 11,
              color: _sageDark,
            ),
          ),
        ),
      ],
    );
  }

  // SECTIONS 5 & 7 — Reward rows (two equal cards, 12px gap).
  Widget _buildRewardRow(List<KidsStoreReward> row) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < row.length; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          Expanded(child: _buildRewardCard(row[i])),
        ],
      ],
    );
  }

  Widget _buildRewardCard(KidsStoreReward reward) {
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

  // SECTION 6 — Family treats heading + subtitle.
  Widget _buildFamilyHeading() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Family treats',
          style: TextStyle(
            fontFamily: _font,
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: _ink,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Approved by Sarah \u00B7 She confirms when to enjoy them.',
          style: TextStyle(
            fontFamily: _font,
            fontWeight: FontWeight.w500,
            fontSize: 11,
            color: _mute,
          ),
        ),
      ],
    );
  }

  // SECTION 8 — Footer note (shares [availablePoints]).
  Widget _buildFooterNote() {
    return Text(
      'Save up for bigger treats! '
      'Your $availablePoints points stay safe until you redeem a reward.',
      style: const TextStyle(
        fontFamily: _font,
        fontWeight: FontWeight.w500,
        fontSize: 11,
        color: _mute,
      ),
    );
  }

  // Bottom navigation: exactly Home / Rewards (active) / Calendar.
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
                fontWeight: active ? FontWeight.w800 : FontWeight.w600,
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
