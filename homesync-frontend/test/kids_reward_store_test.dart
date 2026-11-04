import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:homesync/core/widgets/profile_avatar_dropdown.dart';
import 'package:homesync/views/rewards/kids_reward_store_screen.dart';
import 'package:homesync/views/rewards/models/kids_store_reward.dart';

Future<void> _pumpStore(
  WidgetTester tester, {
  int availablePoints = kAvaAvailablePoints,
  List<KidsStoreReward> rewards = kKidsStoreRewards,
  VoidCallback? onBack,
  VoidCallback? onRequestCustomReward,
  ValueChanged<String>? onUnlockReward,
  ValueChanged<String>? onRedeemReward,
  ValueChanged<String>? onSaveUpForReward,
  VoidCallback? onNavigateHome,
  VoidCallback? onNavigateRewards,
  VoidCallback? onNavigateCalendar,
  ProfileOption activeProfile = const ProfileOption(
    name: 'Ava',
    roleLabel: 'Kids Mode',
  ),
  List<ProfileOption> profiles = const [],
  String parentPin = '1234',
  ValueChanged<ProfileOption>? onSwitchProfile,
  VoidCallback? onAccountSettings,
  VoidCallback? onManageFamily,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: KidsRewardStoreScreen(
        availablePoints: availablePoints,
        rewards: rewards,
        onBack: onBack,
        onRequestCustomReward: onRequestCustomReward,
        onUnlockReward: onUnlockReward,
        onRedeemReward: onRedeemReward,
        onSaveUpForReward: onSaveUpForReward,
        onNavigateHome: onNavigateHome,
        onNavigateRewards: onNavigateRewards,
        onNavigateCalendar: onNavigateCalendar,
        activeProfile: activeProfile,
        profiles: profiles,
        parentPin: parentPin,
        onSwitchProfile: onSwitchProfile,
        onAccountSettings: onAccountSettings,
        onManageFamily: onManageFamily,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('Kids Reward Store (node 100:4854)', () {
    testWidgets('header, balance card, and footer share one balance value',
        (tester) async {
      await _pumpStore(tester);

      expect(find.text('HomeSync'), findsOneWidget);
      expect(find.text('Reward Store'), findsOneWidget);
      expect(find.text('Ava\u2019s little world of rewards'), findsOneWidget);
      expect(find.text('Ava\u2019s available points'), findsOneWidget);
      expect(find.text('120 points'), findsOneWidget);
      expect(
        find.text(
          'Save up for bigger treats! '
          'Your 120 points stay safe until you redeem a reward.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders all 4 rewards from the data array', (tester) async {
      await _pumpStore(tester);

      for (final reward in kKidsStoreRewards) {
        expect(find.text(reward.name), findsOneWidget);
        expect(find.text(reward.subtitle), findsAtLeastNWidgets(1));
        expect(find.text('${reward.points} pts'), findsOneWidget);
      }
      expect(find.text('50 pts'), findsOneWidget);
      expect(find.text('100 pts'), findsOneWidget);
      expect(find.text('120 pts'), findsOneWidget);
      expect(find.text('150 pts'), findsOneWidget);
    });

    testWidgets('action labels: Unlock / Unlock / Redeem / Save 30 more',
        (tester) async {
      await _pumpStore(tester);

      expect(find.text('Unlock'), findsNWidgets(2));
      expect(find.text('Redeem'), findsOneWidget);
      expect(find.text('Save 30 more'), findsOneWidget);
    });

    testWidgets('unaffordable label is computed from points minus balance',
        (tester) async {
      await _pumpStore(tester, availablePoints: 40);

      // 50 - 40 = 10, 100 - 40 = 60, 120 - 40 = 80, 150 - 40 = 110.
      expect(find.text('Save 10 more'), findsOneWidget);
      expect(find.text('Save 60 more'), findsOneWidget);
      expect(find.text('Save 80 more'), findsOneWidget);
      expect(find.text('Save 110 more'), findsOneWidget);
      expect(find.text('Unlock'), findsNothing);
      expect(find.text('Redeem'), findsNothing);
      expect(find.text('40 points'), findsOneWidget);
    });

    testWidgets('custom-reward card copy and button match verbatim',
        (tester) async {
      await _pumpStore(tester);

      expect(find.text('Dreaming of something else?'), findsOneWidget);
      expect(
        find.text(
          'Ask Sarah for a perk not in the store. '
          'Asking doesn\u2019t spend any points.',
        ),
        findsOneWidget,
      );
      expect(find.text('+ Request Custom Reward'), findsOneWidget);
    });

    testWidgets('section headings match verbatim', (tester) async {
      await _pumpStore(tester);

      expect(find.text('Unicorn treasures'), findsOneWidget);
      expect(find.text('Digital'), findsOneWidget);
      expect(find.text('Family treats'), findsOneWidget);
      expect(
        find.text('Approved by Sarah \u00B7 She confirms when to enjoy them.'),
        findsOneWidget,
      );
    });

    testWidgets('bottom nav has exactly Home / Rewards / Calendar',
        (tester) async {
      await _pumpStore(tester);

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Rewards'), findsOneWidget);
      expect(find.text('Calendar'), findsOneWidget);
      expect(find.text('Tasks'), findsNothing);
      expect(find.text('Family'), findsNothing);

      final rewardsLabel =
          tester.widget<Text>(find.text('Rewards')).style!;
      expect(rewardsLabel.color, const Color(0xFF7A9A85));
      expect(rewardsLabel.fontWeight, FontWeight.w800);
      final homeLabel = tester.widget<Text>(find.text('Home')).style!;
      expect(homeLabel.color, const Color(0xFF7C877A));
      expect(homeLabel.fontWeight, FontWeight.w600);
    });

    testWidgets('handlers fire with the tapped reward id', (tester) async {
      String? unlocked;
      String? redeemed;
      String? savedUp;
      var customRequested = false;
      var navigatedHome = false;
      var navigatedCalendar = false;

      await _pumpStore(
        tester,
        onUnlockReward: (id) => unlocked = id,
        onRedeemReward: (id) => redeemed = id,
        onSaveUpForReward: (id) => savedUp = id,
        onRequestCustomReward: () => customRequested = true,
        onNavigateHome: () => navigatedHome = true,
        onNavigateCalendar: () => navigatedCalendar = true,
      );

      await tester.ensureVisible(find.text('Unlock').first);
      await tester.tap(find.text('Unlock').first);
      await tester.pumpAndSettle();
      expect(unlocked, 'rainbow-mane');

      await tester.ensureVisible(find.text('Redeem'));
      await tester.tap(find.text('Redeem'));
      await tester.pumpAndSettle();
      expect(redeemed, 'friday-dinner');

      // "Save 30 more" is a no-op/info handler: it reports the id but
      // the balance stays untouched.
      await tester.ensureVisible(find.text('Save 30 more'));
      await tester.tap(find.text('Save 30 more'));
      await tester.pumpAndSettle();
      expect(savedUp, 'family-movie');
      expect(find.text('120 points'), findsOneWidget);

      await tester.ensureVisible(find.text('+ Request Custom Reward'));
      await tester.tap(find.text('+ Request Custom Reward'));
      await tester.pumpAndSettle();
      expect(customRequested, isTrue);

      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(navigatedHome, isTrue);

      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle();
      expect(navigatedCalendar, isTrue);
    });

    testWidgets('back button fires onBack', (tester) async {
      var wentBack = false;
      await _pumpStore(tester, onBack: () => wentBack = true);

      await tester.tap(find.byIcon(Icons.chevron_left_rounded));
      await tester.pumpAndSettle();
      expect(wentBack, isTrue);
    });

    testWidgets('header avatar opens the standard profile menu',
        (tester) async {
      ProfileOption? switched;
      var settingsOpened = false;
      var familyOpened = false;
      await _pumpStore(
        tester,
        activeProfile: const ProfileOption(
          name: 'Ava',
          roleLabel: 'Kids Mode',
        ),
        profiles: const [
          ProfileOption(name: 'Ava', roleLabel: 'Kids Mode'),
          ProfileOption(name: 'Noah', roleLabel: 'Teen Mode'),
          ProfileOption(
            name: 'Sarah',
            roleLabel: 'Parent',
            isParent: true,
          ),
        ],
        onSwitchProfile: (profile) => switched = profile,
        onAccountSettings: () => settingsOpened = true,
        onManageFamily: () => familyOpened = true,
      );

      await tester.tap(find.byTooltip('Profile'));
      await tester.pumpAndSettle();

      expect(find.text('Ava'), findsOneWidget);
      expect(find.text('Noah'), findsOneWidget);
      expect(find.text('Sarah'), findsOneWidget);
      expect(find.text('Manage family'), findsOneWidget);
      expect(find.text('Account settings'), findsOneWidget);

      await tester.tap(find.text('Noah'));
      await tester.pumpAndSettle();
      expect(switched?.name, 'Noah');

      await tester.tap(find.byTooltip('Profile'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Account settings'));
      await tester.pumpAndSettle();
      expect(settingsOpened, isTrue);

      await tester.tap(find.byTooltip('Profile'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Manage family'));
      await tester.pumpAndSettle();
      expect(familyOpened, isTrue);
    });

    testWidgets('header menu opens with the default mock profile',
        (tester) async {
      await _pumpStore(tester);

      await tester.tap(find.byTooltip('Profile'));
      await tester.pumpAndSettle();

      expect(find.text('Ava'), findsOneWidget);
      expect(find.text('Manage family'), findsOneWidget);
      expect(find.text('Account settings'), findsOneWidget);
    });

  });
}
