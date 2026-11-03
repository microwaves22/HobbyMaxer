import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:homesync/views/rewards/models/reward_management_data.dart';
import 'package:homesync/views/rewards/reward_management_screen.dart';

Future<void> _pumpManagement(
  WidgetTester tester, {
  RewardManagementScreen Function()? build,
}) async {
  await tester.pumpWidget(
    MaterialApp(home: build?.call() ?? const RewardManagementScreen()),
  );
  await tester.pumpAndSettle();
}

TextStyle _styleOf(WidgetTester tester, String text) {
  final widget = tester.widget<Text>(find.text(text));
  final style = widget.style;
  expect(style, isNotNull, reason: '$text has an explicit style');
  return style!;
}

void main() {
  group('Sarah reward management (Figma 62:6235)', () {
    testWidgets('renders header, categories, and control banner',
        (tester) async {
      await _pumpManagement(tester);

      expect(find.text('Reward Management'), findsOneWidget);
      expect(find.text('S'), findsOneWidget);
      expect(
        find.text("Your family's rewards, on your terms."),
        findsOneWidget,
      );

      expect(find.text('Digital'), findsOneWidget);
      expect(find.text('Real-world'), findsOneWidget);
      expect(
        _styleOf(tester, 'Real-world').color,
        const Color(0xFF5F7F55),
      );

      expect(
        find.text('Managed by Sarah · Parent approval'),
        findsOneWidget,
      );
      expect(
        find.text(
          'You set the cost, who can redeem, and any conditions. '
          'All requests come to you.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders the creation card with verbatim fields',
        (tester) async {
      await _pumpManagement(tester);

      expect(find.text('Create a custom perk'), findsOneWidget);
      expect(find.text('Privilege / title'), findsOneWidget);
      expect(
        find.text('Contribution toward a personal purchase'),
        findsOneWidget,
      );
      expect(find.text('Point cost'), findsOneWidget);
      expect(find.text('200 points'), findsOneWidget);
      expect(find.text('Eligible child'), findsOneWidget);
      expect(find.text('Noah · 14'), findsOneWidget);
      expect(find.text('Contribution amount'), findsOneWidget);
      expect(find.text('Enter an amount'), findsOneWidget);
      expect(
        find.text(
          'Parent-defined amount. No payment or commitment is created here.',
        ),
        findsOneWidget,
      );
      expect(find.text('Conditions · optional'), findsOneWidget);
      expect(
        find.text('Agree on the item together before redeeming.'),
        findsOneWidget,
      );
      expect(find.text('Add Perk'), findsOneWidget);
    });

    testWidgets('renders the 4 managed perks with a derived count',
        (tester) async {
      await _pumpManagement(tester);

      expect(find.text('Your real-world perks'), findsOneWidget);
      expect(find.text('4 perks'), findsOneWidget);

      expect(
        kRewardManagementData.perks.map((p) => p.name),
        [
          'Extended weekend curfew',
          'Choose Friday night dinner / takeout',
          'Pick the family movie',
          'Personal purchase contribution',
        ],
      );
      expect(find.text('+30 mins · Noah'), findsOneWidget);
      expect(find.text('Ava & Noah'), findsNWidgets(2));
      expect(
        find.text('Amount defined by parent · Noah'),
        findsOneWidget,
      );
      expect(find.text('★ 80'), findsOneWidget);
      expect(find.text('★ 120'), findsOneWidget);
      expect(find.text('★ 150'), findsOneWidget);
      expect(find.text('★ 200'), findsOneWidget);
      expect(find.text('Edit'), findsNWidgets(4));
      expect(find.byType(Switch), findsNothing);
    });

    testWidgets('bottom nav has Family active', (tester) async {
      await _pumpManagement(tester);

      expect(
        _styleOf(tester, 'Family').color,
        const Color(0xFF5F7F55),
      );
      expect(
        _styleOf(tester, 'Tasks').color,
        const Color(0xFF7C877A),
      );
    });

    testWidgets('create and edit actions fire', (tester) async {
      PerkFormState? created;
      String? edited;
      await _pumpManagement(
        tester,
        build: () => RewardManagementScreen(
          onCreatePerk: (form) => created = form,
          onEditPerk: (id) => edited = id,
        ),
      );

      await tester.ensureVisible(find.text('Add Perk'));
      await tester.tap(find.text('Add Perk'));
      await tester.pumpAndSettle();
      expect(
        created?.field1,
        'Contribution toward a personal purchase',
      );
      expect(created?.field2, isEmpty);

      await tester.ensureVisible(find.text('Edit').first);
      await tester.tap(find.text('Edit').first);
      await tester.pumpAndSettle();
      expect(edited, 'managed-perk-1');
    });
  });
}
