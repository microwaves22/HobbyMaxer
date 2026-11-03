import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:homesync/views/onboarding/models/user_profile.dart';
import 'package:homesync/views/tasks/models/chore_task.dart';
import 'package:homesync/views/tasks/tasks_controller.dart';
import 'package:homesync/views/tasks/teen_todo_list_screen.dart';

UserProfile _teen({String name = 'Alex'}) => UserProfile(
      name: name,
      birthday: DateTime(2011, 6, 15),
      role: FamilyRole.child,
      mode: FamilyMode.teen,
    );

ChoreTask _task({
  String id = 't1',
  String title = 'Take out the trash',
  String child = 'Alex',
  int points = 10,
  TaskState state = TaskState.pending,
}) {
  return ChoreTask(
    id: id,
    title: title,
    details: 'Details $id',
    childName: child,
    points: points,
    state: state,
  );
}

Future<void> _pumpScreen(
  WidgetTester tester, {
  required TasksController controller,
  required UserProfile profile,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: TeenTodoListScreen(controller: controller, profile: profile),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() {
    // Figma type uses runtime Google Fonts; disable network fetching so
    // widget tests run offline with the fallback font.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('TeenTodoListScreen (Figma 03 skeleton)', () {
    testWidgets('renders header, progress, balance, and task cards',
        (tester) async {
      final controller = TasksController.test(
        tasks: [
          _task(id: 't1', title: 'Take out the trash'),
          _task(
            id: 't2',
            title: 'Water the plants',
            points: 5,
            state: TaskState.approved,
          ),
        ],
        balances: {'Alex': 30},
      );

      await _pumpScreen(
        tester,
        controller: controller,
        profile: _teen(),
      );

      expect(find.text('My To-Do List'), findsOneWidget);
      expect(find.text('1 of 2 done'), findsOneWidget);
      expect(find.text('30 pts'), findsOneWidget);
      expect(find.text('Take out the trash'), findsOneWidget);
      expect(find.text('Water the plants'), findsOneWidget);
      // No emoji anywhere in the skeleton.
      expect(
        find.textContaining(RegExp(r'[\u{1F300}-\u{1FAFF}]', unicode: true)),
        findsNothing,
      );
    });

    testWidgets('filter chips narrow the visible tasks', (tester) async {
      final controller = TasksController.test(
        tasks: [
          _task(id: 't1', title: 'Take out the trash'),
          _task(
            id: 't2',
            title: 'Water the plants',
            state: TaskState.approved,
          ),
        ],
      );

      await _pumpScreen(
        tester,
        controller: controller,
        profile: _teen(),
      );

      // Scope to the filter chips: card status pills reuse similar labels.
      await tester.tap(find.widgetWithText(ChoiceChip, 'Done'));
      await tester.pumpAndSettle();
      expect(find.text('Take out the trash'), findsNothing);
      expect(find.text('Water the plants'), findsOneWidget);

      await tester.tap(find.widgetWithText(ChoiceChip, 'To do'));
      await tester.pumpAndSettle();
      expect(find.text('Take out the trash'), findsOneWidget);
      expect(find.text('Water the plants'), findsNothing);
    });

    testWidgets('tapping a to-do task opens the submission sheet',
        (tester) async {
      final controller = TasksController.test(
        tasks: [_task(id: 't1', title: 'Take out the trash')],
      );

      await _pumpScreen(
        tester,
        controller: controller,
        profile: _teen(),
      );

      await tester.tap(find.text('Take out the trash'));
      await tester.pumpAndSettle();
      expect(find.text('Submit for review'), findsOneWidget);
    });

    testWidgets('shows an empty state when the filter matches nothing',
        (tester) async {
      final controller = TasksController.test(tasks: []);

      await _pumpScreen(
        tester,
        controller: controller,
        profile: _teen(),
      );

      expect(find.text('Nothing assigned yet.'), findsOneWidget);
      expect(find.text('All clear'), findsOneWidget);
    });
  });
}
