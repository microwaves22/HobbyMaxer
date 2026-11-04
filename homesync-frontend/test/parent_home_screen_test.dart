import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:homesync/views/home/parent_home_screen.dart';

Future<void> _pumpParentHome(
  WidgetTester tester, {
  ParentHomeScreen Function()? build,
}) async {
  await tester.pumpWidget(
    MaterialApp(home: build?.call() ?? const ParentHomeScreen()),
  );
  await tester.pumpAndSettle();
}

TextStyle _styleOf(WidgetTester tester, String text) {
  final widget = tester.widget<Text>(find.text(text));
  final style = widget.style;
  expect(style, isNotNull, reason: '$text has an explicit style');
  return style!;
}

void _expectInter(
  TextStyle style, {
  required FontWeight weight,
  required double size,
  required Color color,
}) {
  expect(style.fontFamily, 'Inter');
  expect(style.fontWeight, weight);
  expect(style.fontSize, size);
  expect(style.color, color);
}

void main() {
  group('Parent Home matches the Figma 04 spec', () {
    testWidgets('scaffold uses the cream background', (tester) async {
      await _pumpParentHome(tester);

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, const Color(0xFFF9F8F6));
    });

    testWidgets('header greeting, actions, and order', (tester) async {
      await _pumpParentHome(tester);

      _expectInter(
        _styleOf(tester, 'Good morning,'),
        weight: FontWeight.w500,
        size: 14,
        color: const Color(0xFF7C877A),
      );
      _expectInter(
        _styleOf(tester, 'Sarah!'),
        weight: FontWeight.w800,
        size: 26,
        color: const Color(0xFF2B3A2B),
      );
      _expectInter(
        _styleOf(tester, 'Assign Tasks'),
        weight: FontWeight.w700,
        size: 13,
        color: const Color(0xFF7A9A85),
      );
      expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsOneWidget);
      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);

      // Actions order: Assign Tasks pill, bell, avatar.
      final pillX = tester.getCenter(find.text('Assign Tasks')).dx;
      final bellX = tester
          .getCenter(find.byIcon(Icons.notifications_outlined))
          .dx;
      final avatarX = tester.getCenter(find.text('👩').first).dx;
      expect(pillX, lessThan(bellX));
      expect(bellX, lessThan(avatarX));
    });

    testWidgets('stats row values, labels, and tiles', (tester) async {
      await _pumpParentHome(tester);

      for (final entry in {
        '3': 'Events',
        '4': 'Tasks Due',
        '2': 'Approvals',
      }.entries) {
        _expectInter(
          _styleOf(tester, entry.key),
          weight: FontWeight.w800,
          size: 24,
          color: const Color(0xFF2B3A2B),
        );
        _expectInter(
          _styleOf(tester, entry.value),
          weight: FontWeight.w600,
          size: 12,
          color: const Color(0xFF7C877A),
        );
      }
      // Stat tile, two overview tiles, and the Tasks nav tab.
      expect(find.byIcon(Icons.checklist_rounded), findsNWidgets(4));
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('quick overview is text only, no progress widgets',
        (tester) async {
      await _pumpParentHome(tester);

      _expectInter(
        _styleOf(tester, 'Ava 8 · 3/4 tasks done'),
        weight: FontWeight.w700,
        size: 13,
        color: const Color(0xFF7A9A85),
      );
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('review queue header, chips, and banner', (tester) async {
      await _pumpParentHome(tester);

      _expectInter(
        _styleOf(tester, 'Parent Review Queue'),
        weight: FontWeight.w700,
        size: 13,
        color: const Color(0xFF7A9A85),
      );
      _expectInter(
        _styleOf(tester, '3 items'),
        weight: FontWeight.w600,
        size: 11,
        color: const Color(0xFF7C877A),
      );
      _expectInter(
        _styleOf(tester, '2 approvals'),
        weight: FontWeight.w700,
        size: 12,
        color: const Color(0xFF4A6A41),
      );
      _expectInter(
        _styleOf(tester, '1 reward request'),
        weight: FontWeight.w700,
        size: 12,
        color: const Color(0xFF4A6A41),
      );
      _expectInter(
        _styleOf(tester, 'Reward request · Noah'),
        weight: FontWeight.w600,
        size: 11,
        color: const Color(0xFF4A6A41),
      );
      _expectInter(
        _styleOf(tester, 'Go to trampoline park'),
        weight: FontWeight.w700,
        size: 13,
        color: const Color(0xFF2B3A2B),
      );
      _expectInter(
        _styleOf(tester, '200 points requested · 120 available'),
        weight: FontWeight.w600,
        size: 10,
        color: const Color(0xFF4A6A41),
      );
      _expectInter(
        _styleOf(tester, 'Review'),
        weight: FontWeight.w800,
        size: 13,
        color: const Color(0xFFFFFFFF),
      );
    });

    testWidgets('overview rows read exactly, in order', (tester) async {
      await _pumpParentHome(tester);

      const titles = [
        'Laundry · Put away clothes',
        'Math Homework',
        'Family Dinner',
      ];
      const subtitles = [
        'Due by 5:00 PM',
        'Due by 6:00 PM',
        'Today at 7:00 PM',
      ];
      for (final title in titles) {
        _expectInter(
          _styleOf(tester, title),
          weight: FontWeight.w700,
          size: 14,
          color: const Color(0xFF2B3A2B),
        );
      }
      for (final subtitle in subtitles) {
        _expectInter(
          _styleOf(tester, subtitle),
          weight: FontWeight.w500,
          size: 12,
          color: const Color(0xFF7C877A),
        );
      }
      final tops = [
        for (final title in titles)
          tester.getTopLeft(find.text(title)).dy,
      ];
      expect(tops[0], lessThan(tops[1]));
      expect(tops[1], lessThan(tops[2]));
    });

    testWidgets('tip card copy and icon', (tester) async {
      await _pumpParentHome(tester);

      _expectInter(
        _styleOf(tester, 'Family Load Tip'),
        weight: FontWeight.w700,
        size: 13,
        color: const Color(0xFF2B3A2B),
      );
      _expectInter(
        _styleOf(tester, 'Thursday looks busy. Move one chore to Friday?'),
        weight: FontWeight.w500,
        size: 12,
        color: const Color(0xFF7C877A),
      );
      expect(find.byIcon(Icons.lightbulb_rounded), findsOneWidget);
    });

    testWidgets('bottom nav has four tabs, Home active', (tester) async {
      await _pumpParentHome(tester);

      _expectInter(
        _styleOf(tester, 'Home'),
        weight: FontWeight.w800,
        size: 11,
        color: const Color(0xFF7A9A85),
      );
      for (final label in ['Calendar', 'Tasks', 'Family']) {
        _expectInter(
          _styleOf(tester, label),
          weight: FontWeight.w600,
          size: 11,
          color: const Color(0xFF7C877A),
        );
      }
      expect(find.byIcon(Icons.home_rounded), findsOneWidget);
      expect(find.byIcon(Icons.group_rounded), findsNWidgets(2));
    });

    testWidgets('sections render in spec order', (tester) async {
      await _pumpParentHome(tester);

      final tops = [
        for (final text in [
          'Sarah!',
          'Tasks Due',
          'Ava 8 · 3/4 tasks done',
          'Parent Review Queue',
          "Today's Overview",
          'Family Dinner',
          'Family Load Tip',
        ])
          tester.getTopLeft(find.text(text)).dy,
      ];
      for (var i = 1; i < tops.length; i++) {
        expect(tops[i - 1], lessThan(tops[i]));
      }
    });
  });

  group('placeholder handlers', () {
    testWidgets('all handlers fire with the documented values',
        (tester) async {
      final calls = <String>[];
      await _pumpParentHome(
        tester,
        build: () => ParentHomeScreen(
          onAssignTasksPress: () => calls.add('assign'),
          onNotificationsPress: () => calls.add('notifications'),
          onAvatarPress: () => calls.add('avatar'),
          onStatCardPress: calls.add,
          onQuickOverviewPress: () => calls.add('overview'),
          onReviewRewardRequest: calls.add,
          onViewAllOverviewPress: () => calls.add('viewAll'),
          onOverviewItemPress: calls.add,
          onTipCardPress: () => calls.add('tip'),
          onTabPress: calls.add,
        ),
      );

      await tester.tap(find.text('Assign Tasks'));
      await tester.tap(find.byIcon(Icons.notifications_outlined));
      await tester.tap(find.text('👩').first);
      await tester.tap(find.text('Tasks Due'));
      await tester.tap(find.text('Ava 8 · 3/4 tasks done'));
      await tester.tap(find.text('Review'));
      await tester.tap(find.text('View All'));
      await tester.ensureVisible(find.text('Math Homework'));
      await tester.tap(find.text('Math Homework'));
      await tester.ensureVisible(find.text('Family Load Tip'));
      await tester.tap(find.text('Family Load Tip'));
      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle();

      expect(
        calls,
        [
          'assign',
          'notifications',
          'avatar',
          'tasksDue',
          'overview',
          'reward-noah-trampoline',
          'viewAll',
          'math-homework',
          'tip',
          'Calendar',
        ],
      );
    });
  });
}
