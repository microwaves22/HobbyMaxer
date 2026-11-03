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
      expect(scaffold.backgroundColor, const Color(0xFFFBF7EF));

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

    testWidgets('bottom nav has no active tab', (tester) async {
      await _pumpSettings(tester);

      for (final label in ['Home', 'Rewards', 'Calendar']) {
        final style = _styleOf(tester, label);
        expect(style.fontWeight, FontWeight.w600);
        expect(style.color, const Color(0xFF7C877A));
      }
    });
  });
}
