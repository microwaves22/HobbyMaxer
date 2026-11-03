import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:homesync/views/rewards/models/store_section.dart';
import 'package:homesync/views/rewards/rewards_store_screen.dart';

Future<void> _pumpStore(
  WidgetTester tester, {
  RewardsStoreScreen Function()? build,
}) async {
  await tester.pumpWidget(
    MaterialApp(home: build?.call() ?? const RewardsStoreScreen()),
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
  group('Rewards Store Digital view (Figma 5:139)', () {
    testWidgets('renders the title header, points pill, and chips',
        (tester) async {
      await _pumpStore(tester);

      expect(find.text('Teen Rewards'), findsOneWidget);
      // Points pill + the Creature Palette price row.
      expect(find.text('120 pts'), findsNWidgets(2));

      expect(find.text('Digital'), findsOneWidget);
      expect(find.text('Real-world'), findsOneWidget);
      expect(
        _styleOf(tester, 'Digital').color,
        const Color(0xFFFFFFFF),
      );
      expect(
        _styleOf(tester, 'Real-world').color,
        const Color(0xFF2B3A2B),
      );
    });

    testWidgets('renders the 6 real rewards in order', (tester) async {
      await _pumpStore(tester);

      expect(
        kStoreSections.first.rewards.map((r) => r.name),
        [
          'Neon Avatar',
          'Midnight Sage',
          'Rare Dragon Armor',
          'Profile Wallpaper',
          'App Icon Theme',
          'Creature Palette',
        ],
      );
      for (final name in [
        'Neon Avatar',
        'Midnight Sage',
        'Rare Dragon Armor',
        'Profile Wallpaper',
        'App Icon Theme',
        'Creature Palette',
      ]) {
        expect(find.text(name), findsOneWidget, reason: name);
      }

      // Computed actions against the 120 balance.
      expect(find.text('Equipped'), findsOneWidget);
      expect(find.text('Save 30 more'), findsOneWidget);
      expect(find.text('Redeem'), findsNWidgets(4));

      // No subtitles on cards.
      expect(find.text('Placeholder subtitle'), findsNothing);
    });

    testWidgets('renders the custom request card, Rewards nav active',
        (tester) async {
      await _pumpStore(tester);

      expect(find.text('Have a perk in mind?'), findsOneWidget);
      expect(find.text('+ Request Custom Reward'), findsOneWidget);
      expect(
        find.text(
          'Examples: Stay up 30 mins late, Go to trampoline park, '
          'Extra screen time.',
        ),
        findsOneWidget,
      );

      expect(
        _styleOf(tester, 'Rewards').color,
        const Color(0xFF5F7F55),
      );
      expect(
        _styleOf(tester, 'Home').color,
        const Color(0xFF7C877A),
      );
    });

    testWidgets('reward and custom actions fire with ids', (tester) async {
      String? unlocked;
      String? saved;
      var custom = 0;
      await _pumpStore(
        tester,
        build: () => RewardsStoreScreen(
          onUnlockReward: (id) => unlocked = id,
          onSaveUpForReward: (id) => saved = id,
          onRequestCustomReward: () => custom++,
        ),
      );

      await tester.tap(find.text('Redeem').first);
      await tester.pumpAndSettle();
      expect(unlocked, 'midnight-sage');

      await tester.ensureVisible(find.text('Save 30 more'));
      await tester.tap(find.text('Save 30 more'));
      await tester.pumpAndSettle();
      expect(saved, 'profile-wallpaper');

      await tester.ensureVisible(find.text('+ Request Custom Reward'));
      await tester.tap(find.text('+ Request Custom Reward'));
      await tester.pumpAndSettle();
      expect(custom, 1);
    });

    testWidgets('selecting Real-world reports the category', (tester) async {
      String? selected;
      await _pumpStore(
        tester,
        build: () => RewardsStoreScreen(
          onSelectCategory: (name) => selected = name,
        ),
      );

      await tester.tap(find.text('Real-world'));
      await tester.pumpAndSettle();
      expect(selected, 'Real-world');
    });
  });
}
