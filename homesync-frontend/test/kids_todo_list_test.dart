import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:homesync/core/theme/figma_tokens.dart';
import 'package:homesync/views/tasks/kids_todo_list_screen.dart';

Future<void> _pumpScreen(WidgetTester tester) async {
  await tester.pumpWidget(
    const MaterialApp(home: KidsTodoListScreen()),
  );
  await tester.pumpAndSettle();
}

Future<void> _scrollTo(WidgetTester tester, Finder finder) async {
  // ensureVisible (not scrollUntilVisible): the title TextField owns its
  // own inner scrollable, which makes the default scrollable search
  // ambiguous.
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() {
    // Figma type uses runtime Google Fonts; disable network fetching so
    // widget tests run offline with the fallback font.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('KidsTodoListScreen (Figma node 100:4739)', () {
    testWidgets('renders header, destinations, and banner', (tester) async {
      await _pumpScreen(tester);

      // Title plus the current-destination row share the same label.
      expect(find.text('My To-Do List'), findsNWidgets(2));
      expect(find.text('Ava · 8 · Kids Mode'), findsOneWidget);
      expect(find.text('Assign Tasks'), findsOneWidget);
      expect(find.text('Parent To-Do & Chore Assignment'), findsOneWidget);
      expect(find.text('Parent account only'), findsOneWidget);
      expect(find.text('Current'), findsOneWidget);
      expect(find.text('Little plans, big smiles!'), findsOneWidget);
      expect(
        find.text(
          'Your own tasks are for practice. No points or parent review.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders the add-task form with pre-filled values',
        (tester) async {
      await _pumpScreen(tester);
      await _scrollTo(tester, find.text('Add my own task'));

      expect(find.text('Add my own task'), findsOneWidget);
      expect(find.text('Task title'), findsOneWidget);
      // Entered text, not a placeholder.
      expect(find.text('Practice my spelling'), findsOneWidget);
      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Homework'), findsOneWidget);
      expect(find.text('Personal goal'), findsOneWidget);
      expect(find.text('Task'), findsOneWidget);
      expect(find.text('Due / schedule date'), findsOneWidget);
      expect(find.text('Today, Oct 31 · 4:30 PM'), findsOneWidget);
      expect(find.text('Add Task'), findsOneWidget);
    });

    testWidgets('category chips are single-select', (tester) async {
      await _pumpScreen(tester);
      await _scrollTo(tester, find.text('Add my own task'));

      // Default: Homework selected.
      Text chipText(String label) =>
          tester.widget<Text>(find.text(label));
      expect(chipText('Homework').style?.color, FigmaColors.white);
      expect(chipText('Personal goal').style?.color, FigmaColors.sage);

      await tester.tap(find.byKey(const ValueKey('category-personal-goal')));
      await tester.pumpAndSettle();

      expect(chipText('Personal goal').style?.color, FigmaColors.white);
      expect(chipText('Homework').style?.color, FigmaColors.sage);
      expect(chipText('Task').style?.color, FigmaColors.sage);
    });

    testWidgets('renders the Made by me list with a derived pill',
        (tester) async {
      await _pumpScreen(tester);
      await _scrollTo(tester, find.text('Made by me'));

      expect(find.text('Made by me'), findsOneWidget);
      expect(find.text('1 of 3 done!'), findsOneWidget);
      expect(find.text('Read my library book'), findsOneWidget);
      expect(find.text('Homework · Today, 5:00 PM'), findsOneWidget);
      expect(find.text('Learn to draw a cat'), findsOneWidget);
      expect(find.text('Personal goal · Tomorrow'), findsOneWidget);
      expect(find.text('Pack my crayons'), findsOneWidget);
      expect(find.text('Task · All done today!'), findsOneWidget);

      // Only the completed task is struck through.
      final doneTitle = tester.widget<Text>(find.text('Pack my crayons'));
      expect(doneTitle.style?.decoration, TextDecoration.lineThrough);
      expect(doneTitle.style?.color, FigmaColors.mute);
      final todoTitle =
          tester.widget<Text>(find.text('Read my library book'));
      expect(todoTitle.style?.decoration, TextDecoration.none);
      expect(todoTitle.style?.color, FigmaColors.ink);
    });

    testWidgets('toggling completion updates the pill', (tester) async {
      await _pumpScreen(tester);
      await _scrollTo(tester, find.text('Read my library book'));

      await tester.tap(find.byKey(const ValueKey('complete-read-book')));
      await tester.pumpAndSettle();
      expect(find.text('2 of 3 done!'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('complete-pack-crayons')));
      await tester.pumpAndSettle();
      expect(find.text('1 of 3 done!'), findsOneWidget);
    });

    testWidgets('Add Task appends to the Made by me list locally',
        (tester) async {
      await _pumpScreen(tester);
      await _scrollTo(tester, find.text('Add Task'));

      await tester.tap(find.byKey(const ValueKey('kids-add-task')));
      await tester.pumpAndSettle();

      expect(find.text('1 of 4 done!'), findsOneWidget);
      // Form value plus the new row share the title.
      expect(find.text('Practice my spelling'), findsNWidgets(2));
      expect(
        find.text('Homework · Today, Oct 31 · 4:30 PM'),
        findsOneWidget,
      );
    });

    testWidgets('locked destination does not navigate', (tester) async {
      await _pumpScreen(tester);

      await tester.tap(
        find.byKey(const ValueKey('destination-parent-assignment')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ava · 8 · Kids Mode'), findsOneWidget);
      expect(find.text('My To-Do List'), findsNWidgets(2));
    });

    testWidgets('renders parent chores, nav, and no points', (tester) async {
      await _pumpScreen(tester);
      await _scrollTo(tester, find.text('Chores from Mom'));

      expect(find.text('Chores from Mom'), findsOneWidget);
      expect(find.text('Clean your desk'), findsOneWidget);
      expect(
        find.text('Separate from my list · Parent review for points'),
        findsOneWidget,
      );

      await _scrollTo(tester, find.text('Calendar'));
      expect(find.byKey(const ValueKey('nav-home')), findsOneWidget);
      expect(find.byKey(const ValueKey('nav-rewards')), findsOneWidget);
      expect(find.byKey(const ValueKey('nav-calendar')), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Rewards'), findsOneWidget);
      expect(find.text('Calendar'), findsOneWidget);

      // Personal tasks earn nothing: no points anywhere on this screen.
      expect(find.textContaining('pts'), findsNothing);
    });
  });
}
