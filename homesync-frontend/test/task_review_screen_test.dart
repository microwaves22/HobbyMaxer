import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:homesync/core/theme/figma_tokens.dart';
import 'package:homesync/views/tasks/task_review_screen.dart';

Future<void> _pumpScreen(
  WidgetTester tester, {
  TaskReviewData review = const TaskReviewData(),
  ValueChanged<ReviewQueue>? onSwitchReviewQueue,
  VoidCallback? onBackToNotifications,
  VoidCallback? onOpenProfile,
  VoidCallback? onApproveAndAward,
  VoidCallback? onRequestChanges,
  VoidCallback? onNavigateHome,
  VoidCallback? onNavigateCalendar,
  VoidCallback? onNavigateTasks,
  VoidCallback? onNavigateFamily,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: TaskReviewScreen(
        review: review,
        onSwitchReviewQueue: onSwitchReviewQueue,
        onBackToNotifications: onBackToNotifications,
        onOpenProfile: onOpenProfile,
        onApproveAndAward: onApproveAndAward,
        onRequestChanges: onRequestChanges,
        onNavigateHome: onNavigateHome,
        onNavigateCalendar: onNavigateCalendar,
        onNavigateTasks: onNavigateTasks,
        onNavigateFamily: onNavigateFamily,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _scrollTo(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() {
    // Figma type uses runtime Google Fonts; disable network fetching so
    // widget tests run offline with the fallback font.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('TaskReviewScreen (Figma node 62:6347)', () {
    testWidgets('renders queue tabs with Task Reviews active', (
      tester,
    ) async {
      await _pumpScreen(tester);

      expect(find.text('Task Reviews'), findsOneWidget);
      expect(find.text('Reward Requests'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);

      Text tabText(String label) => tester.widget<Text>(find.text(label));
      // Active tab: sage label; inactive tab: ink label.
      expect(tabText('Task Reviews').style?.color, FigmaColors.sage);
      expect(tabText('Reward Requests').style?.color, FigmaColors.ink);
    });

    testWidgets('renders header, submission card, and due row', (
      tester,
    ) async {
      await _pumpScreen(tester);

      expect(find.text('Task Review'), findsOneWidget);
      expect(
        find.text('Sarah · 1 of 2 pending approvals'),
        findsOneWidget,
      );
      expect(find.text('👩'), findsOneWidget);

      expect(find.text('Ava · 8'), findsOneWidget);
      expect(find.text('Submitted for your review'), findsOneWidget);
      expect(find.text('Pending review'), findsOneWidget);
      expect(find.text('Fold Laundry'), findsOneWidget);
      expect(find.text('★ +15 pts'), findsOneWidget);
      expect(find.text('Due today by 7 PM'), findsOneWidget);
      expect(find.byIcon(Icons.schedule_rounded), findsOneWidget);
    });

    testWidgets('renders evidence, instructions, and safeguard verbatim', (
      tester,
    ) async {
      await _pumpScreen(tester);

      expect(find.text('Submission details'), findsOneWidget);
      expect(find.text('1 photo'), findsOneWidget);
      expect(
        find.text('Sample evidence · illustrative photo'),
        findsOneWidget,
      );
      expect(find.text('Instructions'), findsOneWidget);
      expect(find.text('Fold all clean clothes'), findsOneWidget);
      expect(find.text('Put them in your dresser'), findsOneWidget);
      expect(find.text('Place socks in the top drawer'), findsOneWidget);
      expect(find.text('Assigned by Mom'), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsNWidgets(3));

      await _scrollTo(
        tester,
        find.text('Ava’s balance is still 120 points'),
      );
      expect(
        find.text('Ava’s balance is still 120 points'),
        findsOneWidget,
      );
      expect(
        find.text(
          'Pending review adds no points. Approval awards 15 points once, '
          'bringing the balance to 135.',
        ),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.gpp_good_rounded), findsOneWidget);
    });

    testWidgets('renders actions and bottom nav with Tasks active', (
      tester,
    ) async {
      await _pumpScreen(tester);

      await _scrollTo(tester, find.text('Approve & Award 15 Points'));
      expect(find.text('Approve & Award 15 Points'), findsOneWidget);
      expect(find.text('Request Changes'), findsOneWidget);
      expect(
        find.text(
          'Request Changes returns this task to Ava with your feedback, '
          'without awarding points.',
        ),
        findsOneWidget,
      );

      // Bottom nav order: Home / Calendar / Tasks / Family, no Rewards.
      final navLabels = ['Home', 'Calendar', 'Tasks', 'Family'];
      for (final label in navLabels) {
        expect(find.text(label), findsOneWidget);
      }
      expect(find.text('Rewards'), findsNothing);

      final dx = <String, double>{
        for (final label in navLabels)
          label: tester.getCenter(find.text(label)).dx,
      };
      expect(
        [dx['Home']!, dx['Calendar']!, dx['Tasks']!, dx['Family']!],
        orderedEquals(
          [dx['Home']!, dx['Calendar']!, dx['Tasks']!, dx['Family']!]
            ..sort(),
        ),
      );

      Text navText(String label) => tester.widget<Text>(find.text(label));
      expect(navText('Tasks').style?.color, FigmaColors.sage);
      expect(navText('Tasks').style?.fontWeight, FontWeight.w800);
      expect(navText('Home').style?.color, FigmaColors.mute);
      expect(navText('Calendar').style?.color, FigmaColors.mute);
      expect(navText('Family').style?.color, FigmaColors.mute);
    });

    testWidgets('queue switch is local state and fires the handler', (
      tester,
    ) async {
      ReviewQueue? switched;
      await _pumpScreen(
        tester,
        onSwitchReviewQueue: (queue) => switched = queue,
      );

      await tester.tap(find.byKey(const ValueKey('queue-reward-requests')));
      await tester.pumpAndSettle();

      expect(switched, ReviewQueue.rewardRequests);
      // Counts do not change; the active treatment moves.
      expect(find.text('2'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      Text tabText(String label) => tester.widget<Text>(find.text(label));
      expect(tabText('Reward Requests').style?.color, FigmaColors.sage);
      expect(tabText('Task Reviews').style?.color, FigmaColors.ink);
    });

    testWidgets('action and navigation handlers fire as stubs', (
      tester,
    ) async {
      var approved = 0;
      var changes = 0;
      var back = 0;
      var profile = 0;
      var home = 0;
      var calendar = 0;
      var tasks = 0;
      var family = 0;
      await _pumpScreen(
        tester,
        onBackToNotifications: () => back++,
        onOpenProfile: () => profile++,
        onApproveAndAward: () => approved++,
        onRequestChanges: () => changes++,
        onNavigateHome: () => home++,
        onNavigateCalendar: () => calendar++,
        onNavigateTasks: () => tasks++,
        onNavigateFamily: () => family++,
      );

      await tester.tap(find.byKey(const ValueKey('review-back')));
      await tester.tap(find.byKey(const ValueKey('review-profile')));
      await tester.pumpAndSettle();
      expect(back, 1);
      expect(profile, 1);

      await _scrollTo(tester, find.text('Approve & Award 15 Points'));
      await tester.tap(find.byKey(const ValueKey('review-approve')));
      await tester.tap(
        find.byKey(const ValueKey('review-request-changes')),
      );
      await tester.pumpAndSettle();
      expect(approved, 1);
      expect(changes, 1);

      await tester.tap(find.byKey(const ValueKey('nav-home')));
      await tester.tap(find.byKey(const ValueKey('nav-calendar')));
      await tester.tap(find.byKey(const ValueKey('nav-tasks')));
      await tester.tap(find.byKey(const ValueKey('nav-family')));
      await tester.pumpAndSettle();
      expect(home, 1);
      expect(calendar, 1);
      expect(tasks, 1);
      expect(family, 1);
    });

    testWidgets('layout sizes match the spec', (tester) async {
      await _pumpScreen(tester);

      // Evidence photo: local asset at exactly 154x208.
      final image = tester.widget<Image>(find.byType(Image));
      expect(image.image, isA<AssetImage>());
      expect(
        (image.image as AssetImage).assetName,
        'assets/folded-laundry-sample.png',
      );
      expect(tester.getSize(find.byType(Image)), const Size(154, 208));

      // Side by side: the instructions heading sits right of the photo
      // within the photo's vertical span (never stacked below it).
      final photo = tester.getRect(find.byType(Image));
      final instructions = tester.getRect(find.text('Instructions'));
      expect(instructions.left, greaterThan(photo.right));
      expect(instructions.center.dy, greaterThan(photo.top));
      expect(instructions.center.dy, lessThan(photo.bottom));

      // Review actions: 54px primary, 50px-minimum secondary.
      await _scrollTo(tester, find.text('Approve & Award 15 Points'));
      expect(
        tester.getSize(find.byKey(const ValueKey('review-approve'))).height,
        54,
      );
      expect(
        tester
            .getSize(find.byKey(const ValueKey('review-request-changes')))
            .height,
        greaterThanOrEqualTo(50),
      );

      // Content rhythm: six 18px section gaps in one scrollable column.
      expect(
        find.byWidgetPredicate(
          (widget) => widget is SizedBox && widget.height == 18,
        ),
        findsNWidgets(6),
      );
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('renders from the review data object', (tester) async {
      const review = TaskReviewData(
        taskTitle: 'Water Plants',
        pointsPillLabel: '★ +10 pts',
        dueLabel: 'Due tomorrow by 6 PM',
      );
      await _pumpScreen(tester, review: review);

      expect(find.text('Water Plants'), findsOneWidget);
      expect(find.text('★ +10 pts'), findsOneWidget);
      expect(find.text('Due tomorrow by 6 PM'), findsOneWidget);
      expect(find.text('Fold Laundry'), findsNothing);
    });
  });
}
