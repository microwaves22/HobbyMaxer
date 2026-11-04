import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:homesync/views/home/kids_home_screen.dart';

Future<void> _pumpKidsHome(
  WidgetTester tester, {
  KidsHomeScreen Function()? build,
}) async {
  await tester.pumpWidget(
    MaterialApp(home: build?.call() ?? const KidsHomeScreen()),
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
  group('Kids Home (Figma 5:50)', () {
    testWidgets('renders the real greeting, hero, and points pill',
        (tester) async {
      await _pumpKidsHome(tester);

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, const Color(0xFFF9F8F6));

      final greeting = _styleOf(tester, 'Hi Ava! 👋');
      expect(greeting.fontFamily, 'Nunito');
      expect(greeting.fontSize, 26);
      expect(greeting.fontWeight, FontWeight.w800);
      expect(greeting.color, const Color(0xFF2B3A2B));

      final subline = _styleOf(tester, 'Keep up the great work!');
      expect(subline.fontSize, 14);
      expect(subline.fontWeight, FontWeight.w500);
      expect(subline.color, const Color(0xFF7C877A));

      expect(find.text('2 tasks to go!'), findsOneWidget);
      expect(
        find.text("Finish today's chores to earn 25 more points."),
        findsOneWidget,
      );
      expect(find.text('120 pts'), findsOneWidget);
    });

    testWidgets('renders the 3 real tasks with states and notes',
        (tester) async {
      await _pumpKidsHome(tester);

      expect(kidsTasks.map((t) => t.title), [
        'Make bed',
        'Homework: Math',
        'Clean your desk',
      ]);
      expect(find.text('+5 pts · Approved'), findsOneWidget);
      expect(find.text('Due by 6 PM'), findsOneWidget);
      expect(find.text('+10 pts'), findsOneWidget);

      // Approved row: check tile + muted title, no strikethrough.
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      final approved = _styleOf(tester, 'Make bed');
      expect(approved.color, const Color(0xFF7C877A));
      expect(approved.decoration, isNot(TextDecoration.lineThrough));

      // Open rows: chevron tiles, not checkboxes.
      expect(find.text('›'), findsNWidgets(2));
      expect(find.byIcon(Icons.radio_button_unchecked_rounded), findsNothing);
      expect(
        _styleOf(tester, 'Homework: Math').decoration,
        isNot(TextDecoration.lineThrough),
      );
    });

    testWidgets('renders companion and progress widgets from data',
        (tester) async {
      await _pumpKidsHome(tester);

      expect(find.text('Care for your companion'), findsOneWidget);
      expect(find.text('Care 80%'), findsOneWidget);
      expect(find.text('Happy'), findsOneWidget);

      expect(find.text('75%'), findsOneWidget);
      final ring = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(ring.value, 0.75);
      expect(kidsMiniBars, [18, 26, 22, 34, 40, 30, 44]);
    });

    testWidgets('bottom nav has Home active', (tester) async {
      await _pumpKidsHome(tester);

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Rewards'), findsOneWidget);
      expect(find.text('Calendar'), findsOneWidget);
      expect(
        _styleOf(tester, 'Home').color,
        const Color(0xFF7A9A85),
      );
      expect(
        _styleOf(tester, 'Rewards').color,
        const Color(0xFF7C877A),
      );
    });

    testWidgets('handlers fire with task and tab ids', (tester) async {
      final calls = <String>[];
      await _pumpKidsHome(
        tester,
        build: () => KidsHomeScreen(
          onAvatarPress: () => calls.add('avatar'),
          onTaskPress: (id) => calls.add('task:$id'),
          onTabPress: (id) => calls.add('tab:$id'),
        ),
      );

      await tester.tap(find.text('🐱').first);
      await tester.tap(find.text('Clean your desk'));
      await tester.tap(find.text('Rewards'));
      await tester.pumpAndSettle();

      expect(calls, ['avatar', 'task:clean-desk', 'tab:rewards']);
    });
  });
}
