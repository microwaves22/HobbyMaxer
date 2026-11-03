import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:homesync/views/onboarding/models/user_profile.dart';
import 'package:homesync/views/tasks/tasks_controller.dart';
import 'package:homesync/views/tasks/teen_todo_list_screen.dart';

UserProfile _noah() => UserProfile(
      name: 'Noah',
      birthday: DateTime(2012, 3, 9),
      role: FamilyRole.child,
      mode: FamilyMode.teen,
    );

Future<void> _pumpScreen(
  WidgetTester tester, {
  TeenTodoListScreen Function()? build,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: build?.call() ??
          TeenTodoListScreen(
            controller: TasksController.test(),
            profile: _noah(),
          ),
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

  group('TeenTodoListScreen (Figma 100:4622)', () {
    testWidgets('renders identity, plain line, and add card', (tester) async {
      await _pumpScreen(tester);

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, const Color(0xFFF4F3EF));

      expect(find.text('My To-Do List'), findsOneWidget);
      expect(find.text('Noah · 14 · Teen Mode'), findsOneWidget);
      expect(find.text('N'), findsOneWidget);

      // Plain line replaces the kids encouragement banner.
      expect(
        find.text(
          'Your plans, your pace. Personal tasks are just for you — '
          'no points or parent review.',
        ),
        findsOneWidget,
      );
      expect(find.text('Little plans, big smiles!'), findsNothing);

      expect(find.text('New personal task'), findsOneWidget);
      expect(find.text('Outline science project'), findsOneWidget);
      expect(find.text('Add my own task'), findsNothing);
    });

    testWidgets('renders the 3 personal tasks with a computed pill',
        (tester) async {
      await _pumpScreen(tester);

      expect(find.text('Created by me'), findsOneWidget);
      expect(find.text('1 of 3 done'), findsOneWidget);
      expect(find.text('1 of 3 done!'), findsNothing);

      expect(find.text('Read history chapter 4'), findsOneWidget);
      expect(find.text('Homework · Today, 5:00 PM'), findsOneWidget);
      expect(find.text('Run a mile'), findsOneWidget);
      expect(find.text('Personal goal · Sun, Nov 1'), findsOneWidget);
      expect(find.text('Pack soccer bag'), findsOneWidget);
      expect(find.text('Task · Completed today'), findsOneWidget);
    });

    testWidgets('renders the parent block with two rows, no checkboxes',
        (tester) async {
      await _pumpScreen(tester);

      expect(find.text('Assigned by Sarah'), findsOneWidget);
      expect(find.text('Math homework'), findsOneWidget);
      expect(find.text('6:00 PM'), findsOneWidget);
      expect(find.text('Vacuum living room'), findsOneWidget);
      expect(find.text('7:00 PM'), findsOneWidget);
      expect(
        find.text(
          'Separate from your list · Photo/video and parent review '
          'required for chore points.',
        ),
        findsOneWidget,
      );
      expect(find.byType(Checkbox), findsNothing);
    });

    testWidgets('bottom nav has Home active', (tester) async {
      await _pumpScreen(tester);

      await tester.ensureVisible(find.text('Calendar'));
      final home = tester.widget<Text>(find.text('Home'));
      expect(home.style?.color, const Color(0xFF5F7F55));
      final rewards = tester.widget<Text>(find.text('Rewards'));
      expect(rewards.style?.color, const Color(0xFF7C877A));
    });

    testWidgets('toggling a task updates the pill', (tester) async {
      await _pumpScreen(tester);

      final toggle = find.byKey(const ValueKey('teen-complete-run-mile'));
      await tester.ensureVisible(toggle);
      await tester.tap(toggle);
      await tester.pumpAndSettle();

      expect(find.text('2 of 3 done'), findsOneWidget);
    });

    testWidgets('adding a task appends it to the list', (tester) async {
      final controller = TasksController.test();
      await _pumpScreen(
        tester,
        build: () => TeenTodoListScreen(
          controller: controller,
          profile: _noah(),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('teen-add-task')));
      await tester.pumpAndSettle();

      expect(find.text('Outline science project'), findsNWidgets(2));
      expect(find.text('1 of 4 done'), findsOneWidget);
    });

    testWidgets('category chips and parent rows report taps', (tester) async {
      String? category;
      String? chore;
      await _pumpScreen(
        tester,
        build: () => TeenTodoListScreen(
          controller: TasksController.test(),
          profile: _noah(),
          onSelectCategory: (id) => category = id,
          onParentChorePress: (id) => chore = id,
        ),
      );

      await tester.tap(find.text('Personal goal'));
      await tester.pumpAndSettle();
      expect(category, 'personal-goal');

      await tester.ensureVisible(find.text('Math homework'));
      await tester.tap(find.text('Math homework'));
      await tester.pumpAndSettle();
      expect(chore, 'math-homework');
    });
  });
}
