import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:homesync/core/state/focus_areas.dart';
import 'package:homesync/views/home/home_screen.dart';
import 'package:homesync/views/onboarding/models/user_profile.dart';
import 'package:homesync/views/rewards/kids_reward_store_screen.dart';
import 'package:homesync/views/rewards/rewards_screen.dart';

UserProfile _kids() => UserProfile(
      name: 'Ava',
      birthday: DateTime(2018, 5, 2),
      role: FamilyRole.child,
      mode: FamilyMode.kids,
    );

UserProfile _teen() => UserProfile(
      name: 'Noah',
      birthday: DateTime(2012, 9, 14),
      role: FamilyRole.child,
      mode: FamilyMode.teen,
    );

Future<void> _pumpHome(WidgetTester tester, UserProfile profile) async {
  await tester.pumpWidget(
    MaterialApp(
      home: FocusAreasScope(
        controller: FocusAreasController(FocusAreas.all),
        child: HomeScreen(profile: profile),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _openRewards(WidgetTester tester) async {
  final rewards = find.text('Task rewards');
  await tester.ensureVisible(rewards);
  await tester.tap(rewards);
  await tester.pumpAndSettle();
}

void main() {
  group('Reward store entry point', () {
    testWidgets('kids profiles open the Kids Reward Store', (tester) async {
      await _pumpHome(tester, _kids());
      await _openRewards(tester);

      expect(find.byType(KidsRewardStoreScreen), findsOneWidget);
      expect(find.byType(RewardsScreen), findsNothing);
      expect(find.text('Reward Store'), findsOneWidget);
    });

    testWidgets('back button returns kids to the dashboard', (tester) async {
      await _pumpHome(tester, _kids());
      await _openRewards(tester);

      await tester.tap(find.byIcon(Icons.chevron_left_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Hello, Ava!'), findsOneWidget);
      expect(find.byType(KidsRewardStoreScreen), findsNothing);
    });

    testWidgets('bottom-nav Home returns kids to the dashboard',
        (tester) async {
      await _pumpHome(tester, _kids());
      await _openRewards(tester);

      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      expect(find.text('Hello, Ava!'), findsOneWidget);
      expect(find.byType(KidsRewardStoreScreen), findsNothing);
    });

    testWidgets('teen profiles keep the existing Rewards screen',
        (tester) async {
      await _pumpHome(tester, _teen());
      await _openRewards(tester);

      expect(find.byType(RewardsScreen), findsOneWidget);
      expect(find.byType(KidsRewardStoreScreen), findsNothing);
    });
  });
}
