import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:homesync/core/state/focus_areas.dart';
import 'package:homesync/views/home/home_screen.dart';
import 'package:homesync/views/onboarding/models/user_profile.dart';
import 'package:homesync/views/tasks/tasks_controller.dart';
import 'package:homesync/views/tasks/tasks_screen.dart';

UserProfile _parent() => UserProfile(
      name: 'Mom',
      birthday: DateTime(1990, 1, 1),
      role: FamilyRole.parent,
      mode: FamilyMode.parent,
    );

Future<void> _pumpHome(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: FocusAreasScope(
        controller: FocusAreasController(FocusAreas.all),
        child: HomeScreen(profile: _parent()),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('AppBar home title', () {
    testWidgets('tapping Tasks title returns to the dashboard',
        (tester) async {
      await _pumpHome(tester);

      // The dashboard chores card was removed in favor of the bottom
      // nav; push the hub directly to exercise the title-tap pop.
      final profile = _parent();
      Navigator.of(tester.element(find.byType(HomeScreen))).push(
        MaterialPageRoute(
          builder: (_) => TasksScreen(
            controller: TasksController.forProfile(profile),
            profile: profile,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Tasks'),
        ),
        findsOneWidget,
      );

      await tester.tap(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Tasks'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Hello, Mom!'), findsOneWidget);
    });

    testWidgets('tapping Reward Store title returns to the dashboard',
        (tester) async {
      await _pumpHome(tester);

      final rewards = find.text('Task rewards');
      await tester.ensureVisible(rewards);
      await tester.tap(rewards);
      await tester.pumpAndSettle();
      expect(find.text('Reward Store'), findsOneWidget);

      await tester.tap(find.text('Reward Store'));
      await tester.pumpAndSettle();
      expect(find.text('Hello, Mom!'), findsOneWidget);
    });
  });
}
