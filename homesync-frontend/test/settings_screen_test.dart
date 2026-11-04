import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:homesync/views/settings/settings_screen.dart';

Future<void> _pumpSettings(
  WidgetTester tester, {
  SettingsScreen Function()? build,
}) async {
  await tester.pumpWidget(
    MaterialApp(home: build?.call() ?? const SettingsScreen()),
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
  group('Settings (Figma 7:207)', () {
    testWidgets('renders the title-only header and all 10 rows',
        (tester) async {
      await _pumpSettings(tester);

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, const Color(0xFFF9F8F6));

      final title = _styleOf(tester, 'Settings');
      expect(title.fontFamily, 'Nunito');
      expect(title.fontSize, 26);
      expect(title.fontWeight, FontWeight.w800);

      for (final label in [
        'Manage Family',
        'Task Preferences',
        'Notification Settings',
        'Points & Rewards',
        'Customization',
        'Kids / Teen Mode',
        'Family calendars',
        'Dark Mode',
        'Help & Support',
        'About HomeSync',
      ]) {
        expect(find.text(label), findsOneWidget, reason: label);
      }

      // Only Family calendars has a sublabel.
      expect(
        find.text('Import calendars · See free time'),
        findsOneWidget,
      );

      // Nothing extra: no logout, no version text, one toggle only.
      expect(find.textContaining('Log out'), findsNothing);
      expect(find.textContaining('Version'), findsNothing);
      expect(find.byIcon(Icons.chevron_right_rounded), findsNWidgets(9));
    });

    testWidgets('Dark Mode toggle defaults off and flips local state',
        (tester) async {
      bool? reported;
      await _pumpSettings(
        tester,
        build: () => SettingsScreen(
          onDarkModeChange: (v) => reported = v,
        ),
      );

      await tester.tap(find.text('Dark Mode'));
      await tester.pumpAndSettle();
      expect(reported, isTrue);

      await tester.tap(find.text('Dark Mode'));
      await tester.pumpAndSettle();
      expect(reported, isFalse);
    });

    testWidgets('row taps report the row id', (tester) async {
      String? pressed;
      await _pumpSettings(
        tester,
        build: () => SettingsScreen(onRowPress: (id) => pressed = id),
      );

      await tester.tap(find.text('Manage Family'));
      await tester.pumpAndSettle();
      expect(pressed, 'manage-family');
    });

    testWidgets('has no bottom navigation bar', (tester) async {
      await _pumpSettings(tester);

      // Settings is the one page outside the tab flow.
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.bottomNavigationBar, isNull);
      expect(find.text('Home'), findsNothing);
      expect(find.text('Rewards'), findsNothing);
      expect(find.text('Calendar'), findsNothing);
    });

    testWidgets('matches the Figma measurements', (tester) async {
      await _pumpSettings(tester);

      // Tiles: 34px, radius 11, 18px icons, exact fills in row order.
      const tileColors = [
        Color(0xFFCFE0EE), // Manage Family
        Color(0xFFFDF0C8), // Task Preferences
        Color(0xFFF6D9C4), // Notification Settings
        Color(0xFFFDF0C8), // Points & Rewards
        Color(0xFFDDD5EE), // Customization
        Color(0xFFF4C9C9), // Kids / Teen Mode
        Color(0xFFCFE0EE), // Family calendars
        Color(0xFFDDD5EE), // Dark Mode
        Color(0xFFE4EBDC), // Help & Support
        Color(0xFFCFE0EE), // About HomeSync
      ];
      const tileIcons = [
        Icons.group_rounded,
        Icons.checklist_rounded,
        Icons.notifications_rounded,
        Icons.star_rounded,
        Icons.auto_awesome_rounded,
        Icons.favorite_rounded,
        Icons.calendar_month_rounded,
        Icons.dark_mode_rounded,
        Icons.help_outline_rounded,
        Icons.info_outline_rounded,
      ];
      final tiles = find.byWidgetPredicate(
        (w) =>
            w is Container &&
            w.decoration is BoxDecoration &&
            (w.decoration! as BoxDecoration).borderRadius ==
                BorderRadius.circular(11),
      );
      expect(tiles, findsNWidgets(10));
      for (var i = 0; i < 10; i++) {
        final tile = tiles.at(i);
        expect(tester.getSize(tile), const Size(34, 34), reason: 'tile $i');
        expect(
          (tester.widget<Container>(tile).decoration! as BoxDecoration)
              .color,
          tileColors[i],
          reason: 'tile $i fill',
        );
        final icon = tester.widget<Icon>(
          find.descendant(of: tile, matching: find.byType(Icon)),
        );
        expect(icon.icon, tileIcons[i], reason: 'tile $i icon');
        expect(icon.size, 18, reason: 'tile $i icon size');
      }

      // Sublabel: SemiBold 12 mute with a 16px line height.
      final sublabel = _styleOf(tester, 'Import calendars · See free time');
      expect(sublabel.fontSize, 12);
      expect(sublabel.fontWeight, FontWeight.w600);
      expect(sublabel.color, const Color(0xFF7C877A));
      expect(sublabel.height, moreOrLessEquals(16 / 12, epsilon: 0.01));

      // Row heights: the sublabel row is 53px, the rest 50px.
      SizedBox rowBox(String label) => tester.widget<SizedBox>(
            find.ancestor(
              of: find.text(label),
              matching: find.byType(SizedBox),
            ),
          );
      expect(rowBox('Family calendars').height, 53);
      expect(rowBox('Manage Family').height, 50);
      expect(rowBox('Dark Mode').height, 50);
      expect(rowBox('About HomeSync').height, 50);

      // Group cards: radius 22, 4px vertical / 16px horizontal padding,
      // 1px line dividers (6 in Parent, 2 in App).
      final cards = find.byWidgetPredicate(
        (w) =>
            w is Container &&
            w.padding ==
                const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      );
      expect(cards, findsNWidgets(2));
      for (var i = 0; i < 2; i++) {
        expect(
          (tester.widget<Container>(cards.at(i)).decoration!
                  as BoxDecoration)
              .borderRadius,
          const BorderRadius.all(Radius.circular(22)),
        );
      }
      final dividers = find.byType(Divider);
      expect(dividers, findsNWidgets(8));
      final divider = tester.widget<Divider>(dividers.first);
      expect(divider.thickness, 1);
      expect(divider.color, const Color(0xFFE8E4D8));

      // Toggle: 48×28 track, radius 14, sageMid, 22px white knob LEFT.
      final track = find.byWidgetPredicate(
        (w) =>
            w is Container &&
            w.decoration is BoxDecoration &&
            (w.decoration! as BoxDecoration).color ==
                const Color(0xFFA9BE9C),
      );
      expect(track, findsOneWidget);
      expect(tester.getSize(track), const Size(48, 28));
      expect(
        (tester.widget<Container>(track).decoration! as BoxDecoration)
            .borderRadius,
        BorderRadius.circular(14),
      );
      final knob = find.descendant(
        of: track,
        matching: find.byWidgetPredicate(
          (w) =>
              w is Container &&
              w.decoration is BoxDecoration &&
              (w.decoration! as BoxDecoration).shape == BoxShape.circle,
        ),
      );
      expect(knob, findsOneWidget);
      expect(tester.getSize(knob), const Size(22, 22));
      expect(
        tester.getTopLeft(knob).dx,
        tester.getTopLeft(track).dx + 3,
      );
    });
  });
}
