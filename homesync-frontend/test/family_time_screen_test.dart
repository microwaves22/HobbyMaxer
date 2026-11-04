import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:homesync/views/family_time/family_time_data.dart';
import 'package:homesync/views/family_time/family_time_screen.dart';

Future<void> _pumpFamilyTime(
  WidgetTester tester, {
  ValueChanged<String>? onActivityTypeChange,
  VoidCallback? onConfirmFamilyTime,
  VoidCallback? onSeeAllOptions,
  ValueChanged<String>? onOptionSelect,
  ValueChanged<String>? onNavigate,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: FamilyTimeScreen(
        onActivityTypeChange: onActivityTypeChange,
        onConfirmFamilyTime: onConfirmFamilyTime,
        onSeeAllOptions: onSeeAllOptions,
        onOptionSelect: onOptionSelect,
        onNavigate: onNavigate,
      ),
    ),
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
  testWidgets('Family Time matches the Figma 07 spec', (tester) async {
    await _pumpFamilyTime(tester);

    // Solid cream background, edge to edge (Scaffold paints it all).
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, const Color(0xFFF9F8F6));

    // Header: exact copy, Nunito, size, weight, color.
    final title = _styleOf(tester, 'Family Time');
    expect(title.fontFamily, 'Nunito');
    expect(title.fontSize, 28);
    expect(title.fontWeight, FontWeight.w800);
    expect(title.color, const Color(0xFF2B3A2B));
    final subtitle = _styleOf(tester, 'Find a time for the whole family!');
    expect(subtitle.fontFamily, 'Nunito');
    expect(subtitle.fontWeight, FontWeight.w500);
    expect(subtitle.color, const Color(0xFF7C877A));

    // Category strip: four activity glyphs in design order.
    expect(find.byIcon(Icons.casino_rounded), findsOneWidget);
    expect(find.byIcon(Icons.movie_rounded), findsOneWidget);
    expect(find.byIcon(Icons.directions_walk_rounded), findsOneWidget);
    expect(find.byIcon(Icons.restaurant_rounded), findsOneWidget);

    // Suggested card: verbatim copy.
    final suggested = _styleOf(tester, '✨ Suggested Time');
    expect(suggested.fontFamily, 'Nunito');
    expect(suggested.fontSize, 13);
    expect(suggested.fontWeight, FontWeight.w700);
    expect(suggested.color, const Color(0xFF4A6A41));
    expect(find.text('Best match'), findsOneWidget);
    final day = _styleOf(tester, 'Friday, Nov 6');
    expect(day.fontWeight, FontWeight.w800);
    expect(day.color, const Color(0xFF2B3A2B));
    final time = _styleOf(tester, '6:00 – 7:00 PM');
    expect(time.fontWeight, FontWeight.w700);
    expect(time.color, const Color(0xFF7A9A85));
    expect(find.text('Everyone is available!'), findsOneWidget);

    // Activity chips with Game Night selected (white on sage).
    expect(find.text('Dinner'), findsOneWidget);
    expect(find.text('Game Night'), findsOneWidget);
    expect(find.text('Movie'), findsOneWidget);
    expect(find.text('Walk'), findsOneWidget);
    expect(
      _styleOf(tester, 'Game Night').color,
      const Color(0xFFFFFFFF),
    );
    expect(_styleOf(tester, 'Dinner').color, const Color(0xFF2B3A2B));
    expect(_styleOf(tester, 'Movie').color, const Color(0xFF2B3A2B));
    expect(_styleOf(tester, 'Walk').color, const Color(0xFF2B3A2B));

    // Primary action, verbatim.
    expect(find.text('Confirm Family Time'), findsOneWidget);

    // Other options: heading, See All, both rows verbatim.
    expect(find.text('Other Options'), findsOneWidget);
    expect(find.text('See All'), findsOneWidget);
    expect(find.text('Sat, Nov 7'), findsOneWidget);
    expect(find.text('5:00 – 6:00 PM'), findsOneWidget);
    expect(find.text('Sun, Nov 8'), findsOneWidget);
    expect(find.text('4:00 – 5:00 PM'), findsOneWidget);

    // Bottom nav: existing household items with Family active.
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Calendar'), findsOneWidget);
    expect(find.text('Tasks'), findsOneWidget);
    final navFamily = _styleOf(tester, 'Family');
    expect(navFamily.fontFamily, 'Nunito');
    expect(navFamily.fontSize, 11);
    expect(navFamily.fontWeight, FontWeight.w800);
    expect(navFamily.color, const Color(0xFF7A9A85));
    expect(_styleOf(tester, 'Home').color, const Color(0xFF7C877A));
  });

  testWidgets('chip tap switches the selected activity type', (tester) async {
    String? selected;
    await _pumpFamilyTime(
      tester,
      onActivityTypeChange: (id) => selected = id,
    );

    await tester.tap(find.text('Movie'));
    await tester.pumpAndSettle();

    expect(selected, 'movie');
    expect(_styleOf(tester, 'Movie').color, const Color(0xFFFFFFFF));
    expect(
      _styleOf(tester, 'Game Night').color,
      const Color(0xFF2B3A2B),
    );
  });

  testWidgets('confirm and See All fire placeholders', (tester) async {
    var confirmCalls = 0;
    var seeAllCalls = 0;
    await _pumpFamilyTime(
      tester,
      onConfirmFamilyTime: () => confirmCalls++,
      onSeeAllOptions: () => seeAllCalls++,
    );

    await tester.tap(find.text('Confirm Family Time'));
    await tester.pumpAndSettle();
    expect(confirmCalls, 1);

    await tester.tap(find.text('See All'));
    await tester.pumpAndSettle();
    expect(seeAllCalls, 1);
  });

  testWidgets('option tap selects the option', (tester) async {
    String? selected;
    await _pumpFamilyTime(
      tester,
      onOptionSelect: (id) => selected = id,
    );

    await tester.ensureVisible(find.text('Sun, Nov 8'));
    await tester.tap(find.text('Sun, Nov 8'));
    await tester.pumpAndSettle();
    expect(selected, 'sun-nov-8');
  });

  testWidgets('bottom nav reports tab taps', (tester) async {
    String? tab;
    await _pumpFamilyTime(tester, onNavigate: (id) => tab = id);

    await tester.tap(find.text('Tasks'));
    await tester.pumpAndSettle();
    expect(tab, 'tasks');
  });

  group('FamilyTimeData', () {
    test('strings are the verbatim design copy', () {
      expect(FamilyTimeData.title, 'Family Time');
      expect(
        FamilyTimeData.subtitle,
        'Find a time for the whole family!',
      );
      expect(FamilyTimeData.suggestedDay, 'Friday, Nov 6');
      expect(FamilyTimeData.suggestedTime, '6:00 – 7:00 PM');
      expect(
        FamilyTimeData.availabilityLabel,
        'Everyone is available!',
      );
      expect(FamilyTimeData.confirmLabel, 'Confirm Family Time');
    });

    test('chips and strip hold the four activity types', () {
      expect(
        FamilyTimeData.activityTypes.map((t) => t.label),
        ['Dinner', 'Game Night', 'Movie', 'Walk'],
      );
      expect(FamilyTimeData.defaultActivityTypeId, 'game-night');
      expect(
        FamilyTimeData.stripTypeIds,
        ['game-night', 'movie', 'walk', 'dinner'],
      );
      expect(
        FamilyTimeData.activityTypeById('walk').label,
        'Walk',
      );
    });

    test('options are the two designed rows', () {
      expect(
        FamilyTimeData.options.map((o) => o.dayLabel),
        ['Sat, Nov 7', 'Sun, Nov 8'],
      );
      expect(
        FamilyTimeData.options.map((o) => o.timeLabel),
        ['5:00 – 6:00 PM', '4:00 – 5:00 PM'],
      );
    });

    test('members reuse the sibling-screen palette', () {
      final byId = {for (final m in FamilyTimeData.members) m.id: m};
      expect(byId['sarah']!.color, const Color(0xFFF6D9C4));
      expect(byId['ava']!.color, const Color(0xFFF4C9C9));
      expect(byId['noah']!.color, const Color(0xFFCFE0EE));
      expect(FamilyTimeData.members, hasLength(4));
    });
  });
}
