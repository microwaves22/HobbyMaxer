import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:homesync/core/state/focus_areas.dart';
import 'package:homesync/views/calendar/calendar_data.dart';
import 'package:homesync/views/calendar/calendar_screen.dart';
import 'package:homesync/views/calendar/models/calendar_event.dart';
import 'package:homesync/views/home/home_screen.dart';
import 'package:homesync/views/onboarding/models/user_profile.dart';

Future<void> _pumpCalendar(
  WidgetTester tester, {
  ValueChanged<DateTime>? onSelectDay,
  VoidCallback? onPreviousWeek,
  VoidCallback? onNextWeek,
  ValueChanged<CalendarView>? onViewChange,
  ValueChanged<String>? onEventPress,
  VoidCallback? onAddEvent,
  ValueChanged<String>? onNavigate,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: CalendarScreen(
        onSelectDay: onSelectDay,
        onPreviousWeek: onPreviousWeek,
        onNextWeek: onNextWeek,
        onViewChange: onViewChange,
        onEventPress: onEventPress,
        onAddEvent: onAddEvent,
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

/// 'Calendar' appears twice (header + bottom nav); the header is first.
TextStyle _headerStyleOf(WidgetTester tester) {
  final styles = tester
      .widgetList<Text>(find.text('Calendar'))
      .map((w) => w.style!);
  return styles.first;
}

/// 'Calendar' appears twice (header + bottom nav); the nav label is last.
TextStyle _navStyleOf(WidgetTester tester) {
  final styles = tester
      .widgetList<Text>(find.text('Calendar'))
      .map((w) => w.style!);
  return styles.last;
}

void main() {
  testWidgets('Calendar matches the Figma 06 spec', (tester) async {
    await _pumpCalendar(tester);

    // Solid cream background, edge to edge (Scaffold paints it all).
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, const Color(0xFFFBF7EF));

    // Header: exact copy, Nunito, size, weight, color + add button.
    final title = _headerStyleOf(tester);
    expect(title.fontFamily, 'Nunito');
    expect(title.fontSize, 26);
    expect(title.fontWeight, FontWeight.w800);
    expect(title.color, const Color(0xFF2B3A2B));
    expect(find.byIcon(Icons.add), findsOneWidget);

    // View switcher: Day / Week / Month with Week selected.
    expect(find.text('Day'), findsOneWidget);
    expect(find.text('Week'), findsOneWidget);
    expect(find.text('Month'), findsOneWidget);
    final week = _styleOf(tester, 'Week');
    expect(week.fontFamily, 'Nunito');
    expect(week.fontSize, 15);
    expect(week.fontWeight, FontWeight.w700);
    expect(week.color, const Color(0xFFFFFFFF));
    expect(_styleOf(tester, 'Day').color, const Color(0xFF2B3A2B));
    expect(_styleOf(tester, 'Month').color, const Color(0xFF2B3A2B));

    // Week navigation: designed range label, verbatim.
    final range = _styleOf(tester, 'Oct 26 – Nov 1, 2026');
    expect(range.fontFamily, 'Nunito');
    expect(range.fontSize, 15);
    expect(range.fontWeight, FontWeight.w700);
    expect(range.color, const Color(0xFF2B3A2B));
    expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);

    // Weekday header: Monday-first names + designed day numbers.
    for (final name in ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']) {
      expect(find.text(name), findsOneWidget);
    }
    for (final number in ['26', '27', '28', '29', '30', '31', '1']) {
      expect(find.text(number), findsOneWidget);
    }

    // Selection: Saturday the 31st is white-on-sage; others are ink.
    expect(_styleOf(tester, '31').color, const Color(0xFFFFFFFF));
    expect(_styleOf(tester, '30').color, const Color(0xFF2B3A2B));
    expect(_styleOf(tester, '1').color, const Color(0xFF2B3A2B));

    // Time gutter endpoints.
    expect(find.text('8 AM'), findsOneWidget);
    expect(find.text('8 PM'), findsOneWidget);

    // Event blocks, in design counts.
    expect(find.text('Work'), findsOneWidget);
    expect(find.text('Dr.'), findsOneWidget);
    expect(find.text('School'), findsNWidgets(2));
    expect(find.text('Piano'), findsOneWidget);
    expect(find.text('Soccer'), findsOneWidget);
    expect(find.text('Chores'), findsOneWidget);
    expect(find.text('Dinner'), findsNWidgets(2));

    // Smart Planner card, verbatim copy.
    expect(find.text('Smart Planner'), findsOneWidget);
    expect(
      find.text("Thursday is overloaded. Move Noah's vacuuming to Friday?"),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.auto_awesome), findsOneWidget);

    // Bottom nav: existing household items with Calendar active.
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Calendar'), findsNWidgets(2));
    expect(find.text('Tasks'), findsOneWidget);
    expect(find.text('Family'), findsOneWidget);
    final navCalendar = _navStyleOf(tester);
    expect(navCalendar.fontFamily, 'Nunito');
    expect(navCalendar.fontSize, 11);
    expect(navCalendar.fontWeight, FontWeight.w800);
    expect(navCalendar.color, const Color(0xFF5F7F55));
    expect(_styleOf(tester, 'Home').color, const Color(0xFF7C877A));
  });

  testWidgets('selecting a day moves the selection', (tester) async {
    DateTime? selected;
    await _pumpCalendar(tester, onSelectDay: (day) => selected = day);

    await tester.tap(find.text('30'));
    await tester.pumpAndSettle();

    expect(selected, DateTime(2026, 10, 30));
    expect(_styleOf(tester, '30').color, const Color(0xFFFFFFFF));
    expect(_styleOf(tester, '31').color, const Color(0xFF2B3A2B));
  });

  testWidgets('week chevrons change the displayed week', (tester) async {
    var previousCalls = 0;
    var nextCalls = 0;
    await _pumpCalendar(
      tester,
      onPreviousWeek: () => previousCalls++,
      onNextWeek: () => nextCalls++,
    );

    await tester.tap(find.byIcon(Icons.chevron_right_rounded));
    await tester.pumpAndSettle();
    expect(nextCalls, 1);
    expect(find.text('Nov 2 – 8, 2026'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.chevron_left_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.chevron_left_rounded));
    await tester.pumpAndSettle();
    expect(previousCalls, 2);
    expect(find.text('Oct 19 – 25, 2026'), findsOneWidget);
  });

  testWidgets('view switcher updates the active view', (tester) async {
    CalendarView? view;
    await _pumpCalendar(tester, onViewChange: (v) => view = v);

    await tester.tap(find.text('Day'));
    await tester.pumpAndSettle();

    expect(view, CalendarView.day);
    expect(_styleOf(tester, 'Day').color, const Color(0xFFFFFFFF));
    expect(_styleOf(tester, 'Week').color, const Color(0xFF2B3A2B));
    // Day/Month content is out of scope: the week grid stays put.
    expect(find.text('Work'), findsOneWidget);
  });

  testWidgets('event tap and add button fire placeholders', (tester) async {
    String? pressed;
    var addCalls = 0;
    await _pumpCalendar(
      tester,
      onEventPress: (id) => pressed = id,
      onAddEvent: () => addCalls++,
    );

    await tester.ensureVisible(find.text('Soccer'));
    await tester.tap(find.text('Soccer'));
    await tester.pumpAndSettle();
    expect(pressed, 'soccer');

    // The event scroll above pushed the header off-screen; scroll back.
    await tester.ensureVisible(find.byIcon(Icons.add));
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(addCalls, 1);
  });

  testWidgets('bottom nav reports tab taps', (tester) async {
    String? tab;
    await _pumpCalendar(tester, onNavigate: (id) => tab = id);

    await tester.tap(find.text('Tasks'));
    await tester.pumpAndSettle();
    expect(tab, 'tasks');
  });

  testWidgets('dashboard Calendar card opens the screen', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: FocusAreasScope(
          controller: FocusAreasController(FocusAreas.all),
          child: HomeScreen(
            profile: UserProfile(
              name: 'Mom',
              birthday: DateTime(1990, 1, 1),
              role: FamilyRole.parent,
              mode: FamilyMode.parent,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final card = find.text('Calendar coordination');
    await tester.ensureVisible(card);
    await tester.tap(card);
    await tester.pumpAndSettle();

    expect(find.byType(CalendarScreen), findsOneWidget);
  });

  group('CalendarData', () {
    test('designed week starts on Monday Oct 26, 2026', () {
      final start = CalendarData.designedWeekStart;
      expect(start.weekday, DateTime.monday);
      expect(CalendarData.weekDays(start), hasLength(7));
      expect(
        CalendarData.weekRangeLabel(start),
        'Oct 26 – Nov 1, 2026',
      );
    });

    test('shifting weeks is DST-immune', () {
      // Nov 1, 2026 is the US DST fallback; Duration arithmetic would
      // land on Nov 1 at 11 PM instead of Nov 2 at midnight.
      final next = CalendarData.shiftWeek(
        CalendarData.designedWeekStart,
        1,
      );
      expect(next, DateTime(2026, 11, 2));
      expect(
        CalendarData.weekRangeLabel(next),
        'Nov 2 – 8, 2026',
      );
      expect(
        CalendarData.shiftWeek(CalendarData.designedWeekStart, -1),
        DateTime(2026, 10, 19),
      );
    });

    test('events fall on the designed days', () {
      final monday = CalendarData.eventsForDay(DateTime(2026, 10, 26));
      expect(
        monday.map((e) => e.id),
        ['work'],
      );
      final tuesday = CalendarData.eventsForDay(DateTime(2026, 10, 27));
      expect(
        tuesday.map((e) => e.id),
        ['dr'],
      );
      final saturday = CalendarData.eventsForDay(DateTime(2026, 10, 31));
      expect(
        saturday.map((e) => e.id),
        ['chores', 'dinner-sat'],
      );
      final friday = CalendarData.eventsForDay(DateTime(2026, 10, 30));
      expect(
        friday.map((e) => e.id),
        ['piano', 'dinner-fri'],
      );
      expect(
        CalendarData.eventsForDay(DateTime(2026, 11, 2)),
        isEmpty,
      );
    });

    test('event colors match the design system', () {
      final byId = {for (final e in CalendarData.events) e.id: e};
      expect(byId['work']!.color, const Color(0xFFCFE0EE));
      expect(byId['dr']!.color, const Color(0xFFDDD5EE));
      expect(byId['dinner-fri']!.color, const Color(0xFF5F7F55));
      expect(byId['dinner-fri']!.textColor, const Color(0xFFFFFFFF));
      expect(byId['dinner-sat']!.color, const Color(0xFF5F7F55));
      expect(byId['dinner-sat']!.textColor, const Color(0xFFFFFFFF));
      expect(byId['school-wed']!.color, const Color(0xFFFDF0C8));
      expect(byId['soccer']!.color, const Color(0xFFF6D9C4));
      expect(byId['piano']!.color, const Color(0xFFF4C9C9));
      expect(byId['chores']!.color, const Color(0xFFE4EBDC));
    });

    test('Noah is the only member named in the design', () {
      expect(CalendarData.members.map((m) => m.name), ['Noah']);
    });
  });
}
