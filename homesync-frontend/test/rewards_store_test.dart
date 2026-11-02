import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:homesync/views/onboarding/models/user_profile.dart';
import 'package:homesync/views/rewards/rewards_controller.dart';
import 'package:homesync/views/rewards/rewards_screen.dart';
import 'package:homesync/views/rewards/widgets/perk_requests_section.dart';
import 'package:homesync/views/tasks/tasks_controller.dart';

UserProfile _child() => UserProfile(
      name: 'Maya',
      birthday: DateTime(2016, 4, 23),
      role: FamilyRole.child,
      mode: FamilyMode.kids,
    );

UserProfile _parent() => UserProfile(
      name: 'Mom',
      birthday: DateTime(1990, 1, 1),
      role: FamilyRole.parent,
      mode: FamilyMode.parent,
    );

RewardsController _store({int balance = 100}) {
  return RewardsController(
    tasks: TasksController.test(balances: {'Maya': balance}),
  );
}

Future<void> _pumpStore(
  WidgetTester tester, {
  required RewardsController controller,
  required UserProfile profile,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: RewardsScreen(controller: controller, profile: profile),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('Reward store', () {
    testWidgets('shows live balance and both tabs', (tester) async {
      await _pumpStore(tester, controller: _store(), profile: _child());

      expect(find.text("Maya's balance"), findsOneWidget);
      expect(
        tester
            .widget<Text>(find.byKey(const ValueKey('balance-pts')))
            .data,
        '100 pts',
      );
      expect(find.text('Digital Rewards'), findsOneWidget);
      expect(find.text('Parent Perks'), findsOneWidget);
      expect(find.text('Pixel Avatar Pack'), findsOneWidget);
    });

    testWidgets('perks tab lists parent-managed perks', (tester) async {
      await _pumpStore(tester, controller: _store(), profile: _child());

      await tester.tap(find.text('Parent Perks'));
      await tester.pumpAndSettle();

      expect(find.text('Extra 30 min screen time'), findsOneWidget);
      expect(find.text('Pick Friday takeout'), findsOneWidget);
    });

    testWidgets('redeem deducts points and confirms', (tester) async {
      await _pumpStore(tester, controller: _store(), profile: _child());

      await tester.tap(find.text('Redeem').first);
      await tester.pumpAndSettle();

      expect(find.text('Redeemed Pixel Avatar Pack!'), findsOneWidget);
      expect(
        tester
            .widget<Text>(find.byKey(const ValueKey('balance-pts')))
            .data,
        '50 pts',
      );
    });

    testWidgets('short balances disable redeem with the gap', (tester) async {
      await _pumpStore(
        tester,
        controller: _store(balance: 5),
        profile: _child(),
      );

      final label = find.text('Need 45 more');
      expect(label, findsOneWidget);
      final button = find.ancestor(
        of: label,
        matching: find.byType(ElevatedButton),
      );
      expect(tester.widget<ElevatedButton>(button).onPressed, isNull);
    });

    testWidgets('perk redemption raises a parent request', (tester) async {
      final controller = _store();
      await _pumpStore(tester, controller: controller, profile: _child());

      await tester.tap(find.text('Parent Perks'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Redeem').first);
      await tester.pumpAndSettle();

      expect(
        find.text('Redeemed Extra 30 min screen time!'),
        findsOneWidget,
      );
      expect(controller.perkRequests.length, 1);
    });

    testWidgets('parent can add a perk from the perks tab', (tester) async {
      await _pumpStore(tester, controller: _store(), profile: _parent());

      await tester.tap(find.text('Parent Perks'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add perk'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), 'Bonus story');
      await tester.enterText(
        find.byType(TextField).at(1),
        'One extra bedtime story.',
      );
      await tester.enterText(find.byType(TextField).at(2), '15');
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      expect(find.text('Bonus story'), findsOneWidget);
    });
  });

  group('Perk requests section', () {
    testWidgets('fulfill clears the request', (tester) async {
      final controller = _store();
      controller.redeem('Maya', 'perk-screen');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: PerkRequestsSection(controller: controller)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Perk requests (1)'), findsOneWidget);
      expect(find.text('Extra 30 min screen time'), findsOneWidget);

      await tester.tap(find.text('Mark Fulfilled'));
      await tester.pumpAndSettle();

      expect(find.text('Extra 30 min screen time'), findsNothing);
      expect(find.textContaining('Perk requests'), findsNothing);
    });
  });
}
