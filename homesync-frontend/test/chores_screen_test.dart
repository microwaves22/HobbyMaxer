import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:homesync/core/theme/figma_tokens.dart';
import 'package:homesync/views/tasks/chores_screen.dart';

Future<void> _pumpScreen(
  WidgetTester tester, {
  ValueChanged<ChoresSegment>? onSegmentChange,
  ValueChanged<String>? onOpenChore,
  VoidCallback? onNavigateHome,
  VoidCallback? onNavigateRewards,
  VoidCallback? onNavigateCalendar,
}) async {
  tester.view.physicalSize = const Size(375, 812);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      home: ChoresScreen(
        onSegmentChange: onSegmentChange,
        onOpenChore: onOpenChore,
        onNavigateHome: onNavigateHome,
        onNavigateRewards: onNavigateRewards,
        onNavigateCalendar: onNavigateCalendar,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('ChoresScreen (Figma 7:69)', () {
    testWidgets('renders header, segments, 5 rows in order, banner, nav',
        (tester) async {
      await _pumpScreen(tester);

      expect(find.text('Chores'), findsOneWidget);
      expect(find.text('Assigned to me'), findsOneWidget);
      expect(find.text('All tasks'), findsOneWidget);

      // 5 rows in Figma order with exact titles, subtitles, points.
      const titles = [
        'Make bed',
        'Fold laundry',
        'Clean room',
        'Take out trash',
        'Feed pets',
      ];
      var previousDy = -1.0;
      for (final title in titles) {
        final finder = find.text(title);
        expect(finder, findsOneWidget);
        final dy = tester.getTopLeft(finder).dy;
        expect(dy, greaterThan(previousDy), reason: '$title out of order');
        previousDy = dy;
      }
      expect(find.text('Approved by Mom'), findsOneWidget);
      expect(
        find.text('Assigned by Mom • Due today'),
        findsNWidgets(4),
      );
      expect(find.text('+5 pts'), findsOneWidget);
      expect(find.text('+15 pts'), findsNWidgets(2));
      expect(find.text('+10 pts'), findsNWidgets(2));

      // Banner glyph + exact sentence.
      expect(find.text('🏆'), findsOneWidget);
      expect(
        find.text(
          'Take a photo or video when done. Mom reviews it before you earn points.',
        ),
        findsOneWidget,
      );

      // Bottom nav: exactly Home / Rewards / Calendar.
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Rewards'), findsOneWidget);
      expect(find.text('Calendar'), findsOneWidget);
    });

    testWidgets('row 1 is completed (check tile, mute text), rows 2-5 pending',
        (tester) async {
      await _pumpScreen(tester);

      // One sage check tile, four sageLight chevron tiles.
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsNWidgets(4));

      final completedTitle = tester.widget<Text>(find.text('Make bed'));
      expect(completedTitle.style?.color, FigmaColors.mute);
      expect(completedTitle.style?.decoration, isNot(TextDecoration.lineThrough));

      final pendingTitle = tester.widget<Text>(find.text('Fold laundry'));
      expect(pendingTitle.style?.color, FigmaColors.ink);
    });

    testWidgets('segment switch fires handler, keeps the same rows',
        (tester) async {
      ChoresSegment? selected;
      await _pumpScreen(
        tester,
        onSegmentChange: (s) => selected = s,
      );

      await tester.ensureVisible(find.text('All tasks'));
      await tester.tap(find.text('All tasks'));
      await tester.pumpAndSettle();

      expect(selected, ChoresSegment.allTasks);
      // Same 5 rows under both segments (no invented dataset).
      for (final title in [
        'Make bed',
        'Fold laundry',
        'Clean room',
        'Take out trash',
        'Feed pets',
      ]) {
        expect(find.text(title), findsOneWidget);
      }
    });

    testWidgets('row tap and nav taps fire named handlers', (tester) async {
      String? opened;
      var home = 0, rewards = 0, calendar = 0;
      await _pumpScreen(
        tester,
        onOpenChore: (id) => opened = id,
        onNavigateHome: () => home++,
        onNavigateRewards: () => rewards++,
        onNavigateCalendar: () => calendar++,
      );

      await tester.ensureVisible(find.text('Fold laundry'));
      await tester.tap(find.text('Fold laundry'));
      expect(opened, 'fold-laundry');

      await tester.tap(find.text('Home'));
      await tester.tap(find.text('Rewards'));
      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle();
      expect(home, 1);
      expect(rewards, 1);
      expect(calendar, 1);
    });

    testWidgets('Home tab is active (sage ExtraBold)', (tester) async {
      await _pumpScreen(tester);

      final home = tester.widget<Text>(find.text('Home'));
      expect(home.style?.color, FigmaColors.sage);
      expect(home.style?.fontWeight, FontWeight.w800);

      final rewards = tester.widget<Text>(find.text('Rewards'));
      expect(rewards.style?.color, FigmaColors.mute);
      expect(rewards.style?.fontWeight, FontWeight.w600);
    });
  });
}
