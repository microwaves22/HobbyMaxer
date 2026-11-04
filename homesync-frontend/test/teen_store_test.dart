import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:homesync/views/rewards/models/teen_store_reward.dart';
import 'package:homesync/views/rewards/teen_reward_store_screen.dart';

Future<void> _pumpStore(
  WidgetTester tester, {
  TeenRewardStoreScreen Function()? build,
}) async {
  await tester.pumpWidget(
    MaterialApp(home: build?.call() ?? const TeenRewardStoreScreen()),
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
  group('Teen Real-World store (Figma 62:6146)', () {
    testWidgets('renders header, balance card, and Real-world selected',
        (tester) async {
      await _pumpStore(tester);

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, const Color(0xFFF4F3EF));

      expect(find.text('Teen Rewards'), findsOneWidget);
      expect(find.text('N'), findsOneWidget);

      expect(find.text('NOAH\u2019S AVAILABLE BALANCE'), findsOneWidget);
      expect(find.text('0 points'), findsOneWidget);
      expect(find.text('Earned, not bought'), findsOneWidget);

      expect(find.text('Digital'), findsOneWidget);
      expect(find.text('Real-world'), findsOneWidget);
      expect(
        _styleOf(tester, 'Real-world').color,
        const Color(0xFF5F7F55),
      );
      expect(
        _styleOf(tester, 'Digital').color,
        const Color(0xFF7C877A),
      );
    });

    testWidgets('renders intro, custom bar, and the 4 real perks',
        (tester) async {
      await _pumpStore(tester);

      expect(find.text('Real-World Perks'), findsOneWidget);
      expect(
        find.text('Managed by Sarah · Redeem to request approval.'),
        findsOneWidget,
      );
      expect(find.text('+ Request Custom Reward'), findsOneWidget);

      expect(
        kTeenStoreRewards.map((r) => r.name),
        [
          'Extended weekend curfew',
          'Choose Friday night dinner',
          'Pick the family movie',
          'Personal purchase contribution',
        ],
      );
      expect(find.text('+30 mins'), findsOneWidget);
      expect(find.text('Dinner / takeout'), findsOneWidget);

      // Prices render as star text; locked gaps are computed.
      expect(find.text('★ 80 pts'), findsOneWidget);
      expect(find.text('★ 120 pts'), findsOneWidget);
      expect(find.text('Save 80 more'), findsOneWidget);
      expect(find.text('Save 120 more'), findsOneWidget);
      expect(find.text('Save 150 more'), findsOneWidget);
      expect(find.text('Save 200 more'), findsOneWidget);

      expect(
        find.text(
          'Sarah confirms timing and conditions before a perk is used. '
          'Your balance stays unchanged until approved.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('bottom nav has Rewards active', (tester) async {
      await _pumpStore(tester);

      expect(
        _styleOf(tester, 'Rewards').color,
        const Color(0xFF5F7F55),
      );
    });

    testWidgets('redeem, save-up, and custom actions fire', (tester) async {
      String? redeemed;
      String? saved;
      var custom = 0;
      await _pumpStore(
        tester,
        build: () => TeenRewardStoreScreen(
          availablePoints: 120,
          onRedeemReward: (id) => redeemed = id,
          onSaveUpForReward: (id) => saved = id,
          onRequestCustomReward: () => custom++,
        ),
      );

      await tester.tap(find.text('Redeem').first);
      await tester.pumpAndSettle();
      expect(redeemed, 'extended-curfew');

      await tester.ensureVisible(find.text('Save 80 more'));
      await tester.tap(find.text('Save 80 more'));
      await tester.pumpAndSettle();
      expect(saved, 'purchase-contribution');

      await tester.ensureVisible(find.text('+ Request Custom Reward'));
      await tester.tap(find.text('+ Request Custom Reward'));
      await tester.pumpAndSettle();
      expect(custom, 1);
    });
  });
}
