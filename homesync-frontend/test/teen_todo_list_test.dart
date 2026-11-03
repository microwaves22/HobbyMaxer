import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:homesync/core/theme/figma_tokens.dart';
import 'package:homesync/views/onboarding/models/user_profile.dart';
import 'package:homesync/views/tasks/models/personal_task.dart';
import 'package:homesync/views/tasks/tasks_controller.dart';
import 'package:homesync/views/tasks/teen_todo_list_screen.dart';

UserProfile _noah() => UserProfile(
      name: 'Noah',
      birthday: DateTime(2011, 6, 15),
      role: FamilyRole.child,
      mode: FamilyMode.teen,
    );

Future<void> _pumpScreen(
  WidgetTester tester, {
  VoidCallback? onBack,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: TeenTodoListScreen(
        controller: TasksController.test(),
        profile: _noah(),
        onBack: onBack,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

TextStyle _styleOf(WidgetTester tester, String text) {
  final widget = tester.widget<Text>(find.text(text).first);
  return widget.style!;
}

void main() {
  group('TeenTodoListScreen (Figma 100:4622)', () {
    testWidgets('renders the Figma content verbatim', (tester) async {
      await _pumpScreen(tester);

      // Identity + intro line (no encouragement banner).
      expect(find.text('Noah · 14 · Teen Mode'), findsOneWidget);
      expect(
        find.text(
          'Your plans, your pace. Personal tasks are just for you — no points or parent review.',
        ),
        findsOneWidget,
      );

      // Add card.
      expect(find.text('New personal task'), findsOneWidget);
      expect(find.text('Outline science project'), findsOneWidget);

      // Personal list.
      expect(find.text('Created by me'), findsOneWidget);
      expect(find.text('1 of 3 done'), findsOneWidget);
      expect(find.text('Read history chapter 4'), findsOneWidget);
      expect(find.text('Homework · Today, 5:00 PM'), findsOneWidget);
      expect(find.text('Run a mile'), findsOneWidget);
      expect(find.text('Personal goal · Sun, Nov 1'), findsOneWidget);
      expect(find.text('Pack soccer bag'), findsOneWidget);
      expect(find.text('Task · Completed today'), findsOneWidget);

      // Parent block.
      expect(find.text('Assigned by Sarah'), findsOneWidget);
      expect(find.text('Math homework'), findsOneWidget);
      expect(find.text('6:00 PM'), findsOneWidget);
      expect(find.text('Vacuum living room'), findsOneWidget);
      expect(find.text('7:00 PM'), findsOneWidget);
      expect(
        find.text(
          'Separate from your list · Photo/video and parent review required for chore points.',
        ),
        findsOneWidget,
      );

      // Bottom nav.
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Rewards'), findsOneWidget);
      expect(find.text('Calendar'), findsOneWidget);

      // Skeleton leftovers are gone: no points pill, no filter chips.
      expect(find.textContaining('pts'), findsNothing);
      expect(find.widgetWithText(ChoiceChip, 'To do'), findsNothing);
      expect(find.widgetWithText(ChoiceChip, 'Done'), findsNothing);

      // No emoji anywhere on this screen.
      expect(
        find.textContaining(RegExp(r'[\u{1F300}-\u{1FAFF}]', unicode: true)),
        findsNothing,
      );
    });

    testWidgets('matches the Figma measurements', (tester) async {
      await _pumpScreen(tester);

      // Background is the teen canvas, not cream.
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, const Color(0xFFF4F3EF));

      // Avatar: 44px sageLight circle with the letter "N".
      final avatar = find.byKey(const Key('teen-todo-avatar'));
      expect(tester.getSize(avatar), const Size(44, 44));
      final avatarGlyph = tester.widget<Text>(
        find.descendant(of: avatar, matching: find.text('N')),
      );
      expect(avatarGlyph.style!.fontSize, 16);
      expect(avatarGlyph.style!.fontWeight, FontWeight.w800);
      expect(avatarGlyph.style!.color, FigmaColors.sageDark);

      // Completion circles are 26px; rows are at least 66px tall.
      for (final task in kTeenPersonalTasks) {
        expect(
          tester.getSize(find.byKey(Key('personal-circle-${task.id}'))),
          const Size(26, 26),
        );
        expect(
          tester.getSize(find.byKey(Key('personal-row-${task.id}'))).height,
          greaterThanOrEqualTo(66),
        );
      }

      // Category chips: 9px vertical padding, selected chip in sage.
      final homeworkChip = tester.widget<ChoiceChip>(
        find.widgetWithText(ChoiceChip, 'Homework'),
      );
      expect(
        homeworkChip.padding,
        const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      );
      expect(homeworkChip.selected, isTrue);
      expect(homeworkChip.selectedColor, FigmaColors.sage);

      // Progress pill: sageLight with computed copy (no "!").
      final pill = tester.widget<Container>(
        find.byKey(const Key('teen-todo-progress-pill')),
      );
      final pillDecoration = pill.decoration! as BoxDecoration;
      expect(pillDecoration.color, FigmaColors.sageLight);

      // List heading size.
      expect(_styleOf(tester, 'Created by me').fontSize, 17);

      // Parent rows: chevrons, no checkboxes anywhere on the screen.
      expect(find.byIcon(Icons.chevron_right_rounded), findsNWidgets(2));
      expect(find.byType(Checkbox), findsNothing);
    });

    testWidgets('toggling a completion circle updates the pill',
        (tester) async {
      await _pumpScreen(tester);

      final firstCircle = find.byKey(const Key('personal-circle-read-history'));
      await tester.ensureVisible(firstCircle);
      await tester.pumpAndSettle();
      await tester.tap(firstCircle);
      await tester.pumpAndSettle();
      expect(find.text('2 of 3 done'), findsOneWidget);

      await tester.tap(firstCircle);
      await tester.pumpAndSettle();
      expect(find.text('1 of 3 done'), findsOneWidget);
    });

    testWidgets('category chips select locally', (tester) async {
      await _pumpScreen(tester);

      final goalChip = find.widgetWithText(ChoiceChip, 'Personal goal');
      await tester.ensureVisible(goalChip);
      await tester.pumpAndSettle();
      await tester.tap(goalChip);
      await tester.pumpAndSettle();

      expect(
        tester.widget<ChoiceChip>(goalChip).selected,
        isTrue,
      );
      expect(
        tester
            .widget<ChoiceChip>(
              find.widgetWithText(ChoiceChip, 'Homework'),
            )
            .selected,
        isFalse,
      );
    });

    testWidgets('bottom nav has Home active', (tester) async {
      await _pumpScreen(tester);

      final home = _styleOf(tester, 'Home');
      expect(home.color, FigmaColors.sage);
      expect(home.fontWeight, FontWeight.w800);

      final rewards = _styleOf(tester, 'Rewards');
      expect(rewards.color, FigmaColors.mute);
      expect(rewards.fontWeight, FontWeight.w600);

      final calendar = _styleOf(tester, 'Calendar');
      expect(calendar.color, FigmaColors.mute);
      expect(calendar.fontWeight, FontWeight.w600);
    });

    testWidgets('back button fires onBack', (tester) async {
      var calls = 0;
      await _pumpScreen(tester, onBack: () => calls++);

      await tester.tap(find.byTooltip('Back'));
      expect(calls, 1);
    });
  });
}
