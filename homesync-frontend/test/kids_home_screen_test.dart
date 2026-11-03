import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:homesync/views/home/kids_home_screen.dart';

Future<void> _pumpKidsHome(
  WidgetTester tester, {
  KidsHomeScreen Function()? build,
}) async {
  await tester.pumpWidget(
    MaterialApp(home: build?.call() ?? const KidsHomeScreen()),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('Kids Home TODO shell (Figma 5:50, specs not retrieved)', () {
    testWidgets('scaffold uses the verified cream background', (tester) async {
      await _pumpKidsHome(tester);

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, const Color(0xFFFBF7EF));
    });

    testWidgets('renders TODO placeholders, no invented content',
        (tester) async {
      await _pumpKidsHome(tester);

      expect(find.textContaining('TODO(Figma 5:50)'), findsWidgets);
      expect(find.text('TODO(Figma 5:50): header greeting + child name'),
          findsOneWidget);
      expect(
          find.text(
              'TODO(Figma 5:50): task list — names, points, times, icons'),
          findsOneWidget);
      expect(find.text('TODO(Figma 5:50): rewards / progress widgets'),
          findsOneWidget);
      expect(find.text('TODO(Figma 5:50): bottom navigation tabs'),
          findsOneWidget);
    });

    testWidgets('placeholder text uses Nunito + verified tokens',
        (tester) async {
      await _pumpKidsHome(tester);

      final header = tester.widget<Text>(
          find.text('TODO(Figma 5:50): header greeting + child name'));
      expect(header.style?.fontFamily, 'Nunito');
      expect(header.style?.color, const Color(0xFF7C877A));

      final tasks = tester.widget<Text>(find.text(
          'TODO(Figma 5:50): task list — names, points, times, icons'));
      expect(tasks.style?.fontFamily, 'Nunito');
      expect(tasks.style?.color, const Color(0xFF5F7F55));
    });

    testWidgets('task list renders from the (empty) data array',
        (tester) async {
      expect(kidsTasks, isEmpty);
      await _pumpKidsHome(tester);

      // No task rows exist; only the empty-state placeholder.
      expect(find.byIcon(Icons.radio_button_unchecked_rounded), findsNothing);
      expect(find.byIcon(Icons.check_circle_rounded), findsNothing);
    });

    testWidgets('placeholder handlers fire', (tester) async {
      final calls = <String>[];
      await _pumpKidsHome(
        tester,
        build: () => KidsHomeScreen(
          onAvatarPress: () => calls.add('avatar'),
          onRewardsPress: () => calls.add('rewards'),
        ),
      );

      await tester.tap(find.byIcon(Icons.person_rounded));
      await tester.tap(find.text('TODO(Figma 5:50): rewards / progress widgets'));
      await tester.pumpAndSettle();

      expect(calls, ['avatar', 'rewards']);
    });
  });
}
