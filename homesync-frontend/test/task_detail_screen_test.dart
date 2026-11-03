import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:homesync/core/theme/figma_tokens.dart';
import 'package:homesync/views/tasks/task_detail_screen.dart';

Future<void> _pumpScreen(
  WidgetTester tester, {
  TaskDetailData task = foldLaundryTask,
  VoidCallback? onBack,
  VoidCallback? onAddPhoto,
  VoidCallback? onSkipPhoto,
  VoidCallback? onSubmitForReview,
}) async {
  tester.view.physicalSize = const Size(375, 812);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      home: TaskDetailScreen(
        task: task,
        onBack: onBack,
        onAddPhoto: onAddPhoto,
        onSkipPhoto: onSkipPhoto,
        onSubmitForReview: onSubmitForReview,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('TaskDetailScreen (Figma 7:157)', () {
    testWidgets('renders hero, instructions, due date, proof, button',
        (tester) async {
      await _pumpScreen(tester);

      // Hero.
      expect(find.text('🧺'), findsOneWidget);
      expect(find.text('Fold Laundry'), findsOneWidget);
      expect(find.text('+15 pts'), findsOneWidget);

      // Instructions card: heading + 3 steps in order.
      expect(find.text('Instructions'), findsOneWidget);
      const steps = [
        'Fold all clean clothes',
        'Put them in your dresser',
        'Place socks in the top drawer',
      ];
      var previousDy = -1.0;
      for (final step in steps) {
        final finder = find.text(step);
        expect(finder, findsOneWidget);
        final dy = tester.getTopLeft(finder).dy;
        expect(dy, greaterThan(previousDy), reason: '$step out of order');
        previousDy = dy;
      }

      // Due Date row.
      expect(find.text('Due Date'), findsOneWidget);
      expect(find.text('Today by 7:00 PM'), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);

      // Proof card.
      expect(find.text('Proof for Mom'), findsOneWidget);
      expect(find.text('Assigned by Mom'), findsOneWidget);
      expect(find.text('Parent review'), findsOneWidget);
      expect(find.text('Add a photo · optional'), findsOneWidget);
      expect(
        find.text(
          'Share your folded clothes if you like. Mom reviews the task before awarding 15 points.',
        ),
        findsOneWidget,
      );

      // Options: "Add photo" (camera) + "Skip photo" (VIDEO icon), as designed.
      expect(find.text('Add photo'), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
      expect(find.text('Skip photo'), findsOneWidget);
      expect(find.byIcon(Icons.videocam), findsOneWidget);

      // Primary button, and no bottom navigation anywhere.
      expect(find.text('Submit for Review'), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsNothing);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('top bar is back button plus empty spacer, no title',
        (tester) async {
      await _pumpScreen(tester);

      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      // No AppBar/title text besides the screen's specified copy.
      expect(find.byType(AppBar), findsNothing);
    });

    testWidgets('screen renders from the data object', (tester) async {
      const custom = TaskDetailData(
        id: 'custom',
        title: 'Custom Title',
        glyph: '🧺',
        iconTileColor: Color(0xFFCFE0EE),
        points: 7,
        instructions: ['Only step'],
        dueLabel: 'Due Date',
        dueValue: 'Tomorrow',
        proofTitle: 'Proof for Dad',
        proofSubtitle: 'Assigned by Dad',
        proofBadge: 'Needs review',
        proofHeading: 'Heading here',
        proofBody: 'Body here',
      );
      await _pumpScreen(tester, task: custom);

      expect(find.text('Custom Title'), findsOneWidget);
      expect(find.text('+7 pts'), findsOneWidget);
      expect(find.text('Only step'), findsOneWidget);
      expect(find.text('Tomorrow'), findsOneWidget);
      expect(find.text('Proof for Dad'), findsOneWidget);
      expect(find.text('Needs review'), findsOneWidget);
      expect(find.text('Fold Laundry'), findsNothing);
    });

    testWidgets('named handlers fire', (tester) async {
      var back = 0, addPhoto = 0, skipPhoto = 0, submit = 0;
      await _pumpScreen(
        tester,
        onBack: () => back++,
        onAddPhoto: () => addPhoto++,
        onSkipPhoto: () => skipPhoto++,
        onSubmitForReview: () => submit++,
      );

      for (final target in [
        find.byIcon(Icons.chevron_left),
        find.text('Add photo'),
        find.text('Skip photo'),
        find.text('Submit for Review'),
      ]) {
        await tester.ensureVisible(target);
        await tester.tap(target);
      }
      await tester.pumpAndSettle();

      expect(back, 1);
      expect(addPhoto, 1);
      expect(skipPhoto, 1);
      expect(submit, 1);
    });

    testWidgets('points pill uses the yellowLight token', (tester) async {
      await _pumpScreen(tester);

      // The pill behind "+15 pts" carries the Figma pastelYellow fill.
      final pillText = find.text('+15 pts');
      final pill = tester.widget<Container>(
        find.ancestor(of: pillText, matching: find.byType(Container)).first,
      );
      final decoration = pill.decoration! as BoxDecoration;
      expect(decoration.color, FigmaColors.pastelYellow);
      expect(decoration.borderRadius, BorderRadius.circular(18));
    });
  });
}
