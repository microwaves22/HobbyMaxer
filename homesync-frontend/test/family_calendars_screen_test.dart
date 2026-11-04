import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:homesync/views/family_calendars/family_calendars_screen.dart';

Future<void> _pumpCalendars(
  WidgetTester tester, {
  VoidCallback? onBack,
  ValueChanged<String>? onSelectOwner,
  VoidCallback? onChooseFile,
  VoidCallback? onPreviousDay,
  VoidCallback? onNextDay,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: FamilyCalendarsScreen(
        onBack: onBack,
        onSelectOwner: onSelectOwner,
        onChooseFile: onChooseFile,
        onPreviousDay: onPreviousDay,
        onNextDay: onNextDay,
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

/// 'Family calendars' appears twice (title + list heading); title is first.
TextStyle _titleStyleOf(WidgetTester tester) {
  final styles = tester
      .widgetList<Text>(find.text('Family calendars'))
      .map((w) => w.style!);
  return styles.first;
}

void main() {
  testWidgets('Family calendars matches the reference', (tester) async {
    await _pumpCalendars(tester);

    // Solid cream background, no bottom nav on this settings-style screen.
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, const Color(0xFFFBF7EF));
    expect(find.byType(BottomNavigationBar), findsNothing);

    // Header: back link + title copy, Nunito, size, weight, color.
    expect(find.text('Parent settings'), findsOneWidget);
    expect(find.text('Family calendars'), findsNWidgets(2));
    final title = _titleStyleOf(tester);
    expect(title.fontFamily, 'Nunito');
    expect(title.fontSize, 26);
    expect(title.fontWeight, FontWeight.w800);
    expect(title.color, const Color(0xFF2B3A2B));
    expect(
      find.text("Everyone's plans, and a little room to breathe."),
      findsOneWidget,
    );

    // Import card copy, in order.
    expect(find.text('Add a calendar'), findsOneWidget);
    expect(find.text('Import a calendar file (.ics)'), findsOneWidget);
    expect(find.text('Whose calendar is this?'), findsOneWidget);
    expect(find.text('Sarah (you)'), findsOneWidget);
    expect(find.text('Ava'), findsOneWidget);
    expect(find.text('Noah'), findsOneWidget);
    expect(find.text('Choose .ics file'), findsOneWidget);
    expect(
      find.text('No file chosen · Preview events before adding'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.calendar_today), findsOneWidget);

    // Calendar list: heading, badge, rows, note.
    expect(find.text('SAMPLE DATA'), findsOneWidget);
    expect(find.text('Personal & work'), findsOneWidget);
    expect(find.text('Piano lessons'), findsOneWidget);
    expect(find.text('Soccer club'), findsOneWidget);
    expect(find.text('Sarah · Parent'), findsOneWidget);
    expect(find.text('Ava · Child'), findsOneWidget);
    expect(find.text('Noah · Child'), findsOneWidget);
    expect(find.text('.ics'), findsNWidgets(3));
    expect(
      find.text('Example calendars below. Nothing imported yet.'),
      findsOneWidget,
    );
  });

  testWidgets('Sample-day preview shows banner and timeline', (tester) async {
    await _pumpCalendars(tester);

    expect(find.text('Monday, November 2'), findsOneWidget);
    expect(
      find.text('Sample day · Everyone · 9 AM–6 PM'),
      findsOneWidget,
    );
    expect(
      find.text('4 hours free together · 2 windows'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.schedule_outlined), findsOneWidget);

    for (final label in [
      '9 AM–12 PM',
      '12–2 PM',
      '2–3 PM',
      '3–4 PM',
      '4–6 PM',
      'Work planning',
      'Piano lesson',
      'Soccer practice',
      'Sarah · Scheduled',
      'Ava · Scheduled',
      'Noah · Scheduled',
    ]) {
      await tester.ensureVisible(find.text(label));
      expect(find.text(label), findsOneWidget, reason: label);
    }
    expect(find.text('Available'), findsNWidgets(2));
    expect(find.text('Everyone is free'), findsNWidgets(2));
    expect(find.byIcon(Icons.wb_sunny_outlined), findsNWidgets(2));

    final note = find.text(
      'Free time is based on the calendars shown, within the hours above.',
    );
    await tester.ensureVisible(note);
    expect(note, findsOneWidget);
  });

  testWidgets('Owner chips select locally and report the id', (tester) async {
    String? selected;
    await _pumpCalendars(tester, onSelectOwner: (id) => selected = id);

    // Sarah starts selected (white chip, sage border, check icon).
    expect(
      _styleOf(tester, 'Sarah (you)').color,
      const Color(0xFF2B3A2B),
    );
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);

    await tester.tap(find.text('Ava'));
    await tester.pumpAndSettle();

    expect(selected, 'ava');
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
  });

  testWidgets('Back link, file button, and day chevrons fire', (tester) async {
    var back = 0;
    var choose = 0;
    var prev = 0;
    var next = 0;
    await _pumpCalendars(
      tester,
      onBack: () => back++,
      onChooseFile: () => choose++,
      onPreviousDay: () => prev++,
      onNextDay: () => next++,
    );

    await tester.tap(find.text('Parent settings'));
    await tester.tap(find.text('Choose .ics file'));
    expect(back, 1);
    expect(choose, 1);

    // Two chevron_left icons (back link + day "<"); the day pair sits in
    // the sample-day header row next to the day title.
    final chevrons = find.byIcon(Icons.chevron_left);
    expect(chevrons, findsNWidgets(2));
    await tester.ensureVisible(chevrons.last);
    await tester.tap(chevrons.last);
    final chevronRight = find.byIcon(Icons.chevron_right);
    await tester.ensureVisible(chevronRight);
    await tester.tap(chevronRight);
    expect(prev, 1);
    expect(next, 1);
  });
}
