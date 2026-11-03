import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:homesync/views/tasks/assign_tasks_screen.dart';

Future<void> _pumpScreen(WidgetTester tester) async {
  await tester.pumpWidget(
    const MaterialApp(home: AssignTasksScreen()),
  );
  await tester.pumpAndSettle();
}

Finder _checkBadges() => find.byWidgetPredicate(
      (w) => w is Icon && w.icon == Icons.check_rounded,
    );

void main() {
  setUpAll(() {
    // Figma type uses runtime Google Fonts; disable network fetching so
    // widget tests run offline with the fallback font.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  test('data arrays match the spec shape and initial selection', () {
    expect(
      taskOptions.map((t) => t.id),
      [
        'laundry',
        'wash-dishes',
        'make-bed',
        'clean-room',
        'take-out-trash',
        'feed-pets',
        'homework',
        'vacuum',
      ],
    );
    expect(
      taskOptions.where((t) => t.selected).map((t) => t.id),
      ['laundry', 'make-bed'],
    );
    expect(
      assignees.map((a) => a.id),
      ['ava', 'noah', 'both'],
    );
    expect(
      assignees.where((a) => a.selected).map((a) => a.id),
      ['ava'],
    );
  });

  group('AssignTasksScreen (Figma node 4:30)', () {
    testWidgets('renders every section with exact copy', (tester) async {
      await _pumpScreen(tester);

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, const Color(0xFFFBF7EF));

      // Top bar trigger + open menu.
      expect(find.text('Assign Tasks'), findsOneWidget);
      expect(
        find.text('Parent To-Do & Chore Assignment'),
        findsOneWidget,
      );
      expect(find.text('My To-Do List'), findsOneWidget);

      // Heading + parent note.
      expect(
        find.text('What tasks would you like to assign to your kids?'),
        findsOneWidget,
      );
      expect(find.text('Parent account'), findsOneWidget);
      expect(
        find.text(
          'Kids submit a photo or video when done.\n'
          'You review before points are awarded.',
        ),
        findsOneWidget,
      );

      // All 8 tiles render from the data array.
      for (final label in [
        'Laundry',
        'Wash Dishes',
        'Make Bed',
        'Clean Room',
        'Take Out Trash',
        'Feed Pets',
        'Homework',
        'Vacuum',
      ]) {
        expect(find.text(label), findsOneWidget, reason: label);
      }

      expect(find.text('Add Custom Task'), findsOneWidget);
      expect(find.text('Assign to:'), findsOneWidget);
      expect(find.text('Ava'), findsOneWidget);
      expect(find.text('Noah'), findsOneWidget);
      expect(find.text('Both'), findsOneWidget);

      await tester.ensureVisible(find.text('Due: Today, 7:00 PM'));
      await tester.pumpAndSettle();
      expect(find.text('Due: Today, 7:00 PM'), findsOneWidget);

      await tester.ensureVisible(find.text('Assign Tasks  →'));
      await tester.pumpAndSettle();
      expect(find.text('Assign Tasks  →'), findsOneWidget);

      // Exactly three checks: menu option 1 + Laundry + Make Bed.
      expect(_checkBadges(), findsNWidgets(3));
    });

    testWidgets('tapping a tile toggles its check badge', (tester) async {
      await _pumpScreen(tester);
      expect(_checkBadges(), findsNWidgets(3));

      await tester.tap(find.text('Wash Dishes'));
      await tester.pumpAndSettle();
      expect(_checkBadges(), findsNWidgets(4));

      await tester.tap(find.text('Wash Dishes'));
      await tester.pumpAndSettle();
      expect(_checkBadges(), findsNWidgets(3));

      await tester.tap(find.text('Laundry'));
      await tester.pumpAndSettle();
      expect(_checkBadges(), findsNWidgets(2));
    });

    testWidgets('assignee selection is single-select starting with Ava',
        (tester) async {
      await _pumpScreen(tester);

      TextStyle styleOf(String name) =>
          tester.widget<Text>(find.text(name)).style!;

      expect(styleOf('Ava').color, const Color(0xFF5F7F55));
      expect(styleOf('Ava').fontWeight, FontWeight.w800);
      expect(styleOf('Noah').color, const Color(0xFF7C877A));
      expect(styleOf('Noah').fontWeight, FontWeight.w600);
      expect(styleOf('Both').color, const Color(0xFF7C877A));

      await tester.ensureVisible(find.text('Noah'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Noah'));
      await tester.pumpAndSettle();

      expect(styleOf('Noah').color, const Color(0xFF5F7F55));
      expect(styleOf('Noah').fontWeight, FontWeight.w800);
      expect(styleOf('Ava').color, const Color(0xFF7C877A));
      expect(styleOf('Ava').fontWeight, FontWeight.w600);
    });

    testWidgets('dropdown trigger toggles the open menu', (tester) async {
      await _pumpScreen(tester);
      expect(
        find.text('Parent To-Do & Chore Assignment'),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const ValueKey('assign-menu-trigger')));
      await tester.pumpAndSettle();
      expect(find.text('Parent To-Do & Chore Assignment'), findsNothing);
      expect(find.text('My To-Do List'), findsNothing);

      await tester.tap(find.byKey(const ValueKey('assign-menu-trigger')));
      await tester.pumpAndSettle();
      expect(
        find.text('Parent To-Do & Chore Assignment'),
        findsOneWidget,
      );
    });

    testWidgets('menu options swap selection locally without navigating',
        (tester) async {
      await _pumpScreen(tester);

      Color? optionColor(String key) {
        final container =
            tester.widget<Container>(find.byKey(ValueKey(key)));
        return (container.decoration! as BoxDecoration).color;
      }

      expect(
        optionColor('assign-menu-option-parent'),
        const Color(0xFFE4EBDC),
      );
      expect(optionColor('assign-menu-option-my-todo'), isNull);

      await tester.tap(find.text('My To-Do List'));
      await tester.pumpAndSettle();

      expect(optionColor('assign-menu-option-parent'), isNull);
      expect(
        optionColor('assign-menu-option-my-todo'),
        const Color(0xFFE4EBDC),
      );
      // Still on this screen: heading and tiles intact.
      expect(
        find.text('What tasks would you like to assign to your kids?'),
        findsOneWidget,
      );
      expect(find.text('Laundry'), findsOneWidget);
    });

    testWidgets('placeholder handlers do not navigate or crash',
        (tester) async {
      await _pumpScreen(tester);

      await tester.tap(find.byKey(const ValueKey('assign-back')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('assign-settings')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('add-custom-task')));
      await tester.tap(find.byKey(const ValueKey('add-custom-task')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('due-row')));
      await tester.tap(find.byKey(const ValueKey('due-row')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('assign-button')));
      await tester.tap(find.byKey(const ValueKey('assign-button')));
      await tester.pumpAndSettle();

      expect(
        find.text('What tasks would you like to assign to your kids?'),
        findsOneWidget,
      );
    });

    testWidgets('matches exact spec geometry, colors, and typography',
        (tester) async {
      await _pumpScreen(tester);

      TextStyle styleOf(String text) =>
          tester.widget<Text>(find.text(text)).style!;

      // Body padding: 20px sides, 6px top, 30px bottom.
      final scroll = tester.widget<SingleChildScrollView>(
        find.byType(SingleChildScrollView),
      );
      expect(scroll.padding, const EdgeInsets.fromLTRB(20, 6, 20, 30));

      // Heading: ExtraBold 20px/27px, centered.
      const heading = 'What tasks would you like to assign to your kids?';
      expect(styleOf(heading).fontSize, 20);
      expect(styleOf(heading).fontWeight, FontWeight.w800);
      expect(styleOf(heading).color, const Color(0xFF2B3A2B));
      expect(styleOf(heading).height, closeTo(27 / 20, 0.001));
      expect(
        tester.widget<Text>(find.text(heading)).textAlign,
        TextAlign.center,
      );

      // Parent note typography.
      expect(styleOf('Parent account').fontSize, 12);
      expect(styleOf('Parent account').fontWeight, FontWeight.w700);
      expect(styleOf('Parent account').color, const Color(0xFF5F7F55));
      const noteBody = 'Kids submit a photo or video when done.\n'
          'You review before points are awarded.';
      expect(styleOf(noteBody).fontSize, 13);
      expect(styleOf(noteBody).fontWeight, FontWeight.w700);
      expect(styleOf(noteBody).color, const Color(0xFF2B3A2B));
      expect(styleOf(noteBody).height, closeTo(18 / 13, 0.001));

      // Menu option typography: ExtraBold when selected, Bold otherwise.
      expect(
        styleOf('Parent To-Do & Chore Assignment').fontWeight,
        FontWeight.w800,
      );
      expect(styleOf('My To-Do List').fontWeight, FontWeight.w700);

      // Back button: 38x38, radius 19, white.
      final backBox = tester.widget<Container>(
        find.descendant(
          of: find.byKey(const ValueKey('assign-back')),
          matching: find.byType(Container),
        ),
      );
      expect(
        tester.getSize(
          find.descendant(
            of: find.byKey(const ValueKey('assign-back')),
            matching: find.byType(Container),
          ),
        ),
        const Size(38, 38),
      );
      expect(
        (backBox.decoration! as BoxDecoration).borderRadius,
        BorderRadius.circular(19),
      );

      // Menu container radius 18, options radius 14.
      expect(
        (tester
                    .widget<Container>(find.byKey(const ValueKey('assign-menu')))
                    .decoration! as BoxDecoration)
                .borderRadius,
        BorderRadius.circular(18),
      );
      expect(
        (tester
                    .widget<Container>(
                      find.byKey(const ValueKey('assign-menu-option-parent')),
                    )
                    .decoration! as BoxDecoration)
                .borderRadius,
        BorderRadius.circular(14),
      );

      // Tiles: radius 18, 162.5px wide (335 content, 10 gap), at least
      // 58px tall (exactly 58 at design size; rows equalize upward if a
      // label wraps under wider font metrics instead of clipping).
      // 36px icon boxes carry the exact pastel per tile.
      const pastels = {
        'laundry': 0xFFCFE0EE,
        'wash-dishes': 0xFFE4EBDC,
        'make-bed': 0xFFDDD5EE,
        'clean-room': 0xFFF6D9C4,
        'take-out-trash': 0xFFE4EBDC,
        'feed-pets': 0xFFFDF0C8,
        'homework': 0xFFF4C9C9,
        'vacuum': 0xFFCFE0EE,
      };
      final tileHeights = <String, double>{};
      for (final entry in pastels.entries) {
        final tile = find.byKey(ValueKey('task-${entry.key}'));
        await tester.ensureVisible(tile);
        await tester.pumpAndSettle();
        final decoration =
            tester.widget<Container>(tile).decoration! as BoxDecoration;
        expect(
          decoration.borderRadius,
          BorderRadius.circular(18),
          reason: entry.key,
        );
        final size = tester.getSize(tile);
        tileHeights[entry.key] = size.height;
        expect(size.width, 162.5, reason: entry.key);
        expect(size.height, greaterThanOrEqualTo(58), reason: entry.key);
        final iconBox = find.byKey(ValueKey('task-icon-${entry.key}'));
        expect(tester.getSize(iconBox), const Size(36, 36), reason: entry.key);
        final iconDecoration =
            tester.widget<Container>(iconBox).decoration! as BoxDecoration;
        expect(iconDecoration.color, Color(entry.value), reason: entry.key);
        expect(
          iconDecoration.borderRadius,
          BorderRadius.circular(12),
          reason: entry.key,
        );
      }

      // Both tiles in a row share one height.
      const rows = [
        ['laundry', 'wash-dishes'],
        ['make-bed', 'clean-room'],
        ['take-out-trash', 'feed-pets'],
        ['homework', 'vacuum'],
      ];
      for (final row in rows) {
        expect(
          tileHeights[row[0]],
          tileHeights[row[1]],
          reason: row.join(' + '),
        );
      }

      // Only Laundry and Make Bed show the sage check badge.
      for (final id in ['laundry', 'make-bed']) {
        final badge = find.byKey(ValueKey('task-badge-$id'));
        expect(badge, findsOneWidget, reason: id);
        expect(tester.getSize(badge), const Size(20, 20), reason: id);
      }
      for (final id in [
        'wash-dishes',
        'clean-room',
        'take-out-trash',
        'feed-pets',
        'homework',
        'vacuum',
      ]) {
        expect(find.byKey(ValueKey('task-badge-$id')), findsNothing,
            reason: id);
      }

      // Add Custom Task: no fill (dashed border is painted, not a bg).
      final customFill = tester.widget<Container>(
        find.descendant(
          of: find.byKey(const ValueKey('add-custom-task')),
          matching: find.byType(Container),
        ),
      );
      expect(customFill.decoration, isNull);
      expect(styleOf('Add Custom Task').fontSize, 14);
      expect(styleOf('Add Custom Task').fontWeight, FontWeight.w700);
      expect(styleOf('Add Custom Task').color, const Color(0xFF5F7F55));

      // Avatars: 50px, radius 25; only Ava has the 3px sage ring.
      for (final id in ['ava', 'noah', 'both']) {
        final avatar = find.byKey(ValueKey('assignee-avatar-$id'));
        await tester.ensureVisible(avatar);
        await tester.pumpAndSettle();
        expect(tester.getSize(avatar), const Size(50, 50), reason: id);
        final decoration =
            tester.widget<Container>(avatar).decoration! as BoxDecoration;
        expect(decoration.borderRadius, BorderRadius.circular(25),
            reason: id);
        expect(
          decoration.border,
          id == 'ava'
              ? Border.all(color: const Color(0xFF5F7F55), width: 3)
              : isNull,
          reason: id,
        );
      }

      // Due row: radius 16, 1px solid #E8E4D8 border, no shadow.
      final dueBox = tester.widget<Container>(
        find.descendant(
          of: find.byKey(const ValueKey('due-row')),
          matching: find.byType(Container),
        ),
      );
      final dueDecoration = dueBox.decoration! as BoxDecoration;
      expect(dueDecoration.borderRadius, BorderRadius.circular(16));
      expect(
        dueDecoration.border,
        Border.all(color: const Color(0xFFE8E4D8), width: 1),
      );
      expect(dueDecoration.boxShadow, isNull);
      expect(styleOf('Due: Today, 7:00 PM').fontSize, 14);
      expect(styleOf('Due: Today, 7:00 PM').fontWeight, FontWeight.w700);

      // Spacer + primary button: 54px tall, radius 18, sage.
      expect(
        find.byWidgetPredicate(
          (w) => w is SizedBox && w.height == 115,
        ),
        findsOneWidget,
      );
      final buttonBox = find.descendant(
        of: find.byKey(const ValueKey('assign-button')),
        matching: find.byType(Container),
      );
      await tester.ensureVisible(buttonBox);
      await tester.pumpAndSettle();
      expect(tester.getSize(buttonBox).height, 54);
      final buttonDecoration =
          tester.widget<Container>(buttonBox).decoration! as BoxDecoration;
      expect(buttonDecoration.color, const Color(0xFF5F7F55));
      expect(
        buttonDecoration.borderRadius,
        BorderRadius.circular(18),
      );
      const buttonLabel = 'Assign Tasks  →';
      expect(styleOf(buttonLabel).fontSize, 16);
      expect(styleOf(buttonLabel).fontWeight, FontWeight.w800);
      expect(styleOf(buttonLabel).color, const Color(0xFFFFFFFF));
    });
  });
}
